use ExtUtils::MakeMaker;

WriteMakefile(
    DISTNAME     => 'Math-Factor',
    NAME         => 'Math::Factor',
    VERSION_FROM => 'lib/Math/Factor.pm',
    PREREQ_PM    => { Exporter => 0 },
    'dist'       => { COMPRESS => 'gzip', SUFFIX => 'gz' },
    ($] >= 5.005 ?  
       (ABSTRACT_FROM  => 'lib/Math/Factor.pm',
        AUTHOR         => 'Steven Schubiger') : ()),
);
