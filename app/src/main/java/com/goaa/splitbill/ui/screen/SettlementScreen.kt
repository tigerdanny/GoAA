package com.goaa.splitbill.ui.screen

import androidx.compose.foundation.background
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.goaa.splitbill.ui.theme.*

data class Settlement(
    val fromUserId: String,
    val fromUserName: String,
    val toUserId: String,
    val toUserName: String,
    val amount: Double
)

data class UserBalance(
    val userId: String,
    val userName: String,
    val balance: Double // 正數表示別人欠我，負數表示我欠別人
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettlementScreen(
    groupId: String,
    onNavigateBack: () -> Unit,
    onMarkAsSettled: (Settlement) -> Unit
) {
    // Mock data
    val groupName = "週末旅行"
    val totalExpenses = 3250.0
    
    val userBalances = remember {
        listOf(
            UserBalance("user1", "小明", -850.0),
            UserBalance("user2", "小華", 1200.0),
            UserBalance("user3", "小美", -350.0)
        )
    }
    
    val settlements = remember {
        listOf(
            Settlement("user1", "小明", "user2", "小華", 850.0),
            Settlement("user3", "小美", "user2", "小華", 350.0)
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("結算詳情") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "返回")
                    }
                },
                actions = {
                    IconButton(onClick = { /* TODO: 分享結算結果 */ }) {
                        Icon(Icons.Default.Share, contentDescription = "分享")
                    }
                }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Summary card
            item {
                SettlementSummaryCard(
                    groupName = groupName,
                    totalExpenses = totalExpenses,
                    settlementsCount = settlements.size
                )
            }
            
            // User balances
            item {
                Text(
                    text = "個人餘額",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = OnBackground
                )
            }
            
            items(userBalances) { userBalance ->
                UserBalanceCard(userBalance = userBalance)
            }
            
            // Settlement instructions
            if (settlements.isNotEmpty()) {
                item {
                    Text(
                        text = "結算方案",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = OnBackground
                    )
                }
                
                item {
                    SettlementInstructionsCard()
                }
                
                items(settlements) { settlement ->
                    SettlementCard(
                        settlement = settlement,
                        onMarkAsSettled = { onMarkAsSettled(settlement) }
                    )
                }
            } else {
                item {
                    AllSettledCard()
                }
            }
        }
    }
}

@Composable
fun SettlementSummaryCard(
    groupName: String,
    totalExpenses: Double,
    settlementsCount: Int
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = Primary
        ),
        shape = RoundedCornerShape(16.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = groupName,
                        style = MaterialTheme.typography.titleLarge,
                        color = OnPrimary,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "結算報告",
                        style = MaterialTheme.typography.bodyMedium,
                        color = OnPrimary.copy(alpha = 0.8f)
                    )
                }
                
                Icon(
                    Icons.Default.Calculate,
                    contentDescription = null,
                    modifier = Modifier.size(32.dp),
                    tint = OnPrimary.copy(alpha = 0.7f)
                )
            }
            
            Spacer(modifier = Modifier.height(20.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Text(
                        text = "總消費金額",
                        style = MaterialTheme.typography.bodySmall,
                        color = OnPrimary.copy(alpha = 0.7f)
                    )
                    Text(
                        text = "NT$ ${String.format("%.0f", totalExpenses)}",
                        style = MaterialTheme.typography.titleMedium,
                        color = OnPrimary,
                        fontWeight = FontWeight.Bold
                    )
                }
                
                Column(
                    horizontalAlignment = Alignment.End
                ) {
                    Text(
                        text = "待結算筆數",
                        style = MaterialTheme.typography.bodySmall,
                        color = OnPrimary.copy(alpha = 0.7f)
                    )
                    Text(
                        text = "$settlementsCount 筆",
                        style = MaterialTheme.typography.titleMedium,
                        color = if (settlementsCount > 0) Secondary else Credit,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

@Composable
fun UserBalanceCard(userBalance: UserBalance) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = Surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // User avatar
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(Primary.copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = userBalance.userName.take(1),
                    style = MaterialTheme.typography.titleMedium,
                    color = Primary,
                    fontWeight = FontWeight.Bold
                )
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            // User info
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = userBalance.userName,
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Medium,
                    color = OnSurface
                )
                
                Text(
                    text = when {
                        userBalance.balance > 0 -> "應收款項"
                        userBalance.balance < 0 -> "應付款項"
                        else -> "已結清"
                    },
                    style = MaterialTheme.typography.bodySmall,
                    color = OnSurfaceVariant
                )
            }
            
            // Balance amount
            Column(
                horizontalAlignment = Alignment.End
            ) {
                Text(
                    text = when {
                        userBalance.balance > 0 -> "+NT$ ${String.format("%.0f", userBalance.balance)}"
                        userBalance.balance < 0 -> "NT$ ${String.format("%.0f", userBalance.balance)}"
                        else -> "NT$ 0"
                    },
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold,
                    color = when {
                        userBalance.balance > 0 -> Credit
                        userBalance.balance < 0 -> Debt
                        else -> Neutral
                    }
                )
                
                // Status indicator
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(
                                when {
                                    userBalance.balance > 0 -> Credit
                                    userBalance.balance < 0 -> Debt
                                    else -> Neutral
                                }
                            )
                    )
                    
                    Spacer(modifier = Modifier.width(4.dp))
                    
                    Text(
                        text = when {
                            userBalance.balance > 0 -> "收款"
                            userBalance.balance < 0 -> "付款"
                            else -> "結清"
                        },
                        style = MaterialTheme.typography.bodySmall,
                        color = OnSurfaceVariant
                    )
                }
            }
        }
    }
}

