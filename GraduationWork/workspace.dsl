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
                tags "React, SPA, Web Browser"

                webauth = component "Authentication/Authorization" {
                    technology "React"
                    description "Handles SSO, role-based access, and permissions using claims-based auth integrated with external Identity Management (OAuth/SAML)"
                    tags "React, SPA, Web Browser, Auth"
                }

                webpref = component "Prefixes Branch" {
                    technology "React"
                    description "Displays and manages Prefix data, including capacity counters and linking to product/location creation"
                    tags "React, SPA, Web Browser"
                }

                webprod = component "Product Branch" {
                    technology "React"
                    description "Allows users to create, manage, and publish product records with GINs, barcodes, and hierarchies"
                    tags "React, SPA, Web Browser"
                }

                webloc = component "Location Branch" {
                    technology "React"
                    description "Allows users to create, manage, and publish location records with LNs and hierarchical relationships"
                    tags "React, SPA, Web Browser"
                }

                websearch = component "Search/Reporting Branch" {
                    technology "React"
                    description "Enables search, filtering, and reporting for Prefix, GIN, and LN data with export capabilities"
                    tags "React, SPA, Web Browser, Reporting"
                }

                webhelp = component "Help/Tutorials Branch" {
                    technology "React"
                    description "Provides contextual help and access to training materials such as videos and webinars"
                    tags "React, SPA, Web Browser"
                }

                webdash = component "Dashboard/Notifications" {
                    technology "React"
                    description "User home screen with alerts, pending tasks, usage counters, and user-specific updates"
                    tags "React, SPA, Web Browser, Dashboard"
                }

                webworkflow = component "Workflow Management" {
                    technology "React"
                    description "Handles record-level workflows for approval, status tracking, and locking mechanisms"
                    tags "React, SPA, Web Browser, Workflow"
                }

                webpublish = component "Publishing & Subscriptions" {
                    technology "React"
                    description "Allows users to publish and subscribe to record data visibility with granular permission settings"
                    tags "React, SPA, Web Browser, Sharing"
                }

                webimport = component "Import/Export" {
                    technology "React"
                    description "Enables bulk data import/export for products and locations using multiple formats with validation"
                    tags "React, SPA, Web Browser, Data"
                }

                webfeedback = component "Feedback Module" {
                    technology "React"
                    description "Captures user feedback routed to administrators or tracking systems"
                    tags "React, SPA, Web Browser, Feedback"
                }

                webaudit = component "Audit Trail Viewer" {
                    technology "React"
                    description "Displays user activity history, record changes, and transfer logs for transparency and compliance"
                    tags "React, SPA, Web Browser, Audit"
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

                webauth -> enterprise_identity "authenticates user"
                webauth -> external_identity "authenticates user"

                user -> webauth "Login"
                puser -> webauth "Login"
                admin -> webauth "Login"
                public -> webauth "Login"
            }
            
            api = container "API Layer" "REST APIs with .NET 8" "Main business logic and orchestration"

            messaging = container "Messaging Bus" "Azure Service Bus/Event Grid" "Asynchronous messaging"
            monitor = container "Monitoring Stack" "Azure Monitor, App Insights, Log Analytics"
            
            group "Core Services" {
                userMgmt = container "User Management Service" {
                    technology ".NET 8"
                    description "Role-based access, SSO integration"
                    tags "Core, Utility, Shared"

                    cprfm = component "Company Profile Manager" "CRUD operations for company profiles and preferences" ".NET 8"
                    ssoa = component "SSO Auth Handler" "Handles SSO authentication using OAuth2 and SAML protocols" ".NET 8"
                    flogin = component "Federated Login Adapter" "Manages authentication with external IdPs like Google, Microsoft, Okta" ".NET 8"
                    uprfm = component "User Profile Manager" "CRUD operations for user profiles and preferences" ".NET 8"
                    rbac = component "Role & Permission Engine" "Defines and enforces user roles and RBAC policies" ".NET 8"
                    pswm = component "Password Management Service" "Handles password reset, expiration policies, and recovery workflows" ".NET 8"
                    
                    udbs = component "SQL Database" "User Management schema" "SQLServer" "Database" 

                    # userMgmt internal dependencies
                    cprfm -> udbs "SQL via ORM. Store/retrieve company profile info"
                    ssoa -> flogin "Delegates to appropriate external IdP based on login request"
                    ssoa -> uprfm "Retrieves or creates user profile post-authentication"
                    uprfm -> rbac "Resolves user’s role to determine access rights"
                    pswm -> uprfm "Updates/reset passwords and recovery tokens"

                    # userMgmt external dependencies
                    ssoa -> enterprise_identity "OAuth2/SAML. Authenticate user identity"
                    flogin -> external_identity "OpenID Connect/SAML. Support federated login flows"
                    uprfm -> udbs "SQL via ORM. Store/retrieve user profile info"
                }
    
                prefixMgmt = container "Prefix Management Service" {
                    technology ".NET 8"
                    description "Handles prefix licensing, capacity tracking, and lookup for GIN and LN creation"
                    tags "Core, Data"

                    pfstore = component "Prefix Store" "Manages CRUD operations for company prefixes and associated metadata" ".NET 8"
                    capctr = component "Capacity Tracker" "Tracks numeric indicator usage (GINs/LNs) and available capacity per prefix" ".NET 8"
                    prefxval = component "Prefix Validator" "Validates prefix format and compliance with business rules" ".NET 8"
                    pfpubsub = component "Prefix Publish & Subscribe Engine" "Manages visibility and sharing of prefix data with other members" ".NET 8"
                    pfsearch = component "Prefix Search Service" "Handles advanced search, filtering, and lookup for prefix-related data" ".NET 8"
                    pfimport = component "Prefix Import/Export Adapter" "Imports/exports prefix records in formats like CSV, XML, Excel" ".NET 8"

                    pdbs = component "SQL. Prefix Management Schema" "Prefix Management schema for storing licensed prefixes, attributes, and usage data" "SQLServer" "Database"

                    // External Interactions
                    pfstore -> rbac "authorize prefix access"
                    
                    cprfm -> pfstore "assigns prefixes"
                    pfstore -> pdbs "SQL via ORM. Store/retrieve prefix info"
                    pfsearch -> pdbs "search prefix info" 
                    pfimport -> pdbs "bulk insert"
                    prefxval -> capctr "tracks usage IDs"
                    pfimport -> prefxval "bulk validator"
                    uprfm -> cprfm "Assossiates users to company "

                    /*
                    prefixMgmt -> accessData "shares prefix data for search & viewing"
                    prefixMgmt -> productMgmt "provides prefix data for GIN generation"
                    prefixMgmt -> locationMgmt "provides prefix data for LN generation"
                    prefixMgmt -> notifService "sends notifications for usage thresholds, validation errors"
                    prefixMgmt -> auditTrail "logs all prefix updates and access events"
                    */
                }

                ginMgmt = container "GIN Management Service" {
                    technology ".NET 8"
                    description "Manages creation, editing, hierarchy, and sharing of Global Item Numbers (GINs) and associated product metadata"
                    tags "Core, Product"

                    ginstore = component "GIN Store" "CRUD operations for product records and associated GINs" ".NET 8"
                    ginassign = component "GIN Assignment Engine" "Automatically or manually assigns unique GINs with check-digit validation" ".NET 8"
                    ginval = component "GIN Validator" "Ensures GINs and product attributes conform to X-Customer standards" ".NET 8"
                    ginhier = component "Hierarchy Manager" "Builds and manages GIN hierarchies (e.g., each -> case -> pallet) including visual tools" ".NET 8"
                    ginimg = component "Image Attachment Service" "Handles product image uploads, association, and formatting" ".NET 8"
                    ginexport = component "Export & Sheet Generator" "Exports GINs, generates Product Information Sheets, and barcodes in various formats" ".NET 8"
                    ginshare = component "Publish & Transfer Module" "Controls data publishing, ownership transfer, and sharing for GIN records" ".NET 8"
                    ginimport = component "GIN Import Adapter" "Supports record import via Excel, CSV, XML with validation and deduplication" ".NET 8"
                    barcodegen = component "Barcode Generator" "Generates and exports standard-compliant barcodes (e.g., Code128, QR, DataMatrix) for GINs in image formats like PNG, SVG, PDF" ".NET 8"

                    ggdb = component "Graph Database" "Stores product records, GINs, attributes, images, and hierarchy metadata" "SQLServer" "Database"

                    // External Interactions
                    ginMgmt -> capctr "updates prefix capacity after GIN assignment"
                    ginMgmt -> rbac "authorizes user access to product data"

                    // Internal Interactions
                    ginstore -> ginassign "requests GIN assignment and status tracking"
                    ginstore -> ginval "validates record data before save"
                    ginstore -> ginimg "links and stores associated product images"
                    ginstore -> ginhier "creates or updates hierarchy references"
                    ginstore -> ginexport "generates printable product sheets and barcodes"
                    ginstore -> ginshare "handles publish and transfer requests"
                    ginstore -> ginimport "persists imported records"

                    ginassign -> pfstore "fetches prefix and range"
                    ginassign -> capctr "updates prefix usage after assignment"
                    ginassign -> ginval "verifies GIN uniqueness and structure"
                    ginassign -> ggdb "writes assigned GINs"

                    ginval -> ggdb "cross-checks existing data for duplicates"

                    ginimport -> ginval "validates imported records"
                    ginimport -> ginassign "assigns GINs if required"
                    ginimport -> ginstore "stores validated records"

                    ginexport -> ggdb "fetches records for export"
                    ginexport -> ginimg "retrieves image attachments"

                    ginshare -> rbac "verifies permissions for publishing"

                    ginhier -> ggdb "reads and writes hierarchy relationships"
                    ginhier -> ginval "validates hierarchy constraints (e.g., size/weight)"  
                }

                locationMgmt = container "Location Management Service" {
                    technology ".NET 8"
                    description "Manages creation, editing, hierarchy, and sharing of Location Numbers (LNs) and related location metadata"
                    tags "Core, Location"

                    lnstore = component "Location Store" "CRUD operations for location records and associated LNs"
                    lnassign = component "LN Assignment Engine" "Automatically or manually assigns unique LNs with check-digit validation"
                    lnval = component "Location Validator" "Ensures LNs and location attributes meet format and business standards"
                    lnhier = component "Hierarchy Manager" "Creates and manages LN hierarchies with flexible levels and visual UI"
                    lnimport = component "Location Import Adapter" "Supports location record import via Excel, CSV, XML, with validation and deduplication"
                    lnexport = component "Export & Reporting Module" "Handles exporting, filtering, sorting, and audit of location records"
                    lnshare = component "Publish & Transfer Module" "Manages record publishing, subscription permissions, and ownership transfers"
                    lnver = component "Annual Verification Engine" "Tracks and enforces annual verification of location records"

                    lgdb = component "Graph Database" "Stores location records, LNs, hierarchy structures, and verification logs" "Cosmos DB" "Database"
                    /*
                    kv = component "Key Vault Reader" "Securely retrieves configuration and business rule secrets" "Azure Key Vault" "Infrastructure"
                    */

                    // External Interactions
                    locationMgmt -> ginMgmt "shares associated location references for product records"

                    ginMgmt -> locationMgmt "associates location data with product records"

                    // Internal Interaction
                    lnstore -> lnassign "requests LN assignment during creation"
                    lnstore -> lnval "validates location record data before save"
                    lnstore -> lnhier "links records into hierarchy structure"
                    lnstore -> lnimport "stores validated imported records"
                    lnstore -> lnexport "provides data for export and reporting"
                    lnstore -> lnshare "manages publish and ownership actions"
                    lnstore -> lnver "tracks verification status"

                    lnassign -> pfstore "retrieves prefix allocation and rules"
                    lnassign -> capctr "updates LN usage statistics"
                    lnassign -> lnval "validates uniqueness and structure"
                    lnassign -> lgdb "stores assigned LNs"

                    lnval -> lgdb "checks for duplicates and formatting constraints"

                    lnimport -> lnval "validates imported data"
                    lnimport -> lnassign "assigns LNs if required"
                    lnimport -> lnstore "persists data"

                    lnexport -> lgdb "retrieves and formats location records"
                    lnexport -> lnhier "includes hierarchical context in exports"

                    lnshare -> rbac "checks user permissions for publishing"
                    lnver -> lgdb "stores verification flags and logs"
                }


                accessData = container "Data Access Service" {
                    description "Search/view/subscribe to published data"
                    technology ".NET 8"
                    tags "Core, DataAccess"

                    pfpubsub -> accessData "publishes prefix data for external view"
                    ginshare -> accessData "exposes data to subscribers"
                    lnshare -> accessData "exposes location data for viewing"
                }
                
                notify = container "Notification Service" {
                    technology ".NET 8"
                    description "Handles all notifications and preferences"
                    tags "Core, Utility, Shared"

                    pswm -> notify "Azure Service Bus Event. Notify user via email/SMS about password changes"
                    pfpubsub -> notify "Azure Service Bus Event. Notify user via email/SMS about prefix changes"
                    ginMgmt -> notify "sends notifications for status updates, duplicates, errors"
                    ginstore -> notify "sends user notifications"
                    lnver -> notify "sends verification reminders to users"
                }

                reports = container "Reporting Service" "Scheduled reports, audit, usage logs"
                feedback = container "Help & Feedback Service" "Routes user feedback, shows help links"
                integration = container "Integration Gateway" "Gateway to third-party systems (SAP, QuickBooks)"

                sidecar = container "Sidecar" {
                    technology ".NET 8"
                    description "Shared utility functions such as Key Vault access, centralized logging, event-based notifications"
                    tags "Core, Utility, Shared"

                    secrets = component "Secrets Loader" "Fetches secrets/configs from Azure Key Vault" ".NET 8"
                    logger = component "Audit Logger" "Sends authentication and user change audit events" ".NET 8"
                    metrix = component "Metrics Exporter" "Pushes login and performance metrics to Azure Monitor" ".NET 8"
                    notification = component "Notification Dispatcher" "Sends password reset and other events to Notification Service" ".NET 8"

                    secrets -> key_vault
                    logger -> azure_monitor
                    metrix -> azure_monitor
                    notification -> messaging "emmits events"
                    messaging -> notification "listents to subscriptions"
                }

                prefixMgmt -> secrets "retrieves validation rules or schema secrets from Key Vault"
            }

            xsystem -> enterprise_identity "Federated login and authentication"
            xsystem -> sap "Integration via API"
            xsystem -> quickbooks "Integration via API"
            xsystem -> help_portal "Link to help and training content"

            webapp -> api "Communicates via REST"
            
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

        component prefixMgmt "PrefixMgmtComponents" {
            include *
            autolayout
        }

        component webapp "WebAppComponents" {
            include *
        }

        component ginMgmt "GinMgmtComponents" {
            include *
            autolayout
        }

        component locationMgmt "LocationMgmtComponents" {
            include *
            autolayout
        }
/*
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
                background #08427b
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
