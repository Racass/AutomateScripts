$ServiceName = 'Tomcat6'
$arrService = Get-Service -Name $ServiceName
$Source = 'ServOn'
$LogName = 'ServicVerify'
$ProcName = 'tomcat6.exe'
if(![System.Diagnostics.EventLog]::Exists($LogName))
{
    New-EventLog -Source $Source -LogName $LogName
}

Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Information -Message "Restarting B1IF service."

if($arrService.Status -Contains 'Running')
{
    net stop $ServiceName
    Start-Sleep -minutes 300
    $arrService.Refrehs()
    if($arrService.Status -Contains 'Stopping')
    {
        Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Information -Message "Force restart needed.."    
        stop-process -name $ProcName
        Start-sleep -minutes 180
    }
    if($arrService.Status -Contains 'Stopped')
    {
        net start $ServiceName
    }
    Start-sleep -seconds 180
    $arrService.Refresh()
    if ($arrService.Status -Contains 'Running') 
    {
        Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Information -Message "Service: " + $ServiceName + " is now Running."
    }
    else 
    {
        Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Warning -Message "ServOn failed to initialize service" + $ServiceName +"."
    }
    exit
}