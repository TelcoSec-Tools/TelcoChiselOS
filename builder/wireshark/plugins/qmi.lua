-- Qualcomm MSM Interface (QMUX/QMI) Custom Wireshark Dissector
-- Transported over custom encapsulation or tunneled over UDP (e.g. port 7777)

local qmi_proto = Proto("qmi", "Qualcomm MSM Interface (QMI)")

-- QMUX Header Fields
local f_qmux_start = ProtoField.uint8("qmi.qmux.start", "QMUX Start Byte", base.HEX)
local f_qmux_len   = ProtoField.uint16("qmi.qmux.len", "QMUX Packet Length", base.DEC)
local f_qmux_flags = ProtoField.uint8("qmi.qmux.flags", "Control Flags", base.HEX)
local f_qmux_svc   = ProtoField.uint8("qmi.qmux.service", "Service Type", base.HEX, {
    [0x01] = "WDS (Wireless Data Service)",
    [0x02] = "DMS (Device Management Service)",
    [0x03] = "NAS (Network Access Service)",
    [0x04] = "WMS (Wireless Messaging Service)",
    [0x05] = "PDS (Position Determination Service)",
    [0x06] = "AUTH (Authentication Service)",
    [0x09] = "VOICE (Voice Service)",
    [0x1a] = "WDA (Wireless Data Administration)",
    [0xe0] = "CTL (Control Service)"
})
local f_qmux_client = ProtoField.uint8("qmi.qmux.client", "Client ID", base.DEC)

-- QMI Message Header Fields
local f_qmi_flags   = ProtoField.uint8("qmi.msg.flags", "Message Flags", base.HEX, {
    [0x00] = "Request",
    [0x01] = "Response",
    [0x02] = "Indication"
})
local f_qmi_tx_id   = ProtoField.uint16("qmi.msg.tx_id", "Transaction ID", base.DEC)
local f_qmi_msg_id  = ProtoField.uint16("qmi.msg.msg_id", "Message ID (Command)", base.HEX)
local f_qmi_msg_len = ProtoField.uint16("qmi.msg.len", "Message Payload Length", base.DEC)

-- TLV Parameters Fields
local f_tlv_type = ProtoField.uint8("qmi.tlv.type", "TLV Type", base.HEX)
local f_tlv_len  = ProtoField.uint16("qmi.tlv.len", "TLV Length", base.DEC)
local f_tlv_val  = ProtoField.bytes("qmi.tlv.value", "TLV Value")

qmi_proto.fields = {
    f_qmux_start, f_qmux_len, f_qmux_flags, f_qmux_svc, f_qmux_client,
    f_qmi_flags, f_qmi_tx_id, f_qmi_msg_id, f_qmi_msg_len,
    f_tlv_type, f_tlv_len, f_tlv_val
}

function qmi_proto.dissector(tvb, pinfo, tree)
    local tvb_len = tvb:len()
    if tvb_len < 6 then return end -- QMUX header is 6 bytes minimum
    
    -- Check if start byte is 0x01 (QMUX Start)
    local start_byte = tvb(0, 1):uint()
    if start_byte ~= 0x01 then return end
    
    pinfo.cols.protocol = "QMI"
    
    local main_tree = tree:add(qmi_proto, tvb(), "Qualcomm MSM Interface (QMI)")
    local qmux_tree = main_tree:add(tvb(0, 6), "QMUX Header")
    
    qmux_tree:add(f_qmux_start, tvb(0, 1))
    local qmux_len = tvb(1, 2):le_uint()
    qmux_tree:add_le(f_qmux_len, tvb(1, 2))
    qmux_tree:add(f_qmux_flags, tvb(3, 1))
    
    local svc_type = tvb(4, 1):uint()
    qmux_tree:add(f_qmux_svc, tvb(4, 1))
    qmux_tree:add(f_qmux_client, tvb(5, 1))
    
    -- QMI Message Header (starts at offset 6)
    if tvb_len < 12 then return end -- Message Header requires another 6 bytes
    
    local msg_tree = main_tree:add(tvb(6), "QMI Message")
    
    msg_tree:add(f_qmi_flags, tvb(6, 1))
    msg_tree:add_le(f_qmi_tx_id, tvb(7, 2))
    
    local msg_id = tvb(9, 2):le_uint()
    msg_tree:add_le(f_qmi_msg_id, tvb(9, 2))
    
    local msg_len = tvb(11, 2):le_uint()
    msg_tree:add_le(f_qmi_msg_len, tvb(11, 2))
    
    pinfo.cols.info = string.format("Service: 0x%02X, Message: 0x%04X, TxID: %d", svc_type, msg_id, tvb(7, 2):le_uint())
    
    -- TLVs start at offset 13
    local offset = 13
    local tlv_tree = msg_tree:add(tvb(offset), "TLV Parameters")
    
    while offset < tvb_len do
        if offset + 3 > tvb_len then break end -- Must have at least Type (1B) and Length (2B)
        
        local t_type = tvb(offset, 1):uint()
        local t_len = tvb(offset + 1, 2):le_uint()
        
        if offset + 3 + t_len > tvb_len then break end
        
        local single_tlv = tlv_tree:add(tvb(offset, 3 + t_len), string.format("TLV Type: 0x%02X (Length: %d)", t_type, t_len))
        single_tlv:add(f_tlv_type, tvb(offset, 1))
        single_tlv:add_le(f_tlv_len, tvb(offset + 1, 2))
        if t_len > 0 then
            single_tlv:add(f_tlv_val, tvb(offset + 3, t_len))
        end
        
        offset = offset + 3 + t_len
    end
end

-- Bind QMI to UDP port 7777 by default
local udp_table = DissectorTable.get("udp.port")
udp_table:add(7777, qmi_proto)
