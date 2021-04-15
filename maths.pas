unit maths;

interface

uses
  StrUtils, SysUtils, Classes, Math;

type TStringArray = array[1..256] of string;

function cleanup(str: string): string;
function check(str: string): string;
function identify(element: string): string;
function isfunction(str: string): boolean;
function StringtoTSA(str: string): TStringArray;
function TSAtoString(arr: TStringArray): string;
function findvalue(arr: TStringArray; str: string): integer;
function findinnerparantheses(str: string): string;
function simplesolve(str: string): string;
function solveall(str: string; showsteps: boolean): string;
function cleararray(arr: TStringArray): TStringArray;
function execute(str: string; showsteps: boolean): string;
procedure help;

var
  TSA, variables, solutions: TStringArray;
  ii: integer;

implementation

function cleanup(str: string): string;
var
  i: integer;
begin
  str := StringReplace(str, ' ', '', [rfReplaceAll]);
  str := StringReplace(str, ',', '.', [rfReplaceAll]);
  TSA := StringtoTSA(str);
  for i := 1 to High(TSA) do
    if (identify(TSA[i]) = 'other') and (isfunction(TSA[i]) = false) then
      TSA[i] := AnsiUpperCase(TSA[i])
    else
      TSA[i] := AnsiLowerCase(TSA[i]);
  str := TSAtoString(TSA);
  Result := str;
end;

function check(str: string): string;
var
  i, b: integer;
begin
  b := 0;
  Result := '';
  for i := 1 to Length(str) do
  begin
    if identify(str[i]) = 'l.p' then inc(b);
    if identify(str[i]) = 'r.p' then dec(b);
    if b < 0 then
    begin
      writeln('Error: Closing parenthesis was used before opening parenthesis.');
      exit;
    end;
  end;
  if b <> 0 then
  begin
    writeln('Error: The number of opening and closing parentheses do not match.');
    exit;
  end;
  Result := str;
end;

function identify(element: string): string;
begin
  if AnsiContainsText('0123456789.,', element) then Result := 'number' else
    if AnsiContainsText('^-*-/-+--', element) then Result := 'operator' else
      if element = ' ' then Result := 'space' else
        if element = '(' then Result := 'l.p' else
          if element = ')' then Result := 'r.p' else
            if element = '=' then Result := '=' else
              Result := 'other';
end;

function isfunction(str: string): boolean;
begin
  Result := AnsiMatchStr(AnsiLowerCase(str), ['sin', 'cos', 'tan', 'exp', 'ln',
    'log', 'sqrt', 'pi', 'phi', 'help', 'variables', 'exit', 'quit']);
end;

function StringtoTSA(str: string): TStringArray;
var
  i, j: integer;
begin
  str := StringReplace(str, ' ', '', [rfReplaceAll]);
  j := 1;
  Result[j] := str[1];
  for i := 2 to Length(str) do
  begin
    if ((identify(str[i - 1]) = 'number') and (identify(str[i]) = 'number')) or
      ((identify(str[i - 1]) = 'other') and (identify(str[i]) = 'other')) or
      ((identify(str[i - 1]) = 'operator') and (identify(str[i]) = 'operator'))
      then
      Result[j] := Result[j] + str[i]
    else
    begin
      inc(j);
      Result[j] := str[i]
    end;
  end;
  for i := j + 1 to High(TSA) do
    Result[i] := '';
end;

function TSAtoString(arr: TStringArray): string;
var
  i: integer;
  str: string;
begin
  str := '';
  for i := 1 to high(arr) do
    str := str + arr[i];
  Result := StringReplace(str, ' ', '', [rfReplaceAll]);
end;

function findvalue(arr: TStringArray; str: string): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to Length(arr) do
    if (arr[i] = str) then
    begin
      Result := i;
      exit;
    end;
end;

function findinnerparantheses(str: string): string;
var
  i, b, max, s_pos, e_pos: integer;
  arr: TStringArray;
