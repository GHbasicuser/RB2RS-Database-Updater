'------------------------------------------------------------------------------'
'db-update.vbs v°1.00 (07/05/2022) par GHbasicuser (aka PhiliWeb)'
'Ce Script VBS permet de télécharger et d'installer la dernière'
'liste "non officielle" des stations de radios pour RadioSure'
'Cette liste de stations est une conversion de la base "Radio-Browser.info"'
'------------------------------------------------------------------------------'
'Si le fichier 'Latest_RB2RS.zip' a moins de 12 Heures on ne va pas plus loin'
Set FS = createobject("Scripting.FileSystemObject")
Set Fichier = FS.GetFile("RadioSure.exe")
If FS.FileExists("Stations\Latest_RB2RS.zip") Then Set Fichier = FS.GetFile("Stations\Latest_RB2RS.zip")   
If DateDiff("h", Fichier.DateLastModified, Now) < 12 Then wscript.Quit 
Set Fichier = Nothing
'Téléchargement de la dernière base "RB2RS" sur le serveur perso de francois-neosurf'
dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
xHttp.Open "GET", "http://82.66.77.189:8080/latest.zip", False
xHttp.Send
If xHttp.Status = 200 Then dim bStrm: Set bStrm = createobject("Adodb.Stream") Else wscript.Quit 
with bStrm
    .type = 1
    .open
    .write xHttp.responseBody
    .savetofile "Stations\Latest_RB2RS.zip", 2
end with
Set xHttp = Nothing
Set bStrm = Nothing
'On ne va pas plus loin si le fichier ZIP est trop petit pour réellement contenir une base valide'
Set Fichier = FS.GetFile("Stations\Latest_RB2RS.zip")
If Fichier.Size < 1000000 Then wscript.Quit
'Suppression de la base installée (et de tout éventuel autre fichier ".rsd")'
If FS.FileExists("Stations\*.rsd") Then FS.DeleteFile("Stations\*.rsd")
'Décompression du fichier ZIP contenant la nouvelle base ".rsd" dans le sous-dossier "Stations"'
DossierZip = Fichier.ParentFolder & "\" & "Latest_RB2RS.zip"
DossierDezip = Fichier.ParentFolder & "\" 
Set osa = createobject("Shell.Application" )
nbFic = osa.Namespace(DossierZip).Items.Count 
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
