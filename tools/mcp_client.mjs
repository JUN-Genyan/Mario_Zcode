#!/usr/bin/env node
// Minimal MCP stdio client used to drive the Fennara MCP server (bridge to the
// running Godot editor).
//
// Usage:
//   node tools/mcp_client.mjs --list
//   node tools/mcp_client.mjs <tool_name> ['{"json":"args"}'] [--timeout=180000]
//
// Text content parts are printed to stdout; image parts are saved under
// tools/out/ and referenced by path.

import { spawn } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const EXE = "C:\\Users\\27200\\AppData\\Local\\Fennara\\bin\\fennara-mcp.exe";
const OUT_DIR = path.join(path.dirname(fileURLToPath(import.meta.url)), "out");

const rawArgs = process.argv.slice(2);
let timeoutMs = 180000;
const positional = [];
for (const a of rawArgs) {
  const m = a.match(/^--timeout=(\d+)$/);
  if (m) timeoutMs = Number(m[1]);
  else positional.push(a);
}

const proc = spawn(EXE, [], { stdio: ["pipe", "pipe", "pipe"] });
let buf = "";
const pending = new Map();
let nextId = 1;

proc.stdout.on("data", (d) => {
  buf += d.toString("utf8");
  let idx;
  while ((idx = buf.indexOf("\n")) >= 0) {
    const line = buf.slice(0, idx).trim();
    buf = buf.slice(idx + 1);
    if (!line) continue;
    let msg;
    try { msg = JSON.parse(line); } catch { continue; }
    if (msg.id !== undefined && pending.has(msg.id)) {
      const entry = pending.get(msg.id);
      pending.delete(msg.id);
      clearTimeout(entry.timer);
      entry.resolve(msg);
    }
  }
});
proc.stderr.on("data", (d) => process.stderr.write(d));
proc.on("exit", (code) => {
  for (const [, entry] of pending) entry.reject(new Error(`fennara-mcp exited (code ${code})`));
});

function send(obj) {
  proc.stdin.write(JSON.stringify(obj) + "\n");
}

function request(method, params, timeout = timeoutMs) {
  const id = nextId++;
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      pending.delete(id);
      reject(new Error(`timeout (${timeout} ms) waiting for ${method}`));
    }, timeout);
    pending.set(id, { resolve, reject, timer });
    send({ jsonrpc: "2.0", id, method, params });
  });
}

async function handshake() {
  const versions = ["2024-11-05", "2025-06-18", "2025-03-26"];
  let lastErr = null;
  for (const v of versions) {
    try {
      const res = await request("initialize", {
        protocolVersion: v,
        capabilities: {},
        clientInfo: { name: "zcode-mcp-bridge", version: "1.0.0" },
      }, 60000);
      send({ jsonrpc: "2.0", method: "notifications/initialized" });
      return res.result;
    } catch (e) {
      lastErr = e;
    }
  }
  throw lastErr;
}

function printResult(result, toolName) {
  const outs = [];
  let img = 0;
  for (const part of result.content ?? []) {
    if (part.type === "text") outs.push(part.text);
    else if (part.type === "image") {
      mkdirSync(OUT_DIR, { recursive: true });
      const f = path.join(OUT_DIR, `${toolName}_${Date.now()}_${img++}.${(part.mimeType || "image/png").split("/")[1]}`);
      writeFileSync(f, Buffer.from(part.data, "base64"));
      outs.push(`[image saved: ${f}]`);
    } else outs.push(JSON.stringify(part));
  }
  if (result.structuredContent) outs.push("[structured] " + JSON.stringify(result.structuredContent));
  console.log(outs.join("\n") || "(empty result)");
}

async function main() {
  try {
    const info = await handshake();
    if (process.env.MCP_DEBUG) console.error(`connected: ${JSON.stringify(info.serverInfo)} proto=${info.protocolVersion}`);

    if (positional[0] === "--list") {
      const res = await request("tools/list", {});
      for (const t of res.result.tools) {
        console.log(`\n### ${t.name}`);
        console.log((t.description || "").trim());
        if (t.inputSchema) console.log("schema: " + JSON.stringify(t.inputSchema));
      }
    } else if (positional.length >= 1) {
      const [tool, ...rest] = positional;
      let toolArgs = {};
      if (rest.length) {
        try { toolArgs = JSON.parse(rest.join(" ")); }
        catch (e) { throw new Error(`invalid JSON args: ${e.message}`); }
      }
      const res = await request("tools/call", { name: tool, arguments: toolArgs });
      if (res.error) { console.error("JSON-RPC error: " + JSON.stringify(res.error)); process.exit(1); }
      printResult(res.result ?? {}, tool);
      if (res.result?.isError) process.exit(2);
    } else {
      console.error("usage: mcp_client.mjs --list | <tool> [jsonArgs] [--timeout=ms]");
      process.exit(64);
    }
  } catch (e) {
    console.error("FATAL: " + e.message);
    process.exit(1);
  } finally {
    try { proc.stdin.end(); } catch {}
    setTimeout(() => proc.kill(), 1500);
  }
}

await main();
