package me.devhelp.unityplugin;

import android.app.Service;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import static me.devhelp.unityplugin.UnityPluginActivity.LOG_TAG;

public class LocationService extends Service {
    public static final String PENDING_INTENT = "pendingIntent";
    private static final int LOCATION_INTERVAL = 1000;
    private static final float LOCATION_DISTANCE = 10f;

    private LocationManager locationManager;

    private LocationListener gpsListener = new LocationListener();
    private LocationListener networkListener = new LocationListener();

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }


    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(LOG_TAG, "LocationService:onCreate");
        locationManager = (LocationManager) getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(LOG_TAG, "LocationService:onDestroy");
        if (locationManager != null) {
            try {
                locationManager.removeUpdates(gpsListener);
                locationManager.removeUpdates(networkListener);
            } catch (SecurityException ex) {
                Log.w(LOG_TAG, "fail to remove location listners, ignore", ex);
            }
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(LOG_TAG, "LocationService:onStartCommand flags = " + flags + " startId = " + startId);
        if (startId == 1) {
            try {
                locationManager.requestLocationUpdates(
                        LocationManager.GPS_PROVIDER, LOCATION_INTERVAL, LOCATION_DISTANCE,
                        gpsListener);
            } catch (SecurityException ex) {
                Log.w(LOG_TAG, "fail to request location update, ignore", ex);
            } catch (IllegalArgumentException ex) {
                Log.w(LOG_TAG, "provider does not exist, " + ex);
            }
            try {
                locationManager.requestLocationUpdates(
                        LocationManager.NETWORK_PROVIDER, LOCATION_INTERVAL, LOCATION_DISTANCE,
                        networkListener);
            } catch (SecurityException ex) {
                Log.w(LOG_TAG, "fail to request location update, ignore", ex);
            } catch (IllegalArgumentException ex) {
                Log.w(LOG_TAG, "provider does not exist, " + ex);
            }
        }
        saveStartLocation();
        return START_STICKY;
    }

    private void saveStartLocation() {
        Location lastKnownLocation;
        try {
            lastKnownLocation = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
            if (lastKnownLocation == null) {
                lastKnownLocation = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
            }
            saveLocation(lastKnownLocation);
        } catch (SecurityException ex) {
            Log.e(LOG_TAG, "fail to request initial location ", ex);
        } catch (IllegalArgumentException ex) {
            Log.e(LOG_TAG, "provider does not exist " + ex);
        }
    }

    private void saveLocation(Location location) {
        if (location == null) return;

        ContentValues values = new ContentValues();
        values.put(LocationContentProvider.LOCATION_TIME, System.currentTimeMillis());
        values.put(LocationContentProvider.LOCATION_LATITUDE, location.getLatitude());
        values.put(LocationContentProvider.LOCATION_LONGITUDE, location.getLongitude());
        Uri uri = getContentResolver().insert(LocationContentProvider.CONTENT_URI, values);
        Log.d(LOG_TAG, "inserted new location, location: " + location);
    }

    private class LocationListener implements android.location.LocationListener {
        @Override
        public void onLocationChanged(Location location) {
            Log.d(LOG_TAG, "LocationListener:onLocationChanged: " + location);
            saveLocation(location);
        }

        @Override
        public void onProviderDisabled(String provider) {
            Log.w(LOG_TAG, "LocationListener: providerDisabled: " + provider);
        }

        @Override
        public void onProviderEnabled(String provider) {
            Log.i(LOG_TAG, "LocationListener: providerEnabled: " + provider);
        }

        @Override
        public void onStatusChanged(String provider, int i, Bundle bundle) {
            Log.d(LOG_TAG, "LocationListener: statusChanged" + provider);
        }
    }

}
