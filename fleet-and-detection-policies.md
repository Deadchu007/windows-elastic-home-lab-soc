# Fleet collection policy and Elastic Security detection rules

## First: two different kinds of policy

This project uses two different configurations that are easy to confuse:

| Configuration | What it controls | Current lab state |
|---|---|---|
| **Fleet Agent policy** | Which integrations and data streams the enrolled Agent runs, where it sends data, and how Fleet manages it | The existing **Fleet Server Policy** is reused. Fleet Server, System, and Windows integrations are configured. Do not create a duplicate policy for this one host. |
| **Elastic Security detection rule** | A saved query and schedule that search ingested events and create alert records when documents match | Two custom rules are enabled: event 1102 and event 7045. Both have successful scheduled executions; alert matching is a separate verification. |

A Fleet policy is primarily for collection and management. A detection rule is for finding patterns in data already indexed. Detection rules do not change Windows settings, prevent an event, quarantine a file, or isolate the endpoint unless separately configured response capabilities exist. This lab has no confirmed EDR/Elastic Defend and no rule actions/connectors configured.

## Collection policy in this lab

The existing policy is attached to the local Fleet-managed Agent and contains:

- Fleet Server integration for management/control-plane functions.
- System integration for Windows Application, System, and Security event channels.
- Windows integration attached during setup; additional channels such as PowerShell, Defender, and Sysmon must be individually verified in Discover before being treated as telemetry sources.

Observed data streams include `system.security`, `system.application`, and `system.system`. The Agent sends event documents directly to Elasticsearch. Fleet Server is responsible for Agent check-ins and policy delivery; it is not a proxy for every log event.

## Detection-rule settings

Both current rules use:

- Rule type: **Custom query** (KQL).
- Data view/index pattern: `logs-*`.
- Schedule: every 5 minutes.
- Additional lookback: 1 minute. Together with the normal execution window this creates a small overlap to reduce misses from ingestion delays.
- Rule actions and response actions: none.

### Enabled rule 1 — Windows Security audit log cleared

```kql
event.dataset:"system.security" and event.code:"1102"
```

- Severity: High; risk score: 73.
- Purpose: surface an event that Windows records when the Security audit log is cleared.
- Current evidence: query accepted; scheduled execution reported **Succeeded** and created **0 alerts**. No matching 1102 event was found in the checked 24-hour range.
- Meaning: the rule engine successfully ran, but this is not a positive alert test. Do not clear the real Security log to manufacture one.

### Enabled rule 2 — Windows service installed

```kql
event.dataset:"system.system" and event.code:"7045"
```

- Severity: Medium; risk score: 47.
- Purpose: surface installation of a Windows service for analyst review. Services can provide persistence, but legitimate installers and updates create services too.
- Current evidence: one source event 7045 was visible in Discover at 2026-11-24 16:15:29.858; the rule is enabled and a scheduled execution reported **Succeeded**.
- Unknown: the evidence does not yet confirm that this event became a detection alert or that a manual historical run completed successfully.
- Correct alert location: **Security → Detections → Alerts**. The Observability → Alerts page is a different alerting area.

### Notion installation check

The query below returned no results over the checked last-24-hours range:

```kql
event.dataset:"system.application" and event.code:"11707"
```

Event 11707 is associated with successful Windows Installer (MSI) package installation. Some EXE, MSIX, and custom installers do not emit it. Its absence does not show that Notion failed to install. The 7045 rule looks for service installations and is not a universal software-install rule.

## Alert policy expectations

When a rule matches an event, Elastic Security creates an alert record. The analyst should then:

1. Confirm that the rule execution succeeded and that the alert belongs to the expected rule.
2. Open the source event and record the timestamp, host, event ID, initiating account, and available process/service details.
3. Correlate nearby events and compare the activity to a known software update or planned administrative action.
4. Classify the result using the evidence and the available Kibana workflow. Distinguish a true suspicious event from an accurately detected but authorized action.
5. Record tuning or follow-up. Do not suppress a rule simply because its first match is inconvenient.

No email, Slack, webhook, ticket, or endpoint response action is configured. The rule does not automatically respond. No confirmed alert has been documented for either rule yet.

## Candidate rules to add only after checking the data

See [detections/README.md](../detections/README.md) for exact queries and prerequisites. Candidates include local account creation (4720), local security-group membership change (4732), repeated failed logons (4625 threshold), audit policy changes (4719), and group-membership enumeration (4799). Event 4799 was previously observed and can be used for an investigation exercise; it is often generated by legitimate applications. Event 4672 was observed but is high volume and is currently hunt/context data only.
