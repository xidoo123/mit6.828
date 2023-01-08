
obj/user/faultregs.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 66 05 00 00       	call   800597 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 11 28 80 00       	push   $0x802811
  800049:	68 e0 27 80 00       	push   $0x8027e0
  80004e:	e8 7d 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 f0 27 80 00       	push   $0x8027f0
  80005c:	68 f4 27 80 00       	push   $0x8027f4
  800061:	e8 6a 06 00 00       	call   8006d0 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 04 28 80 00       	push   $0x802804
  800077:	e8 54 06 00 00       	call   8006d0 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 08 28 80 00       	push   $0x802808
  80008e:	e8 3d 06 00 00       	call   8006d0 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 12 28 80 00       	push   $0x802812
  8000a6:	68 f4 27 80 00       	push   $0x8027f4
  8000ab:	e8 20 06 00 00       	call   8006d0 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 04 28 80 00       	push   $0x802804
  8000c3:	e8 08 06 00 00       	call   8006d0 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 08 28 80 00       	push   $0x802808
  8000d5:	e8 f6 05 00 00       	call   8006d0 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 16 28 80 00       	push   $0x802816
  8000ed:	68 f4 27 80 00       	push   $0x8027f4
  8000f2:	e8 d9 05 00 00       	call   8006d0 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 04 28 80 00       	push   $0x802804
  80010a:	e8 c1 05 00 00       	call   8006d0 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 08 28 80 00       	push   $0x802808
  80011c:	e8 af 05 00 00       	call   8006d0 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 1a 28 80 00       	push   $0x80281a
  800134:	68 f4 27 80 00       	push   $0x8027f4
  800139:	e8 92 05 00 00       	call   8006d0 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 04 28 80 00       	push   $0x802804
  800151:	e8 7a 05 00 00       	call   8006d0 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 08 28 80 00       	push   $0x802808
  800163:	e8 68 05 00 00       	call   8006d0 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 1e 28 80 00       	push   $0x80281e
  80017b:	68 f4 27 80 00       	push   $0x8027f4
  800180:	e8 4b 05 00 00       	call   8006d0 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 04 28 80 00       	push   $0x802804
  800198:	e8 33 05 00 00       	call   8006d0 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 08 28 80 00       	push   $0x802808
  8001aa:	e8 21 05 00 00       	call   8006d0 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 22 28 80 00       	push   $0x802822
  8001c2:	68 f4 27 80 00       	push   $0x8027f4
  8001c7:	e8 04 05 00 00       	call   8006d0 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 04 28 80 00       	push   $0x802804
  8001df:	e8 ec 04 00 00       	call   8006d0 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 08 28 80 00       	push   $0x802808
  8001f1:	e8 da 04 00 00       	call   8006d0 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 26 28 80 00       	push   $0x802826
  800209:	68 f4 27 80 00       	push   $0x8027f4
  80020e:	e8 bd 04 00 00       	call   8006d0 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 04 28 80 00       	push   $0x802804
  800226:	e8 a5 04 00 00       	call   8006d0 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 08 28 80 00       	push   $0x802808
  800238:	e8 93 04 00 00       	call   8006d0 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 2a 28 80 00       	push   $0x80282a
  800250:	68 f4 27 80 00       	push   $0x8027f4
  800255:	e8 76 04 00 00       	call   8006d0 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 04 28 80 00       	push   $0x802804
  80026d:	e8 5e 04 00 00       	call   8006d0 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 08 28 80 00       	push   $0x802808
  80027f:	e8 4c 04 00 00       	call   8006d0 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 2e 28 80 00       	push   $0x80282e
  800297:	68 f4 27 80 00       	push   $0x8027f4
  80029c:	e8 2f 04 00 00       	call   8006d0 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 04 28 80 00       	push   $0x802804
  8002b4:	e8 17 04 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 35 28 80 00       	push   $0x802835
  8002c4:	68 f4 27 80 00       	push   $0x8027f4
  8002c9:	e8 02 04 00 00       	call   8006d0 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 08 28 80 00       	push   $0x802808
  8002e3:	e8 e8 03 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 35 28 80 00       	push   $0x802835
  8002f3:	68 f4 27 80 00       	push   $0x8027f4
  8002f8:	e8 d3 03 00 00       	call   8006d0 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 04 28 80 00       	push   $0x802804
  800312:	e8 b9 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 39 28 80 00       	push   $0x802839
  800322:	e8 a9 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 08 28 80 00       	push   $0x802808
  800338:	e8 93 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 39 28 80 00       	push   $0x802839
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 04 28 80 00       	push   $0x802804
  80035a:	e8 71 03 00 00       	call   8006d0 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 08 28 80 00       	push   $0x802808
  80036c:	e8 5f 03 00 00       	call   8006d0 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 04 28 80 00       	push   $0x802804
  80037e:	e8 4d 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 39 28 80 00       	push   $0x802839
  80038e:	e8 3d 03 00 00       	call   8006d0 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 a0 28 80 00       	push   $0x8028a0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 47 28 80 00       	push   $0x802847
  8003c6:	e8 2c 02 00 00       	call   8005f7 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 5f 28 80 00       	push   $0x80285f
  80043b:	68 6d 28 80 00       	push   $0x80286d
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba 58 28 80 00       	mov    $0x802858,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 f3 0b 00 00       	call   801058 <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 74 28 80 00       	push   $0x802874
  800472:	6a 5c                	push   $0x5c
  800474:	68 47 28 80 00       	push   $0x802847
  800479:	e8 79 01 00 00       	call   8005f7 <_panic>
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <umain>:

void
umain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800486:	68 a0 03 80 00       	push   $0x8003a0
  80048b:	e8 d8 0d 00 00       	call   801268 <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b1:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b7:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004bd:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c3:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c9:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004cf:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004d4:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004ea:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f0:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f6:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004fc:	89 15 14 40 80 00    	mov    %edx,0x804014
  800502:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800508:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80050d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800513:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800519:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80051f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800525:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80052b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800531:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800537:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80053c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 24 40 80 00       	mov    %eax,0x804024
  80054a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800555:	74 10                	je     800567 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	68 d4 28 80 00       	push   $0x8028d4
  80055f:	e8 6c 01 00 00       	call   8006d0 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 87 28 80 00       	push   $0x802887
  800579:	68 98 28 80 00       	push   $0x802898
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba 58 28 80 00       	mov    $0x802858,%edx
  800588:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058d:	e8 a1 fa ff ff       	call   800033 <check_regs>
}
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8005a2:	e8 73 0a 00 00       	call   80101a <sys_getenvid>
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b4:	a3 b4 40 80 00       	mov    %eax,0x8040b4

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b9:	85 db                	test   %ebx,%ebx
  8005bb:	7e 07                	jle    8005c4 <libmain+0x2d>
		binaryname = argv[0];
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	e8 b2 fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  8005ce:	e8 0a 00 00 00       	call   8005dd <exit>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005e3:	e8 b6 0e 00 00       	call   80149e <close_all>
	sys_env_destroy(0);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 e7 09 00 00       	call   800fd9 <sys_env_destroy>
}
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    

008005f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800605:	e8 10 0a 00 00       	call   80101a <sys_getenvid>
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	ff 75 08             	pushl  0x8(%ebp)
  800613:	56                   	push   %esi
  800614:	50                   	push   %eax
  800615:	68 00 29 80 00       	push   $0x802900
  80061a:	e8 b1 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061f:	83 c4 18             	add    $0x18,%esp
  800622:	53                   	push   %ebx
  800623:	ff 75 10             	pushl  0x10(%ebp)
  800626:	e8 54 00 00 00       	call   80067f <vcprintf>
	cprintf("\n");
  80062b:	c7 04 24 10 28 80 00 	movl   $0x802810,(%esp)
  800632:	e8 99 00 00 00       	call   8006d0 <cprintf>
  800637:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80063a:	cc                   	int3   
  80063b:	eb fd                	jmp    80063a <_panic+0x43>

