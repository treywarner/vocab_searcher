use warnings;
use strict;
use LWP::Simple;
use File::Slurp;
use HTML::Entities;
use YAML 'Dump';

unless (open(FILE, "<", "medieval_text")) {
    open(FILE, ">", "medieval_text");
    my $html;
    my @urls = ("medieval/castle.htm", "medieval/chivarlic.htm", "medieval/cooking.htm", "medieval/ecclesiastical.htm", "medieval/feudal.htm", "medieval/manorial.htm");

    foreach (@urls) {
        print $_;
        $html .= (get "https://home.olemiss.edu/~tjray/$_");
    }
    print FILE $html;
    print $html;
}
my $text = read_file('medieval_text');
my %library;
while ($text =~ /<b>(.*?)<\/b>.*?- (.*?)</sg) {
    my ($key, $value) = (decode_entities($1), decode_entities($2));
    #next if $value =~ /<script/;
    $value =~ s/\R//sg;
    if ($key =~ /(.*?) or (.*?)$/) {
        $library{$2}=$value;
        while ($1 =~ /(\w+)/g) {
            $library{$1} = $value;
        }

        
    } else {
        $library{$key}=$value;
    }
    #print $1, "\n", $2, "\n\n";
}

open(FILE, '>', 'medieval_vocab');
my $key;
foreach $key (keys %library) {
    print FILE "$key: $library{$key}\n";
}