-- trickkiste [v2.8.2] for Awesome WM [v3.5.2-573-gd5e3658 (The Fox)] --
-- <max@10tacle.10>
-- 06.08.15 09:06:47

-- {{{ Libraries
  -- Standard --
  local gears             = require("gears")
  local awful             = require("awful")
  awful.rules             = require("awful.rules")
                            require("awful.autofocus")
  timer                   = require("gears.timer")
  -- Widget and Layout --
  local wibox             = require("wibox")
  local lain              = require("lain")
  -- Theme handling --
  beautiful               = require("beautiful")
  local vicious           = require("vicious")
  -- Notification --
  local naughty           = require("naughty")
  -- User --
  local battery           = require("lib/battery")
  local net               = require("lib/net")
-- }}}

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
                       text = tostring(err) })
      in_error = false
    end)
  end
-- }}}

-- {{{ Variables
  -- Paths --
  local home              = os.getenv("HOME")
  local confdir           = home .. "/.config/awesome"
  local bin_path          = home .. "/bin/"
  local themes            = confdir .. "/themes"
  local active_theme      = themes .. "/trickkiste"
  -- Shortcuts --
  local exec              = awful.util.spawn
  local sexec             = awful.util.spawn_with_shell
  local lsexec            = function (cmd, screen) cmd = { awful.util.shell, "-ic", cmd } return awesome.spawn(cmd, false, screen or mouse.screen) end
  -- Misc. --
  local term              = "/usr/bin/urxvtc"
  local terminal          = "/usr/bin/urxvtc"
  local editor            = os.getenv("EDITOR") or "vim"
  local editor_cmd        = term .. " -e " .. editor
  local browser           = bin_path .. "firefox"
  local fileman           = bin_path .. "thunar"
  local music             = term .. " -title Music -e /usr/bin/ncmpcpp"
  local chat              = term .. " -title Chat -e sh " .. home .. "/bin/irssi"
  local torrent           = term .. " -title Torrent -e /usr/bin/rtorrent"
  local tasks             = term .. " -title Tasks -e sudo /usr/bin/htop"
  local btclient          = "/usr/bin/electrum"
  -- Meta Keys --
  local modkey            = "Mod4"
  local altkey            = "Mod1"
-- }}}

-- {{{ Debug helper
  -- Usage: $ echo "dbg('VAR')" | awesome-client
  -- Make sure that "top_center" is working:
  -- # cd /usr/share/awesome/lib && patch < naughty.lua-top_center.patch
  function dbg(vars)
    local capi = {
      mouse = mouse,
      screen = screen
    }
    naughty.notify({
      text = "VARS: "..vars,
      font = beautiful.widget_font_big,
      font_size = 10,
      timeout = 10,
      width = 1400,
      position = "top_center",
      border_color = '#D00000',
      border_width = 2,
      screen = capi.mouse.screen
    })
  end
-- }}}

-- {{{ Theme and Wallpaper
  -- Themes define colours, icons, font and wallpapers.
  beautiful.init(active_theme .. "/theme.lua")
  -- Wallpaper
  if beautiful.wallpaper then
    for s = 1, screen.count() do
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
  end
-- }}}

