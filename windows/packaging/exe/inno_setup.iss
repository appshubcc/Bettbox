[Setup]
AppId={{APP_ID}}
AppVersion={{APP_VERSION}}
AppName={{DISPLAY_NAME}}
AppPublisher={{PUBLISHER_NAME}}
AppPublisherURL={{PUBLISHER_URL}}
AppSupportURL={{PUBLISHER_URL}}
AppUpdatesURL={{PUBLISHER_URL}}
DefaultDirName={{INSTALL_DIR_NAME}}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename={{OUTPUT_BASE_FILENAME}}
Compression=lzma
SolidCompression=yes
SetupIconFile={{SETUP_ICON_FILE}}
UninstallDisplayIcon={app}\{{EXECUTABLE_NAME}}
WizardStyle=modern
PrivilegesRequired={{PRIVILEGES_REQUIRED}}
ArchitecturesAllowed={{ARCH}}
ArchitecturesInstallIn64BitMode={{ARCH}}
CloseApplications=yes
CloseApplicationsFilter={{EXECUTABLE_NAME}},{{CORE_EXECUTABLE_NAME}},{{HELPER_EXECUTABLE_NAME}}
SetupLogging=yes

[Code]
var
  ShouldCleanUserData: Boolean;

function IsProcessRunning(ProcessName: String): Boolean;
var
  ResultCode: Integer;
