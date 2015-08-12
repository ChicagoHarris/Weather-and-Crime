# precip_hour_cnt_in_last_3_day is row 33
# NR stands for "Number Row" so I can treat the headers differently
# '\' says to include the next line in this command as well
NR == 1 {
	print $0  \
	",count_=0" \
	",count_1_to_5" \
	",count_5_to_10" \
	",count_10_to_20" \
	",count_20_to_24" \
	",count_24_to_30" \
	",count_30_to_36" \
	",count_37_to_47" \
	",count_48_to_57" \
	",count_58_to_65" \
	",count_66_to_72"
}
(NR > 1) {
	print $0 \
	"," ($33 == 0 ? 1 : 0) \
	"," (0 < $33 && $33 <= 5 ? 1 : 0) \
	"," (5 < $33 && $33 <= 10 ? 1 : 0) \
	"," (10 < $33 && $33 <= 20 ? 1 : 0) \
	"," (20 < $33 && $33 <= 24 ? 1 : 0) \
	"," (24 < $33 && $33 <= 30 ? 1 : 0) \
	"," (30 < $33 && $33 <= 36 ? 1 : 0) \
	"," (36 < $33 && $33 <= 47 ? 1 : 0) \
	"," (47 < $33 && $33 <= 57 ? 1 : 0) \
	"," (57 < $33 && $33 <= 65 ? 1 : 0) \
	"," (65 < $33 && $33 <= 72 ? 1 : 0)
}