0080063d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	53                   	push   %ebx
  800641:	83 ec 04             	sub    $0x4,%esp
  800644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800647:	8b 13                	mov    (%ebx),%edx
  800649:	8d 42 01             	lea    0x1(%edx),%eax
  80064c:	89 03                	mov    %eax,(%ebx)
  80064e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800651:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800655:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065a:	75 1a                	jne    800676 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	68 ff 00 00 00       	push   $0xff
  800664:	8d 43 08             	lea    0x8(%ebx),%eax
  800667:	50                   	push   %eax
  800668:	e8 2f 09 00 00       	call   800f9c <sys_cputs>
		b->idx = 0;
  80066d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800673:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800676:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80067a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800688:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068f:	00 00 00 
	b.cnt = 0;
  800692:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800699:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	ff 75 08             	pushl  0x8(%ebp)
  8006a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 3d 06 80 00       	push   $0x80063d
  8006ae:	e8 54 01 00 00       	call   800807 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	e8 d4 08 00 00       	call   800f9c <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 9d ff ff ff       	call   80067f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	83 ec 1c             	sub    $0x1c,%esp
  8006ed:	89 c7                	mov    %eax,%edi
  8006ef:	89 d6                	mov    %edx,%esi
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800708:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070b:	39 d3                	cmp    %edx,%ebx
  80070d:	72 05                	jb     800714 <printnum+0x30>
  80070f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800712:	77 45                	ja     800759 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	ff 75 18             	pushl  0x18(%ebp)
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800720:	53                   	push   %ebx
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072a:	ff 75 e0             	pushl  -0x20(%ebp)
  80072d:	ff 75 dc             	pushl  -0x24(%ebp)
  800730:	ff 75 d8             	pushl  -0x28(%ebp)
  800733:	e8 18 1e 00 00       	call   802550 <__udivdi3>
  800738:	83 c4 18             	add    $0x18,%esp
  80073b:	52                   	push   %edx
  80073c:	50                   	push   %eax
  80073d:	89 f2                	mov    %esi,%edx
  80073f:	89 f8                	mov    %edi,%eax
  800741:	e8 9e ff ff ff       	call   8006e4 <printnum>
  800746:	83 c4 20             	add    $0x20,%esp
  800749:	eb 18                	jmp    800763 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	56                   	push   %esi
  80074f:	ff 75 18             	pushl  0x18(%ebp)
  800752:	ff d7                	call   *%edi
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 03                	jmp    80075c <printnum+0x78>
  800759:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	85 db                	test   %ebx,%ebx
  800761:	7f e8                	jg     80074b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	ff 75 dc             	pushl  -0x24(%ebp)
  800773:	ff 75 d8             	pushl  -0x28(%ebp)
  800776:	e8 05 1f 00 00       	call   802680 <__umoddi3>
  80077b:	83 c4 14             	add    $0x14,%esp
  80077e:	0f be 80 23 29 80 00 	movsbl 0x802923(%eax),%eax
  800785:	50                   	push   %eax
  800786:	ff d7                	call   *%edi
}
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800796:	83 fa 01             	cmp    $0x1,%edx
  800799:	7e 0e                	jle    8007a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007a0:	89 08                	mov    %ecx,(%eax)
  8007a2:	8b 02                	mov    (%edx),%eax
  8007a4:	8b 52 04             	mov    0x4(%edx),%edx
  8007a7:	eb 22                	jmp    8007cb <getuint+0x38>
	else if (lflag)
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	74 10                	je     8007bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007ad:	8b 10                	mov    (%eax),%edx
  8007af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b2:	89 08                	mov    %ecx,(%eax)
  8007b4:	8b 02                	mov    (%edx),%eax
  8007b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bb:	eb 0e                	jmp    8007cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007bd:	8b 10                	mov    (%eax),%edx
  8007bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c2:	89 08                	mov    %ecx,(%eax)
  8007c4:	8b 02                	mov    (%edx),%eax
  8007c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8007dc:	73 0a                	jae    8007e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007e1:	89 08                	mov    %ecx,(%eax)
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	88 02                	mov    %al,(%edx)
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007f3:	50                   	push   %eax
  8007f4:	ff 75 10             	pushl  0x10(%ebp)
  8007f7:	ff 75 0c             	pushl  0xc(%ebp)
  8007fa:	ff 75 08             	pushl  0x8(%ebp)
  8007fd:	e8 05 00 00 00       	call   800807 <vprintfmt>
	va_end(ap);
}
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	57                   	push   %edi
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	83 ec 2c             	sub    $0x2c,%esp
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800816:	8b 7d 10             	mov    0x10(%ebp),%edi
  800819:	eb 12                	jmp    80082d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80081b:	85 c0                	test   %eax,%eax
  80081d:	0f 84 89 03 00 00    	je     800bac <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	ff d6                	call   *%esi
  80082a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082d:	83 c7 01             	add    $0x1,%edi
  800830:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800834:	83 f8 25             	cmp    $0x25,%eax
  800837:	75 e2                	jne    80081b <vprintfmt+0x14>
  800839:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80083d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800844:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80084b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800852:	ba 00 00 00 00       	mov    $0x0,%edx
  800857:	eb 07                	jmp    800860 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800859:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80085c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	8d 47 01             	lea    0x1(%edi),%eax
  800863:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800866:	0f b6 07             	movzbl (%edi),%eax
  800869:	0f b6 c8             	movzbl %al,%ecx
  80086c:	83 e8 23             	sub    $0x23,%eax
  80086f:	3c 55                	cmp    $0x55,%al
  800871:	0f 87 1a 03 00 00    	ja     800b91 <vprintfmt+0x38a>
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	ff 24 85 60 2a 80 00 	jmp    *0x802a60(,%eax,4)
  800881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800884:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800888:	eb d6                	jmp    800860 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800895:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800898:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80089c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80089f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8008a2:	83 fa 09             	cmp    $0x9,%edx
  8008a5:	77 39                	ja     8008e0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008aa:	eb e9                	jmp    800895 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8d 48 04             	lea    0x4(%eax),%ecx
  8008b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b5:	8b 00                	mov    (%eax),%eax
  8008b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008bd:	eb 27                	jmp    8008e6 <vprintfmt+0xdf>
  8008bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c9:	0f 49 c8             	cmovns %eax,%ecx
  8008cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d2:	eb 8c                	jmp    800860 <vprintfmt+0x59>
  8008d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008de:	eb 80                	jmp    800860 <vprintfmt+0x59>
  8008e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008e3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008ea:	0f 89 70 ff ff ff    	jns    800860 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008fd:	e9 5e ff ff ff       	jmp    800860 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800902:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800905:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800908:	e9 53 ff ff ff       	jmp    800860 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8d 50 04             	lea    0x4(%eax),%edx
  800913:	89 55 14             	mov    %edx,0x14(%ebp)
  800916:	83 ec 08             	sub    $0x8,%esp
  800919:	53                   	push   %ebx
  80091a:	ff 30                	pushl  (%eax)
  80091c:	ff d6                	call   *%esi
			break;
  80091e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800921:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800924:	e9 04 ff ff ff       	jmp    80082d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	8d 50 04             	lea    0x4(%eax),%edx
  80092f:	89 55 14             	mov    %edx,0x14(%ebp)
  800932:	8b 00                	mov    (%eax),%eax
  800934:	99                   	cltd   
  800935:	31 d0                	xor    %edx,%eax
  800937:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800939:	83 f8 0f             	cmp    $0xf,%eax
  80093c:	7f 0b                	jg     800949 <vprintfmt+0x142>
  80093e:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  800945:	85 d2                	test   %edx,%edx
  800947:	75 18                	jne    800961 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800949:	50                   	push   %eax
  80094a:	68 3b 29 80 00       	push   $0x80293b
  80094f:	53                   	push   %ebx
  800950:	56                   	push   %esi
  800951:	e8 94 fe ff ff       	call   8007ea <printfmt>
  800956:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800959:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80095c:	e9 cc fe ff ff       	jmp    80082d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800961:	52                   	push   %edx
  800962:	68 f9 2c 80 00       	push   $0x802cf9
  800967:	53                   	push   %ebx
  800968:	56                   	push   %esi
  800969:	e8 7c fe ff ff       	call   8007ea <printfmt>
  80096e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800971:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800974:	e9 b4 fe ff ff       	jmp    80082d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800979:	8b 45 14             	mov    0x14(%ebp),%eax
  80097c:	8d 50 04             	lea    0x4(%eax),%edx
  80097f:	89 55 14             	mov    %edx,0x14(%ebp)
  800982:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800984:	85 ff                	test   %edi,%edi
  800986:	b8 34 29 80 00       	mov    $0x802934,%eax
  80098b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80098e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800992:	0f 8e 94 00 00 00    	jle    800a2c <vprintfmt+0x225>
  800998:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80099c:	0f 84 98 00 00 00    	je     800a3a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a8:	57                   	push   %edi
  8009a9:	e8 86 02 00 00       	call   800c34 <strnlen>
  8009ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009b1:	29 c1                	sub    %eax,%ecx
  8009b3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009b6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009c3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c5:	eb 0f                	jmp    8009d6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009c7:	83 ec 08             	sub    $0x8,%esp
  8009ca:	53                   	push   %ebx
  8009cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ce:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d0:	83 ef 01             	sub    $0x1,%edi
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	85 ff                	test   %edi,%edi
  8009d8:	7f ed                	jg     8009c7 <vprintfmt+0x1c0>
  8009da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009e0:	85 c9                	test   %ecx,%ecx
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e7:	0f 49 c1             	cmovns %ecx,%eax
  8009ea:	29 c1                	sub    %eax,%ecx
  8009ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8009ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f5:	89 cb                	mov    %ecx,%ebx
  8009f7:	eb 4d                	jmp    800a46 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009fd:	74 1b                	je     800a1a <vprintfmt+0x213>
  8009ff:	0f be c0             	movsbl %al,%eax
  800a02:	83 e8 20             	sub    $0x20,%eax
  800a05:	83 f8 5e             	cmp    $0x5e,%eax
  800a08:	76 10                	jbe    800a1a <vprintfmt+0x213>
					putch('?', putdat);
  800a0a:	83 ec 08             	sub    $0x8,%esp
  800a0d:	ff 75 0c             	pushl  0xc(%ebp)
  800a10:	6a 3f                	push   $0x3f
  800a12:	ff 55 08             	call   *0x8(%ebp)
  800a15:	83 c4 10             	add    $0x10,%esp
  800a18:	eb 0d                	jmp    800a27 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a1a:	83 ec 08             	sub    $0x8,%esp
  800a1d:	ff 75 0c             	pushl  0xc(%ebp)
  800a20:	52                   	push   %edx
  800a21:	ff 55 08             	call   *0x8(%ebp)
  800a24:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a27:	83 eb 01             	sub    $0x1,%ebx
  800a2a:	eb 1a                	jmp    800a46 <vprintfmt+0x23f>
  800a2c:	89 75 08             	mov    %esi,0x8(%ebp)
  800a2f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a32:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a35:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a38:	eb 0c                	jmp    800a46 <vprintfmt+0x23f>
  800a3a:	89 75 08             	mov    %esi,0x8(%ebp)
  800a3d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a40:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a43:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a46:	83 c7 01             	add    $0x1,%edi
  800a49:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a4d:	0f be d0             	movsbl %al,%edx
  800a50:	85 d2                	test   %edx,%edx
  800a52:	74 23                	je     800a77 <vprintfmt+0x270>
  800a54:	85 f6                	test   %esi,%esi
  800a56:	78 a1                	js     8009f9 <vprintfmt+0x1f2>
  800a58:	83 ee 01             	sub    $0x1,%esi
  800a5b:	79 9c                	jns    8009f9 <vprintfmt+0x1f2>
  800a5d:	89 df                	mov    %ebx,%edi
  800a5f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a65:	eb 18                	jmp    800a7f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a67:	83 ec 08             	sub    $0x8,%esp
  800a6a:	53                   	push   %ebx
  800a6b:	6a 20                	push   $0x20
  800a6d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	83 c4 10             	add    $0x10,%esp
  800a75:	eb 08                	jmp    800a7f <vprintfmt+0x278>
  800a77:	89 df                	mov    %ebx,%edi
  800a79:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7f:	85 ff                	test   %edi,%edi
  800a81:	7f e4                	jg     800a67 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a86:	e9 a2 fd ff ff       	jmp    80082d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8b:	83 fa 01             	cmp    $0x1,%edx
  800a8e:	7e 16                	jle    800aa6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a90:	8b 45 14             	mov    0x14(%ebp),%eax
  800a93:	8d 50 08             	lea    0x8(%eax),%edx
  800a96:	89 55 14             	mov    %edx,0x14(%ebp)
  800a99:	8b 50 04             	mov    0x4(%eax),%edx
  800a9c:	8b 00                	mov    (%eax),%eax
  800a9e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa4:	eb 32                	jmp    800ad8 <vprintfmt+0x2d1>
	else if (lflag)
  800aa6:	85 d2                	test   %edx,%edx
  800aa8:	74 18                	je     800ac2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aaa:	8b 45 14             	mov    0x14(%ebp),%eax
  800aad:	8d 50 04             	lea    0x4(%eax),%edx
  800ab0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab3:	8b 00                	mov    (%eax),%eax
  800ab5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab8:	89 c1                	mov    %eax,%ecx
  800aba:	c1 f9 1f             	sar    $0x1f,%ecx
  800abd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ac0:	eb 16                	jmp    800ad8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ac2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac5:	8d 50 04             	lea    0x4(%eax),%edx
  800ac8:	89 55 14             	mov    %edx,0x14(%ebp)
  800acb:	8b 00                	mov    (%eax),%eax
  800acd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ad0:	89 c1                	mov    %eax,%ecx
  800ad2:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800adb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ade:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ae7:	79 74                	jns    800b5d <vprintfmt+0x356>
				putch('-', putdat);
  800ae9:	83 ec 08             	sub    $0x8,%esp
  800aec:	53                   	push   %ebx
  800aed:	6a 2d                	push   $0x2d
  800aef:	ff d6                	call   *%esi
				num = -(long long) num;
  800af1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800af4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800af7:	f7 d8                	neg    %eax
  800af9:	83 d2 00             	adc    $0x0,%edx
  800afc:	f7 da                	neg    %edx
  800afe:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b01:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b06:	eb 55                	jmp    800b5d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b08:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0b:	e8 83 fc ff ff       	call   800793 <getuint>
			base = 10;
  800b10:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b15:	eb 46                	jmp    800b5d <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800b17:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1a:	e8 74 fc ff ff       	call   800793 <getuint>
			base = 8;
  800b1f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b24:	eb 37                	jmp    800b5d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b26:	83 ec 08             	sub    $0x8,%esp
  800b29:	53                   	push   %ebx
  800b2a:	6a 30                	push   $0x30
  800b2c:	ff d6                	call   *%esi
			putch('x', putdat);
  800b2e:	83 c4 08             	add    $0x8,%esp
  800b31:	53                   	push   %ebx
  800b32:	6a 78                	push   $0x78
  800b34:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b36:	8b 45 14             	mov    0x14(%ebp),%eax
  800b39:	8d 50 04             	lea    0x4(%eax),%edx
  800b3c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b3f:	8b 00                	mov    (%eax),%eax
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b46:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b49:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b4e:	eb 0d                	jmp    800b5d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b50:	8d 45 14             	lea    0x14(%ebp),%eax
  800b53:	e8 3b fc ff ff       	call   800793 <getuint>
			base = 16;
  800b58:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b64:	57                   	push   %edi
  800b65:	ff 75 e0             	pushl  -0x20(%ebp)
  800b68:	51                   	push   %ecx
  800b69:	52                   	push   %edx
  800b6a:	50                   	push   %eax
  800b6b:	89 da                	mov    %ebx,%edx
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	e8 70 fb ff ff       	call   8006e4 <printnum>
			break;
  800b74:	83 c4 20             	add    $0x20,%esp
  800b77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b7a:	e9 ae fc ff ff       	jmp    80082d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b7f:	83 ec 08             	sub    $0x8,%esp
  800b82:	53                   	push   %ebx
  800b83:	51                   	push   %ecx
  800b84:	ff d6                	call   *%esi
			break;
  800b86:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b89:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b8c:	e9 9c fc ff ff       	jmp    80082d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b91:	83 ec 08             	sub    $0x8,%esp
  800b94:	53                   	push   %ebx
  800b95:	6a 25                	push   $0x25
  800b97:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b99:	83 c4 10             	add    $0x10,%esp
  800b9c:	eb 03                	jmp    800ba1 <vprintfmt+0x39a>
  800b9e:	83 ef 01             	sub    $0x1,%edi
  800ba1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ba5:	75 f7                	jne    800b9e <vprintfmt+0x397>
  800ba7:	e9 81 fc ff ff       	jmp    80082d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	83 ec 18             	sub    $0x18,%esp
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bc3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	74 26                	je     800bfb <vsnprintf+0x47>
  800bd5:	85 d2                	test   %edx,%edx
  800bd7:	7e 22                	jle    800bfb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd9:	ff 75 14             	pushl  0x14(%ebp)
  800bdc:	ff 75 10             	pushl  0x10(%ebp)
  800bdf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be2:	50                   	push   %eax
  800be3:	68 cd 07 80 00       	push   $0x8007cd
  800be8:	e8 1a fc ff ff       	call   800807 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	eb 05                	jmp    800c00 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bfb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c08:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c0b:	50                   	push   %eax
  800c0c:	ff 75 10             	pushl  0x10(%ebp)
  800c0f:	ff 75 0c             	pushl  0xc(%ebp)
  800c12:	ff 75 08             	pushl  0x8(%ebp)
  800c15:	e8 9a ff ff ff       	call   800bb4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    

00800c1c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
  800c27:	eb 03                	jmp    800c2c <strlen+0x10>
		n++;
  800c29:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c2c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c30:	75 f7                	jne    800c29 <strlen+0xd>
		n++;
	return n;
}
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	eb 03                	jmp    800c47 <strnlen+0x13>
		n++;
  800c44:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c47:	39 c2                	cmp    %eax,%edx
  800c49:	74 08                	je     800c53 <strnlen+0x1f>
  800c4b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c4f:	75 f3                	jne    800c44 <strnlen+0x10>
  800c51:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	53                   	push   %ebx
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c5f:	89 c2                	mov    %eax,%edx
  800c61:	83 c2 01             	add    $0x1,%edx
  800c64:	83 c1 01             	add    $0x1,%ecx
  800c67:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c6b:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c6e:	84 db                	test   %bl,%bl
  800c70:	75 ef                	jne    800c61 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c72:	5b                   	pop    %ebx
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	53                   	push   %ebx
  800c79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c7c:	53                   	push   %ebx
  800c7d:	e8 9a ff ff ff       	call   800c1c <strlen>
  800c82:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c85:	ff 75 0c             	pushl  0xc(%ebp)
  800c88:	01 d8                	add    %ebx,%eax
  800c8a:	50                   	push   %eax
  800c8b:	e8 c5 ff ff ff       	call   800c55 <strcpy>
	return dst;
}
  800c90:	89 d8                	mov    %ebx,%eax
  800c92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	8b 75 08             	mov    0x8(%ebp),%esi
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	89 f3                	mov    %esi,%ebx
  800ca4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca7:	89 f2                	mov    %esi,%edx
  800ca9:	eb 0f                	jmp    800cba <strncpy+0x23>
		*dst++ = *src;
  800cab:	83 c2 01             	add    $0x1,%edx
  800cae:	0f b6 01             	movzbl (%ecx),%eax
  800cb1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cb4:	80 39 01             	cmpb   $0x1,(%ecx)
  800cb7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cba:	39 da                	cmp    %ebx,%edx
  800cbc:	75 ed                	jne    800cab <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cbe:	89 f0                	mov    %esi,%eax
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 10             	mov    0x10(%ebp),%edx
  800cd2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cd4:	85 d2                	test   %edx,%edx
  800cd6:	74 21                	je     800cf9 <strlcpy+0x35>
  800cd8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cdc:	89 f2                	mov    %esi,%edx
  800cde:	eb 09                	jmp    800ce9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ce0:	83 c2 01             	add    $0x1,%edx
  800ce3:	83 c1 01             	add    $0x1,%ecx
  800ce6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ce9:	39 c2                	cmp    %eax,%edx
  800ceb:	74 09                	je     800cf6 <strlcpy+0x32>
  800ced:	0f b6 19             	movzbl (%ecx),%ebx
  800cf0:	84 db                	test   %bl,%bl
  800cf2:	75 ec                	jne    800ce0 <strlcpy+0x1c>
  800cf4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cf6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf9:	29 f0                	sub    %esi,%eax
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d05:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d08:	eb 06                	jmp    800d10 <strcmp+0x11>
		p++, q++;
  800d0a:	83 c1 01             	add    $0x1,%ecx
  800d0d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d10:	0f b6 01             	movzbl (%ecx),%eax
  800d13:	84 c0                	test   %al,%al
  800d15:	74 04                	je     800d1b <strcmp+0x1c>
  800d17:	3a 02                	cmp    (%edx),%al
  800d19:	74 ef                	je     800d0a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d1b:	0f b6 c0             	movzbl %al,%eax
  800d1e:	0f b6 12             	movzbl (%edx),%edx
  800d21:	29 d0                	sub    %edx,%eax
}
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	53                   	push   %ebx
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d2f:	89 c3                	mov    %eax,%ebx
  800d31:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d34:	eb 06                	jmp    800d3c <strncmp+0x17>
		n--, p++, q++;
  800d36:	83 c0 01             	add    $0x1,%eax
  800d39:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d3c:	39 d8                	cmp    %ebx,%eax
  800d3e:	74 15                	je     800d55 <strncmp+0x30>
  800d40:	0f b6 08             	movzbl (%eax),%ecx
  800d43:	84 c9                	test   %cl,%cl
  800d45:	74 04                	je     800d4b <strncmp+0x26>
  800d47:	3a 0a                	cmp    (%edx),%cl
  800d49:	74 eb                	je     800d36 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d4b:	0f b6 00             	movzbl (%eax),%eax
  800d4e:	0f b6 12             	movzbl (%edx),%edx
  800d51:	29 d0                	sub    %edx,%eax
  800d53:	eb 05                	jmp    800d5a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d55:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d67:	eb 07                	jmp    800d70 <strchr+0x13>
		if (*s == c)
  800d69:	38 ca                	cmp    %cl,%dl
  800d6b:	74 0f                	je     800d7c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d6d:	83 c0 01             	add    $0x1,%eax
  800d70:	0f b6 10             	movzbl (%eax),%edx
  800d73:	84 d2                	test   %dl,%dl
  800d75:	75 f2                	jne    800d69 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d88:	eb 03                	jmp    800d8d <strfind+0xf>
  800d8a:	83 c0 01             	add    $0x1,%eax
  800d8d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d90:	38 ca                	cmp    %cl,%dl
  800d92:	74 04                	je     800d98 <strfind+0x1a>
  800d94:	84 d2                	test   %dl,%dl
  800d96:	75 f2                	jne    800d8a <strfind+0xc>
			break;
	return (char *) s;
}
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800da3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da6:	85 c9                	test   %ecx,%ecx
  800da8:	74 36                	je     800de0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800daa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800db0:	75 28                	jne    800dda <memset+0x40>
  800db2:	f6 c1 03             	test   $0x3,%cl
  800db5:	75 23                	jne    800dda <memset+0x40>
		c &= 0xFF;
  800db7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dbb:	89 d3                	mov    %edx,%ebx
  800dbd:	c1 e3 08             	shl    $0x8,%ebx
  800dc0:	89 d6                	mov    %edx,%esi
  800dc2:	c1 e6 18             	shl    $0x18,%esi
  800dc5:	89 d0                	mov    %edx,%eax
  800dc7:	c1 e0 10             	shl    $0x10,%eax
  800dca:	09 f0                	or     %esi,%eax
  800dcc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800dce:	89 d8                	mov    %ebx,%eax
  800dd0:	09 d0                	or     %edx,%eax
  800dd2:	c1 e9 02             	shr    $0x2,%ecx
  800dd5:	fc                   	cld    
  800dd6:	f3 ab                	rep stos %eax,%es:(%edi)
  800dd8:	eb 06                	jmp    800de0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddd:	fc                   	cld    
  800dde:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800de0:	89 f8                	mov    %edi,%eax
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800df5:	39 c6                	cmp    %eax,%esi
  800df7:	73 35                	jae    800e2e <memmove+0x47>
  800df9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dfc:	39 d0                	cmp    %edx,%eax
  800dfe:	73 2e                	jae    800e2e <memmove+0x47>
		s += n;
		d += n;
  800e00:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e03:	89 d6                	mov    %edx,%esi
  800e05:	09 fe                	or     %edi,%esi
  800e07:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e0d:	75 13                	jne    800e22 <memmove+0x3b>
  800e0f:	f6 c1 03             	test   $0x3,%cl
  800e12:	75 0e                	jne    800e22 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e14:	83 ef 04             	sub    $0x4,%edi
  800e17:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e1a:	c1 e9 02             	shr    $0x2,%ecx
  800e1d:	fd                   	std    
  800e1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e20:	eb 09                	jmp    800e2b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e22:	83 ef 01             	sub    $0x1,%edi
  800e25:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e28:	fd                   	std    
  800e29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e2b:	fc                   	cld    
  800e2c:	eb 1d                	jmp    800e4b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e2e:	89 f2                	mov    %esi,%edx
  800e30:	09 c2                	or     %eax,%edx
  800e32:	f6 c2 03             	test   $0x3,%dl
  800e35:	75 0f                	jne    800e46 <memmove+0x5f>
  800e37:	f6 c1 03             	test   $0x3,%cl
  800e3a:	75 0a                	jne    800e46 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e3c:	c1 e9 02             	shr    $0x2,%ecx
  800e3f:	89 c7                	mov    %eax,%edi
  800e41:	fc                   	cld    
  800e42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e44:	eb 05                	jmp    800e4b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e46:	89 c7                	mov    %eax,%edi
  800e48:	fc                   	cld    
  800e49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e52:	ff 75 10             	pushl  0x10(%ebp)
  800e55:	ff 75 0c             	pushl  0xc(%ebp)
  800e58:	ff 75 08             	pushl  0x8(%ebp)
  800e5b:	e8 87 ff ff ff       	call   800de7 <memmove>
}
  800e60:	c9                   	leave  
  800e61:	c3                   	ret    

