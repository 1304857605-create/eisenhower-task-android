# 贡献指南

感谢你愿意为「四象限清单」做点什么。这是一个面向 Android 的极简四象限待办应用，功能范围刻意保持克制，因此**「不做什么」和「做什么」同样重要**——加功能之前，请先读一遍 [README 的功能范围](README.md#功能1000) 和 [路线图](README.md#路线图)。

参与本项目即表示你同意：你的贡献以 [GPL-3.0](LICENSE) 授权发布。

## 目录

- [开始之前](#开始之前)
- [开发环境](#开发环境)
- [本地开发流程](#本地开发流程)
- [分支命名](#分支命名)
- [提交信息规范](#提交信息规范)
- [代码风格](#代码风格)
- [测试](#测试)
- [Pull Request 要求](#pull-request-要求)
- [Issue 建议](#issue-建议)
- [不要提交的内容](#不要提交的内容)
- [行为准则](#行为准则)
- [联系方式](#联系方式)

## 开始之前

适合贡献的方向：

- 修复 Bug、改进无障碍与可用性；
- 优化界面细节、动画与深色模式表现；
- 补充测试、文档与翻译（当前仅中文界面）；
- 在 Issue 中复现并确认他人报告的问题。

在动手写代码前，建议先开一个 Issue 说明你想做什么，避免与已在进行的工作重复，也避免实现一个不在 1.0.0 范围内的功能。

**以下改动通常不会被合并**：云同步、账号体系、提醒推送、广告或统计 SDK、任何需要新增 Android 权限的功能、引入除 `shared_preferences` 之外的新依赖（除非有充分理由）。这些限制来自产品定位，不是技术保守。

## 开发环境

| 组件 | 版本 |
| --- | --- |
| Flutter | 3.50.1 stable |
| Dart | 3.14 |
| JDK | 17 或更高 |
| Android SDK | Platform 36 |
| 目标设备 | Android 7.0+（minSdk 24） |

检查环境：

```bash
flutter --version
flutter doctor -v
```

## 本地开发流程

```bash
# 1. Fork 仓库后克隆自己的 fork
git clone https://github.com/<你的用户名>/quadrant-todo.git
cd quadrant-todo

# 2. 从 main 拉出功能分支
git checkout -b feat/your-change main

# 3. 安装依赖
flutter pub get

# 4. 开发与自测
flutter analyze
flutter test
flutter run

# 5. 提交并推送
git push -u origin feat/your-change
```

调试包可直接 `flutter run` 或在本地构建：

```bash
flutter build apk --debug
```

release 构建需要签名配置，请参考 [docs/SIGNING.md](docs/SIGNING.md)，**不要把签名文件提交到仓库**。

## 分支命名

以 `main` 为默认分支，分支名使用小写英文与短横线：

| 类型 | 格式 | 示例 |
| --- | --- | --- |
| 新功能 | `feat/<简短描述>` | `feat/quick-add-task` |
| 修复 | `fix/<简短描述>` | `fix/drag-drop-jitter` |
| 文档 | `docs/<简短描述>` | `docs/privacy-wording` |
| 重构 | `refactor/<简短描述>` | `refactor/task-edit-page` |
| 测试 | `test/<简短描述>` | `test/quadrant-model` |
| 杂项 | `chore/<简短描述>` | `chore/upgrade-deps` |

一个分支只做一件事。不要在同一个 PR 里混合功能、重构与格式化。

## 提交信息规范

采用 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/v1.0.0/) 风格，首行简明说明改了什么：

```text
<type>(<scope>): <subject>
```

- `type`：`feat` / `fix` / `docs` / `refactor` / `test` / `chore`
- `scope`：可选，如 `home`、`settings`、`storage`、`privacy`
- `subject`：动词开头的简短描述，中文或英文均可，不加句号

示例：

```text
feat(home): 支持长按拖动任务到其他象限
fix(storage): 修复导入 JSON 后完成状态丢失
docs(privacy): 补充 shared_preferences 的说明
```

提交前确保 `.gitignore` 生效：不要提交 `build/`、`.dart_tool/`、`*.iml` 等产物。

## 代码风格

- 遵循 Flutter / Dart 官方规范，使用 `dart format` 统一格式（不要手动对抗格式化结果）；
- 提交前必须通过：

  ```bash
  flutter analyze
  ```

  该命令应输出 `No issues found!`；
- 使用 Material 3 组件与主题颜色，不要在页面里硬编码颜色；四象限色值统一取自主题常量（Q1 `#E5484D`、Q2 `#3B82F6`、Q3 `#E8A33D`、Q4 `#8B8D98`）；
- 界面文案使用中文，简洁、不加感叹号与营销词；
- 状态管理尽量简单：优先 `StatefulWidget` + 轻量服务类，不引入额外状态管理库；
- 新增依赖前先讨论：本项目目前唯一的第三方依赖是 `shared_preferences`；
- 注意无障碍：可点击区域不小于 48dp，图标按钮提供 `tooltip` / `semanticLabel`。

## 测试

- 修复 Bug 时尽量补一个能复现问题的测试；
- 新增逻辑优先写单元测试（数据模型、JSON 导入导出、象限排序等）；
- 涉及界面交互的改动，补充对应的 Widget 测试；
- PR 提交前本地运行：

  ```bash
  flutter test
  ```

## Pull Request 要求

提交 PR 时请填写以下信息，保持简短清晰：

1. **做了什么**：一句话概括改动；
2. **为什么**：关联的 Issue 编号（如 `Closes #12`）；
3. **怎么验证**：复现/测试步骤，附截图或录屏（涉及界面时）；
4. **影响面**：是否影响数据格式、导入导出兼容性、权限声明。

合并前应满足：

- [ ] `flutter analyze` 无告警；
- [ ] `flutter test` 全部通过；
- [ ] 只包含与本次改动相关的提交，已 rebase 到最新 `main`；
- [ ] 涉及界面的改动附截图，涉及数据格式的改动说明兼容性；
- [ ] 没有新增权限、没有新增网络请求、没有引入未讨论的依赖。

维护者可能会直接编辑你的分支或在合并时压缩提交。

## Issue 建议

提交 Issue 前先搜索是否已有相同问题。建议使用以下模板方向：

- **Bug 报告**：应用版本（设置 → 关于）、设备型号、Android 版本、复现步骤、预期与实际结果、截图/录屏；
- **功能建议**：使用场景、期望行为、为什么现有功能无法满足（请先对照 README 的功能范围）；
- **文档问题**：具体文件与错误位置。

一个 Issue 只讨论一个问题。不要上传包含真实待办内容的截图。

## 不要提交的内容

以下文件/信息**绝不能**进入仓库或 PR：

- Android 签名文件：`*.jks`、`*.keystore`；
- 签名配置：`android/key.properties`、任何包含 `storePassword` / `keyPassword` 的文件；
- 本地路径与机器配置：`android/local.properties`、`.env`、IDE 个人配置；
- 构建产物与缓存：`build/`、`.dart_tool/`、`*.apk`、`*.aab`；
- 任何密钥、Token、证书、个人隐私数据。

怀疑误提交了敏感信息时，请立即联系维护者，并先撤销（revoke）对应密钥——单靠后续提交删除并不能从历史中抹去。

## 行为准则

- 讨论对事不对人，保持友善与耐心；
- 尊重不同的使用习惯与需求，不贬低他人的用法；
- 不接受骚扰、歧视或攻击性言论；
- 维护者有权关闭不符合项目范围或氛围的 Issue / PR，并说明理由。

## 联系方式

- 邮箱：<1304857605@qq.com>
- Issue：<https://github.com/1304857605-create/quadrant-todo/issues>

提交前如有疑问，建议先开 Issue 讨论，比直接提交一个大 PR 更高效。
