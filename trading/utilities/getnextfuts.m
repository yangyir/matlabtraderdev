function nextfuts = getnextfuts(thisfuts)
    instr = code2instrument(thisfuts);
    assetname = instr.asset_name;
    expiry = instr.last_trade_date1;
    expiry_yy = year(expiry);
    expiry_mm = month(expiry);
    if strcmpi(assetname,'eqindex_300') || ...
            strcmpi(assetname,'eqindex_50') || ...
            strcmpi(assetname,'eqindex_500') || ...
            strcmpi(assetname,'eqindex_1000')
        %
        if expiry_mm == 12
            next_mm = 1;
            next_yy = expiry_yy + 1;
        else
            next_mm = expiry_mm + 1;
            next_yy = expiry_yy;
        end
        if next_mm < 10
            nextfuts = [thisfuts(1:2),num2str(next_yy-2000),'0',num2str(next_mm)];
        else
            nextfuts = [thisfuts(1:2),num2str(next_yy-2000),num2str(next_mm)];
        end
        
    elseif strcmpi(assetname,'govtbond_2y') || ...
            strcmpi(assetname,'govtbond_5y') || ...
            strcmpi(assetname,'govtbond_10y') || ...
            strcmpi(assetname,'govtbond_30y')
        %
        if expiry_mm == 12
            next_mm = 3;
            next_yy = expiry_yy + 1;
        else
            next_mm = expiry_mm + 3;
            next_yy = expiry_yy;
        end
        if next_mm < 10
            if strcmpi(assetname,'govtbond_10y')
                nextfuts = [thisfuts(1),num2str(next_yy-2000),'0',num2str(next_mm)];
            else
                nextfuts = [thisfuts(1:2),num2str(next_yy-2000),'0',num2str(next_mm)];
            end
        else
            if strcmpi(assetname,'govtbond_10y')
                nextfuts = [thisfuts(1),num2str(next_yy-2000),num2str(next_mm)];
            else
                nextfuts = [thisfuts(1:2),num2str(next_yy-2000),num2str(next_mm)];
            end
        end
    end
end