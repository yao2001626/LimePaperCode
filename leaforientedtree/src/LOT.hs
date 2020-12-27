import Control.Concurrent
import System.Environment
import qualified Data.Text    as Text
import qualified Data.Text.IO as Text

data LOTchannel = LOTchannel !(MVar LOTcmd)
data LOTcmd = Add !Int | Search !Int | Found !Bool
  deriving (Show)

lotnode :: LOTchannel -> LOTchannel -> LOTchannel -> LOTchannel -> Int -> IO ()       
lotnode parent_C@(LOTchannel parent) found left_child_C@(LOTchannel left) right_child_C@(LOTchannel right) key = do
    cmd <- takeMVar parent
    case cmd of
        Add a -> do
            if a > key
                then do
                    putMVar right (Add a)
                    lotnode parent_C found left_child_C right_child_C key
                else if a < key
                    then do
                        putMVar left (Add a)
                        lotnode parent_C found left_child_C right_child_C key
                    else do
                        lotnode parent_C found left_child_C right_child_C key
        Search b -> do
            if b <= key 
                then do
                    putMVar left (Search b)
                    lotnode parent_C found left_child_C right_child_C key
                else do
                    putMVar right (Search b)
                    lotnode parent_C found left_child_C right_child_C key


lotnode_leaf :: LOTchannel-> LOTchannel -> Int -> IO ()   
lotnode_leaf parent_C@(LOTchannel parent) found_C@(LOTchannel found) key = do
    cmd <- takeMVar parent
    case cmd of 
        Add a -> do
            if a /= key 
                then do
                    l_child <- newEmptyMVar
                    r_child <- newEmptyMVar
                    let left = LOTchannel l_child
                    --left <- LOTchannel <$> newEmptyMVar
                    let right = LOTchannel r_child
                    --right <- LOTchannel <$> newEmptyMVar
                    let smaller = min key a
                    let larger = max key a
                    forkIO $ lotnode_leaf left  found_C smaller
                    forkIO $ lotnode_leaf right found_C larger
                    lotnode parent_C found_C left right smaller
                else do 
                    lotnode_leaf parent_C found_C key
        Search b -> do
            if b == key
                then do
                    -- putStrLn . shows key $ " leaf: " ++  show b    
                    putMVar found (Found True)
                else do
                    -- putStrLn . shows key $ " leaf: !!" ++  show b 
                    putMVar found (Found False)
            lotnode_leaf parent_C found_C key

f :: [String] -> [Int]
f = map read

main = do
    args <- getArgs
    let path = (args !! 1) ++ (args !! 0)
    file <- readFile path
    let datas = lines file
    let nums = f datas
    
    r <- newEmptyMVar
    f <- newEmptyMVar
    let root = LOTchannel r
    let find = LOTchannel f
    forkIO $ lotnode_leaf root find 5000
    mapM_ (\ x -> putMVar r (Add x)) nums 
    mapM_ (\ x -> do
            putMVar r (Search x)
            takeMVar f
          ) nums 
            --putStrLn . shows x $ ": Received " ++ show y) nums 
    return ()