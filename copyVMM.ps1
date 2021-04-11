###########################################################
# Разработчик: Кордяк Иван Михайлович kordyakim@gmail.com #
###########################################################
#--------------------------------------------------#

$FolderBrowsers = Get-Process -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path | Where-Object -FilterScript {$_ -like "*VMMConsole.exe*"}
$FolderBrowser = $FolderBrowsers -replace "VMMConsole.exe",""
$pathvERSION = "\\SMBPath\vERSION.v"
$version = Get-Content $pathvERSION
	if($FolderBrowser -ne $null) 
	{
		while(Get-Process -Name "VMMConsole"){
			Stop-Process -Name "VMMConsole" -Force -ErrorAction SilentlyContinue
			sleep 1
		}
		Copy-Item "\\SMBPath\VMMConsole.exe" -Destination $FolderBrowser
		Copy-Item "\\SMBPath\VMMConsole.exe.config" -Destination $FolderBrowser
        $output = [System.Windows.Forms.MessageBox]::Show("Программа VMMConsole обновлена до версии $version")
		Start-Process -filepath $folderbrowser"VMMConsole.exe" -ErrorAction SilentlyContinue
		Stop-Process -Name copyVMM -Force -ErrorAction SilentlyContinue
    }