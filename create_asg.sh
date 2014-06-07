#!/bin/bash

NAME=$1
if [ "${NAME}" == "" ] ; then
	echo "Usage: `basename $0` <name>"
	exit 1
fi

set -eu

AMI="ami-fb8e9292"
INSTANCE_TYPE="m3.medium"
TARGET="target"

# create target container
mkdir -p ${TARGET}

aws ec2 create-key-pair --key-name ${NAME} | tee -a ${TARGET}/${NAME}.json
cat ${TARGET}/${NAME}.json | jq -r '.KeyMaterial' > ${TARGET}/${NAME}.pem
chmod 600 ${TARGET}/${NAME}.pem

`dirname $0`/create_user_data.sh ${NAME}

# create the launch configuration
aws autoscaling create-launch-configuration \
	--key-name ${NAME} \
	--launch-configuration-name ${NAME}-launch-config \
	--image-id ${AMI} \
	--instance-type ${INSTANCE_TYPE} \
	--user-data file://${TARGET}/${NAME}.data

# --user-data {filename}

# list the asg's we have
aws autoscaling describe-launch-configurations

# create the asg
aws autoscaling create-auto-scaling-group \
	--auto-scaling-group-name ${NAME}-asg \
	--launch-configuration-name ${NAME}-launch-config \
	--min-size 1 \
	--max-size 1 \
	--availability-zones us-east-1d


