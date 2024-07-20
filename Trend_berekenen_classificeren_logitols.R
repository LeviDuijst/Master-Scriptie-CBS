#######################################
# logit-transformatie voor trendberekening en -classificatie van 
# gemiddelde bedekkings- en waarneemkanswaarden. 
# 2024-06-12 voor Levi: 

# Eerst sourcen van benodigde functies: 
# gekopieerd uit E:/Ontwikkel/SWAN_bedekking/CODE/COCON_LMF_logit.R: 
logit <- function(x){
  log(x / (1 - x))
}
invlogit <- function(x){
  1 / (1 + exp(-x))
}

# gekopieerd uit E:/Ontwikkel/SWAN_bedekking/CODE/SWAN_LMF_output_maken.R: 
trend_berekenen_classificeren_logitols <- function(
    sims = data.frame(), 
    periode = numeric()
){
  #############################################################################
  # Hulpfunctie die tijdens SWAN_nabewerken wordt aangeroepen in output_maken()
  # Doet een logit-transformatie van de posterior parameterwaarden in sims, 
  # trekt dan mbv OLS een streep door de posterior parameterwaarden
  # en checkt of 0 in het 95% CRI valt. 
  # Fitted values van de OLS-uitkomst worden teruggetransformeerd naar de 
  # oorspronkelijke schaal om een gemiddelde verandering per tijdseenheid 
  # (slope/std_trend) en een gemiddelde proportionele toe- of afname per 
  # tijdseenheid (groei/mlt_trend) te berekenen. 
  # Inputargumenten: 
  # sims = simstabel (data.frame) met posterior waarden in een rij per meetronde 
  # en een kolom per MCMC-chain iteratie
  # periode = numerieke vector met jaartallen per rij in de simstabel
  # Output = data.frame met zes kolommen: 
  #   (1) gemiddelde slope per tijdseenheid ('trend'), 
  #   (2) standaard deviatie van de verdeling van slopes ('se') en 
  #   (3) trendclassificatie ('category')
  #   (4) - (6) zelfde voor groei ('mlt_trend')
  #############################################################################
  ## controleren input; meeste gebeurt in output_maken()
  if(nrow(sims) != length(periode)){
    stop("Inputobjecten {sims} en {periode} hebben incompatibele dimensies")
  }
  
  ## slopes berekenen per iteratie
  kolindex_iters <- which(grepl("^V\\d+$", colnames(sims)))
  n_iters <- length(kolindex_iters)
  n_periodes <- periode[length(periode)] - periode[1]
  
  # slope is op de logit-schaal, gemidd_verandering en gemidd_groei zijn 
  # op de oorspronkelijke schaal (pre-transformatie)
  slope_iters <- numeric(n_iters)
  gemiddelde_verandering_iters <- numeric(n_iters)
  gemiddelde_groei_iters <- numeric(n_iters)
  
  for(i in seq_along(kolindex_iters)){
    ## verandering staat voor T+1 - T, groei voor T+1 / T
    lm_i <- lm(logit(as.numeric(sims[, kolindex_iters[i]])) ~ periode)
    slope_iters[i] <- lm_i$coef[2]
    
    gefitte_waarden_i <- lm_i$coef[1] + periode * lm_i$coef[2]
    gefitte_waarden_oorspr_schaal_i <- invlogit(gefitte_waarden_i)
    gemiddelde_verandering_iters[i] <- 
      (tail(gefitte_waarden_oorspr_schaal_i, 1) - gefitte_waarden_oorspr_schaal_i[1]) / 
      (n_periodes)
    gemiddelde_groei_iters[i] <- 
      (tail(gefitte_waarden_oorspr_schaal_i, 1) / gefitte_waarden_oorspr_schaal_i[1])^(1/n_periodes)
  }
  
  ## verdeling samenvatting: gemiddelde en sd op de oorspronkelijke schaal
  slope_mean <- mean(gemiddelde_verandering_iters)
  slope_sd <- sd(gemiddelde_verandering_iters)
  
  ## verdeling classificeren: zit 0 in het CRI? 
  slope_quantielen <- quantile(slope_iters, c(.025, .975))
  slope_classif <- standaard_trend_classificatie(
    slope_quantielen[1], slope_quantielen[2]
  )
  
  # zelfde voor groei (andere classificering)
  groei_mean <- mean(gemiddelde_groei_iters)
  groei_sd <- sd(gemiddelde_groei_iters)
  groei_quantielen <- quantile(gemiddelde_groei_iters, c(.025, .975))
  groei_classif <- multiplicatieve_trend_classificatie(
    groei_quantielen[1], groei_quantielen[2]
  )
  
  # FIX: voor getransformeerde parameters is de slope (op de getransformeerde 
  # schaal) altijd leidend, dus groei kan alleen significant zijn als slope 
  # dat ook is, en is nooit significant als de slope dat niet is. 
  # code hieronder werkt alleen bij Nederlandse classificaties
  if(grepl("^Significant", slope_classif) & groei_classif %in% c("Onzeker", "Stabiel")){
    groei_classif <- paste("Matige", gsub("^Significante ", "", slope_classif))
  }
  if((slope_classif == "Niet significant") & !(groei_classif %in% c("Onzeker", "Stabiel"))){
    groei_classif <- "Onzeker"
  }
  
  
  ## return
  df_terug <- data.frame(
    std_trend = slope_mean, 
    std_trend_se = slope_sd, 
    std_trend_category = slope_classif, 
    mlt_trend = groei_mean, 
    mlt_trend_se = groei_sd, 
    mlt_trend_category = groei_classif
  )
  return(df_terug)
}





