.pragma library
.import "adapters/CodexAdapter.js" as CodexAdapter
.import "adapters/OpenRouterAdapter.js" as OpenRouterAdapter

// Register new adapters here. Each one must implement normalize(raw, now)
// and expose id, name, and icon.
// QML delegates need ordinary JavaScript objects, not imported module
// namespaces, for their modelData roles.
var adapters = [{
    id: CodexAdapter.id,
    name: CodexAdapter.name,
    icon: CodexAdapter.icon,
    reader: CodexAdapter.reader,
    command: CodexAdapter.command,
    normalize: CodexAdapter.normalize
}, {
    id: OpenRouterAdapter.id,
    name: OpenRouterAdapter.name,
    icon: OpenRouterAdapter.icon,
    reader: OpenRouterAdapter.reader,
    command: OpenRouterAdapter.command,
    normalize: OpenRouterAdapter.normalize
}];

function all(codexEnabled, openrouterEnabled) {
    return adapters.filter(function(adapter) {
        return (adapter.id === "codex" && codexEnabled)
            || (adapter.id === "openrouter" && openrouterEnabled);
    });
}

function find(id, available) {
    for (var i = 0; i < available.length; i++) {
        if (available[i].id === id)
            return available[i];
    }
    return available.length > 0 ? available[0] : null;
}
