-module(mapreduce).

-export([initial/1, rep/2, start/1, start/2]).

initial([R, N])->
  rep(1, [R, N]).

rep(1, [R, N]) ->
  start([R, N]);
rep(RR, [R, N]) ->
  start([R, N]),
  rep(RR - 1, [R, N]).

start([R, N]) ->
  _ = start(list_to_integer(R), list_to_integer(N)).

start(R, N) ->
  Self = self(),
  Reducer = start(Self, R, 1, N),
  [receive {Reducer, Result} -> Result end || _ <- lists : seq(1, R)].

start(Parent, R, N, N) ->
  spawn_link(fun() -> mapper(Parent, R, N) end);
start(Parent, R, From, To) ->
  spawn_link(fun() -> reducer(Parent, R, From, To) end).

mapper(Parent, R, N) ->
  [Parent ! {self(), N * N} || _ <- lists : seq(1, R)].

reducer(Parent, R, From, To) ->
  Self = self(),
  Middle = (From + To) div 2,
  A = start(Self, R, From, Middle),
  B = start(Self, R, Middle + 1, To),
  [Parent ! {Self, receive {A, X} -> receive {B, Y} -> X + Y end end}
    || _ <- lists : seq(1, R)].
