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

    local tasksFile = io.open(STaskListFile, "r")

    -- create a new tasks file if it doesn't exist
    if (tasksFile == nil) then
        tasksFile = io.open(STaskListFile, "w")
        tasksFile:write("Recurring task|R\nThing to do today\nThing to do tomorrow")
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

        tasks[#tasks + 1] = line
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
IfMatchAction=[!SetVariable checkPosition fa-sq][!SetOption MeterRepeatingTaskPosition InlineSetting ""][!SetOption MeterRepeatingTaskPosition InlineSetting2 ""]
IfMatch2=1
IfMatchAction2=[!SetVariable checkPosition fa-check-sq][!SetOption MeterRepeatingTaskPosition InlineSetting Strikethrough][!SetOption MeterRepeatingTaskPosition InlineSetting2 "Color | 255,255,255,50"]
IfMatch3=-1
IfMatchAction3=[!SetVariable checkPosition fa-square-minus][!SetOption MeterRepeatingTaskPosition InlineSetting Underline][!SetOption MeterRepeatingTaskPosition InlineSetting2 "Color | #LightHighlight#"]
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
MouseScrollUpAction=[!CommandMeasure "MeasureDynamicTasks" "MoveTask(Position, -1)"][!Refresh]
MouseScrollDownAction=[!CommandMeasure "MeasureDynamicTasks" "MoveTask(Position, 1)"][!Refresh]

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
MouseOverAction=[!SetOption MeterRepeatingTaskPositionHover Highlight "FillColor #LightHighlight#,#NoGradientTransparency#"][!UpdateMeter MeterRepeatingTaskPositionHover][!ShowMeterGroup HoverGroupPosition][!UpdateMeterGroup HoverGroupPosition][!SetOption MeterMoveUpTaskPosition Text "#fa-chevron-up#"][!UpdateMeter MeterMoveUpTaskPosition][!SetOptionGroup NotRecurringGroupPosition Text "#fa-repeat#"][!UpdateMeterGroup NotRecurringGroupPosition][!Redraw]
MouseLeaveAction=[!SetOption MeterRepeatingTaskPositionHover Highlight "FillColor 0,0,0,0"][!UpdateMeter MeterRepeatingTaskPositionHover][!HideMeterGroup HoverGroupPosition][!UpdateMeterGroup HoverGroupPosition][!SetOption MeterMoveUpTaskPosition Text ""][!UpdateMeter MeterMoveUpTaskPosition][!SetOptionGroup NotRecurringGroupPosition Text ""][!UpdateMeterGroup NotRecurringGroupPosition][!Redraw]

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
W=([MeterTitleBackground:H] / 2)

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
]=], "Position", i)
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

