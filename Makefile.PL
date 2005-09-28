use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Math::Factor',
    VERSION_FROM => 'lib/Math/Factor.pm', # finds $VERSION
    PREREQ_PM    => { Exporter => 0 },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005 
       (ABSTRACT_FROM => 'lib/Math/Factor.pm',
        AUTHOR        => 'Steven Schubiger <sts@accognoscere.org>') : ()),
);
