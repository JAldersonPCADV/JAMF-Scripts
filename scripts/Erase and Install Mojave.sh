#!/bin/bash
#[ -f /Applications/Install\ macOS\ Mojave.app ] && echo "Mojave Installer is present" || echo "Mojave Installer Needed"

echo "<result>$(file="/Library/LaunchDaemons/com.kolide-k2.launcher.plist"
if  test -s "$file" 
then 
    echo "Mojave Installer is present"
else 
    echo "Mojave Installer Needed"
fi)</result>"