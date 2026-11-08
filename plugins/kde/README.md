# KDE Plasma plugins

Plasma-specific widgets and integrations live in this directory. They are
grouped under the **KDE** section of Arch Setup's **Plugins** menu. The KDE
section is only shown in a Plasma session, and the installer checks the
session again before running.

Add each installable plugin as a direct child directory containing:

```text
plugins/kde/<plugin-id>/
├── plugin.json
├── install.sh
└── ... plugin payload and documentation
```

The manifest's `name` is shown in the multi-select list. `install.sh` should
install or update the plugin and return a non-zero status on failure. On Gum
2.x, use `x` to toggle items because upstream currently has a Space-key
regression; older Gum versions use Space. Tab is not advertised as a toggle.
