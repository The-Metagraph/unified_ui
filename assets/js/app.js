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
const CANONICAL_WIDGET_EVENT_TYPES = [
  "unified.action.requested",
  "unified.button.clicked",
  "unified.canvas.pointer.changed",
  "unified.chart.point_hovered",
  "unified.chart.point_selected",
  "unified.command.executed",
  "unified.element.blurred",
  "unified.element.focused",
  "unified.form.submitted",
  "unified.input.changed",
  "unified.item.selected",
  "unified.item.toggled",
  "unified.link.clicked",
  "unified.menu.action_selected",
  "unified.overlay.closed",
  "unified.overlay.confirmed",
  "unified.scroll.changed",
  "unified.split.collapse_changed",
  "unified.split.resized",
  "unified.tab.changed",
  "unified.tab.closed",
  "unified.table.row_selected",
  "unified.table.sorted",
  "unified.toast.cleared",
  "unified.toast.dismissed",
  "unified.tree.node_selected",
  "unified.tree.node_toggled",
  "unified.view.changed",
  "unified.viewport.resized",
];
const CANONICAL_WIDGET_EVENT_KEY_SPECS = {
  "unified.action.requested": { required_all_of: ["widget_id", "action"], required_any_of: [] },
  "unified.button.clicked": { required_all_of: [], required_any_of: [["action", "button_id", "widget_id"]] },
  "unified.canvas.pointer.changed": { required_all_of: ["widget_id", "x", "y", "phase"], required_any_of: [] },
  "unified.chart.point_hovered": { required_all_of: ["widget_id", "series", "point"], required_any_of: [] },
  "unified.chart.point_selected": { required_all_of: ["widget_id", "series", "point"], required_any_of: [] },
  "unified.command.executed": { required_all_of: ["widget_id", "command_id"], required_any_of: [] },
  "unified.element.blurred": { required_all_of: ["widget_id"], required_any_of: [] },
  "unified.element.focused": { required_all_of: ["widget_id"], required_any_of: [] },
  "unified.form.submitted": { required_all_of: [], required_any_of: [["form_id", "widget_id"]] },
  "unified.input.changed": { required_all_of: ["value"], required_any_of: [["input_id", "widget_id"]] },
  "unified.item.selected": { required_all_of: ["widget_id"], required_any_of: [["item_id", "index", "value"]] },
  "unified.item.toggled": { required_all_of: ["selected", "widget_id"], required_any_of: [["item_id", "index"]] },
  "unified.link.clicked": { required_all_of: ["widget_id", "href"], required_any_of: [] },
  "unified.menu.action_selected": { required_all_of: ["widget_id", "action_id"], required_any_of: [] },
  "unified.overlay.closed": { required_all_of: ["widget_id"], required_any_of: [] },
  "unified.overlay.confirmed": { required_all_of: ["widget_id", "action_id"], required_any_of: [] },
  "unified.scroll.changed": { required_all_of: ["widget_id", "position"], required_any_of: [] },
  "unified.split.collapse_changed": { required_all_of: ["widget_id", "pane_id", "collapsed"], required_any_of: [] },
  "unified.split.resized": { required_all_of: ["widget_id", "panes"], required_any_of: [] },
  "unified.tab.changed": { required_all_of: ["widget_id", "tab_id"], required_any_of: [] },
  "unified.tab.closed": { required_all_of: ["widget_id", "tab_id"], required_any_of: [] },
  "unified.table.row_selected": { required_all_of: ["widget_id", "row_index"], required_any_of: [] },
  "unified.table.sorted": { required_all_of: ["widget_id", "column", "direction"], required_any_of: [] },
  "unified.toast.cleared": { required_all_of: ["widget_id"], required_any_of: [] },
  "unified.toast.dismissed": { required_all_of: ["widget_id", "toast_id"], required_any_of: [] },
  "unified.tree.node_selected": { required_all_of: ["widget_id", "node_id"], required_any_of: [] },
  "unified.tree.node_toggled": { required_all_of: ["widget_id", "node_id", "expanded"], required_any_of: [] },
  "unified.view.changed": { required_all_of: ["widget_id", "view"], required_any_of: [] },
  "unified.viewport.resized": { required_all_of: ["widget_id", "width", "height"], required_any_of: [] },
};
const CANONICAL_WIDGET_EVENT_ROUTE_FAMILIES = {
  "unified.action.requested": "click",
  "unified.button.clicked": "click",
  "unified.canvas.pointer.changed": "change",
  "unified.chart.point_hovered": "selection",
  "unified.chart.point_selected": "selection",
  "unified.command.executed": "click",
  "unified.element.blurred": "focus",
  "unified.element.focused": "focus",
  "unified.form.submitted": "submit",
  "unified.input.changed": "change",
  "unified.item.selected": "selection",
  "unified.item.toggled": "selection",
  "unified.link.clicked": "click",
  "unified.menu.action_selected": "click",
  "unified.overlay.closed": "click",
  "unified.overlay.confirmed": "click",
  "unified.scroll.changed": "change",
  "unified.split.collapse_changed": "change",
  "unified.split.resized": "change",
  "unified.tab.changed": "selection",
  "unified.tab.closed": "click",
  "unified.table.row_selected": "selection",
  "unified.table.sorted": "click",
  "unified.toast.cleared": "click",
  "unified.toast.dismissed": "click",
  "unified.tree.node_selected": "selection",
  "unified.tree.node_toggled": "selection",
  "unified.view.changed": "change",
  "unified.viewport.resized": "change",
};
const CANONICAL_ROUTE_KEY_REQUIREMENTS = {
  click: ["action", "button_id", "widget_id", "id"],
  change: ["input_id", "widget_id", "field", "action", "id"],
  submit: ["form_id", "action", "id"],
};
const CANONICAL_ROUTE_KEY_SOURCE_VALUES = ["route_key_contract", "widget_event_contract"];
const CANONICAL_ROUTE_KEY_SOURCE_REQUIREMENTS = {
  click: {
    action: "widget_event_contract",
    button_id: "route_key_contract",
    widget_id: "widget_event_contract",
    id: "route_key_contract",
  },
  change: {
    input_id: "route_key_contract",
    widget_id: "widget_event_contract",
    field: "route_key_contract",
    action: "widget_event_contract",
    id: "route_key_contract",
  },
  submit: {
    form_id: "route_key_contract",
    action: "widget_event_contract",
    id: "route_key_contract",
  },
};

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

