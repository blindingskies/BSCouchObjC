BSCouchObjC Documentation
=========================

Firstly, the code should be well documented in the implementation files. This document details how to use BSCouchObjC in an iOS project. For Mac OS X projects, just import the framework

iOS Applications
----------------

These instructions can be followed to include any 3rd party software library in your iPhone project as a static library.

1.	Clone the project to somewhere on your computer.
2.	Drag the Xcode project file into your applications Xcode project file (in the same way that the JSON project is located in the BSCouchObjC project)
3.	Expand this project icon, and drag the libBSCouchObjC target to your application target's Linked Libraries.
4.	Import the BSCouchObjC.h header file, either in the prefix header, or in the specific implementation files where you're going to use the classes.
5.	Updated the User Header Paths in the project build settings.
	*	Select the project and Get Info.
	*	Under Build settings, select All Configurations and All Settings, then search for "Header"
	*	Add the following path to your User Header Search Paths (including the quotation marks): "/path/to/clone/of/BSCouchObjC/Code/src"
	*	Optionally, if you require the JSON project elsewhere also add: "/path/to/clone/of/BSCouchObjC/Code/vendor/json-framework/Classes"	
6.	Update the Framework Search Paths:
*	Select the project and Get Info.
*	Under Build settings, select All Configurations and All Settings, then search for "Header"
	*	Add the following path to your Framework Search Paths (including the quotation marks): "/path/to/clone/of/BSCouchObjC/build/$(BUILD_STYLE)-$(PLATFORM_NAME)"
	*	Add the following path to your Framework Search Paths (including the quotation marks): "/path/to/clone/of/BSCouchObjC/Code/vendor/json-framework/build/$(BUILD_STYLE)-$(PLATFORM_NAME)"
7.	Add the libBSCouchObjC target as a dependency of your application target. To do this, select your application's target, and Get Info. Then under General, Dependencies click the + button, and select libCouchObjC from the BSCouchObjC Xcode project. This will make sure that the library get's build before your application.
8.	Remember to only link the library in the final binary. If you create intermediate software libraries, then do not link against the libraries (just build against them), otherwise you'll end up with duplicate symbols.	