00800e62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6d:	89 c6                	mov    %eax,%esi
  800e6f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e72:	eb 1a                	jmp    800e8e <memcmp+0x2c>
		if (*s1 != *s2)
  800e74:	0f b6 08             	movzbl (%eax),%ecx
  800e77:	0f b6 1a             	movzbl (%edx),%ebx
  800e7a:	38 d9                	cmp    %bl,%cl
  800e7c:	74 0a                	je     800e88 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e7e:	0f b6 c1             	movzbl %cl,%eax
  800e81:	0f b6 db             	movzbl %bl,%ebx
  800e84:	29 d8                	sub    %ebx,%eax
  800e86:	eb 0f                	jmp    800e97 <memcmp+0x35>
		s1++, s2++;
  800e88:	83 c0 01             	add    $0x1,%eax
  800e8b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8e:	39 f0                	cmp    %esi,%eax
  800e90:	75 e2                	jne    800e74 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	53                   	push   %ebx
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ea2:	89 c1                	mov    %eax,%ecx
  800ea4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eab:	eb 0a                	jmp    800eb7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ead:	0f b6 10             	movzbl (%eax),%edx
  800eb0:	39 da                	cmp    %ebx,%edx
  800eb2:	74 07                	je     800ebb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb4:	83 c0 01             	add    $0x1,%eax
  800eb7:	39 c8                	cmp    %ecx,%eax
  800eb9:	72 f2                	jb     800ead <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ebb:	5b                   	pop    %ebx
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eca:	eb 03                	jmp    800ecf <strtol+0x11>
		s++;
  800ecc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ecf:	0f b6 01             	movzbl (%ecx),%eax
  800ed2:	3c 20                	cmp    $0x20,%al
  800ed4:	74 f6                	je     800ecc <strtol+0xe>
  800ed6:	3c 09                	cmp    $0x9,%al
  800ed8:	74 f2                	je     800ecc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eda:	3c 2b                	cmp    $0x2b,%al
  800edc:	75 0a                	jne    800ee8 <strtol+0x2a>
		s++;
  800ede:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ee1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee6:	eb 11                	jmp    800ef9 <strtol+0x3b>
  800ee8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800eed:	3c 2d                	cmp    $0x2d,%al
  800eef:	75 08                	jne    800ef9 <strtol+0x3b>
		s++, neg = 1;
  800ef1:	83 c1 01             	add    $0x1,%ecx
  800ef4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800eff:	75 15                	jne    800f16 <strtol+0x58>
  800f01:	80 39 30             	cmpb   $0x30,(%ecx)
  800f04:	75 10                	jne    800f16 <strtol+0x58>
  800f06:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f0a:	75 7c                	jne    800f88 <strtol+0xca>
		s += 2, base = 16;
  800f0c:	83 c1 02             	add    $0x2,%ecx
  800f0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f14:	eb 16                	jmp    800f2c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f16:	85 db                	test   %ebx,%ebx
  800f18:	75 12                	jne    800f2c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f1a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800f22:	75 08                	jne    800f2c <strtol+0x6e>
		s++, base = 8;
  800f24:	83 c1 01             	add    $0x1,%ecx
  800f27:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f31:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f34:	0f b6 11             	movzbl (%ecx),%edx
  800f37:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f3a:	89 f3                	mov    %esi,%ebx
  800f3c:	80 fb 09             	cmp    $0x9,%bl
  800f3f:	77 08                	ja     800f49 <strtol+0x8b>
			dig = *s - '0';
  800f41:	0f be d2             	movsbl %dl,%edx
  800f44:	83 ea 30             	sub    $0x30,%edx
  800f47:	eb 22                	jmp    800f6b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f49:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f4c:	89 f3                	mov    %esi,%ebx
  800f4e:	80 fb 19             	cmp    $0x19,%bl
  800f51:	77 08                	ja     800f5b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f53:	0f be d2             	movsbl %dl,%edx
  800f56:	83 ea 57             	sub    $0x57,%edx
  800f59:	eb 10                	jmp    800f6b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f5b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f5e:	89 f3                	mov    %esi,%ebx
  800f60:	80 fb 19             	cmp    $0x19,%bl
  800f63:	77 16                	ja     800f7b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f65:	0f be d2             	movsbl %dl,%edx
  800f68:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f6b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f6e:	7d 0b                	jge    800f7b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f70:	83 c1 01             	add    $0x1,%ecx
  800f73:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f77:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f79:	eb b9                	jmp    800f34 <strtol+0x76>

	if (endptr)
  800f7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f7f:	74 0d                	je     800f8e <strtol+0xd0>
		*endptr = (char *) s;
  800f81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f84:	89 0e                	mov    %ecx,(%esi)
  800f86:	eb 06                	jmp    800f8e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f88:	85 db                	test   %ebx,%ebx
  800f8a:	74 98                	je     800f24 <strtol+0x66>
  800f8c:	eb 9e                	jmp    800f2c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f8e:	89 c2                	mov    %eax,%edx
  800f90:	f7 da                	neg    %edx
  800f92:	85 ff                	test   %edi,%edi
  800f94:	0f 45 c2             	cmovne %edx,%eax
}
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	57                   	push   %edi
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800faa:	8b 55 08             	mov    0x8(%ebp),%edx
  800fad:	89 c3                	mov    %eax,%ebx
  800faf:	89 c7                	mov    %eax,%edi
  800fb1:	89 c6                	mov    %eax,%esi
  800fb3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <sys_cgetc>:

int
sys_cgetc(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800fca:	89 d1                	mov    %edx,%ecx
  800fcc:	89 d3                	mov    %edx,%ebx
  800fce:	89 d7                	mov    %edx,%edi
  800fd0:	89 d6                	mov    %edx,%esi
  800fd2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	b8 03 00 00 00       	mov    $0x3,%eax
  800fec:	8b 55 08             	mov    0x8(%ebp),%edx
  800fef:	89 cb                	mov    %ecx,%ebx
  800ff1:	89 cf                	mov    %ecx,%edi
  800ff3:	89 ce                	mov    %ecx,%esi
  800ff5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	7e 17                	jle    801012 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	50                   	push   %eax
  800fff:	6a 03                	push   $0x3
  801001:	68 1f 2c 80 00       	push   $0x802c1f
  801006:	6a 23                	push   $0x23
  801008:	68 3c 2c 80 00       	push   $0x802c3c
  80100d:	e8 e5 f5 ff ff       	call   8005f7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801020:	ba 00 00 00 00       	mov    $0x0,%edx
  801025:	b8 02 00 00 00       	mov    $0x2,%eax
  80102a:	89 d1                	mov    %edx,%ecx
  80102c:	89 d3                	mov    %edx,%ebx
  80102e:	89 d7                	mov    %edx,%edi
  801030:	89 d6                	mov    %edx,%esi
  801032:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_yield>:

void
sys_yield(void)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103f:	ba 00 00 00 00       	mov    $0x0,%edx
  801044:	b8 0b 00 00 00       	mov    $0xb,%eax
  801049:	89 d1                	mov    %edx,%ecx
  80104b:	89 d3                	mov    %edx,%ebx
  80104d:	89 d7                	mov    %edx,%edi
  80104f:	89 d6                	mov    %edx,%esi
  801051:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	be 00 00 00 00       	mov    $0x0,%esi
  801066:	b8 04 00 00 00       	mov    $0x4,%eax
  80106b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801074:	89 f7                	mov    %esi,%edi
  801076:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801078:	85 c0                	test   %eax,%eax
  80107a:	7e 17                	jle    801093 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	50                   	push   %eax
  801080:	6a 04                	push   $0x4
  801082:	68 1f 2c 80 00       	push   $0x802c1f
  801087:	6a 23                	push   $0x23
  801089:	68 3c 2c 80 00       	push   $0x802c3c
  80108e:	e8 64 f5 ff ff       	call   8005f7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801096:	5b                   	pop    %ebx
  801097:	5e                   	pop    %esi
  801098:	5f                   	pop    %edi
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8010a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8010af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b5:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	7e 17                	jle    8010d5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	50                   	push   %eax
  8010c2:	6a 05                	push   $0x5
  8010c4:	68 1f 2c 80 00       	push   $0x802c1f
  8010c9:	6a 23                	push   $0x23
  8010cb:	68 3c 2c 80 00       	push   $0x802c3c
  8010d0:	e8 22 f5 ff ff       	call   8005f7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	57                   	push   %edi
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f6:	89 df                	mov    %ebx,%edi
  8010f8:	89 de                	mov    %ebx,%esi
  8010fa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	7e 17                	jle    801117 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	50                   	push   %eax
  801104:	6a 06                	push   $0x6
  801106:	68 1f 2c 80 00       	push   $0x802c1f
  80110b:	6a 23                	push   $0x23
  80110d:	68 3c 2c 80 00       	push   $0x802c3c
  801112:	e8 e0 f4 ff ff       	call   8005f7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801117:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111a:	5b                   	pop    %ebx
  80111b:	5e                   	pop    %esi
  80111c:	5f                   	pop    %edi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	57                   	push   %edi
  801123:	56                   	push   %esi
  801124:	53                   	push   %ebx
  801125:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801128:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112d:	b8 08 00 00 00       	mov    $0x8,%eax
  801132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801135:	8b 55 08             	mov    0x8(%ebp),%edx
  801138:	89 df                	mov    %ebx,%edi
  80113a:	89 de                	mov    %ebx,%esi
  80113c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80113e:	85 c0                	test   %eax,%eax
  801140:	7e 17                	jle    801159 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	50                   	push   %eax
  801146:	6a 08                	push   $0x8
  801148:	68 1f 2c 80 00       	push   $0x802c1f
  80114d:	6a 23                	push   $0x23
  80114f:	68 3c 2c 80 00       	push   $0x802c3c
  801154:	e8 9e f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801159:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	57                   	push   %edi
  801165:	56                   	push   %esi
  801166:	53                   	push   %ebx
  801167:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116f:	b8 09 00 00 00       	mov    $0x9,%eax
  801174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801177:	8b 55 08             	mov    0x8(%ebp),%edx
  80117a:	89 df                	mov    %ebx,%edi
  80117c:	89 de                	mov    %ebx,%esi
  80117e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801180:	85 c0                	test   %eax,%eax
  801182:	7e 17                	jle    80119b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	50                   	push   %eax
  801188:	6a 09                	push   $0x9
  80118a:	68 1f 2c 80 00       	push   $0x802c1f
  80118f:	6a 23                	push   $0x23
  801191:	68 3c 2c 80 00       	push   $0x802c3c
  801196:	e8 5c f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80119b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	57                   	push   %edi
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bc:	89 df                	mov    %ebx,%edi
  8011be:	89 de                	mov    %ebx,%esi
  8011c0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	7e 17                	jle    8011dd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	50                   	push   %eax
  8011ca:	6a 0a                	push   $0xa
  8011cc:	68 1f 2c 80 00       	push   $0x802c1f
  8011d1:	6a 23                	push   $0x23
  8011d3:	68 3c 2c 80 00       	push   $0x802c3c
  8011d8:	e8 1a f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011eb:	be 00 00 00 00       	mov    $0x0,%esi
  8011f0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  801201:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801211:	b9 00 00 00 00       	mov    $0x0,%ecx
  801216:	b8 0d 00 00 00       	mov    $0xd,%eax
  80121b:	8b 55 08             	mov    0x8(%ebp),%edx
  80121e:	89 cb                	mov    %ecx,%ebx
  801220:	89 cf                	mov    %ecx,%edi
  801222:	89 ce                	mov    %ecx,%esi
  801224:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801226:	85 c0                	test   %eax,%eax
  801228:	7e 17                	jle    801241 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122a:	83 ec 0c             	sub    $0xc,%esp
  80122d:	50                   	push   %eax
  80122e:	6a 0d                	push   $0xd
  801230:	68 1f 2c 80 00       	push   $0x802c1f
  801235:	6a 23                	push   $0x23
  801237:	68 3c 2c 80 00       	push   $0x802c3c
  80123c:	e8 b6 f3 ff ff       	call   8005f7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	57                   	push   %edi
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124f:	ba 00 00 00 00       	mov    $0x0,%edx
  801254:	b8 0e 00 00 00       	mov    $0xe,%eax
  801259:	89 d1                	mov    %edx,%ecx
  80125b:	89 d3                	mov    %edx,%ebx
  80125d:	89 d7                	mov    %edx,%edi
  80125f:	89 d6                	mov    %edx,%esi
  801261:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80126e:	83 3d b8 40 80 00 00 	cmpl   $0x0,0x8040b8
  801275:	75 2e                	jne    8012a5 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801277:	e8 9e fd ff ff       	call   80101a <sys_getenvid>
  80127c:	83 ec 04             	sub    $0x4,%esp
  80127f:	68 07 0e 00 00       	push   $0xe07
  801284:	68 00 f0 bf ee       	push   $0xeebff000
  801289:	50                   	push   %eax
  80128a:	e8 c9 fd ff ff       	call   801058 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80128f:	e8 86 fd ff ff       	call   80101a <sys_getenvid>
  801294:	83 c4 08             	add    $0x8,%esp
  801297:	68 af 12 80 00       	push   $0x8012af
  80129c:	50                   	push   %eax
  80129d:	e8 01 ff ff ff       	call   8011a3 <sys_env_set_pgfault_upcall>
  8012a2:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a8:	a3 b8 40 80 00       	mov    %eax,0x8040b8
}
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012af:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012b0:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	call *%eax
  8012b5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012b7:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8012ba:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8012be:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8012c2:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8012c5:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8012c8:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8012c9:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8012cc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8012cd:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8012ce:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8012d2:	c3                   	ret    

