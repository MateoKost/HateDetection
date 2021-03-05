calculateReplyGraph <- function( input, output, session, users, sentiments ) {
  
  sentwe <- sentiments %>% filter( reply_to_user_id %in% users$user_id )
  sekUsers <- sentwe$user_id %>% unique
  
  sekcategory <- sapply( sekUsers, function(sekUser){
    ke <- users %>% filter( user_id == sekUser )
    ifelse( nrow(ke)>0,
            ke$category,
            'U'
    )     
  })
  
  sekHaters <- sekcategory[ sekcategory=='N' ]
  
  vert <- data.frame(
    id = c( sekUsers, sentwe$status_id ),
    type = c( rep('U', length(sekUsers) ), rep('S', nrow(sentwe))),
    attitude= c(sekcategory, sentwe$category )
  ) 
  
  retete <- sentwe %>% select( status_id, reply_to_user_id ) %>% filter( reply_to_user_id %in% sekUsers )
  
  
  lin <- data.frame(
    from=c( sentwe$user_id, retete$status_id),
    to=c( sentwe$status_id, retete$reply_to_user_id)
  )
  
  net<-graph_from_data_frame( lin, vertices = vert, directed = T)
  
  wc<-cluster_walktrap(net)
  
  replyNets <- lapply( wc %>% membership() %>% unique() %>% sort(), function(g) {
    sub <- induced.subgraph(net, which( (membership(wc)==g) & sizes(wc)[[g]] >2  ))
    if( length( V(sub)[ V(sub)$name %in% names(sekHaters) ]) >=1 ){
      
      Cycles = NULL
      for(v1 in V(sub) ) {
        for(v2 in neighbors(sub, v1, mode="out")) {
          Cycles = c( Cycles,
                      lapply(all_simple_paths(sub, v2,v1, mode="out"), function(p) c(v1,p)))
        }
      }
      
      LongCycles = Cycles[which(sapply(Cycles, length) > 3)]
      dist <- LongCycles[sapply( LongCycles, min ) == sapply(LongCycles, `[`, 1)]
      
      
      if(length( dist ) > 0 ){
        
        cycleGroups <- lapply( dist, function ( d ){
          namess <- names(d)
          nss <- namess[namess!='']
          hatesInNss <- length( V(sub)[V(sub)[V(sub)$attitude=='N']$name %in% nss ]$name )
          if( hatesInNss > 0 )
            nss
        }) %>% discard(is.null)
        
        if(length( cycleGroups ) > 0 )
          return( list( net=sub, cycleIds=cycleGroups ) )
      }
    }
  }) %>% discard(is.null)
  
  keke <- replyNets
  
}

hateReplyGraph <- function( input, output, session, users, sentiments, replyNets ) {
  
  m1 <- readPNG("Assets/tweet.png")
  m2 <- readPNG("Assets/user.png")
  m3 <- readPNG("Assets/hate.png")
  m4 <- readPNG("Assets/hater.png")
  
  lapply( seq_along(replyNets), function(i) {
    
    output[[paste0('hateReply', i )]]<- renderPlot({
      
      replyNet <- replyNets[[i]]
      netia <- replyNet$net
      
      screenNames <- sapply( V(netia)[V(netia)$type=='U']$name, function( id ){
        record<-users %>% filter( user_id == id ) %>% select( user_id ) %>% head(1)
        ifelse(length(record)>0,record,'')
        
      })
      
      V(netia)[V(netia)$type=='U']$label = screenNames
      V(netia)[V(netia)$type=='S']$label = ''
      
      E(netia)$arrow.size <- .7
      E(netia)$arrow.width <- .7
      E(netia)$curved=0.35
      
      V(netia)$frame.color="black"
      V(netia)$frame.width=20
      
      V(netia)$size = 8
      V(netia)$size2 = 8
      V(netia)$shape="raster"
      
      ke1<-length(V(netia)[V(netia)$type == 'S' & V(netia)$attitude=='U' ]$name)
      ke2<-length(V(netia)[V(netia)$type == 'U' & V(netia)$attitude=='U' ]$name)
      ke3<-length(V(netia)[V(netia)$type == 'S' & V(netia)$attitude=='N' ]$name)
      ke4<-length(V(netia)[V(netia)$type == 'U' & V(netia)$attitude=='N' ]$name)
      
      V(netia)[V(netia)$type=='S' & V(netia)$attitude=='U']$raster <- replicate( ke1, m1, simplify=FALSE)
      V(netia)[V(netia)$type=='U' & V(netia)$attitude=='U']$raster <- replicate( ke2, m2, simplify=FALSE)
      V(netia)[V(netia)$type=='S' & V(netia)$attitude=='N']$raster <- replicate( ke3, m3, simplify=FALSE)
      V(netia)[V(netia)$type=='U' & V(netia)$attitude=='N']$raster <- replicate( ke4, m4, simplify=FALSE)
      
      plot.igraph(netia,
                  mark.groups=replyNet$cycleIds,
                  mark.col="#C5E5E7"
      )
      
    })
    
    
    output[[paste0('hateReplySensData', i )]] <- renderTable({
      replyNet <- replyNets[[i]]
      netia <- replyNet$net
      
      cycleIds <- replyNet$cycleIds

      cyleUsers <- users %>% filter( user_id %in% unlist(cycleIds) ) %>% 
        select( user_id,  favGroup, followers_count )
      
      returnData <- sentiments %>% filter( status_id %in% unlist(cycleIds) ) %>% 
        left_join( cyleUsers, by='user_id' ) 
     
      returnData %>%
        select(  user_id, created_at, text, favorite_count, category  ) %>% 
        arrange( created_at ) %>%
        setNames( c('Użytkownik','Data utworzenia','Treść','L.polubień','Nastawienie'))
    })
    
    
    output[[paste0('hateReplyUserData', i )]] <- renderTable({
      replyNet <- replyNets[[1]]
      netia <- replyNet$net
      
      cycleIds <- replyNet$cycleIds
    })
  })
}







