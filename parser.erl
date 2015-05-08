-module(parser).
-compile(export_all).


extract_by_index(Code, {Begin, Length}) ->
    string:substr(Code, Begin + 1, Length).


extract_indexes(Code, MatchedIndex, CodeIndex) ->
    {extract_by_index(Code, MatchedIndex), extract_by_index(Code, CodeIndex)}.


ast_match_number(Code) ->
    case re:run(Code, "^([0-9]+)(.*)", [global]) of
        {match, [Matches|_]} ->
            [_AllMatched, MatchedIndex, CodeIndex] = Matches,
            {TxtNumber, RestOfCode} = extract_indexes(Code, MatchedIndex, CodeIndex),
            NumberValue = list_to_integer(TxtNumber),
            Token = {number, [{value, NumberValue}]},
            {Token, RestOfCode};
        nomatch ->
            ok
    end.


ast_match_operator(Code) ->
    case re:run(Code, "^(\\+)(.*)", [global]) of
        {match, [Matches|_]} ->
            [_AllMatched, MatchedIndex, CodeIndex] = Matches,
            {TxtOperator, RestOfCode} = extract_indexes(Code, MatchedIndex, CodeIndex),
            Token = {operator, [{value, TxtOperator}]},
            {Token, RestOfCode};
        nomatch ->
            ok
    end.


ast_match_binary_operation(Code) ->
    {Left, RestOfExpr} = ast_match_number(Code),
    {Operator, RestOfExpr1} = ast_match_operator(RestOfExpr),
    {Right, RestOfCode} = ast_match_number(RestOfExpr1),
    Token = {binary_op, [Operator, Left, Right]},
    {Token, RestOfCode}.


async_ast_match_number(CallerPid, Code) ->
    case ast_match_number(Code) of
        {{number, _}, _RestOfCode} = Result ->
            CallerPid ! {self(), Result};
        ok ->
            CallerPid ! {self(), nomatch};
        Debug ->
            io:format("~p", [Debug])
    end.


async_ast_match_binary_operation(CallerPid, Code) ->
    case ast_match_binary_operation(Code) of
        {{binary_op, _}, _RestOfCode} = Result ->
            CallerPid ! {self(), Result};
        ok ->
            CallerPid ! {self(), nomatch}
    end.


async_ast_match_root(CallerPid, Code) ->
    process_flag(trap_exit, true),
    BinaryOpPid = spawn_link(?MODULE, async_ast_match_binary_operation, [self(), Code]),
    NumberPid = spawn_link(?MODULE, async_ast_match_number, [self(), Code]),
    listen_reply(CallerPid, BinaryOpPid, NumberPid).


listen_reply(CallerPid, BinaryOpPid, NumberPid) ->
    receive
        {BinaryOpPid, {{binary_op, _}, _RestOfCode} = Result} ->
            CallerPid ! {self(), Result};
        {NumberPid, {{number, _}, _RestOfCode} = Result} ->
            CallerPid ! {self(), Result};
        {_, nomatch} ->
            listen_reply(CallerPid, BinaryOpPid, NumberPid)
    end.


parse("") ->
    {root, nil};

parse(BinaryCode) when is_binary(BinaryCode) ->
    parse(binary_to_list(BinaryCode));

parse(Code) ->
    AstPid = spawn_link(?MODULE, async_ast_match_root, [self(), Code]),
    receive
        {AstPid, Result} ->
            Result
    after
        2000 ->
            timeout
    end.
