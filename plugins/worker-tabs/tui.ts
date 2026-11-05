import { Plugin } from "@opencode/plugin/tui"

export default Plugin.define({
  id: "worker-tabs",
  setup(context) {
    return context.data.on("session.created", (event) => {
      const meta = event.data.metadata as { role?: string } | undefined
      if (meta?.role === "worker" && context.ui.tabs.enabled()) context.ui.tabs.open(event.data.sessionID)
    })
  },
})
