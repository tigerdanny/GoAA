package com.goaa.splitbill.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "groups")
data class Group(
    @PrimaryKey
    val id: String,
    val name: String,
    val description: String? = null,
    val imageUrl: String? = null,
    val createdBy: String, // User ID
    val createdAt: Long = System.currentTimeMillis(),
    val isActive: Boolean = true
) 
