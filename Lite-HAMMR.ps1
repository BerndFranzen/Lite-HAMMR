<#

    SWGOH Mod-HAMMR Lite Build 26-24 (c)2026 SuperSix/Schattenlegion

#>

<# 

Changes

- 

Bugfixes

- 

#>

# CSS for output table form

param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({
        if ($_ -match '^\d{9}$') { $true }
        else { throw "Please provide a valid allycode (e.g. 832123322)."}
    })]
    [string]$AllyCode
)

$header = @"
<style>

    h1 {
        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;
    }
    
    h2 {
        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;
    }
   
   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
        width:100%
    } 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        padding: 10px 15px;
        vertical-align: middle;   
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
        vertical-align: middle;
    }

</style>

"@


$RequestHeader = @{

 "cache-control"="no-cache"
 "x-gg-bot-access"="31a9a"
 "Accept-Encoding" = "gzip, deflate, br"

}

function CheckPrerequisites() {
    
    Clear-Host
    Write-Host $VersionString  -ForegroundColor Green
    Write-Host

    # Check if all prerequisites are met

    if ($PSVersionTable.PSVersion.Major -lt 7) {Write-Host "ERROR - This script requires Microsoft Powershell 7 or higher" -ForegroundColor Red; Break}
    $ParseModule = Get-Module PSParseHTML -ListAvailable -ErrorAction SilentlyContinue
    If ($null -eq $ParseModule) { Install-Module -Name PSParseHTML -AllowClobber -Force }

}


# Define static data

$ModSetShort = ("","HE","OF","DE","SP","CC","CD","PO","TE")
$ModSetLong = ("","Health","Offense","Defense","Speed","Critical Chance","Critical Damage","Potency","Tenacity") 
$SlotNameList = ("","","Transmitter","Receiver","Processor","Holo-Array","Data-Bus","Multiplexer")
$ModMetaUrlList = ("https://swgoh.gg/stats/mod-meta-report/all/","https://swgoh.gg/stats/mod-meta-report/guilds_100_gp/")
$VersionString = "SWGOH Mod-HAMMR Lite Build 26-24 (c)2026 SuperSix/Schatten-Legion"

CheckPrerequisites

$ModMetaModeList = ("Strict","Relaxed")

# Load player data

Write-Host "Calculating statistics for " -foregroundcolor green -NoNewline

$RosterInfo = (Invoke-WebRequest ("http://swgoh.gg/api/player/" + $AllyCode) -Headers $RequestHeader -HttpVersion "2.0" -ErrorAction SilentlyContinue).Content | ConvertFrom-Json

Write-Host $RosterInfo.data.name, "" -foregroundcolor blue -NoNewline
Write-Host $RosterInfo.data.last_updated -ForegroundColor DarkGray

Write-Host "Loading support data" -ForegroundColor Green


$MetaHash = @{}

