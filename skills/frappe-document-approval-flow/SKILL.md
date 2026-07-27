---
name: frappe-document-approval-flow
description: Use when implementing generic Frappe document upload, verification, and admin approval/rejection flows, including approval status fields, private file attachments, rejection reasons, audit trails, or reusable document approval APIs.
---

# Skill: frappe-document-approval-flow

Follow these guidelines when building a document verification and admin approval system in Frappe.

## Architecture

1.  **Canonical Document DocType:** Use a single, central DocType (e.g., `Masar Document`, `Verification Document`) to store the uploaded file and its current state.
2.  **Audit Trail (Optional):** If the product requires tracking every review action (who approved/rejected and when), create a separate `Document Approval Flow` or `Document Audit` DocType. Do NOT use the audit DocType as the source of truth for the current document status.
3.  **State Storage:** Store `approval_status` (Pending, Approved, Rejected) and `rejection_reason` directly on the canonical document DocType.

## Frappe Implementation Rules

### 1. File Handling & Privacy

-   User uploads that contain sensitive personal or verification data must use **private files**.
-   When attaching the file programmatically, set `is_private: 1` on the `File` DocType.
-   **Never** return raw `/private/files/...` paths to external clients (Next.js, Flutter). Always return signed download URLs using a shared helper.

### 2. Permissions & Security

-   **Users:** Must only be able to read and write their own documents, or documents belonging to profiles they manage. Enforce this via custom `has_permission` hooks or explicit checks in whitelisted APIs.
-   **Admins:** Must have a specific role (e.g., `System Manager`, `App Admin`) to approve or reject documents. Ensure this check exists in the backend API, not just the frontend UI.

### 3. API Design

-   Separate user actions from admin actions.
    -   **User APIs:** `upload_document`, `get_my_documents`, `delete_document`
    -   **Admin APIs:** `approve_document`, `reject_document`
-   Always call `frappe.db.commit()` at the end of whitelisted methods that perform writes.
-   Use standard Frappe ORM methods (`doc.insert()`, `doc.save()`) instead of raw SQL or `db.set_value` to ensure `doc_update` and `list_update` realtime events are published automatically.

### 4. Lifecycle & Validation

-   New documents should default to `approval_status = "Pending"`.
-   If a document is rejected, `rejection_reason` is mandatory.
-   If a user updates the attachment of a rejected document, reset the `approval_status` back to `Pending` and clear the `rejection_reason`.

### 5. Desk UI (Frappe Admin)

-   If admins review documents via Frappe Desk, add custom Javascript to the DocType form to provide clear "Approve" and "Reject" buttons.
-   Prompt for a rejection reason when the "Reject" button is clicked.
-   Only show these buttons if the document is pending and the current user has the appropriate admin role.

## Reference Examples

This skill includes reference files based on the proven `Masar Document` implementation. Use them as structural templates when building a similar flow in another app.

For the Flutter admin listing, preview, and review-action adapter, read `flutter-document-approval.md`.

-   [DocType Schema Pattern](references/generic-document-doctype.md)
-   [API Implementation Pattern](references/generic-document-api.md)
-   [Desk UI Approval Pattern](references/generic-document-desk-approval.md)
-   [Implementation Checklist](references/generic-implementation-checklist.md)
