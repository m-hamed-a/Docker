#!/bin/bash

mkdir Backup > /dev/null 2>&1
#CONT="Contaner_Name"
read -p "Please enter the name of your intended container: " CONT
CONTL=`echo $CONT | tr [:upper:] [:lower:]`
#DH="Docker_Hub_Repository"
read -p "Please enter your DockerHub repository: " DH
DATE=`date +%Y%m%d%H%M%S`

echo "#### Backup Job Started; Backup Name: "$CONTL":V_"$DATE" ####" | tee -a ./Backup/backup.log

docker commit $CONT $CONTL:V_$DATE > /dev/null 2>&1

if [ $? -eq 0 ];then
	echo "Container exported successfully!" | tee -a ./Backup/backup.log
else
	echo "There is a problem in exporting of container!" | tee -a ./Backup/backup.log
	exit
fi

docker tag ${CONTL}:V_${DATE} $DH:${CONTL}_V_${DATE} > /dev/null 2>&1
docker save ${CONTL}:V_${DATE} > ./Backup/${CONTL}_V_${DATE}.tar > /dev/null 2>&1

if [ $? -eq 0 ];then
	echo "Backup stored in local storage(./Backup) successfully!" | tee -a ./Backup/backup.log
else
        echo "There is a problem in storing the backup locally!" | tee -a ./Backup/backup.log
	exit
fi

docker rmi ${CONTL}:V_${DATE} > /dev/null 2>&1

if [ $? -eq 0 ];then
        echo "Local format image deleted successfully!" | tee -a ./Backup/backup.log
else
        echo "There is a problem in deleting local format image!" | tee -a ./Backup/backup.log
        exit
fi

docker push ${DH}:${CONTL}_V_${DATE} > /dev/null 2>&1

if [ $? -eq 0 ];then
	echo "Backup pushed to DockerHub successfully!" | tee -a ./Backup/backup.log
else
        echo "There is a problem in pushing the backup to DockerHup!" | tee -a ./Backup/backup.log
	exit
fi

docker rmi ${DH}:${CONTL}_V_$DATE > /dev/null 2>&1

if [ $? -eq 0 ];then
	echo "DockerHub format image deleted successfully!" | tee -a ./Backup/backup.log
else
        echo "There is a problem in deleting DockerHub format image!" | tee -a ./Backup/backup.log
	exit
fi

echo "#### Backup Job Completed Successfully; Backup Name: "$CONTL":V_"$DATE" ####" | tee -a ./Backup/backup.log