ForEach ($ModMetaUrl in $ModMetaUrlList) {

    $RawMetaInfo = (Invoke-WebRequest $ModMetaUrl -Headers $RequestHeader -HttpVersion "2.0").Content | Optimize-HTML    
    $RawMetaHelperList = $RawMetaInfo.Split('data-unit-def-tooltip-app=')
    $RawMetaHelperList = $RawMetaHelperList[1..($RawMetaHelperList.count -1)]
    $RawMetaHelperHash = @{}

    ForEach ($RawMetaHelperListEntry in $RawMetaHelperList) {

        $Identifier = $RawMetaHelperListEntry.Split(' ')[0]
        $RawMetaHelperHash[$Identifier] = $RawMetaHelperListEntry
    }

    $RawMetaList = (($RawMetaInfo | ConvertFrom-HtmlTable)) | Where-Object {$_.Receiver -ne ""}
    $RawMetaList | Add-Member -Name "base_id" -MemberType NoteProperty -Value ""

    If ($ModMetaUrl -like "*guilds_100_gp*") { 
        
        $RawMetaList | Add-Member -Name "Mode" -MemberType NoteProperty -Value "Strict"
        $MetaCharList = @()
               
    } else {
        
        $RawMetaList | Add-Member -Name "Mode" -MemberType NoteProperty -Value "Relaxed"
    
    }

    ForEach ($RawMetaObject in $RawMetaList) {

        # $SearchTarget = ($UnitsList | Where-Object {$_.name -like $RawMetaObject.Character}).base_id

        $SearchTarget = ($RosterInfo.units.data | Where-Object {$_.name -like $RawMetaObject.Character}).base_id

        if ($Searchtarget) {

            $RawMetaObject.base_id = $SearchTarget
            $SetMetaInfo = $RawMetaHelperHash[$SearchTarget].Substring(0,$RawMetaHelperHash[$SearchTarget].IndexOf("</div></div></div></div></div></td>"))  
        
            $SetResults = @()

            $SetResults += ($SetMetaInfo | Select-String "Critical Damage").matches.Value
            $SetResults += ($SetMetaInfo | Select-String "Speed").matches.Value
            $SetResults += ($SetMetaInfo | Select-String "Offense").matches.Value
            $SetResults += ($SetMetaInfo | Select-String "Critical Chance" -AllMatches).matches.Value
            $SetResults += ($SetMetaInfo | Select-String "Defense" -AllMatches).matches.Value
            $SetResults += ($SetMetaInfo | Select-String "Health" -AllMatches).matches.Value
            $SetResults += ($SetMetaInfo | Select-String "Potency" -AllMatches).matches.Value
            $SetResults += ($SetMetaInfo | Select-String "Tenacity" -AllMatches).matches.Value #>
            
            $RawMetaObject.Sets = $SetResults
            $RawMetaObject.Receiver = $RawMetaObject.Receiver.Split(" / ") | Sort-Object
            $RawMetaObject.Multiplexer = $RawMetaObject.Multiplexer.Split(" / ") | Sort-Object
            $RawMetaObject."Holo-Array" = $RawMetaObject."Holo-Array".Split(" / ") | Sort-Object
            $RawMetaObject."Data-Bus" = $RawMetaObject."Data-Bus".Split(" / ") | Sort-Object
            $RawMetaObjectV2 = @{}
            $RawMetaObjectV2[$RawMetaObject.Mode] = $RawMetaObject | Select-Object -ExcludeProperty Character,Mode,base_id
            $MetaHash[($RawMetaObject.base_id)] += $RawMetaObjectV2 

            $MetaCharList += $RawMetaObject.base_id

        }
        
    }
}

$ModTeamObj=[ordered]@{Name="";"Power"=0;"Gear"="";"Speed"="";"MMScore"=0;"Mod-Sets"="";"Transmitter"="";"Receiver"="";"Processor"="";"Holo-Array"="";"Data-Bus"="";"Multiplexer"=""}

# Start player analysis


$ModRoster=@()
$ModList = $RosterInfo.mods | Where-Object {$_.level -eq 15 -and $_.Rarity -ge 5 -and $_.character -ne $null} 

$ModHash = @{}
    ForEach ($Mod in $ModList) {

        if (-not $ModHash.ContainsKey($Mod.character)) { 
            
            $ModHash[$Mod.character] = @{}
        
        } 

        $ModHash[$Mod.character][($Mod.Slot.ToString())] = $Mod

    }

$ModRosterInfo = $RosterInfo.Units.Data | Where-Object {($_.combat_type -eq 1) -and ($_.Level -ge 50) -and ($MetaCharList -contains $_.base_id)}

$ModTeam = New-Object PSObject -Property $ModTeamObj

