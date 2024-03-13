#!/bin/bash
# Script de sauvegarde des fichiers de backup du container joplin: script_backup_rsync_joplin.sh
# Version 00 12 Novembre 2023
# Ce script fait une sauvegarde de la base de données postgres du container joplin-db
# donc les deux containers joplin et joplin-db doivent etre demarres sur le noeud OrangePi5
# Script en cours de validation 11/mars/24 18h43
# Script a executer en etant connecte en user Postgres
set -x
# Répertoire du container joplin
joplin=/share_orangepi5/docker/joplin 
# Répertoire de stockage des fichiers à sauvegarder
BACKUPDIR=$joplin/backup
BACKUPDIR1=$joplin
# Fichier de log
LOG=$joplin/backup_joplin_$(date +%Y%m%d_%H%M%S).log
# Configuration des paramètres de l'email
# "Sujet: Sauvegarde joplin " cosson.patrice@gmail.com -aFrom:cosson.patrice.joplin@gmail.com
SUBJECT="Sauvegarde_joplin_du_"$(date +%Y%m%d_%H%M%S)
FROM="cosson.patrice.joplin@gmail.com"
TO="cosson.patrice@gmail.com"
# Répertoire de sauvegarde sur le NAS Synology de la sauvegarde joplin
BACKUPDIRNAS="patrice@192.168.1.204:/volume1/NetBackup"
# Redirection de toutes les sorties du script vers le fichier de log
# exec 1>$LOG 2>&1
# Vérifier si l'utilisateur est "postgres"
if [ "$(whoami)" == "postgres" ]; then
    echo "L'utilisateur est postgres. Exécution du script..."
else
    echo "L'utilisateur n'est pas postgres. Le script ne sera pas exécuté."
    exit
fi
{ 
date
echo "Début de la sauvegarde des fichiers du container joplin"
# On commence par supprimer la dernière sauvegarde
# echo "Suppression des fichiers des anciennes sauvegardes"  >> $LOG
# cd $BACKUPDIR
# rm $BACKUPDIR/*
# Sauvegarde de la base de donnée Postgres
  cd $BACKUPDIR || exit
  echo "Date et heure de la sauvegarde de la base de donnée Postgres"
  docker exec -it joplin-db bash -c 'date +%Y%m%d_%H%M%S'
  echo "Sauvegarde de la base de donnée Postgres"
  docker exec -it joplin-db bash -c 'pg_dump -O -U joplin -w joplin | gzip > "/var/lib/postgresql/data/joplin_backup_database_`date +%Y%m%d_%H%M%S`.sql.gz"'
  echo "Le code Retour est" $?
# On vérifie si le fichier de sauvegarde de la base de données a bien été créé
  find $joplin/data/*sql.gz
# On le déplace dans backup
  echo "On déplace le fichier de sauvegarde de la base de donnée dans backup"
  mv $joplin/data/joplin_backup_database*.sql.gz $BACKUPDIR
  echo "Le code Retour est" $?
# Liste des fichiers sauvegardés dans backup
  find $BACKUPDIR/*sql.gz
  echo "Liste des fichiers sauvegardés dans backup"
# Arret du container
  echo "Arret du Container joplin-db"
  docker stop joplin-db
  echo "Le code Retour est" $?
  docker ps -a | grep joplin-db
  find $BACKUPDIR/*gz
# On copie les fichiers sauvegardés et le répertoire des containers joplin sur le NAS synology avec rsync
# BACKUPDIRNAS="patrice@192.168.1.204:/volume1/NetBackup/joplin/backup"
  echo "Copie de la sauvegarde des fichiers joplin sur le NAS Synology via rsync"
  /usr/bin/rsync -ratlz --rsh="/usr/bin/sshpass -p Pyc1012%% ssh -p 2200 -o StrictHostKeyChecking=no -l patrice" $BACKUPDIR1 $BACKUPDIRNAS --progress
  echo "Le code Retour est" $?
  date
# Demarrage du container
echo "Demarrage du Container joplin"
docker start joplin-db
echo "Le code Retour est" $?
docker ps -a | grep joplin-db
} >> "$LOG" 2>&1 
# Envoi par email de la log
echo "Envoi d'un email avec le contenu de la log d'execution du script de sauvegarde"
cat "$LOG" | mail -s "$SUBJECT" "$TO" -aFrom:"$FROM"  2>&1
echo "Le code Retour est" $? 2>&1
echo "Fin du script de sauvegarde" 2>&1