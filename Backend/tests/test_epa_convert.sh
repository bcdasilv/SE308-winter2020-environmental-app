#!/bin/bash

# test on the conversion of the existing EPA data to .json
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"  >/dev/null 2>&1 && pwd)"
SETTINGS="${THISDIR}/../scripts/settings.txt"

if [[ "$1" == "-n" ]]; then
   SETTINGS="Backend/scripts/settings_npm.txt"
fi

SCRIPTSDIR=$(grep -oP "(?<=^SCRIPTSDIR:).*" "$SETTINGS")
TESTDIR=$(grep -oP "(?<=^TESTDIR:).*" "$SETTINGS")
TESTDIR="${TESTDIR}epa/"
RAWDATADIR=$(grep -oP "(?<=^RAWDATADIR:).*" "$SETTINGS")
DATADIR=$(grep -oP "(?<=^DATADIR:).*" "$SETTINGS")
EPADIR=$(grep -oP "(?<=^EPADIR:).*" "$SETTINGS")
EPA_DATA_DIR="${DATADIR}${EPADIR}"
EPARAWDATADIR="${RAWDATADIR}${EPADIR}"
EPADATASOURCE=$(grep -oP "(?<=^EPADATASOURCE:).*" "$SETTINGS")
OUTFILE_END=$(grep -oP "(?<=^OUTFILE_END:).*" "$SETTINGS")
EPA_DATA_PREFIX=$(echo "$EPADATASOURCE" | grep -oP "^.*(?=.xls)")
EPA_DATA_FORMATTED="${EPA_DATA_PREFIX}${OUTFILE_END}"
EPA_DATA_FORMATTED_PATH="${EPA_DATA_DIR}${EPA_DATA_FORMATTED}"
EPA_TESTFILE_PATH="${TESTDIR}${EPA_DATA_FORMATTED}"

# make the directory if it doesn't exist on the remote server
if [[ ! -d "$TESTDIR" ]] ; then
   mkdir "$TESTDIR"
fi
# copy the original file to the test directory
cp "$EPA_DATA_FORMATTED_PATH" "$EPA_TESTFILE_PATH"

bash "$SCRIPTSDIR"convertEPAData.sh "$EPARAWDATADIR" "$EPADATASOURCE" "$1"


diff "$EPA_DATA_FORMATTED_PATH" "$EPA_TESTFILE_PATH"
res=$?

if [[ $res -ne 0 ]]; then
   # if the test fails, the bad output is moved into the test directory
   # for later inspection and the original is moved back
   mv "$EPA_DATA_FORMATTED_PATH" .
   mv "$EPA_TESTFILE_PATH" "$EPA_DATA_FORMATTED_PATH"
   mv "$EPA_DATA_FORMATTED" "$EPA_TESTFILE_PATH"
   cat "$EPA_TESTFILE_PATH"
   exit 1
else
   # if the result is identical to the original, the original is removed
   rm "$EPA_TESTFILE_PATH"
   exit 0
fi