008012d3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8012de:	c1 e8 0c             	shr    $0xc,%eax
}
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e9:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012f3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801300:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801305:	89 c2                	mov    %eax,%edx
  801307:	c1 ea 16             	shr    $0x16,%edx
  80130a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801311:	f6 c2 01             	test   $0x1,%dl
  801314:	74 11                	je     801327 <fd_alloc+0x2d>
  801316:	89 c2                	mov    %eax,%edx
  801318:	c1 ea 0c             	shr    $0xc,%edx
  80131b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801322:	f6 c2 01             	test   $0x1,%dl
  801325:	75 09                	jne    801330 <fd_alloc+0x36>
			*fd_store = fd;
  801327:	89 01                	mov    %eax,(%ecx)
			return 0;
  801329:	b8 00 00 00 00       	mov    $0x0,%eax
  80132e:	eb 17                	jmp    801347 <fd_alloc+0x4d>
  801330:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801335:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80133a:	75 c9                	jne    801305 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80133c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801342:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80134f:	83 f8 1f             	cmp    $0x1f,%eax
  801352:	77 36                	ja     80138a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801354:	c1 e0 0c             	shl    $0xc,%eax
  801357:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80135c:	89 c2                	mov    %eax,%edx
  80135e:	c1 ea 16             	shr    $0x16,%edx
  801361:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801368:	f6 c2 01             	test   $0x1,%dl
  80136b:	74 24                	je     801391 <fd_lookup+0x48>
  80136d:	89 c2                	mov    %eax,%edx
  80136f:	c1 ea 0c             	shr    $0xc,%edx
  801372:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801379:	f6 c2 01             	test   $0x1,%dl
  80137c:	74 1a                	je     801398 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80137e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801381:	89 02                	mov    %eax,(%edx)
	return 0;
  801383:	b8 00 00 00 00       	mov    $0x0,%eax
  801388:	eb 13                	jmp    80139d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138f:	eb 0c                	jmp    80139d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801391:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801396:	eb 05                	jmp    80139d <fd_lookup+0x54>
  801398:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80139d:	5d                   	pop    %ebp
  80139e:	c3                   	ret    

0080139f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a8:	ba cc 2c 80 00       	mov    $0x802ccc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013ad:	eb 13                	jmp    8013c2 <dev_lookup+0x23>
  8013af:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013b2:	39 08                	cmp    %ecx,(%eax)
  8013b4:	75 0c                	jne    8013c2 <dev_lookup+0x23>
			*dev = devtab[i];
  8013b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c0:	eb 2e                	jmp    8013f0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013c2:	8b 02                	mov    (%edx),%eax
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	75 e7                	jne    8013af <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c8:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8013cd:	8b 40 48             	mov    0x48(%eax),%eax
  8013d0:	83 ec 04             	sub    $0x4,%esp
  8013d3:	51                   	push   %ecx
  8013d4:	50                   	push   %eax
  8013d5:	68 4c 2c 80 00       	push   $0x802c4c
  8013da:	e8 f1 f2 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  8013df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    

008013f2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
  8013f7:	83 ec 10             	sub    $0x10,%esp
  8013fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8013fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801400:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801403:	50                   	push   %eax
  801404:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80140a:	c1 e8 0c             	shr    $0xc,%eax
  80140d:	50                   	push   %eax
  80140e:	e8 36 ff ff ff       	call   801349 <fd_lookup>
  801413:	83 c4 08             	add    $0x8,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 05                	js     80141f <fd_close+0x2d>
	    || fd != fd2)
  80141a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80141d:	74 0c                	je     80142b <fd_close+0x39>
		return (must_exist ? r : 0);
  80141f:	84 db                	test   %bl,%bl
  801421:	ba 00 00 00 00       	mov    $0x0,%edx
  801426:	0f 44 c2             	cmove  %edx,%eax
  801429:	eb 41                	jmp    80146c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	ff 36                	pushl  (%esi)
  801434:	e8 66 ff ff ff       	call   80139f <dev_lookup>
  801439:	89 c3                	mov    %eax,%ebx
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 1a                	js     80145c <fd_close+0x6a>
		if (dev->dev_close)
  801442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801445:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801448:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80144d:	85 c0                	test   %eax,%eax
  80144f:	74 0b                	je     80145c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	56                   	push   %esi
  801455:	ff d0                	call   *%eax
  801457:	89 c3                	mov    %eax,%ebx
  801459:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	56                   	push   %esi
  801460:	6a 00                	push   $0x0
  801462:	e8 76 fc ff ff       	call   8010dd <sys_page_unmap>
	return r;
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	89 d8                	mov    %ebx,%eax
}
  80146c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146f:	5b                   	pop    %ebx
  801470:	5e                   	pop    %esi
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801479:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	ff 75 08             	pushl  0x8(%ebp)
  801480:	e8 c4 fe ff ff       	call   801349 <fd_lookup>
  801485:	83 c4 08             	add    $0x8,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 10                	js     80149c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	6a 01                	push   $0x1
  801491:	ff 75 f4             	pushl  -0xc(%ebp)
  801494:	e8 59 ff ff ff       	call   8013f2 <fd_close>
  801499:	83 c4 10             	add    $0x10,%esp
}
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <close_all>:

void
close_all(void)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014aa:	83 ec 0c             	sub    $0xc,%esp
  8014ad:	53                   	push   %ebx
  8014ae:	e8 c0 ff ff ff       	call   801473 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b3:	83 c3 01             	add    $0x1,%ebx
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	83 fb 20             	cmp    $0x20,%ebx
  8014bc:	75 ec                	jne    8014aa <close_all+0xc>
		close(i);
}
  8014be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c1:	c9                   	leave  
  8014c2:	c3                   	ret    

008014c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	57                   	push   %edi
  8014c7:	56                   	push   %esi
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 2c             	sub    $0x2c,%esp
  8014cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	ff 75 08             	pushl  0x8(%ebp)
  8014d6:	e8 6e fe ff ff       	call   801349 <fd_lookup>
  8014db:	83 c4 08             	add    $0x8,%esp
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	0f 88 c1 00 00 00    	js     8015a7 <dup+0xe4>
		return r;
	close(newfdnum);
  8014e6:	83 ec 0c             	sub    $0xc,%esp
  8014e9:	56                   	push   %esi
  8014ea:	e8 84 ff ff ff       	call   801473 <close>

	newfd = INDEX2FD(newfdnum);
  8014ef:	89 f3                	mov    %esi,%ebx
  8014f1:	c1 e3 0c             	shl    $0xc,%ebx
  8014f4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014fa:	83 c4 04             	add    $0x4,%esp
  8014fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801500:	e8 de fd ff ff       	call   8012e3 <fd2data>
  801505:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801507:	89 1c 24             	mov    %ebx,(%esp)
  80150a:	e8 d4 fd ff ff       	call   8012e3 <fd2data>
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801515:	89 f8                	mov    %edi,%eax
  801517:	c1 e8 16             	shr    $0x16,%eax
  80151a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801521:	a8 01                	test   $0x1,%al
  801523:	74 37                	je     80155c <dup+0x99>
  801525:	89 f8                	mov    %edi,%eax
  801527:	c1 e8 0c             	shr    $0xc,%eax
  80152a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801531:	f6 c2 01             	test   $0x1,%dl
  801534:	74 26                	je     80155c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801536:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153d:	83 ec 0c             	sub    $0xc,%esp
  801540:	25 07 0e 00 00       	and    $0xe07,%eax
  801545:	50                   	push   %eax
  801546:	ff 75 d4             	pushl  -0x2c(%ebp)
  801549:	6a 00                	push   $0x0
  80154b:	57                   	push   %edi
  80154c:	6a 00                	push   $0x0
  80154e:	e8 48 fb ff ff       	call   80109b <sys_page_map>
  801553:	89 c7                	mov    %eax,%edi
  801555:	83 c4 20             	add    $0x20,%esp
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 2e                	js     80158a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80155c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80155f:	89 d0                	mov    %edx,%eax
  801561:	c1 e8 0c             	shr    $0xc,%eax
  801564:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80156b:	83 ec 0c             	sub    $0xc,%esp
  80156e:	25 07 0e 00 00       	and    $0xe07,%eax
  801573:	50                   	push   %eax
  801574:	53                   	push   %ebx
  801575:	6a 00                	push   $0x0
  801577:	52                   	push   %edx
  801578:	6a 00                	push   $0x0
  80157a:	e8 1c fb ff ff       	call   80109b <sys_page_map>
  80157f:	89 c7                	mov    %eax,%edi
  801581:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801584:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801586:	85 ff                	test   %edi,%edi
  801588:	79 1d                	jns    8015a7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80158a:	83 ec 08             	sub    $0x8,%esp
  80158d:	53                   	push   %ebx
  80158e:	6a 00                	push   $0x0
  801590:	e8 48 fb ff ff       	call   8010dd <sys_page_unmap>
	sys_page_unmap(0, nva);
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	ff 75 d4             	pushl  -0x2c(%ebp)
  80159b:	6a 00                	push   $0x0
  80159d:	e8 3b fb ff ff       	call   8010dd <sys_page_unmap>
	return r;
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	89 f8                	mov    %edi,%eax
}
  8015a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015aa:	5b                   	pop    %ebx
  8015ab:	5e                   	pop    %esi
  8015ac:	5f                   	pop    %edi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    

008015af <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 14             	sub    $0x14,%esp
  8015b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	53                   	push   %ebx
  8015be:	e8 86 fd ff ff       	call   801349 <fd_lookup>
  8015c3:	83 c4 08             	add    $0x8,%esp
  8015c6:	89 c2                	mov    %eax,%edx
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 6d                	js     801639 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d2:	50                   	push   %eax
  8015d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d6:	ff 30                	pushl  (%eax)
  8015d8:	e8 c2 fd ff ff       	call   80139f <dev_lookup>
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	78 4c                	js     801630 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e7:	8b 42 08             	mov    0x8(%edx),%eax
  8015ea:	83 e0 03             	and    $0x3,%eax
  8015ed:	83 f8 01             	cmp    $0x1,%eax
  8015f0:	75 21                	jne    801613 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f2:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8015f7:	8b 40 48             	mov    0x48(%eax),%eax
  8015fa:	83 ec 04             	sub    $0x4,%esp
  8015fd:	53                   	push   %ebx
  8015fe:	50                   	push   %eax
  8015ff:	68 90 2c 80 00       	push   $0x802c90
  801604:	e8 c7 f0 ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801611:	eb 26                	jmp    801639 <read+0x8a>
	}
	if (!dev->dev_read)
  801613:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801616:	8b 40 08             	mov    0x8(%eax),%eax
  801619:	85 c0                	test   %eax,%eax
  80161b:	74 17                	je     801634 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80161d:	83 ec 04             	sub    $0x4,%esp
  801620:	ff 75 10             	pushl  0x10(%ebp)
  801623:	ff 75 0c             	pushl  0xc(%ebp)
  801626:	52                   	push   %edx
  801627:	ff d0                	call   *%eax
  801629:	89 c2                	mov    %eax,%edx
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	eb 09                	jmp    801639 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801630:	89 c2                	mov    %eax,%edx
  801632:	eb 05                	jmp    801639 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801634:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801639:	89 d0                	mov    %edx,%eax
  80163b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	57                   	push   %edi
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
  801646:	83 ec 0c             	sub    $0xc,%esp
  801649:	8b 7d 08             	mov    0x8(%ebp),%edi
  80164c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801654:	eb 21                	jmp    801677 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801656:	83 ec 04             	sub    $0x4,%esp
  801659:	89 f0                	mov    %esi,%eax
  80165b:	29 d8                	sub    %ebx,%eax
  80165d:	50                   	push   %eax
  80165e:	89 d8                	mov    %ebx,%eax
  801660:	03 45 0c             	add    0xc(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	57                   	push   %edi
  801665:	e8 45 ff ff ff       	call   8015af <read>
		if (m < 0)
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 10                	js     801681 <readn+0x41>
			return m;
		if (m == 0)
  801671:	85 c0                	test   %eax,%eax
  801673:	74 0a                	je     80167f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801675:	01 c3                	add    %eax,%ebx
  801677:	39 f3                	cmp    %esi,%ebx
  801679:	72 db                	jb     801656 <readn+0x16>
  80167b:	89 d8                	mov    %ebx,%eax
  80167d:	eb 02                	jmp    801681 <readn+0x41>
  80167f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801681:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801684:	5b                   	pop    %ebx
  801685:	5e                   	pop    %esi
  801686:	5f                   	pop    %edi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    

00801689 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	53                   	push   %ebx
  80168d:	83 ec 14             	sub    $0x14,%esp
  801690:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801693:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	53                   	push   %ebx
  801698:	e8 ac fc ff ff       	call   801349 <fd_lookup>
  80169d:	83 c4 08             	add    $0x8,%esp
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 68                	js     80170e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b0:	ff 30                	pushl  (%eax)
  8016b2:	e8 e8 fc ff ff       	call   80139f <dev_lookup>
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 47                	js     801705 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c5:	75 21                	jne    8016e8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c7:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8016cc:	8b 40 48             	mov    0x48(%eax),%eax
  8016cf:	83 ec 04             	sub    $0x4,%esp
  8016d2:	53                   	push   %ebx
  8016d3:	50                   	push   %eax
  8016d4:	68 ac 2c 80 00       	push   $0x802cac
  8016d9:	e8 f2 ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e6:	eb 26                	jmp    80170e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ee:	85 d2                	test   %edx,%edx
  8016f0:	74 17                	je     801709 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f2:	83 ec 04             	sub    $0x4,%esp
  8016f5:	ff 75 10             	pushl  0x10(%ebp)
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	50                   	push   %eax
  8016fc:	ff d2                	call   *%edx
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	eb 09                	jmp    80170e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801705:	89 c2                	mov    %eax,%edx
  801707:	eb 05                	jmp    80170e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801709:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80170e:	89 d0                	mov    %edx,%eax
  801710:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <seek>:

int
seek(int fdnum, off_t offset)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	ff 75 08             	pushl  0x8(%ebp)
  801722:	e8 22 fc ff ff       	call   801349 <fd_lookup>
  801727:	83 c4 08             	add    $0x8,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 0e                	js     80173c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80172e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801731:	8b 55 0c             	mov    0xc(%ebp),%edx
  801734:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801737:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	83 ec 14             	sub    $0x14,%esp
  801745:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801748:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174b:	50                   	push   %eax
  80174c:	53                   	push   %ebx
  80174d:	e8 f7 fb ff ff       	call   801349 <fd_lookup>
  801752:	83 c4 08             	add    $0x8,%esp
  801755:	89 c2                	mov    %eax,%edx
  801757:	85 c0                	test   %eax,%eax
  801759:	78 65                	js     8017c0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175b:	83 ec 08             	sub    $0x8,%esp
  80175e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801765:	ff 30                	pushl  (%eax)
  801767:	e8 33 fc ff ff       	call   80139f <dev_lookup>
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 44                	js     8017b7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801773:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801776:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177a:	75 21                	jne    80179d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80177c:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801781:	8b 40 48             	mov    0x48(%eax),%eax
  801784:	83 ec 04             	sub    $0x4,%esp
  801787:	53                   	push   %ebx
  801788:	50                   	push   %eax
  801789:	68 6c 2c 80 00       	push   $0x802c6c
  80178e:	e8 3d ef ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80179b:	eb 23                	jmp    8017c0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80179d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a0:	8b 52 18             	mov    0x18(%edx),%edx
  8017a3:	85 d2                	test   %edx,%edx
  8017a5:	74 14                	je     8017bb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	ff 75 0c             	pushl  0xc(%ebp)
  8017ad:	50                   	push   %eax
  8017ae:	ff d2                	call   *%edx
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	eb 09                	jmp    8017c0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	eb 05                	jmp    8017c0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c0:	89 d0                	mov    %edx,%eax
  8017c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 14             	sub    $0x14,%esp
  8017ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d4:	50                   	push   %eax
  8017d5:	ff 75 08             	pushl  0x8(%ebp)
  8017d8:	e8 6c fb ff ff       	call   801349 <fd_lookup>
  8017dd:	83 c4 08             	add    $0x8,%esp
  8017e0:	89 c2                	mov    %eax,%edx
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 58                	js     80183e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e6:	83 ec 08             	sub    $0x8,%esp
  8017e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ec:	50                   	push   %eax
  8017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f0:	ff 30                	pushl  (%eax)
  8017f2:	e8 a8 fb ff ff       	call   80139f <dev_lookup>
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 37                	js     801835 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801801:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801805:	74 32                	je     801839 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801807:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80180a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801811:	00 00 00 
	stat->st_isdir = 0;
  801814:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80181b:	00 00 00 
	stat->st_dev = dev;
  80181e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	53                   	push   %ebx
  801828:	ff 75 f0             	pushl  -0x10(%ebp)
  80182b:	ff 50 14             	call   *0x14(%eax)
  80182e:	89 c2                	mov    %eax,%edx
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	eb 09                	jmp    80183e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801835:	89 c2                	mov    %eax,%edx
  801837:	eb 05                	jmp    80183e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801839:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80183e:	89 d0                	mov    %edx,%eax
  801840:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80184a:	83 ec 08             	sub    $0x8,%esp
  80184d:	6a 00                	push   $0x0
  80184f:	ff 75 08             	pushl  0x8(%ebp)
  801852:	e8 d6 01 00 00       	call   801a2d <open>
  801857:	89 c3                	mov    %eax,%ebx
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 1b                	js     80187b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	ff 75 0c             	pushl  0xc(%ebp)
  801866:	50                   	push   %eax
  801867:	e8 5b ff ff ff       	call   8017c7 <fstat>
  80186c:	89 c6                	mov    %eax,%esi
	close(fd);
  80186e:	89 1c 24             	mov    %ebx,(%esp)
  801871:	e8 fd fb ff ff       	call   801473 <close>
	return r;
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	89 f0                	mov    %esi,%eax
}
  80187b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187e:	5b                   	pop    %ebx
  80187f:	5e                   	pop    %esi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	56                   	push   %esi
  801886:	53                   	push   %ebx
  801887:	89 c6                	mov    %eax,%esi
  801889:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80188b:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801892:	75 12                	jne    8018a6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	6a 01                	push   $0x1
  801899:	e8 34 0c 00 00       	call   8024d2 <ipc_find_env>
  80189e:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018a3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a6:	6a 07                	push   $0x7
  8018a8:	68 00 50 80 00       	push   $0x805000
  8018ad:	56                   	push   %esi
  8018ae:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018b4:	e8 c5 0b 00 00       	call   80247e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018b9:	83 c4 0c             	add    $0xc,%esp
  8018bc:	6a 00                	push   $0x0
  8018be:	53                   	push   %ebx
  8018bf:	6a 00                	push   $0x0
  8018c1:	e8 51 0b 00 00       	call   802417 <ipc_recv>
}
  8018c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c9:	5b                   	pop    %ebx
  8018ca:	5e                   	pop    %esi
  8018cb:	5d                   	pop    %ebp
  8018cc:	c3                   	ret    

