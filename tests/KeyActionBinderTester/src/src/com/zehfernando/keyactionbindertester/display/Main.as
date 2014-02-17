package com.zehfernando.keyactionbindertester.display {
	import com.zehfernando.display.components.text.TextSprite;
	import com.zehfernando.display.shapes.Box;
	import com.zehfernando.input.binding.GamepadControls;
	import com.zehfernando.input.binding.KeyActionBinder;
	import com.zehfernando.keyactionbindertester.display.gamepad.GamepadView;
	import com.zehfernando.keyactionbindertester.display.gamepad.GamepadViewList;

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
		private static const CONTROL_LB:String = "lb";
		private static const CONTROL_RB:String = "rb";
		private static const CONTROL_LT:String = "lt";
		private static const CONTROL_RT:String = "rt";
		private static const CONTROL_DU:String = "du";
		private static const CONTROL_DD:String = "dd";
		private static const CONTROL_DL:String = "dl";
		private static const CONTROL_DR:String = "dr";
		private static const CONTROL_AU:String = "au";
		private static const CONTROL_AD:String = "ad";
		private static const CONTROL_AL:String = "al";
		private static const CONTROL_AR:String = "ar";
		private static const CONTROL_SL_X:String = "sl_x";
		private static const CONTROL_SL_Y:String = "sl_y";
		private static const CONTROL_SL_V:String = "sl_v";
		private static const CONTROL_SR_X:String = "sr_x";
		private static const CONTROL_SR_Y:String = "sr_y";
		private static const CONTROL_SR_V:String = "sr_v";
		private static const CONTROL_MSELECT:String = "mselect";
		private static const CONTROL_MBACK:String = "mback";
		private static const CONTROL_MSTART:String = "mstart";
		private static const CONTROL_MMENU:String = "mmenu";
		private static const CONTROL_MOPTIONS:String = "moptions";
		private static const CONTROL_MTRACKPAD:String = "mtrackpad";
		private static const CONTROL_MSHARE:String = "mshare";

		// Properties
		private var _width:Number;
		private var _height:Number;

		private var frame:uint;

		// Instances
		private var textLog:TextSprite;					// Log of what happens, in order
		private var deviceStates:Vector.<Object>;		// List of devices (Objects with their state: key = control.id, value = control)
		private var deviceSensitive:Vector.<Object>;	// Whether device controls are sensitive or not (key = control.id, value = false or true)
		private var textLogLines:Vector.<String>;
		private var devicesWithEvents:Vector.<GameInputDevice>;
		private var pressedKeys:Object;

		private var binder:KeyActionBinder;

		private var actionsToTrack:Array;
		private var valuesToTrack:Array;

		private var background:Box;

		private var gamepadViewList:GamepadViewList;


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

			// Create assets
			background = new Box(100, 100, 0xeeeeee);
			addChild(background);

			textLog = new TextSprite("_sans", 12, 0xcccccc);
			textLog.embeddedFonts = false;
			textLog.leading = 2;
			addChild(textLog);

			gamepadViewList = new GamepadViewList();
			addChild(gamepadViewList);

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);

			redrawWidth();
			redrawHeight();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function redrawWidth():void {
			textLog.x = 2;
			textLog.width = _width/2;
			background.width = _width;
			gamepadViewList.width = _width;
			updateTextLog();
		}

		private function redrawHeight():void {
			textLog.y = 2;
			background.height = _height;
			gamepadViewList.height = _height;
			updateTextLog();
		}

		private function logText(__text:String):void {
			trace(__text);
			textLogLines.push("[" + frame + "] " + __text);
			//textLogLines.push("[" + (getTimer()/1000).toFixed(3) + "s] " + __text);
			updateTextLog();
		}

		private function updateTextLog():void {
			if (textLogLines.length > 60) textLogLines.splice(0, textLogLines.length - 60);
			textLog.text = textLogLines.join("\n");
			textLog.y = _height - textLog.height;
		}

		private function updateDeviceViewState():void {
			var gamepad:GamepadView;
			for (var i:int = 0; i < binder.getNumDevices(); i++) {
				gamepad = gamepadViewList.getGamepadAt(i);
				gamepad.buttonLB.value   = binder.getActionValue(CONTROL_LB, i);
				gamepad.buttonLB.pressed = binder.isActionActivated(CONTROL_LB, 0, i);
				gamepad.buttonRB.value   = binder.getActionValue(CONTROL_RB, i);
				gamepad.buttonRB.pressed = binder.isActionActivated(CONTROL_RB, 0, i);
				gamepad.buttonLT.value   = binder.getActionValue(CONTROL_LT, i);
				gamepad.buttonLT.pressed = binder.isActionActivated(CONTROL_LT, 0, i);
				gamepad.buttonRT.value   = binder.getActionValue(CONTROL_RT, i);
				gamepad.buttonRT.pressed = binder.isActionActivated(CONTROL_RT, 0, i);
				gamepad.buttonDU.value   = binder.getActionValue(CONTROL_DU, i);
				gamepad.buttonDU.pressed = binder.isActionActivated(CONTROL_DU, 0, i);
				gamepad.buttonDD.value   = binder.getActionValue(CONTROL_DD, i);
				gamepad.buttonDD.pressed = binder.isActionActivated(CONTROL_DD, 0, i);
				gamepad.buttonDL.value   = binder.getActionValue(CONTROL_DL, i);
				gamepad.buttonDL.pressed = binder.isActionActivated(CONTROL_DL, 0, i);
				gamepad.buttonDR.value   = binder.getActionValue(CONTROL_DR, i);
				gamepad.buttonDR.pressed = binder.isActionActivated(CONTROL_DR, 0, i);
				gamepad.buttonAU.value   = binder.getActionValue(CONTROL_AU, i);
				gamepad.buttonAU.pressed = binder.isActionActivated(CONTROL_AU, 0, i);
				gamepad.buttonAD.value   = binder.getActionValue(CONTROL_AD, i);
				gamepad.buttonAD.pressed = binder.isActionActivated(CONTROL_AD, 0, i);
				gamepad.buttonAL.value   = binder.getActionValue(CONTROL_AL, i);
				gamepad.buttonAL.pressed = binder.isActionActivated(CONTROL_AL, 0, i);
				gamepad.buttonAR.value   = binder.getActionValue(CONTROL_AR, i);
				gamepad.buttonAR.pressed = binder.isActionActivated(CONTROL_AR, 0, i);
				gamepad.buttonSL.valueX         = binder.getActionValue(CONTROL_SL_X, i);
				gamepad.buttonSL.valueY         = binder.getActionValue(CONTROL_SL_Y, i);
				gamepad.buttonSL.value          = binder.getActionValue(CONTROL_SL_V, i);
				gamepad.buttonSL.pressed        = binder.isActionActivated(CONTROL_SL_V, 0, i);
				gamepad.buttonSR.valueX         = binder.getActionValue(CONTROL_SR_X, i);
				gamepad.buttonSR.valueY         = binder.getActionValue(CONTROL_SR_Y, i);
				gamepad.buttonSR.value          = binder.getActionValue(CONTROL_SR_V, i);
				gamepad.buttonSR.pressed        = binder.isActionActivated(CONTROL_SR_V, 0, i);
				gamepad.buttonMSelect.value     = binder.getActionValue(CONTROL_MSELECT, i);
				gamepad.buttonMSelect.pressed   = binder.isActionActivated(CONTROL_MSELECT, 0, i);
				gamepad.buttonMBack.value       = binder.getActionValue(CONTROL_MBACK, i);
				gamepad.buttonMBack.pressed     = binder.isActionActivated(CONTROL_MBACK, 0, i);
				gamepad.buttonMStart.value      = binder.getActionValue(CONTROL_MSTART, i);
				gamepad.buttonMStart.pressed    = binder.isActionActivated(CONTROL_MSTART, 0, i);
				gamepad.buttonMMenu.value       = binder.getActionValue(CONTROL_MMENU, i);
				gamepad.buttonMMenu.pressed     = binder.isActionActivated(CONTROL_MMENU, 0, i);
				gamepad.buttonMOptions.value    = binder.getActionValue(CONTROL_MOPTIONS, i);
				gamepad.buttonMOptions.pressed  = binder.isActionActivated(CONTROL_MOPTIONS, 0, i);
				gamepad.buttonMTrackpad.value   = binder.getActionValue(CONTROL_MTRACKPAD, i);
				gamepad.buttonMTrackpad.pressed = binder.isActionActivated(CONTROL_MTRACKPAD, 0, i);
				gamepad.buttonMShare.value      = binder.getActionValue(CONTROL_MSHARE, i);
				gamepad.buttonMShare.pressed    = binder.isActionActivated(CONTROL_MSHARE, 0, i);
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
			updateDeviceViewState();
		}

		private function onDevicesChanged():void {
			// Devices have changed, list them
			logText("The list of game input devices has changed. Total devices: " + binder.getNumDevices());

			var i:int;

			// Update gamepad list
			gamepadViewList.removeAllGamepads();
			for (i = 0; i < binder.getNumDevices(); i++) {
				gamepadViewList.addGamepad(binder.getDeviceAt(i) == null ? null : binder.getDeviceAt(i).name, binder.getDeviceTypeAt(i), binder.getDeviceAt(i) == null ? null : binder.getDeviceAt(i).id);
			}

			// Trace info
			for (i = 0; i < binder.getNumDevices(); i++) {
				logText("  " + i + ": " + binder.getDeviceTypeAt(i));
//				logText("    Name: [" + (binder.getDeviceAt(i) == null ? null : binder.getDeviceAt(i).name) + "]");
//				logText("    Type: [" + binder.getDeviceTypeAt(i) + "]");
//				logText("    id: [" + (binder.getDeviceAt(i) == null ? null : binder.getDeviceAt(i).id) + "]");
			}

			updateDeviceViewState();

		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function init():void {
			binder = new KeyActionBinder();

			binder.onDevicesChanged.add(onDevicesChanged);

			// Create bindings for the controller
			// Normally this would be your own actions (e.g. "jump"), but in this case we just
			// want to track buttons themselves so we add actions that are 1:1 with the buttons
			binder.addGamepadActionBinding(CONTROL_LB,        GamepadControls.LB);
			binder.addGamepadActionBinding(CONTROL_RB,        GamepadControls.RB);
			binder.addGamepadActionBinding(CONTROL_LT,        GamepadControls.LT);
			binder.addGamepadActionBinding(CONTROL_RT,        GamepadControls.RT);
			binder.addGamepadActionBinding(CONTROL_DU,        GamepadControls.DPAD_UP);
			binder.addGamepadActionBinding(CONTROL_DD,        GamepadControls.DPAD_DOWN);
			binder.addGamepadActionBinding(CONTROL_DL,        GamepadControls.DPAD_LEFT);
			binder.addGamepadActionBinding(CONTROL_DR,        GamepadControls.DPAD_RIGHT);
			binder.addGamepadActionBinding(CONTROL_AU,        GamepadControls.ACTION_UP);
			binder.addGamepadActionBinding(CONTROL_AD,        GamepadControls.ACTION_DOWN);
			binder.addGamepadActionBinding(CONTROL_AL,        GamepadControls.ACTION_LEFT);
			binder.addGamepadActionBinding(CONTROL_AR,        GamepadControls.ACTION_RIGHT);
			binder.addGamepadActionBinding(CONTROL_SL_X,      GamepadControls.STICK_LEFT_X);
			binder.addGamepadActionBinding(CONTROL_SL_Y,      GamepadControls.STICK_LEFT_Y);
			binder.addGamepadActionBinding(CONTROL_SL_V,      GamepadControls.STICK_LEFT_PRESS);
			binder.addGamepadActionBinding(CONTROL_SR_X,      GamepadControls.STICK_RIGHT_X);
			binder.addGamepadActionBinding(CONTROL_SR_Y,      GamepadControls.STICK_RIGHT_Y);
			binder.addGamepadActionBinding(CONTROL_SR_V,      GamepadControls.STICK_RIGHT_PRESS);
			binder.addGamepadActionBinding(CONTROL_MSELECT,   GamepadControls.SELECT);
			binder.addGamepadActionBinding(CONTROL_MBACK,     GamepadControls.BACK);
			binder.addGamepadActionBinding(CONTROL_MSTART,    GamepadControls.START);
			binder.addGamepadActionBinding(CONTROL_MMENU,     GamepadControls.MENU);
			binder.addGamepadActionBinding(CONTROL_MOPTIONS,  GamepadControls.OPTIONS);
			binder.addGamepadActionBinding(CONTROL_MTRACKPAD, GamepadControls.TRACKPAD);
			binder.addGamepadActionBinding(CONTROL_MSHARE,    GamepadControls.SHARE);

			// Events
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			stage.addEventListener(Event.ACTIVATE, onActivate);
			stage.addEventListener(Event.DEACTIVATE, onDeactivate);

			logText("Manufacturer: [" + Capabilities.manufacturer + "]");
			logText("OS: [" + Capabilities.os + "]");
			logText("Version: [" + Capabilities.version + "]");
			logText("Player type: [" + Capabilities.playerType + "]");
			logText("GameInput.isSupported: [" + GameInput.isSupported + "]");
			logText("");
			logText("KeyActionBinderPlatform(s): [" + binder.getPlatformTypes() + "]");
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
