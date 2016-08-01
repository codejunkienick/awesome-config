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
local drop      = require("scratchdrop")
local lain      = require("lain")
local vain      = require("vain")
local battary   = require("battery")
local tyrannical = require("tyrannical")
local blingbling = require("blingbling")
local APW        = require("apw/widget")
local awesompd = require("awesompd/awesompd")
APW.Update()

-- }}}

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
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
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


beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/steamburn/theme.lua")

-- common
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "termite" or "terminator" or "xterm"
dropdownterm = "termite"
editor     = os.getenv("EDITOR") or "vim" or "vi"
editor_cmd = terminal .. " -e " .. editor

-- user defined
browser2    = "firefox"
browser   = "chromium"
music_player = "clementine"

-- lain
lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol    = 1

-- vain
vain.layout.browse.extra_padding = 5
vain.layout.browse.ncol = 2
vain.widgets.terminal = terminal

local layouts = {
    lain.layout.cascade,
    lain.layout.uselessfair.horizontal,
    lain.layout.uselesstile,
    lain.layout.uselessfair,

    lain.layout.termfair,
    lain.layout.uselesspiral.dwindle,
    lain.layout.centerwork,
    vain.layout.browse,

    awful.layout.suit.magnifier,
    lain.layout.centerfair,
}
-- }}}
do
    local conky = nil

    function get_conky(default)
        if conky and conky.valid then
            return conky
        end

        conky = awful.client.iterate(function(c) return c.class == "Conky" end)()
        return conky or default
    end

    function raise_conky()
        get_conky({}).ontop = true
    end

    function lower_conky()
        get_conky({}).ontop = false
    end

    local t = awesome_timer({ timeout = 0.01 })
    t:connect_signal("timeout", function()
        t:stop()
        lower_conky()
    end)
    function lower_conky_delayed()
        t:again()
    end

    function toggle_conky()
        local conky = get_conky({})
        conky.ontop = not conky.ontop
    end
end
tyrannical.tags = {
            {
              name        = "term"      ,
              init        = true        ,
              exclusive   = true        ,
              layout      = layouts[3] ,
              class       = {"termite", "XTerm"}
            },
            {
              name        = "web"             ,
              init        = true              ,
              exclusive   = false             ,
              mwfact      = 0.70              ,
              layout      = layouts[7]       ,
              class       = {"Firefox", "brave" ,"chromium", "Google-chrome", "Tor Browser", "termite:web", "Midori"}
            },
            {
              name        = "edit"       ,
              init        = true        ,
              exclusive   = true       ,
              layout      = layouts[3],
              class       = {"Sublime_text","Vscode","Gvim", "termite:vim", "Emacs"}
            },
            {
              name        = "dev"       ,
              init        = true        ,
              exclusive   = false       ,
              mwfact      = 0.75,
              ncol        = 2,
              layout      = layouts[7],
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
              init        = true        ,
              exclusive   = true        ,
              layout      = layouts[7] ,
              mwfact      = 0.65,
              class       = {
                      "MuPDF"     , "Qpdfview"         , "Evince"    , "EPDFviewer"   , "xpdf",
                      "Xpdf"          , "libreoffice-writer", "libreoffice-calc", "LibreOffice 5.0", "libreoffice", "libreoffice-startcenter", "libreoffice-impress" }
            },
            {
              name        = "ssh"     ,
              init        = true        ,
              exclusive   = true        ,
              layout      = layouts[7] ,
              mwfact      = 0.65,
              class       =  {}
            },
            {
              name        = "great"     ,
              init        = true        ,
              exclusive   = false        ,
              layout      = layouts[7] ,
              mwfact      = 0.60,
              class       =  {"termite:great"}
            },
            {
              name        = "dj"     ,
              init        = false        ,
              exclusive   = true        ,
              layout      = layouts[10] ,
              class       = {"xfreerdp"}
            },
            {
              name        = "files"     ,
              init        = false        ,
              exclusive   = true        ,
              layout      = layouts[10] ,
              class       = {"Thunar", "Nautilus", "termite:mc"}
            },
            -----------------VOLATILE TAGS-----------------------
            {
              name = "db",
              init = false,
              excluse = true,
              layout = layouts[10],
              class = {"Pgadmin3", "Mysql-workbench-bin",}
            },
            {
              name = "games",
              init = false,
              excluse = true,
              layout = layouts[10],
              no_focus_stealing_in = true ,
              class = {"Steam"}
            },
            {
              name        = "wine",
              init        = false                 ,
              position    = 10                    ,
              exclusive   = true                  ,
              layout      = layouts[10] ,
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
              layout               = layouts[1]    ,
              no_focus_stealing_in = true ,
              class       = {"Mpv", "Amarok"        , "SongBird"       , "last.fm"   ,}
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
                layout      = layouts[7]                         ,
                class       = {"Cutegram", "telegram", "Pidgin"        , "Kopete"         , "Skype"}
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
                layout      = awful.layout.suit.max                        ,
                class       = {"Systemsettings", "Pavucontrol", "Android SDK Manager", "gconf-editor"}
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
    "kcolorchooser" , "plasmoidviewer" , "plasmaengineexplorer" , "Xephyr" , "kruler"     , "gnome-calculator", "conky", "Conky"
}
tyrannical.properties.floating = {
    "Gpick", "MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "gtksu"          ,
    "xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
    "yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
    "New Form"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer" , "gnome-calculator", "conky", "Conky"
}
tyrannical.properties.sticky = {
  "conky", "Conky"
}

tyrannical.properties.ontop = {
    "Xephyr"       , "ksnapshot"       , "kruler"
}

tyrannical.properties.size_hints_honor = { xterm = false, URxvt = false, aterm = false, sauer_client = false, mythfrontend  = false}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Menu
mymainmenu = awful.menu.new({ items = require("menugen").build_menu(),
                              theme = { height = 16, width = 130 }})
-- }}}

