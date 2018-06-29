unit uProjectFileSync;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AccountSettings, ExtCtrls, ComCtrls, FileCtrl, StdCtrls, ActnList, Menus, idComponent;

type

  TFileTransferThread = class(TThread)
  private
    procedure UploadSingleFile(aFilePath, aServerFolder: string);
    procedure UploadFolder(aFolder, aServerFolder: string);
    procedure ProcessFileName(aFileName, aServerPath: string);
    procedure ProcessFiles(Files: TStrings; aServerFolder: string);

  protected
    FProjectSetting: TProjectSetting;
    FActiveFile: string;
    FActivePercentage: Integer;
    FActiveCount: Int64;
    FActiveMax: Int64;
    FOwner: TFrame;

    FExpandedFileList: TStringList;
    FFileList: TStringList;
    FServerPath: string;
    FLocalMessage: string;
    procedure Execute; override;
    procedure UpdateOwner;
    procedure AddLocalMessageToOwner;
    procedure Log(aMessage: string);


    procedure DoWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure DoWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure DoWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);


  public
    constructor Create(aFileList: TStrings; aServerPath: string; aOwner: TFrame);
    destructor Destroy; override;

  end;

  TFileSyncListBox = class(TFileListBox)
  private
    FOnDirectoryChanged: TNotifyEvent;
    FRootPath: string;
    procedure SetOnDirectoryChanged(const Value: TNotifyEvent);
    procedure SetRootPath(const Value: string);
  protected
    procedure ReadFileNames; override;

  public
    procedure ApplyFilePath (const EditText: string); override;
    property RootPath: string read FRootPath write SetRootPath;
    property OnDirectoryChanged: TNotifyEvent read FOnDirectoryChanged write SetOnDirectoryChanged;
  end;

  TProjectFileSync = class(TFrame)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    pLocalFiles: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lServerPath: TStaticText;
    lLocalPath: TStaticText;
    RemoteList: TListBox;
    lLocalRoot: TLabel;
    lServerRoot: TLabel;
    PopupMenu1: TPopupMenu;
    ActionList1: TActionList;
    actPush: TAction;
    Push1: TMenuItem;
    StatusBar1: TStatusBar;
    lbUploadLog: TListBox;
    actCancel: TAction;
    Button1: TButton;
    Splitter2: TSplitter;
    procedure actPushExecute(Sender: TObject);
    procedure actPushUpdate(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
    procedure actCancelUpdate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
    FUploadThread: TFileTransferThread;
    FProjectSetting: TProjectSetting;
    FFileListBox: TFileSyncListBox;
    FCurrentPercentage: Integer;
    FCurrentFile: string;
    procedure DoTerminated(Sender: TObject);

    function ActiveFileCopyPercentage: Integer;
    procedure PushFileToServer(aFilePath, aServerFolder: string);
    procedure PushFilesToServer(aFilePaths: TStrings; aServerFolder: string);
    procedure RebuildLocalFolder(aFolder: string = '');
    procedure RebuildServerFolder;
    procedure Updateall;
    procedure SetProjectSetting(const Value: TProjectSetting);
    procedure DirectoryChangedCallback(Sender: TObject);
    procedure DoDoubleClickLocalFolder(Sender: TObject);
    function GetRootLocalFolder: string;
    function GetRelativeLocalFolder: string;
    function IsFolder(aPath: string): Boolean;
    function FolderPath(aPath: string): string;
    { Private declarations }
    property RootLocalFolder: string read GetRootLocalFolder;
    property RelativeLocalFolder: string read GetRelativeLocalFolder;
  public
    constructor Create(AOwner: TComponent); override;
    property ProjectSetting: TProjectSetting read FProjectSetting write SetProjectSetting;
  end;

implementation

uses
  ETAComms;

{$R *.dfm}

{ TProjectFileSync }

procedure TProjectFileSync.actCancelExecute(Sender: TObject);
begin
  FUploadThread.Terminate;
end;

procedure TProjectFileSync.actCancelUpdate(Sender: TObject);
begin
  actCancel.Enabled := Assigned(FUploadThread);
end;

function TProjectFileSync.ActiveFileCopyPercentage: Integer;
begin
  Result := FCurrentPercentage;
end;

procedure TProjectFileSync.actPushExecute(Sender: TObject);
var
  sFilePath: string;
  i: Integer;
  sFiles: TStringList;
begin
  lbUploadLog.Clear;
  sFiles := TStringList.Create;
  try
    for i := 0 to FFileListBox.Items.Count - 1 do
    begin
      if FFileListBox.Selected[i] then
      begin
        sFilePath := FFileListBox.Items[i];
        if isFolder(sFilePath) then
          sFilePath := FolderPath(sFilePath) else
          sFilePath := FFileListBox.Directory + '\' + sFilePath;
        sFiles.Add(sFilePath);
      end;
    end;
    if sFiles.Count > 0 then
    begin
      PushFilesToServer(sFiles, lServerPath.Caption);
    end;
  finally
    FreeAndNil(sFiles);
  end;

end;

procedure TProjectFileSync.actPushUpdate(Sender: TObject);
begin
  actPush.Enabled := (FFileListBox.ItemIndex <> -1) and
    (FFileListBox.Items[FFileListBox.ItemIndex] <> '[..]')
end;

constructor TProjectFileSync.Create(AOwner: TComponent);
begin
  inherited;
  FCurrentPercentage := 50;
  FFileListBox := TFileSyncListBox.Create(self);
  FFileListBox.OnDirectoryChanged := DirectoryChangedCallback;
  FFileListBox.Parent := pLocalFiles;
  FFileListBox.FileType := [ftNormal, ftDirectory];
  FFileListBox.ShowGlyphs := true;
  FFileListBox.Align := alClient;
  FFileListBox.OnDblClick := DoDoubleClickLocalFolder;
  FFileListBox.PopupMenu := PopupMenu1;
  FFileListBox.MultiSelect := True;

  
end;

procedure TProjectFileSync.DirectoryChangedCallback(Sender: TObject);
begin
  lLocalPath.Caption := RelativeLocalFolder;

  RebuildServerFolder;
end;


function TProjectFileSync.IsFolder(aPath: string):Boolean;
begin
  Result := (aPath[1] = '[') and (aPath[Length(aPath)] = ']');
end;

procedure TProjectFileSync.PushFilesToServer(aFilePaths: TStrings; aServerFolder: string);
begin
  FUploadThread := TFileTransferThread.Create(aFilePaths, aServerFolder, Self);
  FUploadThread.OnTerminate := DoTerminated;
  FUploadThread.Resume;
end;

procedure TProjectFileSync.PushFileToServer(aFilePath, aServerFolder: string);
begin
  if not FileExists(aFilePath) then
    Exit;
  with TETAClient.New do
  try
    PushSingleFile(FProjectSetting,aFilePath,aServerFolder + '\' + ExtractFileName(aFilePath));
  finally
    Free;
  end;
  RebuildServerFolder;
end;

procedure TProjectFileSync.DoDoubleClickLocalFolder(Sender: TObject);
var
  sFilePath: string;

begin
  if FFileListBox.ItemIndex >= 0 then
  begin
    sFilePath := FFileListBox.Items[FFileListBox.ItemIndex];
    if isFolder(sFilePath) then
      RebuildLocalFolder(FolderPath(sFilePath));
  end;

end;


procedure TProjectFileSync.DoTerminated(Sender: TObject);
begin
  FUploadThread := nil;
  FCurrentPercentage := 0;
  FCurrentFile := '';
  StatusBar1.Panels[2].Text := '';
end;

function TProjectFileSync.FolderPath(aPath: string): string;
begin
  aPath := Copy(aPath, 2, Length(aPath) - 2);
  Result := ExpandFileName(aPath);
end;

function TProjectFileSync.GetRelativeLocalFolder: string;
begin
  Result := FFileListBox.Directory;
  Delete(Result,1,length(RootLocalFolder)+1);
end;

function TProjectFileSync.GetRootLocalFolder: string;
begin
  Result := ProjectSetting.LocalFolder;
end;

procedure TProjectFileSync.RebuildLocalFolder(aFolder: string = '');
begin
  lLocalRoot.Caption := ProjectSetting.LocalFolder;
  if aFolder = '' then
    aFolder := ProjectSetting.LocalFolder;
  FFileListBox.ApplyFilePath(aFolder);
end;

procedure TProjectFileSync.RebuildServerFolder;
begin
  RemoteList.Items.BeginUpdate;
  try
    RemoteList.Items.Clear;
    with TETAClient.New do
    try
      RemoteList.Items.Text := FileList(ProjectSetting, RelativeLocalFolder);
      RemoteList.Items.Delete(0);
      lServerPath.Caption := RelativeLocalFolder;
      lServerRoot.Caption := ProjectRoot(ProjectSetting);
    finally
      Free;
    end;
  finally
    RemoteList.Items.EndUpdate;
  end;
end;

procedure TProjectFileSync.SetProjectSetting(const Value: TProjectSetting);
begin
  FProjectSetting := Value;
  if Assigned(FProjectSetting) then
  begin
    FFileListBox.RootPath := ProjectSetting.LocalFolder;
    UpdateAll;
  end;
end;

procedure TProjectFileSync.StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
var
  varRect: TRect;
  OnePercent: Double;
begin
  if Panel.Index = 1 then
  begin
    with StatusBar.Canvas do
    begin
      Brush.Color := clBlue;
      varRect := Rect;
      OnePercent := (Rect.Right - Rect.Left) / 100;
      varRect.Right := varRect.Left + Round(OnePercent * ActiveFileCopyPercentage);
       InflateRect(varRect,-1,-1);
      FillRect(varRect);
    end;
  end;
end;

procedure TProjectFileSync.Updateall;
begin
  RebuildLocalFolder;
  RebuildServerFolder;
end;

{ TFileSyncListBox }

procedure TFileSyncListBox.ApplyFilePath(const EditText: string);
begin
  inherited;
  if Assigned(FOnDirectoryChanged) then
    FOnDirectoryChanged(Self);
end;

procedure TFileSyncListBox.ReadFileNames;
var
  i: Integer;
begin
  Items.BeginUpdate;
  try
    inherited;
    for i := Items.Count - 1 downto 0 do
    begin
      if Items[i] = '[.]' then
        Items.Delete(i) else
      if (Items[i] = '[..]') and SameText(Directory, RootPath) then
        Items.Delete(i);
    end
  finally
    Items.EndUpdate;
  end;

end;

procedure TFileSyncListBox.SetOnDirectoryChanged(const Value: TNotifyEvent);
begin
  FOnDirectoryChanged := Value;
end;

procedure TFileSyncListBox.SetRootPath(const Value: string);
begin
  FRootPath := Value;
end;

{ TFileTransferThread }

procedure TFileTransferThread.AddLocalMessageToOwner;
begin
  with FOwner as TProjectFileSync do
    lbUploadLog.Items.Insert(0, FLocalMessage);
end;

constructor TFileTransferThread.Create(aFileList: TStrings; aServerPath: string; aOwner: TFrame);
begin
  FProjectSetting := TProjectSetting.Create;
  FOwner := aOwner;
  with FOwner as TProjectFileSync do
  begin
    Self.FProjectSetting.ProjectName := ProjectSetting.ProjectName;
    Self.FProjectSetting.ProjectID := ProjectSetting.ProjectID;
    Self.FProjectSetting.LocalFolder := ProjectSetting.LocalFolder;
    Self.FProjectSetting.PublicName := ProjectSetting.PublicName;
  end;
  FFileList := TStringList.Create;
  FServerPath := aServerPath;
  FFileList.Assign(aFileList);
  FExpandedFileList := TStringList.Create;
  FreeOnTerminate := True;
  inherited Create(True);
end;

destructor TFileTransferThread.Destroy;
begin
  FreeAndNil(FProjectSetting);
  FreeAndNil(FFileList);
  FreeAndNil(FExpandedFileList);
  inherited;
end;

procedure TFileTransferThread.DoWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
var
  iPerc: Integer;
begin
  FActiveCount := AWorkCount;
  iPerc := Round((FActiveCount/FActiveMax)*100);
  if iPerc-FActivePercentage > 5 then
  begin
    FActivePercentage := iPerc;
    Synchronize(UpdateOwner);
  end;
end;

procedure TFileTransferThread.DoWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  FActiveMax := AWorkCountMax;
  FActivePercentage := 0;
  Synchronize(UpdateOwner);
end;

procedure TFileTransferThread.DoWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  FActiveMax := 0;
  FActivePercentage := 100;
  Synchronize(UpdateOwner);
end;

procedure TFileTransferThread.UploadSingleFile(aFilePath: string; aServerFolder: string);
begin
  try
    with TETAClient.New do
    try
      OnWork := DoWork;
      OnWorkBegin := DoWorkBegin;
      OnWorkEnd := DoWorkEnd;
      FActiveFile := aFilePath;
      Synchronize(UpdateOwner);
      Log('PUSH FILE ->  '+aFilePath + ' TO '+ aServerFolder + '\' + ExtractFileName(aFilePath));
      PushSingleFile(FProjectSetting,aFilePath,aServerFolder + '\' + ExtractFileName(aFilePath));
    finally
      Free;
    end;
  except
    on E: Exception do
    begin
      Log('ERROR '+E.ClassName+' '+E.Message);
    end;
  end;
end;


procedure TFileTransferThread.UploadFolder(aFolder: string; aServerFolder: string);
var
  Files: TStringList;
  SearchRec: TSearchRec;
begin
  Log('PUSH FOLDER ->   ' + aFolder + ' TO ' + aServerFolder);
  if Terminated then
    Exit;

  Files := TStringList.Create;
  try

    if FindFirst(aFolder+'\*.*', faDirectory, SearchRec) = 0 then
    try
      repeat
        if (SearchRec.Name = '.') or (SearchRec.Name = '..') then
          Continue;
        Files.Add(aFolder + '\' + SearchRec.Name);
      until (FindNext(SearchRec) <> 0) or Terminated;
    finally
      FindClose(SearchRec);
    end;

    ProcessFiles(Files, aServerFolder);

  finally
    FreeAndNil(Files);
  end;
end;

procedure TFileTransferThread.ProcessFileName(aFileName: string; aServerPath: string);
begin
  if FileExists(aFileName) then
  begin
    UploadSingleFile(aFileName, aServerPath);
  end else
  if DirectoryExists(aFileName) then
  begin
    UploadFolder(aFileName, aServerPath + '\' + ExtractFileName(aFileName));
  end;
end;

procedure TFileTransferThread.ProcessFiles(Files: TStrings; aServerFolder: string);
var
  i: Integer;
begin
  for i := 0 to Files.Count - 1 do
  begin
    if Terminated then
      Exit;
    ProcessFileName(Files[i], aServerFolder);
  end;
end;

procedure TFileTransferThread.Execute;
begin
  ProcessFiles(FFileList, FServerPath);
  if Terminated then
    Log('PUSH Terminated');
    
end;

procedure TFileTransferThread.Log(aMessage: string);
begin
  FLocalMessage := aMessage;
  Synchronize(AddLocalMessageToOwner);
end;

procedure TFileTransferThread.UpdateOwner;
begin
  with FOwner as TProjectFileSync do
  begin
    StatusBar1.Panels[0].Text := 'Cancel';
    StatusBar1.Panels[2].Text := FActiveFile;
    if FActiveFile <> '' then
      StatusBar1.Panels[1].Text := 'Uploading '+IntToStr(FActivePercentage)+'%' else
      StatusBar1.Panels[1].Text := '';
  end;
end;

end.
