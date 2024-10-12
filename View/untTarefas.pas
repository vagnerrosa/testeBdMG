unit untTarefas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, System.ImageList, Vcl.ImgList,
  Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.ComCtrls, System.JSON, REST.Types,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,System.DateUtils, Vcl.StdCtrls;

type
  TfrmControleTarefas = class(TForm)
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    pnlGrid: TPanel;
    DBGrid: TDBGrid;
    PnlTopo: TPanel;
    btnNew: TSpeedButton;
    btnEdit: TSpeedButton;
    btnDelete: TSpeedButton;
    btnClose: TSpeedButton;
    Panel2: TPanel;
    dsConsTarefas: TDataSource;
    btnListaTarefas: TSpeedButton;
    FdMemTableTarefasID_TAREFA: TIntegerField;
    FdMemTableTarefasDESC_TAREFA: TStringField;
    FdMemTableTarefasPRIORIDADE: TIntegerField;
    FdMemTableTarefasSTATUS: TStringField;
    FdMemTableTarefasDTCONCLUSAO: TDateTimeField;
    FdMemTableTarefas: TFDMemTable;
    pnlPostPut: TPanel;
    Panel1: TPanel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    edtTarefa: TEdit;
    lblTarefa: TLabel;
    lblPrioridade: TLabel;
    cbPrioridade: TComboBox;
    cbStatus: TComboBox;
    lblStatus: TLabel;
    SpeedButton1: TSpeedButton;
    procedure btnListaTarefasClick(Sender: TObject);
    procedure GET_Tarefas;
    procedure ProcessarGET;
    procedure ProcessarGETErro(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    function POST_PUT_Tarefas(verbo: TRestRequestMethod;
                                         idTarefa: integer;
                                         descTarefa, status: string;
                                         prioridade: integer;
                                         out erro: string): boolean;
    function DELETE_Tarefa(idTarefa: integer;
                            out erro: string): boolean;
    procedure VisualizaEstatistica;
    procedure btnNewClick(Sender: TObject);
    procedure limpaTela;
    procedure btnEditClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure DBGridDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure GET_Estatistica;
  private
    acao :string;
    { Private declarations }
  public
    { Public declarations }
  end;
var
  frmControleTarefas: TfrmControleTarefas;

implementation

{$R *.dfm}

uses untDM;

procedure TfrmControleTarefas.btnListaTarefasClick(Sender: TObject);
begin
  GET_Tarefas;
end;



procedure TfrmControleTarefas.SpeedButton1Click(Sender: TObject);
begin
GET_Estatistica;
end;

procedure TfrmControleTarefas.SpeedButton2Click(Sender: TObject);
begin
pnlPostPut.Visible:=false;
end;

procedure TfrmControleTarefas.SpeedButton3Click(Sender: TObject);
var
    erro : string;
    verbo : TRESTRequestMethod;
    idTarefa : integer;
begin

    if acao = 'I' then
    begin
      verbo := rmPOST;
      idTarefa := 0;
    end
    else
    begin
      verbo := rmPUT;
      idTarefa :=  FdMemTableTarefasID_TAREFA.AsInteger;
    end;
    if NOT POST_PUT_Tarefas(verbo,
                             idTarefa,
                             edtTarefa.Text,
                             cbStatus.Text,
                             strtoint(cbPrioridade.Text),
                             erro) then
        showmessage(erro)
    else
    begin
        GET_Tarefas;
       pnlPostPut.Visible:=false;
    end;


end;

procedure TfrmControleTarefas.btnCloseClick(Sender: TObject);
begin
close;
end;

procedure TfrmControleTarefas.btnDeleteClick(Sender: TObject);
var
    erro : string;
begin

  // Exibe a mensagem de confirma��o
  // Verifica a resposta do usu�rio
  if MessageDlg('Voc� deseja excluir a tarefa?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
   begin
    if NOT DELETE_Tarefa(FdMemTableTarefasID_TAREFA.AsInteger, erro) then
       showmessage(erro)
    else
       GET_Tarefas;
   end;

end;

procedure TfrmControleTarefas.btnEditClick(Sender: TObject);
begin
  acao := 'E';
  pnlPostPut.Visible:=true;
  edtTarefa.Enabled:=false;
  cbPrioridade.Enabled:=false;
  edtTarefa.Text :=  FdMemTableTarefasDESC_TAREFA.AsString;
  cbPrioridade.Text := FdMemTableTarefasPRIORIDADE.AsString;
  cbStatus.Text := FdMemTableTarefasSTATUS.AsString;

  cbStatus.SetFocus;
end;

procedure TfrmControleTarefas.btnNewClick(Sender: TObject);
begin
  acao := 'I';
  pnlPostPut.Visible:=true;
  limpaTela;
  edtTarefa.Enabled:=true;
  cbPrioridade.Enabled:=true;
  cbStatus.Enabled:=true;
  cbStatus.Text := 'PENDENTE';
  edtTarefa.SetFocus;
end;

procedure TfrmControleTarefas.DBGridDblClick(Sender: TObject);
begin
  btnEdit.Click;
end;

procedure TfrmControleTarefas.FormShow(Sender: TObject);
begin
  btnListaTarefas.Click;
end;

procedure TfrmControleTarefas.GET_Tarefas;
begin
    try
        dm.ReqTarefaGET.ExecuteAsync(ProcessarGET, true, true, ProcessarGETErro);
    except on ex:exception do
        showmessage('Erro ao acessar o servidor: ' + ex.Message);
    end;
end;

procedure TfrmControleTarefas.GET_Estatistica;
begin
    try
        dm.ReqEstatGET.ExecuteAsync(VisualizaEstatistica, true, true, ProcessarGETErro);
    except on ex:exception do
        showmessage('Erro ao acessar o servidor: ' + ex.Message);
    end;
end;

{--- GET ---}

procedure TfrmControleTarefas.ProcessarGET;
var
    json : string;
    arrayTarefas : TJsonArray;
    i : integer;
begin
    if dm.ReqTarefaGET.Response.StatusCode  <> 200 then
    begin
        showmessage('Ocorreu um erro na consulta: ' +
        dm.ReqTarefaGET.Response.StatusCode.ToString);
    end;

    try
        json := dm.ReqTarefaGET.Response.JSONValue.ToString;
        arrayTarefas := TJSONObject.ParseJSONValue(
                          TEncoding.UTF8.GetBytes(json), 0) as TJSONArray;

        FdMemTableTarefas.Close;
        FdMemTableTarefas.Open;

        for i := 0 to arrayTarefas.Size - 1 do
        begin

          FdMemTableTarefas.Insert;
          FdMemTableTarefasID_TAREFA.Value   := arrayTarefas.Get(i).GetValue<integer>('idTarefa', 0);
          FdMemTableTarefasDESC_TAREFA.Value := arrayTarefas.Get(i).GetValue<string>('descTarefa', '');
          FdMemTableTarefasPRIORIDADE.Value  := arrayTarefas.Get(i).GetValue<integer>('prioridade', 0);
          FdMemTableTarefasSTATUS.Value      := arrayTarefas.Get(i).GetValue<string>('status', '');

          // Atribui a data, tratando nulls
          if arrayTarefas.Get(i).GetValue<string>('dtconclusao', '')<> '' then
            FdMemTableTarefas.FieldByName('dtconclusao').AsDateTime := ISO8601ToDate(arrayTarefas.Get(i).GetValue<string>('dtconclusao'))
          else
            FdMemTableTarefas.FieldByName('dtconclusao').Clear;

          FdMemTableTarefas.Post;
        end;
    finally
       arrayTarefas.DisposeOf;
    end;
end;


procedure TfrmControleTarefas.VisualizaEstatistica;
var
  json : string;
  arrayEstatistica : TJsonArray;
  JsonObject: TJSONObject;
  TotalTarefas: Integer;
  MediaPrioridadePendentes: Double;
  TarefasConcluidasUltimos7Dias: Integer;
begin
    if dm.ReqEstatGET.Response.StatusCode <> 200 then
    begin
        showmessage('Ocorreu um erro na consulta: ' +
        dm.ReqEstatGET.Response.StatusCode.ToString);
    end;

    try // L� o JSON
        json := dm.ReqEstatGET.Response.JSONValue.ToString;
        arrayEstatistica := TJSONObject.ParseJSONValue(
                          TEncoding.UTF8.GetBytes(json), 0) as TJSONArray;
        JsonObject := arrayEstatistica.Items[0] as TJSONObject;
        // L� os valores
        TotalTarefas := JsonObject.GetValue<Integer>('totaltarefas');
        MediaPrioridadePendentes := JsonObject.GetValue<Double>('mediaprioridadependentes');
        TarefasConcluidasUltimos7Dias := JsonObject.GetValue<Integer>('tarefasconcluidasultimos7dias');
        // Mostra os dados na tela
        ShowMessage(Format('Total de Tarefas: %d' + sLineBreak +
                           'M�dia de Prioridade Pendentes: %.2f' + sLineBreak +
                           'Tarefas Conclu�das nos �ltimos 7 Dias: %d',
                           [TotalTarefas, MediaPrioridadePendentes, TarefasConcluidasUltimos7Dias]));
    finally
       arrayEstatistica.DisposeOf;
    end;
end;


procedure TfrmControleTarefas.ProcessarGETErro(Sender: TObject);
begin
    if Assigned(Sender) and (Sender is Exception) then
        showmessage(Exception(Sender).Message);
end;


{--- POST / PUT ---}
function TfrmControleTarefas.POST_PUT_Tarefas(verbo: TRestRequestMethod;
                                         idTarefa: integer;
                                         descTarefa, status: string;
                                         prioridade: integer;
                                         out erro: string): boolean;
var
    jsonBody : TJSONObject;
begin
    try
        try
            Result := false;
            erro := '';

            jsonBody := TJSONObject.Create;
            jsonBody.AddPair('descTarefa', descTarefa);
            jsonBody.AddPair('prioridade', prioridade);
            jsonBody.AddPair('status', status);

            if verbo = rmPUT then
               jsonBody.AddPair('idTarefa', idTarefa.ToString);

            dm.REQTarefaPOST.Params.Clear;
            dm.REQTarefaPOST.Body.ClearBody;
            dm.REQTarefaPOST.Method := verbo; // POST ou PUT
            dm.REQTarefaPOST.Body.Add(jsonBody.ToString,
                                          ContentTypeFromString('application/json'));
            dm.REQTarefaPOST.Execute;

            // Tratar retorno...
            if (dm.REQTarefaPOST.Response.StatusCode  <> 200) and
               (dm.REQTarefaPOST.Response.StatusCode  <> 201) then
            begin
                erro := 'Erro ao salvar dados: ';
                exit;
            end;



            Result := true;

        except on ex:exception do
                erro := 'Ocorreu um erro: ' + ex.Message;
        end;
    finally
        jsonBody.DisposeOf;
    end;
end;

{--- DELETE ---}
function TfrmControleTarefas.DELETE_Tarefa(idTarefa: integer;
                                       out erro: string): boolean;
begin
    try
        Result := false;
        erro := '';

        dm.REQTarefaDELETE.Resource := 'tarefa/' + idTarefa.ToString;
        dm.REQTarefaDELETE.Execute;

        // Tratar retorno...
        if (dm.REQTarefaDELETE.Response.StatusCode  <> 200) then
        begin
            erro := 'Erro ao excluir dados: ';
            exit;
        end;

        Result := true;

    except on ex:exception do
        erro := 'Ocorreu um erro: ' + ex.Message;
    end;
end;

procedure TfrmControleTarefas.limpaTela;
begin
//
edtTarefa.Clear;
cbPrioridade.Text:='';
cbStatus.Text:='';
lblDataConclusao.Caption := '';
end;


end.
