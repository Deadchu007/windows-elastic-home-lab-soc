# Alert investigation runbook

## Four states that must not be confused

1. **Source event exists:** Discover can find the underlying Windows event.
2. **Rule execution succeeded:** the scheduler queried the configured data view without an execution error.
3. **Rule matched:** one or more source events met the rule query and time window.
4. **Alert exists and was triaged:** an alert record is visible in Security and an analyst records a disposition.

A successful execution with zero alerts is useful health evidence, but it is not proof that the detection has generated an alert. An event in Discover alone also does not prove the detection engine produced an alert.

## Where to look

Use **Security → Detections → Alerts** for SIEM rule alerts. The separate **Observability → Alerts** page is for Observability alerting rules and may show no SIEM alert even when a Security alert exists.

For rule status and query execution, use **Security → Rules → Detection rules (SIEM)**, open the rule, and review **Execution results**. For source events, use Discover with the `logs-*` data view and a suitable time range.

## Triage procedure

1. Set the time picker to include the event timestamp plus a few minutes on either side. Expand to 24 hours or the full available range if needed.
2. Open the alert in Security → Detections → Alerts. Record rule name, alert timestamp, host, event code, user/account, and available service/process fields. Do not paste raw personal logs into a public repo.
3. Open or find the original source event in Discover. Confirm `event.dataset`, `event.code`, `event.action`, `@timestamp`, `event.created`, `host.name`, and `user.name` if present.
4. Check nearby events and host activity. For a service installation, inspect service name, image path, service account, start type, installer/update context, and who was logged on. Missing fields are unknown, not evidence of innocence.
5. Ask whether the action was expected: software install/update, user-initiated setup, or known maintenance. Use available records and user confirmation; do not assume.
6. Choose the disposition the Kibana workflow supports and document a short evidence-based rationale. If activity was authorized, call it **benign positive / authorized activity**. Reserve **false positive** for a rule match that does not represent the behavior the rule intends to detect, such as bad event mapping or overly broad query logic.
7. If suspicious, preserve the relevant evidence and describe safe next investigation steps. This home lab has no confirmed endpoint response integration; the rule will not stop or isolate anything.
8. Tune only after understanding the match. Prefer narrow exceptions with a documented owner and reason over disabling the whole rule.

## Current rule-specific checklists

### Windows service installed (7045)

Query: `event.dataset:"system.system" and event.code:"7045"`.

Check service name/display name, binary path, account, start mode, timestamp, installer or update activity, and nearby Security/System events. A service can be legitimate or can provide persistence; the event alone does not establish maliciousness. One 7045 source event was seen in Discover, but a corresponding Security alert has not yet been confirmed.

### Windows Security audit log cleared (1102)

Query: `event.dataset:"system.security" and event.code:"1102"`.

Check account, host, timestamp, surrounding logon and administrative activity, and whether maintenance was authorized. Clearing the actual Security log to test this alert is not recommended. Current proof is a successful scheduled query with zero alerts in the checked range.

## Record template

```text
Case/alert:
Rule and severity:
First seen (local time and UTC if available):
Host (use sanitized lab alias in public artifacts):
Source event code/dataset:
Observed facts:
Context checked:
Disposition and evidence-based reason:
Follow-up or tuning:
Analyst/date:
```

## Evidence status today

- 1102: rule execution succeeded; zero alerts; no matching event found in the checked 24-hour range.
- 7045: rule enabled and scheduled execution succeeded; a source 7045 event was seen; matching Security alert and disposition remain unverified.
- Therefore, this project has demonstrated ingestion and scheduled rule execution. It has not yet demonstrated an end-to-end positive detection and triage for these two rules.
