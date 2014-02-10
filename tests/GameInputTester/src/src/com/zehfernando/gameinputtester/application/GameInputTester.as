package com.zehfernando.gameinputtester.application {
	import com.zehfernando.display.templates.application.SimpleApplication;
	import com.zehfernando.gameinputtester.display.Main;
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
