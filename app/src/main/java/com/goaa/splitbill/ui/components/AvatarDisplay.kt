package com.goaa.splitbill.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.goaa.splitbill.data.model.DefaultAvatars
import com.goaa.splitbill.data.model.AvatarType
import com.goaa.splitbill.ui.theme.*

@Composable
fun AvatarDisplay(
    avatarId: String?,
    size: Dp = 80.dp,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(OnSurfaceVariant.copy(alpha = 0.1f)),
        contentAlignment = Alignment.Center
    ) {
        when {
            // 自定義圖片（URI格式）
            avatarId?.startsWith("content://") == true || avatarId?.startsWith("file://") == true -> {
                AsyncImage(
                    model = avatarId,
                    contentDescription = "自定義頭像",
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }
            // 預設頭像
            avatarId != null -> {
                val avatar = DefaultAvatars.getAvatarById(avatarId)
                if (avatar != null) {
                    Text(
                        text = when (avatar.type) {
                            AvatarType.MALE -> when (avatar.id.last()) {
                                '1' -> "😊" // 陽光少年
                                '2' -> "😎" // 酷帥男主  
                                '3' -> "🥰" // 溫柔王子
                                '4' -> "😤" // 熱血青春
                                '5' -> "😏" // 神秘騎士
                                else -> "😊"
                            }
                            AvatarType.FEMALE -> when (avatar.id.last()) {
                                '1' -> "🥺" // 甜美少女
                                '2' -> "😆" // 元氣女孩
                                '3' -> "👸" // 優雅公主
                                '4' -> "🤓" // 學園女神
                                '5' -> "✨" // 魔法少女
                                else -> "🥺"
                            }
                            AvatarType.CAT -> when (avatar.id.last()) {
                                '1' -> "🐱" // 招財喵喵
                                '2' -> "😽" // 賣萌小貓
                                '3' -> "😾" // 傲嬌貓主
                                '4' -> "😻" // 愛心貓咪
                                '5' -> "😴" // 睡眠貓神
                                else -> "🐱"
                            }
                            AvatarType.DOG -> when (avatar.id.last()) {
                                '1' -> "🐕" // 忠犬小八
                                '2' -> "🐕‍🦺" // 柴犬君君
                                '3' -> "🦮" // 秋田美男
                                '4' -> "🐶" // 萌犬王子
                                '5' -> "😇" // 療癒天使
                                else -> "🐶"
                            }
                        },
                        style = when {
                            size >= 120.dp -> MaterialTheme.typography.displayLarge
                            size >= 80.dp -> MaterialTheme.typography.displayMedium
                            size >= 60.dp -> MaterialTheme.typography.displaySmall
                            size >= 40.dp -> MaterialTheme.typography.headlineLarge
                            else -> MaterialTheme.typography.headlineMedium
                        }
                    )
                } else {
                    Icon(
                        Icons.Default.Person,
                        contentDescription = "默認頭像",
                        modifier = Modifier.size(size * 0.6f),
                        tint = OnSurfaceVariant
                    )
                }
            }
            // 沒有頭像
            else -> {
                Icon(
                    Icons.Default.Person,
                    contentDescription = "默認頭像",
                    modifier = Modifier.size(size * 0.6f),
                    tint = OnSurfaceVariant
                )
            }
        }
    }
} 
