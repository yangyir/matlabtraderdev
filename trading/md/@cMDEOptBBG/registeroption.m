function [] = registeroption(obj,underlier,cpflag,strike,maturity)
% %cMDEOptBBG
    if ~(strcmpi(underlier,'510050') || strcmpi(underlier,'510300'))
        error('cMDEOptBBG:registeroption:invalid underlier')
    end
    
    underlierstr = [underlier,' CH Equity'];
    
    if isempty(obj.underliers_)
        obj.underliers_ = {underlierstr};
    else
        if sum(strcmpi(obj.underliers_,underlierstr)) == 0
            underliers = cell(length(obj.underliers_)+1,1);
            for i = 1:length(obj.underliers_),underliers{i} = obj.underliers_{i};end
            underliers(length(obj.underliers_)+1) = underlierstr;
            obj.underliers_ = underliers;
        end
    end
    
    if ~(strcmpi(cpflag,'c') || strcmpi(cpflag,'p') || ...
            strcmpi(cpflag,'call') || strcmpi(cpflag,'put'))
        error('cMDEOptBBG:registeroption:invalid cpflag')
    end
    
    optstr = [underlier,' CH ',datestr(maturity,'mm/dd/yy'),' ',upper(cpflag(1)),num2str(strike),' Equity'];
    
    if isempty(obj.options_)
        obj.options_ = {optstr};
        obj.delta_ = 0;
        obj.gamma_ = 0;
        obj.vega_ = 0;
        obj.theta_ = 0;
        obj.impvol_ = 0;
        obj.deltacarry_ = 0;
        obj.gammacarry_ = 0;
        obj.vegacarry_ = 0;
        obj.thetacarry_ = 0;
        obj.rtprbd_ = cell(1,1);
        
        try
            lastbd = getlastbusinessdate;
            if lastbd <= today
                lastbd = businessdate(lastbd,-1);
            end
            pnlriskoutput = pnlriskbreakdownbbg(optstr,lastbd);
            obj.deltacarryyesterday_ = pnlriskoutput.deltacarry;
            obj.gammacarryyesterday_ = pnlriskoutput.gammacarry;
            obj.vegacarryyesterday_ = pnlriskoutput.vegacarry;
            obj.thetacarryyesterday_ = pnlriskoutput.thetacarry;
            obj.impvolcarryyesterday_ = pnlriskoutput.iv2;
            obj.pvcarryyesterday_ = pnlriskoutput.premium2;
            obj.fwdyesterday_ = pnlriskoutput.fwd2;
            obj.spotyesterday_ = pnlriskoutput.spot2;
        catch
            obj.deltacarryyesterday_ = 0;
            obj.gammacarryyesterday_ = 0;
            obj.vegacarryyesterday_ = 0;
            obj.thetacarryyesterday_ = 0;
            obj.impvolcarryyesterday_ = 0;
            obj.pvcarryyesterday_ = 0;
            obj.fwdyesterday_ = 0;
            obj.spotyesterday_ = 0;
        end
    else
        if sum(strcmpi(obj.options_,optstr)) == 0
            %option not found
            options = cell(length(obj.options_)+1,1);
            rtprbd = cell(length(obj.options_)+1,1);
            for i = 1:length(obj.options_) 
                options{i} = obj.options_{i};
                rtprbd{i} = obj.rtprbd_{i};
            end
            options{length(obj.options_)+1} = optstr;
            rtprbd{length(obj.options_)+1} = [];
            obj.options_ = options;
            obj.delta_ = [obj.delta_;0];
            obj.gamma_ = [obj.gamma_;0];
            obj.vega_ = [obj.vega_;0];
            obj.theta_ = [obj.theta_;0];
            obj.impvol_ = [obj.impvol_;0];
            obj.deltacarry_ = [obj.deltacarry_;0];
            obj.gammacarry_ = [obj.gammacarry_;0];
            obj.vegacarry_ = [obj.vegacarry_;0];
            obj.thetacarry_ = [obj.thetacarry_;0];
            obj.rtprbd_ = rtprbd;
            try
                lastbd = getlastbusinessdate;
                if lastbd <= today
                    lastbd = businessdate(lastbd,-1);
                end
                pnlriskoutput = pnlriskbreakdownbbg(optstr,lastbd);
                obj.deltacarryyesterday_ = [obj.deltacarryyesterday_;pnlriskoutput.deltacarry];
                obj.gammacarryyesterday_ = [obj.gammacarryyesterday_;pnlriskoutput.gammacarry];
                obj.vegacarryyesterday_ = [obj.vegacarryyesterday_;pnlriskoutput.vegacarry];
                obj.thetacarryyesterday_ = [obj.thetacarryyesterday_;pnlriskoutput.thetacarry];
                obj.impvolcarryyesterday_ = [obj.impvolcarryyesterday_;pnlriskoutput.iv2];
                obj.pvcarryyesterday_ = [obj.pvcarryyesterday_;pnlriskoutput.premium2];
                obj.fwdyesterday_ = [obj.fwdyesterday_;pnlriskoutput.fwd2];
                obj.spotyesterday_ = [obj.spotyesterday_;pnlriskoutput.spot2];
            catch
                obj.deltacarryyesterday_ = [obj.deltacarryyesterday_;0];
                obj.gammacarryyesterday_ = [obj.gammacarryyesterday_;0];
                obj.vegacarryyesterday_ = [obj.vegacarryyesterday_;0];
                obj.thetacarryyesterday_ = [obj.thetacarryyesterday_;0];
                obj.impvolcarryyesterday_ = [obj.impvolcarryyesterday_;0];
                obj.pvcarryyesterday_ = [obj.pvcarryyesterday_;0];
                obj.fwdyesterday_ = [obj.fwdyesterday_;0];
                obj.spotyesterday_ = [obj.spotyesterday_;0];
            end
        end
    end
end
%end of registeroption