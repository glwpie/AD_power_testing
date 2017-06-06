#
# User Copy .ps1
# current project = more values
#
# crap load of values 
#
#set domain name 
$domainName = "testdomain"
#set Department Domain Location
$commaDepDomLoc = ",CN=Users,DC=" + $domainName + ",DC=local"
#set user OU
$oubits =  "CN=testUserOU" + $commaDepDomLoc
# setUser csv location
$csvloc = ".\Documents\usrecreationfile.csv"
#set identity 
$userCopyCN = "CN= user to copy from,"
#set Identity
$setIdentity = $userCopyCN + $oubits
#set server
$server = "server ip here"

# Get Company, memberof, orginization of example Profile
$template = get-aduser `
    -identity $setIdentity `
    -properties company,MemberOf,Organization 

Import-Csv $csvloc |  foreach-object {
:confbreak {
$name = $_.FN_custom + " " + SN
$SamAccountName = $_.FN_custom + "." + $_.SN
$userprinicpalname = $SamAccountName + “@" + $domain_name + ".local” 
$group = $_.memberOf 
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
#   email setup here
enable-mailbox -identity $userprincipalname `
  -database  [-DisplayName <String>] [-DomainController <Fqdn>]

   }
}   
