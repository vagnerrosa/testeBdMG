unit Model.Tarefa;

interface

uses FireDAC.Comp.Client, Data.DB, System.SysUtils, Model.Connection, System.JSON;

type
    TTarefa = class
    private
        FID_TAREFA   : Integer;
        FDESC_TAREFA : string;
        FPRIORIDADE  : integer;
        FSTATUS      : string;
        FDTCONCLUSAO : string;
    public
        constructor Create;
        destructor Destroy; override;

        property ID_TAREFA   : Integer read FID_TAREFA   write FID_TAREFA;
        property DESC_TAREFA : string  read FDESC_TAREFA write FDESC_TAREFA;
        property PRIORIDADE  : integer read FPRIORIDADE  write FPRIORIDADE;
        property STATUS      : string  read FSTATUS      write FSTATUS;
        property DTCONCLUSAO : string  read FDTCONCLUSAO write FDTCONCLUSAO;

        function ListarTarefa(order_by: string; out erro: string): TFDQuery;
        function Inserir(out erro: string): Boolean;
        function Excluir(out erro: string): Boolean;
        function EditarStatus(out erro: string): Boolean;
        function GetTarefasInfo(out erro: string): TFDQuery;
end;

implementation

{ TTarefa }

constructor TTarefa.Create;
begin
    Model.Connection.Connect;
end;

destructor TTarefa.Destroy;
begin
    Model.Connection.Disconect;
end;
//Remover uma tarefa.
function TTarefa.Excluir(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('DELETE FROM TAB_TAREFA WHERE ID_TAREFA =:ID_TAREFA');
            ParamByName('ID_TAREFA').Value := ID_TAREFA;
            ExecSQL;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao excluir Tarefa: ' + ex.Message;
            Result := false;
        end;
    end;
end;
//Atualizar o status de uma tarefa.
function TTarefa.EditarStatus(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validacoes...
    if ID_TAREFA <= 0 then
    begin
        Result := false;
        erro := 'Informe o id.Tarefa';
        exit;
    end;

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE TAB_TAREFA SET STATUS=:STATUS');

           if STATUS = 'CONCLUIDA' then
            begin
               SQL.Add(', DTCONCLUSAO=:DTCONCLUSAO ');
               ParamByName('DTCONCLUSAO').Value := FormatDateTime('YYYY-DD-MM HH:MM:SS', now);
            end;

            SQL.Add('WHERE ID_TAREFA=:ID_TAREFA');
            ParamByName('STATUS').Value := STATUS;
            ParamByName('ID_TAREFA').Value := ID_TAREFA;

            ExecSQL;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao alterar Tarefa: ' + ex.Message;
            Result := false;
        end;
    end;
end;
//Adicionar uma nova tarefa.
function TTarefa.Inserir(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validacoes...
    if DESC_TAREFA.IsEmpty then
    begin
        Result := false;
        erro := 'Informe o nome do Tarefa';
        exit;
    end;

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('INSERT INTO TAB_TAREFA(DESC_TAREFA,PRIORIDADE,STATUS)');
            SQL.Add('VALUES(:DESC_TAREFA, :PRIORIDADE, :STATUS)');

            ParamByName('DESC_TAREFA').Value := DESC_TAREFA;
            ParamByName('PRIORIDADE').Value := PRIORIDADE;
            ParamByName('STATUS').Value := STATUS;

            ExecSQL;

            // Busca ID inserido...
            Params.Clear;
            SQL.Clear;
            SQL.Add('SELECT MAX(ID_TAREFA) AS ID_TAREFA FROM TAB_TAREFA');
            SQL.Add('WHERE DESC_TAREFA=:DESC_TAREFA');
            ParamByName('DESC_TAREFA').Value := DESC_TAREFA;
            active := true;

            ID_TAREFA := FieldByName('ID_TAREFA').AsInteger;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao cadastrar Tarefa: ' + ex.Message;
            Result := false;
        end;
    end;
end;
//Consultar e retornar a lista de todas as tarefas
function TTarefa.ListarTarefa(order_by: string;
                                out erro: string): TFDQuery;
var
    qry : TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT * FROM TAB_TAREFA WHERE 1 = 1');

            if ID_TAREFA > 0 then
            begin
                SQL.Add('AND ID_TAREFA = :ID_TAREFA');
                ParamByName('ID_TAREFA').Value := ID_TAREFA;
            end;

            if order_by = '' then
                SQL.Add('ORDER BY ID_TAREFA ASC')
            else
                SQL.Add('ORDER BY ' + order_by);

            Active := true;
        end;

        erro := '';
        Result := qry;
    except on ex:exception do
        begin
            erro := 'Erro ao consultar Tarefa: ' + ex.Message;
            Result := nil;
        end;
    end;
end;
//Desafio SQL utilizando SQL Server: Implemente consultas SQL no servi�o para calcular e retornar
function TTarefa.GetTarefasInfo(out erro: string): TFDQuery;
var
    qry : TFDQuery;
begin
{
  �O n�mero total de tarefas.
  �A m�dia de prioridade das tarefas pendentes.
  �A quantidade de tarefas conclu�das nos �ltimos 7 dias.
}

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT ');
            SQL.Add('COUNT(*) AS TotalTarefas, ' );
            SQL.Add('CASE ' );
            SQL.Add('WHEN COUNT(CASE WHEN STATUS <> ''CONCLUIDA'' THEN 1 END) > 0 ' );
            SQL.Add('THEN AVG(CASE WHEN STATUS <> ''CONCLUIDA'' THEN PRIORIDADE END) ');
            SQL.Add('ELSE 0 END AS MediaPrioridadePendentes, ' );
            SQL.Add('COUNT(CASE WHEN STATUS = ''CONCLUIDA'' AND DTCONCLUSAO >= DATEADD(DAY, -7, GETDATE()) THEN 1 END) AS TarefasConcluidasUltimos7Dias ' );
            SQL.Add('FROM TAB_TAREFA');

            Active := true;
        end;

        erro := '';
        Result := qry;
    except on ex:exception do
        begin
            erro := 'Erro ao consultar estat�sticas: ' + ex.Message;
            Result := nil;
        end;
    end;
end;


end.
