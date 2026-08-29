# Brief to the API Team — Endpoints Used by the App but Missing from the README

**Base URL:** `https://accofinder-trsm.onrender.com/api`

## TL;DR

The Qt app (AccoFinder) calls the endpoints below, but they are **not documented in the README** and most are **not registered on the deployed backend** (confirmed live: `GET /api/agents/` returns HTTP 404 `"Not Found - /api/agents/"`). They block the admin dashboard screens (Manage Agents, Agent Applications, Property Approvals, User deactivation, Payments oversight). Please add these routes and update the README.

All protected endpoints below receive `Authorization: Bearer <accessToken>`; resolve user/agent id from the token (same pattern as the rest of the app).

---

## 1. Agents — no section exists at all (URGENT: 404 on live backend)

Used in `src/repositories/impl/agentrepositoryimpl.cpp`.

| Method | Endpoint | Description | Auth | Roles |
|--------|----------|-------------|------|-------|
| GET | `/agents/` | List all agents | Yes | ADMIN |
| GET | `/agents/:agentId` | Get agent by ID | Yes | ADMIN |
| PATCH | `/agents/:agentId` | Update agent | Yes | ADMIN |
| PATCH | `/agents/:agentId/status` | Activate/deactivate agent | Yes | ADMIN |

`PATCH /agents/:agentId/status` sends body:
```json
{ "isActive": true }
```

## 2. Agent Applications — no section exists

Used in `src/repositories/impl/agentrepositoryimpl.cpp` (lines 140, 175, 194).

| Method | Endpoint | Description | Auth | Roles |
|--------|----------|-------------|------|-------|
| GET | `/agent-applications/` | List agent registration applications | Yes | ADMIN |
| PATCH | `/agent-applications/:applicationId/approve` | Approve an application | Yes | ADMIN |
| PATCH | `/agent-applications/:applicationId/reject` | Reject an application | Yes | ADMIN |

## 3. Property Verification — no section exists

Used in `src/repositories/impl/verificationrepositoryimpl.cpp`. Note the base path is `/api/property/...` (NOT `/api/properties` or `/api/house-listing`) — please confirm the correct base.

| Method | Endpoint | Description | Auth | Roles |
|--------|----------|-------------|------|-------|
| POST | `/property/:id` | Create/update a verification record | Yes | ADMIN |
| GET | `/property/history` | Get verification history | Yes | ADMIN |
| PATCH | `/property/:propertyId` | Approve a property (admin) | Yes | ADMIN |
| PATCH | `/property/:propertyId` | Reject a property (admin) | Yes | ADMIN |

Open questions:
- Approve and reject currently hit the **same path** with different payloads. Does the backend require distinct routes (e.g. `/property/:id/approve`, `/property/:id/reject`), or does it branch on a `status`/`notes` field in the body? Tell us the exact contract.
- What is the request body schema for a verification record (we currently send the full Verification DTO)?

## 4. Users

Used in `src/repositories/impl/adminuserrepositoryimpl.cpp` (line 74).

| Method | Endpoint | Description | Auth | Roles |
|--------|----------|-------------|------|-------|
| PATCH | `/users/:userId/status` | Activate/deactivate a user account | Yes | ADMIN |

Body:
```json
{ "isActive": true }
```

(`PATCH /users/:userId/promote` is documented and already aligned.)

## 5. Payments

Used in `src/services/paymentgatewayimpl.cpp`.

| Method | Endpoint | Description | Auth | Roles |
|--------|----------|-------------|------|-------|
| GET | `/payments/user/:userId` | Get all payments for a user | Yes | All |
| POST | `/payments/cancel` | Cancel a payment | Yes | CLIENT |

---

## Contract confirmations (routes exist, shape must be confirmed)

1. **`POST /api/auth/refresh`** — The app now auto-refreshes on 401. It calls:
   ```json
   { "refreshToken": "<refreshToken>" }
   ```
   and expects `data.accessToken` in the response. Confirm the exact request/response field names. (Access tokens currently last ~15 minutes, so this fires on every dashboard load.)
2. **`GET /api/rooms/?propertyId=...`** — The app loads a property's rooms with a **query parameter**. The README documents `GET /api/rooms/property/:propertyId`. Please support the query form or tell us to switch paths.
3. **Properties list pagination shape** — `GET /api/house-listing/` returns `data` as an object `{ "properties": [...], "pagination": {...} }`. The client has been updated to parse `data.properties`; please keep this shape stable.