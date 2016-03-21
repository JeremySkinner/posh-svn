$global:SvnPromptSettings = New-Object PSObject -Property @{
    BeforeText                = ' ['
    BeforeForegroundColor     = [ConsoleColor]::Yellow
    BeforeBackgroundColor     = $Host.UI.RawUI.BackgroundColor

    AfterText                 = ']'
    AfterForegroundColor      = [ConsoleColor]::Yellow
    AfterBackgroundColor      = $Host.UI.RawUI.BackgroundColor

    BranchForegroundColor     = [ConsoleColor]::Cyan
    BranchBackgroundColor     = $Host.UI.RawUI.BackgroundColor

    RevisionForegroundColor   = [ConsoleColor]::DarkGray
    RevisionBackgroundColor   = $Host.UI.RawUI.BackgroundColor

    WorkingForegroundColor    = [ConsoleColor]::Yellow
    WorkingBackgroundColor    = $Host.UI.RawUI.BackgroundColor

    ExternalStatusSymbol      = [char]0x2190 # arrow right
    ExternalForegroundColor   = [ConsoleColor]::DarkMagenta
    ExternalBackgroundColor   = $Host.UI.RawUI.BackgroundColor

    IncomingStatusSymbol      = [char]0x2193 # Down arrow
    IncomingForegroundColor   = [ConsoleColor]::Red
    IncomingBackgroundColor   = $Host.UI.RawUI.BackgroundColor
}

function Write-SvnStatus($status) {
    if ($status) {
        $s = $global:SvnPromptSettings

        Write-Prompt $s.BeforeText -NoNewline -BackgroundColor $s.BeforeBackgroundColor -ForegroundColor $s.BeforeForegroundColor
        Write-Prompt $status.Branch -NoNewline -BackgroundColor $s.BranchBackgroundColor -ForegroundColor $s.BranchForegroundColor
        Write-Prompt "@$($status.Revision)" -NoNewline -BackgroundColor $s.RevisionBackgroundColor -ForegroundColor $s.RevisionForegroundColor

        if($status.Added) {
          Write-Prompt " +$($status.Added)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }
        if($status.Modified) {
          Write-Prompt " ~$($status.Modified)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }
        if($status.Deleted) {
          Write-Prompt " -$($status.Deleted)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }

        if ($status.Untracked) {
          Write-Prompt " ?$($status.Untracked)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }

        if($status.Missing) {
           Write-Prompt " !$($status.Missing)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }

        if($status.Conflicted) {
          Write-Prompt " C$($status.Conflicted)" -NoNewLine -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
        }

        if($status.Incoming) {
          Write-Prompt " $($s.IncomingStatusSymbol)$($status.Incoming)" -NoNewLine -BackgroundColor $s.IncomingBackgroundColor -ForegroundColor $s.IncomingForegroundColor
          Write-Prompt "@$($status.IncomingRevision)" -NoNewline -BackgroundColor $s.RevisionBackgroundColor -ForegroundColor $s.RevisionForegroundColor
        }

        if($status.External) {
          Write-Prompt " $($s.ExternalStatusSymbol)$($status.External)" -NoNewLine -BackgroundColor $s.ExternalBackgroundColor -ForegroundColor $s.ExternalForegroundColor
        }

        Write-Prompt $s.AfterText -NoNewline -BackgroundColor $s.AfterBackgroundColor -ForegroundColor $s.AfterForegroundColor
    }
}

# Should match https://github.com/dahlbyk/posh-git/blob/master/GitPrompt.ps1
if(!(Test-Path Variable:Global:VcsPromptStatuses)) {
    $Global:VcsPromptStatuses = @()
}

# Scriptblock that will execute for write-vcsstatus
$PoshSvnVcsPrompt = {
	$Global:SvnStatus = Get-SvnStatus
	Write-SvnStatus $SvnStatus
}
$Global:VcsPromptStatuses += $PoshSvnVcsPrompt
$ExecutionContext.SessionState.Module.OnRemove = { $Global:VcsPromptStatuses = $Global:VcsPromptStatuses | ? { $_ -ne $PoshSvnVcsPrompt} }
