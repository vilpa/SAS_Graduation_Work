workspace "X-Customer Member Application" "C4 Model for Target Solution Architecture" {

    !include https://raw.githubusercontent.com/structurizr/dsl/master/examples/theme/theme.dsl
    !theme default

    model {
        user = person "Member User" "X-Customer member using the application"
        admin = person "Company Administrator" "Admin users who manage accounts"
        public = person "Public User" "General public accessing limited data"

        enterprise_identity = softwareSystem "Enterprise Identity Provider" "Handles authentication via SSO, OAuth2, SAML"
        sap = softwareSystem "SAP" "External ERP system"
        quickbooks = softwareSystem "QuickBooks" "External financial system"
        help_portal = softwareSystem "Help Resources" "External training and help content platform"

        system = softwareSystem "X-Customer Member Application" "Modular platform to manage GIN, LN and shared data"

        user -> system "Uses"
        admin -> system "Manages roles and data"
        public -> system "Searches public data"
        system -> enterprise_identity "Federated login and authentication"
        system -> sap "Integration via API"
        system -> quickbooks "Integration via API"
        system -> help_portal "Link to help and training content"

        container webapp = system.container "Web Application" "React SPA" "Delivers UI via Azure Front Door and CDN"
        container api = system.container "API Layer" "REST APIs with .NET 8" "Main business logic and orchestration"
        container user_mgmt = system.container "User Management Service" "Role-based access, SSO integration"
        container prefix_mgmt = system.container "Prefix Management Service" "Manages company prefixes"
        container gin_mgmt = system.container "GIN Management Service" "Create/edit GINs and hierarchies"
        container ln_mgmt = system.container "LN Management Service" "Manage locations and LNs"
        container data_access = system.container "Data Access Service" "Search/view/subscribe to published data"
        container notify = system.container "Notification Service" "Handles all notifications and preferences"
        container reports = system.container "Reporting Service" "Scheduled reports, audit, usage logs"
        container feedback = system.container "Help & Feedback Service" "Routes user feedback, shows help links"
        container integration = system.container "Integration Gateway" "Gateway to third-party systems (SAP, QuickBooks)"

        container db = system.container "SQL Database" "Azure SQL + Data Marts" "Stores structured data"
        container messaging = system.container "Messaging Bus" "Azure Service Bus/Event Grid" "Asynchronous messaging"
        container monitor = system.container "Monitoring Stack" "Azure Monitor, App Insights, Log Analytics"

        user -> webapp "Uses"
        webapp -> api "Communicates via REST"
        api -> user_mgmt
        api -> prefix_mgmt
        api -> gin_mgmt
        api -> ln_mgmt
        api -> data_access
        api -> notify
        api -> reports
        api -> feedback
        api -> integration

        api -> db
        api -> messaging
        messaging -> notify
        messaging -> reports
        messaging -> integration

        user_mgmt -> enterprise_identity
        integration -> sap
        integration -> quickbooks
        feedback -> help_portal
        monitor -> all "Observes"
    }

    views {
        systemContext system "System Context" {
            include *
            autolayout lr
        }

        container system "Container Diagram" {
            include *
            autolayout lr
        }

        component user_mgmt "User Management Components" {
            component "SSO Auth Handler" "OAuth2, SAML federation logic"
            component "Role & Permission Engine" "Manages RBAC and user roles"
            component "User Profile Service" "CRUD for user accounts"
        }

        component gin_mgmt "GIN Management Components" {
            component "GIN Editor" "Create/edit GINs"
            component "Barcode Generator" "Generates barcodes"
            component "GIN Hierarchy Manager" "Manage parent-child relations"
        }

        component ln_mgmt "LN Management Components" {
            component "LN Editor" "Create/edit LNs"
            component "Hierarchy Manager" "Location relationships"
            component "Status Tracker" "LN lifecycle management"
        }

        component data_access "Data Access Components" {
            component "Search Engine" "Advanced filtering and search"
            component "Subscription Engine" "Subscribe to published data"
            component "Access Validator" "Controls visibility by role/subscription"
        }

        styles {
            element "Container" {
                background "#1168bd"
                color "#ffffff"
                shape roundedbox
            }

            element "Component" {
                background "#438dd5"
                color "#ffffff"
                shape component
            }
        }
    }
}
