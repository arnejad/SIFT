function [PoIs, FinalDescs] = sift(orgImg)
% SIFT function implements of the paper Distinctive Image Features from
% Scale-Invariant Keypoints by David Lowe
%
% input:     An gray-scale image in fomrat of double scaled between 0-to-1
% output:    Keypoints locations, and descriptor
%
% Ref: D.G. Lowe, "Distinctive Image Features from Scale-Invariant Keypoints",
%   International Journal of Computer Vision, 2004
%
% This code has been developed for educational purposes at IASBS
%% INITIALIZATIONS
NUM_OF_OCTAVES = 3;
SIGMA = 1.6;
K = sqrt(2);
GUASS_FILTER_SIZE = 21;
NUM_OF_TRIPLES = 3; %TODO: change back to 5
THRESHOLD = 0.03;   %proposed value by Lowe in page 11 of the paper
R = 10;             %proposed value by Lowe in page 12 of the paper
PORadius = 9;       %the radius of the patch for prominent orientation hist
DescRadius = 7.5;   %the radius of the patch around keypoint for descriptor computation
%% KEYPOINTS DETECTION & DESCRIPTION

%double the size of the input image
I = imresize(orgImg,2);   

PoIs = [];          %initialization of the found Points-of-Interest
FinalDescs = [];    %initialization of the descriptors

% Computing DoGs of each octave
for o=1:NUM_OF_OCTAVES %for each octave

    [currH, currW] = size(I);
    
    % compute the gaussians
    Gausses = zeros(currH, currW,(NUM_OF_TRIPLES+3));
    counter=1;
    for i = 1:NUM_OF_TRIPLES+3
        % determine the gaussian sigma
        gaussSigma = (K*(2^(o-1)))*(2^(1/NUM_OF_TRIPLES))^(i-2);
        
        % make smooth gaussian layers
        Gausses(:,:,counter) = imfilter(I, fspecial('gaussian',GUASS_FILTER_SIZE,gaussSigma), 'symmetric');
        counter = counter+1;
    end
    
    % compute DoGs
    DoGs= zeros(currH, currW,NUM_OF_TRIPLES+2);
    for i=1:NUM_OF_TRIPLES+2
        DoGs(:,:,i) = Gausses(:,:,i+1) - Gausses(:,:,i);
    end
    
    
    % Find the interest-points and their Orientation hist
    for z=2:(NUM_OF_TRIPLES+1)  %for each triple DoG
        
        %compute the magnitude and the orientation of scale z
        [M, O] = imgradient(Gausses(:,:,z));
        
        % for each pixel in the middle DoG matrix
        for y=2:(currH-1)
            for x=2:(currW-1)
                %extract the surrounding 3-by-3-by-3 cube
                cube = DoGs(y-1:y+1, x-1:x+1, z-1:z+1);
                
                % if the center pixel has an extrema value then it is a
                %   potential point-of-interest
                if (cube(2,2,2) == max(max(max(cube)))) || (cube(2,2,2) == min(min(min(cube))))   
                    
                    % thresholding the keypoints based on their intensity contrast
                    if abs(cube(2,2,2)) < THRESHOLD
                        
                        %Thresholding based on Harris/Hessian method
                        D_xx =  cube(1,2,2)+cube(3,2,2)-(2*cube(2,2,2));
                        D_yy =  cube(2,1,2)+cube(2,3,2)-(2*cube(2,2,2));
                        D_xy =  cube(1,1,2)+cube(3,3,2)-2*(cube(1,3,2)+cube(3,1,2));
                        
                        %computer trace and determinant
                        tr = D_xx + D_yy;
                        det = D_xx * D_yy - D_xy * D_xy;
                        curv = (tr^2)/det;
                        
                        %thresholding the points based on the ratio of 
                        %   principal curvatures formula
                        if curv > (R+1)^2/det
                            
                            % weighted magnitude
                            if((y-PORadius)<=0); lowY = 1; else lowY=y-PORadius;end
                            if((y+PORadius)>currH); highY = currH; else highY=y+PORadius; end
                            if((x-PORadius)<=0); lowX = 1;else lowX=x-PORadius;end
                            if((x+PORadius)>currW); highX = currW;else highX=x+PORadius; end
                            
                            weights = fspecial('gaussian',[highY-lowY+1, highX-lowX+1], 1.5);
                            wSubM = M(lowY:highY, lowX:highX) .* weights;
                            subO = O(lowY:highY, lowX:highX);

                            %build the histogram
                            oHist = zeros(1,36);
                            for i=1:(highY-lowY+1)
                                for j=1:(highX-lowX+1)
                                    if subO(i,j)<0;subO(i,j)=subO(i,j)+360;end
                                    oHist(floor(subO(i,j)/10)+1) = oHist(floor(subO(i,j)/10)+1) + wSubM(i,j);
                                end
                            end
                            
                            %compute the final orientation based on the max
                            %of the hist and the 80% rule
                            oHist(oHist<0.8*max(oHist))=0;
                            
                            %% compute the descriptor
                            
                            %compute the upper and bottom bounds of window
                            if(floor(y-DescRadius)<=0); lowY = 1; else lowY=floor(y-DescRadius);end
                            if(floor(y+DescRadius)>currH); highY = currH; else highY=floor(y+DescRadius); end
                            if(floor(x-DescRadius)<=0); lowX = 1;else lowX=floor(x-DescRadius);end
                            if(floor(x+DescRadius)>currW); highX = currW;else highX=floor(x+DescRadius); end
                            
                            % extracting the surrounding 16-by-16 window
                            % Gaussian weighting function with ? equal to 
                            %  one half the width of the descriptor window 
                            weights = fspecial('gaussian',[highY-lowY+1, highX-lowX+1], 8);
                            wsubM = M(lowY:highY, lowX:highX) .* weights;
                            subO = O(lowY:highY, lowX:highX);
                            
                            % each 4-by-4 section hit of orientations
                            patchesDescs= zeros(4,4,8);  
                            for i=1:(highY-lowY+1)
                                for j=1:(highX-lowX+1)
                                    if subO(i,j)<0;subO(i,j)=subO(i,j)+360;end
                                    patchesDescs(ceil(j/4), ceil(i/4),floor(subO(i,j)/45)+1) =...
                                        patchesDescs(ceil(j/4), ceil(i/4),floor(subO(i,j)/45)+1)+ wSubM(i,j);
                                end
                            end
                            
                            %concatinate hists of sections to obtain a vector of length 128
                            desc = reshape(permute(patchesDescs,[3,2,1]),[1,128]);
                            
                            % feature vector modi?cation (page 16 of ref.)
                            desc = normr(desc);
                            desc(desc > 0.2) = 0.2; % threshold the maximum value as 0.2
                            desc = normr(desc);
                            
                            % keep the descs and keypoint attributes in the
                            % final output
                            FinalDescs = [FinalDescs; desc];
                            PoIs = [PoIs; [y, x, oHist]];
                        end
                        
                    end
                end
            end
        end
    end
    
    %resize the image I for the next iteration
    I = imresize(I,0.5); % down-sampling the imag
end

end