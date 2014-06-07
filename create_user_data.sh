#!/bin/sh

NAME=$1
if [ "${NAME}" == "" ] ; then
	echo "Usage: `basename $0` <name>"
	exit 1
fi

TARGET="target"

# create target container
mkdir -p ${TARGET}

cat <<EOF > ${TARGET}/${NAME}.data
#!/bin/bash

# Install ImageMagick, a Python library, and create a directory
yum install -y ImageMagick 
yum -y install python python-pip uuid 
easy_install argparse
mkdir /home/ec2-user/jobs

# Download and install the batch processing script
wget -O /home/ec2-user/image_processor.py https://awsu-arch.s3.amazonaws.com/aux/technical-exercises/day-2/lab_1_create_batch_processing_cluster/image_processor.py

export AWS_DEFAULT_REGION="us-east-1"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"

#------------------------------------------------------------------
#
# REPLACE PARAMETERS WITH YOUR QUEUE NAMES
export INPUT_QUEUE=${NAME}-input
export OUTPUT_QUEUE=${NAME}-output
export S3_BUCKET=${NAME}-\$(uuid)

aws sqs create-queue --queue-name \${INPUT_QUEUE}
aws sqs create-queue --queue-name \${OUTPUT_QUEUE}

aws s3api create-bucket --bucket \${S3_BUCKET}


# Launch two processes to do work
/usr/bin/python /home/ec2-user/image_processor.py --input-queue \$INPUT_QUEUE --output-queue \$OUTPUT_QUEUE --s3-output-bucket \$S3_BUCKET &
/usr/bin/python /home/ec2-user/image_processor.py --input-queue \$INPUT_QUEUE --output-queue \$OUTPUT_QUEUE --s3-output-bucket \$S3_BUCKET &

EOF


