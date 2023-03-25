#!/bin/sh
# Ports import script
sysdir=/mnt/SDCARD/.tmp_update

ShortcutsDir="/mnt/SDCARD/Roms/PORTS/Shortcuts"

$sysdir/bin/infoPanel -t "Ports import" -m "Scanning..." --persistent &

OIFS="$IFS"
IFS=$'\n'

for file in $(find "$ShortcutsDir" -type f  \( -name "*.port" -o -name "*.notfound" \))
do
	  filename=$(basename "$file")
	  if [ "${filename}" == "~Import ports.port" ]; then
		continue
	  fi

	echo "======================================================================================"

# ==================================== GAME PATH ====================================

	# classic case : the "GameDir" has been specified.
	GameDir=$(grep "GameDir=" "$file" | cut -d "=" -f2 | grep -o '".*"' | tr -d '"')
	# If the "GameDir" has not been specified we take the RomDir name instead
	if [ -z "$GameDir" ]; then
		GameDir=$(grep "RomDir=" "$file" | cut -d "=" -f2  | grep -o '".*"' | tr -d '"')
	fi
	# If the "RomDir" has not been specified, it's probably a retroarch core withtout rom so we take the name of the core 
	if [ -z "$GameDir" ]; then
		GameDir="/mnt/SDCARD/RetroArch/.retroarch/cores"
	else
		GameDir="/mnt/SDCARD/Roms/PORTS/Games/${GameDir}"
	fi

# ================================= GAME FILE NAME =================================

	# classic case : the "GameDataFile" has been specified.
	GameDataFile=$(grep "GameDataFile=" "$file" | cut -d "=" -f2  | grep -o '".*"' | tr -d '"')
	# If the "GameDataFile" has not been specified we take the game executable name instead
	if [ -z "$GameDataFile" ]; then
		GameDataFile=$(grep "GameExecutable=" "$file" | cut -d "=" -f2  | grep -o '".*"' | tr -d '"')
	fi
	# If the "GameExecutable" has not been specified we take the rom name instead
	if [ -z "$GameDataFile" ]; then
		GameDataFile=$(grep "RomFile=" "$file" | cut -d "=" -f2  | grep -o '".*"' | tr -d '"')
	fi
	# If the "RomFile" has not been specified, it's probably a retroarch core withtout rom so we take the name of the core 
	if [ -z "$GameDataFile" ]; then
		GameDataFile=$(grep "Core=" "$file" | cut -d "=" -f2  | grep -o '".*"' | tr -d '"')
		GameDataFile=${GameDataFile}_libretro.so 
	fi
# ==================================== RESULT ====================================
	
	echo "Current file ---- :  $file"
	echo "GameDir --------- :  $GameDir"
	echo "GameDataFile ---- : $GameDataFile"
  
	  
# =============================== GAME PRESENCE CHECK ===============================
	  
	# echo "find \"${GameDir}\" -maxdepth 1 -type f -iname "${GameDataFile}" | grep ."
	
	filename=$(basename "$file")
	extension="${filename##*.}"
	
	find "${GameDir}" -maxdepth 2 -type f -iname "${GameDataFile}" | grep .
	if [ $? -eq 0 ]; then
		echo "Presence -------- :  OK"
		if [ "$extension" != "port" ]; then
			mv "$file" "${file%.*}.port"
		fi
	else
		echo "Presence -------- :  NOT FOUND !"
		if [ "$extension" != "notfound" ]; then
			echo "renaming \"$file\" \"${file%.*}.notfound\""
			mv "$file" "${file%.*}.notfound"
		fi
	fi


done
IFS="$OIFS"

sed -i "/\"pageend\":/s/:.*,/:   5,/" "/tmp/state.json"   # Little trick which allows to displays all the new items in the game list of MainUI
rm "$ShortcutsDir/Shortcuts_cache2.db"

touch /tmp/dismiss_info_panel
