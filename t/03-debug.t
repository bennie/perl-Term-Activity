use Test;
BEGIN { plan tests => 3 };

use Term::Activity;
ok(1);

my $t = new Term::Activity ({ debug => 1 });
ok(1);

ok(1) if $Term::Activity::debug == 1;
