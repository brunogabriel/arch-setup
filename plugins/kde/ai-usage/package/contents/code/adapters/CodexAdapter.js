.pragma library
.import "AIUsageAdapter.js" as Base

var id = "codex";
var name = "Codex";
var icon = "codex";
var reader = "codex_reader.py";

function command(helperPath, quote) {
    return "python3 " + quote(helperPath);
}

function normalize(raw, now) {
    if (!raw || raw.ok !== true)
        return null;

    var limits = [];
    var primary = raw.primary;
    var secondary = raw.secondary;

    if (primary) {
        var primaryLimit = Base.limit("5-hour limit", primary.usedPercent,
                                      primary.resetsAt, now);
        if (primaryLimit)
            limits.push(primaryLimit);
    }
    if (secondary) {
        var secondaryLimit = Base.limit("7-day limit", secondary.usedPercent,
                                        secondary.resetsAt, now);
        if (secondaryLimit)
            limits.push(secondaryLimit);
    }

    if (limits.length === 0)
        return null;

    return { id: id, name: name, icon: icon, limits: limits };
}
