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

	output := ""
	switch {
		case charge < 10:
			output = ""
		case charge < 35:
			output = ""
		case charge < 65:
			output = ""
		case charge < 90:
			output = ""
		default:
			output = ""
	}
	conservation_mode_output := ""
	if status == "1" {
		if conservation_mode == "0" {
			conservation_mode_output = " "
		} else {
			conservation_mode_output = " "
		}
	}
	fmt.Printf("%s %d%%%s\n\n", output, charge, conservation_mode_output)

	if status == "0" {
		if charge < 20 {
			fmt.Println("#f38ba8")
		}
	} else if status == "Not*" {
		if charge < 90 {
			fmt.Println("#fab387")
		}
	} else if status == "Charging" {
		if charge < 20 {
			fmt.Println("#f9e2af")
		} else if charge > 80 {
			fmt.Println("#a6e3a1")
		}
	}
}
