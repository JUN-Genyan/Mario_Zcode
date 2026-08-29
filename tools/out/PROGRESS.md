# mario-workbuddy 进度交接（2026-08-29 更新：项目已全部完成 ✅）

## 最终状态：全部完成并实测通过
在 2026-08-28 基础上，2026-08-29 补齐了三个 UI 界面并完成全部验证：

- **标题屏** `scenes/ui/title.tscn`（主场景）：空格/回车开始、Esc 退出、闪烁提示、操作说明。运行时实测：空格 → change_scene 到 Level1 ✓
- **暂停层** `scenes/ui/pause_menu.tscn`（实例化进 level_1，PROCESS_MODE_ALWAYS，layer=10）：Esc/P 切换暂停；暂停时空格继续、R 重开本关、Q 退出游戏。运行时实测：paused=true/panel 显示 ✓、恢复 ✓、重复暂停 ✓、Q 进程干净退出 ✓
- **退出界面**：暂停菜单 Q = 退出游戏；标题屏 Esc = 退出游戏（get_tree().quit()）
- **胜利/失败 → 回标题**：level_1.gd 的 GAME OVER(1.6s)/通关(2.5s) 计时器调用 `_back_to_title()` → change_scene_to_file(title)。运行时实测：调用后 current_scene=TitleScreen ✓
- 新增输入动作：pause=Esc/P、quit_game=Q（经编辑器 worker 写入，KEY_* 常量）
- 踩过的坑：title.tscn 三个 Label 最初只设了水平居中锚点，垂直仍为 0，负偏移把大标题排到屏幕外——已改为 anchor_top/bottom=0.5 并截图复验
- 31 个脚本 script_diagnostics 全 0；主场景已设为 title.tscn；README.md 已更新

## 全部实测清单（runtime_session + runtime_script 探针）
跳跃 63.8px / 走路吃金币 / 顶?块出金币(+1币+100分) / 踩怪+100 / 敌人巡逻+击杀+扣命+重生 / 坠坑死亡重生 / 旗→LEVEL COMPLETE / 标题↔关卡双向切换 / 暂停恢复 / Q 退出

（下文为 2026-08-28 的构建过程记录与踩坑，仍有效）

## 已完成（全部经 Fennara MCP 在编辑器内构建，Godot 拥有序列化）
- **MCP 通道**：`tools/mcp_client.mjs`（Node stdio JSON-RPC 客户端 → fennara-mcp.exe → 运行中的 Godot 4.7.1 编辑器，活动项目 Mario_zcode）
  - 用法：`node tools/mcp_client.mjs --list` / `node tools/mcp_client.mjs <tool> '<json>' [--timeout=ms]`
- **项目设置**：960×540、canvas_items/keep、Nearest 过滤、天空蓝背景、物理层命名(world/player/enemy/pickup)、InputMap（move_left=A/←, move_right=D/→, jump=Space/W/↑, down=S/↓, restart=R）、autoload GameManager、主场景 level_1.tscn
- **素材**：kenney pixel-platformer（CC0）+ music(bgm_*.ogg) + sfx(sfx_*.ogg) + coin_sheet.png，复制自参考项目 D:/Godot/program/Mario（HANDOFF.md 是其交接文档）
- **脚本**（8 个，全部 0 诊断）：autoload/game_manager.gd、scenes/{player/player,enemies/enemy,items/coin,items/block,objects/flag,objects/platform,levels/level_1}.gd
- **场景**（8 个，run_scene_edit_script 编辑器序列化）：player/enemy/coin/block/flag/platform/hud + level_1.tscn（TileMapLayer 瓦片地形 + 21 金币 + 12 平台 + 4 ?块 + 13 木箱 + 5 敌人 + 旗 + 视差云山 + HUD）
- **validate_scene**：8 场景 3s 无头运行 0 崩溃 0 错误（77 条警告均为 /root/GameManager 在分离上下文解析不到的预期误报）

## 实测验证结果（runtime_session + runtime_script 探针，用 Engine.get_main_loop()+physics_frame）
- ✅ 跳跃 63.8px（可顶到 ?块）
- ✅ 走路、地面金币收集（走 55px 收 2 枚）
- ✅ 敌人巡逻 AI、触碰玩家致死、扣命、重生
- ✅ 踩怪 +100 分（第一会话实测）
- ✅ 坠坑死亡：lives 2→1、重生回出生点
- ✅ 碰撞修复后：玩家站立中心 y=459、地面射线 468（与视觉瓦片顶完全对齐）

## 待验证/待修（明天自动化任务）
1. **顶 ?块出金币**：上次探针站位算错列——地图 row22 = X Q X Q X @ col13-17，即 Crate1 在 x=243、**QBlock1 在 x=261**。settle (261,430) 跳跃，检查 QBlock1.used + coins/score 增加（crate 在 x=243 已实测 bump 路径生效）
2. **踩怪探针改进**：上一敌人位置静态落点会脱靶；落下期间每帧跟随敌人 x 再判断 stomped
3. **终点旗**：旗实际在 **x=1053**（col58），上次 settle 1035 差 18px 未触发——settle (1053,430) 验证 completed=true + "LEVEL COMPLETE!"
4. 若有真实 bug → write_or_update_file / run_scene_edit_script 修复 → 重跑探针
5. 收尾：README.md（玩法/操作/架构/运行方法）、script_diagnostics scan_project:true、runtime_session stop、清理 tools/dev_context.tscn 与 tools/out 临时 json（保留 mcp_client.mjs 与素材）、输出中文总结

## 关键教训（勿重蹈）
- **Godot 4.7 TileSet 物理多边形坐标以瓦片中心为原点**：整格方块应为 (-9,-9)-(9,9)。参考项目用 (0,0)-(18,18) 导致碰撞面下沉 9px 且每块左半无碰撞——已用 worker 把 tile_set.tres 13 块瓦片改为居中并 ResourceSaver.save
- run_scene_edit_script 重跑会重复添加节点：重建场景前先删 .tscn(+.uid)
- 游戏窗口会弹在用户桌面，可能被手动关闭（会话多次"干净退出"的原因）→ 启动后立即发探针；探针开头设 player.invincible=999 防敌人干扰（坠坑 die() 不受无敌影响，仍可测）
- 探针必须 `await tree.physics_frame`（ctx.frame 是渲染帧，物理不推进）
- project_settings 工具写 input/* 会挂起、键码是 Godot 3 旧值——一律用编辑器 worker 改（KEY_* 常量）
- .tscn/.tres 不要手写文本，一切经编辑器 API；地图改布局改 tools/src/w_level.gd 后删场景重建
- kenney 图集：草地顶(0-3,0)、绿填充(17-19,1)、?块(8,1)、木箱(9,1)；仅 (0-3,0),(17-19,0),(17-19,1),(4-6,4) 有碰撞；角色帧 tilemap-characters.png 24px 步进 25（玩家行0：0/25/50/75，敌人行 y=25：50/75）
- Fennara 工具超时后按 operations.md 查 tool_logs，勿盲目重发
