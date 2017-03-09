#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
+(DBManager*) getInstance;
-(void) insertLocationAt: (double) time latitude:(double) latitude longitude:(double) longitude;
-(NSArray*) selectLocationsAfter: (double) time;
-(int) deleteLocationsBefore:(double) time;
@end
