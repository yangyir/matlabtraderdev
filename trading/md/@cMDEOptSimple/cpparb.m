function [sellfwdlongspot,sellspotlongfwd,synfwdbid,synfwdask] = cpparb(obj,underlier)
%cMDEOptSimple
    if ~isa(underlier,'cInstrument'), underlier = code2instrument(underlier);end
    
    [flag,idx] = obj.underliers_.hasinstrument(underlier);
    
    if ~flag
        fprintf('%s not registered!\n',underlier.code_ctp);
    end
    
    strikes = obj.strikes_{idx};
    
    qms = obj.qms_;

    nk = length(strikes);
    synfwdbid = zeros(nk,1);
    synfwdask = zeros(nk,1);
    spotbid = zeros(nk,1);
    spotask = zeros(nk,1);
    
    for i = 1:nk
        if strcmpi(underlier.exchange,'.DCE')
            qc = qms.getquote([underlier.code_ctp,'-C-',num2str(strikes(i))]);
            qp = qms.getquote([underlier.code_ctp,'-P-',num2str(strikes(i))]);
        else
            qc = qms.getquote([underlier.code_ctp,'C',num2str(strikes(i))]);
            qp = qms.getquote([underlier.code_ctp,'P',num2str(strikes(i))]);
        end

        synfwdbid(i) = -qp.ask1 + qc.bid1 + strikes(i);
        synfwdask(i) = strikes(i) +qc.ask1 - qp.bid1;
        spotbid(i) = qc.bid_underlier;
        spotask(i) = qc.ask_underlier;
    end
    
    sellfwdlongspot = synfwdbid-spotask;
    sellspotlongfwd = spotbid-synfwdask;
    
    if obj.printflag_
        for i = 1:nk
            if sellfwdlongspot(i) > obj.threshold_(idx)
                fprintf('%6s\t%6s\t%6s\t%6s\t%6s\n',underlier.code_ctp,num2str(qc.last_trade_underlier),num2str(strikes(i)),'-C+P+S',num2str(sellfwdlongspot(i)));
            end
            %
            if sellspotlongfwd(i) > obj.threshold_(idx)
                fprintf('%6s\t%6s\t%6s\t%6s\t%6s\n',underlier.code_ctp,num2str(qc.last_trade_underlier),num2str(strikes(i)),'C-P-S',num2str(sellspotlongfwd(i)));
            end
        end
    end


end

