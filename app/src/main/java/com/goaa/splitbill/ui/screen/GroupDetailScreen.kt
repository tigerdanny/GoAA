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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.goaa.splitbill.data.model.Expense
import com.goaa.splitbill.data.model.ExpenseCategory
import com.goaa.splitbill.ui.theme.*
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GroupDetailScreen(
    groupId: String,
    onNavigateBack: () -> Unit,
    onAddExpense: () -> Unit,
    onNavigateToSettle: () -> Unit,
    onNavigateToMembers: () -> Unit
) {
    // Mock data
    val groupName = "週末旅行"
    val totalExpenses = 3250.0
    val myBalance = -850.0 // 負數表示欠錢，正數表示別人欠我
    
    val expenses = remember {
        listOf(
            Expense("1", groupId, "晚餐", "燒肉店", 1200.0, "TWD", "user1", "餐飲"),
            Expense("2", groupId, "住宿", "民宿一晚", 1800.0, "TWD", "user2", "住宿"),
            Expense("3", groupId, "交通", "高鐵票", 250.0, "TWD", "user1", "交通")
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(groupName) },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "返回")
                    }
                },
                actions = {
                    IconButton(onClick = onNavigateToMembers) {
                        Icon(Icons.Default.Group, contentDescription = "成員管理")
                    }
                    IconButton(onClick = { /* TODO: 群組設置 */ }) {
                        Icon(Icons.Default.MoreVert, contentDescription = "更多選項")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = onAddExpense,
                containerColor = Secondary,
                contentColor = OnSecondary
            ) {
                Icon(Icons.Default.Add, contentDescription = "添加消費")
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
            // Summary card
            item {
                GroupSummaryCard(
                    totalExpenses = totalExpenses,
                    myBalance = myBalance,
                    onNavigateToSettle = onNavigateToSettle
                )
            }
            
            // Quick actions
            item {
                QuickActionsRow(
                    onAddExpense = onAddExpense,
                    onNavigateToSettle = onNavigateToSettle,
                    onNavigateToMembers = onNavigateToMembers
                )
            }
            
            // Expenses section
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "消費記錄",
                        style = MaterialTheme.typography.titleMedium,
                        color = OnBackground
                    )
                    
                    TextButton(onClick = { /* TODO: 查看全部 */ }) {
                        Text("查看全部")
                    }
                }
            }
            
            if (expenses.isEmpty()) {
                item {
                    EmptyExpensesCard(onAddExpense = onAddExpense)
                }
            } else {
                items(expenses) { expense ->
                    ExpenseCard(expense = expense)
                }
            }
        }
    }
}

@Composable
fun GroupSummaryCard(
    totalExpenses: Double,
    myBalance: Double,
    onNavigateToSettle: () -> Unit
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
            Text(
                text = "群組總覽",
                style = MaterialTheme.typography.titleMedium,
                color = OnPrimary,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Text(
                        text = "總消費",
                        style = MaterialTheme.typography.bodySmall,
                        color = OnPrimary.copy(alpha = 0.7f)
                    )
                    Text(
                        text = "NT$ ${String.format("%.0f", totalExpenses)}",
                        style = MaterialTheme.typography.titleLarge,
                        color = OnPrimary,
                        fontWeight = FontWeight.Bold
                    )
                }
                
                Column(
                    horizontalAlignment = Alignment.End
                ) {
                    Text(
                        text = "我的餘額",
                        style = MaterialTheme.typography.bodySmall,
                        color = OnPrimary.copy(alpha = 0.7f)
                    )
                    Text(
                        text = if (myBalance >= 0) "+NT$ ${String.format("%.0f", myBalance)}" 
                               else "NT$ ${String.format("%.0f", myBalance)}",
                        style = MaterialTheme.typography.titleLarge,
                        color = if (myBalance >= 0) Credit else Debt,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Button(
                onClick = onNavigateToSettle,
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Secondary,
                    contentColor = OnSecondary
                )
            ) {
                Icon(Icons.Default.Calculate, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("查看結算")
            }
        }
    }
}

@Composable
fun QuickActionsRow(
    onAddExpense: () -> Unit,
    onNavigateToSettle: () -> Unit,
    onNavigateToMembers: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceEvenly
    ) {
        QuickActionItem(
            icon = Icons.Default.Receipt,
            text = "記帳",
            onClick = onAddExpense,
            backgroundColor = Orange
        )
        
        QuickActionItem(
            icon = Icons.Default.Calculate,
            text = "結算",
            onClick = onNavigateToSettle,
            backgroundColor = Accent
        )
        
        QuickActionItem(
            icon = Icons.Default.Group,
            text = "成員",
            onClick = onNavigateToMembers,
            backgroundColor = Secondary
        )
    }
}

