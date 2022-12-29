## Testing Read Time

It is recommended to use build mode instead of debug mode.

### Testing app flows
- Reader -> Book -> Book Menu -> Book
- Reader -> Book -> Minimize app -> Book
- Reader -> Book -> Switch Tabs -> Book

Repeat above by pressing "Keep Reading" or "Add Book" to invoke the Reader.

### Values to check
- If time is updated accordingly to time spent on reader. Note that a minimum of 5 heartbeat sceonds is required for a session to be registered to the database.
- If there is spillover from non-reading states. Usually happens if timer or heartbeat count is not properly terminated.
