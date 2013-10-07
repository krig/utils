-- original code made by Bzed and published on http://awesome.naquadah.org/wiki/Calendar_widget
-- modified by Marc Dequènes (Duck) <Duck@DuckCorp.org> (2009-12-29), under the same licence,
-- and with the following changes:
--   + transformed to module
--   + the current day formating is customizable
-- modified by Jörg Thalheim (Mic92) <jthalheim@gmail.com> (2011), under the same licence,
-- and with the following changes:
--   + use tooltip instead of naughty.notify
--   + rename it to cal
--
-- 1. require it in your rc.lua
--	require("cal")
-- 2. attach the calendar to a widget of your choice (ex mytextclock)
--	cal.register(mytextclock)
--    If you don't like the default current day formating you can change it as following
--	cal.register(mytextclock, "<b>%s</b>") -- now the current day is bold instead of underlined
--
-- # How to Use #
-- Just hover with your mouse over the widget, you register and the calendar popup.
-- On clicking or by using the mouse wheel the displayed month changes.
-- Pressing Shift + Mouse click change the year.

local string = {format = string.format}
local os = {date = os.date, time = os.time}
local awful = require("awful")
local beautiful = require("beautiful")
local tonumber = tonumber

module("cal")

local tooltip
local state = {}

function current_day_format(str)
   return '<span color="' .. beautiful.fg_focus .. '"><b>' .. str .. '</b></span>'
end

function timeInTZ(tz)
   return awful.util.pread('TZ="' .. tz .. '" date "+%a %H:%M"')
end

function styleWrap(x)
   return '<span color="' .. beautiful.fg_normal .. '" font_desc="inconsolata 12">' .. x .. '</span>'
end

function displayMonth(month,year,weekStart)
	local t,wkSt=os.time{year=year, month=month+1, day=0},weekStart or 1
	local d=os.date("*t",t)
	local mthDays,stDay=d.day,(d.wday-d.day-wkSt+1)%7

	local lines = "    "

	for x=0,6 do
		lines = lines .. os.date("%a ",os.time{year=2006,month=1,day=x+wkSt})
	end

	lines = lines .. "\n" .. os.date(" %V",os.time{year=year,month=month,day=1})

	local writeLine = 1
	while writeLine < (stDay + 1) do
		lines = lines .. "    "
		writeLine = writeLine + 1
	end

        for d=1,mthDays do
                local x = d
                local t = os.time{year=year,month=month,day=d}
                if writeLine == 8 then
                        writeLine = 1
                        lines = lines .. "\n" .. os.date(" %V",t)
                end
                if os.date("%Y-%m-%d") == os.date("%Y-%m-%d", t) then
                        x = current_day_format(d)
                end
                if d < 10 then
                        x = " " .. x
                end
                lines = lines .. "  " .. x
                writeLine = writeLine + 1
        end
        if stDay + mthDays < 36 then
                lines = lines .. "\n"
        end
        if stDay + mthDays < 29 then
                lines = lines .. "\n"
        end
        local current_date = os.date("*t")
        local header = ''
        if tonumber(year) == current_date.year and tonumber(month) == current_date.month then
           header = '<b>' .. os.date("%A, %B %d %Y") .. '</b>\n'
        else
           header = '<b>' .. os.date("%B %Y", os.time{year=year, month=month, day=1}) .. '</b>\n'
        end

        local tail =  
           '          UTC: ' .. timeInTZ('UTC') ..
           ' Asia/Beijing: ' .. timeInTZ('Asia/Beijing') .. 
           '   US/Central: ' .. timeInTZ('US/Central')

        return header .. "\n" .. lines .. "\n" .. tail
end


function register(mywidget, custom_current_day_format)
	-- if custom_current_day_format then current_day_format = custom_current_day_format end

	if not tooltip then
		tooltip = awful.tooltip({})
                function tooltip:update()
                        local month, year = os.date('%m'), os.date('%Y')
                        state = {month, year}
                        tooltip:set_text(styleWrap(displayMonth(month, year, 2)))
                end
                tooltip:update()
	end
	tooltip:add_to_object(mywidget)

	mywidget:connect_signal("mouse::enter",tooltip.update)

	mywidget:buttons(awful.util.table.join(
	awful.button({ }, 1, function()
		switchMonth(-1)
	end),
	awful.button({ }, 3, function()
		switchMonth(1)
	end),
	awful.button({ }, 4, function()
		switchMonth(-1)
	end),
	awful.button({ }, 5, function()
		switchMonth(1)
	end),
	awful.button({ 'Shift' }, 1, function()
		switchMonth(-12)
	end),
	awful.button({ 'Shift' }, 3, function()
		switchMonth(12)
	end),
	awful.button({ 'Shift' }, 4, function()
		switchMonth(-12)
	end),
	awful.button({ 'Shift' }, 5, function()
		switchMonth(12)
	end)))
end

function switchMonth(delta)
	state[1] = state[1] + (delta or 1)
	local text = styleWrap(displayMonth(state[1], state[2], 2))
	tooltip:set_text(text)
end
