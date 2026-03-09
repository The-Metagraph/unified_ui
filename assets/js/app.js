const root = document.getElementById("elm-root");

if (!(root && window.Elm && window.Elm.Main)) {
  throw new Error("Elm runtime bootstrap failed: Main module not found");
}

const app = window.Elm.Main.init({ node: root });

const DEFAULT_TOPIC = "webui:runtime:v1";
const SESSION_TOPIC_REGEX = /^webui:runtime:session:[A-Za-z0-9_-]+:v1$/;
const CLIENT_EVENT_NAMES = ["runtime.event.send.v1", "runtime.event.ping.v1"];
const SERVER_EVENT_NAMES = ["runtime.event.recv.v1", "runtime.event.error.v1", "runtime.event.pong.v1"];
const REQUIRED_CLOUDEVENT_FIELDS = ["specversion", "id", "source", "type", "data"];
const REQUIRED_CLOUDEVENT_EXTENSIONS = ["correlation_id", "request_id"];
const OPTIONAL_RUNTIME_CONTEXT_FIELDS = ["session_id", "client_id", "user_id", "trace_id"];

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

const normalizeRuntimeContext = (candidate, fallback = {}) => {
  const safeCandidate = candidate && typeof candidate === "object" && !Array.isArray(candidate) ? candidate : {};
  const context = {};

  for (const requiredField of REQUIRED_CLOUDEVENT_EXTENSIONS) {
    const rawValue = safeCandidate[requiredField] || fallback[requiredField];
    context[requiredField] = typeof rawValue === "string" && rawValue.trim() !== "" ? rawValue : "unknown";
  }

  for (const optionalField of OPTIONAL_RUNTIME_CONTEXT_FIELDS) {
    const rawValue = safeCandidate[optionalField] || fallback[optionalField];

    if (typeof rawValue === "string" && rawValue.trim() !== "") {
      context[optionalField] = rawValue;
    }
  }

  return context;
};

const isValidTopic = (topic) => typeof topic === "string" && (topic === DEFAULT_TOPIC || SESSION_TOPIC_REGEX.test(topic));

const hasCanonicalExpectedEvents = (expectedEvents) => {
  if (!Array.isArray(expectedEvents) || expectedEvents.length !== SERVER_EVENT_NAMES.length) {
    return false;
  }

  return SERVER_EVENT_NAMES.every((eventName) => expectedEvents.includes(eventName));
};

const validateCloudEventEnvelope = (eventEnvelope) => {
  if (!eventEnvelope || typeof eventEnvelope !== "object" || Array.isArray(eventEnvelope)) {
    return { ok: false, reason: "envelope must be an object" };
  }

  for (const field of REQUIRED_CLOUDEVENT_FIELDS) {
    if (!(field in eventEnvelope)) {
      return { ok: false, reason: `missing required field: ${field}` };
    }
  }

  for (const extension of REQUIRED_CLOUDEVENT_EXTENSIONS) {
    if (typeof eventEnvelope[extension] !== "string" || eventEnvelope[extension].trim() === "") {
      return { ok: false, reason: `missing required extension: ${extension}` };
    }
  }

  if (eventEnvelope.specversion !== "1.0") {
    return { ok: false, reason: "specversion must equal 1.0" };
  }

  if (typeof eventEnvelope.data !== "object" || eventEnvelope.data === null || Array.isArray(eventEnvelope.data)) {
    return { ok: false, reason: "data must be an object" };
  }

  return { ok: true };
};

const handleRuntimeCommand = (raw) => {
  const command = normalizeCommand(raw);

  if (!command) {
    sendRuntimeEvent("runtime.event.error.v1", transportError("runtime.command.invalid_payload"));
    return;
  }

  if (command.kind === "ws_join") {
    if (!isValidTopic(command.topic)) {
      sendRuntimeEvent("runtime.event.error.v1", transportError("transport.invalid_topic", { topic: command.topic }));
      return;
    }

    if (!hasCanonicalExpectedEvents(raw.expected_events)) {
      sendRuntimeEvent(
        "runtime.event.error.v1",
        transportError("transport.invalid_expected_events", { expected_events: raw.expected_events }),
      );
      return;
    }

    transportState.joined = true;

    return;
  }

  if (command.event_name === "runtime.event.ping.v1") {
    if (!transportState.joined) {
      sendRuntimeEvent(
        "runtime.event.error.v1",
        transportError("runtime.transport.not_joined", { event_name: command.event_name }),
      );
      return;
    }

    const runtimeContext = normalizeRuntimeContext(command.payload, {
      correlation_id: "corr-local-dev",
      request_id: "req-local-dev",
    });

    sendRuntimeEvent("runtime.event.pong.v1", {
      ...runtimeContext,
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

    const envelopeValidation = validateCloudEventEnvelope(command.payload.event);
    const runtimeContext = normalizeRuntimeContext(command.payload.event, {
      correlation_id: "corr-local-dev",
      request_id: "req-local-dev",
    });

    if (!envelopeValidation.ok) {
      sendRuntimeEvent(
        "runtime.event.error.v1",
        transportError("transport.invalid_cloudevent_envelope", {
          reason: envelopeValidation.reason,
          context: runtimeContext,
        }),
      );
      return;
    }

    transportState.sequence += 1;

    sendRuntimeEvent("runtime.event.recv.v1", {
      event: command.payload.event || {},
      sequence: transportState.sequence,
      context: runtimeContext,
    });

    return;
  }

  if (command.kind === "ws_push" && !CLIENT_EVENT_NAMES.includes(command.event_name)) {
    sendRuntimeEvent(
      "runtime.event.error.v1",
      transportError("transport.unknown_client_event", { event_name: command.event_name, allowed: CLIENT_EVENT_NAMES }),
    );
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
