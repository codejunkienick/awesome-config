--[[
                                     
     Steamburn Awesome WM config 3.0 
     github.com/copycat-killer       
                                     
--]]

-- {{{ Required libraries
local gears     = require("gears")
local awesome_timer = require("gears").timer or timer
local awful     = require("awful")
awful.rules     = require("awful.rules")
                  require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local lain      = require("lain")
local battary   = require("battery")
local tyrannical = require("tyrannical")
local APW        = require("apw/widget")
local awesompd = require("awesompd/awesompd")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
APW.Update()


-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

function is_empty(tag,rule)

  for _, c in pairs(tag:clients()) do
    if not awful.rules.match_any(c, rule) then
      return false
    end
  end

  return true
end

run_once("urxvtd")
run_once("unclutter -root")


beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme/theme.lua")

-- common
local modkey     = "Mod4"
local altkey     = "Mod1"
local terminal   = "termite" or "terminator" or "xterm"
local dropdownterm = "termite"
local editor     = os.getenv("EDITOR") or "nvim" or "vi"
local editor_cmd = terminal .. " -e " .. editor


local quakescratch = {}
for s in screen do
  quakescratch[s] = lain.util.quake({
    app     = terminal,
    name    = "Scratchpad",
    argname = "--name %s",
    height  = 0.5,
    width   = 0.6,
    vert    = "center",
    horiz   = "center"
  })
end


-- user defined
local browser2    = "chromium"
local browser   = "firefox-aurora"
local music_player = "ncmpcpp"

-- lain
lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol    = 1
lain.layout.cascade.offset_x = 8
lain.layout.cascade.offset_y = 8
lain.layout.cascade.nmaster = 5

local layouts = {
    lain.layout.cascade,
    lain.layout.termfair,
    lain.layout.centerwork,
    awful.layout.suit.fair,
    awful.layout.suit.magnifier,
}
-- }}}

