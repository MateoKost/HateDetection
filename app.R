source("Setup/sources.R")

sId <- 'one'
ui <- ui(sId)

server <- function(input, output, session) {
  options(shiny.maxRequestSize = 300 * 1024 ^ 2)
  
  output$srcUi <- startUi(input, output, session)
  
  sentiments = fromJSON("./Data/classified_sentiments.JSON")
  users = fromJSON("./Data/classified_users.json")
  
  appFlow(input, output, session, sentiments, users)
  
  observeEvent(input$startBtn2, {
    sentiments = fromJSON(input$sentimentsJson$datapath)
    users = fromJSON(input$usersJson$datapath)
    appFlow(input, output, session, sentiments, users)
  })
}

appFlow <- function(input, output, session, sentiments, users) {
  show_modal_spinner(spin = "cube-grid",
                     color = "firebrick",
                     text = "Przetwarzanie danych...")
  
  output$tabsMenuUiOutput <- tabsMenuUi (input, output, session)
  
  current_week  <-
    callModule(retieveDays, sId , sentiments[1,]$created_at)
  
  users <- users %>% arrange(category, desc(followers_count))
  
  top10haters <- users %>% filter(category == 'N') %>% head(10)
  
  sentiment_graphs <-
    callModule(calculateGraph, sId, users, sentiments)
  
  callModule(sentimentGraph, sId, sentiment_graphs)
  output$attitudeGUI <-
    attitudeUI(input, output, session, sId, sentiment_graphs)
  
  callModule(negativeSentiments, sId, sentiments)
  callModule(negativeActors, sId, users)
  
  callModule(valueBoxes, sId, sentiments, users)
  callModule(naiveBayesGraph, sId, sentiments)
  
  select_parameters <- list(
    numberHaters = 10,
    favGroup = 'top',
    arrP1 = 'nhates',
    ascP1 = FALSE,
    arrP2 = 'hates_ratio',
    ascP2 = FALSE
  )
  
  neg_nets <-
    callModule(negNets,
               sId,
               users,
               sentiments,
               current_week,
               select_parameters)
  
  replyNets <-
    callModule(calculateReplyGraph, sId, users, sentiments)
  
  observeEvent(input$applyFitlers, {
    select_parameters <- list(
      numberHaters = input$numberHaters,
      favGroup = input$selectedGroup,
      arrP1 = input$arrP1,
      ascP1 = input$ascP1,
      arrP2 = input$arrP2,
      ascP2 = input$ascP2
    )
    neg_nets <-
      callModule(negNets,
                 sId,
                 users,
                 sentiments,
                 current_week,
                 select_parameters)
    
    callModule(negSensTimeline, sId, neg_nets, current_week)
    output$tabTimeUi <-
      timeUi(input, output, session, sId, neg_nets)
    
  })
  
  callModule(negSensTimeline, sId, neg_nets, current_week)
  output$tabTimeUi <-
    timeUi(input, output, session, sId, neg_nets)
  
  callModule(hateReplyGraph, sId, users, sentiments, replyNets)
  output$tabHateReplyUi <-
    hateReplyUi(input, output, session, sId, replyNets)
  
  remove_modal_spinner()
}


shinyApp(ui, server)