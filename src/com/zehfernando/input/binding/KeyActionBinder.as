package com.zehfernando.input.binding {
	import com.zehfernando.signals.SimpleSignal;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.GameInputEvent;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	import flash.ui.KeyLocation;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	/**
	 * @author zeh fernando
	 */
	public class KeyActionBinder {

		// Provides universal input control for game controllers and keyboard
		// http://zehfernando.com/2013/abstracting-key-and-game-controller-inputs-in-adobe-air/
		// http://zehfernando.com/2013/keyactionbinder-updates-time-sensitive-activations-new-constants/

		// TODO:
		// * Allow sensitive controls to be treated as normal controls (with a threshold)
		// * Think of a way to avoid axis injecting button pressed
		// * Add gamepad index to return signals, and rethink whether gamepad index should be part of isActionActivated() and getActionValue() instead
		// * Use caching samples?
		// * Allow "any" gamepad key (for "press any key")
		// * Add missing asdocs
		// * Better multi-platform setup... re-think GamepadControls

		// * Gamepad on isActivated()
		// * Thresholds

		// Versions:
		// 2013-10-08	1.1.1	Removed max/min from addGamepadSensitiveActionBinding() (always use hardcoded values)
		// 2013-10-08	1.1.0	Completely revamped the control scheme by using "auto" controls for cross-platform operation
		// 2013-10-08	1.0.0	First version to have a version number

		// Constants
		public static const VERSION:String = "1.1.1";

		// List of all auto-configurable gamepads
		private static var knownGamepadPlatforms:Vector.<AutoPlatformInfo>;

		private static var stage:Stage;

		// Properties
		private var _isRunning:Boolean;
		private var alwaysPreventDefault:Boolean;						// If true, prevent action by other keys all the time (e.g. menu key)

		// Instances
		private var bindings:Vector.<BindingInfo>;						// Actual existing bindings, their action, and whether they're activated or not
		private var actionsActivations:Object;							// How many activations each action has (key string with ActivationInfo instance)

		private var _onActionActivated:SimpleSignal;					// Receives: action:String
		private var _onActionDeactivated:SimpleSignal;					// Receives: action:String
		private var _onSensitiveActionChanged:SimpleSignal;				// Receives: action:String, value:Number (0-1)

		private var gameInputDevices:Vector.<GameInputDevice>;
		private var gameInputDeviceDefinitions:Vector.<AutoGamepadInfo>;

		private static var gameInput:GameInput;


		// Properties to avoid allocations
		private var mi:Number;											// Used in map()

		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		public static function init(__stage:Stage):void  {
			stage = __stage;

			if (GameInput.isSupported) gameInput = new GameInput();

			// Creates a list of all known gamepads via a more readable/editable initializer
			var platformsObj:Object = {
				"windows7" : {
					"filters" : {
						"manufacturer"		: "Adobe Windows",
						"os"				: "Windows 7",
						"version"			: "WIN"
					},
					"gamepads" : {
						"xbox360" : {
							"filters" : {
								"name"			: "Xbox 360 Controller"
							},
							"controls" : {
								"AXIS_0"		: [GamepadControls.STICK_LEFT_X,			-1,	1],
								"AXIS_1"		: [GamepadControls.STICK_LEFT_Y,			 1,	-1],
								"AXIS_2"		: [GamepadControls.STICK_RIGHT_X,			-1,	1],
								"AXIS_3"		: [GamepadControls.STICK_RIGHT_Y,			 1,	-1],
								"BUTTON_4"		: [GamepadControls.ACTION_DOWN,				 0,	1],
								"BUTTON_5"		: [GamepadControls.ACTION_RIGHT,			 0,	1],
								"BUTTON_6"		: [GamepadControls.ACTION_LEFT,				 0,	1],
								"BUTTON_7"		: [GamepadControls.ACTION_UP,				 0,	1],
								"BUTTON_4"		: [GamepadControls.DPAD_UP,					 0,	1],
								"BUTTON_8"		: [GamepadControls.LB,						 0,	1],
								"BUTTON_9"		: [GamepadControls.RB,						 0,	1],
								"BUTTON_10"		: [GamepadControls.LT,						 0,	1],
								"BUTTON_11"		: [GamepadControls.RT,						 0,	1],
								"BUTTON_12"		: [GamepadControls.BACK,					 0,	1],
								"BUTTON_13"		: [GamepadControls.START,					 0,	1],
								"BUTTON_14"		: [GamepadControls.STICK_LEFT_PRESS,		 0,	1],
								"BUTTON_15"		: [GamepadControls.STICK_RIGHT_PRESS,		 0,	1],
								"BUTTON_16"		: [GamepadControls.DPAD_UP,					 0,	1],
								"BUTTON_17"		: [GamepadControls.DPAD_DOWN,				 0,	1],
								"BUTTON_18"		: [GamepadControls.DPAD_LEFT,				 0,	1],
								"BUTTON_19"		: [GamepadControls.DPAD_RIGHT,				 0,	1]
							},
							"keys" : [
							]
						}
					}
				},
				"ouya" : {
					"filters" : {
						"manufacturer"		: "Android Linux",
						"os"				: "Linux",
						"version"			: "AND"
					},
					"gamepads" : {
						"native" : {
							"filters" : {
								"name"			: "OUYA Game Controller"
							},
							"controls" : {
								"AXIS_0"		: [GamepadControls.STICK_LEFT_X,			-1,	1],
								"AXIS_1"		: [GamepadControls.STICK_LEFT_Y,			-1,	1],
								"AXIS_11"		: [GamepadControls.STICK_RIGHT_X,			-1,	1],
								"AXIS_14"		: [GamepadControls.STICK_RIGHT_Y,			-1,	1],
								"AXIS_17"		: [GamepadControls.LT,						 0,	1],
								"AXIS_18"		: [GamepadControls.RT,						 0,	1],
								"BUTTON_19"		: [GamepadControls.DPAD_UP,					 0,	1],
								"BUTTON_20"		: [GamepadControls.DPAD_DOWN,				 0,	1],
								"BUTTON_21"		: [GamepadControls.DPAD_LEFT,				 0,	1],
								"BUTTON_22"		: [GamepadControls.DPAD_RIGHT,				 0,	1],
								"BUTTON_96"		: [GamepadControls.ACTION_DOWN,				 0,	1],
								"BUTTON_97"		: [GamepadControls.ACTION_RIGHT,			 0,	1],
								"BUTTON_99"		: [GamepadControls.ACTION_LEFT,				 0,	1],
								"BUTTON_100"	: [GamepadControls.ACTION_UP,				 0,	1],
								"BUTTON_102"	: [GamepadControls.LB,						 0,	1],
								"BUTTON_103"	: [GamepadControls.RB,						 0,	1],
								"BUTTON_106"	: [GamepadControls.STICK_LEFT_PRESS,		 0,	1],
								"BUTTON_107"	: [GamepadControls.STICK_RIGHT_PRESS,		 0,	1]

								// Ignored (using analog instead):
								// "BUTTON_104"	: [GamepadControls.CONTROL_L2_DIGITAL,				 0,	1],
								// "BUTTON_105"	: [GamepadControls.CONTROL_R2_DIGITAL,				 0,	1],

								// Missing:
								// CONTROL_START (via keyboard though)
								// CONTROL_MENU
								// CONTROL_BACK
							},
							"keys" : [
								{
									// OUYA button
									"code"			: Keyboard.MENU,
									"location"		: KeyLocation.STANDARD,
									"id"			: GamepadControls.START
								}
							]
						},
						"ps3" : {
							"filters" : {
								"name"			: "Sony PLAYSTATION(R)3 Controller"
							},
							"controls" : {
								"AXIS_0"		: [GamepadControls.STICK_LEFT_X,			-1,	1],
								"AXIS_1"		: [GamepadControls.STICK_LEFT_Y,			-1,	1],
								"AXIS_11"		: [GamepadControls.STICK_RIGHT_X,			-1,	1],
								"AXIS_14"		: [GamepadControls.STICK_RIGHT_Y,			-1,	1],
								"AXIS_17"		: [GamepadControls.LT,						 0,	1],
								"AXIS_18"		: [GamepadControls.RT,						 0,	1],
								"AXIS_36"		: [GamepadControls.DPAD_UP,					 0,	1],
								"AXIS_37"		: [GamepadControls.DPAD_RIGHT,				 0,	1],
								"AXIS_38"		: [GamepadControls.DPAD_DOWN,				 0,	1],
								"AXIS_39"		: [GamepadControls.DPAD_LEFT,				 0,	1],
								"BUTTON_96"		: [GamepadControls.ACTION_DOWN,				 0,	1],
								"BUTTON_97"		: [GamepadControls.ACTION_RIGHT,			 0,	1],
								"BUTTON_99"		: [GamepadControls.ACTION_LEFT,				 0,	1],
								"BUTTON_100"	: [GamepadControls.ACTION_UP,				 0,	1],
								"BUTTON_102"	: [GamepadControls.LB,						 0,	1],
								"BUTTON_103"	: [GamepadControls.RB,						 0,	1],
								"BUTTON_106"	: [GamepadControls.STICK_LEFT_PRESS,		 0,	1],
								"BUTTON_107"	: [GamepadControls.STICK_RIGHT_PRESS,		 0,	1],
								"BUTTON_108"	: [GamepadControls.START,					 0,	1]

								// Ignored:
								// "BUTTON_19"		: [GamepadControls.CONTROL_DPAD_UP,					 0,	1],
								// "BUTTON_20"		: [GamepadControls.CONTROL_DPAD_DOWN,				 0,	1],
								// "BUTTON_21"		: [GamepadControls.CONTROL_DPAD_LEFT,				 0,	1],
								// "BUTTON_22"		: [GamepadControls.CONTROL_DPAD_RIGHT,				 0,	1],

								// Missing:
								// CONTROL_MENU (via keyboard though)
								// CONTROL_BACK (via keyboard though)
							},
							"keys" : [
								{
									// SELECT button
									"code"			: Keyboard.BACK,
									"location"		: KeyLocation.STANDARD,
									"id"			: GamepadControls.BACK
								},
								{
									// PS button
									"code"			: Keyboard.MENU,
									"location"		: KeyLocation.STANDARD,
									"id"			: GamepadControls.MENU
								}
							]
						},
						"xbox360" : {
							"filters" : {
								"name"			: "Microsoft X-Box 360 pad"
							},
							"controls" : {
								"AXIS_0"		: [GamepadControls.STICK_LEFT_X,			-1,	1],
								"AXIS_1"		: [GamepadControls.STICK_LEFT_Y,			-1,	1],
								"AXIS_11"		: [GamepadControls.STICK_RIGHT_X,			-1,	1],
								"AXIS_14"		: [GamepadControls.STICK_RIGHT_Y,			-1,	1],
								"AXIS_15"		: [[GamepadControls.DPAD_LEFT, 0, -1],	[GamepadControls.DPAD_RIGHT, 0, 1], 				 0,	1],
								"AXIS_16"		: [[GamepadControls.DPAD_UP, 0, -1],	[GamepadControls.DPAD_DOWN, 0, 1], 					 0,	1],
								"AXIS_17"		: [GamepadControls.LT,						 0,	1],
								"AXIS_18"		: [GamepadControls.RT,						 0,	1],
								"BUTTON_96"		: [GamepadControls.ACTION_DOWN,				 0,	1],
								"BUTTON_97"		: [GamepadControls.ACTION_RIGHT,			 0,	1],
								"BUTTON_99"		: [GamepadControls.ACTION_LEFT,				 0,	1],
								"BUTTON_100"	: [GamepadControls.ACTION_UP,				 0,	1],
								"BUTTON_102"	: [GamepadControls.LB,						 0,	1],
								"BUTTON_103"	: [GamepadControls.RB,						 0,	1],
								"BUTTON_106"	: [GamepadControls.STICK_LEFT_PRESS,		 0,	1],
								"BUTTON_107"	: [GamepadControls.STICK_RIGHT_PRESS,		 0,	1],
								"BUTTON_108"	: [GamepadControls.START,					 0,	1]

								// Ignored:
								// "BUTTON_19"		: [GamepadControls.CONTROL_DPAD_UP,					 0,	1],
								// "BUTTON_20"		: [GamepadControls.CONTROL_DPAD_DOWN,				 0,	1],
								// "BUTTON_21"		: [GamepadControls.CONTROL_DPAD_LEFT,				 0,	1],
								// "BUTTON_22"		: [GamepadControls.CONTROL_DPAD_RIGHT,				 0,	1],

								// Missing:
								// CONTROL_MENU (via keyboard though)
								// CONTROL_BACK (via keyboard though)
							},
							"keys" : [
								{
									// BACK button
									"code"			: Keyboard.BACK,
									"location"		: KeyLocation.STANDARD,
									"id"			: GamepadControls.BACK
								},
								{
									// XBOX button
									"code"			: Keyboard.MENU,
									"location"		: KeyLocation.STANDARD,
									"id"			: GamepadControls.MENU
								}
							]
						}
					}
				}
			};

			// Parse the platformObj into a proper AutoPlatformInfo list

			knownGamepadPlatforms = new Vector.<AutoPlatformInfo>();

			var platformInfo:AutoPlatformInfo, gamepadInfo:AutoGamepadInfo, controlInfo:AutoGamepadControlInfo;
			var iis:String, jjs:String, kks:String;
			var platformObj:Object, gamepadObj:Object, controlObj:Object;
			var manufacturerFilter:String, osFilter:String, versionFilter:String;

			for (iis in platformsObj) {
				platformObj = platformsObj[iis];

				manufacturerFilter	= platformObj["filters"]["manufacturer"];
				osFilter			= platformObj["filters"]["os"];
				versionFilter		= platformObj["filters"]["version"];

				// Only keep items in memory if the version passes the filters
				if ((manufacturerFilter == null	|| Capabilities.manufacturer.indexOf(manufacturerFilter) > -1) &&
					(osFilter == null 			|| Capabilities.os.indexOf(osFilter) > -1) &&
					(versionFilter == null		|| Capabilities.version.indexOf(versionFilter) > -1)) {
					// Add this platform (same as currentl platform)

					platformInfo = new AutoPlatformInfo();
					platformInfo.id					= iis;
					platformInfo.manufacturerFilter	= manufacturerFilter;
					platformInfo.osFilter			= osFilter;
					platformInfo.versionFilter		= versionFilter;

					knownGamepadPlatforms.push(platformInfo);

					// Add possible gamepads
					for (jjs in platformObj["gamepads"]) {
						gamepadObj = platformObj["gamepads"][jjs];

						gamepadInfo = new AutoGamepadInfo();
						gamepadInfo.id			= jjs;
						gamepadInfo.nameFilter	= gamepadObj["filters"]["name"];

						platformInfo.gamepads.push(gamepadInfo);

						// Add possible controls
						for (kks in gamepadObj["controls"]) {
							controlObj = gamepadObj["controls"][kks];

							// TODO: parse complex split items
							controlInfo = new AutoGamepadControlInfo();
							controlInfo.id	= controlObj[0];
							controlInfo.min	= controlObj[1];
							controlInfo.max	= controlObj[2];

							gamepadInfo.controls[kks] = controlInfo;
						}
					}
				}
			}
		}

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function KeyActionBinder() {
			alwaysPreventDefault = true;
			bindings = new Vector.<BindingInfo>();
			actionsActivations = {};

			_onActionActivated = new SimpleSignal();
			_onActionDeactivated = new SimpleSignal();
			_onSensitiveActionChanged = new SimpleSignal();

			start();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function filterKeyboardKeys(__keyCode:uint, __keyLocation:uint):Vector.<BindingInfo> {
			// Returns a list of all key bindings that fit a filter
			// This is faster than using Vector.<T>.filter()! With 10000 actions bound, this takes ~10ms, as opposed to ~13ms using filter()

			var filteredKeys:Vector.<BindingInfo> = new Vector.<BindingInfo>();

			for (var i:int = 0; i < bindings.length; i++) {
				if (bindings[i].binding.matchesKeyboardKey(__keyCode, __keyLocation)) filteredKeys.push(bindings[i]);
			}

			return filteredKeys;
		}

		private function filterGamepadControls(__controlId:String, __gamepad:uint):Vector.<BindingInfo> {
			// Returns a list of all gamepad control bindings that fit a filter
			// This is faster than using Vector.<T>.filter()! With 10000 actions bound, this takes ~10ms, as opposed to ~13ms using filter()

			var filteredControls:Vector.<BindingInfo> = new Vector.<BindingInfo>();

			for (var i:int = 0; i < bindings.length; i++) {
				if (bindings[i].binding.matchesGamepadControl(__controlId, __gamepad)) filteredControls.push(bindings[i]);
			}

			return filteredControls;
		}

		private function prepareAction(__action:String):void {
			// Pre-emptively creates the list of activations for this action
			if (!actionsActivations.hasOwnProperty(__action)) actionsActivations[__action] = new ActivationInfo();
		}

		private function refreshGameInputDeviceList():void {
			// The list of game devices has changed
			removeGameInputDeviceEvents();
			addGameInputDeviceEvents();

			// Create a list of devices for easy identification
			var i:int;

			gameInputDevices = new Vector.<GameInputDevice>();
			gameInputDeviceDefinitions = new Vector.<AutoGamepadInfo>();
			for (i = 0; i < GameInput.numDevices; i++) {
				gameInputDevices.push(GameInput.getDeviceAt(i));
				gameInputDeviceDefinitions.push(findGamepadInfo(gameInputDevices[i]));
			}

//			log("Game input devices changed; new list:");
//			for (i = 0; i < gameInputDevices.length; i++) {
//				log("  " + i + " => device.name is [" + gameInputDevices[i].name + "], identified as [" + gameInputDeviceDefinitions[i].id + "]");
//			}
		}

		private function findGamepadInfo(__gameInputDevice:GameInputDevice):AutoGamepadInfo {
			// Based on a Game InputDevice, find the internal GamepadInfo that describes this Gamepad
			var i:int, j:int;
			for (i = 0; i < knownGamepadPlatforms.length; i++) {
				for (j = 0; j < knownGamepadPlatforms[i].gamepads.length; j++) {
					if (knownGamepadPlatforms[i].gamepads[j].nameFilter == null || gameInputDevices[i].name.indexOf(knownGamepadPlatforms[i].gamepads[j].nameFilter) > -1) {
						return knownGamepadPlatforms[i].gamepads[j];
					}
				}
			}
			trace("Error! Gamepad definition not found for GameInputDevice " + __gameInputDevice.name + "!!");
			return null;
		}

		private function addGameInputDeviceEvents():void {
			// Add events to all devices currently attached
			// http://www.adobe.com/devnet/air/articles/game-controllers-on-air.html

			var device:GameInputDevice;
			var i:int, j:int;

//			debug("Devices: " + GameInput.numDevices);

			for (i = 0; i < GameInput.numDevices; i++) {
				device = GameInput.getDeviceAt(i);

//				debug("  Found device (" + i + "): " + device);

				// Some times the device is null because numDevices is updated before the added device event is dispatched
				if (device != null) {
//					debug("  Adding events to device (" + i + "): name = " + device.name + ", controls = " + device.numControls + ", sampleInterval = " + device.sampleInterval);
					device.enabled = true;
					for (j = 0; j < device.numControls; j++) {
//						debug("    Control id = " + device.getControlAt(j).id + ", val = " + device.getControlAt(j).minValue + " => " + device.getControlAt(j).maxValue);
						device.getControlAt(j).addEventListener(Event.CHANGE, onGameInputControlChanged, false, 0, true);
					}
				}
			}
		}

		private function removeGameInputDeviceEvents():void {
			// Remove events from all devices currently attached

			var device:GameInputDevice;
			var i:int, j:int;

			for (i = 0; i < GameInput.numDevices; i++) {
				device = GameInput.getDeviceAt(i);
				if (device != null) {
					for (j = 0; j < device.numControls; j++) {
						device.getControlAt(j).removeEventListener(Event.CHANGE, onGameInputControlChanged);
					}
				}
			}
		}

		private function map(__value:Number, __oldMin:Number, __oldMax:Number, __newMin:Number = 0, __newMax:Number = 1, __clamp:Boolean = false):Number {
			// Same as map, but without allocations
			if (__oldMin == __oldMax) return __newMin;
			mi = ((__value-__oldMin) / (__oldMax-__oldMin) * (__newMax-__newMin)) + __newMin;
			if (__clamp) mi = __newMin < __newMax ? clamp(mi, __newMin, __newMax) : clamp(mi, __newMax, __newMin);
			return mi;
		}

		private function clamp(__value:Number, __min:Number = 0, __max:Number = 1):Number {
			return __value < __min ? __min : __value > __max ? __max : __value;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onKeyDown(__e:KeyboardEvent):void {
//			debug("key down: " + __e);
			var filteredKeys:Vector.<BindingInfo> = filterKeyboardKeys(__e.keyCode, __e.keyLocation);
			for (var i:int = 0; i < filteredKeys.length; i++) {
				if (!filteredKeys[i].isActivated) {
					// Marks as pressed
					filteredKeys[i].isActivated = true;
					filteredKeys[i].lastActivatedTime = getTimer();

					// Add this activation to the list of current activations
					(actionsActivations[filteredKeys[i].action] as ActivationInfo).addActivation(filteredKeys[i]);

					// Dispatches signal
					if ((actionsActivations[filteredKeys[i].action] as ActivationInfo).getNumActivations() == 1) _onActionActivated.dispatch(filteredKeys[i].action);
				}
			}

			if (alwaysPreventDefault) __e.preventDefault();
		}

		private function onKeyUp(__e:KeyboardEvent):void {
//			debug("key up: " + __e);
			var filteredKeys:Vector.<BindingInfo> = filterKeyboardKeys(__e.keyCode, __e.keyLocation);
			for (var i:int = 0; i < filteredKeys.length; i++) {
				// Marks as released
				filteredKeys[i].isActivated = false;

				// Removes this activation from the list of current activations
				(actionsActivations[filteredKeys[i].action] as ActivationInfo).removeActivation(filteredKeys[i]);

				// Dispatches signal
				if ((actionsActivations[filteredKeys[i].action] as ActivationInfo).getNumActivations() == 0) _onActionDeactivated.dispatch(filteredKeys[i].action);
			}

			if (alwaysPreventDefault) __e.preventDefault();
		}

		private function onGameInputDeviceAdded(__e:GameInputEvent):void {
			//debug("Device added; num devices = " + GameInput.numDevices);
			refreshGameInputDeviceList();
		}

		private function onGameInputDeviceRemoved(__e:GameInputEvent):void {
			//debug("Device removed; num devices = " + GameInput.numDevices);
			refreshGameInputDeviceList();
		}

		private function onGameInputDeviceUnusable(__e:GameInputEvent):void {
			//debug("A Device is unusable; num devices = " + GameInput.numDevices);
			refreshGameInputDeviceList();
		}

		private function onGameInputControlChanged(__e:Event):void {
			var control:GameInputControl = __e.target as GameInputControl;

			// Find the re-mapped control id
			var deviceIndex:int = gameInputDevices.indexOf(control.device);
			var deviceControlInfo:AutoGamepadControlInfo = gameInputDeviceDefinitions[deviceIndex].controls.hasOwnProperty(control.id) ? gameInputDeviceDefinitions[deviceIndex].controls[control.id] as AutoGamepadControlInfo : null;

			if (deviceControlInfo != null) {

				//debug("onGameInputControlChanged: " + control.id + " [" + metaControlId + "] = " + control.value + " (of " + control.minValue + " => " + control.maxValue + ")");

				var filteredControls:Vector.<BindingInfo> = filterGamepadControls(deviceControlInfo.id, deviceIndex);
				var activationInfo:ActivationInfo;

				// Considers activated if past the middle threshold between min/max values (allows analog controls to be treated as digital)
				var isActivated:Boolean = control.value > control.minValue + (control.maxValue - control.minValue) / 2;

				for (var i:int = 0; i < filteredControls.length; i++) {
					activationInfo = actionsActivations[filteredControls[i].action] as ActivationInfo;

					if (filteredControls[i].binding is GamepadSensitiveBinding) {
						// A sensitive binding, send changed value signals instead

						// Dispatches signal
						activationInfo.addSensitiveValue(filteredControls[i].action, map(control.value, control.minValue, control.maxValue, deviceControlInfo.min, deviceControlInfo.max, true));
						_onSensitiveActionChanged.dispatch(filteredControls[i].action, activationInfo.getValue());
					} else {
						// A standard action binding, send activated/deactivated signals

						if (filteredControls[i].isActivated != isActivated) {
							// Value changed
							filteredControls[i].isActivated = isActivated;
							if (isActivated) {
								// Marks as pressed
								filteredControls[i].lastActivatedTime = getTimer();

								// Add this activation to the list of current activations
								activationInfo.addActivation(filteredControls[i]);

								// Dispatches signal
								if (activationInfo.getNumActivations() == 1) _onActionActivated.dispatch(filteredControls[i].action);
							} else {
								// Marks as released

								// Removes this activation from the list of current activations
								activationInfo.removeActivation(filteredControls[i]);

								// Dispatches signal
								if (activationInfo.getNumActivations() == 0) _onActionDeactivated.dispatch(filteredControls[i].action);
							}
						}
					}
				}
			}
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		/**
		 * Starts listening for input events.
		 *
		 * <p>This happens by default when a KeyActionBinder object is instantiated; this method is only useful if
		 * called after <code>stop()</code> has been used.</p>
		 *
		 * <p>Calling this method when a KeyActionBinder instance is already running has no effect.</p>
		 *
		 * @see #isRunning
		 * @see #stop()
		 */
		public function start():void {
			if (!_isRunning) {
				// Starts listening to keyboard events
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

				// Starts listening to device addition events
				if (gameInput != null) {
					gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onGameInputDeviceAdded);
					gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onGameInputDeviceRemoved);
					gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE, onGameInputDeviceUnusable);
				}

				refreshGameInputDeviceList();

				_isRunning = true;
			}
		}

		/**
		 * Stops listening for input events.
		 *
		 * <p>Action bindings are not lost when a KeyActionBinder instance is stopped; it merely starts ignoring
		 * all input events, until <code>start()<code> is called again.</p>
		 *
		 * <p>This method should always be called when you don't need a KeyActionBinder instance anymore, otherwise
		 * it'll be listening to events indefinitely.</p>
		 *
		 * <p>Calling this method when this a KeyActionBinder instance is already stopped has no effect.</p>
		 *
		 * @see #isRunning
		 * @see #start()
		 */
		public function stop():void {
			if (_isRunning) {
				// Stops listening to keyboard events
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
				stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);

				// Stops listening to device addition events
				if (gameInput != null) {
					gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, onGameInputDeviceAdded);
					gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, onGameInputDeviceRemoved);
				}

				gameInputDevices = null;
				gameInputDeviceDefinitions = null;
				removeGameInputDeviceEvents();

				_isRunning = false;
			}
		}

		/**
		 * Add an action bound to a keyboard key. When a key with the given <code>keyCode</code> is pressed, the
		 * desired action is activated. Optionally, keys can be restricted to a specific <code>keyLocation</code>.
		 *
		 * @param action		An arbitrary String id identifying the action that should be dispatched once this
		 *						key combination is detected.
		 * @param keyCode		The code of a key, as expressed in AS3's Keyboard constants.
		 * @param keyLocation	The code of a key's location, as expressed in AS3's KeyLocation constants. If a
		 *						value of -1 or <code>NaN</code> is passed, the key location is never taken into
		 *						consideration when detecting whether the passed action should be fired.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Left arrow key to move left
		 * myBinder.addKeyboardActionBinding("move-left", Keyboard.LEFT);
		 *
		 * // SPACE key to jump
		 * myBinder.addKeyboardActionBinding("jump", Keyboard.SPACE);
		 *
		 * // Any SHIFT key to shoot
		 * myBinder.addKeyboardActionBinding("shoot", Keyboard.SHIFT);
		 *
		 * // Left SHIFT key to boost
		 * myBinder.addKeyboardActionBinding("boost", Keyboard.SHIFT, KeyLocation.LEFT);
		 * </pre>
		 *
		 * @see flash.ui.Keyboard
		 */
		public function addKeyboardActionBinding(__action:String, __keyCode:int = -1, __keyLocation:int = -1):void {
			// TODO: use KeyActionBinder.KEY_LOCATION_ANY as default param? The compiler doesn't like constants.

			// Create a binding to be verified later
			bindings.push(new BindingInfo(__action, new KeyboardBinding(__keyCode >= 0 ? __keyCode : KeyboardBinding.KEY_CODE_ANY, __keyLocation >= 0 ? __keyLocation : KeyboardBinding.KEY_LOCATION_ANY)));
			prepareAction(__action);
		}

		/**
		 * Add an action bound to a game controller button, trigger, or axis. When a control of id
		 * <code>controlId</code> is pressed, the desired action is activated. Optionally, keys can be restricted
		 * to a specific game controller location.
		 *
		 * @param action		An arbitrary String id identifying the action that should be dispatched once this
		 *						input combination is detected.
		 * @param controlId		The id code of a GameInput contol, as an String. Use one of the constants from
		 *						<code>GamepadControls</code>.
		 * @param gamepadIndex	The int of the gamepad that you want to restrict this action to. Use 0 for the
		 *						first gamepad (player 1), 1 for the second one, and so on. If a value of -1 or
		 *						<code>NaN</code> is passed, the gamepad index is never taken into consideration
		 *						when detecting whether the passed action should be fired.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Direction pad left to move left
		 * myBinder.addGamepadActionBinding("move-left", GamepadControls.DPAD_LEFT);
		 *
		 * // Action button "down" (O in the OUYA, Cross in the PS3, A in the XBox 360) to jump
		 * myBinder.addGamepadActionBinding("jump", GamepadControls.ACTION_DOWN);
		 *
		 * // L1/LB to shoot, on any controller
		 * myBinder.addGamepadActionBinding("shoot", GamepadControls.LB);
		 *
		 * // L1/LB to shoot, on the first controller only
		 * myBinder.addGamepadActionBinding("shoot-player-1", GamepadControls.LB, 0);
		 *
		 * // L2/LT to shoot, regardless of whether it is sensitive or not
		 * myBinder.addGamepadActionBinding("shoot", GamepadControls.LT);
		 * </pre>
		 *
		 * @see GamepadControls
		 * @see #isActionActivated()
		 */
		public function addGamepadActionBinding(__action:String, __controlId:String, __gamepadIndex:int = -1):void {
			// Create a binding to be verified later
			bindings.push(new BindingInfo(__action, new GamepadBinding(__controlId, __gamepadIndex >= 0 ? __gamepadIndex : GamepadBinding.GAMEPAD_INDEX_ANY)));
			prepareAction(__action);
		}

		/**
		 * Add a sensitive action bound to a game controller button, trigger, or axis. When a control of id
		 * <code>controlId</code> is pressed, the desired action receives a value. Optionally, keys can be
		 * restricted to a specific game controller location.
		 *
		 * @param action		An arbitrary String id identifying the action that should be dispatched once this
		 *						input combination is detected.
		 * @param controlId		The id code of a GameInput contol, as an String. Use one of the constants from
		 *						<code>GamepadControls</code>.
		 * @param gamepadIndex	The int of the gamepad that you want to restrict this action to. Use 0 for the
		 *						first gamepad (player 1), 1 for the second one, and so on. If a value of -1 or
		 *						<code>NaN</code> is passed, the gamepad index is never taken into consideration
		 *						when detecting whether the passed action should be fired.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Direction pad left to move left or right
		 * myBinder.addGamepadSensitiveActionBinding("move-sides", GamepadControls.STICK_LEFT_X);
		 *
		 * // L2/LT to accelerate, depending on how much it is pressed
		 * myBinder.addGamepadSensitiveActionBinding("accelerate", GamepadControls.LT);
		 * </pre>
		 *
		 * @see GamepadControls
		 * @see #getActionValue()
		 */
		public function addGamepadSensitiveActionBinding(__action:String, __controlId:String, __gamepadIndex:int = -1):void {
			// Create a binding to be verified later
			bindings.push(new BindingInfo(__action, new GamepadSensitiveBinding(__controlId, __gamepadIndex >= 0 ? __gamepadIndex : GamepadBinding.GAMEPAD_INDEX_ANY)));
			prepareAction(__action);
		}

		/**
		 * Reads the current value of an action.
		 *
		 * @param action		The id of the action you want to read the value of.
		 * @param controlId		The id code of a GameInput contol, as an String. Use one of the constants from
		 *						<code>GamepadControls</code>.
		 * @param gamepadIndex	The int of the gamepad that you want to restrict this action to. Use 0 for the
		 *						first gamepad (player 1), 1 for the second one, and so on. If a value of -1 or
		 *						<code>NaN</code> is passed, the gamepad index is never taken into consideration
		 *						when detecting whether the passed action should be fired.
		 * @return				A numeric value based on the bindings that might have activated this action.
		 *						The maximum and minimum values returned depend on the kind of control passed
		 *						via <code>addGamepadSensitiveActionBinding()</code>.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Direction pad left to move left or right
		 * var speedX:Number = myBinder.getActionValue("move-sides"); // Generally between -1 and 1
		 *
		 * // L2/LT to accelerate, depending on how much it is pressed
		 * var acceleration:Number = myBinder.getActionValue("accelerate"); // Generally between 0 and 1
		 * </pre>
		 *
		 * @see GamepadControls
		 * @see #addGamepadSensitiveActionBinding()
		 * @see #isActionActivated()
		 */
		public function getActionValue(__action:String):Number {
			return actionsActivations.hasOwnProperty(__action) ? (actionsActivations[__action] as ActivationInfo).getValue() : 0;
		}

		/**
		 * Checks whether an action is currently activated.
		 *
		 * @param action				An arbitrary String id identifying the action that should be checked.
		 * @param timeToleranceSeconds	Time tolerance, in seconds, before the action is assumed to be expired. If &lt; 0, no time is checked.
		 * @return						True if the action is currently activated (i.e., its button is pressed), false if otherwise.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Moves player right when right is pressed
		 * // Setup:
		 * myBinder.addGamepadActionBinding("move-right", GamepadControls.DPAD_RIGHT);
		 * // In the game loop:
		 * if (myBinder.isActionActivated("move-right")) {
		 *     player.moveRight();
		 * }
		 *
		 * // Check if a jump was activated (includes just before falling, for a more user-friendly control):
		 * if (isTouchingSurface && myBinder.isActionActivated("jump"), 0.1) {
		 *     player.performJump();
		 * }
		 * </pre>
		 *
		 * @see GamepadControls
		 * @see #addGamepadActionBinding()
		 * @see http://zehfernando.com/2013/keyactionbinder-updates-time-sensitive-activations-new-constants/
		 * @see #getActionValue()
		 */
		public function isActionActivated(__action:String, __timeToleranceSeconds:Number = 0, __gamepadIndex:int = -1):Boolean {
			return actionsActivations.hasOwnProperty(__action) && (actionsActivations[__action] as ActivationInfo).getNumActivations(__timeToleranceSeconds) > 0;
		}

		/**
		 * Consumes an action, causing all current activations and values attached to it to be reset. This is
		 * the same as simulating the player releasing the button that activates an action. It is useful to
		 * force players to re-activate some actions, such as a jump action (otherwise keeping the jump button
		 * pressed would allow the player to jump nonstop).
		 *
		 * @param action		The id of the action you want to consume.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // On jump, consume the jump
		 * if (isTouchingSurface && myBinder.isActionActivated("jump")) {
		 *     myBinder.consumeAction("jump");
		 *     player.performJump();
		 * }
		 * </pre>
		 *
		 * @see GamepadControls
		 * @see #isActionActivated()
		 */
		public function consumeAction(__action:String):void {
			// Deactivates all current actions of an action (forcing a button to be pressed again)
			if (actionsActivations.hasOwnProperty(__action)) (actionsActivations[__action] as ActivationInfo).resetActivations();
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get onActionActivated():SimpleSignal {
			return _onActionActivated;
		}

		public function get onActionDeactivated():SimpleSignal {
			return _onActionDeactivated;
		}

		public function get onSensitiveActionChanged():SimpleSignal {
			return _onSensitiveActionChanged;
		}

		public function get isRunning():Boolean {
			return _isRunning;
		}
	}
}
import flash.utils.Dictionary;
import flash.utils.getTimer;
/**
 * Information listing all activated bindings of a given action
 */
