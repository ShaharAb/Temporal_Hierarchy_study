function [linearidx, locations]  = getLocationsFromMaskNii(mask)
% print what we are doing 
fprintf('matrix size %d by %d by %d, %d voxels masked\n',...
    size(mask,1),size(mask,2),size(mask,3), sum(mask(:)));
cnt = 1; 
for i = 1:size(mask,1)
    for j = 1:size(mask,2)
        for k = 1:size(mask,3)
            if mask(i,j,k)
                linearidx(cnt) = sub2ind(size(mask),i,j,k);
                locations(cnt,:) = [i,j,k];
                cnt = cnt +1; 
            end
        end
    end
end
end
