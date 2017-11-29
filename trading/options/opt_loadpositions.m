function portfolio = opt_loadpositions(fn,dateinput)

    pos_dir_ = [getenv('DATAPATH'),'pos_option\'];
    
    if ~isempty(strfind(fn,'.txt'))
        fid = fopen(pos_dir_,fn,'r');
    else
        fid = fopen([pos_dir_,fn,'.txt'],'r');
    end
        
    if fid < 0, return; end
    
    fut_dir_ = [getenv('DATAPATH'),'info_futures\'];
    opt_dir_ = [getenv('DATAPATH'),'info_option\'];
    
    
    portfolio = cPortfolio;
    portfolio.portfolio_id = fn;
    
    line_ = fgetl(fid);
    while ischar(line_)
        lineinfo = regexp(line_,'\t','split');
        code_i = lineinfo{1};
        flag = isoptchar(code_i);
        if flag
            instrument = cOption(code_i);
            instrument.loadinfo([opt_dir_,code_i,'_info.txt']);
        else
            instrument = cFutures(code_i);
            instrument.loadinfo([fut_dir_,code_i,'_info.txt']);
        end
        v_i = str2double(lineinfo{2});
        cost_i = str2double(lineinfo{3});
        if nargin < 2
            portfolio.addinstrument(instrument,cost_i,v_i);
        else
            if ischar(dateinput)
                dateinputnum = datenum(dateinput);
            else
                dateinputnum = dateinput;
            end
            portfolio.addinstrument(instrument,cost_i,v_i,dateinputnum);
        end
        
        line_ = fgetl(fid);
    end
            
    fclose(fid);
    
    
end