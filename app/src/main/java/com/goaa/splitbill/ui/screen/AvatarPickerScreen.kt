package com.goaa.splitbill.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.goaa.splitbill.data.model.Avatar
import com.goaa.splitbill.data.model.AvatarType
import com.goaa.splitbill.data.model.DefaultAvatars
import com.goaa.splitbill.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AvatarPickerScreen(
    selectedAvatarId: String?,
    onAvatarSelected: (Avatar) -> Unit,
    onNavigateBack: () -> Unit
) {
    var selectedType by remember { mutableStateOf(AvatarType.MALE) }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("選擇頭像") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "返回")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp)
        ) {
            // Type selector tabs
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Surface),
                shape = RoundedCornerShape(12.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(4.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    AvatarType.values().forEach { type ->
                        val isSelected = selectedType == type
                        val (icon, label) = when (type) {
                            AvatarType.MALE -> Icons.Default.Man to "男性"
                            AvatarType.FEMALE -> Icons.Default.Woman to "女性"
                            AvatarType.CAT -> Icons.Default.Pets to "貓咪"
                            AvatarType.DOG -> Icons.Default.Pets to "狗狗"
                        }
                        
                        Surface(
                            modifier = Modifier
                                .weight(1f)
                                .clickable { selectedType = type },
                            color = if (isSelected) Primary else Color.Transparent,
                            shape = RoundedCornerShape(8.dp)
                        ) {
                            Column(
                                modifier = Modifier.padding(12.dp),
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Icon(
                                    icon,
                                    contentDescription = label,
                                    tint = if (isSelected) OnPrimary else OnSurfaceVariant,
                                    modifier = Modifier.size(24.dp)
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = label,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = if (isSelected) OnPrimary else OnSurfaceVariant
                                )
                            }
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Avatar grid
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Surface),
                shape = RoundedCornerShape(12.dp)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp)
                ) {
                    Text(
                        text = "選擇您喜歡的頭像",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(bottom = 16.dp)
                    )
                    
                    LazyVerticalGrid(
                        columns = GridCells.Fixed(4),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        items(DefaultAvatars.getAvatarsByType(selectedType)) { avatar ->
                            AvatarItem(
                                avatar = avatar,
                                isSelected = avatar.id == selectedAvatarId,
                                onClick = { 
                                    onAvatarSelected(avatar)
                                    onNavigateBack()
                                }
                            )
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Info card
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Secondary.copy(alpha = 0.1f)),
                shape = RoundedCornerShape(12.dp)
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Default.Info,
                        contentDescription = null,
                        tint = Secondary,
                        modifier = Modifier.size(20.dp)
                    )
                    
                    Spacer(modifier = Modifier.width(12.dp))
                    
                    Text(
                        text = "選擇一個代表您的頭像，或稍後在設置中上傳自定義照片",
                        style = MaterialTheme.typography.bodySmall,
                        color = OnSurfaceVariant
                    )
                }
            }
        }
    }
}

@Composable
fun AvatarItem(
    avatar: Avatar,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .size(80.dp)
            .clip(CircleShape)
            .background(
                color = if (isSelected) Primary.copy(alpha = 0.2f) else OnSurfaceVariant.copy(alpha = 0.1f)
            )
            .border(
                width = if (isSelected) 3.dp else 1.dp,
                color = if (isSelected) Primary else OnSurfaceVariant.copy(alpha = 0.3f),
                shape = CircleShape
            )
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) {
        // Placeholder avatar - will show emoji until we add real images
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
            style = MaterialTheme.typography.headlineMedium
        )
        
        // Selected indicator
        if (isSelected) {
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .background(Primary)
                    .align(Alignment.BottomEnd),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Default.Check,
                    contentDescription = "已選中",
                    tint = OnPrimary,
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
} 
