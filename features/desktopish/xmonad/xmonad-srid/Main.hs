{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

import qualified Data.Map.Strict as M
import XMonad
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks (ToggleStruts (..), avoidStruts, docks)
import XMonad.Layout.NoBorders (withBorder)
import XMonad.Layout.Spacing (Border (Border), spacingRaw)
import XMonad.Layout.ThreeColumns (ThreeCol (..))

-- NOTE:
-- Chromium won't respect Xmonad's border width, until this is done:
-- https://wiki.archlinux.org/index.php/xmonad#Chrome/Chromium_not_displaying_defined_window_border_color

main :: IO ()
main = do
  xmonad $ docks $ ewmh cfg
  where
    cfg =
      def
        { modMask = mod4Mask, -- Use Super instead of Alt
          terminal = "alacritty", -- "myst",
          layoutHook =
            borderSpacing $
              avoidStruts $
                ThreeColMid 1 (3 / 100) (1 / 2) ||| layoutHook def,
          keys = myKeys,
          -- https://htmlcolorcodes.com/
          focusedBorderColor = "#50CBE8"
        }
    -- Add border spacing between windows
    myKeys baseConfig@XConfig {modMask = modKey} =
      keys def baseConfig
        <> M.fromList
          [ ((modKey, xK_q), restart "/run/current-system/sw/bin/xmonad" True),
            ((modKey, xK_f), spawn "screenshot"),
            ((modKey, xK_b), sendMessage ToggleStruts)
            -- ...
          ]
    borderSpacing =
      withBorder 5
        . spacingRaw
          -- Apply borders only when there are 2 or more windows
          True
          -- Screen border
          (Border 0 10 10 10)
          -- Enable screen border?
          False
          -- Window borders
          (Border 10 10 10 10)
          -- Enable window border?
          True

{- old status bar; remove after configuring taffybar

myStatusBar =
  statusBar dzenCli pp toggleStrutsKey
  where
    -- -dock is necessary for https://github.com/xmonad/xmonad/issues/21
    -- https://github.com/xmonad/xmonad-contrib/pull/203
    dzenCli = "dzen2 -dock -fn CascadiaCode:pixelsize=26"
    pp =
      dzenPP
        { -- ppSep = "🔥", Neither unicode, nor emoji work with dzen2
          ppTitleSanitize =
            shorten 15 . dzenEscape,
          ppExtras =
            [ padL $ pure $ Just "|",
              battery,
              padL $ pure $ Just "|",
              moment
            ]
        }
    toggleStrutsKey :: XConfig t -> (KeyMask, KeySym)
    toggleStrutsKey XConfig {modMask = modm} = (modm, xK_b)

moment :: Logger
moment = do
  now <- liftIO getZonedTime
  pure $ do
    pure $ formatTime defaultTimeLocale "%d/%a %R" now

battery :: Logger
battery = do
  s <-
    fmap trim . liftIO . readFile $
      "/sys/class/power_supply/BAT0/capacity"
  pure $ do
    pct <- readMaybe @Int s
    let fmt
          | pct < 33 = dzenColor "white" "red"
          | pct < 66 = dzenColor "white" "orange"
          | otherwise = id
    pure $ fmt $ show pct <> "%"
  where
    trim = T.unpack . T.strip . T.pack

-}
