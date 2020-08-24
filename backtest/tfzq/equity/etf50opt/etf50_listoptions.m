function [calls1,puts1,calls2,puts2,strikes,exp1,exp2] = etf50_listoptions(datein)
    %calls1 are the 9 call options expiries on current month
    %puts1 are the 9 put options on expiries on current month
    %calls2 are the 9 call options expiries on next month
    %puts2 are the 9 put options expires on next month
    
    p = cDataFileIO.loadDataFromTxtFile('510050_daily.txt');
    
    if ischar(datein)
        datein = datenum(datein);
    end
    
    S = p(p(:,1)==datein,5);
    
    %bucket is 0.05 when S is less than 3
    %bucket is 0.1 when S is between 3 and 5
    %bucket is 0.25 when S is between 5 and 10
    K = 0.05:0.05:3;
    K = [K,3.1:0.1:5];
    K = [K,5.25:0.25:10];

    k1 = K(find(K<S,1,'last'));
    k2 = K(find(K>=S,1,'first'));
    
    if abs(S-k1) <= abs(S-k2)
        atmK = k1;
    else
        atmK = k2;
    end
    
    strikes = [K(find(K<=atmK,5,'last')),K(find(K>atmK,4,'first'))];
    
    %expires on the fourth wednesday
    day1 = datein - day(datein)+1;
    wd = weekday(day1);
    firstwed = day1;
    while wd ~= 4
        firstwed = firstwed+1;
        wd = weekday(firstwed);
    end
    exp1 = firstwed+21;
    
    mm = month(datein);
    yy = year(datein);
    if mm == 12
        day2 = datenum([num2str(yy+1),'0101'],'yyyymmdd');
    else
        if mm < 9
            day2 = datenum([num2str(yy),'0',num2str(mm+1),'01'],'yyyymmdd');
        else
            day2 = datenum([num2str(yy),num2str(mm+1),'01'],'yyyymmdd');
        end
    end
    
    wd = weekday(day2);
    firstwed = day2;
    while wd ~= 4
        firstwed = firstwed+1;
        wd = weekday(firstwed);
    end
    exp2 = firstwed+21;
    
    exp1str = datestr(exp1,'mmmyy');
    exp2str = datestr(exp2,'mmmyy');
    
    nk = length(strikes);
    calls1 = cell(1,nk);
    puts1 = cell(1,nk);
    calls2 = cell(1,nk);
    puts2 = cell(1,nk);
    
    for i = 1:length(strikes)
        calls1{i} = ['510050_',exp1str,'_C',num2str(strikes(i))];
        puts1{i} = ['510050_',exp1str,'_P',num2str(strikes(i))];
        %
        calls2{i} = ['510050_',exp2str,'_C',num2str(strikes(i))];
        puts2{i} = ['510050_',exp2str,'_P',num2str(strikes(i))];
    end
    
end