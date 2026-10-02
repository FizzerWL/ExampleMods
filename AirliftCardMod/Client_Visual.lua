require('Utilities')

--Called on the client when it needs to draw a visual on the map for one of this mod's orders.  We draw an arrow that extends from the source of the airlift to its destination, like the arrows for attacks and transfers.
--
--A visual is just a triangle mesh: a list of vertices, the triangles that connect them, and a color for each vertex.  To animate it, we describe the mesh at several moments in time (frames) and the game tweens every vertex
--between them.  The number of vertices and triangles can't change between frames, so an arrow that "grows" is really the same seven-vertex arrow whose vertices start out bunched up at the source.

--The server's event carries the airlift as two territory modifications: armies removed from the source and added to the destination.
local function FindEndpoints(order)
    local sourceID, destID;
    for _, mod in pairs(order.TerritoryModifications) do
        if (mod.AddArmies ~= nil and mod.AddArmies < 0) then sourceID = mod.TerritoryID; end
        if (mod.AddArmies ~= nil and mod.AddArmies > 0) then destID = mod.TerritoryID; end
    end
    return sourceID, destID;
end

--Returns a color string for the arrow's fill, using the color of the player who played the card, and a contrasting color for its outline
local function ArrowColors(game, playerID)
    local fill = "#2FA82B";
    local outline = "#000000";

    local player = game.Game.Players[playerID];
    if (player ~= nil) then
        fill = player.Color.HtmlColor;
        if (string.sub(fill, 1, 1) ~= "#") then fill = "#" .. fill; end

        --If the fill is nearly black, a black outline would disappear
        if (player.Color.R + player.Color.G + player.Color.B < 150) then outline = "#FFFFFF"; end
    end
    return fill, outline;
end

function Client_Visual(game, order, visual)
    local sourceID, destID = FindEndpoints(order);
    if (sourceID == nil or destID == nil) then
        return; --not an airlift event, so we have nothing to draw
    end

    local source = game.Map.Territories[sourceID];
    local dest = game.Map.Territories[destID];

    local dx = dest.MiddlePointX - source.MiddlePointX;
    local dy = dest.MiddlePointY - source.MiddlePointY;
    local length = math.sqrt(dx * dx + dy * dy);
    if (length < 1) then
        return;
    end

    --We build the arrow pointing along the x axis, then rotate it to point at the destination.
    local ux, uy = dx / length, dy / length;
    local function Rotate(x, y)
        return { x * ux - y * uy, x * uy + y * ux };
    end

    --The same proportions as the attack arrows.  The head is 70% as long as it is wide, and the tail is half as wide as the head.
    local headWidth = 20 + math.min(length * 0.1, 20);
    local headLength = headWidth * 0.7;
    local tailWidth = headWidth * 0.5;
    local outlineSize = 3;

    --The seven vertices of an arrow whose tip is at tip: four for the tail rectangle, then three for the head triangle.  The arrow shrinks to a point as the tip approaches the start.
    local function ArrowVertices(tip, grow)
        local scale = math.min(headLength, tip) / headLength; --1 once the arrow is long enough for a whole head
        local headLen = headLength * scale;
        local tailEnd = tip - headLen;
        local tailHalf = (tailWidth / 2 + grow) * scale;
        local headHalf = (headWidth / 2 + grow) * scale;
        local tipX = tip + grow * 1.5 * scale;
        local startX = -grow * scale;

        return {
            Rotate(startX, -tailHalf), Rotate(tailEnd, -tailHalf), Rotate(tailEnd, tailHalf), Rotate(startX, tailHalf),
            Rotate(tailEnd, -headHalf), Rotate(tipX, 0), Rotate(tailEnd, headHalf)
        };
    end

    --One mesh holds both the outline and the fill.  The outline's seven vertices come first, and triangles are drawn in order, so the fill is drawn on top of it.
    local function Pose(tip)
        local vertices = {};
        for _, v in ipairs(ArrowVertices(tip, outlineSize)) do table.insert(vertices, v); end
        for _, v in ipairs(ArrowVertices(tip, 0)) do table.insert(vertices, v); end
        return vertices;
    end

    local fill, outline = ArrowColors(game, order.PlayerID);
    local colors = {};
    for i = 1, 7 do table.insert(colors, outline); end
    for i = 1, 7 do table.insert(colors, fill); end

    --Triangles are 1-based indexes into the vertices.  Each arrow is the tail (two triangles) plus the head (one triangle).
    local triangles = {
        1, 2, 3,   1, 3, 4,   5, 6, 7,
        8, 9, 10,  8, 10, 11, 12, 13, 14
    };

    --The arrow extends over the first 60% of the time and then holds at full length.  Everything about the arrow's shape changes linearly with the position of its tip, except
    --that the head grows from nothing until it's full size.  So we only need a frame where the arrow starts, where its head becomes complete, and where it's fully extended.
    local extendEnd = 0.6;
    local frames = { { t = 0, Vertices = Pose(0), Colors = colors } };
    if (headLength < length) then
        table.insert(frames, { t = extendEnd * headLength / length, Vertices = Pose(headLength) });
    end
    table.insert(frames, { t = extendEnd, Vertices = Pose(length) });
    table.insert(frames, { t = 1, Vertices = Pose(length) }); --Frames that don't specify Colors keep the previous frame's, so these only change the vertices

    visual.SetAnchorPoint(source.MiddlePointX, source.MiddlePointY) --the vertices above are relative to the source
        .SetTriangles(triangles)
        .SetFrames(frames)
        .SetDuration(1500);
end
