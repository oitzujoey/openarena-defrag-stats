#!/bin/bash

TEMPDIR=$1
BASEDIR=$2
DIR=$3
#   This will be placed in .openarena by default
STATSDIR=statistics
TIMEDIR=times
SPEEDDIR=speeds
#   Do you want multiple top times attributed to one person?
DUPLICATES=0
#   CRCON command
CRCON=crcon
#   Your rcon password
PASSWORD='password'
#   Server port. Localhost is assumed.
PORT='27960'

MAP='__unknown__'
PROMODE='__unknown__'

red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

echo "${grn}I/O Manager started${end}"

mkdir -p $DIR/$STATSDIR/vq3/$TIMEDIR
mkdir -p $DIR/$STATSDIR/vq3/$SPEEDDIR
mkdir -p $DIR/$STATSDIR/cpm/$TIMEDIR
mkdir -p $DIR/$STATSDIR/cpm/$SPEEDDIR

function rcon {
    $CRCON -p $PASSWORD -P $PORT localhost "$1"
}

while read -r LINE
do
    #   Display game output
#     echo "$LINE"
    
    
    #   Get user inputted commands
    CMD=$(echo $LINE | cut -f1 --delimiter=":" | tr -d '[:space:]')
    ARG1=$(echo $LINE | cut -f2 --delimiter=":" | tr -d '[:space:]')
    ARG2=$(echo $LINE | cut -f3- --delimiter=":" | tr -d '[:space:]')
    
    if [ "$CMD" == "say" ]
    then
        if [ "$ARG2" == "!help" ]
        then
            rcon 'say "Recognized commands"'
            rcon 'say "!times  Top times"'
            rcon 'say "!speeds Top speeds (Note: you must beat your local top speed to get on this list)"'
        fi
    fi
    
    #   Top times
    if [ "$CMD" == "say" ]
    then
        if [ "$ARG2" == "!times" ]
        then
            rcon 'say "Top times:"'
            for I in {1..5}
            do
                read -r CMDLINE
                rcon "$CMDLINE"
            done < $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat
        fi
    fi
    
    if [ "$CMD" == "say" ]
    then
        if [ "$ARG2" == "!speeds" ]
        then
            rcon 'say "Top speeds:"'
            for I in {1..5}
            do
                read -r CMDLINE
                rcon "$CMDLINE"
            done < $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat
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

echo "${grn}I/O Manager exited${end}"
