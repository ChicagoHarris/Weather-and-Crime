# drybulb_fahrenheit is the 10th column, awk references that with $10
# NR stands for "Number Row" so I can treat the headers differently
# '\' says to include the next line in this command as well
NR == 1 {
	print $0  \
	",temp_<_neg20" \
	",temp_neg20_to_neg11" \
	",temp_neg10_to_neg1" \
	",temp_0_to_9" \
	",temp_10_to_19" \
	",temp_20_to_29" \
	",temp_30_to_39" \
	",temp_40_to_49" \
	",temp_50_to_59" \
	",temp_60_to_69" \
	",temp_70_to_79" \
	",temp_80_to_89" \
	",temp_90_to_99" \
	",temp_100_to_109" \
	",temp_110_to_119" \
	",temp_>=_120"
}
(NR > 1) {
	print $0 \
	"," ($10 < -20 ? 1 : 0) \
	"," (-20 <= $10 && $10 < -10 ? 1 : 0) \
	"," (-10 <= $10 && $10 < 0 ? 1 : 0) \
	"," (0 <= $10 && $10 < 10 ? 1 : 0) \
	"," (10 <= $10 && $10 < 20 ? 1 : 0) \
	"," (20 <= $10 && $10 < 30 ? 1 : 0) \
	"," (30 <= $10 && $10 < 40 ? 1 : 0) \
	"," (40 <= $10 && $10 < 50 ? 1 : 0) \
	"," (50 <= $10 && $10 < 60 ? 1 : 0) \
	"," (60 <= $10 && $10 < 70 ? 1 : 0) \
	"," (70 <= $10 && $10 < 80 ? 1 : 0) \
	"," (80 <= $10 && $10 < 90 ? 1 : 0) \
	"," (90 <= $10 && $10 < 100 ? 1 : 0) \
	"," (100 <= $10 && $10 < 110 ? 1 : 0) \
	"," (110 <= $10 && $10 < 120 ? 1 : 0) \
	"," (120 <= $10 ? 1 : 0)
}
