-- Compile under Linux and macOS with
-- "ghc -threaded -o parallelthreadring_hs --make -O -rtsopts parallelthreadring.hs"
-- Run with "time ./parallelthreadring_hs 1000 503 10"
--
-- Based on the implementation https://wiki.haskell.org/Shootout/Thread_ring
-- Node threads are created with forkIO, with each thread
-- creating one synchronised mutable variable (inChan) shared with the
-- next thread (outChan) in the ring. The last thread created returns an MVar (outChan) to
-- share with the first thread (inChan). Each thread reads from the MVar (inChan) to its
-- v, and writes v to the MVar (outChan).
--
-- Each thread then waits on a token to be passed from its neighbour.
-- Tokens are then passed around the threads via the MVar chain Hops times,
-- and the node that has the token(v) with value 0 and will notifies the main program through
-- the doneChan.

import Control.Monad
import Control.Concurrent
import System.Environment

create doneChan inChan i = do
  outChan <- newEmptyMVar
  forkIO (node i doneChan inChan outChan)
  return outChan

node :: Int -> MVar Bool -> MVar Int -> MVar Int -> IO ()
node n doneChan inChan outChan = do
    v <- takeMVar inChan
    if v > 0
    then do
        putMVar outChan $! v - 1
    else do
        putMVar doneChan True
    node n doneChan inChan outChan

jointhread :: Int -> MVar Bool -> IO()
jointhread 0 doneChan = do
    return ()
jointhread n doneChan = do
    _ <- takeMVar doneChan
    jointhread (n-1) doneChan

main = do
  args <- getArgs
  let hops = read (args!!0)
  let nodes = read (args!!1)
  let tokens = read (args!!2)
  inChan <- newEmptyMVar
  doneChan <- newEmptyMVar
  outChan <- foldM (create doneChan) inChan [2..nodes]
  forkIO  (node 1 doneChan outChan inChan)
  mapM_ (\ _ -> putMVar inChan hops) [1..tokens]
  jointhread tokens doneChan
