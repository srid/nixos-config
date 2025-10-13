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
  import System.Process (system)
  import System.IO
  import Data.List (isInfixOf)
  import System.Exit (ExitCode(..))
  import Control.Exception (catch, SomeException)

  loadFromBins ["${git}", "${coreutils}"]

  main :: IO ()
  main = do
    hSetBuffering stdout NoBuffering
    hSetBuffering stderr NoBuffering
    
    hPutStrLn stderr "[git-changes] Starting..."
    
    -- Use a simple approach: just run git diff in foreground, restart when files change
    runningRef <- newMVar False
    
    let runDiff = do
          -- Don't restart if already running
          isRunning <- tryTakeMVar runningRef
          case isRunning of
            Just True -> do
              hPutStrLn stderr "[git-changes] Diff already running, skipping..."
              putMVar runningRef True
              return ()
            _ -> do
              putMVar runningRef True
              hPutStrLn stderr "[git-changes] Running git diff..."
              
              -- Run git diff - this blocks until it exits
              exitCode <- system "${git}/bin/git diff HEAD"
              
              void $ takeMVar runningRef
              hPutStrLn stderr $ "[git-changes] Git diff exited with: " ++ show exitCode
              
              -- If user quit successfully, exit the program
              case exitCode of
                ExitSuccess -> error "User quit"
                _ -> return ()
    
    -- Run initial diff in a thread
    diffThread <- forkIO runDiff
    
    -- Fork a thread to watch for file changes
    hPutStrLn stderr "[git-changes] Starting file watcher..."
    void $ forkIO $ withManager $ \mgr -> do
      _ <- watchTree
        mgr
        "."
        (\event -> let path = eventPath event
                   in not (".git" `isInfixOf` path))
        (\event -> do
          hPutStrLn stderr $ "[git-changes] File changed: " ++ eventPath event
          -- Kill the current diff thread
          killThread diffThread
          void $ takeMVar runningRef
          -- Start a new one
          void $ forkIO runDiff)
      
      forever $ threadDelay 1000000
    
    hPutStrLn stderr "[git-changes] Waiting for user to quit..."
    -- Wait for the diff thread to finish
    threadDelay maxBound
''
