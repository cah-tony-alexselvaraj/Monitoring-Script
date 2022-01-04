function Sendemail($toSend) {
$LOGPATH = "D:\mon\Consolidated\Prod_Alteryx.html"
$URLCERT = "D:\mon\Consolidated\PROD_Alteryx_URLCERT.html"
$ALTSERVICE = "D:\mon\logs\AlteryxService.html"
$BASICMON = "D:\mon\logs\PROD_Alteryx_BasicMon.html"
$MongoBkUp = "D:\mon\logs\PROD_Alteryx_MongoDB_BKUP.html"
$MongoBkUpSOX = "D:\mon\logs\PROD_AlteryxSOX_MongoDB_BKUP.html"
$htmlContent=""
$JOBS1=""
$Subj=""
$SubjFlag=""
$ALTSERVICE1=""
$URLCERT1=""
$BASICMON1=""
$ALLJOBS=""
$AVAILCNT=0
$tablerow= ""
$c=0
foreach($line in Get-Content "D:\mon\Consolidated\Summary.txt") {
$GN=0
$AM=0
$RD=0
$MGBK =""
$MGBKSOX=""
 if($line -match $regex){
 $ln = $line.Split("#")
 $LANDSCAPE = $ln[0].Trim()
$JOBS = "D:\mon\logs\"+$LANDSCAPE+"_AlteryxJobs.html"
$AVAILCNT= $AVAILCNT+1
$Subj = $Subj + "-" + $LANDSCAPE
#ALL JOBS
if (Test-Path $JOBS -PathType leaf)  { 
$JOBS1 =  Get-Content -Path $JOBS 
$ALLJOBS = $ALLJOBS + $JOBS1
}
}
# ALteryx Service
if (Test-Path $ALTSERVICE -PathType leaf)  { 
$ALTSERVICE1 =  Get-Content -Path $ALTSERVICE
}
#SERVICE HEALTH CHECK
foreach($line in Get-Content $ALTSERVICE) {
    if($line -match $regex){    
          if ($line.Contains($LANDSCAPE + "#Status-AMBER")) {$AM=1}  
              if ($line.Contains($LANDSCAPE + "#Status-RED")) {$RD=1}            
    }
}
#MongoDB Back Up Content
if (Test-Path $MongoBkUp  -PathType leaf)  { 
$MongoBkUpContent =  Get-Content -Path $MongoBkUp 
}
#MongoDB Back Up HEALTH CHECK
foreach($line in Get-Content $MongoBkUp) {
    if($line -match $regex){    
          if ($line.Contains($LANDSCAPE + "|#Backup-Successful")) {$MGBK="<font color=#148945> | MongoDB Backup Successful [Weekly Maintenance] </font>"}  
            if ($line.Contains($LANDSCAPE +"|#Backup-Failed")) {$MGBK="<font color=#C70039> | MongoDB Backup Failed [Weekly Maintenance] </font>"}            
    }
}

#MongoDBSOX Back Up Content
if (Test-Path $MongoBkUpSOX  -PathType leaf)  { 
$MongoBkUpContentSOX =  Get-Content -Path $MongoBkUpSOX 
}
#MongoDBSOX Back Up HEALTH CHECK
foreach($line in Get-Content $MongoBkUpSOX) {
    if($line -match $regex){    
          if ($line.Contains($LANDSCAPE + "|#Backup-Successful")) {$MGBKSOX="<font color=#148945> | MongoDB Backup Successful [Weekly Maintenance] </font>"}  
          if ($line.Contains($LANDSCAPE +"|#Backup-Failed")) {$MGBKSOX="<font color=#C70039> | MongoDB Backup Failed [Weekly Maintenance] </font>"}                       
    }
}
# ALteryx Basic 
if (Test-Path $BASICMON -PathType leaf)  { 
$BASICMON1 =  Get-Content -Path $BASICMON
}
if ($RD -eq 1) {$tablerow = $tablerow  + "<tr><td>" + $AVAILCNT  +"</td><td>"+$LANDSCAPE +"</td> <td align=center>Production</td><td bgcolor=#FF0000 align=center><font color=WHITE>RED</font></td><td><font color=#807d7d>***</font></td></tr>"} 
else {
if ($AM -eq 1) {$tablerow = $tablerow  + "<tr><td>" + $AVAILCNT  +"</td><td>"+$LANDSCAPE +"</td> <td align=center>Production</td><td bgcolor=#fc6e08 align=center><font color=WHITE>AMBER</font></td><td><font color=#807d7d>***</font></td></tr>"}
  else { $tablerow = $tablerow  + "<tr><td>" + $AVAILCNT   +"</td><td>"+$LANDSCAPE +"</td> <td align=center>Production</td><td bgcolor=#3CDBB4 align=center><font color=black>GREEN</font></td><td><font color=#807d7d>***</font></td></tr>"  }
 }
 $Comments =""
 
 
if (($AM -eq 1) ) {
$Comments = $Comments + " Primary/Worker Node Service(s) failed. "
$SubjFlag = "#Service-Failed"
}
 if (($RD -eq 1) ) {
$Comments = $Comments + " Alteryx/MongoDB Service(s) failed. "
$SubjFlag = "#Service-Failed"
}


$Comments = $Comments + $MGBK + $MGBKSOX
$tablerow = $tablerow.Replace("***",$Comments)
}

 

  #$CERTS
 $UC=0
 if (Test-Path $URLCERT -PathType leaf)  { 
 $URLCERT1 =  Get-Content -Path $URLCERT
 foreach($lineUC in Get-Content $URLCERT) {
    if($lineUC -match $regex){
      if ($lineUC.Contains("**Ensure") ) {$UC=1 }   
    }
}
} 

 if (($UC -eq 1) ) {
 write-host " #CERTS-EXPIRY"
$SubjFlag =$SubjFlag + " #CERTS-EXPIRY"
}


if ( $SubjFlag -eq "") {
$SubjFlag =" #ALL-GREEN"
}
$htmlContent= $URLCERT1 +  $ALTSERVICE1 + $ALLJOBS +  $MongoBkUpContent + $MongoBkUpContentSOX +  $BASICMON1
Set-Content -Path $LOGPATH  -Value $htmlContent
$Body = @"
 <html>
<head>
<style>
#summary {
  font-family: calibri;
  border-collapse: collapse;
}
#summary td, #summary th {
  border: 1px solid #ddd;
  padding: 3px;
}
#summary tr:nth-child(even){background-color: #f2f2f2;}
#summary tr:hover {background-color: #ddd;}
#summary th {
  padding-top: 8px;
  padding-bottom: 8px;
  text-align: left;
  background-color: #0070C0  ;
  color: white;
}
</style>
</head>
<body>
<p> This is an automated email to monitor Alteryx Services (Consolidated). Please do not reply. </p><br>
<b><span style='font-size:14.0pt;color:black'>Alteryx Landscape Availability - Status Summary </span></b><br>
<table id="summary">
  <tr>
    <th>Sno</th>
    <th>Landscape</th>
    <th align=center>Environment</th>
     <th align=center>Service Status</th>
     <th>Comments</th>
  </tr>  
  $tablerow
