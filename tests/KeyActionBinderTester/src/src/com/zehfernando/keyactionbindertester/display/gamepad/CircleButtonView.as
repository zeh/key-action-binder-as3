package com.zehfernando.keyactionbindertester.display.gamepad {
	import com.zehfernando.display.shapes.Circle;

	import flash.display.Sprite;

	/**
	 * @author zeh fernando
	 */
	public class CircleButtonView extends Sprite {

		// View for a round button

		// Properties
		private var radius:Number;

		// Instances
		private var backgroundView:Circle;
		private var strokeView:Circle;
		private var fillView:Circle;

		private var _value:Number;											// Activation value (0..1)
		private var _pressed:Boolean;										// Whether it's actually activated or not


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function CircleButtonView(__radius:Number, __strokeWidth:Number, __backgroundColor:uint, __fillColor:uint, __strokeColor:uint) {
			radius = __radius;
			_value = 0;
			_pressed = false;

			// Create assets
			backgroundView = new Circle(radius, __backgroundColor);
			addChild(backgroundView);

			fillView = new Circle(radius - __strokeWidth, __fillColor);
			addChild(fillView);

			strokeView = new Circle(radius - __strokeWidth, __strokeColor, radius - __strokeWidth * 2);
			addChild(strokeView);

			// End
			applyState();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function applyState():void {
			// Re-apply the current state
			fillView.scaleX = fillView.scaleY = _value;
			strokeView.alpha = _pressed ? 1 : 0.25;
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return radius * 2;
		}

		override public function set width(__value:Number):void {
			// Ignored
		}

		override public function get height():Number {
			return radius * 2;
		}

		override public function set height(__value:Number):void {
			// Ignored
		}

		public function get value():Number {
			return _value;
		}
		public function set value(__value:Number):void {
			if (_value != __value) {
				_value = __value;
				applyState();
			}
		}

		public function get pressed():Boolean {
			return _pressed;
		}
		public function set pressed(__value:Boolean):void {
			if (_pressed != __value) {
				_pressed = __value;
				applyState();
			}
		}
	}
}
