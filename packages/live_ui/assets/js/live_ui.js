const EVENT_SELECTOR = "[data-live-ui-event]"

function parseJson(value, fallback = {}) {
  if (typeof value !== "string" || value.trim() === "") {
    return fallback
  }

  try {
    return JSON.parse(value)
  } catch (_error) {
    return fallback
  }
}

function hookDescriptor(element) {
  if (!(element instanceof HTMLElement)) {
    return null
  }

  const eventName = element.dataset.liveUiEvent

  if (!eventName) {
    return null
  }

  return {
    event: eventName,
    intent: element.dataset.liveUiIntent || eventName,
    payload: parseJson(element.dataset.liveUiPayload, {}),
    widgetId: element.dataset.liveUiWidgetId,
    widgetKind: element.dataset.liveUiWidgetKind,
  }
}

function closestEventTarget(root, target) {
  if (!(target instanceof HTMLElement)) {
    return null
  }

  const candidate = target.closest(EVENT_SELECTOR)

  if (!candidate || !root.contains(candidate)) {
    return null
  }

  return candidate
}

function pushHookEvent(hook, sourceElement, extraPayload = {}) {
  const descriptor = hookDescriptor(sourceElement)

  if (!descriptor || typeof hook.pushEvent !== "function") {
    return
  }

  hook.pushEvent(descriptor.event, {
    widget_id: descriptor.widgetId,
    widget_kind: descriptor.widgetKind,
    intent: descriptor.intent,
    [`event_${descriptor.event}_intent`]: descriptor.intent,
    ...descriptor.payload,
    ...extraPayload,
  })
}

function focusPaletteInput(root) {
  if (root.dataset.open !== "true") {
    return
  }

  const input = root.querySelector("input[name='query']")

  if (input instanceof HTMLElement && document.activeElement !== input) {
    input.focus()
  }
}

const Viewport = {
  mounted() {
    this.content = this.el.querySelector(".live-ui-viewport__content")

    if (!(this.content instanceof HTMLElement)) {
      return
    }

    const scrollTop = Number.parseInt(this.content.dataset.scrollTop || "0", 10)
    const scrollLeft = Number.parseInt(this.content.dataset.scrollLeft || "0", 10)

    if (Number.isFinite(scrollTop)) {
      this.content.scrollTop = scrollTop
    }

    if (Number.isFinite(scrollLeft)) {
      this.content.scrollLeft = scrollLeft
    }

    this.onScroll = () => {
      pushHookEvent(this, this.content, {
        scroll_top: this.content.scrollTop,
        scroll_left: this.content.scrollLeft,
      })
    }

    this.content.addEventListener("scroll", this.onScroll, {passive: true})
  },

  updated() {
    if (!(this.content instanceof HTMLElement)) {
      return
    }

    const scrollTop = Number.parseInt(this.content.dataset.scrollTop || "0", 10)
    const scrollLeft = Number.parseInt(this.content.dataset.scrollLeft || "0", 10)

    if (Number.isFinite(scrollTop) && Math.abs(this.content.scrollTop - scrollTop) > 1) {
      this.content.scrollTop = scrollTop
    }

    if (Number.isFinite(scrollLeft) && Math.abs(this.content.scrollLeft - scrollLeft) > 1) {
      this.content.scrollLeft = scrollLeft
    }
  },

  destroyed() {
    if (this.content instanceof HTMLElement && this.onScroll) {
      this.content.removeEventListener("scroll", this.onScroll)
    }
  },
}

const SplitPane = {
  mounted() {
    this.onClick = (event) => {
      const target = closestEventTarget(this.el, event.target)

      if (!target || target.dataset.liveUiEvent !== "resize") {
        return
      }

      pushHookEvent(this, target)
    }

    this.el.addEventListener("click", this.onClick)
  },

  destroyed() {
    if (this.onClick) {
      this.el.removeEventListener("click", this.onClick)
    }
  },
}

const CommandPalette = {
  mounted() {
    focusPaletteInput(this.el)

    this.onInput = (event) => {
      const target = event.target

      if (!(target instanceof HTMLInputElement) || target.name !== "query") {
        return
      }

      pushHookEvent(this, this.el, {query: target.value})
    }

    this.el.addEventListener("input", this.onInput)
  },

  updated() {
    focusPaletteInput(this.el)
  },

  destroyed() {
    if (this.onInput) {
      this.el.removeEventListener("input", this.onInput)
    }
  },
}

const Canvas = {
  mounted() {
    this.el.dataset.liveUiCanvasReady = "true"
  },

  updated() {
    this.el.dataset.liveUiCanvasReady = "true"
  },
}

const LiveUiHooks = {
  "LiveUi.Canvas": Canvas,
  "LiveUi.CommandPalette": CommandPalette,
  "LiveUi.SplitPane": SplitPane,
  "LiveUi.Viewport": Viewport,
}

export {Canvas, CommandPalette, LiveUiHooks, SplitPane, Viewport}
export default LiveUiHooks
