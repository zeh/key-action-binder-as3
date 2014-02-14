package com.zehfernando.gameinputtester.application {
	import com.zehfernando.gameinputtester.display.Main;

	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	/**
	 * @author zeh fernando
	 */
	public class GameInputTester extends MovieClip {

		// Instances
		private var main:Main;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GameInputTester() {
			super();

			// Initializations
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			// Initiate the main sprite - all logic is somewhere else
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
