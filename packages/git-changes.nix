# Watch for file changes in the current directory and automatically restart
# `git diff HEAD` to show both staged and unstaged changes. Useful for
# monitoring code changes made by LLMs in real-time without manually restarting
# the diff viewer.
{ writers, haskellPackages, git, coreutils, ... }:

writers.writeHaskellBin "git-changes"
{
  libraries = with haskellPackages; [
    shh
    fsnotify
  ];
} ''
  {-# LANGUAGE TemplateHaskell #-}
  import Shh
  import System.FSNotify
  import Control.Concurrent
  import Control.Monad
  import System.Process
  import System.IO
  import Data.List (isInfixOf)

  loadFromBins ["${git}", "${coreutils}"]

  main :: IO ()
  main = do
    hSetBuffering stdout NoBuffering
    
    -- Start initial git diff
    diffRef <- newMVar Nothing
    let runDiff = do
          -- Kill previous diff if running
          oldProc <- takeMVar diffRef
          case oldProc of
            Just ph -> do
              terminateProcess ph
              void $ waitForProcess ph
            Nothing -> return ()
          
          -- Start new git diff
          ph <- spawnCommand "${git}/bin/git diff HEAD"
          putMVar diffRef (Just ph)
    
    -- Run initial diff
    runDiff
    
    -- Watch for file changes
    withManager $ \mgr -> do
      _ <- watchTree
        mgr
        "."
        (\event -> case event of
          _ -> let path = eventPath event
               in not (".git" `isInfixOf` path)
        )
        (\_ -> do
          putStrLn "File changed, restarting diff..."
          runDiff
        )
      
      -- Keep running
      forever $ threadDelay 1000000
''
