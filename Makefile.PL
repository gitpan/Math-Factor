use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Math::Factor',
    VERSION_FROM => 'lib/Math/Factor.pm',
    PREREQ_PM    => { Exporter => 0 },
    ($] >= 5.005 
      ? (ABSTRACT_FROM  => 'lib/Math/Factor.pm') : ()
    ),
);
