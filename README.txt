The goal of this program is to visualize the relationships between word usage with different online news sources. There are two steps:
1. A Python (3.x) program ('Get_Articles.py') to download raw artice text into broken up json files 
  - This is mean to be used with a 'Papers.csv' file contained in the same folder location contain a comma-delimited list of url
    and newspaper names for the program to process.
  - Toggling the "memoize_articles" option as part of the newspaper package may be of interest. This option essentially determines 
    whether the program will remember to download articles it previously downloaded.

2. An R program ('Articles_Network_Plots.R') to process the raw text and plot diagrams
  - An additional 'Generate_Plots.R' file has been included to show how to loop through every possible plot
  - Network diagrams look for the top n relationships between words by paragraph, sentence, or title and also include certain
    network statistics of the final plot.
