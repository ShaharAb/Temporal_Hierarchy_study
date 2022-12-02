function create_nul_dist_cakeData(params, cond_data, condName)
%ONLY for voxels data
% condName='01_intact';
out_dir_name =['shuf_' condName];

out_shuf_dataDir=fullfile(params.group_WHB_res_dir,out_dir_name);
if ~exist(out_shuf_dataDir)
    mkdir(out_shuf_dataDir)
end
Nshuf=1000;
realdataMat=cond_data;
analyze_ISC_parfor_srvr01(params,out_shuf_dataDir,condName,realdataMat,Nshuf)
% analyze_ISC_parfor_srvr02(params,out_shuf_dataDir,condName,RealdataMat,Nshuf)
% analyze_ISC_parfor_srvr02(params,out_shuf_dataDir,condName,RealdataMat,Nshuf)
end