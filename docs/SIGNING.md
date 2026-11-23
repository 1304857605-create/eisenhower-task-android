# Android 签名与发布说明

> 本文写给准备自己构建 / 上架的同学。仓库里**不会**包含任何签名文件或密码；如果你只是安装使用，请直接下载 Releases 里的 APK。

## 0. 本项目当前的 release 签名（仅本地）

2026-11-23 构建并验证的 release APK 使用以下证书：

| 项 | 值 |
| --- | --- |
| keystore | `android/app/quadrant-release.jks`（已被 `.gitignore` 排除） |
| alias | `quadrant` |
| 证书 SHA-256 | `03:99:97:5A:10:56:5F:8B:68:25:6B:09:4F:7A:6A:E1:A9:59:89:4E:58:43:90:CB:A4:4E:3A:15:B8:73:D5:68` |
| 密码 | 保存在本地 `android/key.properties`，**不要提交或公开** |

> 上架后每次更新必须继续使用这张证书。请立即把 `.jks` 和密码备份到加密网盘/离线介质；丢失后无法更新已上架应用。

## 1. 为什么需要签名

Android 要求每个 APK 都有签名。应用上架后，**后续更新必须使用同一张证书签名**，否则商店会拒绝，用户也无法覆盖安装。因此：

- 签名文件（`.jks` / `.keystore`）和密码要自己妥善备份，至少存两份（本地 + 加密网盘）。
- 不要提交到 Git，不要发到公开群聊。
- 本项目已把 `android/key.properties`、`*.jks`、`*.keystore` 加入 `.gitignore`。

## 2. 生成自己的签名（推荐）

需要 JDK 17+（`keytool` 随 JDK 提供）。在仓库根目录执行：

```bash
keytool -genkeypair \
  -v \
  -keystore android/app/quadrant-release.jks \
  -alias quadrant \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storetype JKS
```

按提示设置：

- 密码：至少 6 位，建议 16 位以上，与 `key.properties` 保持一致；
- 姓名 / 组织 / 城市 / 省份 / 国家代码：按实际情况填写即可，会显示在证书里；
- 最后确认输入 `y`。

然后把 `android/key.properties.example` 复制为 `android/key.properties`，填入真实值：

```properties
storePassword=你的仓库密码
keyPassword=你的密钥密码
keyAlias=quadrant
storeFile=quadrant-release.jks
```

> `storeFile` 是相对于 `android/app/` 的路径。把 `.jks` 放在 `android/app/` 下时，直接写文件名即可。

## 3. 构建

```bash
flutter pub get
flutter build apk --release
# 或同时产出 AAB（部分渠道需要）
flutter build appbundle --release
```

产物：

- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

验证签名：

```bash
# JDK 的 apksigner 在 Android SDK build-tools 目录下
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

## 4. 没有 key.properties 时

`android/app/build.gradle.kts` 做了兜底：找不到 `key.properties` 时，release 构建会回退到 debug 签名，方便贡献者本地跑通构建。**这种 APK 不能上架**，只适合自己测试或 CI 构建。正式发布前务必按第 2 节生成并配置签名。

## 5. 上架小米应用商店

- 首次提交用签名后的 **APK**（小米商店当前以 APK 为主，具体以开发者后台要求为准）；
- 后续每次更新必须使用同一签名；
- 不要使用「加固 / 重签名」服务二次签名，除非你清楚会更换证书；
- 如果将来上架 Google Play，建议开启 Play App Signing；这与国内商店的签名策略不同，需分别保管。

## 6. 常见问题

**Q：签名文件丢了怎么办？**
A：无法找回。已上架的应用只能换新包名重新上架，或联系商店走特殊流程（通常很麻烦）。请务必备份。

**Q：可以在 CI 里签名吗？**
A：可以。把 keystore 转成 base64 存入 GitHub Actions Secrets，构建时还原；不要直接提交二进制文件。参考 `.github/workflows/android.yml` 中的注释。

**Q：`key.properties` 会被提交吗？**
A：不会，`.gitignore` 已排除。提交前可用 `git status` 再确认一次。