-- {{{ Wibox
markup = lain.util.markup
gray   = "#94928F"

-- Textclock
mytextclock = awful.widget.textclock(" %H:%M ")

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
musicwidget.font = "Consolas" -- Set widget font 
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
  { "", "XF86AudioLowerVolume", musicwidget:command_volume_down() },
  { "", "XF86AudioRaiseVolume", musicwidget:command_volume_up() },
  { modkey, "Pause", musicwidget:command_playpause() } })
  musicwidget:run() -- After all configuration is done, run the widget

netwidget = blingbling.net({interface = "wlp4s0", show_text = true})
netwidget:set_ippopup()

-- shutdown=blingbling.system.shutdownmenu(beautiful.shutdown,
--                                         beautiful.accept,
--                                         beautiful.cancel)
--
-- reboot=blingbling.system.rebootmenu(beautiful.reboot,
--                                     beautiful.accept,
--                                     beautiful.cancel)
-- lock=blingbling.system.lockmenu() --icons have been set in theme via the theme.bligbling table
-- logout=blingbling.system.logoutmenu() --icons have been set in theme via the theme.blingbling table

volumewidget = blingbling.volume({width = 40, bar =true, show_text = true, label ="$percent%", pulseaudio = true})
volumewidget:update_master()
volumewidget:set_master_control()

-- Weather

-- Separators
first = wibox.widget.textbox(markup.font("Tamsyn 4", " "))
spr = wibox.widget.textbox(' ')

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
txtlayoutbox = {}
mytaglist = {}
mytasklist = {}
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
function updatelayoutbox(layout, s)
    local screen = s or 1
    local txt_l = beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(screen))] or ""
    layout:set_text(txt_l)
