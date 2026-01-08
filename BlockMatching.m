levels = 256;
windowSize = 3;

% Read noisy image
inputImg = imread('input.png');
%inputImg = rgb2gray(inputImg);

% Get image size
[rows,cols] = size(inputImg);

% Convert from uint8 to double
inputImg = double(inputImg);

% Compute initial matching cost
C0 = zeros(rows,cols,levels);
for d = 0:levels-1
	C0(:,:,d+1) = abs(inputImg-d);
end

% Compute aggregated matching cost
C1 = imboxfilt3(C0,[windowSize windowSize 1]);

% Create denoised image
[~,ind] = min(C1,[],3);
outputImg = uint8(ind-1);

% Show denoised image
figure; imshow(outputImg)

% Save denoised image
imwrite(outputImg,'output.png')
