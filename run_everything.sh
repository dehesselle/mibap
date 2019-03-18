#!/usr/bin/env bash
# run-everything.sh
# https://github.com/dehesselle/mibap
#
# do everything "from source to app"

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
TIMESTAMP=$(date +%y%m%d%H%M%S)
LOG=$SELF_DIR/run_everything-$TIMESTAMP.log

{ time ./030-jhbuild-bootstrap.sh 2> 030-$TIMESTAMP.log ; } 2>>$LOG
{ time ./040-jhbuild-python2.sh 2> 040-$TIMESTAMP.log ; } 2>>$LOG
{ time ./050-jhbuild-gtk3.sh 2> 050-$TIMESTAMP.log ; } 2>>$LOG
{ time ./060-jhbuild-inkdeps.sh 2> 060-$TIMESTAMP.log ; } 2>>$LOG
{ time ./070-inkscape.sh 2> 070-$TIMESTAMP.log ; } 2>>$LOG

