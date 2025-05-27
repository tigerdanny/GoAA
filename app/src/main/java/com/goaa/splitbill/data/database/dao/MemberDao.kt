package com.goaa.splitbill.data.database.dao

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import com.goaa.splitbill.data.database.entity.MemberEntity

@Dao
interface MemberDao {
    @Query("SELECT * FROM members WHERE accountId = :accountId AND isActive = 1")
    fun getMembersByAccount(accountId: String): Flow<List<MemberEntity>>
    
    @Query("SELECT * FROM members WHERE id = :id")
    suspend fun getMemberById(id: String): MemberEntity?
    
    @Query("SELECT * FROM members WHERE userId = :userId AND isActive = 1")
    suspend fun getMembersByUser(userId: String): List<MemberEntity>
    
    @Query("SELECT COUNT(*) FROM members WHERE accountId = :accountId AND isActive = 1")
    suspend fun getMemberCountByAccount(accountId: String): Int
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMember(member: MemberEntity)
    
    @Update
    suspend fun updateMember(member: MemberEntity)
    
    @Query("UPDATE members SET isActive = 0 WHERE id = :id")
    suspend fun deleteMember(id: String)
    
    @Query("SELECT * FROM members WHERE accountId = :accountId AND userId = :userId AND isActive = 1")
    suspend fun getMemberByAccountAndUser(accountId: String, userId: String): MemberEntity?
} 
