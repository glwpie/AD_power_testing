﻿#
# User Copy .ps1
# current project = offload duplicate fields in csv
#set Department Domain Location
$commaDepDomLoc = ",CN=Users,DC=adlabdom,DC=local"
# setUser csv location
$csvloc = ".\Documents\usrecreationfile.csv"
# Get Company, memberof, orginization of example Profile
$template = get-aduser `
    -identity "CN=User Copy,CN=testUserOU" + $commaDepDomLoc `
    -properties company,MemberOf,Organization 

Import-Csv $csvloc |  foreach-object {
:confbreak {
$name = $_.FN_custom + " " + SN
$SamAccountName = $_.FN_custom + "." + $_.SN#
# User Copy .ps1
# check variables for user copy
#set Department Domain Location
$commaDepDomLoc = ",OU=Departments,DC=WHPHDOM,DC=local"
#working department OU
$Depart_ou = "OU=Students"
# setUser csv location
$csvloc = ".\user_create__student_2017.csv"
#set Identiy for template copy with comma
$template_copy_id_comm = "CN=Lindsey James," 
#H:/ drive setting
$homeDir = "\\svrwhph02\Users\"
$driveH = "H:"
#server variable 
$server = "SVRWHPH01.whphdom.local"

# Get attributes from example Profile 
#Pulls ADUser to use as example for MemberOf,description,department,title,manager
$template = get-aduser `
    -identity $template_copy_id_comm$Depart_ou$commaDepDomLoc `
    -properties MemberOf,description,department,title,manager
    
#get csv file and start creation 
#all you need in CSV is First Name, Sur Name
#will break out and go to next user if user conflict is found 
Import-Csv $csvloc |  foreach-object {
#Define per user variables
#creates Full name
$name = $_.FN_custom + " " + $_.SN
#first name DOT last name 
$SamAccountName = $_.FN_custom + '.' + $_.SN
#userPrincipalName is unique value, used for logon ID 
$userprinicpalname = $SamAccountName + "@WHPHDOM.local" 
#Group array used for add-adGroupMember
$group = $template.MemberOf
#sets working AD OU loction 
$oubits =  $Depart_ou + $commaDepDomLoc
#sets Canonical Name, is always unique
$CN = "CN=" + $name + "," + $oubits
#home Dircetory folder path
$homeDirSet = $homeDir + $SamAccountName
#check if account to be created will conflict with user in AD
$checkConfName = $SamAccountName
$checkconf = Get-ADUser `
    -Filter {sAMAccountName -eq $checkConfName} `
    -properties UserPrincipalName,distinguishedName
    #if all good, continue, if conflict found, break out, go to next user in csv
    If($checkConf-eq $Null) 
    {"no conflict with user: $checkConfName"}
    Else{
        "There is a conflict with this AD User:"
        "$SamAccountName"
        Break 
        }
#where the magic happens     
New-ADUser `
     -Name $name `
     -AccountPassword (ConvertTo-SecureString "Welcome1" -AsPlainText -force) `
     -Department $template.Department `
     -Description $template.Description `
     -DisplayName $name `
     -Enabled $true `
     -GivenName $_.FN_custom `
     -homeDrive $driveH `
     -homeDirectory $homeDirSet `
     -manager $template.manager `
     -PassThru `
     -Path $oubits `
     -samAccountName $SamAccountName `
     -Server $server `
     -Surname $_.SN `
     -Title $template.title `
     -ChangePasswordAtLogon $true `
     -UserPrincipalName $userprinicpalname `
     -Debug
     
#adds succesfully created user to all the groups from template
foreach($group in $template.MemberOf) {
            $null = Add-ADGroupMember `
            -identity $group `
            -Members $CN `
            -server $server
        }
#email setup here
#Enable-Mailbox -Identity $name -Alias $SamAccountName
}   
$userprinicpalname = $SamAccountName + “@adlabdom.local” 
$group = $_.memberOf 
$oubits =  "CN=testUserOU,CN=Users,DC=adlabdom,DC=local"
$CN = ("Cn=" + $name + "," + $oubits)
$manager = $_.manager + $oubits
$checkconf = Get-ADUser `
    -identity $SamAccountName `
    -properties UserPrincipalName,distinguishedName
    
    If($checkconf.userPrincipalName == $userprincipalname) {
        cout << "There is a conflict with this AD User:"
        cout << $checkconf.distinguishedName 
        break confbreak
    }
New-ADUser `
     -Name $_.name `
     -AccountPassword (ConvertTo-SecureString “Welcome1” -AsPlainText -force) `
     -Company $template.Company `
     -Department $_.Department `
     -Description $_.description `
     -DisplayName $namename `
     -Enabled $true `
     -GivenName $CN `
     -PassThru `
     -Path $oubits `
     -samAccountName $SamAccountName `
     -Server lab-svr1.adlabdom.local `
     -Surname $_.sn `
     -Title $_.Job_title `
     -UserPrincipalName $userprinicpalname

foreach($group in $template.MemberOf) {
            $null = Add-ADGroupMember `
            -identity $group `
            -Members $CN `
            -server lab-svr1.adlabdom.local
        }
   #email setup here
#enable-mailbox -identity $userprincipalname `
#  -database  [-DisplayName <String>] [-DomainController <Fqdn>]

   }
}   
