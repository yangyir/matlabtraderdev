function [] = readparametersfromtxtfile(strategy,fn_)
    fid = fopen(fn_,'r');
    if fid < 0
        error('cStratFutMultiWR:readparametersfromtxtfile:invalid file name input')
    end

    tline = fgetl(fid);
    lineinfo = regexp(tline,'\t','split');
    n = size(lineinfo,2) - 1;
    names_ = cell(100,1);
    values_ = cell(100,n);
    count = 0;
    while ischar(tline)
        count = count + 1;
        lineinfo = regexp(tline,'\t','split');
        names_{count} = lineinfo{1};
        for i = 2:size(lineinfo,2)
            values_{count,i-1} = lineinfo{i};
        end
        tline = fgetl(fid);
    end
    names_ = names_(1:count);
    values_ = values_(1:count,1:n);

    fclose(fid);

    futs = cell(n,1);
    for i = 1:size(names_,1)
        if strcmpi('code',names_{i})
            for j = 1:n
                code = values_{i,j};
                futs{j} = cFutures(code);
                futs{j}.loadinfo([code,'_info.txt']);
                strategy.registerinstrument(futs{j});
            end
            break
        end
    end

    for i = 1:size(names_,1)
        if strcmpi('stop',names_{i})
            for j = 1:n
                strategy.setstopamount(futs{j},str2double(values_{i,j}));
            end
        elseif strcmpi('limit',names_{i})
            for j = 1:n
                strategy.setlimitamount(futs{j},str2double(values_{i,j}));
            end
        elseif strcmpi('stoptype',names_{i})
            for j = 1:n
                strategy.setstoptype(futs{j},values_{i,j});
            end
        elseif strcmpi('limittype',names_{i})
            for j = 1:n
                strategy.setlimittype(futs{j},values_{i,j});
            end
        elseif strcmpi('bidspread',names_{i})
            for j = 1:n
                strategy.setbidspread(futs{j},str2double(values_{i,j}));
            end
        elseif strcmpi('askspread',names_{i})
            for j = 1:n
                strategy.setaskspread(futs{j},str2double(values_{i,j}));
            end                
        elseif strcmpi('baseunits',names_{i})
            for j = 1:n
                strategy.setbaseunits(futs{j},str2double(values_{i,j}));
            end
        elseif strcmpi('maxunits',names_{i})
            for j = 1:n
                strategy.setmaxunits(futs{j},str2double(values_{i,j}));
            end
        elseif strcmpi('autotrade',names_{i})
            for j = 1:n
                strategy.setautotradeflag(futs{j},str2double(values_{i,j}));
            end
        elseif strcmpi('numofperiods',names_{i})
            for j = 1:n
                nop = str2double(values_{i,j});
                params = struct('numofperiods',nop);
                strategy.setparameters(futs{j},params);
            end
        elseif strcmpi('tradingfreq',names_{i})
            for j = 1:n
                strategy.settradingfreq(futs{j},str2double(values_{i,j}));
            end
        elseif strcmpi('executiontype',names_{i})
            for j = 1:n
                strategy.setexecutiontype(futs{j},values_{i,j});
            end
        end
    end

    overbought = zeros(n,1);
    for i = 1:size(names_,1)
        if strcmpi('overbought',names_{i})
            for j = 1:n
                overbought(j) = str2double(values_{i,j});
            end
            break
        end
    end

    oversold = zeros(n,1);
    for i = 1:size(names_,1)
        if strcmpi('oversold',names_{i})
            for j = 1:n
                oversold(j) = str2double(values_{i,j});
            end
            break
        end
    end
    for j = 1:n
        strategy.setboundary(futs{j},overbought(j),oversold(j));
    end
end
%end of readparametersfromtxtfile