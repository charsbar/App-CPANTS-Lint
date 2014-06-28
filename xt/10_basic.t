use strict;
use warnings;
use FindBin;
use File::Path;
use Test::More;
use App::CPANTS::Lint;

eval {
  require WorePAN;
  WorePAN->import("0.09");
  1;
} or plan skip_all => "requires WorePAN 0.09 to test";

my @dists = (
  # should pass as of Module::CPANTS::Analyse 0.92
  'NEILB/Exporter-Lite-0.05.tar.gz',

  # should fail
  'ISHIGAKI/Acme-CPANAuthors-0.23.tar.gz',
);

plan tests => scalar @dists * 2;

my $app = App::CPANTS::Lint->new;

my $testdir = "$FindBin::Bin/worepan";
mkpath $testdir unless -d $testdir;

for my $dist (@dists) {
  my $worepan = WorePAN->new(
    root => $testdir,
    files => [$dist],
    use_backpan => 1,
    no_network => 0,
    cleanup => 1,
    no_indices => 1,
    verbose => 0,
  );
  my $file = $worepan->file($dist);
  ok -f $file;

  my $got = $app->lint($file);
  if ($got) {
    note "Lint ok: $dist";
    like $app->report => qr/Congratulations/;
  } else {
    note "Lint fail: $dist";
    like $app->report => qr/Failed (?:core|extra) Kwalitee metrics/;
  }
}

rmtree $testdir if -d $testdir;
