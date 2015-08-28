# This requires the file to be passed in twice, so I can loop through once getting all the id's
# and then on the second time through use all the id's to create binned columns

BEGIN {
	unpivotColumn=column

}

# The first time through
NR == FNR {
	# Build an array of all the id's we've found so far
	# Ordering is based on the order the id is found in, which shouldn't matter for binning
	if (FNR > 1) {
		a[$unpivotColumn]=0
	}
}

# The second time through
NR > FNR {

	bins=""
	if (FNR > 1) {
		#print "Found " $unpivotColumn " @ FNR: " FNR
		a[$unpivotColumn]=1
	}
	
	for (id in a) {
		if (FNR == 1)  {
			bins=bins "," $unpivotColumn "_" id
		}
		else {
			bins=bins","a[id]
		}
	}

	print $0 bins
	if (FNR > 1) {
		a[$unpivotColumn]=0 			# reset the array to be all zeroes again
	}
}

