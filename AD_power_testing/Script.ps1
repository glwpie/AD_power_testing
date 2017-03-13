﻿#
# User Copy .ps1
# current project = offload duplicate fields in csv
#set Department Domain Location
$commaDepDomLoc = ",CN=Departments,DC=WHPHDOM,DC=local"
#working department OU
$commaDepart_ou = ",CN=Telemetry"
# setUser csv location
$csvloc = ".\Documents\usrecreationfile.csv"
#set Identiy for template copy
$template_copy_id = "CN=Shun Watson" 
#server variable for memberOf setting
$server = "SVRWHPH01.whphdom.local"
# Get attribute from example Profile
$template = get-aduser `
    -identity $template_copy_id + $commaDepart_ou  + $commaDepDomLoc `
    -properties company,MemberOf,Organization,description,department,title,manager
    
#get csv file and start creation 
Import-Csv $csvloc |  foreach-object {
:confbreak {
$name = $_.FN_custom + " " + SN
$SamAccountName = $_.FN_custom + "." + $_.SN
$userprinicpalname = $SamAccountName + "@WHPHDOM.local" 
$group = $_.memberOf 
$oubits =  $commaDepart_ou + $commaDepDomLoc
$CN = ("Cn=" + $name + "," + $oubits)

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
     -AccountPassword (ConvertTo-SecureString "Welcome1" -AsPlainText -force) `
     -Company $template.Company `
     -Department $_.Department `
     -Description $_.description `
     -DisplayName $namename `
     -Enabled $true `
     -GivenName $CN `
     -manager = $template.manager `
     -PassThru `
     -Path $oubits `
     -samAccountName $SamAccountName `
     -Server lab-svr1.adlabdom.local `
     -Surname $_.sn `
     -Title $_.Job_title `
     -userAccountControl = 8389120 `
     -UserPrincipalName $userprinicpalname
     

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
}   
