#!/bin/bash

DATE=`date '+%Y-%m-%d'`
MYSQL_BACKUP=/data/backup/ampache-$DATE.sql
AMPACHE_DIR=/data/ampache
AMPACHE_BACKUP_DIR=/data/ampache-backup-$DATE
TMP_ZIP=/tmp/ampache-$1.zip

if [ -z "$1" ]; then
echo "Must pass Ampache version to download as an argument";
exit 1;
fi

# Stopping Apache during process
echo "Stopping Apache"
systemctl stop apache2.service

# Make a dump before updating
echo "Dumping ampache database"
mysqldump ampache > $MYSQL_BACKUP

# Downloading archive from github project release page
echo "Downloading Ampache Archive"
curl -L -4 https://github.com/ampache/ampache/releases/download/$1/ampache-$1_all.zip -o $TMP_ZIP

# Backup existing Ampache folder
echo "Backup previous version"
mv $AMPACHE_DIR $AMPACHE_BACKUP_DIR

# Uncompress downloaded archive into ampache folder
echo "Uncompress and copying config file"
unzip -q $TMP_ZIP -d $AMPACHE_DIR
chown -R www-data: $AMPACHE_DIR
cp $AMPACHE_BACKUP_DIR/config/ampache.cfg.php $AMPACHE_DIR/config/

# Starting Apache service
echo "Starting Apache"
systemctl start apache2.service

# Cleaning downloaded files
echo "Cleaning ZIP file"
rm $TMP_ZIP
