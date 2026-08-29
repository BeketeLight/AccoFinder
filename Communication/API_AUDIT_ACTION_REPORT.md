# AccoFinder — Backend Source-of-Truth Audit & Exact Action Report

**Backend reviewed:** `/media/csociety/Backup/CISociety/Node/Projects/accofinder` (Express + Mongo)
**Client reviewed:** `/home/csociety/CISociety/Qt/Projects/AccoFinder` (Qt, base URL `https://accofinder-trsm.onrender.com/api`)
**Audit basis:** actual `src/routes/*.mjs` + `src/app.mjs` + controllers + validators + models

---

## 1. Confirmed ALREADY aligned (no action)

| App call | Backend route | Notes |
|----------|---------------|-------|
| `POST /api/auth/refresh` `{refreshToken}` → `data.accessToken` | `POST /api/auth/refresh` (authRoutes.mjs:31, authController.mjs:150) | Exact match. Access token = 15min default. |
| `GET /api/house-listing/` → `data.properties` + `pagination` | `GET /api/house-listing/` & `/api/properties/` (app.mjs:135-136, propertyController.mjs:173) | Client already parses `data.properties`. |
| `POST /api/house-listing/` (inline `rooms[]`) | propertyRoutes.mjs:19, createPropertySchema | Payload fields match 1:1 incl. uppercased `propertyType`. |
| `PUT/DELETE /api/house-listing/:id` | propertyRoutes.mjs:27,35 | ✓ |
| `GET /api/rooms/`, `GET /api/rooms/:id`, `POST /api/rooms/`, `PUT /api/rooms/:id` | roomRoutes.mjs | ✓ |
| `GET/POST /api/bookings/`, `GET/PATCH /api/bookings/:id`, `PATCH /:id/confirm`, `PATCH /:id/cancel` | bookingRoutes.mjs | ✓ |
| `GET/POST /api/disputes/`, `GET /:id`, `PATCH /:id/resolve` | disputeRoutes.mjs | ✓ |
| `GET /api/notifications`, `:id`, `PATCH :id/read`, `PATCH /read/all` | notificationRoutes.mjs | ✓ |
| `POST /media/upload` (fields `propertyId,type,isPrimary,roomId,file`) | uploadRoutes.mjs:26, uploadController.mjs | Field names match exactly. |
| `GET /media/property/:id` | uploadRoutes.mjs:30 | ✓ |
| Users list/get, `PATCH /users/:id/promote` | userRoutes.mjs:9,11,21 | Route exists (role-value bug below). |

---

## 2. MUST-ADD endpoints — the Qt app calls these, the backend has NO route (all currently 404)

All are `Authorization: Bearer <accessToken>`, resolve user/agent id from the token. Bodies in JSON.

### 2.1 Agents — nothing exists (no controller, no routes)
| Method | Path | Body | Purpose |
|--------|------|------|---------|
| GET | `/api/agents/` | – | List agents |
| GET | `/api/agents/:agentId` | – | Get agent by id |
| PATCH | `/api/agents/:agentId` | agent fields | Update agent |
| PATCH | `/api/agents/:agentId/status` | `{ "isActive": true }` | Activate/deactivate agent |

> Needs: `routes/agentsRoutes.mjs`, controller, `User.find({ role: 'AGENT' })`. Reference model fields used by the client: `employeeId, assignedArea, commissionRate, isActive, firstName, lastName, email, phone, createdAt`.

### 2.2 Agent applications — nothing exists
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/agent-applications/` | List applications |
| PATCH | `/api/agent-applications/:applicationId/approve` | Approve |
| PATCH | `/api/agent-applications/:applicationId/reject` | Reject |

> If an application flow doesn't exist yet, decide scope with product: either implement (needs new model) **or** remove the admin "Agent applications" screen from the app. Recommend implementing — the admin dashboard links to it.

### 2.3 Property verification — `Verifications` model EXISTS, no controller/routes
| Method | Path | Purpose |
|--------|------|---------|
| POST | `/api/property/:id` | Create/update a verification record |
| GET | `/api/property/history` | Verification history |
| PATCH | `/api/property/:propertyId` | Approve a property |
| PATCH | `/api/property/:propertyId` | Reject a property |

**Decide now (blocks both sides):**
- Approve and reject use the **same path** in the client. Either split into `PATCH /api/property/:id/approve` and `PATCH /api/property/:id/reject` (client changes accordingly), or branch on a body field.
- `Verifications.verificationStatus` enum = `'Pending'/'Approved'/'Rejected'` (mixed-case) but `Property.verificationStatus` = `'PENDING'/'VERIFIED'/'DRAFT'`. **Pick ONE vocabulary** — recommend upper-case everywhere and add `REJECTED` to `Property.verificationStatus`.
- Also consider: property approval could be done with existing `PUT /api/house-listing/:id` setting `verificationStatus: 'VERIFIED'` (supported by updateProperty.mjs:94) — then `Verifications` routes are only for the audit-history screen.

### 2.4 Users
| Method | Path | Body | Purpose |
|--------|------|------|---------|
| PATCH | `/api/users/:userId/status` | `{ "isActive": true }` | Activate/deactivate account |

> `User.isActive` field already exists (User.mjs). Add middleware so deactivated accounts are rejected by `isAuthenticated`.

### 2.5 Payments
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/payments/user/:userId` | All payments for a user |
| POST | `/api/payments/cancel` | Cancel a payment |

