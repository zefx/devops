#!/bin/bash
# setting param vars
FOLDERPATH=$1
COMPALGO=$2
OUTFILE=$3

# if not all parameters provided + help
if [ -z "$1" ]
  then
    echo "No path to a folder with data supplied. Please see bscript.sh -h for more help." 
    exit 1
fi

if [ "$1" == "-h" ]; then
  echo "
  Usage: `basename $0` -- simple script to backup and encrypt target folder.
  
  Mandatory script arguments are:
  bscript.sh target_folder compression_algo output_file_name
  
  Where:
  target_folder - path to target folder,
  compression_algo - compression algorytm (none, gzip, bzip),
  output_file_name - name of compresset and encrypted folder. AES-256 is in use.  
  "
  exit 0
fi

if [ -z "$3" ]
  then
    echo "No output file name supplied. Please see bscript.sh -h for more help."
    exit 1
fi

# checking algos for compression with ar
case $COMPALGO in
  none )
    OPT="cvf"
    OUTFILE+=".tar"
    ;;
  gzip )
    OPT="cvzf"
    OUTFILE+=".tar.gz"
    ;;
  bzip )
    OPT="cvjf"
    OUTFILE+=".tar.bz2"
    ;;
esac

# adding datetime to log file
(date "+%Y.%m.%d-%H.%M.%S") >> error.log
# compressing and encrypting folder + errors to log
tar $OPT $OUTFILE $FOLDERPATH 2>> error.log | openssl aes-256-cbc -a -salt -pbkdf2 -in $OUTFILE -out "${OUTFILE}.enc" 2>> error.log
# checking if no errors
if [ $? -eq 0 ]; then
    echo "File ${OUTFILE}.enc created"
else
    echo "Encryption unsuccessfull, check error.log."
fi
# removing compressed folder after encryption + errors to log
rm $OUTFILE 2>> error.log
