#!/bin/bash

# generate the SITENAME for the AWS directory from the formatted host
# - lowercase with hyphens only
HOSTNAME="$(hostname -f)";
SITENAME=`echo ${HOSTNAME} | tr [:upper:] [:lower:] | tr -c '[:alnum:]' '-' | tr ' ' '-' | tr -s '-'| sed 's/\-*$//'`;

# sync with Amazon S3 using the CLI (with server side encryption)
# install AWS CLI with instructions found here: https://linuxconfig.org/install-aws-cli-on-ubuntu-18-04-bionic-beaver-linux
# check for existence of environment variable
if [ -z "$MEDIADIR" ]
then
	echo "You need to set the MEDIADIR environment variable for the target media directory (e.g. MEDIADIR=/var/www/yoursite/uploads)";
elif [ -z "$S3MEDIABUCKET" ]
then
	echo "You need to set the S3MEDIABUCKET environment variable for the S3 bucket name (e.g. S3MEDIABUCKET=my-bucket-name)";
else
	echo "Synching media to AWS";
	aws s3 sync $MEDIADIR s3://$S3MEDIABUCKET/$SITENAME --sse;
fi
