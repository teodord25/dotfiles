local lgi = require('lgi')
local Pango = lgi.Pango
local PangoCairo = lgi.PangoCairo

local BG_COLOR = {0.085, 0.085, 0.085} -- black
local BAR_COLOR = {0.616, 0.038, 0.067} -- red
local TEXT_ON_BAR = {0.085, 0.085, 0.085}
local TEXT_ON_BG = {0.616, 0.038, 0.067}

local TEXT = "BAT"

local function get_value()
    local handle = io.popen("upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'percentage' | awk '{print $2}' | tr -d '%'")
    if not handle then
        return 25
    end

    local result = handle:read("*a")
    handle:close()

    -- Trim whitespace and convert
    if result then
        result = result:match("^%s*(.-)%s*$")  -- trim whitespace
        local percentage = tonumber(result)
        if percentage then
            return percentage
        end
    end

    return 25
end

WIDTH = 160
HEIGHT = 40

function draw(cr, width, height)
    local battery_percent = get_value()
    local bar_width = (battery_percent / 100) * WIDTH

    local layout = PangoCairo.create_layout(cr)
    local font_desc = Pango.FontDescription.from_string("EVA-Matisse_Standard 28")
    layout:set_font_description(font_desc)
    layout:set_text(TEXT)

    local text_width, text_height = layout:get_pixel_size()
    local text_x = (WIDTH - text_width) / 2
    local text_y = (HEIGHT - text_height) / 2

    -- trough
    cr:set_source_rgb(BG_COLOR[1], BG_COLOR[2], BG_COLOR[3])
    cr:rectangle(0, 0, WIDTH, HEIGHT)
    cr:fill()

    -- progress
    cr:set_source_rgb(BAR_COLOR[1], BAR_COLOR[2], BAR_COLOR[3])
    cr:rectangle(0, 0, bar_width, HEIGHT)
    cr:fill()

    -- black text clipped
    cr:save()
    cr:rectangle(0, 0, bar_width, HEIGHT)
    cr:clip()
    cr:set_source_rgb(TEXT_ON_BAR[1], TEXT_ON_BAR[2], TEXT_ON_BAR[3])
    cr:move_to(text_x, text_y)
    PangoCairo.show_layout(cr, layout)
    cr:restore()

    -- red text clipped
    cr:save()
    cr:rectangle(bar_width, 0, WIDTH - bar_width, HEIGHT)
    cr:clip()
    cr:set_source_rgb(TEXT_ON_BG[1], TEXT_ON_BG[2], TEXT_ON_BG[3])
    cr:move_to(text_x, text_y)
    PangoCairo.show_layout(cr, layout)
    cr:restore()

    return WIDTH, HEIGHT
end
