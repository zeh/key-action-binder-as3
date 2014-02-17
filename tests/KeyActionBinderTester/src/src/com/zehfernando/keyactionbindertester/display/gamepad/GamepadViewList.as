package com.zehfernando.keyactionbindertester.display.gamepad {
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author zeh fernando
	 */
	public class GamepadViewList extends Sprite {

		// A configurable list of GamepadViews

		// Properties
		private var _width:Number;
		private var _height:Number;

		// Instances
		private var gamepads:Vector.<GamepadView>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GamepadViewList() {
			_width = 100;
			_height = 100;

			gamepads = new Vector.<GamepadView>();

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);

			redrawGamepads();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function redrawGamepads():void {
			var margin:Number = 60;
			var gutter:Number = 50;
			var desiredWidth:Number = (_width - margin * 2 - (gamepads.length-1) * gutter) / gamepads.length;
			var desiredHeight:Number = _height - margin * 2;

			// Find scale to fit inside
			var s:Number;
			if (GamepadView.WIDTH / GamepadView.HEIGHT > desiredWidth / desiredHeight) {
				// Thinner than image, use width
				s = desiredWidth / GamepadView.WIDTH;
			} else {
				// Wider than image, use width
				s = desiredHeight / GamepadView.HEIGHT;
			}

			for (var i:int = 0; i < gamepads.length; i++) {
				gamepads[i].scale = s * 0.75;
				gamepads[i].x = margin + (desiredWidth + gutter) * i + desiredWidth * 0.5 - gamepads[i].width * 0.5;
				gamepads[i].y = margin + desiredHeight * 0.5 - gamepads[i].height * 0.5;
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onAddedToStage(__e:Event):void {
			redrawGamepads();
		}

		private function onRemovedFromStage(__e:Event):void {
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function addGamepad(__name:String, __type:String, __id:String):void {
			var isSymmetric:Boolean = __type.indexOf("ps3") > -1 || __type.indexOf("ps4") > -1;
			var gamepad:GamepadView = new GamepadView(isSymmetric ? GamepadView.LAYOUT_SYMMETRIC : GamepadView.LAYOUT_ASYMMETRIC, __name + "\n" + __type + "\n" + __id); // Update name
			addChild(gamepad);
			gamepads.push(gamepad);
			redrawGamepads();
		}

		public function removeAllGamepads():void {
			while (gamepads.length > 0) {
				removeChild(gamepads[0]);
				gamepads.splice(0, 1);
			}
		}

		public function getGamepadAt(__index:int):GamepadView {
			return gamepads[__index];
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return _width;
		}
		override public function set width(__value:Number):void {
			if (_width != __value) {
				_width = __value;
				redrawGamepads();
			}
		}

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			if (_height != __value) {
				_height = __value;
				redrawGamepads();
			}
		}
	}
}
