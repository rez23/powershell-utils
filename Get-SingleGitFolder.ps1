<#
.SYNOPSIS
Downloads all files from a specific folder in a GitHub repository branch.

.DESCRIPTION
Queries the GitHub Trees API for the specified repository and branch, filters files
under the target folder, and downloads each file into a local output directory.
Only files (blob entries) are downloaded.

.PARAMETER Branch
Branch name to read from in the target repository.
Default: main
Alias: b

.PARAMETER Folder
Repository folder path to download files from (for example: src/utils).
Alias: f

.PARAMETER Repo
GitHub repository in owner/name format (for example: octocat/Hello-World).
Alias: r

.PARAMETER OutputDir
Local folder to save downloaded files into.
If omitted or empty, defaults to ./downloaded-folder. When an empty value is
explicitly passed, the script derives the folder name from the leaf of -Folder.
Alias: o

.EXAMPLE
./Get-SingleGitFolder.ps1 -Repo "octocat/Hello-World" -Folder "docs"

Downloads all files under docs/ from the main branch to ./downloaded-folder.

.EXAMPLE
./Get-SingleGitFolder.ps1 -r "microsoft/PowerShell" -f "tools/packaging" -b "master" -o "./pkg"

Downloads files under tools/packaging/ from the master branch into ./pkg.

.NOTES
Requires internet access and permission to read the target repository.
For private repositories, this script would need authentication headers.
#>

param(
    [Parameter(Mandatory = $false)]    
    [Alias('b')]
    [string]$Branch = 'main',

    [Parameter(Mandatory = $true, Position = 0)]
    [Alias('f')]
    [string]$Folder,
    [Parameter(Mandatory = $true, Position = 1)]
    [Alias('r')]
    [string]$Repo,

    [Parameter(Mandatory = $false)]
    [Alias('o')]
    [string]$OutputDir = './downloaded-folder'
)

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $leaf = Split-Path -Path $Folder -Leaf
    if ([string]::IsNullOrWhiteSpace($leaf)) {
        $leaf = 'downloaded-folder'
    }
    $OutputDir = "./$leaf"
}

New-Item -ItemType Directory -Path $OutputDir -Force

Write-Host "Downloading folder '$Folder' from $Repo (branch: $Branch)"
Write-Host "Saving to: $OutputDir"
Write-Host ""

$apiUrl = "https://api.github.com/repos/${Repo}/git/trees/${Branch}?recursive=1"

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Headers @{ Accept = 'application/vnd.github.v3+json' }
}
catch {
    Write-Error "Failed to fetch file list from GitHub API: $($_.Exception.Message)"
    exit 1
}

$prefix = "$Folder/"
$files = @($response.tree | Where-Object { $_.path -like "$prefix*" -and $_.type -eq 'blob' } | Select-Object -ExpandProperty path)

if ($files.Count -eq 0) {
    Write-Warning "No files found under '$Folder' in $Repo on branch '$Branch'."
    exit 1
}

foreach ($filePath in $files) {
    $fileName = Split-Path -Path $filePath -Leaf
    $destination = Join-Path -Path $OutputDir -ChildPath $fileName
    $rawUrl = "https://raw.githubusercontent.com/$Repo/$Branch/$filePath"

    Write-Host "Downloading: $filePath -> $destination"

    try {
        Invoke-WebRequest -Uri $rawUrl -OutFile $destination -UseBasicParsing | Out-Null
    }
    catch {
        Write-Warning "Failed to download ${filePath}: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "Folder downloaded to $OutputDir"