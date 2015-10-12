# How to Run: 
# ./bag_and_bin.sh inputfile numberofbags [TRUE/FALSE to use cached main file -never applicable in the updater] DownsamplingFactor
helperDir="../../../../Helpers"

set +x
if [[ "z$1" == "z" ]]; then
		echo "Need to pass in an input file"
		exit 1
fi
baggedFile=$1
binnedFile=$baggedFile.binned
tmpBinnedFile=$binnedFile.tmp

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
	
exit 0



