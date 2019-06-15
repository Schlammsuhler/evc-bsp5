%
% Copyright 2017 Vienna University of Technology.
% Institute of Computer Graphics and Algorithms.
%

% main file to start script

function[] = main(rasterization_mode, model)
%MAIN invokes the rasterization pipeline and finally shows the output image.
%       The output image is also saved as 'output.png'.
%     rasterization_mode    ... either 'fill' or 'line' to select how the
%                               model is rasterized
%     model                 ... name of the model file which should be
%                               rasterized. Must be a file name from the
%                               data folder, e.g. 'plane.ply'
    clc;
    clear workspace;
    close all;
    
    if(~ischar(rasterization_mode) || ~ischar(model)) 
        disp('Both input parameters must be strings. Strings in Matlab are written with single quotes.');
        return
    end
    
    if ~strcmp(rasterization_mode, 'line') && ~strcmp(rasterization_mode, 'fill')
        disp('Wrong rasterization mode. Please use "line" or "fill".');
        return
    end    
    
    if ~exist(['data/', model], 'file')
        disp('Model not found in data folder.');
        return
    end

    framebuffer = Framebuffer(600, 600); 
    mesh = loadTransformedModel(['data/', model], 1);
    
    rasterize(mesh, framebuffer, rasterization_mode);
    
    figure; imshow(framebuffer.image);
    imwrite(framebuffer.image, 'output.png');
end