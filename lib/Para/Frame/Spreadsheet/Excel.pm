package Para::Frame::Spreadsheet::Excel;
#=============================================================================
#
# AUTHOR
#   Jonas Liljegren   <jonas@paranormal.se>
#
# COPYRIGHT
#   Copyright (C) 2004-2009 Jonas Liljegren.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
#=============================================================================

=head1 NAME

Para::Frame::Spreadsheet::Excel - Access data in Excel format

=cut

use 5.010;
use strict;
use warnings;
use base 'Para::Frame::Spreadsheet';

use Spreadsheet::ParseExcel;

use Para::Frame::Utils qw( throw );
use Para::Frame::Reload;

##############################################################################

=head2 init

=cut

sub init
{
    my( $sh ) = @_;

    my $book = Spreadsheet::ParseExcel::Workbook->Parse($sh->{'fh'});
    $sh->{'book'} = $book or die "Failed to parce excel file\n";
    my $sheet = $book->{Worksheet}->[0];
    $sh->{'sheet'} = $sheet;

    $sh->{'row_number'} = $sheet->{MinRow};
    $sh->{'row_max'}    = $sheet->{MaxRow};
    $sh->{'col_min'}    = $sheet->{MinCol};
    $sh->{'col_max'}    = $sheet->{MaxCol};
}


##############################################################################

=head2 next_row

=cut

sub next_row
{
    my( $sh ) = @_;

    my $sheet = $sh->{'sheet'};
    my $col_max = $sh->{'col_max'};
    my $col_min = $sh->{'col_min'};
    my $row_number = $sh->{'row_number'} ++;


    if( $row_number > $sh->{'row_max'} )
    {
	return undef;
    }

    my @row;

    my $has_content = 0;
    for( my $i=$col_min; $i <= $col_max; $i++ )
    {
	my $cell = $sheet->Cell( $row_number, $i );
	if( $cell )
	{
	    my $val = $cell->Value;
	    $val =~ s/\0//g;
	    push @row, $val;
	    $has_content ++ if length($val);
	}
	else
	{
	    push @row, undef;
	}
    }

    # Find a line with content, ignoring empty lines
    return $sh->next_row unless $has_content;

    return \@row;
}


##############################################################################

=head2 row_number

=cut

sub row_number
{
    return shift->{'row_number'};

}

##############################################################################

1;

=head1 SEE ALSO

L<Para::Frame>

=cut
