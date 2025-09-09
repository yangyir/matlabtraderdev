function [calls,puts,underlier] = getlistedoptions(code_ctp_underlier,numstrikes)
    if nargin < 2, numstrikes = 5;end
    if mod(numstrikes,2) == 0
        error('getlistedoptions:numstrikes input shall be odd');
    end

    fn = [code_ctp_underlier,'_daily.txt'];
    data = cDataFileIO.loadDataFromTxtFile(fn);
    pclose = data(data(:,1) == getlastbusinessdate,5);
    
    if isempty(pclose)
%         error('getlistedoptions:last business close price not updated')
        try
            conn = bbgconnect;
            data = history(conn,ctp2bbg(code_ctp_underlier),'last_price',...
                getlastbusinessdate,getlastbusinessdate);
            pclose = data(1,2);
            conn.close;
        catch e
            error(e.message)
        end
    end
    
    underlier = cFutures(code_ctp_underlier);
    underlier.loadinfo([code_ctp_underlier,'_info.txt']);
    
    if ~isempty(strfind(code_ctp_underlier,'m'))
        bucketsize = 50;
    elseif ~isempty(strfind(code_ctp_underlier,'SR'))
        bucketsize = 100;
    elseif ~isempty(strfind(code_ctp_underlier,'cu'))
        if pclose <= 40000
            bucketsize = 500;
        elseif pclose > 40000 && pclose < 80000
            bucketsize = 1000;
        else
            bucketsize = 2000;
        end
    elseif ~isempty(strfind(code_ctp_underlier,'ru'))
        bucketsize = 250;
    elseif ~isempty(strfind(code_ctp_underlier,'c')) && isempty(strfind(code_ctp_underlier,'cu'))
        bucketsize = 20;
    elseif ~isempty(strfind(code_ctp_underlier,'CF'))
        bucketsize = 200;
    elseif ~isempty(strfind(code_ctp_underlier,'i'))
        bucketsize = 20;
    elseif ~isempty(strfind(code_ctp_underlier,'IM'))
        if pclose <= 2500
            bucketsize = 25;
        elseif pclose > 2500 && pclose <= 5000
            bucketsize = 50;
        elseif pclose > 5000 && pclose <= 10000
            bucketsize = 100;
        else
            bucketsize = 200;
        end
    elseif ~isempty(strfind(code_ctp_underlier,'IH'))
        if pclose <= 2500
            bucketsize = 25;
        elseif pclose > 2500 && pclose <= 5000
            bucketsize = 50;
        elseif pclose > 5000 && pclose <= 10000
            bucketsize = 100;
        else
            bucketsize = 200;
        end
    elseif ~isempty(strfind(code_ctp_underlier,'IF'))
        if pclose <= 2500
            bucketsize = 25;
        elseif pclose > 2500 && pclose <= 5000
            bucketsize = 50;
        elseif pclose > 5000 && pclose <= 10000
            bucketsize = 100;
        else
            bucketsize = 200;
        end    
    else
        error('getlistedoptions:unknown underlier')
    end
    
    strikemid = round(pclose/bucketsize)*bucketsize;
    n = (numstrikes-1)/2;
    strikes = zeros(numstrikes,1);
    for i = 1:numstrikes
        strikes(i) = (-n+i-1)*bucketsize+strikemid;
    end
    
    code_c = cell(numstrikes,1);
    code_p = cell(numstrikes,1);
    calls = cell(numstrikes,1);
    puts = cell(numstrikes,1);
    
    if ~isempty(strfind(code_ctp_underlier,'m')) || (~isempty(strfind(code_ctp_underlier,'c')) && isempty(strfind(code_ctp_underlier,'cu'))) ...
            || ~isempty(strfind(code_ctp_underlier,'i'))
        for i = 1:numstrikes
            code_c{i} = [code_ctp_underlier,'-C-',num2str(strikes(i))];
            calls{i} = cOption(code_c{i});
            calls{i}.loadinfo([code_c{i},'_info.txt']);
            %
            code_p{i} = [code_ctp_underlier,'-P-',num2str(strikes(i))];
            puts{i} = cOption(code_p{i});
            puts{i}.loadinfo([code_p{i},'_info.txt']);         
        end
    elseif ~isempty(strfind(code_ctp_underlier,'SR')) || ~isempty(strfind(code_ctp_underlier,'CF'))
        for i = 1:numstrikes
            code_c{i} = [code_ctp_underlier,'C',num2str(strikes(i))];
            calls{i} = cOption(code_c{i});
            calls{i}.loadinfo([code_c{i},'_info.txt']);
            %
            code_p{i} = [code_ctp_underlier,'P',num2str(strikes(i))];
            puts{i} = cOption(code_p{i});
            puts{i}.loadinfo([code_p{i},'_info.txt']);
        end
    elseif ~isempty(strfind(code_ctp_underlier,'cu')) || ~isempty(strfind(code_ctp_underlier,'ru'))
        for i = 1:numstrikes
            code_c{i} = [code_ctp_underlier,'C',num2str(strikes(i))];
            calls{i} = code2instrument(code_c{i});
            %
            code_p{i} = [code_ctp_underlier,'P',num2str(strikes(i))];
            puts{i} = code2instrument(code_p{i});
        end
    elseif ~isempty(strfind(code_ctp_underlier,'IM'))    
        for i = 1:numstrikes
            code_c{i} = ['MO',code_ctp_underlier(end-3:end),'-C-',num2str(strikes(i))];
            calls{i} = code2instrument(code_c{i});
            %
            code_p{i} = ['MO',code_ctp_underlier(end-3:end),'-P-',num2str(strikes(i))];
            puts{i} = code2instrument(code_p{i});
        end
    elseif ~isempty(strfind(code_ctp_underlier,'IF'))    
        for i = 1:numstrikes
            code_c{i} = ['IO',code_ctp_underlier(end-3:end),'-C-',num2str(strikes(i))];
            calls{i} = code2instrument(code_c{i});
            %
            code_p{i} = ['IO',code_ctp_underlier(end-3:end),'-P-',num2str(strikes(i))];
            puts{i} = code2instrument(code_p{i});
        end
    elseif ~isempty(strfind(code_ctp_underlier,'IH'))    
        for i = 1:numstrikes
            code_c{i} = ['HO',code_ctp_underlier(end-3:end),'-C-',num2str(strikes(i))];
            calls{i} = code2instrument(code_c{i});
            %
            code_p{i} = ['HO',code_ctp_underlier(end-3:end),'-P-',num2str(strikes(i))];
            puts{i} = code2instrument(code_p{i});
        end    
    else
        error('getlistedoptions:unknown underlier')
    end
    
    
    
    
end
