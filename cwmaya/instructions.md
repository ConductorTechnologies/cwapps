Congratulations! You're set to start submitting renders to Conductor from within Maya. Open Maya and load the Conductor plugin from the Plugin Manager. You should see a new menu called "Conductor" in the main menu bar. From there you can configure a submission.

### Notes for system administrators

#### Shared location
If you'd like to make the plugin accessible to others on your network, set the MAYA_MODULE_PATH environment variable to the install location. The example below is for Mac/Linux. For Windows, please use the **Edit Environment Variables** panel.

```bash
# Add the Conductor module install location to the MAYA_MODULE_PATH.
export MAYA_MODULE_PATH={{installPath}}:$MAYA_MODULE_PATH
```
#### Security
This plugin does not require network access to work. If you distribute it to artists who need to submit directly to the Conductor cloud, please also ensure that they have the desktop app installed. This is the ideal workflow for artists. In the absence of the desktop app, artists can submit their jobs scripts to a dedicated render wrangler machine with the desktop app installed.

The machine with the desktop app installed requires certain ports and URL access as below.

Ports:
- 443 (HTTPS)
- 80 (HTTP)
- 8080 (HTTP)
- 8081 (HTTP)

URLs:
- https://id.conductortech.com
- https://api.conductortech.com
- https://docs.conductortech.com
- https://downloads.conductortech.com
- https://raw.githubusercontent.com


touch install.bat install-mac.sh install-linux.sh