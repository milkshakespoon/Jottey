<#
.NAME
  Jottey
.SYNOPSIS
  A simple notepad
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.IO
[System.Windows.Forms.Application]::EnableVisualStyles()

# Globals
$global:InputFile = ""

$global:OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$global:OpenFileDialog.InitialDirectory = $InitialDirectory
$global:OpenFileDialog.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*"

#region begin GUI{ 

$Jottey = New-Object System.Windows.Forms.Form
$Jottey.ClientSize = "400,400"
$Jottey.Text = "Jottey"
$Jottey.TopMost = $false
$Jottey.Icon = "img/icon.ico"

$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Multiline = $true
$TextBox.AcceptsTab = $true
$TextBox.Width = 400
$TextBox.Height = 354
$TextBox.Anchor = "top,right,bottom,left"
$TextBox.Location = New-Object System.Drawing.Point(0, 24)
$TextBox.Font = "Consolas,10"
$TextBox.ScrollBars = "Both"
$TextBox.Add_KeyUp( { TextBoxType $TextBox $EventArgs } )
$TextBox.Add_Click( { TextBoxType $TextBox $EventArgs } )

$Jottey.Controls.Add($TextBox)

$Menu = New-Object System.Windows.Forms.MenuStrip
$FileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$OpenMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$AboutMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$EditMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$SelectAllMenu = New-Object System.Windows.Forms.ToolStripMenuItem

$Menu.Items.AddRange(@($FileMenu; $EditMenu))
$Menu.Location = New-Object System.Drawing.Point(0, 0)
$Menu.Name = "Menu"
$Menu.Size = New-Object System.Drawing.Size(400, 24)
$Menu.TabIndex = 0
$Menu.Text = "Menu"

$FileMenu.DropDownItems.AddRange(@($OpenMenu; $AboutMenu))
$FileMenu.Name = "fileToolStripMenuItem"
$FileMenu.Size = New-Object System.Drawing.Size(35, 20)
$FileMenu.Text = "&File"

$OpenMenu.Name = "openToolStripMenuItem"
$OpenMenu.Size = New-Object System.Drawing.Size(152, 22)
$OpenMenu.Text = "&Open"
$OpenMenu.Add_Click( { OpenMenuClick $OpenMenu $EventArgs} )
$OpenMenu.ShortCutKeys = "Control+O"

$AboutMenu.Name = "aboutToolStripMenuItem"
$AboutMenu.Size = New-Object System.Drawing.Size(269, 22)
$AboutMenu.Text = "&About"
$AboutMenu.Add_Click( { AboutMenuClick $AboutMenu $EventArgs} )

$EditMenu.DropDownItems.AddRange(@($SelectAllMenu))
$EditMenu.Name = "editToolStripMenuItem"
$EditMenu.Size = New-Object System.Drawing.Size(35, 20)
$EditMenu.Text = "&Edit"

$SelectAllMenu.Name = "selectAllToolStripMenuItem"
$SelectAllMenu.Size = New-Object System.Drawing.Size(152, 22)
$SelectAllMenu.Text = "Select &All"
$SelectAllMenu.Add_Click( { SelectAllMenuClick $OpenMenu $EventArgs} )
$SelectAllMenu.ShortCutKeys = "Control+A"

$Jottey.Controls.Add($Menu)

$StatusBar = New-Object System.Windows.Forms.StatusBar
$StatusBarPanel = New-Object System.Windows.Forms.StatusBarPanel
$StatusBarPanel.Text = "Ln 1, Col 1"
$StatusBar.ShowPanels = $true
$StatusBar.Panels.Add($StatusBarPanel)

$Jottey.Controls.Add($StatusBar)

#region gui events {
function OpenMenuClick($Sender, $e) {
  if ($global:OpenFileDialog.ShowDialog() -eq "OK") {
    $global:InputFile = $global:OpenFileDialog.FileName
    $InputData = Get-Content $global:InputFile
    $TextBox.Text = $InputData
  }
}

function SelectAllMenuClick($Sender, $e) {
  $TextBox.SelectAll()
}

function TextBoxType($Sender, $e) {
  if ($global:InputFile -ne "") {
    Set-Content $global:InputFile $TextBox.Text
  }

  if($TextBox.SelectionLength){
    $StatusBarPanel.Text = "Chars: " + ($TextBox.SelectedText).Length
  }
  else{
    $s = $TextBox.SelectionStart
    $y = $TextBox.GetLineFromCharIndex($s) + 1
    $x = ($s - $TextBox.GetFirstCharIndexOfCurrentLine() + 1)
    $StatusBarPanel.Text = "Ln: $y, Col: $x"
  }

}

function AboutMenuClick(){
  $Buttons=[System.Windows.Forms.MessageBoxButtons]::OK;
  $Message = [string]@'
  Jottey. 
  Simple plain text editor completely written in PowerShell.
  Saves files automatically.

  Contribute - https://github.com/gllms/Jottey
  
  MIT License - https://github.com/gllms/Jottey/blob/master/LICENSE.txt

  Copyright (c) 2018 gllms
'@

  [System.Windows.Forms.MessageBox]::Show($Message, "About", $Buttons);
}

function Alert($Message) {
  [System.Windows.Forms.MessageBox]::Show($Message)
}

#endregion events }

#endregion GUI }

[void]$Jottey.ShowDialog()