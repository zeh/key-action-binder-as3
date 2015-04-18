# Changelog

Below is a list of all significant changes done to KeyActionBinder. Versions with links are assumed to be stable versions, and are [tagged in Git](https://github.com/zeh/key-action-binder/releases).

 * 2015-04-17 - 3.10.11 - Fewer magic numbers being used as parameters: using constants instead of -1 to mean "any" in methods
 * 2015-04-17 - 2.10.11 - Added the removeKeyboardActionBinding() & removeGamepadActionBinding() methods
 * 2015-04-17 - 2.9.11 - onRecentDevice() changed to onMostRecentDevice()
 * 2015-04-17 - 1.9.11 - SimpleSignal is simpler and safer
 * 2015-04-17 - 1.9.10 - Added the ability to get the most recent device via an onRecentDevice() signal
 * 2014-10-25 - 1.8.10 - Added/enabled support for XBox 360 controller on OSX (Plugin version of Flash Player)
 * 2014-10-25 - 1.8.9 - The `onActionValueChanged` events are also dispatched on keyboard up/down events
 * 2014-10-25 - 1.8.8 - Fixed propagation when stopped: avoid crash when `KeyActionBinder.stop()` called from action handler
 * 2014-03-25 - [1.8.7](http://github.com/zeh/key-action-binder/releases/tag/1.8.7) - Fixed keyboard-only support: no more crashes when no gamepads are present
 * 2014-02-23 - 1.8.6 - Fixed Keyboard input events when `null` controllers are present (when `maintainPlayerPositions` is set to `true`)
 * 2014-02-22 - [1.8.5](http://github.com/zeh/key-action-binder/releases/tag/1.8.5) - Added an option to maintain the "player" seat based on controller id (`maintainPlayerPositions`)
 * 2014-02-16 - 1.7.5 - Added support for device detection via signals (onDevicesChanged) and device info getters (getNumDevices(), getDeviceAt(), and getDeviceTypeAt())
 * 2014-02-16 - 1.6.5 - Removed distinction between "sensitive" and normal controls; everything is a sensitive control
 * 2014-02-16 - [1.5.5](http://github.com/zeh/key-action-binder/releases/tag/1.5.5) - When a device is not recognized, just fail with a trace() message rather than crash
 * 2014-02-14 - 1.5.4 - Controllers data now use an array of strings for filters
 * 2014-02-13 - 1.5.3 - Added support for SELECT meta control
 * 2014-02-09 - [1.5.2](http://github.com/zeh/key-action-binder/releases/tag/1.5.2) - Added support for "split" controls, where the same GameInput control fires two distinct buttons (e.g. XBox 360 dpads on OUYA)
 * 2014-01-12 - 1.4.2 - Added support for PS4 controller (and OPTIONS, SHARE and TRACKPAD meta controls)
 * 2014-01-12 - 1.4.1 - Moved gamepad data to an external JSON (cleaner maintenance)
 * 2013-10-12 - 1.3.1 - Added ability to inject game controls from keyboard events (used for some meta keys on some platforms)
 * 2013-10-12 - 1.2.1 - Added gamepad index filter support for isActionActivated() and getActionValue()
 * 2013-10-08 - 1.1.1 - Removed max/min from addGamepadSensitiveActionBinding() (always use hardcoded values)
 * 2013-10-08 - 1.1.0 - Completely revamped the control scheme by using "auto" controls for cross-platform operation
 * 2013-10-08 - 1.0.0 - First version to have a version number

Check [the commit history](https://github.com/zeh/key-action-binder/commits) for a more in-depth list of changes.

The list above also excludes additions of device mappings; check [the history for controllers.json](https://github.com/zeh/key-action-binder/commits/master/src/com/zehfernando/input/binding/controllers.json) for a list of changes and additions.

Please not that starting with 1.8.6, the versioning number system used by KeyActionBinder follows the [semantic versioning specification](http://semver.org/). This means that:

 * The MAJOR version number changes when there are incompatible API changes
 * The MINOR version number changes when new functionality is added in a backwards-compatible manner
 * The PATCH version number changes when backwards-compatible bug fixes are applied
