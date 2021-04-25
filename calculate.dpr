program calculate;
{$APPTYPE CONSOLE}

uses
  maths in 'maths.pas', SysUtils;

var
  str, substring: string;
  c: integer;
label
  again, pass;
begin
  Writeln;
  Writeln('Calculate 1.0.0. (c) Copyright Shpati Koleka MMXXI - MIT License');
  Writeln;
  Writeln('This calculator displays the sequence of the operations that'
    + ' it performs.');
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
    goto pass;
  end;
  again:
  str := '';
  substring := '';
  Writeln;
  Writeln;
  Write(' >> ');
  Readln(str);
  pass:
  Writeln;
  for c := 1 to length(str) do
  begin
    if str[c] <> ';' then
      substring := substring + str[c]
    else
    begin;
      substring := cleanup(substring);
      Writeln;
      writeln('IN: ', substring);
      execute(substring);
      substring := '';
    end;
  end;
  if substring <> '' then
  begin
    substring := cleanup(substring);
    Writeln;
    writeln('IN: ', substring);
    execute(substring);
  end;
  goto again;
end.

