Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-svn module from current directory
Import-Module .\posh-svn

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-svn


# Set up a simple prompt, adding the svn prompt parts inside svn repos
function prompt {
    Write-Host($pwd) -nonewline
        
    # Mercurial Prompt
    $Global:SvnStatus = Get-SvnStatus
    Write-SvnStatus $SvnStatus
      
    return "> "
}

if(-not (Test-Path Function:\DefaultTabExpansion)) {
    Rename-Item Function:\TabExpansion DefaultTabExpansion
}

# Set up tab expansion and include hg expansion
function TabExpansion($line, $lastWord) {
    $lastBlock = [regex]::Split($line, '[|;]')[-1]
    
    switch -regex ($lastBlock) {
        # svn tab expansion
		'(svn) (.*)' { SvnTabExpansion($lastBlock) }
        # Fall back on existing tab expansion
        default { DefaultTabExpansion $line $lastWord }
    }
}


Pop-Location
