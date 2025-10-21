# InvitesOnly Smart Contract

A comprehensive event management smart contract built on the Stacks blockchain using Clarity. Manage private event invitations, track RSVPs, assign seating arrangements, and issue commemorative digital keepsakes—all stored immutably on the blockchain.

## Features

### 🎫 Event Management
- Create and manage private events with detailed information
- Set event name, description, date, venue, and seating capacity
- Update event details as needed
- Close events when finished

### 📧 Invitation System
- Send invitations to individual guests
- Bulk invite multiple guests at once (up to 50 per transaction)
- Track invitation timestamps on-chain
- Verify guest invitation status

### ✅ RSVP Tracking
- Guests can respond with their attendance status
- Support for plus-ones
- Timestamped responses
- Permanent record of commitments

### 💺 Seating Arrangements
- Assign specific seat numbers to attending guests
- Prevent double-booking with automatic validation
- Ensure seat numbers are within venue capacity
- Track seat assignment timestamps

### 🎁 Digital Keepsakes
- Issue commemorative NFT-like keepsakes to attendees
- Hosts can create personalized messages
- Guests can claim their own keepsakes with personal notes
- Permanent blockchain record of attendance
- Perfect for weddings, galas, conferences, and special events

## Contract Structure

### Data Maps

- **events**: Stores event details (name, description, host, date, venue, capacity, status)
- **invitations**: Tracks who has been invited to each event
- **rsvps**: Records guest responses and plus-one counts
- **seating**: Maps seat numbers to specific guests
- **keepsakes**: Stores commemorative messages and attendance records

### Error Codes

- `u100` - Owner only action
- `u101` - Guest not invited
- `u102` - Already RSVPed
- `u103` - Event not found
- `u104` - Seat already taken
- `u105` - Invalid seat number
- `u106` - Event has ended
- `u107` - Guest not attending

## Usage Guide

### For Event Hosts

#### 1. Create an Event

```clarity
(contract-call? .InvitesOnly create-event 
  "Annual Gala 2025"
  "Join us for an evening of elegance and celebration"
  u1750000  ;; date (block height or timestamp)
  "Grand Ballroom, City Center"
  u200  ;; total seats
)
```

#### 2. Invite Guests

Single invitation:
```clarity
(contract-call? .InvitesOnly invite-guest 
  u1  ;; event-id
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM  ;; guest principal
)
```

Multiple invitations:
```clarity
(contract-call? .InvitesOnly invite-guests 
  u1  ;; event-id
  (list 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
        'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
)
```

#### 3. Assign Seating

```clarity
(contract-call? .InvitesOnly assign-seat 
  u1  ;; event-id
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM  ;; guest
  u42  ;; seat-number
)
```

#### 4. Issue Keepsakes

```clarity
(contract-call? .InvitesOnly issue-keepsake 
  u1  ;; event-id
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM  ;; guest
  "Thank you for celebrating with us! Your presence made our day special."
)
```

#### 5. Update Event Details

```clarity
(contract-call? .InvitesOnly update-event 
  u1  ;; event-id
  "Annual Gala 2025 - VENUE CHANGE"
  "Join us for an evening of elegance (new venue!)"
  "Crystal Palace, Downtown"
)
```

#### 6. Close Event

```clarity
(contract-call? .InvitesOnly close-event u1)
```

### For Guests

#### 1. RSVP to Event

```clarity
(contract-call? .InvitesOnly rsvp 
  u1  ;; event-id
  "attending"  ;; status
  u2  ;; plus-ones
)
```

#### 2. Claim Your Keepsake

```clarity
(contract-call? .InvitesOnly claim-keepsake 
  u1  ;; event-id
  "What an amazing night! Thank you for the memories."
)
```

### Read-Only Functions

Check event details:
```clarity
(contract-call? .InvitesOnly get-event u1)
```

Check invitation status:
```clarity
(contract-call? .InvitesOnly get-invitation u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

Check RSVP:
```clarity
(contract-call? .InvitesOnly get-rsvp u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

Check seating assignment:
```clarity
(contract-call? .InvitesOnly get-seating u1 u42)
```

Check keepsake:
```clarity
(contract-call? .InvitesOnly get-keepsake u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

Verify if someone is invited:
```clarity
(contract-call? .InvitesOnly is-invited u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

Get total event count:
```clarity
(contract-call? .InvitesOnly get-event-count)
```

## Use Cases

### 🎩 Weddings
- Send digital save-the-dates
- Track meal preferences via RSVP
- Assign reception seating
- Issue commemorative tokens to all attendees

### 🏢 Corporate Events
- Manage conference registrations
- Assign workshop seats
- Track attendance for compliance
- Provide digital certificates of attendance

### 🎭 Exclusive Gatherings
- Control access to private events
- Manage VIP seating arrangements
- Create collectible event memorabilia
- Build a verifiable attendance history

### 🎓 Graduations & Ceremonies
- Distribute ceremony seating
- Track guest confirmations
- Issue digital diplomas or certificates
- Create permanent records of achievement

## Security Features

- **Access Control**: Only event hosts can manage their events
- **Invitation Validation**: Guests must be invited to RSVP
- **Seat Protection**: Prevents double-booking of seats
- **Event Status**: Closed events cannot be modified
- **Immutable Records**: All data permanently stored on blockchain

## Deployment

1. Install Clarinet: `npm install -g @hirosystems/clarinet`
2. Create a new project: `clarinet new invites-only-project`
3. Add the contract to `contracts/InvitesOnly.clar`
4. Test the contract: `clarinet test`
5. Deploy to testnet: `clarinet deploy --testnet`
6. Deploy to mainnet: `clarinet deploy --mainnet`

## Testing

```bash
# Check syntax
clarinet check

# Run tests
clarinet test

# Open console for manual testing
clarinet console
```

## Best Practices

1. **Event IDs**: Always store event IDs returned from `create-event`
2. **Bulk Operations**: Use `invite-guests` for multiple invitations to save on transaction fees
3. **RSVP Deadline**: Close events after RSVP deadline to prevent late responses
4. **Seating**: Assign seats only to confirmed attendees
5. **Keepsakes**: Issue keepsakes during or after the event for authenticity

## Limitations

- Maximum 50 guests per bulk invitation transaction
- String fields have character limits (see contract constants)
- Events cannot be deleted, only closed
- Seat assignments cannot be changed once set (reassign requires host intervention)

## Future Enhancements

- NFT integration for premium keepsakes
- Token-gated events (require specific NFT to attend)
- Reputation system for reliable attendees
- Secondary market for transferable invitations
- Photo/media attachments to keepsakes
- Multi-signature event management

## Support

For issues, questions, or contributions, please open an issue on the repository.

---

Built with ❤️ on Stacks Blockchain using Clarity