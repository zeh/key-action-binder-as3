# Supported platforms/devices

Because KeyActionBinder tries to automatically support whatever platform and devices one is using, it depends on having code that targets each specific platform/device combination. These are the platforms currently supported, and their respective supported devices:

| Controller             | Win 7 (PL) | Win 7 (GP) | OSX (PL) | OSX (GP)   | OUYA  | Android |
|------------------------|:----------:|:----------:|:--------:|:----------:|:-----:|:-------:|
| XBox 360 controller    | **Y**      | **Y**      | **Y** ([E](http://forums.macrumors.com/showthread.php?p=17725790#post1772579))    | **Y** (\*1) | **Y** | -       |
| PlayStation 3 DS3      | **Y** (E)  | **Y** (E)  | **Y**    | **Y**      | **Y** | **Y**   |
| PlayStation 4 DS3      | **Y**      | **Y**      | **Y**    | **Y** (\*2) | **Y** | **Y**   |
| OUYA Native controller | -          | -          | -        | -          | **Y** | -       |
| [NeoFlex](http://neotronics.com.br/neo/produtos/pc/controle-neo-flex) ("USB Gamepad") | **Y** | Y? | N | N | N | N |
| Buffalo SNES ("USB,2-axis 8-button gamepad") | **Y** | **Y** | **Y** | **Y** | N | N |
| Logitech Gamepad F710  | N          | N          | Y?       | N          | N     | N       |
| Logitech Gamepad F310  | N          | N          | Y?       | N          | N     | N       |

Legend:
 * Y: Supported
 * N: Not supported (no mappings)
 * -: Not supported by the system, or Flash Player (not showing up at all on GameInput)
 * Y?: Maybe; needs to be tested or confirmed
 * (PL): Standard Flash Player plugin (Firefox, Safari), ActiveX (MSIE) or Adobe AIR player
 * (GP): Google Pepper Flash Player (Chrome)
 * (E): Not natively supported by the system, but work when using drivers that emulate other devices
 * (\*1): May not work every time (has been confirmed as working, but may have changed)
 * (\*2): D-pad is not working properly; Flash/driver problems?

Controllers that emulate other controllers (e.g. XBox 360 alternatives) should work as long as the original does.

To add:

 * All other platforms (Windows 8, Windows XP, ...)
 * Android: GameStick, NVIDIA Shield, MadCatz MOJO, GamePop, Green Throttle, ...

More platforms and devices will be added as their controls are tested and figured out. If you wish, you can test it yourself using [any of the demos](#testsdemos), or find the controls using the KeyActionBinder-independent GameInputTester app:

 * [Web-based GameInput tester](http://hosted.zehfernando.com/key-action-binder/game-input-tester/): use this to see if OS is supported by Flash at all, and which controls are reported (requires Flash Player)
 * [Android/OUYA GameInput APK](http://hosted.zehfernando.com/key-action-binder/game-input-tester/GameInputTester.apk)

If you can, consider [contributing to the project](CONTRIBUTE.md) by submitting your own mappings for review and implementation.

A pure AS3 source of the tester app can be found in [/tests/GameInputTester/src](https://github.com/zeh/key-action-binder/tree/master/tests/GameInputTester/src).
