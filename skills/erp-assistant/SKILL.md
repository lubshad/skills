---
name: erp-assistant
description: Use when inspecting, analyzing, reporting on, or making explicitly requested live CoreAxis ERP changes through MCP.
---

# ERP Assistant

For live operations on accessible records at `erp.coreaxissolutions.in`, not application implementation/deployment. Project/task work also reads `project-manager.md`.

## Authority and tools

Plan/read-only agents inspect/propose only. Write-capable agents may execute explicit scoped requests; analysis stays read-only and switching modes alone authorizes nothing. A clear create/update request needs no special phrase, skill exit, or repeated approval because Plan was used earlier. Confirm destructive/high-impact targets and consequences; resolve ambiguous scope/required inputs.

Skills are instructions, not tool sandboxes. For ERP work, use supported MCP only: no local code/shell, unrelated browsing, delegation, server Python, arbitrary scripts, or direct DB-write fallback. Check ERP MCP availability **before queries or asking record/type questions**; if missing, explain enable/connect and stop, without assuming restart. Use `question` for missing input/DocType/record selection; if unavailable, explain and stop rather than guess or substitute numbered chat menus.

Inspect tool side effects; supported search/metadata/documents/analysis/report/approval/dashboard tools retain permission limits. Analytical queries must be read-only; arbitrary SQL is not a report/dashboard builder. Permission failures do not authorize broader access or alternate-tool bypasses.

## Resolve and analyze

Do not guess DocTypes, fields, required values, child schemas, options, links, naming, submission, or workflows. Search unclear types; inspect metadata; resolve canonical IDs with link/document search. Ambiguous matches use concise identifying choices.

Start narrowly and paginate enough for conclusions. Fetch only needed fields; never expose returned secrets/session values or unnecessary personal data. Label ERP facts, calculations, assumptions, inferences, and recommendations; state material filters/date/company/currency/timezone boundaries.

Proposals identify DocType/IDs, current→proposed values, validation, dependencies, and side effects, clearly unapplied. Report/dashboard/chart plans validate source schemas/reports/filters/roles/chart sources and explain visibility. Publishing/sharing artifacts follows the same write authorization as records.

## Execute and verify

1. Check write permission/request scope; validate metadata, targets, links, values, and transitions.
2. Read existing records, preserve unrequested fields, clarify material conflicts since the plan; check duplicates before creation.
3. Use documented mutations and normal validation. Unsupported operations stop without code/SQL fallback.
4. Resolve batch dependencies; track per-item results and stop dependents after prerequisite failure. Neither atomicity nor compensating rollback is implied.
5. After timeout/uncertainty, inspect state before retrying non-idempotent creates/submissions.
6. Read back authoritative persisted results. Report verified IDs/changes, failures, skips, and uncertainty separately; sent requests are not success.

## Verification

Check connection, mode/scope, metadata/IDs, pagination, privacy, resolved ambiguity, and labeled facts/proposals. Report tool failures/incomplete coverage and last verified state; no broader filters, forced operations, or privilege escalation to succeed. Plan/report-only work changes no ERP state. Lead with decisions/risks/required actions and claim saves only with persisted evidence.
