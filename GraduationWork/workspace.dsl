workspace "Memas" "Member Application Solution" {
    model {
        #Actors
        itsupport = person "IT Support" "a" "Person"
        employee  = person "Employee" "" "Person"
        travelDepartment = person "Travel Department"  "" "Person"
        hotelSuppliers = person "Hotel Suppliers" "" "Person"
        transportSuppliers = person "Transport Suppliers" "" "Person"
        

        #External Systems
        sap = softwareSystem "SAP" "" "External System"
        quickbooks = softwareSystem "QuickBooks" "Accounting Software Package" "External System"
        appInsights = softwareSystem "Application Insights" "Monitors application-level logs and performance metrics" "External System"
        ssoSystem = softwareSystem "EPAM SSO System" "Provides Single Sign-On (SSO) authentication, enabling secure and seamless access for employees, suppliers, and travel managers across all portals. Ensures centralized user identity management and access control" "External System"
        emailSystem = softwareSystem "Email System" "Sends email notifications for booking confirmations, approvals, cancellations, and system updates" "External System"
        smsSystem = softwareSystem "SMS Gateway System" "Sends SMS alerts for critical notifications such as booking confirmations, rejections, or urgent travel updates" "External System"
        cosmosDB = softwareSystem "Event Store" "Stores structured data for reporting, ensuring efficient retrieval and generation of analytical insights" "Database"        
        database = softwareSystem "Database" "Stores structured data for policies, rules,regional requirements, ensuring efficient retrieval available items" "Database"
        transportBooking = softwareSystem "External Transport Booking System" "Allows users to search, compare, and book transport options in real-time" "External System"
        hotelBooking = softwareSystem "External HotelBooking System" "Searches, books, and manages hotel reservations outside of an organization's internal system" "External System"
        searchSystem = softwareSystem "Search as a Service" "Azure AI Search. Index, search, and rank data. Enables location-based searches" "External System"

        #Internal System
        memasSystem = softwareSystem "Member Application Solution" "Software System" "Tracks Hotel and Transport booking.Allows access for employees, travel department, suppliers to manage confirmed bookings" {
            #SPA
            itSupportSpaContainer = container "IT support SPA" "A management interface for IT administrators to monitor, troubleshoot, and configure system components, ensuring availability and security compliance" "Container: React"
            employeePortalSpaContainer = container "Employees Portal SPA" "Allows employees to view, manage, and confirm hotel and transport bookings. Provides seamless SSO access and feedback submission" "Container: React" 

            suppliersPortalSpaContainer = container "Suppliers Portal SPA" "A web interface for third-party hotel and transport suppliers to manually upload booking availability, pricing, and other details. Supports manual booking handling" "Container: React" 

            #Services
            productServiceContainer = container "Product Service" "Enables data owners to create, manage, and permission GIN data for product launches and inventory management." "Container: .NET Core, Azure Functions"
            notificationServiceContainer = container "Notification Service" "Manages and dispatches system notifications, ensuring timely alerts for booking status changes and approvals" "Container: .NET Core, Azure Functions"
            policiesConfigServiceContainer = container "Policies Configuration Service" {
                description "A service responsible for managing system configurations, business rules, and policy changes dynamically, ensuring flexibility and adaptability" 
                technology  "Container: NET Core, Azure Function"

                polApiController = component "API Controllers" {
                    description "REST endpoints to configure and query policies"
                    technology "ASP.NET Core Web API"
                }

                ruleEditor = component "Rule Management Module" {
                    description "UI logic for defining and updating policy rules"
                }

                configManager = component "Policy Configuration Manager" {
                    description "Handles saving, validating and versioning of policy settings"
                }

                polRepo = component "Configuration Repository" {
                    description "Persists rules and settings"
                    technology "Azure Cosmos DB or App Configuration"
                }

                validationEngine = component "Validation Engine" {
                    description "Validates rule logic and detects conflicts"
                }

                polRepo -> database "Policies and Rules [CRUD]"

                polApiController -> ruleEditor "Triggers configuration flow"
                ruleEditor -> configManager "Saves/updates rules via"
                configManager -> validationEngine "Validates policy data"
                configManager -> polRepo "Reads/Writes to"

            }

            trxServiceContainer = container "Transaction Engine Service" "Handles requests processing, booking transactions, and financial reporting to ensure accurate and secure financial operations" "Container: NET Core, Azure Function" {
                apiController = component "API Controllers" {
                    description "REST endpoints to handle SPA requests"
                    technology "ASP.NET Core Web API"
                }

                commandHandlers = component "Command Handlers" {
                    description "Handle commands like CreateBooking"
                    technology "MediatR"
                }

                eventHandlers = component "Event Handlers" {
                    description "Handle domain and integration events"
                }

                domainLogic = component "Business Logic Implementation" {
                    description "Implements booking rules, workflows"
                }

                repo = component "Database Repository" {
                    description "Persist booking and transport states"
                    technology "SQL DB"
                }

                eventStore = component "Event Store Repository" {
                    description "Stores domain events"
                    technology "Cosmos DB append-only store"
                }

                changeFeedListener = component "Cosmos DB Feed Processor" {
                    description "Triggers domain logic on data changes"
                }

                integrations = component "External Services Integration" {
                    description "Handles calls to CTC, UPSA"
                    technology "REST Clients"
                }

                cosmosDB -> changeFeedListener "Listen to"
                eventStore -> cosmosDB

                apiController -> commandHandlers "Dispatches commands to"
                apiController -> domainLogic "Delegates to"
                commandHandlers -> domainLogic "Uses"
                domainLogic -> repo "Persists data using"
                repo -> database
                domainLogic -> eventStore "Publishes domain events"
                changeFeedListener -> eventHandlers "Triggers"
                eventHandlers -> domainLogic "Executes logic"
                eventHandlers -> integrations "Sends/receives data from"

                # travelMangersPortalSpaContainer -> apiController "Get transactions data [REST]"
                itSupportSpaContainer -> apiController "Get dashboard data,set configuration [REST]"        
                employeePortalSpaContainer -> apiController "Set transactions data, track statuses [REST]"
                
                domainLogic -> polApiController "Gets transactions policies"

            }

            bookingServiceContainer = container "Booking Service" "Manages hotel bookings by integrating with third-party hotel suppliers, processing availability, pricing, and manual uploads" "Container: NET Core, Azure Function"
            
            reportingServiceContainer = container "Reporting Service" "Generates reports related to bookings, suppliers, financial transactions, and user activities" "Container: .NET Core, PowerBI"
            reactorServiceContainer = container "Reactor Service" "Aggregates reports related data to bookings, suppliers, financial transactions, and user activities" "Container: NET Core, Azure Function" 
            transportServiceContainer = container "Transport  Service" "Handles integration with transport providers like Uber, managing ride bookings, pickup/drop-off locations, and transport availability" "Container: NET Core, Azure Function" 
            hotelServiceContainer = container "Hotel Service" "Manages hotel bookings by integrating with third-party hotel suppliers, processing availability, pricing, and manual uploads" "Container: NET Core, Azure Function"
            hotelTransportSuppliersServiceContainer = container "Hotel & Transport Suppliers Service" "Manages hotel bookings by integrating with third-party hotel suppliers, processing availability, pricing, and manual uploads" "Container: NET Core, Azure Function"

            travelMangersPortalSpaContainer = container "Travel mangers Portal SPA"  {
                description "A dedicated SPA for travel managers to oversee, approve, and manage bookings, configure system rules, and generate reports for cost tracking and optimization" 
                technology "Container: React"
                
                bookingView = component "Booking Management View" {
                    description "Displays, edits and manages booking statuses"
                }

                supplierView = component "Supplier Configuration View" {
                    description "Manages supplier data uploads and overrides"
                }

                policyView = component "Policy Rules Configuration View" {
                    description "UI to manage booking and prioritization rules"
                }

                reportingView = component "Reporting Dashboard" {
                    description "Displays financial and supplier booking reports"
                }

                apiGateway = component "Backend API Gateway / BFF" {
                    description "Forwards API requests to backend services"
                    technology ".NET BFF or API Gateway"
                }

                bookingView -> apiGateway "Sends booking actions"
                supplierView -> apiGateway "Sends supplier updates"
                policyView -> apiGateway "Manages policy rules"
                reportingView -> apiGateway "Fetches report data"
                apiGateway -> apiController

            }

        }

        #Relationships
        #Users
        itsupport -> itSupportSpaContainer "Uses"
        itsupport -> appInsights "View Logs, Dashboards"
        employee  -> employeePortalSpaContainer "Uses"
        travelDepartment  -> travelMangersPortalSpaContainer "Uses"
        hotelSuppliers  -> suppliersPortalSpaContainer "Uses"
        transportSuppliers  -> suppliersPortalSpaContainer "Uses"

        #Systems
        sap -> productServiceContainer "Create, Manage Data"
        quickbooks -> productServiceContainer "Create, Manage Data"
        productServiceContainer -> sap "Import Data"
        productServiceContainer -> quickbooks "Import Data"
        
        memasSystem -> appInsights "Metrix, Logs, Streams"

        itSupportSpaContainer -> ssoSystem "Login, Consent"
        ssoSystem -> itSupportSpaContainer "JWT"
        
        employeePortalSpaContainer -> ssoSystem "Login, Consent"
        ssoSystem -> employeePortalSpaContainer "JWT"
        
        travelMangersPortalSpaContainer -> ssoSystem "Login, Consent"
        travelMangersPortalSpaContainer -> polApiController "Set policies data and flow configuration REST"
        travelMangersPortalSpaContainer -> reportingServiceContainer "Get BI reports"
        travelMangersPortalSpaContainer -> bookingServiceContainer "Modifying, canceling travel bookings,retrieving availability, pricing information REST"
        ssoSystem -> travelMangersPortalSpaContainer "JWT"

        suppliersPortalSpaContainer -> ssoSystem "Login, Consent"
        ssoSystem -> suppliersPortalSpaContainer "JWT"

        notificationServiceContainer -> emailSystem "Sends email [SMTP]"
        notificationServiceContainer -> smsSystem "Sends messages [REST, HTTP]"

        reactorServiceContainer -> database "Update projections materialized views"
        database -> reportingServiceContainer "Queries"

        bookingServiceContainer -> transportServiceContainer "Check availability, book transportation, update transport details for a reservation"
        bookingServiceContainer -> hotelServiceContainer "Check room availability, reserve rooms, or update booking details"
        bookingServiceContainer -> hotelTransportSuppliersServiceContainer "Check availability,reservation,update booking details"
        bookingServiceContainer -> cosmosDB "Updating reservations, confirming reservations, updating booking status"
    
        hotelTransportSuppliersServiceContainer -> database "Room, transport details,policies, availability [CRUD]"
        hotelTransportSuppliersServiceContainer -> searchSystem 

        hotelServiceContainer -> searchSystem
        hotelServiceContainer -> hotelBooking "Real-time data, booking, and updates"
    
        transportServiceContainer -> transportBooking "Real-time data, booking, and updates"
    }

    views {
        systemContext memasSystem {
            
            include itsupport
            include employee
            include travelDepartment
            include hotelSuppliers
            include transportSuppliers
            
            #External Systems
            include appInsights
            include ssoSystem
            include emailSystem
            include smsSystem
            include transportBooking
            include hotelBooking
            include searchSystem
            include sap
            include quickbooks

            #Internal System
            include memasSystem

            autoLayout
        }

        container memasSystem {
            include itsupport
            include employee
            include travelDepartment
            include hotelSuppliers
            include transportSuppliers
            
            #External Systems
            include appInsights
            include ssoSystem
            include emailSystem
            include smsSystem
            include transportBooking
            include hotelBooking
            include searchSystem
            include sap
            include quickbooks

            #Internal System
            include itSupportSpaContainer
            include employeePortalSpaContainer
            include travelMangersPortalSpaContainer
            include suppliersPortalSpaContainer

            #Services
            include notificationServiceContainer
            include policiesConfigServiceContainer
            include trxServiceContainer
            include productServiceContainer

            include bookingServiceContainer
            
            include reportingServiceContainer
            include reactorServiceContainer
            include transportServiceContainer
            include hotelServiceContainer
            include hotelTransportSuppliersServiceContainer

            autoLayout
        }

        component "trxServiceContainer" {
            include *
            autoLayout
        }

        component "policiesConfigServiceContainer" {
            include *
            autoLayout
        }

        component "travelMangersPortalSpaContainer" {
            include *
            autoLayout
        }

        styles {
            element "Person" {
                color #ffffff
                fontSize 22
                shape Person
            }
            element "Customer" {
                background #686868
            }
            element "Bank Staff" {
                background #08427B
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External System" {
                background #686868
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