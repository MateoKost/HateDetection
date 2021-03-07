dashUi <- function(id) {
        ns <- NS( id )
        fluidRow(
                tags$head( tags$style( HTML( '
                        .modal-dialog{overflow-y:auto; overflow-x: auto;}
                        .modal-lg {width:90%;}
                        .modal-body{ overflow-y: auto;overflow-x: auto;}
                        .taskBtn-blue:hover{background-color: #4E2FBD !important;}
                        .taskBtn-red:hover{background-color: #DB07AA !important;}
                        ')),
                           tags$script( setHeightScript )
                ),
                tabItems(
                        tabItem( class = "active",tabName = "tabAttitudeGUI",attitudeGUI(id)),
                        tabItem( tabName = "hateReplyGUI",
                                 fluidRow(
                                         style = 'padding: 15px !important;',
                                         column(width = 12,
                                                uiOutput('tabHateReplyUi')
                                         )
                                 )
                                 
                        ),
                        tabItem( tabName = "tabTimeGUI",
                                 fluidRow(
                                         style = 'padding: 15px !important;
                                                background-color: white;}',
                                         column(width = 12, class = "col-lg-6",
                                                uiOutput('tabTimeFiltersUi')
                                         ),
                                         fluidRow(
                                                 style = 'padding: 15px !important;',
                                                 column(width = 12,
                                                        uiOutput('tabTimeUi')
                                                 )
                                         )
                                 )
                        )
                ),
                bsModal( "modalExample", "Lista sklasyfikowanych wpisów", "showTable", size = "large",
                         dataTableOutput(ns("allSentiments"))
                ),
                bsModal( "modalExample2", "Lista sklasyfikowanych użytkowników", "showActorsTable", 
                         size = "large",
                         dataTableOutput(ns("allActors"))
                )
        )
}


attitudeGUI <- function( id ){
        ns <- NS( id )
        return(
        fluidRow(
                style = 'padding: 15px !important;background-color: white;}',
                column( width = 12, class = "col-lg-7",
                        valueBoxesGUI(id),
                        uiOutput('attitudeGUI'),
                ),
                column( width = 12, class = "col-lg-5",
                        bayesGUI(id),
                        
                        box(    width = 12,collapsible = TRUE,collapsed = FALSE,
                                style = "height:auto; overflow-y: auto;overflow-x: auto;",
                                title = "5 najbardziej aktywnych hejterów",
                                status = "danger",
                                tableOutput( ns('worst5Actorstable') ),
                                downloadButton(ns("dlActors"), "Pobierz listę",
                                               style = actionButtonStyle,class='taskBtn-blue',
                                               style = 'background-color:#3238A6;
                                                                padding-top:8px;'),
                                actionButton(
                                        "showActorsTable", "Wiecej...",
                                        style = actionButtonStyle,class='taskBtn-blue',
                                        style = 'background-color:#3238A6;',
                                        icon = icon("table")
                                )
                        ),
                        box(    width = 12,collapsible = TRUE,collapsed = TRUE,
                                style = "height:auto; overflow-y: auto;overflow-x: auto;",
                                title = "5 najmocniejszych hejtów",
                                status = "danger",
                                tableOutput( ns('worst5table') ),
                                downloadButton(ns("dl"), "Pobierz listę",class='taskBtn-blue',
                                               style = actionButtonStyle,
                                               style = 'background-color:#3238A6;
                                                                padding-top:8px;'),
                                actionButton(
                                        "showTable", "Wiecej...",
                                        style = actionButtonStyle,class='taskBtn-blue',
                                        style = 'background-color:#3238A6;',
                                        icon = icon("table")
                                )
                        ),
                ),
                
        ))
}

bayesGUI <- function( id ){
        ns <- NS( id )
        return(
        # fluidRow( 
        # column( width = 12, class = "col-lg-7",
                box(    width = 12, collapsible = TRUE,
                        title = "Klasyfikacja wpisów",
                        status = "warning",
                        plotlyOutput(ns('naiveBayesGraph'))
                )
        # )
)#)
}

valueBoxesGUI <- function( id ){
        ns <- NS( id )
        return(fluidRow(width = 12, style='padding: 15px !important;',
                column(width = 6,class = "col-lg-3",
                       valueBoxOutput(ns('valueBoxBadActors'), width=NULL),
                ),
                column(width = 6,class = "col-lg-3",
                       valueBoxOutput(ns('valueBoxActors'), width=NULL),
                ),
                column(width = 6,class = "col-lg-3",
                       valueBoxOutput(ns('valueBoxBadSentiments'), width=NULL),
                ),
                column(width = 6,class = "col-lg-3",
                       valueBoxOutput(ns('valueBoxSentiments'), width=NULL),
                )
        ))
        
}


setHeightScript <-  '
          setHeight = function() {
            var window_height = $(window).height();
            var header_height = $(".main-header").height();
            var boxHeight = window_height - header_height - 200;
            $("#graph_container").height(boxHeight);
            $("#plotSentimentGraph").height(boxHeight - 90);
            $("tabBox").height(boxHeight);
          };
          $(document).on("shiny:connected", function(event) { setHeight(); });
          $(window).on("resize", function(){ setHeight(); });
     '

