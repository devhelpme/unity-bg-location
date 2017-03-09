#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

-(void) startLocationService;
-(void) stopLocationService;
-(NSString *) getLocationsJson: (double) time;
-(void) deleteLocationsBefore: (double) time;

@end
