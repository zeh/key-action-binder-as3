package com.zehfernando.keyactionbindertester.application {
	import com.zehfernando.input.binding.KeyActionBinder;
	import com.zehfernando.keyactionbindertester.display.Main;

	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	/**
	 * @author zeh fernando
	 */
	public class KeyActionBinderTester extends MovieClip {

		// Instances
		private var main:Main;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function KeyActionBinderTester() {
			super();

			// Initializations
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			// Anything that uses GameInput must be started on the first "frame" of the application
			KeyActionBinder.init(stage);

			// Create display
			main = new Main();
			main.width = stage.stageWidth;
			main.height = stage.stageHeight;
			addChild(main);
			main.init();

			// Create events
			stage.addEventListener(Event.RESIZE, onResize);
			onResize(null);
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onResize(__e:Event):void {
			trace("New size: " + stage.stageWidth + ", " + stage.stageHeight);
			main.width = stage.stageWidth;
			main.height = stage.stageHeight;
		}
	}
}
