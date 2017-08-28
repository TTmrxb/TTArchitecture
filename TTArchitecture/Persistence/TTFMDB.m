//
//  TTFMDB.m
//  TTArchitecture
//
//  Created by jyzx101 on 2017/8/28.
//  Copyright © 2017年 elliot. All rights reserved.
//

#import "TTFMDB.h"

#import "TTConfiguration.h"
#import "NSDateFormatter+TT.h"

#import <objc/runtime.h>
#import <FMDB.h>

NSString * const kSQlNull    = @"NULL";
NSString * const kSQlInteger = @"INTEGER";
NSString * const kSQlReal    = @"REAL";
NSString * const kSQlText    = @"TEXT";
NSString * const kSQlBlob    = @"BLOB";

@interface TTFMDB ()

@property (nonatomic, strong) FMDatabase *dataBase;

@end

@implementation TTFMDB

#pragma mark - 数据库实例

+ (instancetype)dataBaseInstance {
    
    static TTFMDB * db = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        db = [[self alloc] init];
        
        FMDatabase *dataBase = [TTFMDB userDateBase];
        
        if ([dataBase open]) {
            
            db.dataBase = dataBase;
        }else {
            
            DLog(@"打开数据失败");
        }
    });
    
    return db;
}

+ (FMDatabase *)dataBaseWithFileName:(NSString *)fileName {
    
    return [FMDatabase databaseWithPath:fileName];
}

+ (FMDatabase *)userDateBase {
    
    NSString *name = @"user";
    
    NSString *docuPath
    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    
    NSString *dbName = [NSString stringWithFormat:@"%@.sqlite", name];
    NSString *filePath = [docuPath stringByAppendingPathComponent:@"Persistence"];
    
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:filePath
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:nil];
    
    NSString *fileName;
    if (success) {
        
        fileName = [filePath stringByAppendingPathComponent:dbName];
    }else {
        
        fileName = [docuPath stringByAppendingPathComponent:dbName];
    }
    
    DLog(@"数据库 path = %@", fileName);
    
    return [self dataBaseWithFileName:fileName];
}

- (BOOL)open {
    
    FMDatabase *dataBase = [TTFMDB userDateBase];
    
    if ([dataBase open]) {
        
        self.dataBase = dataBase;
        return YES;
    }else {
        
        DLog(@"打开数据失败");
        return NO;
    }
}

- (BOOL)close {
    
    return [self.dataBase close];
}

#pragma mark - 数据表

- (BOOL)createTable:(NSString *)tableName dictionary:(NSDictionary *)dict primaryKey:(NSString *)primaryKey {
    
    BOOL isSuccess = NO;
    
    if(!primaryKey || [primaryKey isEqualToString:@""]) primaryKey = @"id";
    
    NSMutableString *sql = [NSMutableString stringWithFormat:
                            @"CREATE TABLE IF NOT EXISTS %@ (%@ integer PRIMARY KEY AUTOINCREMENT,",
                            tableName, primaryKey];
    
    NSArray *propFieldArr = dict.allKeys;
    for (NSInteger i = 0; i < propFieldArr.count; i++) {
        
        NSString *fieldName = propFieldArr[i];
        
        if ([fieldName isEqualToString:primaryKey]) continue;
        
        if (i == propFieldArr.count - 1) {
            
            [sql appendFormat:@" %@ %@)", fieldName, dict[fieldName]];
            break;
        }
        
        [sql appendFormat:@" %@ %@,", fieldName, dict[fieldName]];
    }
    
    DLog(@"创建表 sql = %@", sql);
    
    isSuccess = [self.dataBase executeUpdate:sql];
    
    return isSuccess;
}

- (BOOL)createTable:(NSString *)tableName model:(id)model primaryKey:(NSString *)primaryKey {
    
    NSDictionary *sqlDict = [self sqlTypeDictionaryFromModel:model];
    return [self createTable:tableName dictionary:sqlDict primaryKey:primaryKey];
}

- (BOOL)dropTable:(NSString *)tableName {
    
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    return [self.dataBase executeUpdate:sql];
}

#pragma mark - CRUD

