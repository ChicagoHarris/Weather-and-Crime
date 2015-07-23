#!/bin/bash

for i in `seq 1 9`;
do
mv prediction_daily_2015-06-$i.csv prediction_daily_2015-06-0$i.csv
done
