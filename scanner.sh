#!/bin/bash

#Install nmap dependency
#sudo apt install nmap -y

#Run simple nmap to check for live host between ip range 0-200 on 10.0.0.0
#nmap -sn $NTWRKADDR > targets.txt

# nmap flag references:
# -PP: nmap will send ICMP timestamp request (type 13) and expects ICMP timestamp replies (type 14).
# -sP/-sn: means no port scan and this flag will skips port discovery.
# nmap -sP -PP $NTWRKADDR
# added -PP flag for better network host discovery

# Static Variables
NTWRKADDR=192.168.12.0/24
LIVEHOSTS=$(wc -l < targets.txt) # check for targets from last scan
MAIN_MENU=("Network/Recon" "eXploits" "Vulnerability Report")
NETWORKING_MENU=("Scan Network" "Show Live Hosts" "Scan Ports" "Display Port Data")
XPLOIT_MENU=("SSH" "Database" "Windows" "Linux")

cat << "EOF"


███╗░░░███╗██╗██████╗░██████╗░██╗░░░░░███████╗░██████╗███████╗██╗░░██╗
████╗░████║██║██╔══██╗██╔══██╗██║░░░░░██╔════╝██╔════╝██╔════╝╚██╗██╔╝
██╔████╔██║██║██║░░██║██║░░██║██║░░░░░█████╗░░╚█████╗░█████╗░░░╚███╔╝░
██║╚██╔╝██║██║██║░░██║██║░░██║██║░░░░░██╔══╝░░░╚═══██╗██╔══╝░░░██╔██╗░
██║░╚═╝░██║██║██████╔╝██████╔╝███████╗███████╗██████╔╝███████╗██╔╝╚██╗
╚═╝░░░░░╚═╝╚═╝╚═════╝░╚═════╝░╚══════╝╚══════╝╚═════╝░╚══════╝╚═╝░░╚═╝

██╗░░░██╗███╗░░██╗██╗██╗░░░██╗███████╗██████╗░░██████╗██╗████████╗██╗░░░██╗
██║░░░██║████╗░██║██║██║░░░██║██╔════╝██╔══██╗██╔════╝██║╚══██╔══╝╚██╗░██╔╝
██║░░░██║██╔██╗██║██║╚██╗░██╔╝█████╗░░██████╔╝╚█████╗░██║░░░██║░░░░╚████╔╝░
██║░░░██║██║╚████║██║░╚████╔╝░██╔══╝░░██╔══██╗░╚═══██╗██║░░░██║░░░░░╚██╔╝░░
╚██████╔╝██║░╚███║██║░░╚██╔╝░░███████╗██║░░██║██████╔╝██║░░░██║░░░░░░██║░░░
░╚═════╝░╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═════╝░╚═╝░░░╚═╝░░░░░░╚═╝░░░
--------------------------------------------------------------------
--------------------------------------------------------------------
COURSE CODE: CST4550
COURSE TITLE: PEN TESTING AND DIGITAL FORENSICS
AUTHORS: KASHIM MOHAMMED & DANIEL BELLO
DATE: 25/02/2021
PROGRAMME: CYBER SECURITY AND PEN TESTING
--------------------------------------------------------------------
--------------------------------------------------------------------
EOF

progress_bar () {
	output=$(
		case $1 in
		[0-4]) echo -ne "[____________________]" ;;
		[5-9]) echo -ne "[#___________________]" ;;
		[1][0-4]) echo -ne "[##__________________]" ;;
		[1][5-9]) echo -ne "[###_________________]" ;;
		[2][0-4]) echo -ne "[####________________]" ;;
		[2][5-9]) echo -ne "[#####_______________]" ;;
		[3][0-4]) echo -ne "[######______________]" ;;
		[3][5-9]) echo -ne "[#######_____________]" ;;
		[4][0-4]) echo -ne "[########____________]" ;;
		[4][5-9]) echo -ne "[#########___________]" ;;
		[5][0-4]) echo -ne "[##########__________]" ;;
		[5][5-9]) echo -ne "[###########_________]" ;;
		[6][0-4]) echo -ne "[############________]" ;;
		[6][5-9]) echo -ne "[#############_______]" ;;
		[7][0-4]) echo -ne "[##############______]" ;;
		[7][5-9]) echo -ne "[###############_____]" ;;
		[8][0-4]) echo -ne "[################____]" ;;
		[8][5-9]) echo -ne "[#################___]" ;;
		[9][0-4]) echo -ne "[##################__]" ;;
		[9][5-9]) echo -ne "[###################_]" ;;
		100|00) echo -ne "[####################]" ;;
		*) echo -ne "Entry $1 did not match any cases!!!\n";;
		esac)
	printf "$output ($1%%)\r"
}

