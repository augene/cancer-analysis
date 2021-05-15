library(dplyr)
library(stringr)


#raw df
california_new_cancer <- read.csv("data/california_new_cancer.csv")
oregon_new_cancer <- read.csv("data/oregon_new_cancer.csv")
washington_new_cancer <- read.csv("data/washington_new_cancer.csv")

#merge df together
  #merged_df <- merge(california_new_cancer, oregon_new_cancer)

#format df
california_new_cancer <- data.frame(california_new_cancer, stringsAsFactors = FALSE)
oregon_new_cancer <- data.frame(oregon_new_cancer, stringsAsFactors = FALSE)
washington_new_cancer <- data.frame(washington_new_cancer, stringsAsFactors = FALSE)

california_new_cancer$AgeAdjustedRate <- gsub("'", "", california_new_cancer$AgeAdjustedRate)
california_new_cancer$CaseCount <- gsub("'", "", california_new_cancer$CaseCount)
california_new_cancer$Population <- gsub("'", "", california_new_cancer$Population)

#Statistic calculations
statistics <- california_new_cancer %>% summarize(
  n_counties = n(),
  avg_age_adj_rate = mean(AgeAdjustedRate),
  min_age_adj_rate = min(AgeAdjustedRate),
  max_age_adj_rate = max(AgeAdjustedRate),
  
  )

#diagnose why summarise not working
is.numeric(california_new_cancer$AgeAdjustedRate) #not numeric

#identify class of columns
sapply(california_new_cancer, class)

#convert to numeric
class_is_character <- c("AgeAdjustedRate", 
                        "CaseCount", "Population")
california_new_cancer[ , class_is_character] <- apply(california_new_cancer[ , class_is_character], 2,            # Specify own function within apply
                    function(x) as.numeric(as.character(x)))






?gsub()

df1$x1<-gsub("'","",df1$x1)
df1


avg_age_adj_rate = avg(County)

?print()
