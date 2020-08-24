% Compile under Linux and macOS with "erlc -W  -o pingpong.beam  pingpong.erl"
% Run with "erl -noshell -run pingpong start -s init stop -rounds 1000"
%
% Asynchronous Message passing is used for sending the "ball" between the ping and the
% pong Erlang processes. Messages from the ping process to the pong process include
% the process id over which the pong process sends the "ball" back.
%
% In Erlang, a program terminates when the main process terminates. Here, the main/pong
% processes wait for the ping process to terminate.

-module(pingpong).
-export([start/0, ping/1, pong/1]).

start()->
    {ok, [Rounds | _]} = init:get_argument(rounds),
    {R, _} = string:to_integer(Rounds),
    Pong = spawn(pingpong, pong, [self()]),
    Ping = spawn(pingpong, ping, [self()]),
    Ping ! {Pong, R},
    receive
        done ->
            skip
    end.
    
ping(Main) ->
    receive
        {Pong, Bounces} ->
            if Bounces > 0 ->
                % io:fwrite("Ping: " ++ integer_to_list(Bounces) ++ "\n"),
                Pong ! {self(), Bounces - 1},
                ping(Main); 
            true ->
                Pong ! done,
                Main ! done
            end      
    end.

pong(Main) ->
    receive
        {Ping, Bounces} ->
            if Bounces >= 0 ->
                % io:fwrite("Pong: " ++ integer_to_list(Bounces) ++ "\n"),
                Ping ! {self(), Bounces - 1}, 
                pong(Main);
            true ->
                receive 
                    done ->
                        skip
                end
            end
    end.