- (BOOL)insertTable:(NSString *)tableName dictionary:(NSDictionary *)dict {
    
    BOOL isSuccess = NO;
    /**
     INSERT INTO authors (identifier, name, date, comment) VALUES (?, ?, ?, ?)", @(identifier), name, date, comment ?: [NSNull null]];
     **/
    NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT INTO %@ (", tableName];
    
    NSMutableString *placeholder = [NSMutableString string];
    NSMutableArray *valueArr = [NSMutableArray array];
    for (NSString *fieldName in dict.allKeys) {
        
        [sql appendFormat:@"%@, ", fieldName];
        [placeholder appendString:@"?, "];
        [valueArr addObject:dict[fieldName]];
    }
    
    if (sql.length > 2) {
        
        [sql deleteCharactersInRange:NSMakeRange(sql.length - 2, 2)];
    }
    
    if (placeholder.length > 2) {
        
        [placeholder deleteCharactersInRange:NSMakeRange(placeholder.length - 2, 2)];
    }
    
    [sql appendFormat:@") VALUES (%@)", placeholder];
    
    DLog(@"插入表 sql = %@, values = %@", sql, valueArr);
    
    isSuccess = [self.dataBase executeUpdate:sql withArgumentsInArray:valueArr];
    
    return isSuccess;
}

- (BOOL)insertTable:(NSString *)tableName model:(id)model {
    
    NSDictionary *sqlDict = [self dictionaryFromModel:model];
    return [self insertTable:tableName dictionary:sqlDict];
}

- (BOOL)deleteAllDataFromTable:(NSString *)tableName {
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    return [self.dataBase executeUpdate:sql];
}

- (BOOL)deleteFromTable:(NSString *)tableName condition:(NSString *)condition {
    
    if (!condition || [condition isEqualToString:@""]) {
        
        return [self deleteAllDataFromTable:tableName];
    }
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", tableName, condition];
    return [self.dataBase executeUpdate:sql];
}

- (BOOL)updateTable:(NSString *)tableName dictionary:(NSDictionary *)dict condition:(NSString *)condition {
    
    BOOL isSuccess = NO;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", tableName];
    
    NSMutableArray *valueArr = [NSMutableArray array];
    if (!condition || [condition isEqualToString:@""]) {
        
        for (NSString *fieldName in dict.allKeys) {
            
            [sql appendFormat:@"%@ = ?, ", fieldName];
            [valueArr addObject:dict[fieldName]];
        }
    }
    
    if (sql.length > 0) {
        
        [sql deleteCharactersInRange:NSMakeRange(sql.length - 2, 2)];
    }
    
    if (condition && ![condition isEqualToString:@""]) {
        
        [sql appendFormat:@" WHERE %@", condition];
    }
    
    DLog(@"更新数据表 sql = %@, value = %@", sql, valueArr);
    
    isSuccess = [self.dataBase executeUpdate:sql withArgumentsInArray:valueArr];
    
    return isSuccess;
}

- (BOOL)updateTable:(NSString *)tableName model:(id)model condition:(NSString *)condition {
    
    NSDictionary *sqlDict = [self dictionaryFromModel:model];
    return [self updateTable:tableName dictionary:sqlDict condition:condition];
}

- (NSArray *)queryTable:(NSString *)tableName dictionary:(NSDictionary *)dict condition:(NSString *)condition {
    
    NSMutableArray *result = [NSMutableArray array];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@", tableName];
    if (condition && ![condition isEqualToString:@""]) {
        
        [sql appendFormat:@" WHERE %@", condition];
    }
    
    DLog(@"查询表 sql = %@, sqDict = %@", sql, dict);
    
    FMResultSet *set = [self.dataBase executeQuery:sql];
    
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    while ([set next]) {
        
        [resultDict removeAllObjects];
        for (NSString *fieldName in dict.allKeys) {
            
            NSString *sqlType = dict[fieldName];
            if ([sqlType isEqualToString:kSQlText]) {
                
                NSString *value = [set stringForColumn:fieldName];
                [resultDict setObject:value forKey:fieldName];
            }else if ([sqlType isEqualToString:kSQlInteger]) {
                
                NSInteger value = [set intForColumn:fieldName];
                [resultDict setObject:@(value) forKey:fieldName];
            }else if ([sqlType isEqualToString:kSQlReal]) {
                
                double value = [set doubleForColumn:fieldName];
                [resultDict setObject:@(value) forKey:fieldName];
            }else if ([sqlType isEqualToString:kSQlBlob]) {
                
                NSData *value = [set dataForColumn:fieldName];
                [resultDict setObject:value forKey:fieldName];
            }
        }
        
        DLog(@"查询当前记录信息 = %@", resultDict);
        
        [result addObject:resultDict];
    }
    
    return result.copy;
}

- (NSArray *)queryTable:(NSString *)tableName model:(id)model condition:(NSString *)condition {
    
    NSDictionary *sqlTypeDict = [self sqlTypeDictionaryFromModel:model];
    NSMutableArray *result = [NSMutableArray array];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@", tableName];
    if (condition && ![condition isEqualToString:@""]) {
        
        [sql appendFormat:@" WHERE %@", condition];
    }
    
    DLog(@"查询表 sql = %@, sqDict = %@", sql, sqlTypeDict);
    
    FMResultSet *set = [self.dataBase executeQuery:sql];
    
    while ([set next]) {
        
        id queryModel = [[[model class] alloc] init];
        
        for (NSString *fieldName in sqlTypeDict.allKeys) {
            
            NSString *sqlType = sqlTypeDict[fieldName];
            if ([sqlType isEqualToString:kSQlText]) {
                
                NSString *value = [set stringForColumn:fieldName];
                [queryModel setValue:value forKey:fieldName];
            }else if ([sqlType isEqualToString:kSQlInteger]) {
                
                NSInteger value = [set intForColumn:fieldName];
                [queryModel setValue:@(value) forKey:fieldName];
            }else if ([sqlType isEqualToString:kSQlReal]) {
                
                double value = [set doubleForColumn:fieldName];
                [queryModel setValue:@(value) forKey:fieldName];
            }else if ([sqlType isEqualToString:kSQlBlob]) {
                
                NSData *value = [set dataForColumn:fieldName];
                [queryModel setValue:value forKey:fieldName];
            }
        }
        
        [result addObject:queryModel];
    }
    
    return result.copy;
}

- (NSInteger)countOfRecordsTable:(NSString *)tableName condition:(NSString *)condition {
    
    NSInteger count = 0;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT count(*) FROM %@", tableName];
    
    if (condition && ![condition isEqualToString:@""]) {
        
        [sql appendFormat:@" WHERE %@", condition];
    }
    
    DLog(@"查询记录条数 sql = %@", sql);
    
    count = [self.dataBase intForQuery:sql];
    
    return count;
}

#pragma mark - Utility

- (NSDictionary *)sqlTypeDictionaryFromModel:(id)model {
    
    NSMutableDictionary *propDict = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    objc_property_t *propertyList = class_copyPropertyList([model class], &outCount);
    for (NSInteger i = 0; i < outCount; i++) {
        
        NSString *propName = [NSString stringWithCString:property_getName(propertyList[i])
                                                encoding:NSUTF8StringEncoding];
        
        NSString *propType = [NSString stringWithCString:property_getAttributes(propertyList[i])
                                                encoding:NSUTF8StringEncoding];
        NSString *sqlType = [self sqlTypeFromPropertyType:propType];
        if (sqlType) {
            
            [propDict setObject:sqlType forKey:propName];
        }
    }
    
    free(propertyList);
    
    return propDict.copy;
}

- (NSString *)sqlTypeFromPropertyType:(NSString *)propType {
    
    NSString *sqlType = nil;
    
    if ([propType hasPrefix:@"T@\"NSString\""] || [propType hasPrefix:@"T@\"NSDate\""]) {
        
        sqlType = kSQlText;
    } else if ([propType hasPrefix:@"T@\"NSData\""]) {
        
        sqlType = kSQlBlob;
    } else if ([propType hasPrefix:@"Ti"] || [propType hasPrefix:@"TI"]
               || [propType hasPrefix:@"Ts"] || [propType hasPrefix:@"TS"]
               || [propType hasPrefix:@"T@\"NSNumber\""] || [propType hasPrefix:@"TB"]
               || [propType hasPrefix:@"Tq"] || [propType hasPrefix:@"TQ"]) {
        
        sqlType = kSQlInteger;
    } else if ([propType hasPrefix:@"Tf"] || [propType hasPrefix:@"Td"]){
        
        sqlType= kSQlReal;
    }
    
    return sqlType;
}

- (NSDictionary *)dictionaryFromModel:(id)model {
    
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    objc_property_t *propertyList = class_copyPropertyList([model class], &outCount);
    for (NSInteger i = 0; i < outCount; i++) {
        
        NSString *propName = [NSString stringWithCString:property_getName(propertyList[i])
                                                encoding:NSUTF8StringEncoding];
        
        id value = [model valueForKey:propName];
        if ([value isKindOfClass:[NSDate class]]) {
            
            value = [[NSDateFormatter ymdhmsDashFormatter] stringFromDate:value];
        }
        
        [infoDict setObject:value forKey:propName];
    }
    
    free(propertyList);
    
    return infoDict.copy;
}

@end
