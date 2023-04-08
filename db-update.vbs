'------------https://github.com/GHbasicuser/RB2RS-Database-Updater------------'
'db-update.vbs v°1.08 (2023-04-08) by GHbasicuser (aka PhiliWeb)'
'This VBScript downloads and installs the latest "Radio-Browser" station list' 
'for RadioSure. (More information on https://www.radiosure.fr)'
'-----------------------------------------------------------------------------'
BASE_SOURCE = "http://rb2rs.freemyip.com/latest.zip"
RadioSure = 0 'Put 1 to start RadioSure at the end of the script, otherwise 0'
Minimum_waiting_time_to_redownload = 12 'duration in hours'
'-----------------------------------------------------------------------------'
'Pour une utilisation avec schtasks,...'
VBSName = Wscript.ScriptName
ActualPath = WScript.ScriptFullName
ActualPath = Replace(ActualPath, "\" & VBSName, "")
Set objShell = CreateObject("Wscript.Shell")
objShell.CurrentDirectory = ActualPath
Set ActualPath = Nothing
Set objShell = Nothing
Dim oMessageBox
Set oMessageBox = CreateObject("WScript.Shell")
'Est-ce que le script tourne dans le dossier de RadioSure ?'
Set FS = createobject("Scripting.FileSystemObject")
If Not FS.FileExists("RadioSure.exe") Then 
     oMessageBox.Popup "Problem: This VBScript doesn't seem to be running in the RadioSure folder.", 120, "RB2RS-Database-Updater ("& VBSName &")", 0 + 48
     Set oMessageBox = Nothing
     wscript.Quit
End If
'Fonction pour lancer RadioSure à la fin du script'
function Start_RadioSure()
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run "RadioSure.exe"
Set WshShell = Nothing 
End Function
'Si le fichier 'Latest_RB2RS.zip' a moins de 12 Heures on ne va pas plus loin'
If FS.FileExists("Stations\Latest_RB2RS.zip") Then 
     Set Fichier = FS.GetFile("Stations\Latest_RB2RS.zip")
    If DateDiff("h", Fichier.DateLastModified, Now) < Minimum_waiting_time_to_redownload Then 
       If RadioSure = 1 Then Start_RadioSure() 
       wscript.Quit
    End  If 
    If DateDiff("d", Fichier.DateLastModified, Now) > 30 Then 
       oMessageBox.Popup "RadioSure - The last successful update is more than 30 days old.", 120, "RB2RS-Database-Updater ("& VBSName &")", 0 + 64
    End If
     Set Fichier = Nothing
End If
'Téléchargement de la dernière base "RB2RS"'
On Error Resume Next 
dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
xHttp.Open "GET", BASE_SOURCE, False
xHttp.Send
If xHttp.Status = 200 Then 
     dim bStrm: Set bStrm = createobject("Adodb.Stream")
     with bStrm
     .type = 1
     .open
     .write xHttp.responseBody
     .savetofile "Stations\Latest_RB2RS.zip", 2
     end with
     Set bStrm = Nothing
     Set xHttp = Nothing
Else 
     Set xHttp = Nothing
     oMessageBox.Popup "RadioSure - Didn't get a response from Stations list Update server.", 10, "RB2RS-Database-Updater ("& VBSName &")"
     Set oMessageBox = Nothing
     If RadioSure = 1 Then Start_RadioSure()
     wscript.Quit
End If
On Error Goto 0
'On ne va pas plus loin si le fichier ZIP est trop petit pour réellement contenir une base valide'
Set Fichier = FS.GetFile("Stations\Latest_RB2RS.zip")
If Fichier.Size < 800000 Then 
     Set Fichier = Nothing
     oMessageBox.Popup "RadioSure - The downloaded ZIP file seems too small. Update cancelled.", 10, "RB2RS-Database-Updater ("& VBSName &")", 0 + 64
     Set oMessageBox = Nothing
     If RadioSure = 1 Then Start_RadioSure()
     wscript.Quit
End If
'Suppression de la base installée (et de tout éventuel autre fichier ".rsd")'
objStartFolder = "Stations\"
Set objFolder = FS.GetFolder(objStartFolder)
Set colFiles = objFolder.Files
For Each objFile in colFiles
   if instr(objFile.Name,"stations-") <> 0 AND instr(objFile.Name,".rsd") <> 0 then
       FS.DeleteFile(objStartFolder + objFile.Name)
   end if
Next
Set objFolder = Nothing
Set colFiles = Nothing
'Décompression du fichier ZIP contenant la nouvelle base ".rsd" dans le sous-dossier "Stations"'
DossierZip = Fichier.ParentFolder & "\" & "Latest_RB2RS.zip"
DossierDezip = Fichier.ParentFolder & "\" 
Set osa = createobject("Shell.Application")
osa.Namespace(DossierDezip).CopyHere osa.Namespace(DossierZip).Items, 20
Set FS = Nothing
Set Fichier = Nothing
Set osa = Nothing
'Modification du fichier RadioSure.xml avec la date et l'heure de la dernière recherche de mise à jour..'
Set xmlDoc = CreateObject("Microsoft.XMLDOM")
xmlDoc.load "RadioSure.xml"
Set nNode = xmlDoc.selectsinglenode ("//General/LastStationsUpdateCheck")
nNode.text = Year(Now) & "/" & Month(Now) & "/" & Day(Now) & "/" & Hour(Now) & "/" & Minute(Now)
strResult = xmldoc.save("RadioSure.xml")
Set xmlDoc = Nothing
Set nNode = Nothing
'Affiche un message pour informer du succès de la mise à jour pendant 5 secondes'
oMessageBox.Popup "RadioSure - The Radio Stations database has been updated.", 5, "RB2RS-Database-Updater ("& VBSName &")" 
Set oMessageBox = Nothing
Set VBSName = Nothing
If RadioSure = 1 Then Start_RadioSure()
