#
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
$SamAccountName = $_.FN_custom + "." + $_.SN
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
   enable-mailbox -identity $userprincipalname  -database  [-DisplayName <String>] [-DomainController <Fqdn>]

   }
}   
