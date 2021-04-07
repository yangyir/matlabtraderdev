function [] = etf50_cpparity(datein)
    [c1,p1,~,~,strikes,exp1,~,S] = etf50_listoptions('2015-03-27')
    nk = length(strikes);
    cp_c1 = zeros(1,nk);
    cp_p1 = zeros(1,nk);
    for i = 1:nk
        fn_c = [c1{i},'_daily.txt'];
        try
            p_c = cDataFileIO.loadDataFromTxtFile(fn_c);
            cp_c1(i) = p_c(p_c(:,1)==datein,5);
        catch
            cp_c1(i) = NaN;
        end
    end
end