/* Bảng xếp hạng (block/slider/view_leaderboard.tpl).
   - Tabs switch without a reload and keep ?tab= in the address; the course list reloads the page for that course.
   - "Điểm qua từng lần làm": a line chart of the latest attempts (data-mlb-trend).
   - "Bản đồ năng lực": a radar of the chapters with the most questions (data-mlb-radar), when there are at least three. */
(() => {
  "use strict";
  const root = document.querySelector("[data-mlb]");
  if (!root || root.dataset.mlbReady) return;
  root.dataset.mlbReady = "1";

  const svgNs = "http://www.w3.org/2000/svg";
  const svg = (tag, attributes = {}, text) => {
    const node = document.createElementNS(svgNs, tag);
    Object.entries(attributes).forEach(([name, value]) => node.setAttribute(name, value));
    if (text !== undefined) node.textContent = text;
    return node;
  };
  const read = (element, name) => {
    try { return JSON.parse(element.getAttribute(name) || "[]"); } catch (error) { return []; }
  };

  // Tabs
  const tabs = [...root.querySelectorAll("[data-mlb-tab]")];
  const select = (name, focus) => {
    tabs.forEach((tab) => {
      const on = tab.dataset.mlbTab === name;
      tab.setAttribute("aria-selected", on ? "true" : "false");
      tab.tabIndex = on ? 0 : -1;
      if (on && focus) tab.focus();
    });
    root.querySelectorAll("[data-mlb-panel]").forEach((panel) => { panel.hidden = panel.dataset.mlbPanel !== name; });
    const active = tabs.find((tab) => tab.dataset.mlbTab === name);
    if (active) history.replaceState(null, "", active.href);
  };
  tabs.forEach((tab, index) => {
    tab.tabIndex = tab.getAttribute("aria-selected") === "true" ? 0 : -1;
    tab.addEventListener("click", (event) => { event.preventDefault(); select(tab.dataset.mlbTab, false); });
    tab.addEventListener("keydown", (event) => {
      if (event.key !== "ArrowRight" && event.key !== "ArrowLeft") return;
      event.preventDefault();
      const next = tabs[(index + (event.key === "ArrowRight" ? 1 : -1) + tabs.length) % tabs.length];
      select(next.dataset.mlbTab, true);
    });
  });

  root.querySelectorAll("[data-mlb-go]").forEach((list) => list.addEventListener("change", () => { window.location.href = list.value; }));

  // Line chart of the latest attempts (score out of 100)
  root.querySelectorAll("[data-mlb-trend]").forEach((holder) => {
    const points = read(holder, "data-mlb-trend");
    if (!points.length) return;
    const width = 560;
    const height = 230;
    const pad = { top: 14, right: 16, bottom: 30, left: 34 };
    const x = (index) => pad.left + (points.length === 1 ? (width - pad.left - pad.right) / 2 : index * (width - pad.left - pad.right) / (points.length - 1));
    const y = (score) => pad.top + (100 - Math.max(0, Math.min(100, score))) * (height - pad.top - pad.bottom) / 100;
    const chart = svg("svg", { viewBox: `0 0 ${width} ${height}`, role: "img", "aria-label": `Điểm ${points.length} lần làm bài gần nhất` });

    [0, 25, 50, 75, 100].forEach((score) => {
      chart.append(svg("line", { class: "mlb-chart-grid", x1: pad.left, x2: width - pad.right, y1: y(score), y2: y(score) }));
      chart.append(svg("text", { class: "mlb-chart-label", x: pad.left - 8, y: y(score) + 4, "text-anchor": "end" }, String(score)));
    });
    const line = points.map((point, index) => `${x(index)},${y(point.score)}`).join(" ");
    if (points.length > 1) {
      chart.append(svg("polygon", { class: "mlb-chart-area", points: `${x(0)},${y(0)} ${line} ${x(points.length - 1)},${y(0)}` }));
      chart.append(svg("polyline", { class: "mlb-chart-line", points: line }));
    }
    points.forEach((point, index) => {
      const dot = svg("circle", { class: "mlb-chart-dot", cx: x(index), cy: y(point.score), r: 4.5 });
      dot.append(svg("title", {}, `${point.date} · ${point.quiz}: ${point.score} điểm`));
      chart.append(dot);
      chart.append(svg("text", { class: "mlb-chart-label", x: x(index), y: height - 8, "text-anchor": "middle" }, point.date));
    });
    holder.append(chart);
  });

  // Radar of the chapters (up to six, those with the most questions)
  root.querySelectorAll("[data-mlb-radar]").forEach((holder) => {
    const chapters = read(holder, "data-mlb-radar").sort((a, b) => b.questions - a.questions).slice(0, 6);
    if (chapters.length < 3) { holder.hidden = true; return; }
    const size = 320;
    const centre = size / 2;
    const radius = 104;
    const angle = (index) => -Math.PI / 2 + index * 2 * Math.PI / chapters.length;
    const at = (index, value) => [centre + Math.cos(angle(index)) * radius * value, centre + Math.sin(angle(index)) * radius * value];
    const shorten = (text) => (text.length > 22 ? `${text.slice(0, 21).trim()}…` : text);
    const chart = svg("svg", { viewBox: `-50 -6 ${size + 100} ${size + 12}`, role: "img", "aria-label": "Tỉ lệ đúng theo chương" });

    [0.25, 0.5, 0.75, 1].forEach((ring) => {
      chart.append(svg("polygon", { class: "mlb-radar-ring", points: chapters.map((chapter, index) => at(index, ring).join(",")).join(" ") }));
    });
    chapters.forEach((chapter, index) => {
      const [endX, endY] = at(index, 1);
      chart.append(svg("line", { class: "mlb-chart-grid", x1: centre, y1: centre, x2: endX, y2: endY }));
      const [labelX, labelY] = at(index, 1.2);
      const anchor = Math.abs(labelX - centre) < 8 ? "middle" : labelX > centre ? "start" : "end";
      const label = svg("text", { class: "mlb-chart-label", x: labelX, y: labelY + 4, "text-anchor": anchor }, shorten(chapter.name));
      label.append(svg("title", {}, `${chapter.name}: ${chapter.score}%`));
      chart.append(label);
    });
    chart.append(svg("polygon", { class: "mlb-radar-shape", points: chapters.map((chapter, index) => at(index, Math.max(0.03, chapter.score / 100)).join(",")).join(" ") }));
    holder.append(chart);
  });
})();
