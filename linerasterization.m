%
% Copyright 2017 Vienna University of Technology.
% Institute of Computer Graphics and Algorithms.
%

function linerasterization( mesh, framebuffer )
%LINERASTERIZATION iterates over all faces of mesh and draws lines between
%                  their vertices. 
%     mesh                  ... mesh object to rasterize
%     framebuffer           ... framebuffer

    for i=1:numel(mesh.faces)        
        for j=1:mesh.faces(i)
            v1 = mesh.getFace(i).getVertex(j);
            v2 = mesh.getFace(i).getVertex(mod(j, mesh.faces(i)) + 1);
            drawLine(framebuffer, v1, v2);
        end
    end
end

function drawLine( framebuffer, v1, v2 )
%DRAWLINE draws a line between v1 and v2 into the framebuffer using the DDA
%         algorithm.
%     framebuffer           ... framebuffer
%     v1                    ... vertex 1
%     v2                    ... vertex 2

    [x1, y1, z1] = v1.getScreenCoordinates();
    [x2, y2, z2] = v2.getScreenCoordinates();
    
    dx = abs(x2 - x1);
    dy = abs(y2 - y1);
    %dz = z2 - z1;
    %signX = 1;
    %signY = 1;
    c1 = v1.getColor();
    c2 = v2.getColor();
    
    %if x1 > x2; signX = -1; end
    %if y1 > y2; signY = -1; end
    
    if dy < dx
      m = dx / dy;
      for x=0:dx
          %framebuffer.setPixel(ceil(x1+x*signX), ceil(y1+x*m*signY), MeshVertex.mix(z1, z2, x/dx), MeshVertex.mix(c1, c2, x/dx))
      end
    else
      m = dx / dy;
      for y=0:dy
          %framebuffer.setPixel(ceil(x1+y*m*signX), ceil(y1+y*signY), MeshVertex.mix(z1, z2, y/dy), MeshVertex.mix(c1, c2, y/dy))
      end
    end
    
    t = max(dx, dy) + 1;
    vx = linspace(x1, x2, t);
    vy = linspace(y1, y2, t);
    vz = linspace(z1, z2, t);      
    vc = MeshVertex.mix(c1, c2, linspace(0, 1, t));
    framebuffer.setPixel(round(vx), round(vy), vz, vc);
    
end

