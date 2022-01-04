$HostList = "D:\\process\\BO\\Servers.txt"
$LOGPATH = "D:\\process\\LOGs\\basic.html"
Remove-Item $LOGPATH 
$localSystem = Get-WMIObject Win32_ComputerSystem | Select-Object -ExpandProperty name
write-host $localSystem
$dt = Get-Date
$htmlContent = "<html><head><style> #basic { font-family: calibri;  border-collapse: collapse;  width: 100%;}#basic td, #basic th {  border: 1px solid #EEEEF0;  padding: 1px;} #basic tr:nth-child(even) {background-color: #f2f2f2;} "
$htmlContent = $htmlContent + " #basic tr:hover {background-color: #EEEEF0;} #basic th {padding-top: 3px;  padding-bottom: 3px;  text-align: left;  background-color: #E3E3E4;color:black;} </style></head><body>"
$htmlContent = $htmlContent + "<font style='font-family: calibri;' color=black size=3><b>Disk Space,CPU/MEM Usage</b></font><br><br><font style='font-family: calibri;' color=#385CD7><b>Time  " + $dt + " CPU/MEM Threshold Limit 70%, Disk space Threshold Limit 5GB </b> </font>" + " <table id='basic'> <tr><th>Landscape</th><th>Server</th><th>Last Boot Time</th> <th>UP-Time</th> <th>Disk Space</th><th>AVG CPU,MEM</th><th>Top-3-Process</th><th>Comments</th></tr>"
foreach ($Computer in (Get-Content $HostList)) {
$Com =$Computer.Split("#")
$LANDSCAPE = $Com[0].Trim()
$primary = $Com[1].Trim()
$serverName = $Com[2].Trim()
$username = $Com[3].Trim()
$password = $Com[4].Trim()
$UserPass =""
$comments=""

$secpw = ConvertTo-SecureString $password -AsPlainText -Force
$cred  = New-Object Management.Automation.PSCredential ($username, $secpw)
if ($localSystem -eq $serverName) { $UserPass = "N"  } else { $UserPass = "Y" }
write-host $UserPass    $Landscape  
$eachlinenumber = 1
$up = Test-Connection $serverName -Count 1 -Quiet    
 if ($up ) {                                        
                             Write-Host "$serverName  is UP" -ForegroundColor Green

                             if ( $UserPass -eq "Y" ) {
                                $userSystem = Get-WmiObject win32_operatingsystem -ComputerName $serverName -Credential  $cred }
                                else { $userSystem = Get-WmiObject win32_operatingsystem -ComputerName $serverName    }

                                $sysuptime= (Get-Date) - $userSystem.ConvertToDateTime($userSystem.LastBootUpTime)
                                if ( $UserPass -eq "Y" ) {
                                Get-WmiObject -computer $serverName -Credential $cred -class win32_processor | Measure-Object -property LoadPercentage -Average | Select-Object -ExpandProperty Average   }
                                else {
                                 Get-WmiObject -computer $serverName  -class win32_processor | Measure-Object -property LoadPercentage -Average | Select-Object -ExpandProperty Average  
                                } 

$htmlContent = $htmlContent + "<tr> <td><font color=#509CE3><b>" + $LANDSCAPE +"</font></b></td>"
#Server
$htmlContent = $htmlContent + " <td>" + $serverName + "</td>"
#LastBoot
$htmlContent = $htmlContent + "<td>" +$userSystem.ConvertToDateTime($userSystem.LastBootUpTime) +" </td>"
#UPTime
$htmlContent = $htmlContent + "<td>"+ + $sysuptime.Days + " Days " + $sysuptime.Hours + " Hours " + $sysuptime.Minutes + " Minutes"  + "</td>"
#DiskSpace
$res =""
$res1 =""
if ( $UserPass -eq "Y" ) {
$disks = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" -computername $serverName -Credential $cred  }
else { $disks = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" -computername $serverName    } 
$results = foreach ($disk in $disks)
{
    if ($disk.Size -gt 0)
    {
        $size = [math]::round($disk.Size/1GB, 0)
        $free = [math]::round($disk.FreeSpace/1GB, 0)
        if ($free -le 5 ) {
	    $res = $res + "<font color=red>"+ $disk.Name + "\ "+  $free + " GB free of " + $size  + " GB **DiskSpace Attention Required**</font><br>" 
 $comments =  $comments +"#Disk"
 }
        else {  $res = $res + $disk.Name + "\ "+  $free + " GB free of " + $size  + " GB <br> "}
     } 
}
$htmlContent = $htmlContent + " <td><span  style='font-size:11.0pt;font-family:Calibri;color:black'>" + $res  + "</td>"
                            #AVG CPU MEM
                  if ( $UserPass -eq "Y" ) {       
                   $avg = Get-WmiObject win32_processor -computername  $serverName  -Credential $cred | 
                     Measure-Object -property LoadPercentage -Average | 
                      Foreach {$_.Average}
                       $mem = Get-WmiObject win32_operatingsystem -ComputerName $serverName  -Credential $cred | Foreach {"{0:N2}" -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize)}
                       }
                       else {
                        $avg = Get-WmiObject win32_processor -computername  $serverName  | 
                     Measure-Object -property LoadPercentage -Average | 
                      Foreach {$_.Average}
                       $mem = Get-WmiObject win32_operatingsystem -ComputerName $serverName  | Foreach {"{0:N2}" -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize)}
                       }

$cpustr= $avg.ToString()
$cpuint = [int]$cpustr
$memstr= $mem.ToString()
$memint = [int]$memstr
if ($cpuint-ge 70 ) { $cpuavg = "<font color=red> "+  $avg.ToString() +"**CHECK CPU" +"</font>" 
 $comments =  $comments +"#CPU" 
  } else { $cpuavg =   $avg.ToString()   } 
if ($memint -ge 70 ) { $memavg = "<font color=red> "+  $mem.ToString() + "**CHECK MEM" +"</font>" 
 $comments =  $comments +"#MEM"
  } else { $memavg =   $mem.ToString()   } 
$htmlContent = $htmlContent + "<td style='font-size:12.0pt;font-family:Calibri;color:black'><b>" + $cpuavg  + " , " + $memavg  + "<b></td>"
 #top 3 process
 if ( $UserPass -eq "Y" ) {
$top3process= Get-WmiObject WIN32_PROCESS  -ComputerName $serverName  -Credential $cred  | Sort-Object -Property ws -Descending | Select-Object -first 3 ProcessID,Name,WS }
else { $top3process= Get-WmiObject WIN32_PROCESS  -ComputerName $serverName    | Sort-Object -Property ws -Descending | Select-Object -first 3 ProcessID,Name,WS }
$tproc =""
For ($p=0; $p -lt $top3process.Length; $p++) {
    $tproc = $tproc +  $top3process[$p] + "<br>"
}
  $tproc =  $tproc -replace "@{ProcessID=" ,""  
  $tproc =  $tproc -replace "}" ,""
  if ($comments -ne ""){
   $comments = "|"+$LANDSCAPE + $comments +"|"
  }
 
$htmlContent = $htmlContent +  "<td><font size=2>" + $tproc + "</font></td><td><font size=2>" + $comments + "</font></td> </tr>"                         
 }
  else{
    Write-Host "$serverName  is DOWN" -ForegroundColor Red
#Landscape
$htmlContent = $htmlContent + "<tr> <td><font color=#509CE3><b>" + $LANDSCAPE +"</font></b></td>"
 #Server
$htmlContent = $htmlContent + "<td><font color=red>" + $serverName +"</font></b></td>"
#LastBoot
$htmlContent = $htmlContent + "<td>N.A</td>"
#UPTime
$htmlContent = $htmlContent + "<td>N.A</td>"
#DISKSPACE  
$htmlContent = $htmlContent + "<td>N.A</td>"
#AVG CPU MEM
$htmlContent = $htmlContent + "<td>N.A</td>"
#tproc 
$htmlContent = $htmlContent +  "<td>N.A</td>"  
#comments 
$htmlContent = $htmlContent +  "<td>N.A</td></tr>"                        
}  
    $eachlinenumber++
}
$htmlContent = $htmlContent + " </table></body></html>"
Set-Content -Path $LOGPATH  -Value $htmlContent


