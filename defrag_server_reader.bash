#!/bin/bash

TEMPDIR=$1
BASEDIR=$2
DIR=$3
STATSDIR=statistics
TIMEDIR=times
SPEEDDIR=speeds
DUPLICATES=0

MAP='__unknown__'
PROMODE='__unknown__'

mkdir -p $DIR/$STATSDIR/vq3/$TIMEDIR
mkdir -p $DIR/$STATSDIR/vq3/$SPEEDDIR
mkdir -p $DIR/$STATSDIR/cpm/$TIMEDIR
mkdir -p $DIR/$STATSDIR/cpm/$SPEEDDIR

red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

while read -r LINE
do
    #   Display game output
    echo "$LINE"
    
    
    #   Get user inputted commands
    CMD=$(echo $LINE | cut -f1 --delimiter=":" | tr -d '[:space:]')
    ARG1=$(echo $LINE | cut -f2 --delimiter=":" | tr -d '[:space:]')
    ARG2=$(echo $LINE | cut -f3- --delimiter=":" | tr -d '[:space:]')
    
    if [ "$CMD" == "say" ]
    then
        if [ "$ARG2" == "!help" ]
        then
            echo 'say "Recognized commands"' > /tmp/help.cfg
            echo 'say "!times  Top times"' >> /tmp/help.cfg
            echo 'say "!speeds Top speeds"' >> /tmp/help.cfg
            mv /tmp/help.cfg $TEMPDIR/
        fi
    fi
    
    if [ "$CMD" == "say" ]
    then
        if [ "$ARG2" == "!times" ]
        then
            echo 'say "Top times:"' > /tmp/times.cfg
            head -n5 $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat >> /tmp/times.cfg
            mv /tmp/times.cfg $TEMPDIR/
        fi
    fi
    
    if [ "$CMD" == "say" ]
    then
        if [ "$ARG2" == "!speeds" ]
        then
            echo 'say "Top speeds:"' > /tmp/speeds.cfg
            head -n5 $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat >> /tmp/speeds.cfg
            mv /tmp/speeds.cfg $TEMPDIR/
        fi
    fi
    
    #   Store user and time on level completion
    SUBCMD=$(echo $LINE | cut -f6 --delimiter=" " | tr -d '[:space:]')
    ARG1=$(echo $LINE | cut -f3 --delimiter=" " | tr -d '[:space:]')
    ARG1=${ARG1#"\""}
    ARG1=${ARG1%"^7"}
    ARG2=$(echo $LINE | cut -f9 --delimiter=" " | tr -d '[:space:]' | sed -e 's/\^2//' -e 's/\^7\\n"//')
    
    if [ "$CMD" == "broadcast" ] && [ "$SUBCMD" == "finish" ]
    then
        echo "say $ARG1^5 $ARG2" >> $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat
        sort -g -t ' ' -k 3 $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat -o $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat
        
        if [ "$DUPLICATES" == '0' ]
        then
            AWKOUT="$(awk '!seen[$2]++' $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat)"
            echo "$AWKOUT" > $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat
        fi
    fi
    
    #   Store user and speed on level completion
    ARG1=$(echo $LINE | cut -f3 --delimiter=" " | tr -d '[:space:]')
    ARG2=$(echo $LINE | cut -f4 --delimiter=" " | tr -d '[:space:]')
    ARG2=${ARG2#"\""}
    ARG2=${ARG2%"\""}
    
    if [ "$CMD" == "ClientSpeedAward" ]
    then
        echo "say $ARG2^5 $ARG1" >> $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat
        sort -g -t ' ' -k 3 $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat -o $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat
        
        if [ "$DUPLICATES" == '0' ]
        then
            AWKOUT="$(awk '!seen[$2]++' $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat)"
            echo "$AWKOUT" > $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat
        fi
    fi
    
    #   Get map name
    CMD=$(echo $LINE | cut -f1 --delimiter=" " | tr -d '[:space:]')
    ARG1=$(echo $LINE | cut -f2 --delimiter=" " | tr -d '[:space:]')
    
    if [ "$CMD" == "Server:" ]
    then
        MAP=$ARG1
    fi
    
    #   Determine if promode is on
    CMD=$(echo $LINE | cut -f1 --delimiter=" " | tr -d '[:space:]')
    ARG1=$(echo $LINE | cut -f2 --delimiter=" " | tr -d '[:space:]')
    
    if [ "$CMD" == "InitGame:" ]
    then
        searchstring='df_promode'
        rest=${LINE#*$searchstring}
        if [ "${LINE:$(( ${#LINE} - ${#rest} + 1 )):1}" == "1" ]
        then
            PROMODE='cpm'
        else
            PROMODE='vq3'
        fi
    fi
    
done

echo "Reader exited"
