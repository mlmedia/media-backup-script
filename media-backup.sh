#!/bin/bash

# config variables
HOME="/home/deploy";

# generate the SITENAME for the AWS directory from the formatted host
# - lowercase with hyphens only
HOSTNAME="$(hostname -f)";
SITENAME=`echo ${HOSTNAME} | tr [:upper:] [:lower:] | tr -c '[:alnum:]' '-' | tr ' ' '-' | tr -s '-'| sed 's/\-*$//'`;

# sync with Amazon S3 using the CLI (with server side encryption)
# install AWS CLI with instructions found here: https://linuxconfig.org/install-aws-cli-on-ubuntu-18-04-bionic-beaver-linux
# check for existence of environment variable
if [ -z "$S3MEDIABUCKET" ]
then
	echo "You need to set an ENVIRONMENT variable for the target S3MEDIABUCKET (e.g. export S3MEDIABUCKET=my-bucket-name)"
else
	aws s3 sync $HOME/__data s3://$S3MEDIABUCKET/$SITENAME --sse;
fi