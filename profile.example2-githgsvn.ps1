Import-Module PsGet
Import-Module PsJson
Import-Module PsUrl
Import-Module pswatch
Import-Module posh-git
Import-Module posh-svn
Import-Module posh-hg

#Set up a prompt that includes the various status infos from my source control modules.
function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    
    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    Write-Host($pwd) -nonewline
    
    # SVN Prompt
    $Global:SvnStatus = Get-SvnStatus
    if (SvnStatus)
    {
      Write-SvnStatus $SvnStatus
    }
    else
    {
      #Mercurial Prompt
      $Global:HgStatus = Get-HgStatus
      if ($HgStatus)
      {
        Write-HgStatus $HgStatus
      }
      else
      {
        # Git Prompt
        $Global:GitStatus = Get-GitStatus
        if ($GitStatus)
        {
          Write-GitStatus $GitStatus
        }
      }
    }
    
    $LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

$teBackup = 'profile_DefaultTabExpansion'
if(!(Test-Path Function:\$teBackup)) {
    Rename-Item Function:\TabExpansion $teBackup
}

# Set up tab expansion and include git expansion
function TabExpansion($line, $lastWord) {
    $lastBlock = [regex]::Split($line, '[|;]')[-1]
    
    switch -regex ($lastBlock) {
        # svn and tortoisesvn tab expansion
        '(svn|tsvn) (.*)' { SvnTabExpansion($lastBlock) }
        # Execute git tab completion for all git-related commands
        'git (.*)' { GitTabExpansion $lastBlock }
        # mercurial and tortoisehg tab expansion
        '(hg|thg) (.*)' { HgTabExpansion($lastBlock) }
        # Fall back on existing tab expansion
        default { & $teBackup $line $lastWord }
    }
}

Enable-GitColors

# Start-SshAgent -Quiet