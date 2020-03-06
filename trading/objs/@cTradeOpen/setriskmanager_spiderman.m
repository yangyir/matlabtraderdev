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
    riskmanager.tdhigh_ = info.tdhigh_;
    riskmanager.tdlow_ = info.tdlow_;
    riskmanager.trade_ = obj;

    if strcmpi(riskmanager.type_,'breachup-B')
        riskmanager.pxstoploss_ = riskmanager.hh1_ - 0.618*(riskmanager.hh1_-riskmanager.ll1_);
        riskmanager.pxstoploss2_ = riskmanager.hh1_ - 0.382*(riskmanager.hh1_-riskmanager.ll1_);
        riskmanager.pxtarget_ = riskmanager.hh1_ + 1.618*(riskmanager.hh1_-riskmanager.ll1_);
    elseif strcmpi(riskmanager.type_,'reverse-B')
        error('cTradeOpen:setriskmanager_spiderman:reverse-B not implemented...')
    elseif strcmpi(riskmanager.type_,'breachdn-S')
        riskmanager.pxstoploss_ = riskmanager.ll1_ + 0.618*(riskmanager.hh1_-riskmanager.ll1_);
        riskmanager.pxstoploss2_ = riskmanager.ll1_ + 0.382*(riskmanager.hh1_-riskmanager.ll1_);
        riskmanager.pxtarget_ = riskmanager.ll1_ - 1.618*(riskmanager.hh1_-riskmanager.ll1_);
    elseif strcmpi(riskmanager.type_,'reverse-S')
        error('cTradeOpen:setriskmanager_spiderman:reverse-S not implemented...')
    else
        error('cTradeOpen:setriskmanager_spiderman:invalid type...')
    end
    
    obj.riskmanager_ = riskmanager;
end