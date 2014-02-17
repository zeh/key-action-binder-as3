package com.zehfernando.keyactionbindertester.display.gamepad {
	import com.zehfernando.display.components.text.TextSprite;
	import com.zehfernando.display.components.text.TextSpriteAlign;
	import com.zehfernando.utils.MathUtils;

	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;

	/**
	 * @author zeh fernando
	 */
	public class GamepadView extends Sprite {

		// A view that shows the current state of a gamepad. Controlled externally.

		// Constants
		public static const LAYOUT_SYMMETRIC:String = "symmetric";			// Symetric sticks (PS3, PS4)
		public static const LAYOUT_ASYMMETRIC:String = "asymmetric";		// Asymmetric sticks (XBox 360, OUYA)
		public static const LAYOUT_UNKNOWN:String = "unknown";				// Unknown (defaults to asymmetric)

		public static const WIDTH:Number = 210;								// Template width
		public static const HEIGHT:Number = 130;							// Template height

		// Original sizes
		//private static const WIDTH:Number = 196.85;						// Template width
		//private static const HEIGHT:Number = 114.371;						// Template height

		// Properties
		private var _width:Number;
		private var _height:Number;
		private var _scale:Number;

		// Instances
		private var container:Sprite;
		private var shapeView:Sprite;
		private var textName:TextSprite;

		public var buttonLB:RectButtonView;
		public var buttonRB:RectButtonView;
		public var buttonLT:RectButtonView;
		public var buttonRT:RectButtonView;
		public var buttonDU:RectButtonView;
		public var buttonDD:RectButtonView;
		public var buttonDL:RectButtonView;
		public var buttonDR:RectButtonView;
		public var buttonSL:StickButtonView;
		public var buttonSR:StickButtonView;
		public var buttonAU:CircleButtonView;
		public var buttonAD:CircleButtonView;
		public var buttonAL:CircleButtonView;
		public var buttonAR:CircleButtonView;
		public var buttonMSelect:RectButtonView;
		public var buttonMStart:RectButtonView;
		public var buttonMMenu:RectButtonView;
		public var buttonMOptions:RectButtonView;
		public var buttonMShare:RectButtonView;
		public var buttonMTrackpad:RectButtonView;
		public var buttonMBack:RectButtonView;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GamepadView(__layout:String, __name:String) {
			// Sets properties
			_scale = 1;
			_width = WIDTH;
			_height = HEIGHT;

			// Creates all needed assets

			// Button dimensions
			var bw:Number = Math.round(_width * 0.075);
			var bh:Number = Math.round(_width * 0.075);
			var br:Number = Math.round(_width * 0.045);
			var bs:Number = 1.5;

			var bgColor:uint = 0x000000;
			var flColor:uint = 0x00ff00;
			var stColor:uint = 0xffffff;

			var controlsOutsideX:Number = _width * 0.2;
			var controlsInsideX:Number = _width * 0.35;

			var controlsAboveY:Number = _height * 0.4;
			var controlsBelowY:Number = _height * 0.7;

			// Layout-based values
			var dialPadX:Number = controlsInsideX;
			var dialPadY:Number = controlsBelowY;
			var stickLeftX:Number = controlsOutsideX;
			var stickLeftY:Number = controlsAboveY;

			if (__layout == LAYOUT_SYMMETRIC) {
				dialPadX = controlsOutsideX;
				dialPadY = controlsAboveY;
				stickLeftX = controlsInsideX;
				stickLeftY = controlsBelowY;
			}

			// Main holder
			container = new Sprite();
			addChild(container);

			// Background
			shapeView = new Sprite();
			shapeView.graphics.beginFill(0xeeeeee, 1);
			shapeView.graphics.moveTo(98.425, 0);
			shapeView.graphics.cubicCurveTo(2.361,0,0,40.157,0,66.142);
			shapeView.graphics.cubicCurveTo(0,115.11,47.396,129.11,58.026,97.378);
			shapeView.graphics.cubicCurveTo(64.249,78.8,82.563,72.11,98.425,72.11);
			shapeView.graphics.cubicCurveTo(114.287,72.11,132.601,78.8,138.824,97.378);
			shapeView.graphics.cubicCurveTo(149.454,129.11,196.850,115.11,196.85,66.142);
			shapeView.graphics.cubicCurveTo(196.85,40.157,194.488,0,98.425,0);
			shapeView.graphics.endFill();
			shapeView.width = _width;
			shapeView.height = _height;
			shapeView.filters = [new BevelFilter(8, 90, 0xffffff, 1, 0x000000, 0.1, 8, 8, 1, 2), new GlowFilter(0x000000, 1, 8, 8, 20, 1)];
			container.addChild(shapeView);

			// Controls
			buttonLT = new RectButtonView(bw, bh * 2, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor);
			buttonLT.x = _width * 0.2 - buttonLT.width * 0.5;
			buttonLT.y = 0 - buttonLT.height;
			container.addChild(buttonLT);

			buttonLB = new RectButtonView(bw * 2, bh, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor);
			buttonLB.x = _width * 0.2 - buttonLB.width * 0.5;
			buttonLB.y = 0;
			container.addChild(buttonLB);

			buttonRT = new RectButtonView(bw, bh * 2, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor);
			buttonRT.x = _width * 0.8 - buttonRT.width * 0.5;
			buttonRT.y = 0 - buttonRT.height;
			container.addChild(buttonRT);

			buttonRB = new RectButtonView(bw * 2, bh, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor);
			buttonRB.x = _width * 0.8 - buttonRB.width * 0.5;
			buttonRB.y = 0;
			container.addChild(buttonRB);

			buttonDU = new RectButtonView(bw, bh, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor);
			buttonDU.x = dialPadX - buttonDU.width * 0.5;
			buttonDU.y = dialPadY - buttonDU.height * 1.5;
			container.addChild(buttonDU);

			buttonDD = new RectButtonView(bw, bh, RectButtonView.ALIGN_TOP, bs, bgColor, flColor, stColor);
			buttonDD.x = dialPadX - buttonDD.width * 0.5;
			buttonDD.y = dialPadY + buttonDD.height * 0.5;
			container.addChild(buttonDD);

			buttonDL = new RectButtonView(bw, bh, RectButtonView.ALIGN_RIGHT, bs, bgColor, flColor, stColor);
			buttonDL.x = dialPadX - buttonDL.width * 1.5;
			buttonDL.y = dialPadY - buttonDL.height * 0.5;
			container.addChild(buttonDL);

			buttonDR = new RectButtonView(bw, bh, RectButtonView.ALIGN_LEFT, bs, bgColor, flColor, stColor);
			buttonDR.x = dialPadX + buttonDR.width * 0.5;
			buttonDR.y = dialPadY - buttonDR.height * 0.5;
			container.addChild(buttonDR);

			buttonSL = new StickButtonView(br * 2.5, bs, bgColor, flColor, stColor);
			buttonSL.x = stickLeftX;
			buttonSL.y = stickLeftY;
			container.addChild(buttonSL);

			buttonSR = new StickButtonView(br * 2.5, bs, bgColor, flColor, stColor);
			buttonSR.x = _width * 0.65;
			buttonSR.y = _height * 0.7;
			container.addChild(buttonSR);

			buttonAU = new CircleButtonView(br, bs, bgColor, flColor, stColor);
			buttonAU.x = _width * 0.8;
			buttonAU.y = _height * 0.4 - br * 1.75;
			container.addChild(buttonAU);

			buttonAD = new CircleButtonView(br, bs, bgColor, flColor, stColor);
			buttonAD.x = _width * 0.8;
			buttonAD.y = _height * 0.4 + br * 1.75;
			container.addChild(buttonAD);

			buttonAL = new CircleButtonView(br, bs, bgColor, flColor, stColor);
			buttonAL.x = _width * 0.8 - br * 1.75;
			buttonAL.y = _height * 0.4;
			container.addChild(buttonAL);

			buttonAR = new CircleButtonView(br, bs, bgColor, flColor, stColor);
			buttonAR.x = _width * 0.8 + br * 1.75;
			buttonAR.y = _height * 0.4;
			container.addChild(buttonAR);

			var minPos:Number = _width * 0.1;
			var maxPos:Number = _width * 0.9;
			var lastButton:int = 5;

			buttonMSelect = new RectButtonView(bw, bh, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor, "SELECT");
			buttonMSelect.x = MathUtils.map(0, 0, lastButton, minPos, maxPos) - buttonMSelect.width * 0.5;
			buttonMSelect.y = _height;
			container.addChild(buttonMSelect);

			buttonMStart = new RectButtonView(bw, bh, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor, "START");
			buttonMStart.x = MathUtils.map(1, 0, lastButton, minPos, maxPos) - buttonMStart.width * 0.5;
			buttonMStart.y = _height;
			container.addChild(buttonMStart);

			buttonMBack = new RectButtonView(bw, bh, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor, "BACK");
			buttonMBack.x = MathUtils.map(2, 0, lastButton, minPos, maxPos) - buttonMBack.width * 0.5;
			buttonMBack.y = _height;
			container.addChild(buttonMBack);

			buttonMMenu = new RectButtonView(bw, bh, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor, "MENU");
			buttonMMenu.x = MathUtils.map(3, 0, lastButton, minPos, maxPos) - buttonMMenu.width * 0.5;
			buttonMMenu.y = _height;
			container.addChild(buttonMMenu);

			buttonMOptions = new RectButtonView(bw, bh, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor, "OPTIONS");
			buttonMOptions.x = MathUtils.map(4, 0, lastButton, minPos, maxPos) - buttonMOptions.width * 0.5;
			buttonMOptions.y = _height;
			container.addChild(buttonMOptions);

			buttonMShare = new RectButtonView(bw, bh, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor, "SHARE");
			buttonMShare.x = MathUtils.map(5, 0, lastButton, minPos, maxPos) - buttonMShare.width * 0.5;
			buttonMShare.y = _height;
			container.addChild(buttonMShare);

			buttonMTrackpad = new RectButtonView(bw * 3, bh * 2, RectButtonView.ALIGN_BOTTOM, bs, bgColor, flColor, stColor);
			buttonMTrackpad.x = _width * 0.5 - buttonMTrackpad.width * 0.5;
			buttonMTrackpad.y = _height * 0.1;
			container.addChild(buttonMTrackpad);

			// Name
			textName = new TextSprite("_sans", 8, 0x000000, 0.5);
			textName.text = __name;
			textName.embeddedFonts = false;
			textName.align = TextSpriteAlign.CENTER;
			textName.width = _width * 0.6;
			textName.leading = 2;
			textName.x = _width * 0.5 - textName.width * 0.5;
			textName.y = 0 - textName.height - 4;
			container.addChild(textName);

			// End
			applyScale();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function applyScale():void {
			container.scaleX = container.scaleY = _scale;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return _width * _scale;
		}

		override public function set width(__value:Number):void {
			// Ignored
		}

		override public function get height():Number {
			return _height * _scale;
		}

		override public function set height(__value:Number):void {
			// Ignored
		}

		public function get scale():Number {
			return _scale;
		}
		public function set scale(__value:Number):void {
			if (_scale != __value) {
				_scale = __value;
				applyScale();
			}
		}
	}
}
