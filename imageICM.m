% Image Denoising using Iterated Conditional Modes (ICM)
%

% Parameters
levels = 256;
iterations = 2;

% Read input image
inputImg = imread('input.png');

% Get image size
[rows,cols] = size(inputImg);

% Convert to int32
inputImg = int32(inputImg);

% Compute pixel-based matching cost (data cost)
dataCost = zeros(rows,cols,levels,'int32');
for d = 0:levels-1
    dataCost(:,:,d+1) = abs(inputImg-d);
end

% Initialize the output
[cost,index] = min(dataCost,[],3);
output = int32(index-1);

figure
d = int32(permute(0:levels-1,[1 3 2]));

% Start iterations
for it = 1:iterations

    % Compute local energy
    localEnergy = dataCost + ...
        abs(circshift(output,-1,1)-d) + abs(circshift(output,-1,2)-d) + ...
        abs(circshift(output,1,1)-d) + abs(circshift(output,1,2)-d);

    % Create output image
    [cost,index] = min(localEnergy,[],3);
    output = int32(index-1);
    outputImg = uint8(output);
    
    % Compute total energy
    [row,col] = ndgrid(1:size(index,1),1:size(index,2));
    linInd = sub2ind(size(dataCost),row,col,index);
    dataEnergy = sum(sum(dataCost(linInd)));
    smoothnessEnergyHorizontal = sum(sum(abs(diff(output,1,2))));
    smoothnessEnergyVertical = sum(sum(abs(diff(output,1,1))));
    energy = dataEnergy+smoothnessEnergyHorizontal+smoothnessEnergyVertical;

    % Show output image
    imshow(outputImg)
    
    % Show energy and iteration
    fprintf('iteration: %d/%d, energy: %d\n',it,iterations,energy)
end

% Save output image
imwrite(outputImg,'outputICM.png')
