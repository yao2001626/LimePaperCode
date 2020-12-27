-module(big).
-export([start/0]).

-define(Workers, 10).
-define(Rounds, 100).
-define(Neighbourhoods, 2).

start() ->
    supervisor().

supervisor() ->
    neighbourhood(?Neighbourhoods, []).

neighbourhood(0, Procs) ->
    receive_pingpong(?Workers * ?Neighbourhoods, 0, 0),
    lists:foreach(fun (P) -> P ! {exit} end, Procs);

neighbourhood(N, Procs) ->
    Ps = spawn_workers(?Workers, self()),
    worker_start(?Workers, Ps, Ps),
    neighbourhood(N - 1, lists:append(Procs, Ps)).
    
worker_start(0, [], _)->
    skip;
worker_start(N, [Pid|Pids], Procs)->
    Pid ! {pids, N, Procs},
    worker_start(N - 1, Pids, Procs).
        
spawn_workers(0, _) ->
    [];
spawn_workers(N, Supervisor) ->
    [spawn_link(fun () -> worker([], [], [], true, Supervisor) end) | spawn_workers(N - 1, Supervisor)].
 
recipient(R, Id) ->
    T1 = (32236 * R),
    T2 = T1 rem 65521,
    if (T2 rem ?Workers) /= Id ->
        T2 rem ?Workers + 1;
    true ->
        recipient(T2, Id)
    end.


worker([], [], [], true, Supervisor) ->
    receive
        {pids, Id, Procs} ->
            worker(?Rounds, Id, Procs, 0, Supervisor)   
    end;
    
        
worker(0, Id, _, false, Supervisor) ->
    receive 
        {ping, PingId} ->
            PingId ! {pong, self()},
            worker(0, Id, [], false, Supervisor);
        {exit} ->
            ok
    end;

worker(0, Id, PIds, PingPong, Supervisor) ->
    Supervisor ! {done, PingPong},
    worker(0, Id, PIds, false, Supervisor);
    
worker(Rounds, Id, PIds, PingPong, Supervisor)->
    Rand0 = 12345 + Id,
    Rand1 = recipient(Rand0, Id),
    SPid = lists:nth(Rand1, PIds),
    SPid ! {ping, self()},
    receive
        {ping, PingId}->
            PingId ! {pong, self()},
            worker(Rounds, Id, PIds, PingPong - 1, Supervisor);
        {pong, _}->
            worker(Rounds - 1, Id, PIds, PingPong + 1, Supervisor)
    end.
    
receive_pingpong(0, Min, Max)->
    io:fwrite("min, max: ~0p ~0p~n", [Min, Max]);
        
receive_pingpong(N, Min, Max)->
    receive
        {done, PingPong} -> 
            if PingPong < Min ->
                receive_pingpong(N - 1, PingPong, Max);
            PingPong > Max ->
                receive_pingpong(N - 1, Min, PingPong);
            true ->
                receive_pingpong(N - 1, Min, Max)
            end
    end.
