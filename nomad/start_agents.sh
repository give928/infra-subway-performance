#!/bin/bash

BASEDIR=$(pwd)
echo "base directory: ${BASEDIR}"
nomad agent -dev -config=nomad.hcl -data-dir="${BASEDIR}/data" -alloc-dir="${BASEDIR}/alloc" -network-interface="eno2" > /dev/null 2>&1 &
echo "nomad agent pid: $!"
consul agent -dev > /dev/null 2>&1 &
echo "consul agent pid: $!"
