-- Compile under Linux and macOS with
-- "ghc -threaded -o threadring --make -O -rtsopts threadring.hs";
-- run with "time ./threadring 100000 1000".
--
-- Node threads are created with forkIO, with each thread creating one
-- synchronized mutable variable (inChan) shared with the next thread (outChan)
-- in the ring. The last thread created returns an MVar (outChan) to share with
-- the first thread (inChan). Each thread reads from the MVar (inChan) to its v,
-- and writes v to the MVar (outChan).
--
-- Each thread then waits on a token to be passed from its neighbour. Tokens are
-- then passed around the threads via the MVar chain Hops times,  and the thread
-- id of the final thread to receive a token is printed.

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
        node n doneChan inChan outChan
    else do
        -- print n
        putMVar doneChan True

main = do
  args <- getArgs
  let hops = read (args!!0)
  let nodes = read (args!!1)
  inChan <- newEmptyMVar
  doneChan <- newEmptyMVar
  outChan <- foldM (create doneChan) inChan [1..nodes-1]
  forkIO  (node 0 doneChan outChan inChan)
  putMVar outChan hops
  _ <- takeMVar doneChan
  return()
