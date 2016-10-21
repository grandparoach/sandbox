# sandbox
This sample will deploy:
1. A new isolated Virtual Network 
2. A Jump Box with a public IP address - DS14v2 with 3 x 1TB Premium Disks attached
3. Up to 100 instances of a VM Scale Set (Implicit Availability Set)

This template does not run any scripts.  The attached disks are not formatted or striped.
The NFS Service has not been installed or configured.

There are no SSH keys
The only user ID is the admin user that gets specified as an input parameter along with the password



