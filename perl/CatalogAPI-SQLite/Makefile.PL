use 5.018004;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'CatalogAPI::SQLite',
    VERSION_FROM      => 'lib/CatalogAPI/SQLite.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/CatalogAPI/SQLite.pm', # retrieve abstract from module
       AUTHOR         => 'Marc Slagle <marc.slagle@nonet>') : ()),
);
