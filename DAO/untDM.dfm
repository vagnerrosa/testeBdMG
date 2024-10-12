object DM: TDM
  Height = 270
  Width = 991
  PixelsPerInch = 120
  object RESTTarefa: TRESTClient
    Authenticator = HTTPBasicAuthenticator1
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'http://localhost:9000'
    Params = <>
    SynchronizedEvents = False
    Left = 56
    Top = 40
  end
  object ReqTarefaGET: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTTarefa
    Params = <>
    Resource = 'tarefa'
    SynchronizedEvents = False
    Left = 168
    Top = 48
  end
  object HTTPBasicAuthenticator1: THTTPBasicAuthenticator
    Username = 'BDMG'
    Password = '123@2024'
    Left = 784
    Top = 64
  end
  object REQTarefaPOST: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTTarefa
    Params = <>
    Resource = 'tarefa'
    SynchronizedEvents = False
    Left = 278
    Top = 48
  end
  object REQTarefaPut: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTTarefa
    Params = <>
    Resource = 'tarefa'
    SynchronizedEvents = False
    Left = 392
    Top = 46
  end
  object REQTarefaDELETE: TRESTRequest
    Client = RESTTarefa
    Method = rmDELETE
    Params = <>
    Resource = 'tarefa'
    SynchronizedEvents = False
    Left = 492
    Top = 48
  end
  object ReqEstatGET: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTTarefa
    Params = <>
    Resource = 'estatisticas'
    SynchronizedEvents = False
    Left = 96
    Top = 160
  end
end
