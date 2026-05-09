/* Faimily of opcode 0000 */
parameter ALU_OP   = 4'b0000;
parameter ADD_OPex = 4'b0101;
parameter SUB_OPex = 4'b1001;
parameter CMP_OPex = 4'b1011;
parameter AND_OPex = 4'b0001;
parameter OR_OPex  = 4'b0010;
parameter XOR_OPex = 4'b0011;
parameter MOV_OPex = 4'b1101;
  
/* Immediate opcodes */
parameter ADDI_OP  = 4'b0101;
parameter SUBI_OP  = 4'b1001;
parameter CMPI_OP  = 4'b1011;
parameter ANDI_OP  = 4'b0001;
parameter ORI_OP   = 4'b0010;
parameter XORI_OP  = 4'b0011;
parameter MOVI_OP  = 4'b1101;
parameter LUI_OP   = 4'b1111;
parameter Bcond_OP = 4'b1100;
  
/* Faimily of opcode 0100 */
parameter MEM_OP     = 4'b0100;
parameter LOAD_OPex  = 4'b0000;
parameter STOR_OPex  = 4'b0100;
parameter Jcond_OPex = 4'b1100;
parameter JAL_OPex   = 4'b1000;

/* Faimily of opcode 1000 */
parameter SHI_OP    = 4'b1000;
parameter SHII_OPex = 3'b000;

