use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Term::Activity',
    'VERSION_FROM'	=> 'lib/Term/Activity.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/Term/Activity.pm',
       AUTHOR     => 'Phil Pollard <bennie@cpan.org>') : ()),
);