class ActivationInfo {

	private var activations:Vector.<BindingInfo>;			// All activated bindings
	private var sensitiveValues:Dictionary;					// Dictionary with IBinding

	// Temp vars to avoid garbage collection
	private var iiv:Number;									// Value buffer
	private var iix:int;									// Search index
	private var iis:Object;									// Object iterator
	private var iit:int;									// Time
	private var iii:int;									// Iterator
	private var iic:int;									// Count

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function ActivationInfo() {
		activations = new Vector.<BindingInfo>();
		sensitiveValues = new Dictionary();
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function addActivation(__bindingInfo:BindingInfo, __gamepadIndex:int = -1):void {
		activations.push(__bindingInfo);
	}

	public function removeActivation(__bindingInfo:BindingInfo):void {
		iix = activations.indexOf(__bindingInfo);
		if (iix > -1) {
			activations.splice(iix, 1);
		}
	}

	public function getNumActivations(__timeToleranceSeconds:Number = 0):int {
		// If not time-sensitive, just return it
		if (__timeToleranceSeconds <= 0 || activations.length == 0) return activations.length;
		// Otherwise, actually check for activation time
		iit = getTimer() - __timeToleranceSeconds * 1000;
		iic = 0;
		for (iii = 0; iii < activations.length; iii++) {
			if (activations[iii].lastActivatedTime >= iit) iic++;
		}
		return iic;
	}

	public function resetActivations():void {
		activations.length = 0;
	}

	public function addSensitiveValue(__actionId:String, __value:Number):void {
		sensitiveValues[__actionId] = __value;
	}

	public function getValue():Number {
		iiv = NaN;
		for (iis in sensitiveValues) {
			// NOTE: this will be a problem if two axis control the same action, since +1 is not necessarily better than -1
			if (isNaN(iiv) || sensitiveValues[iis] > iiv) iiv = sensitiveValues[iis];
		}
		if (isNaN(iiv)) return activations.length == 0 ? 0 : 1;
		return iiv;
	}
}

/**
 * Information linking an action to a binding, and whether it's activated
 */
class BindingInfo {

