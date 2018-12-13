% ccbly_setup
%
%note:default configuration files
%mannual:ccbly_riskconfigs_manual.txt
%batman:ccbly_riskconfigs_batman.txt
%wlpr:ccbly_riskconfigs_wlpr.txt
%wlprbatman:ccbly_riskconfigs_wlprbatman.txt

%% user inputs
ui_stratname = 'wlpr';
ui_stratfund = 1e6;
ui_usehistoricaldata = false;
ui_assettypes = {'basemetal';'preciousmetal';'govtbond';'energy'};
ui_assetnames = {'deformed bar';'iron ore';...
    'sugar';'soymeal';'palm oil';'corn';'rapeseed meal';'apple'};

%% check the existing risk configurations
ccbly_printriskconfig;

%% mod the risk configurations if nececcary
ui_codes = ccbly_futs2trade;
ui_propnames = {'overbought';'oversold';'wrmode';'samplefreq';'riskmanagername';...
    'stoptypepertrade';'stopamountpertrade';'limittypepertrade';'limitamountpertrade';...
    'baseunits';'maxunits'};
ui_propvalues = {-0.25;-99.75;'classic';'5m';'batman';...
    'rel';-0.008;'rel';0.005;...
    2;6};
ui_override = true;
fprintf('\n')
ccbly_modriskconfig;
fprintf('\nnew risk configurations....\n');
ccbly_printriskconfig;

%% create combos of strategy, mdefut and ops
if strcmpi(ui_stratname,'manual')
    ccbly_book2trade = ccbly_bookname_manual;
    ccbly_riskconfigfile2use = ccbly_riskconfigfilename_manual;
elseif strcmpi(ui_stratname,'batman')
    ccbly_book2trade = ccbly_bookname_batman;
    ccbly_riskconfigfile2use = ccbly_riskconfigfilename_batman;
elseif strcmpi(ui_stratname,'wlpr')
    ccbly_book2trade = ccbly_bookname_wlpr;
    ccbly_riskconfigfile2use = ccbly_riskconfigfilename_wlpr;
elseif strcmpi(ui_stratname,'wlprbatman')
    ccbly_book2trade = ccbly_bookname_wlprbatman;
    ccbly_riskconfigfile2use = ccbly_riskconfigfilename_wlprbatman;
else
    if isempty(ui_stratname)
        error('ERROR:ccb_setup:blank stratey name input!!!');
    else
        error('ERROR:ccb_setup:%s is not a valid stratey name!!!',ui_stratname);
    end
end

ccbly = rtt_setup('CounterName',ccbly_countername,...
    'BookName',ccbly_book2trade,...
    'StrategyName',ui_stratname,...
    'RiskConfigFileName',ccbly_riskconfigfile2use,...
    'InitialFundLevel',ui_stratfund,...
    'UseHistoricalData',ui_usehistoricaldata);

fprintf('\nccbly successfully created...\n');


%%
clear ccbly_book2trade

