# Interactive Map Visualization App using Shiny and Leaflet - vkapur 03102024
# This script creates a Shiny application that allows users to upload geospatial data from an Excel file on the local computer,
# Visualizes the coordinates on a customizable map, and exports the map as an HTML document. It incorporates checks for package installation,
# User input validation, UI feedback, and dynamic initial map view based on the data's geographical extent.
# Required are at least two rows with different coordinates in in decimal degree (DD) format with "lat" and "lon" column heads.  A 'label' column is also required.

# Conditionally Load Libraries with Caching Check
conditionally_load_libraries <- function(packages) {
    for (package in packages) {
        if (!require(package, character.only = TRUE, quietly = TRUE)) {
            install.packages(package)
            library(package, character.only = TRUE)
        }
    }
}

# Load Required Libraries
required_packages <- c("shiny", "colourpicker", "leaflet", "readxl", "dplyr", "htmlwidgets")
conditionally_load_libraries(required_packages)

# UI with Enhanced Feedback and Jittering Slider
ui <- fluidPage(
    titlePanel("Interactive Map with Genotype-based Markers"),
    sidebarLayout(
        sidebarPanel(
            fileInput("file1", "Choose Excel File", accept = ".xlsx"),
            selectInput("mapType", "Select Map Type",
                        choices = c("OpenStreetMap", "OpenTopoMap", "Esri.NatGeoWorldMap", "CartoDB.Positron")),
            checkboxInput("showLabels", "Show Labels", TRUE),
            sliderInput("jitterFactor", "Jittering Factor", min = 0, max = 0.1, value = 0.01, step = 0.001),
            sliderInput("markerSize", "Marker Size", min = 1, max = 20, value = 6),
            uiOutput("genotypeColorsUI"), # Dynamic color pickers for genotypes
            uiOutput("genotypeToggle")    # Checkbox for toggling genotypes
        ),
        mainPanel(
            leafletOutput("map", height = "600px")
        )
    )
)

# Server Logic with User Input Validation and Dynamic Map View
server <- function(input, output, session) {
    # Function to jitter coordinates
    jitter_coordinates <- function(df, factor) {
        df %>%
            group_by(lon, lat) %>%
            mutate(
                count = n(),
                lon = ifelse(count > 1, lon + runif(n(), -factor, factor), lon),
                lat = ifelse(count > 1, lat + runif(n(), -factor, factor), lat)
            ) %>%
            ungroup()
    }
    
    data <- reactive({
        req(input$file1)
        df <- read_excel(input$file1$datapath)
        if (!all(c("lat", "lon", "Genotype", "label") %in% colnames(df))) {
            stop("The Excel file must contain 'lat', 'lon', 'Genotype', and 'label' columns.")
        }
        return(df)
    })
    
    genotypes <- reactive({
        df <- data()
        unique(df$Genotype)
    })

    output$genotypeColorsUI <- renderUI({
        gtypes <- genotypes()
        lapply(gtypes, function(g) {
            colourInput(inputId = paste0("color", g), label = paste("Color for", g), value = "#EB1212")
        })
    })
    
    output$genotypeToggle <- renderUI({
        gtypes <- genotypes()
        checkboxGroupInput("genotypeSelect", "Toggle Genotypes", choices = setNames(gtypes, gtypes), selected = gtypes)
    })
    
    output$map <- renderLeaflet({
        leaflet() %>%
            addProviderTiles("OpenStreetMap") %>%
            setView(lng = 78.9629, lat = 20.5937, zoom = 4)
    })
    
    observeEvent(input$mapType, {
        leafletProxy("map") %>%
            clearTiles() %>%
            addProviderTiles(input$mapType)
    })
    
    # Reactive expression for color palette
    colorPalette <- reactive({
        colors <- sapply(genotypes(), function(g) input[[paste0("color", g)]])
        names(colors) <- genotypes()
        function(x) {
            unname(colors[x])
        }
    })
    
    # Observe changes in data, selected genotypes, color inputs, or jittering factor
    observe({
        req(data(), input$genotypeSelect, input$jitterFactor)
        df <- data()
        selectedGenotypes <- input$genotypeSelect
        
        if(length(selectedGenotypes) == 0 || nrow(df) == 0) return()
        
        df <- df %>% 
            filter(Genotype %in% selectedGenotypes) %>%
            jitter_coordinates(factor = input$jitterFactor)  # Apply jittering with user-defined factor
        
        if(nrow(df) == 0) return()

        # Get the color palette function
        pal <- colorPalette()
        
        # Create a named vector of colors for the legend
        legendColors <- sapply(selectedGenotypes, function(g) input[[paste0("color", g)]])
        names(legendColors) <- selectedGenotypes

        leafletProxy("map", data = df) %>%
            clearMarkers() %>%
            addCircleMarkers(
                lng = ~lon, lat = ~lat,
                popup = ~paste(label, "<br>Genotype:", Genotype),  # Include genotype in popup
                radius = input$markerSize,
                color = ~pal(Genotype),
                fill = TRUE, fillColor = ~pal(Genotype), fillOpacity = 0.7,
                group = "Markers"
            ) %>%
            clearControls() %>%
            addLegend(
                position = "bottomright",
                colors = legendColors,
                labels = names(legendColors),
                title = "Genotypes",
                opacity = 1
            )
    })
}

# Run the Shiny app
shinyApp(ui, server)