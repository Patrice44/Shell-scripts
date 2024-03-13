#!/bin/bash
# Script de sauvegarde des fichiers de backup du container bookstack: script_backup_rsync_bookstack.sh
# Version 00 12 mars 2024
# Ce script fait une sauvegarde de la base de données mariadb du container bookstack_mariadb
# donc les deux containers bookstack et bookstack_mariadb doivent etre demarres sur le noeud OrangePi5
# Script en cours de validation / OK le 12/mars/24 23h23 
# Script a executer en etant connecte en user patrice
set -x
# Répertoire du container bookstack
bookstack=/share_orangepi5/docker/bookstack 
# Répertoire de stockage des fichiers à sauvegarder
BACKUPDIR=$bookstack/mariadb/backup
BACKUPDIR1=$bookstack
# Fichier de log
LOG=$bookstack/backup_bookstack_$(date +%Y%m%d_%H%M%S).log
# Configuration des paramètres de l'email
# "Sujet: Sauvegarde bookstack " cosson.patrice@gmail.com -aFrom:cosson.patrice.bookstack@gmail.com
SUBJECT="Sauvegarde_bookstack_du_"$(date +%Y%m%d_%H%M%S)
FROM="cosson.patrice.bookstack@gmail.com"
TO="cosson.patrice@gmail.com"
# Répertoire de sauvegarde sur le NAS Synology de la sauvegarde bookstack
BACKUPDIRNAS="patrice@192.168.1.204:/volume1/NetBackup"
# Redirection de toutes les sorties du script vers le fichier de log
# exec 1>$LOG 2>&1
# Vérifier si l'utilisateur est "patrice"
if [ "$(whoami)" == "patrice" ]; then
    echo "L'utilisateur est patrice. Exécution du script..."
else
    echo "L'utilisateur n'est pas patrice. Le script ne sera pas exécuté."
    exit
fi
{ 
date
echo "Début de la sauvegarde des fichiers du container bookstack"
# On commence par supprimer la dernière sauvegarde
# echo "Suppression des fichiers des anciennes sauvegardes"  >> $LOG
# cd $BACKUPDIR
# rm $BACKUPDIR/*
# Sauvegarde de la base de donnée mariadb
# cd $BACKUPDIR || exit
  echo "Date et heure de la sauvegarde de la base de donnée mariadb"
  docker exec -it bookstack_mariadb bash -c 'date +%Y%m%d_%H%M%S'
  echo "Sauvegarde de la base de donnée mariadb"
  docker exec -it bookstack_mariadb bash -c 'mysqldump -uroot -pMyRootPasswd --all-databases | gzip > "/config/backup/mariadb_bookstack-dump-$(date +%F_%H-%M-%S).sql.gz"'
  echo "Le code Retour est" $?
# On vérifie si le fichier de sauvegarde de la base de données a bien été créé
# Liste des fichiers sauvegardés dans backup
  find $BACKUPDIR/*sql.gz
  echo "Liste des fichiers sauvegardés dans backup"
# Arret du container
  echo "Arret du Container bookstack_mariadb"
  docker stop bookstack_mariadb
  echo "Le code Retour est" $?
  docker ps -a | grep bookstack_mariadb
  find $BACKUPDIR/*gz
# On copie les fichiers sauvegardés et le répertoire des containers bookstack sur le NAS synology avec rsync
# BACKUPDIRNAS="patrice@192.168.1.204:/volume1/NetBackup/bookstack/backup"
  echo "Copie de la sauvegarde des fichiers bookstack sur le NAS Synology via rsync"
  /usr/bin/rsync -ratlz --rsh="/usr/bin/sshpass -p Pyc1012%% ssh -p 2200 -o StrictHostKeyChecking=no -l patrice" $BACKUPDIR1 $BACKUPDIRNAS --progress
  echo "Le code Retour est" $?
  date
# Demarrage du container
echo "Demarrage du Container bookstack"
docker start bookstack_mariadb
echo "Le code Retour est" $?
docker ps -a | grep bookstack_mariadb
} >> "$LOG" 2>&1 
# Envoi par email de la log
echo "Envoi d'un email avec le contenu de la log d'execution du script de sauvegarde"
cat "$LOG" | mail -s "$SUBJECT" "$TO" -aFrom:"$FROM"  2>&1
echo "Le code Retour est" $? 2>&1
echo "Fin du script de sauvegarde" 2>&1