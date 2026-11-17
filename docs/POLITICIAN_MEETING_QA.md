# Politician Meeting — Likely Questions, Answers and Value

## 1. “Why do we need this when agents can call or send WhatsApp messages?”
**Answer:** Calls and WhatsApp are useful for communication but difficult to aggregate, verify and audit at scale. The reporting app gives each report a defined polling unit, reporter, time, status and approval trail, while the Situation Room provides one view of what is happening across the field.

**Value:** Faster situational awareness, fewer scattered reports, easier escalation and a structured record for post-election review.

## 2. “What exactly will I see in the Situation Room?”
**Answer:** A live operational picture organised by State, LGA, Ward and Polling Unit: field reports, incidents, opening status, submitted results, approval status, evidence and operational exceptions.

**Value:** Leadership can move from anecdotal updates to location-specific information.

## 3. “How do we know a report actually came from the correct location?”
**Answer:** The system can associate each field user with assigned polling units and capture location metadata when reports are submitted. Production deployment should also add stronger device/user authentication and location-validation rules.

**Value:** Better accountability and reduced ambiguity about the source of reports.

## 4. “What if there is no network?”
**Answer:** The field app already supports offline drafts and an offline synchronization queue. An agent can capture the report while offline and synchronize when connectivity returns.

**Value:** Reporting can continue in low-connectivity areas instead of stopping completely.

## 5. “Can one person change a result before it reaches us?”
**Answer:** The current workflow is designed around staged approval: Field Agent → Ward Supervisor → LGA Supervisor → State Supervisor → Situation Room. Each approval changes the status and creates an audit trail.

**Value:** Separation of duties and traceability rather than a single unverified submission.

## 6. “Can we see the original evidence?”
**Answer:** The architecture includes evidence and incident modules, and the field application supports image capture. For production use, uploaded result sheets and incident evidence should be retained with timestamps and integrity controls.

**Value:** Decision-makers can compare reported figures with supporting evidence.

## 7. “How many polling units can it handle?”
**Answer:** The Kaduna demonstration dataset prepared from the supplied workbook contains 8,013 polling units across 255 wards and all 23 LGAs. The software hierarchy is designed to handle polling units through State → LGA → Ward → PU structures.

**Value:** The demonstration is no longer based only on a few sample locations; it can show realistic Kaduna-wide navigation.

## 8. “Can I know where there is a problem immediately?”
**Answer:** Incidents can be submitted by field agents with category, severity, description and location. The Situation Room can prioritize unresolved or high-severity reports.

**Value:** Resources and attention can be directed to documented operational problems more quickly.

## 9. “Can this system announce the official election result?”
**Answer:** No. Official election results remain the responsibility of INEC under the applicable electoral framework. This platform should be presented as an internal monitoring, reporting, evidence and situational-awareness system, not as a replacement for INEC's official result process.

**Value:** It helps an organisation understand its field reports while maintaining a clear distinction from the official electoral process.

## 10. “What stops unauthorized people from accessing it?”
**Answer:** The demo already has role separation, but the current repository is explicitly a demo. Before real deployment, authentication, production-grade Supabase RLS, device/session controls, encryption, backups and audit monitoring must be hardened.

**Value:** There is a clear path from demonstration to a secured operational deployment.

## 11. “What is the biggest advantage?”
**Answer:** It combines field reporting, hierarchy, incidents, results, approvals, offline operation and Situation Room visibility into one workflow.

**Value:** The same event can be followed from the polling unit through supervision to central review without relying on disconnected spreadsheets, calls and chat groups.

## 12. “What will you need from us to deploy it properly?”
**Answer:** Confirm the election scope, user hierarchy, authorised users, polling-unit assignments, required report types, escalation rules, infrastructure/hosting arrangement, security requirements, and the exact reports leadership wants to see.

**Value:** Once those operational rules are agreed, the system can be configured around the organisation’s real structure instead of forcing users into a generic workflow.

## Suggested 30-second opening
“We have developed two connected tools. The first is the field reporting application used by agents and supervisors, including offline reporting and staged verification. The second is the central Election Situation Room, where leadership can monitor reports, incidents and verified submissions by location. For tomorrow’s demonstration we have prepared the Kaduna structure using 8,013 polling units across all 23 LGAs, so we can demonstrate the workflow with realistic geography rather than a small fictional sample.”
