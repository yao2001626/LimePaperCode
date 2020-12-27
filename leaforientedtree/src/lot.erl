-module(lot).
-export([start/0, node/3]).

start()->
    Root = spawn(lot, node, [5000,0,0]),
    {ok, [Path | _]} = init:get_argument(inputdir),
    [Arg1 | _] = init:get_plain_arguments(),
    File = string:concat(Path, Arg1),
    {ok, Binary} = file:read_file(File),
    Lines = string:tokens(erlang:binary_to_list(Binary), "\n"),
    Numbers = lists:map(fun(X) -> {Int, _} = string:to_integer(X), Int end, Lines),
    %io:format("Read ~p ~n", [Lines]),
    evmrepeat(100, Numbers, Root).

evmrepeat(1, Numbers, Root)->
    add_num(Numbers, Root),
    has_num(Numbers, Root);
evmrepeat(N, Numbers, Root)->
    add_num(Numbers, Root),
    has_num(Numbers, Root),
    evmrepeat(N - 1, Numbers, Root).

has_num([], _) ->
    ok;
has_num([H | Rest], Root) ->
    Root ! {has, H, self()},
    receive
        {has_result, _} ->
            true
    end,
    has_num(Rest, Root).


add_num([], _) ->
    ok;
add_num([F | Rest], Root) ->
    Root ! {add, F},
    add_num(Rest, Root).

node(Key, Left, Right) ->
    receive
        {add, X} ->
            if Left /= 0 ->
                if X =< Key ->
                    Left ! {add, X},
                    node(Key, Left, Right);
                true ->
                    Right ! {add, X},
                    node(Key, Left, Right)
                end;
            true->
                if X > Key ->
                    node(Key, spawn(lot, node, [Key, 0, 0]), spawn(lot, node, [X, 0, 0]));
                X < Key ->
                    node(X, spawn(lot, node, [X, 0, 0]), spawn(lot, node, [Key, 0, 0]));
                true ->
                    node(Key, Left, Right)
                end
            end;
        {has, Y, Ret} ->
            if Left == 0 ->
                if Key == Y ->
                    Ret ! {has_result, 1};
                true ->
                    Ret ! {has_result, 0}
                end,
                node(Key, Left, Right);
            true ->
                if Y =< Key ->
                    Left ! {has, Y, Ret},
                    node(Key, Left, Right);
                true -> % Y > Key
                    Right ! {has, Y, Ret},
                    node(Key, Left, Right)
                end
            end
    end.