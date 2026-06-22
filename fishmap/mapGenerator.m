function mapGenerator(ms)
    load("cmap.mat", "cmap")
    load("spots.mat", "spots")
    markerData = readtable("MapMarker.csv");

    % Read folder name as zone name
    zonename = regexprep(pwd, regexprep(matlab.project.rootProject().RootFolder, '\', '\\\')+"\\fishmap\\", "");
    
    %% tuneables
    intensity = 1;
    intensity2 = 0.5;
    lineSpacing = 75;
    lineHeight = 50;
    
    maxCrop = 1024;
    minCrop = 512;
    maxCropFactor = 12.5;
    minCropFactor = 25;
    tinyRadius = minCrop/minCropFactor/sqrt(pi)*7;
    % b = (log(minCropFactor) - log(maxCropFactor))/(minCrop/minCropFactor - maxCrop/maxCropFactor);
    % a = minCropFactor/exp(b*minCrop/minCropFactor);
    % minSize = @(A) min(max(sqrt(A)*a*exp(b*sqrt(A)), minCrop), maxCrop);
    a = (maxCrop - minCrop)/(sqrt(maxCrop/maxCropFactor) - sqrt(minCrop/minCropFactor));
    b = minCrop - a*sqrt(minCrop/minCropFactor);
    minSize = @(A) min(max(a*sqrt(sqrt(A)) + b, minCrop), maxCrop);
    cropSizeFactor = @(Dx, Dy) 1+0.5*exp(-abs(log(Dx/Dy)));
    
    % figure; imagesc(permute(cmap, [1 3 2]))
    
    %% Initialize
    cmap = cmap/255;
    cmap = min((cmap - 0.5*(1-intensity)*[202 182 112]/255)/(intensity), 1);
    cmapSpot = permute([0 0.3835 0.5824] - (1-intensity2)*[202 182 112]/255, [1 3 2])/intensity2;

    % Get list of layer images
    path = zonename+"\";
    files = dir(path);
    files = files([3 end-1 (end-2):-1:4]);
    
    % Interpret first layer as background
    zoneImage = imread(path+files(1).name);
    defaultImage = imread("default_00.png");
    
    %% Do for each subsequent layer
    rgbLayers = zeros([size(zoneImage) length(files)-1]);
    alphaLayers = zeros([size(zoneImage, [1 2]) 1 length(files)-1]);
    spot = strings(length(files)-1, 1);

    for iI = 1:(length(files)-1)
        % Recover layer name
        spot(iI) = regexp(files(iI+1).name, "C1,(.*),visible", "tokens");
        spot(iI) = regexprep(spot(iI), "%0026", "&");
        spot(iI) = regexprep(spot(iI), "%0027", "'");
        spot(iI) = regexprep(spot(iI), "%0028", "(");
        spot(iI) = regexprep(spot(iI), "%0029", ")");
        spot(iI) = regexprep(spot(iI), "%002E", ".");
    end

    for iI = 1:(length(files)-1)
        if iI == 1
            % Create marker overlay
            markerRGB = zeros(size(zoneImage));
            markerAlpha = zeros([size(zoneImage, [1 2]) 1]);
            
            iSpot = find(spots.LayerName == spot(2), 1, 'first');

            if isempty(iSpot)
                error("No matching spot name to " + spot(2));
            else
                iMk = spots.MapMarkerRange(iSpot);
                zoneMarkers = markerData(floor(markerData.x_) == iMk & any(markerData.Icon == [60414 60430 60453 60456 63907], 2), :);
                for iR = 1:height(zoneMarkers)
                    markerRGBTemp = zeros(size(zoneImage));
                    markerAlphaTemp = zeros([size(zoneImage, [1 2]) 1]);

                    markerLocation = any((1:2048) == (zoneMarkers.X(iR)+(-31:32))', 1) & ...
                        any((1:2048)' == (zoneMarkers.Y(iR)+(-31:32)), 2);
                    [markerRGBTemp(repmat(markerLocation, 1, 1, 3)), ~, markerAlphaTemp(markerLocation)] = imread("i"+zoneMarkers.Icon(iR)+".png");

                    markerRGB = markerRGB.*(1-markerAlphaTemp/255) + markerRGBTemp.*markerAlphaTemp/255/255;
                    markerAlpha = markerAlpha + markerAlphaTemp/255 - markerAlpha.*markerAlphaTemp/255;
                end

                % Add zone markers
                zoneImage = zoneImage.*uint8(1-markerAlpha) + uint8(255*markerRGB.*markerAlpha);
                bgImage = double(zoneImage)/255;

            end
        end

        % Read layer into transparency
        [~, ~, alphaLayers(:, :, :, iI)] = imread(path+files(iI+1).name);
        if length(unique(alphaLayers(:, :, :, iI))) > 2
            "loose transperence in layer "+files(iI+1).name+" of "+zonename
        end

        % Make spot maps
        if iI > 1 && (~isfield(ms, "makeAlts") || ms.makeAlts)
            spotIndex = find(spots.LayerName == spot(iI));

            if isempty(spotIndex)
                error("No matching spot name to " + spot(iI));
            else
                [y, x] = find(alphaLayers(:, :, :, iI) > 0);
                if ~isempty(x)
                    imSize = max(range(x), range(y))*cropSizeFactor(range(x), range(y));
                end
                spotAlpha = imgaussfilt(double(alphaLayers(:, :, :, iI))/255, 1);
                spotIntensity = intensity2 .* spotAlpha;
                spotAlpha2 = spotAlpha;
                spotAlpha2(spotAlpha == 0) = 1;
                spotImage = (bgImage.*(1-spotIntensity) + cmapSpot.*spotAlpha.*spotIntensity).*spotAlpha2;

                if ~isempty(x)
                    xSpotMid = (min(x)+max(x))/2;
                    ySpotMid = (min(y)+max(y))/2;
                    xSpotMin = max(0, xSpotMid-imSize/2);
                    xSpotMax = min(2048, xSpotMid+imSize/2);
                    ySpotMin = max(0, ySpotMid-imSize/2);
                    ySpotMax = min(2048, ySpotMid+imSize/2);

                    halfMin = minSize(length(x))/2;
                    xSafeMid = max(halfMin, min(2048-halfMin, xSpotMid));
                    ySafeMid = max(halfMin, min(2048-halfMin, ySpotMid));
                    xSafeMin = xSafeMid-halfMin;
                    xSafeMax = xSafeMid+halfMin;
                    ySafeMin = ySafeMid-halfMin;
                    ySafeMax = ySafeMid+halfMin;

                    xList = round([xSpotMin xSpotMax xSafeMin xSafeMax]);
                    yList = round([ySpotMin ySpotMax ySafeMin ySafeMax]);
                    imSize = max(floor(minSize(length(x))), max(range(xList), range(yList)));
                    xMid = max(0+ceil(imSize/2), min(2048-ceil(imSize/2), (min(xList)+max(xList))/2));
                    yMid = max(0+ceil(imSize/2), min(2048-ceil(imSize/2), (min(yList)+max(yList))/2));
                    
                    if imSize == minCrop
                        spotImage = insertShape(spotImage, "circle", [xSpotMid, ySpotMid, tinyRadius], "LineWidth", 20, "ShapeColor", 'k');
                        spotImage = insertShape(spotImage, "circle", [xSpotMid, ySpotMid, tinyRadius], "LineWidth", 10, "ShapeColor", 'w');
                    end

                    % % Add spot marker
                    % if spots.SpotX(spotIndex(1)) > 0
                    %     spotRGB = zeros(size(zoneImage));
                    %     spotAlpha = zeros([size(zoneImage, [1 2]) 1]);
                    %     spotLocation = any((1:2048) == (spots.SpotX(spotIndex(1))+(-31:32))', 1) & ...
                    %         any((1:2048)' == (spots.SpotY(spotIndex(1))+(-31:32)), 2);
                    %     if contains(spot(iI), "(Lv")
                    %         [spotRGB(repmat(spotLocation, 1, 1, 3)), ~, spotAlpha(spotLocation)] = imread("i60466.png");
                    %     else
                    %         [spotRGB(repmat(spotLocation, 1, 1, 3)), ~, spotAlpha(spotLocation)] = imread("i60465.png");
                    %     end
                    %     spotImage = spotImage.*(1-spotAlpha/255) + spotRGB.*spotAlpha/255/255;
                    % end
                    % 
                    % % Add zone markers
                    % spotImage = spotImage.*(1-markerAlpha) + markerRGB.*markerAlpha;

                    spotImage = imcrop(spotImage, [xMid-imSize/2+0.5 yMid-imSize/2+0.5 imSize-1 imSize-1]);

                    if size(spotImage, 1) ~= size(spotImage, 2) || length(spotImage) ~= imSize
                        "your math is wrong"
                    end
                end

                for iSpot = spotIndex'
                    maskFileName = matlab.project.rootProject().RootFolder+"\spots\masks\map"+spots.MapID(iSpot)+"_spot"+spots.SpotID(iSpot)+"_mask.png";
                    mapFileName = matlab.project.rootProject().RootFolder+"\spots\maps\map"+spots.MapID(iSpot)+"_spot"+spots.SpotID(iSpot)+"_map.png";
                    
                    saveMask = true;
                    saveSpotMap = true;

                    if exist(maskFileName, "file")
                        prevMask = imread(maskFileName);
                        if all(prevMask == alphaLayers(:, :, :, iI), 'all')
                            saveMask = false;
                        end
                    end
                    if exist(mapFileName, "file")
                        prevSpotMap = imread(mapFileName);
                        if all(size(prevSpotMap) == size(spotImage)) && all(prevSpotMap == uint8(spotImage*255), 'all')
                            saveSpotMap = false;
                        end
                    end

                    if saveMask
                        imwrite(alphaLayers(:, :, :, iI), maskFileName);
                    end
                    if saveSpotMap
                        imwrite(spotImage, mapFileName);
                    end
                end
            end
        end
        if iI > 1 || ms.enable0
            alphaLayers(ms.legendY + (00:(lineHeight-1)) + lineSpacing*(ms.skip(iI)+iI-1), ms.legendX + (00:(lineHeight-1)), :, iI) = 255;
        end
        rgbLayers(:, :, 1, iI) = cmap(iI, 1)*(alphaLayers(:, :, :, iI) > 0);
        rgbLayers(:, :, 2, iI) = cmap(iI, 2)*(alphaLayers(:, :, :, iI) > 0);
        rgbLayers(:, :, 3, iI) = cmap(iI, 3)*(alphaLayers(:, :, :, iI) > 0);
        if ms.legendBox && (iI > 1 || ms.enable0)
            if iI < size(alphaLayers, 4)
                zoneImage(ms.legendY - 25 + (00:(lineSpacing+25-1)) + lineSpacing*(iI-1), ms.legendX - 25 + (00:(ms.legendW-1)), :) = defaultImage(ms.legendY - 25 + (00:(lineSpacing-1+25)) + lineSpacing*(iI-1), ms.legendX - 25 + (00:(ms.legendW-1)), :);
            else
                zoneImage(ms.legendY - 25 + (00:(lineHeight+50-1)) + lineSpacing*(iI-1), ms.legendX - 25 + (00:(ms.legendW-1)), :) = defaultImage(ms.legendY - 25 + (00:(lineHeight-1+50)) + lineSpacing*(iI-1), ms.legendX - 25 + (00:(ms.legendW-1)), :);
            end
        end
    end
    
    load("patterns.mat", "patterns")
    patterns(:, :, :, length(files):end) = [];
    
    intensity = intensity .* any(alphaLayers > 0, 4);
    finalImage = double(zoneImage);
    finalImage = (finalImage.*(1-intensity) + sum(patterns.*rgbLayers.*double(alphaLayers).*intensity, 4))/255;
    
    if ms.legendBox
        finalImage = insertShape(finalImage, "line", [ms.legendX+[-26 -26 -24+ms.legendW -24+ms.legendW -26]', ms.legendY+[-26 + lineSpacing*(1-ms.enable0), 26 + lineSpacing*(length(files)-2) + lineHeight, ...
            26 + lineSpacing*(length(files)-2) + lineHeight, -26 + lineSpacing*(1-ms.enable0), -26 + lineSpacing*(1-ms.enable0)]'], ...
            'LineWidth', 2, 'Color', [116 88 54]/255);
    end
    
    sumSpecial = 0;
    % http://xahlee.info/comp/unicode_circled_numbers.html
    for iF = (3 - ms.enable0):length(files)
        if iF-1 == ms.specialLayer
            sumSpecial = sumSpecial+1;
            finalImage = insertText(finalImage, [ms.legendX + 9 + 50, ms.legendY + 25 + lineSpacing*(ms.skip(iF-1)+iF-2)], ...
                sprintf("%s. %s", '@'+sumSpecial, spot(iF-1)), "FontSize", 53, ...
                "AnchorPoint", "LeftCenter", "BoxOpacity", 1*ms.highlight, "BoxColor", [202 182 112]/255);
        else
            finalImage = insertText(finalImage, [ms.legendX + 9 + 50, ms.legendY + 25 + lineSpacing*(ms.skip(iF-1)+iF-2)], ...
                sprintf("%.0f. %s", iF-2-sumSpecial, spot(iF-1)), "FontSize", 53, ...
                'AnchorPoint', 'LeftCenter', "BoxOpacity", 1*ms.highlight, "BoxColor", [202 182 112]/255);
        end
    end
    
    % finalImage = imresize(finalImage, 0.5);
    saveMap = true;

    if exist(zonename+".png", "file")
        prevMap = imread(zonename+".png");
        if all(size(prevMap) == size(finalImage)) && all(prevMap == uint8(finalImage*255), 'all')
            saveMap = false;
        end
    end

    if saveMap
        imwrite(finalImage, zonename+".png")
    end
end