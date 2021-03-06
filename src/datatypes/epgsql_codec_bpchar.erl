%%% @doc
%%% Codec for `bpchar', `char' (CHAR(N), char).
%%% ```SELECT 1::char''' ```SELECT 'abc'::char(10)'''
%%% For 'text', 'varchar' see epgsql_codec_text.erl.
%%% https://www.postgresql.org/docs/10/static/datatype-character.html
%%% $PG$/src/backend/utils/adt/varchar.c
%%% @end
%%% Created : 12 Oct 2017 by Sergey Prokhorov <me@seriyps.ru>

-module(epgsql_codec_bpchar).
-behaviour(epgsql_codec).

-export([init/2, names/0, encode/3, decode/3, decode_text/3]).

-export_type([data/0]).

-type data() :: binary() | byte().

init(_, _) -> [].

names() ->
    [bpchar, char].

encode(C, _, _) when is_integer(C), C =< 255 ->
    <<C:1/big-unsigned-unit:8>>;
encode(Bin, bpchar, _) when is_binary(Bin) ->
    Bin;
encode(Str, bpchar, _) when is_list(Str) ->
    %% See epgsql_codec_text:encode/3
    try iolist_size(Str) of
        _ -> Str
    catch error:badarg ->
            unicode:characters_to_binary(Str)
    end.

decode(<<C:1/big-unsigned-unit:8>>, _, _) -> C;
decode(Bin, bpchar, _) -> Bin.

decode_text(V, _, _) -> V.
