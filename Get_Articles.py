#Uses Python 3 to loop through and download every article from the RSS feed in the news website urls provided in the 
#Articles.csv file and output them to json text files in folders in the same directory as this file.

import newspaper, csv, time, datetime, json, pandas as pd, os, gc

#Function builds a newspaper based on the url provided and downloads every article in that paper's RSS feed.
#For every article the url, title, and text of the article is gathered and printed to a json file contained
#in a folder in the name provided.
def importdata(url, name):
	print('Building newspaper: ' + name)
	if not os.path.exists(os.getcwd() + '\\articles\\' + name):
		os.makedirs(os.getcwd() + '\\articles\\' + name)
	timestamp = datetime.datetime.today().strftime("_%m_%d_%Y_%H_%M_%S")
	paper = newspaper.build(url, memoize_articles=False)
	print(name + ' newspaper built, downloading articles')
	article_num = 0
	file_num = 0
	articleDict = []
	for article in paper.articles:
		article_num = article_num + 1
		if article_num == 1 or article_num % 50 == 0 or article_num == len(paper.articles):
			print(str(article_num) + ' of ' + str(len(paper.articles)))
		try:
			article.download()
			article.parse()
			d = dict([('url', article.url),('title', article.title),('text',article.text)])
			articleDict.append(d)
		except:
			#d = dict([('url', article.url),('title', '!!FAILURE!!'),('text','!!FAILURE!!')])
			#articleDict.append(d)
			print('Exception Thrown')
		if article_num % 100 == 0 or article_num == len(paper.articles):
			file_num = file_num + 1
			print('Writing '+ name + ' file #' + str(file_num)  + ' to text file')
			with open('articles\\' + name + '\\' + name +  timestamp + '(' + str(file_num) + ').json','w') as txtfile:
				json.dump(articleDict, txtfile, indent=4)
			articleDict = []
			gc.collect()

#Reads every row in the Articles.csv file contained in the same directory as this python file. 
#Based on the entries in this file, loops through every url and runs the importdata function.
article_list=pd.read_csv(r'Articles.csv')
for index,row in article_list.iterrows():
	importdata(row['url'], row['name'])