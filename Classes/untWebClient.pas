﻿unit untWebClient;

interface

uses
  System.SysUtils, System.Variants, System.Classes, StrUtils,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, IdMultipartFormData,   IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdServerIOHandler;

type
  TWebClient = class
      class var FWebClient: TWebClient;
      class var FRequestBody: TStream;
      class var FResponseBody: string;
      class var FHttp: TIdHttp;
      class var FStatusCode: Integer;
      class var FExecucao: Boolean;
      class var FParametros : TStringList;

    public
      //constructor Create; virtual;
      destructor Destroy; override;

      class property Http: TIdHttp read FHttp write FHttp;
      class property RequestBody: TStream read FRequestBody write FRequestBody;
      class property ResponseBody: string read FResponseBody write FResponseBody;
      class property WebClient: TWebClient read FWebClient write FWebClient;
      class property StatusCode: Integer read FStatusCode write FStatusCode;
      class property Execucao: Boolean read FExecucao write FExecucao;
      class property parametros: TStringList read FParametros write FParametros;

      class function consomeApi(aUrl:String; aMetodo: string; aBody: string; aHeader:TStrings = nil): TWebClient;
      class function consomeApi2(aUrl: String; aMetodo: string): TWebClient;
      class procedure aguardaExecucao(aTempo: integer=100{milisegundos});
      function addParametro(aValor:String):TWebClient;
  end;

implementation

{ TWebClient }

function TWebClient.addParametro(aValor: String): TWebClient;
begin
  if FParametros = nil then
    FParametros := TStringList.Create;

  FParametros.Add(aValor);
  Result := Self;
end;

class procedure TWebClient.aguardaExecucao(aTempo: integer=100{milisegundos});
begin
  while TWebClient.Execucao  do
    Sleep(100);
end;

class function TWebClient.consomeApi(aUrl:String; aMetodo: string; aBody:string; aHeader:TStrings = nil): TWebClient;
begin
  if FWebClient <> nil then
    FreeAndNil(FWebClient);

  FWebClient := TWebClient.Create;


  FHttp := TIdHTTP.Create(nil);
  //FWebClient := Self;

  //TWebClient.Create;

  //TWebClient.Create;
  FExecucao := True;

  try
    try
      RequestBody := TStringStream.Create(aBody, TEncoding.UTF8);

      if pos('https', aUrl) > 0 then
        aUrl := StringReplace(aUrl, 'https', 'http', [rfReplaceAll]);

      try
        HTTP.Request.Accept := 'application/json';
        HTTP.Request.ContentType := 'application/json';

        if Assigned(aHeader) then
          begin
            HTTP.Request.CustomHeaders.FoldLines := False;
            HTTP.Request.CustomHeaders.AddStrings(aHeader);
          end;

//
//        Http.Request.BasicAuthentication :=  True;
//        Http.Request.Username := 'aTlUZWNub2xvZ2lhR2VzdGFvQDk1MTM1NzAwX19GZXJuYW5kaW5ob1J1bURlQm9sYQ==';
//        Http.Request.Password := 'aTlnZXN0YW90ZWNub2xvZ2lh';

        HTTP.ConnectTimeout := 1800000;
        HTTP.ReadTimeout := 1800000;
        //FHttp.Request.cl

        case AnsiIndexStr(UpperCase(aMetodo), ['POST', 'GET', 'PUT', 'DELETE']) OF
          0 : FResponseBody := Http.Post(aUrl, RequestBody);
          1 : FResponseBody := Http.Get(aUrl);
          2 : FResponseBody := Http.Put(aUrl, RequestBody);
          3 : FResponseBody := Http.Delete(aUrl);
        end;
      finally
        //RequestBody.Free;
      end;

      FStatusCode := Http.ResponseCode;
    except
      on E: EIdHTTPProtocolException do
        begin
          HTTP.Disconnect;
          WriteLn(E.Message);
          WriteLn(E.ErrorMessage);
        end;

      on E: Exception do
        begin

          WriteLn(E.Message);
        end;
    end;
  finally
    //FHttp.Request.Connection := 'close';
    //HTTP.Disconnect;

    //FWebClient := twe;

    FExecucao := False;
    Result := FWebClient;

    if Assigned(FRequestBody) then
      FRequestBody := nil;

    if Assigned(FHttp) then
      FreeAndNil(FHttp);
  end;
end;

class function TWebClient.consomeApi2(aUrl: String; aMetodo: string): TWebClient;
  var
    IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  FExecucao := True;

  Http.Request.ContentLength := -1;
  Http.Request.ContentRangeEnd := 0;
  Http.Request.ContentRangeStart := 0;

  IdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  IdSSLIOHandlerSocketOpenSSL.Port := 0;
  IdSSLIOHandlerSocketOpenSSL.DefaultPort := 0;
  IdSSLIOHandlerSocketOpenSSL.SSLOptions.Method := sslvTLSv1_2;
  IdSSLIOHandlerSocketOpenSSL.SSLOptions.SSLVersions := [sslvTLSv1_2];
  IdSSLIOHandlerSocketOpenSSL.SSLOptions.Mode := sslmUnassigned;
  IdSSLIOHandlerSocketOpenSSL.SSLOptions.VerifyMode := [];
  IdSSLIOHandlerSocketOpenSSL.SSLOptions.VerifyDepth := 0;

  HTTP.IOHandler := IdSSLIOHandlerSocketOpenSSL;
  HTTP.AllowCookies := True;
  HTTP.ProxyParams.BasicAuthentication := False;
  HTTP.Request.ContentType := 'application/x-www-form-urlencoded';
  HTTP.Request.Accept := 'application/json';

  Http.IOHandler := IdSSLIOHandlerSocketOpenSSL;
  HTTP.HTTPOptions := [hoForceEncodeParams, hoNoProtocolErrorException, hoWantProtocolErrorContent];

  try
    try
      try
        Http.HTTPOptions := [hoForceEncodeParams];
        Http.Request.CustomHeaders.Clear;
        Http.Request.ContentType := 'application/x-www-form-urlencoded';
        Http.Request.ContentEncoding := 'multipart/form-data';
        Http.AllowCookies := True;

        HTTP.ConnectTimeout := 180000;
        HTTP.ReadTimeout := 180000;

        case AnsiIndexStr(UpperCase(aMetodo), ['POST', 'GET', 'PUT', 'DELETE']) OF
          0 : FResponseBody := Http.Post(aUrl, FParametros);
          1 : FResponseBody := Http.Get(aUrl);
          //2 : FResponseBody := Http.Put(aUrl);
          3 : FResponseBody := Http.Delete(aUrl);
        end;
      finally
        RequestBody.Free;
      end;

      FStatusCode := Http.ResponseCode;
    except
      on E: EIdHTTPProtocolException do
        begin
          WriteLn(E.Message);
          WriteLn(E.ErrorMessage);
        end;

      on E: Exception do
        begin
          WriteLn(E.Message);
        end;
    end;
  finally
    FExecucao := False;

    if Assigned(FRequestBody) then
      FRequestBody := nil;

    if Assigned(IdSSLIOHandlerSocketOpenSSL) then
      FreeAndNil(IdSSLIOHandlerSocketOpenSSL);

    Result := FWebClient;
  end;
end;

//constructor TWebClient.Create;
//begin
////  FHttp := TIdHTTP.Create(nil);
////  FWebClient := Self;
//end;

destructor TWebClient.Destroy;
begin
  inherited Destroy;

  if Assigned(FHttp) then
    begin
      FreeAndNil(FHttp);
      FHttp := nil;
    end;

  FreeAndNil(FParametros);
end;

end.
