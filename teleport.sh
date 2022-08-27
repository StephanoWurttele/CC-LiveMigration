VM_destination="Debian"
VM_source="Debian4"

#Necesario que la maquina apagada
#$VBoxManage modifyvm $VM_destination --teleporter on --teleporterport 6000

#Recordar que se debe usar adaptador IDE PIIX4 para que funcione el teleport
#Start VM on listening
VBoxManage startvm $VM_destination &
#Sleep until VM is ready for teleport
sleep 4
#Start teleport
VBoxManage controlvm $VM_source teleport --host localhost --port 6000
#Set up metrics for policy
VBoxManage metrics setup --period 1 --samples 1 $VM_destination Guest/CPU/Load,Guest/RAM/Usage

