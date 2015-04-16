#This R file compares the prediction results of crime using logistic bagging regressions when weather variables are included and when they are omitted.

bag_results_weather <-function(training,testing){
	full_predicted = NULL
	for(draw in 1:20)
			{
			#sample from zero cases to create a balanced sample and then make predictions
			zero_cases<-subset(training, training$shooting_count ==0)
			pos_count = sum(training$shooting_count>0)
			bag = zero_cases[sample(length(zero_cases$shooting_count),size=pos_count,replace=F),]
			bag = rbind(bag,training[training$shooting_count>0,])
			logit_bag_model = glm(shooting_count ~ drybulb_fahrenheit+relative_humidity+hourly_precip+wind_speed+factor(day_of_week)+factor(hournumber)+factor(census_tra), data=bag,family="binomial")
			predicted_prob = predict(logit_bag_model,newdata = testing,"response")
			full_predicted = rbind(predicted_prob,full_predicted)
			}
		#average the 20 resulting probability predictions and code to 0 or 1
	testing$average_predict = colMeans(full_predicted)
	testing$binary_logit_bag_predict = ifelse(testing$average_predict < .5, 0, ifelse(testing$average_predict >= .5,1,0)  )
	bag_true_pos_acc = nrow( testing[testing$binary_logit_bag_predict==1 & testing$shooting_count==1,] ) / nrow(testing[testing$shooting_count==1,])
	bag_true_neg_acc = nrow( testing[testing$binary_logit_bag_predict==0 & testing$shooting_count==0,] ) / nrow(testing[testing$shooting_count==0,])
	results = c(bag_true_pos_acc,bag_true_neg_acc)
	return (results)
	}

bag_results_noweather <-function(training,testing){
	full_predicted = NULL
	for(draw in 1:20)
			{
			#sample from zero cases to create a balanced sample and then make predictions
			zero_cases<-subset(training, training$shooting_count ==0)
			pos_count = sum(training$shooting_count>0)
			bag = zero_cases[sample(length(zero_cases$shooting_count),size=pos_count,replace=F),]
			bag = rbind(bag,training[training$shooting_count>0,])
			logit_bag_model = glm(shooting_count ~ factor(day_of_week)+factor(hournumber)+factor(census_tra), data=bag,family="binomial")
			predicted_prob = predict(logit_bag_model,newdata = testing,"response")
			full_predicted = rbind(predicted_prob,full_predicted)
			}
		#average the 20 resulting probability predictions and code to 0 or 1
	testing$average_predict = colMeans(full_predicted)
	testing$binary_logit_bag_predict = ifelse(testing$average_predict < .5, 0, ifelse(testing$average_predict >= .5,1,0))
	bag_true_pos_acc = nrow( testing[testing$binary_logit_bag_predict==1 & testing$shooting_count==1,] ) / nrow(testing[testing$shooting_count==1,])
	bag_true_neg_acc = nrow( testing[testing$binary_logit_bag_predict==0 & testing$shooting_count==0,] ) / nrow(testing[testing$shooting_count==0,])
	#returns positive and negative prediction accuracy
	results = c(bag_true_pos_acc, bag_true_neg_acc)
	return (results)
}


#Full logit model
logit_results_weather <-function(training,testing){
	full_logit_model = glm(shooting_count ~ drybulb_fahrenheit+relative_humidity+hourly_precip+wind_speed+factor(day_of_week)+factor(hournumber)+factor(census_tra), data=training,family="binomial")
	testing$full_logit_model_predict = predict(full_logit_model,newdata = testing,"response")
	testing$binary_full_logit_predict = ifelse(testing$full_logit_model_predict < .5, 0, ifelse(testing$average_predict >= .5,1,0))
	sum(testing$shooting_count == testing$binary_full_logit_predict)
	logit_true_pos_acc = nrow( testing[testing$full_logit_model_predict==1 & testing$shooting_count==1,] ) / nrow(testing[testing$shooting_count==1,])
	logit_true_neg_acc = nrow( testing[testing$full_logit_model_predict==0 & testing$shooting_count==0,] ) / nrow(testing[testing$shooting_count==0,])
	##returns positive and negative prediction accuracy and beta coefficient for temperature
	results = c( logit_true_pos_acc, logit_true_neg_acc, summary(full_logit_model)$coef[2,] )
	return (results)
}

logit_results_noweather <-function(training,testing){
	full_logit_model = glm(shooting_count ~ factor(day_of_week)+factor(hournumber)+factor(census_tra), data=training,family="binomial")
	testing$full_logit_model_predict = predict(full_logit_model,newdata = testing,"response")
	testing$binary_full_logit_predict = ifelse(testing$full_logit_model_predict < .5, 0, 1)
	sum(testing$shooting_count == testing$binary_full_logit_predict)
	logit_true_pos_acc = nrow(testing[testing$shooting_count == testing$binary_full_logit_predict && testing$shooting_count==1,]) / nrow(testing[testing$shooting_count==1,])
	logit_true_neg_acc = nrow(testing[testing$shooting_count == testing$binary_full_logit_predict && testing$shooting_count==0,]) / nrow(testing[testing$shooting_count==0,])
	results = c(logit_true_pos_acc, logit_true_neg_acc)
	return (results)
}


#zeroinfl


