#!/bin/sh
echo '\_SB.PCI0.LPC0.EC0.FCMO' > /proc/acpi/call
status=$(cat /proc/acpi/call | cut -d '' -f1)
if [[ $status = "0x0" ]]; then
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' > /proc/acpi/call
	echo ' Performance'
elif [[ $status = "0x1" ]]; then
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' > /proc/acpi/call
	echo ' Battery'
elif [[ $status = "0x2" ]]; then
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' > /proc/acpi/call
	echo ' Balanced'	
fi
