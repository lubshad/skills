# Reference: Generic Document API

This reference demonstrates how to safely handle document uploads, private attachments, and admin approval actions.

```python
import frappe
from frappe import _

# --- Helper Methods ---

def _require_admin():
    if "System Manager" not in frappe.get_roles():
        frappe.throw(_("Not permitted."))

def _attach_file_to_document(document, upload_file):
    if not upload_file:
        return
    file_doc = frappe.get_doc({
        "doctype": "File",
        "file_name": upload_file.filename,
        "content": upload_file.stream.read(),
        "attached_to_doctype": document.doctype,
        "attached_to_name": document.name,
        "attached_to_field": "attachment",
        "is_private": 1, # IMPORTANT: Keep uploads private
    })
    file_doc.save(ignore_permissions=True)
    document.attachment = file_doc.file_url
    document.save(ignore_permissions=True)

# --- User APIs ---

@frappe.whitelist()
def save_document(title, document_type, document_id=None):
    # 1. Authorize user
    # 2. Get existing or create new document
    # 3. Update fields
    # 4. If re-uploading, reset approval_status to "Pending"
    # 5. Handle file attachment from frappe.request.files
    # 6. document.save()
    # 7. frappe.db.commit()
    # 8. Return serialized response with signed URL
    pass

# --- Admin APIs ---

@frappe.whitelist()
def approve_document(document_id):
    _require_admin()
    if not frappe.db.exists("Generic Document", document_id):
        frappe.throw(_("Invalid document."))
        
    document = frappe.get_doc("Generic Document", document_id)
    document.approval_status = "Approved"
    document.rejection_reason = None
    document.save(ignore_permissions=True)
    frappe.db.commit()
    
    return {"status": "Approved"}

@frappe.whitelist()
def reject_document(document_id, reason):
    _require_admin()
    if not frappe.db.exists("Generic Document", document_id):
        frappe.throw(_("Invalid document."))
        
    reason = str(reason or "").strip()
    if not reason:
        frappe.throw(_("Rejection reason is required."))
        
    document = frappe.get_doc("Generic Document", document_id)
    document.approval_status = "Rejected"
    document.rejection_reason = reason
    document.save(ignore_permissions=True)
    frappe.db.commit()
    
    return {"status": "Rejected"}
```