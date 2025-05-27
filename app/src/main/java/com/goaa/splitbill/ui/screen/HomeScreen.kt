package com.goaa.splitbill.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.goaa.splitbill.data.model.Group
import com.goaa.splitbill.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onNavigateToGroup: (String) -> Unit,
    onCreateGroup: () -> Unit,
    onNavigateToProfile: () -> Unit
) {
    // Mock data for demonstration
    val groups = remember {
        listOf(
            Group("1", "週末旅行", "台中兩天一夜", null, "user1"),
            Group("2", "室友分帳", "房租水電費", null, "user1"),
            Group("3", "公司聚餐", "部門聚餐費用", null, "user2"),
            Group("4", "朋友聚會", "KTV + 宵夜", null, "user1")
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "GoAA",
                            style = MaterialTheme.typography.titleLarge.copy(
                                fontWeight = FontWeight.Bold
                            ),
                            color = Primary
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "分帳助手",
                            style = MaterialTheme.typography.bodyMedium,
                            color = OnSurfaceVariant
                        )
                    }
                },
                actions = {
                    IconButton(onClick = onNavigateToProfile) {
                        Icon(
                            Icons.Default.AccountCircle,
                            contentDescription = "個人資料",
                            tint = Primary
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Surface
                )
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = onCreateGroup,
                containerColor = Secondary,
                contentColor = OnSecondary
            ) {
                Icon(Icons.Default.Add, contentDescription = "創建群組")
            }
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Welcome section
            item {
                WelcomeCard()
            }
            
            // Quick actions
            item {
                QuickActionsSection(
                    onCreateGroup = onCreateGroup,
                    onJoinGroup = { /* TODO */ }
                )
            }
            
            // Groups section
            item {
                Text(
                    text = "我的群組",
                    style = MaterialTheme.typography.titleMedium,
                    color = OnBackground,
                    modifier = Modifier.padding(vertical = 8.dp)
                )
            }
            
            if (groups.isEmpty()) {
                item {
                    EmptyGroupsCard(onCreateGroup = onCreateGroup)
                }
            } else {
                items(groups) { group ->
                    GroupCard(
                        group = group,
                        onClick = { onNavigateToGroup(group.id) }
                    )
                }
            }
        }
    }
}

@Composable
fun WelcomeCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = Primary
        ),
        shape = RoundedCornerShape(20.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    brush = androidx.compose.ui.graphics.Brush.horizontalGradient(
                        colors = listOf(
                            Color(0xFF1B5E7E),
                            Color(0xFF0F4A66)
                        )
                    )
                )
                .padding(24.dp)
        ) {
            Column {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Go",
                        style = MaterialTheme.typography.headlineMedium,
                        color = OnPrimary,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "AA",
                        style = MaterialTheme.typography.headlineMedium,
                        color = Color(0xFFF5A623),
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "分帳神器",
                        style = MaterialTheme.typography.titleMedium,
                        color = OnPrimary.copy(alpha = 0.9f),
                        fontWeight = FontWeight.Medium
                    )
                }
                
                Spacer(modifier = Modifier.height(8.dp))
                
                Text(
                    text = "讓分帳變得簡單有趣",
                    style = MaterialTheme.typography.bodyLarge,
                    color = OnPrimary.copy(alpha = 0.8f)
                )
                
                Spacer(modifier = Modifier.height(4.dp))
                
                Text(
                    text = "智能計算，一鍵結算",
                    style = MaterialTheme.typography.bodyMedium,
                    color = OnPrimary.copy(alpha = 0.7f)
                )
            }
            
            // 装饰性设计元素
            Box(
                modifier = Modifier
                    .align(Alignment.CenterEnd)
                    .size(48.dp)
                    .background(
                        color = OnPrimary.copy(alpha = 0.1f),
                        shape = CircleShape
                    )
            )
        }
    }
}

