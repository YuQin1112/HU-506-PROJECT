setwd("C:\\Users\\fgh0809\\Documents\\GitHub\\HU-506-PROJECT")


library(readr)
real_data <- read_csv("real_data.csv")

# keep columns that has less than 10% NA
df <- real_data[,colSums(is.na(real_data))<nrow(real_data)*0.1]

summary(df)

# we are only analyzing numeric data. 
# exctract categorical data out and attach it as attr in order not to lose the information
chars <- unlist(lapply(df, is.character))  
nums <- unlist(lapply(df, is.numeric))  
only_char<-df[,chars]
only_num<-df[ , nums]

str(only_num)
summary(only_num)



# remove outlier by 1.5 IQR
remove_outliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(0.25, 0.75), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}
  
noout1<-apply(only_num, 2, remove_outliers)

# deal with NA's again, fill it with average if number of NAs less than 10% else drop the column
replace_na <- function(x) {
    m = mean(x, na.rm = TRUE)
    x[is.na(x)] <- m
    x
}
noout1<-noout1[,colSums(is.na(noout1))<nrow(noout1)*0.1]
noout1<-apply(noout1, 2, replace_na)
summary(noout1)

noout2<-cbind(only_char,noout1)

# I forgot what excactly mahalanobis does. 
# but it does filter out outliers that not produced by potential same distribution?
mahal = mahalanobis(
  noout1,
  colMeans(noout1, na.rm=TRUE),
  cov(noout1, use="pairwise.complete.obs"),
  tol=1e-25 
)
cutmahal = qchisq(1-.05,ncol(noout1))
badmahal = as.numeric(mahal > cutmahal)
table(badmahal)
noout3 = subset(noout2, badmahal < 1)
summary(noout3)
str(noout3)

