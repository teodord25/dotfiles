// Dump all open tabs into diane, then quit Firefox.
// Invariant: never quit unless `diane drop` exited 0, so a failed drop loses nothing.
// `diane drop` with no arguments reads stdin; don't add flags: unknown words
// become the note text (so `drop --stdin` would capture "--stdin" and exit 0).
// One line per tab: url \t title \t windowId \t lastAccessed (ISO)
(async () => {
  const tabs = await browser.tabs.query({});
  const lines = tabs
    .filter(t => /^https?:/.test(t.url))
    .map(t => [
      t.url,
      (t.title || "").replace(/[\t\n]/g, " "),
      t.windowId,
      new Date(t.lastAccessed).toISOString(),
    ].join("\t"));

  if (lines.length === 0) {
    await tri.excmds.qall();
    return;
  }

  let r;
  try {
    r = await tri.native.run("diane drop", lines.join("\n") + "\n");
  } catch (e) {
    r = { code: -1, content: String(e) };
  }

  if (!r || r.code !== 0) {
    console.error("tabdump failed", r);
    try {
      await tri.excmds.fillcmdline_tmp(8000, `tabdump FAILED (code ${r && r.code}), not quitting`);
    } catch (_) {}
    return;
  }

  await tri.excmds.qall();
})();
