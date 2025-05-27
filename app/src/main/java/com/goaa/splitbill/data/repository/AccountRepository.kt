package com.goaa.splitbill.data.repository

import kotlinx.coroutines.flow.Flow
import com.goaa.splitbill.data.database.dao.AccountDao
import com.goaa.splitbill.data.database.entity.AccountEntity
import com.goaa.splitbill.data.model.Group
import java.util.Date
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AccountRepository @Inject constructor(
    private val accountDao: AccountDao
) {
    
    fun getAllAccounts(): Flow<List<AccountEntity>> {
        return accountDao.getAllActiveAccounts()
    }
    
    suspend fun getAccountById(id: String): AccountEntity? {
        return accountDao.getAccountById(id)
    }
    
    suspend fun createAccount(name: String, description: String?, createdBy: String): String {
        val id = UUID.randomUUID().toString()
        val now = Date()
        val account = AccountEntity(
            id = id,
            name = name,
            description = description,
            createdBy = createdBy,
            createdAt = now,
            updatedAt = now
        )
        accountDao.insertAccount(account)
        return id
    }
    
    suspend fun updateAccount(account: AccountEntity) {
        val updatedAccount = account.copy(updatedAt = Date())
        accountDao.updateAccount(updatedAccount)
    }
    
    suspend fun deleteAccount(id: String) {
        accountDao.deleteAccount(id)
    }
    
    suspend fun getAccountsByUser(userId: String): List<AccountEntity> {
        return accountDao.getAccountsByUser(userId)
    }
    
    suspend fun getAccountCount(): Int {
        return accountDao.getActiveAccountCount()
    }
    
    // 辅助方法：将数据库实体转换为UI模型
    fun AccountEntity.toGroup(): Group {
        return Group(
            id = this.id,
            name = this.name,
            description = this.description,
            imageUrl = null,
            createdBy = this.createdBy
        )
    }
} 
