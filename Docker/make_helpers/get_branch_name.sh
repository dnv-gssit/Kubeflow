#!/bin/bash

# Returns branch name, regardless of whether run locally or on github runner


BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`


echo ${BRANCH_NAME}