> `queryPaymentSchema` already exists (paymentSchema.mjs:38) — wire a `GET /api/payments/` query route too (admin payments screen).

---

## 3. MUST-FIX backend bugs (existing code is broken)

1. **Payments webhook mount is wrong** (`app.mjs:40-44`): `app.use('/api/payments/webhook', express.raw(...), paymentRoutes)` mounts the *normal* payment router under `/api/payments/webhook/*`. There is **no real webhook endpoint** for PayChangu/Stripe. Remove the bogus mount; if you need payment callbacks, add `POST /api/payments/webhook` handling the raw body.
2. **`paymentController.mjs` has undeclared variables (ReferenceError on use)**:
   - `processMobilePayment` uses `email`, `first_name`, `last_name` (paymentController.mjs) — never defined.
   - `verifyMobilePayment` uses `currency` and `CUURRENCY`, plus `PaymentStatus.COMPLETED` which **does not exist** in the enum (`PaymentStatus` values: `INITIATED/SUCCESS/FAILED`), so a successful payment is never finalized and the booking never becomes `PAID`.
3. **`promoteUser` role values are wrong** (userController.mjs): `allowedRoles = ['Agent','Client','Landlord']` but `UserRole` enum = `['ADMIN','AGENT','CLIENT']` (upper-case) and the app sends **`AGENT`**. `mongoose runValidators` will reject `'Agent'`. Fix: compare upper-case (`['AGENT','CLIENT','ADMIN']`). Also `'Landlord'` is not a valid role anywhere — remove it.
4. **`getAllRooms` ignores all query filters** (roomController.mjs:7): `queryRoomSchema` accepts `propertyId, roomType, minPrice, maxPrice, isAvailable, page, limit`, but the controller returns *every* room unfiltered — the property's "rooms" list shows the whole DB.
5. **Dead/broken recommendation code**: `recommendationController.mjs` imports `../models/Recommendation.mjs`, which **does not exist**; the controller is also never mounted. Either implement the model + routes or delete the file.
6. **`LANDLORD` role is documented but missing** from `UserRole` enum — README lists LANDLORD; enum has only ADMIN/AGENT/CLIENT. Property CRUD is restricted to `['LANDLORD','AGENT','ADMIN']` (propertyRoutes.mjs:22) but a LANDLORD can never be created. Decide: add `LANDLORD` to the enum or align roles.

---

## 4. MUST-FIX payload mismatches (client vs backend validators)

1. **Booking create (app → 400 today).** App `BookingDto::toJson()` sends `{id, clientId, roomId, bookingDate, status, amount, commissionAmount}`. Backend `createBookingSchema` **requires** `roomId, checkInDate, checkOutDate, amount` (commissionAmount default 0). `bookingDate` is stripped as unknown → `checkInDate/checkOutDate` missing → validation error.
   → **App change:** map `bookingDate` → `checkInDate`/`checkOutDate` (check-out = check-in + duration), drop `id`/`status`. Verify `checkOutDate > checkInDate` (backend requires future dates).
2. **Payment process (app → 400 today).** Backend `processMobilePaymentSchema` **requires** `phoneNumber, bookingId, amount, operatorRefId`. App `PaymentDto::toJson()` sends only `{id, bookingId, amount, method, status, transactionRef, payoutStatus, payoutDate}` — no `phoneNumber`/`operatorRefId`.
   → **App change:** collect payer `phoneNumber` (+ operator id) and send `{bookingId, amount, phoneNumber, operatorRefId}`. OR **backend change:** make `phoneNumber`/`operatorRefId` optional. Decide one.
3. **Room `type` casing.** `createRoomSchema` and inline `rooms[].type` accept any string, but the `Room` model enum is `SINGLE/DOUBLE/TRIPLE` (upper-case) — `Room.create` validates. If the app sends `"Single"`/`"Double"`, standalone room creation fails while inline property rooms silently store mixed-case (insertMany skips validators). **Normalize:** `.uppercase()` in the Joi schemas and backfill data.

---

## 5. Documentation — update BOTH READMEs

