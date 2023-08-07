#!/bin/bash

# Überprüfe, ob alle Parameter angegeben wurden
# Falls nicht, gib folgendes zurück:
if [[ $# -lt 4 ]]; then
	echo "Missing parameters"
	echo
	echo "Usage"
	echo "$0 <ctm_job> <ctm_ctrid> <systemdir> <project>"
	echo
	echo "Example"
	echo "$0 0 0 /ldata/dev UltimateMailing"
	exit 1
fi


###Standard Parameter
ctm_job=$1
ctm_ctrid=$2
systemdir=$3
projekt=$4
cores=8
compLevel=5
wdir=$systemdir/$projekt
logfile=${wdir}/logs/housekeeping.log
datumuhrzeit=$(date +%Y%m%d_%H%M%S)
datum=$(date +%Y%m%d)
tmpdir=${wdir}/temp_$datumuhrzeit
stage=`pwd | cut -d / -f 3`

passwort=$(echo $RANDOM | md5sum | head -c 20)
psw=""
passwotFilter="*"
if [[ "$5" == *"secure"* ]]; then
  psw="-p$passwort"
fi
if [[ "$5" == *"conditional"* ]]; then
  passwotFilter=$6
  FILE=$wdir/Daten_Eingang_Archiv/$passwotFilter
  if [ $(ls $FILE) ]; then
	psw="-p$passwort"
  fi
fi
touch "$logfile"
exec > >(tee -ia "$logfile")
exec 2> >(tee -ia "$logfile" >&2)

echo "ctm_job	:" $ctm_job	
echo "ctm_ctrid	:" $ctm_ctrid	
echo "systemdir	:" $systemdir	
echo "projekt	:" $projekt	
echo "wdir		:" $wdir

function fehlerHandling () {
	if [[ $1 != 0 ]]; then
		echo "`date +\"%Y.%m.%d - %T\"` #############################"
		echo "`date +\"%Y.%m.%d - %T\"` $2 fehlgeschlagen"
		echo "`date +\"%Y.%m.%d - %T\"` RC:"$1
		exit $1
	fi
}

function commandLog () {
	echo ====================================
	echo "folgender Command wurde ausgeführt:"	
	echo "7za a -t7z -m0=lzma2 -mmt=${cores} -mx=${compLevel} ${nas}/${projekt}/Daten_Archiv/${stage}-$1-${datum}_${datumuhrzeit}.7z ${wdir}/$2/"
}

function LogFehlerUndCommand() {
	commandLog $3 $4
	fehlerHandling $1 $2
}

function move() {
	mv ${tmpdir}/${projekt}_${stage}-$1-${datumuhrzeit}.7z $2
	RC=$?
	LogFehlerUndCommand $RC "MOVE" $3 $4
}

function zipArchive() {
	7za a -t7z -m0=lzma2 -mmt=$cores -mx=$compLevel ${tmpdir}/${projekt}_${stage}-$1-${datumuhrzeit}.7z ${wdir}/$2 $psw
	RC=$?
	fehlerHandling $RC "zippen $3"
	sleep 2
}

function tryToPing () {
	if [ ! -d $1 ];then
		echo "housekeeping ends with error. Can't find $1"
		echo "housekeeping ends with error. Can't find $1"
		exit 99
	fi
}

hostname=$(hostname -a)
archivetarget="Datenarchiv_"
arcroot="/ldata/archive"

case $hostname in
	'Testserver')
	arcroot="/archive"
	archivetarget+="DEV"
	;;
	'xld2dp100')
	archivetarget+="Prod1"	#${hostname: -1}
	;;
	'xld2dp101')
	archivetarget+="Prod2"
	;;
	'xld2dp102')
	archivetarget+="Prod3"
	;;
	*)
	echo noch etwas machen!!
	exit 69
	;;
esac
	echo "$datumuhrzeit;$archivetarget;$passwort" >>  $wdir/secure.txt