label
  removep;
begin
  b := 0;
  max := 0;
  TSA := StringtoTSA(str);
  s_pos := 1;
  e_pos := 1;
  for i := 1 to High(TSA) do
  begin
    if TSA[i] = '(' then
    begin
      inc(b);
      if max < b then
      begin
        max := b;
        s_pos := i;
      end;
    end;
    if TSA[i] = ')' then
    begin
      dec(b);
      if b = max - 1 then
      begin
        e_pos := i;
        Break;
      end;
    end;
  end;
  if max > 0 then
  begin
    for i := s_pos to e_pos do
      arr[i - s_pos + 1] := TSA[i];
    if s_pos < 2 then goto removep;
    if (isfunction(TSA[s_pos - 1]) = false) then
    begin
      removep:
      arr[1] := ' ';
      arr[e_pos - s_pos + 1] := ' ';
    end;
    Result := StringReplace(TSAtoString(arr), ' ', '', [rfReplaceAll]); ;
  end;
end;

function simplesolve(str: string): string;
var
  i: integer;
  f: extended;
label
  bottom, verybottom;
begin
  TSA := StringtoTSA(str);
  if TSA[1] = '--' then goto verybottom;
  for i := 1 to length(str) do
  begin
    if (identify(TSA[i]) = 'other') and (findvalue(variables, TSA[i]) <> 0) and
      (TSA[i] <> '') and (TryStrToFloat(TSA[i], f) = false) then
    begin
      TSA[i] := solutions[findvalue(variables, TSA[i])];
      goto verybottom;
    end;
    if ((identify(TSA[i]) = 'other') and (findvalue(variables, TSA[i]) = 0) and
      (TSA[i] <> '') and (TryStrToFloat(TSA[i], f) = false) and
      (isfunction(TSA[i]) = false)) then
    begin
      Result := str;
      exit;
    end;
  end;

  for i := 1 to length(str) do
  begin
    if ((TSA[i] = 'sin') and (TryStrToFloat(TSA[i + 2], f) = true))
      and (TSA[i + 1] = '(') and (TSA[i + 3] = ')') then
    begin
      TSA[i] := floattostr(sin(strtofloat(TSA[i + 2])));
      goto bottom;
    end;
    if ((TSA[i] = 'sin') and (TSA[i + 2] = '-') and (TSA[i + 1] = '(') and
      (TSA[i + 4] = ')') and (TryStrToFloat(TSA[i + 3], f) = true)) then
    begin
      TSA[i] := floattostr(sin(-strtofloat(TSA[i + 3])));
      TSA[i + 4] := ' ';
      goto bottom;
    end;
    if ((TSA[i] = 'cos') and (TryStrToFloat(TSA[i + 2], f) = true)) and
      (TSA[i + 1] = '(') and (TSA[i + 3] = ')') then
    begin
      TSA[i] := floattostr(cos(strtofloat(TSA[i + 2])));
      goto bottom;
    end;
    if ((TSA[i] = 'cos') and (TSA[i + 2] = '-') and (TSA[i + 1] = '(') and
      (TSA[i + 4] = ')') and (TryStrToFloat(TSA[i + 3], f) = true)) then
    begin
      TSA[i] := floattostr(cos(-strtofloat(TSA[i + 3])));
      TSA[i + 4] := ' ';
      goto bottom;
    end;
    if ((TSA[i] = 'tan') and (TryStrToFloat(TSA[i + 2], f) = true)) and
      (TSA[i + 1] = '(') and (TSA[i + 3] = ')') then
    begin
      TSA[i] := floattostr(sin(strtofloat(TSA[i + 2]))
        / cos(strtofloat(TSA[i + 2])));
      goto bottom;
    end;
    if ((TSA[i] = 'tan') and (TSA[i + 2] = '-') and (TSA[i + 1] = '(') and
      (TSA[i + 4] = ')') and (TryStrToFloat(TSA[i + 3], f) = true)) then
    begin
      TSA[i] := floattostr(sin(-strtofloat(TSA[i + 3]))
        / cos(-strtofloat(TSA[i + 3])));
      TSA[i + 4] := ' ';
      goto bottom;
    end;
    if ((TSA[i] = 'exp') and (TryStrToFloat(TSA[i + 2], f) = true)) and
      (TSA[i + 1] = '(') and (TSA[i + 3] = ')') then
    begin
      TSA[i] := floattostr(exp(strtofloat(TSA[i + 2])));
      goto bottom;
    end;
    if ((TSA[i] = 'exp') and (TSA[i + 2] = '-') and (TSA[i + 1] = '(') and
      (TSA[i + 4] = ')') and (TryStrToFloat(TSA[i + 3], f) = true)) then
    begin
      TSA[i] := floattostr(exp(-strtofloat(TSA[i + 3])));
      TSA[i + 4] := ' ';
      goto bottom;
    end;
    if ((TSA[i] = 'ln') and (TryStrToFloat(TSA[i + 2], f) = true)) and
      (TSA[i + 1] = '(') and (TSA[i + 3] = ')') then
      if f > 0 then
      begin
        TSA[i] := floattostr(ln(strtofloat(TSA[i + 2])));
        goto bottom;
      end;
    if ((TSA[i] = 'log') and (TryStrToFloat(TSA[i + 2], f) = true)) and
      (TSA[i + 1] = '(') and (TSA[i + 3] = ')') then
      if f > 0 then
      begin
        TSA[i] := floattostr(ln(strtofloat(TSA[i + 2])) / ln(10));
        goto bottom;
      end;
    if ((TSA[i] = 'sqrt') and (TryStrToFloat(TSA[i + 2], f) = true)) and
      (TSA[i + 1] = '(') and (TSA[i + 3] = ')') then
    begin
      TSA[i] := floattostr(sqrt(strtofloat(TSA[i + 2])));
      goto bottom;
    end;
    if (TSA[i] = 'pi') then
    begin
      TSA[i] := floattostr(Pi);
      goto verybottom;
    end;
    if (TSA[i] = 'phi') then
    begin
      TSA[i] := floattostr((1 + sqrt(5)) / 2);
      goto verybottom;
    end;
  end;

  for i := length(str) downto 1 do
    if (TSA[i] = '^') or (TSA[i] = '^-') then
      if (TryStrToFloat(TSA[i - 1], f) = true) and
        (TryStrToFloat(TSA[i + 1], f) = true) then
      begin
        if TSA[i] = '^' then
          TSA[i - 1] := floattostr(exp(ln(strtofloat(TSA[i - 1]))
            * strtofloat(TSA[i + 1])))
        else
          TSA[i - 1] := floattostr(exp(ln(strtofloat(TSA[i - 1]))
            * -strtofloat(TSA[i + 1])));
        TSA[i] := ' ';
        TSA[i + 1] := ' ';
        goto verybottom;
      end;
  for i := 1 to length(str) do
  begin
    if (TSA[i] = '*') or (TSA[i] = '*-') then
    begin
      if (TryStrToFloat(TSA[i - 1], f) = true) and
        (TryStrToFloat(TSA[i + 1], f) = true) then
      begin
        if TSA[i] = '*' then
          TSA[i - 1] := floattostr(strtofloat(TSA[i - 1])
            * strtofloat(TSA[i + 1]))
        else
          TSA[i - 1] := floattostr(strtofloat(TSA[i - 1])
            * -strtofloat(TSA[i + 1]));
        TSA[i] := ' ';
        TSA[i + 1] := ' ';
        goto verybottom;
      end;
    end;
    if (TSA[i] = '/') or (TSA[i] = '/-') then
      if (TryStrToFloat(TSA[i - 1], f) = true) and
        (TryStrToFloat(TSA[i + 1], f) = true) then
      begin
        if TSA[i] = '/' then
          TSA[i - 1] := floattostr(strtofloat(TSA[i - 1])
            / strtofloat(TSA[i + 1]))
        else
          TSA[i - 1] := floattostr(strtofloat(TSA[i - 1])
            / -strtofloat(TSA[i + 1]));
        TSA[i] := ' ';
        TSA[i + 1] := ' ';
        goto verybottom;
      end;
  end;
  for i := 1 to length(str) do
  begin
    if (TSA[i] = '+') or (TSA[i] = '--') then
      if (TryStrToFloat(TSA[i - 1], f) = true) and
        (TryStrToFloat(TSA[i + 1], f) = true) then
      begin
        if (i = 3) and (TSA[1] = '-') then
        begin
          TSA[i - 2] := ' ';
          TSA[i - 1] := floattostr(-strtofloat(TSA[i - 1])
            + strtofloat(TSA[i + 1]));
        end else
          TSA[i - 1] := floattostr(strtofloat(TSA[i - 1])
            + strtofloat(TSA[i + 1]));
        TSA[i] := ' ';
        TSA[i + 1] := ' ';
        goto verybottom;
      end;
    if (TSA[i] = '-') or (TSA[i] = '+-') then
      if i > 1 then
        if (TryStrToFloat(TSA[i - 1], f) = true) and
          (TryStrToFloat(TSA[i + 1], f) = true) then
        begin
          if (i = 3) and (TSA[1] = '-') then
          begin
            TSA[i - 2] := ' ';
            TSA[i - 1] := floattostr(-strtofloat(TSA[i - 1])
              - strtofloat(TSA[i + 1]));
          end else
            TSA[i - 1] := floattostr(strtofloat(TSA[i - 1])
              - strtofloat(TSA[i + 1]));
          TSA[i] := ' ';
          TSA[i + 1] := ' ';
          goto verybottom;
        end;
  end;

  goto verybottom;
  bottom:
  TSA[i + 1] := ' ';
  TSA[i + 2] := ' ';
  TSA[i + 3] := ' ';
  verybottom:
  str := TSAtoString(TSA);
  str := StringReplace(str, '++', '+', [rfReplaceAll]);
  str := StringReplace(str, '+-', '-', [rfReplaceAll]);
  str := StringReplace(str, '--', '+', [rfReplaceAll]);
  if (str[1] = '+') then Delete(str, 1, 1);
  if (TryStrToFloat(str, f) = true) and (abs(f) < 1E-14) then str := '0';
  Result := str;
