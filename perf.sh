#!/bin/sh
status=$(cat /proc/acpi/call | cut -d '' -f1)
if [[ $status = "not called" ]]; then
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' > /proc/acpi/call
	echo ' Balanced'
elif [[ $status = "0x1fb01" ]]; then
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' > /proc/acpi/call
	echo ' Performance'
elif [[ $status = "0x8012b01" ]]; then
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' > /proc/acpi/call
	echo ' Battery'
elif [[ $status = "0x8013b01" ]]; then
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' > /proc/acpi/call
	echo ' Balanced'	
fi
