# Agent 工作约定（PomoRun）

本文件用于约束代码与文档协作方式，适用于仓库全目录。

## 目标

- 优先完成 MVP：模式选择 + 固定 BPM 节拍提示
- 保持实现简单、可扩展到更多运动模式

## 代码风格与结构

- 语言：Dart（Flutter）
- 优先小而清晰的模块：`models/`、`features/`、`services/`、`ui/`
- 避免过早引入复杂架构（MVP 不上 Bloc/Riverpod，除非确有必要）
- 不做与 MVP 无关的“重构/抽象”

## 运行时原则

- 节拍器需要尽量稳定：使用“绝对时间 + 拍号”调度，避免 Timer 漂移累积
- UI 刷新低频即可（例如 200ms-500ms），不要每拍刷新 UI
- 振动默认关闭；开启后可用于“每拍短震 + 分段切换双震”（避免在高 BPM 默认打扰）
- 使用 `vibration` 插件时，优先保证跨平台可编译（不要依赖某些版本不存在的命名参数）

## 跨平台音频约定（tick）

- Android 优先走原生 `ToneGenerator`（MethodChannel），确保“能听见、低延迟”
- Web/桌面使用 `audioplayers` 播放短音（运行时生成 wav），避免 `SystemSound` 在部分平台无声
- Web 受自动播放策略限制：必须用户交互（点击开始）后才允许出声；需要在开始时 prime 一次音频

## 平台与体验约束

- MVP 默认前台运行；不承诺锁屏/后台长时间稳定提示
- iOS 静音/音频会话差异需在文档中说明，避免“看似 bug”

## 构建与排障

- 目标产物：Android `flutter build apk --release`
- Android Studio/JBR 常为 Java 21：确保 AGP `>= 8.2.1`，避免已知的 jlink/JdkImageTransform 构建错误
- 若卡在 `Running Gradle task 'assembleRelease'...`：优先判断是否在下载 Gradle；如遇 `*.zip.lck` 独占锁，结束残留进程并清理 `~/.gradle/wrapper/dists/**/**.lck` 与 `**.part` 后重试
- 可选优化：将 `android/gradle/wrapper/gradle-wrapper.properties` 的 `*-all.zip` 改为 `*-bin.zip` 以减少下载体积

## 文档规则

- 文档默认中文
- 配置（模式参数）要可直接映射为代码常量
