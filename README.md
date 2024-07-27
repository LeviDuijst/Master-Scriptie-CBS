# Master-Scriptie-CBS
On this GitHub page, I share the code that I used for my master's thesis for Statistics and Data Science at CBS. The thesis is split up into three projects: Research Part 1, 2 and 3. Each of these parts belongs to one of the analyses I performed and corresponds to my report. I also have a code titled "Dataset creation"  in which datasets are created that I later used to run the models in Parts 2 and 3. I give a short description of each code section, including the goal of the research part and the main focus. In the code itself, I explain in detail what each chunk means and guide the reader through the whole process.

# **Analyse_OZAB**
With this code, the cover data can be analysed with the OZAB model. This is only relevant  for Research Part 3.

# **Creading_datasets**
This code can be used to create the corresponding cover and presence-absence datasets from all data that is available. Only the relevant information is stored in the cover and/or presence-absence datasets. With these datasets, the OZAB and logistic regression models can be run for both cover and presence-absence data, respectively. The population trends can be calculated from the model outputs. This can be done for all species. Furthermore, the cover and presence-absence data can be updated with information from the other dataset. This code is mainly used for Research Part 2, but also for Research Part 3 where population trends based on cover data are needed. 

# **Trend_berekenen_classificeren_logitols**
This code is used to calculate the population trend based on cover and presence-absence data from the model outputs. The sims outputs of the two models are needed to run the code. The results are the population trend, standard errors of the trend and the group classification.

# **Project_1**
This code is related to the first research part. In this code, I compare the population trend estimations with standard errors of the two datasets/models. One is based on cover data on a small scale, while the other is presence-absence data on a coarse scale. The main idea of interest was to find if one of the two datasets can detect signals if a species population trend is going to decrease/increase. 

# **Project_2**
This code is related to research part 2. This code analyses the model performance of the logistic regression model with Bayesian statistics with presence-absence data. Two datasets are used. The first one is the original presence-absence dataset and the second one is the updated version of the presence-absence dataset. The question was if the model performance of the logistic regression increased with added data of the presence-absence dataset.

# **Project_3**
In the third project, I created an integrated model, called the shared model. This shared model can include both the cover and the presence-absence data in one model. The idea with an integrated model is that more data can be added, which can result in more precise parameter estimations. 

