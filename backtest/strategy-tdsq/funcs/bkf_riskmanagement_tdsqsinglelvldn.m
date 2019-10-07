function [ ret,closestr,tradeout,closeidx ] = bkf_riskmanagement_tdsqsinglelvldn( tradein,p,bs,ss,bc,sc,macdvec,sigvec,macdbs,macdss,sns,varargin )
    %reverse mode 
    variablenotused(bc);
    variablenotused(sc);
    try
        type = tradein.opensignal_.type_;
        if ~strcmpi(type,'single-lvldn') 
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
%     iparser.addParameter('closeonperfect',false,@islogical);
%     iparser.addParameter('closeoncountdown13',false,@islogical);
    
    iparser.parse(varargin{:});
    usesetups = iparser.Results.usesetups;
%     closeonperfect = iparser.Results.closeonperfect;
%     closeoncountdown13 = iparser.Results.closeoncountdown13;
    
    
    diffvec = macdvec - sigvec;
    
    freq = tradein.opensignal_.frequency_;
    
    lvldn_open = tradein.opensignal_.lvldn_;
%     lvlup_open = tradein.opensignal_.lvlup_;
    
    if tradein.opendirection_ == 1
        for j = openidx+1:n
            sn_j = sns{j};
            tag_j = tdsq_snbd(sn_j);
            
            isperfectss_j = strcmpi(tag_j,'perfectss');
            if isperfectss_j
                %check whether perfectss is still valid
                iss_j = find(ss(1:j) == 9,1,'last');
                truehigh_j = max(p(iss_j-8:iss_j,3));
                idxtruehigh_j = find(p(iss_j-8:iss_j,3) == truehigh_j,1,'first');
                idxtruehigh_j = idxtruehigh_j + iss_j - 9;
                truehighbarsize_j = truehigh_j - p(idxtruehigh_j,4);
                stoploss_j = truehigh_j + truehighbarsize_j;
                if ~isempty(find(p(iss_j+1:j,5) > stoploss_j,1,'first'))
                    isperfectss_j = false;
                end
            end
            
            if diffvec(j) < 0 || (usesetups && bs(j) >= 4)
                closestr = 'macd';
                break;
            end
            if ss(j) >= 24
                closestr = 'setuplimit';
                break;
            end
            %
            if sc(j) == 13
                closestr = 'countdown13';
                break;
            end
            %
            if isperfectss_j 
                closestr = 'perfectsetup';
                break;
            end
            %
            if p(j,3) < lvldn_open
                closestr = 'trendreverse';
                break
            end
            %
            lastbar = islastbarbeforeholiday(instrument,freq,p(j,1));
            if lastbar
                closestr = 'holiday';
                break;
            end
        end
    elseif tradein.opendirection_ == -1
        hasperfectbs = false;
        for j = openidx+1:n
            if bs(j) == 9
                low6 = p(j-3,4);
                low7 = p(j-2,4);
                low8 = p(j-1,4);
                low9 = p(j,4);
                close8 = p(j-1,5);
                close9 = p(j,5);
                %unwind the trade if the buysetup sequential
                %itself is perfect
                if (low8 < min(low6,low7) || low9 < min(low6,low7)) && close9 < close8
                    hasperfectbs = true;
                end
            end
            
%             hasbreachlvlup = ~isempty(find(p(openidx:j,5) < lvlup_open,1,'first'));
            
            if diffvec(j) > 0 || (usesetups && ss(j) >= 4)
                closestr = 'macd';
                break;
            end
            if bs(j) >= 24
                closestr = 'setuplimit';
                break;
            end
            %
            if bc(j) == 13
                closestr = 'countdown13';
                break;
            end
            %
            if hasperfectbs && p(j,3) > lvldn_open
                closestr = 'perfectsetup';
                break;
            end
            %
            if p(j,4) > lvldn_open
                closestr = 'trendreverse';
                break
            end
            %
            lastbar = islastbarbeforeholiday(instrument,freq,p(j,1));
            if lastbar
                closestr = 'holiday';
                break;
            end
        end
    end
    %
    %
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

