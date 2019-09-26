function [ ret,closestr,tradeout ] = bkf_riskmanagement_tdsqimperfect( tradein,p,bs,ss,bc,sc,macdvec,sigvec,macdbs,macdss,sns,varargin )
    variablenotused(bc);
    try
        type = tradein.opensignal_.type_;
        if ~(strcmpi(type,'semiperfectbs') || strcmpi(type,'imperfectbs') ||...
                strcmpi(type,'semiperfectss') || strcmpi(type,'imperfectss'))
            ret = false;
            closestr = '';
            tradeout = {};
            return
        end
    catch
        ret = false;
        closestr = '';
        tradeout = {};
        return
    end

    openidx = find(p(:,1) <= tradein.opendatetime1_,1,'last');
    if isempty(openidx)
        ret = false;
        closestr = '';
        return
    end
    
    instrument = tradein.instrument_;
    contractsize = instrument.contract_size;
    if ~isempty(strfind(instrument.code_bbg,'TFT')) || ~isempty(strfind(instrument.code_bbg,'TFC'))
        contractsize = contractsize/100;
    end
    tradeout = tradein.copy;

    n = size(p,1);
    
    iparser = inputParser;
    iparser.CaseSensitive = false;iparser.KeepUnmatched = true;
    iparser.addParameter('usesetups',false,@islogical);
    iparser.addParameter('closeonperfect',false,@islogical);
    
    iparser.parse(varargin{:});
    usesetups = iparser.Results.usesetups;
    closeonperfect = iparser.Results.closeonperfect;
    
    diffvec = macdvec - sigvec;
    
    isrange = ~isempty(strfind(tradein.opensignal_.scenario_,'range'));
    israngereverse = strcmpi(tradein.opensignal_.scenario_,'range-reverse');
    israngebreach = strcmpi(tradein.opensignal_.scenario_,'range-breach');
    istrend = ~isempty(strfind(tradein.opensignal_.scenario_,'trend'));
    %long only
    newlvlup = tradein.opensignal_.lvlup_;
    oldlvldn = tradein.opensignal_.lvldn_;
    breachlvlup = false;
    for j = openidx+1:n
        if diffvec(j) < -5e-4 || (usesetups && bs(j) >= 4)
            closestr = 'macd';
            break;
        end
        %
        if sc(j) == 13
            closestr = 'countdown13';
            break;
        end
        %
        sn_j = sns{j};
        tag_j = tdsq_snbd(sn_j);
        if strcmpi(tag_j,'perfectss') && closeonperfect, 
            closestr = 'perfectsetup';
            break;
        end
        %
        %improvements in riskmanagement for semiperfect/imperfect
        if israngereverse && p(j,3) < oldlvldn
            closestr = 'rangereversebounceback';
            break;
        end
        %
        if israngebreach && p(j,3) < newlvlup
            closestr = 'rangebreachbounceback';
            break
        end
        
        if ~breachlvlup && p(j,5) > newlvlup, breachlvlup = true;end
        if isrange && ~israngereverse && breachlvlup && p(j,3) < newlvlup
            closestr = 'breachlvlupbounceback';
            break;
        end
        if istrend && breachlvlup && p(j,3) < newlvlup
            closestr = 'breachlvlupbounceback';
            break
        end
        if israngereverse && ~isempty(find(macdss(openidx:j) == 20,1,'last')) && macdss(j) == 0
            closestr = 'macdtrendbreak';
            break
        end
        if israngebreach && ss(j) == 9
            closestr = '';
            break
        end
%         if isrange || issinglebearish
%             hasbreachedlvlup = ~isempty(find(p(openidx:j,5) > newlvlup,1,'first'));
%             if hasbreachedlvlup && p(j,5) - newlvlup <= -4*instrument.tick_size, break;end
%         elseif isdoublebearish
%             hasbreachedlvldn = ~isempty(find(p(openidx:j,5) > oldlvldn,1,'first'));
%             if hasbreachedlvldn && p(j,5) - oldlvldn <= -4*instrument.tick_size, break;end
%         end
%         %special treatment before holiday
%         %unwind before holiday as the market is not continous
%         %anymore
%         cobd = floor(p(j,1));
%         nextbd = businessdate(cobd);
%         if nextbd - cobd > 3
%             hh = hour(p(j,1));
%             mm = minute(p(j,1));
%             %hard code below
%             if (hh == 14 && mm == 45) || (hh == 15 && mm == 0)
%                 break;
%             end
%         end
    end
    if j < n
        tradeout.closedatetime1_ = p(j,1);
        tradeout.closeprice_ = p(j,5);
        tradeout.closepnl_ = (tradeout.closeprice_-tradeout.openprice_)*contractsize;
        tradeout.status_ = 'closed';
    elseif j == n
        tradeout.runningpnl_ =(-p(j,5)+tradeout.openprice_)*contractsize;
        tradeout.status_ = 'set';
        j = j + 1;
    end
    
    ret = true;


end

