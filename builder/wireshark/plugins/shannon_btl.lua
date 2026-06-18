-- Samsung Shannon Back Trace Log (BTL) Custom Wireshark Dissector
-- Transported over UDP (e.g. port 25000) or serial/USB capture envelopes

local shannon_btl_proto = Proto("shannon_btl", "Samsung Shannon Back Trace Log (BTL)")

-- Fields definition
local f_magic   = ProtoField.string("shannon_btl.magic", "Magic Signature")
local f_len     = ProtoField.uint16("shannon_btl.len", "Payload Length", base.DEC)
local f_task_id = ProtoField.uint16("shannon_btl.task", "Shannon Task ID", base.HEX, {
    [0x0001] = "Task_PHY",
    [0x0002] = "Task_MAC",
    [0x0003] = "Task_RLC",
    [0x0004] = "Task_PDCP",
    [0x000c] = "Task_RRC",
    [0x000d] = "Task_NAS",
    [0x000e] = "Task_USIM",
    [0x0010] = "Task_CC",
    [0x0011] = "Task_SS",
    [0x0012] = "Task_SMS",
    [0x0020] = "Task_SNDCP",
    [0x0032] = "Task_SM",
    [0x0040] = "Task_L1"
})
local f_level   = ProtoField.uint8("shannon_btl.level", "Log Level", base.DEC, {
    [0] = "DEBUG",
    [1] = "INFO",
    [2] = "WARNING",
    [3] = "ERROR",
    [4] = "FATAL"
})
local f_event   = ProtoField.uint16("shannon_btl.event", "Event ID", base.HEX)
local f_msg     = ProtoField.string("shannon_btl.msg", "Log Message")

shannon_btl_proto.fields = { f_magic, f_len, f_task_id, f_level, f_event, f_msg }

function shannon_btl_proto.dissector(tvb, pinfo, tree)
    local tvb_len = tvb:len()
    if tvb_len < 10 then return end -- Header requires 10 bytes minimum (3B magic, 2B len, 2B task, 1B level, 2B event)
    
    -- Check magic header
    local magic_str = tvb(0, 3):string()
    if magic_str ~= "BTL" then return end
    
    pinfo.cols.protocol = "Shannon-BTL"
    
    local main_tree = tree:add(shannon_btl_proto, tvb(), "Samsung Shannon Back Trace Log (BTL)")
    
    main_tree:add(f_magic, tvb(0, 3))
    
    local msg_len = tvb(3, 2):uint()
    main_tree:add(f_len, tvb(3, 2))
    
    local task_val = tvb(5, 2):uint()
    main_tree:add(f_task_id, tvb(5, 2))
    
    local lvl_val = tvb(7, 1):uint()
    main_tree:add(f_level, tvb(7, 1))
    
    main_tree:add(f_event, tvb(8, 2))
    
    local level_strs = { [0]="DBG", [1]="INF", [2]="WRN", [3]="ERR", [4]="FTL" }
    local lvl_str = level_strs[lvl_val] or "LOG"
    
    local string_len = tvb_len - 10
    if string_len > 0 then
        local log_msg = tvb(10, string_len):string()
        main_tree:add(f_msg, tvb(10, string_len))
        
        pinfo.cols.info = string.format("[%s] Task: 0x%04X - %s", lvl_str, task_val, log_msg)
    else
        pinfo.cols.info = string.format("[%s] Task: 0x%04X - (Empty Message)", lvl_str, task_val)
    end
end

-- Register BTL on UDP port 25000 by default
local udp_table = DissectorTable.get("udp.port")
udp_table:add(25000, shannon_btl_proto)
