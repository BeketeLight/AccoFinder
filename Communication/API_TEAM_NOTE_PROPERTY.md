# Brief to the API Team — Property Creation Flow (Agent)

**Base URL:** `https://accofinder-trsm.onrender.com/api`

## TL;DR

The Qt agent app (AccoFinder) creates a property in **three sequential steps**:

1. `POST api/house-listing/` — create the property **with its rooms inline** (atomic).
2. `POST media/upload` — upload each photo as multipart/form-data (S3 is handled on your side; we send raw file bytes).
3. `PUT api/house-listing/:id` — attach the returned media ids to the property.

**Auth:** the **authenticated agent makes all three calls**. On every one of these endpoints the client sends the header:

```
Authorization: Bearer <accessToken>
```

**Please resolve the user/agent id on your side from the token** and attach it to the payload — the client deliberately does **not** send `owner` / `agentId` in the body. (Same pattern as the rest of the app's protected endpoints.)

---

## Step 1 — Create Property (+ rooms inline)

**`POST /api/house-listing/`**

Body (JSON). `rooms` is inline so the property and its rooms are created atomically in one request.

```json
{
  "title": "Sunview Apartments",
  "description": "Modern three-bedroom house with tiled floors and a perimeter fence",
  "price": 120000,
  "propertyType": "WHOLE",
  "physicalAddress": {
    "district": "Lilongwe",
    "village": "Area 47"
  },
  "verificationStatus": "PENDING",
  "amenities": ["WIFI", "WATER", "SECURITY"],
  "landlord": "Thokozani Banda",
  "landlordPhone": "+265999123456",
  "isActive": true,
  "rooms": [
    { "type": "Single", "price": 60000, "available": true },
    { "type": "Double", "price": 95000, "available": true }
  ]
}
```

### Field notes (important)

- **`price` (whole-property) is OPTIONAL.** It only applies to `WHOLE` listings. For hostel / quarter / standalone-room listings the pricing lives **per room** in `rooms[].price`. The client may send `price: 0` or omit it when a per-room listing is being created.
- **`propertyType`** values the app sends (UPPERCASE): `WHOLE`, `HOSTEL`, `QUARTER`, `STANDALONE_ROOM` (defaults to `WHOLE`).
- **`verificationStatus`** — the agent submits as `"PENDING"`; it becomes `"VERIFIED"` after your verification flow. (Drafts are created with `""`.)
- **`rooms[]`** — each room has `type`, `price` (per-room, required for hostel/quarter/standalone), `available`.
- **Affiliation is yours:** set `owner`/`agentId`/`landlordId` on your Property document from the resolved token, not from client input. History/`createdAt` is also yours.

**Expected response (so the client can continue):**

```json
{
  "success": true,
  "data": { "_id": "<propertyId>", ... }
}
```

---

## Step 2 — Upload Media (photos)

**`POST /media/upload`** — multipart/form-data

The client sends the raw local file for S3 (you handle the actual S3 upload on your end and store the resulting URL on the Media doc).

Form fields:

| Field        | Value                                                        |
|--------------|--------------------------------------------------------------|
| `propertyId` | the id returned in Step 1                                    |
| `type`       | `"image"`                                                    |
| `isPrimary`  | `"true"`/`"false"` — the cover photo flag                    |
| `roomId`     | id of the room a photo belongs to, or `"-1"` for a general/property photo |
| `file`       | the file bytes (content type `image/jpeg`)                   |

**Example multipart part (illustrative):**

```
Content-Disposition: form-data; name="propertyId"
<propertyId>

Content-Disposition: form-data; name="type"
image

Content-Disposition: form-data; name="isPrimary"
true

Content-Disposition: form-data; name="roomId"
-1

Content-Disposition: form-data; name="file"; filename="photo1.jpg"
Content-Type: image/jpeg
<binary bytes>
```

**Expected response — return the created Media id** (the client collects these for Step 3):

```json
{
  "success": true,
  "data": { "_id": "<mediaId>", "url": "...", ... }
}
```

---

## Step 3 — Attach Media to Property

**`PUT /api/house-listing/:id`** — body:

```json
{
  "media": ["<mediaId1>", "<mediaId2>"]
}
```

Tells the property's `media` array (ObjectId refs to `Media`) which uploaded photos belong to it. It should merge/append these ids.

**Expected response:**

```json
{ "success": true, "data": { "_id": "<propertyId>", "media": ["<mediaId1>", "<mediaId2>"] } }
```

---

## Open questions for you

1. Confirm `propertyType` values (we send `WHOLE` / `HOSTEL` / `QUARTER` / `STANDALONE_ROOM`).
2. Confirm the exact path to flag a request as authenticated. The client already sends `Authorization: Bearer <token>`; if you additionally need an explicit `isAuth` flag in the body, tell us the field name and we will add it — currently no `isAuth` body field is sent.
3. Confirm the media multipart field names and the S3 contract (do you store the URL and return it in `data.url`, or should the client provide a `url` too?).
