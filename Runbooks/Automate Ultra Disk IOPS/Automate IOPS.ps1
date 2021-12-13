[string] $FailureMessage = "Failed to execute the command"
[int] $RetryCount = 3 
[int] $TimeoutInSecs = 20
$RetryFlag = $true
$Attempt = 1

do
{
    #-----L O G I N - A U T H E N T I C A T I O N-----
    $connectionName = "AzureRunAsConnection"
    try
    {
        #Flag for CSP subs
        $enableClassicVMs = Get-AutomationVariable -Name 'External_EnableClassicVMs'
        Write-Output "Logging into Azure subscription using Az cmdlets..."

        Import-Module Az.Resources
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        Add-AzAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
        
        Write-Output "Successfully logged into Azure subscription using Az cmdlets..."

        $RetryFlag = $false
    }
    catch 
    {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."

            $RetryFlag = $false

            throw $ErrorMessage
        }

        if ($Attempt -gt $RetryCount) 
        {
            Write-Output "$FailureMessage! Total retry attempts: $RetryCount"

            Write-Output "[Error Message] $($_.exception.message) `n"

            $RetryFlag = $false
        }
        else 
        {
            Write-Output "[$Attempt/$RetryCount] $FailureMessage. Retrying in $TimeoutInSecs seconds..."

            Start-Sleep -Seconds $TimeoutInSecs

            $Attempt = $Attempt + 1
        }   
    }
}
while($RetryFlag)

#-----------F U N C T I O N------------
$rgName="<FMI>"
$diskName="<FMI>"
$disk = Get-AzDisk -ResourceGroupName $rgName -Name $diskName

# Get Current IOPS / Mbps
$DiskIOPSCurrent = $disk.DiskIOPSReadWrite
$DiskMBpsCurrent = $disk.DiskMBpsReadWrite
Write-Output "Current IOPS: $DiskIOPSCurrent"
Write-Output "Current MBps: $DiskMBpsCurrent"

#Time Constraint
$DateTimeCurrent = (Get-Date)

######--------------------Must Adjust Accordingly-----------------------#######
### Winter Time (November 7 ---> March 13)
#$IncreaseTime = (Get-Date -Hour 12 -Minute 35)
#$DecreaseTime = (Get-Date -Hour 00 -Minute 5)
#Write-Output "CurrentTime: $DateTimeCurrent"
#Write-Output "IncreaseTime: $IncreaseTime"
#Write-Output "DecreaseTime: $DecreaseTime"
#---Course Of Action---
#---Reducing---
#if($DateTimeCurrent -gt $DecreaseTime -AND $DateTimeCurrent -lt $IncreaseTime )
#{
#    $diskupdateconfig = New-AzDiskUpdateConfig -DiskIOPSReadWrite 2084 -DiskMBpsReadWrite 63
#   Update-AzDisk -ResourceGroupName $rgName -DiskName $diskName -DiskUpdate $diskupdateconfig
#    Write-Output "Decreasing Performance to IOPS: 2084, MBps: 63"
#}
#--Increasing---
#elseif($DateTimeCurrent -gt $IncreaseTime)
#{
#    $diskupdateconfig = New-AzDiskUpdateConfig -DiskIOPSReadWrite 8000 -DiskMBpsReadWrite 700
#    Update-AzDisk -ResourceGroupName $rgName -DiskName $diskName -DiskUpdate $diskupdateconfig
#    Write-Output "Increasing Performance to IOPS: 8000, MBps: 700"
#}
#end


### Daylight Saving hours (March 14 ---> November 7)
$IncreaseTime = (Get-Date -Hour 11 -Minute 35)
$DecreaseTime = (Get-Date -Hour 23 -Minute 5)
Write-Output "CurrentTime: $DateTimeCurrent"
Write-Output "IncreaseTime: $IncreaseTime"
Write-Output "DecreaseTime: $DecreaseTime"
######------------------------------------------------------------------#######


#---Course Of Action---
#---Reducing---
if($DateTimeCurrent -gt $DecreaseTime -OR $DateTimeCurrent -lt $IncreaseTime )
{
    $diskupdateconfig = New-AzDiskUpdateConfig -DiskIOPSReadWrite 2084 -DiskMBpsReadWrite 63
    Update-AzDisk -ResourceGroupName $rgName -DiskName $diskName -DiskUpdate $diskupdateconfig
    Write-Output "Decreasing Performance to IOPS: 2084, MBps: 63"
}
#--Increasing---
elseif($DateTimeCurrent -gt $IncreaseTime -AND $DateTimeCurrent -lt $DecreaseTime)
{
    $diskupdateconfig = New-AzDiskUpdateConfig -DiskIOPSReadWrite 8000 -DiskMBpsReadWrite 700
    Update-AzDisk -ResourceGroupName $rgName -DiskName $diskName -DiskUpdate $diskupdateconfig
    Write-Output "Increasing Performance to IOPS: 8000, MBps: 700"
}
#end
