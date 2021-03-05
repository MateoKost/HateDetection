changeToASCII <- function( column ) {
        sapply(column, function( value )
                ifelse( value %>% is.na(), NA,
                value  %>% str_split('') %>% unlist %>%
                       sapply(function(ch)
                               65 + as.integer(ch)) %>% as.raw %>% rawToChar) ) %>% return()
}

load(file.choose())

sentiments$status_id <- changeToASCII( sentiments$status_id )
sentiments$user_id <- changeToASCII( sentiments$user_id )
sentiments$reply_to_user_id <- changeToASCII( sentiments$reply_to_user_id )

excluded_vars <- c("screen_name", "reply_to_screen_name")
sentiments %<>% select( -excluded_vars ) 

users$user_id <-  changeToASCII( users$user_id )
excluded_vars <- c("screen_name", ".id")
users%<>% select( -excluded_vars ) 

save(sentiments, users, file = "classified_sentiments_users.RData")

sentiments %>% View()

toJSON( sentiments, encoding = "UTF-8", pretty = TRUE) %>% write( "classified_sentiments.json")
toJSON( users, encoding = "UTF-8", pretty = TRUE) %>% write( "classified_users.json")

