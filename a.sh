#!/bin/bash

set -e

a=$(which mysql)
if [[ "$?" -eq 0 ]];
then echo "Success"
else
	echo "Failed"
fi
