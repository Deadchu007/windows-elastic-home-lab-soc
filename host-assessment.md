# Host security assessment plan

## Important distinction

Elastic event ingestion helps investigate behavior. It does not by itself enumerate every missing patch, vulnerable application, exposed service, or insecure setting. Record vulnerability/configuration findings separately and cite the evidence used to identify each one.

## Read-only baseline to collect

Record date/time and Windows build, then assess:

- Windows Update status and age of the latest security update
- Microsoft Defender service, real-time protection, and signature freshness
- Windows Firewall status for Domain, Private, and Public profiles
- Remote Desktop exposure and whether it is needed
- Local Administrators membership and unused accounts
- Listening services/ports and whether each is needed on the LAN
- BitLocker status on the system volume
- Installed applications with known outdated versions
- Startup and scheduled-task entries that are unfamiliar
- Hosts-file contents and modification history, using read-only inspection only

Do not turn an unverified observation into a vulnerability claim. For each confirmed gap, include severity, evidence, business/lab impact, and a proposed fix/retest plan. This project does not authorize changes to the user's personal Windows settings; remediation remains a documented recommendation unless the user separately asks for a specific change.

## Finding register

| ID | Finding | Evidence | Severity | Remediation | Retest | Status |
|---|---|---|---|---|---|---|
| B-01 | Windows Firewall enabled on Domain, Private, and Public profiles; inbound blocked and outbound allowed | `netsh advfirewall show allprofiles` screenshot, 2026-11-24 | Positive control; no gap observed | None; retain current firewall posture | Not yet retested | Verified |
| B-02 | Microsoft Defender service, antivirus, and real-time protection are enabled; signatures updated 2026-11-24 | `Get-MpComputerStatus` screenshot, 2026-11-24 | Positive control; no gap observed | None; retain current protection and keep signatures current | Not yet retested | Verified |
| B-03 | Remote Desktop is disabled (`fDenyTSConnections=1`) | Registry query screenshot, 2026-11-24 | Positive control; no gap observed | None; keep disabled unless needed | Not yet retested | Verified |
| H-01 | OS volume C: is fully decrypted; BitLocker protection is off and no key protectors exist. `Get-Tpm` returned `TpmPresent=False`, `TpmReady=False` | `manage-bde -status C:` and `Get-Tpm` screenshots, 2026-11-24 | Data-at-rest exposure if the device or drive is lost or accessed offline; severity depends on data sensitivity and physical exposure | No endpoint changes requested; document current state and the user's decision to leave settings as-is | Not applicable unless user later requests a change | Documented; no change made |
| H-02 | Installed hotfixes, free disk, and local Administrators membership not yet captured | Baseline commands not visible in supplied output | TBD | Collect evidence before deciding | Pending | Open |

## Resource and safety constraints

This PC has 8 GB RAM. Earlier Elasticsearch logs reported approximately 11% free disk. Re-check current free disk before adding endpoint protection components, vulnerability scanners, or virtual machines. Use a supported scanner only after confirming its current licensing and safe scan scope. Keep tests on the local machine controlled and non-destructive.
