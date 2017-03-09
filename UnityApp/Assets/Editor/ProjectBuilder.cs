using System;
using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using UnityEngine;

public class ProjectBuilder {

	[PostProcessBuild]
	public static void OnPostProcessBuildIos(BuildTarget target, string pathToBuiltProject) {
		if (target == BuildTarget.iOS) {
			ChangeXcodePlist(target, pathToBuiltProject);
			AddLinkToSQLiteIos(target, pathToBuiltProject);
		}
	}

	private static void ChangeXcodePlist(BuildTarget buildTarget, string pathToBuiltProject) {
		// Get plist
		string plistPath = pathToBuiltProject + "/Info.plist";
		PlistDocument plist = new PlistDocument();
		plist.ReadFromString(File.ReadAllText(plistPath));

		// Get root
		PlistElementDict rootDict = plist.root;

		// Set value of NSLocationAlwaysUsageDescription in Xcode plist
		var buildKey = "NSLocationAlwaysUsageDescription";
		rootDict.SetString(buildKey, "Just to show ");

		// Write to file
		File.WriteAllText(plistPath, plist.WriteToString());
	}

	private static void AddLinkToSQLiteIos(BuildTarget target, string pathToBuiltProject) {
		string projPath = pathToBuiltProject + "/Unity-iPhone.xcodeproj/project.pbxproj";
		PBXProject proj = new PBXProject();
		proj.ReadFromString(File.ReadAllText(projPath));
		string targetGUID = proj.TargetGuidByName("Unity-iPhone");
		proj.AddBuildProperty(targetGUID, "OTHER_LDFLAGS", "-lsqlite3");
		File.WriteAllText(projPath, proj.WriteToString());

		ChangeXcodePlist(target, pathToBuiltProject);
	}
}
