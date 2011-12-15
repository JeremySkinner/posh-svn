Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-svn module from current directory
Import-Module .\posh-svn

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-svn


# Set up a simple prompt, adding the hg prompt parts inside hg repos
function prompt {
    Write-Host($pwd) -nonewline
        
    # SVN Prompt
    $Global:SvnStatus = Get-SvnStatus
    Write-SvnStatus $SvnStatus
      
    return "> "
}
$teBackup = 'posh-svn_DefaultTabExpansion'

if(-not (Test-Path Function:\$teBackup)) {
    Rename-Item Function:\TabExpansion $teBackup
}

# Set up tab expansion and include svn expansion
function TabExpansion($line, $lastWord) {
    $lastBlock = [regex]::Split($line, '[|;]')[-1]
    
    switch -regex ($lastBlock) {
        # svn and tortoisesvn tab expansion
        '(svn|tsvn) (.*)' { SvnTabExpansion($lastBlock) }
        # Fall back on existing tab expansion
        default { & $teBackup $line $lastWord }
    }
}


Pop-Location
