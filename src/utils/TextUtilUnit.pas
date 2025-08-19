unit TextUtilUnit;

interface

uses
  System.SysUtils, System.RegularExpressions, System.Classes, 
  System.StrUtils, System.Character;

type
  TTextUtil = class
  private
    const
      PUNC_EOS_STR = '.!?。！？';
      MEDIUM_THRESHOLD = 60;
  public
    const
      SHORT_THRESHOLD = 30;
      LONG_THRESHOLD = 200;
      VERYLONG_THRESHOLD = 400;
      PUNC_EOS: array[0..5] of Char = ('.', '!', '?', '。', '！', '？');
    
    class function PreprocessText(const Text: string): string;
    class function ReplaceNewlines(const Text: string; Threshold: Integer): string;
    class function ShortenDisplaySentence(const Text: string; MaxLength: Integer): string;
    class function ExtractTargetSentence(const Text: string): string;
    class function RemoveNoticePrefix(const Text: string): string;
    class function GetByteCount(const Text: string): Integer;
    class function GetLastSentenceStart(const Text: string): Integer;
    class function GetLastSentenceEnd(const Text: string): Integer;
    class function IsCompleteSentence(const Text: string): Boolean;
    class function IsEndOfSentence(C: Char): Boolean;
    class function IsCJChar(C: Char): Boolean;
    class function Similarity(const Text1, Text2: string): Double;
  end;

implementation

uses
  System.Math;

{ TTextUtil }

class function TTextUtil.ExtractTargetSentence(const Text: string): string;
var
  Regex: TRegEx;
  Match: TMatch;
begin
  // Extract text between <[ and ]>
  Regex := TRegEx.Create('<\[(.*?)\]>', [roIgnoreCase]);
  Match := Regex.Match(Text);
  if Match.Success then
    Result := Match.Groups[1].Value
  else
    Result := Text;
end;

class function TTextUtil.GetByteCount(const Text: string): Integer;
begin
  Result := Length(TEncoding.UTF8.GetBytes(Text));
end;

