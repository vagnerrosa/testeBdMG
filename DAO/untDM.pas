unit untDM;

interface

uses
  System.SysUtils, System.Classes, REST.Types, REST.Client,
  REST.Authenticator.Basic, Data.Bind.Components, Data.Bind.ObjectScope;

type
  TDM = class(TDataModule)
    RESTTarefa: TRESTClient;
    ReqTarefaGET: TRESTRequest;
    HTTPBasicAuthenticator1: THTTPBasicAuthenticator;
    REQTarefaPOST: TRESTRequest;
    REQTarefaPut: TRESTRequest;
    REQTarefaDELETE: TRESTRequest;
    ReqEstatGET: TRESTRequest;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
