local wibox = require('wibox')
local beautiful = require('beautiful')
local awful = require('awful')
local gears = require('gears')
local clickable_container_color = require('widget.clickable-container-color')
local clickable_container = require('widget.clickable-container')
local dpi = require('beautiful').xresources.apply_dpi
local apps = require('configuration.apps')

local dashboardPanel = function(s)
    local dashboard = wibox {
        visible = false,
        ontop = true,
        bg = beautiful.system_white_dark .. '33',
        type = 'dock',
        screen = s
    }

    awful.placement.maximize(dashboard)

    local function dashboard_visibility()
        if dashboard.visible == true then
            dashboard.visible = false
        else
            dashboard.visible = true
        end
    end

    dashboard.toggle = dashboard_visibility

    local function rounded_shape(cr, width, height)
        return gears.shape.rounded_rect(cr, width, height, 15)
    end

    local function folder(image, dir)
        local clickable_folder = wibox.widget {
            {
                {
                    {
                        nil,
                        {
                            image = image,
                            resize = true,
                            forced_height = dpi(90),
                            widget = wibox.widget.imagebox
                        },
                        nil,
                        expand = "none",
                        layout = wibox.layout.align.horizontal
                    },
                    opacity = 0.7,
                    widget = wibox.container.background
                },
                margins = 10,
                widget = wibox.container.margin
            },
            widget = clickable_container
        }

        clickable_folder:buttons(gears.table.join(awful.button({}, 1, nil, function()
            awful.spawn(apps.default.file_manager .. ' ' .. dir)
            dashboard_visibility()
        end)))

        return clickable_folder
    end

    local function application(icon, action)
        local clickable_application = wibox.widget {
            {
                {
                    {
                        nil,
                        {
                            image = icon,
                            resize = true,
                            forced_height = dpi(50),
                            widget = wibox.widget.imagebox
                        },
                        nil,
                        expand = "none",
                        layout = wibox.layout.align.horizontal
                    },
                    opacity = 0.7,
                    widget = wibox.container.background
                },
                margins = 25,
                widget = wibox.container.margin
            },
            widget = clickable_container
        }
        clickable_application:buttons(gears.table.join(awful.button({}, 1, nil, function()
            action()
            dashboard_visibility()
        end)))
        return clickable_application
    end

    -- right click to hide dashboard
    dashboard:buttons(gears.table.join(awful.button({}, 3, function()
        dashboard_visibility()
    end)))

    local distribution = wibox.widget {
        homogeneous = true,
        forced_num_cols = 6,
        forced_num_rows = 5,
        min_cols_size = dpi(130),
        min_rows_size = dpi(130),
        superpose = true,
        expand = true,
        spacing = dpi(25),
        forced_width = dpi(910),
        forced_height = dpi(650),
        layout = wibox.layout.grid
    }

    distribution:add_widget_at({
        {
            {
                folder(beautiful.computer_folder, 'computer:///'),
                widget = wibox.container.background
            },
            {
                folder(beautiful.desktop_folder, '/home/cristal/Desktop/'),
                widget = wibox.container.background
            },
            {
                folder(beautiful.home_folder, '/home/cristal/'),
                widget = wibox.container.background
            },
            {
                folder(beautiful.download_folder, '/home/cristal/Downloads/'),
                widget = wibox.container.background
            },
            {
                folder(beautiful.pictures_folder, '/home/cristal/Pictures/'),
                widget = wibox.container.background
            },
            {
                folder(beautiful.network_folder, 'network:///'),
                widget = wibox.container.background
            },
            layout = wibox.layout.ratio.vertical
        },
        bg = beautiful.system_black_dark,
        shape_border_width = beautiful.border_width,
        shape_border_color = beautiful.system_yellow_dark,
        shape = rounded_shape,
        widget = wibox.container.background
    }, 1, 1, 4, 1)

    local profile_widget = {
        {
            {
                nil,
                {
                    nil,
                    {
                        {
                            {
                                image = beautiful.user_picture,
                                resize = true,
                                widget = wibox.widget.imagebox
                            },
                            shape = gears.shape.circle,
                            forced_width = dpi(160),
                            forced_height = dpi(160),
                            shape_border_width = beautiful.border_width,
                            shape_border_color = beautiful.background,
                            opacity = 1.0,
                            widget = wibox.container.background
                        },
                        {
                            wibox.widget {
                                markup = '<span font_desc="italic">Cristal</span>',
                                font = 'JetBrains Mono Medium Italic Nerd Font Complete 16',
                                align = 'center',
                                valign = 'center',
                                widget = wibox.widget.textbox
                            },
                            forced_width = dpi(160),
                            forced_height = dpi(50),
                            opacity = 0.6,
                            widget = wibox.container.background
                        },
                        expand = "none",
                        spacing = dpi(5),
                        layout = wibox.layout.fixed.vertical
                    },
                    nil,
                    expand = "none",
                    layout = wibox.layout.align.horizontal
                },
                nil,
                expand = "none",
                layout = wibox.layout.align.vertical
            },
            bg = beautiful.system_black_dark,
            shape = rounded_shape,
            widget = wibox.container.background
        },
        margins = beautiful.border_width,
        widget = wibox.container.margin
    }

    local time_widget = wibox.widget {
        awful.widget.watch('bash -c "date \'+%H:%M\'"', 10, function(widget, stdout)
            for line in stdout:gmatch("[^\r\n]+") do
                widget.font = ('JetBrains Mono Bold Nerd Font Complete 32')
                widget.align = 'center'
                widget.valign = 'center'
                widget.markup = ('<span font_desc="" color=\'' .. beautiful.system_green_dark .. '\'>' .. line ..
                                    '</span>')
                return
            end
        end),
        expand = 'outside',
        layout = wibox.layout.align.horizontal
    }

    local hour_widget = {
        time_widget,
        bg = beautiful.background,
        widget = wibox.container.background
    }

    local second_box = wibox.widget {
        profile_widget,
        hour_widget,
        layout = wibox.layout.ratio.vertical
    }

    second_box:ajust_ratio(2, 0.75, 0.25, 0.0)

    distribution:add_widget_at({
        second_box,
        bg = beautiful.background,
        shape = rounded_shape,
        widget = wibox.container.background
    }, 1, 2, 3, 2)

    distribution:add_widget_at(wibox.widget {
        {
            {
                application(beautiful.nekoray_icon, function()
                    awful.spawn(apps.default.nekoray)
                end),
                application(beautiful.telegram_icon, function()
                    awful.spawn(apps.default.telegram_desktop)
                end),
                application(beautiful.chrome_icon, function()
                    awful.spawn(apps.default.web_browser)
                end),
                application(beautiful.steam_icon, function()
                    awful.spawn(apps.default.steam)
                end),
                application(beautiful.code_icon, function()
                    awful.spawn(apps.default.text_editor)
                end),
                application(beautiful.discord_icon, function()
                    awful.spawn(apps.default.discord)
                end),
                application(beautiful.spotify_icon, function()
                    awful.spawn(apps.default.music_player)
                end),
                layout = wibox.layout.ratio.horizontal
            },
            bg = beautiful.system_black_dark,
            shape_border_width = beautiful.border_width,
            shape_border_color = beautiful.system_blue_dark,
            shape = rounded_shape,
            widget = wibox.container.background
        },
        right = -400,
        widget = wibox.container.margin
    }, 4, 2, 1, 4)

    distribution:add_widget_at(wibox.widget {
        {
            {
                application(beautiful.lampa_icon, function()
                    awful.spawn(apps.default.lampa)
                end),
                application(beautiful.qbittorrent_icon, function()
                    awful.spawn(apps.default.qbittorrent)
                end),
                application(beautiful.multimc_icon, function()
                    awful.spawn(apps.default.multimc)
                end),
                application(beautiful.obsidian_icon, function()
                    awful.spawn(apps.default.obsidian)
                end),
                layout = wibox.layout.ratio.horizontal
            },
            bg = beautiful.system_black_dark,
            shape_border_width = beautiful.border_width,
            shape_border_color = beautiful.system_yellow_dark,
            shape = rounded_shape,
            widget = wibox.container.background
        },
        right = -100,
        widget = wibox.container.margin
    }, 3, 4, 1, 4)

    distribution:add_widget_at(wibox.widget {
        {
            {
                application(beautiful.volume_manager_icon, function()
                    awful.spawn(apps.default.volume_manager)
                end),
                layout = wibox.layout.flex.horizontal
            },
            bg = beautiful.system_black_dark,
            shape_border_width = beautiful.border_width,
            shape_border_color = beautiful.system_yellow_dark,
            shape = rounded_shape,
            widget = wibox.container.background
        },
        right = -10,
        widget = wibox.container.margin
    }, 2, 6, 1, 1)

    distribution:add_widget_at(wibox.widget {
        {
            {
                application(beautiful.bluetooth_manager_icon, function()
                    awful.spawn(apps.default.bluetooth_manager)
                end),
                layout = wibox.layout.flex.horizontal
            },
            bg = beautiful.system_black_dark,
            shape_border_width = beautiful.border_width,
            shape_border_color = beautiful.system_yellow_dark,
            shape = rounded_shape,
            widget = wibox.container.background
        },
        right = -10,
        widget = wibox.container.margin
    }, 1, 6, 1, 1)


    distribution:add_widget_at({
        {
            {
                nil,
                wibox.widget {
                    date = os.date('*t'),
                    font = 'Monospace 14',
                    spacing = 12,
                    week_numbers = false,
                    start_sunday = false,
                    widget = wibox.widget.calendar.month
                },
                nil,
                layout = wibox.layout.align.horizontal
            },
            margins = 20,
            widget = wibox.container.margin
        },
        bg = beautiful.system_black_dark,
        shape_border_width = beautiful.border_width,
        shape_border_color = beautiful.system_yellow_dark,
        shape = rounded_shape,
        widget = wibox.container.background
    }, 1, 4, 2, 2)

    dashboard:setup{
        nil,
        {
            nil,
            {
                distribution,
                widget = wibox.container.background
            },
            nil,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.vertical
    }
    return dashboard
end

return dashboardPanel
