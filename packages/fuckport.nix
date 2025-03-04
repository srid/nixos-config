# https://x.com/sridca/status/1861875950897578113
{ writers, haskellPackages, coreutils, jc, lsof, ... }:

writers.writeHaskellBin "fuckport"
{
  libraries = with haskellPackages; [
    shh
    aeson
  ];
} ''
  {-# LANGUAGE TemplateHaskell #-}
  {-# LANGUAGE DerivingStrategies #-}
  {-# LANGUAGE DeriveAnyClass #-}
  import Shh
  import System.Environment
  import Data.Aeson
  import Data.Maybe
  import GHC.Generics
  import Control.Monad

  loadFromBins ["${lsof}", "${coreutils}", "${jc}"]

  data LsofRow = LsofRow
    { command :: String
    , pid :: Int
    , user :: String
    }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON)

  main :: IO ()
  main = do
    port <- Prelude.head <$> getArgs
    s <- lsof "-i" (":" <> port) |> jc "--lsof" |> capture
    let v = fromJust $ decode @[LsofRow] s
    forM_ v $ \r -> do
      putStrLn $ "Killing " <> show (pid r) <> " (" <> command r <> ")"
      kill ["-KILL", show (pid r)]
''
