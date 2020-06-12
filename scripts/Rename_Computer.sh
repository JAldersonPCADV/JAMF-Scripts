#!/bin/sh
getUser=$(ls -l /dev/console | awk '{ print $3 }')
hwIdentifier=$(sysctl -n hw.model)
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | rev | cut -c -5 | rev)
loggedInUser=$(finger -s $getUser | head -2 | tail -n 1 | awk '{print$2}')
company="PCADV"


	if [[ $hwIdentifier =~ "MacBookPro" ]] ; then
		echo "set name to: $loggedInUser-$company-MBP-$serialNumber"
		scutil --set ComputerName "$loggedInUser-$company-MBP-$serialNumber"
		scutil --set LocalHostName "$loggedInUser-$company-MBP-$serialNumber"
		scutil --set HostName "$loggedInUser-$company-MBP-$serialNumber"
	elif [[ $hwIdentifier =~ "MacBookAir" ]] ; then
		echo "set name to: $loggedInUser-$company-MBA-$serialNumber"
		scutil --set ComputerName "$loggedInUser-$company-MBA-$serialNumber"
		scutil --set LocalHostName "$loggedInUser-$company-MBA-$serialNumber"
		scutil --set HostName "$loggedInUser-$company-MBA-$serialNumber"
	elif [[ $hwIdentifier =~ "iMac" ]] ; then
		echo "set name to: $loggedInUser-$company-IMAC-$serialNumber"
		scutil --set ComputerName "$loggedInUser-$company-IMAC-$serialNumber"
		scutil --set LocalHostName "$loggedInUser-$company-IMAC-$serialNumber"
		scutil --set HostName "$loggedInUser-$company-IMAC-$serialNumber"
	elif [[ $hwIdentifier =~ "MacBook" ]] ; then
		echo "set name to: $loggedInUser-$company-MB-$serialNumber"
		scutil --set ComputerName "$loggedInUser-$company-MB-$serialNumber"
		scutil --set LocalHostName "$loggedInUser-$company-MB-$serialNumber"
		scutil --set HostName "$loggedInUser-$company-MB-$serialNumber"
	elif [[ $hwIdentifier =~ "Macmini" ]] ; then
		echo "set name to: $loggedInUser-$company-MM-$serialNumber"
		scutil --set ComputerName "$loggedInUser-$company-MM-$serialNumber"
		scutil --set LocalHostName "$loggedInUser-$company-MM-$serialNumber"
		scutil --set HostName "$loggedInUser-$company-MM-$serialNumber"
	elif [[ $hwIdentifier =~ "MacPro" ]] ; then
		echo "set name to: $loggedInUser-$company-MP-$serialNumber"
		scutil --set ComputerName "$loggedInUser-$company-MP-$serialNumber"
		scutil --set LocalHostName "$loggedInUser-$company-MP-$serialNumber"
		scutil --set HostName "$loggedInUser-$company-MP-$serialNumber"
	fi
# start Addigy collector and auditor
jamf recon

exit