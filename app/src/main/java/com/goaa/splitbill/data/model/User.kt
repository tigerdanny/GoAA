package com.goaa.splitbill.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "users")
data class User(
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

@Entity(tableName = "user_settings")
data class UserSettings(
    @PrimaryKey
    val userId: String,
    val notificationsEnabled: Boolean = true,
    val emailNotifications: Boolean = true,
    val pushNotifications: Boolean = true,
    val privacyLevel: PrivacyLevel = PrivacyLevel.NORMAL,
    val autoLockEnabled: Boolean = false,
    val autoLockTimeoutMinutes: Int = 5
)

enum class PrivacyLevel {
    STRICT, NORMAL, RELAXED
} 
