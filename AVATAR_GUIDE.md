# GoAA 頭像資源指南

## 📱 頭像功能說明

GoAA 現在支持可愛的頭像選擇功能！用戶可以從預設的頭像庫中選擇自己喜歡的頭像：

- **男性頭像**: 5 個選擇
- **女性頭像**: 5 個選擇  
- **貓咪頭像**: 5 個選擇
- **狗狗頭像**: 5 個選擇

## 🎨 當前實現

目前使用 **Emoji 表情符號** 作為臨時頭像顯示：

### 男性頭像
- 👨 (基本男性)
- 🧑 (中性人物)  
- 👱‍♂️ (金髮男性)
- 🧔 (有鬍子男性)
- 👨‍💼 (商務男性)

### 女性頭像
- 👩 (基本女性)
- 👱‍♀️ (金髮女性)
- 👩‍💼 (商務女性)
- 👩‍🎓 (畢業生女性)
- 🧕 (戴頭巾女性)

### 貓咪頭像
- 🐱 (貓臉)
- 😸 (笑臉貓)
- 😺 (開心貓)
- 😻 (愛心眼貓)
- 🙀 (驚訝貓)

### 狗狗頭像
- 🐶 (狗臉)
- 🐕 (狗)
- 🦮 (導盲犬)
- 🐕‍🦺 (服務犬)
- 🐩 (貴賓犬)

## 🖼️ 添加真實圖片資源

要使用真實的可愛卡通頭像，請按以下步驟操作：

### 1. 準備圖片資源

將以下格式的圖片放入 `app/src/main/res/drawable/` 目錄：

```
drawable/
├── avatar_male_01.png
├── avatar_male_02.png
├── avatar_male_03.png
├── avatar_male_04.png
├── avatar_male_05.png
├── avatar_female_01.png
├── avatar_female_02.png
├── avatar_female_03.png
├── avatar_female_04.png
├── avatar_female_05.png
├── avatar_cat_01.png
├── avatar_cat_02.png
├── avatar_cat_03.png
├── avatar_cat_04.png
├── avatar_cat_05.png
├── avatar_dog_01.png
├── avatar_dog_02.png
├── avatar_dog_03.png
├── avatar_dog_04.png
└── avatar_dog_05.png
```

### 2. 推薦的圖片規格

- **格式**: PNG (支援透明背景)
- **尺寸**: 512x512 px (或其他正方形尺寸)
- **風格**: 可愛卡通風格
- **背景**: 透明或純色

### 3. 開源圖片資源推薦

**免費可愛頭像資源:**

1. **Cute Cat Avatars**
   - 網址: https://cute-cat-avatars.fly.dev/
   - 授權: MIT License
   - 適用: 貓咪頭像

2. **Purrson Icon**
   - GitHub: https://github.com/madrobby/purrson-icon
   - 授權: MIT License
   - 適用: 通用動物頭像

3. **Free CC0 Vector Characters**
   - itch.io: RGS_Dev 的免費角色包
   - 授權: CC0 (公有領域)
   - 適用: 人物頭像

4. **其他開源資源:**
   - OpenGameArt.org
   - Freepik (免費素材)
   - Flaticon (免費圖標)
   - Unsplash (免費照片)

### 4. 更新代碼使用圖片

修改 `AvatarDisplay.kt` 和 `AvatarItem.kt` 中的實現，將 Emoji 替換為 `Image` 組件：

```kotlin
// 替換現有的 Text(emoji) 為:
Image(
    painter = painterResource(id = getDrawableId(avatar.resourceName)),
    contentDescription = avatar.displayName,
    modifier = Modifier.size(size * 0.8f)
)
```

### 5. 自定義頭像建議

如果你想要創建自己的頭像風格：

**設計原則:**
- 保持一致的藝術風格
- 使用明亮、友好的色彩
- 確保在小尺寸下仍然清晰可見
- 避免過於復雜的細節

**工具推薦:**
- **免費**: GIMP, Inkscape, Canva
- **付費**: Adobe Illustrator, Photoshop
- **線上**: Figma, Sketch

## 🎯 使用建議

1. **版權注意**: 確保所有使用的圖片都有適當的授權
2. **一致性**: 保持所有頭像的風格統一
3. **可愛風格**: 選擇溫暖、友好的設計風格
4. **文化敏感性**: 確保頭像設計對所有用戶都是包容和尊重的

## 🚀 未來擴展

可以考慮添加更多頭像類型：
- 熊貓 🐼
- 兔子 🐰  
- 機器人 🤖
- 外星人 👽
- 幻想角色 🧚‍♀️

---

**注意**: 當前版本使用 Emoji 作為臨時解決方案。要獲得最佳視覺效果，建議按照上述指南添加真實的圖片資源。 
