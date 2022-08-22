# RB2RS-Database-Updater
This VBScript download and install the latest "unofficial" list of radio stations for RadioSure.

This list of stations is a conversion of the "Radio-Browser.info" database. (more than 30000 stations ! :-))

Place this script in the RadioSure folder, then you can launch it with a ".bat", a shortcut or the task scheduler :

* eg: wscript.exe db-update.vbs
* Start In (location) = the RadioSure folder (eg: C:\Program Files (x86)\RadioSure)

_______________________________
db-update.vbs : 
* displays a message for 5 second if the update was successfull.
* doesn't try to download anything if an update was done less than 12 hours ago. (Editable number of hours)
* cancels the update if the zip file is too small.
* modifies the "Radiosure.xml" file to inform the software that the last station search has just been done. 
* displays some informational messages (ex : if the last successful RB2RS update is more than 30 days old).
* download source can be modified in file header. (e.g. : http://82.66.77.189/ or http://rb2rs.freemyip.com/)
* can launch RadioSure by setting RadioSure = 1 in file header (db-update.vbs).
_______________________________

![](https://www.zupimages.net/up/22/19/5djq.png)

_______________________________
* Example of creating a desktop shortcut : 
```
- Extract the .zip archive into the RadioSure folder.
- Right-click on “db-update.vbs” file, then choose "Send to desktop (create shortcut)".

On the desktop, right-click on the shortcut, then choose "Properties" :
- In the target area put: wscript.exe db-update.vbs
- For better rendering, you can click on "Change Icon" and use the one inside the RadioSure.exe file.

If you want to rename the shortcut, right-click on the shortcut, then choose "Rename".
```
* Example of use in batch file (in RadioSure folder) :
```
@echo OFF
WScript.exe db-update.vbs
exit
```
