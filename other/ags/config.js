const notifications = await Service.import("notifications")
const audio = await Service.import("audio")
const battery = await Service.import("battery")
const systemtray = await Service.import("systemtray")

const time = Variable("", {
    poll: [1000, 'date "+%H:%M:%S"'],
})

const date = Variable("", {
    poll: [1000, 'date "+%b %e."'],
})

function Clock() {
    return Widget.Label({
        class_name: "clock",
        label: time.bind(),
    })
}

function Date() {
    return Widget.Label({
        class_name: "clock",
        label: date.bind(),
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
                icon: "preferences-system-notifications-symbolic",
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
        67: "high",
        34: "medium",
        1: "low",
        0: "muted",
    }

    function getIcon() {
        const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
            threshold => threshold <= audio.speaker.volume * 100)

        return `audio-volume-${icons[icon]}-symbolic`
    }

    const icon = Widget.Icon({
        icon: Utils.watch(getIcon(), audio.speaker, getIcon),
    })

    const slider = Widget.Slider({
        hexpand: false,
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
        css: "min-width: 180px",
        children: [slider, icon],
    })
}


function Battery() {
    const value = battery.bind("percent").as(p => p > 0 ? p / 100 : 0)
    const icon = battery.bind("percent").as(p =>
        `battery-level-${Math.floor(p / 10) * 10}-symbolic`)

    return Widget.Box({
        vertical: true,
        class_name: "battery",
        visible: battery.bind("available"),
        children: [
            Widget.LevelBar({
                vertical: true,
                widthRequest: 20,
                vexpand: true,
                value,
            }),
            Widget.Icon({ icon }),
        ],
    })
}


function SysTray() {
    const items = systemtray.bind("items")
        .as(items => items.map(item => Widget.Button({
            child: Widget.Icon({ icon: item.bind("icon") }),
            on_primary_click: (_, event) => item.activate(event),
            on_secondary_click: (_, event) => item.openMenu(event),
            tooltip_markup: item.bind("tooltip_markup"),
        })))

    return Widget.Box({
        children: items,
    })
}

function Start() {
    return Widget.Box({
        spacing: 8,
        children: [
            Notification(),
        ],
    })
}

function End() {
    return Widget.Box({
        hpack: "end",
        vertical: true,
        spacing: 8,
        children: [
            Widget.Box({
                hpack: "center",
                spacing: 8,
                children: [
                    Volume(),
                    Battery(),
                ],
            }),
            SysTray(),
            Clock(),
            Date(),
        ],
    })
}

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar-${monitor}`, // name has to be unique
        class_name: "bar",
        monitor,
        anchor: ["top", "bottom", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            vertical: true,
            start_widget: Start(),
            end_widget: End(),
        }),
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

        // you can call it, for each monitor
        // Bar(0),
        // Bar(1)
    ],
})

export { }