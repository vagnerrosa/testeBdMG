program ServerHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Horse.BasicAuthentication,
  Controller.Tarefa in 'Controller\Controller.Tarefa.pas',
  Model.Connection in 'Model\Model.Connection.pas',
  Model.Tarefa in 'Model\Model.Tarefa.pas';

begin
    THorse.Use(Jhonson());
    THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      // Here inside you can access your database and validate if username and password are valid
      Result := AUsername.Equals('BDMG') and APassword.Equals('123@2024');
    end));

    Controller.Tarefa.Registry;
    THorse.Listen(9000);
end.
