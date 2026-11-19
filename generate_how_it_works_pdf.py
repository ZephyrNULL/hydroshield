from fpdf import FPDF
import datetime

class PDF(FPDF):
    def header(self):
        self.set_font('Helvetica', 'B', 10)
        self.set_text_color(2, 136, 209)
        self.cell(0, 8, 'HydroShield - How the App Works', align='L')
        self.ln(10)
        self.set_draw_color(2, 136, 209)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(4)

    def footer(self):
        self.set_y(-15)
        self.set_font('Helvetica', 'I', 8)
        self.set_text_color(120, 120, 120)
        self.cell(0, 10, f'Page {self.page_no()}/{{nb}}', align='C')

    def title_page(self):
        self.add_page()
        self.ln(35)
        self.set_font('Helvetica', 'B', 26)
        self.set_text_color(2, 136, 209)
        self.cell(0, 14, 'HydroShield', align='C', ln=1)
        self.set_font('Helvetica', '', 16)
        self.set_text_color(60, 60, 60)
        self.cell(0, 10, 'Smart Water Management System', align='C', ln=1)
        self.ln(6)
        self.set_font('Helvetica', 'B', 14)
        self.set_text_color(30, 30, 30)
        self.cell(0, 10, 'How the App Works (Prototype Guide)', align='C', ln=1)
        self.ln(10)
        self.set_font('Helvetica', '', 11)
        self.set_text_color(80, 80, 80)
        self.multi_cell(0, 7, 'This document explains the HydroShield mobile app prototype: user roles, screens, features, and demo workflows for property owners and tenants.', align='C')
        self.ln(12)
        self.set_font('Helvetica', '', 10)
        self.set_text_color(100, 100, 100)
        self.cell(0, 8, f'Generated: {datetime.date.today().isoformat()}', align='C', ln=1)
        self.cell(0, 8, 'Version: 1.0.0 (Prototype demo, mock data/services)', align='C', ln=1)

    def section(self, title):
        self.ln(2)
        self.set_font('Helvetica', 'B', 14)
        self.set_text_color(2, 136, 209)
        self.cell(0, 9, title, ln=1)
        self.set_draw_color(220, 235, 245)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(3)

    def subsection(self, title):
        self.ln(1)
        self.set_font('Helvetica', 'B', 11)
        self.set_text_color(20, 60, 90)
        self.cell(0, 8, title, ln=1)
        self.ln(1)

    def body(self, text):
        self.set_font('Helvetica', '', 10)
        self.set_text_color(40, 40, 40)
        self.multi_cell(0, 6, text)
        self.ln(1)

    def bullets(self, items):
        self.set_font('Helvetica', '', 10)
        self.set_text_color(40, 40, 40)
        for item in items:
            x = self.l_margin
            self.set_x(x)
            self.cell(5, 6, '-')
            self.set_x(x + 5)
            self.multi_cell(self.w - self.r_margin - self.get_x(), 6, item)
        self.ln(1)

    def kv(self, k, v):
        self.set_font('Helvetica', 'B', 10)
        self.set_text_color(40, 40, 40)
        self.cell(55, 6, k + ':')
        self.set_font('Helvetica', '', 10)
        self.multi_cell(0, 6, v)


pdf = PDF()
pdf.set_auto_page_break(auto=True, margin=18)
pdf.alias_nb_pages()
pdf.title_page()
pdf.add_page()

pdf.section('1. Overview')
pdf.body('HydroShield is a smart water management mobile app prototype for residential and rental properties. It provides separate, role-based experiences for Property Owners and Tenants to monitor water tanks, track consumption and billing, manage cleaning/maintenance, detect leaks, and (for owners) control the main water supply. This build uses mock/demo data and simulated device responses to demonstrate workflows; real IoT hardware (ESP32/sensors), Firebase backend, and live payment gateway integrations are not fully connected in this prototype.')

pdf.subsection('Key principles')
pdf.bullets([
    'Role-based access: Owners manage property, billing, thresholds, payments, and hardware controls; Tenants view their own consumption, charges, payments, and property tank status.',
    'Demo/mock mode: Login is not validated against a backend, sensor readings are simulated, and hardware commands show simulated device confirmation.',
    'Water-themed, dashboard-driven UI with cards, charts, and status indicators for quick understanding.'
])

