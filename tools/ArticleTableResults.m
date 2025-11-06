% Copyright: Junshan Yin
% LastUpdate: 2023.9.13

function ArticleTableResults(ModelName,Para,ModT)
    
    
    TableResults = './04-ArticleTableResults/';
    if exist(TableResults,'dir') == 0
       mkdir(TableResults);
    end
    
    TableResults = strcat(TableResults,strrep(char(Para.datName),'.',''),'_TableInfo.txt');
    fid = fopen(TableResults, 'a');
    fprintf(fid, '%.2f\t %.2f\t %0.8f \t %s\n',...
        Para.tAc, ModT.spsR, ModT.tr_time, ModelName);
    fclose(fid);

    

end