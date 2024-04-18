# PowerScripts-Assorted-Utilities

Welcome to my personal repository of assorted PowerShell scripts! This repository contains a collection of PowerShell scripts that I've created for various utility tasks that came up at one time or another, or were just constructed for fun.

## Scripts Overview

Here's a brief overview of the scripts available in this repository:

1. **CheckFileInUse.ps1**: This script checks if a specified file is currently in use by any process. It provides options to terminate processes using the file and delete the file, sending it to the Recycle Bin if desired.

2. **BlockDomainsInFirewall.ps1**: This script blocks traffic to specified domains by creating outbound firewall rules for each domain's associated IP addresses.

3. **BlockDomainsInHostsFile.ps1**: This script blocks specified domains by adding entries to the hosts file, redirecting them to the loopback address (127.0.0.1).

4. **FormatHostsFileEntries.ps1**: This script reformats a column-based (multiline) input into a single line, comma-separated format with double quotes around each element, suitable for hosts file entries.

5. **GetMACAddresses.ps1**: This script retrieves a list of IP and MAC addresses from the ARP cache, filtering out local and known devices, and categorizes MAC addresses as unicast, multicast, or broadcast.

6. **SearchFirewallRulesForDomain.ps1**: This script searches non-default firewall rules for a specified domain, matching the resolved IP addresses against the IP scopes of the rules.

Feel free to explore and use these scripts for your own purposes.

## Usage

To use any of the scripts in this repository, simply clone or download the repository to your local machine and run the scripts using PowerShell. Make sure to read the script comments and documentation for specific usage instructions.

## License

This repository is licensed under the [MIT License](LICENSE).
