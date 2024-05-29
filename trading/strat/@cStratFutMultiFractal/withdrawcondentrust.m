function [] = withdrawcondentrust(stratfractal, instrument, varargin)
% member methond of cStratFutMultiFractal
%withdraw any EXISTING conditional entrust associated with input instrument
ncondpending = stratfractal.helper_.condentrustspending_.latest;
if ncondpending <= 0, return; end

ip = inputParser;
ip.CaseSensitive = false;ip.KeepUnmatched = true;
ip.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
ip.addParameter('SignalMode','',@ischar);
ip.parse(instrument,varargin{:});

instrument = ip.Results.Instrument;
signalmode = ip.Results.SignalMode;
if isempty(signalmode)
    usesignalmode = false;
else
    usesignalmode = true;
end

if ~isempty(signalmode)
    if ~(strcmpi(signalmode,'conditional-uptrendconfirmed') || ...
            strcmpi(signalmode,'conditional-uptrendbreak') || ...
            strcmpi(signalmode,'conditional-dntrendconfirmed') || ...
            strcmpi(signalmode,'conditional-dntrendbreak') || ...
            strcmpi(signalmode,'conditional-close2lvlup') || ...
            strcmpi(signalmode,'conditional-close2lvldn') || ...
            strcmpi(signalmode,'conditional-breachuplvlup') || ...
            strcmpi(signalmode,'conditional-breachdnlvldn'))
        error('cStratFutMultiFractal:withdrawcondentrust:invalid signal mode input...')
    end
end


%目前条件单有以下6种：
%   多头：
%       a.uptrendconfirmed
%       b.close2lvlup
%       c.breachuplvlup
%
%   空头：
%       a.dntrendconfirmed
%       b.close2lvldn
%       c.breachdnlvldn

condentrusts2remove = EntrustArray;

for jj = 1:ncondpending
    condentrust = stratfractal.helper_.condentrustspending_.node(jj);
    if ~strcmpi(instrument.code_ctp,condentrust.instrumentCode), continue;end
    %目前只处理开仓单，暂时没有平仓单
    if condentrust.offsetFlag ~= 1, continue; end
    
    signalinfo = condentrust.signalinfo_;
    if isempty(signalinfo), continue; end
    %信号本身必须是Fractal
    if ~strcmpi(signalinfo.name,'fractal'), continue;end
    
    if usesignalmode
        if ~strcmpi(signalinfo.mode,signalmode),continue;end
    end
    
    condentrusts2remove.push(condentrust);
    
    %
end
%
if condentrusts2remove.latest > 0
    stratfractal.removecondentrusts(condentrusts2remove);
end

end