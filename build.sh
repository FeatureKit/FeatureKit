#!/bin/bash

# Exits bash immediately if any command fails
set -e

# Will output commands as the run
set -x

# Want to know what ENV varibles Buildbox sets during the build?
env | grep BUILDBOX

# Update the submodules
git submodule update --init --recursive --remote

./buildscripts/pods.sh
./buildscripts/test.sh -s DNTFeatures
