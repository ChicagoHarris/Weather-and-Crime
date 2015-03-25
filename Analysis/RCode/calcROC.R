########code for calculating TP and FP################

## input: positiveResult: the average prediction for all the positive cases. For eg, if we have 16 bagged samples, positiveResult = (pos_1 + pos_2 + pos_3 + .... + pos_16) / 16
## input: negativeResult: the average prediction for all the negative cases. For eg, if we have 16 bagged samples, negativeResult = (neg_1 + neg_2 + neg_3 + .... + neg_16) / 16

positiveBinaryPredict = positiveResult
positiveBinaryPredict[positiveBinaryPredict > 0.5] = 1
positiveBinaryPredict[positiveBinaryPredict <= 0.5] = 0

TP = mean(positiveBinaryPredict)

negativeBinaryPredict = negativeResult
negativeBinaryPredict[negativeBinaryPredict > 0.5] = 1
negativeBinaryPredict[negativeBinaryPredict <= 0.5] = 0

FP = mean(negativeBinaryPredict)




