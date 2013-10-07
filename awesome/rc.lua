-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- local tonumber = tonumber

require("cal")

-- local json = require("json")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
home_dir = os.getenv("HOME")
theme_dir = home_dir .. "/.config/awesome/themes"
--beautiful.init(theme_dir .. "/multicolor/theme.lua")
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
-- if beautiful.wallpaper then
--     for s = 1, screen.count() do
--         gears.wallpaper.maximized(beautiful.wallpaper, s, true)
--    end
-- end
-- }}}


-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   -- tags[s] = awful.tag({ "a", "b", "c", "d", "e", "f", "g", "h", "i" }, s, layouts[1])
   tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "Manual", terminal .. " -e man awesome" },
   { "Edit rc.lua", editor_cmd .. " " .. awesome.conffile },
   { "Restart awesome", awesome.restart },
   { "Lock Screen", "xdg-screensaver lock" },
   { "Log Out", awesome.quit },
   { "Suspend", "gnomesu -c \"/usr/sbin/pm-suspend\"" },
   { "Reboot", "gnomesu -c \"/sbin/reboot -h\"" },
   { "Shutdown", "gnomesu -c \"/sbin/shutdown -h now\"" },
}

mysystemmenu = {
   { "Control Center", "gnome-control-center" },
   { "YAST", "gnomesu -c \"/sbin/yast2\"" },
   { "Tweak Tool", "gnome-tweak-tool" },
   { "VM Manager", "gnomesu virt-manager" },
  }

myworkmenu = {
   { "Fate", "fate" },
}

mygamesmenu = {
   { "Steam", "steam" },
   { "Minecraft", "minecraft" },
   { "Dominions", "dominions" },
}

function menuicon(name)
   local path = home_dir .. "/.local/share/icons/" .. name
   if awful.util.file_readable(path) then
      return path
   else
      return beautiful.awesome_icon
   end
end

