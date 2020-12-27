%% Compile under Linux and macOS with "erlc -W  -o parallelthreadring.beam  parallelthreadring.erl"
%% Run with "time erl -noshell -run parallelthreadring start -s init stop -hops 10000 -nodes 1000 -tokens 10"
%%
%% Asynchronous message passing is used for passing the token between the node Erlang process.
%% Each node continuously accepts tokens; if the token is larger than 1,
%% it passes the token minus 1 on, otherwise it sends "done" message to the main process (when token == 0).
%%
%% In Erlang, a program terminates when the main process terminates.

-module(parallelthreadring).
-export([start/0]).

%% @doc Send M messages through a ring of N processes.
%% nth

spawn_nodes(0, _, _) ->
    [];
spawn_nodes(N, Main, Hops) ->
    [spawn_link(fun () -> nodes(N, Main, Hops) end) | spawn_nodes(N - 1, Main, Hops)].

init_nodes(0, [], [])->
    skip;
init_nodes(Nodes, [P|Ps], [N|Ns])->
    P ! {nextp, N},
    init_nodes(Nodes - 1, Ps, Ns).

start_nodes(0, _, _)->
    skip;
start_nodes(N, [P|_]=Ps, Hops)->
    P ! Hops,
    start_nodes(N - 1, Ps, Hops).    

join_nodes(0)->
    skip;
join_nodes(N)->
    receive
        done ->
            join_nodes(N-1)
    end.
    
nextNode([H|Hs])->
    lists:append(Hs, [H]).
    
start() ->
  {ok, [H | _]} = init:get_argument(hops),
  {ok, [N | _]} = init:get_argument(nodes),
  {ok, [T | _]} = init:get_argument(tokens),
  {Hops, _} = string:to_integer(H),
  {Nodes, _} = string:to_integer(N),
  {Tokens, _} = string:to_integer(T),
  Main = self(),
  Ps = spawn_nodes(Nodes, Main, Hops),
  PPs = nextNode(Ps),
  init_nodes(Nodes, Ps, PPs),
  start_nodes(Tokens, Ps, Hops),
  join_nodes(Tokens).

nodes(Next, Main)->
    receive
        1 ->
            %%io:format("done~p~n", [Next]),
            Main ! done,
            nodes(Next, Main);
        Index ->
            Next ! Index - 1,
            nodes(Next, Main)
    end.
    
    
nodes(Id, Main, Hops) ->
  receive
    {nextp, Next} ->
        nodes(Next, Main)
  end.
