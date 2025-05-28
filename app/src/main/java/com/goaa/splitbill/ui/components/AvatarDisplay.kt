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
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
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
        val avatar = avatarId?.let { DefaultAvatars.getAvatarById(it) }
        if (avatar != null) {
            Text(
                text = when (avatar.type) {
                    AvatarType.MALE -> when (avatar.id.last()) {
                        '1' -> "👨"
                        '2' -> "🧑"
                        '3' -> "👱‍♂️"
                        '4' -> "🧔"
                        '5' -> "👨‍💼"
                        else -> "👨"
                    }
                    AvatarType.FEMALE -> when (avatar.id.last()) {
                        '1' -> "👩"
                        '2' -> "👱‍♀️"
                        '3' -> "👩‍💼"
                        '4' -> "👩‍🎓"
                        '5' -> "🧕"
                        else -> "👩"
                    }
                    AvatarType.CAT -> when (avatar.id.last()) {
                        '1' -> "🐱"
                        '2' -> "😸"
                        '3' -> "😺"
                        '4' -> "😻"
                        '5' -> "🙀"
                        else -> "🐱"
                    }
                    AvatarType.DOG -> when (avatar.id.last()) {
                        '1' -> "🐶"
                        '2' -> "🐕"
                        '3' -> "🦮"
                        '4' -> "🐕‍🦺"
                        '5' -> "🐩"
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
} 