@Composable
fun QuickActionsSection(
    onCreateGroup: () -> Unit,
    onJoinGroup: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = Color.White
        ),
        shape = RoundedCornerShape(16.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            modifier = Modifier.padding(20.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.FlashOn,
                    contentDescription = null,
                    tint = Color(0xFFF5A623),
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "快速操作",
                    style = MaterialTheme.typography.titleMedium,
                    color = OnSurface,
                    fontWeight = FontWeight.Bold
                )
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // 改为竖向布局以避免横向布局问题
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                QuickActionRow(
                    icon = Icons.Default.Add,
                    text = "創建群組",
                    subtitle = "開始新的分帳",
                    onClick = onCreateGroup,
                    backgroundColor = Color(0xFFF5A623)
                )
                
                QuickActionRow(
                    icon = Icons.Default.GroupAdd,
                    text = "加入群組",
                    subtitle = "參與朋友分帳",
                    onClick = onJoinGroup,
                    backgroundColor = Color(0xFF00BCD4)
                )
                
                QuickActionRow(
                    icon = Icons.Default.Calculate,
                    text = "快捷計算器",
                    subtitle = "臨時分帳計算",
                    onClick = { /* TODO */ },
                    backgroundColor = Color(0xFF1B5E7E)
                )
            }
        }
    }
}

@Composable
fun QuickActionRow(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    text: String,
    subtitle: String,
    onClick: () -> Unit,
    backgroundColor: Color
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = backgroundColor.copy(alpha = 0.08f)
        ),
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(backgroundColor),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    icon,
                    contentDescription = text,
                    tint = Color.White,
                    modifier = Modifier.size(24.dp)
                )
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = text,
                    style = MaterialTheme.typography.bodyLarge,
                    color = OnSurface,
                    fontWeight = FontWeight.Medium
                )
                
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = OnSurfaceVariant
                )
            }
            
            Icon(
                Icons.Default.ChevronRight,
                contentDescription = "執行",
                tint = OnSurfaceVariant,
                modifier = Modifier.size(20.dp)
            )
        }
    }
}

@Composable
fun GroupCard(
    group: Group,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = Color.White
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 3.dp),
        shape = RoundedCornerShape(16.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Group avatar with gradient
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .clip(CircleShape)
                    .background(
                        brush = androidx.compose.ui.graphics.Brush.linearGradient(
                            colors = listOf(
                                Color(0xFF1B5E7E),
                                Color(0xFF00BCD4)
                            )
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = group.name.take(1),
                    style = MaterialTheme.typography.titleLarge,
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            // Group info
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = group.name,
                    style = MaterialTheme.typography.titleMedium,
                    color = OnSurface,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                
                if (group.description != null) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = group.description,
                        style = MaterialTheme.typography.bodyMedium,
                        color = OnSurfaceVariant,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                
                Spacer(modifier = Modifier.height(6.dp))
                
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Default.People,
                        contentDescription = null,
                        tint = Color(0xFF00BCD4),
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "3 位成員",
                        style = MaterialTheme.typography.bodySmall,
                        color = OnSurfaceVariant
                    )
                    
                    Spacer(modifier = Modifier.width(16.dp))
                    
                    Icon(
                        Icons.Default.AccountBalanceWallet,
                        contentDescription = null,
                        tint = Color(0xFFF5A623),
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "5 筆消費",
                        style = MaterialTheme.typography.bodySmall,
                        color = OnSurfaceVariant
                    )
                }
            }
            
            // Status and arrow
            Column(
                horizontalAlignment = Alignment.End
            ) {
                Box(
                    modifier = Modifier
                        .background(
                            color = Color(0xFF4CAF50).copy(alpha = 0.1f),
                            shape = RoundedCornerShape(12.dp)
                        )
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = "進行中",
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(0xFF4CAF50),
                        fontWeight = FontWeight.Medium
                    )
                }
                
                Spacer(modifier = Modifier.height(8.dp))
                
                Icon(
                    Icons.Default.ChevronRight,
                    contentDescription = "進入群組",
                    tint = OnSurfaceVariant,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}

@Composable
fun EmptyGroupsCard(
    onCreateGroup: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = SurfaceVariant
        ),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                Icons.Default.Groups,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = OnSurfaceVariant.copy(alpha = 0.5f)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                text = "還沒有群組",
                style = MaterialTheme.typography.titleMedium,
                color = OnSurface
            )
            
            Text(
                text = "創建第一個分帳群組開始使用",
                style = MaterialTheme.typography.bodyMedium,
                color = OnSurfaceVariant
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Button(
                onClick = onCreateGroup,
                colors = ButtonDefaults.buttonColors(
                    containerColor = Secondary
                )
            ) {
                Icon(Icons.Default.Add, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("創建群組")
            }
        }
    }
} 
