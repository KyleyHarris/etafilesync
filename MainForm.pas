unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uSettings, uProjectFileSync;

type
  TETAFileManager = class(TForm)
    SettingsFrame1: TSettingsFrame;
    ProjectFileSync1: TProjectFileSync;
    procedure FormCreate(Sender: TObject);
  private
    procedure ProjectChangedCallback(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ETAFileManager: TETAFileManager;

implementation

uses
  AccountSettings;

{$R *.dfm}

procedure TETAFileManager.FormCreate(Sender: TObject);
begin
  SettingsFrame1.OnProjectChanged := ProjectChangedCallback;
  Settings.LoadSettingsFromFile;


  ProjectChangedCallback(nil);
end;

procedure TETAFileManager.ProjectChangedCallback(Sender: TObject);
begin
  ProjectFileSync1.ProjectSetting := SettingsFrame1.ActiveProject;
end;

end.
