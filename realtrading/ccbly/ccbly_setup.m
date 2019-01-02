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
ui_usehistoricaldata = true;
ui_assettypes = {'basemetal';'preciousmetal';'energy';'govtbond'};
ui_assetnames = {'deformed bar';'iron ore';'coke';'coking coal';...
    'sugar';'soymeal';'palm oil';'rapeseed meal'};
ui_wrmode = 'flash';

%% check the existing risk configurations
ccbly_genriskconfig;
ccbly_printriskconfig;

%% mod the risk configurations if nececcary
ui_codes = ccbly_futs2trade;
ui_propnames = {'overbought';'oversold';'wrmode';'samplefreq';'riskmanagername';...
    'stoptypepertrade';'stopamountpertrade';'limittypepertrade';'limitamountpertrade';...
    'baseunits';'maxunits'};
ui_propvalues = {-0.01;-99.99;ui_wrmode;'15m';'batman';...
    'rel';-0.01;'rel';0.01;...
    2;6};
ui_override = true;
fprintf('\n')
ccbly_modriskconfig;
fprintf('\nnew risk configurations....\n');
ccbly_printriskconfig;

%% create combos of strategy, mdefut and ops
if strcmpi(ui_stratname,'manual')
    ccbly_book2trade = ccbly_bookname_manual;ccbly_riskconfigfile2use = ccbly_riskconfigfilename_manual;
elseif strcmpi(ui_stratname,'batman')
    ccbly_book2trade = ccbly_bookname_batman;ccbly_riskconfigfile2use = ccbly_riskconfigfilename_batman;
elseif strcmpi(ui_stratname,'wlpr')
    if exist('ui_wrmode','var')
        ccbly_book2trade = [ccbly_bookname_wlpr,'-',ui_wrmode];
        if strcmpi(ui_wrmode,'classic')
            ccbly_riskconfigfile2use = ccbly_riskconfigfilename_wlprclassic;
        elseif strcmpi(ui_wrmode,'flash')
            ccbly_riskconfigfile2use = ccbly_riskconfigfilename_wlprflash;
        elseif strcmpi(ui_wrmode,'reverse')
            ccbly_riskconfigfile2use = ccbly_riskconfigfilename_wlprreverse;
        end
    else
        ccbly_book2trade = ccbly_bookname_wlpr;
        ccbly_riskconfigfile2use = ccbly_riskconfigfilename_wlpr;
    end
elseif strcmpi(ui_stratname,'wlprbatman')
    ccbly_book2trade = ccbly_bookname_wlprbatman;ccbly_riskconfigfile2use = ccbly_riskconfigfilename_wlprbatman;
else
    error('ERROR:ccb_setup:%s is not a valid stratey name!!!',ui_stratname);
end
%%
ccbly = rtt_setup('CounterName',ccbly_countername,...
    'BookName',ccbly_book2trade,...
    'StrategyName',ui_stratname,...
    'RiskConfigFileName',ccbly_riskconfigfile2use,...
    'InitialFundLevel',ui_stratfund,...
    'UseHistoricalData',ui_usehistoricaldata);

fprintf('\nccbly successfully created...\n');


%%
clear ccbly_book2trade

