# precip_hour_cnt_in_last_1_day is row 32
# NR stands for "Number Row" so I can treat the headers differently
# '\' says to include the next line in this command as well
NR == 1 {
	print $0  \
	",rain_1d_count_=0" \
	",rain_1d_count_1_to_5" \
	",rain_1d_count_5_to_10" \
	",rain_1d_count_10_to_20" \
	",rain_1d_count_20_to_24"
#        ",count_=0" \
#        ",count_1_to_5" \
#        ",count_5_to_10" \
#        ",count_10_to_20" \
#        ",count_20_to_24"
}
(NR > 1) {
	print $0 \
	"," ($32 == 0 ? 1 : 0) \
	"," (0 < $32 && $32 <= 5 ? 1 : 0) \
	"," (5 < $32 && $32 <= 10 ? 1 : 0) \
	"," (10 < $32 && $32 <= 20 ? 1 : 0) \
	"," (20 < $32 && $32 <= 24 ? 1 : 0)
}
