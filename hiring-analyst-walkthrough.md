# Hiring analyst walkthrough

## 60-second project summary

“I built a single-host Windows home-lab SOC with Elasticsearch, Kibana, Fleet Server, and a Fleet-managed Elastic Agent. I verified Windows Security, Application, and System events in Discover, then created two scheduled KQL detections: Security audit log cleared (1102) and Windows service installed (7045). Both rules have successful scheduled executions. I distinguish that from a confirmed alert: the 1102 query had no match in the checked period, and I have not yet verified the 7045 source event as a Security alert. I documented a read-only Windows baseline and the lab’s limits. It is a log-based detection lab, not EDR or a completed vulnerability-management program.”

## Architecture explanation

- Windows emits events to configured channels.
- Elastic Agent reads the channels and sends event documents to Elasticsearch.
- Fleet Server checks in with the Agent and supplies management policy; it is not the event data route.
- Kibana provides Discover for source-event validation and Elastic Security for scheduled rules and alert investigation.
- A rule match creates an alert for analyst review. In this lab, rules have no notification or response actions, and no confirmed endpoint response capability is installed.

See [architecture.md](architecture.md) for diagrams and [fleet-and-detection-policies.md](fleet-and-detection-policies.md) for the policy distinction.

## Interview questions to prepare for

### What did you actually detect?

Two rules are enabled: Windows Security audit log cleared (1102) and Windows service installed (7045). Rule executions succeeded. A 7045 source event appeared in Discover, but its matching detection alert has not yet been confirmed. The 1102 rule created zero alerts in the checked range. I would present this as a working detection configuration with end-to-end alert validation still in progress.

### Why use a service-install rule?

Windows services can be a persistence mechanism, and Event 7045 is a useful review signal. Legitimate software also installs services, so the event is not inherently malicious. The analyst validates service binary path, account, timing, and software/update context.

### Why did installing Notion not trigger an alert?

The tested query looked for Windows Installer success event 11707, but it returned no documents in the selected 24-hour range. Notion may use another installer path or event source. The service rule 7045 detects services, not every software installation. An absent event is not proof that the software did not install.

### What does a successful rule execution mean?

The scheduled query ran without an execution error. It does not mean that the query matched an event. I separately verify source event, rule match, alert record, and analyst disposition.

### Does this protect or remediate the computer?

No. It collects and searches logs. There are no confirmed endpoint response actions, no confirmed Elastic Defend deployment, and no automated blocking. The baseline is observational; I intentionally left personal Windows settings unchanged.

### Is this vulnerability management?

Not yet. The lab has documented some security configuration observations, including BitLocker being off and TPM not reported present/ready, but no CVE scan, risk-based findings workflow, or remediation was run. Those observations are not themselves vulnerability scan results, and I made no configuration changes.

### What would you improve next?

Verify a 7045 alert end to end, document its disposition, add a dashboard from verified fields, then add rules only when telemetry prerequisites are confirmed. Later, expand safely to a second endpoint and a dedicated vulnerability scanner if system capacity allows.

## Claims to avoid

- “I caught malware” or “the rule fired” without a visible alert and investigation record.
- “I deployed EDR,” “isolated the host,” or “blocked an attack.”
- “I scanned and remediated vulnerabilities.”
- “Notion installation was detected.”
- “All Windows logs are collected.” Only the three named datasets are verified here.
