(*
  Name:             keymankeyboardsinstalled
  Copyright:        Copyright (C) SIL International.
  Documentation:
  Description:
  Create Date:      20 Jun 2006

  Modified Date:    25 Oct 2016
  Authors:          mcdurdin
  Related Files:
  Dependencies:

  Bugs:
  Todo:
  Notes:
  History:          20 Jun 2006 - mcdurdin - Initial version
                    01 Aug 2006 - mcdurdin - Add AutoApplyKeyman call
                    04 Dec 2006 - mcdurdin - Fix IKeymanKeyboardsInstalled function
                    04 Dec 2006 - mcdurdin - Fix product matchup with keyboards
                    22 Jan 2007 - mcdurdin - Raise error if keyboard not found by name in Get_Item
                    27 Mar 2008 - mcdurdin - I1192 - Fix crash when starting multiple products at once
                    12 Mar 2010 - mcdurdin - I2230 - Resolve crashes due to incorrect reference counting
                    29 Mar 2010 - mcdurdin - I2299 - Internal crash causes keyboard list to not refresh
                    17 Aug 2012 - mcdurdin - I3377 - KM9 - Update code references from 8.0 to 9.0
                    17 Aug 2014 - mcdurdin - I4376 - V9.0 - Unticked keyboards in configuration should be removed from language profile
                    17 Aug 2014 - mcdurdin - I4381 - V9.0 - Keyman keyboards should be removed from language bar when Keyman exits
                    10 Oct 2014 - mcdurdin - I4421 - CrashID:keyman.exe_9.0.470.0_2C631914_EOleException
                    23 Feb 2015 - mcdurdin - I4382 - V9.0 - Keyman Configuration enables keyboards when OK clicked even if Keyman not running
                    01 Apr 2015 - mcdurdin - I4624 - Crash when multiple products installed but one is not available [CrashID:kmshell.exe_9.0.486.0_2C67DFFB_EOleException]
*)
unit keymankeyboardsinstalled;

interface

uses
  Windows, ActiveX, ComObj, keymanapi_TLB, StdVcl, keymanautoobject, KeymanContext,
  keymanerrorcodes, keymankeyboardinstalled, keymankeyboard, internalinterfaces;

type
  TKeymanKeyboardsInstalled = class(TKeymanAutoCollectionObject, IKeymanKeyboardsInstalled, IKeymanKeyboardsInstalled2, IIntKeymanKeyboardsInstalled)   // I4376
  private
    FKeyboards: TKeyboardList;
    procedure TriggerWindowsLanguageSync;
  protected
    procedure DoRefresh; override;

    { IKeymanKeyboards }
    function IndexOf(const ID: WideString): Integer; safecall;

    { IKeymanKeyboardsInstalled}
    function Get_Items(Index: OleVariant): IKeymanKeyboardInstalled; safecall;

    function GetKeyboardFromFile(const Filename: WideString): IKeymanKeyboardFile;
      safecall;
    procedure Install(const Filename: WideString; Force: WordBool); safecall;
    procedure Apply; safecall;
    function Install2(const Filename: WideString; Force: WordBool): IKeymanKeyboardInstalled; safecall;
    procedure RefreshInstalledKeyboards; safecall;

    { IIntKeymanKeyboardsInstalled }
  public
    constructor Create(AContext: TKeymanContext);
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils,
  System.Variants,
  Winapi.msctf,
  custinterfaces,
  DebugPaths,
  keymankeyboardfile,
  keymanpackageinstalled,
  keymanpackagesinstalled,
  KeymanPaths,
  KLog,
  kpinstallkeyboard,
  keyman_msctf,
  regkeyboards,
  RegistryKeys,
  utilexecute,
  utilfiletypes;

constructor TKeymanKeyboardsInstalled.Create(AContext: TKeymanContext);
begin
  _SetContext(AContext);
  FKeyboards := TKeyboardList.Create;
  inherited Create(AContext, IKeymanKeyboardsInstalled, FKeyboards);
  Refresh;
end;

destructor TKeymanKeyboardsInstalled.Destroy;
begin
  FKeyboards.Free;
  inherited Destroy;
end;

procedure TKeymanKeyboardsInstalled.Install(const Filename: WideString; Force: WordBool);
begin
  with TKPInstallKeyboard.Create(Context) do
  try
    Execute(FileName, '', [ikLegacyRegisterAndInstallProfiles], nil, Force);
  finally
    Free;
  end;
end;

function TKeymanKeyboardsInstalled.Install2(const Filename: WideString;
  Force: WordBool): IKeymanKeyboardInstalled;
begin
  with TKPInstallKeyboard.Create(Context) do
  try
    Execute(FileName, '', [], nil, Force);
  finally
    Free;
  end;

  DoRefresh;
  Result := Get_Items(FileName);
end;

/// <summary>Updates installed keyboards to Keyman 14+ registration pattern</summary>
/// <remarks>This refreshes all the registered profiles for keyboards and registers
/// transient profiles for keyboards. This function is idempotent. This function
/// requires elevation to succeed.</remarks>
procedure TKeymanKeyboardsInstalled.RefreshInstalledKeyboards;
var
  I: Integer;
  k: IKeymanKeyboardInstalled;