	// Properties
	public var action:String;
	public var binding:IBinding;
	public var isActivated:Boolean;
	public var lastActivatedTime:uint;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function BindingInfo(__action:String = "", __binding:IBinding = null) {
		action = __action;
		binding = __binding;
		isActivated = false;
		lastActivatedTime = 0;
	}
}

interface IBinding {
	function matchesKeyboardKey(__keyCode:uint, __keyLocation:uint):Boolean;
	function matchesGamepadControl(__controlId:String, __gamepadIndex:uint):Boolean;
}

/**
 * Information on a keyboard event filter
 */
class KeyboardBinding implements IBinding {

	// Constants
	public static var KEY_CODE_ANY:uint = 81653812;
	public static var KEY_LOCATION_ANY:uint = 8165381;

	// Properties
	public var keyCode:uint;
	public var keyLocation:uint;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function KeyboardBinding(__keyCode:uint, __keyLocation:uint) {
		super();

		keyCode = __keyCode;
		keyLocation = __keyLocation;
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function matchesKeyboardKey(__keyCode:uint, __keyLocation:uint):Boolean {
		return (keyCode == __keyCode || keyCode == KEY_CODE_ANY) && (keyLocation == __keyLocation || keyLocation == KEY_LOCATION_ANY);
	}

	// TODO: add modifiers?

	public function matchesGamepadControl(__controlId:String, __gamepadIndex:uint):Boolean {
		return false;
	}
}

/**
 * Information on a gamepad event filter
 */
class GamepadBinding implements IBinding {

