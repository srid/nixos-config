return {
  font = wezterm.font("Monaspace Argon"),
  color_scheme = 'Tokyo Night',
  window_decorations = 'RESIZE',
  keys = {
    -- Emulate other programs (Zed, VSCode, ...)
    {
      key = 'P',
      mods = 'CMD|SHIFT',
      action = wezterm.action.ActivateCommandPalette,
    },
  },
  -- Workaround for https://github.com/NixOS/nixpkgs/issues/336069#issuecomment-2299008280
  -- Remove later.
  front_end = "WebGpu"
}
