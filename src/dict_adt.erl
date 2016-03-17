-module(dict_adt).
-export([get/2, update/3, iterator/1, add_all/2, to_list/1, insert/3, srvGet/2, rpc/2]).
-include("dict.hrl").
-include("iterator.hrl").
-include("bstdict.hrl").
-include("srvdict.hrl").

%Return value stored for Key in dictionary Dict.
get(BDict, Key) when is_record(BDict, bstdict) -> Get1 = BDict#bstdict.get, Get1(BDict#bstdict.data,Key); 
get(SDict, Key) when is_record(SDict, srvdict) -> {_,Val}=srvGet(SDict,Key), Val;
get(Dict, Key) when is_record(Dict, dict) -> Get = Dict#dict.get, Get(Dict#dict.data, Key).

%Update value stored for Key in dictionary Dict, returning updated
%data representation.  Update1 is a function which takes the current
%value stored for Key and returns the new value.  If the Key is not
%present, then Update1 will be called with value [].
update(Dict, Key, Update1)  when is_record(Dict, dict) -> Update = Dict#dict.update, Dict#dict{data=Update(Dict#dict.data, Key, Update1)};
update(SDict, Key, Val)  when is_record(SDict, srvdict) -> {PID,NewData} = srvUpdate(SDict,Key,Val), hotUpdate(SDict,NewData), io:format("Updated the Value for : ~p.", [Key]). %%("Updated").   %%SDict#srvdict{data=NewData}.


insert(Bst,Key,Value) ->
	Insert = Bst#bstdict.insert,
	Bst#bstdict{data=Insert(Bst#bstdict.data,Key,Value)}.

%Returns a iterator for Dict which produces {Key, Value} pairs.
iterator(Dict) ->
    Iterator = Dict#dict.iterator,
    Iterator(Dict#dict.data).
	
srvGet(ServerDict, Key) -> rpc(ServerDict#srvdict.pid,{get,ServerDict,Key}).
srvUpdate(ServerDict, Key, Value) -> rpc(ServerDict#srvdict.pid,{update,ServerDict,Key,Value}).
hotUpdate(ServerDict,NewDictionary) -> rpc(ServerDict#srvdict.pid,{replace,NewDictionary}).
srvprint(ServerDict) -> {Pid,ListData} = rpc(ServerDict#srvdict.pid,{list,ServerDict#srvdict.data}), ListData.
srvInsert(ServerDict,Key,Value) -> rpc(ServerDict#srvdict.pid,{insert,Key,Value}).

rpc(Pid, Request) ->
	Pid ! {self(),Request},
	receive
	    {Pid, Msg} ->
		{Pid, Msg}
	end.

getHello() -> "HE!!!".

%A convenience function function which adds all {Key, Value} pairs in
%2nd argument to Dict.  The 2nd argument can be either a list of {Key,
%Value} pairs or a iterator which produces {Key, Value} pairs.
add_all(Dict, []) ->
    Dict;
add_all(SDict, [{K,V}|Rest]) when is_record(SDict, srvdict) -> srvInsert(SDict,K,V),add_all(SDict,Rest),io:format(" Added to Dictionary : ~p.",[K]);
add_all(Dict, [{K, V}|Rest]) ->
  add_all(update(Dict, K, fun(_) -> V end), Rest);
add_all(Bst, Iterator) when is_record(Bst, bstdict) -> add_Bst(Bst,Iterator);

%%add_all(SDict, [{K,V}|Rest]) when is_record(SDict, srvdict)
add_all(Dict, Iterator) when is_record(Iterator, iterator) ->
    add_all_iterator(Dict, Iterator).
	
add_Bst(Bst,Iterator) ->
	case iterator:has_next(Iterator) of
	true ->
	    {K, V} = iterator:get_next(Iterator),
	    add_Bst(insert(Bst, K, V),
			     iterator:advance(Iterator));
	false -> Bst
     end.

add_all_iterator(Dict, Iterator) ->
    case iterator:has_next(Iterator) of
	true ->
	    {K, V} = iterator:get_next(Iterator),
	    add_all_iterator(update(Dict, K, fun(_) -> V end),
			     iterator:advance(Iterator));
	false -> Dict
     end.
						      
%A convenience function which produces a list of all {Key, Value} pairs
%contained in Dict.
to_list(SDict) when is_record(SDict, srvdict) -> srvprint(SDict); 
to_list(Dict) -> I = iterator(Dict),iterator:to_list(I).

				  