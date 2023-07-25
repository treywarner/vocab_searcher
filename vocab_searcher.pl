use strict;
use warnings;
use Term::ANSIColor;
use Getopt::Long qw(GetOptionsFromArray);
use autodie;

our %colors = (
    'query' => 'on_red',
    'topic' => 'red',
    'query' => 'blue',
    'query&link' => 'green',
    'link' => 'magenta'
);

sub uncolor {
    return $_[0] =~ s/\e.*?m//gr;
}

sub format_sentence {
    my ($sentence, $topics, $query, $plain) = @_;

    my ($topic, $rest_of_sentence) = split(/:/, $sentence, 2);

    $rest_of_sentence =~ s/($query)/colored("$1","$colors{'query'}")/ieg;

    for my $i (0 .. $#{$topics}) {
        $rest_of_sentence =~ s/(\Q${$topics}[$i]\E)/colored("$1","$colors{'link'}")/ieg;
    }
    $sentence = colored($topic.':', $colors{'topic'}) . $rest_of_sentence;
    return $plain ? uncolor($sentence) : $sentence;

    # push @output_sentence, colored("$topic:", $colors{'topic'});

    # my @words = split(/\s+/, $rest_of_sentence);

    # for my $word (@words) {
    #     my ($found_topic, $split1, $split2, $split3) = (-1, '', '', '');

    #     for my $i (0 .. $#{$topics}) {
    #         if ($word =~ /(.*)(\Q${$topics}[$i]\E)(.*)/i) {
    #             $found_topic = $i;
    #             $split1 = $1;
    #             $split2 = $2;
    #             $split3 = $3;
    #             last;
    #         }
    #     }

    #     if ($word =~ /$query/i && $found_topic >= 0) {
    #         push @output_sentence, colored($word, $colors{'query&link'}) . ' ';
    #     } elsif ($word =~ /$query/i) {
    #         push @output_sentence, colored($word, $colors{'query'}) . ' ';
    #     } elsif ($found_topic >= 0) {
    #         push @output_sentence, $split1 . colored($split2, $colors{'link'}) . $split3 . ' ';
    #     } else {
    #         push @output_sentence, $word . ' ';
    #     }
    # }

    #return $plain ? join('', map { uncolor($_) } @output_sentence) : @output_sentence;
}

sub print_query {
    my ($query, $lines, $sentences, $topics, $reverse_search, $plain, $split) = @_;
    my @matches = $reverse_search ? grep { $sentences->[$_] =~ /$query/i } 0 .. $#{$topics}
                                  : grep { $topics->[$_] =~ /^$query/i } 0 .. $#{$topics};

    for my $match (@matches) {
        my $sentence = $lines->[$match];
        my @formatted_sentence = format_sentence($sentence, $topics, $query, $plain);
        print join('', @formatted_sentence), $split;
    }
}

sub process_prompt {
    my ($reverse, $plain, $double, $user_string) = @_;
    my @args = split(/\s+/, $user_string);

    GetOptionsFromArray(\@args, 
        'reverse' => $reverse,
        'plain' => $plain,
        'double' => $double,
    ) or die "Error parsing options from user string";

    return @args;
    #print $$double;
}

sub main {
    my ($reverse_search, $plain, $double);
    #GetOptions("double" => \$double, "reverse" => \$reverse_search, "plain" => \$plain);
    

    my @args = process_prompt(\$reverse_search, \$plain, \$double, join(' ',@ARGV));

    my $split = $double ? "\n\n" : "\n";
    my $path_to_file = shift @args;
    my $query = shift @args;


    open my $handle, '<', $path_to_file;
    chomp(my @lines = <$handle>);
    close $handle;


    my @data = map { { topic => (split(/:/, $_, 2))[0], sentence => (split(/:/, $_, 2))[1] } } @lines;
    my @topics = map { $_->{topic} } @data;
    my @sentences = map { $_->{sentence} } @data;

    if ($query) { # one time
        
        print_query($query, \@lines, \@sentences, \@topics, $reverse_search, $plain, $split);
    } else {
        while (1) {
            print colored("Query: ",$colors{'query'});
            $query = <STDIN>;

            $reverse_search = 0;
            $plain = 0;
            $double = 0;
            
            my @args = process_prompt(\$reverse_search, \$plain, \$double, $query);
            my $split = $double ? "\n\n" : "\n";

            $query = shift @args;
            chomp($query);
            
            print_query($query, \@lines, \@sentences, \@topics, $reverse_search, $plain, $split);
        }
    }
}

main();
