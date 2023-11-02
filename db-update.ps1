############# https://github.com/GHbasicuser/RB2RS-Database-Updater ############
#        db-update.ps1 v°1.01 (2023-11-01) by GHbasicuser (aka PhiliWeb)       #
#   This script (in PowerShell for Windows) downloads and installs the latest  #
#   "Radio-Browser" station list for RadioSure.                                #
#               (More information on https://www.radiosure.fr)                 #
################################################################################
$BASE_SOURCE = "http://rb2rs.freemyip.com/latest.zip"
$RadioSure = 0  # Put 1 to start RadioSure at the end of the script, otherwise 0
$Minimum_waiting_time_to_redownload = 12  # duration in hours
################################################################################

$ScriptName = $MyInvocation.MyCommand.Name
write-host "*** Information from the $ScriptName script for RadioSure ***" -BackgroundColor Black -ForegroundColor Gray

# Function Start_RadioSure
function Start_RadioSure() {
Start-Process -FilePath "radiosure.exe"
}

# Check if script is running in the appropriate directory
if (!(Test-Path -Path "radiosure.exe")) 
{
	write-host "Problem: This script doesn't seem to be running in the RadioSure folder." -BackgroundColor Black -ForegroundColor Red
	Start-Sleep -Seconds 120
	Exit
}

# If the 'Latest_RB2RS.zip' file is less than 12 hours old, exit
$sourcefile = "Stations/Latest_RB2RS.zip"
if (Test-Path $sourcefile) {
	$lastWrite = (get-item $sourcefile).LastWriteTime
	$timespan = new-timespan -Hours $Minimum_waiting_time_to_redownload
	if (((get-date) - $lastWrite) -lt $timespan) {
		write-host "Last download less than $Minimum_waiting_time_to_redownload hours ago. Update not required." -BackgroundColor Black -ForegroundColor Green
		if ($RadioSure -eq 1) {Start_RadioSure}
		Exit
	}
	$timespan = new-timespan -Days 30
	if (((get-date) - $lastWrite) -gt $timespan) {
		write-host "The last successful update is more than 30 days old." -BackgroundColor Black -ForegroundColor Yellow
		Write-host "The RB2RS server address used by this script may no longer be valid." -BackgroundColor Black -ForegroundColor Yellow
		Write-host "If the next download attempt fails, please consult https://www.radiosure.fr" -BackgroundColor Black -ForegroundColor Yellow
	}
}

# Download the latest "RB2RS" database
try
{
	write-host "[ Downloading latest RB2RS database for Radiosure ]" -BackgroundColor Black -ForegroundColor White
	$progressPreference = 'silentlyContinue'
	$Response = Invoke-WebRequest -Uri "$BASE_SOURCE" -OutFile "Stations\Latest_RB2RS.zip"
	$progressPreference = 'Continue'
} catch {
#	$ErrorMessage = $_.Exception.Response
#	Write-Output($ErrorMessage)
#	$FailedItem = $_.Exception
#	Write-Output($FailedItem)
	write-host "Didn't get a response from the Stations list Update server." -BackgroundColor Black -ForegroundColor Red
	Start-Sleep -Seconds 10
	if ($RadioSure -eq 1) {Start_RadioSure}
	Exit
}

# Check if downloaded ZIP file is too small
if ((Get-Item "Stations\Latest_RB2RS.zip").length -lt 800KB)
{
	write-host "The downloaded ZIP file seems too small. Update cancelled." -BackgroundColor Black -ForegroundColor Red
	if ($RadioSure -eq 1) {Start_RadioSure}
	Start-Sleep -Seconds 10
	Exit
}

# Delete existing ".rsd" files
remove-item Stations\* -include stations*.rsd

# Extract the ZIP file
Expand-Archive -Path "Stations/Latest_RB2RS.zip" -Force -DestinationPath "Stations"

# Update the RadioSure.xml file with the current date and time
if ((Test-Path -Path "RadioSure.xml"))
{
	$Current_DateTime = Get-Date -Format "yyyy/MM/dd/HH/mm"
	$xml = [xml](Get-Content -Path "RadioSure.xml")
	$xml.XMLConfigSettings.General.LastStationsUpdateCheck = $Current_DateTime.toString()
	$xml.Save("RadioSure.xml")
}

# Show success message
write-host "The Radio Stations database has been updated." -BackgroundColor Black -ForegroundColor Green
Start-Sleep -Seconds 5

# Start RadioSure if requested
if ($RadioSure -eq 1) {Start_RadioSure}