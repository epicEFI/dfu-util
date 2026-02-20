#define AppName "epicEFI Software Bundle"
#define AppVersion "1.0"
#define Publisher "epicEFI"
#define AppURL "https://epicefi.com"

//#define TSURL "http://localhost:8888"
#define TSURL "https://www.tunerstudio.com/downloads2"
#define TSVersion "3.3.01"

[Setup]
AppId={{778C337C-26B1-4E2C-9FA9-C58ACBB30C6B}
AppName={#AppName}
AppVersion={#AppVersion}
;AppVerName={#AppName} {#AppVersion}
AppPublisher={#Publisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
; Uncomment the following line to run in non administrative install mode (install for current user only).
;PrivilegesRequired=lowest
OutputDir=C:\Users\Ognjen Galic\Documents\Projects\epicEFI
OutputBaseFilename=epicefi
SolidCompression=yes
WizardStyle=modern zircon
LicenseFile=ts_license.txt
WizardImageFile=bg.png
DisableWelcomePage=no

[Messages]
WelcomeLabel2=This will install TunerStudio, the ST USB Drivers and the epicEFI TunerStudio Plugin on your computer.%n%nIt is recommended that you close TunerStudio (if already installed), the epicEFI Console and all other applications before continuing.

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#TSURL}/TunerStudioMS_Setup_v{#TSVersion}.exe"; \
    DestDir: "{tmp}"; DestName: "TunerStudio.exe"; ExternalSize: "87031808"; Flags: ignoreversion external download
    
Source: "Drivers\*"; DestDir: "{app}\Drivers"; Flags: ignoreversion recursesubdirs
    
Source: epic_tuner_plugin.jar; DestDir: {%USERPROFILE}\.efiAnalytics\TunerStudio\plugins\; Flags: 
Source: license2.txt; Flags: dontcopy

[Icons]
Name: "{group}\{cm:ProgramOnTheWeb,{#AppName}}"; Filename: "{#AppURL}"

[Run]
Filename: "{tmp}\TunerStudio.exe"; StatusMsg: "Installing TunerStudio"; \
    Parameters: "/VERYSILENT";
    
Filename: "{app}\Drivers\DFU_Driver\dpinst_amd64.exe"; StatusMsg: "Installing DFU Driver";
Filename: "{app}\Drivers\STLink\dpinst_amd64.exe"; StatusMsg: "Installing STLink V2/V3 Driver";
Filename: "{app}\Drivers\VCP\dpinst_amd64.exe"; StatusMsg: "Installing ST VCP Driver";


[Code]

var
  LicenseAcceptedRadioButtons: array of TRadioButton;

procedure CheckLicenseAccepted(Sender: TObject);
begin
  // Update Next button when user (un)accepts the license
  WizardForm.NextButton.Enabled :=
    LicenseAcceptedRadioButtons[TComponent(Sender).Tag].Checked;
end;

procedure LicensePageActivate(Sender: TWizardPage);
begin
  // Update Next button when user gets to second license page
  CheckLicenseAccepted(LicenseAcceptedRadioButtons[Sender.Tag]);
end;

function CloneLicenseRadioButton(
  Page: TWizardPage; Source: TRadioButton): TRadioButton;
begin
  Result := TRadioButton.Create(WizardForm);
  Result.Parent := Page.Surface;
  Result.Caption := Source.Caption;
  Result.Left := Source.Left;
  Result.Top := Source.Top;
  Result.Width := Source.Width;
  Result.Height := Source.Height;
  // Needed for WizardStyle=modern / WizardResizable=yes
  Result.Anchors := Source.Anchors;
  Result.OnClick := @CheckLicenseAccepted;
  Result.Tag := Page.Tag;
end;

var
  LicenseAfterPage: Integer;

procedure AddLicensePage(LicenseFileName: string);
var
  Idx: Integer;
  Page: TOutputMsgMemoWizardPage;
  LicenseFilePath: string;
  RadioButton: TRadioButton;
begin
  Idx := GetArrayLength(LicenseAcceptedRadioButtons);
  SetArrayLength(LicenseAcceptedRadioButtons, Idx + 1);

  Page :=
    CreateOutputMsgMemoPage(
      LicenseAfterPage, SetupMessage(msgWizardLicense),
      SetupMessage(msgLicenseLabel), SetupMessage(msgLicenseLabel3), '');
  Page.Tag := Idx;

  Page.RichEditViewer.Height := WizardForm.LicenseMemo.Height;
  Page.OnActivate := @LicensePageActivate;

  ExtractTemporaryFile(LicenseFileName);
  LicenseFilePath := ExpandConstant('{tmp}\' + LicenseFileName);
  Page.RichEditViewer.Lines.LoadFromFile(LicenseFilePath);
  DeleteFile(LicenseFilePath);

  RadioButton :=
    CloneLicenseRadioButton(Page, WizardForm.LicenseAcceptedRadio);
  LicenseAcceptedRadioButtons[Idx] := RadioButton;

  RadioButton :=
    CloneLicenseRadioButton(Page, WizardForm.LicenseNotAcceptedRadio);
  RadioButton.Checked := True;

  LicenseAfterPage := Page.ID;
end;

procedure InitializeWizard();
begin
  LicenseAfterPage := wpLicense;
  AddLicensePage('license2.txt');
end;