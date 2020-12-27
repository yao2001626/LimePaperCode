-module(chameneos).
-export([start/0]).

-define(CHAMS, 100).
-define(MEETS, 1000).
-define(TRICHROMATIC, 3).

-import(lists, [foreach/2]).

chameneos(Mall, Color) ->
    Mall ! {self(), Color},
    receive
        {OtherColor} ->
            if Color == OtherColor ->
                chameneos(Mall, Color);
            true ->
                chameneos(Mall, 3 - Color - OtherColor)
            end
    end.

mall(0, Diff) ->
    io:fwrite("Color changes: " ++ integer_to_list(Diff) ++ "\n"),
    halt();
mall(N, Diff) ->
    receive
        {Pid1, C1} -> nil
    end,
    receive
        {Pid2, C2} ->
            Pid1 ! {C2},
            Pid2 ! {C1},
            if C1 == C2 ->
                mall(N - 1, Diff);
            true ->
                mall(N - 1, Diff + 1)
            end
    end.
start() ->
    Mall = spawn(fun () -> mall(?CHAMS * ?MEETS / 2, 0) end),
    foreach(fun(Color) -> spawn(fun() -> chameneos(Mall, Color rem ?TRICHROMATIC) end) end, lists:seq(1, ?CHAMS)).
