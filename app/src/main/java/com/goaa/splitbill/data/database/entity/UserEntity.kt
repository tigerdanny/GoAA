package com.goaa.splitbill.data.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey
    val id: String,
    val name: String,
    val email: String,
    val avatarUrl: String? = null,
    val phoneNumber: String? = null,
    val createdAt: Long = System.currentTimeMillis(),
    val hasPassword: Boolean = false,
    val isBiometricEnabled: Boolean = false
) 
