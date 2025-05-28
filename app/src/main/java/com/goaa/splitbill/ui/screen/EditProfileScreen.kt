package com.goaa.splitbill.ui.screen

import android.Manifest
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import coil.compose.AsyncImage
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import com.goaa.splitbill.data.model.DefaultAvatars
import com.goaa.splitbill.data.model.AvatarType
import com.goaa.splitbill.ui.viewmodel.ProfileViewModel
import com.goaa.splitbill.ui.theme.*
import java.io.File

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditProfileScreen(
    onNavigateBack: () -> Unit,
    onNavigateToAvatarPicker: (String?) -> Unit,
    navController: NavController,
    viewModel: ProfileViewModel = hiltViewModel()
) {
    val context = LocalContext.current
    val user by viewModel.user.collectAsStateWithLifecycle()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    
    var name by remember { mutableStateOf("") }
    var selectedAvatarId by remember { mutableStateOf<String?>(null) }
    var customImageUri by remember { mutableStateOf<String?>(null) }
    var showAvatarOptions by remember { mutableStateOf(false) }
    
    // 相機拍照
    var photoUri by remember { mutableStateOf<Uri?>(null) }
    val cameraLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicture()) { success ->
        if (success && photoUri != null) {
            customImageUri = photoUri.toString()
            selectedAvatarId = null // 清除預設頭像選擇
        }
    }
    
    // 相簿選擇
    val galleryLauncher = rememberLauncherForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        uri?.let {
            customImageUri = it.toString()
            selectedAvatarId = null // 清除預設頭像選擇
        }
    }
    
    // 相機權限
    val cameraPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            // 創建拍照URI
            val file = File(context.cacheDir, "avatar_photo_${System.currentTimeMillis()}.jpg")
            photoUri = FileProvider.getUriForFile(
                context,
                "com.goaa.splitbill.fileprovider",
                file
            )
            cameraLauncher.launch(photoUri)
        }
    }
    
    // Initialize fields when user data loads
    LaunchedEffect(user) {
        user?.let {
            name = it.name
            if (it.avatarUrl?.startsWith("content://") == true || it.avatarUrl?.startsWith("file://") == true) {
                customImageUri = it.avatarUrl
                selectedAvatarId = null
            } else {
                selectedAvatarId = it.avatarUrl
                customImageUri = null
            }
        }
    }
    
    // 監聽從頭像選擇器返回的結果
    LaunchedEffect(navController) {
        navController.currentBackStackEntry?.savedStateHandle?.let { handle ->
            handle.get<String>("selected_avatar")?.let { avatarId ->
                if (avatarId.isNotEmpty()) {
                    selectedAvatarId = avatarId
                    customImageUri = null // 清除自定義圖片
                    handle.remove<String>("selected_avatar")
                }
            }
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
                            val finalAvatarUrl = customImageUri ?: selectedAvatarId
                            viewModel.updateUserProfile(name, finalAvatarUrl)
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
                            // 顯示自定義圖片或預設頭像
                            when {
                                customImageUri != null -> {
                                    AsyncImage(
                                        model = customImageUri,
                                        contentDescription = "自定義頭像",
                                        modifier = Modifier.fillMaxSize(),
                                        contentScale = ContentScale.Crop
                                    )
                                }
                                selectedAvatarId != null -> {
                                    val avatar = DefaultAvatars.getAvatarById(selectedAvatarId!!)
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
                                else -> {
                                    Icon(
                                        Icons.Default.Person,
                                        contentDescription = "頭像",
                                        modifier = Modifier.size(48.dp),
                                        tint = OnSurfaceVariant
                                    )
                                }
                            }
                        }
                        
                        Spacer(modifier = Modifier.height(16.dp))
                        
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            OutlinedButton(
                                onClick = { showAvatarOptions = true },
                                modifier = Modifier.weight(1f)
                            ) {
                                Icon(Icons.Default.Edit, contentDescription = null)
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("選擇頭像")
                            }
                        }
                        
                        // 頭像選項底部彈窗
                        if (showAvatarOptions) {
                            AlertDialog(
                                onDismissRequest = { showAvatarOptions = false },
                                title = { Text("選擇頭像來源") },
                                text = {
                                    Column(
                                        verticalArrangement = Arrangement.spacedBy(8.dp)
                                    ) {
                                        Row(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .clickable {
                                                    showAvatarOptions = false
                                                    cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
                                                }
                                                .padding(12.dp),
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Icon(Icons.Default.CameraAlt, contentDescription = null)
                                            Spacer(modifier = Modifier.width(16.dp))
                                            Text("拍照")
                                        }
                                        
                                        Row(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .clickable {
                                                    showAvatarOptions = false
                                                    galleryLauncher.launch("image/*")
                                                }
                                                .padding(12.dp),
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Icon(Icons.Default.PhotoLibrary, contentDescription = null)
                                            Spacer(modifier = Modifier.width(16.dp))
                                            Text("從相簿選擇")
                                        }
                                        
                                        Row(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .clickable {
                                                    showAvatarOptions = false
                                                    onNavigateToAvatarPicker(selectedAvatarId)
                                                }
                                                .padding(12.dp),
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Icon(Icons.Default.Palette, contentDescription = null)
                                            Spacer(modifier = Modifier.width(16.dp))
                                            Text("可愛頭像")
                                        }
                                    }
                                },
                                confirmButton = {
                                    TextButton(onClick = { showAvatarOptions = false }) {
                                        Text("取消")
                                    }
                                }
                            )
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