-- {{{ Autostart
  function run_once(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
      findme = cmd:sub(0, firstspace-1)
    end
    sexec("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
  end
  --run_once("xcompmgr -cCf -r 0 -D 2 &")
  --run_once("compton -cC -fF -i 0.8 -bc -t -8 -l -9 -r 6 -o 0.7 -m 1.0 &")
-- }}}

-- {{{ Layouts
  layouts = {
    awful.layout.suit.fair.horizontal,  -- 1
    awful.layout.suit.fair,             -- 2
    awful.layout.suit.tile.bottom,      -- 3
    awful.layout.suit.tile.top,         -- 4
    awful.layout.suit.floating,         -- 5
    awful.layout.suit.max               -- 6
    -- awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
  }
-- }}}

-- {{{ Tags
  tags = {
    settings = {
      { names  = { " 1/mail ",  " 2/term ", " 3/web ",  " 4/irc ",  " 5/vm ",   " 6/else ",      " 7/.. ",      " 8/.. ", " 9/media " },
        layout = { layouts[3],  layouts[1], layouts[3], layouts[1], layouts[3], layouts[1], layouts[1], layouts[1], layouts[1] }
      },
      { names  = { " âš¡ ",      " x " },
        layout = { layouts[1], layouts[1] }
      }
    }
  }
  -- Create diffrent tag layout for each attached display
  if screen.count() > 1 then
    for x = 1, screen.count() do
      tags[x] = awful.tag(tags.settings[x].names, x, tags.settings[x].layout)
    end
  else
    for y = 1, screen.count() do
      tags[y] = awful.tag({ " 1/mail ", " 2/term ", " 3/web ", " 4/irc ", " 5/vm ", " 6/else ", " 7/.. ", " 8/.. ", " 9/media "}, y, layouts[1])
    end
  end
-- }}}

-- {{{ Menu
  m_awesome = {
    { "Manual               ", term .. " -e man awesome" },
    { "Edit Config          ", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
    { "Merge Xdefaults      ", "xrdb -merge ~/.Xdefaults" },
    { "Configure GTK        ", function () exec("/usr/bin/lxappearance") end },
    { "Open Site: Naquadah  ", function () exec(browser .. " http://awesome.naquadah.org") end },
    { "Restart Awesome      ", awesome.restart },
    { "Quit                 ", awesome.quit }
  }
  m_display = {
    { "Extend               ", function () exec(bin_path .. "display_mode_extend") end },
    { "Clone                ", function () exec(bin_path .. "display_mode_clone") end },
    { "Normal               ", function () exec(bin_path .. "display_mode_normal") end },
    { "NB Off               ", function () exec(bin_path .. "display_mode_nb_off") end }
  }
  m_system = {
    { "cups config          ", function () sexec("firefox 'http://localhost:631'") end }
  }
  m_remote = {
    { "*.20.2 (vnc)         ", function () exec("vncviewer 192.168.20.2") end },
    { "Accounting VM        ", function () exec(bin_path .. "rdesktop_pacc01_accounting") end },
    { "pwin01 - Admin.      ", function () exec(bin_path .. "rdesktop_pwin_administrator") end },
    { "aoe - avp.           ", function () exec(bin_path .. "rdesktop_aoe") end }
  }
  mainmenu = awful.menu({
    items = {
      { "-  Awesome WM  -", m_awesome },
      { "Display         ", m_display },
      { "Konfiguration   ", m_system },
      { "Remote          ", m_remote },
      { "Filemanager     ", function () exec(fileman) end },
      { "irssi           ", function () exec(chat)    end }
    }
  })
-- }}}

-- {{{ Wibox
  markup = lain.util.markup
  -- {{{ TIME
    local clock_widget_text = awful.widget.textclock("<span color='#000000'> %R </span>",60)
    local clock_widget = wibox.widget.background()
    clock_widget:set_widget(clock_widget_text)
    clock_widget:set_bg("#df7401")
  -- }}}
  -- {{{ DATE
    local markup = lain.util.markup
    lain.widgets.calendar:attach(clock_widget, { font = beautiful.widget_font_big, font_size = 10 })
  -- }}}
  -- {{{ VOLUME
    local volicon = wibox.widget.imagebox()
    volicon:set_image(beautiful.widget_vol)
    local volumewidget = wibox.widget.textbox()
    vicious.register( volumewidget, vicious.widgets.volume, "$1%", 1, "Master" )
  -- }}}
  -- {{{ MAIL
    local mail_icon = wibox.widget.imagebox()
    local mail_widget_acc1 = wibox.widget.textbox()
    local mail_widget_acc2 = wibox.widget.textbox()
    mail_icon:set_image(beautiful.widget_mail)
    -- xxxx/xxx
    vicious.register(mail_widget_acc1, vicious.widgets.mdir, function (widget, args)
      -- Ungelesene Mails vorhanden --
      if args[1] > 0 then
        return "<span color='" .. theme.fg_orange .."'>".. args[1] .."</span>"
      end
      -- Keine ungelesenen Mails --
      if args[1] == 0 then
        return args[1]
      end
      return nil
    end, 5, {home .. "xxxx"})
    -- xxx/xxx
    vicious.register(mail_widget_acc2, vicious.widgets.mdir, function (widget, args)
      -- Ungelesene Mails vorhanden --
      if args[1] > 0 then
        return "<span color='" .. theme.fg_orange .."'>".. args[1] .."</span>"
      end
      -- Keine ungelesenen Mails --
      if args[1] == 0 then
        return args[1]
      end
      return nil
    end, 5, {home .. "xxxx"})
  -- }}}
  -- {{{ BATTERY
    local bat_icon = wibox.widget.imagebox(beautiful.widget_batt)
    bat_widget = wibox.widget.textbox()
    bat_widget_timer = timer({timeout = 1})
    bat_widget_timer:connect_signal("timeout", function()
      local bat0 = batteryInfo("BAT0")
      local bat1 = batteryInfo("BAT1")
      if bat0:match("A/C") and bat1:match("A/C") then
        bat_widget:set_markup("<span color='darkgreen'>A/C</span>")
      else
        bat_widget:set_markup(bat0.."/"..bat1)
      end
    end)
    bat_widget_timer:start()
  -- }}}
  -- {{{ NETWORK
    net_widget = wibox.widget.textbox()
    net_widget_timer = timer({timeout = 1})
    net_widget_timer:connect_signal("timeout", function()
      net_widget:set_markup(netInfo('enp0s25','wlp3s0','wwp0s20u4','tun0'))
    end)
    net_widget_timer:start()
    local function wifi_ssid()
      local f_wfn, wfn
      local capi = {
        mouse = mouse,
        screen = screen
      }
      local f_wfn = io.popen("nmcli d wifi list")
      local wfn = f_wfn:read("*all")
      f_wfn:close()

      wifiinfo = naughty.notify( {
        text	= wfn,
        font = beautiful.widget_font_big,
        font_size = 10,
        timeout	= 0,
        position = "top_right",
        border_color = '#404040',
        border_width = 1,
        screen	= capi.mouse.screen })
    end
    net_widget:connect_signal('mouse::enter', function () wifi_ssid(path) end)
    net_widget:connect_signal('mouse::leave', function () naughty.destroy(wifiinfo) end)
  -- }}}
  -- {{{ NETWORK USAGE
    local netdownicon = wibox.widget.imagebox()
    netdownicon:set_image(beautiful.widget_netdown)
    local netupicon = wibox.widget.imagebox()
    netupicon:set_image(beautiful.widget_netup)
    neticon = wibox.widget.imagebox(beautiful.widget_net)
    neticon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
    local netwidget = wibox.widget.background(lain.widgets.net({
      notify = "off",
      settings = function()
        widget:set_markup(markup(beautiful.fg_orange, " " .. net_now.received)
        .. " " ..
        markup(beautiful.fg_yellow, " " .. net_now.sent .. " "))
      end
    }), beautiful.bg_normal)
  -- }}}
  -- {{{ TEMPERATURE
    local tempicon = wibox.widget.imagebox()
    tempicon:set_image(beautiful.widget_temp)
    local tempwidget = wibox.widget.textbox()
    vicious.register(tempwidget, vicious.widgets.thermal, "$1C", 9, { "coretemp.0/hwmon/hwmon2", "core"})

    local function disptemp()
      local f, infos
      local capi = {
        mouse = mouse,
        screen = screen
      }

      f = io.popen("sensors && cat /proc/acpi/ibm/fan")
      infos = f:read("*all")
      f:close()

      showtempinfo = naughty.notify( {
        text	= infos,
        font = beautiful.widget_font_big,
        font_size = 10,
        timeout	= 0,
        position = "top_right",
        border_color = '#404040',
        border_width = 1,
        -- opacity = 0.95,
        screen	= capi.mouse.screen })
    end
    tempwidget:connect_signal('mouse::enter', function () disptemp(path) end)
    tempwidget:connect_signal('mouse::leave', function () naughty.destroy(showtempinfo) end)
    tempwidget:buttons(awful.util.table.join(
      awful.button({ }, 1, function () sexec(bin_path .. "fan_control") end)
    ))
  -- }}}
  -- {{{ IRC
    local ircwidget = wibox.widget.textbox()
    local function remove_hilight()
      clean = ""
      ircwidget:set_markup(clean)
    end
    function irc(user,mesg,chan)
      local capi = {
        mouse = mouse,
        screen = screen
      }

      -- Make sure that "top_center" is working!
      -- # cd /usr/share/awesome/lib && patch < naughty.lua-top_center.patch
      naughty.notify({
        text = "USER: "..user.."\nMESG: "..mesg,
        font = beautiful.widget_font_big,
        font_size = 10,
        timeout = 3,
        margin = 10,
        width = 1920,
        position = "top_center",
        border_color = '#94738C',
        border_width = 1,
        screen = capi.mouse.screen
      })

      if chan == nil then
        hi = "<span color='" .. beautiful.fg_yellow .. "'>Highlight:</span> From <span color='" .. beautiful.fg_magenta .. "'>" .. user .. "</span> |"
        naughty.notify({text = user .. ": " .. mesg, timeout = 5, position = "top_center", margin = 10, height = 50, width = 500, border_color = '#94738C', border_width = 1, screen = capi.mouse.screen})
      else
        hi = "<span color='" .. beautiful.fg_yellow .. "'>Highlight:</span> From <span color='" .. beautiful.fg_magenta .. "'>" .. user .. "</span><span color='" .. beautiful.fg_yellow .."'>@</span><span color='" .. beautiful.fg_blue .. "'>" .. chan .. "</span> |"
        naughty.notify({text = user .. "@" .. chan .. ": " .. mesg, timeout = 5, position = "top_center", margin = 10, height = 50, width = 500, border_color = '#94738C', border_width = 1, screen = capi.mouse.screen})
      end
      if user == nil then
        remove_hilight()
      else
        ircwidget:set_markup(hi)
      end
    end
    ircwidget:connect_signal('mouse::enter', function () remove_hilight() end)
  -- }}}
  -- {{{ MPD
    local mpdwidget = wibox.widget.textbox()
    vicious.register(mpdwidget, vicious.widgets.mpd,
    function(widget, args)
    string = "MPD: <span color='" .. beautiful.fg_orange .. "'>" .. args["{Artist}"] .. "</span> <span color='" .. beautiful.fg_black .. "'>:</span> <span color='" .. beautiful.fg_yellow .. "'>" .. args["{Title}"] .. "</span> "
    -- play --
    if (args["{state}"] == "Play") then
      mpdwidget.visible = true
      return string
      -- pause --
      elseif (args["{state}"] == "Pause") then
      mpdwidget.visible = true
      return "MPD: <span color='" .. theme.fg_orange .."'>Paused</span>"
      -- stop --
      elseif (args["{state}"] == "Stop") then
      mpdwidget.visible = true
      return "MPD: <span color='" .. beautiful.fg_red .."'>Stopped</span>"
      -- not running --
      else
      mpdwidget.visible = true
      return "MPD: <span color='" .. beautiful.fg_red .."'>Off</span>"
      end
    end, 1)
  -- }}}
  -- {{{ CPU
  local cpuicon = wibox.widget.imagebox()
  cpuicon:set_image(beautiful.widget_cpu)
  local cpuwidget = wibox.widget.textbox()
  vicious.register( cpuwidget, vicious.widgets.cpu, "$1%", 3)
  cpuwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () exec("".. term.. "-e htop -C", false) end)
  ))
  local function pstree()
    local f, infos
    local capi = {
      mouse = mouse,
      screen = screen
    }

    f = io.popen("pstree -A")
    infos = f:read("*all")
    f:close()

    showpstree = naughty.notify( {
      text	= infos,
      font = beautiful.widget_font_big,
      font_size = 10,
      timeout	= 0,
      position = "top_right",
      border_color = '#404040',
      border_width = 1,
      -- opacity = 0.95,
      screen	= capi.mouse.screen })
  end
  cpuwidget:connect_signal('mouse::enter', function () pstree(path) end)
  cpuwidget:connect_signal('mouse::leave', function () naughty.destroy(showpstree) end)
  -- }}}
  -- {{{ MEM
    local memicon = wibox.widget.imagebox()
    memicon:set_image(beautiful.widget_mem)
    local memwidget = wibox.widget.textbox()
    -- vicious.register(memwidget, vicious.widgets.mem, "<span color=\"#7788af\">$2 MB</span>", 1)
    vicious.register(memwidget, vicious.widgets.mem, "$1%", 1)
    memwidget:buttons(awful.util.table.join(
      awful.button({ }, 1, function () exec("".. term.. " -e sudo htop", false) end)
    ))
    local function freemem()
      local f, infos
      local capi = {
        mouse = mouse,
        screen = screen
      }

      f = io.popen("free -m")
      infos = f:read("*all")
      f:close()

      showmemfree = naughty.notify( {
        text	= infos,
        font = beautiful.widget_font_big,
        font_size = 10,
        timeout	= 0,
        position = "top_right",
        border_color = '#404040',
        border_width = 1,
        -- opacity = 0.95,
        screen	= capi.mouse.screen })
    end
    memwidget:connect_signal('mouse::enter', function () freemem(path) end)
    memwidget:connect_signal('mouse::leave', function () naughty.destroy(showmemfree) end)
  -- }}}
  -- {{{ Hard Drives
    local fsicon = wibox.widget.imagebox()
    fsicon:set_image(beautiful.widget_fs)
    fswidget = lain.widgets.fs({
      settings  = function()
        fs_notification_preset.font = beautiful.widget_font_default
        widget:set_text("" .. fs_now.used .. "%")
      end
    })
  -- }}}
  --{{{ Weather
    yawn = lain.widgets.yawn(648820,
    {
      settings = function()
        yawn_notification_preset.font = beautiful.widget_font_big
        yawn_notification_preset.fg = white
      end
    })
  -- }}}
  -- {{{ Separators
    local separator_0 = wibox.widget.textbox()
    separator_0:set_text(' ')
    local separator_1 = wibox.widget.textbox()
    separator_1:set_markup(" <span foreground='grey'>|</span> ")
    local separator_2 = wibox.widget.textbox()
    separator_2:set_markup(" <span foreground='grey'>Â·</span> ")
    local separator_2_correct_bug = wibox.widget.textbox()
    separator_2_correct_bug:set_markup(" <span foreground='grey'>Â·</span>")
    local separator_3 = wibox.widget.textbox()
    separator_3:set_markup("<span foreground='grey'>/</span>")
  -- }}}
  -- {{{ Layout
    -- Create a wibox for each screen and add it --
    mywibox = {}
    mybottomwibox = {}
    mypromptbox = {}
    mylayoutbox = {}
    mytaglist = {}
    mytaglist.buttons = awful.util.table.join(
      awful.button({ }, 1, awful.tag.viewonly),
      awful.button({ modkey }, 1, awful.client.movetotag),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ modkey }, 3, awful.client.toggletag),
      awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
      awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
    )
    mytasklist = {}
    mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
      if c == client.focus then
        c.minimized = true
      else
        -- Without this, the following --
        -- :isvisible() makes no sense --
        c.minimized = false
        if not c:isvisible() then
          awful.tag.viewonly(c:tags()[1])
        end
        -- This will also un-minimize --
        -- the client, if needed --
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
      -- Create a promptbox for each screen --
      mypromptbox[s] = awful.widget.prompt()

      -- We need one layoutbox per screen --
      mylayoutbox[s] = awful.widget.layoutbox(s)
      mylayoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end))
      )

      -- Create a taglist widget --
      mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

      -- Create a tasklist widget --
      mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

      -- Create the wibox --
      mywibox[s] = awful.wibox({ position = "top", screen = s, border_width = 1, border_color = beautiful.border_normal, height = 18 })

      -- Widgets that are aligned to the left --
      left_layout = wibox.layout.fixed.horizontal()
      -- tags --
      left_layout:add(mytaglist[s])
      left_layout:add(separator_0)
      -- prompt --
      left_layout:add(mypromptbox[s])
      left_layout:add(separator_0)

      -- Widgets that are aligned to the right --
      right_layout = wibox.layout.fixed.horizontal()
      -- irc --
      right_layout:add(ircwidget)
      right_layout:add(separator_0)
      -- mpd --
      right_layout:add(mpdwidget)
      right_layout:add(separator_2)
      -- net --
      right_layout:add(net_widget)
      right_layout:add(separator_2_correct_bug)
      right_layout:add(netdownicon)
      right_layout:add(netwidget)
      right_layout:add(netupicon)
      right_layout:add(separator_2_correct_bug)
      -- mem --
      right_layout:add(memicon)
      right_layout:add(memwidget)
      right_layout:add(separator_2_correct_bug)
      -- cpu --
      right_layout:add(cpuicon)
      right_layout:add(cpuwidget)
      right_layout:add(separator_2_correct_bug)
      -- temp --
      right_layout:add(tempicon)
      right_layout:add(tempwidget)
      right_layout:add(separator_2_correct_bug)
      -- fs --
      right_layout:add(fsicon)
      right_layout:add(fswidget)
      right_layout:add(separator_2_correct_bug)
      -- bat --
      right_layout:add(bat_icon)
      right_layout:add(bat_widget)
      right_layout:add(separator_2_correct_bug)
      -- mail --
      right_layout:add(mail_icon)
      right_layout:add(mail_widget_acc1)
      right_layout:add(separator_3)
      right_layout:add(mail_widget_acc2)
      right_layout:add(separator_2_correct_bug)
      -- vol --
      right_layout:add(volicon)
      right_layout:add(volumewidget)
      right_layout:add(separator_2)
      -- time --
      right_layout:add(clock_widget)

      -- Now bring it all together --
      layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      -- layout:set_middle(mytasklist[s]) -- Taskliste in oberer wibox --
      layout:set_right(right_layout)

      mywibox[s]:set_widget(layout)

      -- Create the bottom wibox --
      mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 15 })
      mybottomwibox[s].visible = false

      -- Widgets that are aligned to the left --
      bottom_left_layout = wibox.layout.fixed.horizontal()
      bottom_left_layout:add(separator_0)

      -- Widgets that are aligned to the right --
      bottom_right_layout = wibox.layout.fixed.horizontal()
      bottom_right_layout:add(separator_0)
      if s == 1 then bottom_right_layout:add(wibox.widget.systray()) end
      bottom_right_layout:add(separator_0)
      bottom_right_layout:add(mylayoutbox[s])
      bottom_right_layout:add(separator_0)

      -- Now bring it all together (with the tasklist in the middle) --
      bottom_layout = wibox.layout.align.horizontal()
      bottom_layout:set_left(bottom_left_layout)
      bottom_layout:set_middle(mytasklist[s]) -- Taskliste in unterer wibox --
      bottom_layout:set_right(bottom_right_layout)
      mybottomwibox[s]:set_widget(bottom_layout)

      -- Wenn mehrere Monitore angeschlossen sind, alle Widgets (der rechten Seite) von sekundaeren Displays entfernen --
      if s > 1 then
        layout_notebook = wibox.layout.align.horizontal()
        layout_notebook:set_left(left_layout)
        mywibox[s]:set_widget(layout_notebook)
      end
      -- Wibox von Sekundaerbildschirmen entfernen --
      -- if s > 1 then mywibox[s].visible = not mywibox[s].visible end
  end
  -- }}}
