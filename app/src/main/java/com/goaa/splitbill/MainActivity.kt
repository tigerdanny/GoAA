package com.goaa.splitbill

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController

import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.goaa.splitbill.ui.screen.*
import com.goaa.splitbill.ui.theme.GoAATheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            GoAATheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    GoAAApp()
                }
            }
        }
    }
}

@Composable
fun GoAAApp() {
    val navController = rememberNavController()
    var showSplash by remember { mutableStateOf(true) }

    if (showSplash) {
        SplashScreen(
            onNavigateToMain = {
                showSplash = false
            }
        )
    } else {
        GoAANavigation(navController = navController)
    }
}

@Composable
fun GoAANavigation(navController: NavHostController) {
    NavHost(
        navController = navController,
        startDestination = "home"
    ) {
        composable("home") {
            HomeScreen(
                onNavigateToGroup = { groupId ->
                    navController.navigate("group_detail/$groupId")
                },
                onCreateGroup = {
                    navController.navigate("create_group")
                },
                onNavigateToProfile = {
                    navController.navigate("profile")
                }
            )
        }
        
        composable("group_detail/{groupId}") { backStackEntry ->
            val groupId = backStackEntry.arguments?.getString("groupId") ?: ""
            GroupDetailScreen(
                groupId = groupId,
                onNavigateBack = {
                    navController.popBackStack()
                },
                onAddExpense = {
                    navController.navigate("add_expense/$groupId")
                },
                onNavigateToSettle = {
                    navController.navigate("settlement/$groupId")
                },
                onNavigateToMembers = {
                    navController.navigate("members/$groupId")
                }
            )
        }
        
        composable("add_expense/{groupId}") { backStackEntry ->
            val groupId = backStackEntry.arguments?.getString("groupId") ?: ""
            AddExpenseScreen(
                groupId = groupId,
                onNavigateBack = {
                    navController.popBackStack()
                },
                onSaveExpense = {
                    navController.popBackStack()
                }
            )
        }
        
        composable("settlement/{groupId}") { backStackEntry ->
            val groupId = backStackEntry.arguments?.getString("groupId") ?: ""
            SettlementScreen(
                groupId = groupId,
                onNavigateBack = {
                    navController.popBackStack()
                },
                onMarkAsSettled = { settlement ->
                    // TODO: Handle settlement marking
                }
            )
        }
        
        composable("create_group") {
            CreateGroupScreen(
                onNavigateBack = {
                    navController.popBackStack()
                },
                onGroupCreated = { groupId ->
                    navController.navigate("group_detail/$groupId") {
                        popUpTo("home")
                    }
                }
            )
        }
        
        composable("profile") {
            ProfileScreen(
                onNavigateBack = {
                    navController.popBackStack()
                },
                onNavigateToEditProfile = {
                    navController.navigate("edit_profile")
                },
                onNavigateToPasswordSettings = {
                    navController.navigate("password_settings")
                },
                onNavigateToAbout = {
                    navController.navigate("about")
                }
            )
        }
        
        composable("edit_profile") {
            EditProfileScreen(
                onNavigateBack = {
                    navController.popBackStack()
                },
                onNavigateToAvatarPicker = { selectedAvatarId ->
                    navController.navigate("avatar_picker?selectedId=${selectedAvatarId ?: ""}")
                }
            )
        }
        
        composable("avatar_picker?selectedId={selectedId}") { backStackEntry ->
            val selectedId = backStackEntry.arguments?.getString("selectedId")?.takeIf { it.isNotEmpty() }
            AvatarPickerScreen(
                selectedAvatarId = selectedId,
                onAvatarSelected = { avatar ->
                    // Update user avatar and navigate back
                    navController.previousBackStackEntry?.savedStateHandle?.set("selected_avatar", avatar.id)
                },
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
        
        composable("password_settings") {
            PasswordSettingsScreen(
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
        
        composable("about") {
            AboutScreen(
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
        
        composable("members/{groupId}") { backStackEntry ->
            val groupId = backStackEntry.arguments?.getString("groupId") ?: ""
            MembersScreen(
                groupId = groupId,
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
    }
} 
