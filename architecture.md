# Architecture and event flow

## Current architecture

```mermaid
flowchart LR
  subgraph PC[Single Windows 11 Pro lab PC]
    OS[Windows event channels<br/>Security / Application / System<br/>Additional channels unverified]
    A[Elastic Agent 9.5.6<br/>Servers flavor]
    F[Fleet Server<br/>HTTPS 8220<br/>local internal 8221]
    ES[Elasticsearch 9.5.6<br/>HTTPS 9200]
    K[Kibana 9.5.6<br/>HTTP localhost:5601]
    OS --> A
    A <-->|policy and check-in| F
    A -->|event documents| ES
    F <--> ES
    K <--> ES
  end
  K --> D[Discover and dashboards]
  K --> S[Elastic Security alerts]
```

Fleet Server is the control plane for Agent check-ins and policy delivery. The Agent's configured System and Windows integrations read Windows sources and send event documents to Elasticsearch. Kibana queries Elasticsearch and displays events and detection results. The current single host uses HTTPS Fleet Server port 8220 and local internal port 8221. Public documentation intentionally omits the PC's LAN address and account/host name.

### Current component inventory

| Component | Current state |
|---|---|
| Windows | Windows 11 Pro, build 22631 |
| Elasticsearch | 9.5.6, single node, HTTPS on the private lab host |
| Kibana | 9.5.6, local browser access on port 5601 |
| Fleet Server | 9.5.6, HTTPS on port 8220; local internal communication on 8221 |
| Elastic Agent | 9.5.6 Servers flavor, enrolled; Fleet showed Healthy |
| Fleet policy | Existing Fleet Server Policy reused; Fleet Server, System, and Windows integrations configured |
| Verified event datasets | `system.security`, `system.application`, `system.system` |
| EDR / Elastic Defend | Not deployed or verified |

## Event sequence

```mermaid
sequenceDiagram
  actor Analyst
  participant K as Kibana
  participant DE as Elastic Security detection engine
  participant ES as Elasticsearch
  participant F as Fleet Server
  participant A as Elastic Agent
  participant W as Windows event channels

  Analyst->>K: Sign in and open Discover/Security
  K->>ES: Read Fleet state, events, and alerts
  A->>F: Check in
  F->>ES: Retrieve current policy/control state
  F-->>A: Return policy and integration configuration
  W-->>A: Emit configured Security/Application/System events
  A->>ES: Ingest normalized event documents
  K->>DE: Schedule custom detection rule
  DE->>ES: Search source events using rule query
  ES-->>DE: Return matching event documents
  DE->>ES: Store alert documents for matches
  ES-->>K: Return rule execution status and alerts
  Analyst->>K: Investigate alert and record evidence-based disposition
```

## Proposed next-stage architecture

Keep the current one-PC layout for the first demo. Any future expansion—such as Elastic Defend or a separate Windows target VM—requires a capacity review and a deliberate lab design. Do not add a heavy scanner or extra VM until the host has adequate free disk and memory. A future segmented lab could isolate the target and test tools on a host-only virtual network while keeping Elasticsearch/Kibana management access restricted. No endpoint setting changes are part of the current work.

## Known architecture gaps

- Elasticsearch, Kibana, Fleet Server, and the monitored endpoint share one physical host; this creates a single point of failure.
- The cluster is single-node and previously reported yellow health/no replica assignment; it has no node-level redundancy.
- Self-signed TLS was used during local setup. Keep it private to the lab; review certificates before exposing endpoints beyond the local network.
- Fleet Server's advertised host uses a private lab address; a DHCP address change could affect check-ins unless a stable address or hostname is maintained.
- The project has one endpoint so far. Fleet can manage more hosts, but capacity must be checked first.
- Application, PowerShell, Defender, and Sysmon data streams are not all verified; do not imply process-level or EDR visibility.
