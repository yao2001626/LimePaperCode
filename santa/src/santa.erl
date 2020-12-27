
%% Compile under Linux and macOS with
%% "erlc -W  -o santa.beam santa.erl"; run with
%% "time erl -noshell -run santa start -s init stop -rounds 100000"
%% Each node is a process.  
%% Asynchronous message passing is used for passing message between santa, shop,
%% reindeer and elves. The santa repeats for `-rounds` times
%% 
%%
%% In Erlang, a program terminates when the main process terminate.

-module(santa).
-author('yaos4@mcmaster.ca'). % Shucai Yao
-export([start/0]).

santa(0, Main) ->
    Main ! {done};
santa(N, Main) ->
    receive                                    
        {back, Reindeer} ->
            [PID ! {harness} || PID <- Reindeer]
    after 0 ->
        receive                            
            {back, Reindeer} -> 
                [PID ! {harness} || PID <- Reindeer]; 
            {puzzled, Elves} -> 
                [PID ! {elfenter} || PID <- Elves]
        end                                
    end,            
santa(N-1, Main).

shop_loop(0, Elves, Santa, M) ->
    Santa ! {puzzled, Elves},
    [
        receive
            {elfconsult,PID} -> ok 
        end 
        || PID <- Elves
    ],
    shop_loop(M, [], Santa, M);
shop_loop(N, Elves, Santa, M) ->
    receive {elfpuzzled, PID} ->
        shop_loop(N-1, [PID|Elves], Santa, M)
    end.

sleigh_loop(0, Reindeer, Santa, M) ->
    Santa ! {back, Reindeer},
    [
        receive
            {reindeerpull,PID} -> ok 
                %io:fwrite("Ho, ho, ho! ~p!\n", [PID])
        end 
        || PID <- Reindeer
    ],
    sleigh_loop(M, [], Santa, M);
sleigh_loop(N, Reindeer, Santa, M) ->
    receive {reindeerback, PID} ->
        sleigh_loop(N-1, [PID|Reindeer], Santa, M)
    end.
    
elve(Shop)->
    Shop ! {elfpuzzled, self()},
    receive
        {elfenter} ->
            Shop ! {elfconsult, self()}
    end,
    elve(Shop).
    
reindeer(Sleigh) ->
    Sleigh ! {reindeerback, self()},
    receive
        {harness} ->
            Sleigh ! {reindeerpull, self()}
    end,
    reindeer(Sleigh).
    
start() ->
    {ok, [Rounds | _]} = init:get_argument(rounds),
    {R, _} = string:to_integer(Rounds),
    Main = self(),
    Santa = spawn(fun() -> santa(R, Main) end),
    Sleigh = spawn(fun() -> sleigh_loop(9, [], Santa, 9) end),
    Shop  = spawn(fun() -> shop_loop(3, [], Santa, 3) end),
    [spawn(fun() -> reindeer(Sleigh) end)|| _ <- lists:seq(1, 9)],
    [spawn(fun() -> elve(Shop) end) || _ <- lists:seq(1, 10)],
    receive
            {done} -> ok
    end.
