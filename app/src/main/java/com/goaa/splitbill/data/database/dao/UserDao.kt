package com.goaa.splitbill.data.database.dao

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import com.goaa.splitbill.data.database.entity.UserEntity

@Dao
interface UserDao {
    
    @Query("SELECT * FROM users WHERE id = :userId")
    suspend fun getUserById(userId: String): UserEntity?
    
    @Query("SELECT * FROM users WHERE id = :userId")
    fun getUserByIdFlow(userId: String): Flow<UserEntity?>
    
    @Query("SELECT * FROM users WHERE email = :email")
    suspend fun getUserByEmail(email: String): UserEntity?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUser(user: UserEntity)
    
    @Update
    suspend fun updateUser(user: UserEntity)
    
    @Delete
    suspend fun deleteUser(user: UserEntity)
    
    @Query("UPDATE users SET hasPassword = :hasPassword WHERE id = :userId")
    suspend fun updatePasswordStatus(userId: String, hasPassword: Boolean)
    
    @Query("UPDATE users SET isBiometricEnabled = :enabled WHERE id = :userId")
    suspend fun updateBiometricStatus(userId: String, enabled: Boolean)
    
    @Query("UPDATE users SET name = :name, email = :email, avatarUrl = :avatarUrl, phoneNumber = :phoneNumber WHERE id = :userId")
    suspend fun updateUserProfile(
        userId: String,
        name: String,
        email: String,
        avatarUrl: String?,
        phoneNumber: String?
    )
} 
