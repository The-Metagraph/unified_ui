const root = document.getElementById("elm-root");

if (!(root && window.Elm && window.Elm.Main)) {
  throw new Error("Elm runtime bootstrap failed: Main module not found");
}

const app = window.Elm.Main.init({ node: root });

const transportState = {
  joined: false,
  sequence: 0,
};

const sendRuntimeEvent = (eventName, payload = {}) => {
  if (app.ports && app.ports.runtimeEventReceived) {
    app.ports.runtimeEventReceived.send({
      event_name: eventName,
      payload,
    });
  }
};

const normalizeCommand = (raw) => {
  if (!raw || typeof raw !== "object") {
    return null;
  }

  return {
    kind: raw.kind,
    event_name: raw.event_name,
    topic: raw.topic,
    payload: raw.payload || {},
  };
};

const transportError = (errorCode, details = {}) => ({
  error: {
    error_code: errorCode,
    category: "protocol",
    retryable: false,
    details,
  },
});

const handleRuntimeCommand = (raw) => {
  const command = normalizeCommand(raw);

  if (!command) {
    sendRuntimeEvent("runtime.event.error.v1", transportError("runtime.command.invalid_payload"));
    return;
  }

  if (command.kind === "ws_join") {
    transportState.joined = true;

    sendRuntimeEvent("runtime.event.joined.v1", {
      topic: command.topic || "webui:runtime:v1",
      sequence: transportState.sequence,
    });

    return;
  }

  if (command.event_name === "runtime.event.ping.v1") {
    sendRuntimeEvent("runtime.event.pong.v1", {
      correlation_id: command.payload.correlation_id || "corr-local-dev",
      request_id: command.payload.request_id || "req-local-dev",
    });

    return;
  }

  if (command.event_name === "runtime.event.send.v1") {
    if (!transportState.joined) {
      sendRuntimeEvent(
        "runtime.event.error.v1",
        transportError("runtime.transport.not_joined", { event_name: command.event_name }),
      );

      return;
    }

    transportState.sequence += 1;

    sendRuntimeEvent("runtime.event.recv.v1", {
      event: command.payload.event || {},
      sequence: transportState.sequence,
    });

    return;
  }

  sendRuntimeEvent(
    "runtime.event.error.v1",
    transportError("runtime.transport.unknown_command", {
      event_name: command.event_name,
      kind: command.kind,
    }),
  );
};

if (app.ports && app.ports.sendRuntimeCommand) {
  app.ports.sendRuntimeCommand.subscribe(handleRuntimeCommand);
} else {
  throw new Error("Elm runtime bootstrap failed: sendRuntimeCommand port not found");
}
