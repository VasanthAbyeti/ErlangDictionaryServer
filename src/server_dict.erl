-module(server_dict).
-export([server_dict/1, replace/2, print/2]).
-include("srvdict.hrl").
-include("iterator.hrl").
-include("dict.hrl").
-include("bstdict.hrl").


	
insertBst(Bst,Key,Value) ->
	Insert = Bst#bstdict.insert,
	Bst#bstdict{data=Insert(Bst#bstdict.data,Key,Value)}.
	
add_Bst(Bst,Iterator) ->
	case iterator:has_next(Iterator) of
	true ->
	    {K, V} = iterator:get_next(Iterator),
	    add_Bst(insertBst(Bst, K, V),
			     iterator:advance(Iterator));
	false -> Bst
     end.
	

%returns an empty dictionary.
server_dict(LDict) ->
	%%Pid = spawn(server_dict, loop, [{}]),
	BDict = #bstdict{get = fun get/2, insert = fun insert/3, iterator = fun iterator/1, 
	  data = {}},
	BDict1 = add_Bst(BDict,iterator(LDict#dict.data)),
	Pid = strt(BDict1#bstdict.data),
    #srvdict{get = fun get/2, insert = fun insert/3, iterator = fun iterator/1, pid = Pid,
	  data = BDict1#bstdict.data}.
	  
	  
	  
strt(HD) ->
	spawn(fun() -> loop(HD) end).

go1(Pid, Request) ->

	Pid ! {self(), Request},
	receive
		{Pid, Msg,_} -> io:format(Msg)
	end,
	Pid ! stop.
	
go(Pid, Request) ->
	Pid ! {self(),Request},
	receive
	    {Pid, Msg} ->
		{Pid, Msg}
	end.


replace(SDict,NewSDict) -> go(SDict#srvdict.pid,{replace, NewSDict#srvdict.data}).

getHello() -> "HELLLLLOOOOOOOOW!!!".

loop(HD) ->
	HotDictionary = HD,
	receive
		{From, {test}} ->
		From ! {self(), HotDictionary},
		loop(HotDictionary);
		{From, {get, Bst, A}} ->
		From ! {self(), get(HotDictionary,A)},     %%get(Bst#srvdict.data,A)},
		loop(HotDictionary);
		{From, {update, SBst, A, V}} ->
		From ! {self(), update(SBst#srvdict.data,A,V)},
		loop(HotDictionary);
		{From, {replace, NewDictionary}} ->
		From ! {self(), "Updated!"},
		loop(NewDictionary);
		{From, {insert, K, V}} ->
		From ! {self(), "Updates!"},
		NewHD = insert(HotDictionary,K,V),
		loop(NewHD);
		{From, {list, Dict}} ->
		From ! {self(),print(HD,[])},
		loop(HotDictionary);
		stop ->
		true
	end.



	
serve()->
	receive
	{From, 0} ->
	  From ! io:format("P1 ~w~n")
 %%"RECIEVED THE MESSAGE" %get(T,K)
	end.

get({}, _Key) -> {};
get({Key, Value,T1,T2}, Key) -> Value;
get({Key, Value,T1,T2}, MyKey) when MyKey >= Key -> get(T2,MyKey);
get({Key, Value,T1,T2}, MyKey) -> get(T1,Key).


update({},Key, Value) -> {Key,Value,{},{}};
update({Key,Value,T1,T2},MyKey,MyValue) when MyKey > Key ->{Key,Value,T1,update(T2,MyKey,MyValue)};
update({Key,Value,T1,T2},Key,MyValue)->{Key,MyValue,T1,T2};
update({Key,Value,T1,T2},MyKey,MyValue) when MyKey < Key ->{Key,Value,update(T1,MyKey,MyValue),T2}.



insert({},Key, Value) -> {Key,Value,{},{}};
insert({Key,Value,T1,T2},MyKey,MyValue) when MyKey >= Key ->{Key,Value,T1,insert(T2,MyKey,MyValue)};
insert({Key,Value,T1,T2},MyKey,MyValue) ->{Key,Value,insert(T1,MyKey,MyValue),T2}.


print({},List) -> List;
print({Key,Value,T1,T2},List) -> [{Key,Value}]++List++print(T1,[])++print(T2,[]).


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
