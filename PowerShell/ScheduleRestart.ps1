$ServiceName = 'Tomcat6' #Service that should restart
$arrService = Get-Service -Name $ServiceName
$Source = 'ServOn' #Name of this service
$LogName = 'ServicVerify' #Name in the windows log
$ProcName = 'tomcat6.exe' #Name of the service
$Email = 'sutitel@peninsulapart.com.br' #Email address of who should be contacted in case of problems while restarting the service

function sendMail
{
    [CmdletBinding()]
    param($message, $To)

    
    $From = "sutitel@peninsulapart.com.br"
    $Subject = "Serviço integration do SAP, B1IF parado! Requer atenção"
    $SMTPServer = "smtp.peninsulapart.com.br"
    $SMTPPort = "25"

    $pw = Get-Content 'C:\ServOn\MailPW.txt' | ConvertTo-SecureString
    $cred = New-Object System.Management.Automation.PSCredential $From, $pw

    $emailMessage = New-Object System.Net.Mail.MailMessage( $From , $To )
    $emailMessage.Subject = $Subject
    $emailMessage.Body = $message

    $SMTPClient = New-Object System.Net.Mail.SmtpClient( $SMTPServer , $SMTPPort )
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $From , ($pw ) )
    $SMTPClient.EnableSsl = $False
    $SMTPClient.Send( $emailMessage )
}

if(![System.Diagnostics.EventLog]::Exists($LogName))
{
    New-EventLog -Source $Source -LogName $LogName
}

Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Information -Message "Restarting B1IF service."

if($arrService.Status -Contains 'Running')
{
    net stop $ServiceName
    Start-Sleep -seconds 600
    $arrService.Refrehs()
    if($arrService.Status -Contains 'Stopping')
    {
        Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Information -Message "Force restart was needed.."    
        stop-process -name $ProcName
        Start-sleep -seconds 300
    }
    if($arrService.Status -Contains 'Stopped')
    {
        net start $ServiceName
    }
    Start-sleep -seconds 300
    $arrService.Refresh()
    if ($arrService.Status -Contains 'Running') 
    {
        Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Information -Message "Service: " + $ServiceName + " is now Running."
    }
    else 
    {
        Write-EventLog -LogName $LogName -Source $Source -EventID 3001 -EntryType Warning -Message "ServOn failed to initialize service: " + $ServiceName +". Requires user action."
        sendMail -Message "ServOn falhou em iniciar o serviço: " + $ServiceName + ". É necessária uma interação manual.\n\n Em caso de maiores problemas favor contatar o suporte do serviço." -To $Email
    }
    exit
}