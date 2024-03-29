###########################################################
# Разработчик: Кордяк Иван Михайлович kordyakim@gmail.com #
###########################################################
#--------------------------------------------------#
$x = @()
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Tabl") 
[void] [System.Windows.Forms.ComboBoxStyle]::DropDown
#---------------------CheckBox---------------------#
$Font0 = New-Object Drawing.Font("Microsoft Sans Serif",8.25, [Drawing.FontStyle]::Underline)
$Font0 = New-Object Drawing.Font("Microsoft Sans Serif",8.25, [Drawing.FontStyle]::Bold)
$Font1 = New-Object Drawing.Font("Microsoft Sans Serif",8.25)
#---------------------Создаём форму---------------------#
$body = New-Object System.Windows.Forms.Form;
$excel = New-Object -com excel.application
$body.ClientSize = New-Object System.Drawing.Size(1000, 500);    
$body.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink;    
$body.AutoScaleDimensions = New-Object System.Drawing.SizeF(200, 100);    
$body.MaximizeBox = $true;
$body.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen; 
$versionNow = "3.9.1"
$body.Text = “Custom Console VMM - v$versionNow”;
$body.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
#проверка версии программы
$pathvERSION = "\\SMBPath\vERSION.v"
$version = Get-Content $pathvERSION

if ($version -gt $versionNow)
{
	Start-Process -filepath "$pwd\CopyVMM.exe" -Wait
}
#---------------------------------
#listview VM
$List = New-Object System.Windows.Forms.ListView
$List.AutoSize = $true
$List.dock = "Fill"
$List.View = "Details"
$List.MultiSelect = $true
$List.FullRowSelect = $True
$List.LabelEdit = $True
$List.AllowColumnReorder = $True
$List.GridLines = $true
$List.Columns.Add("VMName").width = 150
$List.Columns.Add("ComputerName").width = 150
$List.Columns.Add("IPv4Addresses").width = 130
$List.Columns.Add("VLanID").width = 130
$List.Columns.Add("vSAN").width = 60
$List.Columns.Add("VirtualizationPlatform").width = 110
$List.Columns.Add("OperatingSystem").width = 150
$List.Columns.Add("VMCheckpoints").width = 150
$List.Columns.Add("IntegrationServicesVersion").width = 150
$List.Columns.Add("Location").width = 200
$List.Columns.Add("HostName").width = 65
$List.Columns.Add("ClusterName").width = 75
$List.Columns.Add("Memory(GB)").width = 80
$List.Columns.Add("MemoryType").width = 80
$List.Columns.Add("CPUCount").width = 60
$List.Columns.Add("vHDSize(GB)").width = 60
$List.Columns.Add("vHDType").width = 80
$List.Columns.Add("DVD.iso").width = 80
$List.Columns.Add("Status").width = 65
$List.Columns.Add("CreationTime").width = 120
$List.Columns.Add("Description").width = 130
$List.Columns.Add("ИС").width = 130
$List.Columns.Add("Окружение").width = 130
$List.Columns.Add("Ответственный за ВМ").width = 130
$List.Columns.Add("Ответственный за ИС").width = 130
$List.Columns.Add("Проект").width = 100
$List.Columns.Add("Роль").width = 100
$List.add_KeyDown({
	param($sender, $e)
	if ($_.KeyCode -eq "C" -and $e.Control){
		Set-ClipBoard
	}
	if ($_.keycode -eq "A" -and $e.Control){
		foreach ($ListItem in $list.Items){
		    $ListItem.selected = $true
		}
	}
})
$List.add_ColumnClick({
	if ($List.Items.Count -gt 1){
		SortListTwoviewDB $_.Column
	}
})
$body.Controls.add($List)
#------------------------------------------------------------------------

#копирует содержимое listview--------------------------------------------
Function Set-ClipBoard {
$CopyTexts = @()
$n = "`n"
$list.SelectedItems | % {$CopyTexts+=$_.subitems.text+$n}
ForEach ($CopyText in $CopyTexts){
$CopyText1 += ";$CopyText"
}
[System.Windows.Forms.Clipboard]::SetText($CopyText1)
}
#------------------------------------------------------------------------
				#Сортироватm в два вида (возрастания и убывание)-------------------------------------------------------------------------------
				function SortListTwoviewDB {
				 param([parameter(Position=0)][UInt32]$Column)
				$Numeric = $true # определить, как сортировать (determine how to sort)
				#если пользователь нажал тот же столбец, который был выбран последний раз, его обратный порядок сортировки. в противном случае, сброс для нормальной сортировки по возрастанию
				#if the user clicked the same column that was clicked last time, reverse its sort order. otherwise, reset for normal ascending sort
				if($Script:LastColumnClickedTwo -eq $Column-or$Script:LastColumnClickedOne -eq $Column){
				    $Script:LastColumnAscendingTwo = -not $Script:LastColumnAscendingTwo
				}else{
				    $Script:LastColumnAscendingTwo = $true
				}
				$Script:LastColumnClickedTwo = $Column
				#трехмерный массив; колонке 1 индексы других столбцов, столбец 2 является значением, которое будет отсортирован, и колонка 3 является System.Windows.Forms.ListViewItem object
				#three-dimensional array; column 1 indexes the other columns, column 2 is the value to be sorted on, and column 3 is the System.Windows.Forms.ListViewItem object
				$ListItems = @(@(@()))
				foreach($ListItem in $List.Items)
				{
				    #если все элементы являются числовыми, могут использовать числовую сортировку (if all items are numeric, can use a numeric sort)
				    if($Numeric -ne $false) #ничто не может установить значение True, поэтому не процесс излишне (nothing can set this back to true, so don't process unnecessarily)
				    {
				        try
				        {
				            $Test = [Double]$ListItem.SubItems[[int]$Column].Text
				        }
				        catch
				        {
				            $Numeric = $false #найден нечисловых элементов, так что сортировка будет происходить в виде строки (a non-numeric item was found, so sort will occur as a string)
						}
				    }
				    $ListItems += ,@($ListItem.SubItems[[int]$Column].Text,$ListItem)
				}
				#создать выражение, которое будет вычисляться для сортировки (create the expression that will be evaluated for sorting)
				$EvalExpression = {
				    if($Numeric)
				    { return [double]$_[0] } #{ return [double]$_[0] } #[double]$_[0] }
				    else
				    { return [String]$_[0] }
				}
				#вся информация собрана; выполнения сортировки (all information is gathered; perform the sort)
				$ListItems = $ListItems | Sort-Object -Property @{Expression=$EvalExpression; Ascending=$Script:LastColumnAscendingTwo}
				#список отсортирован, вывести в list (the list is sorted; display it in the listview)
				$List.BeginUpdate()
				$List.Items.Clear()
				foreach($ListItem in $ListItems)
				{
				    $List.Items.Add($ListItem[1])
				}
				$List.EndUpdate()
				}
				#-------------------------------------------------------------------------------------------------------------------------------
