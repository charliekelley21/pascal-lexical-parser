Program parseSentence (input, output);
    {
      description of Project 1:
    }

    const
        { chararacter classifications }
        LETTER = 0;
        DIGIT = 1;
        UNKNOWN = 8;
        EOL = 9;        { end of input line }

        { token constants }
        VERB_t = 10;
        ADV_t = 11;
        NOUN_t = 12;
        ADJ_t = 13;
        PREP_t = 14;

    var
        { lexical analysis variables }
        line  : string;
        line_ind : integer = 1;
        char_class : integer = UNKNOWN;
        next_lexeme : string = '';
        next_token : integer = UNKNOWN;

        { system control variables }
        failed_parse : boolean = false;
        output  : ansistring = '';
        error_msg : string = '';

{ lexical analyzer methods }
procedure lexical; forward;
function identifyChar ( ind : integer ) : integer; forward;
procedure getLexeme ( start, length : integer ); forward;
procedure lookup ( lexeme : string ); forward;
procedure getNonBreak; forward;
procedure getChar; forward;
{ System I/O and error methods }
procedure appendOutput ( addend : string ); forward;
procedure appendLexeme ( lexeme : string ); forward;
procedure error ( msg : string ); forward;
procedure sentence_setup; forward;
{ recursive decent mthods }
procedure sent; forward;
procedure subject; forward;
procedure noun_phrase; forward;
procedure adj_phrase; forward;
procedure adj; forward;
procedure noun; forward;
procedure prep_phrase; forward;
procedure prep; forward;
procedure verb_phrase; forward;
procedure verb; forward;
procedure adv; forward;
procedure obj; forward;

{ ------------------------------------------------------------------------------
    Lexical Analyzier
-------------------------------------------------------------------------------}
procedure lexical;
var
    lexLength : integer = 0;
    start : integer;
begin
    getNonBreak;
    getChar;
    start := line_ind - 1;
    if ( char_class = LETTER ) then
    begin
        lexLength := lexLength + 1;
        getChar;
        while ((char_class = LETTER) or (char_class = DIGIT)) do
        begin
            lexLength := lexLength + 1;
            getChar;
        end; { end while loop }
    end { end if branch }
    else if char_class = DIGIT then
    begin
        lexLength := lexLength + 1;
        getChar;
        while char_class = DIGIT do
        begin
            lexLength := lexLength + 1;
            getChar;
        end; { end while loop }
    end; { end else if branch }
    getLexeme(start, lexLength);
end; { end lexical function }

procedure getLexeme( start, length : integer );
begin
    if length = 0 then
        next_lexeme := 'EOL'
    else
        next_lexeme := copy(line, start, length);
    lookup( next_lexeme );
end;

procedure lookup( lexeme : string );
begin
    case lexeme of
        'green',
        'mean',
        'lean'          : next_token := ADJ_t;
        'lifted',
        'saw',
        'found'         : next_token := VERB_t;
        'quickly',
        'carefully',
        'brilliantly'   : next_token := ADV_t;
        'cow',
        'alice',
        'book'          : next_token := NOUN_t;
        'of',
        'at',
        'with'          : next_token := PREP_t;
        'EOL'           : next_token := EOL;
    else
        error('Input has invalid tokens.');
    end;
end;

procedure getNonBreak;
begin
    while line[line_ind] = ' ' do
        line_ind := line_ind + 1;
end;

function identifyChar ( ind : integer ) : integer;
begin
    if ( line[ind] in ['a'..'z', 'A'..'Z'] ) then
        identifyChar := LETTER
    else if ( line[ind] in ['0'..'9'] ) then
        identifyChar := DIGIT
    else
        identifyChar := UNKNOWN;
end;

procedure getChar;
begin
    if line_ind <= byte(line[0]) then
        char_class := identifyChar(line_ind)
    else
        char_class := EOL;
    line_ind := line_ind + 1;
end;

{-------------------------------------------------------------------------------
    Recursive decent methods
-------------------------------------------------------------------------------}

procedure sent;
begin
    if ( failed_parse ) then
        exit;
    appendOutput('(');
    subject;
    verb_phrase;
    obj;
    appendOutput(')');
end;

procedure subject;
begin
    if ( failed_parse ) then
        exit;
    appendOutput('(');
    noun_phrase;
    appendOutput(') ');
end;

procedure noun_phrase;
begin
    if ( failed_parse ) then
        exit;
    appendOutput('(');
    adj_phrase;
    noun;
    prep_phrase;
    appendOutput(')');
end;

procedure adj_phrase;
begin
    if ( failed_parse ) then
        exit;
    if ( next_token = ADJ_t ) then
    begin
        appendOutput('(');
        adj;
        adj_phrase;
        appendOutput(')');
    end;
end;

procedure adj;
begin
    if ( failed_parse ) then
        exit;
    if ( next_token = ADJ_t ) then
    begin
        appendLexeme(next_lexeme);
        lexical;
    end
    else
        error('Input is not a sentence.');
end;

procedure noun;
begin
    if ( failed_parse ) then
        exit;
    if ( next_token = NOUN_t ) then
    begin
        appendLexeme(next_lexeme);
        lexical;
    end
    else
        error('Input is not a sentence.');
end;

procedure prep_phrase;
begin
    if ( failed_parse ) then
        exit;
    if ( next_token = PREP_t ) then
    begin
        appendOutput('(');
        prep;
        noun_phrase;
        appendOutput(')');
    end;
end;

procedure prep;
begin
    if ( failed_parse ) then
        exit;
    if ( next_token = PREP_t ) then
    begin
        appendLexeme(next_lexeme);
        lexical;
    end
    else
        error('Input is not a sentence.');
end;

procedure verb_phrase;
begin
    if ( failed_parse ) then
        exit;
    appendOutput('(');
    verb;
    adv;
    appendOutput(') ');
end;

procedure verb;
begin
    if ( failed_parse ) then
        exit;
    if ( next_token = VERB_t ) then
    begin
        appendLexeme(next_lexeme);
        lexical;
    end
    else
        error('Input is not a sentence.');
end;

procedure adv;
begin
    if ( failed_parse ) then
        exit;
    if ( next_token = ADV_t ) then
    begin
        appendLexeme(next_lexeme);
        lexical;
    end
end;

procedure obj;
begin
    if ( failed_parse ) then
        exit;
    appendOutput('(');
    noun_phrase;
    appendOutput(')');
end;

{-------------------------------------------------------------------------------
    Helper Functions
-------------------------------------------------------------------------------}

procedure error ( msg : string );
begin
    failed_parse := true;
    error_msg := msg;
end;

procedure appendOutput ( addend : string );
begin
    output := output + addend;
end;

procedure appendLexeme ( lexeme : string );
begin
    output := output + '"';
    output := output + lexeme;
    output := output + '"';
end;

procedure sentence_setup;
begin
    line_ind := 1;
    output := '';
    error_msg := '';
    failed_parse := false;
end;

{-------------------------------------------------------------------------------
    Main Program
-------------------------------------------------------------------------------}
begin
    sentence_setup;
    while true do
    begin
        { get sentence to test }
        readln(line);

        { initalize everything }
        getNonBreak;
        lexical;

        { parse sentence }
        sent;
        if ( (next_token <> EOL) and not failed_parse) then
            error('Input is not a sentence.');

        { output or error msg displayed }
        if ( failed_parse ) then
            writeln(error_msg)
        else
            writeln(output);

        sentence_setup;

    end;

end.
