{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Map.Strict as M
import XMonad
import XMonad.Actions.UpdatePointer (updatePointer)
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks (ToggleStruts (..), avoidStruts, docks)
import XMonad.Layout.Decoration (Decoration, DefaultShrinker, ModifiedLayout)
import XMonad.Layout.DwmStyle (Theme (decoHeight))
import XMonad.Layout.NoBorders (withBorder)
import qualified XMonad.Layout.Simplest as Simplest
import XMonad.Layout.Spacing (Border (Border), spacingRaw)
import XMonad.Layout.Tabbed
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
        { modMask = mod4Mask, -- Use Super instead of Alt (Using Alt messes up bash shortcuts)
          terminal = "alacritty", -- "myst",
          layoutHook =
            borderSpacingBetweenWindows $
              avoidStruts $ myThreeCol ||| myTabbed ||| layoutHook def,
          logHook =
            pointerFollowsFocus,
          keys = myKeys,
          -- https://htmlcolorcodes.com/
          focusedBorderColor = "#50CBE8"
        }

    myThreeCol =
      ThreeColMid
        1 -- Master window count
        (3 / 100) -- Resize delta
        (1 / 2) -- Initial column size
    myTabbed :: ModifiedLayout (Decoration TabbedDecoration DefaultShrinker) Simplest.Simplest Window
    myTabbed =
      -- FIXME: This doesn't work reliably.
      tabbed shrinkText $ def {decoHeight = 10, activeColor = "#50CBE8", fontName = "xft:Consolas:size=12"}

    pointerFollowsFocus =
      let centerOfWindow = ((0.5, 0.5), (0, 0))
       in uncurry updatePointer centerOfWindow

    myKeys baseConfig@XConfig {modMask = modKey} =
      keys def baseConfig
        <> M.fromList
          [ -- Disable it, to prevent accidental press.
            -- ((modKey, xK_q), restart "/run/current-system/sw/bin/xmonad" True),
            ((modKey, xK_f), spawn "screenshot"),
            ((modKey, xK_b), sendMessage ToggleStruts)
            -- ...
          ]

    borderSpacingBetweenWindows =
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
