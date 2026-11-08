import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: page
    property alias cfg_codexEnabled: codexEnabled.checked
    property alias cfg_openrouterEnabled: openrouterEnabled.checked
    property string pendingCommand: ""
    property string walletMessage: ""
    property bool walletError: false

    ColumnLayout {
    anchors.fill: parent
    anchors.margins: 16
    spacing: Kirigami.Units.largeSpacing

    Controls.Label { text: i18n("OpenAI"); font.bold: true }
    Controls.CheckBox { id: codexEnabled; text: i18n("Enable Codex") }
    Controls.Label { text: i18n("Uses the authenticated Codex CLI."); wrapMode: Text.Wrap; Layout.fillWidth: true }

    Controls.Label { text: i18n("OpenRouter"); font.bold: true; Layout.topMargin: Kirigami.Units.largeSpacing }
    Controls.CheckBox { id: openrouterEnabled; text: i18n("Enable OpenRouter") }
    Controls.Button {
        text: i18n("Add or replace API key…")
        enabled: page.pendingCommand === ""
        onClicked: {
            var url = Qt.resolvedUrl("../code/openrouter_wallet.py").toString()
            var path = decodeURIComponent(url.replace(/^file:\/\//, ""))
            page.pendingCommand = "python3 '" + path.replace(/'/g, "'\\''") + "'"
            page.walletMessage = i18n("Opening secure key editor…")
            walletReader.connectSource(page.pendingCommand)
        }
    }
    Controls.Label {
        text: i18n("The key is stored in KDE Wallet. Saving a new key replaces the previous one immediately.")
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }
    Controls.Label {
        visible: page.walletMessage !== ""
        text: page.walletMessage
        color: page.walletError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }
    Item { Layout.fillHeight: true }
    }

    Plasma5Support.DataSource {
        id: walletReader
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            disconnectSource(source)
            if (source !== page.pendingCommand)
                return
            page.pendingCommand = ""
            page.walletError = data["exit code"] !== 0
            page.walletMessage = page.walletError ? (data["stderr"] || i18n("Could not save the key."))
                                                  : (data["stdout"] || i18n("Done."))
        }
    }
}
