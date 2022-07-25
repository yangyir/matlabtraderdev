function [] = updatestoploss(spiderman,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ExtraInfo',{},@isstruct);
    p.parse(varargin{:});
    extrainfo = p.Results.ExtraInfo;
    
%     candlek = extrainfo.p(end,:);

    if strcmpi(spiderman.type_,'breachup-B')
%         phigh = candlek(3);
%         hh = extrainfo.hh(end);
%         if phigh > hh
%               hh = hh + 0.382*(phigh-hh);
%         end
%         if hh > spiderman.hh1_, spiderman.hh1_ = hh;end
%         ll = extrainfo.ll(end);
%         if ll > spiderman.ll1_, spiderman.ll1_ = ll;end
%         %
%         spiderman.pxstoploss_ = spiderman.hh1_ - 0.618*(spiderman.hh1_-spiderman.ll1_);
%         spiderman.pxstoploss_ = min(spiderman.pxstoploss_,extrainfo.lips(end));
%         spiderman.pxstoploss2_ = spiderman.hh1_ - 0.382*(spiderman.hh1_-spiderman.ll1_);
%         spiderman.pxtarget_ = spiderman.hh1_ + 1.618*(spiderman.hh1_-spiderman.ll1_);
%         
%         if ~isempty(spiderman.trade_.instrument_)
%             ticksize = spiderman.trade_.instrument_.tick_size;
%             spiderman.pxstoploss_ = floor(spiderman.pxstoploss_/ticksize)*ticksize;
%             spiderman.pxstoploss2_ = floor(spiderman.pxstoploss2_/ticksize)*ticksize;
%             spiderman.pxtarget_ = ceil(spiderman.pxtarget_/ticksize)*ticksize;
%         end
%         
        if ~isnan(spiderman.tdlow_) && ~isnan(spiderman.tdhigh_)
            if spiderman.tdlow_ - (spiderman.tdhigh_-spiderman.tdlow_) > spiderman.pxstoploss_
                spiderman.pxstoploss_ = spiderman.tdlow_ - (spiderman.tdhigh_-spiderman.tdlow_);
                spiderman.closestr_ = 'tdsq:ssbreak';
            end
        end
        %
        if extrainfo.teeth(end) > spiderman.pxstoploss_
            spiderman.pxstoploss_ = extrainfo.teeth(end);
            if ~isempty(spiderman.trade_.instrument_)
                ticksize = spiderman.trade_.instrument_.tick_size;
                spiderman.pxstoploss_ = floor(extrainfo.teeth(end)/ticksize)*ticksize;                
            end
            spiderman.closestr_ = 'fractal:teeth';
        end 
        
    elseif strcmpi(spiderman.type_,'reverse-B')
        error('cSpiderman:updatestoploss:reverse-B not implemented...')
    elseif strcmpi(spiderman.type_,'breachdn-S')
%         plow = candlek(4);
%         ll = extrainfo.ll(end);
%         if plow < ll
%               ll = ll - 0.382*(ll-plow);
%         end
%         if ll < spiderman.ll1_, spiderman.ll1_ = ll;end
%         hh = extrainfo.hh(end);
%         if hh < spiderman.hh1_,spiderman.hh1_ = hh;end
%         %
%         spiderman.pxstoploss_ = spiderman.ll1_ + 0.618*(spiderman.hh1_-spiderman.ll1_);
%         spiderman.pxstoploss2_ = spiderman.ll1_ + 0.382*(spiderman.hh1_-spiderman.ll1_);
%         spiderman.pxtarget_ = spiderman.ll1_ - 1.618*(spiderman.hh1_-spiderman.ll1_);
%         
%         if ~isempty(spiderman.trade_.instrument_)
%             ticksize = spiderman.trade_.instrument_.tick_size;
%             spiderman.pxstoploss_ = ceil(spiderman.pxstoploss_/ticksize)*ticksize;
%             spiderman.pxstoploss2_ = ceil(spiderman.pxstoploss2_/ticksize)*ticksize;
%             spiderman.pxtarget_ = floor(spiderman.pxtarget_/ticksize)*ticksize;
%         end
%         
        if ~isnan(spiderman.tdlow_) && ~isnan(spiderman.tdhigh_)
            if spiderman.tdhigh_ + (spiderman.tdhigh_-spiderman.tdlow_) < spiderman.pxstoploss_
                spiderman.pxstoploss_ = spiderman.tdhigh_ + (spiderman.tdhigh_-spiderman.tdlow_);
                spiderman.closestr_ = 'tdsq:bsbreak';
            end
        end
        %
        if extrainfo.teeth(end) < spiderman.pxstoploss_
            spiderman.pxstoploss_ = extrainfo.teeth(end);
            if ~isempty(spiderman.trade_.instrument_)
                ticksize = spiderman.trade_.instrument_.tick_size;
                spiderman.pxstoploss_ = ceil(extrainfo.teeth(end)/ticksize)*ticksize;
            end
            spiderman.closestr_ = 'fractal:teeth';
        end
    elseif strcmpi(spiderman.type_,'reverse-S')
        error('cSpiderman:updatestoploss:reverse-S not implemented...')
    else
        error('cSpiderman:updatestoploss:invalid type...')
    end
    
    
end