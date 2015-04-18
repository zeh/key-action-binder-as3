# Reference

This is the reference to all methods, functions and properties available to KeyActionBinder. Refer to the [guide](GUIDE.md) for practical examples.

## Static methods

### <a name="init"></a>KeyActionBinder.init()

Initializes the KeyActionBinder class. This is necessary to allocate global references needed by KeyActionBinder instances.

Due to bugs in Flash's GameInput API (especially on OUYA and Android), this initialization should be done in the first frame of your SWF, preferably in the root class of your movie.

#### Parameters

 * **stage**: Flash's global stage, used for adding event listeners.

#### See also
 * [KeyActionBinder()](#KeyActionBinder)

## Constructor

### <a name="KeyActionBinder"></a>KeyActionBinder()

Create a new KeyActionBinder instance.

Each instance has its own input bindings and actions.

More than one KeyActionBinder instance can exist and be active at the same time.

#### See also
 * [init()](#init)


## Instance methods


### <a name="start"></a>start():void

Starts listening for input events.

This happens by default when a KeyActionBinder object is instantiated; this method is only useful if
called after `stop()` has been used.

Calling this method when a KeyActionBinder instance is already running has no effect.

#### See also
 * [isRunning](#isRunning)
 * [stop()](#stop)


### <a name="stop"></a>stop():void

Stops listening for input events.

Action bindings are not lost when a KeyActionBinder instance is stopped; it merely starts ignoring
all input events, until `start()` is called again.

This method should always be called when you don't need a KeyActionBinder instance anymore, otherwise
it'll be listening to events indefinitely.

Calling this method when this a KeyActionBinder instance is already stopped has no effect.

#### See also
 * [isRunning](#isRunning)
 * [start()](#start)


### <a name="addKeyboardActionBinding"></a>addKeyboardActionBinding(action:String, keyCode:int = KeyActionBinder.KEY_CODE_ANY, keyLocation:int = KeyActionBinder.KEY_LOCATION_ANY):void

Adds an action bound to a keyboard key. When a key with the given `keyCode` is pressed, the desired action is activated. Optionally, keys can be restricted to a specific `keyLocation`.

#### Parameters

 * **action**: An arbitrary String id identifying the action that should be dispatched once this key combination is detected.
 * **keyCode**: The code of a key, as expressed in AS3's Keyboard constants.
 * **keyLocation**: The code of a key's location, as expressed in AS3's KeyLocation constants. If the default value is passed, the key location is never taken into consideration when detecting whether the passed action should be fired.

#### Examples

<pre>// Left arrow key to move left
myBinder.addKeyboardActionBinding("move-left", Keyboard.LEFT);
// SPACE key to jump
myBinder.addKeyboardActionBinding("jump", Keyboard.SPACE);
// Any SHIFT key to shoot
myBinder.addKeyboardActionBinding("shoot", Keyboard.SHIFT);
// Left SHIFT key to boost
myBinder.addKeyboardActionBinding("boost", Keyboard.SHIFT, KeyLocation.LEFT);
</pre>

#### See also
 * [flash.ui.Keyboard](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html)
 * [isActionActivated()](#isActionActivated)
 * [removeGamepadActionBinding()](#removeGamepadActionBinding)

### <a name="removeKeyboardActionBinding"></a>removeKeyboardActionBinding(action:String, keyCode:int = KeyActionBinder.KEY_CODE_ANY, keyLocation:int = KeyActionBinder.KEY_LOCATION_ANY):void

Removes an action bound to a keyboard key.

#### Parameters

 * **action**: An arbitrary String id identifying the action that should be dispatched once this key combination is detected.
 * **keyCode**: The code of a key, as expressed in AS3's Keyboard constants.
 * **keyLocation**: The code of a key's location, as expressed in AS3's KeyLocation constants. If the default value is passed, the key location is never taken into consideration when detecting whether the passed action should be fired.

#### Examples

<pre>// Left arrow key to move left
myBinder.addKeyboardActionBinding("move-left", Keyboard.LEFT);
// SPACE key to jump
myBinder.addKeyboardActionBinding("jump", Keyboard.SPACE);
// Any SHIFT key to shoot
myBinder.addKeyboardActionBinding("shoot", Keyboard.SHIFT);
// Left SHIFT key to boost
myBinder.addKeyboardActionBinding("boost", Keyboard.SHIFT, KeyLocation.LEFT);
</pre>

#### See also
 * [flash.ui.Keyboard](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html)
 * [addGamepadActionBinding()](#addGamepadActionBinding)


### <a name="addGamepadActionBinding"></a>addGamepadActionBinding(action:String, controlId:String, gamepadIndex:int = KeyActionBinder.GAMEPAD_INDEX_ANY):void

Adds an action bound to a game controller button, trigger, or axis. When a control of id `controlId` is pressed, the desired action can be activated, and its value changes. Optionally, keys can be restricted to a specific game controller location.

#### Parameters

 * **action**: An arbitrary String id identifying the action that should be dispatched once this input combination is detected.
 * **controlId**: The id code of a GameInput control, as an String. Use one of the constants from `GamepadControls`.
 * **gamepadIndex**: The int of the gamepad that you want to restrict this action to. Use 0 for the first gamepad (player 1), 1 for the second one, and so on. If the default value is passed, the gamepad index is never taken into consideration when detecting whether the passed action should be fired.

#### Examples

<pre>// Direction pad left to move left
myBinder.addGamepadActionBinding("move-left", GamepadControls.DPAD_LEFT);
// Action button "down" (O in the OUYA, Cross in the PS3, A in the XBox 360) to jump
myBinder.addGamepadActionBinding("jump", GamepadControls.ACTION_DOWN);
// L1/LB to shoot, on any controller
myBinder.addGamepadActionBinding("shoot", GamepadControls.LB);
// L1/LB to shoot, on the first controller only
myBinder.addGamepadActionBinding("shoot-player-1", GamepadControls.LB, 0);
// L2/LT to shoot, regardless of whether it is sensitive or not
myBinder.addGamepadActionBinding("shoot", GamepadControls.LT);
// L2/LT to accelerate, depending on how much it is pressed (if supported)
myBinder.addGamepadActionBinding("accelerate", GamepadControls.LT);
// Direction pad left to move left or right
myBinder.addGamepadActionBinding("move-sides", GamepadControls.STICK_LEFT_X);
</pre>

#### See also
 * [GamepadControls](#GamepadControls)
 * [isActionActivated()](#isActionActivated)
 * [getActionValue()](#getActionValue)
 * [removeGamepadActionBinding()](#removeGamepadActionBinding)
 
### <a name="removeGamepadActionBinding"></a>removeGamepadActionBinding(action:String, controlId:String, gamepadIndex:int = KeyActionBinder.GAMEPAD_INDEX_ANY):void

Removes an action bound to a game controller button, trigger, or axis.

#### Parameters

 * **action**: An arbitrary String id identifying the action that should be dispatched once this input combination is detected.
 * **controlId**: The id code of a GameInput control, as an String. Use one of the constants from `GamepadControls`.
 * **gamepadIndex**: The int of the gamepad that you want to restrict this action to. Use 0 for the first gamepad (player 1), 1 for the second one, and so on. If the default value is passed, the gamepad index is never taken into consideration when detecting whether the passed action should be fired.

#### See also
 * [GamepadControls](#GamepadControls)
 * [addGamepadActionBinding()](#addGamepadActionBinding)

### <a name="getActionValue"></a>getActionValue(action:String, gamepadIndex:int = KeyActionBinder.GAMEPAD_INDEX_ANY):Number

Reads the current value of an action.

#### Parameters

 * **action**: The id of the action you want to read the value of.
 * **controlId**: The id code of a GameInput control, as an String. Use one of the constants from `GamepadControls`.
 * **gamepadIndex**: The int of the gamepad that you want to restrict this action to. Use 0 for the first gamepad (player 1), 1 for the second one, and so on. If the default value is passed, the gamepad index is never taken into consideration when detecting whether the passed action should be fired.

#### Returns
A numeric value based on the bindings that might have activated this action. The maximum and minimum values returned depend on the kind of control passed via `addGamepadActionBinding()`.

#### Examples

<pre>
// Direction pad left to move left or right
var speedX:Number = myBinder.getActionValue("move-sides"); // Generally between -1 and 1
</pre>
<pre>
// L2/LT to accelerate, depending on how much it is pressed
var acceleration:Number = myBinder.getActionValue("accelerate"); // Generally between 0 and 1
</pre>

#### See also
 * [GamepadControls](#GamepadControls)
 * [addGamepadActionBinding()](#addGamepadActionBinding)
 * [isActionActivated()](#isActionActivated)


### <a name="isActionActivated"></a>isActionActivated(action:String, timeToleranceSeconds:Number = 0, gamepadIndex:int = -1):Boolean

Checks whether an action is currently activated.

#### Parameters

 * **action**: An arbitrary String id identifying the action that should be checked.
 * **timeToleranceSeconds**: Time tolerance, in seconds, before the action is assumed to be expired. If &lt; 0, no time is checked.

#### Returns
True if the action is currently activated (i.e., its button is pressed), false if otherwise.

#### Examples

<pre>// Moves player right when right is pressed
// Setup:
myBinder.addGamepadActionBinding("move-right", GamepadControls.DPAD_RIGHT);
// In the game loop:
if (myBinder.isActionActivated("move-right")) {
	player.moveRight();
}
</pre>
<pre>
// Check if a jump was activated (includes just before falling, for a more user-friendly control)
// Setup:
myBinder.addGamepadActionBinding("jump", GamepadControls.ACTION_DOWN);
// In the game loop:
if (isTouchingSurface && myBinder.isActionActivated("jump"), 0.1)) {
	player.performJump();
}
</pre>

#### See also
 * [GamepadControls](#GamepadControls)
 * [addGamepadActionBinding()](#addGamepadActionBinding)
 * [getActionValue()](#getActionValue)
 * http://zehfernando.com/2013/keyactionbinder-updates-time-sensitive-activations-new-constants/


### <a name="consumeAction"></a>consumeAction(__action:String):void

Consumes an action, causing all current activations and values attached to it to be reset. This is the same as simulating the player releasing the button that activates an action. It is useful to force players to re-activate some actions, such as a jump action (otherwise keeping the jump button pressed would allow the player to jump nonstop).

#### Parameters

 * **action**: The id of the action you want to consume.

#### Examples

<pre>// On jump, consume the jump to avoid constant jumping
if (isTouchingSurface && myBinder.isActionActivated("jump")) {
	myBinder.consumeAction("jump");
    player.performJump();
}
</pre>

#### See also
 * [GamepadControls](#GamepadControls)
 * [isActionActivated()](#isActionActivated)


## Instance functions


### <a name="getNumDevices"></a>getNumDevices():uint

Returns the number of devices currently connected, regardless of whether they're valid or not.

#### See also
 * [maintainPlayerPositions](#maintainPlayerPositions)
 * [getDeviceAt()](#getDeviceAt)
 * [getDeviceTypeAt()](#getDeviceTypeAt)


### <a name="getDeviceAt"></a>getDeviceAt(__index:uint):GameInputDevice

Returns the `GameInputDevice` associated with a player index, if any.

The value returned from this function can be `null`, especially if `maintainPlayerPositions` is set to `true` and the index refers to a gamepad that has been removed.

#### See also
 * [maintainPlayerPositions](#maintainPlayerPositions)
 * [getNumDevices()](#getNumDevices)
 * [getDeviceTypeAt()](#getDeviceTypeAt)

### <a name="getDeviceTypeAt"></a>getDeviceTypeAt(__index:uint):String

Returns the built-in id of the gamepad type at a certain position.

The value returned from this function can be `null` if `maintainPlayerPositions` is set to `true` and the index refers to a gamepad that has been removed, or if the gamepad at that location has not been properly identified by KeyActionBinder.

Check the controllers.json file for a list of supported gamepads, and their ids.

#### See also
 * [maintainPlayerPositions](#maintainPlayerPositions)
 * [getNumDevices()](#getNumDevices)
 * [getDeviceAt()](#getDeviceAt)


### <a name="getPlatformTypes"></a>getPlatformTypes():Vector.&lt;String&gt;

Returns the current identified platform. This is a list of strings that can contain more than one platform id.

Check the controllers.json file for a list of supported platforms, and their ids.


## Instance properties

### <a name="onActionActivated"></a>onActionActivated:SimpleSignal

A signal-like event/callback that gets dispatched when an action is assumed to be activated. You `add()` or `remove()` listening functions to this property.

Notice that the function added must receive a single `String` parameter.

<pre>
// Create a function to handle action activations
private function myOnActionActivated(__action:String):void {
    trace("The user activated the " + __action + " action by pressing a key or button.");
}

// Add that function to the signals list
binder.onActionActivated.add(myOnActionActivated);
</pre>

### <a name="onActionDeactivated"></a>onActionDeactivated:SimpleSignal

A signal-like event/callback that gets dispatched when an action is assumed to be deactivated. You `add()` or `remove()` listening functions to this property.

Notice that the function added must receive a single `String` parameter.

<pre>
// Create a function to handle action deactivations
private function myOnActionDeactivated(__action:String):void {
    trace("The user deactivated the " + __action + " action by releasing a key or button.");
}

// Add that function to the signals list
binder.onActionDeactivated.add(myOnActionDeactivated);
</pre>

### <a name="onActionValueChanged"></a>onActionValueChanged:SimpleSignal

A signal-like event/callback that gets dispatched when the activation value of an action changes. You `add()` or `remove()` listening functions to this property.

Notice that the function added must receive a `String` parameter and a 'Number' parameter.

<pre>
// Create a function to handle action value changes
private function myOnActionValueChanged(__action:String, __value:Number):void {
    trace("The user activated the " + __action + " action's value. The new value is " + __value);
}

// Add that function to the signals list
binder.onActionValueChanged.add(myOnActionValueChanged);
</pre>

### <a name="onDevicesChanged"></a>onDevicesChanged:SimpleSignal

Todo...

### <a name="onRecentDeviceChanged"></a>onRecentDeviceChanged:SimpleSignal

Todo...

### <a name="maintainPlayerPositions"></a>maintainPlayerPositions:Boolean

Toggles whether KeyActionBinder tries to maintain each player's gamepad index based on the unique id of each device.

When this is set to `false`, the list of connected devices (via `getNumDevices()` and others) will always reflect Flash's list of connected GameInputDevices. This means that the connected gamepads can be shuffled around when a device is added or removed, potentially causing players on a multi-player game to have their respective gamepad references swapped.

When this is set to `true`, KeyActionBinder uses the device ids to keep a more consistent list of devices, avoiding shuffling them around. This has several implications:

* When removed, a device will continue to exist in the list as a `null` device (unless it's the last device in the GameInputDevice list, in which case it gets removed entirely)
* An added device will try to be re-added to its previously existing position, if one can be found (that is, if it was present before and then removed)
* If a previously existing position cannot be found for a new device, the device takes the first available (`null`) position if one can be found, or is added to the end of the list of devices otherwise

In general, you should set this option before gameplay starts.

If you set this to `false` after it was set to `true`, it will cause a refresh of the gamepad order, potentially shuffling player positions around if devices were added or removed previously.

The default is `false`.

#### Examples

<pre>
// Test 1
binder.maintainPlayerPositions = false;

// Add controller XBOX1; List is [XBOX1]
// Add controller XBOX2; List is [XBOX1, XBOX2]
// Remove controller XBOX1; List is [XBOX2]
// Add controller XBOX1; List is [XBOX2, XBOX1]
// Remove controller XBOX2; List is [XBOX1]
// Remove controller XBOX1; List is []
</pre>
<pre>
// Test 2
binder.maintainPlayerPositions = true;

// Add controller XBOX1; List is [XBOX1]
// Add controller XBOX2; List is [XBOX1, XBOX2]
// Remove controller XBOX1; List is [null, XBOX2]
// Add controller XBOX1; List is [XBOX1, XBOX2]
// Remove controller XBOX2; List is [XBOX1]
// Remove controller XBOX1; List is []
</pre>

#### See also
 * [getNumDevices()](#getNumDevices)
 * [getDeviceAt()](#getDeviceAt)
 * [getDeviceTypeAt()](#getDeviceTypeAt)


### <a name="isRunning"></a>isRunning:Boolean

Whether this KeyActionBinder instance is running, or not. This property is read-only.

#### See also
 * [start()](#start)
 * [stop()](#stop)

### <a name="alwaysPreventDefault"></a>alwaysPreventDefault(__value:Boolean):void

Whether to run `preventDefault()` on Keyboard events or not.

When this is set to `false`, KeyActionBinder doesn't try stopping the propagation of standard Keyboard behavior. In general, this is a bad idea, as certain keys (such as A on the OUYA) tend to trigger a `Keyboard.BACK` key event, potentially closing your application. Only set this to `false` if you are handling Keyboard events in your own code.

The default is `true`.

## <a name="GamepadControls"></a>GamepadControls static control references

### <a name="STICK_LEFT_X"></a>STICK_LEFT_X:String = "stick_left_x"

Todo...

### <a name="STICK_LEFT_Y"></a>STICK_LEFT_Y:String = "stick_left_y"

Todo...

### <a name="STICK_LEFT_PRESS"></a>STICK_LEFT_PRESS:String = "stick_left_press"

Todo...

### <a name="STICK_RIGHT_X"></a>STICK_RIGHT_X:String = "stick_right_x"

Todo...

### <a name="STICK_RIGHT_Y"></a>STICK_RIGHT_Y:String = "stick_right_y"

Todo...

### <a name="STICK_RIGHT_PRESS"></a>STICK_RIGHT_PRESS:String = "stick_right_press"

Todo...

### <a name="LB"></a>LB:String = "left_button"

Todo...

### <a name="LT"></a>LT:String = "left_trigger"

Todo...

### <a name="RB"></a>RB:String = "right_button"

Todo...

### <a name="RT"></a>RT:String = "right_trigger"

Todo...

### <a name="DPAD_UP"></a>DPAD_UP:String = "dpad_up"

Todo...

### <a name="DPAD_DOWN"></a>DPAD_DOWN:String = "dpad_down"

Todo...

### <a name="DPAD_LEFT"></a>DPAD_LEFT:String = "dpad_left"

Todo...

### <a name="DPAD_RIGHT"></a>DPAD_RIGHT:String = "dpad_right"

Todo...

### <a name="ACTION_UP"></a>ACTION_UP:String = "action_up"

Todo...

### <a name="ACTION_DOWN"></a>ACTION_DOWN:String = "action_down"

Todo...

### <a name="ACTION_LEFT"></a>ACTION_LEFT:String = "action_left"

Todo...

### <a name="ACTION_RIGHT"></a>ACTION_RIGHT:String = "action_right"

Todo...

### <a name="BACK"></a>BACK:String = "meta_back"

Todo...

### <a name="SELECT"></a>SELECT:String = "meta_select"

Todo...

### <a name="START"></a>START:String = "meta_start"

Todo...

### <a name="MENU"></a>MENU:String = "meta_menu"

Todo...

### <a name="OPTIONS"></a>OPTIONS:String = "meta_options"

Todo...

### <a name="TRACKPAD"></a>TRACKPAD:String = "meta_trackpad"

Todo...

### <a name="SHARE"></a>SHARE:String = "meta_share"

Todo...

