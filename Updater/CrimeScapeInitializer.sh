# CrimeScape Initializer
# For Updater Pipeline
# Run from project's Updater directory: Weather-and-Crime/Updater/


## For Getting the data and installing R
brew install jq
brew install wget
brew install go
brew tap homebrew/science
brew install gcc
brew install Caskroom/cask/xquartz
brew install r


# set GOPATH
mkdir $HOME/work
export GOPATH=$HOME/work
export PATH=$PATH:$GOPATH/bin

go get github.com/jehiah/json2csv

## For Formatting the data

#postgis
brew install postgis


# Start postgres on OS X


# R updater section
R
install.packages("nnet")
install.packages("neuralnet")
# End Initialize Section.

# To pull most recent models output from server: 
scp maggiek@128.135.232.75:/mnt/research_disk_1/newhome/weather_crime/Weather-and-Crime/Master_Pipeline/output/prediction_daily*.csv ./
