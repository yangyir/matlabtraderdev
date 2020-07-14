function [] = setriskmanager_spiderman(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name',[],@ischar);
    p.addParameter('ExtraInfo',[],@isstruct);
    p.parse(varargin{:});
    name = p.Results.Name;
    info = p.Results.ExtraInfo;
    if ~strcmpi(name,'spiderman')
        error('cTradeOpen:setriskmanager_spiderman:internal error!!!')
    end
    
    riskmanager = cSpiderman;
    riskmanager.hh0_ = info.hh0_;
    riskmanager.hh1_ = info.hh1_;
    riskmanager.ll0_ = info.ll0_;
    riskmanager.ll1_ = info.ll1_;
    riskmanager.type_ = info.type_;
    %
    try
        riskmanager.tdhigh_ = info.tdhigh_;
        riskmanager.tdlow_ = info.tdlow_;
        riskmanager.td13high_ = info.td13high_;
        riskmanager.td13low_ = info.td13low_;
    catch
    end
    %
    try
        riskmanager.wadopen_ = info.wadopen_;
        riskmanager.cpopen_ = info.cpopen_;
        if strcmpi(riskmanager.type_,'breachup-B')
            riskmanager.wadhigh_ = info.wadhigh_;
            riskmanager.cphigh_ = info.cphigh_;
        elseif strcmpi(riskmanager.type_,'breachdn-S')
            riskmanager.wadlow_ = info.wadlow_;
            riskmanager.cplow_ = info.cplow_;
        end
    catch
    end
    %
    try
        riskmanager.fibonacci0_ = info.fibonacci0_;
        riskmanager.fibonacci1_ = info.fibonacci1_;
    catch
        riskmanager.fibonacci0_ = info.ll1_;
        riskmanager.fibonacci1_ = info.hh1_;
    end
    riskmanager.trade_ = obj;

    if strcmpi(riskmanager.type_,'breachup-B')
        riskmanager.pxstoploss_ = riskmanager.fibonacci1_ - 0.618*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
        riskmanager.pxstoploss2_ = riskmanager.fibonacci1_ - 0.382*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
        riskmanager.pxtarget_ = riskmanager.fibonacci1_ + 1.618*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
        riskmanager.closestr_ = 'fibonacci:0.618';
        
        if ~isempty(obj.instrument_)
            ticksize = obj.instrument_.tick_size;
            riskmanager.pxstoploss_ = floor(riskmanager.pxstoploss_/ticksize)*ticksize;
            riskmanager.pxstoploss2_ = floor(riskmanager.pxstoploss2_/ticksize)*ticksize;
            riskmanager.pxtarget_ = ceil(riskmanager.pxtarget_/ticksize)*ticksize;
        end
        
        if ~isnan(riskmanager.tdlow_) && ~isnan(riskmanager.tdhigh_)
            if riskmanager.tdlow_ - (riskmanager.tdhigh_-riskmanager.tdlow_) > riskmanager.pxstoploss_
                riskmanager.pxstoploss_ = riskmanager.tdlow_ - (riskmanager.tdhigh_-riskmanager.tdlow_);
                riskmanager.closestr_ = 'tdsq:ssbreak';
            end
        end
    elseif strcmpi(riskmanager.type_,'reverse-B')
        error('cTradeOpen:setriskmanager_spiderman:reverse-B not implemented...')
    elseif strcmpi(riskmanager.type_,'breachdn-S')
        riskmanager.pxstoploss_ = riskmanager.fibonacci0_ + 0.618*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
        riskmanager.pxstoploss2_ = riskmanager.fibonacci0_ + 0.382*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
        riskmanager.pxtarget_ = riskmanager.fibonacci0_ - 1.618*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
        riskmanager.closestr_ = 'fibonacci:0.618';
        
        if ~isempty(obj.instrument_)
            ticksize = obj.instrument_.tick_size;
            riskmanager.pxstoploss_ = ceil(riskmanager.pxstoploss_/ticksize)*ticksize;
            riskmanager.pxstoploss2_ = ceil(riskmanager.pxstoploss2_/ticksize)*ticksize;
            riskmanager.pxtarget_ = floor(riskmanager.pxtarget_/ticksize)*ticksize;
        end
        
        
        if ~isnan(riskmanager.tdlow_) && ~isnan(riskmanager.tdhigh_)
            if riskmanager.tdhigh_ + (riskmanager.tdhigh_-riskmanager.tdlow_) < riskmanager.pxstoploss_
                riskmanager.pxstoploss_ = riskmanager.tdhigh_ + (riskmanager.tdhigh_-riskmanager.tdlow_);
                riskmanager.closestr_ = 'tdsq:bsbreak';
            end
        end
    elseif strcmpi(riskmanager.type_,'reverse-S')
        error('cTradeOpen:setriskmanager_spiderman:reverse-S not implemented...')
    else
        error('cTradeOpen:setriskmanager_spiderman:invalid type...')
    end
    
    obj.riskmanager_ = riskmanager;
end