# convert "Bytes","KB","MB","GB","TB"
function Convert-Size {            
	[cmdletbinding()]            
	param(            
	    [validateset("Bytes","KB","MB","GB","TB")]            
	    [string]$From,            
	    [validateset("Bytes","KB","MB","GB","TB")]            
	    [string]$To,            
	    [Parameter(Mandatory=$true)]            
	    [double]$Value,            
	    [int]$Precision = 4            
	)            
	switch($From) {            
	    "Bytes" {$value = $Value }            
	    "KB" {$value = $Value * 1024 }            
	    "MB" {$value = $Value * 1024 * 1024}            
	    "GB" {$value = $Value * 1024 * 1024 * 1024}            
	    "TB" {$value = $Value * 1024 * 1024 * 1024 * 1024}            
	}            
	switch ($To) {            
	    "Bytes" {return $value}            
	    "KB" {$Value = $Value/1KB}            
	    "MB" {$Value = $Value/1MB}            
	    "GB" {$Value = $Value/1GB}            
	    "TB" {$Value = $Value/1TB}                       
	}
	return [Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)
}
#----------------------------------------------------------------------------------------------
#groupVM for combobox
$GroupVM = New-Object System.Windows.Forms.GroupBox
$GroupVM.dock = "top"
$GroupVM.Height = 40
#$GroupVM.Width = 200
$body.Controls.Add($GroupVM);
#------------------------------------------------------------------------
#count VM
$count = New-Object System.Windows.Forms.Label
$count.ForeColor = "red"
$count.dock = "left"
$count.Text = ""
$count.Width = 400
$GroupVM.Controls.Add($count)
#------------------------------------------------------------------------
#textbox queries
$textBox0 = New-Object System.Windows.Forms.TextBox;           
$textBox0name = 'Введите запрос'
$textbox0.ForeColor = 'LightGray'
$textBox0.Text = $textBox0name
$textBox0.dock = "Left"
$textBox0.Width = 250
#автозаполнение
function GetSCVirtualMachine { 
	param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('VMName','ComputerName','Description','IPv4Addresses')]
        [string]$Choose
    )
	[array]$add = ""
	Switch ($choose) {
		'VMName'{
			$count.Text = "Connecting to server VMM, wait..."
			sleep 1
			if($HyperV.Text -eq "All"){
		        $vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue).name
			}elseif ($HyperV.Text -eq "HyperV"){
				if ($ClusterHyperV.Text -eq "All"){
					$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "HyperV"}).name
				}elseif ($ClusterHyperV.Text -eq $saveClusterHyperV){
					$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "HyperV"} | where { $_.vmhost.hostcluster.name -match $saveClusterHyperV}).name
				}
			}elseif ($HyperV.Text -eq "VMWareESX"){
    			$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "VMWareESX"}).name
			}
			if($vmauthocomplete){
				$textBox0.AutoCompleteSource = 'CustomSource'
				$textBox0.AutoCompleteMode = 'SuggestAppend'
				$textBox0.AutoCompleteCustomSource.Clear()
				$textBox0.AutoCompleteCustomSource.AddRange($vmauthocomplete)
				$count.Text = "Ready!"
			}else{
				$count.Text = "VMM server не найден..."
				$textBox0.AutoCompleteCustomSource.Clear()
			}
		}
		'ComputerName'{
			$count.Text = "Connecting to server VMM, wait..."
			sleep 1
			if($HyperV.Text -eq "All"){
		        $vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue).computername
			}elseif ($HyperV.Text -eq "HyperV"){
				if ($ClusterHyperV.Text -eq "All"){
					$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "HyperV"}).computername
				}elseif ($ClusterHyperV.Text -eq $saveClusterHyperV){
					$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "HyperV"} | where { $_.vmhost.hostcluster.name -match $saveClusterHyperV}).computername
				}
			}elseif ($HyperV.Text -eq "VMWareESX"){
    			$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "VMWareESX"}).computername
			}
			if($vmauthocomplete){
				$textBox0.AutoCompleteSource = 'CustomSource'
				$textBox0.AutoCompleteMode = 'SuggestAppend'
				$textBox0.AutoCompleteCustomSource.Clear()
				$textBox0.AutoCompleteCustomSource.AddRange($vmauthocomplete)
				$count.Text = "Ready!"
			}else{
				$count.Text = "VMM server не найден..."
				$textBox0.AutoCompleteCustomSource.Clear()
			}
		}
		'IPv4Addresses'{
			$count.Text = "Connecting to server VMM, wait..."
			sleep 1
			if($HyperV.Text -eq "All"){
		        $vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | Get-SCVirtualNetworkAdapter).IPv4Addresses 
			}elseif ($HyperV.Text -eq "HyperV"){
				if ($ClusterHyperV.Text -eq "All"){
					$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "HyperV"} | Get-SCVirtualNetworkAdapter).IPv4Addresses 
				}elseif ($ClusterHyperV.Text -eq $saveClusterHyperV){
					$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "HyperV"} | where { $_.vmhost.hostcluster.name -match $saveClusterHyperV} | Get-SCVirtualNetworkAdapter).IPv4Addresses 
				}
			}elseif ($HyperV.Text -eq "VMWareESX"){
    			$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "VMWareESX"}).computername
			}
			if($vmauthocomplete){
				$textBox0.AutoCompleteSource = 'CustomSource'
				$textBox0.AutoCompleteMode = 'SuggestAppend'
				$textBox0.AutoCompleteCustomSource.Clear()
				$textBox0.AutoCompleteCustomSource.AddRange($vmauthocomplete)
				$count.Text = "Ready!"
			}else{
				$count.Text = "VMM server не найден..."
				$textBox0.AutoCompleteCustomSource.Clear()
			}
		}
		'Description'{
			$count.Text = "Connecting to server VMM, wait..."
			sleep 1
			if($HyperV.Text -eq "All"){
		        $vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue).description
			}elseif ($HyperV.Text -eq "HyperV"){
				if ($ClusterHyperV.Text -eq "All"){
					$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "HyperV"}).description
				}elseif ($ClusterHyperV.Text -eq $saveClusterHyperV){
					$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "HyperV"} | where { $_.vmhost.hostcluster.name -match $saveClusterHyperV}).description
				}
			}elseif ($HyperV.Text -eq "VMWareESX"){
    			$vmauthocomplete = (Get-SCVirtualMachine -VMMServer $VMMserver.Text -ErrorAction SilentlyContinue | where { $_.VirtualizationPlatform -like "VMWareESX"}).description
			}
			if($vmauthocomplete){
				$textBox0.AutoCompleteSource = 'CustomSource'
				$textBox0.AutoCompleteMode = 'SuggestAppend'
				$textBox0.AutoCompleteCustomSource.Clear()
				$textBox0.AutoCompleteCustomSource.AddRange($vmauthocomplete)
				$count.Text = "Ready!"
			}else{
				$count.Text = "VMM server не найден..."
				$textBox0.AutoCompleteCustomSource.Clear()
			}
		}
	}
}
#---------------
$textBox0.add_KeyDown({
	if ($_.KeyCode -eq "Enter")
		{
		if($count.Text -eq "VMM server не найден..."){
			$VMMserver.ForeColor = 'Red'
			$VMMserver.Text = "Укажите корректное имя сервера VMM!!!"
		}else{
				if($filter.Text -eq ""){
					$textbox0.ForeColor = 'LightGray'
					$textBox0.Text = "Выберите фильтр"
				}elseif($VMMserver.Text -eq ""){
					$textbox0.ForeColor = 'LightGray'
					$textBox0.Text = "Выберите имя Сервера"
				}else{
					$count.Text = "Count..."
					sleep 1
					if($filter.Text -eq "VMName"){
						#Вызываем функцию VM-name
			            VM-name ("*" + $textBox0.Text + "*") -Type $vHDType.Text
					}elseif ($filter.Text -eq "ComputerName"){
						#Вызываем функцию Computer-name 
						Computer-name ("*" + $textBox0.Text + "*") -Type $vHDType.Text
					}elseif ($filter.Text -eq "IPv4Addresses"){
			            #Вызываем функцию IP-Address 
			            IP-Address ("*" + $textBox0.Text + "*") -Type $vHDType.Text
			        }elseif ($filter.Text -eq "Description"){
			            #Вызываем функцию IP-Address 
			            Description-VM ("*" + $textBox0.Text + "*") -Type $vHDType.Text
			        }
				}
			}
		}
})
$textBox0.add_Click({
	if($filter.Text -eq "VMName"){
		if (($count.Text -ne "Ready!") -or ($VMMserver.text -ne $saveVMM) -or ($filter.Text -ne $saveFilter) -or ($ClusterHyperV.Text -ne $saveClusterHyperV) -or ($HyperV.Text -ne $saveHyperV)){
			$global:saveVMM = $VMMserver.Text
			$global:saveFilter = $filter.Text
			$global:saveClusterHyperV = $ClusterHyperV.text
			$global:saveHyperV = $HyperV.Text
			GetSCVirtualMachine -choose VMName
		}
	}elseif($filter.Text -eq "ComputerName"){
		if (($count.Text -ne "Ready!") -or ($VMMserver.text -ne $saveVMM) -or ($filter.Text -ne $saveFilter) -or ($ClusterHyperV.Text -ne $saveClusterHyperV) -or ($HyperV.Text -ne $saveHyperV)){
			$global:saveVMM = $VMMserver.Text
			$global:saveFilter = $filter.Text
			$global:saveClusterHyperV = $ClusterHyperV.text
			$global:saveHyperV = $HyperV.Text
			GetSCVirtualMachine -choose ComputerName
		}
	}elseif($filter.Text -eq "IPv4Addresses"){
		if (($count.Text -ne "Ready!") -or ($VMMserver.text -ne $saveVMM) -or ($filter.Text -ne $saveFilter) -or ($ClusterHyperV.Text -ne $saveClusterHyperV) -or ($HyperV.Text -ne $saveHyperV)){
			$global:saveVMM = $VMMserver.Text
			$global:saveFilter = $filter.Text
			$global:saveClusterHyperV = $ClusterHyperV.text
			$global:saveHyperV = $HyperV.Text
			GetSCVirtualMachine -choose IPv4Addresses
		}
	}elseif($filter.Text -eq "Description"){
		if (($count.Text -ne "Ready!") -or ($VMMserver.text -ne $saveVMM) -or ($filter.Text -ne $saveFilter) -or ($ClusterHyperV.Text -ne $saveClusterHyperV) -or ($HyperV.Text -ne $saveHyperV)){
			$global:saveVMM = $VMMserver.Text
			$global:saveFilter = $filter.Text
			$global:saveClusterHyperV = $ClusterHyperV.text
			$global:saveHyperV = $HyperV.Text
			GetSCVirtualMachine -choose Description
		}
	}else{
		$textBox0.AutoCompleteCustomSource.Clear()
	}
	if(($textBox0.Text -eq $textBox0name) -or ($textBox0.Text -eq "Выберите фильтр") -or ($textBox0.Text -eq "Выберите имя Сервера")){
        #Clear the text
        $textBox0.Text = ""
        $textBox0.ForeColor = 'WindowText'
	}
	if($textBox0.Text -eq $textBox0.Tag){
        #Clear the text
        $textBox0.Text = ""
        $textBox0.ForeColor = 'WindowText'
    }
	})
