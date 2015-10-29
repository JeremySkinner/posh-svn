function isSvnDirectory() {
    $info = Get-SvnInfo
    if($info -isnot [system.array])
    {
        return !($info.StartsWith("svn: E155007"))
    }
    return $true
}

function Get-SvnInfo {
    return svn info
}

function Get-SvnStatus {
  if(IsSvnDirectory) {
    $untracked = 0
    $added = 0
    $modified = 0
    $deleted = 0
    $missing = 0
    $conflicted = 0
    $branchInfo = Get-SvnBranchInfo
    
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
               "Branch" = $branchInfo.Branch;
               "Revision" = $branchInfo.Revision;}
   }
}

function Get-SvnBranchInfo {
  if(IsSvnDirectory) {
    $info = svn info
    $url = $info[3].Replace("Relative URL: ^/", "") #Relative URL: ^/trunk/test
    $revision = $info[6].Replace("Revision: ", "") #Revision: 1234
    
    $pathBits = $url.Split("/", [StringSplitOptions]::RemoveEmptyEntries)
    
    if($pathBits[0] -eq "trunk") {
      $branch =  "trunk";
    }
    elseif($pathBits[0] -match "branches|tags") {
      $branch = $pathBits[1]
    }
    return @{"Branch" = $branch;
             "Revision" = $revision}
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