</table>
<br>
<hr>
<br>
<p>$htmlContent </p> 
<br> 
       <p><font color=Black><br><b>With Regards<br>BICC Monitoring Team</b></font></p>   
       </body>
</html>
"@
$Subj = "Alteryx[" + $AVAILCNT + "] " + $Subj + " #Consolidated Health Check" + $SubjFlag 
$emailFrom = 'Alteryx-Health@cardinalhealth.com'
$emailCC ='tony.alexselvaraj@cardinalhealth.com'
    if ($toSend -eq "EVERYHR"){
    $emailTo = @('tony.alexselvaraj@cardinalhealth.com','asmita.desai@cardinalhealth.com')
    Send-MailMessage -To   $emailTo  -Cc $emailCC  -From  $emailFrom  -Subject  $Subj   -BodyAsHtml -body $body   -SmtpServer  "mpginternalsmtp.cardinalhealth.net" -Port 25
    }
    if ($toSend -eq "BICCHR"){
    $emailTo = @('G-EIT-BICC-OFFSHORE G-EIT-BICC-OFFSHORE@cardinalhealth.com','G-EIT-BICC G-EIT-BICC@cardinalhealth.com')
    Send-MailMessage -To   $emailTo  -Cc $emailCC -Bcc 'lakshmi.subramanian01@cardinalhealth.com' -From  $emailFrom  -Subject  $Subj   -BodyAsHtml -body $body   -SmtpServer  "mpginternalsmtp.cardinalhealth.net" -Port 25
    }
}
$hour1 =get-date -UFormat %H
write-host $hour1
$hour = [int]$hour1
If (($hour -le 22)) {  
      If (($hour -eq  8) -or ($hour -eq  12) -or ($hour -eq  18) -or ($hour -eq  22) ) {
       write-host "BICC Hr"      
        Sendemail("BICCHR")
        # Sendemail("EVERYHR")
      } else {      
        If ($hour -ge 5) {
        write-host "Every Hr"
        Sendemail("EVERYHR")
        } else { write-host "Maintenance Hr" }
      }          
 }   
