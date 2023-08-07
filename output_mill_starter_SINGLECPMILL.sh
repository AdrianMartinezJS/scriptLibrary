#!/bin/bash

ctm_job=$1
ctm_ctrid=$2
systemdir=$3
projekt=$4

wdir=$systemdir/$projekt

echo ""
echo "ctm_job		:" $ctm_job	
echo "ctm_ctrid	:" $ctm_ctrid	
echo "systemdir	:" $systemdir	
echo "projekt		:" $projekt	
echo "wdir		:" $wdir

conf_pilot_path=$wdir/temp/conf_pilot.xml
handler_dbe_path=$wdir/conf/XINCLUDE/HANDLER.DBE

echo "conf_pilot_path		:" $conf_pilot_path
echo "handler_dbe_path		:" $handler_dbe_path
echo ""

cpmill_path=""
declare -a cpmill_params
declare -a printjob_cfgs
declare -a cpmill_files
cpmill_params_string=""
cpmill_license="/app/license/cppilot.lic"

PRINTJOBCFG=""
KEEPOPENSTRATEGY=""
KEEPOPENCOUNT=""
DISABLEJOBINFOFILE=""
JOBINFOFILEDIRECTORY=""

found_searched=false

echo "Reading $conf_pilot_path"

while read line
do
	if $found_searched
	then
		if [[ $line == *"<PRINTJOBCFGID>"*"</PRINTJOBCFGID>"* ]]
		then
			param_val=$(echo "$line" | sed -e 's/<PRINTJOBCFGID>\(.*\)<\/PRINTJOBCFGID>/\1/')
			printjob_cfgs+=("$param_val")
			found_searched=false
		fi
	else
		if [[ $line == *"<PRINTJOBCFG>" ]]
		then
			found_searched=true
		fi
	fi
done <"$conf_pilot_path"

found_searched=false

echo ""
echo "Which cpmill file would you like to produce?"
echo "Showing .cpmill files from $wdir/data/in"
index=0
for entry in `ls $wdir/data/in/*.cpmill`
do
	entry=$(basename $entry)
	cpmill_files+=("$entry")
	echo "$index) $entry"
	((index=index+1))
done
read index
echo ""

CPMILLFILENAME=${cpmill_files[$index]}

echo "Which PRINTJOBCFG would you like to use?"
index=0
for value in "${printjob_cfgs[@]}"
do
	echo "$index) $value"
	((index=index+1))
done
read index
echo ""

PRINTJOBCFG=${printjob_cfgs[$index]}

if [ "$PRINTJOBCFG" = "" ]
then
	echo "PRINTJOBCFG is not valid. Closing."
	exit 1
fi

echo "Reading $handler_dbe_path"

while read line
do
	if $found_searched
	then
		case "$line" in
			*"<KeepOpenStrategy>"*"</KeepOpenStrategy>"*)
				KEEPOPENSTRATEGY=$(echo "$line" | sed -e 's/<KeepOpenStrategy>\(.*\)<\/KeepOpenStrategy>/\1/')
				;;
			*"<KeepOpenCount>"*"</KeepOpenCount>"*)
				KEEPOPENCOUNT=$(echo "$line" | sed -e 's/<KeepOpenCount>\(.*\)<\/KeepOpenCount>/\1/')
				;;
			*"<DisableJobInfoFile>"*"</DisableJobInfoFile>"*)
				DISABLEJOBINFOFILE=$(echo "$line" | sed -e 's/<DisableJobInfoFile>\(.*\)<\/DisableJobInfoFile>/\1/')
				;;
			*"<JobInfoFileDirectory>"*"</JobInfoFileDirectory>"*)
				JOBINFOFILEDIRECTORY=$(echo "$line" | sed -e 's/<JobInfoFileDirectory>\(.*\)<\/JobInfoFileDirectory>/\1/')
				;;
			*"</HandlerDefinition>"*)
				found_searched=false
				;;
		esac
	else
		if [[ $line == *"<HandlerDefinition Id=\"$PRINTJOBCFG\" xsi:type=\"ProduceJobHandler\">" ]]
		then
			found_searched=true
		fi
	fi
done <"$handler_dbe_path"

echo "Reading $conf_pilot_path again"

while read line
do
	if $found_searched
	then
		case "$line" in
		*"<PROGPATH>"*"</PROGPATH>"*)	
			cpmill_path=$(echo "$line" | sed -e 's/<PROGPATH>\(.*\)<\/PROGPATH>/\1/')
			cpmill_path=$cpmill_path/cpmill
			echo "Read cpmill_path = $cpmill_path"
			found_searched=false
			;;
		*"<PARAMETER>"*"</PARAMETER>"*)
			param_val=$(echo "$line" | sed -e 's/<PARAMETER>\(.*\)<\/PARAMETER>/\1/')
			echo "Read param ${#cpmill_params[@]} = $param_val"
			found_searched=false
			if [ "${param_val:0:1}" = "\$" ]
			then
				case "$param_val" in
				"\$PROFILEDIR") param_val="-DPROFILEDIR=$wdir/conf/profiles/output/" ;;
				"\$LOGNAME") date_now=$(date '+%Y%m%d-%H%M%S') ; param_val="-DLOGNAME=cpmill-output-manuell_$projekt_$date_now.log" ;;
				"\$TRACE") date_now=$(date '+%Y%m%d-%H%M%S') ; param_val="-DTRACE=cpmill-output-manuell_$projekt_$date_now.trc" ;;
				"\$PRINTJOBCFGID") param_val="-DPRINTJOBCFGID=$PRINTJOBCFG" ;;
				"\$KEEPOPENCOUNT") param_val="-DKEEPOPENCOUNT=$KEEPOPENCOUNT" ;;
				"\$KEEPOPENSTRATEGY") param_val="-DKEEPOPENSTRATEGY=$KEEPOPENSTRATEGY" ;;
				"\$DISABLEJOBINFOFILE") param_val="-DKEEPOPENCOUNT=$DISABLEJOBINFOFILE" ;;
				"\$JOBINFOFILEDIRECTORY") param_val="-DKEEPOPENCOUNT=$JOBINFOFILEDIRECTORY" ;;
				"\$CPMILLFILENAME") param_val="-DCPMILLFILEMASK=$wdir/data/in/$CPMILLFILENAME" ;;
				*) echo "Warning, unaccounted variable (\"$param_val\") found, cpmill might not work correctly now."
				esac
			else 
				if [ "${param_val:0:1}" = "/" ]
				then
					cpmill_params+=("-DOCPILOT_OUTPUT=true")
					echo "Added param ${#cpmill_params[@]} = -DOCPILOT_OUTPUT=true"
					cpmill_params+=("-DDOCSINSPOOL=10")
					echo "Added param ${#cpmill_params[@]} = -DDOCSINSPOOL=10"
				fi
			fi
			cpmill_params+=("$param_val")
			;;
		*)
			;;
		esac
	else	
		if [[ $line == *"<CMDID>cpmill-output</CMDID>"* ]]
		then
			found_searched=true
		fi
	fi
done <"$conf_pilot_path"

echo ""

for value in "${cpmill_params[@]}"
do
	echo "Using param $value"
	cpmill_params_string="$cpmill_params_string $value"
done

echo ""

${cpmill_path} -L${cpmill_license} ${cpmill_params_string}
echo ${cpmill_path} -L${cpmill_license} "${cpmill_params_string}"
