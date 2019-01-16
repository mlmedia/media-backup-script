# Media Backup Script
BASH script that automatically syncs media folders to an S3 bucket.

NOTE: currently this script only supports syncing a single media directory on a server.

## Requirements
For this script to work as intended, you will need the following set up:
- **Server with Linux** installed as the operating system.  The following instructions work for a server running *Ubuntu 18.04 (Bionic Beaver)*.  Installation will likely be different on other operating systems and future versions.
- **SSH access** to the server, preferably using the SSH key handshake method.  For more information on installation, see https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-1804.
- **AWS** hosting account with the following:
	- **IAM** user with the user credentials saved for use below.  If you do not already have an IAM user set up, follow the instructions at https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console
	- **S3** instance set up with a bucket for use below.  If you do not have an S3 bucket set up, follow the instructions at https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html.

## Installation

### Put the script on your server
Upload the `media-backup.sh` backup script to your server, for example in a `~/__scripts/` directory.

First, SSH into the target server.  The below is for a generic user called *sshuser*.  You should replace with your specific values.  

See the **_Requirements_** section of this README if SSH is not already set up on your server.

```
ssh sshuser@yoursite.com
```
The commands below are to be made on command line in the server.

Download the file directly into the target directory using the WGET command and then change the permissions on the script to allow it to execute.

First, create the directory if it does not already exist.
```
mkdir ~/__scripts
```
Enter the directory to grab the backup script and change permissions to make it executable.
```
cd ~/__scripts &&
wget https://raw.githubusercontent.com/mlmedia/media-backup-script/master/media-backup.sh &&
chmod -R 755 ~/__scripts/media-backup.sh
```
### Install the AWS CLI
You should have your IAM credentials ready to use in the next step.  

If you do not already have an IAM user set up, see the **_Requirements_** section of this README.

```
sudo snap install aws-cli --classic &&
aws --version
```
Find and move bin to standard bin location:
```
sudo find / -name "aws" &&
sudo cp /snap/bin/aws /usr/local/bin
```

Test if cron will work with the script.
```
/bin/sh -c "(export PATH=/usr/bin:/bin:/usr/local/bin; ~/__scripts/media-backup.sh </dev/null)"
```

Configure the AWS CLI.
```
aws configure
```
When prompted, enter your AWS `Access Key ID` and `Secret Access Key` from your IAM user credentials.  You can hit return to accept the default (none) settings for `region name` and `output format`.

### Set config variables for the backup script
Set environment var for S3 bucket.  This presumes you have already set up a bucket under the S3 section in the above AWS account.  

If you do not already have an S3 bucket set up, see the **_Requirements_** section of this README.  

Create the S3MEDIABUCKET and MEDIADIR environment variables to the `/etc/environment` file so that it is accessible by cron.

```
sudo nano /etc/environment
```
Add the following line to the end of the file, using your S3 bucket name and target media directory.
```
S3MEDIABUCKET=your-bucket-name
MEDIADIR=/path/to/target/media/dir
```

Log out.

```
exit
```
Log back in again to register the new environment variable.

```
ssh sshuser@yoursite.com
```

### Test script
```
sh ~/__scripts/media-backup.sh
```
If the above script works and successfully uploads your media folder to your S3 bucket, the next step is to simply setup a cronjob to automatically run the script on a schedule that works for you.

### Crontab setup
Set up crontab to automatically run according to appropriate frequency.

Make a logs directory if it doesn't already exist.
```
mkdir ~/logs
crontab -e
```
When the cron file opens, add a line for the script to run with appropriate frequency with proper logging.

```
MAILTO="you@yoursite.com"
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
SHELL=/bin/bash
0 5 * * 1 $HOME/__scripts/media-backup.sh > $HOME/logs/media-backup-$(date +\%m\%d).log 2>&1
```

For example, the above it to set the script to run once a week at 5am on Monday.  In addition, the output will be logged to a file and time stamped.  

In order to delete the old logs on a regular basis, add the following line to the crontab.  The following will automatically run every day at 6am and delete log files older than 25 days.

```
0 6 * * * find $HOME/logs/*.log -mtime +25 -exec rm -f {} \; > /dev/null 2>&1
```

### More testing
Check your `~/logs` files and your S3 bucket for a few days to make sure it's working as expected.  
