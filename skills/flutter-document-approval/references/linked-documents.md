# Reference: Linked Documents

Masar Admin provides the canonical Flutter implementation for profile-linked document listing, preview, file opening, and review actions.

## Canonical Files

All paths are relative to `flutter_apps/masar_admin/`.

| Responsibility | File | Public type |
|---|---|---|
| Profile/detail tab orchestration | `lib/core/widgets/linked_documents_tab.dart` | `LinkedDocumentsTab` |
| Document summary and actions | `lib/core/widgets/linked_document_card.dart` | `LinkedDocumentCard` |
| Fullscreen preview route | `lib/core/widgets/linked_document_viewer_dialog.dart` | `LinkedDocumentViewerDialog` |
| PDF/image viewer | `lib/core/widgets/linked_document_viewer.dart` | `LinkedDocumentViewer` |
| Dynamic form field | `lib/core/widgets/linked_document_field.dart` | `LinkedDocumentField` |
| Upload form | `lib/core/widgets/linked_document_upload_dialog.dart` | `LinkedDocumentUploadDialog` |
| Remove confirmation | `lib/core/widgets/linked_document_remove_dialog.dart` | `LinkedDocumentRemoveDialog` |
| Typed API access | `lib/core/data/masar_documents_repository.dart` | `MasarDocumentsRepository` |
| Canonical API model | `lib/core/models/masar_document.dart` | `MasarDocument` |
| Authenticated private-file opening | `lib/core/utils/frappe_file_opener.dart` | `FrappeFileOpener` |
| URL normalization | `lib/core/utils/frappe_file_url.dart` | `FrappeFileUrl` |

The widget names are intentionally generic because the same presentation is reused across profile types. The model and repository retain `Masar` because they represent the concrete `Masar Document` backend contract.

## Detail Tab Integration

Add the shared tab widget to the host detail page and pass only the stable profile identity:

```dart
LinkedDocumentsTab(
  profileDoctype: 'Athlete Profile',
  profileName: athleteName,
)
```

The host page owns tab placement. `LinkedDocumentsTab` loads the current records from `MasarDocumentsRepository`, displays shared UI states, and refreshes after review mutations.

## Action Matrix

| Approval status | Available review actions |
|---|---|
| Pending | Approve, Reject |
| Approved | Revoke |
| Rejected | Reset to Pending |

Preview and authenticated open/download remain available whenever an attachment URL is present. Remove is opt-in and appears only when a managing field supplies `canRemove` and `onRemove`.

## Mutation Pattern

The tab owns `_workingDocumentId`, calls the typed repository, checks `mounted`, displays one success or error toast, and reloads documents after success. The card owns confirmation/reason dialogs and emits callbacks only after valid operator input.

Review repository requests include `expected_status`:

- Approve and Reject expect `Pending`.
- Revoke expects `Approved`.
- Reset expects `Rejected`.

This is an optimistic-concurrency guard, not merely UI state. The backend must validate it and enforce review permissions.

## Preview Pattern

`LinkedDocumentCard` normalizes the attachment URL and chooses Preview for supported PDF/image extensions. `LinkedDocumentViewerDialog` provides the fullscreen route. `LinkedDocumentViewer` fetches protected PDF bytes through authenticated Dio and uses a temporary browser blob URL; images use the shared Frappe image widget.

Unsupported attachment formats use `FrappeFileOpener.open(...)` rather than the embedded viewer.

## Adding Another Profile Type

1. Import `linked_documents_tab.dart` into the detail screen.
2. Add a `LinkedDocumentsTab` to the existing detail-page tab set.
3. Pass the exact Frappe profile DocType and stable record name.
4. Ensure the backend `get_documents` permission check allows the operator to read that profile's documents.
5. Verify the document count and tab count remain aligned when the detail page uses a `DefaultTabController`.
6. Test preview, download/open, approve, reject, revoke, reset, refresh, and error recovery.

## Boundaries

- Do not duplicate document cards or review dialogs in each profile feature.
- Do not import an approvals feature widget into shared core widgets.
- Do not move API calls into `LinkedDocumentCard`.
- Do not expose raw private file paths or use `url_launcher` for protected files.
- Do not rename the concrete backend model/repository merely to make presentation names generic.

## Verification

Run from `flutter_apps/masar_admin/`:

```sh
dart format lib/core/widgets lib/features
flutter analyze
```

Exercise at least one profile for each approval status and confirm the visible actions match the action matrix.
