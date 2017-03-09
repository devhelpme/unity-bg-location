
#import <Foundation/Foundation.h>
#import "LocationManager.h"
#import "DBManager.h"

static CLLocationDistance const minDistanceMetters = 1.0;

@interface LocationManager ()

@property (nonatomic , strong)  CLLocationManager *locationManager;
@property (nonatomic , strong)  CLLocation *lastLocation;

@end

@implementation LocationManager

-(id) init {
    self = [super init];
    NSLog(@"iOS -> Location manager: init");
    
    self.locationManager =[[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    
    return self;
}

-(NSString *) getLocationsJson: (double) time {
    NSLog(@"iOS -> Location manager: getLocationsString, time = %f", time);
    NSArray *arr = [[DBManager getInstance] selectLocationsAfter:time];
    
    NSLog(@"iOS -> Location manager: getLocationsString, got elements in Array %lu", (unsigned long)arr.count);
    NSError* error;
    NSData* json = [NSJSONSerialization
                    dataWithJSONObject:arr
                    options:kNilOptions
                    error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSLog(@"iOS -> Location manager: getLocationsString, json= %@", jsonString);
    
    return jsonString;
};


-(void) startLocationService {
    NSLog(@"iOS -> Location manager: startLocationService");
    if([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"iOS -> Location manager: location services disabled");
    }
};


-(void) stopLocationService {
    NSLog(@"iOS -> Location manager: stopLocationService");
    if([CLLocationManager locationServicesEnabled]) {
        [self.locationManager stopUpdatingLocation];
    } else {
        NSLog(@"iOS -> Location manager: location services disabled");
    }
};


-(void) deleteLocationsBefore:(double)time {
    NSLog(@"iOS -> Location manager: deleteLocationsBefore time = %f", time);
    int records = [[DBManager getInstance] deleteLocationsBefore:time];
    NSLog(@"iOS -> Location manager: deleted records = %d", records);
}


#pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if(locations.count == 0) {
        return;
    }
    
    
    for(CLLocation *newLocation in locations) {
        if(!self.lastLocation ||
           [newLocation distanceFromLocation:self.lastLocation] > minDistanceMetters) {
            NSLog(@"iOS -> CLLocationManagerDelegate: Got new location: %@", newLocation);
            self.lastLocation = newLocation;
            //save to DB
            [[DBManager getInstance] insertLocationAt:([[NSDate date] timeIntervalSince1970] * 1000)
                                             latitude: newLocation.coordinate.latitude
                                            longitude:newLocation.coordinate.longitude];
        }
    }
}

-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSLog(@"iOS -> CLLocationManagerDelegate: Authorization status changed: %d", status);
}

-(void) locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"iOS -> CLLocationManagerDelegate: locationManagerDidPauseLocationUpdates");
}

-(void) locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"iOS -> CLLocationManagerDelegate: locationManagerDidResumeLocationUpdates");
}


@end
