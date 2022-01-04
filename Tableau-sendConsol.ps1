
$emailTo = @('tony.alexselvaraj@cardinalhealth.com')
$emailFrom = 'TableauHealth@cardinalhealth.com'
$emailCC ='tony.alexselvaraj@cardinalhealth.com'
  $LOGPATH = "E:\mon\Consolidated\PROD_Tableau.html"
if (Test-Path $LOGPATH -PathType leaf) {   
    Remove-Item $LOGPATH
}
$LANDSERVICE1 = Get-Content -Path E:\mon\Service\PROD_PHARMA_stat.html
$LANDBASIC1 = Get-Content -Path E:\mon\System\PROD_PHARMA_BasicMon.html
$LANDLIC1 = Get-Content -Path E:\mon\License\PROD_PHARMA_lic.html
$LANDSERVICE2 = Get-Content -Path E:\mon\Service\PROD_MEDICAL_stat.html
$LANDBASIC2 = Get-Content -Path E:\mon\System\PROD_MEDICAL_BasicMon.html
$LANDLIC2 = Get-Content -Path E:\mon\License\PROD_MEDICAL_lic.html
$htmlContent =$LANDSERVICE1+$LANDBASIC1+$LANDLIC1+$LANDSERVICE2+$LANDBASIC2+$LANDLIC2
$htmlContent | Out-File -FilePath $LOGPATH -Append

$Body = @"
    <html>
    <head> </head>
        <body style="font-family:calibri"> 
        <p> This is an automated email to monitor Tableau Services. Please do not reply. </p>
        <p>$htmlContent </p> 
        <br> 
       <p><font color=Black><br><b>With Regards<br>BICC Monitoring Team</b></font></p>   
       </body>
    </html>
"@

Send-MailMessage -To   $emailTo  -Cc $emailCC -From  $emailFrom  -Subject  "Tableau Pharma-Medical-FortKnox-ICE-Raven-SPS-Atlas-EINTEL #Consolidated Health Check"  -BodyAsHtml -body $body   -SmtpServer  "mpginternalsmtp.cardinalhealth.net" -Port 25

