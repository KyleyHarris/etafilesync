object ProjectFileSync: TProjectFileSync
  Left = 0
  Top = 0
  Width = 953
  Height = 400
  TabOrder = 0
  object Splitter2: TSplitter
    Left = 0
    Top = 269
    Width = 953
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 0
    ExplicitWidth = 272
  end
  object Panel1: TPanel
    Left = 0
    Top = 272
    Width = 953
    Height = 128
    Align = alBottom
    TabOrder = 0
    object StatusBar1: TStatusBar
      Left = 1
      Top = 108
      Width = 951
      Height = 19
      Panels = <
        item
          Alignment = taCenter
          Width = 100
        end
        item
          Width = 200
        end
        item
          Text = 'Progress File'
          Width = 50
        end>
    end
    object lbUploadLog: TListBox
      Left = 1
      Top = 1
      Width = 951
      Height = 107
      Align = alClient
      ItemHeight = 13
      TabOrder = 1
    end
    object Button1: TButton
      Left = 5
      Top = 112
      Width = 92
      Height = 14
      Action = actCancel
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 92
    Top = 0
    Width = 861
    Height = 269
    Align = alClient
    Caption = 'Panel2'
    TabOrder = 1
    ExplicitLeft = 0
    ExplicitWidth = 953
    object Splitter1: TSplitter
      Left = 473
      Top = 1
      Height = 267
      ExplicitLeft = 616
      ExplicitTop = 256
      ExplicitHeight = 100
    end
    object pLocalFiles: TPanel
      Left = 1
      Top = 1
      Width = 472
      Height = 267
      Align = alLeft
      Caption = 'pLocalFiles'
      TabOrder = 0
      object Panel3: TPanel
        Left = 1
        Top = 1
        Width = 470
        Height = 41
        Align = alTop
        TabOrder = 0
        object Label1: TLabel
          Left = 8
          Top = 4
          Width = 57
          Height = 13
          Caption = 'Local Folder'
        end
        object lLocalRoot: TLabel
          Left = 88
          Top = 4
          Width = 49
          Height = 13
          Caption = 'lLocalRoot'
        end
        object lLocalPath: TStaticText
          Left = 7
          Top = 20
          Width = 458
          Height = 17
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'StaticText1'
          TabOrder = 0
        end
      end
    end
    object Panel4: TPanel
      Left = 476
      Top = 1
      Width = 384
      Height = 267
      Align = alClient
      Caption = 'Panel4'
      TabOrder = 1
      ExplicitWidth = 476
      object Panel5: TPanel
        Left = 1
        Top = 1
        Width = 382
        Height = 41
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 474
        object Label2: TLabel
          Left = 5
          Top = 4
          Width = 65
          Height = 13
          Caption = 'Server Folder'
        end
        object lServerRoot: TLabel
          Left = 85
          Top = 4
          Width = 57
          Height = 13
          Caption = 'lServerRoot'
        end
        object lServerPath: TStaticText
          Left = 5
          Top = 20
          Width = 458
          Height = 17
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'lServerPath'
          TabOrder = 0
        end
      end
      object RemoteList: TListBox
        Left = 1
        Top = 42
        Width = 382
        Height = 224
        Align = alClient
        ItemHeight = 13
        TabOrder = 1
        ExplicitWidth = 474
      end
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 0
    Width = 92
    Height = 269
    Align = alLeft
    TabOrder = 2
    object Button2: TButton
      Left = 8
      Top = 16
      Width = 75
      Height = 25
      Action = actPush
      TabOrder = 0
    end
    object Button3: TButton
      Left = 8
      Top = 48
      Width = 75
      Height = 25
      Action = actCancel
      TabOrder = 1
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 224
    Top = 200
    object Push1: TMenuItem
      Action = actPush
    end
  end
  object ActionList1: TActionList
    Left = 320
    Top = 112
    object actPush: TAction
      Caption = 'Push'
      OnExecute = actPushExecute
      OnUpdate = actPushUpdate
    end
    object actCancel: TAction
      Caption = 'Cancel'
      OnExecute = actCancelExecute
      OnUpdate = actCancelUpdate
    end
  end
end
