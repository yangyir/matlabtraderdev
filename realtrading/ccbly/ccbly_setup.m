% ccbly_setup
%
%note:default configuration files
%mannual:ccbly_riskconfigs_manual.txt
%batman:ccbly_riskconfigs_batman.txt
%wlpr:ccbly_riskconfigs_wlpr.txt
%wlprbatman:ccbly_riskconfigs_wlprbatman.txt

%% user inputs
ui_stratname = 'manual';
ui_stratfund = 1e6;
ui_usehistoricaldata = truel;

%% check the existing risk configurations
fprintf('existing risk configurations...\n');
ccbly_printriskconfig;

%% mod the risk configurations if nececcary
ui_codes = {'T1903'};
ui_propnames = {'bidopenspread';'askopenspread';'use'};
ui_propvalues = {5;5;1};
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
    'RiskConfigFileName',ccbly_riskconfigfile2use);
%
ccbly.strategy.setavailablefund(ui_stratfund,'firstset',true,...
    'checkavailablefund',false);
ccbly.strategy.usehistoricaldata_ = true;
ccbly.strategy.initdata;

fprintf('\nccbly successfully created...\n');

%% ctp login 

ccbly.mdefut.login('Connection','ctp','countername',countername);

clear ccbly_book2trade

