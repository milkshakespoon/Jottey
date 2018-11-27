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
$global:InputFile = "C:\Users\adam.gentle\Desktop\test2.txt"

#region begin GUI{ 

$Jottey = New-Object System.Windows.Forms.Form
$Jottey.ClientSize = "400,400"
$Jottey.Text = "Jottey"
$Jottey.TopMost = $false
$Jottey.Icon = "img/icon.ico"

$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Multiline = $true
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
$SaveAsMenu = New-Object System.Windows.Forms.ToolStripMenuItem

$Menu.Items.AddRange(@($FileMenu))
$Menu.Location = New-Object System.Drawing.Point(0, 0)
$Menu.Name = "Menu"
$Menu.Size = New-Object System.Drawing.Size(400, 24)
$Menu.TabIndex = 0
$Menu.Text = "Menu"

$FileMenu.DropDownItems.AddRange(@($OpenMenu))
$FileMenu.DropDownItems.AddRange(@($SaveAsMenu))
$FileMenu.Name = "fileToolStripMenuItem"
$FileMenu.Size = New-Object System.Drawing.Size(35, 20)
$FileMenu.Text = "&File"

$OpenMenu.Name = "openToolStripMenuItem"
$OpenMenu.Size = New-Object System.Drawing.Size(152, 22)
$OpenMenu.Text = "&Open"
$OpenMenu.Add_Click( { OpenMenuClick $OpenMenu $EventArgs} )

$SaveAsMenu.Name = "saveAsToolStripMenuItem"
$SaveAsMenu.Size = New-Object System.Drawing.Size(269, 22)
$SaveAsMenu.Text = "&Save As"
$SaveAsMenu.Add_Click( { SaveAsMenuClick $SaveAsMenu $EventArgs} )

$Jottey.Controls.Add($Menu)

$StatusBar = New-Object System.Windows.Forms.StatusBar
$StatusBarPanel = New-Object System.Windows.Forms.StatusBarPanel
$StatusBarPanel.Text = "Ln 1, Col 1"
$StatusBar.ShowPanels = $true
$StatusBar.Panels.Add($StatusBarPanel)

$Jottey.Controls.Add($StatusBar)

#region gui events {
function OpenMenuClick($Sender, $e) {
  [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
  
  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.InitialDirectory = "C:\"
  $OpenFileDialog.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*"
  System.Windows.Forms.DialogResult $Result = $OpenFileDialog.ShowDialog() | Out-Null
  $OpenFileDialog.FileName

  if($Result -eq (DialogResult.OK)){
    $global:InputFile = $OpenFileDialog.FileName
    $InputData = Get-Content $global:InputFile
    $TextBox.Text = $InputData
  }
}

# REQUIRES WORK ON SAVING THE CONTENTS OF THE FILE
function SaveAsMenuClick($Sender, $e) {
  
  $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
  $SaveFileDialog.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*" 
  $SaveFileDialog.Title = "Save As"
  $SaveFileDialog.ShowDialog() | Out-Null

  if(($SaveFileDialog.FileName -ne "") -and ($SaveFileDialog.ShowDialog() -eq (System.Windows.Forms.DialogResult.OK))){  
      $SaveFileDialog.OpenFile()
      $global:InputFile = $SaveFileDialog.FileName
      File.WriteAllText($SaveFileDialog.FileName, $TextBox.Text)
  }  
}

function TextBoxType($Sender, $e) {
  if ($global:InputFile -ne "") {
    Set-Content $global:InputFile $TextBox.Text
  }

  $s = $TextBox.SelectionStart
  $y = $TextBox.GetLineFromCharIndex($s) + 1
  $x = $s - $TextBox.GetFirstCharIndexOfCurrentLine() + 1
  $StatusBarPanel.Text = "Ln: $y, Col: $x"
}

function Alert($Message) {
  [System.Windows.Forms.MessageBox]::Show($Message)
}

#endregion events }

#endregion GUI }

[void]$Jottey.ShowDialog()
