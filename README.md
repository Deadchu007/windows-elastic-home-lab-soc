# Detection catalog

These queries are examples for Elastic Security custom-query rules using KQL and the `logs-*` data view. Confirm that the source integration emits the required dataset and fields before enabling a rule. A query that saves or executes successfully is not necessarily a tested detection.

## Implemented rules

| Rule | KQL | Severity / risk | State and validation |
|---|---|---|---|
| Windows Security audit log cleared | `event.dataset:"system.security" and event.code:"1102"` | High / 73 | Enabled; scheduled execution succeeded; zero alerts in checked range; no positive test |
| Windows service installed | `event.dataset:"system.system" and event.code:"7045"` | Medium / 47 | Enabled; scheduled execution succeeded; one source event seen in Discover; corresponding Security alert not confirmed |

Query files: [1102](windows-security-audit-log-cleared-1102.kql) and [7045](windows-service-installed-7045.kql).

## Candidate detections

| Behavior | Event/query starting point | Why useful | Caveat / prerequisite | State |
|---|---|---|---|---|
| Local user created | `event.dataset:"system.security" and event.code:"4720"` | Review unexpected account creation | Verify event fields and expected admin activity | Candidate; not enabled |
| Security group membership changed | `event.dataset:"system.security" and event.code:"4732"` | Review additions to local security-enabled groups | Scope to meaningful groups and expected administrators; verify data first | Candidate; not enabled |
| Repeated failed logons | `event.dataset:"system.security" and event.code:"4625"` | Brute-force or password-spray investigation | Prefer a threshold rule grouped by account/source over one alert per failure; source address may be absent | Candidate; threshold not implemented |
| Audit policy changed | `event.dataset:"system.security" and event.code:"4719"` | Detect changes that weaken audit visibility | Authorized policy changes can be normal; verify fields | Candidate; not enabled |
| Local group membership enumerated | `event.dataset:"system.security" and event.code:"4799"` | Investigate discovery behavior | Can be routine application activity; inspect caller/context; one event was observed historically | Hunt/triage candidate only |
| MSI installation success | `event.dataset:"system.application" and event.code:"11707"` | Identify installs logged by Windows Installer | Does not cover all EXE/MSIX/custom installers; tested query had no results in selected 24h | Not enabled |
| Privileged logon | `event.dataset:"system.security" and event.code:"4672"` | Add context to privileged sessions | Often high volume and not suspicious alone; do not alert on every event by default | Hunt/context only |

## Validation checklist before marking a rule complete

1. Confirm the relevant event is present in Discover for a known time range.
2. Confirm the exact field names and values from the event document.
3. Create or update the rule with an appropriate schedule and severity.
4. Review execution results for a successful query.
5. Confirm a match appears in **Security → Detections → Alerts**. If using historical data, use the supported manual/historical run feature and verify its time coverage.
6. Investigate the source event and record a disposition. Distinguish benign-but-correct detection from a false positive.
7. Document exclusions and their rationale; do not suppress broad behavior without evidence.
