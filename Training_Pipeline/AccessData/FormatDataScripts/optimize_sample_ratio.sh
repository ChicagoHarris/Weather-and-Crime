for ratio in 100 50 40 30 20 10 5 4 3 2 1
#for ratio in 1 2 # for testing code
do 
    mkdir shooting
    cp WeatherandCrime_Data.shooting.ones.csv shooting
	cp WeatherandCrime_Data.shooting.zeroes.csv shooting
    ./bag_and_bin.sh WeatherandCrime_Data.csv 10 1 $ratio
    #./bag_and_bin.sh WeatherandCrime_Data.csv 1 1 $ratio  #for testing code
	mkdir ratio_$ratio
    mv  shooting ratio_$ratio
    #mv robbery ratio_$ratio
    #mv assault ratio_$ratio
    rm ratio_$ratio/shooting/WeatherandCrime_Data.shooting.ones.csv 
    rm ratio_$ratio/shooting/WeatherandCrime_Data.shooting.zeroes.csv 
    tar -cvf Shooting_$ratio.tar ratio_$ratio/shooting/*binned*
    scp Shooting_$ratio.tar mking@fusion.lcrc.anl.gov:~/data
done