008018cd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f0:	e8 8d ff ff ff       	call   801882 <fsipc>
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	8b 40 0c             	mov    0xc(%eax),%eax
  801903:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801908:	ba 00 00 00 00       	mov    $0x0,%edx
  80190d:	b8 06 00 00 00       	mov    $0x6,%eax
  801912:	e8 6b ff ff ff       	call   801882 <fsipc>
}
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	53                   	push   %ebx
  80191d:	83 ec 04             	sub    $0x4,%esp
  801920:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	8b 40 0c             	mov    0xc(%eax),%eax
  801929:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80192e:	ba 00 00 00 00       	mov    $0x0,%edx
  801933:	b8 05 00 00 00       	mov    $0x5,%eax
  801938:	e8 45 ff ff ff       	call   801882 <fsipc>
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 2c                	js     80196d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	68 00 50 80 00       	push   $0x805000
  801949:	53                   	push   %ebx
  80194a:	e8 06 f3 ff ff       	call   800c55 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80194f:	a1 80 50 80 00       	mov    0x805080,%eax
  801954:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80195a:	a1 84 50 80 00       	mov    0x805084,%eax
  80195f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 0c             	sub    $0xc,%esp
  801978:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80197b:	8b 55 08             	mov    0x8(%ebp),%edx
  80197e:	8b 52 0c             	mov    0xc(%edx),%edx
  801981:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801987:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80198c:	50                   	push   %eax
  80198d:	ff 75 0c             	pushl  0xc(%ebp)
  801990:	68 08 50 80 00       	push   $0x805008
  801995:	e8 4d f4 ff ff       	call   800de7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80199a:	ba 00 00 00 00       	mov    $0x0,%edx
  80199f:	b8 04 00 00 00       	mov    $0x4,%eax
  8019a4:	e8 d9 fe ff ff       	call   801882 <fsipc>

}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	56                   	push   %esi
  8019af:	53                   	push   %ebx
  8019b0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019be:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ce:	e8 af fe ff ff       	call   801882 <fsipc>
  8019d3:	89 c3                	mov    %eax,%ebx
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 4b                	js     801a24 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019d9:	39 c6                	cmp    %eax,%esi
  8019db:	73 16                	jae    8019f3 <devfile_read+0x48>
  8019dd:	68 e0 2c 80 00       	push   $0x802ce0
  8019e2:	68 e7 2c 80 00       	push   $0x802ce7
  8019e7:	6a 7c                	push   $0x7c
  8019e9:	68 fc 2c 80 00       	push   $0x802cfc
  8019ee:	e8 04 ec ff ff       	call   8005f7 <_panic>
	assert(r <= PGSIZE);
  8019f3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019f8:	7e 16                	jle    801a10 <devfile_read+0x65>
  8019fa:	68 07 2d 80 00       	push   $0x802d07
  8019ff:	68 e7 2c 80 00       	push   $0x802ce7
  801a04:	6a 7d                	push   $0x7d
  801a06:	68 fc 2c 80 00       	push   $0x802cfc
  801a0b:	e8 e7 eb ff ff       	call   8005f7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a10:	83 ec 04             	sub    $0x4,%esp
  801a13:	50                   	push   %eax
  801a14:	68 00 50 80 00       	push   $0x805000
  801a19:	ff 75 0c             	pushl  0xc(%ebp)
  801a1c:	e8 c6 f3 ff ff       	call   800de7 <memmove>
	return r;
  801a21:	83 c4 10             	add    $0x10,%esp
}
  801a24:	89 d8                	mov    %ebx,%eax
  801a26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    

00801a2d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	53                   	push   %ebx
  801a31:	83 ec 20             	sub    $0x20,%esp
  801a34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a37:	53                   	push   %ebx
  801a38:	e8 df f1 ff ff       	call   800c1c <strlen>
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a45:	7f 67                	jg     801aae <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4d:	50                   	push   %eax
  801a4e:	e8 a7 f8 ff ff       	call   8012fa <fd_alloc>
  801a53:	83 c4 10             	add    $0x10,%esp
		return r;
  801a56:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 57                	js     801ab3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	53                   	push   %ebx
  801a60:	68 00 50 80 00       	push   $0x805000
  801a65:	e8 eb f1 ff ff       	call   800c55 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a75:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7a:	e8 03 fe ff ff       	call   801882 <fsipc>
  801a7f:	89 c3                	mov    %eax,%ebx
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	85 c0                	test   %eax,%eax
  801a86:	79 14                	jns    801a9c <open+0x6f>
		fd_close(fd, 0);
  801a88:	83 ec 08             	sub    $0x8,%esp
  801a8b:	6a 00                	push   $0x0
  801a8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a90:	e8 5d f9 ff ff       	call   8013f2 <fd_close>
		return r;
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	89 da                	mov    %ebx,%edx
  801a9a:	eb 17                	jmp    801ab3 <open+0x86>
	}

	return fd2num(fd);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa2:	e8 2c f8 ff ff       	call   8012d3 <fd2num>
  801aa7:	89 c2                	mov    %eax,%edx
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	eb 05                	jmp    801ab3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aae:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ab3:	89 d0                	mov    %edx,%eax
  801ab5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac5:	b8 08 00 00 00       	mov    $0x8,%eax
  801aca:	e8 b3 fd ff ff       	call   801882 <fsipc>
}
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ad7:	68 13 2d 80 00       	push   $0x802d13
  801adc:	ff 75 0c             	pushl  0xc(%ebp)
  801adf:	e8 71 f1 ff ff       	call   800c55 <strcpy>
	return 0;
}
  801ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae9:	c9                   	leave  
  801aea:	c3                   	ret    

00801aeb <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	53                   	push   %ebx
  801aef:	83 ec 10             	sub    $0x10,%esp
  801af2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801af5:	53                   	push   %ebx
  801af6:	e8 10 0a 00 00       	call   80250b <pageref>
  801afb:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801afe:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b03:	83 f8 01             	cmp    $0x1,%eax
  801b06:	75 10                	jne    801b18 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b08:	83 ec 0c             	sub    $0xc,%esp
  801b0b:	ff 73 0c             	pushl  0xc(%ebx)
  801b0e:	e8 c0 02 00 00       	call   801dd3 <nsipc_close>
  801b13:	89 c2                	mov    %eax,%edx
  801b15:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b18:	89 d0                	mov    %edx,%eax
  801b1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b25:	6a 00                	push   $0x0
  801b27:	ff 75 10             	pushl  0x10(%ebp)
  801b2a:	ff 75 0c             	pushl  0xc(%ebp)
  801b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b30:	ff 70 0c             	pushl  0xc(%eax)
  801b33:	e8 78 03 00 00       	call   801eb0 <nsipc_send>
}
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    

00801b3a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b40:	6a 00                	push   $0x0
  801b42:	ff 75 10             	pushl  0x10(%ebp)
  801b45:	ff 75 0c             	pushl  0xc(%ebp)
  801b48:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4b:	ff 70 0c             	pushl  0xc(%eax)
  801b4e:	e8 f1 02 00 00       	call   801e44 <nsipc_recv>
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b5b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b5e:	52                   	push   %edx
  801b5f:	50                   	push   %eax
  801b60:	e8 e4 f7 ff ff       	call   801349 <fd_lookup>
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	78 17                	js     801b83 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6f:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b75:	39 08                	cmp    %ecx,(%eax)
  801b77:	75 05                	jne    801b7e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b79:	8b 40 0c             	mov    0xc(%eax),%eax
  801b7c:	eb 05                	jmp    801b83 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b7e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 1c             	sub    $0x1c,%esp
  801b8d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b92:	50                   	push   %eax
  801b93:	e8 62 f7 ff ff       	call   8012fa <fd_alloc>
  801b98:	89 c3                	mov    %eax,%ebx
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	78 1b                	js     801bbc <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ba1:	83 ec 04             	sub    $0x4,%esp
  801ba4:	68 07 04 00 00       	push   $0x407
  801ba9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bac:	6a 00                	push   $0x0
  801bae:	e8 a5 f4 ff ff       	call   801058 <sys_page_alloc>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	79 10                	jns    801bcc <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801bbc:	83 ec 0c             	sub    $0xc,%esp
  801bbf:	56                   	push   %esi
  801bc0:	e8 0e 02 00 00       	call   801dd3 <nsipc_close>
		return r;
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	89 d8                	mov    %ebx,%eax
  801bca:	eb 24                	jmp    801bf0 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bcc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bda:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801be1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801be4:	83 ec 0c             	sub    $0xc,%esp
  801be7:	50                   	push   %eax
  801be8:	e8 e6 f6 ff ff       	call   8012d3 <fd2num>
  801bed:	83 c4 10             	add    $0x10,%esp
}
  801bf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5d                   	pop    %ebp
  801bf6:	c3                   	ret    

00801bf7 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801c00:	e8 50 ff ff ff       	call   801b55 <fd2sockid>
		return r;
  801c05:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 1f                	js     801c2a <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c0b:	83 ec 04             	sub    $0x4,%esp
  801c0e:	ff 75 10             	pushl  0x10(%ebp)
  801c11:	ff 75 0c             	pushl  0xc(%ebp)
  801c14:	50                   	push   %eax
  801c15:	e8 12 01 00 00       	call   801d2c <nsipc_accept>
  801c1a:	83 c4 10             	add    $0x10,%esp
		return r;
  801c1d:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	78 07                	js     801c2a <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c23:	e8 5d ff ff ff       	call   801b85 <alloc_sockfd>
  801c28:	89 c1                	mov    %eax,%ecx
}
  801c2a:	89 c8                	mov    %ecx,%eax
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c34:	8b 45 08             	mov    0x8(%ebp),%eax
  801c37:	e8 19 ff ff ff       	call   801b55 <fd2sockid>
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	78 12                	js     801c52 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c40:	83 ec 04             	sub    $0x4,%esp
  801c43:	ff 75 10             	pushl  0x10(%ebp)
  801c46:	ff 75 0c             	pushl  0xc(%ebp)
  801c49:	50                   	push   %eax
  801c4a:	e8 2d 01 00 00       	call   801d7c <nsipc_bind>
  801c4f:	83 c4 10             	add    $0x10,%esp
}
  801c52:	c9                   	leave  
  801c53:	c3                   	ret    

00801c54 <shutdown>:

