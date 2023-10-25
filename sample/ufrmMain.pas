unit ufrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uCacheControl.Impl, Vcl.StdCtrls,
  Data.DB, Datasnap.DBClient;

type

  TFoo = class
  public
    Name: String;
  end;

  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.SyncObjs;

{$R *.dfm}

procedure TfrmMain.Button1Click(Sender: TObject);
var
  LCds: TClientDataSet;
begin
  LCds := TClientDataSet.Create(Nil);

  CacheControl.AddItem<TClientDataSet>('1', LCds, 5000);

end;

procedure TfrmMain.Button2Click(Sender: TObject);
var
  LStr: TStringList;
begin

  if CacheControl.GetItemByKey<TStringList>('1', LStr) then
    SHowmessage('Exists')
  else
    SHowmessage('Not Exists');
end;

procedure TfrmMain.Button3Click(Sender: TObject);
begin
  CacheControl.DeleteItem('1');
end;

procedure TfrmMain.Button4Click(Sender: TObject);
var
  LThreads : array of TThread;
  i: integer;
  LThreadId: Integer;
begin
  LThreadId:= 0;
  SetLength(LThreads, 10);
  Memo1.Lines.Clear;
  for i:= 0 to High(LThreads) do
  begin
   LThreads[i]:= TThread.CreateAnonymousThread(
        procedure
        var
          LStr: TStringList;
          j: integer;
          Execute: Boolean;
          MyLocalthreadId: Integer;
        begin
          TInterlocked.Increment(LThreadId);
          MyLocalthreadId:= LThreadId;
          try
            LStr := TStringList.Create;
            LStr.Add('thread '+MyLocalthreadId.ToString);
            CacheControl.AddItem<TStringList>(MyLocalthreadId.tostring, LStr);

            Execute:= True;
            while Execute do
            begin
              Randomize;
              j:= Random(9);
              if CacheControl.HasKey(j.tostring) then
              begin
                CacheControl.GetItemByKey<TStringList>(j.tostring, LStr);

                TThread.Synchronize(nil,
                procedure
                begin
                  frmMain.Memo1.Lines.Add('thread '+MyLocalthreadId.tostring+' Catch: '+LStr.Text);
                end);
                Execute:= False;
              end;
            end;

          finally
            TThread.Queue(nil,
              procedure
              begin
                frmMain.Memo1.Lines.Add('Thread '+MyLocalthreadId.tostring+',  cache done');
              end);
          end;

        end);
      LThreads[i].FreeOnTerminate := True;
  end;

  for i:= 0 to High(Lthreads) do
    LThreads[i].Start;


end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  CacheControl.SetTimeToLiveWaitTime(1000);
end;

end.
