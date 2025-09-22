function [] = mdeopt_fin_plot( mdeopt)
%
    [~,~,p_i] = mdeopt.calc_macd_('IncludeLastCandle',1,'RemoveLimitPrice',1);
    op_i = tools_technicalplot1(p_i,mdeopt.nfractals_(1),0,'volatilityperiod',0,'tolerance',0);
    if size(op_i,1) >= 80
        tools_technicalplot2(op_i(end-79:end,:),2,[mdeopt.underlier_.code_ctp,'-',num2str(mdeopt.candle_freq_(1)),'m'],true);
    else
        tools_technicalplot2(op_i(1:end,:),2,[mdeopt.underlier_.code_ctp,'-',num2str(mdeopt.candle_freq_(1)),'m'],true);
    end

end

