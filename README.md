# Async Parser - Asyncronous parsing made easy

```warn
Note: This project is just a playgorund for now. Use by your own reponsability.
```

Async parser is a experiment that has objective of verifying if it is possible and how performatic whould be to
create a parser that takes advantage of the multi-core achitecture that is becaming
commonly found in all dipositives we use in our everyday life (phones/desktop/notebooks/etc).

To achive that I decided to use Erlang for two reasons: I want to learn more about Erlang language; and that it is easy to work with multiprocessing in Erlang.

If you have any suggestion or ideas, please contact me on [@rafaelcaricio](http://twitter.com/rafaelcaricio). I will be happy to hear from you. :)


## Current implementation

It's a playground and I just want to play witht he possibilities for now. Maybe at some
point I may make it as a generic parser. For now I want to parse simple mathematical
expresisons just as proof of concept.

## How to run it

Please [install Erlang](https://www.erlang-solutions.com/downloads/download-erlang-otp). Then open cosole and run:

```
$ make
```


### Ideas to play with

- You can also spawn process (instead of try catch) to parse those code blocks
- You can add a tokens message queue to make people listen to types of tokens
- You can see how to read a stream and parse the stream
