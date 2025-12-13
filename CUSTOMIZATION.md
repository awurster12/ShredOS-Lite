# NWipe Customization Guide

This document describes the **optional customization features** available in this project for automatically populating **nwipe PDF erasure certificates**.

These features are **not enabled by default** and must be explicitly configured by the user.

---

## Overview

nwipe supports generating PDF erasure certificates using configuration files located in:

/etc/nwipe/


This project provides an **optional mechanism** to:

- Pre-fill organization and customer information
- Automatically inject the **system serial number**
- Ensure PDF reports are generated consistently and without manual entry

This is implemented using:

- `nwipe.conf`
- `nwipe_customers.csv`
- An init script (`S20nwipe-serial`) that runs at boot

---

## Enabling Customization (High-Level Steps)

1. Copy example configuration files into the root filesystem overlay
2. Edit the configuration files with desired defaults
3. Enable the startup script
4. Rebuild the image

Each step is detailed below.

---

## Step 1: Copy Example Configuration Files

The repository ships **example files only**, located in:

examples/nwipe/


To enable customization, copy them into the Buildroot overlay:

mkdir -p board/pc/overlay/etc/nwipe
cp examples/nwipe/nwipe.conf.example board/pc/overlay/etc/nwipe/nwipe.conf
cp examples/nwipe/nwipe_customers.csv.example board/pc/overlay/etc/nwipe/nwipe_customers.csv


These copied files will be included in the final image.

---

## Step 2: Configuring `nwipe.conf`

The file:


controls default values used when generating PDF certificates.

### Example Structure

Organisation_Details :
{
Business_Name = "";
Business_Address = "";
Contact_Name = "";
Contact_Phone = "";
Op_Tech_Name = "";
};

PDF_Certificate :
{
PDF_Enable = "ENABLED";
PDF_Preview = "DISABLED";
};

Selected_Customer :
{
Customer_Name = "";
Customer_Address = "";
Contact_Name = "";
Contact_Phone = "";
};


### Key Notes

- Fields left blank will appear blank in the PDF
- `PDF_Enable` must be set to `"ENABLED"` to generate reports
- `Contact_Name` under `Selected_Customer` is commonly used for:
  - Asset tag
  - Ticket number
  - **System serial number** (when using the startup script)

---

## Step 3: Configuring `nwipe_customers.csv`

The file:

board/pc/overlay/etc/nwipe/nwipe_customers.csv


must contain a matching customer entry for the customer selected in `nwipe.conf`.

### CSV Format

"Customer Name";"Contact Name";"Customer Address";"Contact Phone"
"GMR Marketing";"";"5CD123456";""


### Important Rules

- The **Customer Name** must match `Selected_Customer.Customer_Name`
- If the customer is missing from the CSV, nwipe will error
- This project’s startup script keeps the CSV in sync automatically

---

## Step 4: The `S20nwipe-serial` Startup Script

How Customization Works

At boot, the init script:

/etc/init.d/S20nwipe-serial


executes unconditionally and performs the following actions:

1. Generates `/etc/nwipe/nwipe_customers.csv`
2. Writes values based on the expected nwipe configuration format
3. Overwrites any existing `nwipe_customers.csv` without checking for prior contents
4. Injects the system serial number (via `dmidecode`) where applicable

**Important:**  
The script does **not** read or validate the existing contents of:

- `/etc/nwipe/nwipe.conf`
- `/etc/nwipe/nwipe_customers.csv`

Both files are treated as **authoritative outputs**, not inputs.

---

## Relationship Between `nwipe.conf` and `nwipe_customers.csv`

nwipe requires that the customer selected in `nwipe.conf` **must have a matching entry** in `nwipe_customers.csv`.

For customization to take effect correctly:

- `Selected_Customer.Customer_Name` in `nwipe.conf`
  **must exactly match**
- the `"Customer Name"` field written into `nwipe_customers.csv`

If these values do not match, nwipe may:

- Ignore the customization
- Display warnings or errors
- Fail to generate PDF certificates as expected

Because of this requirement, the startup script always generates
`nwipe_customers.csv` in a format that is expected to match the active
`nwipe.conf`.

---

## Default Behavior (No Customization)

If customization is not desired:

- `S20nwipe-serial` still runs
- `nwipe_customers.csv` is still generated
- All fields are written as empty strings (`""`)
- No organization, customer, or serial data appears in PDFs

Example generated CSV when customization is disabled:

"Customer Name";"Contact Name";"Customer Address";"Contact Phone"
"";"";"";""


This guarantees:

- nwipe always finds a valid CSV
- No mismatched customer errors occur
- Behavior matches upstream nwipe defaults

---

## About `nwipe.conf` Presence

The startup script **does not verify whether `nwipe.conf` exists**.

Current behavior:

- If `nwipe.conf` is present, nwipe will use it
- If `nwipe.conf` is absent, nwipe will fall back to its internal defaults
- The script does not modify or validate `nwipe.conf`

While nwipe may start without `nwipe.conf`, **customization will only apply**
when:

- `nwipe.conf` exists, and
- its `Selected_Customer` values correspond to the generated CSV

Users who want predictable behavior are encouraged to either:

- Provide a valid `nwipe.conf`, or
- Explicitly leave all fields blank (`""`) to disable customization cleanly

---

## Important Notes for Users

- `S20nwipe-serial` always overwrites `nwipe_customers.csv`
- Existing CSV contents are not preserved
- Customization depends on **matching values**, not file existence checks
- Blank fields are treated as intentional and valid
- No manual CSV management is required or recommended

---

## Summary / Script Requirements

- The startup script is **write-only**
- It does **not** merge or inspect existing files
- `nwipe_customers.csv` must match `nwipe.conf` for customization to apply
- Blank fields disable customization safely
- This behavior is intentional to ensure consistency and prevent nwipe errors

---

### Enabling the Script

Ensure the script exists and is executable:

ls -l board/pc/overlay/etc/init.d/S20nwipe-serial


If needed:

chmod +x board/pc/overlay/etc/init.d/S20nwipe-serial


The script runs automatically at boot once included in the image.

---

## Step 5: Rebuild the Image

After copying and editing configuration files, rebuild the image:

make


The generated image will now include automated PDF customization.

---

## Disabling Customization

Customization is **fully optional**.

To disable it:

rm board/pc/overlay/etc/init.d/S20nwipe-serial


Optionally remove the config files:

rm -rf board/pc/overlay/etc/nwipe


Rebuild:

make


nwipe will now behave exactly like upstream with no automated PDF field injection.

---

## Security and Privacy Considerations

- Do **not** commit organization-specific data to public repositories
- Keep example files generic
- Treat PDF certificates as sensitive audit artifacts
- Always validate that the correct disk is selected before wiping

---

## Troubleshooting

### nwipe reports missing customer errors

- Ensure `Selected_Customer.Customer_Name` matches a CSV entry
- Ensure the CSV file uses semicolons (`;`) not commas

### Serial number not appearing

- Confirm `dmidecode` works on the target system
- Confirm the startup script is executable
- Check boot logs for script errors

---

## Summary

This customization mechanism allows:

- Zero-touch PDF certificate generation
- Consistent audit data
- Reduced operator error

It is intentionally **opt-in** and can be removed entirely without affecting nwipe functionality.

---

End of document.
