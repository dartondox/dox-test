/// How the welcome email goes out.
/// - send: now, in the request
/// - queue: a queue worker sends it
/// - later: a queue worker sends it after a delay
enum MailMode { send, queue, later }
