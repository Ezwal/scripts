#!/usr/bin/bash
set -e

# /!\ this script needs sshpass and the vm password /!\ 

# Parameters handling 

if [[ $@ -eq 0 ]]; then
	echo Usage: testhack.sh --target SOMEIP --vm-password PASS [--get-app] [--app APPPATH] [--back BACKSOURCE]
	exit 0
fi

# default value, modify as needed
TARGETIP=192.168.0.10
VMUSER=root 
VMPASS=root
APP=/tmp
BACK=~/root/bin
GET=false

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
	sshpass -p $VMPASS $1
	return "$?" 
}

# execute as root a bash command (using sshpass), exit if failure (TODO change that ?)
function executeSshCommand () {
	executeSshPass "ssh root@$TARGETIP $1" || echo "Failed to execute command $1"; exit 1
	return 0
}

# search app from vm and get file (as root sorry)
function getFile () {
	pathFile=$1
	executeSshPass "scp -r $VMUSER@$TARGETIP:$pathFile ." || echo "Failed to get file $pathFile"; exit 1
	return 0
}

# if before we want to fetch the app file from vm
if [[ "$GET" -eq true ]]; then
	argList=($app); needArgs $argList
	filename=$(basename $APP)
	getFile $APP
	echo "file $filename succesfully imported"
	exit 0
fi

# to use recursive file watch you must have chokidar file watch 
# TODO call node scripts
