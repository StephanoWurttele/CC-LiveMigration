# Policy

In order for metrics to be read, Guest Additions must be installed in the VMs.

Run:
``` 
sh policy.sh <VM Instance Name>
```
Where VM Instance Name is the origin VM's name in the hypervisor.
i.e.:
```
sh policy.sh Debian administrator admin
```

# Simulation

Run:
``` 
sh policy.sh <VMs Name in common> <VM username> <VM password> 
```

Where VMs OS is the name that all machines in the transaction share, VM username is the username for all of them and VM password is the password for all of them.

In order for stress to be used, it must be installed by running:
```
sudo apt-get install stress
```

## stress parameters used

- \-c \<N\>: N workers to perform tasks sequentually through the cpu stress methods.
- \-i \<N\>: N workers calling sync(2) to buffer cache disk
- \-m \<N\>: N workers continuously calling mmap(2)/munmap(2) and writing to the allocated memory
- \-vm-bytes \<N unit\>: N units per vm worker
- \-t \<N unit\>: N workers creating timer events at a default rate of 1 MHz 
