object ETAFileManager: TETAFileManager
  Left = 0
  Top = 0
  Caption = 'Enter The API Web Project File Manager'
  ClientHeight = 377
  ClientWidth = 1060
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inline SettingsFrame1: TSettingsFrame
    Left = 0
    Top = 0
    Width = 1060
    Height = 38
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 1060
    inherited btnSettings: TImage
      Left = 1024
    end
  end
  inline ProjectFileSync1: TProjectFileSync
    Left = 0
    Top = 38
    Width = 1060
    Height = 339
    Align = alClient
    TabOrder = 1
    ExplicitTop = 38
    ExplicitWidth = 1060
    ExplicitHeight = 339
    inherited Splitter2: TSplitter
      Top = -614
      Width = 1060
      Height = 953
      ExplicitTop = -641
      ExplicitWidth = 1060
      ExplicitHeight = 953
    end
    inherited Panel1: TPanel
      Top = -742
      Width = 1060
      ExplicitTop = -742
      ExplicitWidth = 1060
      inherited StatusBar1: TStatusBar
        Width = 1058
        ExplicitLeft = 1
        ExplicitWidth = 1058
      end
      inherited lbUploadLog: TListBox
        Width = 1058
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 1058
        ExplicitHeight = 107
      end
    end
    inherited Panel2: TPanel
      Width = 1060
      Height = 184
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 1060
      ExplicitHeight = 184
      inherited Splitter1: TSplitter
        Height = 182
        ExplicitHeight = 182
      end
      inherited pLocalFiles: TPanel
        Height = 182
        ExplicitHeight = 182
        inherited Panel3: TPanel
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 470
        end
      end
      inherited Panel4: TPanel
        Width = 583
        Height = 182
        ExplicitLeft = 476
        ExplicitTop = 1
        ExplicitWidth = 583
        ExplicitHeight = 182
        inherited Panel5: TPanel
          Width = 581
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 581
        end
        inherited RemoteList: TListBox
          Width = 581
          Height = 139
          ExplicitLeft = 1
          ExplicitTop = 42
          ExplicitWidth = 581
          ExplicitHeight = 139
        end
      end
    end
  end
end
