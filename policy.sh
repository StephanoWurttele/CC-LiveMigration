#/bin/bash

teleport_machine(){
 
	if [[ $1 == "Debian" ]]; then
    vboxmanage modifyvm Debian4 --teleporter on --teleporterport 6000
		vboxmanage startvm Debian4 &

		sleep 4
		
		VBoxManage controlvm $1 teleport --host localhost --port 6000

		VBoxManage metrics setup --period 1 --samples 1 Debian4 Guest/CPU/Load,Guest/RAM/Usage
	fi
	if [[ $1 == "Debian4" ]]; then
		vboxmanage startvm Debian &

		sleep 4
		
		VBoxManage controlvm $1 teleport --host localhost --port 6000

		VBoxManage metrics setup --period 1 --samples 1 Debian Guest/CPU/Load,Guest/RAM/Usage
	fi

	if [[ $1 == "Debian2" ]]; then
		vboxmanage startvm Debian3 &

		sleep 4
		
		VBoxManage controlvm $1 teleport --host localhost --port 6666

		VBoxManage metrics setup --period 1 --samples 1 Debian3 Guest/CPU/Load,Guest/RAM/Usage
	fi
	if [[ $1 == "Debian3" ]]; then
		vboxmanage startvm Debian2 &

		sleep 4
		
		VBoxManage controlvm $1 teleport --host localhost --port 6666
		
		VBoxManage metrics setup --period 1 --samples 1 Debian2 Guest/CPU/Load,Guest/RAM/Usage
	fi	

}

cpu_min_idle=0.1
ram_min_free=200000
is_running=$(vboxmanage showvminfo $1 | grep -c "running (since")
if [[ $is_running -eq 0 ]]; then
  vboxmanage startvm $1;
  read  -n 1 -p "Press enter when system is done booting:" input
fi
vboxmanage metrics setup --period 1 --samples 1 $1 Guest/CPU/Load,Guest/RAM/Usage
sleep 1
vms_var=$(vboxmanage list vms runningvms |  awk -F" " '{print $1}' | sed 's/"//g')
for vm in $vms_var
do
	teleported=false
  	echo "QUERYING" $vm "METRICS"
	vm_query=$(vboxmanage metrics query $vm | grep -E 'Guest.*CPU.*Idle:max') 
	vm_cpu_idle=$(echo $vm_query | awk -F" " '{print $3}')
	vm_query=$(vboxmanage metrics query $vm | grep -E 'Guest.*RAM.*Free:max') 
	vm_ram_free=$(echo $vm_query | awk -F" " '{print $3}') 
	echo $vm "IDLE CPU" $vm_cpu_idle
	echo $vm "FREE RAM" $vm_ram_free
  	if [[ -z $vm_cpu_idle ]] || [[ -z $vm_ram_free ]]; then
    	echo "System metrics not yet loaded. Please, run this program again"
    	exit
  	fi
	if [[ $vm_cpu_idle <  $cpu_min_idle ]]; then
		echo "HIGH CPU USAGE"
		teleport_machine $vm
		teleported=true
	fi
  	if (( $vm_ram_free <  $ram_min_free )) && (( !$teleported )); then
		echo "HIGH RAM USAGE"
		teleport_machine $vm
	fi
done
