use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Term::Activity',
    'VERSION_FROM'	=> 'lib/Term/Activity.pm',
    'PREREQ_PM'		=> { 'Term::Size' => '0' },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/Term/Activity.pm',
       AUTHOR     => 'Phil Pollard <bennie@cpan.org>') : ()),
);
