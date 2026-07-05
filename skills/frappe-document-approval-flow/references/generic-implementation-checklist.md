# Reference: Implementation Checklist

When building a new document approval flow, follow these steps:

- [ ] **1. Create Canonical DocType**
  - Use Frappe Desk or `bench create-customization` to create the app-owned JSON directly.
  - Include `approval_status` (Select: Pending, Approved, Rejected).
  - Include `rejection_reason` (Small Text).
  - Include `attachment` (Attach).

- [ ] **2. Python Controller Logic**
  - Implement `validate()` to enforce `approval_status` defaults.
  - Enforce `rejection_reason` requirement when status is "Rejected".

- [ ] **3. User APIs (Upload/Manage)**
  - Implement `upload_document` API.
  - Ensure uploaded files are saved as `is_private: 1`.
  - Ensure updating an existing rejected document resets its status to "Pending".

- [ ] **4. Admin APIs (Approve/Reject)**
  - Implement `approve_document` and `reject_document` APIs.
  - Add strict role-based permission checks (`frappe.get_roles()`).
  - Call `frappe.db.commit()` after state changes.

- [ ] **5. Desk UI (Optional)**
  - Create the `public/js/your_doctype.js` file.
  - Register it in `hooks.py` under `doctype_js`.
  - Implement the Approve/Reject buttons using `frappe.call`.

- [ ] **6. Audit Trail (Optional)**
  - If required, create a separate `Document Approval Audit` DocType.
  - Hook into the Admin APIs to insert a new Audit row every time a document is approved or rejected.

- [ ] **7. Verify & Migrate**
  - Run `bench --site <site> migrate` to sync JSON changes.
  - Verify that a user can upload a file, an admin can reject it with a reason, and the user can re-upload to trigger a "Pending" reset.