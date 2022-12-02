function isc=calc_ISC(data_dir,data_mat,AVGSmat,condName,subjs)

corrmatName= [condName '_corrMAT'];
isc=nan(size(data_mat,1),size(data_mat,3));

    for s=1:size(AVGSmat,1)
        for v=1:size(AVGSmat,3)
            subData=squeeze(data_mat(s,:,v));
            avgForCorr = squeeze(AVGSmat(s,:,v));
            %%just for testing
            %             avgForCorr=subData;
            %             avgForCorr= circshift(avgForCorr,5);
            
            isc(s,v) = corr(subData',avgForCorr','rows','complete');
            if isnan(isc(s,v))
%                disp(['isc subj ' num2str(s) 'in voxel ' num2str(v) 'is nan'])
            end
        end
    end
    
    if ~contains(condName, 'shuf')
    save(fullfile(data_dir,[corrmatName '.mat']),'isc','subjs','-v7.3')
    end
end