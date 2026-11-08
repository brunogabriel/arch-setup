.pragma library

// Provider adapters return a normalized provider object consumed by the UI:
// { id, name, icon, limits: [{ label, description, remaining }] }.
function clampPercent(value) {
    if (value === null || value === undefined || value === "")
        return null;
    var number = Number(value);
    if (!isFinite(number))
        return null;
    return Math.max(0, Math.min(100, number));
}

function remainingPercent(usedPercent) {
    var used = clampPercent(usedPercent);
    return used === null ? null : 100 - used;
}

function formatDuration(milliseconds) {
    var totalMinutes = Math.max(0, Math.floor(milliseconds / 60000));
    var days = Math.floor(totalMinutes / 1440);
    var hours = Math.floor((totalMinutes % 1440) / 60);
    var minutes = totalMinutes % 60;

    if (days > 0)
        return days + "d " + hours + "h";
    if (hours > 0)
        return hours + "h " + minutes + "m";
    return minutes + "m";
}

function resetDescription(resetsAt, now) {
    if (resetsAt === null || resetsAt === undefined || resetsAt === "")
        return "";

    var timestamp = Number(resetsAt);
    if (!isFinite(timestamp))
        timestamp = Date.parse(resetsAt);
    if (!isFinite(timestamp))
        return "";
    if (timestamp < 1000000000000)
        timestamp *= 1000;

    var remaining = timestamp - now;
    return remaining <= 0 ? "Reset due" : "Resets in " + formatDuration(remaining);
}

function limit(label, usedPercent, resetsAt, now) {
    var remaining = remainingPercent(usedPercent);
    if (remaining === null)
        return null;
    return {
        label: label,
        description: resetDescription(resetsAt, now),
        remaining: remaining
    };
}
