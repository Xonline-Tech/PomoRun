# PomoRun（MVP）

基于“番茄时钟式分段管理”的跑步/运动辅助工具（移动端）。

本仓库当前目标是 **MVP：只选择预设运动模式 + 固定步频（BPM）节拍提示**，不做步伐检测与自适应。

## MVP做什么

- 预设 5 种跑步模式（轻松慢跑/间歇跑/稳态长跑/节奏跑/超慢跑）
- 选择模式后进入训练会话
- 会话中提供固定 BPM 的节拍器提示音（tick）
- 按模式规则提供语音提醒（TTS）与振动提醒（可开关）
- 会话支持开始/暂停/结束（MVP 默认前台运行）

## MVP不做什么（明确边界）

- 不做计步/步频检测/自动配速建议
- 不做账号体系、云同步、社交分享
- 不做后台长时间保活保证（锁屏/后台体验后续再做）
- 不做复杂的勋章系统（如需，下一阶段补“连续完成/累计完成”）

## 技术栈（Flutter）

- Flutter（Dart）
- 音频短提示音：优先 `soundpool`（低延迟短音）；备选 `just_audio`
- 振动：`vibration`
- 语音提醒：`flutter_tts`
- 状态管理：MVP 使用 `ChangeNotifier` / `ValueNotifier`

## 快速开始（本地创建项目）

本仓库已包含 MVP 的 `lib/` 代码与 `pubspec.yaml`，但当前目录未包含 `android/ios` 等平台工程文件。

建议做法（任选其一）：

1) 在本仓库根目录执行 `flutter create .` 生成平台目录（如提示冲突，优先保留本仓库已有 `lib/` 代码）。
2) 新建一个 Flutter 工程，然后把本仓库的 `lib/`、`pubspec.yaml`、`docs/` 拷贝进去。

1) 创建 Flutter 工程

```bash
flutter create pomorun
cd pomorun
```

2) 把本仓库的 `lib/`、`pubspec.yaml`、`docs/` 和 `AGENTS.md` 复制进工程根目录。

3) 按 `docs/MVP.md` 开始实现。

## 文档

- `docs/MVP.md`：MVP 需求、页面、模块、实现要点
- `docs/Modes.md`：预设模式配置与“脚本化分段”定义

## 下一步建议

1) 先实现“模式选择 -> 会话页 -> 节拍器 tick”完整闭环
2) 再接入语音/振动提醒
3) 最后做最小可用的完成记录与（可选）简单勋章
