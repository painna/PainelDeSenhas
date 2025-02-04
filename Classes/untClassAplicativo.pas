  unit untClassAplicativo;

interface

uses
  SysUtils, Variants, Classes, math, StrUtils, TypInfo, System.IoUtils,
  System.JSON, System.Zlib, FMX.Types, Pkg.Json.DTO;

type
  TImpressao = class(TJsonDTO)
    private
      FUltimoChamado: integer;
      FPadariaMaximoNormal: integer;
      FPadariaMaximoPreferencial: integer;
      FAcougueMaximoNormal: integer;
      FAcougueMaximoPreferencial: integer;

    published
      property padariamaximonormal : integer read FPadariaMaximoNormal write FPadariaMaximoNormal;
      property padariamaximopreferencial : integer read FPadariaMaximoPreferencial write FPadariaMaximoPreferencial;
      property acouguemaximonormal : integer read FAcougueMaximoNormal write FAcougueMaximoNormal;
      property acouguemaximoPreferencial : integer read FAcougueMaximoPreferencial write FAcougueMaximoPreferencial;
      property ultimochamado : integer read FUltimoChamado write FUltimoChamado;
  end;

  TConfiguracoesAplicativo = class(TJsonDTO)
  private
    FArquivoAcougue: string;
    FDiretorioPadrao: string;
    FArquivoPadaria: string;
    FTipo: string;
    FArquivoAplicativo: string;
    FArquivoTeclado: string;
    FArquivoDisplay: string;
    FArquivoImpressao: string;
    FArquivoSom: string;
    FUsaImpressao: string;
    FImpressao: TImpressao;
    FServidor: string;
    FArquivoReport: string;
    FArquivoVisual: string;
    Class var FInstance : TConfiguracoesAplicativo;

    class function GetInstancia: TConfiguracoesAplicativo; static;

    published
      property diretoriopadrao : string read FDiretorioPadrao write FDiretorioPadrao;
      property arquivoacougue : string read FArquivoAcougue write FArquivoAcougue;
      property arquivopadaria : string read FArquivoPadaria write FArquivoPadaria;
      property arquivoaplicativo : string read FArquivoAplicativo write FArquivoAplicativo;
      property arquivodisplay: string read FArquivoDisplay write FArquivoDisplay;
      property arquivoteclado: string read FArquivoTeclado write FArquivoTeclado;
      property arquivoimpressao: string read FArquivoImpressao write FArquivoImpressao;
      property arquivovisual: string read FArquivoVisual write FArquivoVisual;
      property arquivosom: string read FArquivoSom write FArquivoSom;
      property arquivoreport: string read FArquivoReport write FArquivoReport;
      property tipo: string read FTipo write FTipo;
      property usaimrpessao : string read FUsaImpressao write FUsaImpressao;
      property impressao : TImpressao read FImpressao write FImpressao;
      property servidor : string read FServidor write FServidor;

    public
      constructor Create(AOwner: TComponent);
      //destructor Destroy; override;

      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;

      procedure carregaInformacoes;
      procedure carregapadrao;
      function retornaDados:String;
      function retornaArquivoConfigurado:string;
      class property Instancia: TConfiguracoesAplicativo read GetInstancia;

  end;

implementation

uses
  untFuncoes;

{ TConfiguracoes }

procedure TConfiguracoesAplicativo.AfterConstruction;
begin
  inherited;
end;

procedure TConfiguracoesAplicativo.BeforeDestruction;
begin
  inherited;
  Self.FImpressao.Free;
  self.FImpressao := nil;
end;

procedure TConfiguracoesAplicativo.carregaInformacoes;
  var
    strJson : String;
