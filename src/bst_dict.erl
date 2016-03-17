-module(bst_dict).
-export([bst_dict/0]).
-include("bstdict.hrl").
-include("iterator.hrl").

%returns an empty dictionary.
bst_dict() ->
    #bstdict{get = fun get/2, insert = fun insert/3, iterator = fun iterator/1, 
	  data = {}}.

get({}, _Key) -> {};
get({Key, Value,T1,T2}, Key) -> Value;
get({Key, Value,T1,T2}, MyKey) when MyKey >= Key -> get(T2,MyKey);
get({Key, Value,T1,T2}, MyKey) -> get(T1,Key).


insert({},Key, Value) -> {Key,Value,{},{}};
insert({Key,Value,T1,T2},MyKey,MyValue) when MyKey >= Key ->{Key,Value,T1,insert(T2,MyKey,MyValue)};
insert({Key,Value,T1,T2},MyKey,MyValue) ->{Key,Value,insert(T1,MyKey,MyValue),T2}.


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
