package com.zehfernando.display.components {

	import com.zehfernando.display.abstracts.ResizableSprite;
	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class HorizontalSlider extends ResizableSprite {

		// Instances
		protected var slider:Slider;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function HorizontalSlider(__wheelTarget:DisplayObject = null) {
			super();

			slider = new Slider(__wheelTarget);
			slider.addEventListener(Slider.EVENT_POSITION_CHANGED_BY_USER, onPositionChangedByUser, false, 0, true);
			addChild(slider);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			slider.width = _width;
		}

		override protected function redrawHeight():void {
			slider.height = _height;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onPositionChangedByUser(e:Event):void {
			dispatchEvent(new Event(Slider.EVENT_POSITION_CHANGED_BY_USER));
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Extensions of slider

		public function get pickerColor():int {
			return slider.pickerColor;
		}
		public function set pickerColor(__value:int):void {
			slider.pickerColor = __value;
		}

		public function get pickerAlpha():Number {
			return slider.pickerAlpha;
		}
		public function set pickerAlpha(__value:Number):void {
			slider.pickerAlpha = __value;
		}

		public function get pickerScale():Number {
			return slider.pickerScale;
		}
		public function set pickerScale(__value:Number):void {
			slider.pickerScale = __value;
		}

		public function get backgroundColor():int {
			return slider.backgroundColor;
		}
		public function set backgroundColor(__value:int):void {
			slider.backgroundColor = __value;
		}

		public function get backgroundAlpha():Number {
			return slider.backgroundAlpha;
		}
		public function set backgroundAlpha(__value:Number):void {
			slider.backgroundAlpha = __value;
		}

		public function get minPickerWidth():Number {
			return slider.minPickerSize;
		}
		public function set minPickerWidth(__value:Number):void {
			slider.minPickerSize = __value;
		}

		public function get maxPickerWidth():Number {
			return slider.maxPickerSize;
		}
		public function set maxPickerWidth(__value:Number):void {
			slider.maxPickerSize = __value;
		}

		public function get value():Number {
			return slider.value;
		}
		public function set value(__value:Number):void {
			slider.value = __value;
		}

		public function get minValue():Number {
			return slider.minValue;
		}
		public function set minValue(__value:Number):void {
			slider.minValue = __value;
		}

		public function get maxValue():Number {
			return slider.maxValue;
		}
		public function set maxValue(__value:Number):void {
			slider.maxValue = __value;
		}
	}
}
