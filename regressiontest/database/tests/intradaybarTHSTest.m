classdef intradaybarTHSTest < matlab.unittest.TestCase
    properties
        Connection
    end

    methods (TestClassSetup)
        function addPaths(testCase)
            testDir = fileparts(mfilename('fullpath'));
            root = fileparts(fileparts(fileparts(testDir)));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root,'trading','database')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root,'trading','instruments')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root,'trading','utilities')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root,'trading','dates')));
            % Keep vendor stubs off recursive production paths.
            temporary = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            copyfile(fullfile(testDir,'private','THS_HF.m'),temporary.Folder);
            copyfile(fullfile(testDir,'private','THS_iFinDLogin.m'),temporary.Folder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                temporary.Folder));
        end
    end

    methods (TestMethodSetup)
        function connect(testCase)
            global thsIntradayTestData thsIntradayTestCalls
            thsIntradayTestData = [];
            thsIntradayTestCalls = {};
            testCase.addTeardown(@testCase.clearFixtureData);
            testCase.Connection = cTHS;
        end
    end

    methods (Test)
        function oneMinuteFuturesPreserveOHLC(testCase)
            raw = testCase.setBars({'2024-06-03 09:30';'2024-06-03 09:31'});
            f = testCase.future('09:15-11:30;13:00-15:15','');
            actual = testCase.Connection.intradaybar(f, ...
                '2024-06-03','2024-06-03',1,'trade');
            testCase.verifyEqual(actual(:,1), ...
                datenum({'2024-06-03 09:29';'2024-06-03 09:30'}, ...
                'yyyy-mm-dd HH:MM'),'AbsTol',1e-10);
            testCase.verifyEqual(actual(:,2:5),raw(:,2:5),'AbsTol',0);
        end

        function stockSessionClosesAndOpens(testCase)
            raw = testCase.setBars({'2024-06-03 09:30';'2024-06-03 09:31'; ...
                '2024-06-03 11:30';'2024-06-03 13:01';'2024-06-03 15:00'});
            actual = testCase.Connection.intradaybar('510300', ...
                '2024-06-03','2024-06-03',1,'trade');
            testCase.verifyEqual(actual(:,1),datenum({ ...
                '2024-06-03 09:30';'2024-06-03 11:29'; ...
                '2024-06-03 13:00';'2024-06-03 14:59'}, ...
                'yyyy-mm-dd HH:MM'),'AbsTol',1e-10);
            testCase.verifyEqual(actual(:,2:5),raw(2:5,2:5),'AbsTol',0);
        end

        function fiveMinuteBoundaryAndPartialBucket(testCase)
            testCase.setBars({'2024-06-03 09:31';'2024-06-03 09:32'; ...
                '2024-06-03 09:33';'2024-06-03 09:34'; ...
                '2024-06-03 09:35';'2024-06-03 09:36'});
            actual = testCase.Connection.intradaybar('510300', ...
                '2024-06-03','2024-06-03',5,'trade');
            expected = [datenum('2024-06-03 09:30','yyyy-mm-dd HH:MM'),1,15,-5,5.5; ...
                datenum('2024-06-03 09:35','yyyy-mm-dd HH:MM'),6,16,-6,6.5];
            testCase.verifyEqual(actual,expected,'AbsTol',1e-10);
        end

        function thirtyMinuteBoundaryUsesSourceDuration(testCase)
            testCase.setBars({'2024-06-03 10:00';'2024-06-03 10:01'});
            actual = testCase.Connection.intradaybar('510300', ...
                '2024-06-03','2024-06-03',30,'trade');
            expected = [datenum('2024-06-03 09:30','yyyy-mm-dd HH:MM'),1,11,-1,1.5; ...
                datenum('2024-06-03 10:00','yyyy-mm-dd HH:MM'),2,12,-2,2.5];
            testCase.verifyEqual(actual,expected,'AbsTol',1e-10);
        end

        function fifteenMinuteFuturesClose(testCase)
            testCase.setBars({'2024-06-03 15:00';'2024-06-03 15:01'; ...
                '2024-06-03 15:15'});
            f = testCase.future('09:15-11:30;13:00-15:15','');
            actual = testCase.Connection.intradaybar(f, ...
                '2024-06-03','2024-06-03',15,'trade');
            expected = [datenum('2024-06-03 14:45','yyyy-mm-dd HH:MM'),1,11,-1,1.5; ...
                datenum('2024-06-03 15:00','yyyy-mm-dd HH:MM'),2,13,-3,3.5];
            testCase.verifyEqual(actual,expected,'AbsTol',1e-10);
        end

        function regroupingDoesNotShiftAgain(testCase)
            testCase.setBars({'2024-06-03 09:31';'2024-06-03 09:35'; ...
                '2024-06-03 09:36'});
            oneMinute = testCase.Connection.intradaybar('510300', ...
                '2024-06-03','2024-06-03',1,'trade');
            actual = timeseries_compress(oneMinute,'Frequency','5m', ...
                'TradingHours','09:30-11:30;13:00-15:00','TradingBreak','');
            direct = testCase.Connection.intradaybar('510300', ...
                '2024-06-03','2024-06-03',5,'trade');
            testCase.verifyEqual(actual,direct,'AbsTol',1e-10);
            testCase.verifyEqual(actual(:,1),datenum({ ...
                '2024-06-03 09:30';'2024-06-03 09:35'}, ...
                'yyyy-mm-dd HH:MM'),'AbsTol',1e-10);
        end

        function futuresBreakAndSparseGaps(testCase)
            raw = testCase.setBars({'2024-06-03 10:15';'2024-06-03 10:16'; ...
                '2024-06-03 10:30';'2024-06-03 10:31';'2024-06-03 10:34'});
            f = testCase.future('09:00-11:30;13:00-15:00','10:15-10:30');
            actual = testCase.Connection.intradaybar(f, ...
                '2024-06-03','2024-06-03',1,'trade');
            testCase.verifyEqual(actual(:,1),datenum({ ...
                '2024-06-03 10:14';'2024-06-03 10:30';'2024-06-03 10:33'}, ...
                'yyyy-mm-dd HH:MM'),'AbsTol',1e-10);
            testCase.verifyEqual(actual(:,2:5),raw([1,4,5],2:5),'AbsTol',0);
        end

        function midnightRollsIntoPreviousDate(testCase)
            raw = testCase.setBars({'2024-06-03 23:59';'2024-06-04 00:00'});
            f = testCase.future('09:00-11:30;13:00-15:00;21:00-01:00','10:15-10:30');
            actual = testCase.Connection.intradaybar(f, ...
                '2024-06-03','2024-06-03',1,'trade');
            testCase.verifyEqual(actual(:,1),datenum({ ...
                '2024-06-03 23:58';'2024-06-03 23:59'}, ...
                'yyyy-mm-dd HH:MM'),'AbsTol',1e-10);
            testCase.verifyEqual(actual(:,2:5),raw(:,2:5),'AbsTol',0);
        end

        function overnightSessionClose(testCase)
            raw = testCase.setBars({'2024-06-04 00:01';'2024-06-04 01:00'});
            f = testCase.future('09:00-11:30;13:00-15:00;21:00-01:00','10:15-10:30');
            actual = testCase.Connection.intradaybar(f, ...
                '2024-06-04','2024-06-04',1,'trade');
            testCase.verifyEqual(actual(:,1),datenum({ ...
                '2024-06-04 00:00';'2024-06-04 00:59'}, ...
                'yyyy-mm-dd HH:MM'),'AbsTol',1e-10);
            testCase.verifyEqual(actual(:,2:5),raw(:,2:5),'AbsTol',0);
        end

        function multipleStockDatesShiftOnce(testCase)
            raw = testCase.setBars({'2024-06-03 09:31';'2024-06-04 09:31'});
            actual = testCase.Connection.intradaybar('510300', ...
                '2024-06-03','2024-06-04',1,'trade');
            testCase.verifyEqual(actual(:,1),datenum({ ...
                '2024-06-03 09:30';'2024-06-04 09:30'}, ...
                'yyyy-mm-dd HH:MM'),'AbsTol',1e-10);
            testCase.verifyEqual(actual(:,2:5),raw(:,2:5),'AbsTol',0);
        end

        function weekendFuturesFallback(testCase)
            raw = testCase.setBars({'2024-06-08 00:01';'2024-06-08 01:00'});
            f = testCase.future('09:00-11:30;13:00-15:00;21:00-01:00','10:15-10:30');
            actual = testCase.Connection.intradaybar(f, ...
                '2024-06-08','2024-06-09',1,'trade');
            testCase.verifyEqual(actual(:,1),datenum({ ...
                '2024-06-08 00:00';'2024-06-08 00:59'}, ...
                'yyyy-mm-dd HH:MM'),'AbsTol',1e-10);
            testCase.verifyEqual(actual(:,2:5),raw(:,2:5),'AbsTol',0);
        end

        function weekendStockFallback(testCase)
            raw = testCase.setBars({'2024-06-08 09:31';'2024-06-08 15:00'});
            actual = testCase.Connection.intradaybar('510300', ...
                '2024-06-08','2024-06-09',1,'trade');
            testCase.verifyEqual(actual(:,1),datenum({ ...
                '2024-06-08 09:30';'2024-06-08 14:59'}, ...
                'yyyy-mm-dd HH:MM'),'AbsTol',1e-10);
            testCase.verifyEqual(actual(:,2:5),raw(:,2:5),'AbsTol',0);
        end

        function emptyResponse(testCase)
            testCase.setBars(cell(0,1));
            actual = testCase.Connection.intradaybar('510300', ...
                '2024-06-03','2024-06-03',15,'trade');
            testCase.verifyEmpty(actual);
        end

        function explicitOneMinuteSource(testCase)
            global thsIntradayTestCalls
            testCase.setBars({'2024-06-03 09:31'});
            testCase.Connection.intradaybar('510300', ...
                '2024-06-03','2024-06-03',15,'trade');
            testCase.verifyEqual(thsIntradayTestCalls{1}{3}, ...
                'Interval:1,Fill:Original');
        end
    end

    methods (Static, Access = private)
        function clearFixtureData
            clear global thsIntradayTestData thsIntradayTestCalls
        end

        function raw = setBars(labels)
            global thsIntradayTestData
            n = numel(labels);
            values = (1:n)';
            thsIntradayTestData = table(labels,values,values+10,-values,values+0.5, ...
                'VariableNames',{'time','open','high','low','close'});
            raw = [datenum(labels,'yyyy-mm-dd HH:MM'),values,values+10,-values,values+0.5];
        end

        function f = future(hours,breaks)
            f = cFutures;
            f.code_wind = 'TEST.CFE';
            f.trading_hours = hours;
            f.trading_break = breaks;
        end
    end
end
