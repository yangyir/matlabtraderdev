%to generate risk configuration
%
fprintf('running ''citickim_genriskconfig''...\n');
%
if ~exist('citickim_countername','var')
    citickim_init;
end

citickim_chooseinstruments;


citickim_riskconfigfilename_manual = 'citickim_riskconfigs_mannual.txt';
citickim_riskconfigfilename_batman = 'citickim_riskconfigs_batman.txt';
citickim_riskconfigfilename_wlpr = 'citickim_riskconfigs_wlpr.txt';
citickim_riskconfigfilename_wlprbatman = 'citickim_riskconfigs_wlprbatman.txt';

%
genconfigfile(citickim_stratname_manual,[citickim_path_manual,citickim_riskconfigfilename_manual],...
    'instruments',citickim_futs2trade);
%
genconfigfile(citickim_stratname_batman,[citickim_path_batman,citickim_riskconfigfilename_batman],...
    'instruments',citickim_futs2trade);
%
genconfigfile(citickim_stratname_wlpr,[citickim_path_wlpr,citickim_riskconfigfilename_wlpr],...
    'instruments',citickim_futs2trade);
%
genconfigfile(citickim_stratname_wlprbatman,[citickim_path_wlprbatman,citickim_riskconfigfilename_wlprbatman],...
    'instruments',citickim_futs2trade);




