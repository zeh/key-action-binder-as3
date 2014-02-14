package com.zehfernando.keyactionbindertester.display {
	import com.zehfernando.display.components.text.TextSprite;
	import com.zehfernando.display.shapes.Box;
	import com.zehfernando.input.binding.GamepadControls;
	import com.zehfernando.input.binding.KeyActionBinder;
	import com.zehfernando.keyactionbindertester.display.gamepad.GamepadView;

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
		private var textDeviceState:TextSprite;			// Complete device state
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

		private var gamepadView:GamepadView;


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

			textDeviceState = new TextSprite("_sans", 12, 0x333333);
			textDeviceState.embeddedFonts = false;
			textDeviceState.leading = 2;
			addChild(textDeviceState);

			textLog = new TextSprite("_sans", 12, 0x333333);
			textLog.embeddedFonts = false;
			textLog.leading = 2;
			addChild(textLog);

			gamepadView = new GamepadView(GamepadView.LAYOUT_SYMMETRIC, "GamepadName"); // Update name
			addChild(gamepadView);

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);

			redrawWidth();
			redrawHeight();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function redrawWidth():void {
			textDeviceState.x = 0;
			textDeviceState.width = _width/2;
			textLog.x = textDeviceState.x + textDeviceState.width;
			textLog.width = _width/3;
			background.width = _width;
			redrawGamepad();
		}

		private function redrawHeight():void {
			textDeviceState.y = 2;
			textLog.y = 2;
			background.height = _height;
			redrawGamepad();
		}

		private function redrawGamepad():void {
			var margin:Number = 100;
			var desiredWidth:Number = _width - margin * 2;
			var desiredHeight:Number = _height - margin * 2;
			var s:Number;
			// Fit inside
			if (GamepadView.WIDTH / GamepadView.HEIGHT > desiredWidth / desiredHeight) {
				// Thinner than image, use width
				s = desiredWidth / GamepadView.WIDTH;
			} else {
				// Wider than image, use width
				s = desiredHeight / GamepadView.HEIGHT;
			}
			gamepadView.scale = s * 0.5;
			gamepadView.x = _width * 0.5 - gamepadView.width * 0.5;
			gamepadView.y = _height * 0.5 - gamepadView.height * 0.5;
		}

		private function logText(__text:String):void {
			textLogLines.push("[" + frame + "] " + __text);
			//textLogLines.push("[" + (getTimer()/1000).toFixed(3) + "s] " + __text);
			updateTextLog();
		}

		private function updateTextLog():void {
			if (textLogLines.length > 60) textLogLines.splice(0, textLogLines.length - 60);
			textLog.text = textLogLines.join("\n");
			textLog.y = _height - textLog.height;
		}

		private function updateTextDeviceState():void {
			// Update the device text log with the current state of all devices
			var text:String = "";
			var i:int;

			// Update state
//			for (i = 0; i < actionsToTrack.length; i++) {
//				text += "Action " + actionsToTrack[i] + ": " + binder.isActionActivated(ACTION_PREFIX + actionsToTrack[i]) + "\n";
//			}
//			text += "\n";
//			for (i = 0; i < valuesToTrack.length; i++) {
//				text += "Value " + valuesToTrack[i] + ": " + binder.getActionValue(VALUE_PREFIX + valuesToTrack[i]) + "\n";
//			}

			textDeviceState.text = text;
		}

		private function updateDeviceViewState():void {
			gamepadView.buttonLB.value   = binder.getActionValue(CONTROL_LB);
			gamepadView.buttonLB.pressed = binder.isActionActivated(CONTROL_LB);
			gamepadView.buttonRB.value   = binder.getActionValue(CONTROL_RB);
			gamepadView.buttonRB.pressed = binder.isActionActivated(CONTROL_RB);
			gamepadView.buttonLT.value   = binder.getActionValue(CONTROL_LT);
			gamepadView.buttonLT.pressed = binder.isActionActivated(CONTROL_LT);
			gamepadView.buttonRT.value   = binder.getActionValue(CONTROL_RT);
			gamepadView.buttonRT.pressed = binder.isActionActivated(CONTROL_RT);
			gamepadView.buttonDU.value   = binder.getActionValue(CONTROL_DU);
			gamepadView.buttonDU.pressed = binder.isActionActivated(CONTROL_DU);
			gamepadView.buttonDD.value   = binder.getActionValue(CONTROL_DD);
			gamepadView.buttonDD.pressed = binder.isActionActivated(CONTROL_DD);
			gamepadView.buttonDL.value   = binder.getActionValue(CONTROL_DL);
			gamepadView.buttonDL.pressed = binder.isActionActivated(CONTROL_DL);
			gamepadView.buttonDR.value   = binder.getActionValue(CONTROL_DR);
			gamepadView.buttonDR.pressed = binder.isActionActivated(CONTROL_DR);
			gamepadView.buttonAU.value   = binder.getActionValue(CONTROL_AU);
			gamepadView.buttonAU.pressed = binder.isActionActivated(CONTROL_AU);
			gamepadView.buttonAD.value   = binder.getActionValue(CONTROL_AD);
			gamepadView.buttonAD.pressed = binder.isActionActivated(CONTROL_AD);
			gamepadView.buttonAL.value   = binder.getActionValue(CONTROL_AL);
			gamepadView.buttonAL.pressed = binder.isActionActivated(CONTROL_AL);
			gamepadView.buttonAR.value   = binder.getActionValue(CONTROL_AR);
			gamepadView.buttonAR.pressed = binder.isActionActivated(CONTROL_AR);
			gamepadView.buttonSL.valueX         = binder.getActionValue(CONTROL_SL_X);
			gamepadView.buttonSL.valueY         = binder.getActionValue(CONTROL_SL_Y);
			gamepadView.buttonSL.value          = binder.getActionValue(CONTROL_SL_V);
			gamepadView.buttonSL.pressed        = binder.isActionActivated(CONTROL_SL_V);
			gamepadView.buttonSR.valueX         = binder.getActionValue(CONTROL_SR_X);
			gamepadView.buttonSR.valueY         = binder.getActionValue(CONTROL_SR_Y);
			gamepadView.buttonSR.value          = binder.getActionValue(CONTROL_SR_V);
			gamepadView.buttonSR.pressed        = binder.isActionActivated(CONTROL_SR_V);
			gamepadView.buttonMSelect.value     = binder.getActionValue(CONTROL_MSELECT);
			gamepadView.buttonMSelect.pressed   = binder.isActionActivated(CONTROL_MSELECT);
			gamepadView.buttonMBack.value       = binder.getActionValue(CONTROL_MBACK);
			gamepadView.buttonMBack.pressed     = binder.isActionActivated(CONTROL_MBACK);
			gamepadView.buttonMStart.value      = binder.getActionValue(CONTROL_MSTART);
			gamepadView.buttonMStart.pressed    = binder.isActionActivated(CONTROL_MSTART);
			gamepadView.buttonMMenu.value       = binder.getActionValue(CONTROL_MMENU);
			gamepadView.buttonMMenu.pressed     = binder.isActionActivated(CONTROL_MMENU);
			gamepadView.buttonMOptions.value    = binder.getActionValue(CONTROL_MOPTIONS);
			gamepadView.buttonMOptions.pressed  = binder.isActionActivated(CONTROL_MOPTIONS);
			gamepadView.buttonMTrackpad.value   = binder.getActionValue(CONTROL_MTRACKPAD);
			gamepadView.buttonMTrackpad.pressed = binder.isActionActivated(CONTROL_MTRACKPAD);
			gamepadView.buttonMShare.value      = binder.getActionValue(CONTROL_MSHARE);
			gamepadView.buttonMShare.pressed    = binder.isActionActivated(CONTROL_MSHARE);
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
			updateDeviceViewState();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function init():void {
			var i:int;

			binder = new KeyActionBinder();

			// Track actions
//			for (i = 0; i < actionsToTrack.length; i++) {
//				binder.addGamepadActionBinding(ACTION_PREFIX + actionsToTrack[i], actionsToTrack[i]);
//			}
//
//			// Track values
//			for (i = 0; i < valuesToTrack.length; i++) {
//				binder.addGamepadSensitiveActionBinding(VALUE_PREFIX + valuesToTrack[i], valuesToTrack[i]);
//			}

			// Create bindings for the controller
			// Normally this would be your own actions (e.g. "jump"), but in this case we just want to track buttons themselves
			binder.addGamepadSensitiveActionBinding(CONTROL_LB,        GamepadControls.LB);
			binder.addGamepadSensitiveActionBinding(CONTROL_RB,        GamepadControls.RB);
			binder.addGamepadSensitiveActionBinding(CONTROL_LT,        GamepadControls.LT);
			binder.addGamepadSensitiveActionBinding(CONTROL_RT,        GamepadControls.RT);
			binder.addGamepadSensitiveActionBinding(CONTROL_DU,        GamepadControls.DPAD_UP);
			binder.addGamepadSensitiveActionBinding(CONTROL_DD,        GamepadControls.DPAD_DOWN);
			binder.addGamepadSensitiveActionBinding(CONTROL_DL,        GamepadControls.DPAD_LEFT);
			binder.addGamepadSensitiveActionBinding(CONTROL_DR,        GamepadControls.DPAD_RIGHT);
			binder.addGamepadSensitiveActionBinding(CONTROL_AU,        GamepadControls.ACTION_UP);
			binder.addGamepadSensitiveActionBinding(CONTROL_AD,        GamepadControls.ACTION_DOWN);
			binder.addGamepadSensitiveActionBinding(CONTROL_AL,        GamepadControls.ACTION_LEFT);
			binder.addGamepadSensitiveActionBinding(CONTROL_AR,        GamepadControls.ACTION_RIGHT);
			binder.addGamepadSensitiveActionBinding(CONTROL_SL_X,      GamepadControls.STICK_LEFT_X);
			binder.addGamepadSensitiveActionBinding(CONTROL_SL_Y,      GamepadControls.STICK_LEFT_Y);
			binder.addGamepadSensitiveActionBinding(CONTROL_SL_V,      GamepadControls.STICK_LEFT_PRESS);
			binder.addGamepadSensitiveActionBinding(CONTROL_SR_X,      GamepadControls.STICK_RIGHT_X);
			binder.addGamepadSensitiveActionBinding(CONTROL_SR_Y,      GamepadControls.STICK_RIGHT_Y);
			binder.addGamepadSensitiveActionBinding(CONTROL_SR_V,      GamepadControls.STICK_RIGHT_PRESS);
			binder.addGamepadSensitiveActionBinding(CONTROL_MSELECT,   GamepadControls.SELECT);
			binder.addGamepadSensitiveActionBinding(CONTROL_MBACK,     GamepadControls.BACK);
			binder.addGamepadSensitiveActionBinding(CONTROL_MSTART,    GamepadControls.START);
			binder.addGamepadSensitiveActionBinding(CONTROL_MMENU,     GamepadControls.MENU);
			binder.addGamepadSensitiveActionBinding(CONTROL_MOPTIONS,  GamepadControls.OPTIONS);
			binder.addGamepadSensitiveActionBinding(CONTROL_MTRACKPAD, GamepadControls.TRACKPAD);
			binder.addGamepadSensitiveActionBinding(CONTROL_MSHARE,    GamepadControls.SHARE);

			// Events
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			stage.addEventListener(Event.ACTIVATE, onActivate);
			stage.addEventListener(Event.DEACTIVATE, onDeactivate);

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
