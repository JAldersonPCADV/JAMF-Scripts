#!/bin/bash
#[ -f /Applications/Install\ macOS\ Mojave.app ] && echo "Mojave Installer is present" || echo "Mojave Installer Needed"

echo "<result>$(file="/Applications/Contacts.app"
if  test -s "$file" 
then 
    echo "Mojave Installer is present"
else 
    echo "Mojave Installer Needed"
fi)</result>"
exit