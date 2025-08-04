workspace "X-Customer Member Application" "C4 Model for Target Solution Architecture" {


    model {
        user = person "Member User" "X-Customer member using the application"
        admin = person "Company Administrator" "Admin users who manage accounts"
        public = person "Public User" "General public accessing limited data"

        enterprise_identity = softwareSystem "Enterprise Identity Provider" "Handles authentication via SSO, OAuth2, SAML"
        external_identity = softwareSystem "External IdPs (Google, Microsoft, Okta)" "Handles authentication via SSO, OAuth2, SAML"
        sap = softwareSystem "SAP" "External ERP system"
        quickbooks = softwareSystem "QuickBooks" "External financial system"
        help_portal = softwareSystem "Help Resources" "External training and help content platform"
        key_vault = softwareSystem "Azure Key Vault" "Secure secret and credential storage"
        azure_monitor = softwareSystem "Azure Monitor" "Observability and metrics platform"
        graph_db = softwareSystem "Graph Database (Cosmos DB Gremlin API)" "Stores hierarchical GIN structures"

        xsystem = softwareSystem "X-Customer Member Application" {
            description "Modular platform to manage GIN, LN and shared data"
            webapp = container "Web Application" "React SPA" "Delivers UI via Azure Front Door and CDN"
            api = container "API Layer" "REST APIs with .NET 8" "Main business logic and orchestration"
            
            userMgmt = container "User Management Service" "Role-based access, SSO integration" {
                ssoa = component "SSO Auth Handler" "Handles SSO authentication using OAuth2 and SAML protocols"
                flogin = component "Federated Login Adapter" "Manages authentication with external IdPs like Google, Microsoft, Okta"
                uprfm = component "User Profile Manager" "CRUD operations for user profiles and preferences"
                rbac = component "Role & Permission Engine" "Defines and enforces user roles and RBAC policies"
                pswm = component "Password Management Service" "Handles password reset, expiration policies, and recovery workflows"

                group Sidecar {
                    iauth = component "Auth Proxy Interface" "Validates and proxies SSO login requests"
                    fedadapter = component "Federation Adapter" "Handles integration with external identity providers"
                    secrets = component "Secrets Loader" "Fetches secrets/configs from Azure Key Vault"
                    logger = component "Audit Logger" "Sends authentication and user change audit events"
                    metrix = component "Metrics Exporter" "Pushes login and performance metrics to Azure Monitor"
                    notification = component "Notification Dispatcher" "Sends password reset and other events to Notification Service"
                }

                db = component "SQL Database" "User Management schema" "SQLServer" "Database"
            }

            prefix_mgmt = container "Prefix Management Service" "Manages company prefixes"
            gin_mgmt = container "GIN Management Service" "Create/edit GINs and hierarchies"
            ln_mgmt = container "LN Management Service" "Manage locations and LNs"
            data_access = container "Data Access Service" "Search/view/subscribe to published data"
            notify = container "Notification Service" "Handles all notifications and preferences"
            reports = container "Reporting Service" "Scheduled reports, audit, usage logs"
            feedback = container "Help & Feedback Service" "Routes user feedback, shows help links"
            integration = container "Integration Gateway" "Gateway to third-party systems (SAP, QuickBooks)"

            # userMgmt internal dependencies
            ssoa -> flogin "Delegates to appropriate external IdP based on login request"
            ssoa -> uprfm "Retrieves or creates user profile post-authentication"
            uprfm -> rbac "Resolves user’s role to determine access rights"
            pswm -> uprfm "Updates/reset passwords and recovery tokens"

            # userMgmt external dependencies
            ssoa -> enterprise_identity "OAuth2/SAML. Authenticate user identity"
            flogin -> external_identity "OpenID Connect/SAML. Support federated login flows"
            uprfm -> db "SQL via ORM. Store/retrieve user profile info"
            rbac -> api "HTTP Headers/Claims. Attach or interpret RBAC claims in tokens"
            pswm -> notify "Azure Service Bus Event. Notify user via email/SMS about password changes"

            messaging = container "Messaging Bus" "Azure Service Bus/Event Grid" "Asynchronous messaging"
            monitor = container "Monitoring Stack" "Azure Monitor, App Insights, Log Analytics"

            user -> xsystem "Uses"
            admin -> xsystem "Manages roles and data"
            public -> xsystem "Searches public data"
            xsystem -> enterprise_identity "Federated login and authentication"
            xsystem -> sap "Integration via API"
            xsystem -> quickbooks "Integration via API"
            xsystem -> help_portal "Link to help and training content"

            user -> webapp "Uses"
            webapp -> api "Communicates via REST"
            api -> userMgmt
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
            
            integration -> sap
            integration -> quickbooks
            feedback -> help_portal
        }
    }

    views {
        systemcontext xsystem "SystemContext" {
            include *
            autolayout
        }

        container xsystem "ContainerDiagram" {
            include *
            autolayout
        }

        component userMgmt "Components" {
            include *
            autolayout
        }

/*
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
        */
        
        styles {
            element "Person" {
                color #ffffff
                fontSize 22
                shape Person
            }
            element "Customer" {
                background #08427b
            }
            element "Bank Staff" {
                background #999999
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Mobile App" {
                shape MobileDeviceLandscape
            }
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Failover" {
                opacity 25
            }
        }
    }
}
