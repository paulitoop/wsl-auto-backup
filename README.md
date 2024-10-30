WSL BACKUP POWERSHELL SCRIP
===========================

This script allow you to configure automatic backup of your WSL machine.

INSTRUCTIONS
------------
You need to execute those commands in PowerShell console

1. To make manual Backup write `.\wsl_backup.ps1 -Backup`
2. To setup scheduler task write `.\wsl_backup.ps1 -SetUp`
3. To disable scheduler task write `.\wsl_backup.ps1 -CleanUp`

TO DO
-----

1. Make separate folder for backup and logs
2. Add errors handling
3. Add more logs
4. Add auto cleanup before new setup
5. Enable simple config with flags
