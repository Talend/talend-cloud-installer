#!/bin/sh
# exit 0 if upgrade needed, 1 otherwise, 2 if error
set -e
sql_file=$1
version_max_file=$2

CURRENT_VERSION=$(head -n 1 ${version_max_file})
AWAITED_VERSION=$(head -n 1 ${sql_file} | grep 'version' | sed "s/[;']//g" | cut -d ' ' -f 3)

if [ -z "${AWAITED_VERSION}" ]; then
  echo "Error, AWAITED_VERSION is empty"
  exit 2
fi
if [ -z "${CURRENT_VERSION}" ]; then
  # no current version (never used ?)
  exit 0
fi

if [ "${AWAITED_VERSION}" > "${CURRENT_VERSION}" ]; then
  exit 0
else
  exit 1
fi