#NAS
[[ -d $arcroot/$archivetarget ]] || mkdir $arcroot/$archivetarget
[[ -d $arcroot/$archivetarget/done ]] || mkdir $arcroot/$archivetarget/done
nas_done=$arcroot/$archivetarget/done
[[ -d $arcroot/$archivetarget/logs ]] || mkdir $arcroot/$archivetarget/logs
nas_logs=$arcroot/$archivetarget/logs
[[ -d $arcroot/$archivetarget/out ]] || mkdir $arcroot/$archivetarget/out
nas_out=$arcroot/$archivetarget/out
[[ -d $arcroot/$archivetarget/processed ]] || mkdir $arcroot/$archivetarget/processed
nas_processed=$arcroot/$archivetarget/processed
[[ -d $arcroot/$archivetarget/Daten_Eingang_Archiv ]] || mkdir $arcroot/$archivetarget/Daten_Eingang_Archiv
nas_Daten_Eingang_Archiv=$arcroot/$archivetarget/Daten_Eingang_Archiv
[[ -d $arcroot/$archivetarget/report ]] || mkdir $arcroot/$archivetarget/report
nas_report=$arcroot/$archivetarget/report
[[ -d $arcroot/$archivetarget/ebrief ]] || mkdir $arcroot/$archivetarget/ebrief
nas_ebrief=$arcroot/$archivetarget/ebrief
[[ -d ${wdir}/data/archiv ]] || mkdir ${wdir}/data/archiv

echo "housekeeping starting at ${datumuhrzeit}"
echo "Hostname is $hostname."
echo "Archive Directory Root Path is set to $arcroot."
echo "Archive Directory Target Path is set to $archivetarget."

tryToPing $arcroot

mv ${wdir}/data/in/*.* ${wdir}/data/error/
mv ${wdir}/data/accounting/*.* ${wdir}/data/processed/

###############
#Daten_Eingang
###############
tryToPing $nas_Daten_Eingang_Archiv
zipArchive "Daten_Eingang_Archiv" "Daten_Eingang_Archiv/*.*" "Daten_Eingang_Archiv"

###############
#reports
###############
tryToPing $nas_report
zipArchive "reports" "data/out/report*.*" "reports"

###############
#data/out
###############
tryToPing $nas_out
zipArchive "data-out" "data/out/*" "data-out"

###############
#done
###############
tryToPing $nas_done
zipArchive "done" "done/*.*" "done"

###############
#ebrief
###############
tryToPing $nas_ebrief
[[ -d ${wdir}/data/ebriefout ]] || mkdir ${wdir}/data/ebriefout
zipArchive "ebrief" "data/ebriefout/*.*" "data/ebriefout"

###############
#data-processed
###############
tryToPing $nas_processed
zipArchive "data-processed" "data/processed/*.*" "data/processed"

#################################
#Move alle zipArchive Dateien ins Archiv
#################################
move "Daten_Eingang_Archiv" ${nas_Daten_Eingang_Archiv} "Daten_Eingang_Archiv" "Daten_Eingang_Archiv"
move "reports" ${nas_report} "data-report" "data/out/report*"
move "data-out" ${nas_out} "data-out" "data/out"
move "done" ${nas_done} "done" "done"
move "ebrief" ${nas_ebrief} "ebrief" "ebrief"
move "data-processed" ${nas_processed} "data-processed" "data/archiv"

###############
#logs						Die Logs werden hier gehousekeept, damit man alle Infos, auch von den moves, in den Log hat.
###############
tryToPing $nas_logs
zipArchive "logs" "logs/*.*" "logs"
move "logs" ${nas_logs} "logs" "logs"

touch "$logfile"
exec > >(tee -ia "$logfile")
exec 2> >(tee -ia "$logfile" >&2)
datumuhrzeit=$(date +%Y%m%d_%H%M%S)
echo "housekeeping finished at ${datumuhrzeit}"
echo "========================================"

rm ${wdir}/Daten_Eingang_Archiv/*
find ${wdir}/data/out/ -type f -delete
find ${wdir}/done/ -type f -delete
rm -R ${wdir}/done/*
rm ${wdir}/logs/*
rm ${wdir}/data/processed/*
rm ${wdir}/data/ebriefout/*.{pdf,xml,zipArchive}
rm -r ${wdir}/temp_*
rm ${wdir}/data/pool/*

RC=$?
fehlerHandling $RC "zippen Housekeeping"

exit $RC
