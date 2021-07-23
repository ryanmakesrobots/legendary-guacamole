$GroupToCheck = "MyGroupToCheck"
$FileServerLocation = "\\MyServer\MyCentralShare\"
$DomainName = "MyDomainName\"
$UsersInGroup = Get-ADGroupMember -Identity $GroupToCheck

Write-Host $UsersInGroup
foreach ($User in $UsersInGroup) { 
    $User = $User.samaccountname
    if(Test-Path ($FileServerLocation + $User)){
        Continue
    }
    else{
       New-Item -Path $FileServerLocation -Name $User -ItemType "directory"
       $acl = Get-Acl $FileServerLocation$User
       $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(($DomainName+$User),"FullControl","Allow")
       $acl.SetAccessRule($AccessRule)
       $acl | Set-Acl $FileServerLocation$User
    }
}
