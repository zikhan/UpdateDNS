# Update DNS script

Used to update DNS records for Lithium Hosting because I got tired of all the DDNS services either not working or requiring the same type of api call to update the IP.

## Setup

Open the crontab file in an editor
`crontab -e`

Fill in the parameters and paste to the end of the file

`*/30 * * * * /bin/pwsh -File DnsUpdate.ps1 -AuthKey $AuthKey -Endpoint $ENDPOINT -Zone $ZONE -SubDomain $SUBDOMAIN`

## Why powershell

Cause powershell can parse annoying xml docs from SOAP apis out of the box.
