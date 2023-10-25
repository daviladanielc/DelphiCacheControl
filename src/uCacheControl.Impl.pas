{ ***************************************************************************
  Copyright (c) 2023 Daniel Carlos Dávila

  Unit        : uCacheControl.Impl
  Description : Delphi Cache Control
  Author      : Daniel Carlos Dávila
  Version     : 1.0
  Created     : 24/10/2023

  Licensed under the GNU General Public License v3.0

 *************************************************************************** }
unit uCacheControl.Impl;

interface

uses
  System.SysUtils, System.Generics.Collections, System.SyncObjs, Vcl.ExtCtrls, Winapi.Windows, System.Rtti;

type
  TCacheItem<T: class> = class
  private
    FKey: string;
    FTimeToLive: Integer;
    FInserted: Cardinal;
  public
    property Key: string read FKey write FKey;
    property TimeToLive: Integer read FTimeToLive write FTimeToLive;
    property Inserted: Cardinal read FInserted write FInserted;
  end;

  TCacheControl = class
  private
    FCache: TObjectDictionary<string, TObject>;
    FItems: TObjectDictionary<string, TCacheItem<TObject>>;
    FTimerTTL: TTimer;
    procedure EnqueueCacheItem(const AItem: TCacheItem<TObject>);
    procedure OnTimerTTL(Sender: TObject);
  public
    function AddItem<T: class>(AKey: string; AValue: T; ATimeToLive: Integer = 0): Boolean;
    function GetItemByKey<T: class>(AKey: string; var AValue: T): Boolean;
    function DeleteItem(AKey: string): Boolean;
    function HasKey(AKey: String):boolean;
    procedure SetTimeToLiveWaitTime(ATime: Integer);
    constructor Create(ATimeToLiveWaitTime: Integer = 60000); //by default 1 minute
    destructor Destroy; override;
  end;

  var CacheControl: TCacheControl;
      CacheCriticalSession: TCriticalSection;
implementation

{ TCacheControl }

function TCacheControl.AddItem<T>(AKey: string; AValue: T; ATimeToLive: Integer): Boolean;
var
  LCacheItem: TCacheItem<TObject>;
begin
  try
    LCacheItem := TCacheItem<TObject>.Create;
    LCacheItem.Key := AKey;
    LCacheItem.TimeToLive := ATimeToLive;
    LCacheItem.Inserted := GetTickCount;

    FItems.Add(AKey, LCacheItem);
    FCache.Add(AKey, AValue);

    Result := True;
  except
    on E: Exception do
    begin
      Result := False;
      raise Exception.Create('Cache Control: Error when adding a new item: ' + E.Message);
    end;
  end;
end;

constructor TCacheControl.Create(ATimeToLiveWaitTime: Integer);
begin
  CacheCriticalSession := TCriticalSection.Create;
  FCache := TObjectDictionary<string, TObject>.Create([doOwnsValues]);
  FItems := TObjectDictionary<string, TCacheItem<TObject>>.Create([doOwnsValues]);
  FTimerTTL := TTimer.Create(nil);
  FTimerTTL.OnTimer := OnTimerTTL;
  FTimerTTL.Interval := ATimeToLiveWaitTime;
  FTimerTTL.Enabled := True;
end;

function TCacheControl.DeleteItem(AKey: string): Boolean;
begin
  CacheCriticalSession.Enter;
  try
    try
      Result := FCache.ContainsKey(AKey);
      if Result then
      begin
        FCache.Remove(AKey);
        FItems.Remove(AKey);
      end;
    except
      on E: Exception do
        Raise Exception.Create('Cache Control: Error deleting the Item');
    end;
  finally
    CacheCriticalSession.Leave;
  end;
end;

destructor TCacheControl.Destroy;
begin
  FTimerTTL.Enabled := False;
  FTimerTTL.Free;
  CacheCriticalSession.Free;
  FCache.Free;
  FItems.Free;
  inherited;
end;

procedure TCacheControl.EnqueueCacheItem(const AItem: TCacheItem<TObject>);
begin
  CacheCriticalSession.Enter;
  try
    try
      FItems.Add(AItem.Key, AItem);
    except
      on E: Exception do
        raise Exception.Create(E.Message);
    end;
  finally
    CacheCriticalSession.Leave;
  end;
end;

function TCacheControl.GetItemByKey<T>(AKey: string; var AValue: T): Boolean;
var
   LContext: TRttiContext;
   LTypeParameter: TRttiType;
   LTypeCache: TRttiType;
begin
  CacheCriticalSession.Enter;
  try
    Result := FCache.ContainsKey(AKey);
    if Result then
    begin
      try
        LContext:= TRttiContext.Create;
        LTypeParameter:= LContext.GetType(TypeInfo(T));
        LTypeCache:= LContext.GetType(FCache[AKey].ClassType);
        if LTypeParameter = LTypeCache then
          AValue := T(FCache[AKey])
        else begin
          Result:= False;
          raise Exception.Create('The Class provided as a parameter is not the same as the key.')
        end;
      finally
        LContext.Free;
      end;
    end;

  finally
    CacheCriticalSession.Leave;
  end;
end;

function TCacheControl.HasKey(AKey: String): boolean;
begin
  CacheCriticalSession.Enter;
  try
    Result := FCache.ContainsKey(AKey);
  finally
    CacheCriticalSession.Leave;
  end;
end;

procedure TCacheControl.OnTimerTTL(Sender: TObject);
var
  LCacheKey: string;
  LCacheItem: TCacheItem<TObject>;
begin
  CacheCriticalSession.Enter;
  try
    if FItems.Count = 0 then
      exit;

    for LCacheKey in FItems.Keys do
    begin
      if FItems.TryGetValue(LCacheKey, LCacheItem) then
      begin
        if (LCacheItem.TimeToLive > 0) and
          ((GetTickCount - LCacheItem.Inserted) > LCacheItem.TimeToLive) then
        begin
          FItems.Remove(LCacheKey);
          FCache.Remove(LCacheKey);
        end;
      end;
    end;
  finally
    CacheCriticalSession.Leave;
  end;
end;

procedure TCacheControl.SetTimeToLiveWaitTime(ATime: Integer);
begin
  FTimerTTL.Enabled := False;
  FTimerTTL.Interval := ATime;
  FTimerTTL.Enabled := True;
end;

initialization
  CacheControl := TCacheControl.Create;

finalization
  CacheControl.Free;

end.

