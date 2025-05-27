package com.goaa.splitbill.data.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.ForeignKey

@Entity(
    tableName = "user_settings",
    foreignKeys = [
        ForeignKey(
            entity = UserEntity::class,
            parentColumns = ["id"],
            childColumns = ["userId"],
            onDelete = ForeignKey.CASCADE
        )
    ]
)
data class UserSettingsEntity(
    @PrimaryKey
    val userId: String,
    val notificationsEnabled: Boolean = true,
    val emailNotifications: Boolean = true,
    val pushNotifications: Boolean = true,
    val privacyLevel: String = "NORMAL", // PrivacyLevel enum as string
    val autoLockEnabled: Boolean = false,
    val autoLockTimeoutMinutes: Int = 5
) 
