#!/bin/bash

# Function to check if a command is installed
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run a task
run_task() {
    case $1 in
        1) subfinder -d "$domain_name" -t 30  -o allsub.txt;;
        2) amass enum -brute -d "$domain_name" -o allsub1.txt -silent;;
        3) ./remove.sh;;
        4) ./crt.sh "$domain_name" > allsub3.txt;;
        5) sort allsub.txt allsub1.txt allsub3.txt | uniq > finalsubdomains.txt;;
        6) cat finalsubdomains.txt | httpx -t 30 | tee -a subdomain.txt;;
        7) cat subdomain.txt | waybackurls | tee -a waybackurls.txt;;
        8) python3 /dict/dict -l /dict/dict/subdomain.txt -t 100 #add here your directory 
        --format=plain dir.txt;;
        9) grep "403" dir.txt;;
        10) create_subdomain2;;
        11) subzy run --targets allsub.txt --hide_fails | tee -a subzy.txt;;
        12) cat subdomain.txt | nuclei -o nuclei.txt;;
        13) echo "Exiting the script."; exit 0;;
        *) echo "Invalid option. Please select a valid task.";;
    esac
}

# Function to create subdomain2.txt and run Nmap
create_subdomain2() {
   cat subdomain.txt | sed -e 's/^https\?:\/\///' > subdomain2.txt
   sudo nmap -iL subdomain2.txt -p- | sudo tee -a nmap.txt
}

# Trap Ctrl+C to allow interruption of tasks
trap 'echo "Task interrupted. Press any key to continue..."; read -n 1' INT

# Function to display the script logo
display_logo() {
    clear
    echo -e "\e[31m"
    cat << "EOF"
 _   _ ___________ _____
| | | |_   _| ___ \  ___|
| | | | | | | |_/ / |__
| | | | | | | ___ \  __|
\ \_/ /_| |_| |_/ / |___
 \___/ \___/\____/\____/

              - a recon tool bash script

EOF
    echo -e "\e[0m"
}

# Display the script logo
display_logo

# Question 1: VPN status
read -p "1) Are you connected to a VPN or proxy to avoid blocking ip? (y/n): " vpn_status

# Check if the user is connected to a VPN
if [ "$vpn_status" == "n" ]; then
    echo "You need to be connected to a VPN or proxy to run this program (for saving you ip address from blcoking by site)."
    exit 1
fi

# Ask for the domain name
echo -e "\e[32mPlease enter the domain name for eq - example.com:\e[0m"
read domain_name

# Define tasks with descriptions
tasks=("Subfinder - Discover subdomains using Subfinder"
       "Amass - Enumerate subdomains using Amass"
       "Removing and cleaning of the domain"
       "crt.sh - Query crt.sh for subdomains"
       "Combine & Remove Duplicates - Combine subdomain lists and remove duplicates"
       "HTTPX - Probe subdomains for live hosts using HTTPX"
       "Waybackurls - Extract URLs from Wayback Machine archives"
       "dirsearch - Perform directory and file brute-forcing using dirsearch"
       "Check for 403 responses - Check for 403 Forbidden responses in dirsearch output"
       "Create subdomain2.txt and run Nmap"
       "Subzy - Check for subdomain takeovers using Subzy"
       "Nuclei - Perform security scanning using Nuclei"
       "Exit - Exit the script")

# Task selection menu
while true; do
    PS3="Select a task (1-$(( ${#tasks[@]} - 1 )) or 0 to exit): "
    select task in "${tasks[@]}"; do
        case $REPLY in
            0) echo "Exiting the script."; exit 0;;
            9) create_subdomain2;;
            12) echo "Exiting the script."; exit 0;;
            *) run_task "$REPLY";;
        esac
        break
    done
done
