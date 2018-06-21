<#
.SYNOPSIS
    Exports a CSV report of users in $Domain who have not logged in for 90 days.

.DESCRIPTION
    Exports a CSV report of users in $Domain who have not logged in for 90 days.
    CSV Headers are:
        SamAccountName,
        Name,
        LastLogonDate,
        Enabled,
        Domain,
        ObjectGuid
    Output file is written to .\$DomainHead_90DayAccounts_YYYYmmdd_HHMM.csv

.EXAMPLE
    Get-90DayAccounts -Domain ad.contoso.com

.NOTES

#>
param (
        # Target Domain to get GPO Reports from. ("*.*")
        [Parameter(Mandatory=$True)]
        [ValidatePattern( ".+\..+" )]
        [string]
        $Domain,

        # Name of the Outputfile ("path.csv") (Optional)
        [Parameter(Mandatory = $false)]
        [ValidateScript( {-not(test-path $_ -PathType Container)} )]
        [ValidatePattern( ".+\.csv")]
        [string]
        $OutputFile
)

Process {
    $Date = Get-Date -UFormat %Y%m%d_%H%M
    $90DaysAgo = (get-date).adddays(-90)

    $DomainHead = $Domain.Split(".")[0]

    if($OutputFile -like "") {
        $OutputFile =  -join ("$DomainHead", "_90DayAccounts_$Date.csv")
    }
   
    Write-Output "Reading Users from AD"
    $users = Get-ADUser -Server $Domain -filter {LastLogonDate -lt $90DaysAgo} -Properties LastLogonDate

    Write-Output "Writing Output File"
    $users | Add-Member -NotePropertyName "Domain" -NotePropertyValue "$Domain" -Force
    $users | Select-Object -Property SamAccountName, Name, LastLogonDate, Enabled, Domain, ObjectGuid | Export-Csv -NoTypeInformation -Path "$OutputFile"
    Write-Output "Output written to $OutputFile"
}
