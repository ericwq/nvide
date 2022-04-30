-- italic comments
local colors = require("colors").get()
local fg = require("core.utils").fg

local grey_fg = colors.grey_fg
fg("Comment", grey_fg .. " gui=italic")
