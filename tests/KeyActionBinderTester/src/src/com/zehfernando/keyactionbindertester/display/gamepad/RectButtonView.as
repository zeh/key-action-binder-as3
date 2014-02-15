package com.zehfernando.keyactionbindertester.display.gamepad {
	import com.zehfernando.display.components.text.TextSprite;
	import com.zehfernando.display.components.text.TextSpriteAlign;
	import com.zehfernando.display.shapes.Box;

	import flash.display.Sprite;
	/**
	 * @author zeh fernando
	 */
	public class RectButtonView extends Sprite {

		// View for a rectangular button

		// Constants
		public static const ALIGN_TOP:String = "top";
		public static const ALIGN_BOTTOM:String = "bottom";
		public static const ALIGN_LEFT:String = "left";
		public static const ALIGN_RIGHT:String = "right";

		// Properties
		private var _width:Number;
		private var _height:Number;
		private var align:String;
		private var strokeWidth:Number;

		// Instances
		private var backgroundView:Box;
		private var strokeView:Box;
		private var fillView:Box;

		private var _value:Number;											// Activation value (0..1)
		private var _pressed:Boolean;										// Whether it's actually activated or not


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RectButtonView(__width:Number, __height:Number, __align:String, __strokeWidth:Number, __backgroundColor:uint, __fillColor:uint, __strokeColor:uint, __caption:String = "") {
			_width = __width;
			_height = __height;
			align = __align;
			strokeWidth = __strokeWidth;
			_value = 0;
			_pressed = false;

			// Create assets
			backgroundView = new Box(_width, _height, __backgroundColor);
			addChild(backgroundView);

			fillView = new Box(_width - strokeWidth * 2, _height - strokeWidth * 2, __fillColor);
			fillView.x = __strokeWidth;
			fillView.y = __strokeWidth;
			addChild(fillView);

			strokeView = new Box(_width - strokeWidth * 2, _height - strokeWidth * 2, __strokeColor, __strokeWidth);
			strokeView.x = __strokeWidth;
			strokeView.y = __strokeWidth;
			addChild(strokeView);

			if (__caption != null) {
				var textField:TextSprite = new TextSprite("_sans", 7, 0x000000, 0.5);
				textField.text = __caption;
				textField.embeddedFonts = false;
				textField.align = TextSpriteAlign.CENTER;
				textField.width = _width * 2;
				textField.x = _width * 0.5 - textField.width * 0.5;
				textField.y = _height + strokeWidth;
				addChild(textField);
			}

			// End
			applyState();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function applyState():void {
			// Re-apply the current state
			switch (align) {
				case ALIGN_TOP:
					fillView.height = _value * (_height - strokeWidth * 2);
					break;
				case ALIGN_BOTTOM:
					fillView.height = _value * (_height - strokeWidth * 2);
					fillView.y = _height - fillView.height - strokeWidth;
					break;
				case ALIGN_LEFT:
					fillView.width = _value * (_width - strokeWidth * 2);
					break;
				case ALIGN_RIGHT:
					fillView.width = _value * (_width - strokeWidth * 2);
					fillView.x = _width - fillView.width - strokeWidth;
					break;
			}
			strokeView.alpha = _pressed ? 1 : 0.25;
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return _width;
		}

		override public function set width(__value:Number):void {
			// Ignored
		}

		override public function get height():Number {
			return _height;
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
