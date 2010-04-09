function SvnTabExpansion($lastBlock) {
  switch -regex ($lastBlock) { 
  
    #handles svn help <cmd>
    #handles svn <cmd>
    'svn (help )?(\S*)$' {
      svnCommands($matches[2]);
    }
    
    'tsvn (\S*)$' {
      tortoiseSvnCommands($matches[1]);
    }
  }
}

function svnCommands($filter) {
  $cmdList = @()
  $output = svn help
  foreach($line in $output) {
    if($line -match '^   (\S+)(.*)') {
      $cmd = $matches[1]
      if($filter -and $cmd.StartsWith($filter)) {
        $cmdList += $cmd.Trim();
      }
      elseif(-not $filter) {
        $cmdList += $cmd.Trim();
      }
    }
  }
  $cmdList | sort
}

function tortoiseSvnCommands($filter) {
  if($filter) {
    return $tsvnCommands.keys | where { $tsvnCommands[$_].cmd.StartsWith($filter) } | sort
  }
  else {
    return $tsvnCommands.keys | sort
  }
}

$tsvnCommands = @{ 
"about" = @{ cmd = "about"; useCurrentDirectory = $false };
"log" = @{ cmd = "log"; useCurrentDirectory = $true };
"checkout" = @{ cmd = "checkout"; useCurrentDirectory = $false };
"import" = @{ cmd = "import"; useCurrentDirectory = $false };
"update" = @{ cmd = "update"; useCurrentDirectory = $true };
"commit" = @{ cmd = "commit"; useCurrentDirectory = $true };
"add" = @{ cmd = "add"; useCurrentDirectory = $false };
"revert" = @{ cmd = "revert"; useCurrentDirectory = $false };
"cleanup" = @{ cmd = "cleanup"; useCurrentDirectory = $false };
"resolve" = @{ cmd = "resolve"; useCurrentDirectory = $false };
"repocreate" = @{ cmd = "repocreate"; useCurrentDirectory = $false };
"switch" = @{ cmd = "switch"; useCurrentDirectory = $true };
"export" = @{ cmd = "export"; useCurrentDirectory = $false };
"merge" = @{ cmd = "merge"; useCurrentDirectory = $false };
"mergeall" = @{ cmd = "mergeall"; useCurrentDirectory = $false };
"copy" = @{ cmd = "copy"; useCurrentDirectory = $false };
"settings" = @{ cmd = "settings"; useCurrentDirectory = $false };
"remove" = @{ cmd = "remove"; useCurrentDirectory = $false };
"rename" = @{ cmd = "rename"; useCurrentDirectory = $false };
"diff" = @{ cmd = "diff"; useCurrentDirectory = $false };
"showcompare" = @{ cmd = "showcompare"; useCurrentDirectory = $false };
"conflicteditor" = @{ cmd = "conflicteditor"; useCurrentDirectory = $false };
"relocate" = @{ cmd = "relocate"; useCurrentDirectory = $false };
"help" = @{ cmd = "help"; useCurrentDirectory = $false };
"repostatus" = @{ cmd = "repostatus"; useCurrentDirectory = $false };
"repobrowser" = @{ cmd = "repobrowser"; useCurrentDirectory = $false };
"ignore" = @{ cmd = "ignore"; useCurrentDirectory = $false };
"blame" = @{ cmd = "blame"; useCurrentDirectory = $false };
"cat" = @{ cmd = "cat"; useCurrentDirectory = $false };
"createpatch" = @{ cmd = "createpatch"; useCurrentDirectory = $false };
"revisiongraph" = @{ cmd = "revisiongraph"; useCurrentDirectory = $false };
"lock" = @{ cmd = "lock"; useCurrentDirectory = $false };
"unlock" = @{ cmd = "unlock"; useCurrentDirectory = $false };
"rebuildiconcache" = @{ cmd = "rebuildiconcache"; useCurrentDirectory = $false };
"properties" = @{ cmd = "properties"; useCurrentDirectory = $false };
}