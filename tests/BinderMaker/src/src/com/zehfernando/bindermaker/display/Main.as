package com.zehfernando.bindermaker.display {
	import com.zehfernando.display.components.text.RichTextSprite;
	import com.zehfernando.display.components.text.TextSpriteAlign;
	import com.zehfernando.display.debug.QuickButton;
	import com.zehfernando.display.shapes.Box;
	import com.zehfernando.utils.MathUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.GameInputEvent;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	import flash.utils.getTimer;

	/**
	 * @author zeh fernando
	 */
	public class Main extends Sprite {

		// Constants
		private static const STATE_WAITING_FOR_GAMEPAD:String = "waitingForGamepad";
		private static const STATE_START:String = "waitingForStart";
		private static const STATE_READING_KEYS:String = "readingKeys";
		private static const STATE_FINISH:String = "finishing";

		private static const BUTTON_WIDTH:Number = 120;
		private static const BUTTON_HEIGHT:Number = 60;
		private static const BUTTON_MARGIN:Number = 20;

		private static const TIME_TO_WAIT_HOLD_OR_RELEASE:int = 200;				// In ms

		// Properties
		private var _width:Number;
		private var _height:Number;

		// Instances
		private var background:Box;
		private var textMessage:RichTextSprite;
		private var holdView:HoldView;

		private var gameInput:GameInput;

		private var targetGameInput:GameInputDevice;
		private var currentReadingStage:int;
		private var currentReadingTime:int;
		private var currentReadingWaitingForHold:Boolean;

		private var readingStages:Vector.<ReadingStageInfo>;

		private var currentInput:InputState;							// Current input state
		private var baseInput:InputState;								// Base input state
		private var currentHoldInput:InputState;						// Input state with button pressed or activated

		private var currentState:String;

		private var buttons:Vector.<QuickButton>;

		private var holdInputStates:Object;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Main() {
			super();

			_width = 100;
			_height = 100;

			// Create assets
			background = new Box(100, 100, 0xeeeeee);
			addChild(background);

			textMessage = new RichTextSprite("_sans", 20, 0x000000);
			textMessage.setStyle("em", "_sans", 30, 0x000000);
			textMessage.align = textMessage.blockAlignHorizontal = TextSpriteAlign.CENTER;
			textMessage.blockAlignVertical = TextSpriteAlign.BOTTOM;
			textMessage.embeddedFonts = false;
			textMessage.leading = 12;
			addChild(textMessage);

			holdView = new HoldView();
			addChild(holdView);

			// Setup all the bind reading data
			readingStages = new Vector.<ReadingStageInfo>();
			readingStages.push(new ReadingStageInfo("left_button",			ReadingStageInfo.ACTION_PRESS,	"Left shoulder button/L1"));
			readingStages.push(new ReadingStageInfo("left_trigger",			ReadingStageInfo.ACTION_PRESS,	"Left trigger button/L2"));
			readingStages.push(new ReadingStageInfo("right_button",			ReadingStageInfo.ACTION_PRESS,	"Right shoulder button/R1"));
			readingStages.push(new ReadingStageInfo("right_trigger",		ReadingStageInfo.ACTION_PRESS,	"Right trigger button/R2"));

			readingStages.push(new ReadingStageInfo("dpad_up",				ReadingStageInfo.ACTION_PRESS,	"Directional pad up"));
			readingStages.push(new ReadingStageInfo("dpad_down",			ReadingStageInfo.ACTION_PRESS,	"Directional pad down"));
			readingStages.push(new ReadingStageInfo("dpad_left",			ReadingStageInfo.ACTION_PRESS,	"Directional pad left"));
			readingStages.push(new ReadingStageInfo("dpad_right",			ReadingStageInfo.ACTION_PRESS,	"Directional pad right"));;

			readingStages.push(new ReadingStageInfo("action_up",			ReadingStageInfo.ACTION_PRESS,	"Action button up", 		"Y/Yellow on XBox, Triangle on PSX, Y on Ouya, etc"));
			readingStages.push(new ReadingStageInfo("action_down",			ReadingStageInfo.ACTION_PRESS,	"Action button down", 		"A/Green on XBox, Cross on PSX, O on Ouya, etc"));
			readingStages.push(new ReadingStageInfo("action_left",			ReadingStageInfo.ACTION_PRESS,	"Action button left", 		"X/Blue on XBox, Square on PSX, U on Ouya, etc"));
			readingStages.push(new ReadingStageInfo("action_right",			ReadingStageInfo.ACTION_PRESS,	"Action button right", 		"B/Red on XBox, Circle on PSX, A on Ouya, etc"));

			readingStages.push(new ReadingStageInfo("stick_left_x_left",	ReadingStageInfo.ACTION_MOVE,	"Left stick",				"left"));
			readingStages.push(new ReadingStageInfo("stick_left_x_right",	ReadingStageInfo.ACTION_MOVE,	"Left stick",				"right"));
			readingStages.push(new ReadingStageInfo("stick_left_y_up",		ReadingStageInfo.ACTION_MOVE,	"Left stick",				"up"));
			readingStages.push(new ReadingStageInfo("stick_left_y_down",	ReadingStageInfo.ACTION_MOVE,	"Left stick",				"down"));
			readingStages.push(new ReadingStageInfo("stick_left_press",		ReadingStageInfo.ACTION_PRESS,	"Left stick"));

			readingStages.push(new ReadingStageInfo("stick_right_x_left",	ReadingStageInfo.ACTION_MOVE,	"Right stick",				"left"));
			readingStages.push(new ReadingStageInfo("stick_right_x_right",	ReadingStageInfo.ACTION_MOVE,	"Right stick",				"right"));
			readingStages.push(new ReadingStageInfo("stick_right_y_up",		ReadingStageInfo.ACTION_MOVE,	"Right stick",				"up"));
			readingStages.push(new ReadingStageInfo("stick_right_y_down",	ReadingStageInfo.ACTION_MOVE,	"Right stick",				"down"));
			readingStages.push(new ReadingStageInfo("stick_right_press",	ReadingStageInfo.ACTION_PRESS,	"Right stick"));

			readingStages.push(new ReadingStageInfo("meta_back",			ReadingStageInfo.ACTION_PRESS,	"Back", 					"Tap \"skip\" if not available"));
			readingStages.push(new ReadingStageInfo("meta_select",			ReadingStageInfo.ACTION_PRESS,	"Select", 					"Tap \"skip\" if not available"));
			readingStages.push(new ReadingStageInfo("meta_start",			ReadingStageInfo.ACTION_PRESS,	"Start", 					"Tap \"skip\" if not available"));
			readingStages.push(new ReadingStageInfo("meta_menu",			ReadingStageInfo.ACTION_PRESS,	"Menu", 					"Tap \"skip\" if not available"));
			readingStages.push(new ReadingStageInfo("meta_options",			ReadingStageInfo.ACTION_PRESS,	"Options", 					"Tap \"skip\" if not available"));
			readingStages.push(new ReadingStageInfo("meta_trackpad",		ReadingStageInfo.ACTION_PRESS,	"Trackpad", 				"Tap \"skip\" if not available"));
			readingStages.push(new ReadingStageInfo("meta_share",			ReadingStageInfo.ACTION_PRESS,	"Share", 					"Tap \"skip\" if not available"));

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);

			redrawWidth();
			redrawHeight();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function redrawWidth():void {
			background.width = _width;
			textMessage.x = _width * 0.5;
			holdView.x = _width * 0.5;
			redrawButtons();
		}

		private  function redrawHeight():void {
			background.height = _height;
			textMessage.y = _height * 0.4;
			holdView.y = _height * 0.55;
			redrawButtons();
		}

		private function log(__text:String):void {
			trace(__text);
		}

		private function setTargetInput(__targetInput:GameInputDevice):void {
			resetTargetInput();

			var i:int;
			targetGameInput = __targetInput;
			targetGameInput.enabled = true;
			for (i = 0; i < targetGameInput.numControls; i++) {
				targetGameInput.getControlAt(i).addEventListener(Event.CHANGE, onGameInputControlChanged, false);
			}

		}

		private function resetTargetInput():void {
			// Remove events of existing gameinput device
			if (targetGameInput != null) {
				var i:int;
				for (i = 0; i < targetGameInput.numControls; i++) {
					targetGameInput.getControlAt(i).removeEventListener(Event.CHANGE, onGameInputControlChanged, false);
				}
				targetGameInput = null;
			}
		}

		private function setState(__state:String):void {
			// Set the step in the whole task
			currentState = __state;

			updateView();
		}

		private function setReadingStage(__stage:int):void {
			// Set the stepo in the reading stage
			currentReadingStage = __stage;
			currentReadingTime = getTimer();
			currentReadingWaitingForHold = true;
			holdView.value = 0;

			updateView();
		}

		private function updateView():void {
			// Update view based on the current stage

			var i:int;
			var iis:String;

			removeButtons();

			// Update the screen
			if (currentState == STATE_WAITING_FOR_GAMEPAD) {
				// Waiting for valid game input devices
				if (GameInput.numDevices == 0) {
					textMessage.text = "Waiting for one valid game input device\nCurrent devices: 0 []";
				} else if (GameInput.numDevices == 1 && GameInput.getDeviceAt(0) == null) {
					textMessage.text = "Waiting for one valid game input device\nCurrent devices: 1 [null]";
				} else if (GameInput.numDevices > 1) {
					var devices:Vector.<String> = new Vector.<String>();
					for (i = 0; i < GameInput.numDevices; i++) devices.push(GameInput.getDeviceAt(i) == null ? "null" : GameInput.getDeviceAt(i).name);
					textMessage.text = "Waiting for one valid game input device\nCurrent devices: " + devices.length + "[" + devices.join(",") + "]";
				} else if (GameInput.numDevices == 1 && GameInput.getDeviceAt(0) != null) {
					textMessage.text = "Valid device!\nCurrent devices: 1 [null]";
				}

				holdView.visible = false;
			} else if (currentState == STATE_START) {
				textMessage.text = "Device [" + targetGameInput.name + "]\nid: [" + targetGameInput.id + "]\n\nPlease leave all the gamepad buttons/sticks at rest and click/tap BEGIN";
				holdView.visible = false;

				addButton("BEGIN", function(__e:Event):void {
					currentInput.setAllGamepadValues(targetGameInput);
					holdInputStates = {};
					baseInput = currentInput.getSnapshot();

					setState(STATE_READING_KEYS);
					setReadingStage(0);
				});
			} else if (currentState == STATE_READING_KEYS) {
				// A normal state, starting
				holdView.visible = true;

				addButton("SKIP /\nNOT AVAILABLE", function(__e:Event):void {
					skipReadingStage();
				});
				addButton("RESTART", function(__e:Event):void {
					setState(STATE_START);
				});

				var currentStage:ReadingStageInfo = readingStages[currentReadingStage];

				if (currentReadingWaitingForHold) {
					// Waiting for button to be pressed
					if (currentStage.action == ReadingStageInfo.ACTION_PRESS) {
						textMessage.text = "Please press and hold the button\n<em>" + currentStage.name.toUpperCase() + "</em>" + (currentStage.description.length > 0 ? "\n("+currentStage.description+")" : "");
					} else if (currentStage.action == ReadingStageInfo.ACTION_MOVE) {
						textMessage.text = "Please move the\n<em>" + currentStage.name.toUpperCase() + "</em> all the way <em>" + currentStage.description.toUpperCase() + "</em>\nand hold it there";
					}
				} else {
					// Waiting for button to be released
					textMessage.text = "Please release all buttons";
				}
			} else if (currentState == STATE_FINISH) {
				textMessage.text = "Finished!";
				holdView.visible = true;

				// Create list of items (in an array to enforce order)
				var report:Vector.<Object> = new Vector.<Object>();

				// Basic data
				report.push({"Capabilities.manufacturer"		: Capabilities.manufacturer});
				report.push({"Capabilities.os"					: Capabilities.os});
				report.push({"Capabilities.version"				: Capabilities.version});
				report.push({"Capabilities.playerType"			: Capabilities.playerType});
				report.push({"Capabilities.pixelAspectRatio"	: Capabilities.pixelAspectRatio});
				report.push({"Capabilities.screenColor"			: Capabilities.screenColor});
				report.push({"Capabilities.screenDPI"			: Capabilities.screenDPI});
				report.push({"Capabilities.touchscreenType"		: Capabilities.touchscreenType});

				// GameInput data
				report.push({"GameInputDevice.name"				: targetGameInput.name});
				report.push({"GameInputDevice.id"				: targetGameInput.id});

				var obj:Object;
				for (iis in holdInputStates) {
					obj = {};
					obj[iis] = baseInput.getSignificantDifferencesAsString(holdInputStates[iis]);
					report.push(obj);
				}

				log("REPORT:");
				for (i = 0; i < report.length; i++) {
					for (iis in report[i]) {
						log(iis + " : '" + report[i][iis] + "'");
					}
				}

			} else {
				log ("Unknown state!");
				textMessage.text = "Unknown state!";
			}
		}

		private function skipReadingStage():void {
			// Skips the current reading stage
			captureSnapshotForCurrentReadingStage(true);
			nextReadingStage();
		}

		private function nextReadingStage():void {
			if (currentReadingStage < readingStages.length - 1) {
				setReadingStage(currentReadingStage+1);
			} else {
				setState(STATE_FINISH);
			}
		}

		private function addButton(__caption:String, __callback:Function):void {
			var button:QuickButton = new QuickButton(__caption, 0, 0, __callback, BUTTON_WIDTH, BUTTON_HEIGHT);
			addChild(button);
			buttons.push(button);
			redrawButtons();
		}

		private function redrawButtons():void {
			if (buttons != null && buttons.length > 0) {
				var pos:Number = Math.round(_width * 0.5 - (BUTTON_WIDTH * buttons.length + BUTTON_MARGIN * (buttons.length - 1)) * 0.5);

				for (var i:int = 0; i < buttons.length; i++) {
					buttons[i].x = pos;
					buttons[i].y = Math.round(_height * 0.7);
					pos += BUTTON_WIDTH;
					pos += BUTTON_MARGIN;
				}
			}
		}

		private function removeButtons():void {
			while (buttons.length > 0) {
				removeChild(buttons[0]);
				buttons.splice(0, 1);
			}
		}

		private function captureSnapshotForCurrentReadingStage(__useNull:Boolean = false):void {
			holdInputStates[readingStages[currentReadingStage].id] = __useNull ? null : currentInput.getSnapshot();
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
//			log("Pressed key code: [" + __e.keyCode + "] location: [" + __e.keyLocation + "]");
			if (currentInput != null) currentInput.setKeyboardValue(__e.keyCode, __e.keyLocation, true);
			__e.preventDefault();
		}

		private function onKeyUp(__e:KeyboardEvent):void {
//			log("Released key code: [" + __e.keyCode + "] location: [" + __e.keyLocation + "]");
			if (currentInput != null) currentInput.setKeyboardValue(__e.keyCode, __e.keyLocation, false);
			__e.preventDefault();
		}

		private function onGameInputControlChanged(__e:Event):void {
			var control:GameInputControl = __e.target as GameInputControl;
			if (currentInput != null) currentInput.setGamepadValue(control.id, control.value, control.minValue, control.maxValue);
			log("Changed value of control [" + control.id + "] to " + control.value.toFixed(3));
		}

		private function onDevicesChanged(__e:Event):void {
			log("Devices changed");

			if (GameInput.numDevices == 1 && GameInput.getDeviceAt(0) != null) {
				// One device
				if (targetGameInput != GameInput.getDeviceAt(0)) {
					// Changed the current device
					setTargetInput(GameInput.getDeviceAt(0));
					setState(STATE_START);
				}
			} else {
				// Too many or too few game devices
				resetTargetInput();
				setState(STATE_WAITING_FOR_GAMEPAD);
			}
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
			var f:Number;

			if (currentState == Main.STATE_READING_KEYS) {
				if (currentReadingWaitingForHold) {
					// Waiting for a key to be pressed
					if (baseInput.isSignificantlyDifferent(currentInput)) {
						// The new one is different
						f = MathUtils.map(getTimer(), currentReadingTime, currentReadingTime + Main.TIME_TO_WAIT_HOLD_OR_RELEASE, 0, 1, true);
						if (f >= 1) {
							// Is different, switch to releasing
							captureSnapshotForCurrentReadingStage();
							currentReadingTime = getTimer();
							currentHoldInput = currentInput.getSnapshot();
							currentReadingWaitingForHold = false;
							updateView();
						} else {
							// Started being different
							holdView.value = f;
						}
					} else {
						// The new one is the same
						currentReadingTime = getTimer();
						holdView.value = 0;
					}
				} else {
					// Waiting for keys to be released
					if (currentHoldInput.isSignificantlyDifferent(currentInput)) {
						// The new one is different
						f = MathUtils.map(getTimer(), currentReadingTime, currentReadingTime + Main.TIME_TO_WAIT_HOLD_OR_RELEASE, 0, 1, true);
						if (f >= 1) {
							// Is different, go to the next
							nextReadingStage();
						} else {
							// Started being different
							holdView.value = 1-f;
						}
					} else {
						// The new one is the same
						currentReadingTime = getTimer();
						holdView.value = 1;
					}
				}
			}
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
			gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onDevicesChanged);
			gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onDevicesChanged);

			currentInput = new InputState();

			buttons = new Vector.<QuickButton>();

			redrawWidth();
			redrawHeight();

			log("Manufacturer: " + Capabilities.manufacturer);
			log("OS: " + Capabilities.os);
			log("Version: " + Capabilities.version);
			log("Player type = " + Capabilities.playerType);
			log("GameInput.isSupported = " + GameInput.isSupported);
			log("");

			setState(STATE_WAITING_FOR_GAMEPAD);
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


import flash.ui.GameInputDevice;
class ReadingStageInfo {
	/* Information about reading stages */

	public static const ACTION_PRESS:String = "press";
	public static const ACTION_MOVE:String = "move";

	public var id:String;
	public var action:String;
	public var name:String;
	public var description:String;

	public function ReadingStageInfo(__id:String, __action:String, __name:String, __description:String = "") {
		id = __id;
		action = __action;
		name = __name;
		description = __description;
	}
}

class InputState {
	/* A snapshot of the current state of all input controls */

	// Instances

	private var keyboardInputStates:Vector.<int>;				// Array of [code, location, ..] of keys that are on
	private var gameInputControlValues:Object;					// key = id; value = current value
	private var gameInputControlMinValues:Object;
	private var gameInputControlMaxValues:Object;


	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function InputState() {
		keyboardInputStates = new Vector.<int>();
		gameInputControlValues = {};
		gameInputControlMinValues = {};
		gameInputControlMaxValues = {};
	}


	// ================================================================================================================
	// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------


	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function setKeyboardValue(__keyCode:int, __keyLocation:int, __value:Boolean):void {
		if (__value) {
			// Add a value
			if (!getKeyboardValue(__keyCode, __keyLocation)) {
				// Not present, must add
				keyboardInputStates.push(__keyCode, __keyLocation);
			}
		} else {
			// Remove a value
			if (getKeyboardValue(__keyCode, __keyLocation)) {
				// Present, must remove
				for (var i:int = 0; i < keyboardInputStates.length; i += 2) {
					if (keyboardInputStates[i] == __keyCode && keyboardInputStates[i+1] == __keyLocation) {
						keyboardInputStates.splice(i, 2);
						return;
					}
				}
			}
		}
	}

	public function getKeyboardCodeAt(__index:int):int {
		return keyboardInputStates[__index * 2];
	}

	public function getKeyboardLocationAt(__index:int):int {
		return keyboardInputStates[__index * 2 + 1];
	}

	public function getKeyboardValue(__keyCode:int, __keyLocation:int):Boolean {
		for (var i:int = 0; i < keyboardInputStates.length; i++) {
			if (keyboardInputStates[i] == __keyCode && keyboardInputStates[i+1] == __keyLocation) return true;
		}
		return false;
	}

	public function setGamepadValue(__id:String, __value:Number, __min:Number, __max:Number):void {
		gameInputControlValues[__id] = __value;
		gameInputControlMinValues[__id] = __min;
		gameInputControlMaxValues[__id] = __max;
	}

	public function getGamepadValue(__id:String):Number {
		return gameInputControlValues[__id];
	}

	public function getGamepadMinValue(__id:String):Number {
		return gameInputControlMinValues[__id];
	}

	public function getGamepadMaxValue(__id:String):Number {
		return gameInputControlMaxValues[__id];
	}

	public function getGamepadMaxDifference(__id:String):Number {
		return Math.abs(gameInputControlMaxValues[__id] - gameInputControlMinValues[__id]);
	}

	public function setAllGamepadValues(__gameInputDevice:GameInputDevice):void {
		for (var i:int = 0; i < __gameInputDevice.numControls; i++) {
			gameInputControlValues[__gameInputDevice.getControlAt(i).id] = __gameInputDevice.getControlAt(i).value;
			gameInputControlMinValues[__gameInputDevice.getControlAt(i).id] = __gameInputDevice.getControlAt(i).minValue;
			gameInputControlMaxValues[__gameInputDevice.getControlAt(i).id] = __gameInputDevice.getControlAt(i).maxValue;
		}
	}

	public function getSnapshot():InputState {
		// Clones a InputState
		var inputState:InputState = new InputState();

		// Duplicate keyboard state
		for (var i:int = 0; i < keyboardInputStates.length; i += 2) {
			inputState.setKeyboardValue(keyboardInputStates[i], keyboardInputStates[i+1], true);
		}

		// Duplicate gamepad state
		for (var iis in gameInputControlValues) {
			inputState.setGamepadValue(iis, gameInputControlValues[iis], gameInputControlMinValues[iis], gameInputControlMaxValues[iis]);
		}

		return inputState;
	}

	public function isSignificantlyDifferent(__inputState:InputState):Boolean {
		// Check whether this InputState is significantly different than the passed InputState

		// Check keyboard
		if (getNumKeyboardValues() != __inputState.getNumKeyboardValues()) return true;

		for (var i:int = 0; i < keyboardInputStates.length; i += 2) {
			if (!__inputState.getKeyboardValue(keyboardInputStates[i], keyboardInputStates[i+1])) return true;
		}

		// Check gamepad state
		for (var iis:String in gameInputControlValues) {
			if (Math.abs(gameInputControlValues[iis] - __inputState.getGamepadValue(iis)) > 0.25 * getGamepadMaxDifference(iis)) return true;
		}

		// About the same
		return false;
	}

	public function getNumKeyboardValues():int {
		return keyboardInputStates.length / 2;
	}

	public function getSignificantDifferencesAsString(__inputState:InputState):String {
		// Create a report of all differences between the two input states (using this as the base)

		if (__inputState == null) return "-";

		var reportItems:Vector.<String> = new Vector.<String>();
		var i:int;

		// Check keyboard DEACTIVATED
		for (i = 0; i < keyboardInputStates.length; i += 2) {
			if (!__inputState.getKeyboardValue(keyboardInputStates[i], keyboardInputStates[i+1])) {
				reportItems.push("{keyCode:" + keyboardInputStates[i] + ", keyLocation:" + keyboardInputStates[i+1] + ", value:false}");
			}
		}

		// Check keyboard ACTIVATED
		for (i = 0; i < __inputState.getNumKeyboardValues(); i++) {
			if (!getKeyboardValue(__inputState.getKeyboardCodeAt(i), __inputState.getKeyboardLocationAt(i))) {
				reportItems.push("{keyCode:" + keyboardInputStates[i] + ", keyLocation:" + keyboardInputStates[i+1] + ", value:true}");
			}
		}

		// Check gamepad state
		for (var iis:String in gameInputControlValues) {
			if (Math.abs(gameInputControlValues[iis] - __inputState.getGamepadValue(iis)) > 0.25 * getGamepadMaxDifference(iis)) {
				reportItems.push("{control:\"" + iis + "\", value:"+__inputState.getGamepadValue(iis)+", min:"+__inputState.getGamepadMinValue(iis) + ", max:"+__inputState.getGamepadMinValue(iis) + "}");
			}
		}
		return reportItems.join(", ");
	}
}