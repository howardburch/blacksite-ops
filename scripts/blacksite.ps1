Clear-Host

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "            BLACKSITE OPS v0.3" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

$Date = Get-Date -Format "MMMM dd, yyyy"
# -----------------------------
# Generate Session ID
# -----------------------------

$JournalPath = ".\data\journal.json"

if (Test-Path $JournalPath) {

    $Entries = Get-Content $JournalPath -Raw | ConvertFrom-Json

    if ($Entries -eq $null) {
        $Count = 0
    }
    else {
        $Count = @($Entries).Count
    }

}
else {

    $Count = 0

}

$Session = "OPS-{0:D4}" -f ($Count + 1)
Write-Host "Date: $Date"
Write-Host ""


$Hours = Read-Host "Hours Studied"
$Technology = Read-Host "Technologies"
$Tasks = Read-Host "Session Notes"
$Problems = Read-Host "Difficulties"
$Tomorrow = Read-Host "Next Goals"

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "Today's Entry"
Write-Host "---------------------------------------------"

Write-Host "Session      : $Session"
Write-Host "Hours        : $Hours"
Write-Host "Technology    : $Technology"
Write-Host "Session Notes : $Tasks"
Write-Host "Difficulties  : $Problems"
Write-Host "Next Goals    : $Tomorrow"

Write-Host ""
# -----------------------------
# Save Entry to JSON
# -----------------------------

$Entry = @{
    Session = $Session
    Date = Get-Date -Format "yyyy-MM-dd"
    Hours = $Hours
    Technologies = $Technology
    SessionNotes = $Tasks
    Difficulties = $Problems
    NextGoals = $Tomorrow
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

## Session
$Session

## Hours
$Hours

## Technologies
$Technology

## Session Notes
$Tasks

## Difficulties
$Problems

## Next Goals
$Tomorrow
"@ | Set-Content $LogFile
# -----------------------------
# Session Statistics
# -----------------------------

$Entries = Get-Content ".\data\journal.json" -Raw | ConvertFrom-Json

$Entries = @($Entries)

$Today = Get-Date
$CurrentWeek = [System.Globalization.CultureInfo]::CurrentCulture.Calendar.GetWeekOfYear(
    $Today,
    [System.Globalization.CalendarWeekRule]::FirstFourDayWeek,
    [DayOfWeek]::Monday
)

$CurrentMonth = $Today.Month
$CurrentYear = $Today.Year

$LifetimeHours = 0
$WeekHours = 0
$MonthHours = 0

foreach ($Entry in $Entries) {

    $Hours = [double]$Entry.Hours
    $EntryDate = [datetime]$Entry.Date

    $LifetimeHours += $Hours

    $EntryWeek = [System.Globalization.CultureInfo]::CurrentCulture.Calendar.GetWeekOfYear(
        $EntryDate,
        [System.Globalization.CalendarWeekRule]::FirstFourDayWeek,
        [DayOfWeek]::Monday
    )

    if ($EntryWeek -eq $CurrentWeek -and $EntryDate.Year -eq $CurrentYear) {
        $WeekHours += $Hours
    }

    if ($EntryDate.Month -eq $CurrentMonth -and $EntryDate.Year -eq $CurrentYear) {
        $MonthHours += $Hours
    }

}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "             BLACKSITE OPS STATS" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host ("Session           : {0}" -f $Session)
Write-Host ("Today's Hours     : {0}" -f $Hours)
Write-Host ("Week Total        : {0}" -f $WeekHours)
Write-Host ("Month Total       : {0}" -f $MonthHours)
Write-Host ("Lifetime Hours    : {0}" -f $LifetimeHours)
Write-Host ("Sessions Logged   : {0}" -f $Entries.Count)

Write-Host "=================================================="
Write-Host ""
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