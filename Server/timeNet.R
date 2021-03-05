retieveDays <- function(input, output, session, created_at ) {
        first_day <- created_at %>% as.Date( format = "%Y-%m-%d" )
        rev(seq(as.Date(first_day), by = "-1 day", length = 8))
}

negNets <- function( input, output, session, users, sentiments, current_week, select_parameters ){

        #haters <- isolate( top10haters() ) #%>% head(1)
        #haters <- top10haters #%>% head(1)
        
        arrcon1<-ifelse(select_parameters$ascP1,
                        select_parameters$arrP1,
                        paste0('desc(',select_parameters$arrP1,')') 
                        )
        
        arrcon2<-ifelse(select_parameters$ascP2,
                        select_parameters$arrP2,
                        paste0('desc(',select_parameters$arrP2,')')
                        )

        con22<-parse( text=arrcon1 )
        con23<-parse( text=arrcon2 )
        
        #%>% filter( favGroup==input$selectedGroup )

        haters<- users %>% filter( category=='N', favGroup==select_parameters$favGroup ) %>% 
                arrange(eval(con22), eval(con23)) %>% 
                head( select_parameters$numberHaters )#n=input$numberHaters )

        
        
        #sentiments <- isolate( sentiments() ) %>%
        sentiments <- sentiments %>%
                mutate( day=as.Date( created_at, format = "%Y-%m-%d")  )
        
        #days <- rev(seq(as.Date("2020-12-15"), by = "-1 day", length = 8))
        #days <- isolate( current_week() )
        days <- current_week
        nets <- apply( haters, 1, function( hater ) {

                user_sentiments <- sentiments %>% 
                        filter( user_id == hater['user_id'] ) %>% arrange(created_at)

                
                links <-  data.frame( 
                        from=as.character(user_sentiments$status_id), 
                        to=user_sentiments$day,
                        nhates=user_sentiments$score
                ) %>% rbind(data.frame( 
                        from=as.character(days[1:length(days)-1]), 
                        to=  as.character(days[2:length(days)]),
                        nhates=0
                        )
                )
                

                
                vertices <- data.frame( 
                        id=as.character(user_sentiments$status_id),
                        attitude=user_sentiments$category,
                        favGroup=user_sentiments$favGroup
                ) %>% rbind(data.frame( 
                                id=as.character(days),
                                attitude=NA,
                                favGroup='none')
                )
                

                
                value_sens <- sapply(days, function( sday ){
                        user_sentiments %>% filter( day==sday ) %>%  nrow()
                })
                
                
                value_days <- sapply( value_sens, function( vs_counter ){
                        if( vs_counter>0 ) 2:(vs_counter+1)
                }) %>% unlist()
                
                layout <- data.frame(
                        Date=as.Date( c(user_sentiments$day, days )),
                        value=c( value_days, rep(1, length(days)) )
                )
                
                
                list(
                        user = list( user_id=hater['user_id'], user_id=hater['user_id'] ),
                        igraph = graph_from_data_frame( links, vertices = vertices, directed = F),
                        layout = layout,
                        user_sentiments=user_sentiments
                )
        })

        nets
}

