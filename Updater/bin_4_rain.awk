# hourly_precip is the 11th column, awk references that with $11
# NR stands for "Number Row" so I can treat the headers differently
# '\' says to include the next line in this command as well
NR == 1 {
	print $0  \
	",rain_=0" \
	",rain_0_to_.01" \
	",rain_.01_to_.02" \
	",rain_.02_to_.03" \
	",rain_.03_to_.04" \
	",rain_.04_to_.05" \
	",rain_.05_to_0.1" \
	",rain_0.1_to_0.2" \
	",rain_0.2_to_0.3" \
	",rain_0.3_to_0.4" \
	",rain_0.4_to_0.5" \
	",rain_0.5_to_1" \
	",rain_>1"
}
(NR > 1) {
	print $0 \
	"," ($11 == 0 ? 1 : 0) \
	"," (0 < $11 && $11 < 0.01 ? 1 : 0) \
	"," (0.01 <= $11 && $11 < 0.02 ? 1 : 0) \
	"," (0.02 <= $11 && $11 < 0.03 ? 1 : 0) \
	"," (0.03 <= $11 && $11 < 0.04 ? 1 : 0) \
	"," (0.04 <= $11 && $11 < 0.05 ? 1 : 0) \
	"," (0.05 <= $11 && $11 < 0.1 ? 1 : 0) \
	"," (0.1 <= $11 && $11 < 0.2 ? 1 : 0) \
	"," (0.2 <= $11 && $11 < 0.3 ? 1 : 0) \
	"," (0.3 <= $11 && $11 < 0.4 ? 1 : 0) \
	"," (0.4 <= $11 && $11 < 0.5 ? 1 : 0) \
	"," (0.5 <= $11 && $11 < 1 ? 1 : 0) \
	"," (1 <= $11 ? 1 : 0)
}