pdf.section('2. Getting Started (Demo Login)')
pdf.subsection('Sign-in screen')
pdf.bullets([
    'App branding: launcher name "HydroShield" (PascalCase) with a water-drop app icon; the sign-in screen shows the water-drop icon, app title "HydroShield", and subtitle "Smart Water Management".',
    'Role selection: Choose Owner or Tenant using the segmented control.',
    'Credentials: Email and password fields are provided for UI realism but are not validated in this demo build.',
    'Login: Tap "Login" to enter the selected role dashboard (a short loading indicator is shown).',
    'Create account: Tap "Create account" to open registration.'
])

pdf.subsection('Registration (demo)')
pdf.bullets([
    'Select role (Owner or Tenant) and enter name, email, phone number, and password.',
    'Tap "Register" to create a demo session and enter the corresponding dashboard.',
    'In production, accounts would be securely authenticated and linked to the correct property with role-based permissions.'
])

pdf.subsection('Switching roles / logout')
pdf.body('Owners can log out from Settings; Tenants can log out from Profile. After logout, you return to the sign-in screen and can log in as the other role to explore both interfaces.')

pdf.section('3. Owner Interface')
pdf.body('The Owner experience provides property-wide monitoring and management across five main tabs: Home, Usage, Cleaning, Alerts, and Settings.')

pdf.subsection('3.1 Home (Owner Dashboard)')
pdf.bullets([
    'Property header and actions: shows property context, online/offline simulation toggle, and a notifications panel.',
    'Water tank monitoring: animated tank visualization with current level (%), remaining water (litres), tank state (Full/Normal/Low/Critical), filling/draining/stable indicators, and last updated time. Offline mode can be simulated (cached reading label).',
    'Consumption overview: summary tiles for today/week/month property totals and tenant configuration context.',
    'Quick status cards: leakage monitoring status, tank cleaning/maintenance recommendation summary, and billing/payment highlights.',
    'Notifications/alerts (demo): examples include low water level, potential leakage, new bill generated, cleaning updates, and supply ON/OFF events.'
])

pdf.subsection('3.2 Usage & Billing (Owner)')
pdf.bullets([
    'Consumption charts: daily/weekly/monthly views with charted usage and totals.',
    'Billing management: set/edit water price per unit (rental rate), configure number of tenants, and view government tariff as a separate reference.',
    'Calculated charges: displays total consumption and corresponding charges based on configured pricing (demo calculations).',
    'Tenant records: view tenant consumption and payment status records (mock data), including allocated/individual records where supported by configuration.',
    'Transparency: pricing and billing settings are owner-controlled; tenants cannot modify them.'
])

pdf.subsection('3.3 Cleaning & Maintenance')
pdf.bullets([
    'Maintenance status: estimated sediment/maintenance indicator and recommendation based on configured intervals and available data (not claimed as direct dirt measurement without suitable sensors).',
    'History: last cleaning date, days since cleaning, and maintenance/cleaning history entries.',
    'System status: displays cleaning mechanism state (ON/OFF/Cleaning).',
    'Manual activation (Owner only): "Activate Cleaning" requires confirmation before sending a command. The app shows progress/status updates and simulated device completion feedback (demo).'
])

pdf.subsection('3.4 Alerts (Leakage Detection & Valve Control)')
pdf.bullets([
    'Leak monitoring: displays current flow rate, configured threshold, valve state, and leak-detected/normal status with alert history.',
    'Detection configuration: owner can adjust flow-rate threshold and detection duration criteria (demo logic flags abnormal flow meeting configured conditions).',
    'Remote water supply control: Turn OFF/Turn ON main supply via the connected solenoid valve (simulated). Each action requires confirmation and shows simulated device-confirmed success/failure feedback.',
    'Safety/authorization: hardware control actions are presented as owner-only; in production, commands must be authorized and confirmed by the device before showing success.'
])

pdf.subsection('3.5 Settings & Management (Owner)')
pdf.bullets([
    'Property & account: view property/account context (demo).',
    'Tenant management: configure number of tenants/residents (demo).',
    'Payment information: enter/update bank details and other accepted payment methods shown to tenants; save action (demo).',
    'Notification preferences: toggles for low water level, leakage/abnormal flow, and billing/payment alerts (demo).',
    'System/integration notes: indicates ESP32 hardware integration and backend sync are design targets; current build uses mock services.',
    'Logout: end the demo session.'
])

