-module(parser_tests).
-compile(export_all).


test_parse_empty() ->
    Input = <<"">>,
    ExpectedOutput = {root, nil},
    ExpectedOutput =:= parser:parse(Input).


test_parse_number() ->
    Input = <<"1">>,
    ExpectedOutput = {root, {number, [{value, 1}]}},
    ExpectedOutput =:= parser:parse(Input).


test_parse_long_number() ->
    Input = <<"151">>,
    ExpectedOutput = {root, {number, [{value, 151}]}},
    ExpectedOutput =:= parser:parse(Input).


test_parse_binary_operation() ->
    Input = <<"1+2">>,
    {root, {binary_op, [{operator, _}, {number, _}, {number, _}]}} = parser:parse(Input).


run_all() ->
    test_parse_empty(),
    test_parse_binary_operation(),
    test_parse_number().