int
shutdown(int s, int how)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	e8 f3 fe ff ff       	call   801b55 <fd2sockid>
  801c62:	85 c0                	test   %eax,%eax
  801c64:	78 0f                	js     801c75 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c66:	83 ec 08             	sub    $0x8,%esp
  801c69:	ff 75 0c             	pushl  0xc(%ebp)
  801c6c:	50                   	push   %eax
  801c6d:	e8 3f 01 00 00       	call   801db1 <nsipc_shutdown>
  801c72:	83 c4 10             	add    $0x10,%esp
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	e8 d0 fe ff ff       	call   801b55 <fd2sockid>
  801c85:	85 c0                	test   %eax,%eax
  801c87:	78 12                	js     801c9b <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c89:	83 ec 04             	sub    $0x4,%esp
  801c8c:	ff 75 10             	pushl  0x10(%ebp)
  801c8f:	ff 75 0c             	pushl  0xc(%ebp)
  801c92:	50                   	push   %eax
  801c93:	e8 55 01 00 00       	call   801ded <nsipc_connect>
  801c98:	83 c4 10             	add    $0x10,%esp
}
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <listen>:

int
listen(int s, int backlog)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	e8 aa fe ff ff       	call   801b55 <fd2sockid>
  801cab:	85 c0                	test   %eax,%eax
  801cad:	78 0f                	js     801cbe <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801caf:	83 ec 08             	sub    $0x8,%esp
  801cb2:	ff 75 0c             	pushl  0xc(%ebp)
  801cb5:	50                   	push   %eax
  801cb6:	e8 67 01 00 00       	call   801e22 <nsipc_listen>
  801cbb:	83 c4 10             	add    $0x10,%esp
}
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cc6:	ff 75 10             	pushl  0x10(%ebp)
  801cc9:	ff 75 0c             	pushl  0xc(%ebp)
  801ccc:	ff 75 08             	pushl  0x8(%ebp)
  801ccf:	e8 3a 02 00 00       	call   801f0e <nsipc_socket>
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	78 05                	js     801ce0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801cdb:	e8 a5 fe ff ff       	call   801b85 <alloc_sockfd>
}
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 04             	sub    $0x4,%esp
  801ce9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ceb:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  801cf2:	75 12                	jne    801d06 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cf4:	83 ec 0c             	sub    $0xc,%esp
  801cf7:	6a 02                	push   $0x2
  801cf9:	e8 d4 07 00 00       	call   8024d2 <ipc_find_env>
  801cfe:	a3 b0 40 80 00       	mov    %eax,0x8040b0
  801d03:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d06:	6a 07                	push   $0x7
  801d08:	68 00 60 80 00       	push   $0x806000
  801d0d:	53                   	push   %ebx
  801d0e:	ff 35 b0 40 80 00    	pushl  0x8040b0
  801d14:	e8 65 07 00 00       	call   80247e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d19:	83 c4 0c             	add    $0xc,%esp
  801d1c:	6a 00                	push   $0x0
  801d1e:	6a 00                	push   $0x0
  801d20:	6a 00                	push   $0x0
  801d22:	e8 f0 06 00 00       	call   802417 <ipc_recv>
}
  801d27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d2a:	c9                   	leave  
  801d2b:	c3                   	ret    

00801d2c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	56                   	push   %esi
  801d30:	53                   	push   %ebx
  801d31:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d3c:	8b 06                	mov    (%esi),%eax
  801d3e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d43:	b8 01 00 00 00       	mov    $0x1,%eax
  801d48:	e8 95 ff ff ff       	call   801ce2 <nsipc>
  801d4d:	89 c3                	mov    %eax,%ebx
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	78 20                	js     801d73 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d53:	83 ec 04             	sub    $0x4,%esp
  801d56:	ff 35 10 60 80 00    	pushl  0x806010
  801d5c:	68 00 60 80 00       	push   $0x806000
  801d61:	ff 75 0c             	pushl  0xc(%ebp)
  801d64:	e8 7e f0 ff ff       	call   800de7 <memmove>
		*addrlen = ret->ret_addrlen;
  801d69:	a1 10 60 80 00       	mov    0x806010,%eax
  801d6e:	89 06                	mov    %eax,(%esi)
  801d70:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d73:	89 d8                	mov    %ebx,%eax
  801d75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d78:	5b                   	pop    %ebx
  801d79:	5e                   	pop    %esi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    

00801d7c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	53                   	push   %ebx
  801d80:	83 ec 08             	sub    $0x8,%esp
  801d83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d86:	8b 45 08             	mov    0x8(%ebp),%eax
  801d89:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d8e:	53                   	push   %ebx
  801d8f:	ff 75 0c             	pushl  0xc(%ebp)
  801d92:	68 04 60 80 00       	push   $0x806004
  801d97:	e8 4b f0 ff ff       	call   800de7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d9c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801da2:	b8 02 00 00 00       	mov    $0x2,%eax
  801da7:	e8 36 ff ff ff       	call   801ce2 <nsipc>
}
  801dac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801daf:	c9                   	leave  
  801db0:	c3                   	ret    

00801db1 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801db7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801dc7:	b8 03 00 00 00       	mov    $0x3,%eax
  801dcc:	e8 11 ff ff ff       	call   801ce2 <nsipc>
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <nsipc_close>:

int
nsipc_close(int s)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801de1:	b8 04 00 00 00       	mov    $0x4,%eax
  801de6:	e8 f7 fe ff ff       	call   801ce2 <nsipc>
}
  801deb:	c9                   	leave  
  801dec:	c3                   	ret    

00801ded <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	53                   	push   %ebx
  801df1:	83 ec 08             	sub    $0x8,%esp
  801df4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801df7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfa:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dff:	53                   	push   %ebx
  801e00:	ff 75 0c             	pushl  0xc(%ebp)
  801e03:	68 04 60 80 00       	push   $0x806004
  801e08:	e8 da ef ff ff       	call   800de7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e0d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e13:	b8 05 00 00 00       	mov    $0x5,%eax
  801e18:	e8 c5 fe ff ff       	call   801ce2 <nsipc>
}
  801e1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    

00801e22 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e28:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e33:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e38:	b8 06 00 00 00       	mov    $0x6,%eax
  801e3d:	e8 a0 fe ff ff       	call   801ce2 <nsipc>
}
  801e42:	c9                   	leave  
  801e43:	c3                   	ret    

00801e44 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	56                   	push   %esi
  801e48:	53                   	push   %ebx
  801e49:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e54:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e5a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e5d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e62:	b8 07 00 00 00       	mov    $0x7,%eax
  801e67:	e8 76 fe ff ff       	call   801ce2 <nsipc>
  801e6c:	89 c3                	mov    %eax,%ebx
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	78 35                	js     801ea7 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e72:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e77:	7f 04                	jg     801e7d <nsipc_recv+0x39>
  801e79:	39 c6                	cmp    %eax,%esi
  801e7b:	7d 16                	jge    801e93 <nsipc_recv+0x4f>
  801e7d:	68 1f 2d 80 00       	push   $0x802d1f
  801e82:	68 e7 2c 80 00       	push   $0x802ce7
  801e87:	6a 62                	push   $0x62
  801e89:	68 34 2d 80 00       	push   $0x802d34
  801e8e:	e8 64 e7 ff ff       	call   8005f7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e93:	83 ec 04             	sub    $0x4,%esp
  801e96:	50                   	push   %eax
  801e97:	68 00 60 80 00       	push   $0x806000
  801e9c:	ff 75 0c             	pushl  0xc(%ebp)
  801e9f:	e8 43 ef ff ff       	call   800de7 <memmove>
  801ea4:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ea7:	89 d8                	mov    %ebx,%eax
  801ea9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eac:	5b                   	pop    %ebx
  801ead:	5e                   	pop    %esi
  801eae:	5d                   	pop    %ebp
  801eaf:	c3                   	ret    

00801eb0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 04             	sub    $0x4,%esp
  801eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801eba:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebd:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ec2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ec8:	7e 16                	jle    801ee0 <nsipc_send+0x30>
  801eca:	68 40 2d 80 00       	push   $0x802d40
  801ecf:	68 e7 2c 80 00       	push   $0x802ce7
  801ed4:	6a 6d                	push   $0x6d
  801ed6:	68 34 2d 80 00       	push   $0x802d34
  801edb:	e8 17 e7 ff ff       	call   8005f7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ee0:	83 ec 04             	sub    $0x4,%esp
  801ee3:	53                   	push   %ebx
  801ee4:	ff 75 0c             	pushl  0xc(%ebp)
  801ee7:	68 0c 60 80 00       	push   $0x80600c
  801eec:	e8 f6 ee ff ff       	call   800de7 <memmove>
	nsipcbuf.send.req_size = size;
  801ef1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ef7:	8b 45 14             	mov    0x14(%ebp),%eax
  801efa:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801eff:	b8 08 00 00 00       	mov    $0x8,%eax
  801f04:	e8 d9 fd ff ff       	call   801ce2 <nsipc>
}
  801f09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f0c:	c9                   	leave  
  801f0d:	c3                   	ret    

00801f0e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f14:	8b 45 08             	mov    0x8(%ebp),%eax
  801f17:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f24:	8b 45 10             	mov    0x10(%ebp),%eax
  801f27:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f2c:	b8 09 00 00 00       	mov    $0x9,%eax
  801f31:	e8 ac fd ff ff       	call   801ce2 <nsipc>
}
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	56                   	push   %esi
  801f3c:	53                   	push   %ebx
  801f3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f40:	83 ec 0c             	sub    $0xc,%esp
  801f43:	ff 75 08             	pushl  0x8(%ebp)
  801f46:	e8 98 f3 ff ff       	call   8012e3 <fd2data>
  801f4b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f4d:	83 c4 08             	add    $0x8,%esp
  801f50:	68 4c 2d 80 00       	push   $0x802d4c
  801f55:	53                   	push   %ebx
  801f56:	e8 fa ec ff ff       	call   800c55 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f5b:	8b 46 04             	mov    0x4(%esi),%eax
  801f5e:	2b 06                	sub    (%esi),%eax
  801f60:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f66:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f6d:	00 00 00 
	stat->st_dev = &devpipe;
  801f70:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f77:	30 80 00 
	return 0;
}
  801f7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f82:	5b                   	pop    %ebx
  801f83:	5e                   	pop    %esi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    

00801f86 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	53                   	push   %ebx
  801f8a:	83 ec 0c             	sub    $0xc,%esp
  801f8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f90:	53                   	push   %ebx
  801f91:	6a 00                	push   $0x0
  801f93:	e8 45 f1 ff ff       	call   8010dd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f98:	89 1c 24             	mov    %ebx,(%esp)
  801f9b:	e8 43 f3 ff ff       	call   8012e3 <fd2data>
  801fa0:	83 c4 08             	add    $0x8,%esp
  801fa3:	50                   	push   %eax
  801fa4:	6a 00                	push   $0x0
  801fa6:	e8 32 f1 ff ff       	call   8010dd <sys_page_unmap>
}
  801fab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	57                   	push   %edi
  801fb4:	56                   	push   %esi
  801fb5:	53                   	push   %ebx
  801fb6:	83 ec 1c             	sub    $0x1c,%esp
  801fb9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fbc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fbe:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801fc3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fc6:	83 ec 0c             	sub    $0xc,%esp
  801fc9:	ff 75 e0             	pushl  -0x20(%ebp)
  801fcc:	e8 3a 05 00 00       	call   80250b <pageref>
  801fd1:	89 c3                	mov    %eax,%ebx
  801fd3:	89 3c 24             	mov    %edi,(%esp)
  801fd6:	e8 30 05 00 00       	call   80250b <pageref>
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	39 c3                	cmp    %eax,%ebx
  801fe0:	0f 94 c1             	sete   %cl
  801fe3:	0f b6 c9             	movzbl %cl,%ecx
  801fe6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fe9:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  801fef:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ff2:	39 ce                	cmp    %ecx,%esi
  801ff4:	74 1b                	je     802011 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ff6:	39 c3                	cmp    %eax,%ebx
  801ff8:	75 c4                	jne    801fbe <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ffa:	8b 42 58             	mov    0x58(%edx),%eax
  801ffd:	ff 75 e4             	pushl  -0x1c(%ebp)
  802000:	50                   	push   %eax
  802001:	56                   	push   %esi
  802002:	68 53 2d 80 00       	push   $0x802d53
  802007:	e8 c4 e6 ff ff       	call   8006d0 <cprintf>
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	eb ad                	jmp    801fbe <_pipeisclosed+0xe>
	}
}
  802011:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802014:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802017:	5b                   	pop    %ebx
  802018:	5e                   	pop    %esi
  802019:	5f                   	pop    %edi
  80201a:	5d                   	pop    %ebp
  80201b:	c3                   	ret    

0080201c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	57                   	push   %edi
  802020:	56                   	push   %esi
  802021:	53                   	push   %ebx
  802022:	83 ec 28             	sub    $0x28,%esp
  802025:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802028:	56                   	push   %esi
  802029:	e8 b5 f2 ff ff       	call   8012e3 <fd2data>
  80202e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802030:	83 c4 10             	add    $0x10,%esp
  802033:	bf 00 00 00 00       	mov    $0x0,%edi
  802038:	eb 4b                	jmp    802085 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80203a:	89 da                	mov    %ebx,%edx
  80203c:	89 f0                	mov    %esi,%eax
  80203e:	e8 6d ff ff ff       	call   801fb0 <_pipeisclosed>
  802043:	85 c0                	test   %eax,%eax
  802045:	75 48                	jne    80208f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802047:	e8 ed ef ff ff       	call   801039 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80204c:	8b 43 04             	mov    0x4(%ebx),%eax
  80204f:	8b 0b                	mov    (%ebx),%ecx
  802051:	8d 51 20             	lea    0x20(%ecx),%edx
  802054:	39 d0                	cmp    %edx,%eax
  802056:	73 e2                	jae    80203a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802058:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80205b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80205f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802062:	89 c2                	mov    %eax,%edx
  802064:	c1 fa 1f             	sar    $0x1f,%edx
  802067:	89 d1                	mov    %edx,%ecx
  802069:	c1 e9 1b             	shr    $0x1b,%ecx
  80206c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80206f:	83 e2 1f             	and    $0x1f,%edx
  802072:	29 ca                	sub    %ecx,%edx
  802074:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802078:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80207c:	83 c0 01             	add    $0x1,%eax
  80207f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802082:	83 c7 01             	add    $0x1,%edi
  802085:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802088:	75 c2                	jne    80204c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80208a:	8b 45 10             	mov    0x10(%ebp),%eax
  80208d:	eb 05                	jmp    802094 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80208f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802097:	5b                   	pop    %ebx
  802098:	5e                   	pop    %esi
  802099:	5f                   	pop    %edi
  80209a:	5d                   	pop    %ebp
  80209b:	c3                   	ret    

0080209c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	57                   	push   %edi
  8020a0:	56                   	push   %esi
  8020a1:	53                   	push   %ebx
  8020a2:	83 ec 18             	sub    $0x18,%esp
  8020a5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020a8:	57                   	push   %edi
  8020a9:	e8 35 f2 ff ff       	call   8012e3 <fd2data>
  8020ae:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020b0:	83 c4 10             	add    $0x10,%esp
  8020b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020b8:	eb 3d                	jmp    8020f7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020ba:	85 db                	test   %ebx,%ebx
  8020bc:	74 04                	je     8020c2 <devpipe_read+0x26>
				return i;
  8020be:	89 d8                	mov    %ebx,%eax
  8020c0:	eb 44                	jmp    802106 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020c2:	89 f2                	mov    %esi,%edx
  8020c4:	89 f8                	mov    %edi,%eax
  8020c6:	e8 e5 fe ff ff       	call   801fb0 <_pipeisclosed>
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	75 32                	jne    802101 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020cf:	e8 65 ef ff ff       	call   801039 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020d4:	8b 06                	mov    (%esi),%eax
  8020d6:	3b 46 04             	cmp    0x4(%esi),%eax
  8020d9:	74 df                	je     8020ba <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020db:	99                   	cltd   
  8020dc:	c1 ea 1b             	shr    $0x1b,%edx
  8020df:	01 d0                	add    %edx,%eax
  8020e1:	83 e0 1f             	and    $0x1f,%eax
  8020e4:	29 d0                	sub    %edx,%eax
  8020e6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020ee:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020f1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f4:	83 c3 01             	add    $0x1,%ebx
  8020f7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020fa:	75 d8                	jne    8020d4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ff:	eb 05                	jmp    802106 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802101:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802109:	5b                   	pop    %ebx
  80210a:	5e                   	pop    %esi
  80210b:	5f                   	pop    %edi
  80210c:	5d                   	pop    %ebp
  80210d:	c3                   	ret    

