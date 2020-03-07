function Get-NCLauncherBaseDirectory {
  $localMachine = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
  if ( $localMachine -ne $null ) {
    try {
      $key = $localMachine.OpenSubKey('SOFTWARE\plaync\NCLauncherW')
      if ( $key -ne $null ) {
        try {
          $value = [string]$key.GetValue('BaseDir')
          if ( [System.IO.Directory]::Exists($value) ) {
            return $value
          }
        } finally {
          $key.Dispose()
        }
      }

      $key = $localMachine.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\NCLauncherW_plaync')
      if ( $key -ne $null ) {
        try {
          $value = [string]$key.GetValue('InstallLocation')
          if ( [System.IO.Directory]::Exists($value) ) {
            return $BaseDir
          }
        } finally {
          $key.Dispose()
        }
      }

      $default = "$env:MSBuildProgramFiles32\NCSOFT\NC Launcher 2"
      if ( [System.IO.Directory]::Exists($default) ) {
        return $default
      }
    } finally {
      $localMachine.Dispose()
    }
  }
  return $null
}

$BaseDir = Get-NCLauncherBaseDirectory
if ( $BaseDir ) {
  $env:MONOMOD_PUBLIC_EVERYTHING = '1'
  foreach ( $file in @('Gaffeine.Data.dll', 'GameUpdateService.dll') ) {
    & "$env:MSBuildProjectDir\tools\MonoMod\MonoMod.exe" "$BaseDir\$file" "$env:MSBuildProjectDir\lib\ncLauncherW\$file"
  }
}
