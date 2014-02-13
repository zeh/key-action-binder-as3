package com.zehfernando.gameinputtester.application {
	import com.zehfernando.gameinputtester.display.Main;

	import flash.display.MovieClip;
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
			main.width = stage.stageWidth;
			main.height = stage.stageHeight;
		}
	}
}
