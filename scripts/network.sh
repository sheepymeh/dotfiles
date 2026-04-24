#!/bin/bash
set -Eeuo pipefail
enable sleep

render() {
	networkctl status --json=short |
	jq -r '[.Interfaces[]
		| select(.Type != "loopback")
		| if .Type == "ether" then
				. as $i |
				if $i.OperationalState == "missing" or $i.OperationalState == "off" then "󰤭"
				elif $i.OperationalState == "no-carrier" then "󰈂"
				elif $i.OperationalState == "dormant" then ""
				elif $i.OperationalState == "carrier" then "󰈁"
				elif $i.OperationalState == "degraded" or $i.OperationalState == "degraded-carrier" then ""
				elif $i.OperationalState == "routable" then "󰈀"
				elif $i.OperationalState == "enslaved" then ""
				else "" end
			elif .Type == "wlan" then
				. as $i |
				if $i.OperationalState == "missing" or $i.OperationalState == "off" then "󰤭"
				elif $i.OperationalState == "no-carrier" then ""
				elif $i.OperationalState == "dormant" then ""
				elif $i.OperationalState == "carrier" then "󰈁"
				elif $i.OperationalState == "degraded" or $i.OperationalState == "degraded-carrier" then ""
				elif $i.OperationalState == "routable" then ""
				elif $i.OperationalState == "enslaved" then ""
				else "" end
			else "" end
		| select(. != "")] | join("  ")
	'
}

render

ip monitor link addr route |
while read -r line; do
case "$line" in
	*"link"*|*"addr"*|*"route"*)
	render
	;;
esac
done
