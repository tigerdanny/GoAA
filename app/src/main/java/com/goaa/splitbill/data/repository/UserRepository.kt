package com.goaa.splitbill.data.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import com.goaa.splitbill.data.database.dao.UserDao
import com.goaa.splitbill.data.database.dao.UserSettingsDao
import com.goaa.splitbill.data.database.dao.SecuritySettingsDao
import com.goaa.splitbill.data.database.entity.UserEntity
import com.goaa.splitbill.data.database.entity.UserSettingsEntity
import com.goaa.splitbill.data.database.entity.SecuritySettingsEntity
import com.goaa.splitbill.data.model.User
import com.goaa.splitbill.data.model.UserSettings
import com.goaa.splitbill.data.model.SecuritySettings
import com.goaa.splitbill.data.model.PrivacyLevel
import javax.inject.Inject
import javax.inject.Singleton
import java.security.MessageDigest
import java.security.SecureRandom
import android.util.Base64

@Singleton
class UserRepository @Inject constructor(
    private val userDao: UserDao,
    private val userSettingsDao: UserSettingsDao,
    private val securitySettingsDao: SecuritySettingsDao
) {
    
    // User operations
    suspend fun getUser(userId: String): User? {
        return userDao.getUserById(userId)?.toUser()
    }
    
    fun getUserFlow(userId: String): Flow<User?> {
        return userDao.getUserByIdFlow(userId).map { it?.toUser() }
    }
    
    suspend fun insertUser(user: User) {
        userDao.insertUser(user.toEntity())
        
        // Create default settings
        userSettingsDao.insertUserSettings(
            UserSettingsEntity(userId = user.id)
        )
        securitySettingsDao.insertSecuritySettings(
            SecuritySettingsEntity(userId = user.id)
        )
    }
    
    suspend fun updateUserProfile(
        userId: String,
        name: String,
        email: String,
        avatarUrl: String?,
        phoneNumber: String?
    ) {
        userDao.updateUserProfile(userId, name, email, avatarUrl, phoneNumber)
    }
    
    // Settings operations
    suspend fun getUserSettings(userId: String): UserSettings? {
        return userSettingsDao.getUserSettings(userId)?.toUserSettings()
    }
    
    fun getUserSettingsFlow(userId: String): Flow<UserSettings?> {
        return userSettingsDao.getUserSettingsFlow(userId).map { it?.toUserSettings() }
    }
    
    suspend fun updateNotificationSettings(userId: String, enabled: Boolean) {
        userSettingsDao.updateNotificationSettings(userId, enabled)
    }
    
    suspend fun updatePrivacyLevel(userId: String, level: PrivacyLevel) {
        userSettingsDao.updatePrivacyLevel(userId, level.name)
    }
    
    // Security operations
    suspend fun getSecuritySettings(userId: String): SecuritySettings? {
        return securitySettingsDao.getSecuritySettings(userId)?.toSecuritySettings()
    }
    
    suspend fun hasPassword(userId: String): Boolean {
        return securitySettingsDao.hasPassword(userId) ?: false
    }
    
    suspend fun setPassword(userId: String, password: String): Boolean {
        return try {
            val salt = generateSalt()
            val hash = hashPassword(password, salt)
            securitySettingsDao.updatePassword(userId, hash, salt, System.currentTimeMillis())
            userDao.updatePasswordStatus(userId, true)
            true
        } catch (e: Exception) {
            false
        }
    }
    
    suspend fun removePassword(userId: String): Boolean {
        return try {
            securitySettingsDao.removePassword(userId)
            userDao.updatePasswordStatus(userId, false)
            securitySettingsDao.updateBiometricSettings(userId, false)
            userDao.updateBiometricStatus(userId, false)
            true
        } catch (e: Exception) {
            false
        }
    }
    
    suspend fun verifyPassword(userId: String, password: String): Boolean {
        val settings = securitySettingsDao.getSecuritySettings(userId) ?: return false
        val hash = settings.passwordHash ?: return false
        val salt = settings.passwordSalt ?: return false
        
        return hashPassword(password, salt) == hash
    }
    
    suspend fun updateBiometricSettings(userId: String, enabled: Boolean) {
        securitySettingsDao.updateBiometricSettings(userId, enabled)
        userDao.updateBiometricStatus(userId, enabled)
    }
    
    // Helper functions
    private fun generateSalt(): String {
        val salt = ByteArray(16)
        SecureRandom().nextBytes(salt)
        return Base64.encodeToString(salt, Base64.DEFAULT)
    }
    
    private fun hashPassword(password: String, salt: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val saltBytes = Base64.decode(salt, Base64.DEFAULT)
        digest.update(saltBytes)
        val hashedBytes = digest.digest(password.toByteArray())
        return Base64.encodeToString(hashedBytes, Base64.DEFAULT)
    }
}

// Extension functions for data conversion
private fun UserEntity.toUser() = User(
    id = id,
    name = name,
    email = email,
    avatarUrl = avatarUrl,
    phoneNumber = phoneNumber,
    createdAt = createdAt,
    hasPassword = hasPassword,
    isBiometricEnabled = isBiometricEnabled
)

private fun User.toEntity() = UserEntity(
    id = id,
    name = name,
    email = email,
    avatarUrl = avatarUrl,
    phoneNumber = phoneNumber,
    createdAt = createdAt,
    hasPassword = hasPassword,
    isBiometricEnabled = isBiometricEnabled
)

private fun UserSettingsEntity.toUserSettings() = UserSettings(
    userId = userId,
    notificationsEnabled = notificationsEnabled,
    emailNotifications = emailNotifications,
    pushNotifications = pushNotifications,
    privacyLevel = PrivacyLevel.valueOf(privacyLevel),
    autoLockEnabled = autoLockEnabled,
    autoLockTimeoutMinutes = autoLockTimeoutMinutes
)

private fun SecuritySettingsEntity.toSecuritySettings() = SecuritySettings(
    userId = userId,
    passwordHash = passwordHash,
    passwordSalt = passwordSalt,
    isBiometricEnabled = isBiometricEnabled,
    requirePasswordOnStartup = requirePasswordOnStartup,
    autoLockEnabled = autoLockEnabled,
    autoLockTimeoutMinutes = autoLockTimeoutMinutes,
    lastPasswordChange = lastPasswordChange,
    failedLoginAttempts = failedLoginAttempts,
    isAccountLocked = isAccountLocked,
    lockoutEndTime = lockoutEndTime
) 
