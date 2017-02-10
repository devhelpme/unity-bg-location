using System;
using UnityEngine;

namespace Service
{
	public class IodLocationService : BgLocationService
	{
		public void start () {
			Debug.Log("Service started");
		}

		public void stop () {
			Debug.Log("Service stop");
		}
		public string getLocations(){
			Debug.Log("Service getLocations");
			return "";
		}
		public void deleteOld (long time) {
			Debug.Log ("Service deleteOld");
		}
	}
}

