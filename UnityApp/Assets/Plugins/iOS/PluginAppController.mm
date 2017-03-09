#import "UnityAppController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationManager.h"


@interface PluginAppController : UnityAppController

@property (retain, nonatomic) LocationManager* locationManager;

-(void) startLocationService;
-(void) stopLocationService;
-(char const*)  getLocationsJson: (double) time;
-(void) deleteLocationsBefore: (double) time;
@end


static PluginAppController* delegateObject; //a static object is defined to be called from "extern" method


@implementation PluginAppController

@synthesize locationManager;

-(void) startUnity: (UIApplication*) application {
    [super startUnity: application];
    delegateObject = self;
    locationManager = [[LocationManager alloc] init];
}


-(void) startLocationService {
    [locationManager startLocationService];
};

-(void) stopLocationService {
    [locationManager stopLocationService];
};

-(char const*) getLocationsJson: (double) time {
    char const *str =  [[locationManager getLocationsJson: time] UTF8String];
    char* jsn = (char*) malloc(strlen(str) + 1);
    strcpy(jsn, str);
    return jsn;
};

-(void) deleteLocationsBefore: (double) time{
  [locationManager deleteLocationsBefore: time];
};

extern "C" {
    void startLocationService() {
        [delegateObject startLocationService];
    }

    void stopLocationService() {
        [delegateObject stopLocationService];
    }

    char const* getLocationsJson(double time) {
        return [delegateObject getLocationsJson: time];
    }

    void deleteLocationsBefore(double time) {
        [delegateObject deleteLocationsBefore:time];
    }
}

@end

//settings this as app controller
IMPL_APP_CONTROLLER_SUBCLASS(PluginAppController);