function CheckLine(lineNumber)
    local hFile = io.open(STaskListFile, "r")
    local lines = {}
    local restOfFile
    local lineCt = 1
    local startIndex = 1

    -- read through task list
    for line in hFile:lines() do
        -- find the line to be altered
        if (lineCt == lineNumber) then
            if (string.sub(line, 1, 1) == "-") then
                startIndex = 2
            end

            -- toggle completion status of line
            if string.sub(line, 1, 1) ~= "+" then
                lines[#lines + 1] = "+" .. string.sub(line, startIndex, string.len(line))
                SKIN:Bang('!SetVariable', 'check' .. lineCt .. 'state', 1)

                if (string.sub(line, -2, -1) == "|R") then
                    LogTask(string.sub(line, startIndex, string.len(line) - 2))
                else
                    LogTask(string.sub(line, startIndex, string.len(line)))
                end
            else
                lines[#lines + 1] = string.sub(line, 2, string.len(line))
                SKIN:Bang('!SetVariable', 'check' .. lineCt .. 'state', 0)
            end

            -- read the rest of the file
            restOfFile = hFile:read("*a")
            -- and break from loop
            break
        else
            -- write the lines of the file before altered line
            lineCt = lineCt + 1
            lines[#lines + 1] = line
        end
    end

    -- close task list for reading
    hFile:close()

    -- open task list for writing
    hFile = io.open(STaskListFile, "w")

    -- write lines of file from start to altered line
    for i, line in ipairs(lines) do
        hFile:write(line, "\n")
    end

    hFile:write(restOfFile)
    hFile:close()

    Update()
    UpdateGist()

    return true
end

function MarkCurrent(lineNumber)
    local hFile = io.open(STaskListFile, "r")
    local lines = {}
    local restOfFile
    local lineCt = 1
    local startIndex = 1

    -- read through task list
    for line in hFile:lines() do
        -- find the line to be altered
        if (lineCt == lineNumber) then
            if string.sub(line, 1, 1) == "+" then
                startIndex = 2
            end

            -- toggle current status of line
            if string.sub(line, 1, 1) ~= "-" then
                lines[#lines + 1] = "-" .. string.sub(line, startIndex, string.len(line))
                SKIN:Bang('!SetVariable', 'check' .. lineCt .. 'state', -1)
            else
                lines[#lines + 1] = string.sub(line, 2, string.len(line))
                SKIN:Bang('!SetVariable', 'check' .. lineCt .. 'state', 0)
            end

            -- read the rest of the file
            restOfFile = hFile:read("*a")
            -- and break from loop
            break
        else
            -- write the lines of the file before altered line
            lineCt = lineCt + 1
            lines[#lines + 1] = line
        end
    end

    -- close task list for reading
    hFile:close()

    -- open task list for writing
    hFile = io.open(STaskListFile, "w")

    -- write lines of file from start to altered line
    for i, line in ipairs(lines) do
        hFile:write(line, "\n")
    end

    hFile:write(restOfFile)
    hFile:close()

    Update()
    UpdateGist()

    return true
end

function ClearTasks()
    local hFile = io.open(STaskListFile, "r")
    local lines = {}

    -- read through task list
    for line in hFile:lines() do
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
    hFile:write(newline, "\n")
    hFile:close()

    Update()
    UpdateGist()

    return true
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
    local restOfFile
    local lineCt = 1

    -- read through task list
    for line in hFile:lines() do
        -- find the line to be altered
        if (lineCt == lineNumber) then
            -- rename task
            if (newTaskName ~= "") then
                lines[#lines + 1] = newTaskName
            end

            -- read the rest of the file
            restOfFile = hFile:read("*a")
            -- and break from loop
            break
        else
            -- write the lines of the file before altered line
            lineCt = lineCt + 1
            lines[#lines + 1] = line
        end
    end

    -- close task list for reading
    hFile:close()

    -- open task list for writing
    hFile = io.open(STaskListFile, "w")

    -- write lines of file from start to altered line
    for i, line in ipairs(lines) do
        hFile:write(line, "\n")
    end

    hFile:write(restOfFile)
    hFile:close()

    Update()
    UpdateGist()
end

function MoveTask(lineNumber, direction)
    local hFile = io.open(STaskListFile, "r")
    local lines = {}

    -- read through task list
    for line in hFile:lines() do
        lines[#lines + 1] = line
    end

    local swappedLine = lines[lineNumber]
    local targetedIndex = lineNumber + direction

    if (targetedIndex == 0) then
        targetedIndex = #lines
    elseif (targetedIndex > #lines) then
        targetedIndex = 1
    end

    -- swap task
    lines[lineNumber] = lines[targetedIndex]
    lines[targetedIndex] = swappedLine

    -- close task list for reading
    hFile:close()

    -- open task list for writing
    hFile = io.open(STaskListFile, "w")

    -- write lines of file from start to altered line
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
    UpdateTaskContentVariable()
    SKIN:Bang('!SetOption', 'meterSyncTasks', 'FontColor', '255,255,0')
    SKIN:Bang('!UpdateMeasure', 'measureUpdateGist')
    SKIN:Bang('!CommandMeasure', 'measureUpdateGist', 'Run')
end
