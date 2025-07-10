const notifications = await Service.import("notifications")
const audio = await Service.import("audio")
const battery = await Service.import("battery")

const network = await Service.import('network')


const showSSID = Variable(false, {})

const toggleSSID = () => {
    showSSID.value = true
    setTimeout(() => showSSID.value = false, 1000)
}

const WifiIndicator = () => Widget.Box({
    class_name: 'wifi',
    hpack: 'end',
    children: [
        Widget.Button({
            class_name: 'wifi-btn',
            onHover: () => toggleSSID(),
            child: Widget.Icon({
                size: 22,
                icon: network
                .wifi
                .bind('internet')
                .as(
                    internet => { switch (internet) {
                        case 'connected':
                            return 'wifi-symbolic';
                        case 'connecting':
                            return 'loader-symbolic';
                        case 'disconnected':
                            return 'wifi-off-symbolic';
                        }
                    }
                ),
            }),
        })
    ],
})

const hours = Variable("", {
    poll: [1000, 'date "+%H"'],
})

const minutes = Variable("", {
    poll: [1000, 'date "+%M"'],
})

const month = Variable("", {
    poll: [1000, 'date "+%b"'],
})

const day = Variable("", {
    poll: [1000, 'date "+%d"'],
})

function Hours() {
    return Widget.Label({
        class_names: ["clock", "hours"],
        label: hours.bind(),
    })
}

function Minutes() {
    return Widget.Label({
        class_names: ["clock", "minutes"],
        label: minutes.bind(),
    })
}

function Month() {
    return Widget.Label({
        class_names: ["date", "month"],
        label: month.bind(),
    })
}

function Day() {
    return Widget.Label({
        class_names: ["date", "day"],
        label: day.bind(),
    })
}

// we don't need dunst or any other notification daemon
// because the Notifications module is a notification daemon itself
function Notification() {
    const popups = notifications.bind("popups")
    return Widget.Box({
        class_name: "notification",
        visible: popups.as(p => p.length > 0),
        children: [
            Widget.Icon({
                icon: popups.as(p => p[0]?.image || "battery-symbolic"),
                size: 90,
            }),
            Widget.Label({
                label: popups.as(p => p[0]?.summary || ""),
            }),
        ],
    })
}

function Volume() {
    const icons = {
        101: "overamplified",
        67: "volume-2",
        34: "volume-1",
        1: "volume",
        0: "volume-x",
    }

    function getIcon() {
        const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
            threshold => threshold <= audio.speaker.volume * 100)

        return `${icons[icon]}-symbolic`
    }

    const icon = Widget.Icon({
        icon: Utils.watch(getIcon(), audio.speaker, getIcon),
        class_name: "icon",
        size: 20,
    })

    const slider = Widget.Slider({
        inverted: true,
        hexpand: true,
        vexpand: true,
        draw_value: false,
        on_change: ({ value }) => audio.speaker.volume = value,
        setup: self => self.hook(audio.speaker, () => {
            self.value = audio.speaker.volume || 0
        }),
    })

    slider.vertical = true;

    return Widget.Box({
        vertical: true,
        class_name: "volume",
        children: [slider, icon],
    })
}


function Battery() {
    const value = battery.bind("percent").as(p => p > 0 ? p / 100 : 0)
    const icon = Widget.Icon({
        icon: `battery-symbolic`,
        size: 20,
        class_name: "icon",
    })

    return Widget.Box({
        vertical: true,
        class_name: "battery",
        visible: battery.bind("available"),
        children: [
            Widget.LevelBar({
                vertical: true,
                inverted: true,
                widthRequest: 20,
                vexpand: true,
                value,
            }),
            icon,
        ],
    })
}

function Start() {
    return Widget.Box({
        spacing: 8,
        height_request: 550,
        children: [
            Notification(),
        ],
    })
}

function Clock() {
    return Widget.Box({
        class_name: "content-clock",
        hpack: "center",
        vertical: true,
        children: [ Hours(), Minutes(), ],
    })
}

function Date() {
    return Widget.Box({
        hpack: "center",
        spacing: 8,
        children: [ Day(), Month() ],
    })
}

const bluetooth = await Service.import('bluetooth')

function End() {
    return Widget.Box({
        hpack: "end",
        vertical: true,
        spacing: 16,
        children: [
            Widget.Box({
                hpack: "center",
                spacing: 16,
                children: [
                    WifiIndicator(),
                    Widget.Icon({
                        size: 22,
                        icon: bluetooth.bind('enabled').as(on => on ? 'bluetooth-symbolic' : 'loader-symbolic'),
                    }),
                ],
            }),
            Widget.Label({
                label: network.wifi.bind('ssid')
                    .as(ssid => ssid || 'Unknown'),
                visible: showSSID.bind(),
            }),
            Widget.Box({
                hpack: "center",
                spacing: 8,
                children: [ Volume(), Battery(), ],
            }),
            Clock(),
            Date(),
        ],
    })
}

function Content() {
        return Widget.CenterBox({
            class_name: "content",
            vertical: true,
            start_widget: Start(),
            end_widget: End(),
        })
}

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar-${monitor}`, // name has to be unique
        class_name: "bar",
        monitor,
        anchor: ["top", "bottom", "right"],
        exclusivity: "exclusive",
        child: Widget.Box({
            class_name: "content",
            children: [
                Content()
            ],
        })
    })
}

Utils.monitorFile(
    // directory that contains the scss files
    `${App.configDir}/style`,

    // reload function
    function() {
        const css = `${App.configDir}/style/style.css`

        App.resetCss()
        App.applyCss(css)
    },
)

App.config({
    style: "./style/style.css",
    windows: [
        Bar(),
    ],
})

App.addIcons(`${App.configDir}/assets/svg`)

export {}
