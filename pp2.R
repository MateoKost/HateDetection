library(shiny)
source("Setup/sources.R")

ui <-
dashboardPage(
        skin = 'purple',
        dashboardHeader(
                title = "Wykrywanie zagrożeń" 
                # tags$li(
                #   class = 'dropdown', style = 'display: flex;',
                #   actionLink( 'manual', "Instrukcja", icon = NULL ),
                #   a( "GitHub", href = "https://github.com/MateoKost/inz_R", 
                #      target = "_blank" ),
                #   actionLink( 'contact', "Kontakt", icon = NULL )
                # )
        ),
        dashboardSidebar(
                # uiOutput("srcUi"),
                # uiOutput("downloadClassifiedData"),
                # uiOutput('tabsMenuUiOutput')
        ), 
        dashboardBody(
                # dashUi(),
                fluidRow("WCYI7B2S1 Mateusz Kostrzewski 2020",
                         style = 'color:white;text-align: center;')
        ),
        tags$head(tags$style(HTML('* {font-family: "Arial";}.taskBtn-red:hover{background-color: #DB07AA !important;}

                              ')))
)

server <- function( input, output, session ) {
}


shinyApp( ui, server )