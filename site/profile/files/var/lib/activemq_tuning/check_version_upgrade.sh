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

compare_result=$(echo "${AWAITED_VERSION} > ${CURRENT_VERSION}" | bc -l)
if [ "${compare_result}" == "1" ]; then
  # expression is verified, we need to update
  exit 0
else
  # We don't need to update
  exit 1
fi
