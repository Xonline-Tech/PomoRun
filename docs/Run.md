# 本地运行（Flutter）

本仓库在当前环境中未包含 `android/ios` 平台工程目录（因为本环境未安装 Flutter SDK）。

请在你本机安装 Flutter 后，按以下方式运行。

## 方式 A：在本仓库根目录补齐平台工程

```bash
flutter create . --project-name pomorun
flutter pub get
flutter run
```

如果 `flutter create` 提示文件冲突：

- 以本仓库的 `lib/` 为准
- 以本仓库的 `pubspec.yaml` 为准

## 方式 B：新建工程后拷贝代码

```bash
flutter create pomorun
cd pomorun
```

然后将本仓库的：

- `lib/`
- `pubspec.yaml`
- `docs/`
- `AGENTS.md`

覆盖/拷贝到新工程中，再执行：

```bash
flutter pub get
flutter run
```