negSensTimeline <- function( input, output, session, nets, current_week ) {
        # nets <- isolate( nets() )
        # days <- isolate( current_week() )
        days <- current_week
        #days <- rev(seq(as.Date("2020-12-15"), by = "-1 day", length = 8))
        attitudePalette <-c( 'N'='#F2134F', 'U'='#3238A6' )
        
        lapply( seq_along(nets), function(i) {
                
                simple_net <- nets[[i]]
                
                output[[paste0('timeGraph', i )]] <- renderPlot({

                        #simple_net <- nets[[i]]
                        net <- simple_net$igraph
                        layout <- simple_net$layout
                        user_id <- simple_net$user$user_id
                        
                        V(net)$size <- 5

                        V(net)$size <-ifelse( V(net)$favGroup=='none', 7,
                                              ifelse( V(net)$favGroup=='low', 11,
                                                      ifelse( V(net)$favGroup=='popular', 14, 18 ) ) )
                        
                        V(net)$color <- attitudePalette[ V(net)$attitude ]
                        V(net)$label=NA
                        # V(net)$label=V(net)$name
                        V(net)$label.font=2.5#+V(net)$followers_count
                        V(net)$label.color=V(net)$color
                        
                       # View( are.connected(net, V(net)[which(name %in% days)], V(net)[which(attitude=='N')] ))
                        
                        V(net)$strength %>% View()
                        
                        
                        
                        # V(net)[is.na(V(net)$attitude)]$shape='square'
                        V(net)[is.na(V(net)$attitude)]$size <- 15 
                        V(net)[is.na(V(net)$attitude)]$color <- '#9B97D9'
                        # V(net)[is.na(V(net)$attitude) && ]$frame.color <- 'red'
                        #V(net)[is.na(V(net)$attitude)]$frame.width=25
                       
                        
                        V(net)$label.cex=.9
                        E(net)$color <- ifelse( E(net)$nhates>0, '#F2134F', '#AAAAAA')
                        E(net)$width=1
                        E(net)$curved=0.35
                        E(net)$label <- ifelse( E(net)$nhates>0,E(net)$nhates,NA)
                        E(net)$arrow.size <- .5
                        E(net)$arrow.width <- .5

                        E(net)$weight <- E(net)$nhates
                        
                        plot.igraph(
                                net,
                                layout=layout,
                                xlim=as.Date(c( days[1], days[length(days)]+1 )),
                                ylim=c(1,max(layout$value)+1),
                                asp=0,
                                axis=FALSE,
                                rescale=FALSE,
                                main=user_id
                        )

                        axis(1,at=as.numeric(layout$Date),labels=layout$Date, cex.axis=0.9)
                        axis(2,at=1:max(layout$value), labels=1:max(layout$value))
                        
                        legend("topleft", 
                        c(  "negatywny wpis","neutralny wpis"
                        ),
                        pch = c(21, 21),
                        col = "black", 
                        pt.bg = c(attitudePalette[ 'N'], attitudePalette[ 'U']),
                        pt.cex = 1.5)
                        # 
                        # legend("topright", 
                        #        c(  "none","low",'popular','top'),
                        #        pch = c(21, 21,21,21),
                        #        col = "black", 
                        #        horiz=T,
                        #        pt.bg = c(rep('white',4)),
                        #        pt.cex = c(7,11,14,18))
                        
                        
                })
                

                output[[paste0('timeData', i )]] <- renderTable({
                        simple_net$user_sentiments %>% filter( category=='N' ) %>% 
                                arrange( desc( favorite_count ) ) %>% 
                                select( created_at, text, score, favorite_count ) %>%
                                setNames( c('Data utworzenia','Treść','L.neg.wyrazów','L.polubień'))
                })
                
                output[[paste0('timeDegree', i )]] <- renderPlot({
                        net <- simple_net$igraph
                        E(net)$weight <- E(net)$nhates
                        deg <-  data.frame(value=degree(net, v = V(net)[V(net)$name %in% as.character(days)]))
                        ggplot(deg, aes(x=value))+
                                geom_histogram(color="darkblue", fill="#4E2FBD", binwidth = 0.5)+
                        #ggtitle("Histogram wag przyległych krawędzi") +
                        labs( x="Wartość", y="Liczba wystąpień\n" )
                        
                        # axis(1,at=as.numeric(days),labels=days, cex.axis=0.9)
                        # axis(2,at=1:max(layout$value), labels=1:max(layout$value))
                        # axis(2,at=1:max(layout$value), labels=1:max(layout$value))
                })
                
                output[[paste0('timeStrength', i )]] <- renderPlot({
                        net <- simple_net$igraph
                        E(net)$weight <- E(net)$nhates
                        str <-  data.frame(value=strength(net, v = V(net)[V(net)$name %in% as.character(days)]))
                        ggplot(str, aes(x=value))+
                                       geom_histogram(color="darkblue", fill="#4E2FBD", binwidth = 0.5)+
                        #ggtitle("Histogram wag przyległych krawędzi") +
                        labs( x="Wartość", y="Liczba wystąpień\n" )
                     
                })
        })
        
}



