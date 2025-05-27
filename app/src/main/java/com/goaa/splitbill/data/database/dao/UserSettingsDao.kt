package com.goaa.splitbill.data.database.dao

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import com.goaa.splitbill.data.database.entity.UserSettingsEntity

@Dao
interface UserSettingsDao {
    
    @Query("SELECT * FROM user_settings WHERE userId = :userId")
    suspend fun getUserSettings(userId: String): UserSettingsEntity?
    
    @Query("SELECT * FROM user_settings WHERE userId = :userId")
    fun getUserSettingsFlow(userId: String): Flow<UserSettingsEntity?>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUserSettings(settings: UserSettingsEntity)
    
    @Update
    suspend fun updateUserSettings(settings: UserSettingsEntity)
    
    @Query("UPDATE user_settings SET notificationsEnabled = :enabled WHERE userId = :userId")
    suspend fun updateNotificationSettings(userId: String, enabled: Boolean)
    
    @Query("UPDATE user_settings SET emailNotifications = :enabled WHERE userId = :userId")
    suspend fun updateEmailNotifications(userId: String, enabled: Boolean)
    
    @Query("UPDATE user_settings SET pushNotifications = :enabled WHERE userId = :userId")
    suspend fun updatePushNotifications(userId: String, enabled: Boolean)
    
    @Query("UPDATE user_settings SET privacyLevel = :level WHERE userId = :userId")
    suspend fun updatePrivacyLevel(userId: String, level: String)
    
    @Query("UPDATE user_settings SET autoLockEnabled = :enabled, autoLockTimeoutMinutes = :timeoutMinutes WHERE userId = :userId")
    suspend fun updateAutoLockSettings(userId: String, enabled: Boolean, timeoutMinutes: Int)
} 
