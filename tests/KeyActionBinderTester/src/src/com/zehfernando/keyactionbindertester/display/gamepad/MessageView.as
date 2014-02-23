package com.zehfernando.keyactionbindertester.display.gamepad {
	import com.zehfernando.display.components.text.TextSprite;
	import com.zehfernando.display.components.text.TextSpriteAlign;
	import com.zehfernando.display.shapes.RoundedBox;

	import flash.display.Sprite;
	import flash.filters.GlowFilter;

	/**
	 * @author zeh fernando
	 */
	public class MessageView extends Sprite {

		// Instances
		private var backgroundView:RoundedBox;
		private var messageView:TextSprite;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function MessageView(__message:String) {
			var w:Number = GamepadView.WIDTH * 0.8;
			var h:Number = GamepadView.HEIGHT * 0.6;

			backgroundView = new RoundedBox(w, h, 0xdddddd);
			backgroundView.x = -w*0.5;
			backgroundView.y = -h*0.5;
			backgroundView.filters = [new GlowFilter(0x000000, 1, 2, 2, 2)];
			addChild(backgroundView);

			messageView = new TextSprite("_sans", 12, 0x000000, 1);
			messageView.text = __message;
			messageView.embeddedFonts = false;
			messageView.align = TextSpriteAlign.CENTER;
			messageView.width = w * 0.65;
			messageView.x = -messageView.width * 0.5;
			messageView.y = -messageView.height * 0.5;
			addChild(messageView);
		}
	}
}