const hasPresentPayloadKey = (data, key) => {
  if (!data || typeof data !== "object" || Array.isArray(data)) {
    return false;
  }

  const value = data[key];

  if (value === undefined || value === null) {
    return false;
  }

  if (typeof value === "string") {
    return value.trim() !== "";
  }

  return true;
};

const normalizedStringList = (candidate) => {
  if (!Array.isArray(candidate)) {
    return [];
  }

  return candidate.filter((value) => typeof value === "string").map((value) => value.trim()).filter(Boolean);
};

const routeKeyValueType = (value) => {
  if (Array.isArray(value)) {
    return "array";
  }

  if (value === null) {
    return "null";
  }

  return typeof value;
};

const analyzeDeclaredRouteKeys = (candidate) => {
  if (candidate === undefined || candidate === null) {
    return { normalized: [], invalidRouteKeys: [], actualShape: "missing" };
  }

  if (!Array.isArray(candidate)) {
    return {
      normalized: [],
      invalidRouteKeys: [{ index: -1, value_type: routeKeyValueType(candidate) }],
      actualShape: routeKeyValueType(candidate),
    };
  }

  const invalidRouteKeys = candidate
    .map((value, index) => ({ value, index }))
    .filter(({ value }) => typeof value !== "string" || value.trim() === "")
    .map(({ value, index }) => ({ index, value_type: routeKeyValueType(value) }));

  return {
    normalized: normalizedStringList(candidate),
    invalidRouteKeys,
    actualShape: "array<unknown>",
  };
};

const analyzeRequiredRouteKeyValues = (data, requiredRouteKeys) => {
  const safeData = data && typeof data === "object" && !Array.isArray(data) ? data : {};

  const invalidRouteKeyValues = requiredRouteKeys
    .filter((key) => hasPresentPayloadKey(safeData, key))
    .filter((key) => {
      const value = safeData[key];
      return typeof value !== "string" || value.trim() === "";
    })
    .map((key) => ({
      key,
      value_type: routeKeyValueType(safeData[key]),
    }));

  return {
    invalidRouteKeyValues,
    expectedRouteKeyValueShape: "non-empty string",
  };
};

