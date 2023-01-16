# esse arquivo configura o latexmk para usar todas as funcionalidades
# que a classe da FEI disponibiliza
# ele foi criado utilizando os exemplos disponíveis em:
# https://www.ctan.org/tex-archive/support/latexmk/example_rcfiles

$pdflatex = 'pdflatex --shell-escape %O %S';
push @generated_exts, 'slg', 'slo', 'sls';
push @generated_exts, 'bbl', 'loa', 'ins', 'loe', 'mw', 'run.xml', 'xdy';

# não usamos o makeindex, mas sim o texindy
add_cus_dep('idx', 'ind', 0, 'texindy');
$makeindex = 'texindy %O -o %D %S';
sub texindy{
    system("texindy \"$_[0].idx\"");
}

# configuração do makeglossaries para os pacotes glossaries e glossaries-extra
push @generated_exts, 'glo', 'gls', 'glg';
push @generated_exts, 'acn', 'acr', 'alg';
add_cus_dep('glo', 'gls', 0, 'makeglossaries');
add_cus_dep('acn', 'acr', 0, 'makeglossaries');
$clean_ext .= " acr acn alg glo gls glg";
sub makeglossaries {
  my ($base_name, $path) = fileparse( $_[0] );
  pushd $path;
  my $return = system "makeglossaries", $base_name;
  popd;
  return $return;
}

# configuração para o bib2gls
push @generated_exts, 'glstex', 'glg';
add_cus_dep('aux', 'glstex', 0, 'run_bib2gls');
sub run_bib2gls {
    if ( $silent ) {
        my $ret = system "bib2gls --silent --group '$_[0]'";
    } else {
        my $ret = system "bib2gls --group '$_[0]'";
    };
    
    my ($base, $path) = fileparse( $_[0] );
    if ($path && -e "$base.glstex") {
        rename "$base.glstex", "$path$base.glstex";
    }

    # Analyze log file.
    local *LOG;
    $LOG = "$_[0].glg";
    if (!$ret && -e $LOG) {
        open LOG, "<$LOG";
	while (<LOG>) {
            if (/^Reading (.*\.bib)\s$/) {
		rdb_ensure_file( $rule, $1 );
	    }
	}
	close LOG;
    }
    return $ret;
}

# https://ctan.org/pkg/urw-arial
# Reference: https://www.overleaf.com/learn/latex/Questions/I_have_a_custom_font_I'd_like_to_load_to_my_document._How_can_I_do_this%3F
$ENV{'TEXINPUTS'}='texmf//:' . $ENV{'TEXINPUTS'};
$ENV{'T1FONTS'}='texmf/fonts/type1//:' . $ENV{'T1FONTS'};
$ENV{'AFMFONTS'}='texmf/fonts/afm//:' . $ENV{'AFMFONTS'};
$ENV{'TEXFONTMAPS'}='texmf/fonts/map//:' . $ENV{'TEXFONTMAPS'};
$ENV{'TFMFONTS'}='texmf/fonts/tfm//:' . $ENV{'TFMFONTS'};
$ENV{'VFFONTS'}='texmf/fonts/vf//:' . $ENV{'VFFONTS'};
$ENV{'ENCFONTS'}='texmf/fonts/enc//:' . $ENV{'ENCFONTS'};