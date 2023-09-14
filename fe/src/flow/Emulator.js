// taken from bluesign's implmentation here: https://github.com/bluesign/wasmPlayground/blob/main/src/util/emulator.ts

import { get, set, clear } from "idb-keyval"
import { entries } from "idb-keyval"

export class Emulator {
  isLoaded = false
  wasmhttp = {
    path: "api",
    handler: null,
    getAccountStorage: null,
    setHandler: v => {
      console.log("handler set")
      this.wasmhttp.handler = v
      window.setEmulator()
    },
    setGetAccountStorage: v => {
      console.log("getAccountStorage set")
      window["getAccountStorage"] = v
      this.wasmhttp.getAccountStorage = v
    }
  }

  async init(setEmulator) {
    var args = [
      "-v",
      "--simple-addresses",
      "--skip-tx-validation",
      "--persist"
    ]
    const wasm = await fetch("/emulator.wasm")
    // eslint-disable-next-line no-undef
    const go = new Go()
    console.log('go is', go)
    go.argv = [wasm, ...args]
    const module = await WebAssembly.instantiateStreaming(wasm, go.importObject)

    go.run(module.instance)

    this.isLoaded = true

    window.setEmulator = () => setEmulator(this)
  }

  async xget(key) {
    return get(key)
  }

  async xset(key, value) {
    return set(key, value)
  }

  constructor(callbacks) {
    if (this.isLoaded) {
      return
    }

    window["setHandler"] = this.wasmhttp.setHandler
    window["setGetAccountStorage"] = this.wasmhttp.setGetAccountStorage
    window["storage_get"] = this.xget
    window["storage_set"] = this.xset
    window["storage_clear"] = clear
    window["storage_entries"] = entries

    window["emulator_log"] = (message, data, timestamp) => {
      callbacks.log(message, data, timestamp)
    }

    var originalFetch = window.fetch

    window.fetch = async (url, options) => {
      if (!url.startsWith("http")) {
        return originalFetch(url, options)
      }
      const pathname = new URL(url).pathname
      console.log(pathname)

      if (!pathname.startsWith("/api")) {
        return originalFetch(url, options)
      }

      options.url = pathname.substring(4)
      var pos = url.indexOf("?")
      if (pos > 0) {
        options.url = options.url + url.substr(pos)
      }

      if (options.headers == null) {
        options.headers = {}
      }
      if (this.wasmhttp.handler) return this.wasmhttp.handler(options)

      return setTimeout(async function() {
        return await window.fetch(url, options)
      }, 1000)
    }

    const outputBuffers = new Map()
    const decoder = new TextDecoder("utf-8")

    window["fs"].writeSync = function(fileDescriptor, buf) {
      let outputBuffer = outputBuffers.get(fileDescriptor)
      if (!outputBuffer) {
        outputBuffer = ""
      }

      outputBuffer += decoder.decode(buf)

      const nl = outputBuffer.lastIndexOf("\n")
      if (nl != -1) {
        const lines = outputBuffer.substr(0, nl + 1)
        console.debug(`(FD ${fileDescriptor}):`, lines)
        // keep the remainder
        outputBuffer = outputBuffer.substr(nl + 1)
      }
      outputBuffers.set(fileDescriptor, outputBuffer)

      return buf.length
    }
  }
}
