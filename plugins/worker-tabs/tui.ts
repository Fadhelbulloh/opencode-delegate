import { Plugin } from "@opencode/plugin/tui"

export default Plugin.define({
  id: "worker-tabs",
  setup(context) {
    return context.data.on("session.created", (event) => {
      const meta = event.data.metadata as { role?: string; home?: string } | undefined
      const here = (context.location ?? context.data.location.default())?.directory
      if (meta?.role !== "worker" || !context.ui.tabs.enabled()) return
      // `home` is the planner's directory; workers in worktrees still belong to that TUI.
      if ((meta.home ?? event.data.location?.directory) !== here) return
      context.ui.tabs.open(event.data.sessionID)
    })
  },
})