0080210e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
  802111:	56                   	push   %esi
  802112:	53                   	push   %ebx
  802113:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802116:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802119:	50                   	push   %eax
  80211a:	e8 db f1 ff ff       	call   8012fa <fd_alloc>
  80211f:	83 c4 10             	add    $0x10,%esp
  802122:	89 c2                	mov    %eax,%edx
  802124:	85 c0                	test   %eax,%eax
  802126:	0f 88 2c 01 00 00    	js     802258 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212c:	83 ec 04             	sub    $0x4,%esp
  80212f:	68 07 04 00 00       	push   $0x407
  802134:	ff 75 f4             	pushl  -0xc(%ebp)
  802137:	6a 00                	push   $0x0
  802139:	e8 1a ef ff ff       	call   801058 <sys_page_alloc>
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	89 c2                	mov    %eax,%edx
  802143:	85 c0                	test   %eax,%eax
  802145:	0f 88 0d 01 00 00    	js     802258 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80214b:	83 ec 0c             	sub    $0xc,%esp
  80214e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802151:	50                   	push   %eax
  802152:	e8 a3 f1 ff ff       	call   8012fa <fd_alloc>
  802157:	89 c3                	mov    %eax,%ebx
  802159:	83 c4 10             	add    $0x10,%esp
  80215c:	85 c0                	test   %eax,%eax
  80215e:	0f 88 e2 00 00 00    	js     802246 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802164:	83 ec 04             	sub    $0x4,%esp
  802167:	68 07 04 00 00       	push   $0x407
  80216c:	ff 75 f0             	pushl  -0x10(%ebp)
  80216f:	6a 00                	push   $0x0
  802171:	e8 e2 ee ff ff       	call   801058 <sys_page_alloc>
  802176:	89 c3                	mov    %eax,%ebx
  802178:	83 c4 10             	add    $0x10,%esp
  80217b:	85 c0                	test   %eax,%eax
  80217d:	0f 88 c3 00 00 00    	js     802246 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802183:	83 ec 0c             	sub    $0xc,%esp
  802186:	ff 75 f4             	pushl  -0xc(%ebp)
  802189:	e8 55 f1 ff ff       	call   8012e3 <fd2data>
  80218e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802190:	83 c4 0c             	add    $0xc,%esp
  802193:	68 07 04 00 00       	push   $0x407
  802198:	50                   	push   %eax
  802199:	6a 00                	push   $0x0
  80219b:	e8 b8 ee ff ff       	call   801058 <sys_page_alloc>
  8021a0:	89 c3                	mov    %eax,%ebx
  8021a2:	83 c4 10             	add    $0x10,%esp
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	0f 88 89 00 00 00    	js     802236 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ad:	83 ec 0c             	sub    $0xc,%esp
  8021b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b3:	e8 2b f1 ff ff       	call   8012e3 <fd2data>
  8021b8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021bf:	50                   	push   %eax
  8021c0:	6a 00                	push   $0x0
  8021c2:	56                   	push   %esi
  8021c3:	6a 00                	push   $0x0
  8021c5:	e8 d1 ee ff ff       	call   80109b <sys_page_map>
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	83 c4 20             	add    $0x20,%esp
  8021cf:	85 c0                	test   %eax,%eax
  8021d1:	78 55                	js     802228 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021d3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021e8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021fd:	83 ec 0c             	sub    $0xc,%esp
  802200:	ff 75 f4             	pushl  -0xc(%ebp)
  802203:	e8 cb f0 ff ff       	call   8012d3 <fd2num>
  802208:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80220b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80220d:	83 c4 04             	add    $0x4,%esp
  802210:	ff 75 f0             	pushl  -0x10(%ebp)
  802213:	e8 bb f0 ff ff       	call   8012d3 <fd2num>
  802218:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80221b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80221e:	83 c4 10             	add    $0x10,%esp
  802221:	ba 00 00 00 00       	mov    $0x0,%edx
  802226:	eb 30                	jmp    802258 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802228:	83 ec 08             	sub    $0x8,%esp
  80222b:	56                   	push   %esi
  80222c:	6a 00                	push   $0x0
  80222e:	e8 aa ee ff ff       	call   8010dd <sys_page_unmap>
  802233:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802236:	83 ec 08             	sub    $0x8,%esp
  802239:	ff 75 f0             	pushl  -0x10(%ebp)
  80223c:	6a 00                	push   $0x0
  80223e:	e8 9a ee ff ff       	call   8010dd <sys_page_unmap>
  802243:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802246:	83 ec 08             	sub    $0x8,%esp
  802249:	ff 75 f4             	pushl  -0xc(%ebp)
  80224c:	6a 00                	push   $0x0
  80224e:	e8 8a ee ff ff       	call   8010dd <sys_page_unmap>
  802253:	83 c4 10             	add    $0x10,%esp
  802256:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802258:	89 d0                	mov    %edx,%eax
  80225a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5d                   	pop    %ebp
  802260:	c3                   	ret    

00802261 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80226a:	50                   	push   %eax
  80226b:	ff 75 08             	pushl  0x8(%ebp)
  80226e:	e8 d6 f0 ff ff       	call   801349 <fd_lookup>
  802273:	83 c4 10             	add    $0x10,%esp
  802276:	85 c0                	test   %eax,%eax
  802278:	78 18                	js     802292 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80227a:	83 ec 0c             	sub    $0xc,%esp
  80227d:	ff 75 f4             	pushl  -0xc(%ebp)
  802280:	e8 5e f0 ff ff       	call   8012e3 <fd2data>
	return _pipeisclosed(fd, p);
  802285:	89 c2                	mov    %eax,%edx
  802287:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228a:	e8 21 fd ff ff       	call   801fb0 <_pipeisclosed>
  80228f:	83 c4 10             	add    $0x10,%esp
}
  802292:	c9                   	leave  
  802293:	c3                   	ret    

00802294 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802297:	b8 00 00 00 00       	mov    $0x0,%eax
  80229c:	5d                   	pop    %ebp
  80229d:	c3                   	ret    

0080229e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022a4:	68 6b 2d 80 00       	push   $0x802d6b
  8022a9:	ff 75 0c             	pushl  0xc(%ebp)
  8022ac:	e8 a4 e9 ff ff       	call   800c55 <strcpy>
	return 0;
}
  8022b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b6:	c9                   	leave  
  8022b7:	c3                   	ret    

008022b8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
  8022bb:	57                   	push   %edi
  8022bc:	56                   	push   %esi
  8022bd:	53                   	push   %ebx
  8022be:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022c4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022c9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022cf:	eb 2d                	jmp    8022fe <devcons_write+0x46>
		m = n - tot;
  8022d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022d4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022d6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022d9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022de:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022e1:	83 ec 04             	sub    $0x4,%esp
  8022e4:	53                   	push   %ebx
  8022e5:	03 45 0c             	add    0xc(%ebp),%eax
  8022e8:	50                   	push   %eax
  8022e9:	57                   	push   %edi
  8022ea:	e8 f8 ea ff ff       	call   800de7 <memmove>
		sys_cputs(buf, m);
  8022ef:	83 c4 08             	add    $0x8,%esp
  8022f2:	53                   	push   %ebx
  8022f3:	57                   	push   %edi
  8022f4:	e8 a3 ec ff ff       	call   800f9c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f9:	01 de                	add    %ebx,%esi
  8022fb:	83 c4 10             	add    $0x10,%esp
  8022fe:	89 f0                	mov    %esi,%eax
  802300:	3b 75 10             	cmp    0x10(%ebp),%esi
  802303:	72 cc                	jb     8022d1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802305:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    

0080230d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80230d:	55                   	push   %ebp
  80230e:	89 e5                	mov    %esp,%ebp
  802310:	83 ec 08             	sub    $0x8,%esp
  802313:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802318:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80231c:	74 2a                	je     802348 <devcons_read+0x3b>
  80231e:	eb 05                	jmp    802325 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802320:	e8 14 ed ff ff       	call   801039 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802325:	e8 90 ec ff ff       	call   800fba <sys_cgetc>
  80232a:	85 c0                	test   %eax,%eax
  80232c:	74 f2                	je     802320 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80232e:	85 c0                	test   %eax,%eax
  802330:	78 16                	js     802348 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802332:	83 f8 04             	cmp    $0x4,%eax
  802335:	74 0c                	je     802343 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802337:	8b 55 0c             	mov    0xc(%ebp),%edx
  80233a:	88 02                	mov    %al,(%edx)
	return 1;
  80233c:	b8 01 00 00 00       	mov    $0x1,%eax
  802341:	eb 05                	jmp    802348 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802343:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802348:	c9                   	leave  
  802349:	c3                   	ret    

0080234a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802350:	8b 45 08             	mov    0x8(%ebp),%eax
  802353:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802356:	6a 01                	push   $0x1
  802358:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80235b:	50                   	push   %eax
  80235c:	e8 3b ec ff ff       	call   800f9c <sys_cputs>
}
  802361:	83 c4 10             	add    $0x10,%esp
  802364:	c9                   	leave  
  802365:	c3                   	ret    

00802366 <getchar>:

int
getchar(void)
{
  802366:	55                   	push   %ebp
  802367:	89 e5                	mov    %esp,%ebp
  802369:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80236c:	6a 01                	push   $0x1
  80236e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802371:	50                   	push   %eax
  802372:	6a 00                	push   $0x0
  802374:	e8 36 f2 ff ff       	call   8015af <read>
	if (r < 0)
  802379:	83 c4 10             	add    $0x10,%esp
  80237c:	85 c0                	test   %eax,%eax
  80237e:	78 0f                	js     80238f <getchar+0x29>
		return r;
	if (r < 1)
  802380:	85 c0                	test   %eax,%eax
  802382:	7e 06                	jle    80238a <getchar+0x24>
		return -E_EOF;
	return c;
  802384:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802388:	eb 05                	jmp    80238f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80238a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80238f:	c9                   	leave  
  802390:	c3                   	ret    

00802391 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
  802394:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80239a:	50                   	push   %eax
  80239b:	ff 75 08             	pushl  0x8(%ebp)
  80239e:	e8 a6 ef ff ff       	call   801349 <fd_lookup>
  8023a3:	83 c4 10             	add    $0x10,%esp
  8023a6:	85 c0                	test   %eax,%eax
  8023a8:	78 11                	js     8023bb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ad:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023b3:	39 10                	cmp    %edx,(%eax)
  8023b5:	0f 94 c0             	sete   %al
  8023b8:	0f b6 c0             	movzbl %al,%eax
}
  8023bb:	c9                   	leave  
  8023bc:	c3                   	ret    

008023bd <opencons>:

int
opencons(void)
{
  8023bd:	55                   	push   %ebp
  8023be:	89 e5                	mov    %esp,%ebp
  8023c0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c6:	50                   	push   %eax
  8023c7:	e8 2e ef ff ff       	call   8012fa <fd_alloc>
  8023cc:	83 c4 10             	add    $0x10,%esp
		return r;
  8023cf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023d1:	85 c0                	test   %eax,%eax
  8023d3:	78 3e                	js     802413 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023d5:	83 ec 04             	sub    $0x4,%esp
  8023d8:	68 07 04 00 00       	push   $0x407
  8023dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e0:	6a 00                	push   $0x0
  8023e2:	e8 71 ec ff ff       	call   801058 <sys_page_alloc>
  8023e7:	83 c4 10             	add    $0x10,%esp
		return r;
  8023ea:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ec:	85 c0                	test   %eax,%eax
  8023ee:	78 23                	js     802413 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023f0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802405:	83 ec 0c             	sub    $0xc,%esp
  802408:	50                   	push   %eax
  802409:	e8 c5 ee ff ff       	call   8012d3 <fd2num>
  80240e:	89 c2                	mov    %eax,%edx
  802410:	83 c4 10             	add    $0x10,%esp
}
  802413:	89 d0                	mov    %edx,%eax
  802415:	c9                   	leave  
  802416:	c3                   	ret    

00802417 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802417:	55                   	push   %ebp
  802418:	89 e5                	mov    %esp,%ebp
  80241a:	56                   	push   %esi
  80241b:	53                   	push   %ebx
  80241c:	8b 75 08             	mov    0x8(%ebp),%esi
  80241f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802422:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802425:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802427:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80242c:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80242f:	83 ec 0c             	sub    $0xc,%esp
  802432:	50                   	push   %eax
  802433:	e8 d0 ed ff ff       	call   801208 <sys_ipc_recv>

	if (from_env_store != NULL)
  802438:	83 c4 10             	add    $0x10,%esp
  80243b:	85 f6                	test   %esi,%esi
  80243d:	74 14                	je     802453 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80243f:	ba 00 00 00 00       	mov    $0x0,%edx
  802444:	85 c0                	test   %eax,%eax
  802446:	78 09                	js     802451 <ipc_recv+0x3a>
  802448:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  80244e:	8b 52 74             	mov    0x74(%edx),%edx
  802451:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802453:	85 db                	test   %ebx,%ebx
  802455:	74 14                	je     80246b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802457:	ba 00 00 00 00       	mov    $0x0,%edx
  80245c:	85 c0                	test   %eax,%eax
  80245e:	78 09                	js     802469 <ipc_recv+0x52>
  802460:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  802466:	8b 52 78             	mov    0x78(%edx),%edx
  802469:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80246b:	85 c0                	test   %eax,%eax
  80246d:	78 08                	js     802477 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80246f:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802474:	8b 40 70             	mov    0x70(%eax),%eax
}
  802477:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80247a:	5b                   	pop    %ebx
  80247b:	5e                   	pop    %esi
  80247c:	5d                   	pop    %ebp
  80247d:	c3                   	ret    

0080247e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	57                   	push   %edi
  802482:	56                   	push   %esi
  802483:	53                   	push   %ebx
  802484:	83 ec 0c             	sub    $0xc,%esp
  802487:	8b 7d 08             	mov    0x8(%ebp),%edi
  80248a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80248d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802490:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802492:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802497:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80249a:	ff 75 14             	pushl  0x14(%ebp)
  80249d:	53                   	push   %ebx
  80249e:	56                   	push   %esi
  80249f:	57                   	push   %edi
  8024a0:	e8 40 ed ff ff       	call   8011e5 <sys_ipc_try_send>

		if (err < 0) {
  8024a5:	83 c4 10             	add    $0x10,%esp
  8024a8:	85 c0                	test   %eax,%eax
  8024aa:	79 1e                	jns    8024ca <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8024ac:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024af:	75 07                	jne    8024b8 <ipc_send+0x3a>
				sys_yield();
  8024b1:	e8 83 eb ff ff       	call   801039 <sys_yield>
  8024b6:	eb e2                	jmp    80249a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8024b8:	50                   	push   %eax
  8024b9:	68 77 2d 80 00       	push   $0x802d77
  8024be:	6a 49                	push   $0x49
  8024c0:	68 84 2d 80 00       	push   $0x802d84
  8024c5:	e8 2d e1 ff ff       	call   8005f7 <_panic>
		}

	} while (err < 0);

}
  8024ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024cd:	5b                   	pop    %ebx
  8024ce:	5e                   	pop    %esi
  8024cf:	5f                   	pop    %edi
  8024d0:	5d                   	pop    %ebp
  8024d1:	c3                   	ret    

