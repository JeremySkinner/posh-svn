Push-Location $psScriptRoot
. ./SvnUtils.ps1
. ./SvnPrompt.ps1
. ./SvnTabExpansion.ps1
Pop-Location

New-Alias -Name "ap" -Value "Get-ActualPath"

Export-ModuleMember -Function @(
  'Write-SvnStatus',
  'Get-SvnStatus',
  'Get-ActualPath',
  'SvnTabExpansion',
  'tsvn'
) -Alias @(
  'ap'
)