end;

function solveall(str: string; showsteps: boolean): string;
var
  i, j: integer;
  f: extended;
label
  top;
begin
  i := 0;
  Writeln('#', i, ': ', str);
  top:
  while (AnsiContainsStr(str, '(') = true) do
  begin
    j := i;
    Result := str;
    str := StringReplace(str, findinnerparantheses(str),
      simplesolve(findinnerparantheses(str)), [rfReplaceAll]);
    TSA := StringtoTSA(str);
    for i := 1 to length(str) do
    begin
      if i = 1 then
      begin
        if ((TSA[1] = '(') and (TryStrToFloat(TSA[2], f) = true))
          and (TSA[3] = ')') then
        begin
          TSA[1] := ' ';
          TSA[3] := ' ';
        end;
        if ((TSA[1] = '(') and (TSA[2] = '-') and (TryStrToFloat(TSA[3], f) = true))
          and (TSA[4] = ')') then
        begin
          TSA[1] := ' ';
          TSA[4] := ' ';
        end;
        if ((TSA[1] = '-') and (TSA[2] = '(') and (TryStrToFloat(TSA[3], f) = true))
          and (TSA[4] = ')') then
        begin
          TSA[2] := ' ';
          TSA[4] := ' ';
        end;
      end;
      if i > 1 then
      begin
        if (TSA[i] = '(') and (TryStrToFloat(TSA[i + 1], f) = true)
          and (TSA[i + 2] = ')') and (isfunction(TSA[i - 1]) = false) then
        begin
          TSA[i] := ' ';
          TSA[i + 2] := ' ';
        end;
        if (TSA[i] = '(') and (TSA[i + 1] = '-') and (TryStrToFloat(TSA[i + 2], f) = true)
          and (TSA[i + 3] = ')') and (isfunction(TSA[i - 1]) = false) then
        begin
          TSA[i] := ' ';
          TSA[i + 3] := ' ';
        end;
        if (TSA[i] = '-') and (TSA[i + 1] = '(') and (TryStrToFloat(TSA[i + 2], f) = true)
          and (TSA[i + 3] = ')') and (isfunction(TSA[i - 1]) = false) then
        begin
          TSA[i + 1] := ' ';
          TSA[i + 3] := ' ';
        end;
      end;
    end;
    i := j;
    str := TSAtoString(TSA);
    if Result = str then Break;
    Result := str;
    inc(i);
    if showsteps = true then
      Writeln('#', i, ': ', str);
  end;
  begin
    inc(i);
    Result := str;
    str := simplesolve(str);
    if str = '' then Exit;
    if showsteps = true then
      if Result <> str then
      begin
        Writeln('#', i, ': ', str);
        goto top;
      end;
  end;
