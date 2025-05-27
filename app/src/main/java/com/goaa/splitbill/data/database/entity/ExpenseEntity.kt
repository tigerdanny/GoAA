package com.goaa.splitbill.data.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.ForeignKey
import androidx.room.Index
import java.util.Date

@Entity(
    tableName = "expenses",
    foreignKeys = [
        ForeignKey(
            entity = AccountEntity::class,
            parentColumns = ["id"],
            childColumns = ["accountId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["accountId"])]
)
data class ExpenseEntity(
    @PrimaryKey
    val id: String,
    val accountId: String,
    val description: String,
    val amount: Double,
    val currency: String = "NT$",
    val category: String,
    val paidBy: String,
    val createdAt: Date,
    val updatedAt: Date,
    val isDeleted: Boolean = false
) 
