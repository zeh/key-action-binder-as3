package com.zehfernando.bindermaker.display {
	import com.zehfernando.display.shapes.Circle;

	import flash.display.Sprite;

	/**
	 * @author zeh fernando
	 */
	public class HoldView extends Sprite {

		// Constants
		private static const RADIUS:Number = 40;

		// Properties
		private var _value:Number;

		// Instances
		private var outline:Circle;
		private var fill:Circle;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function HoldView() {
			_value = 0;

			outline = new Circle(RADIUS, 0x000000, RADIUS - 3);
			outline.alpha = 0.9;
			addChild(outline);

			fill = new Circle(RADIUS, 0xff4444);
			fill.alpha = 0.9;
			addChild(fill);

			redraw();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function redraw():void {
			fill.scaleX = fill.scaleY = value;
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get value():Number {
			return _value;
		}
		public function set value(__value:Number):void {
			if (_value != __value) {
				_value = __value;
				redraw();
			}
		}
	}
}
