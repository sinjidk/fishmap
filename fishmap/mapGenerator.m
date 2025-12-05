function mapGenerator(ms)
    load("cmap.mat", "cmap")
    load("spots.mat", "spots")

    zonename = regexprep(pwd, regexprep(matlab.project.rootProject().RootFolder, '\', '\\\')+"\\fishmap\\", "");
    
    intensity = 1;
    intensity2 = 0.5;
    cmap = cmap/255;
    cmap = min((cmap - 0.5*(1-intensity)*[202 182 112]/255)/(intensity), 1);
    cmapSpot = permute([0 0.3835 0.5824] - (1-intensity2)*[202 182 112]/255, [1 3 2])/intensity2;
    lineSpacing = 75;
    lineHeight = 50;
    
    % figure; imagesc(permute(cmap, [1 3 2]))
    
    path = zonename+"\";
    files = dir(path);
    files = files([3 end-1 (end-2):-1:4]);
    
    bgImage = imread(path+files(1).name);
    bgImageClean = double(bgImage)/255;
    defaultImage = imread("default.jpg");
    rgbLayers = zeros([size(bgImage) length(files)-1]);
    alphaLayers = zeros([size(bgImage, [1 2]) 1 length(files)-1]);
    spot = strings(length(files)-1, 1);
    for iI = 1:(length(files)-1)
        spot(iI) = regexp(files(iI+1).name, "C1,(.*),visible", "tokens");
        spot(iI) = regexprep(spot(iI), "%0026", "&");
        spot(iI) = regexprep(spot(iI), "%0027", "'");
        spot(iI) = regexprep(spot(iI), "%0028", "(");
        spot(iI) = regexprep(spot(iI), "%0029", ")");
        spot(iI) = regexprep(spot(iI), "%002E", ".");
        [~, ~, alphaLayers(:, :, :, iI)] = imread(path+files(iI+1).name);
        if iI > 1
            spotIndex = spots.LayerName == spot(iI);
            if any(spotIndex)
                imwrite(alphaLayers(:, :, :, iI), matlab.project.rootProject().RootFolder+"\spots\map"+spots.MapID(spotIndex)+"_spot"+spots.SpotID(spotIndex)+"_mask.png");

                spotAlpha = imgaussfilt(double(alphaLayers(:, :, :, iI))/255, 1);
                spotIntensity = intensity2 .* spotAlpha;
                spotAlpha2 = spotAlpha;
                spotAlpha2(spotAlpha == 0) = 1;
                spotImage = (bgImageClean.*(1-spotIntensity) + cmapSpot.*spotAlpha.*spotIntensity).*spotAlpha2;
                imwrite(spotImage, matlab.project.rootProject().RootFolder+"\spots\map"+spots.MapID(spotIndex)+"_spot"+spots.SpotID(spotIndex)+"_map.png");
            else
                error("No matching spot name to " + spot(iI));
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
                bgImage(ms.legendY - 25 + (00:(lineSpacing+25-1)) + lineSpacing*(iI-1), ms.legendX - 25 + (00:(ms.legendW-1)), :) = defaultImage(ms.legendY - 25 + (00:(lineSpacing-1+25)) + lineSpacing*(iI-1), ms.legendX - 25 + (00:(ms.legendW-1)), :);
            else
                bgImage(ms.legendY - 25 + (00:(lineHeight+50-1)) + lineSpacing*(iI-1), ms.legendX - 25 + (00:(ms.legendW-1)), :) = defaultImage(ms.legendY - 25 + (00:(lineHeight-1+50)) + lineSpacing*(iI-1), ms.legendX - 25 + (00:(ms.legendW-1)), :);
            end
        end
    end
    
    load("patterns.mat")
    patterns(:, :, :, length(files):end) = [];
    
    intensity = intensity .* any(alphaLayers > 0, 4);
    finalImage = double(bgImage);
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
    
    imwrite(imresize(finalImage, 0.5), zonename+".png")
end