scan_network () {
	printf "Starting network scan....\n"
	nmap -sn -PP $NTWRKADDR > targets-full.txt && cat targets-full.txt | grep report | awk '{print $(NF)}' | sort -V > targets.txt
    LIVEHOSTS=$(wc -l < targets.txt)
    printf "Network scan done. Found $LIVEHOSTS live hosts.\n\n"
}

display_targets () {
	printf "\n********** ($LIVEHOSTS) Live Hosts **********\n"
	cat targets.txt
	printf "********** End of list **********\n\n"
}

scan_ports () {
	printf "Port scaning starting...\n"
	#nmap -Pn -iL targets.txt --stats-every 1s

	while read line; do
		HOLDER=$(echo $line | grep -o '.....%')
		# if loop checks if operand is nonzero in length (not empty). ignore empty lines
		if [[ -n "$HOLDER" ]]; then
			HOLDER=${HOLDER::-4} # truncate decimals. Stores whole number
			progress_bar $HOLDER
		fi
	done < <(nmap -Pn -iL targets.txt -oN targets-port-data.txt --stats-every 0.5s)
	echo -e "Port Scanning Comple!\n"
}

display_ports () {
	PS3='Select target to retrieve port data (return to menu: q): '
	#NOTE -A flag means array is associative; bound to specify their associated keys during assingment
	#declare -A assoc_array

	declare -a targets
	declare -a targets_data
	index=0;

	while read line; do
		#assoc_array[$line]="empty entry"
		targets[$index]=$line
		((index++))
	done < targets.txt

	index=0 #resets index
	while read line; do
		#if [[ ${line:0:1} == "#" ]] ; then echo "!!Hash Found: $line" && continue; fi
		[[ ${line:0:1} == "#" ]] && continue #skip lines with hashes
		[[ $line == "" ]] && ((index++)) && continue #treat incoming empty line as a delimeter

		#echo "Object $index; Line: $line" # debugging index/output
		#assoc_array[$index]+="$line\n" #store data in associated array
		targets_data[$index]+="$line\n"
	done < targets-port-data.txt

	#echo ${!my_array[@]} #Print list of targets
	select opt in "${targets[@]}"; do
	#while read -r -p "Select device (m:menu; q:main menu): "; do  #NOTE: -n1:expects 1 chars without pressing newline(enter); -r: ignore back slash escape characters; -p: prompt;
		case $REPLY in
			0) echo "Invalid input!";;
			[[:digit:]]) clear; echo -e ${targets_data[(($REPLY-1))]};;
			m) echo -e ${targets[@]};;
			t) echo -e ${targets_data[2]};;
			q) break;;
			*) echo "Invalid input!";;
		esac
	done
	clear
}

#--------------------- Menu Methods --------------------
networking_menu(){
	PS3='Please enter your choice (main menu: q): '
	echo -e "******* Networking Menu *******"
	select opt in "${NETWORKING_MENU[@]}"; do
		echo -e "******* eXploits Top Menu *******"
		case "$REPLY" in
		1)
			scan_network;;
		2)
			display_targets;;
		3)
			scan_ports;;
		4)
			display_ports;;
		q)
			echo "Returning to main menu..."
			break;;
		*) echo "invalid option $REPLY";;
		esac
	done
	clear
	PS3='Please enter your choice (main menu: q): '
}

xploit_menu(){
	PS3='Please enter your choice (main menu: q): '
	echo -e "******* eXploits Menu *******"
	select opt in "${XPLOIT_MENU[@]}"; do
		case "$REPLY" in
			1)
				echo "SSH";;
			2)
				echo "Database";;
			3)
				echo "Windows";;
			4)
				echo "Linux";;
			q)
				echo "Returning to main menu..."
				break;;
			*) echo "invalid option of $REPLY";;
		esac
	done
	clear
}

