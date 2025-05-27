package com.goaa.splitbill.data.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date

@Entity(tableName = "accounts")
data class AccountEntity(
    @PrimaryKey
    val id: String,
    val name: String,
    val description: String?,
    val createdBy: String,
    val createdAt: Date,
    val updatedAt: Date,
    val isActive: Boolean = true
) 
