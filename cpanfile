requires 'Getopt::Long';
requires 'File::Slurp';
requires 'Moose';
requires 'PPI';

on test => sub {
    requires 'Test2::V0';
};