begin
  for I := 0 to Get_Count - 1 do
  begin
    k := Get_Items(i);
    (k as IIntKeymanKeyboardInstalled).RefreshInstallation;
  end;
end;

function TKeymanKeyboardsInstalled.Get_Items(Index: OleVariant): IKeymanKeyboardInstalled;
var
  i: Integer;
begin
  if VarType(Index) = varOleStr
    then i := IndexOf(Index)
    else i := Index;

  if (i < Get_Count) and (i >= 0)
    then Result := FKeyboards[i] as IKeymanKeyboardInstalled
    else ErrorFmt(KMN_E_Collection_InvalidIndex, VarArrayOf([VarToStr(Index)]));
end;

function TKeymanKeyboardsInstalled.IndexOf(const ID: WideString): Integer;
var
  i: Integer;
  s: string;
begin
  s := ExtractFileName(RemoveFileExtension(ID, Ext_KeymanFile));
  for i := 0 to FKeyboards.Count - 1 do
    if (AnsiCompareText((FKeyboards[i] as IKeymanKeyboard).ID, s) = 0) then
      Exit(i);

  Result := -1;
end;

procedure TKeymanKeyboardsInstalled.Apply;
var
  i, n: Integer;
begin
  with TRegKeyboardList.Create do
  try
    Load(True);

    for i := 0 to FKeyboards.Count - 1 do
    begin
      n := IndexOfName((FKeyboards[i] as IKeymanKeyboard).ID);
      if n >= 0 then
      begin
        Items[n].ApplySettings((FKeyboards[i] as IIntKeymanKeyboardInstalled).RegKeyboard);
      end;
    end;

    Save;
  finally
    Free;
  end;

  Context.Control.AutoApplyKeyman;

  TriggerWindowsLanguageSync;
end;

// This triggers a synchronisation of the language settings to the
// cloud, which avoids an issue where language setting changes are
// overwritten on a subsequent reboot of the system.
//
// See #4447 and kmrefresh.cpp for additional detail.
//
// Although the sync function is not supported on Windows 7, 8.1,
// we'll call kmrefresh.exe anyway, as we cannot be sure which version
// of Windows we are running on -- the calling process may be lied to
// if it does not have an appropriate manifest. kmrefresh.exe is safe
// to run as it will simply exit if it does not find the appropriate
// endpoint to call.
//
// On x64 systems, we must call the x64 version of the process, as the
// x86 version does not appear to work.
procedure TKeymanKeyboardsInstalled.TriggerWindowsLanguageSync;
var
  processName: string;
  FWow64: LongBool;
begin
  if not Reg_GetDebugFlag(SRegValue_Flag_SyncLanguagesToCloud, True) then
    Exit;

{$IFDEF WIN64}
  processName := 'kmrefresh.x64.exe';
{$ELSE}
  if IsWow64Process(GetCurrentProcess, FWow64) and FWow64
    then processName := 'kmrefresh.x64.exe'
    else processName := 'kmrefresh.x86.exe';
{$ENDIF}

  TUtilExecute.Execute(
    TKeymanPaths.KeymanEngineInstallPath(processName),
    ExtractFileDir(ParamStr(0)),
    SW_HIDE
  );
end;

procedure TKeymanKeyboardsInstalled.DoRefresh;
var
  iKeyboard: Integer;
  c: TKeymanKeyboardInstalled;
  pkg: IIntKeymanPackageInstalled;
  iPackage: Integer;
begin
  KL.MethodEnter(Self, 'DoRefresh', []);
  try
    FKeyboards.Clear;
    with TRegKeyboardList.Create do
    try
      Load(False);
      KL.Log('  Keyboards found = %d', [Count]);
      for iKeyboard := 0 to Count - 1 do
      try
        KL.Log('  Keyboards[%d] = %s', [iKeyboard, Items[iKeyboard].Name]);
        c := TKeymanKeyboardInstalled.Create(Context, Items[iKeyboard].Name);
        FKeyboards.Add(c);
      except
        ;
      end;
    finally
      Free;
    end;

    { I1192 - 7.0.244.0 - fix crash when starting multiple products }
    if Context.Packages <> nil then
      for iPackage := 0 to Context.Packages.Count -1  do
      begin
        pkg := Context.Packages.Items[iPackage] as IIntKeymanPackageInstalled;
        pkg.RefreshKeyboards;
      end;

  finally
    KL.Log('  On exit, total keyboards found = %d', [Count]);
    KL.MethodExit(Self, 'DoRefresh');
  end;
end;

function TKeymanKeyboardsInstalled.GetKeyboardFromFile(const Filename: WideString): IKeymanKeyboardFile;
var
  k: TKeymanKeyboardFile;
begin
  ClearErrors;
  k := nil;

  try
    if not FileExists(Filename) then
      raise Exception.Create('File does not exist.');
    k := TKeymanKeyboardFile.Create(Context, Filename, nil);
  except
    on E:Exception do
      ErrorFmt(KMN_E_Install_InvalidFile, VarArrayOf([Filename, E.Message]));
  end;

  Result := k;
end;

end.
