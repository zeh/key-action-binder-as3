This is a project to test for the support of different GameInput devices on KeyActionBinder

The /bin folder contains Web, Standalone, and Android/OUYA versions of the application. It should work seamlessly on any of those.

This project was created with FDT. Simply import the "src" folder as a project for it to compile.

It uses ASC 2.0 for compilation. It may require a SDK of a given name for compilation. The name will indicate which version it's looking for. If you have an SDK of a different name of version, just change the project SDK to match. Make sure the descriptor (KeyActionBinderTester-app.xml) has a namespace that matches your SDK version if you change the major version of AIR used (e.g. 4.0 to 4.1).

It can easily be edited and compiled on non-FDT environments. Check the "src/.settings/com.powerflasher.fdt.core.prefs" file for the compilation parameters used.

Binary versions of this project are available:

 * [Web-based version](http://hosted.zehfernando.com/key-action-binder/tester/)
 * [Android/OUYA APK](http://hosted.zehfernando.com/key-action-binder/tester/KeyActionBinderTester.apk)