const analyzeDeclaredRouteKeySources = (candidate, requiredRouteKeys) => {
  if (candidate === undefined || candidate === null) {
    return {
      normalized: {},
      invalidRouteKeySources: [],
      missingRouteKeySourceKeys: [...requiredRouteKeys],
      unexpectedRouteKeySourceKeys: [],
      actualShape: "missing",
    };
  }

  if (!candidate || typeof candidate !== "object" || Array.isArray(candidate)) {
    return {
      normalized: {},
      invalidRouteKeySources: [{ key: "route_key_sources", value_type: routeKeyValueType(candidate) }],
      missingRouteKeySourceKeys: [...requiredRouteKeys],
      unexpectedRouteKeySourceKeys: [],
      actualShape: routeKeyValueType(candidate),
    };
  }

  const normalized = {};
  const invalidRouteKeySources = [];

  for (const [key, value] of Object.entries(candidate)) {
    if (typeof value !== "string" || value.trim() === "") {
      invalidRouteKeySources.push({
        key,
        value_type: routeKeyValueType(value),
      });
      continue;
    }

    const normalizedSource = value.trim();

    if (!CANONICAL_ROUTE_KEY_SOURCE_VALUES.includes(normalizedSource)) {
      invalidRouteKeySources.push({
        key,
        value_type: "invalid_source_value",
        value: normalizedSource,
      });
      continue;
    }

    normalized[key] = normalizedSource;
  }

  const missingRouteKeySourceKeys = requiredRouteKeys.filter((key) => !(key in normalized));
  const unexpectedRouteKeySourceKeys = Object.keys(normalized).filter((key) => !requiredRouteKeys.includes(key));

  return {
    normalized,
    invalidRouteKeySources,
    missingRouteKeySourceKeys,
    unexpectedRouteKeySourceKeys,
    actualShape: "object<route_key,source>",
  };
};

const analyzeDeclaredRouteKeySourceKeys = (candidate, requiredRouteKeys) => {
  if (candidate === undefined || candidate === null) {
    return {
      normalized: [],
      invalidRouteKeySourceKeys: [],
      duplicateRouteKeySourceKeys: [],
      missingRouteKeySourceKeys: [...requiredRouteKeys],
      unexpectedRouteKeySourceKeys: [],
      actualShape: "missing",
    };
  }

  if (!Array.isArray(candidate)) {
    return {
      normalized: [],
      invalidRouteKeySourceKeys: [{ index: -1, value_type: routeKeyValueType(candidate) }],
      duplicateRouteKeySourceKeys: [],
      missingRouteKeySourceKeys: [...requiredRouteKeys],
      unexpectedRouteKeySourceKeys: [],
      actualShape: routeKeyValueType(candidate),
    };
  }

  const invalidRouteKeySourceKeys = candidate
    .map((value, index) => ({ value, index }))
    .filter(({ value }) => typeof value !== "string" || value.trim() === "")
    .map(({ value, index }) => ({ index, value_type: routeKeyValueType(value) }));

  const normalized = normalizedStringList(candidate);
  const duplicateRouteKeySourceKeys = duplicateStrings(normalized);
  const missingRouteKeySourceKeys = requiredRouteKeys.filter((key) => !normalized.includes(key));
  const unexpectedRouteKeySourceKeys = normalized.filter((key) => !requiredRouteKeys.includes(key));

  return {
    normalized,
    invalidRouteKeySourceKeys,
    duplicateRouteKeySourceKeys,
    missingRouteKeySourceKeys,
    unexpectedRouteKeySourceKeys,
    actualShape: "array<unknown>",
  };
};

