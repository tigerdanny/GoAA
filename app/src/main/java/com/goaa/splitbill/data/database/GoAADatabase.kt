package com.goaa.splitbill.data.database

import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import android.content.Context
import com.goaa.splitbill.data.database.entity.AccountEntity
import com.goaa.splitbill.data.database.entity.ExpenseEntity
import com.goaa.splitbill.data.database.entity.MemberEntity
import com.goaa.splitbill.data.database.entity.UserEntity
import com.goaa.splitbill.data.database.entity.UserSettingsEntity
import com.goaa.splitbill.data.database.entity.SecuritySettingsEntity
import com.goaa.splitbill.data.database.dao.AccountDao
import com.goaa.splitbill.data.database.dao.ExpenseDao
import com.goaa.splitbill.data.database.dao.MemberDao
import com.goaa.splitbill.data.database.dao.UserDao
import com.goaa.splitbill.data.database.dao.UserSettingsDao
import com.goaa.splitbill.data.database.dao.SecuritySettingsDao
import com.goaa.splitbill.data.database.converter.DateConverter

@Database(
    entities = [
        AccountEntity::class,
        ExpenseEntity::class,
        MemberEntity::class,
        UserEntity::class,
        UserSettingsEntity::class,
        SecuritySettingsEntity::class
    ],
    version = 2,
    exportSchema = false
)
@TypeConverters(DateConverter::class)
abstract class GoAADatabase : RoomDatabase() {
    
    abstract fun accountDao(): AccountDao
    abstract fun expenseDao(): ExpenseDao
    abstract fun memberDao(): MemberDao
    abstract fun userDao(): UserDao
    abstract fun userSettingsDao(): UserSettingsDao
    abstract fun securitySettingsDao(): SecuritySettingsDao
    
    companion object {
        @Volatile
        private var INSTANCE: GoAADatabase? = null
        
        fun getDatabase(context: Context): GoAADatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    GoAADatabase::class.java,
                    "goaa_database"
                )
                    .fallbackToDestructiveMigration()
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }
} 
