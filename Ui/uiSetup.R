startUi <- function( input, output, session ) {
        renderUI({
                sidebarMenu(
                id = 'rdataSM',
                fileInput(
                        "rdataFile",
                        label = "Wybierz plik .RData",
                        accept = ".RData",
                        buttonLabel = "Otwórz...",
                        multiple = FALSE,
                        placeholder = "Nie wybrano"
                ),
                tags$style("
               .btn-file { background-color:#F2134F; color:white;}
               .progress-bar { background-color: #F2134F;}
          "
                )
                )
        })
}


tabsMenuUi <- function( input, output, session ) {
        renderUI({
                sidebarMenu(
                        id='analysisTabsMenu',
                        menuItem( "Nastroje", tabName = "tabAttitudeGUI", icon = icon("pie-chart") ),
                        menuItem("Analiza czasowa", icon = icon("user-times"), tabName = "tabTimeGUI"),
                        menuItem("Hate - odpowiedź", icon = icon("reply"), tabName = "hateReplyGUI")       
                )
        })
}

timeFiltersUi <- function( input, output, session, id, neg_nets  ) {
        ns <- NS( id )
        favGroups <- c('top','popular','low','none')
        arrangeParameters <- c(
                                'Liczba negatywnych wpisów'='nhates',
                                'Stosunek hejtów do liczby wypowiedzi w cyklu'='hates_ratio',
                                'Liczba wypowiedzi w badanym cyklu'='nsentiments', 
                                'Liczba obserwatoróW'='followers_count',
                                'Liczba wpisów od utworzenia konta'= 'statuses_count'
                              )
        ascParameters <- c('desc')
        renderUI({
                box( width=12,title = "Parametry sortowania ",
                     status = "primary", collapsible = TRUE,
                     fluidRow(
                             column(width=6,
                                    numericInput("numberHaters", "Liczba:", value=5, step=1),   
                             ),
                             column(width=6,
                                    selectInput(
                                            'selectedGroup', 'Grupa popularności:', choices = favGroups,
                                            selected = favGroups[1]
                                    ),
                             )
                     ),
                     fluidRow(
                             column(width=6,
                                    selectInput(
                                            'arrP1', 'Pierwszy parametr:', choices = arrangeParameters,
                                            selected = arrangeParameters[1]
                                    ),   
                                    checkboxInput(
                                            'ascP1', 'Sortuj rosnąco', FALSE
                                    )
                             ),
                             column(width=6,
                                    selectInput(
                                            'arrP2', 'Drugi parametr:', choices = arrangeParameters,
                                            selected =  arrangeParameters[2]
                                    ),
                                    checkboxInput(
                                            'ascP2', 'Sortuj rosnąco', FALSE
                                    )
                             )
                     ),
                     actionButton(
                             "applyFitlers", "Zastosuj filtry", 
                             icon = icon("caret-right"),
                             width='200px', class = 'taskBtn-blue',
                             style = actionButtonStyle,
                             style = 'background-color:#3238A6;'
                     )
                     
                )
        })
        
}


timeUi <- function( input, output, session, id, neg_nets  ) {
        ns <- NS( id )
        renderUI({
                lapply(seq_along(neg_nets), function(i) {
                        simple_net<-neg_nets[[i]]
                        simple_user<-simple_net$user
                        box(    width = 12,
                                title = paste0(i,'. Historia wpisów użytkownika ',simple_user$screen_name),
                                status = "primary",
                                collapsible = TRUE,
                                fluidRow(
                                        column( width = 12, class = "col-lg-6",
                                                plotOutput(ns(paste0('timeGraph',i)))
                                        ),
                                        column( width = 12, class = "col-lg-6",
                                                box(  
                                                        status = "danger",width = 12,
                                                        title = "Negatywne wpisy użytkownika",
                                                        collapsible = TRUE,
                                                        tableOutput(ns(paste0('timeData',i))),
                                                ),
                                                box(  
                                                        status = "info",width = 12,
                                                        title = "Histogram wag przyległych krawędzi",
                                                        collapsible = TRUE, collapsed=TRUE,
                                                        plotOutput(ns(paste0('timeStrength',i))) 
                                                )
                                                
                                        )
                                )
                        )
                        
                        
                })
        })
}

hateReplyUi <- function( input, output, session, id, replyNets  ) {
        ns <- NS( id )
        renderUI({
                lapply(seq_along( replyNets ), function(i) {
                        box(    width = 12,
                                # id = "graph_container", 
                                title = paste0(i,'. Klaster z cyklem'),
                                status = "primary",
                                collapsible = TRUE,
                                fluidRow(
                                        column( width = 12, class = "col-lg-6",
                                                plotOutput(height='80vh', ns(paste0('hateReply',i))) 
                                        ),
                                        column( width = 12, class = "col-lg-6",
                                                tableOutput(ns(paste0('hateReplySensData',i)))
                                        )
                                )
                        )
                        
                        
                })
        })
}

attitudeUI <- function( input, output, session, id, sentiment_graphs  ) {
        ns <- NS( id )
        tabNames<-lapply(seq_along(sentiment_graphs), function(i) {
                simple_net <- sentiment_graphs[[i]]
                simple_net$day
        })
        renderUI({
                do.call(tabBox, c(
                        id = ns("graph_container"),
                        title = "Graf nastrojów",
                        # status = "primary",
                        # height = "250px",
                        selected = tabNames[[1]],
                        width=12,
                        # height='1000px',
                        lapply(seq_along(sentiment_graphs), function(i) {
                                tabPanel(
                                        paste0(tabNames[[i]]),
                                                plotOutput(height='80vh',ns(paste0('attitudeGraph',i)))    
                                         
                                )
        
                        })
                )
                )
        })
}

