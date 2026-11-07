import { View, div, image } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { exec, appHome, theme, openOverlay, props, closeOverlay, run, layout } from "herdr";

const HELPER = `${appHome()}/mods/codex-usage/read_usage.py`;
const initial = () => ({ loading: true, error: false, primary: null, secondary: null });
// Add providers here when their local usage readers are implemented. The UI
// renders each configured provider independently; Codex is the only adapter today.
const PROVIDERS = [{ id: "codex", name: "Codex", icon: "icons/codex.svg" }];

function duration(minutes) {
  if (!Number.isFinite(minutes)) return "Quota";
  if (minutes % 10080 === 0) return `${minutes / 10080}w`;
  if (minutes % 1440 === 0) return `${minutes / 1440}d`;
  if (minutes % 60 === 0) return `${minutes / 60}h`;
  return `${minutes}m`;
}

function usedPercent(window) {
  return window && Number.isFinite(window.usedPercent)
    ? Math.max(0, Math.min(100, Math.round(window.usedPercent)))
    : null;
}

function remainingPercent(window) {
  const used = usedPercent(window);
  return used === null ? null : 100 - used;
}

function resetCountdown(epoch) {
  if (!Number.isFinite(epoch)) return "unavailable";
  const minutes = Math.max(0, Math.floor((epoch - Date.now() / 1000) / 60));
  const days = Math.floor(minutes / 1440);
  const hours = Math.floor((minutes % 1440) / 60);
  const mins = minutes % 60;
  if (days > 0) return `${days}d ${hours}h`;
  if (hours > 0) return `${hours}h ${mins}m`;
  return `${mins}m`;
}

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const match = find(child, id);
    if (match) return match;
  }
  return null;
}

export default class CodexUsage extends View {
  init(_props, cx) {
    this.state = initial();
    this.expanded = false;
    if (props()?.details) return;
    this.refresh(cx);
    cx.timer.every(60000, cx => this.refresh(cx));
  }

  refresh(cx) {
    if (this.busy) return;
    this.busy = true;
    cx.spawn(async cx => {
      try {
        const result = await exec("python3", [HELPER]);
        const data = JSON.parse(result.stdout);
        this.state = result.code === 0 && data.ok
          ? { ...data, loading: false, error: false }
          : { ...initial(), loading: false, error: true };
      } catch {
        this.state = { ...initial(), loading: false, error: true };
      }
      this.busy = false;
      cx.notify();
    });
  }

  open(cx) {
    if ((find(layout(), "sidebar")?.size?.px ?? Infinity) < 160) return;
    this.expanded = !this.expanded;
    run("layout.resize", { id: "codex-usage", px: this.expanded ? 160 : 33 });
    run("layout.resize", { id: "sidebar-bottom", px: this.expanded ? 237 : 110 });
    cx.notify();
  }

  render() {
    const t = theme();
    const narrow = (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;
    const provider = PROVIDERS.find(item => item.id === "codex") ?? PROVIDERS[0];
    if (props()?.details) {
      const { primary, secondary, planType, resetCredits, readAt, error } = props()?.snapshot ?? {};
      return v_flex().w(360).gap(12).p(18).text_color(t.foreground)
        .child(h_flex().items_center().justify_between().child(div().font_semibold().text_size(16).child("Codex usage"))
          .child(div().cursor_pointer().text_color(t.muted).on_click(() => closeOverlay(props().overlay)).child("×")))
        .when(Boolean(error), el => el.child(div().text_color(t.accent).child("Quota indisponível. Verifique o login do Codex CLI.")))
        .when(Boolean(primary), el => el.child(this.detailWindow("Short window", primary, t)))
        .when(Boolean(secondary), el => el.child(this.detailWindow("Long window", secondary, t)))
        .when(Boolean(planType), el => el.child(div().text_color(t.dim).child(`Plan: ${planType}`)))
        .when(Number.isFinite(resetCredits), el => el.child(div().text_color(t.dim).child(`Reset credits available: ${resetCredits}`)))
        .when(Number.isFinite(readAt), el => el.child(div().text_color(t.dim).text_size(11).child(`Updated ${new Date(readAt * 1000).toLocaleTimeString()}`)));
    }
    const { primary, secondary, loading, error } = this.state;
    const weekly = remainingPercent(secondary);
    const row = h_flex().w_full().h(28).flex_none().px(8).gap(9).items_center().rounded(8)
      .cursor_pointer().hover(el => el.bg(t.hover)).on_click((_event, cx) => this.open(cx))
      .child(image(provider.icon).w(14).h(14).flex_none())
      .when(!narrow, el => el.child(div().flex_1().min_w(0).truncate().text_color(t.muted).child(provider.name))
        .child(div().flex_none().text_size(11).text_color(t.dim).child(error
          ? "Unavailable" : loading ? "…" : `${weekly ?? "—"}%`)));
    return v_flex().size_full().min_h(0).bg(t.chrome).border_t(1).border_color(t.border).text_size(13)
      .when(!this.expanded || narrow, el => el.pt(4).px(narrow ? 0 : 8).child(row))
      .when(this.expanded && !narrow, el => el.px(8).pt(4).gap(4)
        .child(row)
        .child(h_flex().h(24).px(8).items_center().justify_between()
          .child(div().text_size(10).font_semibold().text_color(t.muted).child("Plan limits")))
        .when(!error && !loading, details => details
          .child(this.usageWindow(limitLabel(primary?.windowDurationMins), primary, t, false))
          .child(this.usageWindow(limitLabel(secondary?.windowDurationMins), secondary, t, true)))
        .when(error, details => details.child(div().px(8).text_size(11).text_color(t.dim).child("Quota unavailable")))
        .when(loading, details => details.child(div().px(8).text_size(11).text_color(t.dim).child("Refreshing quota…"))));
  }

  detailWindow(label, value, t) {
    const remaining = remainingPercent(value);
    return v_flex().gap(4).rounded(8).bg(t.chrome).p(10)
      .child(h_flex().justify_between().child(div().font_semibold().child(label))
      .child(div().text_color(t.foreground).child(`${remaining ?? "—"}% left`)))
      .child(div().text_size(12).text_color(t.dim).child(`Window: ${duration(value.windowDurationMins)}`))
      .child(div().text_size(12).text_color(t.dim).child(`Resets in ${resetCountdown(value.resetsAt)}`));
  }

  usageWindow(label, value, t, last) {
    const remaining = remainingPercent(value);
    const sidebarWidth = find(layout(), "sidebar")?.size?.px ?? 268;
    const trackWidth = Math.max(0, sidebarWidth - 32);
    return v_flex().gap(3).px(8).pb(last ? 12 : 8)
      .child(div().text_size(10).font_semibold().text_color(t.muted).child(label))
      .child(h_flex().w_full().items_center().justify_between()
        .child(div().text_size(10).text_color(t.dim).child(`Resets in ${resetCountdown(value?.resetsAt)}`))
        .child(div().text_size(10).text_color(t.foreground).child(`${remaining ?? "—"}% left`)))
      .child(h_flex().w_full().h(4).rounded_full().bg(t.border)
        .child(div().h_full().w(Math.round(trackWidth * (remaining ?? 0) / 100)).rounded_full().bg(t.muted)));
  }
}

function limitLabel(minutes) {
  if (!Number.isFinite(minutes)) return "Usage limit";
  if (minutes % 1440 === 0) return `${minutes / 1440}-day limit`;
  if (minutes % 60 === 0) return `${minutes / 60}-hour limit`;
  return `${minutes}-minute limit`;
}
