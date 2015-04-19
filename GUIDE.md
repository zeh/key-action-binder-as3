# Using KeyActionBinder

This is a guide to the common uses of KeyActionBinder. For a full reference of available functions, methods and properties, refer to the [reference list](REFERENCE.md).

## Basic setup

In KeyActionBinder, you evaluate your own arbitrary "actions" instead of specific keys or controls.

First, initialize the class *in the first frame/class of your application*. This is necessary due to a [bug in the GameInput API](http://zehfernando.com/2013/adobe-air-gameinput-pitfalls/); if you don't initialize the class properly, your GameInput controls will stop working on OUYA or Android the second time you run your game.

	KeyActionBinder.init(stage);

Then, anywhere in your game setup block, create a `KeyActionBinder` instance.

	binder = new KeyActionBinder();

You can create as many instances as you need.

## Keyboard bindings

You can then add actions with specific bindings to that instance. To add a keyboard binding that means pressing the left arrow key will activate a "move-left" action, and pressing the right arrow key will activate a "move-right" action, you do:

	binder.addKeyboardActionBinding("move-left", Keyboard.LEFT);
	binder.addKeyboardActionBinding("move-right", Keyboard.RIGHT);

You can add as many bindings to the same action as you'd like.

	binder.addKeyboardActionBinding("move-left", Keyboard.LEFT);
	binder.addKeyboardActionBinding("move-left", Keyboard.A);
	binder.addKeyboardActionBinding("move-right", Keyboard.RIGHT);
	binder.addKeyboardActionBinding("move-right", Keyboard.D);

## Gamepad bindings (buttons)

To add a gamepad binding, you use a similar syntax:

	binder.addGamepadActionBinding("move-left", GamepadControls.DPAD_LEFT);
	binder.addGamepadActionBinding("move-right", GamepadControls.DPAD_RIGHT);

To filter actions by player, you pass one additional parameter when adding the action.

	binder.addGamepadActionBinding("move-left-player-1", GamepadControls.DPAD_LEFT, 0); // 0 = player 1

Alternatively, you can also check for the index of the player that activated an action during the game loop (examples below).

## Evaluating actions

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
	binder.addGamepadActionBinding("jump", GamepadControls.ACTION_DOWN);

	// During the loop
	if (isPlayerOnTheGround && binder.isActionActivated("jump")) {
		binder.consumeAction("jump");

		// Perform jump...
		// ...
	}

You can also check actions based on the time they were activated. This is especially useful for time-sensitive actions that are not available all the time; otherwise, a player could press the button way before an action was allowed to be performed - for example, a player pressing a button for "jump" while he/she is still in the air would jump immediately when touching the ground. To verify whether the player pressed jump in the past 0.03 seconds (30 miliseconds) instead:

	// During setup
	binder.addGamepadActionBinding("jump", GamepadControls.ACTION_DOWN);

	// During the loop
	if (isPlayerOnTheGround && binder.isActionActivated("jump", 0.03) {
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

## Gamepad bindings (analog)

To handle sensitive gamepad controls, like axis or triggers, you still use actions. Set it up first:

	binder.addGamepadActionBinding("run-speed", GamepadControls.LT); // L2/LT
	binder.addGamepadActionBinding("axis-x", GamepadControls.STICK_LEFT_X);
	binder.addGamepadActionBinding("axis-y", GamepadControls.STICK_LEFT_Y);

Then use it on your loop:

	var runSpeed:Number = binder.getActionValue("run-speed"); // Value will be between 0 and 1
	var speedX:Number = binder.getActionValue("axis-x"); // Value will be between -1 and 1
	var speedY:Number = binder.getActionValue("axis-y");

You can also restrict the value to specific players:

	var speedX:Number = binder.getActionValue("axis-x", 0); // Only check player 1 (gamepad index 0)

Also notice that, technically, *every* control supports sensitive actions. You can read the sensitive value of an action bound to the action button "A", for example. However, the values returned will be restricted to what the hardware, and the device driver, permit -- if that same action button "A" only provides digital (non-sensitive) input, the values returned will always be either 0 or 1.

## Stopping and resuming

By default, KeyActionBinder starts reading input events as soon as the instance is created. You can stop it with `stop()` and restart it with `start()`.

	// Stop interpreting input
	binder.stop();

	// Resume input
	binder.start();

## Different controls

As of now, `GamepadControls` has a list of known gamepad controls that you can add as action bindings to your game code.

## Events

If you'd rather use events (especially useful for user interfaces), KeyActionBinder also exposes control events for all actions.

	// Create input bindings
	binder.addKeyboardActionBinding("continue", Keyboard.ENTER);
	binder.addGamepadActionBinding("trigger-press", GamepadControls.LT);

	// Add callbacks to the event signals
	binder.onActionActivated.add(onActionActivated);
	binder.onActionDeactivated.add(onActionReleased);
	binder.onActionValueChanged.add(onActionValueChanged);

	private function onActionValueChanged(__action:String, __value:Number):void {
		trace("The user activated the " + __action + " action's value. The new value is " + __value);
	}

	private function onActionActivated(__action:String):void {
		trace("The user activated the " + __action + " action by pressing a key or button.");
	}

	private function onActionDeactivated(__action:String):void {
		trace("The user deactivated the " + __action + " action by releasing a key or button.");
	}