% Image Denoising using Block Matching
%

% Parameters
levels = 256;
windowSize = 3;

% Read input image
inputImg = imread('input.png');

% Get image size
[rows,cols] = size(inputImg);

% Convert from uint8 to double
inputImg = double(inputImg);

% Compute initial cost
C0 = zeros(rows,cols,levels);
for d = 0:levels-1
	C0(:,:,d+1) = abs(inputImg-d);
end

% Compute aggregated cost
C1 = imboxfilt3(C0,[windowSize windowSize 1]);

% Create output image
[cost,index] = min(C1,[],3);
outputImg = uint8(index-1);

% Show output image
figure; imshow(outputImg)

% Save output image
imwrite(outputImg,'outputBM.png')
