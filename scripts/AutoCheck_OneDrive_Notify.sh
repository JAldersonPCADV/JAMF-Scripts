#!/bin/bash
#This script is designed to check to see if OneDrive is running and notify user if it is not running.
#The script will run every half hour and check. 

if []

/usr/bin/osascript -e 'tell app "OneDrive" to activate'

#!/bin/bash
#check if app is open, notify and quit, use script parameter for application name

LoggedInUser=$( stat -f%Su /dev/console )
LoggedInUID=$(stat -f %u /dev/console)

if [[ $LoggedInUser = "root" ]]; then
echo "No user logged in - exiting script"
exit 0
fi

# check to see if a value was passed for $4, and if so, assign it
if [ "$4" != "" ]; then
application=$4
else
echo "No application parameter set on JSS, exiting script"
exit 1
fi

#convert to add .app and brackets - re https://www.jamf.com/jamf-nation/discussions/22283/check-if-program-is-running-script-using-ps-aux-grep

application=$( echo "$4".app | sed 's/./&]/1' | sed -e 's/^/[/' )
#echo "converted string = $application"
number=$(ps ax | grep -c "$application")

if [ $number -gt 0 ]; then
echo "$4 is open - notify user"

#Notify
cp /Library/Application\ Support/JAMF/bin/icons/Notifications.icns /private/var/tmp

sleep 3

icon="/private/var/tmp/Notifications.icns"        
title="IT Notification - Update" 
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
description="$4 is not currently running and needs to be for you data to sync and be backed up in $4 & SharePoint. Click OPEN to launch $4."

button1="Not Now"
button2="OPEN"

#resolved pasteboard error - https://www.jamf.com/jamf-nation/discussions/17245/running-management-action-fails-on-10-10-and-10-11
userChoice=$(/bin/launchctl asuser $(id -u $LoggedInUser) sudo -u $(ls -l /dev/console | awk '{print $3}') "$jamfHelper" -windowPosition ul -windowType hud -description "$description" -title "$title" -button1 "$button1" -button2 "$button2" -icon "$icon")

    if [ "$userChoice" == "2" ]; then

echo "User clicked OPEN - hoorah"
rm /private/var/tmp/Notifications.icns


#Launch application
#---- create separate script to run as user, cannot get asuser working with a $ parameter
#approach from - https://www.jamf.com/jamf-nation/discussions/24584/need-help-forcing-script-to-run-commands-under-current-logged-on-user

cat << EOF > /private/tmp/launch_application.sh
#!/bin/bash

echo "Launching $4"
/usr/bin/osascript -e 'quit app "$4"'

EOF

if [ -e /private/tmp/quit_application.sh ]; then
    /bin/chmod +x /private/tmp/launch_application.sh
    /bin/launchctl asuser "$LoggedInUID" sudo -iu "$LoggedInUser" "/private/tmp/launch_application.sh"
    sleep 2
    echo "Cleaning up..."
    /bin/rm -f "/private/tmp/launch_application.sh"
else
    echo "Oops! Couldn't find the script to run. Something went wrong!"
    exit 1
fi


#convert $4 paramater so it can be used in trigger command, remove space and make lower case
trigger=$( echo $4 | sed 's/ //g' | tr '[:upper:]' '[:lower:]' )

echo "triggering policy"
jamf policy -trigger "run$trigger"

exit 0

else

echo "User clicked later - exit script"
rm /private/var/tmp/Notifications.icns
exit 0


fi

fi

echo "$4 is open - triggering policy"
trigger=$( echo $4 | sed 's/ //g' | tr '[:upper:]' '[:lower:]' )

jamf policy -trigger "run$trigger"