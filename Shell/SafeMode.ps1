Whoami
Write-Host ' '
Write-Host ' '
Write-Host ' '
Write-Host ' '
Write-Host ' '
Write-Host ' '
Write-Host ' '
Write-Host ' '
Write-Host ' '

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" Shell -Type String -Value "explorer.exe" -Force

cmd.exe /c "bcdedit /deletevalue {default} safeboot"

Write-Host ' '
Write-Host '=================================================='
Write-Host ' ЧИЩУ АВТОЗАГРУЗКУ '
Write-Host '=================================================='

$autorunCount = 0;

function Test-Entry{ 
    Param($Entry,$File) 
    $objFile=Get-Item (Find-Path $File) 
    if ($objFile){ 
        if ($colSafeFiles -notcontains $File){ 
            if ($objFile.GetType().Name -eq 'FileInfo') { 
                $Filename=$objFile.Name 
                $OriginalFilename=[System.Diagnostics.FileVersionInfo]::GetVersionInfo($objFile).OriginalFilename 
                $CompanyName=[System.Diagnostics.FileVersionInfo]::GetVersionInfo($objFile).CompanyName 
                if ($Filename -ne $OriginalFilename -or $colSafeVendors -notcontains $CompanyName){ 
                    if ($Filename -ne $OriginalFilename){write-host 'Имя файла:'$Filename 'Ожидалось:'$OriginalFilename 'Удаляю:' $Entry} 
                    if ($colSafeVendors -notcontains $CompanyName){write-host $CompanyName 'не найдена в списке доверенных организаций. Удаляю:' $Entry} 
                    Remove-Entry $Entry                     
                } 
            } 
        } 
    } 
    ELSE{ 
        Remove-Entry $Entry         
    } 
} 
 
function Find-Path{ 
param($Path, [switch]$All=$false, [Microsoft.PowerShell.Commands.TestPathType]$type="Any") 
    if($(Test-Path $Path -Type $type)) { 
        return $path 
    } else { 
        [string[]]$paths = @($pwd); 
        $paths += "$pwd;$env:path".Replace(';;',';').Replace('%SystemRoot%',$env:SystemRoot).Split(";") 
        $paths = Join-Path $paths $(Split-Path $Path -leaf) | ? { Test-Path $_ -Type $type } 
        if($paths.Length -gt 0) { 
            if($All) { 
                return $paths; 
            } else { 
                return $paths[0] 
            } 
        } 
    } 
} 
 
function Remove-Entry{ 
    Param($Entry) 
    Remove-ItemProperty -Path $regLoc -Name $Entry 
    $autorunCount = $autorunCount+1
} 
 
$colRegLocs=@( 
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", 
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run", 
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", 
    "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"; 
) 
 
$colSafeVendors=@( 
    'Alps Electric Co., Ltd.',        #Alps Touchpad 
    'Microsoft Corporation',        #Office 2010, Security Essentials (Virus Scan) 
    'Dell Inc.',                    #Dell Wireless Card Tray, Control Point 
    'Smith Micro Software, Inc.',    #Dell Connection Manager 
    'Intel Corporation',            #Intel Event Monitor 
    'NVIDIA Corporation',            #NVIDIA Display Properies, Hotkey Service, nView Wizard 
    'IDT, Inc.',                    #PC Audio Tray 
    'Broadcom Corporation',            #Dell Security Device and Task Status 
    'Trend Micro Inc.', 
    'Realtek Semiconductor', #Realtek Semiconductor
    'Kaspersky Lab ZAO';  #Virus Scan 
) 
 
$colSafeNames=@( 
    'PSPath', 
    'PSParentPath', 
    'PSChildName', 
    'PSDrive', 
    'PSProvider', 
    '(default)', 
    'Synergy Client',
    'Synergy Server',
    'RESTART_STICKY_NOTES';
) 
 
$colSafeFiles=@( 
    'C:\Program Files (x86)\Synergy\synergyc.exe',
    'C:\Program Files\Synergy\synergyc.exe',      
    'C:\Program Files (x86)\Synergy\synergy.exe', 
    'C:\Program Files\Synergy\synergy.exe';       
)  

foreach ($regLoc in $colRegLocs) { 
    if (Test-Path $regLoc){ 
        $objRegLoc=Get-ItemProperty $regLoc 
        $list=$objRegLoc.psobject.properties  | select name,value 
        $list|ForEach-Object{ 
            if  ($colSafeNames -notcontains $_.Name) { 
                $Entry=$_.Name 
                if($_.Value){
                    $File=$_.Value.Split(',/')[0].Trim() -replace ('rundll32.exe ','') -replace ('^"','') -replace ('\".*','') 
                    Test-Entry $Entry $File 
                }
            } 
        } 
    } 
}

Write-Host '--------------------------------------------------'
Write-Host ' Всего удалено ' $autorunCount ' записей автозагрузки.'
Write-Host '--------------------------------------------------'
Write-Host ' '


Write-Host '=================================================='
Write-Host ' ОЧИСТКА ЖЕСТКОГО ДИСКА ОТ ТЕЛА ВИРУСА '
Write-Host '=================================================='

$malwareCount = 0;

$Drives = Get-PSDrive -p "FileSystem" 

$malFileNames=@(
    'ksmmainsvc.exe',
    'mssecsvc.exe',
    'mssecsvc.exe',
    'Taskdl.exe',
    'Taskse.exe',
    '@wanadecryptor@.exe';
)

foreach($drv in $Drives){
    
        Set-Location -ErrorAction SilentlyContinue -ErrorVariable FailedRoots $drv.Root;   
        
        If($?){
            Write-Host 'Проверяю диск ' $drv.Root;
        }
    
        Get-ChildItem -ErrorAction SilentlyContinue -ErrorVariable FailedDirs -Filter *.exe -Recurse -Force | %{
            Write-Progress -Activity "Поиск и удаление вирусов" -Status $_.FullName
            foreach($mf in $malFileNames){
                If($_.Name -eq $mf){
                    Remove-Item $_.FullName -Force;
                    $count = $count + 1;
                    Write-Host '    Удалён Файл: ' $_.FullName ' (всего ' $malwareCount ' удалено)';
                }            
            }
        }
    }



Write-Host '--------------------------------------------------'
Write-Host ' Всего найдено и удалено ' $malwareCount ' тел вируса.'
Write-Host '--------------------------------------------------'
Write-Host ' '

cmd.exe /c "shutdown -r -t 0"