$textBox0.add_KeyPress({
if($textBox0.Visible -and $textBox0.Tag -eq $null)
    {
        #Initialize the watermark and save it in the Tag property
        $textBox0.Tag = $textBox0.Text;
        $textBox0.ForeColor = 'WindowText'
		
        #If we have focus then clear out the text
        if($textBox0.Focused)
        {
            $textBox0.Text = ""
            $textBox0.ForeColor = 'WindowText'
        }
		
    }
})
$textBox0.add_Leave({
if($textBox0.Text -eq "")
    {
        #Display the watermark
        $textBox0.Text = 'Введите запрос'
        $textBox0.ForeColor = 'LightGray'
    }
	if($textBox0.Text -eq "")
    {
        #Display the watermark
        $textBox0.Text = $textBox0.Tag
        $textBox0.ForeColor = 'LightGray'
    }
})
$GroupVM.Controls.Add($textBox0);
#------------------------------------------------------------------------
#groupVM for vHDType+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
$GroupvHDType = New-Object System.Windows.Forms.GroupBox
$GroupvHDType.dock = "top"
$GroupvHDType.Height = 40
$body.Controls.Add($GroupvHDType);
#------------------------------------------------------------------------
#vHDType
$vHDType = New-Object System.Windows.Forms.comboBox  
$vHDType.dock = "left"
$vHDType.Width = 250
$vHDType.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$vHDType.add_Click({
	$vHDType.DroppedDown = $true
})
$GroupvHDType.Controls.Add($vHDType);
#------------------------------------------------------------------------
#array vHDType
[array]$ArrayvHDType = "All","FixedSize","DynamicallyExpanding","Differencing"
ForEach ($Item in $ArrayvHDType) {
  $vHDType.Items.Add($Item)
}
$vHDType.SelectedIndex = 0 # Select the first item by default
#------------------------------------------------------------------------
#caption dropdawn vHDType
$captionvHDType = New-Object System.Windows.Forms.Label
$captionvHDType.dock = "left"
$captionvHDType.Text = "Выберите тип диска:"
$captionvHDType.Width = 140
$captionvHDType.BackColor = "lightgray"
$GroupvHDType.Controls.Add($captionvHDType)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#groupVM for Filter++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
$GroupFilter = New-Object System.Windows.Forms.GroupBox
$GroupFilter.dock = "top"
$GroupFilter.Height = 40
$body.Controls.Add($GroupFilter);
#------------------------------------------------------------------------
#combobox filter
$filter = New-Object System.Windows.Forms.comboBox  
$filter.dock = "left"
$filter.Width = 250
$filter.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$filter.add_Click({
	$filter.DroppedDown = $true
})
$GroupFilter.Controls.Add($filter);
#------------------------------------------------------------------------
#array Filter
[array]$filters = "VMName","ComputerName","IPv4Addresses","Description"
ForEach ($Item in $filters) {
  $filter.Items.Add($Item)
}
$filter.SelectedIndex = 0 # Select the first item by default
#------------------------------------------------------------------------

#caption dropdawn filter
$captionFilter = New-Object System.Windows.Forms.Label
$captionFilter.dock = "left"
$captionFilter.Text = "Выберите тип запроса:"
$captionFilter.Width = 140
$captionFilter.BackColor = "lightgray"
$GroupFilter.Controls.Add($captionFilter)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#groupVM for Hyper-Visor+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
$GroupHyperV = New-Object System.Windows.Forms.GroupBox
$GroupHyperV.dock = "top"
$GroupHyperV.Height = 40
$body.Controls.Add($GroupHyperV);
#------------------------------------------------------------------------

