sentimentGraph <- function(input, output, session, nets) {
  attitudePalette <- c('N' = '#F2134F', 'U' = '#3238A6')
  
  lapply(seq_along(nets), function(i) {
    output[[paste0('attitudeGraph', i)]] <-
      renderPlot(width = "auto", height = "auto", res = 72,
                 {
                   simple_net <- nets[[i]]
                   day <- simple_net$day
                   net <- simple_net$igraph
                   favGroups <- c('none', 'low', 'popular', 'top')
                   
                   V(net)$size <- 2
                   V(net)$color <- attitudePalette[V(net)$attitude]
                   V(net)$label = V(net)$name
                   V(net)$label = ifelse(V(net)$role == 'R', V(net)$label, NA)
                   
                   E(net)$color <- 'grey'
                   E(net)[from(V(net)[which(attitude == 'N')])]$color <-
                     'red'
                   E(net)[to(favGroups)]$color <- NA
                   
                   V(net)$label.font = 2.5
                   V(net)$label.color = V(net)$color
                   V(net)$label.cex = .9
                   V(net)$frame.color = NA
                   
                   V(net)$shape <-
                     ifelse(V(net)$role == 'S', 'circle', "square")
                   
                   E(net)$width = 1.1
                   
                   plot.igraph(net,
                               layout = layout_as_tree(
                                 net,
                                 flip.y = TRUE,
                                 circular = TRUE,
                                 root = favGroups,
                                 rootlevel = c(1, 5, 10, 16)
                                 
                               ))
                   legend(
                     "bottom",
                     c(
                       "negatywny użytkownik",
                       "negatywny wpis",
                       "neutralny użytkownik",
                       "neutralny wpis"
                     ),
                     pch = c(22, 21, 22, 21),
                     col = "black",
                     horiz = T,
                     pt.bg = c(rep(attitudePalette['N'], 2), rep(attitudePalette['U'], 2)),
                     pt.cex = 1.5
                   )
                 })
  })
}

calculateGraph <-
  function(input, output, session, users, sentiments) {
    sentiments %<>% arrange(category)
    users %<>% arrange(category)
    
    View(sentiments)
    
    sentiments %<>% mutate(day = as.Date(created_at, format = "%Y-%m-%d")) %>% arrange(day)
    
    days <- sentiments$day %>% unique()
    
    lapply(as.character(days), function(sday) {
      sentiments_at_day <- sentiments %>% filter(day == sday)
      
      users_at_day <-
        users %>% filter(user_id %in% sentiments_at_day$user_id)
      
      vertices <- data.frame(
        id = users_at_day$user_id,
        role = 'U',
        popularity = users_at_day$followers_count,
        favGroup = users_at_day$favGroup,
        attitude = users_at_day$category,
        score = users_at_day$statuses_count
      )
      
      vertices %<>% rbind(
        data.frame(
          id = sentiments_at_day$status_id,
          role = 'S',
          popularity = sentiments_at_day$favorite_count,
          favGroup = sentiments_at_day$favGroup,
          attitude = sentiments_at_day$category,
          score = sentiments_at_day$retweet_count
        )
      )
      
      favGroups <- c('none', 'low', 'popular', 'top')
      
      vertices %<>% rbind(
        data.frame(
          id = favGroups,
          role = 'R',
          popularity = NA,
          favGroup = favGroups,
          attitude = NA,
          score = NA
        )
      )
      
      links <-  data.frame(from = sentiments_at_day$status_id,
                           to = sentiments_at_day$user_id)
      
      for (group in favGroups) {
        group_users_ids <-
          users_at_day %>% filter(favGroup == group) %>% select(user_id)
        
        links %<>% rbind(data.frame(from = group_users_ids$user_id,
                                    to = c(rep(
                                      group, length(group_users_ids$user_id)
                                    ))))
      }
      
      list(day = sday,
           igraph = graph_from_data_frame(links, vertices = vertices, directed = F))
    })
    
    
    
  }
