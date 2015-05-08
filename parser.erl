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
            throw(nomatch)
    end.

ast_match_operator(Code) ->
    case re:run(Code, "^(\\+)(.*)", [global]) of
        {match, [Matches|_]} ->
            [_AllMatched, MatchedIndex, CodeIndex] = Matches,
            {TxtOperator, RestOfCode} = extract_indexes(Code, MatchedIndex, CodeIndex),
            Token = {operator, [{value, TxtOperator}]},
            {Token, RestOfCode};
        nomatch ->
            throw(nomatch)
    end.


ast_match_binary_operation(Code) ->
    {Left, RestOfExpr} = ast_match_number(Code),
    {Operator, RestOfExpr1} = ast_match_operator(RestOfExpr),
    {Right, RestOfCode} = ast_match_number(RestOfExpr1),
    Token = {binary_op, [Operator, Left, Right]},
    {Token, RestOfCode}.


ast_match_root(Code) ->
    try ast_match_binary_operation(Code) of
        {Ast, RestOfCode} ->
            {{root, Ast}, RestOfCode}
    catch
        nomatch ->
            try ast_match_number(Code) of
                {Ast, RestOfCode} ->
                    {{root, Ast}, RestOfCode}
            catch
                nomatch ->
                    {{root, nil}, Code}
            end
    end.


parse(BinaryCode) when is_binary(BinaryCode) ->
    parse(binary_to_list(BinaryCode));

parse(Code) ->
    {AstTree, _UnParsedCode} = ast_match_root(Code),
    AstTree.
