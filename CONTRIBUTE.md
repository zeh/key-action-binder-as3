# Contributing

There are everal ways to contribute to this project.

## Testing devices

To contribute with new key mappings (so more devices are supported by KeyActionBinder):

 1. Run the [Web-based KeyActionBinder tester](http://hosted.zehfernando.com/key-action-binder/tester/) or install the [Android/OUYA KeyActionBinder APK](http://hosted.zehfernando.com/key-action-binder/tester/KeyActionBinderTester.apk) with your desired device connected to the machine. Be sure to press all buttons to see if it comes to life. If it works perfectly, there's nothing else needed!
 2. If not, run the [Web-based GameInput tester](http://hosted.zehfernando.com/key-action-binder/game-input-tester/) or install the [Android/OUYA GameInput APK](http://hosted.zehfernando.com/key-action-binder/game-input-tester/GameInputTester.apk) with your desired device connected to the machine.
 3. Push all buttons.
 4. Take a screenshot.
 5. Take notes of all buttons, indicating which buttons and axis relate to what (e.g. "BUTTON_4" means "directional pad up"). Be sure to include which of the values (-1 or 1) mean "UP" on the gamepad's analog sticks, if needed.
 6. [Create a new issue](http://github.com/zeh/key-action-binder/issues) with the screenshot and the list of controls, stating which exact device was tested, in which OS, and with which browser.
 7. If possible, test in additional browsers to see if you get different results. In some systems, the regular Flash Player (plugin on FireFox, Safari, etc) behaves differently from the built-in Flash Player (Pepper Flash on Chrome). In this case, we need screenshots and lists of mappings for both kinds of player, so the device is more widely supported.

## Changing code or mappings yourself

To contribute with code, fixes, additions, or even new key mappings added directly to the [controllers list file](https://github.com/zeh/key-action-binder/blob/master/src/com/zehfernando/input/binding/controllers.json), you can just edit the related file inside GitHub (by editing it directly on the website, or creating a fork) and doing a pull request. This is an easy way to contribute, and it guarantees you will be credited for your work (accepted pull requests have their authors automatically show as contributors to the project).