# Script Name: Update-Repo.ps1
#
# Description:
#   Updates a destination file in a Git submodule directory (DataDir) with content from a source file
#   and commits the change to Git if necessary. Ensures the submodule is on the master branch and
#   up to date with origin's master branch using a rebase before committing.
#
# Usage:
#   .\Update-Repo.ps1 -DataDir <DATADIR> -DestFile <DEST_FILE> -SrcFile <SRC_FILE> -CommitMsg <COMMIT_MSG>
#
# Parameters:
#   DataDir     - The submodule directory where the destination file is stored. Created if it does not exist.
#   DestFile    - The filename in DataDir to be updated or created.
#   SrcFile     - The full path to the source file providing the content.
#   CommitMsg   - The message for the Git commit if a commit is performed.
#
# Behavior:
#   - Creates DataDir if it doesn’t exist and assumes it’s an initialized Git submodule.
#   - Switches DataDir to the master branch and updates it to origin/master with rebase.
#   - Exits with an error if SrcFile does not exist or Git operations fail.
#   - Updates DestFile with SrcFile content and commits if changes are detected.
#   - If DestFile is identical to SrcFile, exits without changes.
#
# Exit Codes:
#   0 - Success (files identical or update committed).
#   1 - Error (invalid arguments, file not found, Git failure).
#
# Notes:
#   - File comparison assumes text content; binary files may require alternative methods.
#

# Define parameters
param (
    [Parameter(Mandatory=$true)][string]$DataDir,
    [Parameter(Mandatory=$true)][string]$DestFile,
    [Parameter(Mandatory=$true)][string]$SrcFile,
    [Parameter(Mandatory=$true)][string]$CommitMsg
)

# Check for correct number of arguments
if ($PSBoundParameters.Count -ne 4) {
    Write-Output "Usage: .\Update-Repo.ps1 -DataDir <DATADIR> -DestFile <DEST_FILE> -SrcFile <SRC_FILE> -CommitMsg <COMMIT_MSG>"
    exit 1
}

# Create DataDir if it doesn’t exist
if (-not (Test-Path -Path $DataDir -PathType Container)) {
    try {
        New-Item -Path $DataDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Write-Output "Created directory $DataDir"
    } catch {
        Write-Output "Error: Failed to create directory $DataDir"
        exit 1
    }
}

# Change to DataDir
try {
    Set-Location -Path $DataDir -ErrorAction Stop
} catch {
    Write-Output "Error: Failed to change to directory $DataDir"
    exit 1
}

# Fetch the latest changes from origin
& "C:\Program Files\Git\bin\git.exe" fetch origin
if ($LASTEXITCODE -ne 0) {
    Write-Output "Error: Git fetch failed in $DataDir"
    exit 1
}

# Try to checkout master; if it fails, create it from origin/master
& "C:\Program Files\Git\bin\git.exe" checkout master 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    & "C:\Program Files\Git\bin\git.exe" checkout -b master origin/master
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to create master branch in $DataDir"
        exit 1
    }
}

# Pull with rebase to update to origin/master
& "C:\Program Files\Git\bin\git.exe" pull --rebase origin master
if ($LASTEXITCODE -ne 0) {
    Write-Output "Error: Git pull --rebase failed in $DataDir"
    exit 1
}

# Check if SrcFile exists
if (-not (Test-Path -Path $SrcFile -PathType Leaf)) {
    Write-Output "Error: Source file $SrcFile does not exist"
    exit 1
}

# Define destination path relative to DataDir
$DestPath = Join-Path -Path $DataDir -ChildPath $DestFile

# Update and commit logic
if (Test-Path -Path $DestPath -PathType Leaf) {
    # Destination exists; compare with source
    try {
        $srcContent = Get-Content -Path $SrcFile -Raw -ErrorAction Stop
        $destContent = Get-Content -Path $DestPath -Raw -ErrorAction Stop
        if ($srcContent -eq $destContent) {
            Write-Output "Destination file $DestFile in $DataDir is identical to source file $SrcFile"
            exit 0
        }
    } catch {
        Write-Output "Error: Failed to read files for comparison"
        exit 1
    }
    # Files differ; update and commit
    try {
        Copy-Item -Path $SrcFile -Destination $DestPath -Force -ErrorAction Stop
    } catch {
        Write-Output "Error: Failed to copy $SrcFile to $DestPath"
        exit 1
    }
    & "C:\Program Files\Git\bin\git.exe" add $DestPath
    & "C:\Program Files\Git\bin\git.exe" commit -m "$CommitMsg"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Git commit failed in $DataDir"
        exit 1
    }
    Write-Output "Updated $DestFile in $DataDir and committed changes"
} else {
    # Destination doesn’t exist; copy and commit
    try {
        Copy-Item -Path $SrcFile -Destination $DestPath -Force -ErrorAction Stop
    } catch {
        Write-Output "Error: Failed to copy $SrcFile to $DestPath"
        exit 1
    }
    & "C:\Program Files\Git\bin\git.exe" add $DestPath
    & "C:\Program Files\Git\bin\git.exe" commit -m "$CommitMsg"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Git commit failed in $DataDir"
        exit 1
    }
    Write-Output "Created $DestFile in $DataDir and committed changes"
}

exit 0
