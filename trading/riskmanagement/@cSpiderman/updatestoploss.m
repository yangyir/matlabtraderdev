function [] = updatestoploss(spiderman,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ExtraInfo',{},@isstruct);
    p.parse(varargin{:});
    extrainfo = p.Results.ExtraInfo;
    
    candlek = extrainfo.p(end,:);

    if strcmpi(spiderman.type_,'breachup-B')
        hh = candlek(3);
        if hh > spiderman.hh1_, spiderman.hh1_ = hh;end
        ll = extrainfo.ll(end);
        if ll > spiderman.ll1_, spiderman.ll1_ = ll;end
        %
        spiderman.pxstoploss_ = spiderman.hh1_ - 0.618*(spiderman.hh1_-spiderman.ll1_);
        spiderman.pxstoploss2_ = spiderman.hh1_ - 0.382*(spiderman.hh1_-spiderman.ll1_);
        spiderman.pxtarget_ = spiderman.hh1_ + 1.618*(spiderman.hh1_-spiderman.ll1_);
        if ~isnan(spiderman.tdlow_) && ~isnan(spiderman.tdhigh_)
            if spiderman.tdlow_ - (spiderman.tdhigh_-spiderman.tdlow_) > spiderman.pxstoploss_
                spiderman.pxstoploss_ = spiderman.tdlow_ - (spiderman.tdhigh_-spiderman.tdlow_);
            end
        end
        
    elseif strcmpi(spiderman.type_,'reverse-B')
        error('cSpiderman:updatestoploss:reverse-B not implemented...')
    elseif strcmpi(spiderman.type_,'breachdn-S')
        ll = candlek(4);
        if ll < spiderman.ll1_, spiderman.ll1_ = ll;end
        hh = extrainfo.hh(end);
        if hh < spiderman.hh1_,spiderman.hh1_ = hh;end
        %
        spiderman.pxstoploss_ = spiderman.ll1_ + 0.618*(spiderman.hh1_-spiderman.ll1_);
        spiderman.pxstoploss2_ = spiderman.ll1_ + 0.382*(spiderman.hh1_-spiderman.ll1_);
        spiderman.pxtarget_ = spiderman.ll1_ - 1.618*(spiderman.hh1_-spiderman.ll1_);
        if ~isnan(spiderman.tdlow_) && ~isnan(spiderman.tdhigh_)
            if spiderman.tdhigh_ + (spiderman.tdhigh_-spiderman.tdlow_) < spiderman.pxstoploss_
                spiderman.pxstoploss_ = spiderman.tdhigh_ + (spiderman.tdhigh_-spiderman.tdlow_);
            end
        end
    elseif strcmpi(spiderman.type_,'reverse-S')
        error('cSpiderman:updatestoploss:reverse-S not implemented...')
    else
        error('cSpiderman:updatestoploss:invalid type...')
    end
    
    
end