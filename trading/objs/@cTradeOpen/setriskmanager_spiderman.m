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
    catch
    end
    try
        riskmanager.tdlow_ = info.tdlow_;
    catch
    end
    try
        riskmanager.td13high_ = info.td13high_;
    catch
    end
    try
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
    %
    try
        riskmanager.setusefractalupdateflag(info.usefractalupdate_);
    catch
    end
    %
    try
        riskmanager.setusefibonacciflag(info.usefibonacci_)
    catch
    end
    %
    riskmanager.trade_ = obj;

    if strcmpi(riskmanager.type_,'breachup-B')
        if strcmpi(info.status_, 'closed')
            riskmanager.status_ = info.status_;
            riskmanager.pxstoploss_ = info.pxstoploss_;
            riskmanager.pxtarget_ = info.pxtarget_;
            riskmanager.closestr_ = info.closestr_;
            if ~strcmpi(info.tdlow_,'NaN')
                riskmanager.tdlow_ = info.tdlow_;
            end
            if ~strcmpi(info.tdhigh_,'NaN')
                riskmanager.tdhigh_ = info.tdhigh_;
            end
        else
            try
                if ~strcmpi(info.pxstoploss_,'NaN') && isnumeric(info.pxstoploss_) && abs(info.pxstoploss_+9.99)>1e-6
                    riskmanager.pxstoploss_ = info.pxstoploss_;
                else
                    riskmanager.pxstoploss_ = riskmanager.fibonacci0_ - 0.382*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
                end
            catch
                riskmanager.pxstoploss_ = riskmanager.fibonacci0_ - 0.382*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
            end
%           riskmanager.pxstoploss2_ = riskmanager.fibonacci1_ - 0.382*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
            try
                if ~strcmpi(info.pxtarget_,'NaN') && isnumeric(info.pxtarget_) && abs(info.pxtarget_+9.99)>1e-6
                    riskmanager.pxtarget_ = info.pxtarget_;
                else
                    riskmanager.pxtarget_ = riskmanager.fibonacci1_ + 1.618*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
                end
            catch
                riskmanager.pxtarget_ = riskmanager.fibonacci1_ + 1.618*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
            end
            try
                if ~strcmpi(info.closestr_,'NaN')
                    riskmanager.closestr_ = info.closestr_;
                else
                    riskmanager.closestr_ = 'fibonacci:0.618';
                end
            catch
                riskmanager.closestr_ = 'fibonacci:0.618';
            end
        
            if ~isempty(obj.instrument_)
                ticksize = obj.instrument_.tick_size;
                riskmanager.pxstoploss_ = floor(riskmanager.pxstoploss_/ticksize)*ticksize;
%               riskmanager.pxstoploss2_ = floor(riskmanager.pxstoploss2_/ticksize)*ticksize;
                riskmanager.pxtarget_ = ceil(riskmanager.pxtarget_/ticksize)*ticksize;
            end
        
            if ~isnan(riskmanager.tdlow_) && ~isnan(riskmanager.tdhigh_)
                if riskmanager.tdlow_ - (riskmanager.tdhigh_-riskmanager.tdlow_) > riskmanager.pxstoploss_
                    riskmanager.pxstoploss_ = riskmanager.tdlow_ - (riskmanager.tdhigh_-riskmanager.tdlow_);
                    riskmanager.closestr_ = 'tdsq:ssbreak';
                end
            end
        end
    elseif strcmpi(riskmanager.type_,'reverse-B')
        error('cTradeOpen:setriskmanager_spiderman:reverse-B not implemented...')
    elseif strcmpi(riskmanager.type_,'breachdn-S')
        if strcmpi(info.status_, 'closed')
            riskmanager.status_ = info.status_;
            riskmanager.pxstoploss_ = info.pxstoploss_;
            riskmanager.pxtarget_ = info.pxtarget_;
            riskmanager.closestr_ = info.closestr_;
            if ~strcmpi(info.tdlow_,'NaN')
                riskmanager.tdlow_ = info.tdlow_;
            end
            if ~strcmpi(info.tdhigh_,'NaN')
                riskmanager.tdhigh_ = info.tdhigh_;
            end
        else
            try
                if ~strcmpi(info.pxstoploss_,'NaN') && isnumeric(info.pxstoploss_) && abs(info.pxstoploss_+9.99)>1e-6 
                    riskmanager.pxstoploss_ = info.pxstoploss_;
                else
                    riskmanager.pxstoploss_ = riskmanager.fibonacci1_ + 0.382*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
                end
            catch
                riskmanager.pxstoploss_ = riskmanager.fibonacci1_ + 0.382*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
            end
    %         riskmanager.pxstoploss2_ = riskmanager.fibonacci0_ + 0.382*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
            try
                if ~strcmpi(info.pxtarget_,'NaN') && isnumeric(info.pxtarget_) && abs(info.pxtarget_+9.99)>1e-6
                    riskmanager.pxtarget_ = info.pxtarget_;
                else
                    riskmanager.pxtarget_ = riskmanager.fibonacci0_ - 1.618*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
                end
            catch
                riskmanager.pxtarget_ = riskmanager.fibonacci0_ - 1.618*(riskmanager.fibonacci1_-riskmanager.fibonacci0_);
            end
            try
                if ~strcmpi(info.closestr_,'NaN')
                    riskmanager.closestr_ = info.closestr_;
                else
                    riskmanager.closestr_ = 'fibonacci:0.618';
                end
            catch
                riskmanager.closestr_ = 'fibonacci:0.618';
            end

            if ~isempty(obj.instrument_)
                ticksize = obj.instrument_.tick_size;
                riskmanager.pxstoploss_ = ceil(riskmanager.pxstoploss_/ticksize)*ticksize;
    %             riskmanager.pxstoploss2_ = ceil(riskmanager.pxstoploss2_/ticksize)*ticksize;
                riskmanager.pxtarget_ = floor(riskmanager.pxtarget_/ticksize)*ticksize;
            end


            if ~isnan(riskmanager.tdlow_) && ~isnan(riskmanager.tdhigh_)
                if riskmanager.tdhigh_ + (riskmanager.tdhigh_-riskmanager.tdlow_) < riskmanager.pxstoploss_
                    riskmanager.pxstoploss_ = riskmanager.tdhigh_ + (riskmanager.tdhigh_-riskmanager.tdlow_);
                    riskmanager.closestr_ = 'tdsq:bsbreak';
                end
            end
        end
    elseif strcmpi(riskmanager.type_,'reverse-S')
        error('cTradeOpen:setriskmanager_spiderman:reverse-S not implemented...')
    else
        error('cTradeOpen:setriskmanager_spiderman:invalid type...')
    end
    
    obj.riskmanager_ = riskmanager;
end