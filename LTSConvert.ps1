#----------------------------------------------------------------------------------------------------------------------------------------------
cd "$PSScriptRoot"

#----------------------------------------------------------------------------------------------------------------------------------------------
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#----------------------------------------------------------------------------------------------------------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Icon = "$PSScriptRoot\Dependencies\LTSC.ico"
$form.BackgroundImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\Dependencies\LTSC.png")
$form.BackgroundImageLayout = "Stretch"
$form.BackColor = "Black"
$form.ForeColor = "Cyan"
$form.FormBorderStyle = "None"
$form.Text = "LTSConvert by Bladez1992"
$form.Size = New-Object System.Drawing.Size(450, 320)
$form.StartPosition = "CenterScreen"

#----------------------------------------------------------------------------------------------------------------------------------------------
$btn1LTSCKeys = New-Object System.Windows.Forms.Button
$btn1LTSCKeys.Text = "1: Write LTSC Registry Keys"
$btn1LTSCKeys.BackColor = "Black"
$btn1LTSCKeys.ForeColor = "Cyan"
$btn1LTSCKeys.Size = New-Object System.Drawing.Size(205, 20)
$btn1LTSCKeys.Location = New-Object System.Drawing.Point(125, 25)
$btn1LTSCKeys.Add_Click({
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

    $values = @{
        "CompositionEditionID"         = "EnterpriseS"
        "EditionID"                    = "EnterpriseS"
        "ProductName"                  = "Windows 10 Enterprise LTSC 2021"
    }

    foreach ($key in $values.Keys) {
        try {
            if ($values[$key] -is [byte[]]) {
                Set-ItemProperty -Path $registryPath -Name $key -Value $values[$key] -Type Binary -Force
            }
            elseif ($values[$key] -is [int]) {
                Set-ItemProperty -Path $registryPath -Name $key -Value $values[$key] -Type DWord -Force
            }
            else {
                Set-ItemProperty -Path $registryPath -Name $key -Value $values[$key] -Type String -Force
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to set registry key: $key", "Error", "OK", "Error")
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Registry values have been updated successfully, now click on Convert Windows to LTSC 2021.", "Success", "OK", "Information")
})

#----------------------------------------------------------------------------------------------------------------------------------------------
$btn2ConvertWindows = New-Object System.Windows.Forms.Button
$btn2ConvertWindows.Text = "2: Convert Windows to LTSC 2021"
$btn2ConvertWindows.BackColor = "Black"
$btn2ConvertWindows.ForeColor = "Cyan"
$btn2ConvertWindows.Size = New-Object System.Drawing.Size(205, 20)
$btn2ConvertWindows.Location = New-Object System.Drawing.Point(125, 50)

$btn2ConvertWindows.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("After the Windows installer is finished and your PC restarts, run this script again and click on Activate Windows - the conversion to LTSC 2021 will deactivate Windows", "Instructions", "OK", "Information")
    $SelectedISO = $null
    $isDownload = $false  # false if ISO is manually selected, true if downloading

    $mirrors = @{
        "Archive.org Mirror 1" = "https://archive.org/download/Windows10EnterpriseLTSC202164Bit/en-us_windows_10_enterprise_ltsc_2021_x64_dvd_d289cf96.iso"
        "Archive.org Mirror 2" = "https://archive.org/download/win10ltsc2021enx64/en-us_windows_10_enterprise_ltsc_2021_x64_dvd_d289cf96.iso"
        "Archive.org Mirror 3" = "https://archive.org/download/Windows_10_Enterprise_LTSC_Versions/Windows%2010%20Enterprise%20LTSC%202021/en-us_windows_10_enterprise_ltsc_2021_x64_dvd_d289cf96.iso"
        "Archive.org Mirror 4" = "https://archive.org/download/en-us_windows_10_enterprise_ltsc_2021_x64_dvd_d289cf96_202112/en-us_windows_10_enterprise_ltsc_2021_x64_dvd_d289cf96.iso"
    }

    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "ISO Files (*.iso)|*.iso"
    $fileDialog.Title  = "Select a Windows 10 Enterprise LTSC 2021 64-bit ISO File or Press Cancel to Download One"
    if ($fileDialog.ShowDialog() -eq "OK") {
        $SelectedISO = $fileDialog.FileName
    }
    else {
        $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderDialog.Description = "Select a location to save the downloaded ISO file"

        if ($folderDialog.ShowDialog() -eq "OK") {
            $mirrorDropdown = New-Object System.Windows.Forms.ComboBox
            $mirrorDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
            $mirrorDropdown.Items.Add("Archive.org Mirror 1")
            $mirrorDropdown.Items.Add("Archive.org Mirror 2")
            $mirrorDropdown.Items.Add("Archive.org Mirror 3")
            $mirrorDropdown.Items.Add("Archive.org Mirror 4")
            $mirrorDropdown.SelectedIndex = 0
            $mirrorDropdown.Location = New-Object System.Drawing.Point(10, 40)
            $mirrorDropdown.Size     = New-Object System.Drawing.Size(300, 20)

            $mirrorForm = New-Object System.Windows.Forms.Form
            $mirrorForm.Text = "Select an ISO Download Mirror"
            $mirrorForm.Size = New-Object System.Drawing.Size(350, 180)
            $mirrorForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

            $label = New-Object System.Windows.Forms.Label
            $label.Text = "Select ISO Download Mirror"
            $label.Location = New-Object System.Drawing.Point(10, 10)
            $label.Size     = New-Object System.Drawing.Size(320, 20)
            $mirrorForm.Controls.Add($label)
            $mirrorForm.Controls.Add($mirrorDropdown)

            $buttonOK = New-Object System.Windows.Forms.Button
            $buttonOK.Text = "OK"
            $buttonOK.Location = New-Object System.Drawing.Point(120, 80)
            $buttonOK.Add_Click({ $mirrorForm.Close() })
            $mirrorForm.Controls.Add($buttonOK)

            $mirrorForm.ShowDialog()

            $SelectedMirror = $mirrorDropdown.SelectedItem
            if (-not $SelectedMirror) {
                [System.Windows.Forms.MessageBox]::Show("Invalid selection.", "Error", "OK", "Error")
                return
            }

            $remoteFilename = [System.IO.Path]::GetFileName($mirrors[$SelectedMirror])
            $SelectedISO = Join-Path -Path $folderDialog.SelectedPath -ChildPath $remoteFilename

            $btn2ConvertWindows.Text = "Downloading ISO..."
            $btn2ConvertWindows.Enabled = $false
            $isDownload = $true

            $progressForm = New-Object System.Windows.Forms.Form
            $progressForm.Text = "Downloading ISO (4.56gb)"
            $progressForm.Size = New-Object System.Drawing.Size(325, 150)
            $progressForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

            $progressLabel = New-Object System.Windows.Forms.Label
            $progressLabel.Size = New-Object System.Drawing.Size(250, 20)
            $progressLabel.Location = New-Object System.Drawing.Point(25, 40)
            $progressLabel.Text = "Downloading"
            $progressLabel.TextAlign = 'MiddleCenter'
            $progressForm.Controls.Add($progressLabel)

            $progressForm.Show()
            [System.Windows.Forms.Application]::DoEvents()

            $dotTimer = New-Object System.Windows.Forms.Timer
            $dotTimer.Interval = 500
            $dotTimer.Add_Tick({
                $current = $progressLabel.Text
                if ($current -match "^Downloading(\.*)$") {
                    $dots = $Matches[1]
                    $progressLabel.Text = "Downloading" + ("." * (($dots.Length + 1) % 4))
                }
            })
            $dotTimer.Start()

            $wc = New-Object System.Net.WebClient
            # Start the download asynchronously...
            $wc.DownloadFileAsync($mirrors[$SelectedMirror], $SelectedISO)
            # Continuously poll until the download finishes
            while ($wc.IsBusy) {
                Start-Sleep -Milliseconds 200
                [System.Windows.Forms.Application]::DoEvents()
            }
            $dotTimer.Stop()
            $dotTimer.Dispose()
            $progressForm.Close()
            $progressForm.Dispose()

            try {
                $btn2ConvertWindows.Text = "Mounting ISO..."
                $mountResult = Mount-DiskImage -ImagePath $SelectedISO -PassThru
                # Wait up to 10 seconds for the drive letter to appear
                $attempt = 0
                do {
                    Start-Sleep -Seconds 1
                    $driveLetter = ($mountResult | Get-Volume).DriveLetter
                    $attempt++
                } until ($driveLetter -or $attempt -ge 10)
                if ($driveLetter) {
                    $drivePath = "${driveLetter}:"
                    $setupPath = Join-Path -Path $drivePath -ChildPath "setup.exe"
                    if (Test-Path $setupPath) {
                        $btn2ConvertWindows.Text = "Launching Setup..."
                        Start-Process -FilePath $setupPath
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("setup.exe not found in the root of the mounted ISO!", "Error", "OK", "Error")
                    }
                }
                else {
                    [System.Windows.Forms.MessageBox]::Show("Failed to mount the ISO or retrieve the drive letter.", "Error", "OK", "Error")
                }
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("An error occurred while mounting the ISO: $_", "Error", "OK", "Error")
            }
            finally {
                $btn2ConvertWindows.Text = "2: Convert Windows to LTSC 2021"
                $btn2ConvertWindows.Enabled = $true
            }
            return  # Exit so the manual mount code below doesn't run
        }
    }

    if (-not $SelectedISO) {
        [System.Windows.Forms.MessageBox]::Show("No ISO selected or downloaded!", "Error", "OK", "Error")
        return
    }

    # --- If the user selected an ISO manually, mount it now ---
    if (-not $isDownload) {
        try {
            $btn2ConvertWindows.Text = "Mounting ISO..."
            $btn2ConvertWindows.Enabled = $false

            $mountResult = Mount-DiskImage -ImagePath $SelectedISO -PassThru
            $driveLetter = ($mountResult | Get-Volume).DriveLetter

            if ($driveLetter) {
                $drivePath = "${driveLetter}:"
                $setupPath = Join-Path -Path $drivePath -ChildPath "setup.exe"
                if (Test-Path $setupPath) {
                    $btn2ConvertWindows.Text = "Launching Setup..."
                    Start-Process -FilePath $setupPath
                }
                else {
                    [System.Windows.Forms.MessageBox]::Show("setup.exe not found in the root of the mounted ISO!", "Error", "OK", "Error")
                }
            }
            else {
                [System.Windows.Forms.MessageBox]::Show("Failed to mount the ISO or retrieve the drive letter.", "Error", "OK", "Error")
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred while mounting the ISO: $_", "Error", "OK", "Error")
        }
        finally {
            $btn2ConvertWindows.Text = "2: Convert Windows to LTSC 2021"
            $btn2ConvertWindows.Enabled = $true
        }
    }
})

#----------------------------------------------------------------------------------------------------------------------------------------------
$btn3ActivateWindows = New-Object System.Windows.Forms.Button
$btn3ActivateWindows.Text = "3: Activate Windows"
$btn3ActivateWindows.BackColor = "Black"
$btn3ActivateWindows.ForeColor = "Cyan"
$btn3ActivateWindows.Size = New-Object System.Drawing.Size(205, 20)
$btn3ActivateWindows.Location = New-Object System.Drawing.Point(125, 75)
$btn3ActivateWindows.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Choose Option 1 (HWID Activation) when the activation script runs - if it fails for some reason then choose Option 4 (KMS38 Activation)", "Activation Instructions", "OK", "Information")

    $btn3ActivateWindows.Text = "3: Activating..."
    $btn3ActivateWindows.Enabled = $false

    try {
        irm https://get.activated.win | iex
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred while executing the command: $_", "Error", "OK", "Error")
    }
    finally {
        $btn3ActivateWindows.Text = "3: Activate Windows"
        $btn3ActivateWindows.Enabled = $true
    }
})

