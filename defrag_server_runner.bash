#!/bin/bash

#   User configurable settings
#   Name displayed when running script
GAME='Defrag'
#   Directory containing server binary
BINDIR=/usr/local/games/defrag
#   Full name of server binary
SERVER=oa_ded.x86_64
#   Optional server arguments
SARGS="+set fs_homepath /home/joey/.defrag +set fs_basegame baseoa +set fs_game defrag +exec server.cfg"
#   Home directory for OpenArena
DIR=~/.defrag
#   baseoa
BASEDIR=$DIR/baseoa
#   Config "queue" directory. /tmp/ would be ideal, but that is slightly more difficult than I thought.
TEMPDIR=$BASEDIR/tmp
#   Script to call that manages server command input.
WRITER=defrag_server_writer.bash
#   Script to call that manages server command output.
READER=defrag_server_reader.bash


red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

#   Prepare the queue
mkdir $TEMPDIR 2>/dev/null
rm "$TEMPDIR/*" 2>/dev/null

mkdir /tmp/defrag-server-$$
LASTDIR=$(pwd)
cd /tmp/defrag-server-$$

mkfifo writerpid
mkfifo gamepid
mkfifo readerpid
mkfifo pipe

#   Run the game
printf "${blu}=== Starting $GAME ===${end}\n"

#   It seems the proper way to make Bash do something useful is to abuse it. On second thought, am I abusing it, or is Bash abusing me?
( $BINDIR/$WRITER $TEMPDIR <&0 & echo $! >writerpid & ) | ( $BINDIR/$SERVER $SARGS $@ & echo $! >gamepid & ) 2> >( $BINDIR/$READER $TEMPDIR $BASEDIR $DIR & )
#>(while read -r LINE ; do echo $LINE  ; done ; echo "Exited" &)
# echo $! >readerpid &
#| ($BINDIR/$READER < pipe & echo $! >readerpid & )
# ( $BINDIR/$SERVER $SARGS $@ & printf $! >gamepid & )
PID=$(cat gamepid)

#   Wait until the game exits
while kill -0 $PID &> /dev/null
do
    sleep 0.1
done

printf "${blu}=== $GAME exited ===${end}\n"

kill -s SIGTERM `cat writerpid`
# kill -s SIGTERM `cat readerpid`

cd $LASTDIR
rm /tmp/defrag-server-$$ -r

printf "${blu}=== Runner exiting ===${end}\n"
