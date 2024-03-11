local wezterm = require 'wezterm';

return {
  -- option	= value	, [default] comment

  -- Fonts
  font     	= wezterm.font("JetBrains Mono")                             	, -- [JetBrains Mono]
  -- font  	= wezterm.font("JetBrains Mono", {weight="Bold",italic=true})	, -- [JetBrains Mono] Name with parameters
  font_size	= 20.0                                                       	, -- [12.0]

  -- Colors
  color_scheme     	= "nord"   	, -- full list @ wezfurlong.org/wezterm/colorschemes/index.html
  colors           	= {        	  -- color_scheme takes precedence over these
    foreground     	= "silver" 	, -- [silver] The default text color
    background     	= "black"  	, -- [black]  The default background color
    cursor_bg      	= "#52ad70"	, -- [#52ad70] Overrides the cell background color when the current cell is occupied by the cursor and the cursor style is set to Block
    cursor_fg      	= "black"  	, -- [black]   Overrides the text color when the current cell is occupied by the cursor
    cursor_border  	= "#52ad70"	, -- [#52ad70] Specifies the border color of the cursor when the cursor style is set to Block, of the color of the vertical or horizontal bar when the cursor style is set to Bar or Underline.
    selection_fg   	= "black"  	, -- [black]   The foreground color of selected text
    selection_bg   	= "#fffacd"	, -- [#fffacd] The background color of selected text
    scrollbar_thumb	= "#222222"	, -- [#222222] The color of the scrollbar "thumb"; the portion that represents the current viewport
    split          	= "#444444"	, -- [#444444] The color of the split lines between panes
  --   ansi        	= {"black", "maroon", "green", "olive", "navy", "purple", "teal", "silver"},
  --   brights     	= {"grey", "red", "lime", "yellow", "blue", "fuchsia", "aqua", "white"},
  --   indexed     	= {[136]="#af8700"} , -- Arbitrary colors of the palette in the range from 16 to 255
  },

  -- Appearance
  window_background_opacity   	= 0.9  	, -- [1.0] alpha channel value with floating point numbers in the range 0.0 (meaning completely translucent/transparent) through to 1.0 (meaning completely opaque)
  enable_tab_bar              	= true	, -- [true]
  hide_tab_bar_if_only_one_tab	= false	, -- [false] hide the tab bar when there is only a single tab in the window
}
