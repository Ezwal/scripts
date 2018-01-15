#!/usr/bin/bash
set -e

# /!\ this script needs sshpass and the valid vm password /!\

# Parameters handling

if [[ $@ -eq 0 ]]; then
	echo "Usage: testhack.sh --target SOMEIP --vm-password PASS [--get-app] [--app APPPATH] [--back BACKSOURCE]"
	exit 0
fi

# Default values, modify as needed
TARGETIP=192.168.0.1
VMUSER=root
VMPASS=root
APP=/tmp 				# App file localisation
BACK=$PWD 				# Path for back-end file
REMOTE_BACK="to be defined"
GET=false 				# If true fetch the app file following $APP path

POSITIONAL=()
while [[ $# -gt 0 ]]; do
key=$1

case $key in
	-g|--get-app)
		GET=true
		shift
		;;
	-u|--user)
		VMUSER=$2
		shift; shift
		;;
  -b|--back)
    BACK=$2
    shift; shift
    ;;
	-a|--app)
		APP=$2
		shift; shift
		;;
	-t|--target)
		TARGETIP=$2
		shift; shift
		;;
	-t|--vm-password)
		VMPASS=$2
		shift; shift
		;;
	-u|--upload-file)
		TOUPLOAD=$2
		shift; shift
		;;
	*)
		POSITIONAL+=("$1")
		shift
		;;
esac; done
set -- "${POSITIONAL[@]}"

# check if args in a list needed are there; if yes return 0 otherwise exit (and print error mgs $2)
function needArgs () {
	argsList=$1
	errorMsg=$2
	for arg in $argsList; do
		if [[ $arg -eq "" ]]; then
			echo "$errorMsg"
			exit 1
		fi
	done
	return 0
}

# use sshpass to communicate a password to ssh command of any kind
function executeSshPass () {
	sshpass -p "$VMPASS" "$1"
	return "$?"
}

# execute as root a bash command (using sshpass), exit if failure (TODO change that ?)
function executeSshCommand () {
	executeSshPass "ssh $VMUSER@$TARGETIP $1" || { echo "Failed to execute command $1"; exit 1 }
	return 0
}

# search app from vm and get file
function dlFile () {
	pathFile=$1
	executeSshPass "scp -r $VMUSER@$TARGETIP:$pathFile ." || { echo "Failed to download file $pathFile"; exit 1 }
	return 0
}

function upFile () {
	pathFile=$1
	executeSshPass "scp -r $pathFile $VMUSER@$TARGETIP:$pathFile" || { echo "Failed to upload file $pathFile"; exit 1 }
	return 0
}

# will return file(s) from the vm
if [[ -n "$TOUPLOAD" ]]; then
	# TODO path shenanigan and make it work. simple
	filename=$(basename "$APP")
	dlFile "$APP"
	mv "$filename" "$BACK"
	echo "file $filename succesfully imported"
	exit 0
fi

# if before we want to fetch the app file from vm
if [[ "$GET" == true ]]; then
	needArgs "$APP"
	filename=$(basename "$APP")
	dlFile "$APP"
	mv "$filename" "$BACK"
	echo file "$filename" succesfully imported
	exit 0
fi

while :
do
    CHANGED=$(watching "$BACK")
    if [[ $? -eq 0 ]]; then
        # TODO transformed CHANGED FROM LOCAL TO REMOTE
        upFile "$CHANGED"
    fi
done
