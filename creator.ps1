$GroupToCheck = "MyGroupToCheck"
$FileServerLocation = "\\MyServer\MyCentralShare\"
$DomainName = "MyDomainName\"
$UsersInGroup = Get-ADGroupMember -Identity $GroupToCheck
$UsersSAMs = [System.Collections.ArrayList]@()

Write-Host $UsersInGroup
foreach ($User in $UsersInGroup) { 

    $User = $User.samaccountname
    $UsersSAMs.Add($User)

    if(Test-Path ($FileServerLocation + $User)){

        $UserAccessAv = 0
        $acl = Get-ACL $FileServerLocation$User
        $rules = $acl.access | Where-Object {-not $_.IsInherited}

        ForEach($rule in $rules){
            if($rule.IdentityReference -like ($DomainName + $User)){
                $UserAccessAv = 1
                Break
            }
        }

        if($UserAccessAv -eq 0){
           $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(($DomainName+$User),"FullControl","Allow")
           $acl.SetAccessRule($AccessRule)
           $acl | Set-Acl $FileServerLocation$User
           Write-Host "Written"
        }            
    }

    else{
       New-Item -Path $FileServerLocation -Name $User -ItemType "directory"
       $acl = Get-Acl $FileServerLocation$User
       $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(($DomainName+$User),"FullControl","Allow")
       $acl.SetAccessRule($AccessRule)
       $acl | Set-Acl $FileServerLocation$User
    }
}


foreach ($Folder in Get-ChildItem -Path $FileServerLocation -Recurse -Directory -Force -ErrorAction SilentlyContinue){
    
    if($UsersSAMs -notcontains (Split-Path $Folder -Leaf)){
        $acl = Get-ACL ($FileServerLocation + $Folder)
        $rules = $acl.access | Where-Object { 
            (-not $_.IsInherited) -and 
            $_.IdentityReference -like ($DomainName + (Split-Path $Folder -Leaf))
        }

        ForEach($rule in $rules) {
            $acl.RemoveAccessRule($rule) | Out-Null
        }

        Set-ACL -Path ($FileServerLocation + $Folder) -AclObject $acl
    }
}
