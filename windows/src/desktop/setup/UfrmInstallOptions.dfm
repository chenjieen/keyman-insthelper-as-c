object frmInstallOptions: TfrmInstallOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'ssOptionsTitle'
  ClientHeight = 386
  ClientWidth = 646
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblInstallOptions: TLabel
    Left = 8
    Top = 8
    Width = 159
    Height = 13
    Caption = 'ssOptionsTitleInstallOptions'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblDefaultKeymanSettings: TLabel
    Left = 8
    Top = 69
    Width = 214
    Height = 13
    Caption = 'ssOptionsTitleDefaultKeymanSettings'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblSelectModulesToInstall: TLabel
    Left = 8
    Top = 149
    Width = 212
    Height = 13
    Caption = 'ssOptionsTitleSelectModulesToInstall'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblAssociatedKeyboardLanguage: TLabel
    Left = 242
    Top = 149
    Width = 251
    Height = 13
    Caption = 'ssOptionsTitleAssociatedKeyboardLanguage'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblInstallerVersion: TLabel
    Left = 8
    Top = 358
    Width = 84
    Height = 13
    Caption = 'lblInstallerVersion'
  end
  object lblTitleLocation: TLabel
    Left = 497
    Top = 149
    Width = 128
    Height = 13
    Caption = 'ssOptionsTitleLocation'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object chkStartWithWindows: TCheckBox
    Left = 8
    Top = 88
    Width = 473
    Height = 17
    Caption = 'ssOptionsStartWithWindows'
    TabOrder = 2
  end
  object chkStartAfterInstall: TCheckBox
    Left = 8
    Top = 27
    Width = 473
    Height = 17
    Caption = 'ssOptionsStartAfterInstall'
    TabOrder = 0
  end
  object chkCheckForUpdates: TCheckBox
    Left = 8
    Top = 126
    Width = 473
    Height = 17
    Caption = 'ssOptionsCheckForUpdates'
    TabOrder = 4
  end
  object chkUpgradeKeyman7: TCheckBox
    Left = 8
    Top = 46
    Width = 473
    Height = 17
    Caption = 'ssOptionsUpgradeKeyboards'
    TabOrder = 1
  end
  object cmdOK: TButton
    Left = 242
    Top = 353
    Width = 73
    Height = 25
    Caption = 'ssOkButton'
    Default = True
    TabOrder = 6
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 330
    Top = 353
    Width = 73
    Height = 25
    Cancel = True
    Caption = 'ssCancelButton'
    ModalResult = 2
    TabOrder = 7
  end
  object chkAutomaticallyReportUsage: TCheckBox
    Left = 8
    Top = 107
    Width = 473
    Height = 17
    Caption = 'ssOptionsAutomaticallyReportUsage'
    TabOrder = 3
  end
  object sbTargets: TScrollBox
    Left = 6
    Top = 168
    Width = 619
    Height = 175
    BorderStyle = bsNone
    ParentBackground = True
    TabOrder = 5
  end
end
