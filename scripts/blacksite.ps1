Clear-Host

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "            BLACKSITE OPS v1.0" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

$Date = Get-Date -Format "MMMM dd, yyyy"

Write-Host "Date: $Date"
Write-Host ""

$Mission = Read-Host "Mission"
$Hours = Read-Host "Hours Studied"
$Technology = Read-Host "Technologies"
$Tasks = Read-Host "Tasks Completed"
$Problems = Read-Host "Problems Encountered"
$Tomorrow = Read-Host "Tomorrow's Goal"

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "Today's Entry"
Write-Host "---------------------------------------------"

Write-Host "Mission      : $Mission"
Write-Host "Hours        : $Hours"
Write-Host "Technology   : $Technology"
Write-Host "Tasks        : $Tasks"
Write-Host "Problems     : $Problems"
Write-Host "Tomorrow     : $Tomorrow"

Write-Host ""
# -----------------------------
# Save Entry to JSON
# -----------------------------

$Entry = @{
    Date = Get-Date -Format "yyyy-MM-dd"
    Mission = $Mission
    Hours = $Hours
    Technologies = $Technology
    Tasks = $Tasks
    Problems = $Problems
    Tomorrow = $Tomorrow
}

$JsonPath = ".\data\journal.json"

# Load existing journal entries
$Existing = Get-Content $JsonPath -Raw | ConvertFrom-Json

# Make sure we always have an array
if ($null -eq $Existing) {
    $Existing = @()
}

$Existing = @($Existing)

# Add today's entry
$Existing += $Entry

# Save back to JSON
$Existing | ConvertTo-Json -Depth 5 | Set-Content $JsonPath
# -----------------------------
# Build Markdown Log
# -----------------------------

$Year = Get-Date -Format "yyyy"
$Month = Get-Date -Format "MM"

$LogFolder = ".\logs\$Year\$Month"

if (!(Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Force -Path $LogFolder | Out-Null
}

$LogFile = "$LogFolder\$(Get-Date -Format 'yyyy-MM-dd').md"

@"
# Engineering Daily Report

**Date:** $Date

## Mission
$Mission

## Hours
$Hours

## Technologies
$Technology

## Work Completed
$Tasks

## Problems
$Problems

## Tomorrow
$Tomorrow
"@ | Set-Content $LogFile
# -----------------------------
# Git Automation
# -----------------------------

Write-Host ""
$Push = Read-Host "Push today's engineering log to GitHub? (Y/N)"

if ($Push.ToUpper() -eq "Y") {

    Write-Host ""
    Write-Host "Adding files..." -ForegroundColor Cyan
    git add .

    $CommitMessage = "Engineering Log - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

    Write-Host "Creating commit..." -ForegroundColor Cyan
    git commit -m $CommitMessage

    Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
    git push

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host " SUCCESS! Engineering Log Published" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
}
else {

    Write-Host ""
    Write-Host "Engineering log saved locally." -ForegroundColor Yellow

}