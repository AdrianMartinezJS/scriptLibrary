#!/bin/bash

input=$1
systemdir=$2
projekt=$3
from=$4
to=$5
wdir=$systemdir/$projekt

if [ $version != $version ]; then
version=current
echo "version=current"
fi

if [ $from != $from ]; then
	from="9"
echo "from=9"
fi

if [ $to != $to ]; then
to="28"
echo "to=28"
fi

if [ $# -eq 0 ]; then
    echo "No arguments provided"
    echo "Usage makemusterpdf.sh inputFile.pdf/.afp pathtoprojekt projekt frompage topage"
	exit 1
fi

echo "input	    :" $input
echo "systemdir	:" $systemdir
echo "projekt	:" $projekt
echo "version	:" $version
echo "wdir		:" $wdir
echo "from		:" $from
echo "to		:" $to

/app/dbMill/$version/bin/cpmcopy -lic /app/license/cppilot.lic -i $input -page $from..$to -o $wdir/data/out/Muster.pdf -type pdf
#/app/dbMill/$version/bin/cpmcopy -lic /app/license/cppilot.lic -i $wdir/data/out/*.PDF -page $from..$to -o $wdir/data/out/Muster.pdf -type pdf