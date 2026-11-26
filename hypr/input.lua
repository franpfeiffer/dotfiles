hl.config({
  input = {
    kb_layout = "us,latam",
    kb_options = "caps:escape,grp:alt_space_toggle",
    accel_profile = "flat",
    numlock_by_default = true,
    touchpad = {
      scroll_factor = 0.4,
    },
  },
})

o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
