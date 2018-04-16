% NOTE:historical iv analysis of soymeal
fprintf('run empirical analysis of implied volatilies of listed options written on soymeal futures......\n');
%%
% download historical price for futures
fprintf('download historical close prices of underlying futures contracts......\n');
ds = cLocal;
fut_codes = {'m1801';'m1805';'m1809'};
nfuts = size(fut_codes,1);
fut_objs = cell(nfuts,1);
fut_cp = cell(nfuts,1);
for i = 1:nfuts
    fut_objs{i} = cFutures(fut_codes{i});fut_objs{i}.loadinfo([fut_codes{i},'_info.txt']);
    fut_cp{i} = ds.history(fut_objs{i},'last_trade',fut_objs{i}.first_trade_date1,fut_objs{i}.last_trade_date1);
end
%%
% download historical price for options
fprintf('download historical close prices of calls and puts......\n');
atmk = cell(nfuts,1);
k = cell(nfuts,1);
bucketsize = 50;
for i = 1:nfuts
    atmk{i} = round(fut_cp{i}(:,2)/bucketsize)*bucketsize;
    k{i} = unique(atmk{i});
    k{i} = [k{i}(1)-bucketsize;...
        k{i};k{i}(end)+bucketsize]; 
end
opt_objs = cell(nfuts,1);
opt_cp = cell(nfuts,1);
for i = 1:nfuts
    nk = size(k{i},1);
    objs = cell(nk,2);
    cp = cell(nk,2);
    for j = 1:nk
        c_code = [fut_codes{i},'-C-',num2str(k{i}(j))];
        p_code = [fut_codes{i},'-P-',num2str(k{i}(j))];
        objs{j,1} = cOption(c_code);objs{j,1}.loadinfo([c_code,'_info.txt']);
        objs{j,2} = cOption(p_code);objs{j,2}.loadinfo([p_code,'_info.txt']);
        cp{j,1} = ds.history(objs{j,1},'last_trade',objs{j,1}.first_trade_date1,objs{j,1}.last_trade_date1);
        cp{j,2} = ds.history(objs{j,2},'last_trade',objs{j,2}.first_trade_date1,objs{j,2}.last_trade_date1);
    end
    opt_objs{i} = objs;
    opt_cp{i} = cp;
end
%%
fprintf('calculate implied volatility of listed options......\n');
ivs = cell(nfuts,1);
for i = 1:nfuts
    f_cp = fut_cp{i};
    c_cp = opt_cp{i}(:,1);
    p_cp = opt_cp{i}(:,2);
    nopt = size(c_cp,1);
    temp = [cell2mat(c_cp);cell2mat(p_cp)];
    bds = unique(temp(:,1));
    nbds = size(bds,1);
    c_iv = NaN(nbds,nopt);
    p_iv = NaN(nbds,nopt);
    tbl_export = zeros(nbds,nopt+2);
    tbl_export(:,1) = bds;
    for j = 1:nbds
        s = f_cp(f_cp(:,1) == bds(j),2);
        tbl_export(j,2) = s;
        for jj = 1:nopt
            strike = k{i}(jj);
            c_premium = c_cp{jj}(c_cp{jj}(:,1) == bds(j),2);
            p_premium = p_cp{jj}(p_cp{jj}(:,1) == bds(j),2);
            
            if ~isempty(c_premium)
                tbl_export(j,jj+2) = c_premium;
            else
                tbl_export(j,jj+2) = NaN;
            end
            
            if bds(j) >= opt_objs{i}{jj,1}.opt_expiry_date1,continue;end
            
            if ~isempty(c_premium)
                c_iv(j,jj) = bjsimpv(s,strike,0.035,bds(j),...
                    opt_objs{i}{jj,1}.opt_expiry_date1,c_premium,[],0.035,[],'call');
            end
            
            if ~isempty(p_premium)
                p_iv(j,jj) = bjsimpv(s,strike,0.035,bds(j),...
                    opt_objs{i}{jj,2}.opt_expiry_date1,p_premium,[],0.035,[],'put');
            end

        end
    end
end


