function [ret,tag] = updatetag(strategy,instrument,p,bs,ss,lvlup,lvldn,varargin)
%cStratFutMultiTDSQ
    np = size(p,1);
    if np ~= length(bs) || np ~= length(ss) || np ~= length(lvlup) || np ~= length(lvldn)
        error('%s:updatetag:invalid inputs!',strategy.name_);
    end

    tag = 'blank';
    [ret,i] = strategy.hasinstrument(instrument);
    if ~ret, return;end
    
    if ~(bs(end) == 9 || ss(end) == 9)
        tag = strategy.tags_{i};
        return
    else
        low6 = p(np-3,4);
        low7 = p(np-2,4);
        low8 = p(np-1,4);
        low9 = p(np,4);
        high6 = p(np-3,3);
        high7 = p(np-2,3);
        high8 = p(np-1,3);
        high9 = p(np,3);
        close8 = p(np-1,5);
        close9 = p(np,5);
    end
    
    if bs(end) == 9
        %TODO:need to study in case all the prices are below lvldn, i.e. in
        %double/single bearish case
        closedbelow = false;
        for k = np-8:np
            if isnan(lvldn(k)), continue;end
            if p(k,5) < lvldn(k)
                closedbelow = true;
                break
            end
        end
        
        if (low8 < min(low6,low7) || low9 < min(low6,low7)) && ~closedbelow
            if close9 < close8
                tag = 'perfectbs';
            else
                tag = 'semiperfectbs';
            end
        else
            tag = 'imperfectbs';
        end
        strategy.tags_{i} = tag;
        return
    end
    
    if ss(end) == 9
        %TODO:need to study in case all the prices are above lvlup, i.e. in
        %double/single bullish case
        closedabove = false;
        for k = np-8:np
            if isnan(lvlup(k)), continue;end
            if p(k,5) > lvlup(k)
                closedabove = true;
                break
            end
        end
        
        if (high8 > max(high6,high7) || high9 > max(high6,high7)) && ~closedabove
            if close9 > close8
                tag = 'perfectss';
            else
                tag = 'semiperfectss';
            end
        else
            tag = 'imperfectss';
        end
        strategy.tags_{i} = tag;
        return
    end

end