function data_cube = get_FLIM_cube( session, image, sizet , modulo, ZCT )



    % sizet  here is the size of the relative-time dimension(t)
    % ie the number of time-points/length(delays)
     %
    data_cube = [];
    %
    if ~strcmp(modulo,'ModuloAlongC') && ~strcmp(modulo,'ModuloAlongT') && ~strcmp(modulo,'ModuloAlongZ')
        [ST,I] = dbstack('-completenames');
        errordlg(['No acceptable ModuloAlong* in the function ' ST.name]);
        return;
    end;    
    
    
    pixelsList = image.copyPixels();    
    pixels = pixelsList.get(0);
    %
    sizeX = pixels.getSizeX().getValue();
    sizeY = pixels.getSizeY().getValue();
    %sizeC = pixels.getSizeC().getValue();
    %sizeT = pixels.getSizeT().getValue();
    %sizeZ = pixels.getSizeZ().getValue();
    %
    pixelsId = pixels.getId().getValue();
   
    store = session.createRawPixelsStore(); 
    store.setPixelsId(pixelsId, false);   
    
    % convert to java/c++ numbering from 0
    Z  = ZCT(1)-1;
    C = ZCT(2)-1;
    T = ZCT(3)-1;
    
    data_cube = zeros(sizet,1,sizeX,sizeY,1);
    
    w = waitbar(0, 'Loading FLIMage....');
    
    switch modulo
        case 'ModuloAlongZ'
            tt = Z .* sizet;
            for t = 1:sizet
                rawPlane = store.getPlane(tt , C, T ); 
                tt = tt + 1;
                plane = toMatrix(rawPlane, pixels); 
                data_cube(t,1,:,:,1) = plane';
                waitbar((t/sizet),w);
                drawnow;
            end
            
        case 'ModuloAlongC' 
            tt = C .* sizet;
            for t = 1:sizet
                rawPlane = store.getPlane(Z , tt, T ); 
                tt = tt + 1;
                plane = toMatrix(rawPlane, pixels); 
                data_cube(t,1,:,:,1) = plane';
                waitbar((t/sizet),w);
                drawnow;
            end
            
        case 'ModuloAlongT' 
            tt = T .* sizet;
            for t = 1:sizet
                rawPlane = store.getPlane(Z , C, tt); 
                tt = tt + 1;
                plane = toMatrix(rawPlane, pixels); 
                data_cube(t,1,:,:,1) = plane';
                waitbar((t/sizet),w);
                drawnow;
            end
            
    end
    
    

    delete(w);
    drawnow;
    
    store.close();

end

