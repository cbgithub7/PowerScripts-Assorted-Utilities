<#
.SYNOPSIS
    Performs network diagnostics including ping, traceroute, and DNS lookup for a specified hostname or IP address.

.DESCRIPTION
    This script performs network diagnostics for a specified hostname or IP address. It includes the following tests:
    - Ping: Tests connectivity to the specified host.
    - Traceroute: Displays the route packets take to reach the specified host.
    - DNS Lookup: Performs a DNS resolution for the specified host.

.PARAMETER TargetHost
    Specifies the hostname or IP address to test.

.EXAMPLE
    .\Invoke-NetworkDiagnostics.ps1 -TargetHost "example.com"

    Performs network diagnostics for the hostname "example.com".

.NOTES
    Author: Cody
    Date: April 18, 2024
    Version: 1.0
#>

param (
    [string]$HostToTest
)

# Function to perform ping
function Test-Ping {
    param (
        [string]$targetHost
    )
    $result = Test-Connection -ComputerName $targetHost -Count 4 -ErrorAction SilentlyContinue
    if ($result) {
        Write-Output "Ping to ${targetHost} successful."
    } else {
        Write-Output "Ping to ${targetHost} failed."
    }
}

# Function to perform traceroute
function Test-Traceroute {
    param (
        [string]$targetHost
    )
    $result = tracert $targetHost
    Write-Output "Traceroute to ${targetHost}:"
    Write-Output $result
}

# Function to perform DNS lookup
function Test-DNSLookup {
    param (
        [string]$targetHost
    )
    $result = Resolve-DnsName -Name $targetHost
    Write-Output "DNS lookup for ${targetHost}:"
    Write-Output $result
}

# Main script
Test-Ping -targetHost $HostToTest
Test-Traceroute -targetHost $HostToTest
Test-DNSLookup -targetHost $HostToTest