end

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- Create a textbox widget which will contains a short string representing the
    -- layout we're using.  We need one layoutbox per screen.
    txtlayoutbox[s] = wibox.widget.textbox(beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(s))])
    awful.tag.attached_connect_signal(s, "property::selected", function ()
        updatelayoutbox(txtlayoutbox[s], s)
    end)
    awful.tag.attached_connect_signal(s, "property::layout", function ()
        updatelayoutbox(txtlayoutbox[s], s)
    end)
    txtlayoutbox[s]:buttons(awful.util.table.join(
            awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
            awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
            awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
            awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(first)
    left_layout:add(mytaglist[s])
    left_layout:add(spr)
    left_layout:add(txtlayoutbox[s])
    left_layout:add(spr)
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(spr)
    right_layout:add(mpdwidget)
    --right_layout:add(mailwidget)
    right_layout:add(musicwidget.widget)
    right_layout:add(cpuwidget)
    right_layout:add(memwidget)
    right_layout:add(batwidget)
    right_layout:add(APW)
    right_layout:add(netwidget)
    right_layout:add(mytextclock)
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
    awful.key({ modkey, "Shift" }, "p", function () run_once('xscreensaver-command -lock') end),

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
            ful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show Menu
    awful.key({ modkey }, "w",
        function ()
            mymainmenu:show({ keygrabber = true })
        end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),

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
    awful.key({ altkey, "Shift_L"   }, "l",      function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ altkey, "Shift_L"   }, "h",      function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
    awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
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
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "o",      awesome.quit),

    -- Dropdown terminal
    awful.key({ modkey,	          }, "z",      function () drop(dropdownterm, "center", "center", 0.6, 0.55) end),

    -- Widgets popups
    -- awful.key({ altkey,           }, "c",      function () lain.widgets.calendar:show(7) end),
    -- awful.key({ altkey,           }, "h",      function () fshomeupd.show(7) end),
    -- awful.key({ altkey,           }, "w",      function () yawn.show(7) end),

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
    awful.key({ modkey }, "q", function () awful.util.spawn(browser) end),
    awful.key({ modkey }, "i", function () awful.util.spawn(browser2) end),
    awful.key({ modkey }, "g", function () awful.util.spawn(music_player) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run({ prompt = "Run: ", hooks = {
                {{         },"Return",function(command)
                    local result = awful.util.spawn(command)
                    mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                    return true
                end},
                {{"Mod1"   },"Return",function(command)
                    local result = awful.util.spawn(command,{intrusive=true})
                    mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                    return true
                end},
                {{"Shift"  },"Return",function(command)
                    local result = awful.util.spawn(command,{intrusive=true,ontop=true,floating=true})
                    mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                    return true
                end}
            }},
            mypromptbox[mouse.screen].widget,nil,
            awful.completion.shell,
            awful.util.getdir("cache") .. "/history") end)
    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run({ prompt = "Run Lua code: " },
    --               mypromptbox[mouse.screen].widget,
    --               awful.util.eval, nil,
    --               awful.util.getdir("cache") .. "/history_eval")
    --           end)
)



clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
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
-- be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
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
                     keys = clientkeys,
                     maximized_vertical   = false,
                     maximized_horizontal = false,
                     buttons = clientbuttons,
	                   size_hints_honor = false } },
       { rule = { class = "Conky" },
       properties = {
         floating = true,
         sticky = true,
         ontop = false,
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
--
--     { rule = { class = "Iron" },
--           properties = { tag = tags[1][1] } },
--
--     { rule = { class = "plugin-container" },
--           properties = { tag = tags[1][1] } },
--
-- 	  { rule = { class = "Gimp" },
--      	    properties = { tag = tags[1][5] } },
--
-- 	  { rule = { class = "Vlc" },
--      	    properties = { tag = tags[1][5]
--                         } },
--
-- 	  { rule = { class = "Acestreamplayer" },
--      	    properties = { tag = tags[1][5]
--                         } },
--
-- 	  { rule = { class = "Plaidchat"  },
--      	    properties = { tag = tags[1][7] } },
--
--     { rule = { class = "Gimp", role = "gimp-image-window" },
--           properties = { maximized_horizontal = true,
--                          maximized_vertical = true } },
}
-- }}}

-- {{{ Signals
-- signal function to execute when a new client appears.
local sloppyfocus_last = {c=nil}
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    client.connect_signal("mouse::enter", function(c)
         if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
             -- Skip focusing the client if the mouse wasn't moved.
             if c ~= sloppyfocus_last.c then
                 client.focus = c
                 sloppyfocus_last.c = c
             end
         end
     end)

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

        -- widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- the title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c,{size=16}):set_widget(layout)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true and not awful.rules.match(c, {class = "VirtualBox"}) then
            c.border_color = beautiful.border_normal
        else
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do -- Floaters always have borders
                if awful.client.floating.get(c) or layout == "floating" then
                    c.border_width = beautiful.border_width

                -- No borders with only one visible client
                elseif #clients == 1 or layout == "max" then
                    c.border_width = 0
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
      end)
end

-- }}}
