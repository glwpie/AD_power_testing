#﻿
# User Copy .ps1
# current project = offload duplicate fields in csv
#set Department Domain Location
$commaDepDomLoc = ",OU=Departments,DC=WHPHDOM,DC=local"
#working department OU
$Depart_ou = "OU=Telemetry"
# setUser csv location
$csvloc = ".\usercreationfile_v2.csv"
#set Identiy for template copy
$template_copy_id_comm = "CN=Shun Watson," 
#H:/ drive setting
$homeDir ="\\svrwhph02\Users\"
#server variable for memberOf setting
$server = "SVRWHPH01.whphdom.local"
# Get attribute from example Profile
$template = get-aduser `
    -identity $template_copy_id_comm$Depart_ou$commaDepDomLoc `
    -properties MemberOf,description,department,title,manager,homeDrive
    
#get csv file and start creation 
Import-Csv $csvloc |  foreach-object {
$name = $_.FN_custom + " " + $_.SN
$SamAccountName = $_.FN_custom + '.' + $_.SN
$userprinicpalname = $SamAccountName + "@WHPHDOM.local" 
$group = $template.MemberOf 
$oubits =  $Depart_ou + $commaDepDomLoc
$CN = "CN=" + $name + "," + $oubits
$homeDirSet = $homeDir + $SamAccountName 
$checkConfName = $SamAccountName
$checkconf = Get-ADUser `
    -Filter {sAMAccountName -eq $checkConfName} `
    -properties UserPrincipalName,distinguishedName
    
    If($checkConf-eq $Null) 
    {"no conflict with user: $checkConfName"}
    Else{
        "There is a conflict with this AD User:"
        "$checkconf.distinguishedName"
        }
"$name" 
"$SamAccountName" 
"$userprinicpalname"  
"$group"  
"$oubits"
"$CN"     
New-ADUser `
     -Name $name `
     -AccountPassword (ConvertTo-SecureString "Welcome1" -AsPlainText -force) `
     -Department $template.Department `
     -Description $template.Description `
     -DisplayName $name `
     -Enabled $true `
     -GivenName $_.FN_custom `
     -manager $template.manager `
     -PassThru `
     -Path $oubits `
     -samAccountName $SamAccountName `
     -Server $server `
     -Surname $_.SN `
     -Title $template.title `
     -ChangePasswordAtLogon $true `
     -UserPrincipalName $userprinicpalname `
     -homeDrive $template.homedrive `
     -homeDirectory $homeDirSet `
     -Debug
     

foreach($group in $template.MemberOf) {
            $null = Add-ADGroupMember `
            -identity $group `
            -Members $CN `
            -server $server
        }
#email setup here
#enable-mailbox -identity $userprincipalname `
#  -database  [-DisplayName <String>] [-DomainController <Fqdn>]

   
}   
