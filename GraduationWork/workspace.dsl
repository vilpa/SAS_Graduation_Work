workspace "X-Customer Member Application" "C4 Model for Target Solution Architecture" {

/*
container <name> [description] [technology] [tags] {
    ...
}
*/
    model {
        user = person "Member User" "Member User using the application"
        admin = person "Member Administrator" "Member Admin user who manage account"
        puser = person "Proxy User" "X-Customer Admin user who view/manage account on behalf of Member user"
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
            
            webapp = container "Web Application" {
                technology "React"
                description "Delivers UI via Azure Front Door and CDN"
                tags "React, SPA"

                webauth = component "Authentication/Authorization" {
                    technology "React"
                    description "Handles SSO, role-based access, and permissions using claims-based auth integrated with external Identity Management (OAuth/SAML)"
                    tags "React, SPA, Auth"
                }

                webpref = component "Prefixes Branch" {
                    technology "React"
                    description "Displays and manages Prefix data, including capacity counters and linking to product/location creation"
                    tags "React, SPA"
                }

                webprod = component "Product Branch" {
                    technology "React"
                    description "Allows users to create, manage, and publish product records with GINs, barcodes, and hierarchies"
                    tags "React, SPA"
                }

                webloc = component "Location Branch" {
                    technology "React"
                    description "Allows users to create, manage, and publish location records with LNs and hierarchical relationships"
                    tags "React, SPA"
                }

                websearch = component "Search/Reporting Branch" {
                    technology "React"
                    description "Enables search, filtering, and reporting for Prefix, GIN, and LN data with export capabilities"
                    tags "React, SPA, Reporting"
                }

                webhelp = component "Help/Tutorials Branch" {
                    technology "React"
                    description "Provides contextual help and access to training materials such as videos and webinars"
                    tags "React, SPA"
                }

                webdash = component "Dashboard/Notifications" {
                    technology "React"
                    description "User home screen with alerts, pending tasks, usage counters, and user-specific updates"
                    tags "React, SPA, Dashboard"
                }

                webworkflow = component "Workflow Management" {
                    technology "React"
                    description "Handles record-level workflows for approval, status tracking, and locking mechanisms"
                    tags "React, SPA, Workflow"
                }

                webpublish = component "Publishing & Subscriptions" {
                    technology "React"
                    description "Allows users to publish and subscribe to record data visibility with granular permission settings"
                    tags "React, SPA, Sharing"
                }

                webimport = component "Import/Export" {
                    technology "React"
                    description "Enables bulk data import/export for products and locations using multiple formats with validation"
                    tags "React, SPA, Data"
                }

                webfeedback = component "Feedback Module" {
                    technology "React"
                    description "Captures user feedback routed to administrators or tracking systems"
                    tags "React, SPA, Feedback"
                }

                webaudit = component "Audit Trail Viewer" {
                    technology "React"
                    description "Displays user activity history, record changes, and transfer logs for transparency and compliance"
                    tags "React, SPA, Audit"
                }

                webauth -> webpref "authorize and redirect"
                webauth -> webprod "authorize and redirect"
                webauth -> webloc "authorize and redirect"
                webauth -> websearch "authorize and redirect"
                webauth -> webhelp "authorize and redirect"
                webauth -> webdash "authorize and redirect"
                webauth -> webworkflow "authorize and redirect"
                webauth -> webpublish "authorize and redirect"
                webauth -> webimport "authorize and redirect"
                webauth -> webfeedback "authorize and redirect"
                webauth -> webaudit "authorize and redirect"

                user -> webauth "Login"
                puser -> webauth "Login"
                admin -> webauth "Login"
                public -> webauth "Login"
            }

            api = container "API Layer" "REST APIs with .NET 8" "Main business logic and orchestration"
            
            userMgmt = container "User Management Service" "Role-based access, SSO integration" {
                ssoa = component "SSO Auth Handler" "Handles SSO authentication using OAuth2 and SAML protocols"
                flogin = component "Federated Login Adapter" "Manages authentication with external IdPs like Google, Microsoft, Okta"
                uprfm = component "User Profile Manager" "CRUD operations for user profiles and preferences"
                rbac = component "Role & Permission Engine" "Defines and enforces user roles and RBAC policies"
                pswm = component "Password Management Service" "Handles password reset, expiration policies, and recovery workflows"
                
                db = component "SQL Database" "User Management schema" "SQLServer" "Database"
            }

            sidecar = container "Sidecar" {
                technology ".NET 8"
                description "Shared utility functions such as Key Vault access, centralized logging, event-based notifications"
                tags "Core, Utility, Shared"

                secrets = component "Secrets Loader" "Fetches secrets/configs from Azure Key Vault"
                logger = component "Audit Logger" "Sends authentication and user change audit events"
                metrix = component "Metrics Exporter" "Pushes login and performance metrics to Azure Monitor"
                notification = component "Notification Dispatcher" "Sends password reset and other events to Notification Service"
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

            xsystem -> enterprise_identity "Federated login and authentication"
            xsystem -> sap "Integration via API"
            xsystem -> quickbooks "Integration via API"
            xsystem -> help_portal "Link to help and training content"

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

        component userMgmt "UserMgmtComponents" {
            include *
            autolayout
        }

        component webapp "WebAppComponents" {
            include *
            autoLayout lr 500 500
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