#Hyper-Visor
$HyperV = New-Object System.Windows.Forms.comboBox  
$HyperV.dock = "left"
$HyperV.Width = 250
$HyperV.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$HyperV.add_Click({
	$HyperV.DroppedDown = $true
})
$GroupHyperV.Controls.Add($HyperV);

		#Добавление дополнительной фильтрации по кластеру Hyper-V
		#Hyper-Visor-Cluster
			$ClusterHyperV = New-Object System.Windows.Forms.comboBox  
			$ClusterHyperV.dock = "left"
			$ClusterHyperV.Width = 250
			$ClusterHyperV.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
			$ClusterHyperV.add_Click({
				$ClusterHyperV.DroppedDown = $true
			})
			#------------------------------------------------------------------------

			#------------------------------------------------------------------------
			$HyperV.add_DropDownClosed({
				if($HyperV.SelectedItem -eq "HyperV"){
					$GroupHyperV.Controls.Add($ClusterHyperV)
					$GroupHyperV.Controls.Add($HyperV)
					$GroupHyperV.Controls.Add($captionHyperV)
					#array Hyper-Visor-Cluster
					$count.Text = "Connecting to server VMM, wait..."
					sleep 1
					[array]$ClusterHyperVs = "All"
					$ClusterHyperVs += Get-scvmhostcluster -VMMServer $VMMserver.Text | ? { $_.VirtualizationPlatform -eq "HyperV"} | select -ExpandProperty ClusterName | Sort-Object
					if(!$?){
						$count.Text = "VMM server не найден..."
						$ClusterHyperV.Items.Clear()
					}else{
						$ClusterHyperV.Items.Clear()
						ForEach ($Item in $ClusterHyperVs) {
					  		$ClusterHyperV.Items.Add($Item)
						}
						$ClusterHyperV.SelectedIndex = 0 # Select the first item by default
						$count.Text = "Ready!"
					}
				}else{
					$GroupHyperV.Controls.Remove($ClusterHyperV)
				}
			});
		#--------------------------------------------------------------
#------------------------------------------------------------------------

#array Hyper-Visor
[array]$HyperVs = "All","HyperV","VMWareESX"
ForEach ($Item in $HyperVs) {
  $HyperV.Items.Add($Item)
}
$HyperV.SelectedIndex = 0 # Select the first item by default
#------------------------------------------------------------------------

#caption dropdawn Hyper-Visor
$captionHyperV = New-Object System.Windows.Forms.Label
$captionHyperV.dock = "left"
$captionHyperV.Text = "Выберите гипервизор:"
$captionHyperV.Width = 140
$captionHyperV.BackColor = "lightgray"
$GroupHyperV.Controls.Add($captionHyperV)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#groupVM for combobox++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
$GroupServer = New-Object System.Windows.Forms.GroupBox
$GroupServer.dock = "top"
$GroupServer.Height = 40
$body.Controls.Add($GroupServer);
#------------------------------------------------------------------------

				#Добавление дополнительной фильтрации по серверам VMM			
				#textbox queries
				$VMMserver = New-Object System.Windows.Forms.TextBox;           
				$VMMserver.ForeColor = 'Black'
				$VMMserver.Text = "serverVMM"
				$VMMserver.dock = "Left"
				$VMMserver.Width = 250
				#автозаполнение
					$VMMserver.AutoCompleteSource = 'CustomSource'
					$VMMserver.AutoCompleteMode = 'SuggestAppend'
					$VMMserver.AutoCompleteCustomSource.AddRange($VMMserver.Text)
				#--------------------------
				$VMMserver.add_Click({
					if ($VMMserver.Text -ne $saveVMMserver){
						$global:saveVMMserver = $VMMserver.Text
					}
					if(($VMMserver.Text -eq $saveVMMserver) -or ($VMMserver.Text -eq "Укажите корректное имя сервера VMM!!!")){
				        #Clear the text
				        $VMMserver.Text = ""
				        $VMMserver.ForeColor = 'WindowText'
				    }
					if($VMMserver.Text -eq $VMMserver.Tag){
				        #Clear the text
				        $VMMserver.Text = ""
				        $VMMserver.ForeColor = 'WindowText'
				    }
				})
				$VMMserver.add_KeyPress({
					if($VMMserver.Visible -and $VMMserver.Tag -eq $null){
				        #Initialize the watermark and save it in the Tag property
				        $VMMserver.Tag = $VMMserver.Text;
				        $VMMserver.ForeColor = 'WindowText'
						
				        #If we have focus then clear out the text
				        if($VMMserver.Focused)
				        {
				            $VMMserver.Text = ""
				            $VMMserver.ForeColor = 'WindowText'
				        }
				    }
				})
				$VMMserver.add_Leave({
					if($VMMserver.Text -eq ""){
				        #Display the watermark
				        $VMMserver.Text = $saveVMMserver
				        $VMMserver.ForeColor = 'Black'
				    }
					if($VMMserver.Text -eq ""){
				        #Display the watermark
				        $VMMserver.Text = $VMMserver.Tag
				        $VMMserver.ForeColor = 'LightGray'
				    }
				})
				$GroupServer.Controls.Add($VMMserver);
				#------------------------------------------------------------------------
			
