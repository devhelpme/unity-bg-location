using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using UnityEngine;

namespace Service
{
	public class IodLocationService : BgLocationService
	{
		public string getLocations() {
			Debug.Log("Unity: BackgroundLocationService getLocations");
			var json = getLocationsJson(0);
			Debug.Log("Unity: Got json:" + json);

			return json;
		}

		public void start() {
			Debug.Log("Unity: BackgroundLocationService start");
			startLocationService();
		}

		public void stop() {
			Debug.Log("Unity: BackgroundLocationService stop");
			stopLocationService();
		}

		public void deleteOld(long time) {
			Debug.Log("Unity: BackgroundLocationService stop");
			deleteLocationsBefore(time);
		}


		[DllImport("__Internal")]
		extern static private void startLocationService();

		[DllImport("__Internal")]
		extern static private void stopLocationService();

		[DllImport("__Internal")]
		extern static private string getLocationsJson(double time);

		[DllImport("__Internal")]
		extern static private string deleteLocationsBefore(double time);
	}
}

