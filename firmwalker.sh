#!/usr/bin/env bash
set -e
set -u

function usage {
	echo "Usage:"
	echo "$0 {path to extracted file system of firmware}\
 {optional: name of the file to store results - defaults to firmwalker.txt}"
	echo "Example: ./$0 linksys/fmk/rootfs/"
	exit 1
}

function msg {
    echo "$1" | tee -a $FILE
}

function getArray {
    array=() # Create array
    while IFS= read -r line
    do
        array+=("$line")
    done < "$1"
}

# Check for arguments
if [[ $# -gt 2 || $# -lt 1 ]]; then
    usage
fi

# Set variables
FIRMDIR=$1
if [[ $# -eq 2 ]]; then
    FILE=$2
else
    FILE="firmwalker.txt"
fi
# Remove previous file if it exists, is a file and doesn't point somewhere
if [[ -e "$FILE" && ! -h "$FILE" && -f "$FILE" ]]; then
    rm -f $FILE
fi

# Perform searches
msg "***Firmware Directory***"
msg $FIRMDIR
msg "***Search for password files***"
getArray "data/passfiles"
passfiles=("${array[@]}")
for passfile  in "${passfiles[@]}"
do
    msg "##################################### $passfile"
    find $FIRMDIR -name $passfile | cut -c${#FIRMDIR}- | tee -a $FILE
    msg ""
done
msg "***Search for Unix-MD5 hashes***"
egrep -ro '\$1\$\w{8}\S{23}' $FIRMDIR | tee -a $FILE
msg ""
if [[ -d "$FIRMDIR/etc/ssl" ]]; then
    msg "***List etc/ssl directory***"
    ls -l $FIRMDIR/etc/ssl | tee -a $FILE
fi
msg ""
msg "***Search for SSL related files***"
getArray "data/sslfiles"
sslfiles=("${array[@]}")
for sslfile in ${sslfiles[@]}
do
    msg "##################################### $sslfile"
    find $FIRMDIR -name $sslfile | cut -c${#FIRMDIR}- | tee -a $FILE
    msg ""
done
msg ""
msg "***Search for SSH related files***"
getArray "data/sshfiles"
sshfiles=("${array[@]}")
for sshfile in ${sshfiles[@]}
do
    msg "##################################### $sshfile"
    find $FIRMDIR -name $sshfile | cut -c${#FIRMDIR}- | tee -a $FILE
    msg ""
done
msg ""
msg "***Search for configuration files***"
getArray "data/conffiles"
conffiles=("${array[@]}")
for conffile in ${conffiles[@]}
do
    msg "##################################### $conffile"
    find $FIRMDIR -name $conffile | cut -c${#FIRMDIR}- | tee -a $FILE
    msg ""
done
msg ""
msg "***Search for database related files***"
getArray "data/dbfiles"
dbfiles=("${array[@]}")
for dbfile in ${dbfiles[@]}
do
    msg "##################################### $dbfile"
    find $FIRMDIR -name $dbfile | cut -c${#FIRMDIR}- | tee -a $FILE
    msg ""
done
msg ""
msg "***Search for shell scripts***"
msg "##################################### shell scripts"
find $FIRMDIR -name "*.sh" | cut -c${#FIRMDIR}- | tee -a $FILE
msg ""
msg "***Search for other .bin files***"
msg "##################################### bin files"
find $FIRMDIR -name "*.bin" | cut -c${#FIRMDIR}- | tee -a $FILE
msg ""
msg "***Search for patterns in files***"
getArray "data/patterns"
patterns=("${array[@]}")
for pattern in "${patterns[@]}"
do
    msg "##################################### $pattern"
    grep -lsirnw $FIRMDIR -e "$pattern" | cut -c${#FIRMDIR}- | tee -a $FILE
    msg ""
done
msg ""
msg "***Search for web servers***"
msg "##################################### search for web servers"
getArray "data/webservers"
webservers=("${array[@]}")
for webserver in ${webservers[@]}
do
    msg "##################################### $webserver"
    find $FIRMDIR -name "$webserver" | cut -c${#FIRMDIR}- | tee -a $FILE
    msg ""
done
msg ""
msg "***Search for important binaries***"
msg "##################################### important binaries"
getArray "data/binaries"
binaries=("${array[@]}")
for binary in "${binaries[@]}"
do
    msg "##################################### $binary"
    find $FIRMDIR -name "$binary" | cut -c${#FIRMDIR}- | tee -a $FILE
    msg ""
done
