# KeyActionBinder

KeyActionBinder tries to provide universal game input control for both keyboard and game controllers in Adobe AIR, independent of the game engine used or the hardware platform it is running in.

While Adobe Flash already provides all the means for using keyboard and game input (via [KeyboardEvent](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/KeyboardEvent.html) and [GameInput](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/GameInput.html)), KeyActionBinder tries to abstract those classes behind a straightforward, higher-level interface. It is meant to be simple but powerful, while solving some of the most common pitfalls involved with player input in AS3 games.

[Using KeyActionBinder](GUIDE.md) — [Reference/docs](REFERENCE.md) — [Version Changelog](CHANGELOG.md) — [List of supported devices](SUPPORT.md) — [Contribute to the project](CONTRIBUTE.md)


## Goals

 * Unified interface for keyboard and game controller input
 * Made to be fast: memory allocation is kept to a minimum, and there are no device references or instances to maintain
 * Abstract actual controls in favor of action ids: easier to configure key bindings through variables, with redundant input types (keyboard and gamepad)
 * Automatic bindings on any platform by hiding away platform-specific controls over unified ids
 * Self-containment and independence from any other system or framework

## Usage

	private var binder:KeyActionBinder

	// Setup (first frame/root of SWF)
	KeyActionBinder.init(stage);
	
	public function setup():void {
		// Create instance
		binder = new KeyActionBinder();
		
		// Setup as many action bindings as you want
		binder.addKeyboardActionBinding("move-left", Keyboard.LEFT);
		binder.addKeyboardActionBinding("move-right", Keyboard.RIGHT);
		binder.addGamepadActionBinding("move-left", GamepadControls.DPAD_LEFT);
		binder.addGamepadActionBinding("move-right", GamepadControls.DPAD_RIGHT);
	}
	
	function function gameLoop():void {
		// Evaluate actions
		if (binder.isActionActivated("move-left")) {
			// ...
		} else if (binder.isActionActivated("move-right")) {
			// ...
		}
	}

Read more in the [guide](GUIDE.md).

## Tests/demos

| [![KeyActionBinderTester](http://hosted.zehfernando.com/key-action-binder/tester/git/kab_thumb.png)](http://hosted.zehfernando.com/key-action-binder/tester) |
|:--:|
| **KeyActionBinderTester** |
| [Web-based version](http://hosted.zehfernando.com/key-action-binder/tester/), [Android/OUYA APK](http://hosted.zehfernando.com/key-action-binder/tester/KeyActionBinderTester.apk) |
| [Source code](https://github.com/zeh/key-action-binder/tree/master/tests/KeyActionBinderTester) |


## Read more

 * Blog post: [Known OUYA GameInput controls on Adobe AIR](http://zehfernando.com/2013/known-ouya-gameinput-controls-on-adobe-air/) (July 2013)
 * Blog post: [Abstracting key and game controller inputs in Adobe AIR](http://zehfernando.com/2013/abstracting-key-and-game-controller-inputs-in-adobe-air/) (July 2013)
 * Blog post: [KeyActionBinder updates: time sensitive activations, new constants](http://zehfernando.com/2013/keyactionbinder-updates-time-sensitive-activations-new-constants/) (September 2013)
 * Blog post: [Big changes to KeyActionBinder: automatic game control ids, new repository](http://zehfernando.com/2013/big-changes-to-keyactionbinder-automatic-game-control-ids-new-repository/) (October 2013)
 * Blog post: [A GameInput testing interface](http://zehfernando.com/2014/a-gameinput-testing-interface/) (January 2014)
 * Blog post: [KeyActionBinder is growing up](http://zehfernando.com/2014/keyactionbinder-is-growing-up/) (February 2014)


## GameInput problems

In case of problems with KeyActionBinder... know that Flash's GameInput API is still severely ridden with bugs. You may run into some of them. Here's some more information.

* Supported devices are not detected properly when added or removed ([Bug #3709110](https://bugbase.adobe.com/index.cfm?event=bug&id=3709110)): no workaround
* [Using GameInput add Timer overhead every second in Windows](http://forums.adobe.com/message/6129689#6129689) ([Bug #3660823](https://bugbase.adobe.com/index.cfm?event=bug&id=3660823)): no workaround
* [GameInput devices simply stop working when running on Android/OUYA](http://forums.adobe.com/message/6033965): need to initialize things in the first frame of SWF (fixed in [AIR 13.0.0.36/Flash Player 13.0.0.130](http://forums.adobe.com/thread/1411911?tstart=0)?)
* Quick button presses may not be properly detected on Macs ([Bug #3702039](https://bugbase.adobe.com/index.cfm?event=bug&id=3702039)): no workaround (need to test sampling rate changes and if button activation can always be assumed from the up event)

I'll remove items from the list when they're fixed.


## Credits and thanks

 * James Dean Palmer for the original idea about auto-mapping controls and many bindings
 * Patrick Bastiani for the NeoFlex controller mapping
 * Rusty Moyher for the Buffalo SNES mapping, and several other mappings for Windows and OSX


## License

KeyActionBinder uses the [MIT License](http://choosealicense.com/licenses/mit/). You can use this code in any project, whether of commercial nature or not. If you redistribute the code, the license (LICENSE.txt) must be present with it.


## To-do

 * Use caching samples? Change sampling rate?
 * Properly detect buttons that immediately send down+up events that cannot be detected by normal frames (e.g. HOME on OUYA)
 * Allow detecting "any" gamepad key (for "press any key")
 * More automatic gamepad mappings
 * Still allow platform-specific control ids?
 * Profile and test performance/bottlenecks/memory allocations
 * A better looking KeyActionBinderTester demo
 * Compile binary/stable SWC
 * More bulletproof support for 2+ controllers