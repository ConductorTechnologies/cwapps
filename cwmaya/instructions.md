### Set up
If the installation was a success, you should see the Conductor plugin in Maya's Plugin Manager. When you load the plugin, you'll see a new menu called Conductor in the main menu bar. From there you can configure a submission. 

### Notes for system administrators

If you are installing on behalf of other artists, we recommend you download the installer script from the tool detail card (link in the top right corner of the card) and run it on their machines.
```bash
# Add the Conductor module install location to the MAYA_MODULE_PATH.
export MAYA_MODULE_PATH={{installPath}}:$MAYA_MODULE_PATH
```
#### Security
In a high security environment, artists on machines without access to the internet can submit jobs to a machine with the desktop app installed, possibly manned by a render wrangler. The render wrangler can then forward jobs to the Conductor cloud.

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