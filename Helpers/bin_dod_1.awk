# NR stands for "Number Row" so I can treat the headers differently
# '\' says to include the next line in this command as well
NR == 1 {
	print $0  \
	",dod_1_change_=0" \
	",dod_1_change_1_to_5" \
	",dod_1_change_5_to_10" \
	",dod_1_change_10_to_20" \
	",dod_1_change_20_to_30" \
	",dod_1_change_30_to_40" \
	",dod_1_change_40_to_50" \
	",dod_1_change_>50" \
	",dod_1_change_neg1_to_neg5" \
	",dod_1_change_neg5_to_neg10" \
	",dod_1_change_neg10_to_neg20" \
	",dod_1_change_neg20_to_neg30" \
	",dod_1_change_neg30_to_neg40" \
	",dod_1_change_neg40_to_neg50" \
	",dod_1_change_>neg50"
#        ",change_=0" \
#        ",change_1_to_5" \
#        ",change_5_to_10" \
#        ",change_10_to_20" \
#        ",change_20_to_30" \
#        ",change_30_to_40" \
#        ",change_40_to_50" \
#        ",change_>50" \
#        ",change_neg1_to_neg5" \
#        ",change_neg5_to_neg10" \
#        ",change_neg10_to_neg20" \
#        ",change_neg20_to_neg30" \
#        ",change_neg30_to_neg40" \
#        ",change_neg40_to_neg50" \
#        ",change_>neg50"

}
(NR > 1) {
	print $0 \
	"," ($27 == 0 ? 1 : 0) \
	"," (0 < $27 && $27 < 5 ? 1 : 0) \
	"," (5 <= $27 && $27 < 10 ? 1 : 0) \
	"," (10 <= $27 && $27 < 20 ? 1 : 0) \
	"," (20 <= $27 && $27 < 30 ? 1 : 0) \
	"," (30 <= $27 && $27 < 40 ? 1 : 0) \
	"," (40 <= $27 && $27 < 50 ? 1 : 0) \
	"," (50 <= $27 ? 1 : 0) \
	"," (0 > $27 && $27 > -5 ? 1 : 0) \
	"," (-5 >= $27 && $27 > -10 ? 1 : 0) \
	"," (-10 >= $27 && $27 > -20 ? 1 : 0) \
	"," (-20 >= $27 && $27 > -30 ? 1 : 0) \
	"," (-30 >= $27 && $27 > -40 ? 1 : 0) \
	"," (-40 >= $27 && $27 > -50 ? 1 : 0) \
	"," ($27 <= -50 ? 1 : 0)
}
