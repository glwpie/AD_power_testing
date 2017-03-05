#
# Script.ps1
#
$template = get-aduser -identity "CN=Food Nutrician,OU=Food and Nutrition,OU=Departments,DC=WHPHDOM,DC=local" -properties company,department,description,Manager,MemberOf,Organization,homeDrive 

Import-Csv .\usercreationfile.csv | foreach-object { 
$userprinicpalname = $_.SamAccountName + “@whphdom.local” 
$group = $_.memberOf 
$oubits =  "OU=Food and Nutrition,OU=Departments,DC=WHPHDOM,DC=local"
$addMember = ("Cn=" + $_.name + "," + $oubits)
$homeDirectory = "\\svrwhph02\Users\" + $_.SamAccountName 
New-ADUser -SamAccountName $_.SamAccountName -UserPrincipalName $userprinicpalname -Name $_.name -DisplayName $_.name -GivenName $_.cn -SurName $_.sn -Department $_.Department -homeDrive $_.homeDrive -description $_.description -Manager $_.Manager -homeDirectory $homeDirectory -Path “OU=Food and Nutrition,OU=Departments,DC=WHPHDOM,DC=local” -AccountPassword (ConvertTo-SecureString “Microsoft~1;” -AsPlainText -force) -Enabled $True -PasswordNeverExpires $False -PassThru 

 foreach($group in $template.MemberOf) {
            $null = Add-ADGroupMember -identity $group -Members $addMember -server svrwhph01.whphdom.local
        }}
