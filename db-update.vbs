'------------https://github.com/GHbasicuser/RB2RS-Database-Updater------------'
'db-update.vbs v°1.09 (2023-11-01) by GHbasicuser (aka PhiliWeb)'
'This VBScript downloads and installs the latest "Radio-Browser" station list' 
'for RadioSure. (More information on https://www.radiosure.fr)'
'-----------------------------------------------------------------------------'
BASE_SOURCE = "http://rb2rs.freemyip.com/latest.zip"
RadioSure = 0 'Put 1 to start RadioSure at the end of the script, otherwise 0'
Minimum_waiting_time_to_redownload = 12 'duration in hours'
'-----------------------------------------------------------------------------'
'To use the script with schtasks,...'
VBSName = Wscript.ScriptName
ActualPath = WScript.ScriptFullName
ActualPath = Replace(ActualPath, "\" & VBSName, "")
Set objShell = CreateObject("Wscript.Shell")
objShell.CurrentDirectory = ActualPath
Set ActualPath = Nothing
Set objShell = Nothing
Dim oMessageBox
Set oMessageBox = CreateObject("WScript.Shell")
'Check if script is running in the appropriate directory'
Set FS = createobject("Scripting.FileSystemObject")
If Not FS.FileExists("RadioSure.exe") Then 
     oMessageBox.Popup "Problem: This VBScript doesn't seem to be running in the RadioSure folder.", 120, "RB2RS-Database-Updater ("& VBSName &")", 0 + 48
     Set oMessageBox = Nothing
     wscript.Quit
End If
'Function Start_RadioSure'
function Start_RadioSure()
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run "RadioSure.exe"
Set WshShell = Nothing 
End Function
'If the "Latest_RB2RS.zip" file is less than 12 hours old, exit'
If FS.FileExists("Stations\Latest_RB2RS.zip") Then 
     Set Fichier = FS.GetFile("Stations\Latest_RB2RS.zip")
    If DateDiff("h", Fichier.DateLastModified, Now) < Minimum_waiting_time_to_redownload Then 
       If RadioSure = 1 Then Start_RadioSure() 
       wscript.Quit
    End  If 
    If DateDiff("d", Fichier.DateLastModified, Now) > 30 Then 
       oMessageBox.Popup "RadioSure" & vbCrLf & vbCrLf & _
       "- The last successful update is more than 30 days old." & vbCrLf & vbCrLf & _
       "- The RB2RS server address used by this script may no longer be valid. " &_
       "If the next download attempt fails, please consult : https://www.radiosure.fr", 120, "RB2RS-Database-Updater ("& VBSName &")", 0 + 64
    End If
     Set Fichier = Nothing
End If
'Download the latest "RB2RS" database'
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
'Check if downloaded ZIP file is too small'
Set Fichier = FS.GetFile("Stations\Latest_RB2RS.zip")
If Fichier.Size < 800000 Then 
     Set Fichier = Nothing
     oMessageBox.Popup "RadioSure - The downloaded ZIP file seems too small. Update cancelled.", 10, "RB2RS-Database-Updater ("& VBSName &")", 0 + 64
     Set oMessageBox = Nothing
     If RadioSure = 1 Then Start_RadioSure()
     wscript.Quit
End If
'Delete existing ".rsd" files'
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
'Extract the ZIP file'
DossierZip = Fichier.ParentFolder & "\" & "Latest_RB2RS.zip"
DossierDezip = Fichier.ParentFolder & "\" 
Set osa = createobject("Shell.Application")
osa.Namespace(DossierDezip).CopyHere osa.Namespace(DossierZip).Items, 20
Set Fichier = Nothing
Set osa = Nothing
'Update the RadioSure.xml file with the current date and time'
If FS.FileExists("RadioSure.xml") Then
Set xmlDoc = CreateObject("Microsoft.XMLDOM")
xmlDoc.load "RadioSure.xml"
Set nNode = xmlDoc.selectsinglenode ("//General/LastStationsUpdateCheck")
  If Not nNode Is Nothing Then
  nNode.text = Year(Now) & "/" & Month(Now) & "/" & Day(Now) & "/" & Hour(Now) & "/" & Minute(Now)
  strResult = xmldoc.save("RadioSure.xml")
  End If
Set xmlDoc = Nothing
Set nNode = Nothing
End If
Set FS = Nothing
'Show success message'
oMessageBox.Popup "RadioSure - The Radio Stations database has been updated.", 5, "RB2RS-Database-Updater ("& VBSName &")" 
Set oMessageBox = Nothing
Set VBSName = Nothing
If RadioSure = 1 Then Start_RadioSure()