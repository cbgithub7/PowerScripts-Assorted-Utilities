<#
.SYNOPSIS
    Checks if a specified file is currently in use by any process and provides options to terminate processes using the file and delete the file.

.DESCRIPTION
    This script checks if a specified file is currently in use by any process. If the file is in use, it provides the option to terminate the processes using the file and delete the file. If the user chooses to delete the file, it is sent to the Recycle Bin for safe deletion.

.PARAMETER None
    This script does not accept any parameters. It prompts the user to enter the full path of the file to check.

.EXAMPLE
    .\Check-FileUsageAndDelete.ps1

    Prompts the user to enter the full path of the file to check. If the file is in use by any process, it offers options to terminate the processes and delete the file.

.NOTES
    Author: Cody
    Date: April 18, 2024
    Version: 1.0
#>

# Prompt the user to enter the full path of the file to check
$filePath = Read-Host "Enter the full path of the file you want to check (e.g., C:\path\to\file.docx):"

# Check if the file exists
if (Test-Path $filePath) {
    Write-Host "File exists."

    try {
        $fileInUse = $false
        $processesUsingFile = @()

        # Get process IDs using the file
        $processes = Get-Process
        foreach ($process in $processes) {
            $commandLine = $process | Select-Object -ExpandProperty CommandLine
            # Check if the process command line contains the file path
            if ($commandLine -match [regex]::Escape($filePath)) {
                $fileInUse = $true
                $processesUsingFile += $process
                Write-Host "Process $($process.ProcessName) (PID: $($process.Id)) is using the file."
            }
        }

        # If no process is using the file, proceed with deletion
        if (-not $fileInUse) {
            Write-Host "No process is using the file."
        } else {
            # Prompt user to confirm deletion
            $userResponse = Read-Host "Do you want to end the process(es) and delete the file? (yes/no)"
            if ($userResponse -match '^(yes|y)$') {
                # Terminate processes using the file
                foreach ($process in $processesUsingFile) {
                    $process | Stop-Process -Force
                    Write-Host "Process $($process.ProcessName) (PID: $($process.Id)) has been terminated."
                }
                
                # Dispose of StreamReader object to release file handle
                $null = [System.GC]::Collect()
                
                # Check if Recycle module is installed, if not install it
                if (-not (Get-Module -Name Recycle -ListAvailable)) {
                    Write-Host "Installing Recycle module..."
                    Install-Module -Name Recycle -Scope CurrentUser -Force
                }
                
                # Send file to Recycle Bin using Remove-ItemSafely cmdlet from Recycle module
                Remove-ItemSafely -Path $filePath -Verbose
                
                Write-Host "File has been sent to the recycle bin."
            } elseif ($userResponse -match '^(no|n)$') {
                Write-Host "File deletion aborted."
            } else {
                Write-Host "Invalid input. File deletion aborted."
            }
        }
    } catch {
        Write-Host "Error occurred while checking for processes using the file: $_"
    }
} else {
    Write-Host "File does not exist."
}