mymainmenu = awful.menu({ items = { { "Settings", myawesomemenu, beautiful.awesome_icon },
                                    { "System", mysystemmenu, menuicon("villager-mini.png") },
                                    { "Work", myworkmenu, menuicon("zombie-pigman-mini.png") },
                                    { "Games", mygamesmenu, menuicon("ghast-mini.png") },
                                    { "Terminal", terminal, menuicon("transit-32.png") },
                                    { "Emacs", "emacs", menuicon("scratchpad-32.png") },
                                    { "Firefox", "firefox", menuicon("chrome-32.png") },
                                    { "Nautilus", "nautilus " .. home_dir },
                                    { "Chromium", "chromium" },
                                    { "Gnucash", "gnucash" },
                                    { "Evince", "evince" },
                                    { "EOG", "eog" },
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock(" %H:%M ")

cal.register(mytextclock)

-- Create a keyboard layout swapper
kbdcfg = {}
kbdcfg.styles = { us = "-option '' -option ctrl:nocaps", mac = "-option '' -option ctrl:nocaps -option altwin:swap_lalt_lwin" }
kbdcfg.style = "us"
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { { "us", beautiful.us_flag },
                  { "se", beautiful.se_flag } }
kbdcfg.current = 1 -- us is the default layout
kbdcfg.widget = wibox.widget.imagebox() -- widget({ type = "imagebox", align = "right" })
kbdcfg.widget:set_image(kbdcfg.layout[kbdcfg.current][2])
kbdcfg.set = function ()
   local t = kbdcfg.layout[kbdcfg.current]
   local s = kbdcfg.styles[kbdcfg.style]
   kbdcfg.widget:set_image(t[2])
   awful.util.spawn_with_shell( kbdcfg.cmd .. " " .. t[1] .. " " .. s )
   naughty.notify({ title = t[1] .. " (" .. kbdcfg.style .. ")",
                    text = "Keyboard layout set to " .. t[1] .. " (style: " .. kbdcfg.style .. ")\n" .. kbdcfg.cmd .. " " .. t[1] .. " " .. s,
                    preset = naughty.config.presets.low
   })
end
kbdcfg.switch = function ()
   kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
   kbdcfg.set()
end
kbdcfg.switch_style = function()
   if kbdcfg.style == "mac" then
      kbdcfg.style = "us"
   else
      kbdcfg.style = "mac"
   end
   kbdcfg.set()
end

-- Keyboard layout mouse bindings
kbdcfg.widget:buttons(awful.util.table.join(
                         awful.button({ }, 1, function () kbdcfg.switch() end)
))


-- Email count widget

-- function string_starts(String,Start)
--    return string.sub(String,1,string.len(Start))==Start
-- end

-- function style_from(f)
--    return '<i>' .. awful.util.escape(f) .. '</i>'
-- end

-- function style_subject(s)
--    return '<span color="' .. beautiful.fg_urgent .. '">' .. awful.util.escape(s) .. '</span>'
-- end

-- function limit_string(s, l)
--    if string.len(s) > l then
--       return string.sub(s, 1, l) .. '...'
--    else
--       return s
--    end
-- end

-- mailcount = {}
-- mailcount.notmuch_cmd = 'notmuch'
-- mailcount.enabled = os.execute("which " .. mailcount.notmuch_cmd .. " >/dev/null") == 0
-- mailcount.widget = widget({ type = "imagebox", align = "right" })
-- mailcount.tooltip = awful.tooltip(
--    {
--       objects = { mailcount.widget },
--       timer_function = function ()
--          if not mailcount.enabled then
--             return '   <b>Disabled.</b>   \n'
--          end
--          local unread = awful.util.pread(mailcount.notmuch_cmd .. " search --format=json tag:unread")
--          local parsed = json.decode(unread)
--          local info = ''
         
--          for i,thread in ipairs(parsed) do
--             info = info .. ' [' .. thread['matched'] .. '/' .. thread['total'] .. '] ' .. style_subject(thread['subject']) .. '  \n'
--             info = info .. style_from('   ' .. thread['date_relative'] .. ': ' .. limit_string(thread['authors'], 50)) .. '  \n'
--          end
         
--          if string.len(info) == 0 then
--             info = '   <b>Inbox zero.</b>   \n'
--          end
--          info = '\n' .. info
         
--          return '<span color="' .. beautiful.fg_normal .. '">' .. info .. '</span>'
--       end
-- })
-- mailcount.timer = timer({timeout=10})
-- mailcount.widget:set_image(beautiful.mail_0_icon)

-- function mailcount.check_mailcount()
--    if not mailcount.enabled then return end
--    local count = awful.util.pread(mailcount.notmuch_cmd .. " count tag:unread")
--    if tonumber(count) > 0 then
--       mailcount.widget:set_image(beautiful.mail_1_icon)
--    else
--       mailcount.widget:set_image(beautiful.mail_0_icon)
--    end
-- end

-- if mailcount.enabled then
--     mailcount.timer:connect_signal("timeout", mailcount.check_mailcount)
--     mailcount.timer:start()
--     mailcount.check_mailcount()
-- end

-- now playing
mynowplaying = {}
mynowplaying.widget = wibox.widget.textbox()
mynowplaying.timer = timer({ timeout = 5 })
mynowplaying.update = function() 
   txt = awful.util.pread("now-playing")
   mynowplaying.widget:set_markup('<span color="#4A4646">' .. awful.util.escape(txt) .. '_</span>')
end
mynowplaying.timer:connect_signal("timeout", mynowplaying.update)
mynowplaying.timer:start()

mynowplaying.widget:buttons(awful.util.table.join(
                               awful.button({}, 1, function ()
                                               awful.util.spawn("xmms2 toggle")
                               end),
                               awful.button({}, 3, function ()
                                               awful.util.spawn("xmms2 next")
                                               awful.util.spawn("sleep 2")
                                               mynowplaying.update()
                               end)
))

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, 
                                          awful.widget.tasklist.filter.currenttags, 
                                          mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(mynowplaying.widget) end
    if s == 1 then right_layout:add(kbdcfg.widget) end
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    if s == 1 then right_layout:add(mytextclock) end
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    --awful.key({ modkey,           }, "Tab",
    --    function ()
    --        awful.client.focus.history.previous()
    --       if client.focus then
    --            client.focus:raise()
    --        end
    --    end),

    awful.key({ modkey,           }, "Tab",
        function ()
           awful.client.cycle(false)
           c = awful.client.getmaster()
           awful.client.focus.byidx(0, c)
           c:raise()
        end),

    awful.key({ modkey, "Shift"   }, "Tab",
        function ()
           awful.client.cycle(true)
           c = awful.client.getmaster()
           awful.client.focus.byidx(0, c)
           c:raise()
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "]", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey,           }, "[", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    -- Keyboard switcher
    awful.key({ modkey },            "F12",   function () kbdcfg.switch() end),
    awful.key({ modkey, "Shift" }, "F12", function () kbdcfg.switch_style() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "b",      function(c)
                 if c.titlebar then
                    awful.titlebar.remove(c)
                 else
                    awful.titlebar(c, { modkey = modkey })
                 end
    end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

function titlebar_add_with_settings(c)
   awful.titlebar.add(c, { modkey = modkey, height = 16 })
end

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     size_hints_honor = false,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule_any = { class = { "MPlayer", "pinentry", "Gimp" } },
      properties = { floating = true } },
    { rule = { instance = "plugin-container" },
      properties = { floating = true } },
    { rule = { instance = "exe" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    -- Add a titlebar to floating windows
    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_middle(middle_layout)
        layout:set_right(right_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- awful.titlebar(c) -- show
-- awful.titlebar(c, {size = 0}) -- hide

-- initialize the keyboard map on startup
kbdcfg.set()

-- }}}
