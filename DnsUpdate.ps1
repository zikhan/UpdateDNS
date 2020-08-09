#! /usr/bin/pwsh
[CmdletBinding()]
param (
    # Used to Authentacate to LiPanel API
    [Parameter()]
    [string]
    $AuthKey,
    # LiPanel Soap endpoint
    [Parameter()]
    [string]
    $Endpoint,
    # zone to update
    [Parameter()]
    [string]
    $Zone,
    # subdomain to update for zone
    [Parameter()]
    [string]
    $SubDomain
)

$liFullUrl = "${Endpoint}?authkey=$AuthKey";
$ContentType = 'text/xml;charset=utf-8'

# Check if record exists
function Test-RecordExists {
    $recordExistsReq = "<Envelope xmlns=`"http://schemas.xmlsoap.org/soap/envelope/`"><Body><dns_remove_record xmlns=`"urn:net.apnscp.api`"><zone>$Zone</zone><subdomain>$SubDomain</subdomain><rr>A</rr><param></param></dns_remove_record></Body></Envelope>"
    $recordExistsResp = Invoke-RestMethod $liFullUrl -Method Post -ContentType $ContentType -Headers @{SOAPAction='urn:net.apnscp.soap#dns_record_exists'} -Body $recordExistsReq
    return $recordExistsResp.Envelope.Body.dns_record_existsResponse.return.'#text'
}

# Delete record
function Remove-Record {
    $deleteRecordReq = "<Envelope xmlns=`"http://schemas.xmlsoap.org/soap/envelope/`"><Body><dns_remove_record xmlns=`"urn:net.apnscp.api`"><zone>$Zone</zone><subdomain>$SubDomain</subdomain><rr>A</rr><param></param></dns_remove_record></Body></Envelope>"
    $deleteRecordResp = Invoke-RestMethod $liFullUrl -Method Post -ContentType $ContentType -Headers @{SOAPAction='urn:net.apnscp.soap#dns_remove_record'} -Body $deleteRecordReq
    return $deleteRecordResp.Envelope.Body.dns_remove_recordResponse.return.'#text'
}

# Add Record
function Add-Record {
    param ([Parameter(ValueFromPipeline=$true)][string] $IP)
    $addRecordReq = "<Envelope xmlns=`"http://schemas.xmlsoap.org/soap/envelope/`"><Body><dns_add_record xmlns=`"urn:net.apnscp.api`"><zone>$Zone</zone><subdomain>$SubDomain</subdomain><rr>A</rr><param>${IP}</param><ttl>14400</ttl></dns_add_record></Body></Envelope>"
    $addRecordResp = Invoke-RestMethod $liFullUrl -Method Post -ContentType $ContentType -Headers @{SOAPAction='urn:net.apnscp.soap#dns_add_record'} -Body $addRecordReq
    return $addRecordResp.Envelope.Body.dns_add_recordResponse.return.'#text'
}

function Get-IP {
    return (Invoke-RestMethod https://checkip.amazonaws.com).Trim()
}

while (Test-RecordExists) {
    if(Remove-Record -eq $false) {
        Write-Host "DNS Update encountered an error"
        exit 1;
    }
}

if ( (Get-IP | Add-Record) -eq $true ) {
    Write-Host "$SubDomain.$Zone successfully updated"
    exit 0;
}
else {
    Write-Host "DNS Update encountered an error"
    exit 1
}