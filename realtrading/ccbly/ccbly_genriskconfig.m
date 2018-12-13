%to generate risk configuration
%
fprintf('running ''ccbly_genriskconfig''...\n');
%
if ~exist('ccbly_countername','var')
    ccbly_init;
end

ccbly_chooseinstruments;


ccbly_riskconfigfilename_manual = 'ccbly_riskconfigs_mannual.txt';
ccbly_riskconfigfilename_batman = 'ccbly_riskconfigs_batman.txt';
ccbly_riskconfigfilename_wlpr = 'ccbly_riskconfigs_wlpr.txt';
ccbly_riskconfigfilename_wlprbatman = 'ccbly_riskconfigs_wlprbatman.txt';

%
genconfigfile(ccbly_stratname_manual,[ccbly_path_manual,ccbly_riskconfigfilename_manual],...
    'instruments',ccbly_futs2trade);
%
genconfigfile(ccbly_stratname_batman,[ccbly_path_batman,ccbly_riskconfigfilename_batman],...
    'instruments',ccbly_futs2trade);
%
genconfigfile(ccbly_stratname_wlpr,[ccbly_path_wlpr,ccbly_riskconfigfilename_wlpr],...
    'instruments',ccbly_futs2trade);
%
genconfigfile(ccbly_stratname_wlprbatman,[ccbly_path_wlprbatman,ccbly_riskconfigfilename_wlprbatman],...
    'instruments',ccbly_futs2trade);




