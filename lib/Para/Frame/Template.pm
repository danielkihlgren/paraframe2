package Para::Frame::Template;
#=============================================================================
#
# AUTHOR
#   Jonas Liljegren   <jonas@paranormal.se>
#
# COPYRIGHT
#   Copyright (C) 2004-2015 Jonas Liljegren.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
#=============================================================================

=head1 NAME

Para::Frame::Template - Represents a Template file

=cut

use 5.010;
use strict;
use warnings;
use base qw( Para::Frame::File );

use Carp qw( croak confess cluck );
use List::Uniq qw( uniq ); # keeps first of each value

use Para::Frame::Reload;
use Para::Frame::Utils qw( throw debug create_dir chmod_file idn_encode idn_decode datadump catch );
use Para::Frame::Dir;
use Para::Frame::File;
use Para::Frame::Burner;
use Para::Frame::Template::Compiled;
#use Para::Frame::Time qw( now );
use Para::Frame::L10N qw( loc );

##############################################################################

=head1 Constructors

=cut

##############################################################################

=head2 new

See L<Para::Frame::File>

This constructor is usually called by L</response_page>.

=cut

##############################################################################

=head2 initialize

=cut

sub initialize
{
    my( $tmpl, $args ) = @_;

#    confess("CHECKME: ".datadump($args,2));
#    if( my $burner = $args->{'burner'} )
#    {
#	$tmpl->{'burner'} = $burner;
#    }

    return 1;
}


##############################################################################

=head2 is_template

=cut

sub is_template
{
    return 1;
}

##############################################################################

=head2 title

  $p->title()

Returns the L</template> C<otitle> or L<title> or undef.

=cut

sub title
{
    my( $tmpl ) = @_;

    my $doc = $tmpl->document;

    return $doc->otitle || $doc->title || undef;
}

##############################################################################

=head2 document

=cut

sub document
{
    my( $tmpl ) = @_;

    #Cache within a req

    unless( $Para::Frame::REQ->{'document'}{$tmpl} )
    {
#	debug "Getting doc for ".$tmpl->sysdesig;

	my $req = $Para::Frame::REQ;

	my $mod_time = $tmpl->mtime_as_epoch;

	my $burner = Para::Frame::Burner->get_by_ext( $tmpl->suffix )
	    or confess "No burner found for ".$tmpl->sysdesig;
	my $compdir = $burner->compile_dir;
	my $tmplname = $tmpl->sys_path;

	my $compfile = Para::Frame::Template::Compiled->new_possible_sysfile($compdir.$tmplname);



#	debug "Compdir: $compdir";

	my( $doc, $ltime);

	# 1. Look in memory cache
	#
	if( my $rec = $Para::Frame::Cache::td{$tmplname} )
	{
#	    debug("Found in MEMORY");
	    ( $doc, $ltime) = @$rec;
	    if( $ltime <= $mod_time )
	    {
		if( debug > 3 )
		{
		    debug(0,"     To old!");
		    debug(0,"     ltime: $ltime");
		    debug(0,"  mod_time: $mod_time");
		}
		undef $doc;
	    }
	}

	# 2. Look for compiled file
	#
	unless( $doc )
	{
	    if( $compfile->is_plain_file )
	    {
#		debug("Found in COMPILED file");

		my $ltime = $compfile->mtime_as_epoch;
		if( $ltime <= $mod_time )
		{
		    if( debug > 3 )
		    {
			debug(0,"     To old!");
			debug(0,"     ltime: $ltime");
			debug(0,"  mod_time: $mod_time");
		    }
		}
		else
		{
		    $doc = $compfile->load_compiled();

#		    debug("Loading ".$compfile->sys_path);

		    # Save to memory cache (loadtime)
		    $Para::Frame::Cache::td{$tmplname} =
			[$doc, $ltime];
		}
	    }
	}

	# 3. Compile the template
	#
	unless( $doc )
	{
#	    debug("Reading file");
	    $mod_time = time; # The new time of reading file
	    my $tmpltext = $tmpl->contentref_as_text;
	    my $parser = $burner->parser;
	    unless( $parser )
	    {
		debug "No parser: ".datadump($burner);
		confess( Template::Config->error );
	    }

#	    debug("Parsing with ($parser): ".$burner->type);
	    $req->note(loc("Compiling [_1]",($tmpl->site ? $tmpl->url_path_slash : $tmpl->sys_path_slash)));
	    my $metadata =
	    {
	     name => $tmplname,
	     time => $mod_time,
	    };
	    my $parsedoc = $parser->parse( $$tmpltext, $metadata )
		or throw('template', "parse error:\nFile: $tmplname\n".
			 $parser->error);

#	    debug("Writing compiled file ".datadump($parsedoc));
#	    to_utf8_recursive( $parsedoc );

	    $compfile->dir->create;

	    Template::Document->write_perl_file($compfile->sys_path, $parsedoc);
	    $compfile->chmod;
	    $compfile->utime($mod_time);

	    $doc = Template::Document->new($parsedoc)
		or throw('template', $Template::Document::ERROR);

	    # Save to memory cache
	    $Para::Frame::Cache::td{$tmplname} =
		[$doc, $mod_time];
	}

	return $Para::Frame::REQ->{'document'}{$tmpl} = $doc;
    }

    return $Para::Frame::REQ->{'document'}{$tmpl};
}

