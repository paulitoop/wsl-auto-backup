Param(
    [switch]$Backup,
    [switch]$CleanUp,
    [switch]$SetUp
    )

function GetScheduledTask(){
    param (
        [string]$task_name = "WSL backup task v1.0"
    )
    try{
        $result = Get-ScheduledTask -TaskName $task_name -ErrorAction Stop
    }
    catch {
        $result = "Task not found"
    }
    
    return $result
}

function MakeWSLBackup(){
    param (
        [string]$wsl_name="Ubuntu",
        [string]$backup_path=($PSCommandPath | Split-Path -Parent),
        [string]$backup_name="ubuntu-$(Get-Date -format 'dd-MM-yy').tar"
    )
    Remove-Item -Path "$backup_path\ubuntu*.tar"
    $full_name = "$backup_path\$backup_name"
    Add-Content -Path backup.log -Value "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss K') info Backup is running now..."
    wsl --export $wsl_name $full_name
    Add-Content -Path backup.log -Value "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss K') info Backup is finished"
    Add-Content -Path backup.log -Value "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss K') info Backup size $(((GEt-item $full_name).Length / (1024*1024*1024)).ToString('0.00')) GB"
}

function SetTaskAction(){
    param (
        [string]$full_path_to_script = $PSCommandPath
    )
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $full_path_to_script -Backup"
    return $action
}

function SetTaskTrigger(){
    $trigger = New-ScheduledTaskTrigger -Daily -At "10:00AM"
    return $trigger
}

function SetTaskSettings() {
    $task_settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    return $task_settings
}

function SetTask(){
    param (
        $action,
        $trigger,
        $settings
    )
    $task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings
    return $task
}

function RegisterTask {
    param (
        [string]$task_name="WSL backup task v1.0"
    )
    $result = Register-ScheduledTask -TaskName $task_name -InputObject $task
    return $result
}

function UnregisterTask {
    param (
        [string]$task_name="WSL backup task v1.0"
    )
    try {
        $result = Unregister-ScheduledTask -TaskName $task_name -Confirm:$false -ErrorAction Stop
        return 0
    }
    catch {
        Add-Content -Path backup.log -Value "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss K') warning Task '$task_name' not found. Can't unregister."
        return 1
    }
    return $0
}


if ($Backup){
    $res = MakeWSLBackup
}
elseif ($SetUp){
    $action = SetTaskAction
    $trigger = SetTaskTrigger
    $settings = SetTaskSettings
    $task = (SetTask $action $trigger $settings)
    $res = (RegisterTask -InputObject=$task)
}
elseif ($CleanUp) {
    $res = UnregisterTask
}