$ServiceName = 'Tomcat8'
$arrService = Get-Service -Name $ServiceName
$Source = 'ServOn'
$LogName = 'ServicVerify'
if(![System.Diagnostics.EventLog]::Exists($LogName))
{
    New-EventLog -Source $Source -LogName $LogName
}

Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Information -Message "Initializing test."

if ( $arrService.Status -Contains 'Stopped') 
{
    net start $ServiceName 
    Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Information -Message "Service was stopped, now starting."
    Start-Sleep -seconds 30
    $arrService.Refresh()
    if ($arrService.Status -Contains 'Running') 
    {
        Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Information -Message "Service is now Running."
    }
    else 
    {
        Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Warning -Message "ServOn failed to initialize service" + $ServiceName +"."
    }
    exit
}