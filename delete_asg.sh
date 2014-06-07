#!/bin/bash

NAME=$1
if [ "${NAME}" == "" ] ; then
	echo "Usage: `basename $0` <name>"
	exit 1
fi

# Delete the Auto Scaling group
aws autoscaling delete-auto-scaling-group \
	--force-delete \
	--auto-scaling-group-name ${NAME}-asg

# Delete the Auto Scaling launch config:
aws autoscaling delete-launch-configuration \
	--launch-configuration-name ${NAME}-launch-config 
