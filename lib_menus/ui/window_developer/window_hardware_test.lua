-- expect the library to be present. If not, reload it
local library = nil
local globalVariable = "controllerToLoad"
local signalTable   = select(3,...);
local my_handle     = select(4,...);

local util = nil
local controller = nil
local runTest = nil

-- simple table representing this window and all its elements.
-- The window will always be changed by a controller from the library plugin using its methods.
local Window = {
	backBtn = nil,
    rerunBtn = nil,
    nextBtn = nil,
    instructionText = nil,
	resultText = nil,
	titleText = nil
}

--- Constructor for a window.
---@param self Window
---@param caller any window that represents the hardwaretest
function Window:new(caller)
	local o = {}
    self.__index = self
    setmetatable(o, self)

	o.backBtn = caller.Frame.Textfields.Buttons.BackBtn
	o.rerunBtn = caller.Frame.Textfields.Buttons.RerunBtn
	o.nextBtn = caller.Frame.Textfields.Buttons.ConfirmBtn
	o.instructionText = caller.Frame.Textfields.InstructionText
	o.resultText = caller.Frame.Textfields.ResultText
	o.titleText = caller.Title.TitleBtn

    return o
end

--- Initializes the buttons with their default text.
---@param self Windows
---@param buttonText table containing labels "back", "rerun" and "next" for each button.
---@param title any title that is appended to "Hardwaretest: ". Will be converted to string, so __string works.
function Window:initButtons(buttonText, title)
	self.backBtn.Text = buttonText.back
	self.rerunBtn.Text = buttonText.rerun
    self.nextBtn.Text = buttonText.next

	self.backBtn.visible = false

	self.titleText.text = "Hardwaretest: " .. tostring(title)
end

--- Changes the textboxes in the window.
---@param self Window
---@param text table with keys "generic" and either "success" or "fail".
function Window:changeTextBoxes(text)
	local generic = text.generic
	local success = text.success
	local fail = text.fail
	local neutral = text.neutral
	local instruction = text.instruction

	if generic then
		self.instructionText.Text = generic
	end
	self.resultText.Text = success or fail or neutral or instruction

	if success then
		self.resultText.TextColor = "Global.SuccessText"
	elseif fail then
		self.resultText.TextColor = "Global.AlertText"
	elseif neutral then
		self.resultText.TextColor = "Global.Text"
	elseif instruction then
		self.resultText.TextColor = "Global.Text"
	end
end

--- Initializes all "global" local variables.
---@param caller any reference to window
local function _initDependencies(caller)
	library = PlugLib
    util = library.util

    -- if no controller is defined by global variable, user will be asked which to use
    controller = GetVar(GlobalVars(), globalVariable)
    if controller == nil then
        error("Please use the showbuilder to create a show that is suitable for testing a device.")
	else
		controller = util.require(library, controller)
	end
	controller.window = Window:new(caller)
	runTest = controller:runTest()
end

--- Initializes the iterator for the tests, runs the first test and initializes the buttons on window loaded.
---@param caller any
---@param status any
---@param creator any
function signalTable.HardwareTestLoaded(caller, status, creator)
	_initDependencies(caller)
	runTest("next")
end

--- On click of back button the last test is run.
---@param caller any
---@param status any
---@param creator any
function signalTable.backClick(caller, status, creator)
	runTest("back")
end

--- On click of rerun button, the same test is run again.
---@param caller any
---@param status any
---@param creator any
function signalTable.rerunClick(caller, status, creator)
	runTest("rerun")
end

--- On click of the confirm button, the next test is run.
---@param caller any
---@param status any
---@param creator any
function signalTable.confirmClick(caller, status, creator)
	runTest("next")
end

--- On click of the reset button, the first test is run.
---@param caller any
---@param status any
---@param creator any
function signalTable.resetClick(caller, status, creator)
	runTest("reset")
end