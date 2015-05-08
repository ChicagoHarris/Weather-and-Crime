Weather-and-Crime
==========
This project uses enhanced analytical methods to estimate the link between weather and crime. 

Crime data is from the City of Chicago. Weather data is from NOAA, via the Plenar.io API which offers cleaned Chicago weather data for hourly reports from the city. US Census block and tract shapefiles are used to define the geospatial unit of analysis for the study. 

This project is funded by a grant from the Arnold Foundation and is housed at the University of Chicago.

Use the Get* scripts to pull the data, and then the Import scripts to centralize and format for analysis in R.



##How to Run

### Requirements

 * [Python](http://python.org/) (2.6>=, 3.3>=)
 * [R](http://www.r-project.org/)(3.1>=)
 * [package "parallel"](https://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf)
 * [package "grid"](https://stat.ethz.ch/R-manual/R-devel/library/grid/html/00Index.html)
 * [package "neuralnet"](http://cran.r-project.org/web/packages/neuralnet/neuralnet.pdf)
 * [package "nnet"](http://cran.r-project.org/web/packages/nnet/nnet.pdf)
 * [GNU Parallel](http://www.gnu.org/software/parallel/)
 * [Numpy](https://github.com/numpy/numpy)
 * [Scipy](https://github.com/scipy/scipy)
 
### Before you start

* Set the DATAPATH in the bash file `$WeatherAndCrimeROOT/script/execute.sh`. Make sure you already create directory for data and models.


### Run the Code

* Run the command  
```
cd $WeatherAndCrimeROOT/src/
bash ../script/execute.sh
```
It will go through three stages:  
    1) Preprocess the historical data and the forecast data;  
    2) Training the model with bagging in parallel;  
    3) Testing the model, and produce the prediction csv file;  
