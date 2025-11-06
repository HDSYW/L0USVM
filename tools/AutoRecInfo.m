function [Para,fid] = AutoRecInfo(Para)
%% -----------------------------------------
ModelName = Para.ModelName;     seed = Para.seed;
ktype = Para.kpar.ktype;        DatStd = Para.DatStd;
kp1 = Para.kp1;                 kp2 = Para.kp2;
M1 = Para.M1;                   M2 = Para.M2; 
M3 = Para.M3;                   M4 = Para.M4;
UndSpl = Para.UndSpl;           usr = Para.usr;
% ------- Folder Path ----------
Data_Path = Para.dPth;  spritv_index = strfind(Data_Path,'/');
DataClass = Data_Path(spritv_index(2)+1:spritv_index(3)-1);
DataName =  Data_Path(spritv_index(3)+1:end-4);

FolderPath = sprintf('./03-ExpResults/%s/%s/%s/%s/%s/rng%d',Para.run_name,ModelName,ktype,DataClass,DataName,seed);
if ~exist(FolderPath,'dir'),mkdir(FolderPath);end
Para.FolderPath = FolderPath;

% ------- Time && Note ---------
Time = datestr(now,'yyyy-mm-dd_HH-MM-SS');    Para.Time = Time;
Note = ['rng',num2str(seed)];

% -- The txt file of results --
TxtFilePath = sprintf('%s/%s_%s_%s.txt',...
    FolderPath, Note, ModelName, Time);

fid = fopen(TxtFilePath, 'wt');

for ii3 = "Record info into txt file"
    fprintf(fid,'___________ >>>> Experiment Information Recording <<<< ___________ \n');
    fprintf(fid,'Launch Time: %s \n', Time);
    fprintf(fid,'Random Seed: rng(%d) -----> [Update seed is %s]\n', seed, Para.Update_seed);
    fprintf(fid,'Model Name: %s \n', ModelName);
    fprintf(fid,'Model Hyper-Parameters: \n');
    fprintf(fid,'  p1(#%d) = [%s] \n', length(M1), num2str(M1,'%10.2e, '));
    fprintf(fid,'  p2(#%d) = [%s] \n', length(M2), num2str(M2,'%10.2e, '));
    fprintf(fid,'  p3(#%d) = [%s] \n', length(M3), num2str(M3,'%10.2e, '));
    fprintf(fid,'  p4(#%d) = [%s] \n', length(M4), num2str(M4,'%10.2e, '));
    fprintf(fid,'Kernel Type: %s \n', ktype);
    if Para.UNI == 1,fprintf(fid,'Universum Type: %s \n', Para.utype);end
    fprintf(fid,'Kernel Hyper-Parameters: \n');
    fprintf(fid,'  kp1(#%d) = [%s] \n', length(kp1), num2str(kp1,'%10.2e, '));
    fprintf(fid,'  kp2(#%d) = [%s] \n', length(kp2), num2str(kp2,'%10.2e, '));
    fprintf(fid,'Hyper-Parameter Groups Number: %d, ', ...
        length(M1)*length(M2)*length(M3)*length(M4)*length(kp1)*length(kp2));
    fprintf(fid,'UnderSampling: %s, Ratio = 1/%d \n', UndSpl, usr);
    fprintf(fid,'Data Standardization: %s \n', DatStd);
    fprintf(fid,'Data Separation: %s (Test=%.1f) \n', Para.DS, Para.tstp);
    fprintf(fid,'Major Indicator: %s, Indicator Repeat: %d×CV \n', Para.indctmjr, Para.indctRpt);
    fprintf(fid,'Minor Indicator: %s, OptParaLogi: %s \n', Para.indctmnr, Para.OPLogi);
    fprintf(fid,'CV-MethodSetting: %s(cvp1=%d,cvp2=%g), BaseOnClass: %s, MiniElementNum: %s \n', ...
        Para.CVM, Para.cvp1, Para.cvp2, Para.BOC, Para.MEN);
end
end