;; InvitesOnly - Private Event Management Smart Contract
;; Handles invitations, RSVP tracking, seating arrangements, and digital keepsakes

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-invited (err u101))
(define-constant err-already-rsvped (err u102))
(define-constant err-event-not-found (err u103))
(define-constant err-seat-taken (err u104))
(define-constant err-invalid-seat (err u105))
(define-constant err-event-ended (err u106))
(define-constant err-not-attending (err u107))

;; Data Variables
(define-data-var event-counter uint u0)

;; Data Maps
(define-map events
  uint
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    host: principal,
    date: uint,
    venue: (string-ascii 100),
    total-seats: uint,
    is-active: bool
  }
)

(define-map invitations
  {event-id: uint, guest: principal}
  {
    invited: bool,
    invited-at: uint
  }
)

(define-map rsvps
  {event-id: uint, guest: principal}
  {
    status: (string-ascii 20),
    responded-at: uint,
    plus-ones: uint
  }
)

(define-map seating
  {event-id: uint, seat-number: uint}
  {
    guest: principal,
    assigned-at: uint
  }
)

(define-map keepsakes
  {event-id: uint, guest: principal}
  {
    message: (string-ascii 500),
    issued-at: uint,
    attended: bool
  }
)

;; Read-only functions
(define-read-only (get-event (event-id uint))
  (map-get? events event-id)
)

(define-read-only (get-invitation (event-id uint) (guest principal))
  (map-get? invitations {event-id: event-id, guest: guest})
)

(define-read-only (get-rsvp (event-id uint) (guest principal))
  (map-get? rsvps {event-id: event-id, guest: guest})
)

(define-read-only (get-seating (event-id uint) (seat-number uint))
  (map-get? seating {event-id: event-id, seat-number: seat-number})
)

(define-read-only (get-keepsake (event-id uint) (guest principal))
  (map-get? keepsakes {event-id: event-id, guest: guest})
)

(define-read-only (is-invited (event-id uint) (guest principal))
  (match (map-get? invitations {event-id: event-id, guest: guest})
    invitation (get invited invitation)
    false
  )
)

(define-read-only (get-event-count)
  (var-get event-counter)
)

;; Public functions

;; Create a new event
(define-public (create-event 
  (name (string-ascii 100))
  (description (string-ascii 500))
  (date uint)
  (venue (string-ascii 100))
  (total-seats uint))
  (let
    (
      (new-event-id (+ (var-get event-counter) u1))
    )
    (map-set events new-event-id
      {
        name: name,
        description: description,
        host: tx-sender,
        date: date,
        venue: venue,
        total-seats: total-seats,
        is-active: true
      }
    )
    (var-set event-counter new-event-id)
    (ok new-event-id)
  )
)

;; Send invitation to a guest
(define-public (invite-guest (event-id uint) (guest principal))
  (let
    (
      (event (unwrap! (map-get? events event-id) err-event-not-found))
    )
    (asserts! (is-eq tx-sender (get host event)) err-owner-only)
    (asserts! (get is-active event) err-event-ended)
    (map-set invitations {event-id: event-id, guest: guest}
      {
        invited: true,
        invited-at: stacks-block-height
      }
    )
    (ok true)
  )
)

;; Invite multiple guests
(define-public (invite-guests (event-id uint) (guests (list 50 principal)))
  (let
    (
      (event (unwrap! (map-get? events event-id) err-event-not-found))
    )
    (asserts! (is-eq tx-sender (get host event)) err-owner-only)
    (asserts! (get is-active event) err-event-ended)
    (ok (map invite-single-guest guests))
  )
)

(define-private (invite-single-guest (guest principal))
  (let
    (
      (event-id (var-get event-counter))
    )
    (map-set invitations {event-id: event-id, guest: guest}
      {
        invited: true,
        invited-at: stacks-block-height
      }
    )
    true
  )
)

;; RSVP to an event
(define-public (rsvp (event-id uint) (status (string-ascii 20)) (plus-ones uint))
  (let
    (
      (event (unwrap! (map-get? events event-id) err-event-not-found))
      (invitation (unwrap! (map-get? invitations {event-id: event-id, guest: tx-sender}) err-not-invited))
    )
    (asserts! (get invited invitation) err-not-invited)
    (asserts! (get is-active event) err-event-ended)
    (map-set rsvps {event-id: event-id, guest: tx-sender}
      {
        status: status,
        responded-at: stacks-block-height,
        plus-ones: plus-ones
      }
    )
    (ok true)
  )
)

;; Assign seating
(define-public (assign-seat (event-id uint) (guest principal) (seat-number uint))
  (let
    (
      (event (unwrap! (map-get? events event-id) err-event-not-found))
      (guest-rsvp (unwrap! (map-get? rsvps {event-id: event-id, guest: guest}) err-not-attending))
      (existing-seat (map-get? seating {event-id: event-id, seat-number: seat-number}))
    )
    (asserts! (is-eq tx-sender (get host event)) err-owner-only)
    (asserts! (<= seat-number (get total-seats event)) err-invalid-seat)
    (asserts! (is-eq (get status guest-rsvp) "attending") err-not-attending)
    (asserts! (is-none existing-seat) err-seat-taken)
    (map-set seating {event-id: event-id, seat-number: seat-number}
      {
        guest: guest,
        assigned-at: stacks-block-height
      }
    )
    (ok true)
  )
)

;; Issue commemorative keepsake
(define-public (issue-keepsake (event-id uint) (guest principal) (message (string-ascii 500)))
  (let
    (
      (event (unwrap! (map-get? events event-id) err-event-not-found))
      (guest-rsvp (unwrap! (map-get? rsvps {event-id: event-id, guest: guest}) err-not-attending))
    )
    (asserts! (is-eq tx-sender (get host event)) err-owner-only)
    (asserts! (is-eq (get status guest-rsvp) "attending") err-not-attending)
    (map-set keepsakes {event-id: event-id, guest: guest}
      {
        message: message,
        issued-at: stacks-block-height,
        attended: true
      }
    )
    (ok true)
  )
)

;; Claim your own keepsake (guest self-service after event)
(define-public (claim-keepsake (event-id uint) (personal-note (string-ascii 500)))
  (let
    (
      (event (unwrap! (map-get? events event-id) err-event-not-found))
      (guest-rsvp (unwrap! (map-get? rsvps {event-id: event-id, guest: tx-sender}) err-not-attending))
    )
    (asserts! (is-eq (get status guest-rsvp) "attending") err-not-attending)
    (map-set keepsakes {event-id: event-id, guest: tx-sender}
      {
        message: personal-note,
        issued-at: stacks-block-height,
        attended: true
      }
    )
    (ok true)
  )
)

;; Close event (host only)
(define-public (close-event (event-id uint))
  (let
    (
      (event (unwrap! (map-get? events event-id) err-event-not-found))
    )
    (asserts! (is-eq tx-sender (get host event)) err-owner-only)
    (map-set events event-id
      (merge event {is-active: false})
    )
    (ok true)
  )
)

;; Update event details (host only)
(define-public (update-event 
  (event-id uint)
  (name (string-ascii 100))
  (description (string-ascii 500))
  (venue (string-ascii 100)))
  (let
    (
      (event (unwrap! (map-get? events event-id) err-event-not-found))
    )
    (asserts! (is-eq tx-sender (get host event)) err-owner-only)
    (map-set events event-id
      (merge event {
        name: name,
        description: description,
        venue: venue
      })
    )
    (ok true)
  )
)