begin
  Exec('cmd.exe', '/c tasklist /fi "imagename eq ' + ProcessName + '" 2>nul | find /i "' + ProcessName + '" >nul', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := (ResultCode = 0);
end;

procedure ForceKillProcesses;
var
  ResultCode: Integer;
  WaitCount: Integer;
begin
  if IsProcessRunning('{{HELPER_EXECUTABLE_NAME}}') then
  begin
    Exec('sc', 'stop {{HELPER_SERVICE_NAME}}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

    WaitCount := 0;
    while (WaitCount < 5) and IsProcessRunning('{{HELPER_EXECUTABLE_NAME}}') do
    begin
      Sleep(400);
      WaitCount := WaitCount + 1;
    end;

    if IsProcessRunning('{{HELPER_EXECUTABLE_NAME}}') then
      Exec('taskkill', '/f /im {{HELPER_EXECUTABLE_NAME}}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;

  { Try to elegantly exit the main app using --exit parameter }
  if FileExists(ExpandConstant('{app}\{{EXECUTABLE_NAME}}')) and IsProcessRunning('{{EXECUTABLE_NAME}}') then
  begin
    Exec(ExpandConstant('{app}\{{EXECUTABLE_NAME}}'), '--exit', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

    { Wait up to 3 seconds for the main app and core to exit }
    WaitCount := 0;
    while (WaitCount < 10) and (IsProcessRunning('{{EXECUTABLE_NAME}}') or IsProcessRunning('{{CORE_EXECUTABLE_NAME}}')) do
    begin
      Sleep(300);
      WaitCount := WaitCount + 1;
    end;
  end;

  { Fallback: force-kill if still running }
  if IsProcessRunning('{{EXECUTABLE_NAME}}') then
    Exec('taskkill', '/f /im {{EXECUTABLE_NAME}}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

  if IsProcessRunning('{{CORE_EXECUTABLE_NAME}}') then
    Exec('taskkill', '/f /im {{CORE_EXECUTABLE_NAME}}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure CleanWintunDevices;
var
  ResultCode: Integer;
  PowerShellScript: String;
  TempScriptPath: String;
begin
  PowerShellScript := 
    '$ErrorActionPreference = ''SilentlyContinue'';' + #13#10 +
    'Write-Host "Cleaning old Wintun/Bettbox/LiClash network adapters...";' + #13#10 +
    '$adapters = Get-NetAdapter | Where-Object {' + #13#10 +
    '$_.InterfaceDescription -like "*Bettbox*" -or' + #13#10 +
    '  $_.Name -like "*Bettbox*"' + #13#10 +
    '};' + #13#10 +
    'if ($adapters) {' + #13#10 +
    '  foreach ($adapter in $adapters) {' + #13#10 +
    '    Write-Host "Removing adapter: $($adapter.Name) - $($adapter.InterfaceDescription)";' + #13#10 +
    '    try {' + #13#10 +
    '      $adapter | Disable-NetAdapter -Confirm:$false -ErrorAction Stop;' + #13#10 +
    '      Start-Sleep -Milliseconds 500;' + #13#10 +
    '      $adapter | Remove-NetAdapter -Confirm:$false -ErrorAction Stop;' + #13#10 +
    '      Write-Host "Successfully removed: $($adapter.Name)";' + #13#10 +
    '    } catch {' + #13#10 +
    '      Write-Host "Failed to remove $($adapter.Name): $_";' + #13#10 +
    '    }' + #13#10 +
    '  }' + #13#10 +
    '} else {' + #13#10 +
    '  Write-Host "No old adapters found.";' + #13#10 +
    '}' + #13#10 +
    'Write-Host "Cleanup completed.";';
  
  TempScriptPath := ExpandConstant('{tmp}\clean_wintun.ps1');
  SaveStringToFile(TempScriptPath, PowerShellScript, False);

  Exec('powershell.exe', 
    '-NoProfile -ExecutionPolicy Bypass -File "' + TempScriptPath + '"', 
    '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  
  DeleteFile(TempScriptPath);
end;

procedure RegisterHelperService;
var
  ResultCode: Integer;
  HelperPath: String;
  ServiceName: String;
begin
  ServiceName := '{{HELPER_SERVICE_NAME}}';
  HelperPath := ExpandConstant('{app}\{{HELPER_EXECUTABLE_NAME}}');
  
  Exec('sc', 'stop ' + ServiceName, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('sc', 'delete ' + ServiceName, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  
  Exec('sc', 'create ' + ServiceName + ' binPath= "' + HelperPath + '" start= auto', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  
  Exec('sc', 'start ' + ServiceName, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure UnregisterHelperService;
var
  ResultCode: Integer;
  ServiceName: String;
begin
  ServiceName := '{{HELPER_SERVICE_NAME}}';
  
  Exec('sc', 'stop ' + ServiceName, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('sc', 'delete ' + ServiceName, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure UnregisterTaskScheduler;
var
  ResultCode: Integer;
  TaskNames: TArrayOfString;
  i: Integer;
begin
  TaskNames := ['{{TASK_NAME}}'];
  
  for i := 0 to GetArrayLength(TaskNames)-1 do
  begin
    Exec('schtasks', '/Delete /TN ' + TaskNames[i] + ' /F', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

procedure CleanRegistry;
var
  RegistryKeys: TArrayOfString;
  i: Integer;
begin
  SetArrayLength(RegistryKeys, 2);
  RegistryKeys[0] := 'Software\com.appshub.bettbox';
  RegistryKeys[1] := 'Software\com.appshub\Bettbox';
  
  for i := 0 to GetArrayLength(RegistryKeys)-1 do
  begin
    RegDeleteKeyIncludingSubkeys(HKCU, RegistryKeys[i]);
  end;
end;

procedure CleanUserData;
var
  UserDataPaths: TArrayOfString;
  i: Integer;
  AppDataPath: String;
begin
  AppDataPath := ExpandConstant('{userappdata}');
  
  SetArrayLength(UserDataPaths, 2);
  UserDataPaths[0] := AppDataPath + '\com.appshub.bettbox';
  UserDataPaths[1] := AppDataPath + '\com.appshub\Bettbox';
  
  for i := 0 to GetArrayLength(UserDataPaths)-1 do
  begin
    if DirExists(UserDataPaths[i]) then
    begin
      DelTree(UserDataPaths[i], True, True, True);
    end;
  end;
  
  if DirExists(AppDataPath + '\com.appshub') then
  begin
    RemoveDir(AppDataPath + '\com.appshub');
  end;
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
end;

function InitializeUninstall(): Boolean;
var
  Response: Integer;
begin
  Response := MsgBox(CustomMessage('RemoveUserDataPrompt'), mbConfirmation, MB_YESNOCANCEL);
  
  if Response = IDCANCEL then
  begin
    Result := False;
  end
  else
  begin
    ShouldCleanUserData := (Response = IDYES);
    Result := True;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    { Let Inno Setup try CloseApplications first; force-kill any leftovers before files are copied. }
    ForceKillProcesses;
  end;

  if CurStep = ssPostInstall then
  begin
    RegisterHelperService;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    ForceKillProcesses;
    CleanWintunDevices;
  end;
  
  if CurUninstallStep = usPostUninstall then
  begin
    UnregisterHelperService;
    
    UnregisterTaskScheduler;
    
    if ShouldCleanUserData then
    begin
      CleanUserData;
      CleanRegistry;
    end;
  end;
end;

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
{% if LOCALES %}
{% for locale in LOCALES %}
{% if locale.lang == 'zh' %}
Name: "chineseSimplified"; MessagesFile: {% if locale.file %}{{ locale.file }}{% else %}"compiler:Languages\\ChineseSimplified.isl"{% endif %}
{% endif %}
{% endfor %}
{% endif %}

[CustomMessages]
english.RemoveUserDataPrompt=Do you want to remove all user data?%n%nThis will remove:%n• Configuration files%n• Profiles and subscriptions%n• Settings and preferences%n• Registry entries%n%nThis action cannot be undone.
{% if LOCALES %}
{% for locale in LOCALES %}
{% if locale.lang == 'zh' %}
chineseSimplified.RemoveUserDataPrompt=是否要删除所有用户数据？%n%n这将删除：%n• 配置文件%n• 代理配置与订阅%n• 设置和偏好%n• 注册表记录%n%n此操作无法撤销。
{% endif %}
{% endfor %}
{% endif %}

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if CREATE_DESKTOP_ICON != true %}unchecked{% else %}checkedonce{% endif %}
[Files]
Source: "{{SOURCE_DIR}}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"
Name: "{autodesktop}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"; Tasks: desktopicon
[Run]
Filename: "{app}\\{{EXECUTABLE_NAME}}"; Description: "{cm:LaunchProgram,{{DISPLAY_NAME}}}"; Flags: {% if PRIVILEGES_REQUIRED == 'admin' %}runascurrentuser{% endif %} nowait postinstall skipifsilent