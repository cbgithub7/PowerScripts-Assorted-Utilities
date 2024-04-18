<#
.SYNOPSIS
    Reformats a column-based (multiline) input into a single line, comma-separated list with double quotes around each element.

.DESCRIPTION
    This script takes a column-based input where each item is on a new line and reformats it into a single line, comma-separated list. Each element is enclosed in double quotes. The script is useful for converting lists of items from one format to another.

.PARAMETER None
    This script does not accept any parameters. It prompts the user to input the list of websites.

.EXAMPLE
    .\Format-ColumnInputToSingleLine.ps1

    Prompts the user to input a list of websites, then formats and outputs the list.

.NOTES
    Author: Cody
    Date: April 18, 2024
    Version: 1.0
#>

# Prompt the user to input the list of websites
Write-Host "Enter the list of websites, each on a new line. Press Ctrl+Z followed by Enter when you're done."
$websites = @()
while ($line = Read-Host) {
    $websites += $line
}

# Remove any empty lines from the input
$websites = $websites | Where-Object { $_ -ne '' }

# Initialize an empty array to store formatted websites
$formattedWebsites = @()

# Loop through each website and format it
foreach ($website in $websites) {
    $formattedWebsites += "`"$website`""
}

# Combine the formatted websites into a single string
$output = '@(' + ($formattedWebsites -join ', ') + ')'

# Output the formatted list of websites
Write-Output $output
