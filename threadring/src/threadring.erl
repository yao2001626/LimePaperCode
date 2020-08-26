%% Compile under Linux and macOS with
%% "erlc -W  -o threadring.beam  threadring.erl"; run with
%% "erl -noshell -run threadring start -s init stop -hops 100000 -nodes 1000"
%%
%% Asynchronous message passing is used for passing the token between the node
%% processes. Each node continuously accepts tokens; if the token is larger than
%% 1, it passes the token minus 1 on, otherwise it exits.
%%
%% In Erlang, a program terminates when the main process terminate.

-module(threadring).
-export([start/0]).

spawn_nodes(0, _, _) -> [];
spawn_nodes(N, Main, Nodes) ->
  [spawn_link(fun () -> nodes(N, Main, Nodes) end) |
  spawn_nodes(N - 1, Main, Nodes)].
init_nodes(0, [], []) -> skip;
init_nodes(Nodes, [P|Ps], [N|Ns]) ->
  P ! {nextp, N},
  init_nodes(Nodes - 1, Ps, Ns).
shiftNode([H|Hs]) -> lists:append(Hs, [H]).
start() ->
  {ok, [H | _]} = init:get_argument(hops),
  {ok, [N | _]} = init:get_argument(nodes),
  {Hops, _} = string:to_integer(H),
  {Nodes, _} = string:to_integer(N),
  Main = self(),
  Ps = spawn_nodes(Nodes, Main, Nodes),
  PPs = shiftNode(Ps),
  init_nodes(Nodes, Ps, PPs),
  Head = lists:nth(1, Ps),
  Head ! Hops,
  receive
    done -> skip
  end.
nodes(Id, Next, Main, Nodes)->
  receive
    0 ->
      io:format("~p~n", [Nodes - Id]),
      Main ! done,
      nodes(Id, Next, Main, Nodes);
    Index ->
      Next ! Index - 1,
      nodes(Id, Next, Main, Nodes)
  end.
nodes(Id, Main, Nodes) ->
  receive
    {nextp, Next} -> nodes(Id, Next, Main, Nodes)
  end.
