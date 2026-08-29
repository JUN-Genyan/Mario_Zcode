# Mario_zcode — 类 Mario 平台跳跃游戏

用 Godot 4.7.1 制作的单关卡横版平台跳跃游戏。全部场景与资源通过 **Fennara MCP** 在运行中的 Godot 编辑器内构建（节点由编辑器 API 创建、由 Godot 序列化），未手写任何 .tscn 文本。美术/音频来自 [kenney.nl](https://kenney.nl) CC0 素材包（pixel-platformer + 音乐/音效）。

## 运行

用 Godot 4.7+ 打开本文件夹，按 **F5** 运行（主场景已设为 `scenes/levels/level_1.tscn`）。

## 操作

| 按键 | 动作 |
| --- | --- |
| A / ← , D / → | 左右移动 |
| Space / W / ↑ | 跳跃（长按跳更高） |
| S / ↓ | 下穿单向平台 |
| R | 重新开始本关 |

## 玩法

- 标题屏按 **空格** 开始，**Esc** 退出游戏
- 踩踏敌人消灭（+100），侧向触碰敌人会损失一条命（共 3 条）
- 顶黄色 **?块** 弹出金币（+100），顶过的木箱会变旧
- 收集金币（每枚 +100），坠入深坑损失一条命
- 游戏中 **Esc/P** 暂停：空格继续、R 重开本关、Q 退出游戏
- 抵达终点旗通关，GAME OVER 或通关后自动返回标题屏

## 项目结构

```
project.godot                 # 输入映射、960×540、像素过滤、物理层命名、autoload
autoload/game_manager.gd      # 分数/金币/生命 + 信号 + BGM/音效（autoload 单例）
scenes/
  player/player.tscn          # CharacterBody2D：跑/跳（土狼时间+缓冲+可变跳高）、顶块、踩怪、Camera2D
  enemies/enemy.tscn          # CharacterBody2D 巡逻：RayCast2D 悬崖折返、离屏休眠、被踩粒子
  items/coin.tscn             # Area2D 金币（旋转动画），pop 模式供 ?块弹出
  items/block.tscn            # StaticBody2D ?块/木箱（content 导出变量：coin/none），顶块动画+变旧
  objects/platform.tscn       # 单向平台（按玩家位置动态开关碰撞层）
  objects/flag.tscn           # Area2D 终点旗（Polygon2D 旗杆+旗面、通关彩带粒子）
  objects/hud.tscn            # CanvasLayer HUD（分数/金币/生命 + 居中消息）
  ui/title.tscn               # 标题屏（主场景）：空格开始、Esc 退出、闪烁提示
  ui/pause_menu.tscn          # 暂停层（PROCESS_MODE_ALWAYS）：继续/重开/退出
  levels/level_1.tscn         # 关卡：TileMapLayer 地形（内嵌瓦片数据）+ 视差云山 + 全部实体实例
assets/pixel-platformer/      # kenney CC0 图集与 tile_set.tres（18px 瓦片+碰撞）
assets/music|sfx|generated/   # kenney CC0 BGM/音效/金币帧
tools/
  mcp_client.mjs              # Fennara MCP stdio 客户端（node tools/mcp_client.mjs --list）
  src/*.gd                    # 场景构建 worker 源码（w_level.gd 含 ASCII 关卡布局，改布局后经编辑器重建）
  out/PROGRESS.md             # 构建与验证过程记录
```

## 技术要点

- **碰撞层**：1=地形/块、2=玩家、4=单向平台、8=敌人（玩家 mask=1|4，敌人 layer=8，拾取/旗帜 Area mask=2）
- **TileSet 物理多边形以瓦片中心为原点**（Godot 4.7）：整格碰撞为 (-9,-9)-(9,9)
- 顶块判定在 `move_and_slide()` 前捕获 `was_rising`，撞天花板法线朝下即触发 `bump()`
- 探针/自动化测试：`runtime_session` + `runtime_script`，务必 `await tree.physics_frame`（渲染帧不推进物理）
