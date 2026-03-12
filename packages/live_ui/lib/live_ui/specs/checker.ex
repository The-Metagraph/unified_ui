defmodule LiveUi.Specs.Checker do
  @moduledoc """
  Repo-local governance/compliance checker for `live_ui` specs.
  """

  alias LiveUi.Specs.ComplianceReport
  alias LiveUi.Specs.Document
  alias LiveUi.Specs.Parser

  @governance_policy_id "policy.live_ui_governance"
  @conformance_policy_id "policy.live_ui_conformance"
  @required_policy_ids MapSet.new([@governance_policy_id, @conformance_policy_id])
  @primary_planes MapSet.new(["package", "integration", "execution", "rendering"])
  @verification_file_kinds MapSet.new(["doc", "test_file"])

  @type check :: %{
          required(:control_id) => String.t(),
          required(:status) => String.t(),
          optional(:reason) => String.t()
        }

  @type verification_check :: %{
          required(:target) => String.t(),
          required(:status) => String.t(),
          optional(:kind) => String.t(),
          optional(:covers) => [String.t()],
          optional(:reason) => String.t()
        }

  @spec check_repo(keyword()) :: ComplianceReport.t()
  def check_repo(opts \\ []) do
    documents = Parser.read_documents(Keyword.get(opts, :glob, ".spec/specs/**/*.spec.md"))
    check_documents(documents, opts)
  end

  @spec check_documents([Document.t()], keyword()) :: ComplianceReport.t()
  def check_documents(documents, opts \\ []) when is_list(documents) do
    root = Keyword.get(opts, :root, File.cwd!())
    today = Keyword.get(opts, :today, Date.utc_today())
    duplicates = duplicate_subject_ids(documents)

    %ComplianceReport{
      generated_at: DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601(),
      subjects: Enum.map(documents, &check_document(&1, documents, duplicates, root, today))
    }
  end

  @spec write_report(ComplianceReport.t(), String.t()) :: :ok
  def write_report(%ComplianceReport{} = report, path \\ default_report_path())
      when is_binary(path) do
    path
    |> Path.dirname()
    |> File.mkdir_p!()

    path
    |> File.write!(Jason.encode!(ComplianceReport.to_map(report), pretty: true))

    :ok
  end

  @spec default_report_path() :: String.t()
  def default_report_path do
    Path.join(["_build", "specled", "compliance-report.json"])
  end

  @spec summary(ComplianceReport.t()) :: %{
          pass: non_neg_integer(),
          warn: non_neg_integer(),
          fail: non_neg_integer()
        }
  def summary(%ComplianceReport{subjects: subjects}) do
    Enum.reduce(subjects, %{pass: 0, warn: 0, fail: 0}, fn %{status: status}, acc ->
      case status do
        "pass" -> Map.update!(acc, :pass, &(&1 + 1))
        "warn" -> Map.update!(acc, :warn, &(&1 + 1))
        "fail" -> Map.update!(acc, :fail, &(&1 + 1))
        _other -> acc
      end
    end)
  end

  defp check_document(%Document{} = document, documents, duplicate_subject_ids, root, today) do
    subject_id = document.meta["id"]
    requirements = requirement_ids(document)

    governance_checks =
      []
      |> maybe_append(duplicate_subject_check(subject_id, duplicate_subject_ids))
      |> maybe_append(governance_block_present_check(document))
      |> maybe_append(governance_owner_check(document))
      |> maybe_append(governance_criticality_check(document))
      |> maybe_append(primary_plane_check(document))
      |> maybe_append(approval_policy_check(document))
      |> maybe_append(gates_present_check(document))
      |> maybe_append(change_rules_present_check(document))
      |> maybe_append(governed_by_policy_check(document, documents))
      |> maybe_append(
        covers_integrity_check(document.scenarios, requirements, "scenario_covers_valid")
      )
      |> maybe_append(
        covers_integrity_check(document.verification, requirements, "verification_covers_valid")
      )
      |> maybe_append(
        covers_integrity_check(document.exceptions, requirements, "exception_covers_valid")
      )
      |> maybe_append(exception_approval_check(document))
      |> maybe_append(exception_expiry_check(document, today))

    verification_checks = Enum.map(document.verification, &verification_check(&1, root))
    findings = findings_for(governance_checks, verification_checks)

    %{
      subject_id: subject_id,
      status: status_for(governance_checks, verification_checks),
      governance_checks: governance_checks,
      verification_checks: verification_checks,
      exceptions_applied: active_exception_ids(document, today),
      findings: findings
    }
  end

  defp duplicate_subject_ids(documents) do
    documents
    |> Enum.group_by(& &1.meta["id"])
    |> Enum.filter(fn {_id, grouped} -> length(grouped) > 1 end)
    |> Enum.map(&elem(&1, 0))
    |> MapSet.new()
  end

  defp duplicate_subject_check(subject_id, duplicates) do
    if MapSet.member?(duplicates, subject_id) do
      fail("subject_id_unique", "duplicate subject id #{subject_id}")
    else
      pass("subject_id_unique")
    end
  end

  defp governance_block_present_check(%Document{governance: nil}) do
    fail("governance_block_present", "missing spec-governance block")
  end

  defp governance_block_present_check(_document), do: pass("governance_block_present")

  defp governance_owner_check(%Document{governance: governance}) do
    required_string_check(governance, "owner", "governance_owner_present")
  end

  defp governance_criticality_check(%Document{governance: governance}) do
    required_string_check(governance, "criticality", "governance_criticality_present")
  end

  defp primary_plane_check(%Document{governance: governance}) do
    with %{"primary_plane" => plane} <- governance,
         true <- is_binary(plane) and plane != "" do
      if MapSet.member?(@primary_planes, plane) do
        pass("primary_plane_valid")
      else
        fail(
          "primary_plane_valid",
          "primary_plane #{inspect(plane)} is not one of #{Enum.join(MapSet.to_list(@primary_planes), ", ")}"
        )
      end
    else
      _ -> fail("primary_plane_valid", "missing governance.primary_plane")
    end
  end

  defp approval_policy_check(%Document{governance: governance}) do
    approval = governance && governance["approval"]

    cond do
      not is_map(approval) ->
        fail("approval_policy_present", "missing governance.approval map")

      not is_boolean(approval["required"]) ->
        fail("approval_policy_present", "governance.approval.required must be boolean")

      approval["required"] and not non_empty_list_of_strings?(approval["roles"]) ->
        fail(
          "approval_policy_present",
          "governance.approval.roles must list one or more approver roles"
        )

      true ->
        pass("approval_policy_present")
    end
  end

  defp gates_present_check(%Document{governance: governance}) do
    gates = governance && governance["gates"]

    cond do
      not is_list(gates) or gates == [] ->
        fail("governance_gates_present", "governance.gates must include at least one gate")

      Enum.any?(gates, fn gate ->
        not is_binary(gate["id"]) or gate["id"] == "" or not is_binary(gate["kind"]) or
            gate["kind"] == ""
      end) ->
        fail(
          "governance_gates_present",
          "each governance gate must include non-empty id and kind"
        )

      true ->
        pass("governance_gates_present")
    end
  end

  defp change_rules_present_check(%Document{governance: governance}) do
    rules = governance && governance["change_rules"]

    cond do
      not is_list(rules) or rules == [] ->
        fail("change_rules_present", "governance.change_rules must include at least one rule")

      Enum.any?(rules, fn rule ->
        not is_binary(rule["id"]) or rule["id"] == "" or not is_map(rule["when"]) or
          not is_list(rule["requires"]) or rule["requires"] == []
      end) ->
        fail(
          "change_rules_present",
          "each governance change rule must include id, when, and non-empty requires"
        )

      true ->
        pass("change_rules_present")
    end
  end

  defp governed_by_policy_check(%Document{} = document, documents) do
    if document.meta["kind"] == "policy" do
      pass("governed_by_policies")
    else
      present_relationships =
        document.meta
        |> Map.get("relationships", [])
        |> Enum.filter(&(&1["kind"] == "governed_by"))
        |> Enum.map(& &1["target"])
        |> MapSet.new()

      defined_policies =
        documents
        |> Enum.filter(&(&1.meta["kind"] == "policy"))
        |> Enum.map(& &1.meta["id"])
        |> MapSet.new()

      cond do
        not MapSet.subset?(@required_policy_ids, defined_policies) ->
          fail("governed_by_policies", "required local policy subjects are missing")

        not MapSet.subset?(@required_policy_ids, present_relationships) ->
          fail(
            "governed_by_policies",
            "subject must declare governed_by relationships to #{Enum.join(MapSet.to_list(@required_policy_ids), ", ")}"
          )

        true ->
          pass("governed_by_policies")
      end
    end
  end

  defp covers_integrity_check(entries, requirement_ids, control_id) do
    invalid_ids =
      entries
      |> Enum.flat_map(&Map.get(&1, "covers", []))
      |> Enum.reject(&MapSet.member?(requirement_ids, &1))
      |> Enum.uniq()

    if invalid_ids == [] do
      pass(control_id)
    else
      fail(control_id, "unknown requirement references: #{Enum.join(invalid_ids, ", ")}")
    end
  end

  defp exception_approval_check(%Document{exceptions: exceptions}) do
    invalid =
      Enum.any?(exceptions, fn exception ->
        waiver_exception?(exception) and blank?(exception["approval_ref"])
      end)

    if invalid do
      fail("exception_approval_refs_present", "waiver-style exceptions must include approval_ref")
    else
      pass("exception_approval_refs_present")
    end
  end

  defp exception_expiry_check(%Document{exceptions: exceptions}, today) do
    expired_ids =
      Enum.flat_map(exceptions, fn exception ->
        case exception["expires_on"] do
          expires_on when is_binary(expires_on) ->
            case Date.from_iso8601(expires_on) do
              {:ok, date} ->
                if Date.compare(date, today) == :lt, do: [exception["id"]], else: []

              _ ->
                []
            end

          _ ->
            []
        end
      end)

    if expired_ids == [] do
      pass("exception_not_expired")
    else
      fail("exception_not_expired", "expired exceptions: #{Enum.join(expired_ids, ", ")}")
    end
  end

  defp verification_check(entry, root) do
    target = entry["target"]
    kind = entry["kind"]
    covers = entry["covers"] || []

    cond do
      not is_binary(target) or target == "" ->
        %{
          target: inspect(target),
          kind: to_string(kind),
          status: "fail",
          covers: covers,
          reason: "verification target must be a non-empty string"
        }

      MapSet.member?(@verification_file_kinds, kind) and File.exists?(Path.expand(target, root)) ->
        %{target: target, kind: kind, status: "pass", covers: covers}

      MapSet.member?(@verification_file_kinds, kind) ->
        %{
          target: target,
          kind: kind,
          status: "warn",
          covers: covers,
          reason: "verification target does not exist"
        }

      kind == "command" ->
        %{target: target, kind: kind, status: "pass", covers: covers}

      true ->
        %{
          target: target,
          kind: to_string(kind),
          status: "warn",
          covers: covers,
          reason: "unknown verification kind"
        }
    end
  end

  defp active_exception_ids(%Document{exceptions: exceptions}, today) do
    Enum.flat_map(exceptions, fn exception ->
      case exception["expires_on"] do
        expires_on when is_binary(expires_on) ->
          case Date.from_iso8601(expires_on) do
            {:ok, date} ->
              if Date.compare(date, today) in [:gt, :eq], do: [exception["id"]], else: []

            _ ->
              []
          end

        _ ->
          if is_binary(exception["id"]) and exception["id"] != "", do: [exception["id"]], else: []
      end
    end)
  end

  defp status_for(governance_checks, verification_checks) do
    statuses = Enum.map(governance_checks ++ verification_checks, & &1.status)

    cond do
      "fail" in statuses -> "fail"
      "warn" in statuses -> "warn"
      true -> "pass"
    end
  end

  defp findings_for(governance_checks, verification_checks) do
    governance_findings =
      Enum.flat_map(governance_checks, fn check ->
        case check.status do
          "pass" ->
            []

          "warn" ->
            [%{id: "finding.#{check.control_id}", severity: "warning", message: check.reason}]

          "fail" ->
            [%{id: "finding.#{check.control_id}", severity: "error", message: check.reason}]
        end
      end)

    verification_findings =
      Enum.flat_map(verification_checks, fn check ->
        case check.status do
          "pass" ->
            []

          "warn" ->
            [
              %{
                id: "finding.verification.#{verification_finding_id(check)}",
                severity: "warning",
                message: check.reason
              }
            ]

          "fail" ->
            [
              %{
                id: "finding.verification.#{verification_finding_id(check)}",
                severity: "error",
                message: check.reason
              }
            ]
        end
      end)

    governance_findings ++ verification_findings
  end

  defp verification_finding_id(check) do
    check.target
    |> String.replace(~r/[^a-zA-Z0-9]+/u, "_")
    |> String.trim("_")
    |> String.downcase()
  end

  defp requirement_ids(%Document{requirements: requirements}) do
    requirements
    |> Enum.map(& &1["id"])
    |> MapSet.new()
  end

  defp required_string_check(map, field, control_id) when is_map(map) do
    case map[field] do
      value when is_binary(value) and value != "" -> pass(control_id)
      _ -> fail(control_id, "missing governance.#{field}")
    end
  end

  defp required_string_check(_map, field, control_id),
    do: fail(control_id, "missing governance.#{field}")

  defp non_empty_list_of_strings?(value) when is_list(value) do
    value != [] and Enum.all?(value, &(is_binary(&1) and &1 != ""))
  end

  defp non_empty_list_of_strings?(_value), do: false

  defp blank?(value), do: not (is_binary(value) and value != "")

  defp waiver_exception?(exception) do
    non_empty_list?(exception["covers"]) or is_binary(exception["expires_on"])
  end

  defp non_empty_list?(value) when is_list(value), do: value != []
  defp non_empty_list?(_value), do: false

  defp maybe_append(checks, nil), do: checks
  defp maybe_append(checks, check), do: checks ++ [check]

  defp pass(control_id), do: %{control_id: control_id, status: "pass"}
  defp fail(control_id, reason), do: %{control_id: control_id, status: "fail", reason: reason}
end
