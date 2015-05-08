all: compile run

compile:
	erlc parser.erl parser_tests.erl

run:
	erl -noshell -s parser_tests run_all -s init stop
