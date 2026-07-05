# Reference: Desk UI Approval Script

This is an example of custom Javascript added to a Frappe Desk form (via `hooks.py` -> `doctype_js`) to enable easy admin review.

```javascript
(function () {
    const canApprove = (frm) => {
        return !frm.is_new() && frappe.user.has_role("System Manager");
    };

    const reloadAfterApproval = (frm) => {
        frm.reload_doc();
    };

    const addApproveButton = (frm) => {
        frm.add_custom_button(
            __("Approve"),
            () => {
                frappe.confirm(
                    __("Approve this Document?"),
                    () => {
                        frappe.call({
                            method: "your_app.api.approve_document",
                            args: { document_id: frm.doc.name },
                            callback: () => reloadAfterApproval(frm),
                        });
                    }
                );
            },
            __("Approval") // Groups buttons under this dropdown
        );
    };

    const addRejectButton = (frm) => {
        frm.add_custom_button(
            __("Reject"),
            () => {
                frappe.prompt(
                    [
                        {
                            fieldname: "reason",
                            fieldtype: "Small Text",
                            label: __("Reason"),
                            reqd: 1,
                        },
                    ],
                    (values) => {
                        frappe.call({
                            method: "your_app.api.reject_document",
                            args: {
                                document_id: frm.doc.name,
                                reason: values.reason || "",
                            },
                            callback: () => reloadAfterApproval(frm),
                        });
                    },
                    __("Reject Document"),
                    __("Reject")
                );
            },
            __("Approval")
        );
    };

    frappe.ui.form.on("Generic Document", {
        refresh(frm) {
            if (!canApprove(frm)) return;

            // Only show buttons if the action is available
            if (frm.doc.approval_status !== "Approved") {
                addApproveButton(frm);
            }
            if (frm.doc.approval_status !== "Rejected") {
                addRejectButton(frm);
            }
        },
    });
})();
```