-- }}}

-- {{{ Mouse Bindings
  root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
  ))
-- }}}

-- {{{ Key Bindings
    -- {{{ Tag Browsing
        globalkeys = awful.util.table.join(
        -- Non-empty tag browsing
        awful.key({ altkey            }, "Left", function () lain.util.tag_view_nonempty(-1) end),
        awful.key({ altkey            }, "Right", function () lain.util.tag_view_nonempty(1) end),
        awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    -- }}}
    -- {{{ Applications
        -- urxvt --
        awful.key({ modkey, "Shift"   }, "Return", function () exec(term) end),
        awful.key({ altkey, "Shift"   }, "Return", function () exec("sudo urxvt") end),
        -- thunar --
        awful.key({ modkey            }, "e", function () exec(fileman) end),
        -- Skype --
        awful.key({ modkey, "Control" }, "s", function () sexec(bin_path .. "skype") end),
        -- Teamviewer --
        awful.key({ modkey, "Control" }, "t", function () sexec("sudo " .. bin_path .. "teamviewer") end),
        -- firefox --
        awful.key({ modkey, "Control" }, "f", function () exec(browser) end),
        -- mutt --
        awful.key({ modkey, "Control" }, "m", function () lsexec("urxvtc -title Mail -e mutt") end),
        -- newsbeuter --
        awful.key({ modkey, "Control" }, "n", function () sexec("urxvtc -title RSS -e newsbeuter") end),
        -- ncmpcpp --
        awful.key({ modkey, "Control" }, "p", function () exec(music) end),
        -- irssi --
        awful.key({ modkey, "Control" }, "i", function () exec(chat) end),
        -- bitcoin --
        awful.key({ modkey, "Control" }, "b", function () sexec(btclient .. " -w xxxxwallet.dat") end),
        -- Sonstiges --
        -- Toggle xcompmgr:
        awful.key({ modkey,           }, "+", function () sexec(bin_path .. "check_xcompmgr.sh") end),
        -- Scratchpad -> ADD:
        awful.key({ modkey            }, "a", function () scratch.drop("urxvtc", "bottom", nil, nil, 0.30) end),
        -- Lock Screen:
        awful.key({ modkey            }, "-", function () exec("sudo " .. bin_path .. "slimlock") end),
        awful.key({ modkey,           }, "i", function () yawn.show(7) end),
    -- }}}
    -- {{{ Multimedia Keys
        -- Volume --
        awful.key({}, "#121", function () sexec(bin_path .. "dzen2_volume_control -t") end),
        awful.key({}, "#122", function () sexec(bin_path .. "dzen2_volume_control -d 8") end),
        awful.key({}, "#123", function () sexec(bin_path .. "dzen2_volume_control -i 8") end),
        -- Mic --
        awful.key({}, "#198", function () sexec(bin_path .. "dzen2_volume_control -m") end),
        -- Brightness --
        awful.key({}, "#232", function () exec("xbacklight -dec 12") end),
        awful.key({}, "#233", function () exec("xbacklight -inc 12") end),
        -- Screenshot --
        awful.key({}, "#235", function () sexec(bin_path .. "screenshot") end),
        -- Awesome Config --
        awful.key({}, "#179", function () lsexec("urxvtc -title Awesome-RC -e vim ~/.config/awesome/rc.lua") end),
        -- Web Search --
        awful.key({}, "#225", function ()
          awful.prompt.run({ prompt = "<span color=\"#BF4D80\">Web: </span>"}, mypromptbox[mouse.screen].widget,
            function (command)
            sexec("firefox --profile $CONFIG_HOME/mozilla/firefox/default 'https://www.google.de/search?q="..command.."'")
            end)
        end),
        -- Hibernate --
        --awful.key({}, "#128", function () exec("sudo pm-hibernate") end),
        -- Lock Display --
        awful.key({}, "#152", function () exec("slimlock") end),
        -- MPC next --
        awful.key({}, "#171", function () exec("mpc next") end),
        -- MPC prev --
        awful.key({}, "#173", function () exec("mpc prev") end),
        -- Toggle MPC (play/pause) --
        awful.key({}, "#172", function () exec("mpc toggle") end),
        -- MPC play FM stream --
        --awful.key({ modkey, "Shift"   }, "p", function () sexec(bin_path .. "last.fm-drum_n_bass.sh") end),
        awful.key({ modkey, "Shift"   }, "p", function () sexec(script_path .. "last.fm-rockabilly.sh") end),
        -- Toggle 'intl' KBD variant --
        awful.key({ modkey, "Shift"   }, "o", function () sexec(script_path .. "set_xkb_variant.sh") end),
        -- Hibernate / Suspend --
        -- awful.key({}, "#165", function () exec("sudo /usr/sbin/pm-hibernate") end),
        -- awful.key({}, "#150", function () exec("sudo /usr/sbin/pm-suspend") end),
    -- }}}
    -- {{{ Toggle Wibox (show/hide)
        awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible end),
        awful.key({ modkey, altkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
        mybottomwibox[mouse.screen].visible = not mybottomwibox[mouse.screen].visible end),
        awful.key({ altkey }, "b", function ()
        mybottomwibox[mouse.screen].visible = not mybottomwibox[mouse.screen].visible end),
    -- }}}
    -- {{{ Layout Manipulation
        awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(   1)    end),
        awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(  -1)    end),
        awful.key({ modkey,           }, "l", function () awful.tag.incmwfact(    0.05)    end),
        awful.key({ modkey,           }, "h", function () awful.tag.incmwfact(   -0.05)    end),
        awful.key({ modkey, "Shift"   }, "l", function () awful.client.incmwfact(-0.05)    end),
        awful.key({ modkey, "Shift"   }, "h", function () awful.client.incmwfact( 0.05)    end),
        -- awful.key({ modkey, "Control" }, "l", function () awful.tag.incnmaster(     -1)    end),
        -- awful.key({ modkey, "Control" }, "h", function () awful.tag.incnmaster(      1)    end),
        -- awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(        -1)    end),
        -- awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol(         1)    end),
        awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
        awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
        -- Scratchpad --
        awful.key({ modkey            }, "s",     function () scratch.pad.toggle()          end),
    -- }}}
    -- {{{ Focus Control
        -- Move Cursor to top left corner --
        awful.key({ modkey, altkey    }, "p", function () awful.screen.focus_relative(1) end),
        -- Restore minimized client --
        awful.key({ modkey, "Shift"   }, "n", awful.client.restore),
        --awful.key({ modkey, "Shift"   }, "n", function () c = awful.client.restore() if c then client.focus = c c:raise() end end),
        -- Jump to urgent client --
        awful.key({ modkey            }, "u", awful.client.urgent.jumpto),
        -- Conflicts with  mutt configuration, and I don't need it..
        -- Jump next client --
        --awful.key({ altkey }, "k", function ()
        --        awful.client.focus.byidx( 1)
        --        if client.focus then client.focus:raise() end
        --    end),
        -- Jump previous client --
        --awful.key({ altkey }, "j", function ()
        --        awful.client.focus.byidx(-1)
        --        if client.focus then client.focus:raise() end
        --    end),
        -- Jump down --
        awful.key({ modkey }, "j", function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
        -- Jump up --
        awful.key({ modkey }, "k", function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
        -- Jump left --
        awful.key({ modkey }, "h", function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
        -- Jump right --
        awful.key({ modkey }, "l", function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),
    -- }}}
    -- {{{ Awesome Control
        awful.key({ modkey, "Shift" }, "r", awesome.restart),
        awful.key({ modkey, "Shift" }, "q", awesome.quit),
        awful.key({ modkey,         }, "m", function () mainmenu:show({keygrabber=true}) end), -- MOD+m: Open Menu
    -- }}}
    -- {{{ Prompts
        awful.key({ modkey,         }, "p", function () sexec("dmenu_path_c | dmenu_run -b -l 15 -sf '#DF7401' -sb '#121212' -nf '#ffffff' -nb '#282828' -fn '-*-squarefont-*-*-*-*-18-*-*-*-*-*-iso8859-1'" ) end),
        awful.key({ modkey,         }, "o", function () sexec("nmcli_dmenu" ) end),
        awful.key({ altkey,         }, "F1", function ()
            awful.prompt.run({ prompt = "<span color=\"#BF4D80\">Dict: </span>"}, mypromptbox[mouse.screen].widget,
                function (words)
                    sexec("firefox 'http://www.dict.cc/?s="..words.."'")
                end)
        end)
    -- }}}
    )
    -- {{{ Client Manipulation
        clientkeys = awful.util.table.join(
            -- Scratchpad -> Center --
            awful.key({ modkey            }, "d", function (c) scratch.pad.set(c, 0.60, 0.60, true) end),
            awful.key({ modkey,           }, "Return",
                function (c)
                    c.maximized_horizontal = not c.maximized_horizontal
                    c.maximized_vertical   = not c.maximized_vertical
                end
            ),
            awful.key({ modkey, "Shift"   }, "t",
                function (c)
                    if   c.titlebar then awful.titlebar.remove(c)
                    else awful.titlebar.add(c, { modkey = modkey }) end
                end
            ),
            -- awful.key({ modkey, "Control" }, "r", function (c) c:redraw()                       end),
            awful.key({ modkey,           }, "f", function (c) c.fullscreen = not c.fullscreen  end),
            awful.key({ modkey,           }, "q", function (c) c:kill()                         end),
            awful.key({ modkey,           }, "Left", awful.client.movetoscreen                     ),
            awful.key({ modkey,           }, "Right", awful.client.movetoscreen                    ),
            awful.key({ modkey, "Shift"   }, "t", function (c) c.ontop = not c.ontop            end),
            --awful.key({ modkey,           }, "n", function (c) c.minimized = not c.minimized    end)
            awful.key({ modkey,           }, "n", function (c) c.minimized = true end)
        )
    -- }}}
    -- {{{ Keyboard digits
        -- Compute the maximum number of digit we need, limited to 9 --
        keynumber = 0
        for s = 1, screen.count() do
           keynumber = math.min(9, math.max(#tags[s], keynumber));
        end
    -- }}}
    -- {{{ Tag Control
        -- Bind all key numbers to tags --
        -- Be careful: we use keycodes to make it works on any keyboard layout --
        -- This should map on the top row of your keyboard, usually 1 to 9 --
        for i = 1, keynumber do
            globalkeys = awful.util.table.join(globalkeys,
                awful.key({ modkey }, "#" .. i + 9,
                          function ()
                                screen = mouse.screen
                                if tags[screen][i] then
                                    awful.tag.viewonly(tags[screen][i])
                                end
                          end),
                awful.key({ modkey, "Control" }, "#" .. i + 9,
                          function ()
                              screen = mouse.screen
                              if tags[screen][i] then
                                  awful.tag.viewtoggle(tags[screen][i])
                              end
                          end),
                awful.key({ modkey, "Shift" }, "#" .. i + 9,
                          function ()
                              if client.focus and tags[client.focus.screen][i] then
                                  awful.client.movetotag(tags[client.focus.screen][i])
                              end
                          end),
                awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                          function ()
                              if client.focus and tags[client.focus.screen][i] then
                                  awful.client.toggletag(tags[client.focus.screen][i])
                              end
                          end))
        end

        clientbuttons = awful.util.table.join(
            awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
            awful.button({ modkey }, 1, awful.mouse.client.move),
            awful.button({ modkey }, 3, awful.mouse.client.resize))

        -- Set keys --
        root.keys(globalkeys)
    -- }}}
-- }}}

