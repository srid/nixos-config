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