package com.goaa.splitbill.data.database.dao

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import com.goaa.splitbill.data.database.entity.SecuritySettingsEntity

@Dao
interface SecuritySettingsDao {
    
    @Query("SELECT * FROM security_settings WHERE userId = :userId")
    suspend fun getSecuritySettings(userId: String): SecuritySettingsEntity?
    
    @Query("SELECT * FROM security_settings WHERE userId = :userId")
    fun getSecuritySettingsFlow(userId: String): Flow<SecuritySettingsEntity?>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSecuritySettings(settings: SecuritySettingsEntity)
    
    @Update
    suspend fun updateSecuritySettings(settings: SecuritySettingsEntity)
    
    @Query("UPDATE security_settings SET passwordHash = :hash, passwordSalt = :salt, lastPasswordChange = :timestamp WHERE userId = :userId")
    suspend fun updatePassword(userId: String, hash: String, salt: String, timestamp: Long)
    
    @Query("UPDATE security_settings SET passwordHash = NULL, passwordSalt = NULL, lastPasswordChange = NULL WHERE userId = :userId")
    suspend fun removePassword(userId: String)
    
    @Query("UPDATE security_settings SET isBiometricEnabled = :enabled WHERE userId = :userId")
    suspend fun updateBiometricSettings(userId: String, enabled: Boolean)
    
    @Query("UPDATE security_settings SET requirePasswordOnStartup = :required WHERE userId = :userId")
    suspend fun updatePasswordOnStartup(userId: String, required: Boolean)
    
    @Query("UPDATE security_settings SET failedLoginAttempts = :attempts WHERE userId = :userId")
    suspend fun updateFailedLoginAttempts(userId: String, attempts: Int)
    
    @Query("UPDATE security_settings SET isAccountLocked = :locked, lockoutEndTime = :endTime WHERE userId = :userId")
    suspend fun updateAccountLockStatus(userId: String, locked: Boolean, endTime: Long?)
    
    @Query("SELECT passwordHash IS NOT NULL FROM security_settings WHERE userId = :userId")
    suspend fun hasPassword(userId: String): Boolean?
} 
