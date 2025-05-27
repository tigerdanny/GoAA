package com.goaa.splitbill.data.database.dao

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import com.goaa.splitbill.data.database.entity.AccountEntity
import java.util.Date

@Dao
interface AccountDao {
    @Query("SELECT * FROM accounts WHERE isActive = 1 ORDER BY updatedAt DESC")
    fun getAllActiveAccounts(): Flow<List<AccountEntity>>
    
    @Query("SELECT * FROM accounts WHERE id = :id")
    suspend fun getAccountById(id: String): AccountEntity?
    
    @Query("SELECT * FROM accounts WHERE createdBy = :userId AND isActive = 1")
    suspend fun getAccountsByUser(userId: String): List<AccountEntity>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAccount(account: AccountEntity)
    
    @Update
    suspend fun updateAccount(account: AccountEntity)
    
    @Query("UPDATE accounts SET isActive = 0, updatedAt = :deletedAt WHERE id = :id")
    suspend fun deleteAccount(id: String, deletedAt: Date = Date())
    
    @Query("SELECT COUNT(*) FROM accounts WHERE isActive = 1")
    suspend fun getActiveAccountCount(): Int
} 
