# usage: .\regtest.ps1 -extensionId aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

param(
    [string]$extensionId,
    [switch]$info
)

if ($info) {
    $InformationPreference = "Continue"
}

if (!($extensionId)) {
    $result = "Missing an extension ID!!"

} else {

    $extensionId = "$extensionId;https://clients2.google.com/service/update2/crx"

    $regKey = "HKLM:SOFTWARE\Google\Chrome\ExtensionInstallForceList"
    $regKeyWOWNode = "HKLM:SOFTWARE\Wow6432Node\Google\Chrome\ExtensionInstallForceList"
    
    # Create empty extension
    if(!(Test-Path $regKey)) {
        New-Item $regKey -Force
    }

    # Add a key to hold an executable's path
    if(Test-Path $regKey) {
        New-ItemProperty -Path $regKey -Name "Path" -Value "C:\Windows\System32\calc.exe" -Type String -Force 
    }

    # What other keys would we want?

    # Repeat for WOW6432Node entries
    if(!(Test-Path $regKeyWOWNode)) {
        New-Item $regKeyWOWNode -Force
    }

    if(Test-Path $regKeyWOWNode) {
        New-ItemProperty -Path $regKeyWOWNode -Name "Path" -Value "C:\Windows\System32\calc.exe" -Type String -Force 
    }

# Add Extension to Chrome
$extensionsList = New-Object System.Collections.ArrayList 
    $number = 0
    $noMore = 0#
    do {
        $number++
        try {
            $install = Get-ItemProperty $regKey -name $number -ErrorAction Stop
                $extensionObj = [PSCustomObject]@{
                    Name = $number
                    Value = $install.$number
                }
                $extensionsList.add($extensionObj) | Out-Null
                Write-Information "Extension List Item : $($extensionObj.name) / $($extensionObj.value)"
        } catch {
            $noMore = 1
        }
    }
    until ($noMore -eq 1)
    $extensionCheck = $extensionsList | Where-Object {$_.Value -eq $extensionId}
        if ($extensionCheck) {
            $result = "Extension already exists!!"
            Write-Information $result
        } else {
            $newExtensionID = $extensionsList[-1].name + 1
            New-ItemProperty HKLM:SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist -Type String -Name $newExtensionId -Value $extensionId
                $result = "Installed"
        }
   }
$result
