${C`ReD} = Get-Credential
${Se`Ssi`oN} = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential ${CR`ed} -Authentication Basic -AllowRedirection
${ImP`O`RTCMd} = Import-PSSession ${sE`ssION}

${u`sE`RToFiNd} = Read-Host -Prompt "Enter user to find (leave blank for all)"

${pA`RAms} = @{}
if([string]::IsNullOrEmpty(${usErt`O`Fi`ND}) -eq ${fa`LSe})
{${PAr`AMS} = @{Identity = ${Us`Er`TOf`ind}}
}


${US`ERMaILBo`XSTA`TS} = Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited ${P`ARamS} | Get-MailboxStatistics
${USe`RMAiLBOX`sT`Ats} | Add-Member -MemberType ScriptProperty -Name TotalItemSizeInBytes -Value {${Th`Is}.TotalItemSize -replace "(.*\()|,| [a-z]*\)", ""}
${u`seR`MaI`lb`o`xStATS} | Select-Object DisplayName, TotalItemSizeInBytes,@{Name="TotalItemSize (GB)"; Expression={[math]::Round(${_}.TotalItemSizeInBytes/1GB,2)}}
