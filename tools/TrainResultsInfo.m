function TrainResultsInfo(Mod, Para, ModT)
    % CopyRigth : Junshan Yin       % LastUpdate : 2023.9.1
    % Svae results info 
    
    dPth = Para.dPth;
    index = strfind(dPth,'/');
    data_name = dPth(index(2)+1:index(3)-1);
    
    if Para.AutoRec == "ON"
        % |DataSet|Method|rng|AC|SpnR|p1|p2|p3|p4|
        FilePth = strcat('./03-ExpResults/',Para.run_name,'/ResultsInfo_', char(Mod), '-',data_name,'_', num2str(Para.m), 'x', num2str(Para.n), '.txt');
        fid = fopen(FilePth, 'a'); 
        fprintf(fid, '|%s|utype = %s|%s|%d|%.2f|%.2f|%.4f|%.4f|%.4f|%.4f|\n', ...
        string([num2str(Para.dat), '-', Para.datName]), string(Para.utype), Mod, Para.seed, ...
        Para.tAc, ModT.spsR, Para.p1, Para.p2, Para.p3, Para.p4);
        fclose(fid);
    end
end
