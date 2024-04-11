function [] = processcondentrust( stratfractal, instrument, varargin )
% member methond of cStratFutMultiFractal
%process any EXISTING conditional entrust associated with input instrument
ncondpending = stratfractal.helper_.condentrustspending_.latest;
if ncondpending <= 0, return; end

ip = inputParser;
ip.CaseSensitive = false;ip.KeepUnmatched = true;
ip.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
ip.addParameter('techvar',0,@isnumeric);
ip.parse(instrument,varargin{:});

instrument = ip.Results.Instrument;
techvar = ip.Results.techvar;
p = techvar(:,1:5);
idxHH = techvar(:,6);
idxLL = techvar(:,7);
hh = techvar(:,8);
ll = techvar(:,9);
jaw = techvar(:,10);
teeth = techvar(:,11);
lips = techvar(:,12);
bs = techvar(:,13);
ss = techvar(:,14);
lvlup = techvar(:,15);
lvldn = techvar(:,16);
% bc = techvar(:,17);
% sc = techvar(:,18);
wad = techvar(:,19);

try
    ticksize = instrument.tick_size;
catch
    ticksize = 0;
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

nfractal = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','nfractals');

for jj = 1:ncondpending
    condentrust = stratfractal.helper_.condentrustspending_.node(jj);
    if ~strcmpi(instrument.code_ctp,condentrust.instrumentCode), continue;end
    %目前只处理开仓单，暂时没有平仓单
    if condentrust.offsetFlag ~= 1, continue; end
    
    signalinfo = condentrust.signalinfo_;
    if isempty(signalinfo), continue; end
    %信号本身必须是Fractal
    if ~strcmpi(signalinfo.name,'fractal'), continue;end
    
    if strcmpi(signalinfo.mode,'conditional-uptrendconfirmed') || strcmpi(signalinfo.mode,'conditional-uptrendbreak')
        %cancel 1)either the price falls below the alligator's teeth
        %2)the latest HH is (1-tick) below the previous HH
        %3)the lastest HH is updated
        ispxbelowteeth = p(end,5) < teeth(end);
        last2hh = hh(find(idxHH == 1,2,'last'));
        if size(last2hh,1) == 2
            islatesthhlower = last2hh(2)<last2hh(1)-ticksize;
            ishhupdated = condentrust.price < last2hh(2);
        else
            islatesthhlower = false;
            ishhupdated = false;
        end
        if ispxbelowteeth || islatesthhlower || ishhupdated
            condentrusts2remove.push(condentrust);
            if ispxbelowteeth
                fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as price falls below alligator teeth...');
            elseif islatesthhlower
                fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as new hh is lower...');
            elseif ishhupdated
                fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as new hh is higher...');
            end
        end
        %
    elseif strcmpi(signalinfo.mode,'conditional-dntrendconfirmed') || strcmpi(signalinfo.mode,'conditional-dntrendbreak')
        %cancel 1)either the price rallies above the alligator's teeth
        %2)the latest LL is (1-tick) above the previous LL
        %3)the latest LL is updated
        ispxaboveteeth = p(end,5) > teeth(end);
        last2ll = ll(find(idxLL == -1,2,'last'));
        if size(last2ll,1) == 2
            islatestllhigher = last2ll(2)>last2ll(1)+ticksize;
            isllupdated = condentrust.price > last2ll(2);
        else
            islatestllhigher = false;
            isllupdated = false;
        end
        if ispxaboveteeth || islatestllhigher || isllupdated
            condentrusts2remove.push(condentrust);
            if ispxaboveteeth
                fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as price rallies above alligator teeth...');
            elseif islatestllhigher
                fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as new ll is higher...');
            elseif isllupdated
                fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as new ll is lower...');
            end
        end
        %    
    elseif strcmpi(signalinfo.mode,'conditional-close2lvlup')
        %cancel once cp as of the latest candle stick falls below HH
        if p(end,5) < hh(end)
            condentrusts2remove.push(condentrust);
            fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as close price falls below hh...');
        end
        %
    elseif strcmpi(signalinfo.mode,'conditional-close2lvldn')
        %cancel once the cp as of the latest candle stick rallies above LL
        if p(end,5) > ll(end)
            condentrusts2remove.push(condentrust);
            fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as close price rallied above ll...');
        end
        %
    elseif strcmpi(signalinfo.mode,'conditional-breachuplvlup')
        %cancle once hp as of the latest candle stick falls below lvldn
        %or hh is updated
        if p(end,3) < lvldn(end) || hh(end-1) ~= hh(end)
            condentrusts2remove.push(condentrust);
            if p(end,3) < lvldn(end)
                fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as highest price fell below lvldn...');
            elseif hh(end-1) ~= hh(end)
                fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as hh value updated...');
            end
        else
            [~,~,~,~,~,isteethjawcrossed,~] = fractal_countb(p,idxHH,nfractal,lips,teeth,jaw,ticksize);
            if isteethjawcrossed && ss(end) >= 8
                %if alligator's teeth and jaw crossed with sell setup
                %breaches 8
                maxpx = max(p(end-ss(end)+1:end-1,5));%calculate the max price as of the sell sequential
                maxpxidx = find(p(end-ss(end)+1:end-1,5)==maxpx,1,'last')+size(p,1)-ss(end);
                if wad(maxpxidx) >= wad(end)
                    %if the WAD at the max price is above the latest wad
                    %the probability of price keeps rallying is slimmer
                    condentrusts2remove.push(condentrust);
                    fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as teeth jaw crossed..');
                end 
            end
        end
        %
    elseif strcmpi(signalinfo.mode,'conditional-breachdnlvldn')
        %cancel once lp as of the latest candle stick rallies above lvlup
        %or ll is updated
        if p(end,4) > lvlup(end) || ll(end-1) ~= ll(end)
            condentrusts2remove.push(condentrust);
            if p(end,4) > lvlup(end)
                fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as lowest price rallied above lvlup...');
            elseif ll(end-1) ~= ll(end)
                fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as ll value updated...');
            end
        else
            [~,~,~,~,~,isteethjawcrossed,~] = fractal_counts(p,idxLL,nfractal,lips,teeth,jaw,ticksize);
            if isteethjawcrossed && bs(end) >= 8
                %if alligator's teeth and jaw crossed with buy setup
                %breaches 8
                minpx = min(p(end-bs(end)+1:end-1,5));%calculate the min price as of the sell sequential
                minpxidx = find(p(end-bs(end)+1:end-1,5)==minpx,1,'last')+size(p,1)-bs(end);
                if wad(minpxidx) <= wad(end)
                    %if the WAD at the min price is below the latest wad
                    %the probability of price keeps falling is slimmer
                    condentrusts2remove.push(condentrust);
                    fprintf('\t%6s:%s:%s\n',instrument.code_ctp,signalinfo.mode, 'canceled as teeth jaw crossed..');
                end
            end
        end
    end
    %
end
%
if condentrusts2remove.latest > 0
    stratfractal.removecondentrusts(condentrusts2remove);
end


end

