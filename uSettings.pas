unit uSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, AccountSettings;

type
  TSettingsFrame = class(TFrame)
    btnSettings: TImage;
    Label1: TLabel;
    comboProjects: TComboBox;
    procedure btnSettingsClick(Sender: TObject);
  private
    FOnProjectChanged: TNotifyEvent;
    procedure UpdateProjectCombo;
    function GetActiveProject: TProjectSetting;
    procedure DoProjectChanged;
    procedure SetOnProjectChanged(const Value: TNotifyEvent);
    { Private declarations }
  protected
    procedure SetParent(AParent: TWinControl); override;

  public
    property ActiveProject: TProjectSetting read GetActiveProject;
    property OnProjectChanged: TNotifyEvent read FOnProjectChanged write SetOnProjectChanged;
    { Public declarations }
  end;

implementation

uses
  frmSettings;

{$R *.dfm}

procedure TSettingsFrame.btnSettingsClick(Sender: TObject);
begin
  TAccountSettingsForm.Open;
  UpdateProjectCombo;
end;

procedure TSettingsFrame.DoProjectChanged;
begin
  if Assigned(FOnProjectChanged) then
    FOnProjectChanged(ActiveProject);
end;

function TSettingsFrame.GetActiveProject: TProjectSetting;
begin
  if comboProjects.ItemIndex > -1 then
    Result := comboProjects.Items.Objects[comboProjects.ItemIndex] as TProjectSetting else
    Result := nil;
end;

procedure TSettingsFrame.SetOnProjectChanged(const Value: TNotifyEvent);
begin
  FOnProjectChanged := Value;
end;

procedure TSettingsFrame.SetParent(AParent: TWinControl);
begin
  inherited;
  if Assigned(Parent) then
    UpdateProjectCombo;
end;

procedure TSettingsFrame.UpdateProjectCombo;
var
  sProjectGuid: string;
  Project: TProjectSetting;
  I: Integer;
begin
  Project := ActiveProject;
  comboProjects.Items.BeginUpdate;
  try
    comboProjects.Items.Clear;
    for I := 0 to Settings.ProjectCount - 1 do
      comboProjects.Items.AddObject(Settings.Project[i].ProjectName, Settings.Project[i]);

  finally
    comboProjects.Items.EndUpdate;
  end;
  comboProjects.ItemIndex := comboProjects.Items.IndexOfObject(Project);
  if (comboProjects.ItemIndex = -1) and (comboProjects.Items.Count > 0) then
    comboProjects.ItemIndex := 0;


  DoProjectChanged;


end;

end.
