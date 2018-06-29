unit AccountSettings;

interface

uses
  Contnrs;
type

  TProjectSetting = class
  private
    FLocalFolder: string;
    FProjectName: string;
    FProjectID: string;
    FPublicName: string;
    procedure SetLocalFolder(const Value: string);
    procedure SetProjectID(const Value: string);
    procedure SetProjectName(const Value: string);
    procedure SetPublicName(const Value: string);
  published
  public
    property ProjectName: string read FProjectName write SetProjectName;
    property ProjectID: string read FProjectID write SetProjectID; // GUID
    property LocalFolder: string read FLocalFolder write SetLocalFolder;
    property PublicName: string read FPublicName write SetPublicName;
  end;

  TAccountSettings = class
  private
    FProjects: TObjectList;
    FLocalStorageFileName: string;
    FEmailAccount: string;
    FAuthorizationToken: string;
    procedure SetAuthorizationToken(const Value: string);
    procedure SetEmailAccount(const Value: string);
    function GetProjectCount: Cardinal;
    function GetProject(aIndex: Cardinal): TProjectSetting;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadSettingsFromFile;
    procedure SaveSettingstoFile;
    function AddProject: TProjectSetting;
    function AddProjectIfMissing(const aProjectName, aProjectID, aPublicName: string): TProjectSetting;
    procedure DeleteProject(aProject: TProjectSetting);
    property AuthorizationToken: string read FAuthorizationToken write SetAuthorizationToken;
    property EmailAccount: string read FEmailAccount write SetEmailAccount;
    property ProjectCount: Cardinal read GetProjectCount;
    property Project[aIndex: Cardinal]:TProjectSetting read GetProject;
  end;


var
  Settings: TAccountSettings;
implementation

uses
  IniFiles, SysUtils, Classes;

{ TAccountSettings }

function TAccountSettings.AddProject: TProjectSetting;
begin
  Result := TProjectSetting.Create;
  FProjects.Add(Result);
end;

function TAccountSettings.AddProjectIfMissing(const aProjectName,
  aProjectID, aPublicName: string): TProjectSetting;
var
  I: Integer;
begin
  for I := 0 to FProjects.Count - 1 do
    if SameText(aProjectID, Project[i].ProjectID) then
    begin
      Project[i].ProjectName := aProjectName;
    end;

  Result := AddProject;
  Result.ProjectName := aProjectName;
  Result.ProjectID := aProjectID;
  Result.PublicName := aPublicName;  
end;

constructor TAccountSettings.Create;
begin
  FProjects := TObjectList.Create(True);
  FLocalStorageFileName := ExtractFilePath(ParamStr(0)) + 'AccountSettings.ini';
  if FileExists(FLocalStorageFileName) then
    LoadSettingsFromFile;

end;

procedure TAccountSettings.DeleteProject(aProject: TProjectSetting);
begin
  FProjects.Remove(aProject);  
end;

destructor TAccountSettings.Destroy;
begin
  FreeAndNil(FProjects);
  inherited;
end;

function TAccountSettings.GetProject(aIndex: Cardinal): TProjectSetting;
begin
  Result := FProjects[aIndex] as TProjectSetting;
end;

function TAccountSettings.GetProjectCount: Cardinal;
begin
  Result := FProjects.Count;
end;

procedure TAccountSettings.LoadSettingsFromFile;
var
  localFile: TIniFile;
  i,iProjectCount: Integer;
  sProj: string;
  Proj: TProjectSetting;
const
  MAIN = 'MAIN';
begin
  localFile := TIniFile.Create(FLocalStorageFileName);
  try
    EmailAccount := localFile.ReadString(MAIN, 'EmailAccount','');
    AuthorizationToken := localFile.ReadString(MAIN, 'AuthorizationToken','');
    iProjectCount := localFile.ReadInteger(MAIN,'ProjectCount',0);
    for i := 0 to iProjectCount-1 do
    begin
      sProj := 'PROJ_'+IntToStr(i);
      Proj := AddProject;
      Proj.ProjectName := localFile.ReadString(sProj, 'ProjectName','');
      Proj.ProjectID := localFile.ReadString(sProj, 'ProjectID','');
      Proj.LocalFolder := localFile.ReadString(sProj, 'LocalFolder','');
      Proj.PublicName := localFile.ReadString(sProj, 'PublicName','');
    end;
  finally
    FreeAndNil(localFile);
  end;

end;

procedure TAccountSettings.SaveSettingstoFile;
var
  localFile: TIniFile;
  i,iProjectCount: Integer;
  sProj: string;
  Proj: TProjectSetting;
const
  MAIN = 'MAIN';
begin
  localFile := TIniFile.Create(FLocalStorageFileName);
  try

    localFile.WriteString(MAIN, 'EmailAccount',EmailAccount);
    localFile.WriteString(MAIN, 'AuthorizationToken',AuthorizationToken);
    localFile.WriteInteger(MAIN,'ProjectCount',FProjects.Count);
    for i := 0 to FProjects.Count -1 do
    begin
      sProj := 'PROJ_'+IntToStr(i);
      Proj := Project[i];
      localFile.WriteString(sProj, 'ProjectName', Proj.ProjectName);
      localFile.WriteString(sProj, 'ProjectID',Proj.ProjectID);
      localFile.WriteString(sProj, 'LocalFolder',Proj.LocalFolder);
      localFile.WriteString(sProj, 'PublicName',Proj.PublicName);
    end;
    localFile.UpdateFile;
  finally
    FreeAndNil(localFile);
  end;

end;

procedure TAccountSettings.SetAuthorizationToken(const Value: string);
begin
  FAuthorizationToken := Value;
end;

procedure TAccountSettings.SetEmailAccount(const Value: string);
begin
  FEmailAccount := Value;
end;

{ TProjectSetting }

procedure TProjectSetting.SetLocalFolder(const Value: string);
begin
  FLocalFolder := Value;
end;

procedure TProjectSetting.SetProjectID(const Value: string);
begin
  FProjectID := Value;
end;

procedure TProjectSetting.SetProjectName(const Value: string);
begin
  FProjectName := Value;
end;

procedure TProjectSetting.SetPublicName(const Value: string);
begin
  FPublicName := Value;
end;

initialization
  Settings := TAccountSettings.Create;
finalization
  FreeAndNil(Settings);
end.