008024d2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024d2:	55                   	push   %ebp
  8024d3:	89 e5                	mov    %esp,%ebp
  8024d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024d8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024dd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024e0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024e6:	8b 52 50             	mov    0x50(%edx),%edx
  8024e9:	39 ca                	cmp    %ecx,%edx
  8024eb:	75 0d                	jne    8024fa <ipc_find_env+0x28>
			return envs[i].env_id;
  8024ed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024f0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024f5:	8b 40 48             	mov    0x48(%eax),%eax
  8024f8:	eb 0f                	jmp    802509 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024fa:	83 c0 01             	add    $0x1,%eax
  8024fd:	3d 00 04 00 00       	cmp    $0x400,%eax
  802502:	75 d9                	jne    8024dd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802504:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802509:	5d                   	pop    %ebp
  80250a:	c3                   	ret    

0080250b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80250b:	55                   	push   %ebp
  80250c:	89 e5                	mov    %esp,%ebp
  80250e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802511:	89 d0                	mov    %edx,%eax
  802513:	c1 e8 16             	shr    $0x16,%eax
  802516:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80251d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802522:	f6 c1 01             	test   $0x1,%cl
  802525:	74 1d                	je     802544 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802527:	c1 ea 0c             	shr    $0xc,%edx
  80252a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802531:	f6 c2 01             	test   $0x1,%dl
  802534:	74 0e                	je     802544 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802536:	c1 ea 0c             	shr    $0xc,%edx
  802539:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802540:	ef 
  802541:	0f b7 c0             	movzwl %ax,%eax
}
  802544:	5d                   	pop    %ebp
  802545:	c3                   	ret    
  802546:	66 90                	xchg   %ax,%ax
  802548:	66 90                	xchg   %ax,%ax
  80254a:	66 90                	xchg   %ax,%ax
  80254c:	66 90                	xchg   %ax,%ax
  80254e:	66 90                	xchg   %ax,%ax

00802550 <__udivdi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	83 ec 1c             	sub    $0x1c,%esp
  802557:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80255b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80255f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802563:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802567:	85 f6                	test   %esi,%esi
  802569:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80256d:	89 ca                	mov    %ecx,%edx
  80256f:	89 f8                	mov    %edi,%eax
  802571:	75 3d                	jne    8025b0 <__udivdi3+0x60>
  802573:	39 cf                	cmp    %ecx,%edi
  802575:	0f 87 c5 00 00 00    	ja     802640 <__udivdi3+0xf0>
  80257b:	85 ff                	test   %edi,%edi
  80257d:	89 fd                	mov    %edi,%ebp
  80257f:	75 0b                	jne    80258c <__udivdi3+0x3c>
  802581:	b8 01 00 00 00       	mov    $0x1,%eax
  802586:	31 d2                	xor    %edx,%edx
  802588:	f7 f7                	div    %edi
  80258a:	89 c5                	mov    %eax,%ebp
  80258c:	89 c8                	mov    %ecx,%eax
  80258e:	31 d2                	xor    %edx,%edx
  802590:	f7 f5                	div    %ebp
  802592:	89 c1                	mov    %eax,%ecx
  802594:	89 d8                	mov    %ebx,%eax
  802596:	89 cf                	mov    %ecx,%edi
  802598:	f7 f5                	div    %ebp
  80259a:	89 c3                	mov    %eax,%ebx
  80259c:	89 d8                	mov    %ebx,%eax
  80259e:	89 fa                	mov    %edi,%edx
  8025a0:	83 c4 1c             	add    $0x1c,%esp
  8025a3:	5b                   	pop    %ebx
  8025a4:	5e                   	pop    %esi
  8025a5:	5f                   	pop    %edi
  8025a6:	5d                   	pop    %ebp
  8025a7:	c3                   	ret    
  8025a8:	90                   	nop
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	39 ce                	cmp    %ecx,%esi
  8025b2:	77 74                	ja     802628 <__udivdi3+0xd8>
  8025b4:	0f bd fe             	bsr    %esi,%edi
  8025b7:	83 f7 1f             	xor    $0x1f,%edi
  8025ba:	0f 84 98 00 00 00    	je     802658 <__udivdi3+0x108>
  8025c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	89 c5                	mov    %eax,%ebp
  8025c9:	29 fb                	sub    %edi,%ebx
  8025cb:	d3 e6                	shl    %cl,%esi
  8025cd:	89 d9                	mov    %ebx,%ecx
  8025cf:	d3 ed                	shr    %cl,%ebp
  8025d1:	89 f9                	mov    %edi,%ecx
  8025d3:	d3 e0                	shl    %cl,%eax
  8025d5:	09 ee                	or     %ebp,%esi
  8025d7:	89 d9                	mov    %ebx,%ecx
  8025d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025dd:	89 d5                	mov    %edx,%ebp
  8025df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025e3:	d3 ed                	shr    %cl,%ebp
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	d3 e2                	shl    %cl,%edx
  8025e9:	89 d9                	mov    %ebx,%ecx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	09 c2                	or     %eax,%edx
  8025ef:	89 d0                	mov    %edx,%eax
  8025f1:	89 ea                	mov    %ebp,%edx
  8025f3:	f7 f6                	div    %esi
  8025f5:	89 d5                	mov    %edx,%ebp
  8025f7:	89 c3                	mov    %eax,%ebx
  8025f9:	f7 64 24 0c          	mull   0xc(%esp)
  8025fd:	39 d5                	cmp    %edx,%ebp
  8025ff:	72 10                	jb     802611 <__udivdi3+0xc1>
  802601:	8b 74 24 08          	mov    0x8(%esp),%esi
  802605:	89 f9                	mov    %edi,%ecx
  802607:	d3 e6                	shl    %cl,%esi
  802609:	39 c6                	cmp    %eax,%esi
  80260b:	73 07                	jae    802614 <__udivdi3+0xc4>
  80260d:	39 d5                	cmp    %edx,%ebp
  80260f:	75 03                	jne    802614 <__udivdi3+0xc4>
  802611:	83 eb 01             	sub    $0x1,%ebx
  802614:	31 ff                	xor    %edi,%edi
  802616:	89 d8                	mov    %ebx,%eax
  802618:	89 fa                	mov    %edi,%edx
  80261a:	83 c4 1c             	add    $0x1c,%esp
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	5d                   	pop    %ebp
  802621:	c3                   	ret    
  802622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802628:	31 ff                	xor    %edi,%edi
  80262a:	31 db                	xor    %ebx,%ebx
  80262c:	89 d8                	mov    %ebx,%eax
  80262e:	89 fa                	mov    %edi,%edx
  802630:	83 c4 1c             	add    $0x1c,%esp
  802633:	5b                   	pop    %ebx
  802634:	5e                   	pop    %esi
  802635:	5f                   	pop    %edi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
  802638:	90                   	nop
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	89 d8                	mov    %ebx,%eax
  802642:	f7 f7                	div    %edi
  802644:	31 ff                	xor    %edi,%edi
  802646:	89 c3                	mov    %eax,%ebx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 fa                	mov    %edi,%edx
  80264c:	83 c4 1c             	add    $0x1c,%esp
  80264f:	5b                   	pop    %ebx
  802650:	5e                   	pop    %esi
  802651:	5f                   	pop    %edi
  802652:	5d                   	pop    %ebp
  802653:	c3                   	ret    
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	39 ce                	cmp    %ecx,%esi
  80265a:	72 0c                	jb     802668 <__udivdi3+0x118>
  80265c:	31 db                	xor    %ebx,%ebx
  80265e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802662:	0f 87 34 ff ff ff    	ja     80259c <__udivdi3+0x4c>
  802668:	bb 01 00 00 00       	mov    $0x1,%ebx
  80266d:	e9 2a ff ff ff       	jmp    80259c <__udivdi3+0x4c>
  802672:	66 90                	xchg   %ax,%ax
  802674:	66 90                	xchg   %ax,%ax
  802676:	66 90                	xchg   %ax,%ax
  802678:	66 90                	xchg   %ax,%ax
  80267a:	66 90                	xchg   %ax,%ax
  80267c:	66 90                	xchg   %ax,%ax
  80267e:	66 90                	xchg   %ax,%ax

00802680 <__umoddi3>:
  802680:	55                   	push   %ebp
  802681:	57                   	push   %edi
  802682:	56                   	push   %esi
  802683:	53                   	push   %ebx
  802684:	83 ec 1c             	sub    $0x1c,%esp
  802687:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80268b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80268f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802693:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802697:	85 d2                	test   %edx,%edx
  802699:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80269d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026a1:	89 f3                	mov    %esi,%ebx
  8026a3:	89 3c 24             	mov    %edi,(%esp)
  8026a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026aa:	75 1c                	jne    8026c8 <__umoddi3+0x48>
  8026ac:	39 f7                	cmp    %esi,%edi
  8026ae:	76 50                	jbe    802700 <__umoddi3+0x80>
  8026b0:	89 c8                	mov    %ecx,%eax
  8026b2:	89 f2                	mov    %esi,%edx
  8026b4:	f7 f7                	div    %edi
  8026b6:	89 d0                	mov    %edx,%eax
  8026b8:	31 d2                	xor    %edx,%edx
  8026ba:	83 c4 1c             	add    $0x1c,%esp
  8026bd:	5b                   	pop    %ebx
  8026be:	5e                   	pop    %esi
  8026bf:	5f                   	pop    %edi
  8026c0:	5d                   	pop    %ebp
  8026c1:	c3                   	ret    
  8026c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026c8:	39 f2                	cmp    %esi,%edx
  8026ca:	89 d0                	mov    %edx,%eax
  8026cc:	77 52                	ja     802720 <__umoddi3+0xa0>
  8026ce:	0f bd ea             	bsr    %edx,%ebp
  8026d1:	83 f5 1f             	xor    $0x1f,%ebp
  8026d4:	75 5a                	jne    802730 <__umoddi3+0xb0>
  8026d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026da:	0f 82 e0 00 00 00    	jb     8027c0 <__umoddi3+0x140>
  8026e0:	39 0c 24             	cmp    %ecx,(%esp)
  8026e3:	0f 86 d7 00 00 00    	jbe    8027c0 <__umoddi3+0x140>
  8026e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026f1:	83 c4 1c             	add    $0x1c,%esp
  8026f4:	5b                   	pop    %ebx
  8026f5:	5e                   	pop    %esi
  8026f6:	5f                   	pop    %edi
  8026f7:	5d                   	pop    %ebp
  8026f8:	c3                   	ret    
  8026f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802700:	85 ff                	test   %edi,%edi
  802702:	89 fd                	mov    %edi,%ebp
  802704:	75 0b                	jne    802711 <__umoddi3+0x91>
  802706:	b8 01 00 00 00       	mov    $0x1,%eax
  80270b:	31 d2                	xor    %edx,%edx
  80270d:	f7 f7                	div    %edi
  80270f:	89 c5                	mov    %eax,%ebp
  802711:	89 f0                	mov    %esi,%eax
  802713:	31 d2                	xor    %edx,%edx
  802715:	f7 f5                	div    %ebp
  802717:	89 c8                	mov    %ecx,%eax
  802719:	f7 f5                	div    %ebp
  80271b:	89 d0                	mov    %edx,%eax
  80271d:	eb 99                	jmp    8026b8 <__umoddi3+0x38>
  80271f:	90                   	nop
  802720:	89 c8                	mov    %ecx,%eax
  802722:	89 f2                	mov    %esi,%edx
  802724:	83 c4 1c             	add    $0x1c,%esp
  802727:	5b                   	pop    %ebx
  802728:	5e                   	pop    %esi
  802729:	5f                   	pop    %edi
  80272a:	5d                   	pop    %ebp
  80272b:	c3                   	ret    
  80272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802730:	8b 34 24             	mov    (%esp),%esi
  802733:	bf 20 00 00 00       	mov    $0x20,%edi
  802738:	89 e9                	mov    %ebp,%ecx
  80273a:	29 ef                	sub    %ebp,%edi
  80273c:	d3 e0                	shl    %cl,%eax
  80273e:	89 f9                	mov    %edi,%ecx
  802740:	89 f2                	mov    %esi,%edx
  802742:	d3 ea                	shr    %cl,%edx
  802744:	89 e9                	mov    %ebp,%ecx
  802746:	09 c2                	or     %eax,%edx
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	89 14 24             	mov    %edx,(%esp)
  80274d:	89 f2                	mov    %esi,%edx
  80274f:	d3 e2                	shl    %cl,%edx
  802751:	89 f9                	mov    %edi,%ecx
  802753:	89 54 24 04          	mov    %edx,0x4(%esp)
  802757:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80275b:	d3 e8                	shr    %cl,%eax
  80275d:	89 e9                	mov    %ebp,%ecx
  80275f:	89 c6                	mov    %eax,%esi
  802761:	d3 e3                	shl    %cl,%ebx
  802763:	89 f9                	mov    %edi,%ecx
  802765:	89 d0                	mov    %edx,%eax
  802767:	d3 e8                	shr    %cl,%eax
  802769:	89 e9                	mov    %ebp,%ecx
  80276b:	09 d8                	or     %ebx,%eax
  80276d:	89 d3                	mov    %edx,%ebx
  80276f:	89 f2                	mov    %esi,%edx
  802771:	f7 34 24             	divl   (%esp)
  802774:	89 d6                	mov    %edx,%esi
  802776:	d3 e3                	shl    %cl,%ebx
  802778:	f7 64 24 04          	mull   0x4(%esp)
  80277c:	39 d6                	cmp    %edx,%esi
  80277e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802782:	89 d1                	mov    %edx,%ecx
  802784:	89 c3                	mov    %eax,%ebx
  802786:	72 08                	jb     802790 <__umoddi3+0x110>
  802788:	75 11                	jne    80279b <__umoddi3+0x11b>
  80278a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80278e:	73 0b                	jae    80279b <__umoddi3+0x11b>
  802790:	2b 44 24 04          	sub    0x4(%esp),%eax
  802794:	1b 14 24             	sbb    (%esp),%edx
  802797:	89 d1                	mov    %edx,%ecx
  802799:	89 c3                	mov    %eax,%ebx
  80279b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80279f:	29 da                	sub    %ebx,%edx
  8027a1:	19 ce                	sbb    %ecx,%esi
  8027a3:	89 f9                	mov    %edi,%ecx
  8027a5:	89 f0                	mov    %esi,%eax
  8027a7:	d3 e0                	shl    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	d3 ea                	shr    %cl,%edx
  8027ad:	89 e9                	mov    %ebp,%ecx
  8027af:	d3 ee                	shr    %cl,%esi
  8027b1:	09 d0                	or     %edx,%eax
  8027b3:	89 f2                	mov    %esi,%edx
  8027b5:	83 c4 1c             	add    $0x1c,%esp
  8027b8:	5b                   	pop    %ebx
  8027b9:	5e                   	pop    %esi
  8027ba:	5f                   	pop    %edi
  8027bb:	5d                   	pop    %ebp
  8027bc:	c3                   	ret    
  8027bd:	8d 76 00             	lea    0x0(%esi),%esi
  8027c0:	29 f9                	sub    %edi,%ecx
  8027c2:	19 d6                	sbb    %edx,%esi
  8027c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027cc:	e9 18 ff ff ff       	jmp    8026e9 <__umoddi3+0x69>
