unit ETAComms;

interface

uses
  IdTCPClient, idComponent, IdHTTP, uLkJSON, Classes, AccountSettings;


type

  TETAClient = class
  private
    FTcp: TIdHTTP;
    FEmailAccount: string;
    FAuthorizationToken: string;
    FServer: string;
    FData: TStringList;
    FOnWorkBegin: TWorkBeginEvent;
    FOnWorkEnd: TWorkEndEvent;
    FOnWork: TWorkEvent;
    procedure SetAuthorizationToken(const Value: string);
    procedure SetEmailAccount(const Value: string);
    procedure SetServer(const Value: string);
    function HttpClient: TIdHttp;

    procedure DoWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure DoWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure DoWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);

  public
    constructor Create(aAccount, aToken: string);
    destructor destroy; override;
    function SanitizeUrl(aUrl: string): string;

    property AuthorizationToken: string read FAuthorizationToken write SetAuthorizationToken;
    property EmailAccount: string read FEmailAccount write SetEmailAccount;
    property Server: string read FServer write SetServer;


    class function New: TETAClient;
    function ProjectList: TlkJSONobject;
    function FileList(aProject: TProjectSetting; aFolder: string): string;
    function PushSingleFile(aProject: TProjectSetting; aLocalFileName: string; aServerName: string): boolean;
    function ProjectRoot(aProject: TProjectSetting): string;

    property OnWork: TWorkEvent read FOnWork write FOnWork;
    property OnWorkBegin: TWorkBeginEvent read FOnWorkBegin write FOnWorkBegin;
    property OnWorkEnd: TWorkEndEvent read FOnWorkEnd write FOnWorkEnd;

  end;
implementation

uses
  SysUtils, IdSSL, IdSSLOpenSSL;

{ TETAClient }

constructor TETAClient.Create(aAccount, aToken: string);
begin
  inherited create;
  AuthorizationToken := aToken;
  EmailAccount := aAccount;
  FData := TStringList.Create;
  FData.Add(' { name:"Default Object from client app" }  ');
  //Server := 'http://localhost:60775'; //'https://entertheapi.azurewebsites.net';
  Server := 'https://entertheapi.azurewebsites.net';
end;

destructor TETAClient.destroy;
begin
  FreeAndNil(FData);
  inherited;
end;

procedure TETAClient.DoWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  if Assigned(FOnWork) then
    FOnWork(ASender, aWorkMode, aWorkCount);
end;

procedure TETAClient.DoWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  if Assigned(FOnWorkBegin) then
    FOnWorkBegin(ASender, aWorkMode, AWorkCountMax);
end;

procedure TETAClient.DoWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  if Assigned(FOnWorkEnd) then
    FOnWorkEnd(ASender, aWorkMode);
end;

function TETAClient.FileList(aProject: TProjectSetting; aFolder: string): string;
var
  sWeb: string;
  sData: TStringStream;

begin
  aFolder := StringReplace(aFolder,'\','/',[rfReplaceAll]);
  if (aFolder <> '') and (aFolder[Length(aFolder)] <> '/') then
    aFolder := aFolder + '/';
    
  sWeb := ProjectRoot(aProject) + aFolder;
  with HttpClient do
  try
    Result := Get(SanitizeUrl(sWeb));
  finally
    Free;
  end;
end;

function TETAClient.HttpClient: TIdHttp;
var
  ssl: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := TIdHTTP.Create(nil);

  with result do
  begin
    if pos('https:', server) > 0 then
    begin
      ssl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      ssl.PassThrough := false;
      ssl.SSLOptions.Mode := sslmClient;
      ssl.SSLOptions.VerifyMode := [];
      ssl.SSLOptions.Method := sslvTLSv1_2;
      ManagedIOHandler := True;
      IOHandler := ssl;
    end;


    HTTPOptions := [];

    Request.CustomHeaders.FoldLines := False;
    Request.CustomHeaders.AddValue('userSessionAuth',AuthorizationToken);
    Request.CustomHeaders.AddValue('userAccount',EmailAccount);
    OnWorkBegin := Self.DoWorkBegin;
    OnWorkEnd := Self.DoWorkEnd;
    OnWork := Self.DoWork;

  end;
end;

class function TETAClient.New: TETAClient;
begin
  Result := TETAClient.Create(Settings.EmailAccount, Settings.AuthorizationToken);
end;

function TETAClient.ProjectList: TlkJSONobject;
var
  ss: TStringStream;
  fld: TlkJSONbase;
begin
  ss := TStringStream.Create('');
  with HttpClient do
  try
    Post(SanitizeUrl(Server + '/api/project/list'), FData,ss);
    Result := TLkJson.ParseText(ss.DataString) as TlkJSONobject;
    fld := Result.Field['Success'];
    if not (Assigned(fld) and SameText(fld.Value, 'true')) then
      FreeAndNil(Result);

  finally
    Free;
    FreeAndNil(ss);
  end;
end;

function TETAClient.ProjectRoot(aProject: TProjectSetting): string;
begin
  Result := Server + '/web/' + aProject.PublicName + '/';
end;

function TETAClient.PushSingleFile(aProject: TProjectSetting; aLocalFileName,
  aServerName: string): boolean;
var
  sWeb: string;
  FileStream: TFileStream;
begin
  aServerName := StringReplace(aServerName, '\', '/', [rfReplaceAll]);
  sWeb := ProjectRoot(aProject) + aServerName;
  FileStream := TFileStream.Create(aLocalFileName, fmOpenRead);
  try
    with HttpClient do
    try
      Put(SanitizeUrl(sWeb), FileStream);
    finally
      Free;
    end;
  finally
    FreeAndNil(FileStream);
  end;
end;

function TETAClient.SanitizeUrl(aUrl: string): string;
begin
  Result := StringReplace(aUrl, '\', '/', [rfReplaceAll]);
  Result := StringReplace(Result, '//', '/', [rfReplaceAll]);
  if pos('http', LowerCase(Result)) = 1 then
    Insert('/', Result, Pos(':', Result)+1);

end;

procedure TETAClient.SetAuthorizationToken(const Value: string);
begin
  FAuthorizationToken := Value;
end;

procedure TETAClient.SetEmailAccount(const Value: string);
begin
  FEmailAccount := Value;
end;

procedure TETAClient.SetServer(const Value: string);
begin
  FServer := Value;
end;

end.
