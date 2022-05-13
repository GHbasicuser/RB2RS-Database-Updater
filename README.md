# RB2RS-Database-Updater
This VBS Script download and install the latest "unofficial" list of radio stations for RadioSure.

This list of stations is a conversion (made by Francois-neosurf) of the "Radio-Browser.info" database.

Place this script in the RadioSure folder, then you can launch it with a ".bat", a shortcut or the task scheduler :

* eg: C:\Windows\System32\WScript.exe db-update.vbs

(Don't forget : In the "start in" (location) section, you must specify the RadioSure folder.)

_______________________________
db-update.vbs : 
* displays a message for 5 second if the update was successfull.
* doesn't try to download anything if an update was done less than 12 hours ago. (Editable number of hours)
* cancels the update if the zip file is too small.
* modifies the "Radiosure.xml" file to inform the software that the last station search has just been done. 
* displays some informational messages (ex : if the last successful RB2RS update is more than 30 days old).
* download source can be modified in file header. (Francois-neosurf's server = http://82.66.77.189:8080/)
* can launch RadioSure by setting RadioSure = 1 in file header (db-update.vbs).
_______________________________

![](https://www.zupimages.net/up/22/19/5djq.png)

_______________________________
* Example of creating a desktop shortcut : https://zupimages.net/up/22/18/lfkh.jpg
```
Target = C:\Windows\System32\WScript.exe db-update.vbs
Start In (location) = the RadioSure folder (eg: C:\Program Files (x86)\RadioSure)
```
* Example of use in batch file (in RadioSure folder) :
```
@echo OFF
WScript.exe db-update.vbs
exit
```
