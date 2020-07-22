local EditorLib = {};
EditorLib.new = function(Name) 
    local Name = Name or "EditorLib"
    local EditorLibInstance = {
        Client = {}; 
        Queue = {};
    };
    local Queue = EditorLibInstance.Queue;
    local Client = EditorLibInstance.Client;
    local BackupClient = {};
    local function insertToClient(Name, Value) 
        Client[Name] = Value;
        BackupClient[Name] = Value;
    end;
    function EditorLibInstance:AddToQueue(Name, ...)
        table.insert(Queue, {Type = "Function", Name = Name, Args = {...}});
        insertToClient(Name, function() end);
    end;
    function EditorLibInstance:AddToQueueTable(Name, Index) 
        table.insert(Queue, {Type = "Table", Name = Name, Index = Index});
        insertToClient(Name, {});
    end;
    function EditorLibInstance:Scan() 
        local QueueLength = #EditorLibInstance.Queue;
        local QueuesPassed = 0;
        for i, v in pairs(getgc(true)) do 
            if typeof(v) == "function" and islclosure(v) and not is_synapse_function(v) then
                local CurrentQueue = Queue[QueuesPassed + 1];
                CurrentQueue = (CurrentQueue and CurrentQueue.Type == "Function") and CurrentQueue;
                local Constants = debug.getconstants(v);
                local ConstantsFound = 0;
                local Args = CurrentQueue and CurrentQueue.Args or {};
                for _, Arg in pairs(Args) do 
                    if table.find(Constants, Arg) then 
                        ConstantsFound = ConstantsFound + 1;
                    end;
                end;
                if ConstantsFound == #Args and CurrentQueue then 
                    Client[CurrentQueue.Name] = v;
                    QueuesPassed = QueuesPassed + 1;
                end;
            end;
            if typeof(v) == "table" then 
                local CurrentQueue = Queue[QueuesPassed + 1];
                CurrentQueue = (CurrentQueue and CurrentQueue.Type == "Table") and CurrentQueue;
                if CurrentQueue and rawget(v, CurrentQueue.Index) then 
                    Client[CurrentQueue.Name] = v;
                    QueuesPassed = QueuesPassed + 1;
                end;
            end
            if QueuesPassed == QueuesLength then -- hacker moment
                break;
            end;
        end;
    end;
    function EditorLibInstance:CheckClient() 
        local function FindValue(Value) 
            local Found = false;
            for i, v in pairs(BackupClient) do 
                if v == Value then 
                    Found = true;
                end;
            end;
            return Found;
        end;
        local Failed = false;
        for i, v in pairs(Client) do 
            if FindValue(v) then 
                messagebox("Failed to scan \"" .. i .. "\"", Name, 0x10);
                Failed = true;
            end;
        end;
        return Failed;
    end;
    return EditorLibInstance;
end;

print("sex")