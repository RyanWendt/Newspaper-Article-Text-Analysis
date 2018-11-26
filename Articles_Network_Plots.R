#load libraries
lapply(c("tm", 'jsonlite', 'dplyr', 'tidyr', 'stringr', 'tidytext', 'purrr', 'widyr', 'ggplot2', 'igraph', 'ggraph', 
         'data.table'), 
       require, character.only=T)

#Read in data
read_json_data <- function(){
  directories <- list.dirs('articles')[-1]
  data.list <- list()
  i <- 0
  for (paper.dir in directories){
    i <- i + 1
    files <- list.files(paper.dir)
    data.list[[i]] <- do.call("rbind", lapply(paste(paper.dir,files, sep='/'), read_json, simplifyVector=T) )
  }
  names(data.list) <- str_replace_all(directories, "articles/", "")
  return(data.list)
  
}


unnest_by_title <- function(news){
  title.frame <- unnest_tokens(news, word, title, token="words", to_lower = T)
  title.frame <- title.frame[,c('word', 'url')]
  colnames(title.frame) <- c( 'word', 'key')
  return(title.frame)
}



unnest_by_paragraph <- function(news){
  #Create a row for every paragraph (also lower cases all letters)
  paragraph.frame <- unnest_tokens(news, text, text,token = "paragraphs", to_lower = T)[,'text']
  paragraph.frame <- cbind(paragraph.frame, key=row.names(paragraph.frame))
  
  #break down into every word, with incrementing key for every paragraph
  word.frame <- unnest_tokens(paragraph.frame, word, text, token = "words")
  return(word.frame)
}

unnest_by_sentence <- function(news){
  #Create a row for every paragraph (also lower cases all letters)
  paragraph.frame <- unnest_tokens(news, text, text,token = "sentences", to_lower = T)[,'text']
  paragraph.frame <- cbind(paragraph.frame, key=row.names(paragraph.frame))
  
  #break down into every word, with incrementing key for every paragraph
  word.frame <- unnest_tokens(paragraph.frame, word, text, token = "words")
  return(word.frame)
}



#input data frame of extracte news data, output is list object for graphing
get_count_data <- function(word.frame, top.relationships){
  
  #Clean text to remove punctuation and special characters
  word.frame$word <- iconv(word.frame$word,"latin1", "ASCII", sub="") %>% str_replace_all("[[:punct:]]", "")
  
  #remove stop words
  custom.stop.words <- c("","said", "{{video.duration.momentjs}}") #subscribe newsletter
  stop.words <- as.data.frame(c(stopwords("english"), custom.stop.words))
  colnames(stop.words) <- "word"
  word.frame <- anti_join(word.frame,stop.words, by="word")
  
  
  #Get pairwise relationships and pick top n relationships
  word.frame$key <- as.character(word.frame$key) #fixes error comparing factor to character
  pair.count <- pairwise_count(word.frame, word, key, sort=T)# %>% head(top.relationships)
  pair.count <- pair.count[!duplicated(data.table(pmin(pair.count$item1,pair.count$item2),pmax(pair.count$item1,pair.count$item2))),]
  pair.count <- head(pair.count, top.relationships)
  colnames(pair.count)[3] <- "pair.count"
  
  #word count for the top relationships selected
  
  word.count<-count(word.frame, word, sort=T) %>% filter(word %in% pair.count$item1 | word %in% pair.count$item2)
  colnames(word.count) <- c("item1", "single.count") 
  
  templist <-list()
  templist[[1]] <- pair.count
  templist[[2]] <- word.count
  return(templist)
}




#input is count.data list object, prints out a network diagram in jpg format
plot_network_diagram <- function(count.data, filename, title){
  
  #count.data[[1]]$pair.count <- count.data[[1]]$pair.count / 2
  graph.object <- graph_from_data_frame(count.data[[1]], vertices=count.data[[2]], directed = F) 
  
  top.count <- count.data[[2]]$item1  %>% head(10) %>% paste(collapse=', ')
  graph.closeness <- closeness(graph.object) %>% sort(decreasing=T) %>% head(10) %>% names() %>% paste(collapse=', ')
  graph.betweeness <- betweenness(graph.object) %>% sort(decreasing=T) %>% head(10) %>% names() %>% paste(collapse=', ')
  
  
  sub.title <- paste('\nTop 10 Nodes by Total Word Count:\t', top.count,
                     '\n\nTop 10 Nodes by Closesness:\t' , graph.closeness , 
                     '\n\nTop 10 Nodes by Betweeness:\t', graph.betweeness)
  
  network.plot <- ggraph(graph.object, layout="fr") + 
      geom_edge_link(aes(edge_alpha=pair.count, edge_width=pair.count), edge_colour="orange2") + 
      geom_node_point(aes(size=single.count))  + scale_size(range=c(1,6)) + 
      geom_node_text(aes(label=name),color="blue",size=3,fontface="bold", repel=T, point.padding=unit(.2,"lines")) +
      theme_void() + labs(title = title, subtitle=sub.title ) +
      theme(plot.title = element_text(size=20, hjust=.5), plot.subtitle= element_text(face="bold")) 
  
  pdf(file=filename, height=12, width=9)
  plot(network.plot)
  
  dev.off()

}