const analyzeRouteKeySourceRequirements = (routeFamily, requiredRouteKeys) => {
  const candidate = CANONICAL_ROUTE_KEY_SOURCE_REQUIREMENTS[routeFamily];

  if (!candidate || typeof candidate !== "object" || Array.isArray(candidate)) {
    return {
      normalized: {},
      missingRequirementKeys: [...requiredRouteKeys],
      invalidRequirementKeys: [{ route_family: routeFamily, value_type: routeKeyValueType(candidate) }],
      unexpectedRequirementKeys: [],
    };
  }

  const normalized = {};
  const invalidRequirementKeys = [];

  for (const routeKey of requiredRouteKeys) {
    const sourceValue = candidate[routeKey];

    if (typeof sourceValue !== "string" || sourceValue.trim() === "") {
      continue;
    }

    const normalizedSource = sourceValue.trim();

    if (!CANONICAL_ROUTE_KEY_SOURCE_VALUES.includes(normalizedSource)) {
      invalidRequirementKeys.push({
        key: routeKey,
        value: normalizedSource,
      });
      continue;
    }

    normalized[routeKey] = normalizedSource;
  }

  const missingRequirementKeys = requiredRouteKeys.filter((routeKey) => !(routeKey in normalized));
  const unexpectedRequirementKeys = Object.keys(candidate).filter((routeKey) => !requiredRouteKeys.includes(routeKey));

  return {
    normalized,
    missingRequirementKeys,
    invalidRequirementKeys,
    unexpectedRequirementKeys,
  };
};

const analyzeRouteKeySourceKeyParityWithRouteKeys = (routeKeys, routeKeySourceKeys) => {
  const expected = Array.isArray(routeKeys) ? [...routeKeys] : [];
  const actual = Array.isArray(routeKeySourceKeys) ? [...routeKeySourceKeys] : [];

  const length = Math.max(expected.length, actual.length);
  const mismatches = [];

  for (let index = 0; index < length; index += 1) {
    if (expected[index] !== actual[index]) {
      mismatches.push({
        index,
        route_key: expected[index] ?? null,
        route_key_source_key: actual[index] ?? null,
      });
    }
  }

  return {
    matches: mismatches.length === 0,
    mismatches,
  };
};

const duplicateStrings = (candidate) => {
  const seen = new Set();
  const duplicates = [];

  for (const item of candidate) {
    if (seen.has(item) && !duplicates.includes(item)) {
      duplicates.push(item);
    } else {
      seen.add(item);
    }
  }

  return duplicates;
};

const validateWidgetEventPayload = (eventEnvelope) => {
  const keySpec = CANONICAL_WIDGET_EVENT_KEY_SPECS[eventEnvelope.type];

  if (!keySpec) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_type",
      reason: `unknown canonical widget event type: ${eventEnvelope.type}`,
    };
  }

  const missingAllOf = keySpec.required_all_of.filter((key) => !hasPresentPayloadKey(eventEnvelope.data, key));
  const missingAnyOfGroups = keySpec.required_any_of.filter((group) =>
    !group.some((candidateKey) => hasPresentPayloadKey(eventEnvelope.data, candidateKey)),
  );

  if (missingAllOf.length > 0 || missingAnyOfGroups.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_payload",
      reason: `missing required payload keys for event type: ${eventEnvelope.type}`,
      details: {
        event_type: eventEnvelope.type,
        missing_all_of: missingAllOf,
        missing_any_of_groups: missingAnyOfGroups,
      },
    };
  }

  return { ok: true };
};

