# NAME

MooseX::amine - Examine Yr Moose

# VERSION

version 0.07

# SYNOPSIS

    my $mex  = MooseX::amine->new( 'MooseX::amine' );
    my $data = $mex->examine;

    my $attributes = $data->{attributes};
    my $methods    = $data->{methods};

# METHODS

## new

    # these two are the same
    my $mex = MooseX::amine->new( 'Module' );
    my $mex = MooseX::amine->new({ module => 'Module' });

    # or you can go from the path to the file
    my $mex = MooseX::amine->new({ path = 'path/to/Module.pm' });

    # there are a number of options that all pretty much do what they say.
    # they all default to off
    my $mex = MooseX::amine->new({
      module                           => 'Module' ,
      include_accessors_in_method_list => 1,
      include_moose_in_isa             => 1,
      include_private_attributes       => 1,
      include_private_methods          => 1,
      include_standard_methods         => 1,
    });

## examine

    my $mex  = MooseX::amine( 'Module' );
    my $data = $mex->examine();

Returns a multi-level hash-based data structure, with two top-level keys,
`attributes` and `methods`. `attributes` points to a hash where the keys
are attribute names and the values are data structures that describe the
attributes. Similarly, `methods` points to a hash where the keys are method
names and the values are data structures describing the method.

A sample attribute entry:

    simple_attribute => {
      accessor => 'simple_attribute',
      from     => 'Module',
      meta     => {
        constraint => 'Str'
      }
    }

The prescence of an `accessor` key indicates that this attribute was defined
with `is =` 'rw'>. A read-only attribute will have a `reader` key. A
`writer` key may also be present if a specific writer method was given when
creating the attribute.

Depending on the options given when creating the attribute there may be
various other options present under the `meta` key.

A sample method entry:

    simple_method => {
      code => 'sub simple_method   { return \'simple\' }',
      from => 'Module'
    }

The `code` key will contain the actual code from the method, extracted with
PPI. Depending on where the method code actually lives, this key may or may
not be present.

# CREDITS

- Semi-inspired by [MooseX::Documenter](https://metacpan.org/pod/MooseX%3A%3ADocumenter).
- Syntax highlighting Javascript/CSS stuff based on SHJS and largely stolen from search.cpan.org.

# AUTHOR

John SJ Anderson <john@genehack.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by John SJ Anderson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
