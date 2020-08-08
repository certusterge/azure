
######################################
# Script to define regional settings on Azure Virtual Machines deployed from the market place
# Author: Alexandre Verkinderen
# Blogpost: https://mscloud.be/configure-regional-settings-and-windows-locales-on-azure-virtual-machines/
#
######################################
# Modified by TRG from regional settings script to WVD firstboot script
# Aug 2020
#
######################################

#variables
#$regionalsettingsURL = "https://raw.githubusercontent.com/certusterge/azure/master/wvd_firstboot_regionalsettings.xml"
$RegionalSettings = "D:\wvd_firstboot_regionalsettings.xml"
$RegionalSettingsSource = "\\aquagroup.cloud\SysVol\aquagroup.cloud\Policies\{2E400681-C2BB-4228-BCDC-5291BBC4275F}\Machine\Scripts\Startup\wvd_firstboot_regionalsettings.xml"
$RunOnceFile = "C:\GPO\regionalsettingsapplied"
$FileExists	= Test-Path $RunOnceFile


#downdload regional settings file
#$webclient = New-Object System.Net.WebClient
#$webclient.DownloadFile($regionalsettingsURL,$RegionalSettings)

#copy file to local temp drive

Copy-Item -Path $RegionalSettingsSource -Destination $RegionalSettings


#checkfiles
If ($FileExists -eq $False) {

# Set Locale, language etc. 
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""

# Set languages, time, home
Set-WinSystemLocale en-GB
Set-WinUserLanguageList -LanguageList en-GB -Force
Set-Culture -CultureInfo en-GB
Set-WinHomeLocation -GeoId 242
Set-TimeZone -Name "GMT Standard Time"

#create runoncefile
New-Item -ItemType file $RunOnceFile

#gpupdate
gpupdate

# restart virtual machine after delay
Start-sleep -Seconds 60
Restart-Computer
}
