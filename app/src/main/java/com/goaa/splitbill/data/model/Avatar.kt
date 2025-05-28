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
        // 男性頭像
        Avatar("male_01", AvatarType.MALE, "avatar_male_01", "男性頭像 1"),
        Avatar("male_02", AvatarType.MALE, "avatar_male_02", "男性頭像 2"),
        Avatar("male_03", AvatarType.MALE, "avatar_male_03", "男性頭像 3"),
        Avatar("male_04", AvatarType.MALE, "avatar_male_04", "男性頭像 4"),
        Avatar("male_05", AvatarType.MALE, "avatar_male_05", "男性頭像 5"),
        
        // 女性頭像
        Avatar("female_01", AvatarType.FEMALE, "avatar_female_01", "女性頭像 1"),
        Avatar("female_02", AvatarType.FEMALE, "avatar_female_02", "女性頭像 2"),
        Avatar("female_03", AvatarType.FEMALE, "avatar_female_03", "女性頭像 3"),
        Avatar("female_04", AvatarType.FEMALE, "avatar_female_04", "女性頭像 4"),
        Avatar("female_05", AvatarType.FEMALE, "avatar_female_05", "女性頭像 5"),
        
        // 貓咪頭像
        Avatar("cat_01", AvatarType.CAT, "avatar_cat_01", "可愛貓咪 1"),
        Avatar("cat_02", AvatarType.CAT, "avatar_cat_02", "可愛貓咪 2"),
        Avatar("cat_03", AvatarType.CAT, "avatar_cat_03", "可愛貓咪 3"),
        Avatar("cat_04", AvatarType.CAT, "avatar_cat_04", "可愛貓咪 4"),
        Avatar("cat_05", AvatarType.CAT, "avatar_cat_05", "可愛貓咪 5"),
        
        // 狗狗頭像
        Avatar("dog_01", AvatarType.DOG, "avatar_dog_01", "可愛狗狗 1"),
        Avatar("dog_02", AvatarType.DOG, "avatar_dog_02", "可愛狗狗 2"),
        Avatar("dog_03", AvatarType.DOG, "avatar_dog_03", "可愛狗狗 3"),
        Avatar("dog_04", AvatarType.DOG, "avatar_dog_04", "可愛狗狗 4"),
        Avatar("dog_05", AvatarType.DOG, "avatar_dog_05", "可愛狗狗 5")
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
