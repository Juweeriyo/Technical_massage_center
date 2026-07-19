# Payment Module Implementation Plan

This plan addresses the full implementation of the Payment Module, ensuring strict role-based access control across both the FastAPI backend and Flutter frontend, as per the requirements.

## Proposed Changes

### 1. Backend: API Security and New Routes (`backend/routers/payments.py`)

- **Role Enforcement:** Update dependencies to ensure Admin has full access, Staff has read-only access (with hidden financial data), and Doctor has no access.
- **Financial Data Protection:** If the `current_user.role` is `"Staff"`, the backend will explicitly zero out `total_amount` and `amount_paid` in the returned `Payment` objects so sensitive financial data never leaves the server.
- **Delete Endpoint:** Implement `DELETE /payments/{id}` restricted to Admin.
- **Patient Status Endpoint:** Implement `GET /payments/patient/{patient_id}/status` which calculates and returns:
  - `"Not Paid"` (if no payments exist or all are unpaid)
  - `"Partially Paid"` (if total paid > 0 but < total billed)
  - `"All Paid"` (if total paid >= total billed)

### 2. Frontend: API Repository (`frontend/lib/features/payments/data/payments_repository.dart`)

- Implement `deletePayment(int id)` using `apiClient.delete()`.
- Implement `getPatientPaymentStatus(int patientId)` using `apiClient.get()`.

### 3. Frontend: Payments UI (`frontend/lib/features/payments/presentation/payments_screen.dart`)

- **Role Awareness:** Read the current user's role using `SharedPreferences` (or `AuthService`) to determine the UI layout.
- **Doctor View:** Return a "Not Authorized" screen if a Doctor forces their way to the `/payments` route.
- **Staff View:** Dynamically remove the "Total Bill", "Amount Paid", and "Balance" columns from the `DataTable`. Hide the "Add Payment", "Edit", and "Print Receipt" buttons. Show only Patient, Method, and Status.
- **Admin View:** Show all columns and action buttons.
- Connect the Delete button to the repository and refresh the provider.

### 4. Frontend: Patients UI Integration (`frontend/lib/features/patients/presentation/patients_screen.dart`)

- Add a "Payment Status" column to the Patient List.
- Use a `FutureProvider.family` (or `FutureBuilder`) to asynchronously load and display each patient's payment status ("All Paid", "Partially Paid", "Not Paid") by calling the new `/payments/patient/{patient_id}/status` endpoint.
- Ensure the UI remains performant by caching the status results.

## User Review Required

> [!IMPORTANT]
> To strictly enforce the rule "Staff must NOT see payment amount", the backend will set `total_amount` and `amount_paid` to `0.0` for any requests made by a Staff user, before the JSON response is sent. This guarantees the data cannot be inspected in browser developer tools. 

Please approve this plan so I can begin execution.
