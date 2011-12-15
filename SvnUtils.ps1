function Get-SvnInfo {
  try
  {
      $xinfo = [xml](svn info Get-ActualPath($Pwd) --xml)
      if ($xinfo.info.entry.url)
      {
        return $xinfo
      }
   }
   catch
   {
      return
   }
}

function Get-ActualPath($path)
{
    if (!$path)
    {
        $path = $Pwd
    }
    #We need the correct case for a path so that svn recognises it as a node.
    if (Test-Path $path)
    {
        Push-Location
        Set-Location $path
        $path = Get-Location
        Set-Location -Path ..
        
        $pathStr = [System.IO.Path]::GetFullPath($path)
        foreach ($subdir in Get-ChildItem)
        {
            Push-Location
            Set-Location $subdir
            $subdir = Get-Location
            $subStr = [System.IO.Path]::GetFullPath($subdir)
            Pop-Location
            if ($subStr -eq $pathStr)
            {
               $path = $subdir
               break
            }
        }
        Pop-Location
    }
    return $path
}

function Get-SvnStatus {
  if(Get-SvnInfo)
  {
    $untracked = 0
    $added = 0
    $modified = 0
    $deleted = 0
    $missing = 0
    $conflicted = 0
    $branch = Get-SvnBranch
    
    svn status | foreach {
      $char = $_[0]
      switch($char) {
         'A' { $added++ }
         'C' { $conflicted++ }
         'D' { $deleted++ }
         'M' { $modified++ }
         'R' { $modified++ }
         '?' { $untracked++ }
         '!' { $missing++ }
      }
    }
    
    return @{"Untracked" = $untracked;
               "Added" = $added;
               "Modified" = $modified;
               "Deleted" = $deleted;
               "Missing" = $missing;
               "Conflicted" = $conflicted;
               "Branch" = $branch}
   }
}

function Get-SvnBranch {
  $xinfo = Get-SvnInfo
  if($xinfo)
  {
    $url = $xinfo.info.entry.url #URL: svn://server/repo/trunk/test
    $root = $xinfo.info.entry.repository.root #Repository Root: svn://server/repo
    
    #Get the repository name
    $repositoryBits = $root.Split("/", [StringSplitOptions]::RemoveEmptyEntries)
    $repository = $repositoryBits[-1]
    
    #Try to get the branch name
    $path = $url.Replace($root, "")
    $pathBits = $path.Split("/", [StringSplitOptions]::RemoveEmptyEntries)
    
    foreach ($bit in $pathBits)
    {
        if($bit -match "trunk") {
          return $repository + ":trunk"
        }
        if($bit -match "branches|tags") {
          if ($ForEach.MoveNext())
          {
             return $repository + ":" + $ForEach.Current
          }
          else
          {
             break
          }
        }
    }
    return $repository
  }
}

function tsvn {
  if($args) {
    if($args[0] -eq "help") {
      #I don't like the built in help behaviour!
      $tsvnCommands.keys | sort | % { write-host $_ }
          
      return    
    }

    $newArgs = @()
    $newArgs += "/command:" + $args[0]
    
    $cmd = $tsvnCommands[$args[0]]
    if($cmd -and $cmd.useCurrentDirectory) {
       $newArgs += "/path:."
    }
    
    if($args.length -gt 1) {
      $args[1..$args.length] | % { $newArgs += $_ }
    }
      
    tortoiseproc $newArgs
  }
}

