mydata = read.csv("~/Google Drive/Copy of WeatherCrime2012_2014.csv")

#mydata <- within(mydata, {
#  dt <- strftime(dt,format = "%Y-%M-%D %H:%M:%S")
#  census_tra <- factor(census_tra)
#})
##sa and fu are not useful

nrow(mydata)
sum(mydata$assault_count > 0)
hist(mydata$drybulb_fahrenheit)
hist(mydata$hourly_precip)
index = seq(100000)
sampleData = mydata[index,]

d = as.data.frame(sampleData)

#Remove NULL data
d[is.na(d)] = 0
sum(d$homicide_count)

library(pscl)
summary(m1 <- zeroinfl(d$homicide_count~factor(census_tra) + drybulb_fahrenheit + hourly_precip + relative_humidity + wind_speed,dist = "poisson", link = "logit",data = d))


