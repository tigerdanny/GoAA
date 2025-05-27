package com.goaa.splitbill.data.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.ForeignKey
import androidx.room.Index
import java.util.Date

@Entity(
    tableName = "members",
    foreignKeys = [
        ForeignKey(
            entity = AccountEntity::class,
            parentColumns = ["id"],
            childColumns = ["accountId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["accountId"])]
)
data class MemberEntity(
    @PrimaryKey
    val id: String,
    val accountId: String,
    val userId: String,
    val userName: String,
    val userEmail: String?,
    val joinedAt: Date,
    val isActive: Boolean = true
) 
