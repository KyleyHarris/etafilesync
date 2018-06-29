object AccountSettingsForm: TAccountSettingsForm
  Left = 0
  Top = 0
  Caption = 'Settings'
  ClientHeight = 403
  ClientWidth = 733
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 41
    Width = 733
    Height = 49
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 7
      Top = 6
      Width = 96
      Height = 13
      Caption = 'Authorization Token'
    end
    object mAuthorizationToken: TMemo
      Left = 109
      Top = 3
      Width = 524
      Height = 38
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 362
    Width = 733
    Height = 41
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      733
      41)
    object btnOK: TButton
      Left = 7
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnSync: TButton
      Left = 592
      Top = 6
      Width = 129
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Sync'
      TabOrder = 1
      OnClick = btnSyncClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 733
    Height = 41
    Align = alTop
    TabOrder = 2
    object Label2: TLabel
      Left = 7
      Top = 8
      Width = 66
      Height = 13
      Caption = 'Account Email'
    end
    object eAccountEmail: TEdit
      Left = 112
      Top = 8
      Width = 313
      Height = 21
      TabOrder = 0
    end
  end
  object ProjTab: TTabControl
    Left = 0
    Top = 90
    Width = 733
    Height = 23
    Align = alTop
    TabOrder = 3
    Tabs.Strings = (
      'One '
      'Two'
      'Thjree')
    TabIndex = 0
  end
  object Panel4: TPanel
    Left = 0
    Top = 113
    Width = 733
    Height = 249
    Align = alClient
    TabOrder = 4
    object Label3: TLabel
      Left = 8
      Top = 8
      Width = 64
      Height = 13
      Caption = 'Project Name'
    end
    object lblLocalFolder: TLabel
      Left = 8
      Top = 32
      Width = 55
      Height = 13
      Caption = 'Local folder'
    end
    object eProjectName: TEdit
      Left = 78
      Top = 6
      Width = 259
      Height = 21
      ReadOnly = True
      TabOrder = 0
      Text = 'eProjectName'
    end
    object eLocalFolder: TEdit
      Left = 78
      Top = 32
      Width = 481
      Height = 21
      TabOrder = 1
      OnChange = eLocalFolderChange
    end
  end
end
