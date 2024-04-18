<#
.SYNOPSIS
    Performs MAC address vendor lookup for unicast MAC addresses discovered on the local network.

.DESCRIPTION
    This script retrieves the list of IP addresses and MAC addresses from the ARP cache of the local machine, filters out known and local devices, and performs MAC address vendor lookup for unicast MAC addresses using a REST API. It includes the following functionalities:
    - Retrieving IP addresses and MAC addresses from the ARP cache.
    - Filtering out known and local devices.
    - Determining the type of MAC address (Broadcast, Multicast, or Unicast).
    - Optionally performing MAC address vendor lookup for unicast MAC addresses with rate limiting.

.PARAMETER None
    This script does not accept any parameters. It retrieves information directly from the local ARP cache.

.EXAMPLE
    .\Get-DeviceMACInfo.ps1

    Performs MAC address vendor lookup for unicast MAC addresses discovered on the local network.

.NOTES
    Author: Cody
    Date: April 18, 2024
    Version: 1.0
#>

# Function to determine MAC address type
function Get-MACAddressType {
    param (
        [string]$MACAddress
    )

    if ($MACAddress -eq "ff-ff-ff-ff-ff-ff") {
        return "Broadcast"
    }

    try {
        # Extract the first byte of the MAC address
        $firstByte = [convert]::ToByte($MACAddress.Substring(0, 2), 16)

        if (($firstByte -band 1) -eq 1) {
            return "Multicast"
        }
    } catch {
        # Invalid MAC address format
        return "Invalid"
    }

    # If not broadcast or multicast, consider it unicast
    return "Unicast"
}

# Function to perform MAC address vendor lookup with rate limiting
function Get-MACVendorWithRateLimit {
    param (
        [string]$MACAddress
    )

    # API endpoint for MAC address vendor lookup
    $url = "https://api.macvendors.com/$MACAddress"

    try {
        # Invoke REST API to get vendor information
        $response = Invoke-RestMethod -Uri $url -ErrorAction Stop
        return $response
    } catch {
        Write-Warning "Failed to lookup MAC address vendor: $_"
        return $null
    }
}

# Function to generate list of IP addresses and MAC addresses
function Get-IPMACAddresses {
    # Query ARP cache to get list of devices
    $arpCache = arp -a | Select-String '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | ForEach-Object {
        $fields = $_ -split '\s+'
        [PSCustomObject]@{
            IPAddress = $fields[1]
            MACAddress = $fields[2]
        }
    }

    # Filter out local device and known devices (such as routers or gateways)
    $filteredDevices = $arpCache | Where-Object { $_.IPAddress -notmatch "^(127\.|192\.168\.)" }

    # Add MAC address type column
    $filteredDevices | ForEach-Object {
        $_ | Add-Member -MemberType NoteProperty -Name MACAddressType -Value (Get-MACAddressType -MACAddress $_.MACAddress) -PassThru
    }
}

# Get list of IP and MAC addresses
$devices = Get-IPMACAddresses

# Output list of IP and MAC addresses
Write-Host "List of discovered devices:"
$devices | Format-Table

# Prompt user if they want to perform MAC address vendor lookup
$choice = Read-Host "Would you like to perform MAC address vendor lookup for unicast MAC addresses? (yes/no)"
while ($choice -notmatch "^(?i)(yes|no|y|n)$") {
    Write-Host "Invalid input. Please enter 'yes' or 'no' (or 'y' or 'n')."
    $choice = Read-Host "Would you like to perform MAC address vendor lookup for unicast MAC addresses? (yes/no)"
}

if ($choice -match "^(?i)(yes|y)$") {
    # Perform MAC address vendor lookup for each unicast MAC address with rate limiting
    foreach ($device in ($devices | Where-Object { $_.MACAddressType -eq "Unicast" })) {
        if ($device.MACAddressType -ne "Invalid") {
            $vendor = Get-MACVendorWithRateLimit -MACAddress $device.MACAddress
            if ($vendor) {
                Write-Host "MAC Address: $($device.MACAddress), Vendor: $vendor, Type: $($device.MACAddressType)"
            } else {
                Write-Host "MAC Address: $($device.MACAddress), Vendor: Unknown, Type: $($device.MACAddressType)"
            }
        } else {
            Write-Host "Invalid MAC Address: $($device.MACAddress)"
        }

        # Delay to comply with rate limit (slightly more than 500 milliseconds)
        Start-Sleep -Milliseconds 900
    }
} else {
    Write-Host "MAC address vendor lookup for unicast MAC addresses skipped."
}
