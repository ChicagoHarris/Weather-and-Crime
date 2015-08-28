# relative_humidity is the 12th column, awk references that with $12
# NR stands for "Number Row" so I can treat the headers differently
# '\' says to include the next line in this command as well
NR == 1 {
	print $0  \
	",humidity_<10" \
	",humidity_10_to_20" \
	",humidity_20_to_30" \
	",humidity_30_to_40" \
	",humidity_40_to_50" \
	",humidity_50_to_60" \
	",humidity_60_to_70" \
	",humidity_70_to_80" \
	",humidity_80_to_90" \
	",humidity_90_to_100"
}
(NR > 1) {
	print $0 \
	"," ($12 < 10 ? 1 : 0) \
	"," (10 <= $12 && $12 < 20 ? 1 : 0) \
	"," (20 <= $12 && $12 < 30 ? 1 : 0) \
	"," (30 <= $12 && $12 < 40 ? 1 : 0) \
	"," (40 <= $12 && $12 < 50 ? 1 : 0) \
	"," (50 <= $12 && $12 < 60 ? 1 : 0) \
	"," (60 <= $12 && $12 < 70 ? 1 : 0) \
	"," (70 <= $12 && $12 < 80 ? 1 : 0) \
	"," (80 <= $12 && $12 < 90 ? 1 : 0) \
	"," (90 <= $12 && $12 < 100 ? 1 : 0)
}
