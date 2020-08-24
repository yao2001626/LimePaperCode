{- Compile under Linux and macOS with
"ghc -threaded -o pingpong --make -O -rtsopts pingpong.hs";
run with "./pingpong 10000"

Asynchronous channels with capacity of 1 (MVar) are used for sending the "ball"
between the ping and the pong threads. The threads do not "know" about each
other, they communicate only through three channels: pingChannel and
pongChannel to integer type and doneChannel of unit type.

In Haskell, a program terminates when the main thread terminates. Here, the
main thread and pong thread wait for the notification from the ping threads.
-}
import Control.Concurrent
import System.Environment

ping :: (MVar Int) -> (MVar Int) -> (MVar Bool) -> IO()
ping pingChan pongChan doneChan = do        
    bounces <- takeMVar pongChan
    if bounces > 0
        then do
            putMVar pingChan (bounces - 1)
            ping pingChan pongChan doneChan
        else do
            putMVar doneChan True
            putMVar doneChan True
        
pong :: (MVar Int) -> (MVar Int) -> (MVar Bool) -> IO()
pong pingChan pongChan doneChan = do
    bounces <- takeMVar pingChan
    if bounces >= 0
        then do
            putMVar pongChan (bounces - 1)
            pong pingChan pongChan doneChan
        else do
            _ <- takeMVar doneChan
            return()

main = do
    args <- getArgs
    let bounces = read (args!!0)
    pingChan <- newEmptyMVar
    pongChan <- newEmptyMVar
    doneChan <- newEmptyMVar
    forkIO $ ping pingChan pongChan doneChan
    forkIO $ pong pingChan pongChan doneChan
    putMVar pingChan bounces
    _ <- takeMVar doneChan
    return ()