#caption dropdawn server name vmm
$captionServ = New-Object System.Windows.Forms.Label
$captionServ.dock = "left"
$captionServ.Text = "Имя сервера VMM:"
$captionServ.Width = 140
$captionServ.BackColor = "lightgray"
$GroupServer.Controls.Add($captionServ)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#caption programms
$MenuBar = New-Object System.Windows.Forms.MenuStrip
$MenuBar.Dock = "bottom"
$body.Controls.Add($MenuBar);
$UserMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$UserMenu.Text = "Информация"
$UserMenu.Name = "openToolStripMenuItem"
$UserMenu.Alignment = 'Right'
$MenuBar.Items.Add($UserMenu)
$UserMenu.add_Click{[void][System.Windows.Forms.MessageBox]::Show("Custom- консоль VMM для поиска и выгрузки информации по ВМ.
- Имя сервера VMM: отправная точка запроса, сервер VMM.
- Выберите гипервизор:
	1. All - парсит по всей ферме VMM.
	2. HyperV - делает выборку по HyperV.
	3. VMWare - делает выборку по VMWare.
- Выберите тип запроса:
	1. VMName - имя ВМ в консоле VMM.
	2. ComputerName - доменное имя ВМ, может отличаться от имени ВМ.
	3. IPv4Addresses - IP- адрес ВМ, самый долгий запрос.
	4. Description - запрос по описанию ВМ.
- Выберите тип диска:
	1. All - парсит по всем типам vHD.
	2. FixedSize - выгружает ВМ с толстыми vHD.
	3. DinamicallyExpanding - выгружает ВМ с тонкими vHD.

Разработчк:
-  Кордяк Иван")}
#-----------------------------------------------------

#ищит по имени ВМ в VMM
function VM-name { 
		[cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('All','FixedSize','DynamicallyExpanding','Differencing')]
        [string]$Type,
		$Mask = "*"
    )
	$List.Items.Clear()
	$s = $textBox0.Text + ""
	if($HyperV.Text -eq "All"){
        $str = Get-SCVirtualMachine -VMMServer $VMMserver.text | Where { $_.name -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,customproperty
	}elseif ($HyperV.Text -eq "HyperV"){
		if ($ClusterHyperV.Text -eq "All"){
			$str = Get-SCVirtualMachine -VMMServer $VMMserver.text | where { $_.VirtualizationPlatform -like "HyperV"} | Where { $_.name -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,customproperty
		}elseif ($ClusterHyperV.Text -eq $saveClusterHyperV){
			$str = Get-SCVirtualMachine -VMMServer $VMMserver.text | where { $_.VirtualizationPlatform -like "HyperV"} | where { $_.vmhost.hostcluster.name -match $saveClusterHyperV} | Where { $_.name -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,customproperty
		}
	}elseif ($HyperV.Text -eq "VMWareESX"){
        $str = Get-SCVirtualMachine -VMMServer $VMMserver.text | where { $_.VirtualizationPlatform -like "VMWareESX"} | Where { $_.name -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,customproperty
    }
	if($str -eq $null){
		$I = $List.Items.Add("ВМ не найдена...") | Out-Null
	}else{
		foreach ( $item in $str ) {
			# vHDType+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			$vHDTypes=(Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).VirtualHardDisks.vHDType | ? {($_ -eq "DynamicallyExpanding") -or ($_ -eq "Differencing")-or ($_ -eq "FixedSize")} | Select-Object -Unique
			Switch ($Type){
		        'All' {if($vHDTypes -eq "DynamicallyExpanding"){$vHDTypes="DynamicallyExpanding"}elseif($vHDTypes -eq "Differencing"){$vHDTypes="Differencing"}else{$vHDTypes="FixedSize"}}
		        'FixedSize' {if($vHDTypes -eq 'FixedSize'){$vHDTypes="FixedSize"}else{$vHDTypes=$false}}
		        'DynamicallyExpanding' {if($vHDTypes -eq 'DynamicallyExpanding'){$vHDTypes="DynamicallyExpanding"}else{$vHDTypes=$false}}
				'Differencing' {if($vHDTypes -eq 'Differencing'){$vHDTypes="Differencing"}else{$vHDTypes=$false}}
		    }
			if($vHDTypes){
				$r = "Ответственный за ВМ"
				$r1 = "Ответственный за ИС"
				$s1 = $item -split ";"
				$s2 = $s1 -split "}"
				$description = $item.description
				$n = "`n"
				$description1 = "$description" -replace "$n",";"
				# IP address+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					$ipi=""
					$ipv=""
					$ipo=0
					$ips = Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name | Get-SCVirtualNetworkAdapter | Select IPv4Addresses,VLanID
					foreach ($ip in $ips){
						if($ipo -cge 1){
							$ipi += "..."+"$ipo"+"-" +$ip.IPv4Addresses
							$ipv += "..."+"$ipo"+"-" +$ip.VLanID
							$ipo++
						}else{
							$ipi += "$ipo"+"-" +$ip.IPv4Addresses
							$ipv += "$ipo"+"-" +$ip.VLanID
							$ipo++
						}
					}
					$ipi = $ipi -replace "[ ^]",";"
					$ipv = $ipv -replace "[ ^]",";"
				# size HDDisk+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					$vHDisks=""
					$nHD=0
					$vHDs=(Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).VirtualHardDisks | select MaximumSize,Size
					foreach ($vHDi in $vHDs){
						$measure=$vHDi.size * 100/$vHDi.MaximumSize
						$vHD= convert-size -from Bytes -to GB -value $vHDi.MaximumSize;
						if($nHD -cge 1){
							$vHDisks += "..."+"$nHD"+"-"+$vHD; $nHD++
						}else{
							$vHDisks += "$nHD"+"-"+$vHD; $nHD++
						}
					}
				# cluster name
					$Clust = (Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).vmhost.hostcluster.name
				# convert memory bytes to GB
					$memory = convert-size -from MB -to GB -value $item.memory
				# DVD.iso
					$DVD = (Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).VirtualDVDDrives.iso.SharePath
				# memory type
					if(!$item.DynamicMemoryEnabled){
						$memoryType = "Static"
					}else{
						$memoryType = "Dynamic"
					}
				#table
				try{$I = $List.Items.Add($s2[0].Substring(7))}catch{}
				try{$I.SubItems.Add($s2[1].Substring(14))}catch{}
				try{$I.SubItems.Add("$ipi")}catch{}
				try{$I.SubItems.Add("$ipv")}catch{}
				try{$I.SubItems.Add($Item.VirtualFibreChannelAdapters.count)}catch{}
				try{$I.SubItems.Add($s2[3].Substring(24))}catch{}
				try{$I.SubItems.Add($s2[4].Substring(17))}catch{}
				try{$I.SubItems.Add($item.VMCheckpoints.count)}catch{}
				try{$I.SubItems.Add($s2[6].Substring(12))}catch{}
				try{$I.SubItems.Add($s2[7].Substring(10))}catch{}
				try{$I.SubItems.Add($s2[8].Substring(10))}catch{}
				try{$I.SubItems.Add("$Clust")}catch{}
				try{$I.SubItems.Add("$memory")}catch{}
				try{$I.SubItems.Add("$memoryType")}catch{}
				try{$I.SubItems.Add($s2[11].Substring(10))}catch{}
				try{$I.SubItems.Add("$vHDisks")}catch{}
				try{$I.SubItems.Add("$vHDTypes")}catch{}
				try{$I.SubItems.Add("$DVD")}catch{}
				try{$I.SubItems.Add($s2[13].Substring(8))}catch{}
				try{$I.SubItems.Add($s2[14].Substring(14))}catch{}
				try{$I.SubItems.Add("$description1")}catch{}
				try{$I.SubItems.Add($item.customproperty.ИС)}catch{}
				try{$I.SubItems.Add($item.customproperty.Окружение)}catch{}
				try{$I.SubItems.Add($item.customproperty."$r")}catch{}
				try{$I.SubItems.Add($item.customproperty."$r1")}catch{}
				try{$I.SubItems.Add($item.customproperty.Проект)}catch{}
				try{$I.SubItems.Add($item.customproperty.Роль)}catch{}
				$o++
			}
		}if(!$List.Items){$I = $List.Items.Add("ВМ не найдена...") | Out-Null}
	}
	$count.Text = $o
}
#------------------------------------------------------------------------
	#ищит по имени компьютера в VMM
	function Computer-name {
		[cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('All','FixedSize','DynamicallyExpanding','Differencing')]
        [string]$Type,
		$Mask = "*"
    )
		$Arrays = ""
		$Arrays = @()
		$List.Items.Clear()
		$s = $textBox0.Text + ""
		if($HyperV.Text -eq "All"){
            $str = Get-SCVirtualMachine -VMMServer $VMMserver.text | Where { $_.ComputerName -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,CustomProperty
		}elseif ($HyperV.Text -eq "HyperV"){
			if ($ClusterHyperV.Text -eq "All"){
				$str = Get-SCVirtualMachine -VMMServer $VMMserver.text | where { $_.VirtualizationPlatform -like "HyperV"} | Where { $_.name -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,customproperty
			}elseif ($ClusterHyperV.Text -eq $saveClusterHyperV){
				$str = Get-SCVirtualMachine -VMMServer $VMMserver.text | where { $_.VirtualizationPlatform -like "HyperV"} | where { $_.vmhost.hostcluster.name -match $saveClusterHyperV} | Where { $_.ComputerName -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,customproperty
			}
		}elseif ($HyperV.Text -eq "VMWareESX"){
            $str = Get-SCVirtualMachine -VMMServer $VMMserver.text | where { $_.VirtualizationPlatform -like "VMWareESX"} | Where { $_.ComputerName -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,CustomProperty
        }
		if($str -eq $null){
			$I = $List.Items.Add("ВМ не найдена...") | Out-Null
		}else{
	    	foreach ( $item in $str ){
				# vHDType+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				$vHDTypes=(Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).VirtualHardDisks.vHDType | ? {($_ -eq "DynamicallyExpanding") -or ($_ -eq "Differencing")} | Select-Object -Unique
				Switch ($Type){
			        'All' {if($vHDTypes -eq "DynamicallyExpanding"){$vHDTypes="DynamicallyExpanding"}elseif($vHDTypes -eq "Differencing"){$vHDTypes="Differencing"}else{$vHDTypes="FixedSize"}}
			        'FixedSize' {if($vHDTypes -eq 'FixedSize'){$vHDTypes="FixedSize"}else{$vHDTypes=$false}}
			        'DynamicallyExpanding' {if($vHDTypes -eq 'DynamicallyExpanding'){$vHDTypes="DynamicallyExpanding"}else{$vHDTypes=$false}}
					'Differencing' {if($vHDTypes -eq 'Differencing'){$vHDTypes="Differencing"}else{$vHDTypes=$false}}
		    	}
				if($vHDTypes){
					$r = "Ответственный за ВМ"
					$r1 = "Ответственный за ИС"
			    	$s1 = $item -split ";"
					$s2 = $s1 -split "}"
					$description = $item.description
					$n = "`n"
					$description1 = "$description" -replace "$n",";"
					# IP address+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					$ipi=""
					$ipv=""
					$ipo=0
					$ips = Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name | Get-SCVirtualNetworkAdapter | Select IPv4Addresses,VLanID
					foreach ($ip in $ips){
						if($ipo -cge 1){
							$ipi += "..."+"$ipo"+"-" +$ip.IPv4Addresses
							$ipv += "..."+"$ipo"+"-" +$ip.VLanID
							$ipo++
						}else{
							$ipi += "$ipo"+"-" +$ip.IPv4Addresses
							$ipv += "$ipo"+"-" +$ip.VLanID
							$ipo++
						}
					}
					$ipi = $ipi -replace "[ ^]",";"
					$ipv = $ipv -replace "[ ^]",";"
					# size HDDisk+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
						$vHDisks=""
						$nHD=0
						$vHDs=(Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).VirtualHardDisks | select MaximumSize,Size
						foreach ($vHDi in $vHDs){
							$measure=$vHDi.size * 100/$vHDi.MaximumSize
							$vHD= convert-size -from Bytes -to GB -value $vHDi.MaximumSize;
							if($nHD -cge 1){
								$vHDisks+="..."+"$nHD"+"-"+$vHD; $nHD++
							}else{
								$vHDisks += "$nHD"+"-"+$vHD; $nHD++
							}
						}
					# cluster name
						$Clust = (Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).vmhost.hostcluster.name
					# convert memory bytes to GB
						$memory = convert-size -from MB -to GB -value $item.memory
					# DVD.iso
						$DVD = (Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).VirtualDVDDrives.iso.SharePath
					# memory type
						if(!$item.DynamicMemoryEnabled){
							$memoryType = "Static"
						}else{
							$memoryType = "Dynamic"
						}
					#table
			    	try{$I = $List.Items.Add($s2[0].Substring(7))}catch{}
					try{$I.SubItems.Add($s2[1].Substring(14))}catch{}
					try{$I.SubItems.Add("$ipi")}catch{}
					try{$I.SubItems.Add("$ipv")}catch{}
					try{$I.SubItems.Add($Item.VirtualFibreChannelAdapters.count)}catch{}
					try{$I.SubItems.Add($s2[3].Substring(24))}catch{}
					try{$I.SubItems.Add($s2[4].Substring(17))}catch{}
					try{$I.SubItems.Add($item.VMCheckpoints.count)}catch{}
					try{$I.SubItems.Add($s2[6].Substring(12))}catch{}
					try{$I.SubItems.Add($s2[7].Substring(10))}catch{}
					try{$I.SubItems.Add($s2[8].Substring(10))}catch{}
					try{$I.SubItems.Add("$Clust")}catch{}
					try{$I.SubItems.Add("$memory")}catch{}
					try{$I.SubItems.Add("$memoryType")}catch{}
					try{$I.SubItems.Add($s2[11].Substring(10))}catch{}
					try{$I.SubItems.Add("$vHDisks")}catch{}
					try{$I.SubItems.Add("$vHDTypes")}catch{}
					try{$I.SubItems.Add("$DVD")}catch{}
					try{$I.SubItems.Add($s2[13].Substring(8))}catch{}
					try{$I.SubItems.Add($s2[14].Substring(14))}catch{}
					try{$I.SubItems.Add("$description1")}catch{}
					try{$I.SubItems.Add($item.customproperty.ИС)}catch{}
					try{$I.SubItems.Add($item.customproperty.Окружение)}catch{}
					try{$I.SubItems.Add($item.customproperty."$r")}catch{}
					try{$I.SubItems.Add($item.customproperty."$r1")}catch{}
					try{$I.SubItems.Add($item.customproperty.Проект)}catch{}
					try{$I.SubItems.Add($item.customproperty.Роль)}catch{}
					$o++
				}
			}if(!$List.Items){$I = $List.Items.Add("ВМ не найдена...") | Out-Null}
		}
		$count.Text = $o
	}
	#------------------------------------------------------------------------
			#ищит по ip-адерсу в VMM
			function IP-Address {
				[cmdletbinding()]
		    param(
		        [Parameter(Mandatory=$true)]
		        [ValidateSet('All','FixedSize','DynamicallyExpanding','Differencing')]
		        [string]$Type,
				$Mask = "*"
		    )
				$List.Items.Clear()
				$s = $textBox0.Text + ""
				if($HyperV.Text -eq "All"){
		            $str = Get-SCVirtualMachine -VMMServer $VMMserver.Text | Get-SCVirtualNetworkAdapter | ? IPv4Addresses -match $s | Select-Object -Property name -Unique
				}elseif ($HyperV.Text -eq "HyperV"){
					if ($ClusterHyperV.Text -eq "All"){
						$str = Get-SCVirtualMachine -VMMServer $VMMserver.text | ? { $_.VirtualizationPlatform -like "HyperV"} | Get-SCVirtualNetworkAdapter | ? IPv4Addresses -match $s | Select-Object -Property name -Unique
					}elseif ($ClusterHyperV.Text -eq $saveClusterHyperV){
						$str = Get-SCVirtualMachine -VMMServer $VMMserver.text | ? { $_.VirtualizationPlatform -like "HyperV"} | where { $_.vmhost.hostcluster.name -match $saveClusterHyperV} | Get-SCVirtualNetworkAdapter | ? IPv4Addresses -match $s | Select-Object -Property name -Unique
					}
				}elseif ($HyperV.Text -eq "VMWareESX"){
		            $str = Get-SCVirtualMachine -VMMServer $VMMserver.Text | ? { $_.VirtualizationPlatform -like "VMWareESX"} | Get-SCVirtualNetworkAdapter | ? IPv4Addresses -match $s | Select-Object -Property name -Unique
		        }
				if(!$str){
					$I = $List.Items.Add("ВМ не найдена...") | Out-Null
				}else{
					foreach ( $item in $str ){
						$str1 = Get-SCVirtualMachine -VMMServer $VMMserver.text | ? { $_.VirtualNetworkAdapters.name -eq $item.name } | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,CustomProperty
						# vHDType+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
						$vHDTypes=(Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $str1.name).VirtualHardDisks.vHDType | ? {($_ -eq "DynamicallyExpanding") -or ($_ -eq "Differencing")} | Select-Object -Unique
						Switch ($Type){
					        'All' {if($vHDTypes -eq "DynamicallyExpanding"){$vHDTypes="DynamicallyExpanding"}elseif($vHDTypes -eq "Differencing"){$vHDTypes="Differencing"}else{$vHDTypes="FixedSize"}}
					        'FixedSize' {if($vHDTypes -eq 'FixedSize'){$vHDTypes="FixedSize"}else{$vHDTypes=$false}}
					        'DynamicallyExpanding' {if($vHDTypes -eq 'DynamicallyExpanding'){$vHDTypes="DynamicallyExpanding"}else{$vHDTypes=$false}}
							'Differencing' {if($vHDTypes -eq 'Differencing'){$vHDTypes="Differencing"}else{$vHDTypes=$false}}
		    			}
						if($vHDTypes){
					    	#description
							$r = "Ответственный за ВМ"
							$r1 = "Ответственный за ИС"
							$s1 = $str1 -split ";"
							$s2 = $s1 -split "}"
							$description = $str1.description
							$n = "`n"
							$description1 = "$description" -replace "$n",";"
							# IP address+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
							$ipi=""
							$ipv=""
							$ipo=0
							$ips = (Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $str1.name ).VirtualNetworkAdapters | Select IPv4Addresses,VLanID
							foreach ($ip in $ips){
								if($ipo -cge 1){
									$ipi += "..."+"$ipo"+"-" +$ip.IPv4Addresses
									$ipv += "..."+"$ipo"+"-" +$ip.VLanID
									$ipo += 1
								}else{
									$ipi += "$ipo"+"-" +$ip.IPv4Addresses
									$ipv += "$ipo"+"-" +$ip.VLanID
									$ipo += 1
								}
							}
							$ipi = $ipi -replace "[ ^]",";"
							$ipv = $ipv -replace "[ ^]",";"
							# size HDDisk+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
								$vHDisks=""
								$nHD=0
								$vHDs=(Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $str1.name).VirtualHardDisks | select MaximumSize,Size
								foreach ($vHDi in $vHDs){
									$measure=$vHDi.size * 100/$vHDi.MaximumSize
									$vHD= convert-size -from Bytes -to GB -value $vHDi.MaximumSize;
									if($nHD -cge 1){
										$vHDisks+="..."+"$nHD"+"-"+$vHD; $nHD++
									}else{
										$vHDisks += "$nHD"+"-"+$vHD; $nHD++
									}
								}
							# cluster name
								$Clust = (Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $str1.name).vmhost.hostcluster.name
							# convert memory bytes to GB
								$memory = convert-size -from MB -to GB -value $str1.memory
							# DVD.iso
								$DVD = (Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $str1.name).VirtualDVDDrives.iso.SharePath
							# memory type
								if(!$str1.DynamicMemoryEnabled){
									$memoryType = "Static"
								}else{
									$memoryType = "Dynamic"
								}
							#table
					    	try{$I = $List.Items.Add($s2[0].Substring(7))}catch{}
							try{$I.SubItems.Add($s2[1].Substring(14))}catch{}
							try{$I.SubItems.Add("$ipi")}catch{}
							try{$I.SubItems.Add("$ipv")}catch{}
							try{$I.SubItems.Add($str1.VirtualFibreChannelAdapters.count)}catch{}
							try{$I.SubItems.Add($s2[3].Substring(24))}catch{}
							try{$I.SubItems.Add($s2[4].Substring(17))}catch{}
							try{$I.SubItems.Add($str1.VMCheckpoints.count)}catch{}
							try{$I.SubItems.Add($s2[6].Substring(12))}catch{}
							try{$I.SubItems.Add($s2[7].Substring(10))}catch{}
							try{$I.SubItems.Add($s2[8].Substring(10))}catch{}
							try{$I.SubItems.Add("$Clust")}catch{}
							try{$I.SubItems.Add("$memory")}catch{}
							try{$I.SubItems.Add("$memoryType")}catch{}
							try{$I.SubItems.Add($s2[11].Substring(10))}catch{}
							try{$I.SubItems.Add("$vHDisks")}catch{}
							try{$I.SubItems.Add("$vHDTypes")}catch{}
							try{$I.SubItems.Add("$DVD")}catch{}
							try{$I.SubItems.Add($s2[13].Substring(8))}catch{}
							try{$I.SubItems.Add($s2[14].Substring(14))}catch{}
							try{$I.SubItems.Add("$description1")}catch{}
							try{$I.SubItems.Add($str1.customproperty.ИС)}catch{}
							try{$I.SubItems.Add($str1.customproperty.Окружение)}catch{}
							try{$I.SubItems.Add($str1.customproperty."$r")}catch{}
							try{$I.SubItems.Add($str1.customproperty."$r1")}catch{}
							try{$I.SubItems.Add($str1.customproperty.Проект)}catch{}
							try{$I.SubItems.Add($str1.customproperty.Роль)}catch{}
							$o++
						}
					}if(!$List.Items){$I = $List.Items.Add("ВМ не найдена...") | Out-Null}
				}
				$count.Text = $o
			}
			#------------------------------------------------------------------------
				#ищит по Description в VMM
				function Description-VM {
					[cmdletbinding()]
			    param(
			        [Parameter(Mandatory=$true)]
			        [ValidateSet('All','FixedSize','DynamicallyExpanding','Differencing')]
			        [string]$Type,
					$Mask = "*"
			    )
					
					$List.Items.Clear()
					$s = $textBox0.Text + ""
					if($HyperV.Text -eq "All"){
				            $str = Get-SCVirtualMachine -VMMServer $VMMserver.text | Where { $_.Description -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,CustomProperty
						}elseif ($HyperV.Text -eq "HyperV"){
							if ($ClusterHyperV.Text -eq "All"){
								$str = Get-SCVirtualMachine -VMMServer $VMMserver.text | where { $_.VirtualizationPlatform -like "HyperV"} | Where { $_.Description -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,customproperty
							}elseif ($ClusterHyperV.Text -eq $saveClusterHyperV){
								$str = Get-SCVirtualMachine -VMMServer $VMMserver.text | where { $_.VirtualizationPlatform -like "HyperV"} | where { $_.vmhost.hostcluster.name -match $saveClusterHyperV} | Where { $_.Description -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,customproperty
							}
						}elseif ($HyperV.Text -eq "VMWareESX"){
				            $str = Get-SCVirtualMachine -VMMServer $VMMserver.text | where { $_.VirtualizationPlatform -like "VMWareESX"} | Where { $_.Description -match $s} | select Name,ComputerName,VirtualFibreChannelAdapters,VirtualizationPlatform,OperatingSystem,VMCheckpoints,VMAddition,Location,HostName,Memory,DynamicMemoryEnabled,CPUCount,VirtualHardDisks,Status,CreationTime,Description,CustomProperty
				        }
					if($str -eq $null){
						$I = $List.Items.Add("ВМ не найдена...") | Out-Null
					}else{
				    	foreach ( $item in $str ){
							# vHDType+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
							$vHDTypes=(Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).VirtualHardDisks.vHDType | ? {($_ -eq "DynamicallyExpanding") -or ($_ -eq "Differencing")} | Select-Object -Unique
							Switch ($Type){
						        'All' {if($vHDTypes -eq "DynamicallyExpanding"){$vHDTypes="DynamicallyExpanding"}elseif($vHDTypes -eq "Differencing"){$vHDTypes="Differencing"}else{$vHDTypes="FixedSize"}}
						        'FixedSize' {if($vHDTypes -eq 'FixedSize'){$vHDTypes="FixedSize"}else{$vHDTypes=$false}}
						        'DynamicallyExpanding' {if($vHDTypes -eq 'DynamicallyExpanding'){$vHDTypes="DynamicallyExpanding"}else{$vHDTypes=$false}}
								'Differencing' {if($vHDTypes -eq 'Differencing'){$vHDTypes="Differencing"}else{$vHDTypes=$false}}
						    }
							if($vHDTypes){
								$r = "Ответственный за ВМ"
								$r1 = "Ответственный за ИС"
						    	$s1 = $item -split ";"
								$s2 = $s1 -split "}"
								$description = $item.description
								$n = "`n"
								$description1 = "$description" -replace "$n",";"
								# IP address+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
								$ipi=""
								$ipv=""
								$ipo=0
								$ips = Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name | Get-SCVirtualNetworkAdapter | Select IPv4Addresses,VLanID
								foreach ($ip in $ips){
									if($ipo -cge 1){
										$ipi += "..."+"$ipo"+"-" +$ip.IPv4Addresses
										$ipv += "..."+"$ipo"+"-" +$ip.VLanID
										$ipo += 1
									}else{
										$ipi += "$ipo"+"-" +$ip.IPv4Addresses
										$ipv += "$ipo"+"-" +$ip.VLanID
										$ipo += 1
									}
								}
								$ipi = $ipi -replace "[ ^]",";"
								$ipv = $ipv -replace "[ ^]",";"
								# size HDDisk+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
									$vHDisks=""
									$nHD=0
									$vHDs=(Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).VirtualHardDisks | select MaximumSize,Size
									foreach ($vHDi in $vHDs){
										$measure=$vHDi.size * 100/$vHDi.MaximumSize
										$vHD= convert-size -from Bytes -to GB -value $vHDi.MaximumSize;
										if($nHD -cge 1){
											$vHDisks+="..."+"$nHD"+"-"+$vHD; $nHD++
										}else{
											$vHDisks += "$nHD"+"-"+$vHD; $nHD++
										}
									}
								# cluster name
									$Clust = (Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).vmhost.hostcluster.name
								# convert memory bytes to GB
									$memory = convert-size -from MB -to GB -value $item.memory
								# DVD.iso
									$DVD = (Get-SCVirtualMachine -VMMServer $VMMserver.text -Name $item.name).VirtualDVDDrives.iso.SharePath
								# memory type
									if(!$item.DynamicMemoryEnabled){
										$memoryType = "Static"
									}else{
										$memoryType = "Dynamic"
									}
								#table
						    	try{$I = $List.Items.Add($s2[0].Substring(7))}catch{}
								try{$I.SubItems.Add($s2[1].Substring(14))}catch{}
								try{$I.SubItems.Add("$ipi")}catch{}
								try{$I.SubItems.Add("$ipv")}catch{}
								try{$I.SubItems.Add($Item.VirtualFibreChannelAdapters.count)}catch{}
								try{$I.SubItems.Add($s2[3].Substring(24))}catch{}
								try{$I.SubItems.Add($s2[4].Substring(17))}catch{}
								try{$I.SubItems.Add($item.VMCheckpoints.count)}catch{}
								try{$I.SubItems.Add($s2[6].Substring(12))}catch{}
								try{$I.SubItems.Add($s2[7].Substring(10))}catch{}
								try{$I.SubItems.Add($s2[8].Substring(10))}catch{}
								try{$I.SubItems.Add("$Clust")}catch{}
								try{$I.SubItems.Add("$memory")}catch{}
								try{$I.SubItems.Add("$memoryType")}catch{}
								try{$I.SubItems.Add($s2[11].Substring(10))}catch{}
								try{$I.SubItems.Add("$vHDisks")}catch{}
								try{$I.SubItems.Add("$vHDTypes")}catch{}
								try{$I.SubItems.Add("$DVD")}catch{}
								try{$I.SubItems.Add($s2[13].Substring(8))}catch{}
								try{$I.SubItems.Add($s2[14].Substring(14))}catch{}
								try{$I.SubItems.Add("$description1")}catch{}
								try{$I.SubItems.Add($item.customproperty.ИС)}catch{}
								try{$I.SubItems.Add($item.customproperty.Окружение)}catch{}
								try{$I.SubItems.Add($item.customproperty."$r")}catch{}
								try{$I.SubItems.Add($item.customproperty."$r1")}catch{}
								try{$I.SubItems.Add($item.customproperty.Проект)}catch{}
								try{$I.SubItems.Add($item.customproperty.Роль)}catch{}
								$o++
							}
						}if(!$List.Items){$I = $List.Items.Add("ВМ не найдена...") | Out-Null}
					}
					$count.Text = $o
				}
				#------------------------------------------------------------------------
#кнопка выгрузки в Excel
$ExportVM = New-Object System.Windows.Forms.Button
$ExportVM.Location = New-Object System.Drawing.Size(1000,600)
$ExportVM.Size = New-Object System.Drawing.Size(100,23)
$ExportVM.Text = "Выгрузить"
$ExportVM.Enabled = $true
$ExportVM.Dock = "Bottom"
$ExportVM.Add_Click({
	if(!($VMMserver.text -eq "Выберите пожалуйста имя сервера")){
		$excel.Visible = $True
			$Workbook = $excel.Workbooks.Add()
			#Соединяемся к worksheet, меняем имя и делаем активным
			$serverInfoSheet = $workbook.Worksheets.Item(1)
			$serverInfoSheet.Name = 'VM get info'
			$serverInfoSheet.application.activewindow.splitrow = 1
			$serverInfoSheet.application.activewindow.freezepanes = $true
			$serverInfoSheet.Activate() | Out-Null
			$row = 1
			$Column = 1
			$serverInfoSheet.Cells.Item($row,$column)= 'Name'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'ComputerName'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'ipv4Addresses'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'VLanID'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'VirtualFibreChannelAdapters'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'VirtualizationPlatform'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'OperatingSystem'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'VMCheckpoints'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'IntegrationServicesVersion'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'Location'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'HostName'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'ClusterName'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'Memory'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'MemoryType'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'CPUCount'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'vHDSize'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'vHDType'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'DVD.iso'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'Status'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'CreationTime'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'Description'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'ИС'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'Окружение'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'Ответственный за ВМ'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'Ответственный за ИС'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'Проект'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$Column++
			$serverInfoSheet.Cells.Item($row,$column)= 'Роль'
			$serverInfoSheet.Cells.Item($row,$column).Interior.ColorIndex =48
			$row++
			$Column1 = 1
			$Column2 = 2
			$Column3 = 3
			$Column4 = 4
			$Column5 = 5
			$Column6 = 6
			$Column7 = 7
			$Column8 = 8
			$Column9 = 9
			$Column10 = 10
			$Column11 = 11
			$Column12 = 12
			$Column13 = 13
			$Column14 = 14
			$Column15 = 15
			$Column16 = 16
			$Column17 = 17
			$Column18 = 18
			$Column19 = 19
			$Column20 = 20
			$Column21 = 21
			$Column22 = 22
			$Column23 = 23
			$Column24 = 24
			$Column25 = 25
			$Column26 = 26
			$Column27 = 27
	    	foreach ( $ListItem in $List.Items) {
		    	#Добавляем элемент в список
		    	try{$serverInfoSheet.Cells.Item($row,$column1)=($ListItem.subitems[0].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column2)=($ListItem.subitems[1].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column3)=($ListItem.subitems[2].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column4)=($ListItem.subitems[3].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column5)=($ListItem.subitems[4].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column6)=($ListItem.subitems[5].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column7)=($ListItem.subitems[6].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column8)=($ListItem.subitems[7].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column9)=($ListItem.subitems[8].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column10)=($ListItem.subitems[9].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column11)=($ListItem.subitems[10].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column12)=($ListItem.subitems[11].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column13)=($ListItem.subitems[12].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column14)=($ListItem.subitems[13].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column15)=($ListItem.subitems[14].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column16)=($ListItem.subitems[15].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column17)=($ListItem.subitems[16].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column18)=($ListItem.subitems[17].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column19)=($ListItem.subitems[18].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column20)=($ListItem.subitems[19].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column21)=($ListItem.subitems[20].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column22)=($ListItem.subitems[21].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column23)=($ListItem.subitems[22].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column24)=($ListItem.subitems[23].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column25)=($ListItem.subitems[24].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column26)=($ListItem.subitems[25].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column27)=($ListItem.subitems[26].text)}catch{}
				$Column++
				try{$serverInfoSheet.Cells.Item($row,$column28)=($ListItem.subitems[27].text)}catch{}
				$row++
			}									
	     	$excel.Selection.AutoFilter(1)
	}
})
$body.Controls.Add($ExportVM)
#------------------------------------------------------------------------
$body.ShowDialog();
$x