function [output,cparb_pnl,synthetic_l,synthetic_s] = listedoptmonitor_cparb(bbg,underlier,tenor,varargin)
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('BloombergConnection',@(x) validateattributes(x,{'blp'},{},'','BloombergConnection'));
p.addRequired('Underlier',@ischar);
p.addRequired('Tenor',@ischar);
p.addParameter('PrintOutput',false,@islogical);
p.addParameter('NumberOfStrikes',5,@isnumeric);
p.parse(bbg,underlier,tenor,varargin{:});
%
bbg = p.Results.BloombergConnection;
underlier = p.Results.Underlier;
tenor = p.Results.Tenor;
print = p.Results.PrintOutput;
nstrikes = p.Results.NumberOfStrikes;

output = listedoptinfo(bbg,underlier,tenor,'numberofstrikes',nstrikes,'printoutput',print);

futbid = output.Bid;
futask = output.Ask;

ivc = output.CallImpVol;
ivp = output.PutImpVol;
strikes = output.Strike;
quotec = output.CallQuote;
quotep = output.PutQuote;

%monitor1
%call-put parity
%same strike call and put with futures
cparb_pnl = zeros(nstrikes,1);
for i = 1:nstrikes
    if ivc(i) > ivp(i)
        %if implied vol of call is higher than implied vol of put, we short
        %call and long put and long futures
        %synthetic short forward with strike k and cost at put premium -
        %call premium
        cost = strikes(i)-(quotep(i,2)-quotec(i,1));
        cparb_pnl(i) = cost - futask;
        if cparb_pnl(i) > 0
            fprintf('c-p parity arb:short call/long put at strike %d / long fut\n',strikes(i));
        end
    elseif ivc(i) < ivp(i)
        %if implied vol of call is lower than implied vol of put, we long
        %call and short put and short futures
        %synthetic long forward with strike k and cost at call premium -
        %put premium
        cost = strikes(i)+(quotec(i,2)-quotep(i,1));
        cparb_pnl(i) = futbid - cost;
        if cparb_pnl(i) > 0
            fprintf('c-p parity arb:long call/short put at strike %d / short fut\n',strikes(i));
        end
    end
end

%call-put parity2 (box arb)
%different strikes call-put
synthetic_l = zeros(nstrikes,1);
synthetic_s = zeros(nstrikes,1);
for i = 1:nstrikes
    %synthetic long is to long call and short put
    %the real synthetic strike is the strike plus the call ask
    %subtracted by the put ask
    synthetic_l(i) = strikes(i)+quotec(i,2)-quotep(i,1);
    %
    %synthetic short is to short call and long put
    %the real synthetic strike is the strike plus the call bid subtracted
    %by the put bid
    synthetic_s(i) = strikes(i)+quotec(i,1)-quotep(i,2);
end

%if any synthetic long is smaller than synthetic short, long the synthetic
%foward 
for i = 1:nstrikes
    for j = i:nstrikes
        if synthetic_l(i) < synthetic_s(j)
            fprintf('box arb:long call and short put at strike %d; short call and long put at strike %d\n',...
                strikes(i),strikes(j));
        elseif synthetic_s(i) > synthetic_l(j)
            fprintf('box arb:long put and short call at strike %d; long call and short put at strike %d\n',...
                strikes(i),strikes(j));
        end
            
    end
end

end

    