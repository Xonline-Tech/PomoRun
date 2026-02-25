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
- tick（节拍提示音）：
  - Android：原生 `ToneGenerator`（通过 `MethodChannel` 调用，延迟更低、更稳定）
  - Web/桌面：运行时生成短 `wav` 蜂鸣并播放（`audioplayers`）
  - 兜底：系统 `SystemSound.click`
- 振动：`vibration`
- 语音提醒：`flutter_tts`
- 状态管理：MVP 使用 `ChangeNotifier` / `ValueNotifier`

## 快速开始

本仓库已是完整 Flutter 工程。

```bash
flutter pub get
flutter run
```

编译 APK：

```bash
flutter build apk --release
```

产物默认在：`build/app/outputs/flutter-apk/app-release.apk`。

生成 App 图标（Android/iOS/Web/桌面各自会有输出）：

```bash
dart run flutter_launcher_icons
```

## 文档

- `docs/MVP.md`：MVP 需求、页面、模块、实现要点
- `docs/Modes.md`：预设模式配置与“脚本化分段”定义
- `docs/Run.md`：运行、编译 APK、常见卡住问题处理

## 下一步建议

1) 先实现“模式选择 -> 会话页 -> 节拍器 tick”完整闭环
2) 再接入语音/振动提醒
3) 最后做最小可用的完成记录与（可选）简单勋章

## 平台说明

- Web：浏览器有自动播放限制，必须用户点击“开始训练”后才允许出声；若仍无声请检查浏览器站点音频权限/标签页是否静音。
- Android：需要 `VIBRATE` 权限；会话页右上角可分别开关“声音/语音/振动”。
