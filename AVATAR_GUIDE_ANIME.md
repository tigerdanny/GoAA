# GoAA 日式動漫頭像系統指南 🌸

## 概述
本指南說明如何將當前的emoji頭像系統替換為真實的日式動漫風格圖片。

## 當前頭像設計

### 🎌 男性動漫角色 (Male Characters)
1. **陽光少年** (😊) - `male_01`
   - 描述：活力滿滿的熱血青春
   - 建議圖片：年輕陽光的動漫男主角，明亮笑容

2. **酷帥男主** (😎) - `male_02`
   - 描述：冷酷外表溫暖內心
   - 建議圖片：戴墨鏡或表情冷酷的帥氣男角

3. **溫柔王子** (🥰) - `male_03`
   - 描述：紳士風度迷人魅力
   - 建議圖片：溫文儒雅的王子型角色

4. **熱血青春** (😤) - `male_04`
   - 描述：永不放棄的戰鬥精神
   - 建議圖片：充滿鬥志的少年漫畫主角

5. **神秘騎士** (😏) - `male_05`
   - 描述：深藏不露的強大力量
   - 建議圖片：神秘帥氣的騎士或魔法師

### 🌸 女性動漫角色 (Female Characters)
1. **甜美少女** (🥺) - `female_01`
   - 描述：純真可愛的小天使
   - 建議圖片：大眼睛可愛系少女

2. **元氣女孩** (😆) - `female_02`
   - 描述：充滿活力的陽光少女
   - 建議圖片：活潑開朗的運動系女孩

3. **優雅公主** (👸) - `female_03`
   - 描述：高貴典雅的完美女神
   - 建議圖片：公主般優雅的美少女

4. **學園女神** (🤓) - `female_04`
   - 描述：智慧與美貌並存
   - 建議圖片：戴眼鏡的知性美少女

5. **魔法少女** (✨) - `female_05`
   - 描述：擁有神奇力量的守護者
   - 建議圖片：魔法少女風格角色

### 🐱 萌系貓咪 (Cute Cats)
1. **招財喵喵** (🐱) - `cat_01`
   - 描述：帶來好運的小天使
   - 建議圖片：日式招財貓風格

2. **賣萌小貓** (😽) - `cat_02`
   - 描述：可愛到犯規的萌物
   - 建議圖片：超萌的卡通貓咪

3. **傲嬌貓主** (😾) - `cat_03`
   - 描述：高冷外表柔軟內心
   - 建議圖片：表情傲嬌的貓咪

4. **愛心貓咪** (😻) - `cat_04`
   - 描述：滿滿愛意的甜蜜寶貝
   - 建議圖片：眼睛愛心的可愛貓

5. **睡眠貓神** (😴) - `cat_05`
   - 描述：療癒系的夢幻存在
   - 建議圖片：睡覺的治癒系貓咪

### 🐕 可愛狗狗 (Adorable Dogs)
1. **忠犬小八** (🐕) - `dog_01`
   - 描述：忠誠可靠的最佳夥伴
   - 建議圖片：忠實的柴犬或秋田犬

2. **柴犬君君** (🐕‍🦺) - `dog_02`
   - 描述：呆萌可愛的日系犬
   - 建議圖片：經典日系柴犬

3. **秋田美男** (🦮) - `dog_03`
   - 描述：帥氣優雅的紳士犬
   - 建議圖片：帥氣的大型犬

4. **萌犬王子** (🐶) - `dog_04`
   - 描述：可愛到爆表的小王子
   - 建議圖片：超萌的小型犬

5. **療癒天使** (😇) - `dog_05`
   - 描述：溫暖人心的治癒系
   - 建議圖片：溫暖治癒的狗狗

## 實現步驟

### 1. 圖片準備
- 圖片尺寸：建議 512x512px 或更高
- 格式：PNG 或 JPG（建議 PNG 以支持透明背景）
- 風格：日式動漫/卡通風格
- 表情：需符合角色個性描述

### 2. 資源文件放置
```
app/src/main/res/drawable/
├── avatar_male_01.png      # 陽光少年
├── avatar_male_02.png      # 酷帥男主
├── avatar_male_03.png      # 溫柔王子
├── avatar_male_04.png      # 熱血青春
├── avatar_male_05.png      # 神秘騎士
├── avatar_female_01.png    # 甜美少女
├── avatar_female_02.png    # 元氣女孩
├── avatar_female_03.png    # 優雅公主
├── avatar_female_04.png    # 學園女神
├── avatar_female_05.png    # 魔法少女
├── avatar_cat_01.png       # 招財喵喵
├── avatar_cat_02.png       # 賣萌小貓
├── avatar_cat_03.png       # 傲嬌貓主
├── avatar_cat_04.png       # 愛心貓咪
├── avatar_cat_05.png       # 睡眠貓神
├── avatar_dog_01.png       # 忠犬小八
├── avatar_dog_02.png       # 柴犬君君
├── avatar_dog_03.png       # 秋田美男
├── avatar_dog_04.png       # 萌犬王子
└── avatar_dog_05.png       # 療癒天使
```

### 3. 代碼修改

#### AvatarDisplay.kt
```kotlin
// 替換 emoji 顯示為圖片
AsyncImage(
    model = when (avatar.type) {
        AvatarType.MALE -> when (avatar.id.last()) {
            '1' -> R.drawable.avatar_male_01
            '2' -> R.drawable.avatar_male_02
            '3' -> R.drawable.avatar_male_03
            '4' -> R.drawable.avatar_male_04
            '5' -> R.drawable.avatar_male_05
            else -> R.drawable.avatar_male_01
        }
        // ... 其他類型
    },
    contentDescription = avatar.displayName,
    modifier = Modifier.fillMaxSize(),
    contentScale = ContentScale.Crop
)
```

### 4. HTML 頭像選擇器更新
更新 `avatar_gallery.html` 中的圖片路徑和樣式以配合新的動漫風格。

## 推薦圖片來源

### 🎨 開源動漫圖片資源
- **OpenGameArt.org** - 大量開源遊戲美術資源
- **Kenney Assets** - 高質量的遊戝資源包
- **Freepik** - 豐富的向量圖和插畫（需註明來源）
- **Pixabay** - 免費的動漫風格插畫
- **Unsplash** - 部分動漫風格圖片

### 🖼️ 創作工具推薦
- **Stable Diffusion** - AI 生成動漫風格圖片
- **DALL-E** - AI 圖片生成
- **Midjourney** - 高質量 AI 藝術生成
- **NovelAI** - 專門的動漫風格 AI

### 📐 設計規範
- **色調**：溫暖明亮的色彩
- **線條**：清晰的動漫線條風格
- **表情**：符合角色個性的生動表情
- **背景**：簡潔或透明背景
- **一致性**：所有頭像保持相似的藝術風格

## 版權注意事項
- 確保所有使用的圖片都有適當的使用權限
- 如使用 AI 生成圖片，確認生成平台的使用條款
- 建議使用 CC0 或 MIT 授權的開源圖片
- 商業使用前請仔細檢查授權條款

## 測試指南
1. 替換圖片後重新構建應用
2. 測試所有頭像在不同螢幕尺寸下的顯示效果
3. 檢查頭像在個人資料頁面和選擇器中的一致性
4. 驗證自定義頭像上傳功能仍正常工作

---

*最後更新：2024年12月*
*GoAA 開發團隊 - Danny Wang* 
