# Detection engineering plan

## Local Windows rule menu

Scope is the existing Fleet-managed Elastic Agent collecting Windows Security, Application, and System event logs. This lab has no Elastic Defend/EDR, Sysmon, or central identity source. A detection rule searches recorded events and creates an alert; it does not block activity, inspect a full process tree, or prove a host is vulnerability-free. Do not change Windows audit/security settings for these rules.

| Priority | Candidate / event | Example KQL or configuration | Purpose and expected alert | Noise / limitation | Status |
|---|---|---|---|---|---|
| 1 | Security audit log cleared (1102) | `event.dataset:"system.security" and event.code:"1102"` | Flag Security log clearing for investigation. | Rare; do not clear the real log to test. | Created/enabled; scheduled execution succeeded with 0 alerts; no matching event observed. |
| 2 | Local group membership enumerated (4799) | `event.dataset:"system.security" and event.code:"4799"` | Surface group enumeration that may be reconnaissance; inspect event user, process/application fields if present, and surrounding events. | Often legitimate software or OS activity; the event alone is not malicious. A 4799 event was seen in prior Discover results. | Candidate for next manual historical run and triage. |
| 3 | Local account created (4720) | `event.dataset:"system.security" and event.code:"4720"` | Identify account creation and review who created it and whether it was expected. | Expected user/admin actions can match; event occurs only when Windows logs it. | Candidate; verify query in Discover first. |
| 4 | Added to local security group (4732) | `event.dataset:"system.security" and event.code:"4732"` | Flag local group membership changes, especially unexpected administrator-group additions. | Legitimate software/admin setup can match. Review target group and member fields. | Candidate; verify query in Discover first. |
| 5 | Repeated failed logons (4625) | Threshold rule: query `event.dataset:"system.security" and event.code:"4625"`; alert at 5+ events in 10 minutes, grouped by `host.name` and `user.name` if those fields are populated. | Surface password guessing or repeated authentication failures. | Mistyped passwords can match; grouping fields must exist. Do not create failed logons to test. | Candidate; check field availability and event counts first. |
| 6 | System audit policy changed (4719) | `event.dataset:"system.security" and event.code:"4719"` | Flag a change to audit policy that could reduce visibility. | Legitimate administration can match; inspect change details and nearby events. | Candidate; verify data availability. |
| 7 | New Windows service installed (7045) | `event.dataset:"system.system" and event.code:"7045"` | Surface service installation that may represent persistence or legitimate software installation. | Installers and updates routinely add services; inspect service name, image path, account, and timing. | Created/enabled; latest rule response shows Succeeded. Alert/manual-run result not yet verified. |
| 8 | Successful Windows Installer package install (11707) | `event.dataset:"system.application" and event.code:"11707"` | Identify successful installations logged by Windows Installer (MSI); review product and time. | Does not cover every EXE/MSIX/custom installer; Notion may not emit this event depending on installer type. | No matching event in the last 24 hours in the supplied Discover screenshot; do not create this rule to detect the Notion install. |
| 9 | Special privileges assigned (4672) | `event.dataset:"system.security" and event.code:"4672"` | Use for investigation context around privileged logons. | Microsoft documents this event as very high volume; routine SYSTEM and administrator logons make a simple alert noisy. Prefer a Discover hunt or tune against known expected accounts. | Observed in Discover; hunt/context only for now. |
| Later | Defender detection/action (1116/1117) | Only after `windows.windows_defender` contains relevant Defender Operational events. | Surface a Defender malware detection and the subsequent remediation/action event. | Current data presence has not been verified; this is Windows Defender telemetry, not Elastic Defend EDR. | Not ready; data source unverified. |

The initial custom rules (1102 and 7045) are created and enabled; Kibana has shown successful scheduled executions for both. Alert creation and analyst disposition remain unverified. Build the next rule from observed 4799 telemetry if desired; add 4720, 4732, 4625, and 4719 only after confirming matching source events and fields in Discover. Use a threshold rule for counts over time. The System integration collects Security/Application/System channels; additional Windows-specific channels such as PowerShell and Defender must be verified in Discover before relying on them.

Do not claim that a rule is alert-tested merely because the query was accepted or an execution succeeded. Record query execution, event match, alert generation, and analyst disposition as separate validation stages. Prefer prebuilt rules only when their data prerequisites match this lab.

## Custom rule worksheet

For each custom rule, record:

- Name and problem it addresses
- KQL/EQL query and required fields
- Data source and time window
- Severity, risk score, and MITRE ATT&CK mapping
- Benign validation procedure and expected result
- False positives observed and tuning/exception rationale
- Rule execution status and last validated date

Do not mark a rule complete until it executes successfully and a controlled test proves the expected behavior. Avoid destructive tests on the daily-use PC.

## Alert triage workflow

1. Check the host, user, process, timestamp, event IDs, and surrounding events.
2. Determine whether the activity was expected, suspicious, or inconclusive.
3. Preserve the relevant event IDs/timestamps and sanitized evidence.
4. If suspicious, take a safe containment/remediation action appropriate to the finding, then verify the outcome.
5. Record disposition, action, and follow-up. Do not publish personal event details.
