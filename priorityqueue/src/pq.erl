-module(pq).
-export([start/0, node/3]).
% args: -- num -inputdir -- thread_num
start() ->
    Root = spawn(pq, node, [0, self(), 0]),
    {ok, [Path | _]} = init:get_argument(inputdir),
    [Arg1 | _]= init:get_plain_arguments(),
    File = string:concat(Path, Arg1),
    {ok, Binary} = file:read_file(File),
    Lines = string:tokens(erlang:binary_to_list(Binary), "\n"),
    Numbers = lists:map(fun(X) -> {Int, _} = string:to_integer(X), Int end, Lines),
    evmrepeat(100, Numbers, Root, list_to_integer(Arg1)).  

evmrepeat(1, Numbers, Root, Arg1)->
    add_num(Numbers, Root), 
    remove(Arg1, Root);
evmrepeat(N, Numbers, Root, Arg1)->
    add_num(Numbers, Root), 
    remove(Arg1, Root),
    evmrepeat(N-1, Numbers, Root, Arg1).


remove(1, Root)->
    Root ! remove,
    receive
        {remove_ret, _, _}->
            true
            %io:format("Smallest ~p~n", [Val])
    end;
remove(Num, Root)->
    Root ! remove,
    receive
        {remove_ret, _, _} ->
            true
            %io:format("Smallest ~p~n", [Val])
    end,
    remove(Num - 1, Root).

add_num([F], Root)->
    Root ! {add, F};
add_num([F | Rest], Root)->
    Root ! {add, F},
    add_num(Rest, Root).    
                
node(Val, From, To) ->
    receive
        {add, Value_add} ->
            if To == 0 ->
                node(Value_add, From, spawn(pq, node, [0, self(), 0]));
            true ->
                To ! {add, max(Val, Value_add)},
                node(min(Val, Value_add), From, To)
            end;
        remove ->
            if To == 0 ->
                From ! {remove_ret, Val, 0};
            true ->
                From ! {remove_ret, Val, self()},
                To ! remove,
                receive
                    {remove_ret, V, To_new} ->
                        node(V, From, To_new)
                end
            end
    end.