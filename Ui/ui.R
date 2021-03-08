source( "Ui/dashUi.R", encoding = "UTF-8" )

ui <- function(id) {
ns <- NS( id )
        
  dashboardPage(
    skin = 'purple',
    dashboardHeader(
      title = "Wykrywanie zagrożeń",
      tags$li(
        class = 'dropdown', style = 'display: flex;',
        a( "GitHub", href = "https://github.com/MateoKost/HateDetection",
           target = "_blank" )
      ),
      tags$li(
        class = 'dropdown', style = 'display: flex;',
        a( "Kaggle", href = "https://www.kaggle.com/mateuszkostrzewski/polish-twitter-sentiments",
           target = "_blank" )
      )
    ),
    dashboardSidebar(
            useShinyjs(),
      uiOutput("srcUi"),
            sidebarMenu(
                    id = "User Name2",
                    actionButton(
                            "startBtn2", "Eksploruj", width='200px', class = 'taskBtn-red',
                            style = actionButtonStyle, icon = icon("chart-bar"),
                    )
            ),
      uiOutput('tabsMenuUiOutput')
    ), 
    dashboardBody(
      dashUi(id),

       fluidRow("WCYI7B2S1 Mateusz Kostrzewski 2020",
                style = 'color:white;text-align: center;')
    ),
    tags$head(tags$style(HTML('* {font-family: "Arial";}.taskBtn-red:hover{background-color: #DB07AA !important;}

                              ')))
  )
}


actionButtonStyle <- '
            background-color:#F2134F;
            height:40px;
            border: none;
            color: white;
            text-align: center;
            text-decoration: none;
            font-size: 16px;
            '

brandStyle <- '
            font-size: 45px;
            color:white;
            text-transform: uppercase;
            font-weight:bold;
            font-family: Tahoma, sans-serif;
            letter-spacing: -1.5px;
            text-align: center;'



