function signal = tdsq_gensignal(bs,ss,lvlup,lvldn,bc,sc,p,macdvec,sigvec,prevsignal)
    

    scenarioname = tdsq_getscenarioname(bs,ss,lvlup,lvldn,bc,sc,p);
    if strcmpi(scenarioname,'blank')
        signal = 0;
        return
    end
    
    scenarionamebreakups = regexp(scenarioname,'-','split');
    
%     nsetups = str2double(scenarionamebreakups{2});
    
    isperfect = strfind(scenarionamebreakups{3},'perfect')== 1;
    
    if strcmpi(scenarionamebreakups{1},'bsonly') || strcmpi(scenarionamebreakups{1},'bslast')
        if isperfect
            signal = 1;
        else
            if macdvec(end) > sigvec(end)
                signal = 1;
            else
                if prevsignal == -1
                    signal = -1;
                else
                    signal = 0;
                end
            end
        end 
    elseif strcmpi(scenarionamebreakups{1},'ssonly') || strcmpi(scenarionamebreakups{1},'sslast')
        if isperfect
            signal = -1;
        else
            if macdvec(end) < sigvec(end)
                signal = -1;
            else
                if prevsignal == 1
                    signal = 1;
                else
                    signal = 0;
                end
            end
        end
    end
    
    
end