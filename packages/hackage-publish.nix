# Publish current package to Hackage.
{ writers, haskellPackages, coreutils, cabal-install, _1password-cli, ... }:

writers.writeHaskellBin "hackage-publish"
{
  libraries = with haskellPackages; [
    shh
    temporary
  ];
} ''
  {-# LANGUAGE TemplateHaskell #-}
  import Shh
  import System.IO.Temp
  import System.FilePath
  import System.Directory
  import Control.Monad

  loadFromBins ["${cabal-install}", "${coreutils}", "${_1password-cli}"]

  main :: IO ()
  main = do
    withSystemTempDirectory "hackage-publish" $ \tmpDir -> do
      putStrLn $ "Using temporary directory: " <> tmpDir

      -- Run cabal sdist
      putStrLn "Creating source distribution..."
      cabal "sdist" "-o" tmpDir

      -- Get password from 1password
      putStrLn "Retrieving password from 1password..."
      password <- op "read" "op://Private/Hackage/password" |> captureTrim

      -- Find the tarball file
      files <- listDirectory tmpDir
      let tarball = Prelude.head $ filter (\f -> takeExtension f == ".gz") files

      -- Upload to hackage
      putStrLn "Publishing to Hackage..."
      cabal "upload" "--publish" "-u" "sridca" "-p" password (tmpDir </> tarball)

      putStrLn "Successfully published to Hackage!"
''
