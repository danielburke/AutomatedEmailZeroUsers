$dgmaint_analysis = Import-csv 'C:\Users\DBURK1\Desktop\LDAP Cleanup\dgmaint-analysis.csv'
[array]$dlnames = $null
[array]$dlowners = $null
[array]$dlallowedsenders = $null
[array]$unique_owners_senders = $null
[array]$owner=$null
[array]$sender=$null
[array]$inactive=$null
$mail=new-object Net.Mail.MailMessage
$smtp=new-object Net.Mail.SmtpClient("mail.monsanto.com")

$i=0
foreach ($dl in $dgmaint_analysis) {
    $dlnames += $dl.Group_Name
    $unique_owners_senders += $dl.Group_Owner

    if($dl.Allowed_Senders -ne "") {               
                    [array]$dlallowedsender_entry = $dl.Allowed_Senders.Split('|')
                    $unique_owners_senders += $dlallowedsender_entry
    }
}

$unique_owners_senders = $unique_owners_senders | Select-Object -Unique
echo $unique_owners_senders
foreach($user in $unique_owners_senders){
    [array]$owner=$null
    [array]$sender=$null
    [array]$inactive=$null
    foreach($dl in $dgmaint_analysis){
       
        if($dl.Group_Owner-eq $unique_owners_senders[$i]){
            $owner+=$dl.Group_Name
        }
        [array]$AllowedSenders_atLine=$dl.Allowed_Senders.Split('|')
        if($AllowedSenders_atLine-contains $unique_owners_senders[$i]){
            $sender+=$dl.Group_Name
        }
        if($dl.'Number of Group Members' -eq 0 -and $dl.Group_Owner -eq $users ){
            $inactive+=$dl.Group_Name
        }
    $mail.From-"Daniel.1.burke@monsanto.com"
    $mail.To.add($unique_owners_senders[$i]+"@monsanto.com")
    $mail.Subject="DGMAINT"
    $mail.Body=get-Content 'C:\Users\DBURK1\Desktop\LDAP Cleanup\DG MAINT Warning.htm' -f $dl.Group_Owner, $owner, $sender
    if($inactive.count -ne 0){
        $Mail2=new-object Net.Mail.MailMessage
        $Mail2.To.add($unique_owners_senders[$i]+"@monsanto.com")
        $Mail2.Subject="DG MAINT ACTION REQUIRED"
        $Mai2.Body=get-Content 'C:\Users\DBURK1\Desktop\LDAP Cleanup\DG MAINT.htm' -f $dl.Group_Owner, $owner, $inactive
    
    }
    $i++
    }
# $smtp.Send($mail)
# $smtp.Send($Mail2)
}
