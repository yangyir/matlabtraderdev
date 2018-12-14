% citickim_setup
%
%note:default configuration files
%mannual:citickim_riskconfigs_manual.txt
%batman:citickim_riskconfigs_batman.txt
%wlpr:citickim_riskconfigs_wlpr.txt
%wlprbatman:citickim_riskconfigs_wlprbatman.txt

%% user inputs
ui_stratname = 'wlpr';
ui_stratfund = 1e6;
ui_usehistoricaldata = true;
ui_assettypes = {''};
ui_assetnames = {'govtbond_10y';'crude oil';'gold'};

%% check the existing risk configurations
citickim_genriskconfig;
citickim_printriskconfig;

%% mod the risk configurations if nececcary
ui_codes = citickim_futs2trade;
ui_propnames = {'overbought';'oversold';'wrmode';'samplefreq';'riskmanagername';...
    'stoptypepertrade';'stopamountpertrade';'limittypepertrade';'limitamountpertrade';...
    'baseunits';'maxunits'};
ui_propvalues = {-0.25;-99.75;'classic';'5m';'batman';...
    'rel';-0.008;'rel';0.005;...
    2;6};
ui_override = true;
fprintf('\n')
citickim_modriskconfig;
fprintf('\nnew risk configurations....\n');
citickim_printriskconfig;

%% create combos of strategy, mdefut and ops
if strcmpi(ui_stratname,'manual')
    citickim_book2trade = citickim_bookname_manual;citickim_riskconfigfile2use = citickim_riskconfigfilename_manual;
elseif strcmpi(ui_stratname,'batman')
    citickim_book2trade = citickim_bookname_batman;citickim_riskconfigfile2use = citickim_riskconfigfilename_batman;
elseif strcmpi(ui_stratname,'wlpr')
    citickim_book2trade = citickim_bookname_wlpr;citickim_riskconfigfile2use = citickim_riskconfigfilename_wlpr;
elseif strcmpi(ui_stratname,'wlprbatman')
    citickim_book2trade = citickim_bookname_wlprbatman;citickim_riskconfigfile2use = citickim_riskconfigfilename_wlprbatman;
else
    error('ERROR:ccb_setup:%s is not a valid stratey name!!!',ui_stratname);
end

citickim = rtt_setup('CounterName',citickim_countername,...
    'BookName',citickim_book2trade,...
    'StrategyName',ui_stratname,...
    'RiskConfigFileName',citickim_riskconfigfile2use,...
    'InitialFundLevel',ui_stratfund,...
    'UseHistoricalData',ui_usehistoricaldata);

fprintf('\nccbly successfully created...\n');


%%
clear citickim_book2trade

