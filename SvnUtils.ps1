function isSvnDirectory() {
    $info = Get-SvnInfo
    if($info -is [system.array])
    {
        return $true
    }
    return $false
}

function Get-SvnInfo {
    Try {
        $info = svn info 2> $null
        return $info
    }
    Catch
    {
        return $_.Exception.Message
    }
}

function Get-SvnStatus {
  if(IsSvnDirectory) {
    $untracked = 0
    $added = 0
    $ignored = 0
    $modified = 0
    $replaced = 0
    $deleted = 0
    $missing = 0
    $conflicted = 0
    $external = 0
    $obstructed = 0
    $incoming = 0
    $incomingRevision = 0
    $branchInfo = Get-SvnBranchInfo
    $info = Get-SvnInfo
    $hostName = ([System.Uri]$info[2].Replace("URL: ", "")).Host #URL: http://svnserver/trunk/test

    if (Test-Connection -computername $hostName -Quiet -Count 1 -BufferSize 1) {
        $status = svn status -u --ignore-externals
    } else {
        $status = svn status --ignore-externals
    }

    foreach($line in $status) {
        if ($line.StartsWith("Status"))
        {
            $incomingRevision = [Int]$line.Replace("Status against revision:", "")
        }
        else
        {
            switch($line[0]) {
                'A' { $added++; break; }
                'C' { $conflicted++; break; }
                'D' { $deleted++; break; }
                'I' { $ignored++; break; }
                'M' { $modified++; break; }
                'R' { $replaced++; break; }
                'X' { $external++; break; }
                '?' { $untracked++; break; }
                '!' { $missing++; break; }
                '~' { $obstructed++; break; }
            }
            switch($line[4]) {
                'X' { $external++; break; }
            }
            switch($line[6]) {
                'C' { $conflicted++; break; }
            }
            switch($line[8]) {
                '*' { $incoming++; break; }
            }
        }
    }

    return @{"Untracked" = $untracked;
               "Added" = $added;
               "Modified" = $modified + $replaced;
               "Deleted" = $deleted;
               "Missing" = $missing;
               "Conflicted" = $conflicted + $obstructed;
               "External" = $external;
               "Incoming" = $incoming
               "Branch" = $branchInfo.Branch;
               "Revision" = $branchInfo.Revision;
               "IncomingRevision" = $incomingRevision;}
   }
}

function Get-SvnBranchInfo {
  if(IsSvnDirectory) {
    $info = Get-SvnInfo
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
