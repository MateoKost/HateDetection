valueBoxes <- function( input, output, session, sentiments, users ) {
        output$valueBoxBadActors <- renderValueBox({ valueBox( 
                         users %>% filter( category=='N' ) %>% nrow(),
                        'Aktorów negatywnych', icon = icon("user"), color = "maroon")
        })
        
        output$valueBoxBadSentiments <- renderValueBox({ valueBox( 
                        sentiments %>% filter( category=='N' ) %>% nrow(),
                        'Negatywnych wpisów', icon = icon("thumbs-down"), color = "maroon")
        })
        
        output$valueBoxSentiments <- renderValueBox({ valueBox( 
                sentiments %>% filter( category=='U' ) %>% nrow(),
                'Neutralnych wpisów', icon = icon("thumbs-up"), color = "purple")
        })
        
        output$valueBoxActors <- renderValueBox({ valueBox( 
                users %>% filter( category=='U' ) %>% nrow(),
                'Neutralnych użytkowników', icon = icon("user"), color = "purple")
        })
}

