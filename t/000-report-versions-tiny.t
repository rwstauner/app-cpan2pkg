use strict;
use warnings;
use Test::More 0.88;
# This is a relatively nice way to avoid Test::NoWarnings breaking our
# expectations by adding extra tests, without using no_plan.  It also helps
# avoid any other test module that feels introducing random tests, or even
# test plans, is a nice idea.
our $success = 0;
END { $success && done_testing; }

my $v = "\n";

eval {                     # no excuses!
    # report our Perl details
    my $want = '5.012';
    my $pv = ($^V || $]);
    $v .= "perl: $pv (wanted $want) on $^O from $^X\n\n";
};
defined($@) and diag("$@");

# Now, our module version dependencies:
sub pmver {
    my ($module, $wanted) = @_;
    $wanted = " (want $wanted)";
    my $pmver;
    eval "require $module;";
    if ($@) {
        if ($@ =~ m/Can't locate .* in \@INC/) {
            $pmver = 'module not found.';
        } else {
            diag("${module}: $@");
            $pmver = 'died during require.';
        }
    } else {
        my $version;
        eval { $version = $module->VERSION; };
        if ($@) {
            diag("${module}: $@");
            $pmver = 'died during VERSION check.';
        } elsif (defined $version) {
            $pmver = "$version";
        } else {
            $pmver = '<undef>';
        }
    }

    # So, we should be good, right?
    return sprintf('%-45s => %-10s%-15s%s', $module, $pmver, $wanted, "\n");
}

eval { $v .= pmver('DateTime','any version') };
eval { $v .= pmver('Devel::Platform::Info::Linux','any version') };
eval { $v .= pmver('Exporter::Lite','any version') };
eval { $v .= pmver('File::Find','any version') };
eval { $v .= pmver('File::ShareDir::PathClass','any version') };
eval { $v .= pmver('File::Temp','any version') };
eval { $v .= pmver('Find::Lib','any version') };
eval { $v .= pmver('FindBin','any version') };
eval { $v .= pmver('HTML::TreeBuilder','any version') };
eval { $v .= pmver('HTTP::Request','any version') };
eval { $v .= pmver('List::MoreUtils','any version') };
eval { $v .= pmver('List::Util','any version') };
eval { $v .= pmver('Module::Build','0.3601') };
eval { $v .= pmver('Moose','any version') };
eval { $v .= pmver('Moose::Util::TypeConstraints','any version') };
eval { $v .= pmver('MooseX::ClassAttribute','any version') };
eval { $v .= pmver('MooseX::Has::Sugar','any version') };
eval { $v .= pmver('MooseX::POE','any version') };
eval { $v .= pmver('MooseX::SemiAffordanceAccessor','any version') };
eval { $v .= pmver('MooseX::Singleton','any version') };
eval { $v .= pmver('POE','any version') };
eval { $v .= pmver('POE::Component::Client::HTTP','any version') };
eval { $v .= pmver('POE::Kernel','any version') };
eval { $v .= pmver('POE::Loop::Tk','any version') };
eval { $v .= pmver('POE::Wheel::Run','any version') };
eval { $v .= pmver('Path::Class','any version') };
eval { $v .= pmver('Readonly','any version') };
eval { $v .= pmver('Test::Exception','any version') };
eval { $v .= pmver('Test::More','0.88') };
eval { $v .= pmver('Tk','any version') };
eval { $v .= pmver('Tk::Balloon','any version') };
eval { $v .= pmver('Tk::HList','any version') };
eval { $v .= pmver('Tk::NoteBook','any version') };
eval { $v .= pmver('Tk::PNG','any version') };
eval { $v .= pmver('Tk::ROText','any version') };
eval { $v .= pmver('Tk::Role::HasWidgets','any version') };
eval { $v .= pmver('Tk::Sugar','any version') };
eval { $v .= pmver('strict','any version') };
eval { $v .= pmver('warnings','any version') };



# All done.
$v .= <<'EOT';

Thanks for using my code.  I hope it works for you.
If not, please try and include this output in the bug report.
That will help me reproduce the issue and solve you problem.

EOT

diag($v);
ok(1, "we really didn't test anything, just reporting data");
$success = 1;

# Work around another nasty module on CPAN. :/
no warnings 'once';
$Template::Test::NO_FLUSH = 1;
exit 0;
