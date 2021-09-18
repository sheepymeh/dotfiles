package main

import (
	"io/ioutil"
	"fmt"
	"os"
	"strconv"
	"strings"
	"syscall"
)

func main() {
	syscall.Setuid(0)
	status_, _ := ioutil.ReadFile("/sys/class/power_supply/ADP0/online")
	status := strings.Trim(string(status_[:]), "\n")
	charge_, _ := ioutil.ReadFile("/sys/class/power_supply/BAT0/capacity")
	charge, _ := strconv.Atoi(strings.Trim(string(charge_[:]), "\n"))
	conservation_mode_, _ := ioutil.ReadFile("/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode")
	conservation_mode := strings.Trim(string(conservation_mode_[:]), "\x00\n")

	if len(os.Args) > 1 {
		if conservation_mode == "0" {
			conservation_mode = "1"
		} else {
			conservation_mode = "0"
		}
		ioutil.WriteFile("/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode", []byte(conservation_mode), 0644)
	}

	switch {
		case charge < 10:
			fmt.Print("")
		case charge < 35:
			fmt.Print("")
		case charge < 65:
			fmt.Print("")
		case charge < 90:
			fmt.Print("")
		default:
			fmt.Print("")
	}
	fmt.Printf(" %d%%", charge)

	if status == "1" {
		if conservation_mode == "0" {
			fmt.Println(" ")
		} else {
			fmt.Println(" ")
		}
	} else {
		fmt.Println()
	}

	if status == "0" {
		if charge < 20 {
			fmt.Println("#ce575d")
		}
	} else if status == "Not*" {
		if charge < 90 {
			fmt.Println("#FFFF00")
		}
	} else if status == "Charging" {
		if charge < 20 {
			fmt.Println("#ffe665")
		} else if charge > 80 {
			fmt.Println("#77dd77")
		}
	}
}