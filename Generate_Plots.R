source('Articles_NetWork_Plots.R')
#Below runs through every paper in the input data and plots network diagrams of word usage patterns by
#sentence, paragraph, and article
 data.list <- read_json_data()
 dir.create('plots')
 for (name in names(data.list)){
   print(name)
   
   word.frame<-unnest_by_title(data.list[[name]])
   count.data<-get_count_data(word.frame, 500)
   plot_network_diagram(count.data, paste("plots/",name,"_title_" ,".pdf", sep=""), paste(name, " Words Connections in Titles", sep=""))
   
   
   word.frame <- unnest_by_paragraph(data.list[[name]])
   count.data<-get_count_data(word.frame, 500)
   plot_network_diagram(count.data, paste("plots/",name,"_paragraph_" ,".pdf", sep=""), paste(name, " Words Connections in Paragraphs", sep=""))
   
   word.frame<-unnest_by_sentence(data.list[[name]])
   count.data<-get_count_data(word.frame, 500)
   plot_network_diagram(count.data, paste("plots/",name,"_sentence_" ,".pdf", sep=""), paste(name, " Words Connections in Sentences", sep=""))
 }
 