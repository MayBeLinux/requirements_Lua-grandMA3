local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.SwitchEditor = function(caller, status,creator)
    local NewExecutorEditorConcept = caller:Parent():Parent()
    local KeyEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.KeyEditor
    local EncoderEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.EncoderEditor
    local FaderEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.FaderEditor

    if KeyEditor.Visible == true then
        KeyEditor.Visible = false
        EncoderEditor.Visible = true
        FaderEditor.Visible = false
    elseif EncoderEditor.Visible == true then
        KeyEditor.Visible = false
        EncoderEditor.Visible = false
        FaderEditor.Visible = true
    elseif FaderEditor.Visible == true then
        KeyEditor.Visible = true
        EncoderEditor.Visible = false
        FaderEditor.Visible = false
    end
end

signalTable.EncoderInputClicked = function(caller,status,creator)
    local NewExecutorEditorConcept = caller:GetOverlay()
    local KeyEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.KeyEditor
    local EncoderEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.EncoderEditor
    local FaderEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.FaderEditor
    local ExecLabel = EncoderEditor.ExecFunctionSelect.ExecLabel

    ExecLabel.Text = caller.SignalValue

    KeyEditor.Visible = false
    EncoderEditor.Visible = true
    FaderEditor.Visible = false
end

signalTable.KeyInputClicked = function(caller,status,creator)
    local NewExecutorEditorConcept = caller:GetOverlay()
    local KeyEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.KeyEditor
    local EncoderEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.EncoderEditor
    local FaderEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.FaderEditor
    local ExecLabel = KeyEditor.ExecFunctionSelect.ExecLabel

    ExecLabel.Text = caller.SignalValue
    KeyEditor.Visible = true
    EncoderEditor.Visible = false
    FaderEditor.Visible = false
end

signalTable.FaderInputClicked = function(caller,status,creator)
    local NewExecutorEditorConcept = caller:GetOverlay()
    local KeyEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.KeyEditor
    local EncoderEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.EncoderEditor
    local FaderEditor = NewExecutorEditorConcept.Content.Dialogs.ExecutorConfigurationEditor.FaderEditor
    local ExecLabel = FaderEditor.FaderFunctionSelect.FaderLabel

    ExecLabel.Text = caller.SignalValue
    KeyEditor.Visible = false
    EncoderEditor.Visible = false
    FaderEditor.Visible = true
end