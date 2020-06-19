#!/bin/bash

BASEDIR=$1
DIR=$2
PIPE=$DIR/defrag/$3
#   This will be placed in .openarena by default
STATSDIR=statistics
TIMEDIR=times
SPEEDDIR=speeds
#   Do you want multiple top times attributed to one person?
DUPLICATES=0
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

SORTTEMP=$(mktemp)

function timesort {
    cat $1 | awk -F' ' '{print($NF" "$0)}' | sort -t ' ' -k 1 | cut -f2- -d' ' > ${SORTTEMP}
    cat $SORTTEMP > $1
}

function speedsort {
    cat $1 | awk -F' ' '{print($NF" "$0)}' | sort -r -t ' ' -k 1 | cut -f2- -d' ' > ${SORTTEMP}
    cat $SORTTEMP > $1
}

while read -r LINE
do
    #   Get user inputted commands
    CMD=$(echo $LINE | cut -f1 --delimiter=":" | tr -d '[:space:]')
    ARG1=$(echo $LINE | cut -f2 --delimiter=":" | tr -d '[:space:]')
    ARG2=$(echo $LINE | rev | cut -f1 -d' ' | rev | tr -d '[:space:]')
    ARG3=$(echo $LINE | rev | cut -f2 -d' ' | rev | tr -d '[:space:]')

    if [ "$CMD" == "say" ]
    then
        if [ "$ARG2" == "!help" ]
        then
            echo 'say "^3Recognized commands"' > $PIPE
            echo 'say "^2!times ^5[^2n^5]   ^3Top times"' > $PIPE
            echo 'say "^2!speeds ^5[^2n^5]  ^3Top speeds (Note: you must beat your local top speed to get on this list)"' > $PIPE
        fi
        
        #   List top times
        if [ "$ARG2" == "!times" ] || [ "$ARG2" == "!top" ]
        then
            echo 'say "Top times:"' > $PIPE
            
            I=1
            while [ "$I" -le "5" ]
            do
                read -r CMDLINE
                echo "$CMDLINE" > $PIPE
                I=$((I + 1))
            done < $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat
        fi
        
        #   List top times + parameter
        if [ "$ARG3" == "!times" ] || [ "$ARG3" == "!top" ]
        then
            echo 'say "Top times:"' > $PIPE
            
            I=1
            while [ "$I" -le "${ARG2:-5}" ]
            do
                read -r CMDLINE
                echo "$CMDLINE" > $PIPE
                I=$((I + 1))
            done < $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat
        fi
        
        #   List top speeds
        if [ "$ARG2" == "!speeds" ]
        then
            echo 'say "Top speeds:"' > $PIPE
            
            I=1
            while [ "$I" -le "5" ]
            do
                read -r CMDLINE
                echo "$CMDLINE" > $PIPE
                I=$((I + 1))
            done < $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat
        fi
        
        #   List top speeds + parameter
        if [ "$ARG3" == "!speeds" ]
        then
            echo 'say "Top speeds:"' > $PIPE
            
            I=1
            while [ "$I" -le "${ARG2:-5}" ]
            do
                read -r CMDLINE
                echo "$CMDLINE" > $PIPE
                I=$((I + 1))
            done < $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat
        fi
    fi
    
    #   Store user and time on level completion
    SUBCMD=$(echo $LINE | rev | cut -f4 -d' ' | rev | tr -d '[:space:]')
    ARG1=$(echo $LINE | rev | cut -f7- -d' ' | rev | cut -f3- -d' ')
    ARG1=${ARG1#"\""}
    ARG1=${ARG1%"^7"}
    ARG2=$(echo $LINE | rev | cut -f1 -d' ' | rev | tr -d '[:space:]' | sed -e 's/\^2//' -e 's/\^7\\n"//')
    
    if [ "$CMD" == "broadcast" ] && [ "$SUBCMD" == "finish" ]
    then
        COUNT=$(echo $ARG2 | awk -F':' '{print NF-1}')
        
        #   Add a leading zero to the time if necessary.
        if [ "$COUNT" == '1' ]
        then
            ARG2="0:$ARG2"
        fi
        
        echo "say $ARG1^5 $ARG2" >> $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat
        timesort $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat
        
        if [ "$DUPLICATES" == '0' ]
        then
            AWKOUT="$(awk '!seen[$2]++' $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat)"
            echo "$AWKOUT" > $DIR/$STATSDIR/$PROMODE/$TIMEDIR/$MAP.stat
        fi
    fi
    
    #   Store user and speed on level completion
    ARG1=$(echo $LINE | cut -f3 --delimiter=" " | tr -d '[:space:]')
    ARG2=$(echo $LINE | cut -f4- -d' ')
    ARG2=${ARG2#"\""}
    ARG2=${ARG2%"\""}
    
    if [ "$CMD" == "ClientSpeedAward" ]
    then
        echo "say $ARG2^5 $ARG1" >> $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat
        speedsort $DIR/$STATSDIR/$PROMODE/$SPEEDDIR/$MAP.stat
        
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

rm -f SORTTEMP

echo "${grn}I/O Manager exited${end}"
