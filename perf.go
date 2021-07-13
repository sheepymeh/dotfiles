package main

import (
	"io/ioutil"
	"fmt"
	"strings"
	"syscall"
)

func main() {
	syscall.Setuid(0)
	ioutil.WriteFile("/proc/acpi/call", []byte("\\_SB.PCI0.LPC0.EC0.FCMO"), 0660)
	status_, _ := ioutil.ReadFile("/proc/acpi/call")
	status := strings.Trim(string(status_[:]), "\x00\n")
	switch (status) {
		case "0x0":
			ioutil.WriteFile("/proc/acpi/call", []byte("\\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001"), 0660)
			fmt.Println(" Performance")
		case "0x1":
			ioutil.WriteFile("/proc/acpi/call", []byte("\\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001"), 0660)
			fmt.Println(" Battery")
		case "0x2":
			ioutil.WriteFile("/proc/acpi/call", []byte("\\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001"), 0660)
			fmt.Println(" Balanced")
	}
}