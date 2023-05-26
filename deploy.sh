echo "********** DEploymeny AUtomation ***********"
echo " Author Mattaparthi Mohan"

echo " Last update - 03-04-2019"


function stopServices()
{
  echo "**** Stopping the Tomcat services ****"
  echo "The input path param: $1"
  ssh root@192.168.146.129 "sh $1/bin/shutdown.sh"
  if [ $? -eq 0 ]
  then
    echo "***** Tomcat has bee succesfully stopped***"
  else
   echo "***** Tomcat having issues in stopping***"
  fi
  ssh root@192.168.146.129 'sleep 3'
}

function startServices()
{
  echo "**** Starting the Tomcat services ****"
  ssh root@192.168.146.129 "sh $1/bin/startup.sh"
  if [ $? -eq 0 ]
  then
    echo "***** Tomcat has bee succesfully started***"
  else
   echo "***** Tomcat having issues in starting***"
  fi
  ssh root@192.168.146.129 'sleep 8'
}
function backupServices()
{
  echo "**** Backup the Tomcat war services ****"
  ssh root@192.168.146.129  "mv $1/webapps/leadapp.war /root/backup" 
  ssh root@192.168.146.129  "rm -rf $1/webapps/leadapp"
 
  echo "***** Tomcat war fiel backup has been complete ***"
 
}

function dbBackup()
{
  echo "**** DB Backup services ****"
  ssh root@192.168.146.129  "mysqldump -u lead -plead leadapp > /root/backup/leadapp_bkp.sql"
  echo "***** DB backup has been complete ***"

}

function dbDeploy()
{
  echo "**** DB Deployment started ****"
  scp src/database/schema.sql root@192.168.146.129:$1
 
  ssh root@192.168.146.129  "mysql -u $2 -p$3 < $1/schema.sql"
  echo "***** DB deployment has been complete ***"

}

function appDeploy()
{
  echo "**** App Deployment started ****"
  scp dist/lib/leadapp.war root@192.168.146.129:$1/webapps

}

function localiseApp()
{
  echo "**** Localisation Deployment started ****"
  ssh root@192.168.146.129 "sed -i 's/DB_IP/localhost/g' $1/webapps/leadapp/WEB-INF/classes/hibernate.cfg.xml"
ssh root@192.168.146.129 "sed -i 's/DB_NAME/leadapp/g' $1/webapps/leadapp/WEB-INF/classes/hibernate.cfg.xml"
ssh root@192.168.146.129 "sed -i 's/DB_USER/lead/g' $1/webapps/leadapp/WEB-INF/classes/hibernate.cfg.xml"
ssh root@192.168.146.129 "sed -i 's/DB_PWD/lead/g' $1/webapps/leadapp/WEB-INF/classes/hibernate.cfg.xml"
}

if [ $# -eq 1 ]
then
if [ $1 == "all" ]
then

stopServices "/root/apache-tomcat-8.0.15"

backupServices "/root/apache-tomcat-8.0.15"

dbBackup

dbDeploy "/root/Artifacts" lead lead

appDeploy "/root/apache-tomcat-8.0.15"

startServices "/root/apache-tomcat-8.0.15"

localiseApp "/root/apache-tomcat-8.0.15"

stopServices "/root/apache-tomcat-8.0.15"

startServices "/root/apache-tomcat-8.0.15"

elif [ $1 == "backup" ]
then

stopServices "/root/apache-tomcat-8.0.15"
backupServices "/root/apache-tomcat-8.0.15"

elif [ $1 == "stop" ]
then

  stopServices "/root/apache-tomcat-8.0.15"
elif [ $1 == "appdeploy" ]
then

 appDeploy "/root/apache-tomcat-8.0.15"

elif [ $1 == "dbbackup" ]
then

dbBackup

elif [ $1 == "start" ]
then

  startServices "/root/apache-tomcat-8.0.15"

elif [ $1 == "dbdeploy" ]
then

  dbDeploy "/root/Artifacts" lead lead

else
 echo Wrong option
fi
else
 echo Please provide atelast one option
 echo Helo

fi


