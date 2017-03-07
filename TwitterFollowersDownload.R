
library(stringr)
library(dplyr)
library(twitteR)
#library(XLConnect)

# Declare Twitter API Credentials
api_key <- "AAAABBBB" # From dev.twitter.com
api_secret <- "CCCCDDDD" # From dev.twitter.com
token <- "123-ABCD" # From dev.twitter.com
token_secret <- "TTTTT" # From dev.twitter.com

# Create Twitter Connection
setup_twitter_oauth(api_key, api_secret, token, token_secret)

#Uploading lists of previously Rejected or Accepted Accounts
#Rejected_Accounts <- read.csv(Rejected_Accounts, header = TRUE, sep = ",")
#Accepted_Accounts <- read.csv(Accepted_Accounts, header = TRUE, sep = ",")

#Paste the Twitter Account that you want to export Followers from
Account <- getUser("MIT")
followersAccount <- Account$getFollowers()
followersAccount_DF <- twListToDF(followersAccount)

#Adding Columns
followersAccount_DF$link <- paste("https://twitter.com/", followersAccount_DF$screenName, sep="")
followersAccount_DF$handle <- paste("@", followersAccount_DF$screenName, sep="")

#Filtering the List
followersAccount_DF_Clean <- followersAccount_DF %>%
  select(-id, -listedCount, -followRequestSent, -profileImageUrl) %>%
  filter(protected==0) %>%
  filter(!(description %in% c("", "XXX", "porn"))) %>%
  filter(friendsCount < 2000) %>%
  filter(statusesCount > 1) %>%
  filter(!(friendsCount > 500  & (friendsCount/followersCount) > 10))
#Checking with old Lists (you can remove this bit)
#anti_join(Rejected_Accounts, by = "handle") %>%
# anti_join(Accepted_Accounts, by = "handle")

#Adding Date of last interacion
Lookup_FADF_Clean <- lookupUsers(followersAccount_DF_Clean$screenName)
n_of_rows <- nrow(followersAccount_DF_Clean)

Dates_List <- c(rep(NA,n_of_rows))
class(Dates_List) <- "Date"

for(i in 1:n_of_rows) {
  Dates_List[i] <- Lookup_FADF_Clean[[i]]$lastStatus$created
}

followersAccount_DF_Clean$Last_Interaction <- Dates_List

#Wrting to a CSV
write.table(followersAccount_DF_Clean, file = "MIT.csv", sep = ";",row.names = FALSE)