begin
  if tipo = 'TECLADO DISPLAY 1' then
    begin
      if FileExists(FArquivoPadaria) then
        begin
          leStringStrream(FArquivoPadaria, strJson);
          Self.AsJson := strJson;
        end;
    end;

  if tipo = 'TECLADO DISPLAY 2' then
    begin
      if FileExists(FArquivoAcougue) then
        begin
          leStringStrream(FArquivoAcougue, strJson);
          Self.AsJson := strJson;
        end;
    end;

  if tipo = 'DISPLAY' then
    begin
      if FileExists(FArquivoDisplay) then
        begin
          leStringStrream(FArquivoDisplay, strJson);
          Self.AsJson := strJson;
        end;
    end;

  if tipo = 'IMPRESS�O' then
    begin
      if FileExists(FArquivoImpressao) then
        begin
          leStringStrream(FArquivoImpressao, strJson);
          Self.AsJson := strJson;
        end;
    end;

  leStringStrream(FArquivoAplicativo, strJson);
  Self.AsJson := strJson;
end;

procedure TConfiguracoesAplicativo.carregapadrao;
begin
  if FAplicativo = nil then
    begin
      var strJSon : String;
      leStringStrream(FArquivoAplicativo, strJson);

      FAplicativo := Self;
      FAplicativo.AsJson := strJSon;
    end;
end;

constructor TConfiguracoesAplicativo.Create(AOwner: TComponent);
  var
    strJson : string;
begin
  {$IFDEF Android}
    FDiretorioPadrao := TPath.GetDocumentsPath; // TPath.Combine(TPath.GetDocumentsPath, 'PainelCuiabaSoft');
  {$ELSE}
    if FIsServidor = True then
      FDiretorioPadrao := TPath.Combine(TPath.GetLibraryPath, 'Servidor')
    else
      FDiretorioPadrao := TPath.Combine(System.IoUtils.TDirectory.GetCurrentDirectory, '');
  {$ENDIF}

  FImpressao := TImpressao.Create;

  if not DirectoryExists(FDiretorioPadrao) then
    TDirectory.CreateDirectory(FDiretorioPadrao);

  FArquivoAplicativo := TPath.Combine(FDiretorioPadrao, 'aplicativo.json');
  FArquivoAcougue := TPath.Combine(FDiretorioPadrao, 'acougue.json');
  FArquivoPadaria := TPath.Combine(FDiretorioPadrao, 'padaria.json');
  FArquivoTeclado := TPath.Combine(FDiretorioPadrao, 'teclado.json');
  FArquivoDisplay := TPath.Combine(FDiretorioPadrao, 'display.json');
  FArquivoImpressao := TPath.Combine(FDiretorioPadrao, 'impressao.json');
  FArquivoVisual := TPath.Combine(FDiretorioPadrao, 'visual.json');

  //leStringStrream(FArquivoAplicativo, strJson);
  //Self.AsJson := strJson;
  carregaInformacoes;
end;

//destructor TConfiguracoesAplicativo.Destroy;
//begin
//
//  inherited;
//end;

class function TConfiguracoesAplicativo.GetInstancia: TConfiguracoesAplicativo;
begin
  if not(Assigned(FInstance)) then
    begin
      FInstance := TConfiguracoesAplicativo.Create(nil);
    end;

  Result := FInstance;
end;

function TConfiguracoesAplicativo.retornaArquivoConfigurado: string;
begin
  if  FTipo = 'TECLADO DISPLAY 1' then
    Result := FArquivoDisplay
  else if  FTipo = 'TECLADO DISPLAY 2' then
    Result := FArquivoDisplay
  else if  FTipo = 'DISPLAY' then
    Result := FArquivoDisplay
  else if  FTipo = 'IMPRESS�O' then
    Result := FArquivoImpressao
  else
    Result := FArquivoPadaria;
end;

function TConfiguracoesAplicativo.retornaDados: String;
  var
    strJson : string;
begin
  if  FTipo = 'TECLADO DISPLAY 1' then
    begin
      if FileExists(FArquivoDisplay) then
        leStringStrream(FArquivoDisplay, strJson);
    end;

  if FTipo = 'DISPLAY DISPLAY 2' then
    begin
      if FileExists(FArquivoDisplay) then
        leStringStrream(FArquivoDisplay, strJson);
    end;

  if FTipo = 'IMPRESS�O' then
    begin
      if FileExists(FArquivoImpressao) then
        leStringStrream(FArquivoImpressao, strJson);
    end;

  if FileExists(FArquivoVisual) then
    leStringStrream(FArquivoVisual, strJson);

  Result  := strJson;
end;

end.
