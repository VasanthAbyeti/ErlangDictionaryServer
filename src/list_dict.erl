-module(list_dict).
-export([list_dict/0]).
-include("dict.hrl").
-include("iterator.hrl").

%returns an empty dictionary.
list_dict() ->
    #dict{get = fun get/2, update = fun update/3, iterator = fun iterator/1, 
	  data = []}.

get([], _Key) -> [];
get([{Key, Value}|_], Key) -> Value;
get([_|Rest], Key) -> get(Rest, Key).

update([], Key, Update) ->
    [{Key, Update([])}];
update([{Key, Value}|Rest], Key, Update) ->
    [{Key, Update(Value)}|Rest];
update([Pair|Rest], Key, Update) ->
    [Pair|update(Rest, Key, Update)].

iterator(List) ->
    #iterator{has_next = fun has_next/1, get_next = fun get_next/1,
	      advance = fun advance/1, state = List}.

has_next([]) ->
    false;
has_next([_|_]) ->
    true.

get_next([Pair|_]) ->
    Pair.

advance([_|Rest]) ->
    Rest.
