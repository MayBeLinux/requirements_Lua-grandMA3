local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.SetItemConfig = function(i, policy, size)
	i.SizePolicy = policy;
	i.Size = size;
end

signalTable.invertItemCollect = function(grid)
	local rows = grid:Ptr(1)
	local columns = grid:Ptr(2)
	-- get itemcollect
	local newRows = {}; -- Entry: {Sizepolicy, Size}, {Sizepolicy, Size}, ..
	local newCols = {};
	for i = 1, columns:Count() do
		local sizepolicy = columns:Ptr(i).SizePolicy;
		local size = columns:Ptr(i).Size;
		size = math.floor(size); size = tostring(size)
		newRows[i] = {sizepolicy, size};
	end
	for i = 1, rows:Count() do
		local sizepolicy = rows:Ptr(i).SizePolicy;
		local size = rows:Ptr(i).Size;
		size = math.floor(size); size = tostring(size)
		newCols[i] = {sizepolicy, size};
	end
	-- set new itemcollect
	rows:Resize(#newRows)
	columns:Resize(#newCols)
	for i = 1, #newRows do
		signalTable.SetItemConfig(rows:Create(i), newRows[i][1], newRows[i][2]);
	end
	for i = 1, #newCols do
		signalTable.SetItemConfig(columns:Create(i), newCols[i][1], newCols[i][2]);
	end
	-- switch anchors of elements
	for i = 3, grid:Count() do
		local a = grid:Ptr(i).Anchors;
		local left, top = a["left"], a["top"];
		grid:Ptr(i).Anchors = tostring(top)..","..tostring(left);
	end
end

signalTable.SetItemCollectLayout = function(grid, type)
	local rows    = grid:Ptr(1):Count();
	local columns = grid:Ptr(2):Count();
	if rows < columns and type == "Vertical" then
		-- current layout = Horizontal
		signalTable.invertItemCollect(grid);
	end
	if rows > columns and type == "Horizontal" then
		-- current layout = Vertical
		signalTable.invertItemCollect(grid);
	end
end

----------------------------------------------------------------------
local ONELINE, TWOLINE = 1, 2;

local TITLE_ONELINE_H = 50;
local TITLE_TWOLINE_H = 105;
local TITLE_ONELINE_W = 245;
local TITLE_TWOLINE_W = 94; -- matches pool title button

signalTable.AnalyseWindowDimensions = function(window)
	local direction, textmode;

	if (IsObjectValid(window)) then
		local width = window.AbsRect.w
		local height = window.AbsRect.h

		if ((height / width) > 1.2) then
			--window vertical
			direction = "Vertical"

			if (width > TITLE_ONELINE_W) then
				-- | MA Name   |
				textmode = ONELINE
			elseif (width <= TITLE_ONELINE_W) then
				-- | MA    |
				-- | Name  |
				textmode = TWOLINE
			end
		else
			--window horizontal (default)
			direction = "Horizontal"

			if (height <= TITLE_ONELINE_H) then
				-- | MA Name   |
				textmode = ONELINE
			elseif (height > TITLE_ONELINE_H) then
				-- | MA    |
				-- | Name  |
				textmode = TWOLINE
			end
		end
	end
	return direction, textmode;
end

signalTable.ChangeGeneralLayout = function(window, direction, textmode)
	local function changeTitle(button, mode)
		if mode == ONELINE then
			button.Text = string.gsub(button.Text, "\n", " ")
		elseif mode == TWOLINE then
			button.Text = string.gsub(button.Text, " ", "\n")
		end
	end

	if (IsObjectValid(window)) then
		local Title = window.Title;

		changeTitle(Title.Context.TitleBtn,textmode)
		signalTable.SetItemCollectLayout(Title, direction)

		if textmode == ONELINE then
			signalTable.SetItemCollectLayout(Title.Context,"Horizontal");
		else
			signalTable.SetItemCollectLayout(Title.Context,"Vertical");
		end

		if direction == "Vertical" then
			Title.Context.W = "100%";
			if textmode == ONELINE then
				Title.Context.H = TITLE_ONELINE_H;
				Title.Context.TitleBtn.TextAlignmentV = "Center";
			else
				Title.Context.H = TITLE_TWOLINE_H;
				Title.Context.TitleBtn.TextAlignmentV = "Top";
			end
		else
			Title.Context.H = "100%";
			if textmode == ONELINE then
				Title.Context.W = TITLE_ONELINE_W;
				Title.Context.TitleBtn.TextAlignmentV = "Center";
			else
				Title.Context.W = TITLE_TWOLINE_W;
				Title.Context.TitleBtn.TextAlignmentV = "Top";
			end
		end
	end
end
