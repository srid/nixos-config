module Main where

import Xmobar

main :: IO ()
main =
  xmobar $
    -- Override ref: https://github.com/jaor/xmobar/blob/master/src/Xmobar/App/Config.hs#L37
    defaultConfig
      { font = "xft:FiraCode:size=12",
        bgColor = "#02183b",
        fgColor = "#dce8fc",
        allDesktops = True,
        persistent = True,
        commands =
          [Run HelloWorld]
      }

data HelloWorld = HelloWorld
  deriving (Read, Show)

instance Exec HelloWorld where
  alias HelloWorld = "hw"
  run HelloWorld = return "<fc=red>Hello World!!</fc>"

{- Run $ Date "%a %b %_d %Y * %H:%M:%S" "theDate" 10,
Run $
  Battery
    [ "--template",
      "<acstatus>",
      "--Low",
      "15",
      -- battery specific options start here.
      "--",
      "--off",
      "<left> (<timeleft>)"
    ]
    100,
Run $ MultiCpu [] 100
-}
