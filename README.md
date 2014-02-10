# KeyActionBinder

KeyActionBinder tries to provide universal game input control for both keyboard and game controllers in Adobe AIR, independent of the game engine used or the hardware platform it is running in.

While Adobe Flash already provides all the means for using keyboard and game input (via [KeyboardEvent](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/KeyboardEvent.html) and [GameInput](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/GameInput.html)), KeyActionBinder tries to abstract those classes behind a straightforward, higher-level interface. It is meant to be simple but powerful, while solving some of the most common pitfalls involved with player input in AS3 games.

## Advantages

 * Unified interface for keyboard and game controller input
 * Made to be fast: memory allocation is kept to a minimum
 * Abstract actual controls in favor of action ids: easier to configure key bindings through variables
 * Automatic bindings on any platform by hiding away platform-specific controls over unified ids

## Using KeyActionBinder

### Basic setup

In KeyActionBinder, you evaluate your own arbitrary "actions" instead of specific keys or controls.

First, initialize the class *in the first frame/class of your application*. This is necessary due to a [bug in the GameInput API](http://zehfernando.com/2013/adobe-air-gameinput-pitfalls/); if you don't initialize the class properly, your GameInput controls will stop working on OUYA or Android the second time you run your game.

	KeyActionBinder.init(stage);

Then, anywhere in your game setup block, create a `KeyActionBinder` instance.

	binder = new KeyActionBinder();

You can create as many instances as you need.

### Keyboard bindings

You can then add actions with specific bindings to that instance. To add a keyboard binding that means pressing the left arrow key will activate a "move-left" action, and pressing the right arrow key will activate a "move-right" action, you do:

	binder.addKeyboardActionBinding("move-left", Keyboard.LEFT);
	binder.addKeyboardActionBinding("move-right", Keyboard.RIGHT);

You can add as many bindings to the same action as you'd like.

	binder.addKeyboardActionBinding("move-left", Keyboard.LEFT);
	binder.addKeyboardActionBinding("move-left", Keyboard.A);
	binder.addKeyboardActionBinding("move-right", Keyboard.RIGHT);
	binder.addKeyboardActionBinding("move-right", Keyboard.D);

### Gamepad bindings (buttons)
	
To add a gamepad binding, you use a similar syntax:

	binder.addGamepadActionBinding("move-left", GamepadControls.DPAD_LEFT);
	binder.addGamepadActionBinding("move-right", GamepadControls.DPAD_RIGHT);

To filter actions by player, you pass one additional parameter when adding the action.

	binder.addGamepadActionBinding("move-left-player-1", GamepadControls.DPAD_LEFT, 0); // 0 = player 1

Alternatively, you can also check for the index of the player that activated an action during the game loop (examples below).

### Evaluating actions

Then, on your game loop block, you simply check whether any action is activated by using `isActionActivated()`:

	if (binder.isActionActivated("move-left")) {
		// Move the player to the left...
		// ...
	} else if (binder.isActionActivated("move-right")) {
		// Move the player to the right...
		// ...
	}

For actions that are not repeated, like a player jump, you can "consume" them via `consumeAction()`. This forces the player to activate the button again if they want to perform the action again.

	// During setup
	binder.addGamepadActionBinding("jump", GamepadControls.BUTTON_ACTION_DOWN);

	// During the loop
	if (isPlayerOnTheGround && binder.isActionActivated("jump")) {
		binder.consumeAction("jump");

		// Perform jump...
		// ...
	}

You can also check actions based on the time they were activated. This is especially useful for time-sensitive actions that are not available all the time; otherwise, a player could press the button way before an action was allowed to be performed - for example, a player pressing a button for "jump" while he/she is still in the air would jump immediately when touching the ground. To verify whether the player pressed jump in the past 0.03 seconds (30 miliseconds) instead:

	// During setup
	binder.addGamepadActionBinding("jump", GamepadControls.BUTTON_ACTION_DOWN);

	// During the loop
	if (isPlayerOnTheGround && binder.isActionActivated("jump"), 0.03) {
		binder.consumeAction("jump");

		// Perform jump...
		// ...
	}

You can also check for the player/gamepad index during activation.

	// Action, time sensititivy = 0 (default), gamepad index = 0 (first)
	if (binder.isActionActivated("move-left", 0, 0)) {
		// Player 1 moved to the left
		// ...
	}

You can check for the activation of actions regardless of whether they're bound to a pressure-sensitive/analog control, or a digital control. In the case of a simple digital control (like most buttons), the action will be considered activated when the button is considered pressed by the device and the driver. In the case of a pressure-sensitive button, it will be considered activated when it is past a middle threshold. For example, on most controllers, the value reported by the left trigger will range from 0 to 1; thus, when the reported value is higher than 0.5, an action bound to that button will be considered *activated*.

### Gamepad bindings (analog)

To handle sensitive gamepad controls, like axis or triggers, you create sensitive actions. Set it up first:

	binder.addGamepadSensitiveActionBinding("run-speed", GamepadControls.LT); // L2/LT
	binder.addGamepadSensitiveActionBinding("axis-x", GamepadControls.STICK_LEFT_X);
	binder.addGamepadSensitiveActionBinding("axis-y", GamepadControls.STICK_LEFT_Y);

Then use it on your loop:

	var runSpeed:Number = binder.getActionValue("run-speed"); // Value will be between 0 and 1
	var speedX:Number = binder.getActionValue("axis-x"); // Value will be between -1 and 1
	var speedY:Number = binder.getActionValue("axis-y");

You can also restrict the value to specific players:

	var speedX:Number = binder.getActionValue("axis-x", 0); // Only check player 1 (gamepad index 0)

Also notice that, technically, *every* control supports sensitive actions. You can read the sensitive value of an action bound to the action button "A", for example. However, the values returned will be restricted to what the hardware, and the device driver, permit -- if that same action button "A" only provides digital (non-sensitive) input, the values returned will always be either 0 or 1.

### Stopping and resuming

By default, KeyActionBinder starts reading input events as soon as the instance is created. You can stop it with `stop()` and restart it with `start()`.

	// Stop interpreting input
	binder.stop();

	// Resume input
	binder.start();

### Different controls

As of now, `GamepadControls` has a list of known gamepad controls that you can add as action bindings to your game code.

### Events

If you'd rather use events (especially useful for user interfaces), KeyActionBinder also exposes control events for all actions.

	// Create input bindings
	binder.addKeyboardActionBinding("continue", Keyboard.ENTER);
	binder.addGamepadSensitiveActionBinding("trigger-press", GamepadControls.LT);

	// Add callbacks to the event signals
	binder.onActionActivated.add(onActionActivated);
	binder.onActionDeactivated.add(onActionReleased);
	binder.onSensitiveActionChanged.add(onSensitiveActionChanged);

	private function onSensitiveActionChanged(__action:String, __value:Number):void {
		trace("The user activated the " + __action + " action's value. The new value is " + __value);
	}

	private function onActionActivated(__action:String):void {
		trace("The user activated the " + __action + " action by pressing a key or button.");
	}

	private function onActionDeactivated(__action:String):void {
		trace("The user deactivated the " + __action + " action by releasing a key or button.");
	}


## Changelog

 * 2014-02-09 - 1.5.2 - Added support for "split" controls, where the same GameInput control fires two distinct buttons (e.g. XBox 360 dpads on OUYA)
 * 2014-01-12 - 1.4.2 - Added support for PS4 controller (and OPTIONS, SHARE and TRACKPAD meta controls)
 * 2014-01-12 - 1.4.1 - Moved gamepad data to an external JSON (cleaner maintenance)
 * 2013-10-12 - 1.3.1 - Added ability to inject game controls from keyboard events (used for some meta keys on some platforms)
 * 2013-10-12 - 1.2.1 - Added gamepad index filter support for isActionActivated() and getActionValue()
 * 2013-10-08 - 1.1.1 - Removed max/min from addGamepadSensitiveActionBinding() (always use hardcoded values)
 * 2013-10-08 - 1.1.0 - Completely revamped the control scheme by using "auto" controls for cross-platform operation
 * 2013-10-08 - 1.0.0 - First version to have a version number

Check [the commit history](https://github.com/zeh/key-action-binder/commits) for a more in-depth list.


## Supportted platforms/devices

Because KeyActionBinder tries to automatically support whatever platform and devices one is using, it depends on having code that targets each specific platform/device combination. These are the platforms currently supported, and their respective supported devices:

 * Windows 7
  * XBox 360 controller
  * PlayStation 4 DS4
 * OUYA
  * XBox 360 controller

To confirm/re-test:

 * OUYA
  * Native controller
  * PlayStation 3 controller
 * All other platforms (Mac, Android, Windows 8, ...)

More platforms and devices will be added as their controls are tested and figured out. If you wish, you can test it yourself:

 * [Web-based GameInput tester](http://hosted.zehfernando.com/key-action-binder/game-input-tester/) (requires Flash Player)
 * [Android/OUYA APK GameInput tester app](hosted.zehfernando.com/key-action-binder/game-input-tester/GameInputTester.apk)

A pure AS3 source of the tester app can be found on /tests/GameInputTester/src.

## Read more

 * Blog post: [Known OUYA GameInput controls on Adobe AIR](http://zehfernando.com/2013/known-ouya-gameinput-controls-on-adobe-air/) (July 2013)
 * Blog post: [Abstracting key and game controller inputs in Adobe AIR](http://zehfernando.com/2013/abstracting-key-and-game-controller-inputs-in-adobe-air/) (July 2013)
 * Blog post: [KeyActionBinder updates: time sensitive activations, new constants](http://zehfernando.com/2013/keyactionbinder-updates-time-sensitive-activations-new-constants/) (September 2013)
 * Blog post: [Big changes to KeyActionBinder: automatic game control ids, new repository](http://zehfernando.com/2013/big-changes-to-keyactionbinder-automatic-game-control-ids-new-repository/) (October 2013)
 * Blog post: [A GameInput testing interface](http://zehfernando.com/2014/a-gameinput-testing-interface/) (January 2014)

 
## License

KeyActionBinder uses the [MIT License](http://choosealicense.com/licenses/mit/). You can use this code in any project, whether of commercial nature or not. If you redistribute the code, the license (LICENSE.txt) must be present with it .


## To-do

 * Allow sensitive controls to be treated as normal controls (with a user-defined threshold?)
 * Think of a way to avoid axis injecting button pressed
 * Add gamepad index to return signals parameters?
 * Use caching samples?
 * Allow "any" gamepad key (for "press any key")
 * Add missing asdocs (any?)
 * Finish auto Gamepad control ids
 * Still allow platform-specific control ids?
 * Profile and test performance/bottlenecks/memory allocations
 * More demos
 * Add events (signals) for devices removal/listing?
 * Binary SWC
 * Better tests with 2 controllers
