function simulationLogs = findReTransmissions(simulationLogs,simParameters)
    simTable = simulationLogs{1, 1}.SchedulingAssignmentLogs();
    numReTxDL =  zeros(simParameters.NumUEs,1);
    numReTxUL = zeros(simParameters.NumUEs,1);
    avgMCS = zeros(simParameters.NumUEs,1);
    [rows, cols] = size(simTable);
    fprintf("Rows:%d Cols:%d\n",rows,cols);
    for i = 2:rows-1
        
        rntiCell = simTable(i,1);
        rnti = rntiCell{1};
    
        TxType = simTable(i,13);
        GrantDir = simTable(i,4);
        % TxType{1}
        % GrantDir{1}
        if string(TxType{1}) == 'reTx' & string(GrantDir{1})=='DL'
            numReTxDL(rnti) = numReTxDL(rnti)+ 1;
        end
        if string(TxType{1}) == 'reTx' & string(GrantDir{1})=='UL'
            numReTxUL(rnti) = numReTxUL(rnti)+ 1;
        end
    end

    %find Avg MCS
    a = cell2mat(simTable(2:end,1))
    unique(a)

    %add analysis back to logs
    simulationLogs{end+1, 1} = "numReTxDL";
    simulationLogs{end, 2} = numReTxDL;

    simulationLogs{end+1, 1} = "numReTxUL";
    simulationLogs{end, 2} = numReTxUL;
    simulationLogs{end+1,1} = 'avgMcs';
    simulationLogs{end,2} = avgMCS;

    disp(simulationLogs);
end 