CREATE TABLE IF NOT EXISTS events (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    starts_at TEXT,
    location TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS invitations (
    id TEXT PRIMARY KEY NOT NULL,
    event_id TEXT NOT NULL,
    label TEXT NOT NULL,
    token_hash TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'cancelled')),
    table_name TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id)
);

CREATE TABLE IF NOT EXISTS guests (
    id TEXT PRIMARY KEY NOT NULL,
    invitation_id TEXT NOT NULL,
    full_name TEXT NOT NULL CHECK (length(trim(full_name)) > 0),
    role TEXT NOT NULL DEFAULT 'companion'
        CHECK (role IN ('graduate', 'companion')),
    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'cancelled')),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invitation_id) REFERENCES invitations(id)
);

CREATE TABLE IF NOT EXISTS entries (
    id TEXT PRIMARY KEY NOT NULL,
    guest_id TEXT NOT NULL,
    entry_type TEXT NOT NULL
        CHECK (entry_type IN ('first_entry', 'reentry')),
    entered_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    recorded_by TEXT NOT NULL,
    request_id TEXT NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES guests(id),
    UNIQUE (request_id, guest_id)
);

CREATE INDEX IF NOT EXISTS idx_invitations_event
    ON invitations(event_id);

CREATE INDEX IF NOT EXISTS idx_guests_invitation
    ON guests(invitation_id);

CREATE INDEX IF NOT EXISTS idx_entries_guest_time
    ON entries(guest_id, entered_at);

CREATE UNIQUE INDEX IF NOT EXISTS idx_one_first_entry_per_guest
    ON entries(guest_id)
    WHERE entry_type = 'first_entry';