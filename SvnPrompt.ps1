$global:SvnPromptSettings = New-Object PSObject -Property @{
    BeforeText                = ' ['
    BeforeForegroundColor     = [ConsoleColor]::Yellow
    BeforeBackgroundColor     = $Host.UI.RawUI.BackgroundColor
    
    AfterText                 = ']'
    AfterForegroundColor      = [ConsoleColor]::Yellow
    AfterBackgroundColor      = $Host.UI.RawUI.BackgroundColor
    
    ErrorForegroundColor      = [ConsoleColor]::Red
    ErrorBackgroundColor      = $Host.UI.RawUI.BackgroundColor
    
    BranchForegroundColor    = [ConsoleColor]::Cyan
    BranchBackgroundColor    = $Host.UI.RawUI.BackgroundColor
    
    WorkingForegroundColor    = [ConsoleColor]::Yellow
    WorkingBackgroundColor    = $Host.UI.RawUI.BackgroundColor
}

function Write-SvnStatus($status) {
    if ($status) {
        $s = $global:SvnPromptSettings
       
        Write-Host $s.BeforeText -NoNewline -BackgroundColor $s.BeforeBackgroundColor -ForegroundColor $s.BeforeForegroundColor
        Write-Host $status.Branch -NoNewline -BackgroundColor $s.BranchBackgroundColor -ForegroundColor $s.BranchForegroundColor
        
        if($status.Added) {
          Write-Host " +$($status.Added)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }
        if($status.Modified) {
          Write-Host " ~$($status.Modified)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }
        if($status.Deleted) {
          Write-Host " -$($status.Deleted)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }
        
        if ($status.Untracked) {
          Write-Host " ?$($status.Untracked)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }
                
        if($status.Missing) {
           Write-Host " !$($status.Missing)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }
      
        if($status.Conflicted) {
          write-host " C$($status.Conflicted)" -NoNewLine -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }
      
        Write-Host $s.AfterText -NoNewline -BackgroundColor $s.AfterBackgroundColor -ForegroundColor $s.AfterForegroundColor
    }
}

# Should match https://github.com/dahlbyk/posh-git/blob/master/GitPrompt.ps1
if (!$Global:VcsPromptStatuses) { $Global:VcsPromptStatuses = @() }

function Global:Write-VcsStatus {
    $Global:VcsPromptStatuses | foreach {
        $vcsPromptErrors = $null
        try {
            Invoke-Command -ScriptBlock $_ -ErrorVariable vcsPromptErrors 2>$null
        }
        catch {
            $vcsPromptErrors = $_
        }
        if ($vcsPromptErrors.Length -gt 0) {
             # Log the errors but dont affect the users prompt, splat error objects into Write-Error
            $vcsPromptErrors | % { Write-Error -ErrorAction SilentlyContinue @_ }
            $s = $Global:SvnPromptSettings
            if ($s) {
                Write-Prompt $s.BeforeText -BackgroundColor $s.BeforeBackgroundColor -ForegroundColor $s.BeforeForegroundColor
                Write-Prompt "Error" -BackgroundColor $s.ErrorBackgroundColor -ForegroundColor $s.ErrorForegroundColor
                Write-Prompt $s.AfterText -BackgroundColor $s.AfterBackgroundColor -ForegroundColor $s.AfterForegroundColor
            }
        }
    }
}

# Scriptblock that will execute for write-vcsstatus
$Global:VcsPromptStatuses += {
	$Global:SvnStatus = Get-SvnStatus
	Write-SvnStatus $SvnStatus
}
