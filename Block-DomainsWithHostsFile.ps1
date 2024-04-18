<#
.SYNOPSIS
    Blocks specified domains by adding entries to the hosts file.

.DESCRIPTION
    This script blocks specified domains by adding entries to the hosts file located at "C:\Windows\System32\drivers\etc\hosts". It checks if the domains are already blocked in the hosts file and appends entries for those that are not blocked.

.PARAMETER None
    This script does not accept any parameters. It defines the domains to block and adds entries to the hosts file accordingly.

.EXAMPLE
    .\BlockDomains.ps1

    Blocks the domains specified in the script by adding entries to the hosts file.

.NOTES
    Author: Cody
    Date: April 18, 2024
    Version: 1.0
#>

# Define the domains to block
$domainsToBlock = @("example1.com", "example2.com", "example3.com")

# Path to the hosts file
$hostsFilePath = "C:\Windows\System32\drivers\etc\hosts"

foreach ($domainToBlock in $domainsToBlock) {
    # Check if the domain is already blocked in the hosts file
    if ((Get-Content $hostsFilePath) -match ("^127\.0\.0\.1\s+$domainToBlock\s*$")) {
        Write-Host "Domain $domainToBlock is already blocked."
    } else {
        # Append a line to the hosts file to block the domain
        Add-Content -Path $hostsFilePath -Value ("127.0.0.1 $domainToBlock")
        Write-Host "Domain $domainToBlock has been blocked."
    }
}
