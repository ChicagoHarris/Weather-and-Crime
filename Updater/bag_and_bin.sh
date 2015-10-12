# How to Run: 
# ./bag_and_bin.sh inputfile numberofbags [TRUE/FALSE to use cached main file -never applicable in the updater] DownsamplingFactor
helperDir="../../../Helpers"

set +x
if [[ "z$1" == "z" ]]; then
		echo "Need to pass in an input file"
		exit 1
fi
if [[ "z$2" == "z" ]]; then
	echo "No bag passed in via 2nd param, defaulting to 1"
	NumBags=1
else
	NumBags=$2
fi

if [[ "z$3" == "z1" ]]; then
	useCachedMainOnesAndZeroes="true"
else
	useCachedMainOnesAndZeroes="false"
fi

if [[ "z$4" == "z" ]]; then
	echo "No multiple parameter passed in, defaulting to creating balanced samples"
	MultipleOfZeroes=1
else
	MultipleOfZeroes=$4
fi

input=$1
baseName=$( echo $1 | sed 's/.csv//' )
bagDir="bag"
binDir="bin"

#mkdir -p $bagDir
#mkdir -p $binDir
for crime in shooting robbery assault; do
#for crime in shooting; do
	echo ""
	echo "*** Starting $crime @ $(date)"
	if [[ "$crime" == "shooting" ]]; then
		crimeCsvColumn=5
	elif [[ "$crime" == "robbery" ]]; then
		crimeCsvColumn=6
	elif [[ "$crime" == "assault" ]]; then
		crimeCsvColumn=7
	else 
		echo " Invalid loop value"
		exit 1
	fi
	dir=$crime
	mkdir -p $dir
	onesFile=$dir/$baseName.$crime.ones.csv
	zeroesFile=$dir/$baseName.$crime.zeroes.csv

	awkOneCmd="NR>1 {if ($"${crimeCsvColumn}' >= 1 && 2009 <= $2 && $2 <= 2013) print $0}'
	awkZeroCmd="NR>1 {if ($"${crimeCsvColumn}' == 0 && 2009 <= $2 && $2 <= 2013) print $0}'

	# Use 2009 - 2013 for training
	if [ "$useCachedMainOnesAndZeroes" == "true" ] && [ -e $onesFile ]; then
		echo " Using cached $onesFile"	
	else
		echo " Writing training $crime Ones to $onesFile  @ $(date)"
		awk -F, "$awkOneCmd" $input > $onesFile
	fi	

	if [ "$useCachedMainOnesAndZeroes" == "true" ] && [ -e $zeroesFile ]; then
		echo " Using cached $zeroesFile"
	else
		echo " Writing training $crime Zeroes to $zeroesFile  @ $(date)"
		awk -F, "$awkZeroCmd" $input > $zeroesFile
	fi

	# Find how many zeros to pull
	NumberOfOnes=$(wc -l $onesFile | awk '{print $1 }')
	echo " Found $NumberOfOnes rows with One"

	for iter in $(seq 1 $NumBags); do
		echo " Starting iteration $iter @ $(date)"

		iterZeroesFile=$dir/$baseName.$crime.$iter.zeroes.csv
		baggedFile=$dir/$baseName.$crime.$iter.bagged.csv
		binnedFile=$dir/$baseName.$crime.$iter.binned.csv
		tmpBinnedFile=$binnedFile.tmp

		echo " Pulling $NumberOfOnes total rows into $iterZeroesFile"
		#For perfrectly balanced samples run this line:
		#perl $helperDir/randlines.pl $NumberOfOnes $zeroesFile > $iterZeroesFile
		
		#For tuned downsamples instead of perfectly balanced samples, run this line and define the tuning parameter $MultipleOfZeroes first
		set -x
		echo $NumberOfOnes
		numberofzeroes=$(($MultipleOfZeroes*$NumberOfOnes))
		perl $helperDir/randlines.pl $numberofzeroes $zeroesFile > $iterZeroesFile
		set +x

		foundZeros=$(wc -l $iterZeroesFile | awk '{print $1 }') 
		echo " Found $foundZeros Zeroes in $iterZeroesFile"

		# Write the header row out
		head -n 1 $input > $baggedFile
		echo " Writing Zeros and Ones to $baggedFile"
		cat $onesFile >> $baggedFile
		cat $iterZeroesFile >> $baggedFile

		echo " Binning $baggedFile to $binnedFile"
		awk -F, -f $helperDir/bin_1_temperature.awk $baggedFile \
			| awk -F, -f $helperDir/bin_2_wind.awk \
			| awk -F, -f $helperDir/bin_4_rain.awk \
			| awk -F, -f $helperDir/bin_5_humidity.awk \
			| awk -F, -f $helperDir/bin_wow_1.awk \
			| awk -F, -f $helperDir/bin_wow_2.awk \
			| awk -F, -f $helperDir/bin_dod_1.awk \
			| awk -F, -f $helperDir/bin_dod_2.awk \
			| awk -F, -f $helperDir/bin_dod_3.awk \
			| awk -F, -f $helperDir/bin_rain_count_1day.awk \
			| awk -F, -f $helperDir/bin_rain_count_2day.awk \
			| awk -F, -f $helperDir/bin_rain_count_1week.awk \
			| awk -F, -f $helperDir/bin_count_SINCE_rain.awk \
			> $binnedFile

		awk -F, -v column="37" -f $helperDir/unpivot.awk $binnedFile $binnedFile > $tmpBinnedFile
		mv $tmpBinnedFile $binnedFile

		awk -F, -v column="36" -f $helperDir/unpivot.awk $binnedFile $binnedFile > $tmpBinnedFile
		mv $tmpBinnedFile $binnedFile
		
		awk -F, -v column="2" -f $helperDir/unpivot.awk $binnedFile $binnedFile > $tmpBinnedFile
		mv $tmpBinnedFile $binnedFile

		awk -F, -v column="3" -f $helperDir/unpivot.awk $binnedFile $binnedFile > $tmpBinnedFile
		mv $tmpBinnedFile $binnedFile

		awk -F, -v column="1" -f $helperDir/unpivot.awk $binnedFile $binnedFile > $tmpBinnedFile
		mv $tmpBinnedFile $binnedFile
	
		gzip -f $binnedFile
	
	done
	
done
exit 0



