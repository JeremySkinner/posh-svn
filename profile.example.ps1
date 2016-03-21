Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-svn module from current directory
Import-Module .\posh-svn

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-svn


# Set up a simple prompt, adding the svn prompt parts inside svn repos
function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host($pwd) -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

Pop-Location
