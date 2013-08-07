use 5.018000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Whapps::CatalogAPI',
    VERSION_FROM      => 'lib/Whapps/CatalogAPI.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Whapps/CatalogAPI.pm', # retrieve abstract from module
       AUTHOR         => 'Ken Prows <kprows@whapps.com>') : ()),
);