ForEach ($Char in $ModRosterInfo) {

    $ModTeam.Name = $Char.Name
    $ModTeam.Speed = "{0:0} ({1:0})" -f $Char.stats.5,$Char.stat_diffs.5 
    $ModTeam.Power = $Char.power

    if ($Char.relic_tier -gt 2) {
        
        $ModTeam.Gear = "R{0:00}" -f ($Char.relic_tier -2)

    } else {

        $ModTeam.Gear = "G{0:00}" -f ($Char.gear_level)
        
        if (($Char.gear | Where-Object {$_.is_obtained -eq $true}).count -gt 0) {
            
            $ModTeam.Gear = $ModTeam.Gear + "+" + ($Char.gear | Where-Object {$_.is_obtained -eq $true}).count
        
        }

    }

    $FinalMMScore = 0;
    $EquippedModsets = $Char.mod_set_ids
    $EquippedMods = $ModHash[$Char.base_id]

    ForEach($ModMetaMode in $ModMetaModeList) {

        if ($ModMetaMode -eq "Strict" -or $FinalMMScore -lt 100) {

            $MMScore = 0
            $RequiredMods = $MetaHash[$Char.base_id][$ModMetaMode]

            if ($RequiredMods) {

                $RequiredModSets = $RequiredMods.Sets

                $ModTeam."Mod-Sets" = $RequiredModSets | Join-String -Separator " / "
                
                if (($RequiredModSets -contains "Offense" -and $EquippedModsets -contains 2) -or ($RequiredModSets -contains "Speed" -and $EquippedModsets -contains 4) -or ($RequiredModSets -contains "Critical Damage" -and $EquippedModsets -contains 6)) {$MMScore += 20}

                $MMScore += 10 * (($RequiredModSets | Where-Object {$_ -eq "Health"}).count,($EquippedModsets | Where-Object {$_ -eq 1}).Count | Measure-Object -Minimum).Minimum 
                $MMScore += 10 * (($RequiredModSets | Where-Object {$_ -eq "Defense"}).count,($EquippedModsets | Where-Object {$_ -eq 3}).Count | Measure-Object -Minimum).Minimum 
                $MMScore += 10 * (($RequiredModSets | Where-Object {$_ -eq "Critical Chance"}).count,($EquippedModsets | Where-Object {$_ -eq 5}).Count | Measure-Object -Minimum).Minimum 
                $MMScore += 10 * (($RequiredModSets | Where-Object {$_ -eq "Potency"}).count,($EquippedModsets | Where-Object {$_ -eq 7}).Count | Measure-Object -Minimum).Minimum 
                $MMScore += 10 * (($RequiredModSets | Where-Object {$_ -eq "Tenacity"}).count,($EquippedModsets | Where-Object {$_ -eq 8}).Count | Measure-Object -Minimum).Minimum 

                if ($MMScore -lt 30) {$ModTeam."Mod-Sets" = "RED" + $ModTeam."Mod-Sets"}
            
                ForEach ($Slot in (2..7)) {
                    
                    if ($EquippedMods) {

                        $SelectedMod = $EquippedMods[$Slot.ToString()]

                    } else {

                        $SelectedMod = $null
                    }

                    $SlotName=$SlotNameList[$Slot]
        
                    switch ($Slot) {
                        
                        2 { $RequiredPrimaries = "Offense" }
                        3 { $RequiredPrimaries = $RequiredMods."Receiver" }
                        4 { $RequiredPrimaries = "Defense" }
                        5 { $RequiredPrimaries = $RequiredMods."Holo-Array" }
                        6 { $RequiredPrimaries = $RequiredMods."Data-Bus" }
                        7 { $RequiredPrimaries = $RequiredMods."Multiplexer" }
            
                    }

                    if (($RequiredPrimaries -contains $SelectedMod.primary_stat.name) -and ($RequiredModSets -contains $ModSetLong[$SelectedMod.set])) {

                        $MMScore += 5 # Mod primary matches meta

                        if (($SelectedMod.primary_stat.stat_id -eq 5) -or ($SelectedMod.secondary_stats.stat_id -contains 5)) { 
                            
                            $MMScore += 5 # Mod has speed on it or is excluded via Need4Speed list

                            if ($SelectedMod.primary_stat.stat_id -eq 5) {
                            
                                $ModSpeed = ("{0:00}" -f [int]$SelectedMod.primary_stat.display_value)
                            
                            } elseif ($SelectedMod.secondary_stats.stat_id -contains 5) {
                                
                                $ModSpeed = ("{0:00} " -f [int]($SelectedMod.secondary_stats | Where-Object {$_.Stat_id -eq 5}).display_value) + " (" + ($SelectedMod.secondary_stats | Where-Object {$_.Stat_id -eq 5}).roll + ")"
                                
                            } else {

                                $ModSpeed = "00"

                            }

                            $ModTeam.($Slotname) = [string]($ModSpeed + " - " + $ModSetShort[$SelectedMod.set] + " - " +  $SelectedMod.primary_stat.name.Replace("Critical","Crit."))

                            $ModTeam.($Slotname) += ("+" * ($SelectedMod.secondary_stats.name | Where-Object {$_ -like $SelectedMod.primary_stat.name}).count )
                            $ModTeam.($Slotname) += ("*" * ($SelectedMod.secondary_stats.name | Where-Object {$RequiredModSets -contains $_ -and $_ -notlike "Speed"}).count )


                            if ($SelectedMod.rarity -gt 5) {$ModTeam.($Slotname) = "BOLD" + $ModTeam.($Slotname)}
                                            
                        } else {$ModTeam.($Slotname) = "RED" + ($RequiredPrimaries | Join-String  -Separator (" / ")).Replace("Critical","Crit.")} 
                    } else {$ModTeam.($Slotname) = "RED" + ($RequiredPrimaries | Join-String  -Separator (" / ")).Replace("Critical","Crit.")}

                }
                
                $ModTeam."Mod-Sets" = $ModTeam."Mod-Sets".Replace("Tenacity / Tenacity / Tenacity","Tenacity (x3)").Replace("Tenacity / Tenacity","Tenacity (x2)").Replace("Health / Health / Health","Health (x3)").Replace("Health / Health","Health (x2)").Replace("Defense / Defense / Defense","Defense (x3)")
                $ModTeam."Mod-Sets" = $ModTeam."Mod-Sets".Replace("Defense / Defense","Defense (x2)").Replace("Potency / Potency / Potency","Potency (x3)").Replace("Potency / Potency","Potency (x2)")
                $ModTeam."Mod-Sets" = $ModTeam."Mod-Sets".Replace("Critical Chance / Critical Chance / Critical Chance","Crit. Chance (x3)").Replace("Critical Chance / Critical Chance","Crit. Chance (x2)").Replace("Critical","Crit.")
                
                if ($MMScore -eq 90) {
                
                    $MMScore = 100 + ($EquippedMods.values | Where-Object {$_.rarity -gt 5}).count * 5

                        if ($MMScore -eq 130 -and ($EquippedMods.values | Where-Object {$_.rarity -gt 5 -and $_.tier -eq 5}).count -eq 6) {$MMScore = 150}

                } 

                $ModTeam.MMScore = $MMScore

                if ($ModMetaMode -like "Strict") { 
                    
                    $FinalModTeam = ($ModTeam).psobject.copy()
                    $FinalMMScore = $MMScore

                } elseif ($ModMetaMode -like "Relaxed" -and $ModTeam.MMScore -gt $FinalModTeam.MMScore) {

                    $ModTeam.MMScore = [string]$ModTeam.MMScore + " (A)"
                    $FinalModTeam = ($ModTeam).psobject.copy()
                    $FinalMMScore = $MMScore                    
                    
                } 
            }
        
        }

    }

    
    if ($FinalMMscore -ge 130) {$FinalModTeam.MMScore = "BOLD" + $FinalModTeam.MMScore}

    $ModRoster = $ModRoster + $FinalModTeam


} # ForEach

$ModRoster = $ModRoster | Sort-Object @{Expression="Power"; Descending=$true}

($ModRoster | ConvertTo-Html -PreContent ("<H1> <Center>" + $Rosterinfo.data.name + "</H1>") -Head $header ).Replace("<td>RED","<td style='color:red'>").Replace("BOLD","<b>").Replace("Transmitter","Transmitter</br>(Square)").Replace("Receiver","Receiver</br>(Arrow)").Replace("Processor","Processor</br>(Diamond)").Replace("Holo-Array","Holo-Array</br>(Triangle)").Replace("Data-Bus","Data-Bus</br>(Circle)").Replace("Multiplexer","Multiplexer</br>(Cross)") | Out-File ($RosterInfo.data.Name + ".htm" ) -Encoding unicode -ErrorAction SilentlyContinue

