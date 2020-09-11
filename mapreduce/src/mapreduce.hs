import Control.Concurrent
import Control.Monad
import System.Environment
import Data.String

mapper :: MVar Int -> MVar Int -> IO ()
mapper left right = do
    v <- takeMVar left
    putMVar right $! v * v
    mapper left right

reducer :: Int -> MVar Int -> MVar Int -> MVar Int -> IO ()
reducer x left_1 left_2 right = do 
    v1 <- takeMVar left_1
    v2 <- takeMVar left_2
    if x == 1
        then putStrLn (show $! v1 + v2)
        else putMVar right $! v1 + v2 
    reducer x left_1 left_2 right        

repeats :: Int -> [MVar Int] -> [MVar Int] -> IO ()
repeats 0 m r = do        
    mapM_ (\ (e, x) -> putMVar e (x + 1)) $ zip m [0..]
    return ()

repeats n m r = do
    mapM_ (\ (e, x) -> putMVar e (x + 1)) $ zip m [0..]
    repeats (n-1) m r

main = do
    args <- getArgs
    let num = read  (args !! 0) :: Int
    let reps = read  (args !! 1) :: Int
    m <- replicateM num newEmptyMVar
    r <- replicateM (num * 2) newEmptyMVar
    mapM_ (\ (mapMVar, x) -> forkIO (mapper mapMVar (r !! (num + x) ))) $ zip m [0..]
    mapM_ (\ x -> forkIO (reducer x (r !! (x * 2)) (r !! (x * 2 + 1))  (r !! x))) [1..(num - 1)]
    repeats (reps - 1) m r