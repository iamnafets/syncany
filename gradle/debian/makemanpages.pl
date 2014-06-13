#!/usr/bin/perl

use Date::Parse;
use Time::Local;
use POSIX qw(strftime);

# Fix locale (for dates)
use locale;
use POSIX qw(locale_h);
setlocale(LC_CTYPE, "en_US.UTF-8");
setlocale(LC_TIME, "en_US.UTF-8");

my $sourceDir = "../../syncany-cli/src/main/resources/org/syncany/cli/cmd";
my $targetBuildDir = "../../build/debian/syncany/debian";
my $targetManDir = "$targetBuildDir/man";

my @manpages = glob("$sourceDir/*.skel");
my $targetManFile = "$targetBuildDir/syncany.manpages";

system("mkdir -p $targetManDir");

open(MAN, '>', $targetManFile);

foreach (@manpages) {
	my $skelfile = $_;
	my $command = ($skelfile =~ /help\.([-a-z]+)\.skel/) ? $1 : "syncany";
	my $thcommand = $command eq "syncany" ? "syncany" : "syncany-$command"; 

	print MAN "debian/man/$thcommand.1\n";

	open(IN, "$skelfile");
	open(OUT, '>', "$targetManDir/$thcommand.1");

	print OUT ".TH $thcommand 1\n";

	my $indent = 0;
	my $nf = 0;
	my $indentSection = 0;
	my @indents = (0);

	while (my $line = <IN>) {
		chomp $line;
	
		# Trim right
		$line =~ s/\s+$//g; 
		
		# Escape line 
		$line =~ s/\\/\\\\/g;
	
		# Header
		if ($line =~ /^([A-Z\s]+)$/) {	
			if ($indent > 0) {
				print OUT ".RE\n";
				$indent = 0;
			}
			
			if ($1 =~ /SYNOPSIS|DESCRIPTION/i) {
				$indentSection = 0;
			}
			else {
				$indentSection = 1;
			}
		
			print OUT ".SH $line\n";
		}
	
		# Empty line
		elsif ($line =~ /^\s*$/) {
			print OUT ".PP\n";
		}

		# Indent section		
		else {	
			# Trim left two spaces
			$line =~ s/^\s\s//g; 
						
			# Highlight options --some-option=<option1|option2> or -o
			$line =~ s/(^|\W+?)(--?[-\w]+=?)/$1\\fB$2\\fR/g;
		
			# Highlight commands `ls -al`
			$line =~ s/(`[^`]+`)/\\fB$1\\fR/g;
			
			# Highlight args <args>
			$line =~ s/(<[-\w\|]+>)/\\fB$1\\fR/g;

			# Replace - with \-
			$line =~ s/-/\\-/;

			if ($indentSection) {
				# Calculate indent (after two left spaces)
				my $lineindent = 0;
	
				if ($line =~ /^(\s+)/) {
					$lineindent = length $1;
				}
		
				# Don't break list items and option lines
				if (!$nf && $line =~ /^\s*[-\*]/) {
					print OUT ".nf\n";
					$nf = 1;
				}
				elsif ($nf && $line =~ /^\s*[^-\*]/) {
					print OUT ".fi\n";
					$nf = 0;
				}
		
				# Remove indent 
				$line =~ s/^\s*//g; 

				# End indent sections				
				while ($lineindent < $indent && $#indents > 0) {
					$indent = pop(@indents);
					print OUT ".RE\n";				
				}
				
				if ($lineindent > $indent) { 
					print OUT ".RS\n";
					print OUT "$line\n";
					
					push(@indents, $indent);
					$indent = $lineindent;
				}
				else {												
					print OUT "$line\n";
					$indent = $lineindent;
				}
			}
			else {
				print OUT "$line\n";
			}
		}
	}

	close(IN);
	close(OUT);
}

close(MAN);

