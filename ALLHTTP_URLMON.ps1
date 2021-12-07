function Sendemail($toSend) {
$LOGPATH = "C:\\mon\\PROD_ALLHTTP_URL.html"
$URLPATH = "C:\\mon\\ALLHTTP_URL.txt"
$ACCESSFILE = "C:\\mon\\URL-ACCESS-LOG.txt"
$htmlTable = "<html><head> <style> table {  font-family: Calibri;  border-collapse: collapse;} td, th {  border: 1px solid #dddddd;  text-align: left;  padding: 3px;} tr:nth-child(even) {  background-color:#F9F9F9;} </style></head><body>"
$htmlTable1 = "<font style='font-family: calibri;' color=#385CD7> BICC Production URL accessibility  </font> <table> <tr  bgcolor=#E6E4E4><th>BI</th><th>Environment</th><th>Business URL/Web URL</th> <th>Response</th>   </tr>"
$URLSTATUS ="<font color=green>BICC Production All URL-Status-OK</font>"
$OVERALLURLSTAT="#SUCCESS"
$T=""
$newstreamreader = New-Object System.IO.StreamReader($URLPATH)
$eachlinenumber = 1
$row =""
while (($readeachline =$newstreamreader.ReadLine()) -ne $null)
{
[string] $ENVURL = $readeachline.Trim() 
$URL =  $ENVURL.Split("#")
$_TECH = $URL[0]
$_ENV = $URL[1]
$_URL = $URL[2]
write-host $_URL
try {
    $request= [System.Net.WebRequest]::Create($_URL)
    $request.Credentials = New-Object System.Net.NetworkCredential("tony.alexselvaraj","Cardinal10#","CARDINALHEALTH"); 
     $response = $request.getResponse()
    $HTTP_Status = [int]$response.StatusCode
    if ($HTTP_Status -eq "200") {
    write-host "    Site - $_URL is up (Return code: $($response.StatusCode) - $([int] $response.StatusCode)) " -ForegroundColor green 
    if ($_URL.Contains("https:")) {
    [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    $req = [Net.HttpWebRequest]::Create($_URL)   
    $row = $row+ "<tr><td>" + $_TECH  + "</td><td style='background-color:#2CCDA1'><b>" + $_ENV + "</b></td><td>" + "<a href=" + $_URL + ">"+ $_URL + "</a>"   + "</td><td><font color=green>" +  $response.StatusCode  + "  " + $([int] $response.StatusCode) + "</font></td></tr>"
 }
        if ($_URL.Contains("http:")) {
       $row = $row+ "<tr><td>" + $_TECH  + "</td><td style='background-color:#2CCDA1'><b>" + $_ENV + "</b></td><td>" + "<a href=" + $_URL + ">"+ $_URL + "</a>"   + "</td><td><font color=green>" +  $response.StatusCode  + "  " + $([int] $response.StatusCode) + "</font></td></tr>"
       }
      }
  
 else {
write-host "    Site - $_URL is down "  -ForegroundColor red
$T = $T +"#"+$_TECH
$T = $T | select -Unique
write-host "******************" +$T

$OVERALLURLSTAT = $T +"#URL-DOWN"
$URLSTATUS ="<font color=red>" + $T + " URL-Health-FAILED</font>"
$row = $row+ "<tr><td><font color = #FF0000>" + $_TECH  + "</font></td><td><b><font color = #FF0000>" + $_ENV + "</font></b></td><td style='background-color:#FF0000'>" +  "<a href=" + $_URL + ">"+ $_URL + "</a>" + "</td><td><font color=red>" +  $response.StatusCode  + "  " + $([int] $response.StatusCode) + "</font></td></tr>"
}
} catch {
write-host  $_.Exception.Message "   Site is not accessable "  $_URL -ForegroundColor red
$T = $T +"#"+$_TECH
$T = $T | select -Unique
$OVERALLURLSTAT = $T +"#URL-DOWN"
write-host $OVERALLURLSTAT
$URLSTATUS ="<font color=red>" +  $T + " URL-Health-FAILED</font>"
$row = $row+ "<tr><td><font color = #FF0000>" + $_TECH  + "</font></td><td><b><font color = #FF0000>" + $_ENV + "</font></b></td><td style='background-color:#FF0000'>" +  "<a href=" + $_URL + ">"+ $_URL + "</a>" + "</td><td><font color=red>NOT FOUND 404</font></td></tr>"

}   
    
}

$newstreamreader.close()
$newstreamreader.Dispose() 
$dt = Get-Date
$htmlTable = $htmlTable + "<font face=Calibri> <h3>" + $dt + " CST   " + $URLSTATUS  + "</h3><br>*** This is an automated email to monitor All BICC Production http(s) URL ****</font><BR><BR>" + $htmlTable1  + $row  + "</table><br><br> With Regards <br> BICC Support</body></html><br>"
Set-Content -Path $LOGPATH  -Value $htmlTable

if ($toSend -eq "EVERYMINSFALERT"){
if ($OVERALLURLSTAT.Contains("URL-DOWN")) 
{
$emailFrom = 'HTTP-URL-FAILURE@cardinalhealth.com'

$Subj = "**** IMMEDIATE ATTENTION REQUIRED **** BICC Production URL Response " + $OVERALLURLSTAT
Write-host "URL Failing -> Email Sent"     
    $emailTo = @('tony.alexselvaraj@cardinalhealth.com','sukesh.ravula02@cardinalhealth.com','amarjit.saha@cardinalhealth.com’,'pooja.kudale@cardinalhealth.com','G-EIT-BICC-OFFSHORE G-EIT-BICC-OFFSHORE@cardinalhealth.com')
    Send-MailMessage -To   $emailTo    -From  $emailFrom  -Subject  $Subj     -BodyAsHtml -body $htmlTable   -SmtpServer  "mpginternalsmtp.cardinalhealth.net" -Port 25
     #   $emailCC ='G-EIT-BICC G-EIT-BICC@cardinalhealth.com'
 #   $emailTo = @('tony.alexselvaraj@cardinalhealth.com', 'sukesh.ravula02@cardinalhealth.com','amarjit.saha@cardinalhealth.com’,'G-EIT-BICC-OFFSHORE G-EIT-BICC-OFFSHORE@cardinalhealth.com')
  #  Send-MailMessage -To   $emailTo  -Cc $emailCC  -From  $emailFrom  -Subject  $Subj    -BodyAsHtml -body $htmlTable   -SmtpServer  "mpginternalsmtp.cardinalhealth.net" -Port 25   
} 

}
else {
 if ($toSend -eq "EVERYHRSUCCESS" ){
     $Subj = "Production - ALL HTTP URL Access Status " + $OVERALLURLSTAT
     $emailFrom = 'HTTP-URL-RESPONSE@cardinalhealth.com'
     $emailCC ='tony.alexselvaraj@cardinalhealth.com'
     $emailTo = @('tony.alexselvaraj@cardinalhealth.com' , 'sukesh.ravula02@cardinalhealth.com','amarjit.saha@cardinalhealth.com’)  
     Send-MailMessage -To   $emailTo  -Cc $emailCC  -From  $emailFrom  -Subject  $Subj     -BodyAsHtml -body $htmlTable   -SmtpServer  "mpginternalsmtp.cardinalhealth.net" -Port 25
    }    
 if($toSend -eq "BICCHRSUCCESS" ){
      $Subj = "BICC Production - ALL HTTP URL Access Status " + $OVERALLURLSTAT
     $emailFrom = 'HTTP-URL-RESPONSE@cardinalhealth.com'
     $emailCC ='tony.alexselvaraj@cardinalhealth.com'
     $emailTo = @('tony.alexselvaraj@cardinalhealth.com', 'sukesh.ravula02@cardinalhealth.com','amarjit.saha@cardinalhealth.com’,'G-EIT-BICC-OFFSHORE G-EIT-BICC-OFFSHORE@cardinalhealth.com','G-EIT-BICC G-EIT-BICC@cardinalhealth.com')
     Send-MailMessage -To   $emailTo  -Cc $emailCC  -From  $emailFrom  -Subject  $Subj     -BodyAsHtml -body $htmlTable   -SmtpServer  "mpginternalsmtp.cardinalhealth.net" -Port 25
    }
 }  
}
#Sendemail("EVERYHRSUCCESS")

#-------------------------------------------------------------------------
# every 2 mins failure check
 $hour1 =get-date -UFormat %H
 write-host $hour1
$hour = [int]$hour1
      If (($hour -ge  4) -and ($hour -le 21) ) {
      write-host "EVERYMINSFALERT"
      Sendemail("EVERYMINSFALERT")
      } else { write-host "Maintenance Hr" }



$min1 =get-date -UFormat %M
$min = [int]$min1
write-host "minute " $min
If (($min -eq 0)) {  
 $hour1 =get-date -UFormat %H
 write-host $hour1
$hour = [int]$hour1
      If (($hour -eq  8)  ) {
       write-host "BICC Hr Success"      
       Sendemail("BICCHRSUCCESS")
        # Sendemail("EVERYHR")
      } else {      
        If (($hour -ge  3) -and ($hour -le 21) ) {
        write-host "Every Hr Success"
        Sendemail("EVERYHRSUCCESS")
        } else { write-host "Maintenance Hr" }
      }          
 }   