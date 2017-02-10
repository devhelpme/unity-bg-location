using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Service;

public class LocationController : MonoBehaviour {

	public Text locationsViewText;
	private BgLocationService _locationService;

	void Awake () {
		_locationService = LocationServiceFactory.GetService ();
	}
	

	public void StartLocationClick() {
		Debug.Log ("StartLocationClick");
		_locationService.start ();
	}

	public void StopLocationClick() {
		Debug.Log ("StopLocationClick");
		_locationService.stop ();
	}

	public void GetLocationClick() {
		Debug.Log ("GetLocationClick");
		locationsViewText.text = _locationService.getLocations ();
	}
}
