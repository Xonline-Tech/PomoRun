# 本地运行（Flutter）

本仓库已包含 `android/ios` 等平台目录，可直接运行与打包。

## 运行（调试）

```bash
flutter pub get
flutter run
```

## 编译 APK（Release）

```bash
flutter pub get
flutter build apk --release
```

APK 输出：`build/app/outputs/flutter-apk/app-release.apk`

## 常见问题：卡在 "Running Gradle task 'assembleRelease'..."

第一次构建常见原因是 Gradle/依赖下载（尤其是 Gradle distribution），可能会“看起来像卡住”。

建议按顺序排查：

1) 等待 3-10 分钟（首次下载正常）
2) 看是否在下载 Gradle：检查 `~/.gradle/wrapper/dists/` 下是否存在 `*.part` 文件且大小在增长
3) 如果出现类似“waiting for exclusive access ... *.zip.lck”的报错，说明有残留锁或另一个 Gradle 进程在占用：

```bash
pkill -f GradleWrapperMain || true
rm -f ~/.gradle/wrapper/dists/*/*/*.lck
rm -f ~/.gradle/wrapper/dists/*/*/*.part
flutter clean
flutter build apk --release
```

4) 可选优化：把 `android/gradle/wrapper/gradle-wrapper.properties` 的 `distributionUrl` 从 `*-all.zip` 改成 `*-bin.zip`，能显著减少下载体积。

## 常见问题：Gradle 下载依赖失败（TLS 握手 / 网络）

现象示例：

- `Could not download ... from https://repo.maven.apache.org/maven2/...`
- `Remote host terminated the handshake`

处理建议（优先级从高到低）：

1) 确认网络/代理可访问 Maven Central 与 Google Maven
2) 若处于网络受限环境：在 Gradle 仓库源加入可用镜像（本仓库已在 `android/settings.gradle` 与 `android/build.gradle` 加入镜像源）
3) 仍失败时：检查是否被公司网关/杀软拦截 TLS，或在系统层面配置代理

## 常见问题：Java 21 + 旧 AGP 导致 jlink 失败

现象示例：

- `Failed to transform core-for-system-modules.jar`
- `Execution failed for JdkImageTransform ... jlink`

原因：Android Studio 自带 JBR 往往是 Java 21；当 Android Gradle Plugin (AGP) < 8.2.1 且项目设置了 `sourceCompatibility` 时，会触发已知 bug。

处理：升级 AGP 到 `>= 8.2.1`（本仓库已在 `android/settings.gradle` 使用 `com.android.application` 8.2.2）。
