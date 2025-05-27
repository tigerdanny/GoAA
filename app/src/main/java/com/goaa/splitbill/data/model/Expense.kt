package com.goaa.splitbill.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "expenses")
data class Expense(
    @PrimaryKey
    val id: String,
    val groupId: String,
    val title: String,
    val description: String? = null,
    val amount: Double,
    val currency: String = "TWD",
    val paidBy: String, // User ID
    val category: String = "其他",
    val date: Long = System.currentTimeMillis(),
    val imageUrl: String? = null,
    val isSettled: Boolean = false
)

enum class ExpenseCategory(val displayName: String) {
    FOOD("餐飲"),
    TRANSPORT("交通"),
    ACCOMMODATION("住宿"),
    ENTERTAINMENT("娛樂"),
    SHOPPING("購物"),
    UTILITIES("水電費"),
    GROCERIES("日用品"),
    MEDICAL("醫療"),
    OTHER("其他")
} 
