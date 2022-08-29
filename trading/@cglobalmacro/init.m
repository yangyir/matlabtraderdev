function obj = init(obj,varargin)
%cglobalmacro
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('Name','globalmacro',@ischar);
p.addParameter('InitiateWind',true,@islogical);
p.parse(varargin{:});
obj.name_ = p.Results.Name;
initiatewind = p.Results.InitiateWind;
if initiatewind
    obj.conn_ = cWind;
else
    fprintf('cETFWatcher:init:wind not initiated!!!\n');
end

obj.codes_rates_ = {'10YRNOTE.GBM'};
obj.codes_fx_ = {'USDX.FX';'EURUSD.FX';'USDJPY.FX';'GBPUSD.FX';'AUDUSD.FX';'AUDJPY.FX';'EURCHF.FX';'USDCNH.FX'};
obj.codes_eqindex_ = {'SPX.GI';'IXIC.GI';'FTSE.GI';'N225.GI';'SX5E.DF';'000001.SH';'000300.SH';'399006.SZ';'000688.SH'};
obj.codes_comdty_ = {'SPTAUUSDOZ.IDC';'SPTAGUSDOZ.IDC';...
    'B.IPE';...
    'CA.LME';'AH.LME';'PB.LME';'ZS.LME';'NI.LME';'SN.LME';...
    'S.CBT';'C.CBT';'W.CBT';'P.DCE';'LH.DCE';...
    'I.DCE';'RB.SHF'};

n_rates = size(obj.codes_rates_,1);
n_fx = size(obj.codes_fx_,1);
n_eqindex = size(obj.codes_eqindex_,1);
n_comdty = size(obj.codes_comdty_,1);

obj.dailystatus_rates_ = nan(n_rates,1);
obj.dailystatus_fx_ = nan(n_fx,1);
obj.dailystatus_eqindex_ = nan(n_eqindex,1);
obj.dailystatus_comdty_ = nan(n_comdty);
%
obj.reload;
    

end