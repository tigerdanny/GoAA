package com.goaa.splitbill.data.database.dao

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import com.goaa.splitbill.data.database.entity.ExpenseEntity
import java.util.Date

@Dao
interface ExpenseDao {
    @Query("SELECT * FROM expenses WHERE accountId = :accountId AND isDeleted = 0 ORDER BY createdAt DESC")
    fun getExpensesByAccount(accountId: String): Flow<List<ExpenseEntity>>
    
    @Query("SELECT * FROM expenses WHERE id = :id")
    suspend fun getExpenseById(id: String): ExpenseEntity?
    
    @Query("SELECT * FROM expenses WHERE paidBy = :userId AND isDeleted = 0")
    suspend fun getExpensesByPayer(userId: String): List<ExpenseEntity>
    
    @Query("SELECT SUM(amount) FROM expenses WHERE accountId = :accountId AND isDeleted = 0")
    suspend fun getTotalExpenseByAccount(accountId: String): Double?
    
    @Query("SELECT COUNT(*) FROM expenses WHERE accountId = :accountId AND isDeleted = 0")
    suspend fun getExpenseCountByAccount(accountId: String): Int
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertExpense(expense: ExpenseEntity)
    
    @Update
    suspend fun updateExpense(expense: ExpenseEntity)
    
    @Query("UPDATE expenses SET isDeleted = 1, updatedAt = :deletedAt WHERE id = :id")
    suspend fun deleteExpense(id: String, deletedAt: Date = Date())
    
    // 分类统计将在repository层处理
    @Query("SELECT * FROM expenses WHERE accountId = :accountId AND isDeleted = 0")
    suspend fun getAllExpensesByAccount(accountId: String): List<ExpenseEntity>
} 
