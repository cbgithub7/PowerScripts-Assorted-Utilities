<#
.SYNOPSIS
    Creates firewall rules to block outbound traffic to specified domains based on their resolved IP addresses.

.DESCRIPTION
    This script creates firewall rules to block outbound traffic to specified domains by resolving their domain names to obtain their IP addresses. For each domain, it extracts the first two letters from the domain name and creates firewall rules to block traffic to each resolved IP address associated with the domain.

.PARAMETER None
    This script does not accept any parameters. It defines the domains to block and creates firewall rules accordingly.

.EXAMPLE
    .\BlockDomains.ps1

    Creates firewall rules to block outbound traffic to the specified domains.

.NOTES
    Author: Cody
    Date: April 18, 2024
    Version: 1.0
#>

# Define the domains to block
$domainsToBlock = @("example1.com", "example2.com", "example3.com")
foreach ($domain in $domainsToBlock) {
    try {
        # Extract the two letters from the website name
        $firstTwoLetters = $domain.Substring(0, 2)
        # Resolve the domain to obtain its IP addresses
        $ipAddresses = [System.Net.Dns]::GetHostAddresses($domain) | Select-Object -ExpandProperty IPAddressToString

        # Create firewall rules to block traffic to each IP address associated with the domain
        foreach ($ip in $ipAddresses) {
            New-NetFirewallRule -DisplayName "Block all traffic for $firstTwoLetters" -Direction Outbound -Action Block -RemoteAddress $ip -Profile Any -Enabled True
        }
    } catch {
        # Extract more information about the exception
        $exceptionMessage = $_.Exception.Message

        # Display detailed information about the exception
        Write-Host "Failed to resolve IP addresses for $($domain):"
        Write-Host "Exception Message: $exceptionMessage"
    }
}
