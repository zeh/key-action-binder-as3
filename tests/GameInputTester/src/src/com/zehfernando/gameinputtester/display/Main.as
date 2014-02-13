package com.zehfernando.gameinputtester.display {
	import com.zehfernando.display.components.text.TextSprite;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.GameInputEvent;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;

	/**
	 * @author zeh fernando
	 */
	public class Main extends Sprite {

		// Properties
		private var _width:Number;
		private var _height:Number;

		private var frame:uint;

		// Instances
		private var textDeviceState:TextSprite;			// Complete device state
		private var textLog:TextSprite;					// Log of what happens, in order
		private var textKeys:TextSprite;				// Log of all pressed keys
		private var deviceStates:Vector.<Object>;		// List of devices (Objects with their state: key = control.id, value = control)
		private var deviceSensitive:Vector.<Object>;	// Whether device controls are sensitive or not (key = control.id, value = false or true)
		private var textLogLines:Vector.<String>;
		private var gameInput:GameInput;
		private var devicesWithEvents:Vector.<GameInputDevice>;
		private var pressedKeys:Object;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Main() {
			super();

			frame = 0;
			_width = 100;
			_height = 100;

			pressedKeys = {};

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

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);

			redrawWidth();
			redrawHeight();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function redrawWidth():void {
			textDeviceState.x = 0;
			textDeviceState.width = _width/3;
			textKeys.x = textDeviceState.x + textDeviceState.width;
			textKeys.width = _width/3;
			textLog.x = textKeys.x + textKeys.width;
			textLog.width = _width/3;
		}

		private  function redrawHeight():void {
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
			if (textLogLines.length > 50) textLogLines.splice(0, textLogLines.length - 50);
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

			textDeviceState.text = text;
		}

		private function reportDevices(__e:Event = null):void {
			// Create state for devices

			var i:int, j:int;
			var device:GameInputDevice;

			// Remove events for all existing devices
			removeGameInputDeviceEvents();

			// Create events and state object for all controls
			deviceStates = new Vector.<Object>(GameInput.numDevices, true);
			deviceSensitive = new Vector.<Object>(GameInput.numDevices, true);
			for (i = 0; i < GameInput.numDevices; i++) {
				device = GameInput.getDeviceAt(i);
				deviceStates[i] = {};
				deviceSensitive[i] = {};

				if (device != null) {
					device.enabled = true;
					for (j = 0; j < device.numControls; j++) {
						// Create event
						device.getControlAt(j).addEventListener(Event.CHANGE, onGameInputControlChanged, false, 0, true);

						// Add device state
						deviceStates[i][device.getControlAt(j).id] = device.getControlAt(j);
					}
					devicesWithEvents.push(device);
				}
			}

			// Update the display with the list of devices
			updateTextDeviceState();
		}

		private function removeGameInputDeviceEvents():void {
			// Remove events of current all gameinput devices
			var i:int;
			while (devicesWithEvents.length > 0) {
				if (devicesWithEvents[0] != null) {
					for (i = 0; i < devicesWithEvents[0].numControls; i++) {
						devicesWithEvents[0].getControlAt(i).removeEventListener(Event.CHANGE, onGameInputControlChanged, false);
					}
				}
				devicesWithEvents.splice(0, 1);
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onAddedToStage(__e:Event):void {
			redrawWidth();
			redrawHeight();
		}

		private function onRemovedFromStage(__e:Event):void {
		}

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
			trace("Activating");
		}

		private function onDeactivate(__e:Event):void {
			trace("Deactivating");

//			if (gameInput != null) {
//				gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, reportDevices);
//				gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, reportDevices);
//				gameInput = null;
//			}
		}

		private function onEnterFrame(__e:Event):void {
			frame++;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function init():void {
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			stage.addEventListener(Event.ACTIVATE, onActivate);
			stage.addEventListener(Event.DEACTIVATE, onDeactivate);

			gameInput = new GameInput();
			gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, reportDevices);
			gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, reportDevices);

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


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return _width;
		}
		override public function set width(__value:Number):void {
			if (_width != __value) {
				_width = __value;
				redrawWidth();
			}
		}

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			if (_height != __value) {
				_height = __value;
				redrawHeight();
			}
		}
	}
}
