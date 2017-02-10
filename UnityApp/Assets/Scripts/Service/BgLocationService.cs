using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Service {

	public interface BgLocationService {
		void start ();
		void stop ();
		string getLocations();
		void deleteOld (long time);
	} 
}