-- {{{ Rules
  -- Rules to apply to new clients (through the "manage" signal).
  awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
        properties = { border_width = beautiful.border_width,
                       border_color = beautiful.border_normal,
                       focus = true,
                       keys = clientkeys,
                       maximized_vertical = false,
                       maximized_horizontal = false,
                       buttons = clientbuttons,
                       size_hints_honor = false
                      }
    },
    { rule = { class = "Xmessage", instance = "xmessage"          }, properties = { floating = true }, callback = awful.titlebar.add  },
    { rule = { class = "Firefox",                                 }, properties = { tag = tags[1][3], } },
    -- URxvt --
    { rule = { class = "URxvt"                                    }, properties = { }, callback = awful.client.setslave },
    { rule = { class = "URxvt",    name = "Mail"                  }, properties = { tag = tags[1][1], switchtotag = true } },
    { rule = { class = "URxvt",    name = "RSS"                   }, properties = { tag = tags[1][1], switchtotag = true } },
    { rule = { class = "URxvt",    name = "Torrent"               }, properties = { tag = tags[1][3], switchtotag = true } },
    { rule = { class = "URxvt",    name = "Chat"                  }, properties = { tag = tags[1][4], switchtotag = true } },
    { rule = { class = "URxvt",    name = "Music"                 }, properties = { tag = tags[1][9], switchtotag = true } },
  }
-- }}}

