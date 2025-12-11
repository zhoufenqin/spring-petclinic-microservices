# Cross-Repo Issue Creator - 简化版

这个 GitHub Action 可以轻松地在多个仓库中创建关联的 issues，只需要提供链接即可。

## 🚀 功能特点

- ✅ 直接输入 issue URL，无需手动复制标题和内容
- ✅ 支持多个目标仓库，一次创建多个关联 issue
- ✅ 自动添加源 issue 的链接
- ✅ 在源 issue 中自动添加指向新创建 issues 的评论
- ✅ 灵活的输入格式：支持完整 URL 或简写格式

## ⚙️ 配置步骤

### 1. 创建 Personal Access Token (PAT)

如果需要在**其他用户/组织的仓库**创建 issue，需要创建 PAT：

1. 访问 GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. 点击 "Generate new token (classic)"
3. 勾选 `repo` 权限（或 `public_repo` 如果都是公开仓库）
4. 复制生成的 token

### 2. 添加 Secret（如果需要）

如果目标仓库是你自己的仓库，可以**跳过这步**，直接使用默认的 `GITHUB_TOKEN`。

如果目标仓库是其他人的仓库：

1. 在当前仓库，访问 Settings → Secrets and variables → Actions
2. 点击 "New repository secret"
3. Name: `CROSS_REPO_TOKEN`
4. Value: 粘贴 PAT
5. 点击 "Add secret"

## 📝 使用方法

### 步骤 1：找到源 issue 的 URL

例如：`https://github.com/zhoufenqin/spring-petclinic-microservices/issues/10`

### 步骤 2：准备目标仓库列表

支持以下格式（可混用）：

**格式 1：完整 URL**
```
https://github.com/zhoufenqin/spring-petclinic-microservices-admin-service
https://github.com/zhoufenqin/spring-petclinic-microservices-custom-service
```

**格式 2：简写格式**
```
zhoufenqin/spring-petclinic-microservices-admin-service
zhoufenqin/spring-petclinic-microservices-custom-service
```

**格式 3：逗号分隔**
```
zhoufenqin/repo-a, zhoufenqin/repo-b, zhoufenqin/repo-c
```

### 步骤 3：运行 Workflow

1. 访问仓库的 **Actions** 页面
2. 选择 **"Create Cross-Repo Issues"** workflow
3. 点击 **"Run workflow"**
4. 填写表单：
   - **Source issue URL**: 粘贴源 issue 的完整 URL
   - **Target repo URLs**: 粘贴目标仓库列表（每行一个或逗号分隔）
5. 点击 **"Run workflow"** 按钮

就这么简单！

## 📋 示例

### 示例 1：基本用法

**Source issue URL:**
```
https://github.com/zhoufenqin/spring-petclinic-microservices/issues/10
```

**Target repo URLs:**
```
https://github.com/zhoufenqin/spring-petclinic-microservices-admin-service
https://github.com/zhoufenqin/spring-petclinic-microservices-custom-service
```

### 示例 2：使用简写格式

**Source issue URL:**
```
https://github.com/zhoufenqin/spring-petclinic-microservices/issues/10
```

**Target repo URLs:**
```
zhoufenqin/repo-backend
zhoufenqin/repo-frontend
zhoufenqin/repo-mobile
```

### 示例 3：混合格式 + 逗号分隔

**Target repo URLs:**
```
https://github.com/zhoufenqin/repo-a, zhoufenqin/repo-b, https://github.com/microsoft/vscode
```

## 📤 创建的 Issue 格式

新创建的 issue 会包含：

```markdown
[原始 issue 的内容]

==================================================
**Related Issue:** [zhoufenqin/spring-petclinic-microservices#10](URL)
**Source:** https://github.com/zhoufenqin/spring-petclinic-microservices/issues/10
```

同时，源 issue 会收到一条评论：

```markdown
Cross-repo issues created:

- [zhoufenqin/repo-backend#5](URL)
- [zhoufenqin/repo-frontend#12](URL)
```

## 🏷️ 自动标签

创建的 issues 会自动添加 `cross-repo` 标签，方便识别和过滤。

## ❓ 故障排查

### 问题 1：Token 权限不足

**错误信息：** `Resource not accessible by integration`

**解决方案：**
- 如果目标仓库是你自己的，确认仓库可以被访问
- 如果目标仓库是其他人的，需要创建 PAT 并添加为 `CROSS_REPO_TOKEN` secret

### 问题 2：无效的 URL 格式

**错误信息：** `Invalid source issue URL format`

**解决方案：**
- 确保 URL 格式为：`https://github.com/owner/repo/issues/123`
- 不要包含额外的路径或参数

### 问题 3：找不到源 issue

**错误信息：** `Failed to fetch source issue`

**解决方案：**
- 检查 issue 编号是否正确
- 确认 issue 未被删除
- 如果是私有仓库，确保有访问权限

### 问题 4：无法在目标仓库创建 issue

**错误信息：** `Failed to create issue in owner/repo`

**解决方案：**
- 检查目标仓库名称是否正确
- 确认 token 有权限访问目标仓库
- 确认目标仓库开启了 issues 功能

## 💡 高级用法

### 只在某些仓库成功也算成功

默认情况下，即使部分仓库创建失败，workflow 也会继续执行。只有**全部失败**时才会报错。

### 查看详细日志

在 Actions 运行页面，展开 "Create Cross-Repo Issues" 步骤可以看到：
- 源 issue 信息
- 目标仓库列表
- 每个仓库的创建状态
- 成功/失败统计

## 🎯 最佳实践

1. **批量创建**：一次可以在多个仓库创建 issue，节省时间
2. **保持关联**：通过链接保持 issues 之间的关联关系
3. **添加上下文**：源 issue 的完整内容会被复制，确保信息完整
4. **定期检查**：查看 Actions 日志了解创建状态

## 🔧 自定义

如果需要修改行为，可以编辑 `.github/workflows/create-cross-repo-issues.yml` 文件：

**修改标签：**
```javascript
labels: ['cross-repo', 'bug', 'enhancement']  // 第 91 行
```

**修改 issue 内容格式：**
```javascript
const separator = '\n\n' + '='.repeat(50);  // 第 76 行
const issueBody = sourceIssue.body + separator + `\n自定义内容...`;
```

**添加 assignees：**
```javascript
const newIssue = await github.rest.issues.create({
  owner: targetRepo.owner,
  repo: targetRepo.repo,
  title: sourceIssue.title,
  body: issueBody,
  labels: ['cross-repo'],
  assignees: ['username']  // 添加这一行
});
```
