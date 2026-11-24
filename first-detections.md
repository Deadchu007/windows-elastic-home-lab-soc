# First Elastic Security detections

These are starter custom query rules for the existing Windows integration. They do not change Windows settings. Create them only after each query runs in Discover against the observed `logs-*` data view. A zero-result query can still be valid; it means the event has not occurred in the selected time range. Do not generate destructive events to force an alert.

## Validation note

On 2026-11-24, Discover accepted `event.dataset:"system.security" and event.code:"1102"` over the `All logs` data view with a 24-hour range and returned no matching events. This validates query syntax and confirms there is no matching event in that range; it does not test alert generation. Keep the rule enabled for future matching events and do not clear the real Windows Security log to manufacture a test.

The rule was created and enabled on 2026-11-24 as **Windows Security audit log cleared** with data view `logs-*`, severity High, risk score 73, 5-minute interval, and 1-minute additional lookback. Execution results showed **Succeeded**, 7.395 ms duration, 0 alerts created, and message `Rule executed successfully` at 2026-11-24 18:01:13.383. This confirms successful rule execution, not a positive alert test; no matching event or generated alert has been observed yet. The Gaps panel showed no items for the selected last-24-hours range.

## Collection and connectivity decision

The Fleet-managed Agent is already Healthy and Windows Security, Application, and System events have appeared in Discover. The connection is working. Keep the existing `Fleet Server Policy` and its Windows integration; do not make a duplicate policy or reinstall the Agent. Fleet policies control collection. Detection rules belong in Elastic Security.

## Rule 1: Windows Security audit log cleared

- Rule type: Custom query
- KQL: `event.dataset:"system.security" and event.code:"1102"`
- Data view / indices: `logs-*`
- Severity: High
- Risk score: 73
- Schedule: every 5 minutes; look back 6 minutes
- Actions: none for this local lab
- Purpose: alert when the Windows Security audit log is cleared.

## Rule 2: Local account created

- Rule type: Custom query
- KQL: `event.dataset:"system.security" and event.code:"4720"`
- Data view / indices: `logs-*`
- Severity: Medium
- Risk score: 47
- Schedule: every 5 minutes; look back 6 minutes
- Actions: none for this local lab
- Purpose: review unexpected local account creation.

## Rule 3: Account added to a local security group

- Rule type: Custom query
- KQL: `event.dataset:"system.security" and event.code:"4732"`
- Data view / indices: `logs-*`
- Severity: High
- Risk score: 73
- Schedule: every 5 minutes; look back 6 minutes
- Actions: none for this local lab
- Purpose: review unexpected membership changes to a local security-enabled group.

## Add the first rule in Kibana

1. In Discover, select the `logs-*` data view and run Rule 1's KQL over `Last 24 hours`. Confirm the query is accepted; note whether it returns any rows.
2. Open **Security → Alerts → Detection rules** (or use global search for “Detection rules”). Choose **Create rule → Custom query**.
3. Set the data view / index to `logs-*`, paste Rule 1's KQL, and enter its name, description, severity, and risk score above.
4. Set the schedule to 5 minutes with a 6-minute lookback. Leave notifications/actions empty.
5. Save and enable the rule. This changes only the Elastic lab configuration; it does not change Windows.
6. Confirm the rule is enabled and healthy. Record its name and status. Do not claim an alert test unless an alert was actually generated from a controlled, safe event.
7. Repeat for Rules 2 and 3 after confirming each query is accepted.

## Evidence to record

For each rule, record creation date, enabled/healthy state, query, lookback, and whether the query returned source events. Record alert test results separately. If there are no matching events, document “rule enabled; no matching event observed” rather than claiming the detection was tested.

Keep screenshots sanitized. Never publish API keys, enrollment/service tokens, usernames, raw security records, or private IP details.