-- {{{ Signals
  -- Signal function to execute when a new client appears.
  client.connect_signal("manage", function (c)
    if not awesome.startup then
      -- Set the windows at the slave,
      -- i.e. put it at the end of others instead of setting it master.
      -- awful.client.setslave(c)

      -- Put windows in a smart way, only if they do not set an initial position.
      if not c.size_hints.user_position and not c.size_hints.program_position then
          awful.placement.no_overlap(c)
          awful.placement.no_offscreen(c)
      end
    elseif not c.size_hints.user_position and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
    end

    local titlebars_enabled = false
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

      -- Widgets that are aligned to the left
      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(awful.titlebar.widget.iconwidget(c))
      left_layout:buttons(buttons)

      -- Widgets that are aligned to the right
      local right_layout = wibox.layout.fixed.horizontal()
      right_layout:add(awful.titlebar.widget.floatingbutton(c))
      right_layout:add(awful.titlebar.widget.maximizedbutton(c))
      right_layout:add(awful.titlebar.widget.stickybutton(c))
      right_layout:add(awful.titlebar.widget.ontopbutton(c))
      right_layout:add(awful.titlebar.widget.closebutton(c))

      -- The title goes in the middle
      local middle_layout = wibox.layout.flex.horizontal()
      local title = awful.titlebar.widget.titlewidget(c)
      title:set_align("center")
      middle_layout:add(title)
      middle_layout:buttons(buttons)

      -- Now bring it all together
      local layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      layout:set_right(right_layout)
      layout:set_middle(middle_layout)

      awful.titlebar(c):set_widget(layout)
    end
  end)

  -- Enable sloppy focus
  client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  --client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
  --client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
  -- Swap window transparency on focus --
  client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus c.opacity = 1.0 end)
  client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal c.opacity = 0.9 end)
-- }}}

-- {{{ Custom signals
  -- Stop MPD playback while leaving awesome --
  awesome.connect_signal("exit", function ()
      awful.util.spawn_with_shell("/usr/bin/mpc pause &>/dev/null")
  end)
-- }}}