standaard_trend_classificatie <- function(trendlower, trendupper, taal='NL') {
  #############################################################################
  # Hulpfunctie die wordt aangeroepen in trend_berekenen_classificeren
  # Doel: classificatie van standaard trend adhv 95% CRI in model: 
  # Als 0 niet in het CRI zit is de verandering 'significant'
  #############################################################################
  require(dplyr)
  if(trendlower > trendupper){
    stop("Ingevoerde bovengrens is kleiner dan de ondergrens")
  }
  
  if (taal=='NL' | taal=='Nederlands' | taal=='Dutch') { 
    standaardtrendcategory <- case_when(
      trendlower > 0 ~ "Significante toename", 
      trendupper < 0 ~ "Significante afname", 
      trendlower <= 0 & trendupper >= 0 ~ "Niet significant"
    )
  }
  
  if (taal=='EN' | taal=='English' | taal=='Engels') {
    standaardtrendcategory <- case_when(
      trendlower > 0 ~ "Significant increase", 
      trendupper < 0 ~ "Significant decrease", 
      trendlower <= 0 & trendupper >= 0 ~ "No significant change"
    )
  }
  
  return(standaardtrendcategory)
  
} # E I N D E functie standaard_trend_classificatie
###########################################################################################################


multiplicatieve_trend_classificatie <- function(trendlower, trendupper, taal='NL') {
  #############################################################################
  # Hulpfunctie die wordt aangeroepen in trend_berekenen_classificeren
  # Doel: classificatie van standaard trend adhv 95% CRI in model
  # Als het CRI omvat alleen waarden >= 1.05 => 'Sterke toename'
  #         CRI omvat alleen waarden >= 1    => 'Toename'
  #         CRI omvat 1 en geen waarden extremer dan 0.95 en 1.05 => 'Stabiel'
  #         CRI omvat 1 en waarden extremer dan 0.95 en 1.05      => 'Onzeker'
  #         CRI omvat alleen waarden <= 1    => 'Afname'
  #         CRI omvat alleen waarden <= 0.95 => 'Sterke afname'
  #############################################################################
  require(dplyr)
  if(trendlower > trendupper){
    stop("Ingevoerde bovengrens is kleiner dan de ondergrens")
  }
  
  if (taal=='NL' | taal=='Nederlands' | taal=='Dutch') { 
    standaardtrendcategory <- case_when(
      trendlower > 1.05 ~ "Sterke toename", 
      (trendlower > 1) & (trendlower <= 1.05)  ~ "Matige toename", 
      trendupper < 0.95 ~ "Sterke afname", 
      (trendupper < 1) & (trendupper >= 0.95)  ~ "Matige afname", 
      ((trendupper - trendlower) > 0.10) ~ "Onzeker", 
      ((trendlower - 0.95) * (1.05 - trendupper)) < 0.00 ~ "Onzeker", 
      (trendlower >= .95) & (trendupper <= 1.05) ~ "Stabiel"
    )
  }
  
  if (taal=='EN' | taal=='English' | taal=='Engels') {
    standaardtrendcategory <- case_when(
      trendlower > 1.05 ~ "Strong increase", 
      (trendlower > 1) & (trendlower <= 1.05)  ~ "Moderate increase", 
      trendupper < 0.95 ~ "Strong decrease", 
      (trendupper < 1) & (trendupper >= 0.95)  ~ "Moderate decrease", 
      ((trendupper - trendlower) > 0.10) ~ "Uncertain", 
      ((trendlower - 0.95) * (1.05 - trendupper)) < 0.00 ~ "Uncertain", 
      (trendlower >= .95) & (trendupper <= 1.05) ~ "Stabile"
    )
  }
  
  return(standaardtrendcategory)
  
} # E I N D E functie standaard_trend_classificatie
###########################################################################################################


#######################################
# Minimum reproducible example: 
# Set the code to your current working directory
# You can alternate between the two parameters of interest depending on which one you are interested in
parameternaam_jags <- "psi.fs" #This one based on the presence-absence data
#parameternaam_jags <- "mean_unconditional_cover" #This one is based on the cover data

sims$knaam |> 
  (function(x1) gsub("\\[.+\\]$", "", x1))() |>
  unique()

# simstabel inlezen (rij per parameter, kolom per MCMC-iteratie)
sims <- read.csv2("Zwarte_populier_post_sims.csv") #You can change the name of the dataset to calculate the trend of another species
#rownames(sims) = sims[,1]
#sims = sims[,-1]
# rijen met gemiddelde bedekking selecteren: 
sims_cover <- sims[
  grepl(paste0("^", parameternaam_jags), sims$knaam), 
]

trends <- trend_berekenen_classificeren_logitols(sims = sims_cover[4:6,], periode =4:6)
trends


