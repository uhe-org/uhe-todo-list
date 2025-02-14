function Initialize()
    SDynamicMeterFile = SELF:GetOption('DynamicMeterFile')
    STaskListFile = SELF:GetOption('TaskListFile')
    SLogFile = SELF:GetOption('LogFile')
end

function Update()
    local dynamicOutput = {}
    local tasks = {}
    local checked = ""
    local current = ""
    local recurring = ""
    local titleSet = false

    local tasksFile = io.open(STaskListFile, "r")

    -- create a new tasks file if it doesn't exist
    if (tasksFile == nil) then
        tasksFile = io.open(STaskListFile, "w")
    end

    tasksFile:close();

    -- Iterate through each line in the task list
    for line in io.lines(STaskListFile) do
        -- check if the task is complete
        if string.sub(line, 1, 1) == "+" then
            checked = checked .. "|" .. #tasks + 1
            line = string.sub(line, 2, string.len(line))
        end

        if string.sub(line, 1, 1) == "-" then
            current = current .. "|" .. #tasks + 1
            line = string.sub(line, 2, string.len(line))
        end

        -- check if the task is recurring
        if string.sub(line, -2, -1) == "|R" then
            recurring = recurring .. "|" .. #tasks + 1
            line = string.sub(line, 1, -3)
        end


        if string.sub(line, 1, 2) == "# " and titleSet == false then
            SKIN:Bang('!SetVariable', 'Title', string.sub(line, 3, string.len(line)))
            titleSet = true
        else
            tasks[#tasks + 1] = line
        end
    end

    if titleSet == false then
        SKIN:Bang('!SetVariable', 'Title', "Tasks#ListNumber#")
    end

    -- add delimeter to end of checked string
    checked = checked .. "|"

    -- add delimeter to end of current string
    current = current .. "|"

    -- add delimeter to end of recurring string
    recurring = recurring .. "|"

    if #tasks > 0 then
        SKIN:Bang('!HideMeter', 'meterPlaceholder')
    end

    for i = 1, #tasks, 1 do
        dynamicOutput[#dynamicOutput + 1] = string.gsub([=[
[MeasureTaskIconPosition]
Measure=String
String=#checkPositionstate#
IfMatch=0
IfMatchAction=[!SetVariable checkPosition fa-sq][!SetOption MeterRepeatingTaskPosition InlineSetting ""][!SetOption MeterRepeatingTaskPosition InlineSetting2 ""][!SetOption MeterTaskIconPosition InlineSetting ""]
IfMatch2=1
IfMatchAction2=[!SetVariable checkPosition fa-check-sq][!SetOption MeterRepeatingTaskPosition InlineSetting Strikethrough][!SetOption MeterRepeatingTaskPosition InlineSetting2 "Color | #*FadedOutColor*#"][!SetOption MeterTaskIconPosition InlineSetting "Color | #*FadedOutColor*#"]
IfMatch3=-1
IfMatchAction3=[!SetVariable checkPosition fa-square-minus][!SetOption MeterRepeatingTaskPosition InlineSetting Underline][!SetOption MeterRepeatingTaskPosition InlineSetting2 "Color | #*CurrentHighlight*#"][!SetOption MeterTaskIconPosition InlineSetting "Color | #*CurrentHighlight*#"]
IfMatchMode=1
DynamicVariables=1

[MeterTaskIconPositionBackground]
Meter=Shape
Shape=Rectangle 0,0,[MeterTaskIconPosition:W],([MeterRepeatingTaskPosition:H]),#CornerRadius# | Fill LinearGradient Gradient | StrokeWidth 0
Gradient=0 | 0,0,0,0 ; 0.0
DynamicVariables=1
Group=BackgroundGroup
X=0
Y=R

[MeterTaskIconPosition]
Meter=String
MeasureName=MeasureTaskIconPosition
Text=[#[#checkPosition]]
FontFace=#RegularIconFace#
FontSize=#TaskFontSize#
Group=TextGroup
AntiAlias=1
X=r
Y=r
H=([MeterRepeatingTaskPosition:H] - (#SidePadding# * 2))
LeftMouseUpAction=#PlayButtonClick#[!CommandMeasure "MeasureDynamicTasks" "CheckLine(Position)"][!Update]
RightMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "MarkCurrent(Position)"][!Update]
DynamicVariables=1
GradientAngle=180
Padding=#PaddingSize#
MouseOverAction=[!SetOption MeterRepeatingTaskPositionHover Highlight "FillColor #LightHighlight#,#NoGradientTransparency#"][!UpdateMeter MeterRepeatingTaskPositionHover][!Redraw]
MouseLeaveAction=[!SetOption MeterRepeatingTaskPositionHover Highlight "FillColor 0,0,0,0"][!UpdateMeter MeterRepeatingTaskPositionHover][!Redraw]

[MeterRepeatingTaskPositionBackground]
Meter=Shape
Shape=Rectangle 0,0,(#Width# - [MeterTaskIconPosition:W]),([MeterRepeatingTaskPosition:H]),#CornerRadius# | Fill LinearGradient Gradient | StrokeWidth 0
Shape2=Rectangle -#CornerRadius#,0,(#Width# - [MeterTaskIconPosition:W]),([MeterRepeatingTaskPosition:H]),0
Shape3=Rectangle (-#CornerRadius# * 2),0,(#CornerRadius# * 2),([MeterRepeatingTaskPosition:H]),#CornerRadius#
Shape4=Combine Shape | Union Shape2 | Exclude Shape3
Gradient=0 | 0,0,0,0 ; 0.0
DynamicVariables=1
Group=OpaqueBackgroundGroup
X=R
Y=r

[MeterRepeatingTaskPositionHover]
Meter=Shape
Shape=Rectangle 0,0,(#Width# - [MeterTaskIconPosition:W]),([MeterRepeatingTaskPosition:H]),#CornerRadius# | Extend Highlight | StrokeWidth 0
Highlight=FillColor 0,0,0,0
DynamicVariables=1
X=r
Y=r
LeftMouseUpAction=#PlayButtonClick#[!CommandMeasure MeasureRenameTextBoxPosition "ExecuteBatch 1-2"]
]=] .. (i >= 2 and [=[
MouseScrollUpAction=[!CommandMeasure "MeasureDynamicTasks" "MoveTask(Position, -1)"][!Refresh]
]=] or "") .. (i == #tasks and "" or [=[
MouseScrollDownAction=[!CommandMeasure "MeasureDynamicTasks" "MoveTask(Position, 1)"][!Refresh]
]=]) .. [=[

[MeterRepeatingTaskPosition]
Meter=String
Text=]=] .. tasks[i] .. [=[

FontFace=#FontFace#
FontSize=#TaskFontSize#
Group=TextGroup
AntiAlias=1
ClipString=2
X=r
Y=r
DynamicVariables=1
W=(#Width# - [MeterTaskIconPosition:W] - #SidePadding# * 2)
Padding=#PaddingSize#
MouseOverAction=[!SetOption MeterRepeatingTaskPositionHover Highlight "FillColor #LightHighlight#,#NoGradientTransparency#"][!UpdateMeter MeterRepeatingTaskPositionHover][!ShowMeterGroup HoverGroupPosition][!UpdateMeterGroup HoverGroupPosition]]=] ..
            (i >= 2 and [=[[!SetOption MeterMoveUpTaskPosition Text "#fa-chevron-up#"][!UpdateMeter MeterMoveUpTaskPosition]]=] or "") ..
            [=[[!SetOptionGroup NotRecurringGroupPosition Text "#fa-repeat#"][!UpdateMeterGroup NotRecurringGroupPosition][!Redraw]
MouseLeaveAction=[!SetOption MeterRepeatingTaskPositionHover Highlight "FillColor 0,0,0,0"][!UpdateMeter MeterRepeatingTaskPositionHover][!HideMeterGroup HoverGroupPosition][!UpdateMeterGroup HoverGroupPosition]]=] ..
            (i >= 2 and [=[[!SetOption MeterMoveUpTaskPosition Text ""][!UpdateMeter MeterMoveUpTaskPosition]]=] or "") ..
            [=[[!SetOptionGroup NotRecurringGroupPosition Text ""][!UpdateMeterGroup NotRecurringGroupPosition][!Redraw]

[MeasureRenameTextBoxPosition]
Measure=Plugin
Plugin=InputText
DefaultValue=]=] .. tasks[i] .. [=[

FontFace=#FontFace#
FontSize=#TaskFontSize#
Group=TextBoxGroup | TextGroup
AntiAlias=1
X=([MeterTaskIconPosition:W] + #SidePadding#)
Y=([MeterRepeatingTaskPosition:Y] + #SidePadding#)
W=(#Width# - ([MeterTaskIconPosition:W] + #SidePadding# * 2))
H=([MeterRepeatingTaskPosition:H] - (#SidePadding# * 2))
Command1=[!SetVariable placeholder $UserInput$
Command2=[!CommandMeasure "MeasureDynamicTasks" "RenameTask(Position, '[MeasureRenameTextBoxPosition]')"][!Refresh]
Substitute="'":"\'"

[MeterToggleRecurringPositionBackground]
Meter=Shape
Shape=Rectangle 0,0,([MeterTitleBackground:H] / 2),([MeterRepeatingTaskPosition:H]),#CornerRadius# | Fill LinearGradient Gradient | StrokeWidth 0
Gradient=0 | 0,0,0,0 ; 0.0
DynamicVariables=1
Group=BackgroundGroup | HoverGroupPosition
X=(-[MeterTitleBackground:H] / 2)R
Y=[MeterRepeatingTaskPosition:Y]
Hidden=1
MouseOverAction=[!SetOption MeterToggleRecurringPositionHover Highlight "FillColor #LightHighlight#,#NoGradientTransparency#"][!UpdateMeter MeterToggleRecurringPositionHover][!Redraw]
MouseLeaveAction=[!SetOption MeterToggleRecurringPositionHover Highlight "FillColor 0,0,0,0"][!UpdateMeter MeterToggleRecurringPositionHover][!Redraw]
LeftMouseUpAction=#PlayButtonClick#[!CommandMeasure "MeasureDynamicTasks" "RenameTask(Position, ']=] ..
            tasks[i] .. (string.find(recurring, "|" .. i .. "|") ~= nil and "" or "|R") .. [=[')][!Refresh]
TooltipText=Toggle recurring

[MeterToggleRecurringPositionHover]
Meter=Shape
Shape=Rectangle 0,0,([MeterTitleBackground:H] / 2),([MeterRepeatingTaskPosition:H]),#CornerRadius# | Extend Highlight | StrokeWidth 0
Highlight=FillColor 0,0,0,0
DynamicVariables=1
X=r
Y=[MeterRepeatingTaskPosition:Y]

[MeterToggleRecurringPosition]
Meter=String
FontFace=#IconFace#
FontSize=#TaskFontSize#
AntiAlias=1
X=([MeterTitleBackground:H] / 4)r
DynamicVariables=1
Y=([MeterRepeatingTaskPosition:Y] + ([MeterRepeatingTaskPosition:H] / 2))]=]
            .. (string.find(recurring, "|" .. i .. "|") ~= nil and [=[

Text=#fa-repeat#
FontColor=#LightHighlight#]=]
                or [=[

Group=TextGroup | NotRecurringGroupPosition]=]) .. [=[

StringAlign=CenterCenter
H=([MeterRepeatingTaskPosition:H] / 2)
W=([MeterTitleBackground:H] / 2)]=]
            .. (i >= 2 and [=[


[MeterMoveUpTaskPositionBackground]
Meter=Shape
Shape=Rectangle 0,0,([MeterTitleBackground:H] / 2),([MeterRepeatingTaskPosition:H]),#CornerRadius# | Fill LinearGradient Gradient | StrokeWidth 0
Gradient=0 | 0,0,0,0 ; 0.0
DynamicVariables=1
Group=BackgroundGroup | HoverGroupPosition
X=(-[MeterTitleBackground:H] / 4 - [MeterTitleBackground:H] / 2)r
Y=[MeterRepeatingTaskPosition:Y]
Hidden=1
LeftMouseUpAction=#PlayButtonClick#[!CommandMeasure "MeasureDynamicTasks" "MoveTask(Position, -1)"][!Refresh]
MouseOverAction=[!SetOption MeterMoveUpTaskPositionHover Highlight "FillColor #LightHighlight#,#NoGradientTransparency#"][!UpdateMeter MeterMoveUpTaskPositionHover][!Redraw]
MouseLeaveAction=[!SetOption MeterMoveUpTaskPositionHover Highlight "FillColor 0,0,0,0"][!UpdateMeter MeterMoveUpTaskPositionHover][!Redraw]
TooltipText=Move up

[MeterMoveUpTaskPositionHover]
Meter=Shape
Shape=Rectangle 0,0,([MeterTitleBackground:H] / 2),([MeterRepeatingTaskPosition:H]),#CornerRadius# | Extend Highlight | StrokeWidth 0
Highlight=FillColor 0,0,0,0
DynamicVariables=1
X=r
Y=[MeterRepeatingTaskPosition:Y]

[MeterMoveUpTaskPosition]
Meter=String
FontFace=#IconFace#
FontSize=#TaskFontSize#
Group=TextGroup
AntiAlias=1
X=([MeterTitleBackground:H] / 4)r
DynamicVariables=1
Y=([MeterRepeatingTaskPosition:Y] + ([MeterRepeatingTaskPosition:H] / 2))
H=([MeterRepeatingTaskPosition:H] / 2)
W=([MeterTitleBackground:H] / 2)
StringAlign=CenterCenter
]=] or [=[

]=]), "Position", i)
    end

    dynamicOutput[#dynamicOutput + 1] = "[Variables]"

    for i = 1, #tasks, 1 do
        if string.find(checked, "|" .. i .. "|") ~= nil then
            dynamicOutput[#dynamicOutput + 1] = "check" .. i .. "state=1"
            dynamicOutput[#dynamicOutput + 1] = "check" .. i .. "=fa-check-sq"
        else
            if string.find(current, "|" .. i .. "|") ~= nil then
                dynamicOutput[#dynamicOutput + 1] = "check" .. i .. "state=-1"
                dynamicOutput[#dynamicOutput + 1] = "check" .. i .. "=fa-square-minus"
            else
                dynamicOutput[#dynamicOutput + 1] = "check" .. i .. "state=0"
                dynamicOutput[#dynamicOutput + 1] = "check" .. i .. "=fa-sq"
            end
        end
    end

    local File = io.open(SDynamicMeterFile, "r")

    if (File == nil) then
        InitialRefresh = true
    end

    File = io.open(SDynamicMeterFile, "w")
    File:write(table.concat(dynamicOutput, '\n'))
    File:close()

    UpdateLogItems()

    if (InitialRefresh) then
        SKIN:Bang('!Refresh')
    end

    return true
end

function GetList()
    local hFile = io.open(STaskListFile, "r")
    local lines = {}

    for line in hFile:lines() do
        lines[#lines + 1] = line
    end

    return lines
end

function CheckLine(lineNumber)
    local hFile = io.open(STaskListFile, "r")
    local lines = {}
    local taskIndex

    lines = GetList()

    taskIndex = lineNumber

    if (string.sub(lines[1], 1, 2) == "# ") then
        lineNumber = lineNumber + 1
    end

    local modifiedLine = lines[lineNumber]

    -- toggle completion status of selected task
    if string.sub(modifiedLine, 1, 1) ~= "+" then
        local startIndex = 1

        if (string.sub(modifiedLine, 1, 1) == "-") then
            startIndex = 2
        end

        lines[lineNumber] = "+" .. string.sub(modifiedLine, startIndex, string.len(modifiedLine))
        SKIN:Bang('!SetVariable', 'check' .. taskIndex .. 'state', 1)

        if (string.sub(modifiedLine, -2, -1) == "|R") then
            LogTask(string.sub(modifiedLine, startIndex, string.len(modifiedLine) - 2))
        else
            LogTask(string.sub(modifiedLine, startIndex, string.len(modifiedLine)))
        end
    else
        lines[lineNumber] = string.sub(modifiedLine, 2, string.len(modifiedLine))
        SKIN:Bang('!SetVariable', 'check' .. taskIndex .. 'state', 0)
    end

    -- close task list for reading
    hFile:close()

    -- open task list for writing
    hFile = io.open(STaskListFile, "w")

    -- update lines of file
    for i, line in ipairs(lines) do
        hFile:write(line, "\n")
    end

    hFile:close()

    Update()
    UpdateGist()

    return true
end

function MarkCurrent(lineNumber)
    local hFile = io.open(STaskListFile, "r")
    local lines = {}
    local taskIndex

    lines = GetList()

    taskIndex = lineNumber

    if (string.sub(lines[1], 1, 2) == "# ") then
        lineNumber = lineNumber + 1
    end

    local modifiedLine = lines[lineNumber]

    -- toggle current status of selected task
    if string.sub(modifiedLine, 1, 1) ~= "-" then
        local startIndex = 1

        if string.sub(modifiedLine, 1, 1) == "+" then
            startIndex = 2
        end

        lines[lineNumber] = "-" .. string.sub(modifiedLine, startIndex, string.len(modifiedLine))
        SKIN:Bang('!SetVariable', 'check' .. taskIndex .. 'state', -1)
    else
        lines[lineNumber] = string.sub(modifiedLine, 2, string.len(modifiedLine))
        SKIN:Bang('!SetVariable', 'check' .. taskIndex .. 'state', 0)
    end

    -- close task list for reading
    hFile:close()

    -- open task list for writing
    hFile = io.open(STaskListFile, "w")

    -- update lines of file
    for i, line in ipairs(lines) do
        hFile:write(line, "\n")
    end

    hFile:close()

    Update()
    UpdateGist()

    return true
end

function ClearTasks()
    local hFile = io.open(STaskListFile, "r")
    local lines = {}
    local allLines = {}

    allLines = GetList()

    -- read through task list
    for i, line in ipairs(allLines) do
        -- do not delete recurring tasks
        if string.sub(line, -2, -1) == "|R" then
            if string.sub(line, 1, 1) == "+" then
                lines[#lines + 1] = string.sub(line, 2, string.len(line))
            else
                lines[#lines + 1] = line
            end
            -- do not delete uncompleted tasks
        elseif string.sub(line, 1, 1) ~= "+" and string.sub(line, -2, -1) ~= "|R" then
            lines[#lines + 1] = line
        end
    end

    -- close task list for reading
    hFile:close()

    -- open task list for writing
    hFile = io.open(STaskListFile, "w")

    for i, line in ipairs(lines) do
        hFile:write(line, "\n")
    end

    hFile:close()

    Update()
    UpdateGist()

    return true
end

function AddTask(newline)
    -- read entire task list
    local hFile = io.open(STaskListFile, "r")
    local wholeFile = hFile:read("*a")
    hFile:close()

    -- write task list back to itself and add new line
    hFile = io.open(STaskListFile, "w")
    hFile:write(wholeFile)

    if (newline ~= "") then
        hFile:write(newline, "\n")
        hFile:close()
        Update()
        UpdateGist()
        SKIN:Bang('!Refresh')
    else
        hFile:close()
    end

    return true
end

function SetTitle(newTaskName)
    local hFile = io.open(STaskListFile, "r")
    local lines = {}
    local lineNumber = 1
    local titleSet = false

    lines = GetList()

    if #lines > 0 and (string.sub(lines[1], 1, 2) == "# ") then
        titleSet = true
    end

    if titleSet == true then
        if newTaskName ~= "" then
            lines[lineNumber] = "# " .. newTaskName
        else
            lines[lineNumber] = ""
        end
    end

    -- close task list for reading
    hFile:close()

    -- open task list for writing
    hFile = io.open(STaskListFile, "w")

    if titleSet == false and newTaskName ~= "" then
        hFile:write("# " .. newTaskName, "\n")
    end

    -- update lines of file
    for i, line in ipairs(lines) do
        if (line ~= "") then
            hFile:write(line, "\n")
        end
    end

    hFile:close()

    Update()
    UpdateGist()
end

function LogTask(task)
    local logFile = io.open(SLogFile, "r")

    -- create a new log file if it doesn't exist
    if (logFile == nil) then
        logFile = io.open(STaskListFile, "w")
        logFile:close()
        logFile = io.open(STaskListFile, "r")
    end

    local readFile = logFile:read("*a")
    logFile:close()

    logFile = io.open(SLogFile, "w")
    logFile:write(readFile)
    ---@diagnostic disable-next-line: param-type-mismatch
    logFile:write(os.date())
    logFile:write(': ')
    logFile:write(task, "\n")
    logFile:close()
    UpdateLogItems()
end

function UpdateLogItems()
    SKIN:Bang('!SetOption', 'MeterLogs', 'Text', GetLogItems())
end

function GetLogItems()
    local logFile = io.open(SLogFile, "r")
    local logs = {}
    local logsText = ""

    if (logFile ~= nil) then
        for line in logFile:lines() do
            logs[#logs + 1] = line

            logsText = logs[#logs] .. "#CRLF#" .. logsText
        end
        io.close(logFile)
    else
        logsText = "No logs yet!"
    end

    return logsText
end

function RenameTask(lineNumber, newTaskName)
    local hFile = io.open(STaskListFile, "r")
    local lines = {}

    lines = GetList()

    if (string.sub(lines[1], 1, 2) == "# ") then
        lineNumber = lineNumber + 1
    end

    lines[lineNumber] = newTaskName

    -- close task list for reading
    hFile:close()

    -- open task list for writing
    hFile = io.open(STaskListFile, "w")

    -- update lines of file
    for i, line in ipairs(lines) do
        if (line ~= "") then
            hFile:write(line, "\n")
        end
    end

    hFile:close()

    Update()
    UpdateGist()
end

function MoveTask(lineNumber, direction)
    local hFile = io.open(STaskListFile, "r")
    local lines = {}

    lines = GetList()

    if (string.sub(lines[1], 1, 2) == "# ") then
        lineNumber = lineNumber + 1
    end

    local swappedLine = lines[lineNumber]
    local targetedIndex = lineNumber + direction

    -- swap task
    lines[lineNumber] = lines[targetedIndex]
    lines[targetedIndex] = swappedLine

    -- close task list for reading
    hFile:close()

    -- open task list for writing
    hFile = io.open(STaskListFile, "w")

    -- update lines of file
    for i, line in ipairs(lines) do
        hFile:write(line, "\n")
    end

    hFile:close()

    Update()
    UpdateGist()
end

function UpdateTaskContentVariable()
    local taskContent = ""

    for line in io.lines(STaskListFile) do
        taskContent = taskContent .. line .. "\\n"
    end

    SKIN:Bang('!SetVariable', 'taskContent', taskContent)
end

function UpdateGist()
    if (SKIN:GetVariable('Sync') == "0") then
        return
    end

    UpdateTaskContentVariable()
    SKIN:Bang('!SetOption', 'meterSyncTasks', 'FontColor', '255,255,0')
    SKIN:Bang('!UpdateMeasure', 'measureUpdateGist')
    SKIN:Bang('!CommandMeasure', 'measureUpdateGist', 'Run')
end