-- First, set some settings
tyrannical.settings.default_layout =  awful.layout.suit.tile.left
tyrannical.settings.mwfact = 0.66
tyrannical.tags = {
  {
    name        = "term"      ,
    init        = true        ,
    screen      = 1,
    exclusive   = true        ,
    layout      = layouts[3] ,
    class       = {"termite", "XTerm"}
  },
  {
    name        = "web"             ,
    screen      = 1,
    init        = true              ,
    exclusive   = false             ,
    mwfact      = 0.70              ,
    layout      = layouts[1]       ,
    class       = {"Firefox", "brave" ,"chromium", "Google-chrome-unstable", "Google-chrome", "Tor Browser", "termite:web", "Midori"}
  },
  {
    name        = "edit"       ,
    screen      = 1,
    init        = true        ,
    exclusive   = true       ,
    layout      = layouts[3],
    class       = {"Sublime_text","Vscode","Gvim", "NyaoVim", "termite:vim", "Emacs"}
  },
  {
    name        = "dev"       ,
    screen      = 1,
    init        = true        ,
    exclusive   = false       ,
    mwfact      = 0.25,
    ncol        = 1,
    layout      = layouts[3],
    class       = {"jetbrains-pycharm-ce", "jetbrains-pycharm", "jetbrains-webstorm", "MonoDevelop", "Code::Blocks", "Scala IDE", "Codelite", "Atom", "Java", "jetbrains-idea-ce", "LocalTestRunner", "jetbrains-idea-c", "jetbrains-idea", "Code", "jetbrains-rider"}
  },
  {
    name        = "img",
    init        = true,
    exclusive   = true,
    layout      = layouts[1],
    class       = {"Photoshop.exe", "Inkscape"      , "KolourPaint"    , "Krita"     , "Karbon"       , "Karbon14", "Gimp"}
  },
  {
    name        = "vm"       ,
    init        = true        ,
    exclusive   = true       ,
    init        = false                 ,
    ncol        = 2,
    layout      = layouts[3],
    class       = {"vmware", "VirtualBox", "Android Virtual Device (AVD) Manager", "emulator64-x86", "Genymotion", "Genymotion Player"}
  },
  {
    name        = "docs"     ,
    screen      = 1,
    init        = true        ,
    exclusive   = true        ,
    layout      = layouts[4] ,
    mwfact      = 0.65,
    class       = {
      "MuPDF", "llpp"     , "Qpdfview"         , "Evince"    , "EPDFviewer"   , "xpdf",
      "Xpdf"          , "libreoffice-writer", "libreoffice-calc", "LibreOffice 5.0", "libreoffice", "libreoffice-startcenter", "libreoffice-impress" }
    },
    {
      name        = "ssh"     ,
      init        = true        ,
      exclusive   = true        ,
      layout      = layouts[4] ,
      mwfact      = 0.65,
      class       =  {}
    },
    {
      name        = "dj"     ,
      init        = false        ,
      exclusive   = true        ,
      layout      = layouts[4] ,
      class       = {"xfreerdp"}
    },
    {
      name        = "files"     ,
      init        = false        ,
      exclusive   = true        ,
      layout      = layouts[4] ,
      class       = {"Thunar", "Nautilus", "termite:mc"}
    },
    -----------------VOLATILE TAGS-----------------------
    {
      name = "db",
      init = false,
      excluse = true,
      layout = layouts[4],
      class = {"Pgadmin3", "Mysql-workbench-bin",}
    },
    {
      name = "games",
      init = false,
      excluse = true,
      layout = layouts[4],
      no_focus_stealing_in = true ,
      class = {"Steam"}
    },
    {
      name        = "wine",
      init        = false                 ,
      position    = 10                    ,
      exclusive   = true                  ,
      layout      = layouts[4] ,
      class       = {"Wine"}
    },
    {
      name        = "picture"             ,
      init        = false                 ,
      position    = 10                    ,
      exclusive   = true                  ,
      layout      = awful.layout.suit.max ,
      class       = {"Digikam"       , "F-Spot"         , "GPicView"  , "ShowPhoto"    , "KPhotoAlbum"}
    },
    {
      name                 = "music"       ,
      init                 = false         ,
      position             = 10            ,
      exclusive            = true          ,
      layout               = layouts[1]    ,
      no_focus_stealing_in = true ,
      class       = {"clementine", "Clementine"}
    },
    {
      name                 = "media"       ,
      init                 = false         ,
      position             = 10            ,
      exclusive            = true          ,
      layout               = layouts[3]    ,
      no_focus_stealing_in = true ,
      class       = {"Mpv", "Amarok"        , "SongBird"       , "last.fm", "Gpodder"   ,"Pragha"}
    },
    {
      name        = "office",
      init        = false                                          ,
      position    = 10                                             ,
      exclusive   = true                                           ,
      layout      = awful.layout.suit.max                          ,
      class       = {
        "OOWriter"      , "OOCalc"         , "OOMath"    , "OOImpress"    , "OOBase"       ,
        "SQLitebrowser" , "Silverun"       , "Workbench" , "KWord"        , "KSpread"      ,
        "KPres","Basket", "openoffice.org" , "OpenOffice.*"               , "LibreOffice"
      }
    } ,
    {
      name        = "chat",
      init        = false                                          ,
      position    = 10                                             ,
      exclusive   = true                                           ,
      screen      = 1,--config.data().scr.sec or config.data().scr.sec ,
      --   icon        = utils.tools.invertedIconPath("chat.png")       ,
      layout      = layouts[3]                         ,
      class       = {"discord", "Cutegram", "telegram", "Pidgin"        , "Kopete"         , "Skype"}
    } ,
    {
      name        = "mail",
      init        = false                                          ,
      position    = 10                                             ,
      exclusive   = true                                           ,
      --         screen      = 1,--config.data().scr.sec or config.data().scr.pri     ,
      --   icon        = utils.tools.invertedIconPath("mail2.png")      ,
      layout      = awful.layout.suit.max                          ,
      class       = {"Thunderbird"   , "kmail"          , "evolution" ,}
    } ,
    {
      name        = "conf",
      init        = false                                          ,
      position    = 10                                             ,
      exclusive   = false                                          ,
      --   icon        = utils.tools.invertedIconPath("tools.png")      ,
      layout      = layouts[4]                        ,
      class       = {"Systemsettings", "Pavucontrol", "Android SDK Manager", "gconf-editor", "Arandr"}
    } ,
    {
      name        = "Gimp",
      init        = false                                          ,
      position    = 10                                             ,
      exclusive   = false                                          ,
      --   icon        = utils.tools.invertedIconPath("image.png")      ,
      layout      = awful.layout.tile                              ,
      nmaster     = 1                                              ,
      incncol     = 10                                             ,
      ncol        = 2                                              ,
      mwfact      = 0.00                                           ,
      class       = {}
    } ,
  }
  tyrannical.properties.intrusive = {
    "Gpick",    "ksnapshot"     , "pinentry"       , "gtksu"     , "kcalc"        , "xcalc"           ,
    "feh"           , "Gradient editor", "About KDE" , "Paste Special", "Background color",
    "kcolorchooser" , "plasmoidviewer" , "plasmaengineexplorer" , "Xephyr" , "kruler"     , "gnome-calculator", "conky", "Conky", "Gnome-pomodoro", "Vlc"
  }
  tyrannical.properties.floating = {
    "Gpick", "MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "gtksu"          ,
    "xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
    "yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
    "New Form"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer" , "gnome-calculator", "conky", "Conky", "Gnome-pomodoro", "Vlc"
  }
  tyrannical.properties.sticky = {
    "conky", "Conky", "Vlc"
  }

  tyrannical.properties.ontop = {
    "Xephyr"       , "ksnapshot"       , "kruler", "Vlc"
  }

  tyrannical.properties.size_hints_honor = { termite = false, xterm = false, URxvt = false, aterm = false, sauer_client = false, mythfrontend  = false}
  tyrannical.properties.focusable = { Vlc = false }
  tyrannical.properties.above = { Vlc = true }


  -- {{{ Wallpaper
  local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
      local wallpaper = beautiful.wallpaper
      -- If wallpaper is a function, call it with the screen
      if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
      end
      gears.wallpaper.maximized(wallpaper, s, true)
    end
  end
-- }}}

