# Searchable and link selectors

Use the platform-native dialog/picker and focus flow.

- Preserve typed search/filter state during loading. Debounce per-character search (for example, 300ms) rather than requesting on every key event.
- Mark the current selection in the result list, not in a separate selected-value panel.
- Search canonical identifiers and titles: include `name`; also include `title` and `id` when the schema supports them or the selector API already requests them.
- Open a focused selector with `Space` or `Enter`; navigate results with `ArrowUp`/`ArrowDown`.
- Scroll the highlighted result into view with minimal movement.
- `Enter` selects the highlighted result; without a highlighted row, it runs search.
