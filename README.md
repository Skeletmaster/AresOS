
Hello and welcome to the Hyperion Gunner Script.

For further information you can contact: Skeletmaster#9864



The main target of this script is to provide a functional overlay for PvP. 
It has many common features and some new takes in a robust and modular Framework made by Proximo(https://github.com/Proximitron/AresOS)

How to install: 
For everyone:
    Download:
    LGAres_GunnerV0.9.conf
    LGAres_RemoteV0.9.conf

    Link all elements(radar,guns, etc) to the seat and ONE DB to both the Gunner and the Remote. If you have multiple gunner seats connect up to 4 gunner seats to the same DB, for higher counts pls contact Skeletmaster for more information
    Run both autoconfigs on the respective element, have fun

For Hyperion:
    Download:
    Ares_GunnerV0.9.conf
    Ares_RemoteV0.9.conf

    Link all elements(radar,guns, etc) to the seat and ONE DB to both the Gunner and the Remote. If you have multiple gunner seats connect up to 4 gunner seats to the same DB, for higher counts pls contact Skeletmaster for more information
    Run both autoconfigs on the respective element, have fun



The Framework allows easy adding and removal of script parts, you can add your own "Plugins". For that you only need to add a folder named "AresOS" into your custom folder. In that folder you can put additional files, that the script can load. Node the only file loaded under normal circumstances is a file named "optionals.lua". if you want to have your plugin loaded, you need to put the filename into that file, like this: getPlugin("awsomeaddon"). To see how a standard addon looks, you can check out all standard plugins in(https://github.com/Skeletmaster/AresOS/tree/main/AresOS) or the template (https://github.com/Skeletmaster/AresOS/blob/main/AresOS/template.lua).

If you want to make your own configs: just follow the steps in this file(https://github.com/Skeletmaster/AresOS/blob/main/ReadMEforProgrammers.md) if you cannot read german pls use deepl ;). The commands I use to create a file can be found here (https://github.com/Skeletmaster/AresOS/blob/main/convertToDU.sh). 

Pls note that you might need to modify the following file(https://github.com/Skeletmaster/AresOS/blob/main/AresOS/configuration.lua) for your respective Org.
self.owner -- integer of the OrgId of all members that are allowed to fly this script, if nil will skip this check
self.creator -- integer of the creatorId of the construct, if nil will skip this check
self.basePos -- Position of your home base as String like ("::pos{0,0,-91264.7828,408204.8952,40057.4424}")
self.friOrgs -- list of all friendly org ids for 2Auth
self.friPlayer -- list of all friendly player ids for 2Auth


Features: 
Search for ID, AR vision of important objects in space, customizable menu and many more.

Auto turnoff the remote when you get out of the seat, you can change the behavior inside the settings tab

You can add additonal Waypoints we this file(https://github.com/Skeletmaster/AresOS/blob/main/specialCoords.lua) you need to put this directly into your lua folder ....\Game\data\lua , nexto your atlas.lua file.

HotKeys:
G toggle break (CTRL toggle can be switched on inside the settings)
ALT + 3: Switching thru the Radarmodes
Alt + 5: Toggle the text from the Planets in AR
ALt + 8: Vent your Shield
Alt + 6: Toggle of the CMCI(Combat Monitoring and Control Interface) [This option is only available in the first person], you can find a settings tab under this
Alt + Scroll: Scrolling thru the radar widget

Commands: 
/help: to see all commands of the gunnerseat
!help: to see all commands of the remote

additional just a 3 letter tag to target it, like: "DE3"
