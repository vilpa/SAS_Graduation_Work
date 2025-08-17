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
        apimAdmin = person "X-Customer Engineer" "General public accessing limited data, logging, management"

        enterprise_identity = softwareSystem "Enterprise Identity Provider" "Handles authentication via SSO, OAuth2, SAML"
        external_identity = softwareSystem "External IdPs (Google, Microsoft, Okta)" "Handles authentication via SSO, OAuth2, SAML"
        
        sap = softwareSystem "SAP" "External ERP system"
        quickbooks = softwareSystem "QuickBooks" "External financial system"

        azsystem = softwareSystem "Azure Services" {
            communicationServices   = container "Azure Communication Services" "ACS, tDevOps, Microsoft Azure - Azure Communication Services"
            logicApps               = container "Logic Apps" "Outbound webhooks/Teams/Slack" "LogicApps, tDevOps, Microsoft Azure - Logic Apps"
            functions               = container "Azure Functions" "Stateless processing" "Functions, tDevOps, Microsoft Azure - Function Apps"
            serviceBus              = container "Azure Service Bus" "Retry & DLQ queues" "ServiceBus, Queue, tDevOps, Microsoft Azure - Azure Service Bus"
            applicationInsights     = container "Application Insights" "Telemetry & metrics" "AppInsights, tDevOps, Microsoft Azure - Application Insights"
            cosmosDB                = container "Azure Cosmos DB" "Prefs, topics, templates" "CosmosDB, Database, tDevOps, tDBA, Microsoft Azure - Azure Cosmos DB"
            cosmosDBfeedbacks       = container "Azure Cosmos DB (feedbacks)" "Feedbacks" "CosmosDB, Database, tDevOps, tDBA, Microsoft Azure - Azure Cosmos DB"
            key_vault               = container "Azure Key Vault" "Secure secret and credential storage" "KeyVault, tDevOps, Microsoft Azure - Key Vaults"
            azure_monitor           = container "Azure Monitor" "Observability and metrics platform" "tDevOps, Microsoft Azure - Monitor"
            eventHubs               = container "Azure Event Hubs" "Scalable event streaming platform for ingesting and processing CDC and business events in near real-time" "EventHub, tDevOps, Microsoft Azure - Event Hubs"            
            eventHubs2              = container "Azure Event Hubs (CDC)" "Scalable event streaming platform for ingesting and processing CDC and business events in near real-time" "EventHub, tDevOps, Microsoft Azure - Event Hubs"            

            graph_db                = container "Graph Database (Cosmos DB Gremlin API)" "Stores hierarchical GIN structures" "CosmosDB, Database, tDevOps, tDBA, Microsoft Azure - Azure Cosmos DB"
            helpBlobStorage         = container "Azure Blob Storage" "Stores help videos, documents, and media assets for tutorials and training" "BlobStorage, tDevOps"
            
            // Lightweight Reporting Subsystem (ADX + Power BI)
            // Azure systems (if not already declared elsewhere)
            adx                     = container "Azure Data Explorer" "Fast time-series analytics over API usage (Kusto)" "ADX, tDevOps" 
            logAnalytics            = container "Azure Log Analytics" "Central store for APIM diagnostics and metrics (KQL)" "LogAnalytics, tDevOps"
            eventHubs3              = container "Azure Event Hubs (APIM)" "Optional streaming path for high-volume APIM diagnostics" "EventHub, tDevOps"
            powerBI                 = container "Power BI" "Self-service BI dashboards and scheduled reports" "PowerBI, tDBD"

            functions -> cosmosDB "reads changes from Cosmos"
            functions -> eventHubs "emits events"
            functions -> serviceBus "emits events"
        }

        xsystem = softwareSystem "X-Customer Member Application" {
            description "Modular platform to manage GIN, LN and shared data"
            
            webapp = container "Web Application" {
                technology "REST, React"
                description "Delivers UI via Azure Front Door and CDN"
                tags "React, SPA, Web Browser"

                webauth = component "Authentication/Authorization" {
                    technology "REST, React"
                    description "Handles SSO, role-based access, and permissions using claims-based auth integrated with external Identity Management (OAuth/SAML)"
                    tags "React, SPA, Web Browser, tDesing, tReact, Auth"
                }

                webpref = component "Prefixes Branch" {
                    technology "REST, React"
                    description "Displays and manages Prefix data, including capacity counters and linking to product/location creation"
                    tags "React, SPA, Web Browser, tDesing, tReact"
                }

                webprod = component "Product Branch" {
                    technology "REST, React"
                    description "Allows users to create, manage, and publish product records with GINs, barcodes, and hierarchies"
                    tags "React, SPA, Web Browser, tDesing, tReact"
                }

                webloc = component "Location Branch" {
                    technology "REST, React"
                    description "Allows users to create, manage, and publish location records with LNs and hierarchical relationships"
                    tags "React, SPA, Web Browser, tDesing, tReact"
                }

                websearch = component "Search/Reporting Branch" {
                    technology "REST, React"
                    description "Enables search, filtering, and reporting for Prefix, GIN, and LN data with export capabilities"
                    tags "React, SPA, Web Browser, tDesing, tReact, Reporting"
                }

                webhelp = component "Help/Tutorials Branch" {
                    technology "REST, React"
                    description "Provides contextual help and access to training materials such as videos and webinars"
                    tags "React, SPA, Web Browser, tDesing, tReact"
                }

                webdash = component "Dashboard/Notifications" {
                    technology "REST, React"
                    description "User home screen with alerts, pending tasks, usage counters, and user-specific updates"
                    tags "React, SPA, Web Browser, tDesing, tReact, Dashboard"
                }

                webworkflow = component "Workflow Management" {
                    technology "REST, React"
                    description "Handles record-level workflows for approval, status tracking, and locking mechanisms"
                    tags "React, SPA, Web Browser, tDesing, tReact, Workflow"
                }

                webpublish = component "Publishing & Subscriptions" {
                    technology "REST, React"
                    description "Allows users to publish and subscribe to record data visibility with granular permission settings"
                    tags "React, SPA, Web Browser, tDesing, tReact, Sharing"
                }

                webimport = component "Import/Export" {
                    technology "REST, React"
                    description "Enables bulk data import/export for products and locations using multiple formats with validation"
                    tags "React, SPA, Web Browser, tDesing, tReact, Data"
                }

                webfeedback = component "Feedback Module" {
                    technology "REST, React"
                    description "Captures user feedback routed to administrators or tracking systems"
                    tags "React, SPA, Web Browser, tDesing, tReact, Feedback"
                }

                webaudit = component "Audit Trail Viewer" {
                    technology "REST, React"
                    description "Displays user activity history, record changes, and transfer logs for transparency and compliance"
                    tags "React, SPA, Web Browser, tDesing, tReact, Audit"
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
            
            group "Core Services" {
                userMgmt = container "User Management Service" {
                    technology ".NET 8"
                    description "Role-based access, SSO integration"
                    tags "Core, Utility, Shared"

                    cprfm = component "Company Profile Manager" "CRUD operations for company profiles and preferences" ".NET 8" "tNet"
                    ssoa = component "SSO Auth Handler" "Handles SSO authentication using OAuth2 and SAML protocols" ".NET 8" "tNet"
                    flogin = component "Federated Login Adapter" "Manages authentication with external IdPs like Google, Microsoft, Okta" ".NET 8" "tNet"
                    uprfm = component "User Profile Manager" "CRUD operations for user profiles and preferences" ".NET 8" "tNet"
                    rbac = component "Role & Permission Engine" "Defines and enforces user roles and RBAC policies" ".NET 8" "tNet"
                    pswm = component "Password Management Service" "Handles password reset, expiration policies, and recovery workflows" ".NET 8" "tNet"
                    
                    udbs = component "SQL Database" "User Management schema" "SQLServer" "Database, tDBA, tDBD" 

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

                    pfstore = component "Prefix Store" "Manages CRUD operations for company prefixes and associated metadata" ".NET 8" "tNet"
                    capctr = component "Capacity Tracker" "Tracks numeric indicator usage (GINs/LNs) and available capacity per prefix" ".NET 8" "tNet"
                    prefxval = component "Prefix Validator" "Validates prefix format and compliance with business rules" ".NET 8" "tNet"
                    pfpubsub = component "Prefix Publish & Subscribe Engine" "Manages visibility and sharing of prefix data with other members" ".NET 8" "tNet"
                    pfsearch = component "Prefix Search Service" "Handles advanced search, filtering, and lookup for prefix-related data" ".NET 8" "tNet"
                    pfimport = component "Prefix Import/Export Adapter" "Imports/exports prefix records in formats like CSV, XML, Excel" ".NET 8" "tNet"

                    pdbs = component "SQL. Prefix Management Schema" "Prefix Management schema for storing licensed prefixes, attributes, and usage data" "SQLServer" "Database, tDBD, tDBA"

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

                    ginstore = component "GIN Store" "CRUD operations for product records and associated GINs" ".NET 8" "tNet"
                    ginassign = component "GIN Assignment Engine" "Automatically or manually assigns unique GINs with check-digit validation" ".NET 8" "tNet"
                    ginval = component "GIN Validator" "Ensures GINs and product attributes conform to X-Customer standards" ".NET 8" "tNet"
                    ginhier = component "Hierarchy Manager" "Builds and manages GIN hierarchies (e.g., each -> case -> pallet) including visual tools" ".NET 8" "tNet"
                    ginimg = component "Image Attachment Service" "Handles product image uploads, association, and formatting" ".NET 8" "tNet"
                    ginexport = component "Export & Sheet Generator" "Exports GINs, generates Product Information Sheets, and barcodes in various formats" ".NET 8" "tNet"
                    ginshare = component "Publish & Transfer Module" "Controls data publishing, ownership transfer, and sharing for GIN records" ".NET 8" "tNet"
                    ginimport = component "GIN Import Adapter" "Supports record import via Excel, CSV, XML with validation and deduplication" ".NET 8" "tNet"
                    barcodegen = component "Barcode Generator" "Generates and exports standard-compliant barcodes (e.g., Code128, QR, DataMatrix) for GINs in image formats like PNG, SVG, PDF" ".NET 8" "tNet"

                    ggdb = component "Graph Database" "Stores product records, GINs, attributes, images, and hierarchy metadata" "Cosmos DB" "Database, tDBD, tDBA"
                    
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
                    ginassign -> barcodegen "generates barcodes"

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

                    lnstore = component "Location Store" "CRUD operations for location records and associated LNs" ".NET 8" "tNet"
                    lnassign = component "LN Assignment Engine" "Automatically or manually assigns unique LNs with check-digit validation" ".NET 8" "tNet"
                    lnval = component "Location Validator" "Ensures LNs and location attributes meet format and business standards" ".NET 8" "tNet"
                    lnhier = component "Hierarchy Manager" "Creates and manages LN hierarchies with flexible levels and visual UI" ".NET 8" "tNet"
                    lnimport = component "Location Import Adapter" "Supports location record import via Excel, CSV, XML, with validation and deduplication" ".NET 8" "tNet"
                    lnexport = component "Export & Reporting Module" "Handles exporting, filtering, sorting, and audit of location records" ".NET 8" "tNet"
                    lnshare = component "Publish & Transfer Module" "Manages record publishing, subscription permissions, and ownership transfers" ".NET 8" "tNet"
                    lnver = component "Annual Verification Engine" "Tracks and enforces annual verification of location records" ".NET 8" "tNet"

                    lgdb = component "Graph Database" "Stores location records, LNs, hierarchy structures, and verification logs" "Cosmos DB" "Database, tDBD, tDBA"
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

                accessData = container "Access Data Service" {
                    technology ".NET 8"
                    description "Provides search, view, subscription, and export functionality for shared Prefix, GIN, and LN data"
                    tags "Core, Consumer, Search"

                    adsearch = component "Access Search Engine" "Performs advanced search and filtering across Prefix, GIN, and LN datasets" ".NET 8" "tNet"
                    adview = component "Record Viewer" "Displays record details, including basic/full data and hierarchy" ".NET 8" "tNet"
                    adsub = component "Subscription Manager" "Handles subscription requests for accessing full record views" ".NET 8" "tNet"
                    adgroup = component "Group Access Controller" "Processes join requests for controlled access groups" ".NET 8" "tNet"
                    adexport = component "Export Adapter" "Exports selected records to formats like CSV, Excel, XML, and prints" ".NET 8" "tNet"
                    adaccess = component "Access Rights Evaluator" "Determines data access level based on user's subscription, group membership, or public access" ".NET 8" "tNet"
                    adpay = component "Ad-hoc Access Info Module" "Informs users about external payment options for access (outside of system)" ".NET 8" "tNet"
                    
                    esdb = component "Read-Optimized Vector Database" "Indexed subset of shared Prefix, GIN, and LN records, optimized for fast queries" "Elasticsearch" "Database, tDBD, tDBA"                     
                    /*
                    kv = component "Key Vault Reader" "Retrieves secure config such as API keys or export format settings" "Azure Key Vault" "Infrastructure"
                    */

                    // External Interactions
                    adsearch -> esdb "queries shared Prefix, GIN, and LN records"
                    adsearch -> adaccess "filters search results by access rights"

                    adview -> esdb "loads record details and hierarchy"
                    adview -> adaccess "determines full or basic view"
                    adview -> adgroup "displays group membership info if restricted"
                    adview -> adsub "offers option to request full access"

                    adaccess -> rbac "retrieves user roles and permissions"
                    adaccess -> pfpubsub "verifies prefix-level sharing"
                    adaccess -> ginshare "retrieves published GINs and hierarchies"
                    adaccess -> lnshare "retrieves published LN records and hierarchies"

                    adsub -> rbac "identifies requesting user"
                    adgroup -> rbac "validates group membership"
                    
                    adexport -> esdb "retrieves and formats selected records"
                    adexport -> adaccess "ensures user has export permissions"
                    /*
                    adexport -> kv "fetches supported export formats"
                    */

                    adpay -> rbac "verifies non-member status"
                    adpay -> adview "displays payment message if full access is blocked"
                    /*
                    adsearch -> auditTrail "logs search queries"
                    adview -> auditTrail "logs view events"
                    adexport -> auditTrail "logs export activity"
                    */
                }
                
                sidecar = container "Sidecar" {
                    technology ".NET 8"
                    description "Shared utility functions such as Key Vault access, centralized logging, event-based notifications"
                    tags "Core, Utility, Shared"

                    secrets = component "Secrets Loader" "Fetches secrets/configs from Azure Key Vault" ".NET 8" "tNet"
                    logger = component "Audit Logger" "Sends authentication and user change audit events" ".NET 8" "tNet"
                    metrix = component "Metrics Exporter" "Pushes login and performance metrics to Azure Monitor" ".NET 8" "tNet"
                    notification = component "Notification Dispatcher" "Sends password reset and other events to Notification Service" ".NET 8" "tNet"

                    secrets -> key_vault
                    logger -> azure_monitor
                    metrix -> azure_monitor
                    notification -> serviceBus "emmits events"
                    serviceBus -> notification "listents to subscriptions"
                    metrix -> applicationInsights "Telemetry & metrics"
                }
            }

            apiGateway = container "API Gateway" {
                technology "Azure API Management"
                description "Central entry point for all RESTful APIs; enforces policies, routing, throttling, monitoring, and legacy 3Scale migration"
                tags "Infrastructure, Gateway, Azure"

                configmgr = component "3Scale Config Migrator" "Migrates existing API definitions, plans, rate limits, and policies from 3Scale to Azure API Management" "APIM" "tDevOps"
                routing = component "API Router" "Routes requests to internal services (GIN, Location, Prefix, Access Data, User Mgmt) based on path, method, and version" "APIM" "tDevOps"
                policy = component "Policy Enforcement Engine" "Applies throttling, quota, CORS, caching, IP filtering, and JWT validation policies" "APIM" "tDevOps"
                analytics = component "Telemetry & Analytics Module" "Captures request metrics, logs, errors, and usage analytics for monitoring and reporting" "APIM" "tDevOps"
                docportal = component "Developer Portal" "Provides auto-generated API documentation, testing sandbox, and subscription access to consumers" "APIM" "tDevOps"

                // External Consumers
                // apiGateway -> publicConsumer "allows public and registered users to access shared data"
                // apiGateway -> partnerSystem "supports integration with external trading/retail partners via secure APIs"
                
                // Internal Services
                // routing -> ginMgmt "routes product-related API calls"
                // routing -> locationMgmt "routes location-related API calls"
                // routing -> prefixMgmt "routes prefix-related API calls"
                // routing -> accessData "routes search and subscription calls"
                // routing -> userMgmt "routes authentication and profile management APIs"

                // Other Interactions
                configmgr -> apimAdmin "used by devops team to execute migration scripts from 3Scale to Azure"
                policy -> rbac "validates user tokens and claims (OAuth2, SAML)"
            }

            indexing = container "Search Indexing Pipeline" {
                technology "Azure Functions / .NET 8"
                description "Consumes CDC events, denormalizes to search docs, and bulk-indexes to Elasticsearch"
                tags "Integration, ETL, Search"

                sub = component "Event Consumer" "Consumes gin.* and location.* from Event Hubs" ".NET 8" "tNet"
                xform = component "Denormalizer" "Flattens graph hierarchies & selected attributes into search-friendly documents" ".NET 8" "tNet"
                dedup = component "Idempotency Store" "Tracks processed event IDs/versions to ensure exactly-once semantics" "Redis, .NET 8" "Cache, tDevOps"
                bulk = component "Elasticsearch Bulk Indexer" "Batches writes/updates/deletes to Elasticsearch with backoff and DLQ" ".NET 8" "tNet"

                ises = component "Elasticsearch Cluster" "Read-optimized indices: prefixes, gins, lns (+ alias per version)" "Elasticsearch" "Database, tDevOps"
                dlq = component "Dead Letter Queue" "Unprocessable events for replay/inspection" "Azure Storage Queue" "Queue, tDevOps"

                // Links
                indexing -> eventHubs "subscribes to events"
                sub -> xform "passes event payloads"
                xform -> dedup "checks/records event version"
                xform -> bulk "sends upserts/deletes"
                bulk -> ises "bulk API"
                sub -> dlq "sends failed events"
            }
            
            notify = container "Notification Service" {
                technology ".NET 8"
                description "Handles all notifications and preferences"
                tags "Core, Utility, Shared"

                notifEventConsumer = component "EventHub Consumer" "Consumes domain/system events and converts them into notification intents" ".NET 8" "Notification, Ingest, tNet"
                notifOrchestrator = component "Notification Orchestrator" "Routes intents to channels, applies routing rules, and coordinates multi-channel fan-out" ".NET 8" "Notification, Core, tNet"
                notifPreferenceManager = component "Preference & Opt-In Manager" "Stores per-user/company preferences, opt-ins, quiet hours, and frequency settings" ".NET 8" "Notification, Privacy, tNet"
                notifRetryDLQ = component "Retry & DLQ Processor" "Retries transient failures and moves poison messages to dead letter queue" ".NET 8" "Notification, Reliability, tNet"
                notifDeliveryTracker = component "Delivery Status & Bounce Tracker" "Tracks sends, opens, clicks, bounces, and complaints; updates user/channel health" ".NET 8" "Notification, Metrics, tNet"
                notifEmailAdapter = component "Email Adapter" "Sends emails via SMTP/SendGrid with templating and attachments support" ".NET 8" "Notification, Channel, Email, tNet"
                notifSmsAdapter = component "SMS Adapter" "Sends text messages via Twilio/Azure Communication Services" ".NET 8" "Notification, Channel, SMS, tNet"
                notifWebhookAdapter = component "Webhook/ChatOps Adapter" "Delivers messages to Slack/Teams/webhooks for operational alerts" ".NET 8" "Notification, Channel, Webhook, tNet"
                notifScheduler = component "Digest & Scheduling Service" "Schedules digests, reminders, and time-windowed deliveries" ".NET 8" "Notification, Scheduling, tNet"

                notifEventConsumer -> notifOrchestrator "routes through the appropriate delivery workflows"
                notifEventConsumer -> notifRetryDLQ "sends failed events for later processing"

                notifEmailAdapter -> communicationServices "Email delivery"
                notifSmsAdapter   -> communicationServices "SMS delivery"
                notifWebhookAdapter -> logicApps "Outbound webhooks/Teams/Slack"

                // Ingest, orchestration, and reliability
                eventHubs -> notifEventConsumer "Event ingress (domain/system)"
                notifOrchestrator  -> functions "Stateless processing"
                notifScheduler     -> logicApps "Scheduling & digests"                 
                
                // Config, security, observability, data
                notifPreferenceManager -> cosmosDB "Prefs, topics, templates"

                pswm -> notify "Azure Service Bus Event. Notify user via email/SMS about password changes"
                pfpubsub -> notify "Azure Service Bus Event. Notify user via email/SMS about prefix changes"
                ginMgmt -> notify "sends notifications for status updates, duplicates, errors"
                ginstore -> notify "sends user notifications"
                lnver -> notify "sends verification reminders to users"
                accessData -> notify "sends notifications for new subscriptions, approvals, or record updates"
                adsub -> notify "sends request to data owner"
                adgroup -> notify "notifies group owner if request submitted"
            }

            feedback = container "Help & Feedback Service" {
                description "Routes user feedback, shows help links"
                technology ".NET 8"
                tags "Core, Reporting"

                helpContentManager = component "Help Content Manager" "CRUD operations for help articles, FAQs, and tutorial metadata" ".NET 8" "Help, Content, tNet"
                helpSearchEngine = component "Help Search Engine" "Indexes help content and enables keyword/topic-based search" ".NET 8" "Help, Search, tNet"
                helpContextResolver = component "Contextual Help Resolver" "Determines and displays relevant help content based on the user's current module or action" ".NET 8" "Help, Context, tNet"
                helpLocalizationEngine = component "Help Localization Engine" "Provides localized help content in multiple languages" ".NET 8" "Help, Localization, tNet"
                feedbackCollector = component "Feedback Collector" "Captures user feedback from the UI, including comments, ratings, and issue reports" ".NET 8" "Feedback, Capture, tNet"
                feedbackRouter = component "Feedback Router" "Routes feedback to administrators or appropriate service teams" ".NET 8" "Feedback, Routing, tNet"
                feedbackAnalytics = component "Feedback Analytics" "Aggregates and analyzes feedback for trends, satisfaction scores, and improvement areas" ".NET 8" "Feedback, Analytics, tNet"
                feedbackNotification = component "Feedback Notification" "Sends alerts to admins when new feedback or critical issues are submitted" ".NET 8" "Feedback, Notification, tNet"
                helpApi = component "Help & Feedback API" "Provides REST endpoints for retrieving help content and submitting feedback" ".NET 8" "Help, API, tNet"
            
                helpApi -> helpContentManager "retrieves and manages help articles and tutorials"
                helpApi -> helpSearchEngine "performs keyword and topic-based help searches"
                helpApi -> helpContextResolver "fetches context-specific help content"
                helpApi -> helpLocalizationEngine "serves localized help content to users"
                helpApi -> feedbackCollector "submits user feedback through UI/API"

                helpContentManager -> helpLocalizationEngine "provides localized versions of help content"
                helpContentManager -> helpBlobStorage "stores and retrieves help videos, documents, and other media assets"

                helpSearchEngine -> helpContentManager "indexes new or updated help content"
                helpSearchEngine -> helpLocalizationEngine "indexes localized help content"

                helpContextResolver -> helpContentManager "retrieves relevant help content"
                helpContextResolver -> helpSearchEngine "queries for matching articles based on context"

                feedbackCollector -> feedbackRouter "routes feedback to appropriate admins or teams"
                feedbackCollector -> feedbackAnalytics "provides raw feedback data for aggregation"
                feedbackCollector -> cosmosDBfeedbacks "upserts feedback documents"

                feedbackRouter -> feedbackNotification "triggers alerts for new or critical feedback"

                feedbackAnalytics -> feedbackNotification "sends reports or alerts based on aggregated feedback"
            }

            integration = container "Integration Gateway" { 
                description "Gateway to third-party systems (SAP, QuickBooks)" 
                technology ".NET 8"
                tags "Core, Reporting"

                igApi = component "Integration Gateway API" "Centralized API interface for importing/exporting records with external systems" ".NET 8" "Integration, API, tNet"
                igSapAdapter = component "SAP Adapter" "Handles data exchange with SAP for product, location, and prefix records; supports IDoc/XML/JSON formats" ".NET 8" "Integration, SAP, tNet"
                igQuickBooksAdapter = component "QuickBooks Adapter" "Manages data synchronization with QuickBooks Online/Desktop for product and location records" ".NET 8" "Integration, QuickBooks, tNet"
                igMappingEngine = component "Data Mapping & Transformation Engine" "Transforms internal GIN/LN/Prefix schema to and from external system formats" ".NET 8" "Integration, Transformation, tNet"
                igValidationEngine = component "Validation & Compliance Engine" "Validates incoming external data against X-Customer standards and business rules" ".NET 8" "Integration, Validation, tNet"
                igScheduler = component "Integration Scheduler" "Schedules batch imports/exports and coordinates asynchronous data sync jobs" ".NET 8" "Integration, Scheduling, tNet"
                igEventPublisher = component "Change Event Publisher" "Publishes internal change events to external systems via webhooks, APIs, or message queues" ".NET 8" "Integration, Eventing, tNet"
                igErrorHandler = component "Error Handling & Retry Manager" "Captures integration errors, retries transient failures, and logs issues for review" ".NET 8" "Integration, Reliability, tNet"

                integration -> accessData "import and export shared Prefix, GIN, and LN data for external systems"

                // Internal links
                igApi -> igMappingEngine "transform internal schema to external formats and vice versa"
                igApi -> igValidationEngine "enforce X-Customer standards and business rules on payloads"
                igApi -> igScheduler "schedule batch imports/exports and async sync jobs"
                igApi -> igEventPublisher "publish change events/webhooks to external subscribers"
                igApi -> igErrorHandler "route transient/permanent integration errors for handling"

                igMappingEngine -> igSapAdapter "invoke SAP-specific connectors with mapped payloads"
                igMappingEngine -> igQuickBooksAdapter "invoke QuickBooks-specific connectors with mapped payloads"

                igSapAdapter -> igErrorHandler "retry/backoff on SAP connectivity or validation failures"
                igQuickBooksAdapter -> igErrorHandler "retry/backoff on QuickBooks connectivity or validation failures"

                // External system links
                igSapAdapter -> sap "exchange product/location data via IDoc/XML/JSON over SAP PI/PO or SAP API Management"
                sap -> igSapAdapter "push inbound updates (IDoc/webhook) for import"

                igQuickBooksAdapter -> quickbooks "synchronize product/location data via QuickBooks Online/Desktop APIs/SDK"
                quickbooks -> igQuickBooksAdapter "push inbound changes via webhooks/callbacks for import"
            }

            reports = container "Reporting Service" {
                description "Near real-time API usage analytics using Log Analytics → ADX, served via Power BI"
                technology "ADX, Power BI"
                tags "Reporting, Azure"

                apimDiag = component "APIM Diagnostic Settings" "Emits request logs, metrics, and traces" "APIM, Diagnostics" "tDevOps"
                laExport = component "Log Analytics Exporter" "Continuous export from Log Analytics to ADX tables" "KQL, Export" "tDevOps"
                evhIngest = component "Event Hub Ingest (optional)" "Alternative path: APIM → Event Hubs → ADX ingestion batching" "Streaming, Optional" "tDevOps"
                adxDb = component "ADX Database & Tables" "Kusto DB with tables: Requests, Aggregates, Errors; retention + caching policies" "ADX, Kusto" "tDevOps, tDBD, tDBA"
                adxFuncs = component "ADX Update Policies" "Materialize rollups (hour/day/week), parse URL paths, compute percentiles" "ADX, Policies" "tDevOps, tDBD, tDBA"
                rptModels = component "Power BI Semantic Model" "Datasets/Measures (RLS by company/role); scheduled or DirectQuery to ADX" "PowerBI, Dataset" "tDevOps, tDBD, tDBA"
                rptDash = component "Power BI Reports & Dashboards" "Usage heatmaps, latency SLAs, error breakdowns; embeddable in SPA" "PowerBI, Reports" "tDevOps, tDBD, tDBA"


                reports -> eventHubs2 "export statistics and analytics of GIN and Location usage by users and companies"

                // Links from API Gateway (APIM) to analytics
                apiGateway -> apimDiag "send request/response logs and metrics (diagnostic settings)"
                apimDiag -> logAnalytics "write API logs to Log Analytics"
                apimDiag -> eventHubs3 "stream diagnostics to Event Hubs (optional high-volume path)"

                // Log Analytics → ADX
                logAnalytics -> laExport "continuous export (KQL-based) to ADX tables"

                // Event Hubs → ADX (optional)
                eventHubs3 -> evhIngest "subscribe and batch to ADX ingestion commands"
                evhIngest -> adxDb "write to Kusto tables"

                // Inside ADX
                laExport -> adxDb "ingest curated API usage data"
                adxDb -> adxFuncs "apply update policies/materialized aggregates"
                adxFuncs -> adxDb "persist rollups to aggregate tables"

                // Serving to BI
                adxDb -> rptModels "DirectQuery or import via ADX connector"
                rptModels -> rptDash "serve curated measures and visuals"
                rptDash -> powerBI "publish/refresh dashboards and embed tokens"
            }

            xsystem -> enterprise_identity "Federated login and authentication"

            webapp -> apiGateway "Communicates via REST"
        }
    
        development = deploymentEnvironment "Development" {

            deploymentNode "Azure Subscription - X-Customer" {
                tags "Azure, Microsoft Azure - Subscriptions"

                deploymentNode "Azure Region - Primary (East US)" {
                    tags "Microsoft Azure - Region Management"


                    deploymentNode "Virtual Network" {
                        tags "Microsoft Azure - Virtual Networks"
                    
                    
                        deploymentNode "APIM subnet" {
                            tags "Microsoft Azure - Virtual Networks"
                    
                            // Ingress
                            deploymentNode "Azure API Management (APIM)" {
                                tags "Microsoft Azure - API Management Services"
                                // routes external partner calls to Integration Gateway API
                                containerInstance apiGateway
                            }

                            deploymentNode "Cosmos DB" {
                                tags "Azure Cosmos DB, Microsoft Azure - Azure Cosmos DB"
                                // routes external partner calls to Integration Gateway API
                                containerInstance cosmosDB
                            }
                        }

                        deploymentNode "Services subnet" {
                            tags "Microsoft Azure - Virtual Networks"

                            // Compute tier for Integration Gateway
                            deploymentNode "AKS Cluster - ig-aks" {
                                tags "AKS, Kubernetes, Compute"

                                containerInstance integration
                            }
                        }

/*
            communicationServices   = container "Azure Communication Services" "ACS, tDevOps, Microsoft Azure - Azure Communication Services"
            logicApps               = container "Logic Apps" "Outbound webhooks/Teams/Slack" "LogicApps, tDevOps, Microsoft Azure - Logic Apps"
            functions               = container "Azure Functions" "Stateless processing" "Functions, tDevOps, Microsoft Azure - Function Apps"
            serviceBus              = container "Azure Service Bus" "Retry & DLQ queues" "ServiceBus, Queue, tDevOps, Microsoft Azure - Azure Service Bus"
            applicationInsights     = container "Application Insights" "Telemetry & metrics" "AppInsights, tDevOps, Microsoft Azure - Application Insights"
            cosmosDB                = container "Azure Cosmos DB" "Prefs, topics, templates" "CosmosDB, Database, tDevOps, tDBA, Microsoft Azure - Azure Cosmos DB"
            cosmosDBfeedbacks       = container "Azure Cosmos DB (feedbacks)" "Feedbacks" "CosmosDB, Database, tDevOps, tDBA, Microsoft Azure - Azure Cosmos DB"
            key_vault               = container "Azure Key Vault" "Secure secret and credential storage" "KeyVault, tDevOps, Microsoft Azure - Key Vaults"
            azure_monitor           = container "Azure Monitor" "Observability and metrics platform" "tDevOps, Microsoft Azure - Monitor"
            eventHubs               = container "Azure Event Hubs" "Scalable event streaming platform for ingesting and processing CDC and business events in near real-time" "EventHub, tDevOps, Microsoft Azure - Event Hubs"            
            eventHubs2              = container "Azure Event Hubs (CDC)" "Scalable event streaming platform for ingesting and processing CDC and business events in near real-time" "EventHub, tDevOps, Microsoft Azure - Event Hubs"            

            graph_db                = container "Graph Database (Cosmos DB Gremlin API)" "Stores hierarchical GIN structures" "CosmosDB, Database, tDevOps, tDBA, Microsoft Azure - Azure Cosmos DB"
            helpBlobStorage         = container "Azure Blob Storage" "Stores help videos, documents, and media assets for tutorials and training" "BlobStorage, tDevOps"
            
            // Lightweight Reporting Subsystem (ADX + Power BI)
            // Azure systems (if not already declared elsewhere)
            adx                     = container "Azure Data Explorer" "Fast time-series analytics over API usage (Kusto)" "ADX, tDevOps" 
            logAnalytics            = container "Azure Log Analytics" "Central store for APIM diagnostics and metrics (KQL)" "LogAnalytics, tDevOps"
            eventHubs3              = container "Azure Event Hubs (APIM)" "Optional streaming path for high-volume APIM diagnostics" "EventHub, tDevOps"
            powerBI                 = container "Power BI" "Self-service BI dashboards and scheduled reports" "PowerBI, tDBD"

*/
                    }
                }
                deploymentNode "Monitoring" {
                    deploymentNode "Azure Monitor" {
                        tags "Microsoft Azure - Monitor"
                        containerInstance azure_monitor 
                    }
                    deploymentNode "Application Insights" {
                        tags "Microsoft Azure - Application Insights"
                        containerInstance applicationInsights 
                    }
                }
            }
        }
    }

    views {
        systemcontext xsystem "SystemContext" {
            include *
            autolayout
        }

        systemcontext azsystem "AzSystemContext" {
            include *
        }
        
        container xsystem "ContainerDiagram" {
            include *
            exclude logAnalytics eventHubs3 powerBI azsystem
        }

        container azsystem "AzContainerDiagram" {
            include *
        }

        component userMgmt "UserMgmtComponents" {
            include *
            exclude accessData ginMgmt locationMgmt
        }

        component prefixMgmt "PrefixMgmtComponents" {
            include *
            exclude locationMgmt userMgmt
        }

        component webapp "WebAppComponents" {
            include *
        }

        component ginMgmt "GinMgmtComponents" {
            include *
            exclude notify
        }

        component locationMgmt "LocationMgmtComponents" {
            include *
            exclude userMgmt
        }

        component accessData "AccessDataComponents" {
            include *
            exclude "locationMgmt -> userMgmt"
            exclude "locationMgmt -> ginMgmt"
            exclude "locationMgmt -> prefixMgmt"
            exclude "locationMgmt -> accessData"
            exclude "locationMgmt -> notify"

            exclude "ginMgmt -> userMgmt"
            exclude "ginMgmt -> prefixMgmt"
            exclude "ginMgmt -> accessData"
            exclude "ginMgmt -> notify"
            exclude "ginMgmt -> locationMgmt"

            exclude "userMgmt -> ginMgmt"
            exclude "userMgmt -> prefixMgmt"
            exclude "userMgmt -> accessData"
            exclude "userMgmt -> notify"
            exclude "userMgmt -> locationMgmt"

            exclude "prefixMgmt -> ginMgmt"
            exclude "prefixMgmt -> userMgmt"
            exclude "prefixMgmt -> accessData"
            exclude "prefixMgmt -> notify"
            exclude "prefixMgmt -> locationMgmt"

            exclude "userMgmt -> locationMgmt"
        }

        component indexing "IndexingES" {
            include *
        }

        component notify "NotificationService" {
            include *
        }

        component sidecar "SideCar" {
            include *
        }

        component apiGateway "ApiGateWay" {
            include *
        }

        component feedback "HelpAndFeedback" {
            include *
        }

        component integration "IntegrationGateway" {
            include *
        }

        component reports "ReportingModule" {
            include *
        }
        
        deployment * development {
            include *
        }
        
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
            element "KeyVault" {
                background #1168bd
                color #ffffff
                shape Folder
            }
            element "Queue" {
                shape Pipe
            }
        }
    
        theme https://static.structurizr.com/themes/microsoft-azure-2021.01.26/theme.json
    }
}
