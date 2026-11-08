.pragma library
.import "AIUsageAdapter.js" as Base

var id = "openrouter";
var name = "OpenRouter";
var icon = "openrouter";
var reader = "openrouter_reader.py";

function command(helperPath, quote) {
    return "python3 " + quote(helperPath);
}

function normalize(raw, now) {
    if (!raw || raw.ok !== true)
        return null;
    var limits = [];
    var hasRemaining = raw.remaining !== null && raw.remaining !== undefined
                       && raw.remaining !== "" && isFinite(Number(raw.remaining));
    var remainingAmount = hasRemaining ? "US$ " + Number(raw.remaining).toFixed(2) : "";
    if (raw.limit !== null && raw.limit !== undefined && Number(raw.limit) > 0
        && hasRemaining) {
        var remaining = Base.clampPercent(Number(raw.remaining) / Number(raw.limit) * 100);
        if (remaining !== null)
            limits.push({label: "API key spending limit",
                         description: remainingAmount + " remaining of US$ " + Number(raw.limit).toFixed(2)
                                      + (raw.reset ? " · Reset: " + raw.reset : ""),
                         remaining: remaining});
    }
    return {id: id, name: name, icon: icon, limits: limits,
            message: limits.length ? "" : hasRemaining ? remainingAmount + " remaining"
                     : "No remaining amount available for this API key."};
}
