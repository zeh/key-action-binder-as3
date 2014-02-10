package com.zehfernando.keyactionbindertester.application {
	import com.zehfernando.display.templates.application.SimpleApplication;
	import com.zehfernando.input.binding.KeyActionBinder;
	import com.zehfernando.keyactionbindertester.display.Main;
	import com.zehfernando.utils.console.log;
	/**
	 * @author zeh fernando
	 */
	public class KeyActionBinderTester extends SimpleApplication {

		// Instances
		private var main:Main;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function KeyActionBinderTester() {
			// Anything that uses GameInput must be started on the first "frame" of the application
			KeyActionBinder.init(stage);

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
