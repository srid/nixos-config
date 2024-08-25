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
}
