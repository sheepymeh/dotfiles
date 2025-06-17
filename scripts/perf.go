package main

import (
	"io/ioutil"
	"os"
	"fmt"
	"strings"
	"syscall"
)

func update(mode string) {
	switch (mode) {
		case "0x0":
			// balanced -> performance
			ioutil.WriteFile("/sys/devices/system/cpu/cpufreq/boost", []byte("1"), 0644)
			ioutil.WriteFile("/proc/acpi/call", []byte("\\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001"), 0660)
			fmt.Println("󰓅")
		case "0x1":
			// performance -> battery saver
			ioutil.WriteFile("/sys/devices/system/cpu/cpufreq/boost", []byte("0"), 0644)
			ioutil.WriteFile("/proc/acpi/call", []byte("\\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001"), 0660)
			fmt.Println("󰾆")
		case "0x2":
			// battery saver -> balanced
			ioutil.WriteFile("/sys/devices/system/cpu/cpufreq/boost", []byte("1"), 0644)
			ioutil.WriteFile("/proc/acpi/call", []byte("\\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001"), 0660)
			fmt.Println("󰾅")
		default:
			help("Invalid mode")
	}
}

func help(err string) {
	fmt.Printf("error: %s\n\nUsage: perf [mode]\nChange the performance setting of the laptop.\n\n  mode  The new performance mode to switch to. Possible modes:\n          0x0: performance mode\n          0x1: battery saver mode\n          0x2: balanced mode\n\nIf the mode is not specified, the program will loop in the order of:\n  balanced -> performance -> battery -> balanced\n\nRequires setuid permissions.\n\n", err)
}

func main() {
	syscall.Setuid(0)
	switch (len(os.Args)) {
		case 1:
			ioutil.WriteFile("/proc/acpi/call", []byte("\\_SB.PCI0.LPC0.EC0.FCMO"), 0660)
			mode_, _ := ioutil.ReadFile("/proc/acpi/call")
			mode := strings.Trim(string(mode_[:]), "\x00\n")
			update(mode)
		case 2:
			// Modes: 0x0: performance; 0x1: battery; 0x2: balanced
			update(os.Args[1])
		default:
			help("Invalid number of arguments")
	}
}