vuln_report(){
cat << "TEST"

                 .,,,,,,╓╖╗╗▄▄▄▄▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄▄▄▄▄▄╗╖╓,,,,,,
         ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
         ╫▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
         ╫▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ╚▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
         ╫▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌   ▀▓▓▓▓▓▌  ▓▓▓▓▓▓▀   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
         ╫▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓,  ▀▓▓▓▓▓▀  ▓▓▓▓▓▓M ,,▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
         ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌  └╨""`   ``"╙╨`  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
         ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                 ╒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
         ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌                ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
         ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄,            ,▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
         ╫▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
         ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
         ╘▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓Ñ
          ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀`╙▓▓▓▓▓▓▓▓▓▓▀▀▀▀▀▀▀▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
          ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌ .▓▓▀╜"`                   `"╜▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█
          ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀'                                 `╜▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
           ▓▓▓▓▓▓▓▓▓▓▌╙`       ,,┌╗▄▄▄▓▓▓▓▓▓▄▄╗╖,  ╔▓▓▓┐         ╝▓▓▓▓▓▓▓▓▓▓▓
           ╢▓▓▓▓▓▓▓⌐      ,,▄Φ  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌           ▀▓▓▓▓▓▓▓▓▌
            ▓▓▓▓▓▓▓▓w,▄▓▓▓▓▓Ω ,▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌,           ║▓▓▓▓▓▓▓
            └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
             ▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀"▓▓▓▓▓▓▓▓▓▓▀▀▀▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
              ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌ ╓▀▀╙``               `"╜▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
               ▓▓▓▓▓▓▓▓▓▓▓▓▓▀"                   ,╓╦.      "▀▓▓▓▓▓▓▓▓▓▓▓▓
                ▓▓▓▓▓▓▓▌╙`        Φ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█         ▀▓▓▓▓▓▓▓▓▓
                 ▓▓▓▓▓▓▌  ,╓▄▓▓Ω ,▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓,         ╙▓▓▓▓▓▓▓
                  ▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
                   "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀╙▓▓▓▓▓▓▓▓▓▓█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓╛
                     ▀▓▓▓▓▓▓▓▓▓▓▓▌ ª╨"`           ``╙▀▓▓▓▓▓▓▓▓▓▓▓▓▌
                      '▓▓▓▓▓▓▓▀"      ,,,╓╓╓,,,╗▓▓,     ╙▓▓▓▓▓▓▓▓^
                        ╙▓▓▓   ,,╦R ,▓▓▓▓▓▓▓▓▓▓▓▓▓▌       ╙▓▓▓▓╜
                          ╙▓▓▓▓▓▓▓▌▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓╜
                            "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌"
                              `╝▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
                                 "▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀`
                                    `╝▓▓▓▓▓▓▓▓▓▓▓▓╜`
                                        "▀▓▓▓▓╩`

Please wait while the coffee brews [generating report]...
TEST

	while read line; do
		HOLDER=$(echo $line | grep -o '.....%')
		if [[ -n "$HOLDER" ]]; then
			HOLDER=${HOLDER::-4}
			progress_bar $HOLDER
		fi
	done < <(nmap --script scripts/nmap-vulners/vulners.nse -sV $NTWRKADDR -oN vulnReport.txt --stats-every 0.5s)
	clear
	cat vulnReport.txt
	# nmap -Pn -iL targets.txt -oN targets-port-data.txt --stats-every 0.5s
}

#main loop that runs until user presses 5
home_menu () {
	echo -e "\n******* Main Menu *******"
	PS3='Please enter a choice (exit: q): '
	select opt in "${MAIN_MENU[@]}"; do
		case "$REPLY" in
		1)
			clear
			networking_menu;;
		2)
			clear
			xploit_menu;;
		3)
			clear
			vuln_report;;
		4|q)
			echo "Terminating Script...Goodbye."
			sleep 1
			break;;
		*) echo "invalid option $REPLY";;
		esac
		echo -e "******* Main Menu *******"
		PS3='Please enter a choice (exit: q): '
		REPLY=
	done
}

main() {
	home_menu
	clear
}

main