const validateWidgetEventRouteKeys = (eventEnvelope) => {
  const routeFamily = CANONICAL_WIDGET_EVENT_ROUTE_FAMILIES[eventEnvelope.type];

  if (typeof routeFamily !== "string" || routeFamily.trim() === "") {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_family",
      reason: `missing canonical route family for event type: ${eventEnvelope.type}`,
      details: {
        event_type: eventEnvelope.type,
      },
    };
  }

  const declaredRouteFamily = eventEnvelope.data && eventEnvelope.data.route_family;

  if (typeof declaredRouteFamily !== "string" || declaredRouteFamily.trim() === "") {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_family",
      reason: `missing route_family payload field for event type: ${eventEnvelope.type}`,
      details: {
        event_type: eventEnvelope.type,
        expected_route_family: routeFamily,
      },
    };
  }

  if (declaredRouteFamily !== routeFamily) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_family",
      reason: `route_family payload mismatch for event type: ${eventEnvelope.type}`,
      details: {
        event_type: eventEnvelope.type,
        expected_route_family: routeFamily,
        actual_route_family: declaredRouteFamily,
      },
    };
  }

  const requiredRouteKeys = CANONICAL_ROUTE_KEY_REQUIREMENTS[routeFamily] || [];

  if (requiredRouteKeys.length === 0) {
    return { ok: true };
  }

  const presentRouteKeys = requiredRouteKeys.filter((key) => hasPresentPayloadKey(eventEnvelope.data, key));
  const missingRouteKeys = requiredRouteKeys.filter((key) => !hasPresentPayloadKey(eventEnvelope.data, key));
  const routeKeyAnalysis = analyzeDeclaredRouteKeys(eventEnvelope.data && eventEnvelope.data.route_keys);
  const declaredRouteKeys = routeKeyAnalysis.normalized;
  const routeKeyValueAnalysis = analyzeRequiredRouteKeyValues(eventEnvelope.data, requiredRouteKeys);
  const sourceRequirementAnalysis = analyzeRouteKeySourceRequirements(routeFamily, requiredRouteKeys);
  const expectedRouteKeySources = sourceRequirementAnalysis.normalized;
  const routeKeySourceAnalysis = analyzeDeclaredRouteKeySources(
    eventEnvelope.data && eventEnvelope.data.route_key_sources,
    requiredRouteKeys,
  );
  const routeKeySourceKeyAnalysis = analyzeDeclaredRouteKeySourceKeys(
    eventEnvelope.data && eventEnvelope.data.route_key_source_keys,
    requiredRouteKeys,
  );

  if (presentRouteKeys.length === 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route",
      reason: `missing canonical route keys for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        required_route_keys: requiredRouteKeys,
      },
    };
  }

  if (routeKeyAnalysis.invalidRouteKeys.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_keys payload contains invalid key values for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_value_shape: "array<non-empty string>",
        actual_value_shape: routeKeyAnalysis.actualShape,
        invalid_route_keys: routeKeyAnalysis.invalidRouteKeys,
      },
    };
  }

  if (declaredRouteKeys.length === 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `missing route_keys payload field for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_keys: requiredRouteKeys,
      },
    };
  }

  if (missingRouteKeys.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `missing required route keys for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_keys: requiredRouteKeys,
        missing_route_keys: missingRouteKeys,
        actual_route_keys: presentRouteKeys,
      },
    };
  }

  if (routeKeyValueAnalysis.invalidRouteKeyValues.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route-key payload values must be non-empty strings for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_key_value_shape: routeKeyValueAnalysis.expectedRouteKeyValueShape,
        invalid_route_key_values: routeKeyValueAnalysis.invalidRouteKeyValues,
      },
    };
  }

  if (
    sourceRequirementAnalysis.missingRequirementKeys.length > 0 ||
    sourceRequirementAnalysis.invalidRequirementKeys.length > 0 ||
    sourceRequirementAnalysis.unexpectedRequirementKeys.length > 0
  ) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `canonical route_key source requirements drift for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_keys: requiredRouteKeys,
        allowed_route_key_source_values: CANONICAL_ROUTE_KEY_SOURCE_VALUES,
        missing_route_key_source_requirements: sourceRequirementAnalysis.missingRequirementKeys,
        invalid_route_key_source_requirements: sourceRequirementAnalysis.invalidRequirementKeys,
        unexpected_route_key_source_requirements: sourceRequirementAnalysis.unexpectedRequirementKeys,
      },
    };
  }

  if (routeKeySourceAnalysis.invalidRouteKeySources.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_key_sources payload contains invalid source values for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_key_source_values: CANONICAL_ROUTE_KEY_SOURCE_VALUES,
        actual_route_key_sources_shape: routeKeySourceAnalysis.actualShape,
        invalid_route_key_sources: routeKeySourceAnalysis.invalidRouteKeySources,
      },
    };
  }

  if (routeKeySourceAnalysis.missingRouteKeySourceKeys.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason:
        routeKeySourceAnalysis.actualShape === "missing"
          ? `missing route_key_sources payload field for route family: ${routeFamily}`
          : `missing required route_key_sources entries for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_key_sources: expectedRouteKeySources,
        missing_route_key_source_keys: routeKeySourceAnalysis.missingRouteKeySourceKeys,
        actual_route_key_sources: routeKeySourceAnalysis.normalized,
      },
    };
  }

  if (routeKeySourceAnalysis.unexpectedRouteKeySourceKeys.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_key_sources payload contains non-canonical route key entries for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_key_sources: expectedRouteKeySources,
        unexpected_route_key_source_keys: routeKeySourceAnalysis.unexpectedRouteKeySourceKeys,
        actual_route_key_sources: routeKeySourceAnalysis.normalized,
      },
    };
  }

  const routeKeySourceMismatches = requiredRouteKeys
    .filter((key) => routeKeySourceAnalysis.normalized[key] !== expectedRouteKeySources[key])
    .map((key) => ({
      key,
      expected_source: expectedRouteKeySources[key],
      actual_source: routeKeySourceAnalysis.normalized[key],
    }));

  if (routeKeySourceMismatches.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_key_sources payload mismatch for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_key_sources: expectedRouteKeySources,
        source_mismatches: routeKeySourceMismatches,
        actual_route_key_sources: routeKeySourceAnalysis.normalized,
      },
    };
  }

  if (routeKeySourceKeyAnalysis.invalidRouteKeySourceKeys.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_key_source_keys payload contains invalid key values for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_value_shape: "array<non-empty string>",
        actual_value_shape: routeKeySourceKeyAnalysis.actualShape,
        invalid_route_key_source_keys: routeKeySourceKeyAnalysis.invalidRouteKeySourceKeys,
      },
    };
  }

  if (routeKeySourceKeyAnalysis.normalized.length === 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason:
        routeKeySourceKeyAnalysis.actualShape === "missing"
          ? `missing route_key_source_keys payload field for route family: ${routeFamily}`
          : `missing required route_key_source_keys entries for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_key_source_keys: requiredRouteKeys,
      },
    };
  }

  if (routeKeySourceKeyAnalysis.missingRouteKeySourceKeys.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `missing required route_key_source_keys entries for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_key_source_keys: requiredRouteKeys,
        missing_route_key_source_keys: routeKeySourceKeyAnalysis.missingRouteKeySourceKeys,
        actual_route_key_source_keys: routeKeySourceKeyAnalysis.normalized,
      },
    };
  }

  if (routeKeySourceKeyAnalysis.duplicateRouteKeySourceKeys.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_key_source_keys payload contains duplicate route keys for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        duplicate_route_key_source_keys: routeKeySourceKeyAnalysis.duplicateRouteKeySourceKeys,
        actual_route_key_source_keys: routeKeySourceKeyAnalysis.normalized,
      },
    };
  }

  if (routeKeySourceKeyAnalysis.unexpectedRouteKeySourceKeys.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_key_source_keys payload contains non-canonical route keys for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        allowed_route_key_source_keys: requiredRouteKeys,
        unexpected_route_key_source_keys: routeKeySourceKeyAnalysis.unexpectedRouteKeySourceKeys,
        actual_route_key_source_keys: routeKeySourceKeyAnalysis.normalized,
      },
    };
  }

  const expectedRouteKeySourceKeys = [...requiredRouteKeys];
  const actualRouteKeySourceKeys = [...routeKeySourceKeyAnalysis.normalized];

  const routeKeySourceKeysMatch =
    expectedRouteKeySourceKeys.length === actualRouteKeySourceKeys.length &&
    expectedRouteKeySourceKeys.every((expectedKey, index) => expectedKey === actualRouteKeySourceKeys[index]);

  if (!routeKeySourceKeysMatch) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_key_source_keys payload mismatch for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_key_source_keys: expectedRouteKeySourceKeys,
        actual_route_key_source_keys: actualRouteKeySourceKeys,
      },
    };
  }

  const routeKeySourceMapKeys = Object.keys(routeKeySourceAnalysis.normalized);
  const routeKeySourceKeyParity =
    routeKeySourceMapKeys.length === actualRouteKeySourceKeys.length &&
    routeKeySourceMapKeys.every((key, index) => key === actualRouteKeySourceKeys[index]);

  if (!routeKeySourceKeyParity) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_key_source_keys payload mismatch with route_key_sources entries for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        route_key_sources_keys: routeKeySourceMapKeys,
        route_key_source_keys: actualRouteKeySourceKeys,
      },
    };
  }

  const duplicateRouteKeys = duplicateStrings(declaredRouteKeys);

  if (duplicateRouteKeys.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_keys payload contains duplicate route keys for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        duplicate_route_keys: duplicateRouteKeys,
        actual_route_keys: declaredRouteKeys,
      },
    };
  }

  const unexpectedRouteKeys = declaredRouteKeys.filter((key) => !requiredRouteKeys.includes(key));

  if (unexpectedRouteKeys.length > 0) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_keys payload contains non-canonical route keys for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        allowed_route_keys: requiredRouteKeys,
        unexpected_route_keys: unexpectedRouteKeys,
        actual_route_keys: declaredRouteKeys,
      },
    };
  }

  const expectedRouteKeys = [...requiredRouteKeys];
  const actualRouteKeys = [...declaredRouteKeys];

  const routeKeysMatch =
    expectedRouteKeys.length === actualRouteKeys.length &&
    expectedRouteKeys.every((expectedKey, index) => expectedKey === actualRouteKeys[index]);

  if (!routeKeysMatch) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_keys payload mismatch for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        expected_route_keys: expectedRouteKeys,
        actual_route_keys: actualRouteKeys,
      },
    };
  }

  const sourceKeyRouteKeyParityAnalysis = analyzeRouteKeySourceKeyParityWithRouteKeys(
    actualRouteKeys,
    actualRouteKeySourceKeys,
  );

  if (!sourceKeyRouteKeyParityAnalysis.matches) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_route_keys",
      reason: `route_key_source_keys payload mismatch with route_keys payload for route family: ${routeFamily}`,
      details: {
        event_type: eventEnvelope.type,
        route_family: routeFamily,
        route_keys: actualRouteKeys,
        route_key_source_keys: actualRouteKeySourceKeys,
        source_key_parity_mismatches: sourceKeyRouteKeyParityAnalysis.mismatches,
      },
    };
  }

  return { ok: true };
};

const validateCloudEventEnvelope = (eventEnvelope) => {
  if (!eventEnvelope || typeof eventEnvelope !== "object" || Array.isArray(eventEnvelope)) {
    return { ok: false, errorCode: "transport.invalid_cloudevent_envelope", reason: "envelope must be an object" };
  }

  for (const field of REQUIRED_CLOUDEVENT_FIELDS) {
    if (!(field in eventEnvelope)) {
      return {
        ok: false,
        errorCode: "transport.invalid_cloudevent_envelope",
        reason: `missing required field: ${field}`,
      };
    }
  }

  for (const extension of REQUIRED_CLOUDEVENT_EXTENSIONS) {
    if (typeof eventEnvelope[extension] !== "string" || eventEnvelope[extension].trim() === "") {
      return {
        ok: false,
        errorCode: "transport.invalid_cloudevent_envelope",
        reason: `missing required extension: ${extension}`,
      };
    }
  }

  if (eventEnvelope.specversion !== "1.0") {
    return { ok: false, errorCode: "transport.invalid_cloudevent_envelope", reason: "specversion must equal 1.0" };
  }

  if (typeof eventEnvelope.data !== "object" || eventEnvelope.data === null || Array.isArray(eventEnvelope.data)) {
    return { ok: false, errorCode: "transport.invalid_cloudevent_envelope", reason: "data must be an object" };
  }

  if (!CANONICAL_WIDGET_EVENT_TYPES.includes(eventEnvelope.type)) {
    return {
      ok: false,
      errorCode: "transport.invalid_widget_event_type",
      reason: `unknown canonical widget event type: ${eventEnvelope.type}`,
    };
  }

  const payloadValidation = validateWidgetEventPayload(eventEnvelope);

  if (!payloadValidation.ok) {
    return payloadValidation;
  }

  const routeValidation = validateWidgetEventRouteKeys(eventEnvelope);

  if (!routeValidation.ok) {
    return routeValidation;
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
      const errorCode = envelopeValidation.errorCode || "transport.invalid_cloudevent_envelope";
      const errorDetails = envelopeValidation.details || {};

      sendRuntimeEvent(
        "runtime.event.error.v1",
        transportError(errorCode, {
          reason: envelopeValidation.reason,
          context: runtimeContext,
          ...errorDetails,
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
