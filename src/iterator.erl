-module(iterator).
-export([has_next/1, get_next/1, advance/1, to_list/1]).
-include("iterator.hrl").

%Return true iff Iterator can yield another value.
has_next(Iterator) ->
    HasNext = Iterator#iterator.has_next,
    HasNext(Iterator#iterator.state).

%Return next value from iterator.  
%Precondition: has_next(Iterator) returns true.
get_next(Iterator) ->
    GetNext = Iterator#iterator.get_next,
    GetNext(Iterator#iterator.state).

%Advance iterator over current element returning updated iterator.  
%Precondition has_next(Iterator) returns true.
advance(Iterator) ->
    Advance = Iterator#iterator.advance,
    Iterator#iterator{state=Advance(Iterator#iterator.state)}.

to_list(Iterator) ->
    case has_next(Iterator) of
	false -> [];
	true ->
	    [get_next(Iterator)|to_list(advance(Iterator))]
    end.
				  
    