#!/bin/sh

# Separate list of database names by space
DATABASES="";
EMAIL="";

BZIP="0";
PATH="/var/www/dbbackups";

backup ()
{
	DATE=`/bin/date "+%A"`;
	DUMP="$DATABASE-$DATE";
	EXT1=".sql";
	EXT2=".tar";
	EXT3=".gz";
	EXT4=".bz2";

	# Locate the mysqldump and mail commands
	if [ -f /etc/redhat-release ]
	then
	    MAIL="/bin/mail";
	else
	    MAIL="/usr/bin/mail";
	fi

	if [ -e "/usr/bin/mysql" ]; then
        MYSQLDUMP="/usr/bin/mysqldump";
	else
        MYSQLDUMP="/usr/local/bin/mysqldump";
	fi

	# Create the MySQL dump
	# echo "$PATH/$DUMP$EXT1";
	$MYSQLDUMP --defaults-extra-file=/root/mysql.conf --add-drop-table $DATABASE >> "$PATH/$DUMP$EXT1";

	# Compress the dump
	cd $PATH;
	/bin/tar -cf $DATABASE-$DATE$EXT2 $DATABASE-$DATE$EXT1;

	# echo $BZIP;

	# Zip and Send mail - as an attachment
	if [ $BZIP -eq "0" ]
	then
		/bin/gzip -f $DATABASE-$DATE$EXT2;
	#	/usr/bin/uuencode $DUMP$EXT2$EXT3 $DUMP$EXT2$EXT3 |$MAIL -s "Mysql Backup For $DATABASE" $EMAIL ;
	elif [ $BZIP -eq "1" ]
	then
		/usr/bin/bzip2 $DATABASE-$DATE$EXT2;
	#	/usr/bin/uuencode $DUMP$EXT2$EXT4 $DUMP$EXT2$EXT4 |$MAIL -s "Mysql Backup For $DATABASE" $EMAIL ;
	fi

	# Remove the mysql dump (but still keep the compressed copy)
	/bin/rm -f $DUMP$EXT1;

	# Task complete
	cd;
}

# Function which backs up database one by one.
for DATABASE in $DATABASES
do
	# echo $DATABASE;
	backup;
done

exit;

