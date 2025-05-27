package com.goaa.splitbill.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.goaa.splitbill.data.repository.UserRepository
import com.goaa.splitbill.data.model.User
import com.goaa.splitbill.data.model.UserSettings
import com.goaa.splitbill.data.model.SecuritySettings
import com.goaa.splitbill.data.model.PasswordValidationResult
import com.goaa.splitbill.data.model.PasswordValidator
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val userRepository: UserRepository
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()
    
    private val _user = MutableStateFlow<User?>(null)
    val user: StateFlow<User?> = _user.asStateFlow()
    
    private val _userSettings = MutableStateFlow<UserSettings?>(null)
    val userSettings: StateFlow<UserSettings?> = _userSettings.asStateFlow()
    
    private val _securitySettings = MutableStateFlow<SecuritySettings?>(null)
    val securitySettings: StateFlow<SecuritySettings?> = _securitySettings.asStateFlow()
    
    // Mock current user ID - in real app this would come from authentication
    private val currentUserId = "current_user_id"
    
    init {
        loadUserData()
    }
    
    private fun loadUserData() {
        viewModelScope.launch {
            try {
                _uiState.value = _uiState.value.copy(isLoading = true)
                
                // Load user data
                val user = userRepository.getUser(currentUserId)
                if (user == null) {
                    // Create default user if not exists
                    val defaultUser = User(
                        id = currentUserId,
                        name = "我的帳戶",
                        email = "user@example.com"
                    )
                    userRepository.insertUser(defaultUser)
                    _user.value = defaultUser
                } else {
                    _user.value = user
                }
                
                // Load settings
                _userSettings.value = userRepository.getUserSettings(currentUserId)
                _securitySettings.value = userRepository.getSecuritySettings(currentUserId)
                
                _uiState.value = _uiState.value.copy(isLoading = false)
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message
                )
            }
        }
    }
    
    fun updateUserProfile(name: String, email: String, phoneNumber: String?) {
        viewModelScope.launch {
            try {
                userRepository.updateUserProfile(
                    userId = currentUserId,
                    name = name,
                    email = email,
                    avatarUrl = _user.value?.avatarUrl,
                    phoneNumber = phoneNumber
                )
                
                // Reload user data
                _user.value = userRepository.getUser(currentUserId)
                
                _uiState.value = _uiState.value.copy(
                    showSuccessMessage = "個人資料更新成功"
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    error = "更新失敗: ${e.message}"
                )
            }
        }
    }
    
    fun setPassword(password: String): PasswordValidationResult {
        val validation = PasswordValidator.validate(password)
        if (!validation.isValid) {
            return validation
        }
        
        viewModelScope.launch {
            try {
                val success = userRepository.setPassword(currentUserId, password)
                if (success) {
                    _user.value = userRepository.getUser(currentUserId)
                    _securitySettings.value = userRepository.getSecuritySettings(currentUserId)
                    _uiState.value = _uiState.value.copy(
                        showSuccessMessage = "密碼設置成功"
                    )
                } else {
                    _uiState.value = _uiState.value.copy(
                        error = "密碼設置失敗"
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    error = "密碼設置失敗: ${e.message}"
                )
            }
        }
        
        return validation
    }
    
    fun removePassword() {
        viewModelScope.launch {
            try {
                val success = userRepository.removePassword(currentUserId)
                if (success) {
                    _user.value = userRepository.getUser(currentUserId)
                    _securitySettings.value = userRepository.getSecuritySettings(currentUserId)
                    _uiState.value = _uiState.value.copy(
                        showSuccessMessage = "密碼已移除"
                    )
                } else {
                    _uiState.value = _uiState.value.copy(
                        error = "移除密碼失敗"
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    error = "移除密碼失敗: ${e.message}"
                )
            }
        }
    }
    
    fun updateBiometricSettings(enabled: Boolean) {
        viewModelScope.launch {
            try {
                userRepository.updateBiometricSettings(currentUserId, enabled)
                _user.value = userRepository.getUser(currentUserId)
                _securitySettings.value = userRepository.getSecuritySettings(currentUserId)
                
                val message = if (enabled) "生物識別已啟用" else "生物識別已停用"
                _uiState.value = _uiState.value.copy(
                    showSuccessMessage = message
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    error = "設置失敗: ${e.message}"
                )
            }
        }
    }
    
    fun clearMessages() {
        _uiState.value = _uiState.value.copy(
            error = null,
            showSuccessMessage = null
        )
    }
}

data class ProfileUiState(
    val isLoading: Boolean = false,
    val error: String? = null,
    val showSuccessMessage: String? = null
) 
