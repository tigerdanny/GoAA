package com.goaa.splitbill.data.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.ForeignKey

@Entity(
    tableName = "security_settings",
    foreignKeys = [
        ForeignKey(
            entity = UserEntity::class,
            parentColumns = ["id"],
            childColumns = ["userId"],
            onDelete = ForeignKey.CASCADE
        )
    ]
)
data class SecuritySettingsEntity(
    @PrimaryKey
    val userId: String,
    val passwordHash: String? = null,
    val passwordSalt: String? = null,
    val isBiometricEnabled: Boolean = false,
    val requirePasswordOnStartup: Boolean = false,
    val autoLockEnabled: Boolean = false,
    val autoLockTimeoutMinutes: Int = 5,
    val lastPasswordChange: Long? = null,
    val failedLoginAttempts: Int = 0,
    val isAccountLocked: Boolean = false,
    val lockoutEndTime: Long? = null
) 
