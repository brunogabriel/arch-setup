pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as Plasma5Support
import "../code/ProviderRegistry.js" as ProviderRegistry

PlasmoidItem {
    id: root

    property var adapters: ProviderRegistry.all(Plasmoid.configuration.codexEnabled,
                                                Plasmoid.configuration.openrouterEnabled)
    property var provider: ProviderRegistry.find(Plasmoid.configuration.selectedProvider, adapters)
    property var providerData: ({})
    property string errorMessage: ""
    property string pendingCommand: ""
    property double now: Date.now()

    switchWidth: Kirigami.Units.gridUnit * 16
    switchHeight: Kirigami.Units.gridUnit * 12
    Plasmoid.icon: root.provider && root.provider.icon === "codex"
                   ? "arch-setup-codex-symbolic"
                   : root.provider && root.provider.icon === "openrouter"
                     ? "arch-setup-openrouter-symbolic" : "arch-setup-ai-providers-usage-symbolic"
    activationTogglesExpanded: true
    Plasmoid.title: "AI Usage"
    toolTipMainText: root.tooltipSummary()
    toolTipSubText: ""

    compactRepresentation: Item {
        implicitWidth: Kirigami.Units.iconSizes.small
        implicitHeight: Kirigami.Units.iconSizes.small

        Kirigami.Icon {
            anchors.centerIn: parent
            width: Math.min(parent.width, Kirigami.Units.iconSizes.small)
            height: Math.min(parent.height, Kirigami.Units.iconSizes.small)
            source: root.Plasmoid.icon
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: PlasmaExtras.Representation {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        Layout.minimumHeight: Kirigami.Units.gridUnit * 12
        Layout.preferredHeight: Kirigami.Units.gridUnit * 16

        contentItem: ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        RowLayout {
            Layout.fillWidth: true
            Controls.Label {
                text: "AI Usage"
                font.bold: true
                font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                Layout.fillWidth: true
            }
            Controls.ToolButton {
                icon.name: "view-refresh"
                text: "Refresh"
                display: Controls.AbstractButton.IconOnly
                onClicked: root.refresh()
            }
            Controls.ToolButton {
                icon.name: "configure"
                text: "Settings"
                display: Controls.AbstractButton.IconOnly
                onClicked: Plasmoid.internalAction("configure").trigger()
            }
        }

        RowLayout {
            visible: root.provider !== null
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Controls.Label {
                text: "Provider:"
            }

            Controls.ComboBox {
                id: providerSelector
                visible: root.adapters.length > 1
                Layout.fillWidth: true
                model: root.adapters
                textRole: "name"
                currentIndex: root.provider ? root.adapters.indexOf(root.provider) : -1
                onActivated: function(index) {
                    if (index >= 0 && index < root.adapters.length)
                        root.selectProvider(root.adapters[index])
                }
            }

            Controls.Label {
                visible: root.adapters.length === 1
                text: root.provider ? root.provider.name : ""
                Layout.fillWidth: true
            }
        }

        Controls.Label {
            visible: root.errorMessage !== ""
            text: root.errorMessage
            wrapMode: Text.Wrap
            color: Kirigami.Theme.negativeTextColor
            Layout.fillWidth: true
        }

        Controls.Label {
            visible: !!root.providerData.message
            text: root.providerData.message || ""
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        ListView {
            id: limitsView
            model: root.providerData.limits || []
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Kirigami.Units.largeSpacing
            boundsBehavior: Flickable.StopAtBounds
            delegate: ColumnLayout {
                id: limitRow
                required property var modelData
                width: limitsView.width
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: limitRow.modelData.label
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    Controls.Label {
                        text: Math.round(limitRow.modelData.remaining) + "% left"
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 5
                    radius: height / 2
                    color: Kirigami.Theme.disabledTextColor

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(100, limitRow.modelData.remaining)) / 100
                        height: parent.height
                        radius: parent.radius
                        color: Kirigami.Theme.highlightColor
                    }
                }
                Controls.Label {
                    text: limitRow.modelData.description
                    opacity: 0.75
                    Layout.fillWidth: true
                }
            }
        }

        Controls.Label {
            visible: !root.errorMessage && !root.providerData.message && (!root.providerData.limits || root.providerData.limits.length === 0)
            text: root.provider ? "Waiting for usage data…" : "No providers enabled. Open widget settings to enable one."
            wrapMode: Text.Wrap
            opacity: 0.75
            Layout.fillWidth: true
        }

        }
    }

    Plasma5Support.DataSource {
        id: reader
        engine: "executable"
        connectedSources: []

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
            if (sourceName !== root.pendingCommand)
                return
            root.pendingCommand = ""
            root.consume(data)
        }

        function exec(command) {
            if (connectedSources.indexOf(command) === -1)
                connectSource(command)
        }
    }

    function shellQuote(value) {
        return "'" + value.replace(/'/g, "'\\''") + "'"
    }

    function tooltipSummary() {
        var limits = providerData.limits || []
        if (limits.length === 0)
            return !provider ? "Nada configurado ainda" : "—"
        return Math.round(limits[0].remaining) + "% left"
    }

    function refresh() {
        if (pendingCommand !== "")
            return
        if (!provider) {
            errorMessage = ""
            return
        }
        if (!provider || !provider.reader || !provider.command) {
            errorMessage = provider.name + " usage and API key storage are not implemented yet."
            return
        }

        var helperUrl = Qt.resolvedUrl("../code/" + provider.reader).toString()
        var helperPath = decodeURIComponent(helperUrl.replace(/^file:\/\//, ""))
        pendingCommand = provider.command(helperPath, shellQuote)
        errorMessage = ""
        reader.exec(pendingCommand)
    }

    function selectProvider(adapter) {
        if (!adapter || (provider && adapter.id === provider.id))
            return
        if (pendingCommand !== "") {
            reader.disconnectSource(pendingCommand)
            pendingCommand = ""
        }
        Plasmoid.configuration.selectedProvider = adapter.id
    }

    onProviderChanged: {
        if (pendingCommand !== "") {
            reader.disconnectSource(pendingCommand)
            pendingCommand = ""
        }
        providerData = ({})
        errorMessage = ""
        if (provider)
            refresh()
    }

    function consume(data) {
        var stdout = data["stdout"] || ""
        var result
        try {
            result = JSON.parse(stdout)
        } catch (error) {
            errorMessage = "Could not read Codex usage data. Check that the Codex CLI is installed and logged in."
            providerData = ({})
            return
        }

        var adapter = provider
        var normalized = adapter ? adapter.normalize(result, now) : null
        if (!normalized) {
            errorMessage = result.error || "No Codex usage limits were returned."
            providerData = ({})
            return
        }

        errorMessage = ""
        providerData = normalized
    }

    Timer {
        interval: Math.max(60, Plasmoid.configuration.refreshInterval) * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.now = Date.now()
            root.refresh()
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = Date.now()
    }
}
