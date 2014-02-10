package com.zehfernando.keyactionbindertester.display {
	import com.zehfernando.display.abstracts.ResizableSprite;
	import com.zehfernando.display.components.text.TextSprite;
	import com.zehfernando.input.binding.GamepadControls;
	import com.zehfernando.input.binding.KeyActionBinder;
	import com.zehfernando.utils.console.log;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;

	/**
	 * @author zeh fernando
	 */
	public class Main extends ResizableSprite {

		// Constants
		private static const ACTION_PREFIX:String = "action-";		// Prefix just to be easy (normally those are arbritrary action names)
		private static const VALUE_PREFIX:String = "value-";		// Prefix just to be easy (normally those are arbritrary value names)

		// Instances
		private var textDeviceState:TextSprite;			// Complete device state
		private var textLog:TextSprite;					// Log of what happens, in order
		private var textKeys:TextSprite;				// Log of all pressed keys
		private var deviceStates:Vector.<Object>;		// List of devices (Objects with their state: key = control.id, value = control)
		private var deviceSensitive:Vector.<Object>;	// Whether device controls are sensitive or not (key = control.id, value = false or true)
		private var textLogLines:Vector.<String>;
		private var devicesWithEvents:Vector.<GameInputDevice>;
		private var frame:uint;
		private var pressedKeys:Object;

		private var binder:KeyActionBinder;

		private var actionsToTrack:Array;
		private var valuesToTrack:Array;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Main() {
			super();

			frame = 0;

			pressedKeys = {};

			actionsToTrack = [
				GamepadControls.ACTION_LEFT, GamepadControls.ACTION_RIGHT, GamepadControls.ACTION_UP, GamepadControls.ACTION_DOWN,
				GamepadControls.DPAD_LEFT, GamepadControls.DPAD_RIGHT, GamepadControls.DPAD_UP, GamepadControls.DPAD_DOWN,
				GamepadControls.MENU, GamepadControls.BACK, GamepadControls.START,
				GamepadControls.OPTIONS, GamepadControls.TRACKPAD,
				GamepadControls.LB, GamepadControls.RB,
				GamepadControls.LT, GamepadControls.RT,
				GamepadControls.STICK_LEFT_PRESS, GamepadControls.STICK_RIGHT_PRESS
			];

			valuesToTrack = [
				GamepadControls.LT, GamepadControls.RT,
				GamepadControls.STICK_LEFT_X, GamepadControls.STICK_LEFT_Y, GamepadControls.STICK_RIGHT_X, GamepadControls.STICK_RIGHT_Y,
			];

			deviceStates = new Vector.<Object>();
			deviceSensitive = new Vector.<Object>();
			textLogLines = new Vector.<String>();
			devicesWithEvents = new Vector.<GameInputDevice>();

			textDeviceState = new TextSprite("_sans", 12, 0xff5555);
			textDeviceState.embeddedFonts = false;
			textDeviceState.leading = 2;
			addChild(textDeviceState);

			textLog = new TextSprite("_sans", 12, 0xffff55);
			textLog.embeddedFonts = false;
			textLog.leading = 2;
			addChild(textLog);

			textKeys = new TextSprite("_sans", 12, 0xff55ff);
			textKeys.embeddedFonts = false;
			textKeys.leading = 2;
			addChild(textKeys);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			textDeviceState.x = 0;
			textDeviceState.width = _width/3;
			textKeys.x = textDeviceState.x + textDeviceState.width;
			textKeys.width = _width/3;
			textLog.x = textKeys.x + textKeys.width;
			textLog.width = _width/3;
		}

		override protected function redrawHeight():void {
			textDeviceState.y = 2;
			textKeys.y = 2;
			textLog.y = 2;
		}

		private function logText(__text:String):void {
			textLogLines.push("[" + frame + "] " + __text);
			//textLogLines.push("[" + (getTimer()/1000).toFixed(3) + "s] " + __text);
			updateTextLog();
		}

		private function setKeyState(__code:int, __location:int, __pressed:Boolean):void {
			var key:String = "" + __code + " @ " + __location + "";
			pressedKeys[key] = __pressed;
			updateTextKeyState();
		}

		private function updateTextLog():void {
			if (textLogLines.length > 60) textLogLines.splice(0, log.length - 60);
			textLog.text = textLogLines.join("\n");
			textLog.y = _height - textLog.height;
		}

		private function updateTextKeyState():void {
			// Update the list of keys

			var text:String = "";
			var i:int;
			var ids:Vector.<String>, iis:String;

			// Header
			text += "Keyboard keys: \n";
			text += "\n";

			// Create a sorted list of keys
			ids = new Vector.<String>();
			for (iis in pressedKeys) {
				ids.push(iis);
			}
			ids = ids.sort(Array.CASEINSENSITIVE);
			for (i = 0; i < ids.length; i++) {
				text += ids[i] + ": " + pressedKeys[ids[i]] + "\n";
			}

			textKeys.text = text;
		}

		private function updateTextDeviceState():void {
			// Update the device text log with the current state of all devices
			var text:String = "";
			var i:int, j:int;

			/*
			var ids:Vector.<String>, iis:String;
			var device:GameInputDevice;
			var control:GameInputControl;

			// Header
			text += "Devices: " + GameInput.numDevices + "\n";
			text += "\n";

			// Device info
			for (i = 0; i < GameInput.numDevices; i++) {
				if (i > 0) text += "\n";
				device = GameInput.getDeviceAt(i);
				if (device != null) {
					text += i + ": \"" + device.name + "\"\n";
					text += "  Enabled: " + device.enabled + "\n";
					text += "  Sample interval: " + device.sampleInterval + "\n";
					text += "  Controls: " + device.numControls + "\n";

					// Device state
					if (device.enabled) {
						// Create a sorted list of controls
						ids = new Vector.<String>();
						for (iis in deviceStates[i]) {
							ids.push(iis);
						}
						ids = ids.sort(Array.CASEINSENSITIVE);
						for (j = 0; j < ids.length; j++) {
							control = deviceStates[i][ids[j]];

							// Find whether they're sensitive or not
							if (!deviceSensitive[i][ids[j]] && control.value != control.minValue && control.value != control.maxValue) {
								// If the value is not min nor max, should be pressure-sensitive
								deviceSensitive[i][ids[j]] = true;
							}

							text += "  " + ids[j] + ": " + control.minValue + " -> " + control.maxValue + " = " + control.value.toFixed(3);
							if (deviceSensitive[i][ids[j]]) text += " (Pressure sensitive)";
							text += "\n";
						}
					}
				} else {
					text += "Device [" + i + "]: NULL!";
				}
			}
			*/

			// Update state
			for (i = 0; i < actionsToTrack.length; i++) {
				text += "Action " + actionsToTrack[i] + ": " + binder.isActionActivated(ACTION_PREFIX + actionsToTrack[i]) + "\n";
			}
			text += "\n";
			for (i = 0; i < valuesToTrack.length; i++) {
				text += "Value " + valuesToTrack[i] + ": " + binder.getActionValue(VALUE_PREFIX + valuesToTrack[i]) + "\n";
			}

			textDeviceState.text = text;
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onKeyDown(__e:KeyboardEvent):void {
			logText("Pressed key code: [" + __e.keyCode + "] location: [" + __e.keyLocation + "]");
			setKeyState(__e.keyCode, __e.keyLocation, true);
		}

		private function onKeyUp(__e:KeyboardEvent):void {
			logText("Released key code: [" + __e.keyCode + "] location: [" + __e.keyLocation + "]");
			setKeyState(__e.keyCode, __e.keyLocation, false);
		}

		private function onGameInputControlChanged(__e:Event):void {
			// Update device states
			updateTextDeviceState();

			// Update log
			var control:GameInputControl = __e.target as GameInputControl;
			logText("Changed value of control [" + control.id + "] to " + control.value.toFixed(3));
		}

		private function onActivate(__e:Event):void {
			log("Activating");
		}

		private function onDeactivate(__e:Event):void {
			log("Deactivating");
		}

		private function onEnterFrame(__e:Event):void {
			// Increase frame count
			frame++;

			// Update controller state
			updateTextDeviceState();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function init():void {
			var i:int;

			binder = new KeyActionBinder();

			// Track actions
			for (i = 0; i < actionsToTrack.length; i++) {
				binder.addGamepadActionBinding(ACTION_PREFIX + actionsToTrack[i], actionsToTrack[i]);
			}

			// Track values
			for (i = 0; i < valuesToTrack.length; i++) {
				binder.addGamepadSensitiveActionBinding(VALUE_PREFIX + valuesToTrack[i], valuesToTrack[i]);
			}

			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			stage.addEventListener(Event.ACTIVATE, onActivate);
			stage.addEventListener(Event.DEACTIVATE, onDeactivate);

			redrawWidth();
			redrawHeight();

			updateTextDeviceState();
			updateTextLog();

			logText("Manufacturer: " + Capabilities.manufacturer);
			logText("OS: " + Capabilities.os);
			logText("Version: " + Capabilities.version);
			logText("Player type = " + Capabilities.playerType);
			logText("GameInput.isSupported = " + GameInput.isSupported);
			logText("");
		}
	}
}
