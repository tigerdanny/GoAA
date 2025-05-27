package com.goaa.splitbill.di

import android.content.Context
import androidx.room.Room
import com.goaa.splitbill.data.database.GoAADatabase
import com.goaa.splitbill.data.database.dao.AccountDao
import com.goaa.splitbill.data.database.dao.ExpenseDao
import com.goaa.splitbill.data.database.dao.MemberDao
import com.goaa.splitbill.data.database.dao.UserDao
import com.goaa.splitbill.data.database.dao.UserSettingsDao
import com.goaa.splitbill.data.database.dao.SecuritySettingsDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    
    @Provides
    @Singleton
    fun provideGoAADatabase(@ApplicationContext context: Context): GoAADatabase {
        return Room.databaseBuilder(
            context.applicationContext,
            GoAADatabase::class.java,
            "goaa_database"
        )
            .fallbackToDestructiveMigration()
            .build()
    }
    
    @Provides
    fun provideAccountDao(database: GoAADatabase): AccountDao {
        return database.accountDao()
    }
    
    @Provides
    fun provideExpenseDao(database: GoAADatabase): ExpenseDao {
        return database.expenseDao()
    }
    
    @Provides
    fun provideMemberDao(database: GoAADatabase): MemberDao {
        return database.memberDao()
    }
    
    @Provides
    fun provideUserDao(database: GoAADatabase): UserDao {
        return database.userDao()
    }
    
    @Provides
    fun provideUserSettingsDao(database: GoAADatabase): UserSettingsDao {
        return database.userSettingsDao()
    }
    
    @Provides
    fun provideSecuritySettingsDao(database: GoAADatabase): SecuritySettingsDao {
        return database.securitySettingsDao()
    }
} 
