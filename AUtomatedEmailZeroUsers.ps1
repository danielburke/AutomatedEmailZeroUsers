# AutomatedEmailZeroUsers
$owner=@()
$DL=@()
$EmailAddress=@()
$ownerAllowed=@()
$DLAllowed=@()
$EmailAddressAllowed=@()
$AllowedSenders=@()
$x=0
$y=0
$z=0
$Outlook= New-Object -ComObject Outlook.Application
$Mail=$outlook.CreateItem(0)
$listOfDls=""
$listOfDlsender=""
$Mail.Subject="DG MAINT Owner Action Required"


#Loads all columns into arrays
Import-csv 'C:\Users\DBURK1\Desktop\LDAP Cleanup\Zero Result.csv' | ForEach-Object{
    $owner+=$_.owner
    $DL+=$_.dlname
    $results=& 'C:\Users\DBURK1\Desktop\LDAP Cleanup\IsActiveIDM-NonUser.ps1' $._emailaddress
    if($results -eq 'Active'){
        $EmailAddress+=$_.emailaddress
    }
    $x++
}
Import-csv 'C:\Users\DBURK1\Desktop\LDAP Cleanup\Zero ResultAllowedSenders.csv' | ForEach-Object{
    $ownerAllowed+=$_.owner
    $DLAllowed+=$_.dlname
    $results=& 'C:\Users\DBURK1\Desktop\LDAP Cleanup\IsActiveIDM-NonUser.ps1' $._emailaddress
    if($results -eq 'Active'){
        $EmailAddressAllowed+=$_.emailaddress
    }
    $AllowedSenders+=$_.allowedsenders
    $x++
}




#Emails the owner
while($y -le $dl.count-1){
    #construct an email object
    #Find out if the next DL on the list is owned by the same person
    #if so, append the DL, else, send email
    $Mail.To="Daniel.1.Burke@monsanto.com" #$EmailAddress[$y]
    $listOfDls+= $DL[$y]
    while($owner[$y] -eq $owner[$y+1] -and $y -lt $dl.Count-1){
        $listOfDls+=$DL[$y+1]+" "
        $y++
    }
    while($AllowedSenders[$z] -eq $AllowedSenders[$z+1] -and $z -lt $dl.Count-1){
        $listOfDlsender+=$DL[$z+1]+" "
        $z++
    } 
    $listOfDls=$listOfDls | select -Unique
    $listOfDlsender=$listOfDlsender | select -Unique
    $Mail.Body=('Hello'+$owner[$y]+' ,

I am working with the Enterprise Identity Solutions team to help automated DLs become more efficient and more precise. Part of this task is to look at all of the current automated DLs and find a better way to return the same results, while doing this I have found that you are the owner of' +$listOfDls+'

Currently, this DL has zero users and is not returning any results when we process the query. 

Is'+$listOfDls + 'still valid, if so please let me know, as well as the what the goal or intended purpose of this DL is so I can help you remediate the issue. If it is not valid please respond as such and we will delete it for you.

Please note, we will delete said DL if no response is received by <DATE>

You are also an allowed sender on these DLs'+$listOfDlsender+' which have also been marked as inactive and may discontinue at the owners request
')

    $y++
    $z++
    echo $listOfDls
    $listOfDls=""
    #add send function when ready

}