	// Constants
	public static var GAMEPAD_INDEX_ANY:uint = 8165381;

	// Properties
	public var controlId:String;
	public var gamepadIndex:uint;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function GamepadBinding(__controlId:String, __gamepadIndex:uint) {
		super();

		controlId = __controlId;
		gamepadIndex = __gamepadIndex;
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function matchesGamepadControl(__controlId:String, __gamepadIndex:uint):Boolean {
		return controlId == __controlId && (gamepadIndex == __gamepadIndex || gamepadIndex == GAMEPAD_INDEX_ANY);
	}

	public function matchesKeyboardKey(__keyCode:uint, __keyLocation:uint):Boolean {
		return false;
	}

	// TODO: add option to restrict to a given gamepad based on name? (e.g. OUYA)
}

/**
 * Information on a gamepad event filter with sensitivity values
 */
class GamepadSensitiveBinding extends GamepadBinding {

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function GamepadSensitiveBinding(__controlId:String, __gamepadIndex:uint) {
		super(__controlId, __gamepadIndex);
	}
}

/**
 * Information on platforms that are automatically mapped
 */
class AutoPlatformInfo {

	// Properties
	public var id:String;

	public var manufacturerFilter:String;		// Filter for Capabilities.manufacturer
	public var osFilter:String;					// Filter for Capabilities.os
	public var versionFilter:String;			// Filter for Capabilities.version

	public var gamepads:Vector.<AutoGamepadInfo>;


	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function AutoPlatformInfo() {
		gamepads = new Vector.<AutoGamepadInfo>();
	}
}

/**
 * Information on gamepads that are automatically mapped
 */
class AutoGamepadInfo {

	// Properties
	public var id:String;

	public var nameFilter:String;				// Filter for device.name

	public var controls:Object;					// AutoGamepadControlInfo, key is the control.id


	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function AutoGamepadInfo() {
		controls = {};
	}
}

/**
 * Information on gamepads controls that are automatically mapped
 */
class AutoGamepadControlInfo {

	// Properties
	public var id:String;
	public var min:Number;
	public var max:Number;


	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function AutoGamepadControlInfo() {
	}
}

