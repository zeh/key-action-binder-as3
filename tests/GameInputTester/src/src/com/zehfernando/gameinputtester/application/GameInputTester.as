package com.zehfernando.gameinputtester.application {
	import com.zehfernando.display.templates.application.SimpleApplication;
	import com.zehfernando.gameinputtester.display.Main;
	import com.zehfernando.input.binding.KeyActionBinder;
	/**
	 * @author zeh fernando
	 */
	public class GameInputTester extends SimpleApplication {

		// Instances
		private var main:Main;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GameInputTester() {
			super();

			// Anything that uses GameInput must be started on the first "frame" of the application
			KeyActionBinder.init(stage);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function createVisualAssets():void {
			// Initiate the main sprite - all logic is somewhere else
			main = new Main();
			main.width = stage.stageWidth;
			main.height = stage.stageHeight;
			addChild(main);
			main.init();
		}

		override protected function redrawVisualAssets():void {
			main.width = stage.stageWidth;
			main.height = stage.stageHeight;
		}
	}
}
