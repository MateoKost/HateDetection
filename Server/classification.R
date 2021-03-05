negativeSentiments <- function( input, output, session, sentiments ) {
        output$worst5table <- renderTable( width = "auto", height = "auto", {
                sentiments %>% filter( category=='N' ) %>% arrange(  desc( score ), desc( favorite_count ) ) %>% 
                select( user_id,text, score, favorite_count ) %>% 
                setNames( c('Użytkownik','Treść','L.neg.wyrazów','L.polubień')) %>% 
                head( 5 )
        })
      
        output$dl <- downloadHandler(
          filename = function() { paste("top_hates-", Sys.Date(), ".csv", sep="") },
          content = function(file) {
            my_workbook <- createWorkbook()
            
            addWorksheet(
              wb = my_workbook, sheetName = "Negatywne wpisy"
            )

            writeData(
              my_workbook,
              sheet = 1,
              sentiments,
              startRow = 1,
              startCol = 1
            )

            saveWorkbook(my_workbook, file)
          }
        )
        
        output$allSentiments <- renderDataTable(
          sentiments %>% arrange( category, desc( score ), desc( favorite_count ) ) %>%
          select( 
                  user_id,
                  created_at,text, category, score, favorite_count )%>%
          setNames( c(#'Id',
                 'Użytkownik',   
                  'Data utworzenia','Treść','Nastawienie','L.neg.wyrazów','L.polubień')),
          options = list( pageLength=5, lengthChange = TRUE,
                                      columnDefs = list(list( width = '40vw',
                                                              targets = 2 ))) )
        
}

negativeActors <- function( input, output, session, users ) {
  output$worst5Actorstable <- renderTable( width = "auto", height = "auto", {
      users %>% 
      filter( category=='N' )  %>% 
      arrange( desc( nhates ), desc( hates_ratio ) ) %>%  
      select( user_id, favGroup, nhates, nsentiments, hates_ratio ) %>% 
      setNames( c('Użytkownik','Popularność','L. hejtów', 'L. wpisów','Proporcja')) %>% 
      head( 5 )
     
  })
  
  
  output$dlActors <- downloadHandler(
    filename = function() { paste("top_haters-", Sys.Date(), ".csv", sep="") },
    content = function(file) {
      my_workbook <- createWorkbook()
      
      addWorksheet(
        wb = my_workbook, sheetName = "Negatywne wpisy"
      )
      
      writeData(
        my_workbook,
        sheet = 1,
        users,
        startRow = 1,
        startCol = 1
      )
      
      saveWorkbook(my_workbook, file)
    }
  )
  
  output$allActors <- renderDataTable(
    users %>% arrange( category, desc( nhates ), desc( hates_ratio ) )  %>%
    select( user_id, favGroup, category, nhates, nsentiments, hates_ratio ) %>% 
    setNames( c('Użytkownik','Popularność','Nastawienie','L. hejtów', 'L. wpisów','Proporcja')) , 
    options = list( pageLength=10, lengthChange = TRUE,
                           columnDefs = list(list( width = '300px',
                                                   targets = 4 )))
  )
}

naiveBayesGraph <- function( input, output, session, sentiments ) {
        output$naiveBayesGraph <- renderPlotly( {
                groupSen  <- sentiments

                ind <- sample( 2, nrow( groupSen ), replace=TRUE, prob=c(0.8,.2))
                train <- groupSen[ ind==1, ]
                test <- groupSen[ ind==2, ]
                
                model <- naive_bayes( favGroup ~ category, data = train ) 

                attitudePalette <-c( 'N'='#F2134F', 'U'='#3238A6' )

                 a <-  ggplot( groupSen, 
                        aes( factor(favGroup, levels = c('top','popular','low','none')), 
                        fill = factor(category) )) +
                geom_bar( position = "fill" ) +
                scale_fill_manual( "Charakter", values = attitudePalette )+
                labs( 
                             x="Popularność", y="Prawdopodobieństwo\n")+ 
                theme(
                                plot.title = element_text(size=17, face="bold"),
                                axis.title.x = element_text(size = 15, face = "bold"),
                                axis.title.y = element_text(size = 15, 
                                                            face = "bold"
                                                            ),
                                axis.text.x = element_text( face = "bold",  size=14 ),
                                axis.text.y = element_text( face = "bold",  size=14 ),
                                legend.title = element_blank()
                                
                        ) 
              ggplotly(a) %>% layout( 
                      legend = list(
                      title=list(text='<b> Nastawienie </b>'),
                      orientation = "h", x=-0.1,y=-0.3
                                        )) 
        })
        
}


