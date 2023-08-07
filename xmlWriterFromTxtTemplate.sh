#!/bin/bash
##############################################
#
# Script to create xmls via a template file
# and fill those with the values of a csv
#
# Author: Adrian Martinez
# Date: 23.01.2023
#
##############################################

CTM_JOB=$1
CTM_CTRID=$2
SYSTEM_DIRECTORY=$3
PROJEKT=$4
FILENAME=$5
WORKING_DIRECTORY=$SYSTEM_DIRECTORY/$PROJEKT
INPUT_FILE_WITH_PATH=$WORKING_DIRECTORY/$PROJEKT/$FILENAME
DIRECTORY_TO_WRITE_XML="$WORKING_DIRECTORY/data/ebriefout/"
LOG_PATH="$WORKING_DIRECTORY/logs"
LOG_FILE="xmlWriter.log"
TMPFILE="BandbreitenBrief_template.txt" # Statik template file
DATUM=$(date +%d.%m.%Y) # Today in dd.mm.yyyy form

# check for parmeters
if [ $# -lt 5 ]; then
	echo "Failure. No arguments provided."
	echo "Please provide following agruments: (1) CTM_JOB (2) CTM_CTRID (3) SYSTEM_DIRECTORY - /ldata/dev|prod (4) Projekt (5) Name of the csv to write the xml"
	exit 1
fi

# itereate over the input file
LINE_COUNTER=0
while IFS= read -r line
do
	((LINE_COUNTER++))
	
	# Jump over the header
	if [ $LINE_COUNTER -eq 1 ]; then
		continue
	fi
	
	echo ""
	echo "$(basename $INPUT_FILE_WITH_PATH) | Line $LINE_COUNTER | $line"
	echo "$(basename $INPUT_FILE_WITH_PATH) | Line $LINE_COUNTER | $line" >>$LOG_PATH/$LOG_FILE
	
	PERSONALNUMMER=$(echo ${line} | cut -d ";" -f 1)
	SVNR=$(echo ${line} | cut -d ";" -f 2)
	FILENAME=$(echo ${line} | tr -d '\r\n'| cut -d ";" -f 3)
	XML_NAME="$FILENAME.xml"
	
	# PERSONENNUMMER;SVNR;VRG_STRING;FILENAME
	# replace placeholder in template an print it to file
	sed "
	s/%DATUM%/${DATUM}/g;
	s/%PERSONALNUMMER%/${PERSONALNUMMER}/g;
	s/%SVNR%/${SVNR}/g;
	s/%FILENAME%/${FILENAME}.pdf/g;" < ${TMPFILE} > $DIRECTORY_TO_WRITE_XML/"$XML_NAME"

done <"$INPUT_FILE_WITH_PATH"

RETURN_CODE=$?
if [ ${RETURN_CODE} != 0 ]; then
	echo $(date '+%F;%T;')"Could not write the xml." >>$LOG_PATH/$LOG_FILE
	echo $(date '+%F;%T;')"Return code: $RETURN_CODE" >>$LOG_PATH/$LOG_FILE
	exit $RETURN_CODE
fi

echo  "" 
echo  "Finished creating $LINE_COUNTER files."
echo  "Finished creating $LINE_COUNTER files." >>$LOG_PATH/$LOG_FILE
exit $RETURN_CODE
