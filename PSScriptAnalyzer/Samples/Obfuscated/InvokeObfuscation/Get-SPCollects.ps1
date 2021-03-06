 <#
	.SYNOPSIS
		A cmdlet to get SP Collects from an EMC storage array using naviseccli. NAVISECCLI MUST BE IN THE SYSTEM PATH

	.DESCRIPTION
		The Get-SPCollects cmdlet allows you to gather SP Collects from EMC storage units via naviseccli.
		
		Provide the cmdlet an array of SP IP's and it will download the SP Collects to the current folder. 

	.PARAMETER  IP
		A list of the SP IP's to query for SP Collects.

    .PARAMETER Path
        The location of where the files are downloaded. If not provided the current location is used.

	.EXAMPLE
		PS C:\> $ips = "192.168.1.10", "192.168.1.11"
		PS C:\> Get-SPCollects $ips
		This example shows how to call the Get-SPCollects function with named parameters.


	.INPUTS
		System.String

	.OUTPUTS
		SP Collect Files

	.NOTES
		Name:		Get-SPCollects
		Author:		Justin Rich
		Website:	http://jrich523.wordpress.com
		LastEdit:	4/11/2012
		

#>
function Get-SPCollects {
	[CmdletBinding()]
	param(
		[Parameter(poSiTiON=0, MAnDATOrY=$true)]
		[String[]]
		$IP,
        [string] $path=$pwd
	)
	process {
		
        $dt = Get-Date -Format "yyyy-MM-dd"
        $sb = {
                $path, $ips = $args

                while ( ($ips | measure-object -property complete -sum)."S`um" -lt $ips."cou`Nt")
                {
                    sleep 30
                    $ips | ? {$_."cO`mPLETe" -eq 0} | %{
                        $file = $_."Fi`LE"
                        $ip = $_."I`p"
                        if(naviseccli -h $ip managefiles -list | ? {$_ -match "$file.*data.zip"})
                        {
                            naviseccli -h $ip managefiles -retrieve -path $path -file $matches[0] -o
                            $_."co`mP`lETe" = 1

                        }
                    }
                 }
                        
              }

        try {
			$results = @()
            foreach ($ip in $ips)
			{
				naviseccli -h $ip spcollect -messner | out-null
                sleep 2
                write-verbose "SP Collect started for $ip"
                $file = naviseccli -h $ip managefiles -list | ?{$_ -match "APM.*$dt.*\.txt"}|%{$matches[0] -replace "_runlog.txt"}
                $obj = New-Object psobject
                $obj | Add-Member -MemberType NoteProperty -Name 'IP' -Value $ip
                $obj | Add-Member -MemberType NoteProperty -Name 'File' -Value $file
                $obj | Add-Member -MemberType NoteProperty -Name 'Complete' -Value 0
                $results += $obj

			}

			Write-Host "SP Collects requested, retrieving running in background.."
            $job = Start-Job -ScriptBlock $sb -Name spcollect -ArgumentList $path,$results
            Register-ObjectEvent -InputObject $job -EventName statechanged -Action {write-host "`nSP Collects $($job.state)";remove-job spcollect;remove-job j2 -force} -SourceIdentifier j2 | out-null
		}
		catch {
		Write-Error "AN ERROR WAS ENCOUNERED!"
		}
	}
}
