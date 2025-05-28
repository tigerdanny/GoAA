package com.goaa.splitbill.data.model

enum class AvatarType {
    MALE, FEMALE, CAT, DOG
}

data class Avatar(
    val id: String,
    val type: AvatarType,
    val resourceName: String,
    val displayName: String
)

object DefaultAvatars {
    val avatars = listOf(
        // 男性頭像 - 日式動漫風格
        Avatar("male_01", AvatarType.MALE, "avatar_male_01", "陽光少年"),
        Avatar("male_02", AvatarType.MALE, "avatar_male_02", "酷帥男主"),
        Avatar("male_03", AvatarType.MALE, "avatar_male_03", "溫柔王子"),
        Avatar("male_04", AvatarType.MALE, "avatar_male_04", "熱血青春"),
        Avatar("male_05", AvatarType.MALE, "avatar_male_05", "神秘騎士"),
        
        // 女性頭像 - 日式動漫風格
        Avatar("female_01", AvatarType.FEMALE, "avatar_female_01", "甜美少女"),
        Avatar("female_02", AvatarType.FEMALE, "avatar_female_02", "元氣女孩"),
        Avatar("female_03", AvatarType.FEMALE, "avatar_female_03", "優雅公主"),
        Avatar("female_04", AvatarType.FEMALE, "avatar_female_04", "學園女神"),
        Avatar("female_05", AvatarType.FEMALE, "avatar_female_05", "魔法少女"),
        
        // 貓咪頭像 - 日式萌系風格
        Avatar("cat_01", AvatarType.CAT, "avatar_cat_01", "招財喵喵"),
        Avatar("cat_02", AvatarType.CAT, "avatar_cat_02", "賣萌小貓"),
        Avatar("cat_03", AvatarType.CAT, "avatar_cat_03", "傲嬌貓主"),
        Avatar("cat_04", AvatarType.CAT, "avatar_cat_04", "愛心貓咪"),
        Avatar("cat_05", AvatarType.CAT, "avatar_cat_05", "睡眠貓神"),
        
        // 狗狗頭像 - 日式可愛風格
        Avatar("dog_01", AvatarType.DOG, "avatar_dog_01", "忠犬小八"),
        Avatar("dog_02", AvatarType.DOG, "avatar_dog_02", "柴犬君君"),
        Avatar("dog_03", AvatarType.DOG, "avatar_dog_03", "秋田美男"),
        Avatar("dog_04", AvatarType.DOG, "avatar_dog_04", "萌犬王子"),
        Avatar("dog_05", AvatarType.DOG, "avatar_dog_05", "療癒天使")
    )
    
    fun getAvatarsByType(type: AvatarType): List<Avatar> {
        return avatars.filter { it.type == type }
    }
    
    fun getAvatarById(id: String): Avatar? {
        return avatars.find { it.id == id }
    }
    
    fun getDefaultAvatar(): Avatar {
        return avatars.first()
    }
} 
