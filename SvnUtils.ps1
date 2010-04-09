function isSvnDirectory() {
  return (test-path ".svn")
}

function Get-SvnStatus {
  if(IsSvnDirectory) {
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
  if(IsSvnDirectory) {
    $info = svn info
    $url = $info[1].Replace("URL: ", "") #URL: svn://server/repo/trunk/test
    $root = $info[2].Replace("Repository Root: ", "") #Repository Root: svn://server/repo
    
    $path = $url.Replace($root, "")
    $pathBits = $path.Split("/", [StringSplitOptions]::RemoveEmptyEntries)
    
    if($pathBits[0] -eq "trunk") {
      return "trunk";
    }
    if($pathBits[0] -match "branches|tags") {
      return $pathBits[1]
    }
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