@Composable
fun SettlementInstructionsCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = Accent.copy(alpha = 0.1f)
        ),
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                Icons.Default.Info,
                contentDescription = null,
                tint = Accent,
                modifier = Modifier.size(24.dp)
            )
            
            Spacer(modifier = Modifier.width(12.dp))
            
            Column {
                Text(
                    text = "最佳結算方案",
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Medium,
                    color = OnSurface
                )
                Text(
                    text = "以下是最少轉帳次數的結算方案",
                    style = MaterialTheme.typography.bodySmall,
                    color = OnSurfaceVariant
                )
            }
        }
    }
}

@Composable
fun SettlementCard(
    settlement: Settlement,
    onMarkAsSettled: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = Surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            // Settlement flow
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // From user
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                            .background(Debt.copy(alpha = 0.1f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = settlement.fromUserName.take(1),
                            style = MaterialTheme.typography.titleSmall,
                            color = Debt,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    
                    Spacer(modifier = Modifier.height(4.dp))
                    
                    Text(
                        text = settlement.fromUserName,
                        style = MaterialTheme.typography.bodySmall,
                        color = OnSurface,
                        textAlign = TextAlign.Center
                    )
                }
                
                Spacer(modifier = Modifier.width(16.dp))
                
                // Arrow and amount
                Column(
                    modifier = Modifier.weight(1f),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .height(2.dp)
                                .weight(1f)
                                .background(OnSurfaceVariant.copy(alpha = 0.3f))
                        )
                        
                        Icon(
                            Icons.Default.ArrowForward,
                            contentDescription = null,
                            tint = OnSurfaceVariant,
                            modifier = Modifier.size(20.dp)
                        )
                        
                        Box(
                            modifier = Modifier
                                .height(2.dp)
                                .weight(1f)
                                .background(OnSurfaceVariant.copy(alpha = 0.3f))
                        )
                    }
                    
                    Spacer(modifier = Modifier.height(4.dp))
                    
                    Text(
                        text = "NT$ ${String.format("%.0f", settlement.amount)}",
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.Bold,
                        color = Primary
                    )
                }
                
                Spacer(modifier = Modifier.width(16.dp))
                
                // To user
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                            .background(Credit.copy(alpha = 0.1f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = settlement.toUserName.take(1),
                            style = MaterialTheme.typography.titleSmall,
                            color = Credit,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    
                    Spacer(modifier = Modifier.height(4.dp))
                    
                    Text(
                        text = settlement.toUserName,
                        style = MaterialTheme.typography.bodySmall,
                        color = OnSurface,
                        textAlign = TextAlign.Center
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Action button
            Button(
                onClick = onMarkAsSettled,
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Secondary
                )
            ) {
                Icon(
                    Icons.Default.Check,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text("標記為已結算")
            }
        }
    }
}

@Composable
fun AllSettledCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = Credit.copy(alpha = 0.1f)
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
                Icons.Default.CheckCircle,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = Credit
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                text = "全部結清！",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = Credit,
                textAlign = TextAlign.Center
            )
            
            Text(
                text = "所有帳務都已結算完成",
                style = MaterialTheme.typography.bodyMedium,
                color = OnSurfaceVariant,
                textAlign = TextAlign.Center
            )
        }
    }
} 
