#This python file buckets observations into bins based off their predictied probabilities of a shooting

import csv
with open('predictedDataNew.csv') as f:
	reader = csv.reader(f,delimiter=' ')
	data=[]
	headers = reader.next()
	
	ratios = {'Equal0':{'positive':0,'total':0},'0':{'positive':0,'total':0},'1':{'positive':0,'total':0},'2':{'positive':0,'total':0},'3':{'positive':0,'total':0},'4':{'positive':0,'total':0},'5':{'positive':0,'total':0},'6':{'positive':0,'total':0},'7':{'positive':0,'total':0},'8':{'positive':0,'total':0},'9':{'positive':0,'total':0}}
	for line in reader:
		values = [float(i) for i in line[-16:]]
		line = line[:-16]
		average = sum(values)/float(len(values))
		#line.append(average)
		if average == 0:
			bucket =='Equal0'
		else:
			bucket = str(int(100*average)/10)
		shooting = int(line[904])
		ratios[bucket]['total']+=1
		if shooting >=1:
			ratios[bucket]['positive']+=1
	for key in ratios.keys():
		if ratios[key]['total'] != 0:
			print ratios[key]['positive'] / ratios[key]['total']
	print ratios
