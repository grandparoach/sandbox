# sandbox
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgrandparoach%2Fsandbox%2Fweka%2F%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This sample will deploy a number of HC44rs VMSS instances onto an existing VNet.
It will also deploy a jumpbox with a public IP address
All of the instances will have a 1TB premium disk attached and mounted over /opt

It will also create ssh keys that will enable the root user to ssh between all the nodes without requiring a password.





