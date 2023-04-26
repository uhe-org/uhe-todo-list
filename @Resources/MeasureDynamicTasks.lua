function Initialize()
    SDynamicMeterFile = SELF:GetOption('DynamicMeterFile')
    STaskListFile = SELF:GetOption('TaskListFile')
    SLogFile = SELF:GetOption('LogFile')
    SDynamicLogItems = SELF:GetOption('DynamicLogItems')
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

    -- dynamic measures checking task status
    for i = 1, #tasks, 1 do
        dynamicOutput[#dynamicOutput + 1] = "[MeasureTaskIcon" .. i .. "]"
        dynamicOutput[#dynamicOutput + 1] = "Measure=String"
        dynamicOutput[#dynamicOutput + 1] = "String=#check" .. i .. "state#"
        dynamicOutput[#dynamicOutput + 1] = "IfMatch=0"
        dynamicOutput[#dynamicOutput + 1] = "IfMatchAction=[!SetVariable check" ..
            i ..
            " fa-sq][!SetOption MeterRepeatingTask" ..
            i .. " InlineSetting \"\"][!SetOption MeterRepeatingTask" .. i .. " InlineSetting2 \"\"]"
        dynamicOutput[#dynamicOutput + 1] = "IfMatch2=1"
        dynamicOutput[#dynamicOutput + 1] = "IfMatchAction2=[!SetVariable check" ..
            i ..
            " fa-check-sq][!SetOption MeterRepeatingTask" ..
            i ..
            " InlineSetting Strikethrough][!SetOption MeterRepeatingTask" ..
            i .. " InlineSetting2 \"Color | 255,255,255,50\"]"
        dynamicOutput[#dynamicOutput + 1] = "IfMatch3=-1"
        dynamicOutput[#dynamicOutput + 1] = "IfMatchAction3=[!SetVariable check" ..
            i ..
            " fa-square-minus][!SetOption MeterRepeatingTask" ..
            i ..
            " InlineSetting Underline][!SetOption MeterRepeatingTask" ..
            i .. " InlineSetting2 \"Color | #LightHighlight#\"]"
        dynamicOutput[#dynamicOutput + 1] = "IfMatchMode=1"
        dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
    end

    -- dynamic meters
    for i = 1, #tasks, 1 do
        dynamicOutput[#dynamicOutput + 1] = "[MeterTaskIcon" .. i .. "Background]"
        dynamicOutput[#dynamicOutput + 1] = "Meter=Shape"
        dynamicOutput[#dynamicOutput + 1] = "Shape=Rectangle 0,0,[MeterTaskIcon" ..
            i .. ":W],([MeterRepeatingTask" .. i .. ":H]),#CornerRadius# | Fill LinearGradient Gradient | StrokeWidth 0"
        dynamicOutput[#dynamicOutput + 1] = "Gradient=0 | 0,0,0,0 ; 0.0"
        dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
        dynamicOutput[#dynamicOutput + 1] = "Group=BackgroundGroup"
        dynamicOutput[#dynamicOutput + 1] = "X=0"
        if (i == 1) then
            dynamicOutput[#dynamicOutput + 1] = "Y=[MeterTitleBackground:H]"
        else
            dynamicOutput[#dynamicOutput + 1] = "Y=R"
        end

        dynamicOutput[#dynamicOutput + 1] = "[MeterTaskIcon" .. i .. "]"
        dynamicOutput[#dynamicOutput + 1] = "Meter=String"
        dynamicOutput[#dynamicOutput + 1] = "MeasureName=MeasureTaskIcon" .. i
        dynamicOutput[#dynamicOutput + 1] = "Text=[#[#check" .. i .. "]]"
        dynamicOutput[#dynamicOutput + 1] = "FontFace=#RegularIconFace#"
        dynamicOutput[#dynamicOutput + 1] = "FontSize=#TaskFontSize#"
        dynamicOutput[#dynamicOutput + 1] = "Group=TextGroup"
        dynamicOutput[#dynamicOutput + 1] = "AntiAlias=1"
        dynamicOutput[#dynamicOutput + 1] = "X=r"
        dynamicOutput[#dynamicOutput + 1] = "Y=r"
        dynamicOutput[#dynamicOutput + 1] = "H=([MeterRepeatingTask" .. i .. ":H] - (#SidePadding# * 2))"
        dynamicOutput[#dynamicOutput + 1] = "LeftMouseUpAction=[!CommandMeasure \"MeasureDynamicTasks\" \"CheckLine(" ..
            i .. ")\"][!Update]"
        dynamicOutput[#dynamicOutput + 1] = "RightMouseUpAction=[!CommandMeasure \"MeasureDynamicTasks\" \"MarkCurrent(" ..
            i .. ")\"][!Update]"
        dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
        dynamicOutput[#dynamicOutput + 1] = "GradientAngle=180"
        dynamicOutput[#dynamicOutput + 1] = "Padding=#PaddingSize#"
        dynamicOutput[#dynamicOutput + 1] = "MouseOverAction=[!SetOption MeterRepeatingTask" ..
            i ..
            "Hover Highlight \"FillColor #LightHighlight#,#NoGradientTransparency#\"][!UpdateMeter MeterRepeatingTask" ..
            i .. "Hover][!Redraw]"
        dynamicOutput[#dynamicOutput + 1] = "MouseLeaveAction=[!SetOption MeterRepeatingTask" ..
            i .. "Hover Highlight \"FillColor 0,0,0,0\"][!UpdateMeter MeterRepeatingTask" .. i .. "Hover][!Redraw]"

        dynamicOutput[#dynamicOutput + 1] = "[MeterRepeatingTask" .. i .. "Background]"
        dynamicOutput[#dynamicOutput + 1] = "Meter=Shape"
        dynamicOutput[#dynamicOutput + 1] = "Shape=Rectangle 0,0,(#Width# - [MeterTaskIcon" ..
            i .. ":W]),([MeterRepeatingTask" .. i .. ":H]),#CornerRadius# | Fill LinearGradient Gradient | StrokeWidth 0"
        dynamicOutput[#dynamicOutput + 1] = "Shape2=Rectangle -#CornerRadius#,0,(#Width# - [MeterTaskIcon" ..
            i .. ":W]),([MeterRepeatingTask" .. i .. ":H]),0"
        dynamicOutput[#dynamicOutput + 1] =
            "Shape3=Rectangle (-#CornerRadius# * 2),0,(#CornerRadius# * 2),([MeterRepeatingTask" ..
            i .. ":H]),#CornerRadius#"
        dynamicOutput[#dynamicOutput + 1] = "Shape4=Combine Shape | Union Shape2 | Exclude Shape3"
        dynamicOutput[#dynamicOutput + 1] = "Gradient=0 | 0,0,0,0 ; 0.0"
        dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
        dynamicOutput[#dynamicOutput + 1] = "Group=OpaqueBackgroundGroup"
        dynamicOutput[#dynamicOutput + 1] = "X=R"
        dynamicOutput[#dynamicOutput + 1] = "Y=r"

        dynamicOutput[#dynamicOutput + 1] = "[MeterRepeatingTask" .. i .. "Hover]"
        dynamicOutput[#dynamicOutput + 1] = "Meter=Shape"
        dynamicOutput[#dynamicOutput + 1] = "Shape=Rectangle 0,0,(#Width# - [MeterTaskIcon" ..
            i .. ":W]),([MeterRepeatingTask" .. i .. ":H]),#CornerRadius# | Extend Highlight | StrokeWidth 0"
        dynamicOutput[#dynamicOutput + 1] = "Highlight=FillColor 0,0,0,0"
        dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
        dynamicOutput[#dynamicOutput + 1] = "X=r"
        dynamicOutput[#dynamicOutput + 1] = "Y=r"
        dynamicOutput[#dynamicOutput + 1] = "LeftMouseUpAction=[!CommandMeasure MeasureRenameTextBox" ..
            i .. " \"ExecuteBatch 1-2\"]"
        dynamicOutput[#dynamicOutput + 1] = "MouseScrollUpAction=[!CommandMeasure \"MeasureDynamicTasks\" \"MoveTask(" ..
            i .. ", -1)\"][!Refresh]"

        dynamicOutput[#dynamicOutput + 1] = "[MeterRepeatingTask" .. i .. "]"
        dynamicOutput[#dynamicOutput + 1] = "Meter=String"
        dynamicOutput[#dynamicOutput + 1] = "Text=" .. tasks[i]
        dynamicOutput[#dynamicOutput + 1] = "FontFace=#FontFace#"
        dynamicOutput[#dynamicOutput + 1] = "FontSize=#TaskFontSize#"
        dynamicOutput[#dynamicOutput + 1] = "Group=TextGroup"
        dynamicOutput[#dynamicOutput + 1] = "AntiAlias=1"
        dynamicOutput[#dynamicOutput + 1] = "ClipString=2"
        dynamicOutput[#dynamicOutput + 1] = "X=r"
        dynamicOutput[#dynamicOutput + 1] = "Y=r"
        dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
        dynamicOutput[#dynamicOutput + 1] = "W=(#Width# - [MeterTaskIcon" .. i .. ":W] - #SidePadding# * 2)"
        dynamicOutput[#dynamicOutput + 1] = "Padding=#PaddingSize#"
        dynamicOutput[#dynamicOutput + 1] = "MouseOverAction=[!SetOption MeterRepeatingTask" ..
            i ..
            "Hover Highlight \"FillColor #LightHighlight#,#NoGradientTransparency#\"][!UpdateMeter MeterRepeatingTask" ..
            i ..
            "Hover][!ShowMeterGroup HoverGroup" ..
            i ..
            "][!UpdateMeterGroup HoverGroup" ..
            i ..
            "][!SetOption MeterMoveUpTask" ..
            i ..
            " Text \"#fa-chevron-up#\"][!UpdateMeter MeterMoveUpTask" ..
            i ..
            "][!SetOptionGroup NotRecurringGroup" ..
            i .. " Text \"#fa-repeat#\"][!UpdateMeterGroup NotRecurringGroup" .. i .. "][!Redraw]"
        dynamicOutput[#dynamicOutput + 1] = "MouseLeaveAction=[!SetOption MeterRepeatingTask" ..
            i ..
            "Hover Highlight \"FillColor 0,0,0,0\"][!UpdateMeter MeterRepeatingTask" ..
            i ..
            "Hover][!HideMeterGroup HoverGroup" ..
            i ..
            "][!UpdateMeterGroup HoverGroup" ..
            i ..
            "][!SetOption MeterMoveUpTask" ..
            i ..
            " Text \"\"][!UpdateMeter MeterMoveUpTask" ..
            i ..
            "][!SetOptionGroup NotRecurringGroup" ..
            i .. " Text \"\"][!UpdateMeterGroup NotRecurringGroup" .. i .. "][!Redraw]"

        dynamicOutput[#dynamicOutput + 1] = "[MeasureRenameTextBox" .. i .. "]"
        dynamicOutput[#dynamicOutput + 1] = "Measure=Plugin"
        dynamicOutput[#dynamicOutput + 1] = "Plugin=InputText"
        dynamicOutput[#dynamicOutput + 1] = "DefaultValue=" .. tasks[i]
        dynamicOutput[#dynamicOutput + 1] = "FontFace=#FontFace#"
        dynamicOutput[#dynamicOutput + 1] = "FontSize=#TaskFontSize#"
        dynamicOutput[#dynamicOutput + 1] = "Group=TextBoxGroup | TextGroup"
        dynamicOutput[#dynamicOutput + 1] = "AntiAlias=1"
        dynamicOutput[#dynamicOutput + 1] = "X=([MeterTaskIcon" .. i .. ":W] + #SidePadding#)"
        dynamicOutput[#dynamicOutput + 1] = "Y=([MeterRepeatingTask" .. i .. ":Y] + #SidePadding#)"
        dynamicOutput[#dynamicOutput + 1] = "W=(#Width# - ([MeterTaskIcon" .. i .. ":W] + #SidePadding# * 2))"
        dynamicOutput[#dynamicOutput + 1] = "H=([MeterRepeatingTask" .. i .. ":H] - (#SidePadding# * 2))"
        dynamicOutput[#dynamicOutput + 1] = "Command1=[!SetVariable placeholder $UserInput$"
        dynamicOutput[#dynamicOutput + 1] = "Command2=[!CommandMeasure \"MeasureDynamicTasks\" \"RenameTask(" ..
            i .. ", '[MeasureRenameTextBox" .. i .. "]')\"][!Refresh]"
        dynamicOutput[#dynamicOutput + 1] = "Substitute=\"'\":\"\\'\""

        dynamicOutput[#dynamicOutput + 1] = "[MeterToggleRecurring" .. i .. "Background]"
        dynamicOutput[#dynamicOutput + 1] = "Meter=Shape"
        dynamicOutput[#dynamicOutput + 1] = "Shape=Rectangle 0,0,([MeterTitleBackground:H] / 2),([MeterRepeatingTask" ..
            i .. ":H]),#CornerRadius# | Fill LinearGradient Gradient | StrokeWidth 0"
        dynamicOutput[#dynamicOutput + 1] = "Gradient=0 | 0,0,0,0 ; 0.0"
        dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
        dynamicOutput[#dynamicOutput + 1] = "Group=BackgroundGroup | HoverGroup" .. i
        dynamicOutput[#dynamicOutput + 1] = "X=(-[MeterTitleBackground:H] / 2)R"
        dynamicOutput[#dynamicOutput + 1] = "Y=[MeterRepeatingTask" .. i .. ":Y]"
        dynamicOutput[#dynamicOutput + 1] = "Hidden=1"
        dynamicOutput[#dynamicOutput + 1] = "MouseOverAction=[!SetOption MeterToggleRecurring" ..
            i ..
            "Hover Highlight \"FillColor #LightHighlight#,#NoGradientTransparency#\"][!UpdateMeter MeterToggleRecurring" ..
            i .. "Hover][!Redraw]"
        dynamicOutput[#dynamicOutput + 1] = "MouseLeaveAction=[!SetOption MeterToggleRecurring" ..
            i .. "Hover Highlight \"FillColor 0,0,0,0\"][!UpdateMeter MeterToggleRecurring" .. i .. "Hover][!Redraw]"
        if string.find(recurring, "|" .. i .. "|") ~= nil then
            dynamicOutput[#dynamicOutput + 1] =
                "LeftMouseUpAction=[!CommandMeasure \"MeasureDynamicTasks\" \"RenameTask(" ..
                i .. ", '" .. tasks[i] .. "')][!Refresh]"
        else
            dynamicOutput[#dynamicOutput + 1] =
                "LeftMouseUpAction=[!CommandMeasure \"MeasureDynamicTasks\" \"RenameTask(" ..
                i .. ", '" .. tasks[i] .. "|R')][!Refresh]"
        end

        dynamicOutput[#dynamicOutput + 1] = "[MeterToggleRecurring" .. i .. "Hover]"
        dynamicOutput[#dynamicOutput + 1] = "Meter=Shape"
        dynamicOutput[#dynamicOutput + 1] = "Shape=Rectangle 0,0,([MeterTitleBackground:H] / 2),([MeterRepeatingTask" ..
            i .. ":H]),#CornerRadius# | Extend Highlight | StrokeWidth 0"
        dynamicOutput[#dynamicOutput + 1] = "Highlight=FillColor 0,0,0,0"
        dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
        dynamicOutput[#dynamicOutput + 1] = "X=r"
        dynamicOutput[#dynamicOutput + 1] = "Y=[MeterRepeatingTask" .. i .. ":Y]"

        dynamicOutput[#dynamicOutput + 1] = "[MeterToggleRecurring" .. i .. "]"
        dynamicOutput[#dynamicOutput + 1] = "Meter=String"
        dynamicOutput[#dynamicOutput + 1] = "FontFace=#IconFace#"
        dynamicOutput[#dynamicOutput + 1] = "FontSize=#TaskFontSize#"
        dynamicOutput[#dynamicOutput + 1] = "AntiAlias=1"
        dynamicOutput[#dynamicOutput + 1] = "X=([MeterTitleBackground:H] / 4)r"
        dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
        dynamicOutput[#dynamicOutput + 1] = "Y=([MeterRepeatingTask" .. i .. ":Y] + ([MeterRepeatingTask" ..
            i .. ":H] / 2))"
        if string.find(recurring, "|" .. i .. "|") ~= nil then
            dynamicOutput[#dynamicOutput + 1] = "Text=#fa-repeat#"
            dynamicOutput[#dynamicOutput + 1] = "FontColor=#LightHighlight#"
        else
            dynamicOutput[#dynamicOutput + 1] = "Group=TextGroup | NotRecurringGroup" .. i
        end
        dynamicOutput[#dynamicOutput + 1] = "StringAlign=CenterCenter"
        dynamicOutput[#dynamicOutput + 1] = "H=([MeterRepeatingTask" .. i .. ":H] / 2)"
        dynamicOutput[#dynamicOutput + 1] = "W=([MeterTitleBackground:H] / 2)"

        if (i >= 2) then
            dynamicOutput[#dynamicOutput + 1] = "[MeterMoveUpTask" .. i .. "Background]"
            dynamicOutput[#dynamicOutput + 1] = "Meter=Shape"
            dynamicOutput[#dynamicOutput + 1] = "Shape=Rectangle 0,0,([MeterTitleBackground:H] / 2),([MeterRepeatingTask" ..
                i .. ":H]),#CornerRadius# | Fill LinearGradient Gradient | StrokeWidth 0"
            dynamicOutput[#dynamicOutput + 1] = "Gradient=0 | 0,0,0,0 ; 0.0"
            dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
            dynamicOutput[#dynamicOutput + 1] = "Group=BackgroundGroup | HoverGroup" .. i
            dynamicOutput[#dynamicOutput + 1] = "X=(-[MeterTitleBackground:H] / 4 - [MeterTitleBackground:H] / 2)r"
            dynamicOutput[#dynamicOutput + 1] = "Y=[MeterRepeatingTask" .. i .. ":Y]"
            dynamicOutput[#dynamicOutput + 1] = "Hidden=1"
            dynamicOutput[#dynamicOutput + 1] = "LeftMouseUpAction=[!CommandMeasure \"MeasureDynamicTasks\" \"MoveTask(" ..
                i .. ", -1)\"][!Refresh]"
            dynamicOutput[#dynamicOutput + 1] = "MouseOverAction=[!SetOption MeterMoveUpTask" ..
                i ..
                "Hover Highlight \"FillColor #LightHighlight#,#NoGradientTransparency#\"][!UpdateMeter MeterMoveUpTask" ..
                i .. "Hover][!Redraw]"
            dynamicOutput[#dynamicOutput + 1] = "MouseLeaveAction=[!SetOption MeterMoveUpTask" ..
                i .. "Hover Highlight \"FillColor 0,0,0,0\"][!UpdateMeter MeterMoveUpTask" .. i .. "Hover][!Redraw]"

            dynamicOutput[#dynamicOutput + 1] = "[MeterMoveUpTask" .. i .. "Hover]"
            dynamicOutput[#dynamicOutput + 1] = "Meter=Shape"
            dynamicOutput[#dynamicOutput + 1] = "Shape=Rectangle 0,0,([MeterTitleBackground:H] / 2),([MeterRepeatingTask" ..
                i .. ":H]),#CornerRadius# | Extend Highlight | StrokeWidth 0"
            dynamicOutput[#dynamicOutput + 1] = "Highlight=FillColor 0,0,0,0"
            dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
            dynamicOutput[#dynamicOutput + 1] = "X=r"
            dynamicOutput[#dynamicOutput + 1] = "Y=[MeterRepeatingTask" .. i .. ":Y]"

            dynamicOutput[#dynamicOutput + 1] = "[MeterMoveUpTask" .. i .. "]"
            dynamicOutput[#dynamicOutput + 1] = "Meter=String"
            dynamicOutput[#dynamicOutput + 1] = "FontFace=#IconFace#"
            dynamicOutput[#dynamicOutput + 1] = "FontSize=#TaskFontSize#"
            dynamicOutput[#dynamicOutput + 1] = "Group=TextGroup"
            dynamicOutput[#dynamicOutput + 1] = "AntiAlias=1"
            dynamicOutput[#dynamicOutput + 1] = "X=([MeterTitleBackground:H] / 4)r"
            dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
            dynamicOutput[#dynamicOutput + 1] = "Y=([MeterRepeatingTask" ..
                i .. ":Y] + ([MeterRepeatingTask" .. i .. ":H] / 2))"
            dynamicOutput[#dynamicOutput + 1] = "H=([MeterRepeatingTask" .. i .. ":H] / 2)"
            dynamicOutput[#dynamicOutput + 1] = "W=([MeterTitleBackground:H] / 2)"
            dynamicOutput[#dynamicOutput + 1] = "StringAlign=CenterCenter"
        end
    end

    dynamicOutput[#dynamicOutput + 1] = "[Variables]"

    -- variables for each task
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

    -- create dynamic meter file
    local File = io.open(SDynamicMeterFile, 'w')

    -- error handling
    if not File then
        print('Update: unable to open file at ' .. SDynamicMeterFile)
        return
    end

    File:write(table.concat(dynamicOutput, '\n'))
    File:close()

    UpdateDynamicLogItems()

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
    UpdateDynamicLogItems()
end

function UpdateDynamicLogItems()
    SKIN:Bang('!SetOption', 'MeterLogs', 'Text', GetDynamicLogItems())
end

function GetDynamicLogItems()
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
    local restOfFile
    local lineCt = 1
    local nearLine

    -- read through task list
    for line in hFile:lines() do
        -- find the lines to be swapped
        if (lineCt == lineNumber) then
            -- swap task
            if (direction == -1) then
                nearLine = lines[#lines]
                lines[#lines + 1] = line
                lines[#lines - 1] = lines[#lines]
                lines[#lines] = nearLine

                -- todo: add other direction support
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

function UpdateTaskContentVariable()
    local taskContent = ""

    for line in io.lines(STaskListFile) do
        taskContent = taskContent..line.."\\n"
    end

    SKIN:Bang('!SetVariable', 'taskContent', taskContent)
end

function UpdateGist()
    UpdateTaskContentVariable()
    SKIN:Bang('!SetOption', 'meterSyncTasks', 'FontColor', '255,255,0')
    SKIN:Bang('!UpdateMeasure', 'measureUpdateGist')
    SKIN:Bang('!CommandMeasure', 'measureUpdateGist', 'Run')
end
