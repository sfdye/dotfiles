const SERVICE = "keepawake"
const BIN = `${process.env.HOME ?? ""}/.local/bin/keepawake`

function run(args) {
  try {
    Bun.spawn([BIN, ...args], { stdout: "ignore", stderr: "ignore" })
  } catch {}
}

export const KeepAwakePlugin = async ({ client }) => {
  if (process.platform !== "darwin") {
    return { event: async () => {} }
  }

  try {
    client.app.log({ body: { service: SERVICE, level: "info", message: "plugin initialized" } }).catch(() => {})
  } catch {}

  return {
    event: async ({ event }) => {
      const props = event.properties
      const sessionID = props?.sessionID
      if (typeof sessionID !== "string") return
      const key = `opencode-${sessionID}`

      switch (event.type) {
        case "session.status": {
          const status = props?.status
          if (status?.type === "idle") run(["release", key])
          else run(["acquire", key, "--reason", "opencode"])
          break
        }
        case "session.idle":
        case "session.deleted":
          run(["release", key])
          break
      }
    },
  }
}