end;

function cleararray(arr: TStringArray): TStringArray;
var
  i: integer;
begin
  for i := 1 to High(arr) do
    Result[i] := '';
end;

function execute(str: string; showsteps: boolean): string;
var
  n, j: integer;
begin
  str := cleanup(str);
  if str = check(str) then
  begin
    TSA := StringtoTSA(str);
    if isfunction(TSA[1]) and (TSA[2] = '=') then
    begin
      writeln('Error: ', TSA[1], ' is an existing function or constant. ');
      Writeln('Please choose another variable name.');
      exit;
    end;
    if (identify(TSA[1]) = 'other') and (TSA[2] = '=') and
      (isfunction(TSA[1]) = false) then
    begin
      n := findvalue(variables, TSA[1]);
      if n = 0 then ii := ii + 1 else ii := n;
      variables[ii] := AnsiUpperCase(TSA[1]);
      TSA[1] := ' ';
      TSA[2] := ' ';
      str := TSAtoString(TSA);
      str := StringReplace(str, ' ', '', [rfReplaceAll]);
      solutions[ii] := solveall(str, showsteps);
      result := variables[ii] + '=' + solutions[ii];
      exit;
    end;

    if (AnsiLowerCase(TSA[1]) = 'exit') or (AnsiLowerCase(TSA[1]) = 'quit') then
      Halt;
    if AnsiLowerCase(TSA[1]) = 'help' then
    begin
      help;
      exit;
    end;
    if AnsiLowerCase(TSA[1]) = 'variables' then
    begin
      j := 1;
      while variables[j] <> '' do
      begin
        Writeln('  : ', variables[j], ' = ', solutions[j]);
        inc(j);
      end;
      exit;
    end;
    if AnsiLowerCase(TSA[1]) = 'reset' then
    begin
      variables := cleararray(variables);
      solutions := cleararray(solutions);
      Writeln('The variables values are now cleared!');
      exit;
    end;
    str := solveall(str, showsteps);
    Result := str;
  end;
end;

procedure help;
begin
  Writeln;
  writeln(' >> The supported functions are: sin, cos, tan, exp, ln, log, sqrt.');
  writeln(' >> The following constants are included: pi=3.141...; phi=1.618...');
  Writeln(' >> You can assign up to 256 variables of your own. ');
  Writeln(' >> To view the variables type VARIABLES.');
  Writeln(' >> To clear the variables type RESET.');
  Writeln(' >> To exit the program type EXIT.');
  Writeln;
  Writeln(' >> You can enter multiple expressions at once separating them by ";"');
  Writeln(' >> For example:');
  Writeln(' >> a=1;b=2;c=1;x=-(b+sqrt(4*a*c-b*b))/(2*a)');

end;
end.

