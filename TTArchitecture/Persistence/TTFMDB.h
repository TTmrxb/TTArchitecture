//
//  TTFMDB.h
//  TTArchitecture
//
//  Created by jyzx101 on 2017/8/28.
//  Copyright © 2017年 elliot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface TTFMDB : NSObject

#pragma mark - 数据库实例

+ (instancetype)dataBaseInstance;

- (instancetype)init __attribute__((unavailable("请使用dataBaseInstance方法获取单例")));

+ (FMDatabase *)dataBaseWithFileName:(NSString *)fileName;

- (BOOL)open;

- (BOOL)close;

#pragma mark - 数据表

- (BOOL)createTable:(NSString *)tableName
         dictionary:(NSDictionary *)dict
         primaryKey:(NSString *)primaryKey;

- (BOOL)createTable:(NSString *)tableName model:(id)model primaryKey:(NSString *)primaryKey;

- (BOOL)dropTable:(NSString *)tableName;

#pragma mark - CRUD

- (BOOL)insertTable:(NSString *)tableName dictionary:(NSDictionary *)dict;

- (BOOL)insertTable:(NSString *)tableName model:(id)model;

- (BOOL)deleteAllDataFromTable:(NSString *)tableName;

- (BOOL)deleteFromTable:(NSString *)tableName condition:(NSString *)condition;

- (BOOL)updateTable:(NSString *)tableName
         dictionary:(NSDictionary *)dict
          condition:(NSString *)condition;

- (BOOL)updateTable:(NSString *)tableName model:(id)model condition:(NSString *)condition;

- (NSArray *)queryTable:(NSString *)tableName
             dictionary:(NSDictionary *)dict
              condition:(NSString *)condition;

- (NSArray *)queryTable:(NSString *)tableName model:(id)model condition:(NSString *)condition;

/**
 查询符合条件的记录数
 */
- (NSInteger)countOfRecordsTable:(NSString *)tableName condition:(NSString *)condition;

@end
