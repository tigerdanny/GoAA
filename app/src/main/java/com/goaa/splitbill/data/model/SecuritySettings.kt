package com.goaa.splitbill.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "security_settings")
data class SecuritySettings(
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

data class PasswordValidationResult(
    val isValid: Boolean,
    val errors: List<String> = emptyList()
)

object PasswordValidator {
    fun validate(password: String): PasswordValidationResult {
        val errors = mutableListOf<String>()
        
        if (password.length < 6) {
            errors.add("密碼長度至少需要6個字符")
        }
        
        if (!password.any { it.isUpperCase() }) {
            errors.add("密碼需要包含至少一個大寫字母")
        }
        
        if (!password.any { it.isLowerCase() }) {
            errors.add("密碼需要包含至少一個小寫字母")
        }
        
        if (!password.any { it.isDigit() }) {
            errors.add("密碼需要包含至少一個數字")
        }
        
        return PasswordValidationResult(
            isValid = errors.isEmpty(),
            errors = errors
        )
    }
} 