@Composable
fun QuickActionItem(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    text: String,
    onClick: () -> Unit,
    backgroundColor: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.clickable { onClick() }
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
                modifier = Modifier.size(20.dp)
            )
        }
        
        Spacer(modifier = Modifier.height(6.dp))
        
        Text(
            text = text,
            style = MaterialTheme.typography.bodySmall,
            color = OnSurface
        )
    }
}

@Composable
fun ExpenseCard(expense: Expense) {
    val dateFormat = SimpleDateFormat("MM/dd HH:mm", Locale.getDefault())
    
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
            // Category icon
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(getCategoryColor(expense.category).copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    getCategoryIcon(expense.category),
                    contentDescription = expense.category,
                    tint = getCategoryColor(expense.category),
                    modifier = Modifier.size(20.dp)
                )
            }
            
            Spacer(modifier = Modifier.width(12.dp))
            
            // Expense info
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = expense.title,
                    style = MaterialTheme.typography.titleSmall,
                    color = OnSurface,
                    fontWeight = FontWeight.Medium
                )
                
                if (expense.description != null) {
                    Text(
                        text = expense.description,
                        style = MaterialTheme.typography.bodySmall,
                        color = OnSurfaceVariant
                    )
                }
                
                Text(
                    text = "${dateFormat.format(Date(expense.date))} • 由 ${getUserName(expense.paidBy)} 支付",
                    style = MaterialTheme.typography.bodySmall,
                    color = OnSurfaceVariant
                )
            }
            
            // Amount
            Column(
                horizontalAlignment = Alignment.End
            ) {
                Text(
                    text = "NT$ ${String.format("%.0f", expense.amount)}",
                    style = MaterialTheme.typography.titleSmall,
                    color = OnSurface,
                    fontWeight = FontWeight.Bold
                )
                
                Text(
                    text = expense.category,
                    style = MaterialTheme.typography.bodySmall,
                    color = OnSurfaceVariant
                )
            }
        }
    }
}

@Composable
fun EmptyExpensesCard(onAddExpense: () -> Unit) {
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
                Icons.Default.Receipt,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = OnSurfaceVariant.copy(alpha = 0.5f)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                text = "還沒有消費記錄",
                style = MaterialTheme.typography.titleMedium,
                color = OnSurface,
                textAlign = TextAlign.Center
            )
            
            Text(
                text = "開始記錄第一筆消費",
                style = MaterialTheme.typography.bodyMedium,
                color = OnSurfaceVariant,
                textAlign = TextAlign.Center
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Button(
                onClick = onAddExpense,
                colors = ButtonDefaults.buttonColors(
                    containerColor = Secondary
                )
            ) {
                Icon(Icons.Default.Add, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("添加消費")
            }
        }
    }
}

// Helper functions
fun getCategoryIcon(category: String): androidx.compose.ui.graphics.vector.ImageVector {
    return when (category) {
        "餐飲" -> Icons.Default.Restaurant
        "交通" -> Icons.Default.DirectionsCar
        "住宿" -> Icons.Default.Hotel
        "娛樂" -> Icons.Default.Movie
        "購物" -> Icons.Default.ShoppingCart
        "水電費" -> Icons.Default.ElectricBolt
        "日用品" -> Icons.Default.ShoppingBasket
        "醫療" -> Icons.Default.LocalHospital
        else -> Icons.Default.Receipt
    }
}

fun getCategoryColor(category: String): Color {
    return when (category) {
        "餐飲" -> Color(0xFFFF6B35)
        "交通" -> Color(0xFF2196F3)
        "住宿" -> Color(0xFF9C27B0)
        "娛樂" -> Color(0xFFE91E63)
        "購物" -> Color(0xFF4CAF50)
        "水電費" -> Color(0xFFFF9800)
        "日用品" -> Color(0xFF795548)
        "醫療" -> Color(0xFFF44336)
        else -> Color(0xFF607D8B)
    }
}

fun getUserName(userId: String): String {
    return when (userId) {
        "user1" -> "小明"
        "user2" -> "小華"
        "user3" -> "小美"
        else -> "未知用戶"
    }
} 
