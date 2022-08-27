#/bin/bash

#VBoxManage metrics setup --period 1 --samples 1 Debian Guest/CPU/Load,Guest/RAM/Usage
#VBoxManage metrics setup --period 1 --samples 1 Debian2 Guest/CPU/Load,Guest/RAM/Usage
#VBoxManage metrics setup --period 1 --samples 1 Debian3 Guest/CPU/Load,Guest/RAM/Usage
#VBoxManage metrics setup --period 1 --samples 1 Debian4 Guest/CPU/Load,Guest/RAM/Usage


teleport_machine(){
 
	if [[ $1 == "Debian" ]]; then
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


stress_machine(){
	VBoxManage guestcontrol $1 run --exe "/usr/bin/stress" --username administrador --password admin -- stress -c 8 -i 4 -m 2 --vm-bytes 128M -t 10s
}

cpu_min_idle=0.2
ram_min_free=100000

for (( i = 0; i < 10; i++ )); do

vms_var=$(vboxmanage list vms runningvms |  awk -F" " '{print $1}' | sed 's/"//g')

	for vm in $vms_var
	do
		probability=$(($RANDOM % 3))
		echo $probability
		if [[ $probability == 1 ]]; then
			stress_machine $vm
		fi
		teleported=false
		vm_query=$(vboxmanage metrics query $vm | grep -E 'Guest.*CPU.*Idle:max') 
		vm_cpu_idle=$(echo $vm_query | awk -F" " '{print $3}')
		vm_query=$(vboxmanage metrics query $vm | grep -E 'Guest.*RAM.*Free:max') 
		vm_ram_free=$(echo $vm_query | awk -F" " '{print $3}') 
		echo $vm "IDLE CPU" $vm_cpu_idle
		echo $vm "FREE RAM" $vm_ram_free
		if [[ $vm_cpu_idle <  $cpu_min_idle ]]; then
			echo "HIGH CPU USAGE"
			teleport_machine $vm
			teleported=true
		fi
		if [[ $vm_ram_free <  $ram_min_free && $teleported ]]; then
			echo "HIGH RAM USAGE"
			teleport_machine $vm
		fi
	done
	sleep 2
done
