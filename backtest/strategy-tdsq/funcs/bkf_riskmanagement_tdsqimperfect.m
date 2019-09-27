function [ ret,closestr,tradeout,closeidx ] = bkf_riskmanagement_tdsqimperfect( tradein,p,bs,ss,bc,sc,macdvec,sigvec,macdbs,macdss,sns,varargin )
    %reverse mode 
    variablenotused(bc);
    variablenotused(sc);
    try
        type = tradein.opensignal_.type_;
        if ~(strcmpi(type,'semiperfectbs') || strcmpi(type,'imperfectbs') ||...
                strcmpi(type,'semiperfectss') || strcmpi(type,'imperfectss'))
            ret = false;
            closestr = '';
            tradeout = {};
            closeidx = -1;
            return
        end
    catch
        ret = false;
        closestr = '';
        tradeout = {};
        closeidx = -1;
        return
    end

    openidx = find(p(:,1) <= tradein.opendatetime1_,1,'last');
    if isempty(openidx)
        ret = false;
        closestr = '';
        closeidx = -1;
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
    iparser.addParameter('closeoncountdown13',false,@islogical);
    
    iparser.parse(varargin{:});
    usesetups = iparser.Results.usesetups;
    closeonperfect = iparser.Results.closeonperfect;
    closeoncountdown13 = iparser.Results.closeoncountdown13;
    
    
    diffvec = macdvec - sigvec;
    
    freq = tradein.opensignal_.frequency_;
    
    israngereverse = ~isempty(strfind(tradein.opensignal_.scenario_,'range-reverse'));
    isbreach = strcmpi(tradein.opensignal_.scenario_,'breach');
    israngebreach = ~isempty(strfind(tradein.opensignal_.scenario_,'range-breach'));
    %long only
    if tradein.opendirection_ == 1
        newlvlup = tradein.opensignal_.lvlup_;
        oldlvldn = tradein.opensignal_.lvldn_;
        isdoublebearish = false;
%         issinglebearish = false;
        if isnan(oldlvldn)
%             issinglebearish = true;
        else
            isdoublebearish = newlvlup < oldlvldn;
        end
%         isdoublerange = ~(isdoublebearish || issinglebearish);
        
        for j = openidx+1:n
            if diffvec(j) < -5e-4 || (usesetups && bs(j) >= 4)
                closestr = 'macd';
                break;
            end
            if ss(j) >= 24
                closestr = 'setuplimit';
                break;
            end
            %
            if sc(j) == 13 && closeoncountdown13
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
            if israngereverse && p(j,3) < oldlvldn
                closestr = 'reversebounceback';
                break;
            end
            %
            if isbreach && p(j,3) < newlvlup
                closestr = 'breachbounceback1';
                break
            end
            %
            if israngereverse && ~isempty(find(macdss(openidx:j) == 20,1,'last')) && macdss(j) == 0
                closestr = 'macdlimit';
                break
            end
            %
            if israngebreach && ss(j) == 9
                closestr = 'rangebreachsetuplimit';
                break
            end
            %
            if ~isdoublebearish
                hasbreachedlvlup = ~isempty(find(p(openidx:j,5) > newlvlup,1,'first'));
                if hasbreachedlvlup && p(j,5) - newlvlup < -4*instrument.tick_size
%                 if hasbreachedlvlup && p(j,3) <= newlvlup
                    closestr = 'breachbounceback2';
                    break;
                end
            else
                hasbreachedlvldn = ~isempty(find(p(openidx:j,5) > oldlvldn,1,'first'));
                if hasbreachedlvldn && p(j,5) - oldlvldn < -4*instrument.tick_size
%                 if hasbreachedlvldn && p(j,3) <= oldlvldn
                    closestr = 'breachbounceback3';
                    break;
                end
            end
            %
            lastbar = islastbarbeforeholiday(instrument,freq,p(j,1));
            if lastbar
                closestr = 'holiday';
                break;
            end
        end
    else
        oldlvlup = tradein.opensignal_.lvlup_;
        newlvldn = tradein.opensignal_.lvldn_;
        isdoublebullish = false;
%         issinglebullish = false;
        if isnan(oldlvlup)
%             issinglebullish = true;
        else
            isdoublebullish = newlvldn > oldlvlup;
        end
%         isdoublerange = ~(isdoublebullish || issinglebullish);
        
        for j = openidx+1:n
            if diffvec(j) > 5e-4 || (usesetups && ss(j) >= 4)
                closestr = 'macd';
                break;
            end
            if bs(j) >= 24
                closestr = 'setuplimit';
                break;
            end
            %
            if bc(j) == 13 && closeoncountdown13
                closestr = 'countdown13';
                break;
            end
            %
            sn_j = sns{j};
            tag_j = tdsq_snbd(sn_j);
            if strcmpi(tag_j,'perfectbs') && closeonperfect, 
                closestr = 'perfectsetup';
                break;
            end
            %
            if israngereverse && p(j,4) > oldlvlup
                closestr = 'reversebounceback';
                break;
            end
            %
            if isbreach && p(j,4) < newlvldn
                closestr = 'breachbounceback1';
                break
            end
            %
            if israngereverse && ~isempty(find(macdbs(openidx:j) == 20,1,'last')) && macdbs(j) == 0
                closestr = 'macdlimit';
                break
            end
            %
            if israngebreach && bs(j) == 9
                closestr = 'rangebreachsetuplimit';
                break
            end
            %
            if ~isdoublebullish
                hasbreachedlvldn = ~isempty(find(p(openidx:j,5) < newlvldn,1,'first'));
                if hasbreachedlvldn && p(j,5) - newlvldn > 4*instrument.tick_size
%                 if hasbreachedlvldn && p(j,4) >= newlvldn
                    closestr = 'breachbounceback2';
                    break;
                end
            else
                hasbreachedlvlup = ~isempty(find(p(openidx:j,5) < oldlvlup,1,'first'));
                if hasbreachedlvlup && p(j,5) - oldlvlup > 4*instrument.tick_size
%                 if hasbreachedlvlup && p(j,4) >= oldlvlup
                    closestr = 'breachbounceback3';
                    break;
                end
            end
            %
            lastbar = islastbarbeforeholiday(instrument,freq,p(j,1));
            if lastbar
                closestr = 'holiday';
                break;
            end
        end        
    end
    if j < n
        tradeout.closedatetime1_ = p(j,1);
        tradeout.closeprice_ = p(j,5);
        tradeout.closepnl_ = tradeout.opendirection_*(tradeout.closeprice_-tradeout.openprice_)*contractsize;
        tradeout.status_ = 'closed';
        closeidx = j;
    elseif j == n
        closestr = '';
        tradeout.runningpnl_ =tradeout.opendirection_*(p(j,5)-tradeout.openprice_)*contractsize;
        tradeout.status_ = 'set';
        closeidx = j+1;
    end
    
    ret = true;


end

