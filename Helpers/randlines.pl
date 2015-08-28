use strict;
use warnings;
use Symbol;
use Fcntl qw( :seek O_RDONLY ) ;
#my $seekdiff = 256; #e.g. from "rand_position-256" up to rand_positon+256
my $seekdiff = 175; #e.g. from "rand_position-256" up to rand_positon+256

my($want, $filename) = @ARGV;

my $fd = gensym ;
sysopen($fd, $filename, O_RDONLY ) || die("Can't open $filename: $!");
binmode $fd;
my $endpos = sysseek( $fd, 0, SEEK_END ) or die("Can't seek: $!");

my $buffer;
my $cnt;
while($want > $cnt++) {
    my $randpos = int(rand($endpos));   #random file position
    my $seekpos = $randpos - $seekdiff; #start read here ($seekdiff chars before)
    $seekpos = 0 if( $seekpos < 0 );

    sysseek($fd, $seekpos, SEEK_SET);   #seek to position
    my $in_count = sysread($fd, $buffer, $seekdiff<<1); #read 2*seekdiff characters

    my $rand_in_buff = ($randpos - $seekpos)-1; #the random positon in the buffer

    my $linestart = rindex($buffer, "\n", $rand_in_buff) + 1; #find the begining of the line in the buffer
    my $lineend = index $buffer, "\n", $linestart;            #find the end of line in the buffer
    my $the_line = substr $buffer, $linestart, $lineend < 0 ? 0 : $lineend-$linestart;

    print "$the_line\n";
}
