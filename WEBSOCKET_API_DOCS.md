# WebSocket API Documentation
## provana.mafiola.net:5000

---

## Connection

**Endpoint:** `ws://provana.mafiola.net:5000`

**Protocol:** WebSocket (RFC 6455)

**Status:** ✓ Confirmed WebSocket server (verified via handshake)

---

## Available Routes/Endpoints

All messages must be sent as JSON strings. The server uses a `type` field to route requests.

### 1. ONBOARDING_CHAT

**Purpose:** Send chat messages, possibly for onboarding or initial communication

**Request Format:**
```json
{
    "type": "ONBOARDING_CHAT",
    "message": "Hi agent"
}
```

**Fields:**
- `type`: Must be `"ONBOARDING_CHAT"`
- `message`: String containing the message to send

---

### 2. AUTH - Authentication

Authentication endpoints for user sign-in and auth status checking.

#### 2.1 AUTH_CHECK

Check authentication status

**Request Format:**
```json
{
    "type": "AUTH",
    "action": "AUTH_CHECK"
}
```

**Fields:**
- `type`: Must be `"AUTH"`
- `action`: Must be `"AUTH_CHECK"`

#### 2.2 SIGN_IN

Sign in with authentication token

**Request Format:**
```json
{
    "type": "AUTH",
    "action": "SIGN_IN",
    "data": {
        "token": "your_auth_token_here"
    }
}
```

**Fields:**
- `type`: Must be `"AUTH"`
- `action`: Must be `"SIGN_IN"`
- `data`: Object containing authentication data
  - `token`: Your authentication token (string)

---

### 3. NOTIFICATIONS

Notification system for subscribing to updates

#### 3.1 SUBSCRIBE

Subscribe to notifications

**Request Format:**
```json
{
    "type": "NOTIFICATIONS",
    "action": "SUBSCRIBE"
}
```

**Fields:**
- `type`: Must be `"NOTIFICATIONS"`
- `action`: Must be `"SUBSCRIBE"`

#### 3.2 Notification Format (Server → Client)

When subscribed, the server may send notifications in this format:

```json
{
    "type": "NOTIFICATIONS",
    "data": [
        {
            "type": "",
            "status": "",
            "message": "",
            "meta": {
                "key": "value"
            }
        }
    ]
}
```

**Fields:**
- `type`: Notification type/category
- `status`: Current status of the notification
- `message`: Human-readable message
- `meta`: Additional metadata as key-value pairs

---

## Error Handling

When an invalid or unknown request is sent, the server responds with:

```json
{
    "status": "error",
    "message": "Unknown request"
}
```

---

## Testing

Use the provided `ws_test_client.py` script to test the API:

### Test all endpoints:
```bash
python3 ws_test_client.py --test-all
```

### Interactive mode:
```bash
python3 ws_test_client.py
```

### Send custom message:
```bash
python3 ws_test_client.py --message '{"type":"ONBOARDING_CHAT","message":"Hello"}'
```

---

## Summary of Routes

| Type | Action | Purpose |
|------|--------|---------|
| `ONBOARDING_CHAT` | - | Send chat messages |
| `AUTH` | `AUTH_CHECK` | Check authentication status |
| `AUTH` | `SIGN_IN` | Authenticate with token |
| `NOTIFICATIONS` | `SUBSCRIBE` | Subscribe to notifications |

---

## Notes

- The server appears to be intermittently available (may have rate limiting)
- All messages must be valid JSON
- The WebSocket handshake is standard RFC 6455 compliant
- No initial message is sent by the server upon connection
- Message format uses `type` and optional `action` fields for routing
