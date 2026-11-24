# GitHub publishing guide

## Suggested repository

Suggested name: `windows-elastic-home-lab-soc`.

Suggested description: “A single-host Windows home lab for Elastic log collection, KQL detections, and SOC alert-triage practice.”

## Before publishing

1. Read the root README and current status page as if you were a reviewer unfamiliar with the lab.
2. Keep documentation and rule queries; do not commit raw Windows event exports, Elasticsearch data directories, Kibana saved-object exports containing local details, screenshots with browser/session data, or generated logs.
3. Search the whole folder for passwords, API keys, service/enrollment tokens, usernames, private paths, public IPs, LAN IPs, and host IDs. Remove or replace them with a generic lab alias.
4. Check screenshots at full size. Crop browser tabs, profile icons, local addresses, and personal notifications where appropriate.
5. Verify every diagram renders on GitHub and every relative link works.
6. State statuses as **verified**, **in progress**, **planned**, or **unknown**. Do not turn a successful rule run into a claim that an alert fired.

## Publish with GitHub Desktop

1. Create a new repository on GitHub named `windows-elastic-home-lab-soc`. Choose public only if the sanitized content is ready for anyone to see; otherwise keep it private while reviewing.
2. In GitHub Desktop, use **Add an Existing Repository** and select the `windows-soc-home-lab` folder. If it is not already a Git repository, use **Create a New Repository** and choose this folder.
3. Review the changed-files list. Ensure it contains documentation and safe query examples only; exclude local logs, secrets, and machine-specific exports.
4. Commit with a descriptive message such as `Document Elastic Windows SOC home lab and detections`.
5. Publish the repository and open its GitHub page. Verify README rendering, Mermaid diagrams, links, and visibility.
6. Add the public URL to a resume only after this review. Do not imply enterprise production deployment.

## Suggested repository sections

- README: what it is, architecture, status, and how to navigate.
- `docs/`: architecture, policy distinction, triage runbook, baseline, roadmap, and analyst walkthrough.
- `detections/`: query files and a catalog with prerequisites and validation status.
- `scripts/`: only reviewed, read-only scripts with clear requirements. Do not include commands that change host settings.
- `screenshots/`: optional, sanitized screenshots of Discover, rule configuration, and Security alert details.

## LinkedIn wording

Share a progress update only after the repository is live and reviewed. Say “built a single-host Elastic SIEM lab; verified three Windows event datasets and scheduled two custom rules” and disclose that positive alert validation is still in progress if it remains so. Avoid “detected an attack” unless the alert and investigation evidence support it.
