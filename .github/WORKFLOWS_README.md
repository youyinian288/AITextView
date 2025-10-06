# 🚀 GitHub Actions 工作流说明

这个文档介绍了为 RichEditorView 项目设置的 GitHub Actions CI/CD 流水线。

## 📋 工作流概览

### 1. 🔄 持续集成 (CI) - `ci.yml`

**触发条件:**
- 推送到 `master`, `main`, `develop` 分支
- 创建 Pull Request 到这些分支

**包含的任务:**

#### 🏗️ Swift Package Manager 构建
- 测试多个 Xcode 版本 (15.2, 14.3.1)
- 测试多个 iOS 版本 (17.2, 16.4, 15.5, 13.7, 12.4)
- 验证包结构和依赖

#### 📱 框架构建和测试
- 在不同 iOS 模拟器上构建
- 运行单元测试
- 验证框架兼容性

#### 🎯 示例应用构建
- 构建 SwiftUI 示例应用
- 构建 UIKit 示例应用
- 确保集成正确性

#### 📦 CocoaPods 验证
- 验证 `.podspec` 文件
- 检查 Pod 库语法

#### 🔍 代码质量检查
- SwiftLint 代码规范检查
- 代码格式验证

#### 🛡️ 安全扫描
- CodeQL 静态代码分析
- 安全漏洞检测

#### 📚 文档检查
- 验证必要的文档文件存在
- 检查项目配置文件

#### 🎯 发布就绪性检查
- 版本一致性验证
- 生成发布就绪报告

### 2. 🚀 自动发布 - `release.yml`

**触发条件:**
- 推送版本标签 (格式: `1.2.3` 或 `1.2.3-beta`)

**发布流程:**

1. **验证标签**: 检查版本标签格式和一致性
2. **构建测试**: 运行完整的测试套件
3. **创建 XCFramework**: 构建通用框架文件
4. **CocoaPods 发布**: 自动发布到 CocoaPods (正式版本)
5. **GitHub 发布**: 创建 GitHub Release 和变更日志

## 🔧 设置说明

### 必需的 Secrets

在 GitHub 仓库设置中添加以下 Secrets:

```
COCOAPODS_TRUNK_TOKEN - CocoaPods 发布令牌
```

### 获取 CocoaPods Token:

```bash
# 注册 CocoaPods Trunk (如果还没有)
pod trunk register 你的邮箱 '你的名字'

# 获取 session token
pod trunk me
```

## 📂 添加的文件结构

```
.github/
├── workflows/
│   ├── ci.yml           # 持续集成工作流
│   └── release.yml      # 自动发布工作流
├── ISSUE_TEMPLATE/
│   ├── bug_report.md    # Bug 报告模板
│   └── feature_request.md # 功能请求模板
├── PULL_REQUEST_TEMPLATE.md # PR 模板
├── dependabot.yml       # 依赖自动更新配置
└── WORKFLOWS_README.md  # 工作流说明文档

.swiftlint.yml          # SwiftLint 配置文件
```

## 🎯 使用方法

### 开发工作流

1. **创建分支**: 从 `master` 创建功能分支
2. **编写代码**: 遵循代码规范
3. **提交 PR**: 系统自动运行 CI 检查
4. **代码审查**: 通过后合并到主分支

### 发布工作流

1. **更新版本**: 在 `RichEditorView.podspec` 中更新版本号
2. **创建标签**: 
   ```bash
   git tag 4.3.1
   git push origin 4.3.1
   ```
3. **自动发布**: 系统自动构建和发布

### 预发布版本

```bash
git tag 4.4.0-beta.1
git push origin 4.4.0-beta.1
```

## 📊 状态徽章

在 README.md 中添加状态徽章:

```markdown
[![CI Status](https://github.com/T-Pro/RichEditorView/workflows/CI/badge.svg)](https://github.com/T-Pro/RichEditorView/actions?query=workflow%3ACI)
[![Release Status](https://github.com/T-Pro/RichEditorView/workflows/Release/badge.svg)](https://github.com/T-Pro/RichEditorView/actions?query=workflow%3ARelease)
```

## 🔧 自定义配置

### 修改 CI 触发条件

在 `ci.yml` 中修改:

```yaml
on:
  push:
    branches: [ master, main, develop, feature/* ]
  pull_request:
    branches: [ master, main ]
```

### 添加更多测试平台

```yaml
matrix:
  destination: 
    - 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.2'
    - 'platform=iOS Simulator,name=iPad Pro,OS=17.2'
```

## 🎉 完成!

现在你的 RichEditorView 项目已经配置了完整的 CI/CD 流水线！每次代码变更都会自动测试，每次发布都会自动构建和分发。

**享受自动化的开发体验吧！** 🚀
