# GoAA - 中文分账应用

GoAA 是一款现代化的中文分账应用，专为朋友、家庭和团体聚餐、旅行等活动中的费用分摊而设计。

## 主要功能

- 🍽️ **智能分账**: 支持多种分账方式（平均分、按比例分、自定义分配）
- 👥 **群组管理**: 创建和管理分账群组，轻松添加成员
- 💳 **费用记录**: 快速记录各类支出，支持9大费用类别
- 🧮 **自动结算**: 智能计算最优结算方案，减少转账次数
- 📊 **数据统计**: 详细的支出统计和分析图表
- 🎨 **精美界面**: 基于 Material Design 3 的现代化设计

## 技术栈

- **开发语言**: Kotlin
- **UI框架**: Jetpack Compose
- **架构模式**: MVVM + Clean Architecture
- **依赖注入**: Hilt
- **本地数据库**: Room
- **网络请求**: Retrofit
- **导航**: Navigation Compose
- **图表**: MPAndroidChart

## 项目结构

```
app/
├── src/main/
│   ├── java/com/goaa/splitbill/
│   │   ├── data/          # 数据层
│   │   ├── domain/        # 业务逻辑层
│   │   ├── presentation/  # 展示层
│   │   └── di/           # 依赖注入
│   └── res/
│       ├── values/        # 资源文件
│       ├── drawable/      # 图标和图片
│       └── mipmap/        # 应用图标
```

## 开始使用

### 环境要求

- Android Studio Arctic Fox 或更高版本
- Kotlin 1.9.22
- Android SDK 34
- 最低支持 Android 7.0 (API 24)

### 安装步骤

1. 克隆项目：
```bash
git clone git@github.com:tigerdanny/GoAA.git
```

2. 在 Android Studio 中打开项目

3. 等待 Gradle 同步完成

4. 运行项目

## 设计理念

GoAA 的设计围绕着品牌logo展开：
- **深蓝色 (#1B5E7E)**: 代表"Go"的专业性和可靠性
- **金黄色 (#F5A623)**: 代表"AA"的温暖和友好
- **青色 (#00BCD4)**: 用于金钱相关元素
- **橙色 (#FF6B35)**: 用于互动和手势元素

## 贡献

欢迎提交 Issue 和 Pull Request 来改进项目。

## 许可证

本项目采用 MIT 许可证，详情请见 [LICENSE](LICENSE) 文件。

## 联系方式

如有任何问题或建议，请通过 GitHub Issues 联系我们。 
