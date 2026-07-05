% Image Denoising using Belief Propagation
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

% Compute smoothness cost
d = 0:levels-1;
smoothnessCost = abs(d-d.');
smoothnessCost = permute(int32(smoothnessCost),[3 4 1 2]);

% Initialize messages
msgFromUp = zeros(rows,cols,levels,'int32');
msgFromDown = zeros(rows,cols,levels,'int32');
msgFromRight = zeros(rows,cols,levels,'int32');
msgFromLeft = zeros(rows,cols,levels,'int32');

figure

% Start iterations
for it = 1:iterations

    % Create messages to up
    incomingMessages = dataCost + msgFromDown + msgFromRight + msgFromLeft;
    msgToUp = minSumConvolution(incomingMessages,smoothnessCost);

    % Create messages to down
    incomingMessages = dataCost + msgFromUp + msgFromRight + msgFromLeft;
    msgToDown = minSumConvolution(incomingMessages,smoothnessCost);

    % Create messages to right
    incomingMessages = dataCost + msgFromUp + msgFromDown + msgFromLeft;
    msgToRight = minSumConvolution(incomingMessages,smoothnessCost);

    % Create messages to left
    incomingMessages = dataCost + msgFromUp + msgFromDown + msgFromRight;
    msgToLeft = minSumConvolution(incomingMessages,smoothnessCost);

    % Normalize messages
    msgToUp = msgToUp - min(msgToUp,[],3);
    msgToDown = msgToDown - min(msgToDown,[],3);
    msgToRight = msgToRight - min(msgToRight,[],3);
    msgToLeft = msgToLeft - min(msgToLeft,[],3);

    % Send messages
    msgFromDown = circshift(msgToUp,-1,1);
    msgFromUp = circshift(msgToDown,1,1);
    msgFromLeft = circshift(msgToRight,1,2);
    msgFromRight = circshift(msgToLeft,-1,2);

    % Compute belief
    belief = dataCost + msgFromUp + msgFromDown + msgFromRight + msgFromLeft;

    % Create output image
    [cost,index] = min(belief,[],3);
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
imwrite(outputImg,'outputBP.png')

function output = minSumConvolution(incomingMessages,smoothnessCost)
    output = zeros(size(incomingMessages),'like',incomingMessages);
    levels = size(output,3);
    for i = 1:levels
        output(:,:,i) = min(incomingMessages + smoothnessCost(1,1,:,i),[],3);
    end
end
