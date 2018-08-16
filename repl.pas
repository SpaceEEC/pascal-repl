program repl;

uses
    Crt,
    Classes,
    SysUtils,
    Process;

const
    FILE_NAME = 'tmp.pas';
    BUF_SIZE = 2048;
    BORDER = '===================================================';

procedure WriteBorder(text: AnsiString);
begin
    WriteLn(BORDER);
    WriteLn(text);
    WriteLn(BORDER);
    WriteLn();
end;

// http://wiki.freepascal.org/Executing_External_Programs#Reading_large_output
function RunProcess(executable: AnsiString; parameters: TStrings): integer;
var
    process: TProcess;
    bytesRead: longint;
    buffer: array[1..BUF_SIZE] of byte;
    output: AnsiString;
    exitCode: integer;
begin
    process := TProcess.Create(nil);
    process.Executable := executable;
    process.Options := [poUsePipes];
    if parameters <> nil then
        process.Parameters := parameters;

    process.Execute();

    repeat
        bytesRead := process.Output.Read(buffer, BUF_SIZE);
        if bytesRead = 0 then break;
        // https://stackoverflow.com/a/3885508
        SetString(output, PAnsiChar(@buffer[1]), bytesRead);
        writeln(output);
    until false;

    process.WaitOnExit();
    exitCode := process.ExitStatus;
    process.Free();

    exit(exitCode);
end;

procedure Run();
var
    exitCode: integer;
begin
    WriteBorder('Executing...');

    exitCode := RunProcess('./tmp', nil);

    WriteBorder('Process exited with code ' + IntToStr(exitCode) + '.');

    WriteLn('Press enter to continue...');
    ReadLn();
end;

function Compile(): boolean;
var
    parameters: TStrings;
    exitCode: integer;
begin
    WriteLn();
    WriteBorder('Compiling...');

    parameters := TStringList.Create();
    parameters.Add('-gs');
    parameters.Add('-Mdelphi');
    parameters.Add('tmp.pas');

    exitCode := RunProcess('fpc', parameters);

    if exitCode <> 0 then
    begin
        WriteBorder('Compiler exited with code ' + IntToStr(exitCode) + ', aborting...');

        WriteLn('Press enter to continue...');
        ReadLn();

        exit(false);
    end
    else
        exit(true);
end;

function ReadInput(var f: TextFile): boolean;
var input: string;
begin
        Rewrite(f);

        ClrScr();
        WriteBorder(
            'Write your Pascal code here.'
             + #10 + #13
             + 'You can exit by writing "..exit".'
             + #10 + #13
             + 'Be sure to finish with "end.".'
             );
        WriteLn('program tmp;');
        WriteLn();

        WriteLn(f, 'program tmp;');
        WriteLn(f);

        repeat
            ReadLn(input);

            if (input = '..exit') then
            begin
                CloseFile(f);

                exit(false);
            end;

            WriteLn(f, input);
            if (input = 'end.') then
            begin
                CloseFile(f);
                if Compile() then
                    Run();
            end;
        until input = 'end.';

        exit(true);
end;

var f: TextFile;
begin
    AssignFile(f, FILE_NAME);
    while ReadInput(f) do;
end.