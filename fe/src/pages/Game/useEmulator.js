// Taken from bluesign's implementation here: https://github.com/bluesign/wasmPlayground/blob/9c2df7571a6ee04e4bcf4d6dbc8d02a23f1a2838/src/hooks/useEmulator.ts#L48

import { useEffect, useState } from "react"

import { Emulator } from "../../flow/Emulator"

export default function useEmulator() {
  let initialCallbacks = {
    log: (message, data, timestamp) => {
      if (window.emulatorLog == null) {
        window.emulatorLog = []
      }

      if (
        data
          .toString()
          .includes(
            "821888a7a83e6a3c534bdeeee5dd9e9057b803e0a488ba98de97269257bb8126"
          )
      ) {
        window.emulatorLog.pop()
        return
      }

      if (message.toString().includes("Starting admin server")) {
        return
      }
      if (message.toString().includes("Starting REST API on port")) {
        console.log("Started wasm emulator.")
        window.emulatorLog.push({
          message: "Started wasm emulator.",
          data: "{}",
          timestamp
        })

        return
      }

      if (message.toString().includes("Starting gRPC server on port ")) {
        return
      }

      window.emulatorLog.push({ message, data, timestamp })
      console.log(message, data, timestamp)
    }
  }

  const [emulator, setEmulator] = useState(null)
  const [callbacks, setCallbacks] = useState(initialCallbacks)

  useEffect(() => {
    if (!emulator) {
      new Emulator(callbacks).init(setEmulator)
    }
  })

  return {
    emulator,
    setCallbacks
  }
}
