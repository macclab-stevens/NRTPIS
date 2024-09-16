function simulationLogs = findReTransmissions(simulationLogs)
    simTable = simulationLogs{1, 1}.SchedulingAssignmentLogs();
    numReTxDL =  [0 0 0 0];
    numReTxUL = [0 0 0 0];
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
    simulationLogs{2, 1} = "numReTxDL";
    simulationLogs{3, 1} = "numReTxUL";
    simulationLogs{2, 2} = numReTxDL
    simulationLogs{3, 2} = numReTxUL
end 