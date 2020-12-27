import Control.Concurrent
import System.Environment
import qualified Data.Text    as Text
import qualified Data.Text.IO as Text

data PQchannel = PQchannel !(MVar PQcmd)
data PQcmd = Add !Int | Remove  | RemoveRet !Int | LastNode 
  deriving (Show)
-- this will need compile option to unbox strict fields 
pqnode :: PQchannel -> PQchannel ->PQchannel -> PQchannel -> Int -> IO ()      
pqnode left_input_C@(PQchannel left_input) left_output_C@(PQchannel left_output) right_output_C@(PQchannel right_output) right_input_C@(PQchannel right_input) key = do
    cmd <- takeMVar left_input
    case cmd of 
        Add x -> do
            putMVar right_output (Add (max key x))
            pqnode left_input_C left_output_C right_output_C right_input_C (min key x)
        Remove -> do
            putMVar left_output (RemoveRet key)
            putMVar right_output Remove 
            k <- takeMVar right_input 
            case k of 
                RemoveRet kvalue  -> do
                    pqnode left_input_C left_output_C right_output_C right_input_C kvalue
                LastNode -> do
                    pqnode_lastnode left_input_C left_output_C

pqnode_lastnode :: PQchannel -> PQchannel -> IO ()
pqnode_lastnode left_input_C@(PQchannel left_input)  left_output_C@(PQchannel left_output)= do 
    m_r_input <- newEmptyMVar
    m_r_output <- newEmptyMVar
    let right_input = PQchannel m_r_input
    let right_output = PQchannel m_r_output
    cmd <- takeMVar left_input
    case cmd of 
        Add a -> do
            forkIO $ pqnode_lastnode right_output right_input
            pqnode left_input_C left_output_C  right_output right_input  a
        Remove -> do
            putMVar left_output LastNode
            return ()
        
f :: [String] -> [Int]
f = map read

main = do
    args <- getArgs
    let path = (args !! 1) ++ (args !! 0)
    file <- readFile path
    let datas = lines file
    let nums = f datas 
    
    r_output <- newEmptyMVar
    r_input <- newEmptyMVar
    let right_output = PQchannel r_output
    let right_input = PQchannel r_input
    forkIO $ pqnode_lastnode right_output right_input
    mapM_ (\ x -> putMVar r_output (Add x)) nums
    --mapM_ (\x->putMVar r_output (Add x)) [1..8000]
    --mapM_ (\ x -> do putMVar r_output Remove >> takeMVar r_input) [1..8000]
    mapM_ (\ x -> do
        putMVar r_output Remove
        takeMVar r_input
        ) nums
        --putStrLn . shows x $ ": Received " ++ show y) [1..8000]
        --putStrLn . shows x $ ": Received " ++ show y) nums
    return ()