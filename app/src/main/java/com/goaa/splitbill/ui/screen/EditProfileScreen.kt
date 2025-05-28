package com.goaa.splitbill.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.goaa.splitbill.data.model.DefaultAvatars
import com.goaa.splitbill.data.model.AvatarType
import com.goaa.splitbill.ui.viewmodel.ProfileViewModel
import com.goaa.splitbill.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditProfileScreen(
    onNavigateBack: () -> Unit,
    onNavigateToAvatarPicker: (String?) -> Unit,
    viewModel: ProfileViewModel = hiltViewModel()
) {
    val user by viewModel.user.collectAsStateWithLifecycle()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    
    var name by remember { mutableStateOf("") }
    var selectedAvatarId by remember { mutableStateOf<String?>(null) }
    
    // Initialize fields when user data loads
    LaunchedEffect(user) {
        user?.let {
            name = it.name
            selectedAvatarId = it.avatarUrl
        }
    }
    
    // Show success/error messages
    LaunchedEffect(uiState.showSuccessMessage, uiState.error) {
        uiState.showSuccessMessage?.let {
            // In real app, show snackbar
            viewModel.clearMessages()
        }
        uiState.error?.let {
            // In real app, show error snackbar
            viewModel.clearMessages()
        }
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("編輯個人資料") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "返回")
                    }
                },
                actions = {
                    TextButton(
                        onClick = {
                            viewModel.updateUserProfile(name, selectedAvatarId)
                            onNavigateBack()
                        }
                    ) {
                        Text("保存", color = Primary)
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            if (uiState.isLoading) {
                Box(
                    modifier = Modifier.fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            } else {
                // Profile photo section
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = Surface),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(20.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Box(
                            modifier = Modifier
                                .size(100.dp)
                                .clip(CircleShape)
                                .background(OnSurfaceVariant.copy(alpha = 0.1f)),
                            contentAlignment = Alignment.Center
                        ) {
                            // Show selected avatar or default
                            val avatar = selectedAvatarId?.let { DefaultAvatars.getAvatarById(it) }
                            if (avatar != null) {
                                Text(
                                    text = when (avatar.type) {
                                        AvatarType.MALE -> when (avatar.id.last()) {
                                            '1' -> "👨"
                                            '2' -> "🧑"
                                            '3' -> "👱‍♂️"
                                            '4' -> "🧔"
                                            '5' -> "👨‍💼"
                                            else -> "👨"
                                        }
                                        AvatarType.FEMALE -> when (avatar.id.last()) {
                                            '1' -> "👩"
                                            '2' -> "👱‍♀️"
                                            '3' -> "👩‍💼"
                                            '4' -> "👩‍🎓"
                                            '5' -> "🧕"
                                            else -> "👩"
                                        }
                                        AvatarType.CAT -> when (avatar.id.last()) {
                                            '1' -> "🐱"
                                            '2' -> "😸"
                                            '3' -> "😺"
                                            '4' -> "😻"
                                            '5' -> "🙀"
                                            else -> "🐱"
                                        }
                                        AvatarType.DOG -> when (avatar.id.last()) {
                                            '1' -> "🐶"
                                            '2' -> "🐕"
                                            '3' -> "🦮"
                                            '4' -> "🐕‍🦺"
                                            '5' -> "🐩"
                                            else -> "🐶"
                                        }
                                    },
                                    style = MaterialTheme.typography.displayMedium
                                )
                            } else {
                                Icon(
                                    Icons.Default.Person,
                                    contentDescription = "頭像",
                                    modifier = Modifier.size(48.dp),
                                    tint = OnSurfaceVariant
                                )
                            }
                        }
                        
                        Spacer(modifier = Modifier.height(16.dp))
                        
                        OutlinedButton(
                            onClick = { onNavigateToAvatarPicker(selectedAvatarId) }
                        ) {
                            Icon(Icons.Default.Edit, contentDescription = null)
                            Spacer(modifier = Modifier.width(8.dp))
                            Text("選擇頭像")
                        }
                    }
                }
                
                // Name field
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = Surface),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(
                            text = "基本資料",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(bottom = 16.dp)
                        )
                        
                        OutlinedTextField(
                            value = name,
                            onValueChange = { name = it },
                            label = { Text("姓名") },
                            leadingIcon = {
                                Icon(Icons.Default.Person, contentDescription = null)
                            },
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
                
                // Info card
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = Secondary.copy(alpha = 0.1f)),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            Icons.Default.Info,
                            contentDescription = null,
                            tint = Secondary,
                            modifier = Modifier.size(20.dp)
                        )
                        
                        Spacer(modifier = Modifier.width(12.dp))
                        
                        Text(
                            text = "選擇一個可愛的頭像來代表您的身份，姓名將顯示在分帳記錄中",
                            style = MaterialTheme.typography.bodySmall,
                            color = OnSurfaceVariant
                        )
                    }
                }
            }
        }
    }
} 
