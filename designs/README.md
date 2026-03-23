# Pencil Artifacts

Use this directory for Pencil wireframe artifacts that support SRS screen specifications.

## Convention

- Store `.pen` files under `designs/`
- Prefer one subdirectory per initiative or product area
- Prefer one primary screen artifact per screen or flow

Example paths:
- `designs/customer-portal/SCR-01-login.pen`
- `designs/customer-portal/SCR-02-dashboard.pen`
- `designs/customer-portal/auth-flow.pen`

## Usage

- Link each SRS screen section to the relevant `.pen` file
- Keep screen IDs aligned between the SRS and Pencil artifact names
- Use the `.pen` file as the low-fidelity wireframe source of truth

## Notes

- Pencil is used here for wireframes only, not design-to-code generation
- If a single `.pen` file covers multiple screens, list the covered screen IDs in the SRS