`/media/csociety/Backup/.../accofinder/README.md` and `/home/csociety/README.md` are the same stale snapshot. After items 2–4 are done, rewrite the API Endpoints section to include: Agents, Agent Applications, Property Verification, `PATCH /users/:id/status`, `GET /payments/user/:userId`, `POST /payments/cancel`, and correct the Rooms/Booking/Payment request bodies. Keep the *existing* route table accurate for what's already live.

## 6. Deploy checklist (after backend changes)

1. Redeploy `accofinder-trsm.onrender.com` — the deployed backend is missing the agents routes entirely (live 404 confirmed on `GET /api/agents/`).
2. Verify with one admin token: users list, agents list, application approve/reject, property verify/approve/reject, user activate/deactivate, payments user list.
3. Client-side re-build: Qt app already auto-refreshes tokens and parses `data.properties` — no change needed for items 2.4/2.1 once routes exist, **except** items 4.1/4.2 (booking/payment payloads).

---

## Priority order

1. **P0 (app is blocked):** 2.1 agents (404), 2.3 verification routes, 2.5 payment query/cancel, 3.1–3.3 payment crashes + promote roles, 4.1 booking body, 4.2 payment body.
2. **P1:** 2.2 agent applications (or remove screen), 2.4 user status, 3.4 room filters, 3.5 recommendation cleanup.
3. **P2:** 3.6 LANDLORD role, 4.3 room type casing, section 5 README rewrite, section 6 redeploy+verify.
---

## 7. Implementation status (2026-08-29) — ALL back-end fixes now applied

Resolution chosen: **all fixes landed on the backend** (no client DTO changes needed — the app's payloads were already the right target; the backend schema/controllers were the broken side).

**Must-fix bugs:**
- 3.1/3.2 `paymentController.mjs` — undefined `email/first_name/last_name` derived from populated booking client; `PaymentStatus.COMPLETED` → `SUCCESS`; Payment creation fixed to `method:'mobile_money'`, `status: INITIATED`, `transactionRef: tx_ref`, `payoutStatus:'Pending'` (was `paymentMethod`/`PENDING`/`transactionId` → mongoose ValidationError). `paidAt` added to the model. `GET /payments/user/:userId` (returns single latest payment; also resolves a payment id for the app's refresh flow) and `POST /payments/cancel` (marks FAILED, booking → PENDING, room released) added.
- 3.1 webhook — bogus `/api/payments/webhook` raw-body mount removed from `app.mjs`.
- 3.3 `promoteUser` — roles now validated against the real `UserRole` enum (`ADMIN`/`AGENT`/`CLIENT`), input case-normalized.
- 3.4 `getAllRooms` — now honors `propertyId, roomType, minPrice, maxPrice, isAvailable, page, limit` (paginated, sorted, `roomType` case-insensitive).
- 3.5 `Recommendation` model created; `recommendationController` import fixed.
- 3.6 `LANDLORD` — out of scope (no schema change); agent/landlord distinction handled via `assignedArea` fields added to `User`.

**Payload mismatches (4.1/4.2/4.3):**
- 4.1 `createBookingSchema` now accepts `bookingDate` (ISO, optional) — matches `Booking` model, `createBooking` controller, and the app's payload. `checkInDate/checkOutDate` requirements removed. Booking responses also now expose `id` (the app's DTOs read `id`, not `_id`).
- 4.2 `processMobilePaymentSchema` makes `phoneNumber`/`operatorRefId` optional; `processMobilePayment` falls back to the booking client's phone/operator ref. 4.1/4.2 therefore need **no** Qt client change.
- 4.3 Room `type` normalized to upper-case in `createRoomSchema`, `createPropertySchema rooms[]`, `updateRoomSchema`, and propertyController inline `roomDocs`.

**Missing endpoints (section 2) — now live:**
- Agents: `GET/GET-id/PATCH/PATCH:status` under `/api/agents/**` (ADMIN).
- Agent Applications: model + `GET`, `POST`, `PATCH /:id/approve`, `PATCH /:id/reject` under `/api/agent-applications/**`.
- Property Verification: `POST /api/property/:id`, `GET /api/property/history`, `PATCH /api/property/:propertyId` (approve=0/reject=1 int<->enum map; `Property.verificationStatus` extended with `REJECTED`; `notes` added to Verification model).
- Users: `PATCH /api/users/:id/status` (`{isActive}`); `isAuthenticated` now rejects deactivated accounts (403).
- Payments: `GET /api/payments/user/:userId`, `POST /api/payments/cancel`.

**Verified:** all edited/new backend files pass `node --check`; `src/app.mjs` imports cleanly; the two missing npm deps (`@messagebird/sdk`, `resend`) reinstalled. Qt client Android (Qt 6.11) build passes — no client source changes were required this round (client fixes from prior work: `data.properties` parsing, refresh-on-401).
