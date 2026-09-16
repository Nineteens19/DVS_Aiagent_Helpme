# Tool Rules (Environment-Aware)

Shared rules for all phase prompts. Load based on detected platform.

## File Operations

- **Kiro**: Use `fsWrite` for new files. Use `fsWrite` + `fsAppend` if a single file exceeds ~50 lines.
- **Claude Code**: Use `Write` for new files, `Edit` for modifications. For large files, use `Write` with full content.
- **Other**: Use `Write` for new files, `Edit` for modifications.

## Batch Reading

- **Kiro**: Use `readMultipleFiles` to load all needed templates in a single call
- **Claude Code**: Call `Read` tool multiple times in parallel (all in same invocation block)
- **Other**: Call `Read` tool sequentially if parallel not supported

## Parallel Writes

When generating multiple independent files (e.g., design/*.md), write them in parallel tool calls rather than sequentially.
