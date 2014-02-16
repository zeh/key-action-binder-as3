# KeyActionBinder

KeyActionBinder tries to provide universal game input control for both keyboard and game controllers in Adobe AIR, independent of the game engine used or the hardware platform it is running in.

While Adobe Flash already provides all the means for using keyboard and game input (via [KeyboardEvent](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/KeyboardEvent.html) and [GameInput](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/GameInput.html)), KeyActionBinder tries to abstract those classes behind a straightforward, higher-level interface. It is meant to be simple but powerful, while solving some of the most common pitfalls involved with player input in AS3 games.

## Goals

 * Unified interface for keyboard and game controller input
 * Made to be fast: memory allocation is kept to a minimum
 * Abstract actual controls in favor of action ids: easier to configure key bindings through variables
 * Automatic bindings on any platform by hiding away platform-specific controls over unified ids
 * Self-containment and independence from any other system or framework

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

 * 2014-02-14 - 1.5.4 - Controllers data now use an array of strings for filters
 * 2014-02-13 - 1.5.3 - Added support for SELECT meta control
 * 2014-02-09 - 1.5.2 - Added support for "split" controls, where the same GameInput control fires two distinct buttons (e.g. XBox 360 dpads on OUYA)
 * 2014-01-12 - 1.4.2 - Added support for PS4 controller (and OPTIONS, SHARE and TRACKPAD meta controls)
 * 2014-01-12 - 1.4.1 - Moved gamepad data to an external JSON (cleaner maintenance)
 * 2013-10-12 - 1.3.1 - Added ability to inject game controls from keyboard events (used for some meta keys on some platforms)
 * 2013-10-12 - 1.2.1 - Added gamepad index filter support for isActionActivated() and getActionValue()
 * 2013-10-08 - 1.1.1 - Removed max/min from addGamepadSensitiveActionBinding() (always use hardcoded values)
 * 2013-10-08 - 1.1.0 - Completely revamped the control scheme by using "auto" controls for cross-platform operation
 * 2013-10-08 - 1.0.0 - First version to have a version number

Check [the commit history](https://github.com/zeh/key-action-binder/commits) for a more in-depth list.

The list above also excludes additions of device mappings; check [the history for controllers.json](https://github.com/zeh/key-action-binder/commits/master/src/com/zehfernando/input/binding/controllers.json) for a list of changes and additions.


## Supportted platforms/devices

Because KeyActionBinder tries to automatically support whatever platform and devices one is using, it depends on having code that targets each specific platform/device combination. These are the platforms currently supported, and their respective supported devices:

| Controller             | Win 7 (PL) | Win 7 (GP) | OSX (PL) | OSX (GP)   | OUYA  | Android |
|------------------------|:----------:|:----------:|:--------:|:----------:|:-----:|:-------:|
| XBox 360 controller    | **Y**      | **Y**      | -        | **Y**      | **Y** | -       |
| PlayStation 3 DS3      | **Y** (E)  | **Y** (E)  | **Y**    | **Y**      | **Y** | **Y**   |
| PlayStation 4 DS3      | **Y**      | -          | **Y**    | **Y** (*1) | **Y** | **Y**   |
| OUYA Native controller | -          | -          | -        | -          | **Y** | -       |
| [NeoFlex](http://neotronics.com.br/neo/produtos/pc/controle-neo-flex) ("USB Gamepad") | **Y** | Y? | N | N | N | N |
| Buffalo SNES ("USB,2-axis 8-button gamepad") | **Y** | **Y** | **Y** | **Y** | N | N |
| Logitech Gamepad F710  | N          | N          | Y?       | N          | N     | N       |
| Logitech Gamepad F310  | N          | N          | Y?       | N          | N     | N       |

Legend:
 * Y: Supported
 * N: Not supported (no mappings)
 * -: Not supported by the system, or Flash Player (not showing up at all on GameInput)
 * Y?: Maybe; needs to be tested or confirmed
 * (PL): Standard Flash Player plugin (Firefox, Safari), ActiveX (MSIE) or Adobe AIR player
 * (GP): Google Pepper Flash Player (Chrome)
 * (E): Not natively supported by the system, but work when using drivers that emulate other devices
 * (*1): D-pad is not working properly; Flash/driver problems?

Controllers that emulate other controllers (e.g. XBox 360 alternatives) should work as long as the original does.

To add:

 * All other platforms (Mac, Android, Windows 8, Windows XP, ...)
 * Android: GameStick, NVIDIA Shield, MadCatz MOJO, GamePop, Green Throttle, ...

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
 * Blog post: [KeyActionBinder is growing up](http://zehfernando.com/2014/keyactionbinder-is-growing-up/) (February 2014)


## License

KeyActionBinder uses the [MIT License](http://choosealicense.com/licenses/mit/). You can use this code in any project, whether of commercial nature or not. If you redistribute the code, the license (LICENSE.txt) must be present with it.


## To-do

 * Use caching samples? Change sampling rate?
 * Properly detect buttons that immediately send down+up events that cannot be detected by normal frames (e.g. HOME on OUYA)
 * Allow detecting "any" gamepad key (for "press any key")
 * Finish auto Gamepad control ids
 * Still allow platform-specific control ids?
 * Profile and test performance/bottlenecks/memory allocations
 * A better looking KeyActionBinderTester demo
 * Add events (signals) for devices removal/listing?
 * Compile binary/stable SWC
 * More bulletproof support for 2+ controllers


## Contributing

There are everal ways to contribute to this project.

To contribute with new key mappings (so more devices are supported by KeyActionBinder):

 1. Run the [Web-based GameInput tester](http://hosted.zehfernando.com/key-action-binder/game-input-tester/) with your desired device connected to the machine.
 2. Push all buttons.
 3. Take a screenshot.
 4. Take notes of all buttons, indicating which buttons and axis relate to what (e.g. "BUTTON_4" means "directional pad up"). Be sure to include which of the values (-1 or 1) mean "UP" on the gamepad's sticks.
 5. Send the screenshot and the list of controls to zeh at zehfernando dot com.
 6. If possible, test in additional browsers to see if you get different results. In some systems, the regular Flash Player (plugin on FireFox, Safari, etc) behaves differently from the built-in Flash Player (Pepper Flash on Chrome). In this case, we need screenshots and lists of mappings for both kinds of player.

To contribute with code, fixes, additions, or even new key mappings added directly to the [controllers list file](https://github.com/zeh/key-action-binder/blob/master/src/com/zehfernando/input/binding/controllers.json), you can just edit the related file inside GitHub (by editing it directly on the website, or creating a fork) and doing a pull request. This is an easy way to contribute, and it guarantees you will be credited for your work (accepted pull requests have their authors automatically show as contributors to the project).


## Credits and thanks

 * James Dean Palmer for the original idea about auto-mapping controls and many bindings
 * Patrick Bastiani for the NeoFlex controller mapping
 * Rusty Moyher for the Buffalo SNES mapping, and several other mappings for Windows and OSX