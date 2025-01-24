;Inno Setup Script
;#define MyAppVersion "$env:VERSION"

#define MyAppName "TRTOrderManager"
#define MyAppPublisher "trttech.ca"
#define MyAppURL "https://trttech.ca"
#define IconPath = "{%GITHUB_WORKSPACE|D:\a\trt-order-manager-app\trt-order-manager-app\}\assets\icon\icon.ico"
#define BundleDirectory = "{%GITHUB_WORKSPACE|D:\a\trt-order-manager-app\trt-order-manager-app\}\.inno-bundle\"

;the flutter executable exe name
#define MyAppExeName "pdf_printer.exe"

[Setup]
SetupIconFile={#IconPath}
AppName={#MyAppName}
AppVersion=1.0.0
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
DefaultDirName={autopf}\trtordermanager
DisableProgramGroupPage=yes
OutputDir=build\installer
OutputBaseFilename=TrtInstaller
PrivilegesRequired=lowest
Compression=lzma
SolidCompression=yes
WizardStyle=modern
LanguageDetectionMethod=uilanguage

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs;
Source: "{#BundleDirectory}\*"; DestDir: "{tmp}"; Flags: nocompression createallsubdirs recursesubdirs deleteafterinstall
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\VC_redist.x86.exe"; Parameters: "/Q"; Flags: waituntilterminated skipifdoesntexist; StatusMsg: "Installing Microsoft Visual C++ (x86) ..."
Filename: "{tmp}\VC_redist.x64.exe"; Parameters: "/Q"; Flags: waituntilterminated skipifdoesntexist; StatusMsg: "Installing Microsoft Visual C++ (x64) ..."; Check: IsWin64
Filename: "{tmp}\XPrinter_Driver_Setup_V8.2"; Parameters: "/SILENT"; Flags: waituntilterminated skipifdoesntexist; StatusMsg: "Installing Xprinter Driver Setup V8.2 ..."
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent