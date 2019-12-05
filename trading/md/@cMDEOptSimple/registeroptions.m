function [] = registeroptions(obj,underlier,strikes)
%cMDEOptSimple
    if ischar(underlier)
        code = underlier;
    elseif isa(underlier,'cInstrument')
        code = underlier.code_ctp;
        %todo:for 50ETF and 300 ETF options
    end
    
    nk = length(strikes);
    
    if ~isa(underlier,'cInstrument'), underlier = code2instrument(underlier);end
    
    if isempty(obj.underliers_),obj.underliers_ = cInstrumentArray;end
    
    [flag,idx] = obj.underliers_.hasinstrument(underlier);
    
    if ~flag
        nu = obj.underliers_.count;
        obj.underliers_.addinstrument(underlier);
        k = cell(nu+1,1);
        for i = 1:nu;k{i,1} = obj.strikes_{i,1};end
        k{nu+1,1} = strikes;
        obj.strikes_ = k;
    else
        k = [obj.strikes_{idx,1};strikes];
        k = unique(k);
        obj.strikes_{idx,1} = k;
    end
    
    for i = 1:nk
        if strcmpi(underlier.asset_name,'soymeal') || strcmpi(underlier.asset_name,'corn')
            code_c = [code,'-C-',num2str(strikes(i))];
            code_p = [code,'-P-',num2str(strikes(i))];
            obj.registerinstrument(code_c);
            obj.registerinstrument(code_p);
        end
    end

end