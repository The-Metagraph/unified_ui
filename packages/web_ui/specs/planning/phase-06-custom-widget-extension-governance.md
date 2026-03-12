# Phase 6 - Custom Widget Extension Governance

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `WidgetRegistrationRequest`
- `WidgetDescriptor`
- `WebUi.WidgetRegistry`
- `TypedError`
- Extension Plane policy constraints

## Relevant Assumptions / Defaults
- Custom widget registration is supported but fail-closed by default.
- Built-in widget IDs are reserved and protected from override.
- Custom widget events must remain compatible with transport contracts.

[x] 6 Phase 6 - Custom Widget Extension Governance
  Implement custom-widget extension workflows with strict validation, policy guardrails, and deterministic registry behavior.

  [x] 6.1 Section - Custom Registration Admission Controls
    Implement registration request validation and deterministic acceptance/rejection behavior.

    [x] 6.1.1 Task - Implement custom widget ID policy enforcement
      Enforce custom ID format and reservation constraints for registry admission.

      [x] 6.1.1.1 Subtask - Implement `custom.<namespace>.<name>` ID-format validation.
      [x] 6.1.1.2 Subtask - Implement reserved built-in ID rejection.
      [x] 6.1.1.3 Subtask - Implement duplicate custom ID rejection with typed conflict errors.

    [x] 6.1.2 Task - Implement descriptor/schema validation for custom widgets
      Validate descriptor fields and schemas before runtime activation.

      [x] 6.1.2.1 Subtask - Implement required descriptor field checks for custom origin.
      [x] 6.1.2.2 Subtask - Implement props schema validation for declared state model.
      [x] 6.1.2.3 Subtask - Implement event schema validation against supported naming conventions.

  [x] 6.2 Section - Extension Capability and Isolation Rules
    Implement capability checks and runtime isolation boundaries for custom widget execution.

    [x] 6.2.1 Task - Implement capability declaration and validation
      Require explicit capability declarations and reject unsupported capability requests.

      [x] 6.2.1.1 Subtask - Implement baseline capability registry for extension permissions.
      [x] 6.2.1.2 Subtask - Implement unsupported-capability rejection with typed validation errors.
      [x] 6.2.1.3 Subtask - Implement capability version checks for forward compatibility.

    [x] 6.2.2 Task - Implement extension runtime isolation and safety constraints
      Prevent extension code from bypassing transport and runtime-authority boundaries.

      [x] 6.2.2.1 Subtask - Implement extension invocation through controlled registry dispatch only.
      [x] 6.2.2.2 Subtask - Implement policy checks blocking direct domain-state mutation attempts.
      [x] 6.2.2.3 Subtask - Implement isolation telemetry for denied extension actions.

  [x] 6.3 Section - Custom Event Interop and Lifecycle Telemetry
    Implement custom-widget event compatibility and required lifecycle event emissions.

    [x] 6.3.1 Task - Implement custom event naming and envelope compatibility
      Ensure custom widget events follow naming and envelope conventions.

      [x] 6.3.1.1 Subtask - Implement namespaced event naming checks for custom events.
      [x] 6.3.1.2 Subtask - Implement CloudEvent envelope compatibility checks for custom dispatch.
      [x] 6.3.1.3 Subtask - Implement route-key convention checks for custom standard-like events.

    [x] 6.3.2 Task - Implement registration and render lifecycle event emission
      Emit required lifecycle events for custom registration and render paths.

      [x] 6.3.2.1 Subtask - Implement `runtime.widget.registered.v1` emission on successful registration.
      [x] 6.3.2.2 Subtask - Implement `runtime.widget.registration_failed.v1` emission on denied registration.
      [x] 6.3.2.3 Subtask - Implement render success/failure lifecycle event emission for custom widgets.

  [x] 6.4 Section - Phase 6 Integration Tests
    Validate custom-widget governance behavior, denial paths, and lifecycle telemetry end-to-end.

    [x] 6.4.1 Task - Registration validation integration scenarios
      Verify custom registration requests pass/fail according to ID, schema, and capability policies.

      [x] 6.4.1.1 Subtask - Verify valid custom registrations are accepted and queryable.
      [x] 6.4.1.2 Subtask - Verify duplicate or reserved IDs fail with typed errors.
      [x] 6.4.1.3 Subtask - Verify invalid descriptor schemas fail closed before activation.

    [x] 6.4.2 Task - Extension safety and telemetry integration scenarios
      Verify extension behavior remains isolated and emits required lifecycle events.

      [x] 6.4.2.1 Subtask - Verify extension actions cannot bypass runtime authority boundaries.
      [x] 6.4.2.2 Subtask - Verify denied extension operations emit deterministic telemetry.
      [x] 6.4.2.3 Subtask - Verify registration and render lifecycle events are complete and correlation-safe.
