function mapGenerator
    load("cmap.mat", "cmap")
    
    intensity = 1;
    cmap = cmap/255;
    cmap = min((cmap - 0.5*(1-intensity)*[202 182 112]/255)/(intensity), 1);
    lineSpacing = 75;
    lineHeight = 50;
    lineDelta = (lineSpacing - lineHeight)/2;
    
    % figure; imagesc(permute(cmap, [1 3 2]))
    
    path = zonename+"\"+zonename+"\";
    files = dir(path);
    files = files([3 end-1 (end-2):-1:4]);
    
    bgimage = imread(path+files(1).name);
    defaultimage = imread("default.jpg");
    rgbLayers = zeros([size(bgimage) length(files)-1]);
    alphaLayers = zeros([size(bgimage, [1 2]) 1 length(files)-1]);
    for iI = 1:size(alphaLayers, 4)
        [~, ~, alphaLayers(:, :, :, iI)] = imread(path+files(iI+1).name);
        if iI > 1 || enable0
            alphaLayers(legendY + (00:(lineHeight-1)) + lineSpacing*(skip(iI)+iI-1), legendX + (00:(lineHeight-1)), :, iI) = 255;
        end
        rgbLayers(:, :, 1, iI) = cmap(iI, 1)*(alphaLayers(:, :, :, iI) > 0);
        rgbLayers(:, :, 2, iI) = cmap(iI, 2)*(alphaLayers(:, :, :, iI) > 0);
        rgbLayers(:, :, 3, iI) = cmap(iI, 3)*(alphaLayers(:, :, :, iI) > 0);
        if legendBox && (iI > 1 || enable0)
            if iI < size(alphaLayers, 4)
                bgimage(legendY - 25 + (00:(lineSpacing+25-1)) + lineSpacing*(iI-1), legendX - 25 + (00:(legendW-1)), :) = defaultimage(legendY - 25 + (00:(lineSpacing-1+25)) + lineSpacing*(iI-1), legendX - 25 + (00:(legendW-1)), :);
            else
                bgimage(legendY - 25 + (00:(lineHeight+50-1)) + lineSpacing*(iI-1), legendX - 25 + (00:(legendW-1)), :) = defaultimage(legendY - 25 + (00:(lineHeight-1+50)) + lineSpacing*(iI-1), legendX - 25 + (00:(legendW-1)), :);
            end
        end
    end
    
    load("patterns.mat")
    patterns(:, :, :, length(files):end) = [];
    
    intensity = intensity .* any(alphaLayers > 0, 4);
    finalImage = double(bgimage);
    finalImage = (finalImage.*(1-intensity) + sum(patterns.*rgbLayers.*double(alphaLayers).*intensity, 4))/255;
    
    if legendBox
        finalImage = insertShape(finalImage, "line", [legendX+[-26 -26 -24+legendW -24+legendW -26]', legendY+[-26 + lineSpacing*(1-enable0), 26 + lineSpacing*(length(files)-2) + lineHeight, ...
            26 + lineSpacing*(length(files)-2) + lineHeight, -26 + lineSpacing*(1-enable0), -26 + lineSpacing*(1-enable0)]'], ...
            'LineWidth', 2, 'Color', [116 88 54]/255);
    end
    
    sumSpecial = 0;
    % http://xahlee.info/comp/unicode_circled_numbers.html
    for iF = (3 - enable0):length(files)
        spot = regexp(files(iF).name, "C1,(.*),visible", "tokens");
        spot = regexprep(spot{1}{1}, "%0026", "&");
        spot = regexprep(spot, "%0027", "'");
        spot = regexprep(spot, "%0028", "(");
        spot = regexprep(spot, "%0029", ")");
        spot = regexprep(spot, "%002E", ".");
        if iF-1 == specialLayer
            sumSpecial = sumSpecial+1;
            finalImage = insertText(finalImage, [legendX + 9 + 50, legendY + 25 + lineSpacing*(skip(iF-1)+iF-2)], ...
                sprintf("%s. %s", '@'+sumSpecial, spot), "FontSize", 53, ...
                "AnchorPoint", "LeftCenter", "BoxOpacity", 1*highlight, "BoxColor", [202 182 112]/255);
        else
            finalImage = insertText(finalImage, [legendX + 9 + 50, legendY + 25 + lineSpacing*(skip(iF-1)+iF-2)], ...
                sprintf("%.0f. %s", iF-2-sumSpecial, spot), "FontSize", 53, ...
                'AnchorPoint', 'LeftCenter', "BoxOpacity", 1*highlight, "BoxColor", [202 182 112]/255);
        end
    end
    
    imwrite(imresize(finalImage, 0.5), zonename+"\"+zonename+".png")
end