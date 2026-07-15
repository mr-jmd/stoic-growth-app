/// Outcome recorded on a habit check-in (the append-only consistency log).
/// Stored in Drift as `textEnum`. A `relapse` is history, never a failure —
/// paired with a [RelapseEvents] row and framed as learning (Sprint 4).
enum CheckInStatus { success, relapse }
