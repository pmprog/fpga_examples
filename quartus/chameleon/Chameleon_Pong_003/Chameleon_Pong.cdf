/* Quartus II 32-bit Version 11.1 Build 216 11/23/2011 Service Pack 1 SJ Web Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Ign)
		Device PartName(DUMMY) MfrSpec(OpMask(0));
	P ActionCode(Cfg)
		Device PartName(EP3C25E144) Path("E:/FPGA/Chameleon_Pong/") File("Chameleon_Pong.sof") MfrSpec(OpMask(1));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
