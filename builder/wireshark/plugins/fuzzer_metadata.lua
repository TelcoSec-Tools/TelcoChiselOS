-- TelcoSec Fuzzer Metadata Custom Wireshark Dissector
-- Chained dissector to extract fuzzer testcase metadata and pass payload to native dissectors
-- Transported over UDP (e.g. port 9999) or raw loopback encapsulation

local fuzzer_meta_proto = Proto("fuzzer_meta", "TelcoSec Fuzzer Metadata")

-- Fields definition
local f_magic   = ProtoField.string("fuzzer_meta.magic", "Fuzzer Magic")
local f_case_id = ProtoField.uint32("fuzzer_meta.case_id", "Test Case ID", base.DEC)
local f_seed    = ProtoField.uint32("fuzzer_meta.seed", "Mutation Seed", base.DEC)
local f_proto   = ProtoField.uint8("fuzzer_meta.protocol", "Target Protocol", base.DEC, {
    [1] = "Diameter",
    [2] = "GTPv2",
    [3] = "GSM-MAP",
    [4] = "SIP"
})
local f_pay_len = ProtoField.uint16("fuzzer_meta.pay_len", "Payload Length", base.DEC)

fuzzer_meta_proto.fields = { f_magic, f_case_id, f_seed, f_proto, f_pay_len }

function fuzzer_meta_proto.dissector(tvb, pinfo, tree)
    local tvb_len = tvb:len()
    if tvb_len < 15 then return end -- 4B magic, 4B case_id, 4B seed, 1B proto, 2B pay_len = 15B minimum
    
    local magic_str = tvb(0, 4):string()
    if magic_str ~= "FUZZ" then return end
    
    pinfo.cols.protocol = "Fuzz-Meta"
    
    local main_tree = tree:add(fuzzer_meta_proto, tvb(), "TelcoSec Fuzzer Metadata")
    
    main_tree:add(f_magic, tvb(0, 4))
    
    local case_id = tvb(4, 4):uint()
    main_tree:add(f_case_id, tvb(4, 4))
    
    local seed = tvb(8, 4):uint()
    main_tree:add(f_seed, tvb(8, 4))
    
    local proto_val = tvb(12, 1):uint()
    main_tree:add(f_proto, tvb(12, 1))
    
    local pay_len = tvb(13, 2):uint()
    main_tree:add(f_pay_len, tvb(13, 2))
    
    pinfo.cols.info = string.format("Case: %d, Seed: %d, Next Protocol: %d", case_id, seed, proto_val)
    
    -- Chain to native dissectors starting from offset 15
    local payload_offset = 15
    if tvb_len > payload_offset then
        local payload_tvb = tvb(payload_offset):tvb()
        
        local sub_dissector = nil
        if proto_val == 1 then
            sub_dissector = Dissector.get("diameter")
        elseif proto_val == 2 then
            sub_dissector = Dissector.get("gtpv2")
        elseif proto_val == 3 then
            sub_dissector = Dissector.get("gsm_map")
        elseif proto_val == 4 then
            sub_dissector = Dissector.get("sip")
        end
        
        if sub_dissector then
            sub_dissector:call(payload_tvb, pinfo, tree)
        else
            -- Fallback: show raw data if no dissector is found
            main_tree:add(tvb(payload_offset), "Payload Data (No Dissector)")
        end
    end
end

-- Register Fuzzer Metadata on UDP port 9999 by default
local udp_table = DissectorTable.get("udp.port")
udp_table:add(9999, fuzzer_meta_proto)
