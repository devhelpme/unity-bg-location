package me.devhelp.unityplugin;

import android.app.PendingIntent;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.os.Bundle;
import android.util.Log;

import com.google.gson.Gson;
import com.unity3d.player.UnityPlayerActivity;

import java.util.ArrayList;
import java.util.List;

public class UnityPluginActivity extends UnityPlayerActivity {
    private static final int REQUEST_LOCATION = 1;
    private static final int LOCATION_REQUEST_CODE = 1010;
    public static final String LOG_TAG = "LocationPlugin";
    private Intent locationIntent;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i(LOG_TAG, "UnityPluginActivity:onCreate");
        locationIntent = new Intent(getApplicationContext(), LocationService.class);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.i(LOG_TAG, "UnityPluginActivity:onDestroy");
        stopLocationService();
    }


    public void startLocationService() {
        checkPermissions();
        Log.i(LOG_TAG, "UnityPluginActivity:startLocationService");
        PendingIntent pendingIntent = createPendingResult(REQUEST_LOCATION, new Intent(), PendingIntent.FLAG_UPDATE_CURRENT);
        locationIntent.putExtra(LocationService.PENDING_INTENT, pendingIntent);
        startService(locationIntent);
    }

    public void stopLocationService() {
        Log.i(LOG_TAG, "UnityPluginActivity:stopLocationService");
        stopService(locationIntent);
    }

    public String getLocationsJson(long time) {
        Log.d(LOG_TAG, "UnityPluginActivity: getLocationsJson after " + time);
        Cursor cursor = getContentResolver().query(LocationContentProvider.CONTENT_URI, null,
                LocationContentProvider.LOCATION_TIME + " > " + time,
                null, null);
        List<LocationDto> locationUpdates = new ArrayList<>();
        if (cursor != null) {
            while (cursor.moveToNext()) {
                LocationDto dto = new LocationDto();
                dto.setTime(cursor.getLong(cursor.getColumnIndex(LocationContentProvider.LOCATION_TIME)));
                dto.setLongitude(cursor.getLong(cursor.getColumnIndex(LocationContentProvider.LOCATION_LONGITUDE)));
                dto.setLatitude(cursor.getLong(cursor.getColumnIndex(LocationContentProvider.LOCATION_LATITUDE)));
                locationUpdates.add(dto);
            }
            cursor.close();
        }
        String json = new Gson().toJson(locationUpdates);
        Log.d(LOG_TAG, "Json: " + json);
        return json;
    }

    public void deleteLocationsBefore(long time) {
        Log.i(LOG_TAG, "UnityPluginActivity: deleteLocationsBefore " + time);
        int count = getContentResolver().delete(LocationContentProvider.CONTENT_URI,
                LocationContentProvider.LOCATION_TIME + " <= " + time,
                null);
        Log.i(LOG_TAG, "Deleted: " + count + "rows");
    }

    private boolean hasPermission() {
        return PackageManager.PERMISSION_GRANTED == checkSelfPermission(android.Manifest.permission.ACCESS_FINE_LOCATION);
    }

    private void checkPermissions() {
        if (!hasPermission()) {
            requestPermissions(new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION}, LOCATION_REQUEST_CODE);
        }
    }
}
