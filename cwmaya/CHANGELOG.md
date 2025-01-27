## Version:0.0.1-rc.9 -- 27 Jan 2025

* Make the target descriptions clearer
* Change release types to take up less space.
* Clean up detail prose.

## Version:0.0.1-rc.8 -- 26 Jan 2025

* Modified detail.md to give sys-admin download instructions

## Version:0.0.1-rc.7 -- 26 Jan 2025

* This release makes changes to the cwapps integration by way of the skulk_pre_push script.
  * It removes the releasenotes entry.
  * It copies in the entire changelog file.
  * While adding an entry for the current version, it removes versions of the same release label if they exist.

## Version:0.0.1-rc.6 -- 26 Jan 2025

* Consolidate the circleci config to copy the cwapps repo on tagged releases

## Version:0.0.1-rc.5 -- 25 Jan 2025

* Changed cwapps CICD flow to use manifest file where possible

## Version:0.0.1-rc.4 -- 24 Jan 2025
* Fix bad import in reloader bug
* CircleCI now uses the pyproject.toml file for build dependencies
* Updated skulk version requirement
* Updated setup.py and requirements files
* Refactored desktop app integration:
* Desktop app now does upload normalization
* Desktop app now connects to desktop app from context manager to function
* Removed authentication and related properties for now
* Cleaned up unused functions and dead code
* Removed unnecessary UI buttons
* Documentation improvements

## Version 0.0.1-beta.29
* depend on storm 0.6.3

## Version 0.0.1-beta.27

* Make batch script self contained to avoid the need to escape quotes


## Version 0.0.1-beta.25

* Adds asset scraping for maya based tasks
* Send to composer checks token expiry and refetches from Conductor if neccessary.
* Send to composer always sends along the coredata so that Edit panels can have the correct projects and instance types.

## Version 0.0.1-beta.24

* View-in-vscode now finds the code command automatiically.
* Changes the commands attribute from an array of commands, to an array of arrays of args. Users specify every arg separately.
* Busywork default and scene updated for args
* Updates Busywork and Slinky scene files and default presets

## Version 0.0.1-beta.23

* Copied over presets and updates scenefile
* Use b64 encoded python script generator
* Don't reload unless env var present CWMAYA_RELOAD_FOR_DEVELOPMENT
* Fix missing token bug
* More concise warning for exuisting presets on plugin load


## Version 0.0.1-beta.22

* Adds better diagnostic display in workflow job index.
* Adds health check buttons.

## Version 0.0.1-beta.20

* Make the example project have a better name and add github actions to make it available for download in the releases folder.
* Adds the Maya bin path to the PATH in the clipboard script so that the result is ready to run in a terminal.
* No longer rely on storm fileRule because when it has not been set the stormdir token is misleading.

## Version 0.0.1-beta.18

* Adds workspace.mel to uploads
* Adds basic upload pack to renders, even though mostly not needed
* Adds a clipboard button for the commands widget
* Adds storm comp filerule and change the token name to stormdir
* Only print the automatic presets install warnings when not batch
* Refactor send coredata to desktop app

## Version 0.0.1-beta.17

* Now uses nodePreset mechanism to implement default configuration. developers can save presets, copy to repo, and then when customer loads plugin, the default presets, and any others we include, will be copied over to their local presets folder.

## Version 0.0.1-beta.15

* Implement script control to facilitate creation of maya batch commands
* Adds storm_remote module - makes resources available on the farm

## Version 0.0.1-beta.14

* Adds menu item to send real coredata to the desktop app

## Version 0.0.1-beta.13

* Adds semantic coordinates
* Only attempt to open desktop app if health check fails
* Change BC notification port - 8000 clashes with workflow api
* Bump storm requirement

## Version 0.0.1-beta.12 

* Adds a utility to show json in vscode
* Adds ability to export self contained submission to python file 
* Adds menu item to how account info
* make context less error prone, and display useful info if it fails due to bad token use
* adds an upload optimization algorithm to ensure each file is only specified once while minimizing the number of Upload nodes

## Version 0.0.1-beta.11

* Set up busywork tutorial and documentation

## Version 0.0.1-beta.10

* Bring the README up to date and add template authoring instructions

## Version 0.0.1-beta.9

* Reset dag node unique naming stack before each compute so that successive graphs start from 0
* On Send-to-Composer, we now automatically open the desktop app if it is not already open.
* Adds a presets section to the tools menu with load and save options.

## Version 0.0.1-beta.8
* Adds template for a test job to run several tasks one after the other, chained up.
* Massive refactor of the template system in order to make it easier to add 3rd party templates.
* The window now remembers the last loaded template
* Refactored to minimize inheritance and adopt a more composition-based approach
* Adds an oiption to save the spec to disk
* Flattened all menu items so its easier to find items quickly.
* Show json in vscode rather than in a window in Maya
* Adds a Namefield for easy name editing
* Adds an example project

## Version 0.0.1-beta.7
* Adds a mechanism to specify default template values
* Adds a context manager to do stuff in the context of a saved scene
* Adds a menu item to save the JSON payload to a file
* Adds a context manager to send stuff to desktop app in the context of a healthy authenticated session

## Version 0.0.1-beta.6
* Adds a template for a SimRenderMovie graph
* Removed the AssExportKick graph template for now.

## Version 0.0.1-beta.4
* Retrieves actual Core Data entities from Conductor
* Reduces the amount of information broadcasted to Slack channels
* Includes the versions of ciocore and storm DSL  on PyPi
* Resolves software and environment in the compute function
* Refactors inheritance hierarchy as BaseTab to TaskTab to ConcreteTask implementations
* Adds UI components for managing u=inst types and software/plugin relationships 
* Relaxes the dependencies on the 'requests' library
* Adds an output path configuration option
* Adds window to visualize submission results
* Adds automatic hydration upon application start
* Integrates a smoke test preset node into the workflow
* Adds a user interface for managing extra assets

* 0.0.1-beta.2
* Initial import
