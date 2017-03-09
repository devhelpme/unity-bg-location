using System;
using UnityEngine;

namespace Service
{
	public class AndroidLocationService : BgLocationService
	{
		private AndroidJavaObject activityObj;

		public AndroidLocationService() {
			Debug.Log("AndroidBackgroundLocationService init");
			try {
				AndroidJavaClass activityClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
				activityObj = activityClass.GetStatic<AndroidJavaObject>("currentActivity");
			}
			catch (Exception e) {
				#if UNITY_EDITOR_OSX || UNITY_EDITOR_WIN || UNITY_EDITOR_LINUX
				Debug.Log(e.Message);
				#else
				Debug.LogError(e.Message);
				#endif
			}
		}

		public string getLocations() {
			if (activityObj == null) {
				return "";
			}
			Debug.Log("BackgroundLocationService getLocations");
			long lastUpdateTime = 0; //TODO: should be replaced with actual value

			object[] method_args = new object[1];
			method_args[0] = lastUpdateTime;
			string json = activityObj.Call<string>("getLocationsJson", method_args);
			Debug.Log("Got json:" + json);
			return json;
		}

		public void start() {
			if (activityObj != null) {
				Debug.Log("BackgroundLocationService start");
				activityObj.Call("startLocationService");
			}
		}

		public void stop() {
			if (activityObj != null) {
				Debug.Log("BackgroundLocationService stop");
				activityObj.Call("stopLocationService");
			}
		}

		public void deleteOld(long time) {
			if (activityObj != null) {
				Debug.Log("BackgroundLocationService clearOldData");
				object[] method_args = new object[1];
				method_args[0] = time;
				activityObj.Call("deleteLocationsBefore", method_args);
			}
		}
	}
}

