unit frmSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, AccountSettings;

type
  TAccountSettingsForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    mAuthorizationToken: TMemo;
    Panel2: TPanel;
    btnOK: TButton;
    Panel3: TPanel;
    Label2: TLabel;
    eAccountEmail: TEdit;
    ProjTab: TTabControl;
    Panel4: TPanel;
    Label3: TLabel;
    eProjectName: TEdit;
    lblLocalFolder: TLabel;
    eLocalFolder: TEdit;
    btnSync: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnSyncClick(Sender: TObject);
    procedure eLocalFolderChange(Sender: TObject);
  private
    procedure SaveSettings;
    procedure LoadSettings;
    procedure SyncProjectDisplay;
    procedure UpdateActiveProjectDisplay;
    function ActiveProject: TProjectSetting;
    { Private declarations }
  public

    class procedure Open;
  end;

var
  AccountSettingsForm: TAccountSettingsForm;

implementation

uses
  ETAComms, uLkJSON;

{$R *.dfm}


function TAccountSettingsForm.ActiveProject: TProjectSetting;
begin
  if ProjTab.TabIndex >= 0 then
    Result := ProjTab.Tabs.Objects[ProjTab.TabIndex] as TProjectSetting else
    Result := nil;
end;

procedure TAccountSettingsForm.btnOKClick(Sender: TObject);
begin
  SaveSettings;
  ModalResult := mrOk;
end;

procedure TAccountSettingsForm.btnSyncClick(Sender: TObject);
var
  Data: TlkJSONlist;
  Projects, Project: TlkJSONobject;
  i: Integer;

begin
  with TETAClient.Create(Settings.EmailAccount, Settings.AuthorizationToken) do
  try
    Projects := ProjectList;
    if Assigned(Projects) then
    begin
      try
        Data := Projects.Field['Data'] as TlkJSONList;

        for i := 0 to Data.Count - 1 do
        begin
          Project := Data.Child[i] as TlkJSONobject;
          Settings.AddProjectIfMissing(Project.Field['Name'].Value, Project.Field['Id'].Value, Project.Field['PublicName'].Value )
        end;

      finally
        FreeAndNil(Projects);
      end;
      Settings.SaveSettingstoFile;
      SyncProjectDisplay;
    end else
      ShowMessage('Sync Failed');

  finally
    Free;
  end;
end;

procedure TAccountSettingsForm.eLocalFolderChange(Sender: TObject);
var
  Project: TProjectSetting;
begin
  Project := ActiveProject;
  if Assigned(Project) then
    Project.LocalFolder := eLocalFolder.Text;
end;

procedure TAccountSettingsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TAccountSettingsForm.FormCreate(Sender: TObject);
begin
  LoadSettings;
end;

procedure TAccountSettingsForm.LoadSettings;
begin
  mAuthorizationToken.Lines.Text := Settings.AuthorizationToken;
  eAccountEmail.Text := Settings.EmailAccount;
  SyncProjectDisplay;
end;

class procedure TAccountSettingsForm.Open;
begin
  TAccountSettingsForm.Create(Application.MainForm).ShowModal;
end;

procedure TAccountSettingsForm.SaveSettings;
begin
  Settings.EmailAccount := eAccountEmail.Text;
  Settings.AuthorizationToken := mAuthorizationToken.Lines.Text;
  Settings.SaveSettingsToFile;
end;

procedure TAccountSettingsForm.SyncProjectDisplay;
var
  I: Integer;
begin
  ProjTab.Tabs.BeginUpdate;
  try
    ProjTab.Tabs.Clear;
    for I := 0 to Settings.ProjectCount - 1 do
      ProjTab.Tabs.AddObject(Settings.Project[i].ProjectName, Settings.Project[i]);
  finally
    ProjTab.Tabs.EndUpdate;
  end;
  ProjTab.TabIndex := 0;
  UpdateActiveProjectDisplay;
end;

procedure TAccountSettingsForm.UpdateActiveProjectDisplay;
var
  Project: TProjectSetting;
begin
  Project := ActiveProject; 
  if Assigned(Project) then
  begin
    eProjectName.Text := Project.ProjectName;
    eLocalFolder.Text := Project.LocalFolder;
  end else
  begin
    eProjectName.Text := '';
    eLocalFolder.Text := '';
  end;

end;

end.
