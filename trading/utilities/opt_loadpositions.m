function portfolio = opt_loadpositions(fn)

    pos_dir_ = [getenv('DATAPATH'),'pos_opt\'];
    
    fid = fopen([pos_dir_,fn,'.txt'],'r');
        
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
        portfolio.addinstrument(instrument,cost_i,v_i);
        
        line_ = fgetl(fid);
    end
            
    fclose(fid);
    
    
end