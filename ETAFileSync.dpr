program ETAFileSync;

uses
  Forms,
  MainForm in 'MainForm.pas' {ETAFileManager},
  uSettings in 'uSettings.pas' {SettingsFrame: TFrame},
  frmSettings in 'frmSettings.pas' {AccountSettingsForm},
  AccountSettings in 'Data\AccountSettings.pas',
  ETAComms in 'ETAComms.pas',
  uProjectFileSync in 'uProjectFileSync.pas' {ProjectFileSync: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TETAFileManager, ETAFileManager);
  Application.Run;
end.
