# wind_speed is the 9th column, awk references that with $9
# NR stands for "Number Row" so I can treat the headers differently
# '\' says to include the next line in this command as well
# bins based on http://www.isws.illinois.edu/atmos/statecli/wind/wind.htm
NR == 1 {
	print $0 \
	",wind_<_5mph" \
	",wind_5_to_10mph" \
	",wind_11_to_15mph" \
	",wind_16_to_20mph" \
	",wind_21_to_25mph" \
	",wind_26_to_30mph" \
	",wind_31_to_35mph" \
	",wind_36_to_40mph" \
	",wind_41_to_45mph" \
	",wind_46_to_50mph" \
	",wind_>=_50mph"
}
(NR > 1) {
	print $0 \
	"," ($9 < 5 ? 1 : 0) \
	"," (5 <= $9 && $9 < 10 ? 1 : 0) \
	"," (10 <= $9 && $9 < 15 ? 1 : 0) \
	"," (15 <= $9 && $9 < 20 ? 1 : 0) \
	"," (20 <= $9 && $9 < 25 ? 1 : 0) \
	"," (25 <= $9 && $9 < 30 ? 1 : 0) \
	"," (30 <= $9 && $9 < 35 ? 1 : 0) \
	"," (35 <= $9 && $9 < 40 ? 1 : 0) \
	"," (40 <= $9 && $9 < 45 ? 1 : 0) \
	"," (45 <= $9 && $9 < 50 ? 1 : 0) \
	"," (50 <= $9 ? 1 : 0)
}
