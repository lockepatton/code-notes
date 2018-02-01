#!/bin/bash

# Remove READ ONLY Bit on Backup File
chmod 700 ~/Linux_101_Class_Files/Bash/MyImportantFile.txt.BACKUP


# Remove PREVIOUS Backup File
rm  ~/Linux_101_Class_Files/Bash/MyImportantFile.txt.BACKUP 

# Comment Here - MAKE Backup of my file and SET READ-ONLY
cp   ~/Linux_101_Class_Files/Bash/MyImportantFile.txt  ~/Linux_101_Class_Files/Bash/MyImportantFile.txt.BACKUP
chmod 400 ~/Linux_101_Class_Files/Bash/MyImportantFile.txt.BACKUP

# Now Open file for Editing
vi ~/Linux_101_Class_Files/Bash/MyImportantFile.txt 
 

