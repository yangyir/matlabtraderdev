function op = fractal_exclusiontest1(p,nfractal,code,freq)
%CHECK status of the long trades which satisfied the following conditions
%condition 1:open ss >= 9 or sc == 13
%
%condition 2:highest candle close and highest candle high reached at this
%candle at the same time
%
%condition 3:how many full sell sequential has reached but
%   a. without any buy sequential between
%   b. the price has never fall below the TDST supports

%fractals
[~,~,HH,LL] = fractal(p,nfractal);
%alligators
jaw = smma(p,13,8);jaw = [nan(8,1);jaw];
teeth = smma(p,8,5);teeth = [nan(5,1);teeth];
lips = smma(p,5,3);lips = [nan(3,1);lips];
%demark
[bs,ss,lvlup,lvldn,bc,sc] = tdsq(p(:,1:5));
%A/D
wad = williamsad(p(:,1:5));
%
idxfractalb1 = fractal_genindicators1( p(:,1:5),HH,LL,jaw,teeth,lips );
nb1 = size(idxfractalb1,1);
op = zeros(nb1,4);
count = 0;
for i = 1:nb1
    j = idxfractalb1(i);
    %check condition 1
    if ~(ss(j)>=9 || sc(j) == 13), continue;end
    %check condition 2
    if ss(j) >= 9 && ~(max(p(j-ss(j)+1:j,5)) == p(j,5) && max(p(j-ss(j)+1:j,3)) == p(j,3)), continue;end
    %check condition 3
    ss9 = find(ss(1:j)==9,2,'last');
    if length(ss9)< 2 || ...
            ~isempty(find(bs(ss9(1):j)==9,1,'last')) || ...
            ~isempty(find(p(ss9(1):j,4)<lvldn(ss9(1)),1,'first'))
        continue
    end
    %
    count = count+1;
    ss9 = find(ss(1:j)==9,3,'last');
    if isempty(find(bs(ss9(1):j)==9,1,'last')) && ...
            isempty(find(p(ss9(1):j,4)<lvldn(ss9(1)),1,'first')) && ...
            isempty(find(p(ss9(2):j,4)<lvldn(ss9(2)),1,'first'))
         op(count,4) = 3;
    else
        op(count,4) = 2;
    end
    
    op(count,1:2) = idxfractalb1(i,:);
    if sc(j) == 13
        op(count,4) = -1;
    end
        
end
if count > 0
    op = op(1:count,:);
    trades = cTradeOpenArray;
    for i = 1:count
        j = op(i,1);
        signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency',freq);
        riskmanager = struct('hh0_',p(j,3),'hh1_',p(j,3),'ll0_',LL(j),'ll1_',LL(j),'type_','breachup-B');
        tradenew = cTradeOpen('id',i,'opendatetime',p(j,1),'openprice',p(j,5),'opendirection',1,'openvolume',1,'code',code);
        tradenew.status_ = 'set';
        tradenew.setsignalinfo('name','fractal','extrainfo',signalinfo);
        tradenew.setriskmanager('name','spiderman','extrainfo',riskmanager);
        if ss(j) >= 9
            ssreached = ss(j);
            tradenew.riskmanager_.tdhigh_ = max(p(j-ssreached+1:j,3));
            tdidx = find(p(j-ssreached+1:j,3)==tradenew.riskmanager_.tdhigh_,1,'last')+j-ssreached;
            tradenew.riskmanager_.tdlow_ = p(tdidx,4);
            if tradenew.riskmanager_.tdlow_ - (tradenew.riskmanager_.tdhigh_-tradenew.riskmanager_.tdlow_) > tradenew.riskmanager_.pxstoploss_
                tradenew.riskmanager_.pxstoploss_ = tradenew.riskmanager_.tdlow_ - (tradenew.riskmanager_.tdhigh_-tradenew.riskmanager_.tdlow_);
            end
        end
        trades.push(tradenew);
    end
    for i = 1:count
        tradeout = fractal_runtrade(trades.node_(i),p(:,1:5),HH,LL,jaw,teeth,lips,bs,ss,bc,sc,lvlup,lvldn,wad,false);
        if isempty(tradeout)
            if ~isempty(trades.node_(i).runningpnl_)
                op(i,3) = trades.node_(i).runningpnl_;
            else
                op(i,3) = 0;
            end
        else
            op(i,3) = tradeout.closepnl_;
        end
    end
else
    op = [];
    return
end




end