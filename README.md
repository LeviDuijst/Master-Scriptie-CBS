# Master-Scriptie-CBS
On this GitHub page, I share my code that I used for my master thesis at CBS for Statistics and Data Science. The thesis is split up into three projects: Research Part 1, 2 and 3. Each of these parts belong to one of the analysis that I performed and corresponding to my report. I also have a code title "Dataset creation" in which datasets are created that I lated used to run the models in Part 2 and 3. 
I give a short description of each code section on what the goal was of the research part and what the main focus was. In the code itself, I explain in detail what each chunk means and guide the reader thought the whole process. 

# **Analyse_OZAB**
With this code, the cover data can be analysed with the OZAB model. This is only relevent for Research Part 3.

# **Creading_datasets**
This code can be used to create the corresponding cover and presence-absence datasets from all data that is available. Only the information that is relevent is stored in the cover and/or presence-absence datasets. With these datasets, the OZAB and logistic regression models can be run for both cover and presence-absence data, respectively. The population trends can be calculated from the model outputs. This can be done for all species. Furthermore, the cover and presence-absence data can be updated with information from the other dataset. This code is mainly used for Research Part 2, but also for Research Part 3 where population trends based on cover data is needed. 

# **Trend_berekenen_classificeren_logitols**
This code is used to calculate the population trend based on cover and presence-absence data from the model outputs. The sims output of the two models are needed to run the code. The results are the population trend, standard errors of the trend and the group classification.

# **Project_1**
This code is related to the first research part. In this code, I compare the population trend estimations with standard errors of the two datasets/models. One is based on cover data on a small scale, while the other is presence-absence data on a coarse scale. The main idea of interest was to find if one of the two datasets can detected signals if a species population trend is going to decrease/increase. 

#**Project_2**
This code is related to research part 2. This code analyses the model performace of the logistic regression model with Bayesian statistics with presence-absence data. Two datasets are used. The first one is the original presence-absence dataset and the second one is the updated version of the presence-absence dataset. 