pdf.section('4. Tenant Interface')
pdf.body('The Tenant experience provides a simplified view (no control over pricing, thresholds, or hardware) across four main tabs: Home, Charges, Payments, and Profile.')

pdf.subsection('4.1 Home (Tenant Dashboard)')
pdf.bullets([
    'Property water tank: view current tank level (%), remaining litres, state, and last updated time with animated tank visualization.',
    'Your water consumption: daily/weekly/monthly summaries (demo data) with guidance to view detailed records in Charges.',
    'Current charges summary: applicable unit price, estimated monthly amount, and payment status; tenants cannot modify prices or hardware settings.'
])

pdf.subsection('4.2 Charges & Usage (Tenant)')
pdf.bullets([
    'Usage view: daily/weekly/monthly consumption charts and summaries for the tenant\'s recorded/share usage (demo).',
    'Charges: shows applicable price per unit, recorded consumption, calculated amount payable, and payment status (Pending/Paid).',
    'Historical records: view past consumption and payment records (demo). Pricing/configuration remains owner-controlled.'
])

pdf.subsection('4.3 Payments (Tenant) - Demo Payment Gateway')
pdf.bullets([
    'Owner payment details: displays owner-provided bank/UPI/other accepted payment information for reference.',
    'Current bill: shows bill period, amount payable, consumption/rate breakdown, and status (Pending/Paid).',
    'Pay securely (demo): "Pay ..." opens HydroShield SecurePay, a simulated checkout flow with order summary and secure/demo indicators.',
    'Payment methods: choose UPI, Card, or Net Banking and enter method-specific details (e.g. UPI ID; card number/expiry/CVV/name; bank selection) with basic validation.',
    'Processing & confirmation: simulated steps (connecting, verifying, authorizing, confirming) followed by a success screen with transaction ID, amount, method, date/time, and status.',
    'Receipt & history: option to download receipt (demo) and the completed payment is added to Payment History with status updated to Paid in the session (no real money charged).'
])

pdf.subsection('4.4 Profile (Tenant)')
pdf.bullets([
    'Identity & property: displays tenant name and assigned property (demo).',
    'Personal details form: tenants can add/update Email, Address, and Additional phone numbers (add/remove multiple numbers).',
    'Name restriction: Name is shown but locked/read-only and cannot be changed by the tenant.',
    'Save details: saves entered information in the demo session and shows a confirmation message.',
    'Permissions & logout: shows role permission summary and provides logout.'
])

pdf.section('5. Data, Hardware & Integration (Prototype Notes)')
pdf.bullets([
    'Mock device/service layer: tank level, flow rate, valve state, and cleaning status are simulated; service interfaces are structured so real MQTT/REST/ESP32 integrations can be swapped in later.',
    'Backend/services: Firebase Auth/Firestore/Messaging, persistent multi-property/tenant data, and push notification delivery are not fully integrated in this build.',
    'Hardware (target): ultrasonic sensor (level), flow sensor (consumption/leak), solenoid valve (supply control), and cleaning mechanism (maintenance) via ESP32; production control should require device-confirmed execution.',
    'Payments: payment gateway is a realistic demo UI only; no real transactions are processed.',
    'Offline/updates: UI demonstrates last-updated timestamps and offline indicators in places; full sync/offline handling requires backend integration.'
])

pdf.section('6. Demo Walkthrough (Suggested)')
pdf.bullets([
    '1) Open app and log in as Owner (demo). Explore Home tank status, Usage & Billing, Cleaning activation flow, Alerts/valve controls, and Settings.',
    '2) Log out, then log in as Tenant (demo). Review Home and Charges, open Payments and complete a demo SecurePay transaction, and update Profile details (name remains locked).',
    '3) Observe role differences: tenants cannot change pricing, thresholds, payment configuration, or control hardware.'
])

pdf.section('7. Current Limitations')
pdf.bullets([
    'No real authentication, property/tenant provisioning, or secure per-user data storage.',
    'No live sensor telemetry or confirmed hardware actuation; all readings/commands are simulated.',
    'No real payment processing, receipts, or accounting integration.',
    'Notifications and alerts are demonstrated in-app; push delivery and end-to-end eventing require backend setup.'
])

pdf.output('HOW_HYDROSHIELD_APP_WORKS.pdf')
print('created HOW_HYDROSHIELD_APP_WORKS.pdf')