class function TTextUtil.GetLastSentenceEnd(const Text: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Length(Text) downto 1 do
  begin
    if IsEndOfSentence(Text[I]) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

class function TTextUtil.GetLastSentenceStart(const Text: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Length(Text) - 1 downto 1 do
  begin
    if IsEndOfSentence(Text[I]) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

class function TTextUtil.IsCompleteSentence(const Text: string): Boolean;
begin
  Result := (Length(Text) > 0) and IsEndOfSentence(Text[Length(Text)]);
end;

class function TTextUtil.IsCJChar(C: Char): Boolean;
begin
  // Check if character is Chinese, Japanese, or Korean
  Result := TCharacter.GetUnicodeCategory(C) in [
    TUnicodeCategory.ucOtherLetter,
    TUnicodeCategory.ucModifierLetter
  ];
  
  // More specific check for CJK ranges
  if not Result then
  begin
    case Ord(C) of
      $4E00..$9FFF,   // CJK Unified Ideographs
      $3400..$4DBF,   // CJK Extension A
      $20000..$2A6DF, // CJK Extension B
      $2A700..$2B73F, // CJK Extension C
      $2B740..$2B81F, // CJK Extension D
      $3040..$309F,   // Hiragana
      $30A0..$30FF,   // Katakana
      $AC00..$D7AF:   // Hangul Syllables
        Result := True;
    end;
  end;
end;

class function TTextUtil.IsEndOfSentence(C: Char): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(PUNC_EOS) to High(PUNC_EOS) do
  begin
    if C = PUNC_EOS[I] then
    begin
      Result := True;
      Break;
    end;
  end;
end;

class function TTextUtil.PreprocessText(const Text: string): string;
var
  RegexAcronym, RegexAcronymWords, RegexPuncSpace, RegexCJPuncSpace: TRegEx;
begin
  Result := Text;
  
  // Apply various regex replacements
  RegexAcronym := TRegEx.Create('([A-Z])\.([A-Z])', [roIgnoreCase]);
  Result := RegexAcronym.Replace(Result, '$1$2');
  
  RegexAcronymWords := TRegEx.Create('([A-Z]{2,})([a-z])', [roIgnoreCase]);
  Result := RegexAcronymWords.Replace(Result, '$1 $2');
  
  RegexPuncSpace := TRegEx.Create('([.!?])([A-Za-z])', [roIgnoreCase]);
  Result := RegexPuncSpace.Replace(Result, '$1 $2');
  
  RegexCJPuncSpace := TRegEx.Create('([。！？])([^\s])', [roIgnoreCase]);
  Result := RegexCJPuncSpace.Replace(Result, '$1$2');
  
  // Replace redundant newlines within sentences
  Result := ReplaceNewlines(Result, MEDIUM_THRESHOLD);
end;

class function TTextUtil.RemoveNoticePrefix(const Text: string): string;
var
  Regex: TRegEx;
begin
  // Remove patterns like [123 ms], [ERROR], [WARNING], etc.
  Regex := TRegEx.Create('^\[(.*?)\]\s*', [roIgnoreCase]);
  Result := Regex.Replace(Text, '');
end;

class function TTextUtil.ReplaceNewlines(const Text: string; Threshold: Integer): string;
var
  Lines: TStringList;
  I: Integer;
  CurrentLine: string;
  Replacement: string;
begin
  Result := Text;
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
    if Lines.Count <= 1 then
      Exit;
      
    for I := 0 to Lines.Count - 1 do
    begin
      CurrentLine := Trim(Lines[I]);
      if (CurrentLine <> '') and (GetByteCount(CurrentLine) < Threshold) then
      begin
        // Determine replacement based on last character
        if (Length(CurrentLine) > 0) and IsEndOfSentence(CurrentLine[Length(CurrentLine)]) then
          Replacement := ' '
        else if IsCJChar(CurrentLine[Length(CurrentLine)]) then
          Replacement := '，'
        else
          Replacement := ', ';
          
        // Replace newline with appropriate punctuation
        Result := StringReplace(Result, #13#10 + CurrentLine, Replacement + CurrentLine, []);
        Result := StringReplace(Result, #10 + CurrentLine, Replacement + CurrentLine, []);
      end;
    end;
  finally
    Lines.Free;
  end;
end;

class function TTextUtil.ShortenDisplaySentence(const Text: string; MaxLength: Integer): string;
begin
  Result := Text;
  if GetByteCount(Result) > MaxLength then
  begin
    // Truncate and add ellipsis
    while GetByteCount(Result + '...') > MaxLength do
    begin
      if Length(Result) <= 1 then
        Break;
      Result := Copy(Result, 1, Length(Result) - 1);
    end;
    Result := Result + '...';
  end;
end;

class function TTextUtil.Similarity(const Text1, Text2: string): Double;
var
  Len1, Len2, MaxLen, Distance: Integer;
  
  function LevenshteinDistance(const S1, S2: string): Integer;
  var
    I, J: Integer;
    Cost: Integer;
    D: array of array of Integer;
  begin
    SetLength(D, Length(S1) + 1, Length(S2) + 1);
    
    for I := 0 to Length(S1) do
      D[I, 0] := I;
    for J := 0 to Length(S2) do
      D[0, J] := J;
      
    for I := 1 to Length(S1) do
    begin
      for J := 1 to Length(S2) do
      begin
        if S1[I] = S2[J] then
          Cost := 0
        else
          Cost := 1;
          
        D[I, J] := Min(
          D[I - 1, J] + 1,        // deletion
          Min(
            D[I, J - 1] + 1,      // insertion
            D[I - 1, J - 1] + Cost // substitution
          )
        );
      end;
    end;
    
    Result := D[Length(S1), Length(S2)];
  end;
  
begin
  Len1 := Length(Text1);
  Len2 := Length(Text2);
  
  if (Len1 = 0) and (Len2 = 0) then
  begin
    Result := 1.0;
    Exit;
  end;
  
  if (Len1 = 0) or (Len2 = 0) then
  begin
    Result := 0.0;
    Exit;
  end;
  
  MaxLen := Max(Len1, Len2);
  Distance := LevenshteinDistance(Text1, Text2);
  Result := 1.0 - (Distance / MaxLen);
end;

end.