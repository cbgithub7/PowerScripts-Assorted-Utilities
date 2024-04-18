<#
.SYNOPSIS
    Checks non-default firewall rules to determine if a specified domain's resolved IP addresses fall within their scope.

.DESCRIPTION
    This script resolves the IP addresses associated with a specified domain and checks them against non-default firewall rules to determine if any rules are blocking traffic to or from the domain. It retrieves non-default firewall rules, excluding default Windows rules, and matches the resolved IP addresses with the IP scopes of the rules. The script displays matching firewall rules along with their details, including the rule name, IP address, IP range, and address family.

.PARAMETER None
    This script does not accept any parameters. It prompts the user to input the domain to check and whether to include inbound rules in the search.

.EXAMPLE
    .\Check-FirewallRuleForDomainBlock.ps1

    Prompts the user to input a domain to check against non-default firewall rules and whether to include inbound rules in the search. Displays matching firewall rules and their details.

.NOTES
    Author: Cody
    Date: April 18, 2024
    Version: 1.0
#>

# Function to truncate a string to a maximum length and append "..." if truncated
function TruncateString {
    param(
        [string]$inputString,
        [int]$maxLength
    )

    if ($inputString.Length -le $maxLength) {
        return $inputString
    } else {
        return $inputString.Substring(0, $maxLength - 3) + "..."
    }
}

# Function to print a line separator for the ASCII-style table
function PrintSeparator {
    Write-Host ("+" + "-"*30 + "+" + "-"*20 + "+" + "-"*20 + "+" + "-"*20 + "+")
}

# Prompt the user to input the domain to check
$domain = Read-Host "Enter the domain to check"

# Resolve the domain to obtain its IP addresses
try {
    $ipAddresses = [System.Net.Dns]::GetHostAddresses($domain) | Select-Object -ExpandProperty IPAddressToString
} catch {
    Write-Host "Failed to resolve IP addresses for [$domain]"
    exit
}

# List the resolved IP addresses
Write-Host "Resolved IP addresses for [$domain]:"
$ipAddresses

# Get all firewall rules excluding default Windows rules
$nonDefaultFirewallRules = Get-NetFirewallRule |
    Where-Object {
        $_.Owner -ne "Microsoft" -and           # Exclude rules owned by Microsoft
        $_.DisplayName -notmatch "^(?:CoreNet-|FWX_)" -and  # Exclude rules with certain display name patterns
        $_.Program -notmatch "^%SystemRoot%" -and           # Exclude rules associated with system binaries
        $_.Action -ne "Allow" -and                         # Exclude rules with Allow action
        $_.Profile -ne "Domain" -and                       # Exclude rules specific to the Domain profile
        $_.Profile -ne "Public"                            # Exclude rules specific to the Public profile
    }

# Count the total number of both inbound and outbound rules
$totalInboundRules = ($nonDefaultFirewallRules | Where-Object { $_.Direction -eq "Inbound" }).Count
$totalOutboundRules = ($nonDefaultFirewallRules | Where-Object { $_.Direction -eq "Outbound" }).Count

# Print the total number of both inbound and outbound rules
Write-Host "Total number of non-default inbound rules: $totalInboundRules"
Write-Host "Total number of non-default outbound rules: $totalOutboundRules"

# Prompt the user to choose whether to check inbound rules as well
do {
    $checkInbound = Read-Host "Do you want to check inbound rules as well? (yes/no)"
} until ($checkInbound -match '^(yes|no|y|n)$')

$checkInbound = $checkInbound.ToLower()

# If the user chooses to check inbound rules, include them; otherwise, only check outbound rules
if ($checkInbound -eq "yes" -or $checkInbound -eq "y") {
    $firewallRulesToCheck = $nonDefaultFirewallRules
} else {
    $firewallRulesToCheck = $nonDefaultFirewallRules | Where-Object { $_.Direction -eq "Outbound" }
}

# Start measuring the total search time
$totalSearchTime = Measure-Command {
    # Display text indicating the start of the search
    Write-Host "Searching for firewall rules for domain [$domain]..."

    # Initialize an array to store matching results
    $matchingResults = @()

    # Loop through each non-default firewall rule
    foreach ($firewallRule in $firewallRulesToCheck) {
        Write-Host "Searching non-default rule for [$domain]: $($firewallRule.DisplayName)"

        # Get the associated address filter for the rule
        $addressFilter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $firewallRule

        # Loop through each resolved IP address
        foreach ($ip in $ipAddresses) {
            # Check if the resolved IP is included in the IP scope of the firewall rule
            if ($addressFilter.RemoteAddress -like "*$ip*") {
                # Add matching result to the array
                $matchingResults += [PSCustomObject]@{
                    RuleName = TruncateString -inputString $firewallRule.DisplayName -maxLength 30
                    IP = $ip
                    IPRange = $addressFilter.RemoteAddress
                    AddressFamily = $addressFilter.AddressFamily
                }
            }
        }
    }
}

# Print matching results in ASCII-style box-cell table
if ($matchingResults.Count -gt 0) {
    Write-Host "Matching firewall rules for domain [$domain]:"
    PrintSeparator
    Write-Host ("|{0,-30}|{1,-20}|{2,-20}|{3,-20}|" -f "Rule Name", "IP", "IP Range", "Address Family")
    PrintSeparator
    foreach ($result in $matchingResults) {
        Write-Host ("|{0,-30}|{1,-20}|{2,-20}|{3,-20}|" -f $result.RuleName, $result.IP, $result.IPRange, $result.AddressFamily)
    }
    PrintSeparator
} else {
    Write-Host "No matching firewall rules found for domain [$domain]."
}

# Display the total elapsed time
Write-Host "Total search time: $($totalSearchTime.TotalSeconds) seconds"