#----------------------------------------------------------------------------------------------------------------------------------------------
$btnOpenLTSConvertDir = New-Object System.Windows.Forms.Button
$btnOpenLTSConvertDir.Text = "LTSConvert Directory"
$btnOpenLTSConvertDir.BackColor = "Black"
$btnOpenLTSConvertDir.ForeColor = "Cyan"
$btnOpenLTSConvertDir.Size = New-Object System.Drawing.Size(125, 20)
$btnOpenLTSConvertDir.Location = New-Object System.Drawing.Point(5, 295)
$btnOpenLTSConvertDir.Add_Click({
    Invoke-Item "$PSScriptRoot"
})

#----------------------------------------------------------------------------------------------------------------------------------------------
$btnMinimize = New-Object System.Windows.Forms.Button
$btnMinimize.Text = "-"
$btnMinimize.BackColor = "Black"
$btnMinimize.ForeColor = "Cyan"
$btnMinimize.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 20, [System.Drawing.FontStyle]::Bold)
$btnMinimize.Size = New-Object System.Drawing.Size(20, 20)
$btnMinimize.Location = New-Object System.Drawing.Point(405, 5)
$btnMinimize.Add_Click({
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
})

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "X"
$btnExit.BackColor = "Black"
$btnExit.ForeColor = "Cyan"
$btnExit.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9, [System.Drawing.FontStyle]::Bold)
$btnExit.Size = New-Object System.Drawing.Size(20, 20)
$btnExit.Location = New-Object System.Drawing.Point(425, 5)
$btnExit.Add_Click({
    taskkill /IM "cmd.exe" /F
    taskkill /IM "powershell.exe" /F
    $form.Close()
})

#----------------------------------------------------------------------------------------------------------------------------------------------
$form.Controls.Add($btn1LTSCKeys)
$form.Controls.Add($btn2ConvertWindows)
$form.Controls.Add($btn3ActivateWindows)
$form.Controls.Add($btnOpenLTSConvertDir)
$form.Controls.Add($btnMinimize)
$form.Controls.Add($btnExit)
$form.Controls.Add($btn3ActivateWindows)

#----------------------------------------------------------------------------------------------------------------------------------------------
$form.ShowDialog()
