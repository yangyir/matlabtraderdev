function [] = opt_arbmonitor(mdeopt,underlier,strikes)
    qms = mdeopt.qms_;

    for i = 1:length(strikes)
        if strcmpi(underlier(1:2),'SR') || strcmpi(underlier(1:2),'CF') ...
                || strcmpi(underlier(1:2),'cu') || strcmpi(underlier(1:2),'ru')
            qc = qms.getquote([underlier,'C',num2str(strikes(i))]);
            qp = qms.getquote([underlier,'P',num2str(strikes(i))]);
        else
            qc = qms.getquote([underlier,'-C-',num2str(strikes(i))]);
            qp = qms.getquote([underlier,'-P-',num2str(strikes(i))]);
        end

        bid = -qp.ask1 + qc.bid1 + strikes(i);
        ask = strikes(i) +qc.ask1 - qp.bid1;
        bid_underlier = qc.bid_underlier;
        ask_underlier = qc.ask_underlier;
        if i == 1
            fprintf('\n');
            fprintf('%6s\t%6s\t%6s\t%6s\t%6s\n','strike','fwdbid','fwdask','futbid','futask');
        end

        fprintf('%6s\t%6s\t%6s\t%6s\t%6s\n',num2str(strikes(i)),num2str(bid),num2str(ask),...
            num2str(bid_underlier),num2str(ask_underlier));
    end

end

