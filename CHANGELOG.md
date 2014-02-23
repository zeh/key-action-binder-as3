# Changelog

Below is a list of all significant changes done to KeyActionBinder. Versions with links are assumed to be stable versions, and are [tagged in Git](https://github.com/zeh/key-action-binder/releases).

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
