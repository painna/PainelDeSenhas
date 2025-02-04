unit untFuncoes;

interface

uses
  SysUtils, Variants, Classes, math, StrUtils, TypInfo, System.NetEncoding,
  Soap.EncdDecd, system.ioutils,  Pkg.Json.DTO, untClassMonitor,
  untClassAplicativo;

function iif(Test: boolean; TrueR, FalseR: string): string; overload;
function iif(Test: boolean; aTrue, aFalse: Boolean): Boolean; overload;
function iif(Test: boolean; TrueR, FalseR: Variant): Variant; overload;
function stringToBoolean(aExpressao, aValor:String): Boolean;
function vazio(const value:string):Boolean; overload;
function vazio(const value:TDateTime):Boolean; overload;
procedure gravaStringStream(aCaminho:string; aValor:String);
procedure leStringStrream(aCaminho:String; out aSaida:string);
procedure gravaLog(const aNome, aValue: String);



var
  FAplicativo : TConfiguracoesAplicativo;
  FMonitor : TClassMonitor;
  FLendoOuGravando : Boolean;
  FIsServidor : Boolean;

implementation

uses
  FMX.Forms;

function iif(Test: boolean; TrueR, FalseR: string): string;
begin
  if Test then
    Result := TrueR
  else
    Result := FalseR;
end;

function iif(Test: boolean; TrueR, FalseR: Variant): Variant;
begin
  if Test then
    Result := TrueR
  else
    Result := FalseR;
end;

function stringToBoolean(aExpressao, aValor:String): Boolean;
begin
  if aExpressao = aValor then
    Result := True
  else
    Result := False;
end;

function iif(Test: boolean; aTrue, aFalse: Boolean): Boolean;
begin
  if Test then
    Result := aTrue
  else
    Result := aFalse;
end;

function vazio(const value:string):Boolean;
begin
  Result := (value = EmptyStr) or (value = null);
end;

function vazio(const value:TDateTime):Boolean;
begin
  Result := (value = 0);
end;

procedure gravaStringStream(aCaminho:string; aValor:String);
  var
    arq: TStringStream;
begin
  try
  while FLendoOuGravando do
    begin
      // so segura a grava��o
    end;

  FLendoOuGravando := True;
  arq := TStringStream.Create;
  arq.WriteString(aValor);
  arq.SaveToFile(aCaminho);
  arq.Free;
  FLendoOuGravando := False;
  except
    on e : exception do
     begin
       //LOG.d(E.Message);
     end;
  end;
end;

procedure leStringStrream(aCaminho:String; out aSaida:string);
  var
    arq: TStringStream;
begin
  while FLendoOuGravando do
    begin
      // so segura a leitura
    end;

  if not FileExists(aCaminho) then
    Exit;

  FLendoOuGravando := True;
  arq := TStringStream.Create;
  arq.LoadFromFile(aCaminho);
  aSaida := arq.DataString;
  arq.Free;
  FLendoOuGravando := False;
end;

procedure gravaLog(const aNome, aValue: String);
var
   Arq: TextFile;
   //strArq : string;
   stArquivo : TStringList;

   //strLinha: String;
   strCaminho : string;
begin
//  stArquivo := TStringList.Create;
//  strArq.inser

  while FLendoOuGravando do
    begin
      // so segura o processo
    end;

  FLendoOuGravando := True;

  {$IFDEF Android}
    strCaminho := TPath.Combine(tpath.GetDocumentsPath, 'CuiabaSoftware');
  {$ELSE}
    strCaminho := TPath.Combine(ExtractFilePath(ParamStr(0)), 'CuiabaSoftware');
  {$ENDIF}

  if not DirectoryExists(strCaminho) then
    CreateDir(strCaminho);

  if not DirectoryExists(TPath.Combine(strCaminho, 'log')) then
    CreateDir(TPath.Combine(strCaminho, 'Log'));

  strCaminho := TPath.Combine(strCaminho, 'Log');

  strCaminho := TPath.Combine(strCaminho, FormatDateTime('yyyymmdd', Date) + '_' + aNome + '.log');

   AssignFile(Arq, strCaminho);

   if FileExists(strCaminho) then
      Append(Arq)
   else
      Rewrite(Arq);

   try
      Writeln(Arq, '[', DateTimeToStr( Now ), '] ', aValue);
   finally
      //Flush(Arq);
      CloseFile(Arq);
      //Arq := nil;
   end;

  FLendoOuGravando := False;
end;

end.