##############################################################################

=head2 to_utf8_recursive

=cut

sub to_utf8_recursive
{
    if( ref $_[0] )
    {
	if( ref $_[0] eq 'ARRAY' )
	{
	    foreach(@{$_[0]})
	    {
		to_utf8_recursive($_);
	    }
	}
	elsif( ref $_[0] eq 'HASH' )
	{
	    foreach(keys %{$_[0]})
	    {
		to_utf8_recursive($_[0]{$_});
	    }
	}
	else
	{
	    die "Conversion of $_[0] not implemented";
	}
    }
    else
    {
	utf8::upgrade($_[0]);
    }
}


##############################################################################

=head2 desig

=cut

sub desig
{
    my( $tmpl ) = @_;

    if( $tmpl->exist )
    {
	return $tmpl->title || $tmpl->SUPER::desig();
    }
    else
    {
	return $tmpl->SUPER::desig();
    }
}


##############################################################################

=head2 sysdesig

=cut

sub sysdesig
{
    my( $tmpl ) = @_;

    return $tmpl->SUPER::sysdesig();
}


##############################################################################

=head2 find

  $resp->find($page)

Returns:

A L<Para::Frame::Template> object or undef

=cut

sub find
{
    my( $this, $page ) = @_;
    my $class = ref($this) || $this;

#    Para::Frame::Logging->this_level(4);
   debug 3, "Finding template for page ".$page->sysdesig;

    my $req = $Para::Frame::REQ;

    # Handle index.tt (for KNOWN dirs)
    if( $page->is_dir )
    {
	if( $page->exist )
	{
	    $page = $page->get_virtual('index.tt');
	}
	else
	{
	    return( undef );
	}
    }

    my $site = $page->site
      or confess sprintf "Page %s not part of a site", $page->sysdesig;

    my $suffix = $page->suffix;
    unless( $suffix )
    {
	return undef;
    }

    # Check that this file is handled by TT
    unless( Para::Frame::Burner->get_by_ext( $suffix ) )
    {
	return undef;
    }


    # Reasonable default?
    my $lang = $req->language;
    my( @languages ) = $lang->alternatives;
    if( my $langcode = $page->langcode )
    {
	if( $site->supports_language( $langcode ) )
	{
	    @languages = uniq( $langcode, @languages );
	}
    }

    my $dir_sps = $page->dir->sys_path_slash;
    my @searchpath = $dir_sps;

    if( $page->is_compiled )
    {
	push @searchpath, map $_."def/", @{$page->dirsteps};
    }
    else
    {
	my $destroot = $site->home->sys_path;

	my $dir = $dir_sps;
	$dir =~ s/^$destroot// or
	  die "destroot $destroot not part of $dir";

	my $paraframedir = $Para::Frame::CFG->{'paraframe'};

	foreach my $appback (@{$site->appback})
	{
	    push @searchpath, $appback . '/html' . $dir;
	}

	push @searchpath, $paraframedir . '/html' . $dir;

	foreach my $path ( Para::Frame::Utils::dirsteps($dir), '/' )
	{
	    push @searchpath, $destroot . $path . "def/";
	    foreach my $appback (@{$site->appback})
	    {
		push @searchpath, $appback . '/html' . $path . "def/";
	    }
	    push @searchpath,  $paraframedir . '/html' . $path . "def/";
	}
    }

    my $base_name = $page->base_name;
    my $ext_full = '.' . $suffix;

    foreach my $path ( @searchpath )
    {
	unless( $path )
	{
	    cluck "path undef (@searchpath)";
	    next;
	}

	# We look for both tt and html regardless of it the file was called as .html
	debug(3,"  Check $path");
	die "dir_redirect failed" unless $base_name;

	# Handle dirs
	if( -d $path.$base_name.$ext_full )
	{
	    confess "Found a directory: $path$base_name$ext_full\nShould redirect";
	}


	# Find language specific template
	foreach my $langcode ( map(".$_",@languages),'' )
	{
	    debug(3, "    Check $langcode");
	    my $tmplname = $path.$base_name.$langcode.$ext_full;
	    debug(3, "      Looking at $tmplname");
	    my $tmpl = $class->new_possible_sysfile($tmplname);

	    if( $tmpl->exist )
	    {
		debug(3, "      Using $tmplname");
		return $tmpl;
	    }
	}
    }

    # Check if site should be compiled but hasn't been yet
    #
    if( $site->is_compiled )
    {
	my $langcode = $languages[0];
	my $path = "/def/page_not_found.$langcode.tt";
	my $sample_tmpl = $site->get_possible_page($path);
	unless( $sample_tmpl->exist )
	{
	    $site->set_is_compiled(0);
	    debug "*** The site is not yet compiled";
#	    die datadump($sample_tmpl); ####### DEBUG
	    return $class->find($page);
	}
    }

    # If we can't find the filname
    debug(2, "Not found: ".$page->sys_path);
    return( undef );
}


##############################################################################

=head2 as_template

=cut

sub as_template
{
    return $_[0];
}

##############################################################################

1;

=head1 SEE ALSO

L<Para::Frame>

=cut
