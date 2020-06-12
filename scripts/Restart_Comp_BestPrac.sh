#!/bin/bash

# This script is designed to be run as often as you'd like, presumably once a week. Each time it runs, it checks the uptime. If the current uptime > recommended (7 days by default and editable in the script), then it will prompt the user.

# If uptime > recommended, it will prompt the user to restart and if declined or ignored, it will simply dismiss the prompt (not restart) by default. If user clicks Restart in our prompt, it will show the system's confirmation dialog with the standard 60-second countdown as if the user had selected Restart from the Apple menu.

# If uptime > preferred, it will prompt the user to restart and if no response it will restart by default, attempting a graceful restart (with no further confirmation dialog).

# If uptime > limit, the script will prompt the user and then if no response, default to first try restarting gracefully, and then restart forcibly after 75 seconds if needed. The user *does* have the option to decline by clicking Cancel. (If you don't want to use the heavy-handed forced restart limit, but you want to use the rest of the script, just configure the limit to an absurdly high number like 730 days.)

# Known Limitations: if a user is logged in, but the screen is locked (after sleep or screen saver), then the script fails to actually restart. There doesn't appear to be a way to detect this condition using bash, especially when running a script remotely via SSH. The best we may be able to do is infer it from idle time, but for now I recommend running the script when a user is likely to be logged in and working.

# Uptimes to address (in days)
# $recommended is the number of days of uptime to allow before we prompt the user (graceful restart only if user agrees)
# $preferred is when to try a graceful restart by default (after countdown, if user ignores prompt or no user is present but screen is unlocked so prompt can be displayed)
# $limit is the maximum allowed, and will result in forced restart if ignored or if no user is logged in

recommended="7"
preferred="21"
limit="75"

# Get uptime.
days=$(uptime | grep -ohe 'up .* day' | sed 's/,//g' | awk '{ print $2" " }')
if [ "${days}" = "" ]; then
days="0"
fi

# Get logged in user.
username=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`


if [ "$days" -gt "$limit" ]; then

    echo "Machine must reboot (uptime $days days)."

    if [ "$username" != "" ]; then

     echo "User $username is logged in. Prompting user."

(/Library/Addigy/macmanage/MacManage.app/Contents/MacOS/MacManage action=notify title="Restart Required - Uptime $days days" description="Your Mac has been on for more than $limit days. A restart is required." closeLabel="Restart" acceptLabel="Cancel" timeout="120" && echo "User $username declined to restart.") || (echo 'Restarting gracefully in 5 seconds, and restarting forcibly in 75 seconds if needed.' && (sleep 5 && osascript -e 'tell app "System Events" to restart') && (sleep 75 && /sbin/shutdown -r now) &> /dev/null &)

    else
     echo "No user is logged in. Restarting forcibly in 5 seconds."
     (sleep 5 && /sbin/shutdown -r now) &> /dev/null &
    fi

elif [ "$days" -gt "$preferred" ]; then
    echo "Machine needs reboot (uptime $days days)."

    if [ "$username" != "" ]; then

     echo "User $username is logged in. Prompting user."

     (/Library/Addigy/macmanage/MacManage.app/Contents/MacOS/MacManage action=notify title="Restart Needed - Uptime $days days" description="Your Mac has been on for more than $preferred days. A restart is needed." closeLabel="Restart" acceptLabel="Cancel" timeout="60" && echo "User $username declined to restart.") || (echo 'Restarting gracefully in 5 seconds.' && (sleep 5 && osascript -e 'tell app "System Events" to restart')>/dev/null 2>&1 &)

    else
     echo "No user is logged in. No way to restart gracefully. Exiting."
     # sleep 5 && osascript -e 'tell app "System Events" to restart'
    fi

elif [ "$days" -gt "$recommended" ]; then
    echo "Machine reboot recommended (uptime $days days)."

    if [ "$username" != "" ]; then

     echo "User $username is logged in. Prompting user."

/Library/Addigy/macmanage/MacManage.app/Contents/MacOS/MacManage action=notify title="Restart Recommended" description="Your Mac has been on for more than $recommended days. A restart is recommended." acceptLabel="Restart" closeLabel="Later" timeout="60" && echo "Prompting user with system dialog for graceful restart." && sudo -u $username osascript -e 'tell app "loginwindow" to «event aevtrrst»' || echo "User $username declined to restart or prompt was ignored."

    else
     echo "No user is logged in. No way to restart gracefully. Exiting."
     # sleep 5 && osascript -e 'tell app "System Events" to restart'
    fi


else
    echo "Machine does not need to reboot, uptime less than $recommended days"
fi