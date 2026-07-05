# Reference: Generic Document DocType Schema

This is an example structure based on `Masar Document`. When creating a reusable document upload DocType, include these essential fields.

## Essential Fields

| Fieldname | Fieldtype | Label | Notes |
| :--- | :--- | :--- | :--- |
| `document_type` | Select | Type | e.g., License, Certification, ID |
| `title` | Data | Title | User-friendly name |
| `document_number` | Data | Document Number | Optional reference number |
| `attachment` | Attach | Attachment | The actual file |
| `issue_date` | Date | Issue Date | |
| `expiry_date` | Date | Expiry Date | Used for status calculation |
| `user` | Link | User | The system user who owns this |
| `scope` | Select | Scope | E.g., 'User' vs 'Profile' |
| `profile_doctype` | Select | Profile Doctype | Dynamic link target |
| `profile_name` | Dynamic Link | Profile | Dynamic link name |
| `status` | Select | Expiry Status | Active, Expiring Soon, Expired |
| `approval_status` | Select | Approval Status | Pending, Approved, Rejected |
| `rejection_reason` | Small Text | Rejection Reason | Mandatory if Rejected |

## Recommended Python Controller Validation

```python
import frappe
from frappe import _
from frappe.model.document import Document

class GenericDocument(Document):
    def validate(self):
        if not self.approval_status:
            self.approval_status = "Pending"
            
        if self.approval_status == "Rejected":
            if not str(self.rejection_reason or "").strip():
                frappe.throw(_("Rejection reason is required."))
            self.rejection_reason = str(self.rejection_reason).strip()
        else:
            self.rejection_reason = None
            
        # Add expiry status calculation logic here
```