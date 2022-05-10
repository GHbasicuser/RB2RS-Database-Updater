# RB2RS-Database-Updater
This VBS Script download and install the latest "unofficial" list of radio stations for RadioSure from the francois-neosurf server.

This list of stations is a conversion (made by francois-neosurf) of the "Radio-Browser.info" database.

Place this script in the RadioSure folder, then you can launch it (via WScript) with a ".bat, a shortcut or the task scheduler :

eg: C:\Windows\System32\WScript.exe db-update.vbs

(Don't forget : In the "start in" (location) section, you must specify the RadioSure folder.)

_______________________________
db-update.vbs v°1.04 :

* displays a message for 5 second if the update was successfull.
* doesn't try to download anything if an update was done less than 12 hours ago. (to preserve the server)
* cancels the update if the zip file is too small.
* modifies the "Radiosure.xml" file to inform the software that the last station search has just been done. 
* displays a message if the last successful RB2RS update is more than 30 days old, or if it doesn't recognize the RadioSure folder.
* can launch RadioSure by setting RadioSure = 1 in file header (db-update.vbs).
_______________________________
