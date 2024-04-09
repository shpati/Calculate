program calculate;
{$APPTYPE CONSOLE}
{$R calculate.res}

uses
  maths in 'maths.pas', SysUtils;

var
  str, substring: string;
  show: boolean = false;
  c: integer;
label
  again, pass;
begin
  Writeln;
  Writeln('Calculate 1.0.2. (c) Copyright Shpati Koleka MMXXI - MIT License');
  Writeln;
  Writeln('This calculator can show the sequence of the operations that it performs.');
  Writeln('Press Ctrl+C or type EXIT in the prompt in order to the program anytime.');
  Writeln('Type HELP to see help page.');
  Writeln;
  Writeln('Please enter below the expression you would like to calculate.');
  Writeln('You can enter multiple expressions at once separating them by semicolon.');
  ii := 0;
  ans := '0';
  if ParamCount > 0 then
  begin
    str := ParamStr(1);
    if AnsiLowerCase(str) = 'filein' then
    begin
      if not FileExists(ParamStr(2)) then
      begin
        Writeln;
        Writeln('ERROR: File not found');
        Halt;
      end;
      str := loadtextfromfile(ParamStr(2));
      str := StringReplace(str, sLineBreak, '', [rfReplaceAll]);
      Writeln;
      Writeln('Input file (', ParamStr(2), ') contents: ');
      Write(str);
    end;
    if AnsiLowerCase(str) = 'showsteps' then
    begin
      show := true;
      str := ParamStr(2);
    end;
    goto pass;
  end;
  again:
  show := false;
  str := '';
  substring := '';
  Writeln;
  Write('  >> ');
  Readln(str);
  str := AnsiLowerCase(str);
  if Copy(str, 0, 7) = 'filein ' then
  begin
    str := StringReplace(str, 'filein ', '', [rfReplaceAll]);
    str := StringReplace(str, ' ', '', [rfReplaceAll]);
    if not FileExists(str) then
    begin
      Writeln;
      Writeln('ERROR: File not found');
      Halt;
    end;
    Writeln;
    Writeln('Input file (', str, ') contents: ');
    str := loadtextfromfile(str);
    str := StringReplace(str, sLineBreak, '', [rfReplaceAll]);
    Write(str);
  end;
  if Copy(str, 0, 10) = 'showsteps ' then
  begin
    show := true;
    str := StringReplace(str, 'showsteps ', '', [rfReplaceAll]);
  end;
  pass:
  Writeln;
  if str[length(str)] <> ';' then str := str + ';';
  for c := 1 to length(str) do
  begin
    if (str[c] <> ';') then
      substring := substring + str[c]
    else
    begin;
      substring := cleanup(substring);
      execute(substring, show);
      substring := '';
    end;
  end;
  if ParamCount > 0 then Halt;
  goto again;
end.

