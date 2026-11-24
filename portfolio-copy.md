# Portfolio copy — draft, publish only after validation

## Resume bullet (current, accurate foundation)

Built a self-managed Elastic 9.5.6 home-lab SIEM on Windows 11 Pro; configured Fleet Server and a Fleet-managed Elastic Agent, verified Security, Application, and System event ingestion, and created two custom detections with successful scheduled executions. Alert generation and triage validation are in progress.

## Resume bullet (only after completing the remaining work)

Built and validated a Windows home-lab SOC with Elastic, including Fleet-managed telemetry, a Windows event dashboard, tuned prebuilt/custom detections mapped to MITRE ATT&CK, controlled alert tests, and a documented endpoint assessment/remediation record.

## LinkedIn post draft — current state

I’m building a self-hosted Elastic SOC lab to practice Windows telemetry, detection engineering, and alert investigation. Fleet Server and a Fleet-managed Elastic Agent are running, and Security, Application, and System events are visible in Discover. I’ve created two custom detections and confirmed that their scheduled queries execute successfully; I’m now validating alert generation against historical events. This is a single-host, log-based lab—not EDR or a vulnerability scanner—so I’m documenting those boundaries and keeping my Windows settings unchanged.

## Interview explanation

**Why this project?** I wanted hands-on practice with the full SOC workflow: telemetry, detection, investigation, remediation, and evidence.

**What does the architecture do?** Fleet Server distributes policy and handles Agent control check-ins. Elastic Agent collects the Windows sources and sends events to Elasticsearch. Kibana is where I query events, review alerts, and present dashboards.

**Does the current data prove the PC has no vulnerabilities?** No. It proves selected event sources are ingesting. Vulnerability and configuration exposure require a separate assessment, evidence, and retesting after remediation.

**What is the main limitation?** It is a single-host, single-node learning lab with no redundancy or confirmed EDR. Scheduled rule execution is verified, but alert generation and triage are still in progress. It is not a production SOC or a vulnerability assessment.
