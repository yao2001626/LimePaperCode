import Control.Concurrent
import System.Environment

data RequestChan = RequestChan (MVar (Int, (MVar Int)))
data DoneChan = DoneChan (MVar Bool)

chameneos :: (MVar (Int, (MVar Int))) -> Int -> IO()
chameneos mall col = do
    re <- newEmptyMVar
    putMVar mall (col, re)
    othercol <- takeMVar re
    if col /= othercol
        then do
            chameneos mall (3 - col - othercol)
        else do
            chameneos mall col
            
mall :: Int -> (MVar (Int, (MVar Int))) -> MVar Bool -> IO() 
mall reps cham done = do
    (fstColor, fstReply) <- takeMVar cham
    (scdColor, scdReply) <- takeMVar cham
    putMVar fstReply scdColor
    putMVar scdReply fstColor
    -- when (fstColor /= scdColor) $ putStr "diff"
    if reps > 1 
        then do
            -- putStr "reps"
            mall (reps-1) cham done
        else do
            -- putStr "done"
            putMVar done True

main = do
    args <- getArgs
    r <- newEmptyMVar
    d <- newEmptyMVar
    request <- newMVar (0, r)
    forkIO $ mall 300000 request d
    mapM_ (\ x-> forkIO (chameneos request (x `rem` 3))) [1..600]
    tmp <- takeMVar d
    return ()
