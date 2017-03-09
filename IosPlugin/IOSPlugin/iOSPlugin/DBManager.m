#import "DBManager.h"

static DBManager *instance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@interface DBManager ()
-(void) createDB;
@property(nonatomic, strong) NSString *databasePath;
@end


@implementation DBManager

+(DBManager*) getInstance{
    if(!instance) {
        instance = [[super allocWithZone:nil] init];
        [instance createDB];
    }
    return instance;
}

-(void) createDB {
    NSLog(@"iOS -> DBManager createDB: Start");
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    self.databasePath = [[NSString alloc] initWithString:
                         [docsDir stringByAppendingPathComponent: @"devhelp.db"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath: self.databasePath] == NO) {
        NSLog(@"iOS -> DBManager createDB: creating DB file");
        const char *dbPath = [self.databasePath UTF8String];
        int openResult =  sqlite3_open(dbPath, &database);
        
        if(openResult == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE location (time REAL PRIMARY KEY, latitude REAL, longitude REAL);";
            int exec = sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) ;
            if(exec != SQLITE_OK) {
                NSLog(@"iOS -> DBManager createDB: Failed to create TABLE, result = %d, errMsg: %s", exec, errMsg);
            }
            sqlite3_close(database);
            
        } else {
            NSLog(@"iOS -> DBManager createDB: Failed to open/create database, result = %d, error: %s",
                  openResult, sqlite3_errmsg(database));
        }
    }
    NSLog(@"iOS -> DBManager createDB: Finish");
}

-(void) insertLocationAt:(double)time latitude:(double)latitude longitude:(double)longitude {
    NSLog(@"iOS -> DBManager insert: start with params %f, %f, %f", time, latitude, longitude);
    const char *dbPath = [self.databasePath UTF8String];
    int openResult =  sqlite3_open(dbPath, &database);
    if(openResult == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:
                         @"INSERT INTO location (time, latitude, longitude) VALUES(\"%f\", \"%f\", \"%f\")",
                         time, latitude, longitude ];
        const char *sql_stmt = [sql UTF8String];
        sqlite3_prepare_v2(database, sql_stmt, -1, &statement, NULL);
        int exec  = sqlite3_step(statement);
        if(exec != SQLITE_DONE) {
            NSLog(@"iOS -> DBManager insert: execution result = %d, msg: %s", exec, sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"iOS -> DBManager insert: Failed to open DB, result = %d, error : %s", openResult, sqlite3_errmsg(database));
    }
    sqlite3_close(database);
}

-(NSArray*) selectLocationsAfter: (double) time {
    NSLog(@"iOS -> DBManager select: start with params %f", time);
    
    NSMutableArray *resultArray  =[[NSMutableArray alloc] init];
    
    const char *dbPath = [self.databasePath UTF8String];
    int openResult =  sqlite3_open(dbPath, &database);
    if(openResult == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:
                         @"SELECT time, latitude, longitude FROM location WHERE time > %f", time];
        char const *sql_stmt = [sql UTF8String];
        
        int prepare = sqlite3_prepare_v2(database, sql_stmt, -1, &statement, NULL);
        if(prepare == SQLITE_OK) {
            while(sqlite3_step(statement) == SQLITE_ROW) {
                double time = sqlite3_column_double(statement, 0);
                double latitude = sqlite3_column_double(statement, 1);
                double longitude = sqlite3_column_double(statement, 2);
                
                NSMutableDictionary *rowData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithDouble:time], @"time",
                                                [NSNumber numberWithDouble:latitude], @"latitude",
                                                [NSNumber numberWithDouble:longitude], @"longitude",
                                                nil];
                
                [resultArray addObject:rowData];
            }
        } else {
            NSLog(@"iOS -> DBManager select: Failed prepare, result = %d, error : %s", prepare, sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"iOS -> DBManager select: Failed to open DB, result = %d, error : %s", openResult, sqlite3_errmsg(database));
    }
    
    sqlite3_close(database);
    return resultArray;
}

-(int) deleteLocationsBefore:(double)time {
    NSLog(@"iOS -> DBManager delete: start with param %f", time);
    int deletedRows;
    const char *dbPath = [self.databasePath UTF8String];
    int openResult =  sqlite3_open(dbPath, &database);
    if(openResult == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:
                         @"DELETE FROM location WHERE time < \"%f\"", time];
        const char *sql_stmt = [sql UTF8String];
        sqlite3_prepare_v2(database, sql_stmt, -1, &statement, NULL);
        int exec  = sqlite3_step(statement);
        if(exec == SQLITE_DONE) {
            deletedRows = sqlite3_changes(database);
            NSLog(@"iOS -> DBManager delete: affected rows = %d", deletedRows);
        } else {
            NSLog(@"iOS -> DBManager delete: execution result = %d, msg: %s", exec, sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"iOS -> DBManager delete: Failed to open DB, result = %d, error : %s", openResult, sqlite3_errmsg(database));
    }
    sqlite3_close(database);
    return deletedRows;
}

@end
