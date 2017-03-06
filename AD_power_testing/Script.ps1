#
# User Copy .ps1
# current project = offload duplicate fields in csv
$template = get-aduser `
    -identity "CN=User Copy,CN=testUserOU,CN=Users,DC=adlabdom,DC=local" `
    -properties company,MemberOf,Organization 

Import-Csv .\Documents\usrecreationfile.csv | foreach-object {
$name = $_.FN_custom + " " + SN
$SamAccountName = $_.FN_custom + "." + $_.SN
$userprinicpalname = $SamAccountName + “@adlabdom.local” 
$group = $_.memberOf 
$oubits =  "CN=testUserOU,CN=Users,DC=adlabdom,DC=local"
$addMember = ("Cn=" + $_.name + "," + $oubits)

New-ADUser -Name $_.name `
 -AccountPassword (ConvertTo-SecureString “Welcome1” -AsPlainText -force) `
 -Company $template.Company `
 -Department $_.Department `
 -Description $_.description `
 -DisplayName $_.name `
 -Enabled $true `
 -GivenName $_.cn `
 -PassThru `
 -Path $oubits `
 -samAccountName $_.SamAccountName `
 -Server lab-svr1.adlabdom.local `
 -Surname $_.sn `
 -Title $_.Job_title `
 -UserPrincipalName $userprinicpalname

 foreach($group in $template.MemberOf) {
            $null = Add-ADGroupMember `
            -identity $group `
            -Members $addMember `
            -server lab-svr1.adlabdom.local
        }
   }
