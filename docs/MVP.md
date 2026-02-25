# MVP 项目文档（Flutter）

本文件描述 PomoRun 的 MVP 版本范围、交互、模块划分与关键实现约束。

## 1. 产品定位

在运动中用“番茄时钟式的分段管理 + 稳定节拍提示”帮助用户坚持训练。

MVP 的核心闭环：

1) 选择一个预设模式
2) 进入会话
3) 按固定 BPM 播放节拍（tick）
4) 按规则进行语音/振动提醒
5) 结束会话并展示完成结果

## 2. MVP 功能清单

### 2.1 必做

- 预设模式列表（5 个）
- 模式详情（说明、注意事项、提醒规则）
- 会话页：开始/暂停/结束
- 节拍器：固定 BPM 的 tick
- 提醒：
  - 每 5 分钟鼓励（适用于部分模式）
  - 剩余 5 分钟/1 分钟提醒（节奏跑）
  - 间歇模式切换前 10 秒提醒
- 设置开关（至少在会话内提供）：声音/振动/语音

### 2.2 可选（不阻塞 MVP）

- BPM 微调（例如 +/- 1）
- 训练时长在建议范围内可调
- “保持亮屏”开关
- 结束页展示：总时长、各段用时（间歇）、是否完成

## 3. 预设模式定义

预设模式与脚本化分段见：`docs/Modes.md`。

实现上建议：把“模式配置”做成 Dart 常量（可直接映射为代码常量），会话开始时由配置生成 `segments`（分段列表）。

## 4. 页面与交互

### 4.1 模式列表页（ModeListPage）

- 展示模式卡片：名称、建议时长、速度感受一句话、默认 BPM
- 点击进入模式详情

### 4.2 模式详情页（ModeDetailPage）

- 展示：适合人群、注意事项、语音提醒规则
- 可调（可选）：
  - BPM：默认值 + 最小/最大
  - 时长：默认值 + 最小/最大
- 按钮：开始

### 4.3 会话页（SessionPage）

信息展示：

- 当前 BPM（大字）
- 当前分段：稳态/快跑/恢复（间歇模式）
- 总计时：已用/剩余
- 分段计时：本段剩余（间歇模式建议显示）

操作：

- 开始/暂停/继续
- 结束
- （可选）BPM +/-
- （可选）跳到下一段（仅间歇模式）

### 4.4 完成页（FinishPage，可选）

- 展示完成结果
- 返回模式列表

## 5. 模块划分（建议目录）

建议在 Flutter 工程内使用如下结构：

- `lib/models/`
  - `mode.dart`（模式配置结构）
  - `segment.dart`（分段结构）
  - `prompt_policy.dart`（提醒策略枚举）
- `lib/features/modes/`
  - `mode_list_page.dart`
  - `mode_detail_page.dart`
- `lib/features/session/`
  - `session_page.dart`
  - `session_controller.dart`（状态机）
- `lib/services/`
  - `metronome_engine.dart`（节拍器引擎）
  - `prompt_engine.dart`（提醒引擎）
  - `tick_player.dart`（tick 播放器封装；分平台实现，优先保证“能听见”）
  - `beep_wav.dart`（运行时生成短 wav 蜂鸣，供 Web/桌面使用）
  - `haptics.dart`（振动封装）
  - `tts_service.dart`（TTS 封装）
- `lib/ui/`
  - `theme.dart`、`widgets/`（MVP 可非常精简）

## 6. 关键实现约束（稳定节拍）

### 6.1 节拍器调度（必须遵守）

不要用“每次 tick 后 `Timer(period)` 再 schedule 下一拍”的方式累计漂移。

推荐做法：以会话开始的绝对时间为基准，用“拍号”计算下一拍应该发生的时间。

概念公式：

- `beatInterval = 60_000ms / bpm`
- `nextBeatAt = startAt + beatIndex * beatInterval`

实现时允许用小间隔 Timer（例如 10ms-30ms）轮询检查是否到点，或用单次 Timer 直接 schedule 到 `nextBeatAt - now`。

### 6.2 UI 刷新节流

- UI 刷新 200ms-500ms 即可
- 不要每拍刷新 UI（尤其是 180-200bpm）

### 6.3 振动默认策略

- 默认关闭振动（避免 180-200bpm 过度打扰）
- 开启振动后：
  - 每拍短震（用于“跟拍”）
  - 分段切换时双震（更明确的提示）

## 7. 提醒规则（MVP）

提醒分两类：

1) 时间点提醒（每 5 分钟、剩余 5 分钟/1 分钟）
2) 分段切换提醒（间歇模式切换前 10 秒）

建议：`PromptEngine` 每 200ms-500ms 跟随会话 tick 检查“是否触发某个提醒事件”，并保证同一事件只触发一次（去重）。

## 8. 平台行为说明（写进 App 内说明或 README）

- iOS 静音模式下提示音可能不可听；可开启振动/语音或关闭静音
- Web 端受浏览器自动播放策略限制：必须有用户交互（点击开始）后才允许出声
- MVP 默认前台运行；锁屏/后台稳定提示不承诺

## 9. 依赖建议（pubspec）

MVP 推荐：

- `flutter_tts`：语音提醒
- `vibration`：振动

MVP 当前实现：

- tick：
  - Android：原生 `ToneGenerator`（MethodChannel）
  - Web/桌面：运行时生成短 `wav` 蜂鸣并播放（`audioplayers`）
  - 兜底：系统 `SystemSound.click`

后续优化（可选）：

- `soundpool`：换成更低延迟的短音 tick（需要自带 wav 资源）

备选：

- `just_audio`：若 `soundpool` 兼容性/延迟不满足再替换
