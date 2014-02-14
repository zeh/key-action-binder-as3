package com.zehfernando.keyactionbindertester.display {
	import com.zehfernando.display.components.text.TextSprite;
	import com.zehfernando.input.binding.GamepadControls;
	import com.zehfernando.input.binding.KeyActionBinder;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.ui.GameInput;
	import flash.ui.GameInputDevice;

	/**
	 * @author zeh fernando
	 */
	public class Main extends Sprite {

		// Constants
		private static const ACTION_PREFIX:String = "action-";		// Prefix just to be easy (normally those are arbritrary action names)
		private static const VALUE_PREFIX:String = "value-";		// Prefix just to be easy (normally those are arbritrary value names)

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
		private var devicesWithEvents:Vector.<GameInputDevice>;
		private var pressedKeys:Object;

		private var binder:KeyActionBinder;

		private var actionsToTrack:Array;
		private var valuesToTrack:Array;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Main() {
			super();

			frame = 0;
			_width = 100;
			_height = 100;

			pressedKeys = {};

			actionsToTrack = [
				GamepadControls.ACTION_LEFT, GamepadControls.ACTION_RIGHT, GamepadControls.ACTION_UP, GamepadControls.ACTION_DOWN,
				GamepadControls.DPAD_LEFT, GamepadControls.DPAD_RIGHT, GamepadControls.DPAD_UP, GamepadControls.DPAD_DOWN,
				GamepadControls.MENU, GamepadControls.BACK, GamepadControls.START, GamepadControls.SELECT, GamepadControls.SHARE,
				GamepadControls.OPTIONS, GamepadControls.TRACKPAD,
				GamepadControls.LB, GamepadControls.RB,
				GamepadControls.LT, GamepadControls.RT,
				GamepadControls.STICK_LEFT_PRESS, GamepadControls.STICK_RIGHT_PRESS
			];

			valuesToTrack = [
				GamepadControls.LT, GamepadControls.RT,
				GamepadControls.STICK_LEFT_X, GamepadControls.STICK_LEFT_Y, GamepadControls.STICK_RIGHT_X, GamepadControls.STICK_RIGHT_Y,
				GamepadControls.DPAD_LEFT, GamepadControls.DPAD_RIGHT, GamepadControls.DPAD_UP, GamepadControls.DPAD_DOWN
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

		private function redrawHeight():void {
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
			if (textLogLines.length > 60) textLogLines.splice(0, textLogLines.length - 60);
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
			var i:int;

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

		private function onAddedToStage(__e:Event):void {
			redrawWidth();
			redrawHeight();
		}

		private function onRemovedFromStage(__e:Event):void {
		}

		private function onActivate(__e:Event):void {
			trace("Activating");
		}

		private function onDeactivate(__e:Event):void {
			trace("Deactivating");
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