-- {{{ Menu
local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}
local mymainmenu = freedesktop.menu.build({
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", terminal },
        -- other triads can be put here
    }
})
-- }}}

-- {{{ Wibox
local markup = lain.util.markup
local gray   = "#94928F"

-- Textclock
local mytextclock = wibox.widget.textclock(" %H:%M ")

-- lain.widgets.calendar.attach(mytextclock, {
--     notification_preset = {
--         font = "Tamsyn 10.5",
--         fg   = white,
--         bg   = beautiful.bg_normal
-- }})

-- Calendar
-- lain.widgets.calendar:attach(mytextclock)

-- Mail IMAP check
mailwidget = lain.widgets.imap({
    timeout  = 180,
    server   = "server",
    mail     = "mail",
    password = "keyring get mail",
    settings = function()
        mail  = ""
        count = ""

        if mailcount > 0 then
            mail = "Mail "
            count = mailcount .. " "
        end

        widget:set_markup(markup(gray, mail) .. count)
    end
})

mpdicon = wibox.widget.imagebox()
mpdwidget = lain.widgets.mpd({
    settings = function()
        mpd_notification_preset = {
            text = string.format("%s [%s] - %s\n%s", mpd_now.artist,
                   mpd_now.album, mpd_now.date, mpd_now.title)
        }

        if mpd_now.state == "play" then
            artist = mpd_now.artist .. " > "
            title  = mpd_now.title .. " "
            mpdicon:set_image(beautiful.widget_note_on)
        elseif mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        else
            artist = ""
            title  = ""
            mpdicon:set_image(nil)
        end
        widget:set_markup(markup("#e54c62", artist) .. markup("#b2b2b2", title))
    end
})

-- CPU
cpuwidget = lain.widgets.sysload({
    settings = function()
        widget:set_markup(markup(gray, " Cpu ") .. load_1 .. " ")
    end
})

-- MEM
memwidget = lain.widgets.mem({
    settings = function()
        widget:set_markup(markup(gray, " Mem ") .. mem_now.used .. " ")
    end
})

-- /home fs
fshomeupd = lain.widgets.fs({
    partition = "/home"
})

-- Battery
batwidget = lain.widgets.bat({
  battery = "BAT1",
  settings = function()
    bat_perc = bat_now.perc
    bat_left = bat_now.time
    if bat_perc == "N/A" then bat_perc = "AC" end
    widget:set_markup(markup(gray, " Bat ") .. bat_perc .. " " .. markup(gray, " Left ") .. bat_left .. " ")
  end
})

musicwidget = awesompd:create() -- Create awesompd widget
musicwidget.font = "Lucida Grande" -- Set widget font 
musicwidget.scrolling = true -- If true, the text in the widget will be scrolled
musicwidget.output_size = 30 -- Set the size of widget in symbols
musicwidget.update_interval = 10 -- Set the update interval in seconds
-- Set the folder where icons are located (change username to your login name)
musicwidget.path_to_icons = "/home/codejunkienick/.config/awesome/awesompd/icons" 
-- Set the default music format for Jamendo streams. You can change
-- this option on the fly in awesompd itself.
-- possible formats: awesompd.FORMAT_MP3, awesompd.FORMAT_OGG
musicwidget.jamendo_format = awesompd.FORMAT_MP3
-- If true, song notifications for Jamendo tracks and local tracks will also contain
-- album cover image.
musicwidget.show_album_cover = true
-- Specify how big in pixels should an album cover be. Maximum value
-- is 100.
musicwidget.album_cover_size = 50
-- This option is necessary if you want the album covers to be shown
-- for your local tracks.
musicwidget.mpd_config = "/home/codejunkienick/.config/mpd/mpd.conf"
-- Specify the browser you use so awesompd can open links from
-- Jamendo in it.
musicwidget.browser = "chromium"
-- Specify decorators on the left and the right side of the
-- widget. Or just leave empty strings if you decorate the widget
-- from outside.
musicwidget.ldecorator = " "
musicwidget.rdecorator = " "
-- Set all the servers to work with (here can be any servers you use)
musicwidget.servers = {
  { server = "localhost",
  port = 6600 }}
  -- Set the buttons of the widget
  musicwidget:register_buttons({ { "", awesompd.MOUSE_LEFT, musicwidget:command_playpause() },
  { "Control", awesompd.MOUSE_SCROLL_UP, musicwidget:command_prev_track() },
  { "Control", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_next_track() },
  { "", awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
  { "", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
  { "", awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() },
  { "Control", "XF86AudioLowerVolume", musicwidget:command_volume_down() },
  { "Control", "XF86AudioRaiseVolume", musicwidget:command_volume_up() },
  { modkey, "Pause", musicwidget:command_playpause() } })
  musicwidget:run() -- After all configuration is done, run the widget

local netwidget = lain.widgets.net({
    settings = function()
        if net_now.state == "up" then net_state = "On"
        else net_state = "Off" end
        widget:set_markup(markup(gray, " Net ") .. net_state .. " ")
    end
})

-- volumewidget = blingbling.volume({width = 40, bar =true, show_text = true, label ="$percent%", pulseaudio = true})
-- volumewidget:update_master()
-- volumewidget:set_master_control()

-- Separators
local first = wibox.widget.textbox(markup.font("Tamsyn 4", " "))
local spr   = wibox.widget.textbox(' ')

-- Create a wibox for each screen and add it
local mywibox = {}
local mypromptbox = {}
local txtlayoutbox = {}
local mytaglist = {}
local mytasklist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end))

mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
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

-- Writes a string representation of the current layout in a textbox widget
local function update_txt_layoutbox(s)
    -- Writes a string representation of the current layout in a textbox widget
    local txt_l = beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(s))] or ""
    s.mytxtlayoutbox:set_text(txt_l)
end

awful.screen.connect_for_each_screen(function(s)
    -- Quake application

    -- Wallpaper
    set_wallpaper(s)

    -- Tags
    -- awful.tag(tagnames, s, awful.layout.layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    --[[ Standard layoutbox
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    --]]

    -- Textual layoutbox
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 18 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            first,
            s.mytaglist,
            spr,
            s.mylayoutbox,
            --spr,
            s.mypromptbox,
            spr,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            spr,
            mpdwidget,
            musicwidget.widget,
            cpuwidget,
            memwidget,
            batwidget,
            netwidget,
            APW,
            mytextclock
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

    -- Tag browsing
    -- awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    -- awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    -- Lock-screen binding
    awful.key({ modkey, "Shift" }, "p", function () run_once('xscreensaver-command --lock') end),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end),

    -- Default client focus
    awful.key({ altkey }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ altkey }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show Menu
    awful.key({ modkey }, "w",
        function ()
            mymainmenu:show({ keygrabber = true })
        end),

    -- Show/Hide Wibox
awful.key({ modkey }, "b", function ()
        for s in screen do
            s.mywibox.visible = not s.mywibox.visible
        end
    end),
    -- On the fly useless gaps change
    awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- Dynamic tagging
    awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end),
    awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end),
    awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(1) end),   -- move to next tag
    awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(-1) end), -- move to previous tag
    awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey, "Shift"   }, "t",      function () awful.tag.incmwfact(0.05)     end),
    awful.key({ modkey, "Shift"   }, "y",      function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ altkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
    awful.key({ altkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
    awful.key({ modkey, "Control" }, "l",      function () awful.tag.incncol(-1)          end),
    awful.key({ modkey, "Control" }, "h",      function () awful.tag.incncol( 1)          end),
    awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1)  end),
    awful.key({ modkey, "Control" }, "n",      awful.client.restore),

   awful.key({ modkey }, "Next",  function () awful.client.moveresize( 20,  20, -40, -40) end),
   awful.key({ modkey }, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end),

   awful.key({ modkey, "Shift" }, "Down",  function () awful.client.moveresize(  0,   0,     0,   20) end),
   awful.key({ modkey, "Shift" }, "Up",    function () awful.client.moveresize(  0,   0,     0,  -20) end),
   awful.key({ modkey, "Shift" }, "Right",  function () awful.client.moveresize(  0,   0,    20,    0) end),
   awful.key({ modkey, "Shift" }, "Right", function () awful.client.moveresize(  0,   0,   -20,    0) end),

   awful.key({ modkey }, "Down",  function () awful.client.moveresize(  0,  20,   0,   0) end),
   awful.key({ modkey }, "Up",    function () awful.client.moveresize(  0, -20,   0,   0) end),
   awful.key({ modkey }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
   awful.key({ modkey }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "o",      awesome.quit),

    -- Dropdown terminal
  awful.key({ modkey,           }, "z",
            function () quakescratch[mouse.screen]:toggle() end,
            {description = "Scratchpad", group = "applications"}),
    --awful.key({ modkey,	          }, "z",      function () drop(dropdownterm, "center", "center", 0.6, 0.55) end),

    -- Widgets popups
    -- awful.key({ altkey,           }, "c",      function () lain.widgets.calendar:show(7) end),
    -- awful.key({ altkey,           }, "h",      function () fshomeupd.show(7) end),
    -- awful.key({ altkey,           }, "w",      function () yawn.show(7) end),

   awful.key({ }, "Print", function() awful.spawn_with_shell("import -window root ~/Screenshots/shot-(date +%F)--(date +%T).png") end),
   awful.key({ }, "XF86AudioRaiseVolume",  APW.Up),
   awful.key({ }, "XF86AudioLowerVolume",  APW.Down),
   awful.key({ }, "XF86MonBrightnessUp", function() awful.util.spawn_with_shell("xbacklight + 10%") end),
   awful.key({ }, "XF86MonBrightnessDown",  function() awful.util.spawn_with_shell("xbacklight - 10%") end),
   awful.key({ }, "XF86AudioPrev", function() awful.util.spawn_with_shell("mpc prev") end),
   awful.key({ }, "XF86AudioNext", function() awful.util.spawn_with_shell("mpc next") end),
   awful.key({ }, "XF86AudioStop", function() awful.util.spawn_with_shell("mpc stop") end),
   awful.key({ }, "XF86AudioPlay", function() awful.util.spawn_with_shell("mpc toggle") end),
   awful.key({ }, "XF86AudioMute",         APW.ToggleMute),

    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
        function ()
            awful.util.spawn_with_shell("mpc toggle || ncmpc toggle || pms toggle")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Down",
        function ()
            awful.util.spawn_with_shell("mpc stop || ncmpc stop || pms stop")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Left",
        function ()
            awful.util.spawn_with_shell("mpc prev || ncmpc prev || pms prev")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Right",
        function ()
            awful.util.spawn_with_shell("mpc next || ncmpc next || pms next")
            mpdwidget.update()
        end),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey }, "q", function () awful.spawn(browser) end),
    awful.key({ modkey }, "i", function () awful.spawn(browser2) end),

 -- Default
    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run {
    --                 prompt       = "Run Lua code: ",
    --                 textbox      = awful.screen.focused().mypromptbox.widget,
    --                 exe_callback = awful.util.eval,
    --                 history_path = awful.util.get_cache_dir() .. "/history_eval"
    --               }
    --           end,
    --           {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
    --]]
    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run({ prompt = "Run Lua code: " },
    --               mypromptbox[mouse.screen].widget,
    --               awful.util.eval, nil,
    --               awful.util.getdir("cache") .. "/history_eval")
    --           end)
)



