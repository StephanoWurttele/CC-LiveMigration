# Policy

Run:
``` sh policy.sh <VM Instance Name> <VM username> <VM password> ```
i.e.:
```
sh policy.sh Debian administrator admin
```
## stress-ng parameters used

- \-c \<N\>: N workers to perform tasks sequentually through the cpu stress methods.
- \-i \<N\>: N workers calling sync(2) to buffer cache disk
- \-m \<N\>: N workers continuously calling mmap(2)/munmap(2) and writing to the allocated memory
- \-vm-bytes \<N unit\>: N units per vm worker
- \-t \<N unit\>: N workers creating timer events at a default rate of 1 MHz 