clientkeys = awful.util.table.join(
    awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client                         ),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
musicwidget:append_global_keys()
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     screen = awful.screen.preferred,
                     raise = true,
                     keys = clientkeys,
                     maximized_vertical   = false,
                     maximized_horizontal = false,
                     buttons = clientbuttons,
	                   size_hints_honor = false } },
    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_enabled = false } },

       { rule = { class = "Conky" },
       properties = {
         floating = true,
         sticky = true,
         ontop = false,
         focusable = false
       } },
       { rule = { class = "Vlc" },
       properties = {
         focusable = false
       } },
--     { rule = { class = "URxvt" },
--           properties = { opacity = 0.99 } },
--
--     { rule = { class = "MPlayer" },
--           properties = { floating = true } },
--
    {
        rule = { class = "Termite" },
        callback = function(c)
         -- Floating clients don't overlap, cover 
         -- the titlebar or get placed offscreen
         awful.placement.no_overlap(c)
         awful.placement.no_offscreen(c)
        end
    },
    {
        rule = { class = "VirtualBox"  },
        properties = { border_width = 0, },
    },
    {
        rule = { class = "Termite", name = "great"  },
        callback = function(c)
        awful.client.property.set(c, "overwrite_class", "termite:great")
        end
    },
    {
        rule = { class = "Termite", name = "web"  },
        callback = function(c)
        awful.client.property.set(c, "overwrite_class", "termite:web")
        end
    },
    {
        rule = { class = "Termite", name = "vim"  },
        callback = function(c)
        awful.client.property.set(c, "overwrite_class", "termite:vim")
        end
    },
    {
        rule = { class = "Termite", name = "vim"  },
        callback = function(c)
        awful.client.property.set(c, "overwrite_class", "termite:vim")
        end
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
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

    awful.titlebar(c, {size = 16}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_width = 0
        -- no borders if only 1 client visible
        elseif #awful.client.visible(mouse.screen) > 1 then
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
-- for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
--         local clients = awful.client.visible(s)
--         local layout  = awful.layout.getname(awful.layout.get(s))
--
--         if #clients > 0 then -- Fine grained borders and floaters control
--             for _, c in pairs(clients) do -- Floaters always have borders
--                 if awful.client.floating.get(c) or layout == "floating" then
--                     c.border_width = beautiful.border_width
--
--                 -- No borders with only one visible client
--                 elseif #clients == 1 or layout == "max" then
--                     c.border_width = 0
--                 else
--                     c.border_width = beautiful.border_width
--                 end
--             end
--         end
--       end)
-- end

-- }}}
