
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
  800044:	68 91 28 80 00       	push   $0x802891
  800049:	68 60 28 80 00       	push   $0x802860
  80004e:	e8 7d 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 70 28 80 00       	push   $0x802870
  80005c:	68 74 28 80 00       	push   $0x802874
  800061:	e8 6a 06 00 00       	call   8006d0 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 84 28 80 00       	push   $0x802884
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
  800089:	68 88 28 80 00       	push   $0x802888
  80008e:	e8 3d 06 00 00       	call   8006d0 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 92 28 80 00       	push   $0x802892
  8000a6:	68 74 28 80 00       	push   $0x802874
  8000ab:	e8 20 06 00 00       	call   8006d0 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 84 28 80 00       	push   $0x802884
  8000c3:	e8 08 06 00 00       	call   8006d0 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 88 28 80 00       	push   $0x802888
  8000d5:	e8 f6 05 00 00       	call   8006d0 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 96 28 80 00       	push   $0x802896
  8000ed:	68 74 28 80 00       	push   $0x802874
  8000f2:	e8 d9 05 00 00       	call   8006d0 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 84 28 80 00       	push   $0x802884
  80010a:	e8 c1 05 00 00       	call   8006d0 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 88 28 80 00       	push   $0x802888
  80011c:	e8 af 05 00 00       	call   8006d0 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 9a 28 80 00       	push   $0x80289a
  800134:	68 74 28 80 00       	push   $0x802874
  800139:	e8 92 05 00 00       	call   8006d0 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 84 28 80 00       	push   $0x802884
  800151:	e8 7a 05 00 00       	call   8006d0 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 88 28 80 00       	push   $0x802888
  800163:	e8 68 05 00 00       	call   8006d0 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 9e 28 80 00       	push   $0x80289e
  80017b:	68 74 28 80 00       	push   $0x802874
  800180:	e8 4b 05 00 00       	call   8006d0 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 84 28 80 00       	push   $0x802884
  800198:	e8 33 05 00 00       	call   8006d0 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 88 28 80 00       	push   $0x802888
  8001aa:	e8 21 05 00 00       	call   8006d0 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 a2 28 80 00       	push   $0x8028a2
  8001c2:	68 74 28 80 00       	push   $0x802874
  8001c7:	e8 04 05 00 00       	call   8006d0 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 84 28 80 00       	push   $0x802884
  8001df:	e8 ec 04 00 00       	call   8006d0 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 88 28 80 00       	push   $0x802888
  8001f1:	e8 da 04 00 00       	call   8006d0 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 a6 28 80 00       	push   $0x8028a6
  800209:	68 74 28 80 00       	push   $0x802874
  80020e:	e8 bd 04 00 00       	call   8006d0 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 84 28 80 00       	push   $0x802884
  800226:	e8 a5 04 00 00       	call   8006d0 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 88 28 80 00       	push   $0x802888
  800238:	e8 93 04 00 00       	call   8006d0 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 aa 28 80 00       	push   $0x8028aa
  800250:	68 74 28 80 00       	push   $0x802874
  800255:	e8 76 04 00 00       	call   8006d0 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 84 28 80 00       	push   $0x802884
  80026d:	e8 5e 04 00 00       	call   8006d0 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 88 28 80 00       	push   $0x802888
  80027f:	e8 4c 04 00 00       	call   8006d0 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 ae 28 80 00       	push   $0x8028ae
  800297:	68 74 28 80 00       	push   $0x802874
  80029c:	e8 2f 04 00 00       	call   8006d0 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 84 28 80 00       	push   $0x802884
  8002b4:	e8 17 04 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 b5 28 80 00       	push   $0x8028b5
  8002c4:	68 74 28 80 00       	push   $0x802874
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
  8002de:	68 88 28 80 00       	push   $0x802888
  8002e3:	e8 e8 03 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 b5 28 80 00       	push   $0x8028b5
  8002f3:	68 74 28 80 00       	push   $0x802874
  8002f8:	e8 d3 03 00 00       	call   8006d0 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 84 28 80 00       	push   $0x802884
  800312:	e8 b9 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 b9 28 80 00       	push   $0x8028b9
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
  800333:	68 88 28 80 00       	push   $0x802888
  800338:	e8 93 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 b9 28 80 00       	push   $0x8028b9
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 84 28 80 00       	push   $0x802884
  80035a:	e8 71 03 00 00       	call   8006d0 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 88 28 80 00       	push   $0x802888
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
  800379:	68 84 28 80 00       	push   $0x802884
  80037e:	e8 4d 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 b9 28 80 00       	push   $0x8028b9
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
  8003ba:	68 20 29 80 00       	push   $0x802920
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 c7 28 80 00       	push   $0x8028c7
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
  800436:	68 df 28 80 00       	push   $0x8028df
  80043b:	68 ed 28 80 00       	push   $0x8028ed
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba d8 28 80 00       	mov    $0x8028d8,%edx
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
  80046d:	68 f4 28 80 00       	push   $0x8028f4
  800472:	6a 5c                	push   $0x5c
  800474:	68 c7 28 80 00       	push   $0x8028c7
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
  80048b:	e8 5c 0e 00 00       	call   8012ec <set_pgfault_handler>

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
  80055a:	68 54 29 80 00       	push   $0x802954
  80055f:	e8 6c 01 00 00       	call   8006d0 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 07 29 80 00       	push   $0x802907
  800579:	68 18 29 80 00       	push   $0x802918
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba d8 28 80 00       	mov    $0x8028d8,%edx
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
  8005e3:	e8 3a 0f 00 00       	call   801522 <close_all>
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
  800615:	68 80 29 80 00       	push   $0x802980
  80061a:	e8 b1 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061f:	83 c4 18             	add    $0x18,%esp
  800622:	53                   	push   %ebx
  800623:	ff 75 10             	pushl  0x10(%ebp)
  800626:	e8 54 00 00 00       	call   80067f <vcprintf>
	cprintf("\n");
  80062b:	c7 04 24 90 28 80 00 	movl   $0x802890,(%esp)
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
  800733:	e8 98 1e 00 00       	call   8025d0 <__udivdi3>
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
  800776:	e8 85 1f 00 00       	call   802700 <__umoddi3>
  80077b:	83 c4 14             	add    $0x14,%esp
  80077e:	0f be 80 a3 29 80 00 	movsbl 0x8029a3(%eax),%eax
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
  80087a:	ff 24 85 e0 2a 80 00 	jmp    *0x802ae0(,%eax,4)
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
  80093e:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  800945:	85 d2                	test   %edx,%edx
  800947:	75 18                	jne    800961 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800949:	50                   	push   %eax
  80094a:	68 bb 29 80 00       	push   $0x8029bb
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
  800962:	68 79 2d 80 00       	push   $0x802d79
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
  800986:	b8 b4 29 80 00       	mov    $0x8029b4,%eax
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
  801001:	68 9f 2c 80 00       	push   $0x802c9f
  801006:	6a 23                	push   $0x23
  801008:	68 bc 2c 80 00       	push   $0x802cbc
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
  801082:	68 9f 2c 80 00       	push   $0x802c9f
  801087:	6a 23                	push   $0x23
  801089:	68 bc 2c 80 00       	push   $0x802cbc
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
  8010c4:	68 9f 2c 80 00       	push   $0x802c9f
  8010c9:	6a 23                	push   $0x23
  8010cb:	68 bc 2c 80 00       	push   $0x802cbc
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
  801106:	68 9f 2c 80 00       	push   $0x802c9f
  80110b:	6a 23                	push   $0x23
  80110d:	68 bc 2c 80 00       	push   $0x802cbc
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
  801148:	68 9f 2c 80 00       	push   $0x802c9f
  80114d:	6a 23                	push   $0x23
  80114f:	68 bc 2c 80 00       	push   $0x802cbc
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
  80118a:	68 9f 2c 80 00       	push   $0x802c9f
  80118f:	6a 23                	push   $0x23
  801191:	68 bc 2c 80 00       	push   $0x802cbc
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
  8011cc:	68 9f 2c 80 00       	push   $0x802c9f
  8011d1:	6a 23                	push   $0x23
  8011d3:	68 bc 2c 80 00       	push   $0x802cbc
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
  801230:	68 9f 2c 80 00       	push   $0x802c9f
  801235:	6a 23                	push   $0x23
  801237:	68 bc 2c 80 00       	push   $0x802cbc
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

00801268 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	57                   	push   %edi
  80126c:	56                   	push   %esi
  80126d:	53                   	push   %ebx
  80126e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801271:	bb 00 00 00 00       	mov    $0x0,%ebx
  801276:	b8 0f 00 00 00       	mov    $0xf,%eax
  80127b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127e:	8b 55 08             	mov    0x8(%ebp),%edx
  801281:	89 df                	mov    %ebx,%edi
  801283:	89 de                	mov    %ebx,%esi
  801285:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801287:	85 c0                	test   %eax,%eax
  801289:	7e 17                	jle    8012a2 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	50                   	push   %eax
  80128f:	6a 0f                	push   $0xf
  801291:	68 9f 2c 80 00       	push   $0x802c9f
  801296:	6a 23                	push   $0x23
  801298:	68 bc 2c 80 00       	push   $0x802cbc
  80129d:	e8 55 f3 ff ff       	call   8005f7 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8012a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5e                   	pop    %esi
  8012a7:	5f                   	pop    %edi
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	57                   	push   %edi
  8012ae:	56                   	push   %esi
  8012af:	53                   	push   %ebx
  8012b0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b8:	b8 10 00 00 00       	mov    $0x10,%eax
  8012bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c3:	89 df                	mov    %ebx,%edi
  8012c5:	89 de                	mov    %ebx,%esi
  8012c7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	7e 17                	jle    8012e4 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cd:	83 ec 0c             	sub    $0xc,%esp
  8012d0:	50                   	push   %eax
  8012d1:	6a 10                	push   $0x10
  8012d3:	68 9f 2c 80 00       	push   $0x802c9f
  8012d8:	6a 23                	push   $0x23
  8012da:	68 bc 2c 80 00       	push   $0x802cbc
  8012df:	e8 13 f3 ff ff       	call   8005f7 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8012e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5e                   	pop    %esi
  8012e9:	5f                   	pop    %edi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012f2:	83 3d b8 40 80 00 00 	cmpl   $0x0,0x8040b8
  8012f9:	75 2e                	jne    801329 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8012fb:	e8 1a fd ff ff       	call   80101a <sys_getenvid>
  801300:	83 ec 04             	sub    $0x4,%esp
  801303:	68 07 0e 00 00       	push   $0xe07
  801308:	68 00 f0 bf ee       	push   $0xeebff000
  80130d:	50                   	push   %eax
  80130e:	e8 45 fd ff ff       	call   801058 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801313:	e8 02 fd ff ff       	call   80101a <sys_getenvid>
  801318:	83 c4 08             	add    $0x8,%esp
  80131b:	68 33 13 80 00       	push   $0x801333
  801320:	50                   	push   %eax
  801321:	e8 7d fe ff ff       	call   8011a3 <sys_env_set_pgfault_upcall>
  801326:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801329:	8b 45 08             	mov    0x8(%ebp),%eax
  80132c:	a3 b8 40 80 00       	mov    %eax,0x8040b8
}
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801333:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801334:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	call *%eax
  801339:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80133b:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80133e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801342:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801346:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801349:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80134c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80134d:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801350:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801351:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801352:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801356:	c3                   	ret    

00801357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80135a:	8b 45 08             	mov    0x8(%ebp),%eax
  80135d:	05 00 00 00 30       	add    $0x30000000,%eax
  801362:	c1 e8 0c             	shr    $0xc,%eax
}
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80136a:	8b 45 08             	mov    0x8(%ebp),%eax
  80136d:	05 00 00 00 30       	add    $0x30000000,%eax
  801372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801389:	89 c2                	mov    %eax,%edx
  80138b:	c1 ea 16             	shr    $0x16,%edx
  80138e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801395:	f6 c2 01             	test   $0x1,%dl
  801398:	74 11                	je     8013ab <fd_alloc+0x2d>
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	c1 ea 0c             	shr    $0xc,%edx
  80139f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a6:	f6 c2 01             	test   $0x1,%dl
  8013a9:	75 09                	jne    8013b4 <fd_alloc+0x36>
			*fd_store = fd;
  8013ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b2:	eb 17                	jmp    8013cb <fd_alloc+0x4d>
  8013b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013be:	75 c9                	jne    801389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013d3:	83 f8 1f             	cmp    $0x1f,%eax
  8013d6:	77 36                	ja     80140e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013d8:	c1 e0 0c             	shl    $0xc,%eax
  8013db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013e0:	89 c2                	mov    %eax,%edx
  8013e2:	c1 ea 16             	shr    $0x16,%edx
  8013e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ec:	f6 c2 01             	test   $0x1,%dl
  8013ef:	74 24                	je     801415 <fd_lookup+0x48>
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	c1 ea 0c             	shr    $0xc,%edx
  8013f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fd:	f6 c2 01             	test   $0x1,%dl
  801400:	74 1a                	je     80141c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801402:	8b 55 0c             	mov    0xc(%ebp),%edx
  801405:	89 02                	mov    %eax,(%edx)
	return 0;
  801407:	b8 00 00 00 00       	mov    $0x0,%eax
  80140c:	eb 13                	jmp    801421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80140e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801413:	eb 0c                	jmp    801421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141a:	eb 05                	jmp    801421 <fd_lookup+0x54>
  80141c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    

00801423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142c:	ba 4c 2d 80 00       	mov    $0x802d4c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801431:	eb 13                	jmp    801446 <dev_lookup+0x23>
  801433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801436:	39 08                	cmp    %ecx,(%eax)
  801438:	75 0c                	jne    801446 <dev_lookup+0x23>
			*dev = devtab[i];
  80143a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80143f:	b8 00 00 00 00       	mov    $0x0,%eax
  801444:	eb 2e                	jmp    801474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801446:	8b 02                	mov    (%edx),%eax
  801448:	85 c0                	test   %eax,%eax
  80144a:	75 e7                	jne    801433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80144c:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801451:	8b 40 48             	mov    0x48(%eax),%eax
  801454:	83 ec 04             	sub    $0x4,%esp
  801457:	51                   	push   %ecx
  801458:	50                   	push   %eax
  801459:	68 cc 2c 80 00       	push   $0x802ccc
  80145e:	e8 6d f2 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  801463:	8b 45 0c             	mov    0xc(%ebp),%eax
  801466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
  80147b:	83 ec 10             	sub    $0x10,%esp
  80147e:	8b 75 08             	mov    0x8(%ebp),%esi
  801481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80148e:	c1 e8 0c             	shr    $0xc,%eax
  801491:	50                   	push   %eax
  801492:	e8 36 ff ff ff       	call   8013cd <fd_lookup>
  801497:	83 c4 08             	add    $0x8,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 05                	js     8014a3 <fd_close+0x2d>
	    || fd != fd2)
  80149e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014a1:	74 0c                	je     8014af <fd_close+0x39>
		return (must_exist ? r : 0);
  8014a3:	84 db                	test   %bl,%bl
  8014a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014aa:	0f 44 c2             	cmove  %edx,%eax
  8014ad:	eb 41                	jmp    8014f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	ff 36                	pushl  (%esi)
  8014b8:	e8 66 ff ff ff       	call   801423 <dev_lookup>
  8014bd:	89 c3                	mov    %eax,%ebx
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 1a                	js     8014e0 <fd_close+0x6a>
		if (dev->dev_close)
  8014c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	74 0b                	je     8014e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014d5:	83 ec 0c             	sub    $0xc,%esp
  8014d8:	56                   	push   %esi
  8014d9:	ff d0                	call   *%eax
  8014db:	89 c3                	mov    %eax,%ebx
  8014dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	56                   	push   %esi
  8014e4:	6a 00                	push   $0x0
  8014e6:	e8 f2 fb ff ff       	call   8010dd <sys_page_unmap>
	return r;
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	89 d8                	mov    %ebx,%eax
}
  8014f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f3:	5b                   	pop    %ebx
  8014f4:	5e                   	pop    %esi
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801500:	50                   	push   %eax
  801501:	ff 75 08             	pushl  0x8(%ebp)
  801504:	e8 c4 fe ff ff       	call   8013cd <fd_lookup>
  801509:	83 c4 08             	add    $0x8,%esp
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 10                	js     801520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	6a 01                	push   $0x1
  801515:	ff 75 f4             	pushl  -0xc(%ebp)
  801518:	e8 59 ff ff ff       	call   801476 <fd_close>
  80151d:	83 c4 10             	add    $0x10,%esp
}
  801520:	c9                   	leave  
  801521:	c3                   	ret    

00801522 <close_all>:

void
close_all(void)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	53                   	push   %ebx
  801526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	53                   	push   %ebx
  801532:	e8 c0 ff ff ff       	call   8014f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801537:	83 c3 01             	add    $0x1,%ebx
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	83 fb 20             	cmp    $0x20,%ebx
  801540:	75 ec                	jne    80152e <close_all+0xc>
		close(i);
}
  801542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801545:	c9                   	leave  
  801546:	c3                   	ret    

00801547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	57                   	push   %edi
  80154b:	56                   	push   %esi
  80154c:	53                   	push   %ebx
  80154d:	83 ec 2c             	sub    $0x2c,%esp
  801550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	ff 75 08             	pushl  0x8(%ebp)
  80155a:	e8 6e fe ff ff       	call   8013cd <fd_lookup>
  80155f:	83 c4 08             	add    $0x8,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	0f 88 c1 00 00 00    	js     80162b <dup+0xe4>
		return r;
	close(newfdnum);
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	56                   	push   %esi
  80156e:	e8 84 ff ff ff       	call   8014f7 <close>

	newfd = INDEX2FD(newfdnum);
  801573:	89 f3                	mov    %esi,%ebx
  801575:	c1 e3 0c             	shl    $0xc,%ebx
  801578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80157e:	83 c4 04             	add    $0x4,%esp
  801581:	ff 75 e4             	pushl  -0x1c(%ebp)
  801584:	e8 de fd ff ff       	call   801367 <fd2data>
  801589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80158b:	89 1c 24             	mov    %ebx,(%esp)
  80158e:	e8 d4 fd ff ff       	call   801367 <fd2data>
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801599:	89 f8                	mov    %edi,%eax
  80159b:	c1 e8 16             	shr    $0x16,%eax
  80159e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015a5:	a8 01                	test   $0x1,%al
  8015a7:	74 37                	je     8015e0 <dup+0x99>
  8015a9:	89 f8                	mov    %edi,%eax
  8015ab:	c1 e8 0c             	shr    $0xc,%eax
  8015ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015b5:	f6 c2 01             	test   $0x1,%dl
  8015b8:	74 26                	je     8015e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8015c9:	50                   	push   %eax
  8015ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015cd:	6a 00                	push   $0x0
  8015cf:	57                   	push   %edi
  8015d0:	6a 00                	push   $0x0
  8015d2:	e8 c4 fa ff ff       	call   80109b <sys_page_map>
  8015d7:	89 c7                	mov    %eax,%edi
  8015d9:	83 c4 20             	add    $0x20,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 2e                	js     80160e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015e3:	89 d0                	mov    %edx,%eax
  8015e5:	c1 e8 0c             	shr    $0xc,%eax
  8015e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ef:	83 ec 0c             	sub    $0xc,%esp
  8015f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f7:	50                   	push   %eax
  8015f8:	53                   	push   %ebx
  8015f9:	6a 00                	push   $0x0
  8015fb:	52                   	push   %edx
  8015fc:	6a 00                	push   $0x0
  8015fe:	e8 98 fa ff ff       	call   80109b <sys_page_map>
  801603:	89 c7                	mov    %eax,%edi
  801605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80160a:	85 ff                	test   %edi,%edi
  80160c:	79 1d                	jns    80162b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	53                   	push   %ebx
  801612:	6a 00                	push   $0x0
  801614:	e8 c4 fa ff ff       	call   8010dd <sys_page_unmap>
	sys_page_unmap(0, nva);
  801619:	83 c4 08             	add    $0x8,%esp
  80161c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80161f:	6a 00                	push   $0x0
  801621:	e8 b7 fa ff ff       	call   8010dd <sys_page_unmap>
	return r;
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	89 f8                	mov    %edi,%eax
}
  80162b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162e:	5b                   	pop    %ebx
  80162f:	5e                   	pop    %esi
  801630:	5f                   	pop    %edi
  801631:	5d                   	pop    %ebp
  801632:	c3                   	ret    

00801633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	53                   	push   %ebx
  801637:	83 ec 14             	sub    $0x14,%esp
  80163a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801640:	50                   	push   %eax
  801641:	53                   	push   %ebx
  801642:	e8 86 fd ff ff       	call   8013cd <fd_lookup>
  801647:	83 c4 08             	add    $0x8,%esp
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 6d                	js     8016bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165a:	ff 30                	pushl  (%eax)
  80165c:	e8 c2 fd ff ff       	call   801423 <dev_lookup>
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	85 c0                	test   %eax,%eax
  801666:	78 4c                	js     8016b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80166b:	8b 42 08             	mov    0x8(%edx),%eax
  80166e:	83 e0 03             	and    $0x3,%eax
  801671:	83 f8 01             	cmp    $0x1,%eax
  801674:	75 21                	jne    801697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801676:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80167b:	8b 40 48             	mov    0x48(%eax),%eax
  80167e:	83 ec 04             	sub    $0x4,%esp
  801681:	53                   	push   %ebx
  801682:	50                   	push   %eax
  801683:	68 10 2d 80 00       	push   $0x802d10
  801688:	e8 43 f0 ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801695:	eb 26                	jmp    8016bd <read+0x8a>
	}
	if (!dev->dev_read)
  801697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169a:	8b 40 08             	mov    0x8(%eax),%eax
  80169d:	85 c0                	test   %eax,%eax
  80169f:	74 17                	je     8016b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016a1:	83 ec 04             	sub    $0x4,%esp
  8016a4:	ff 75 10             	pushl  0x10(%ebp)
  8016a7:	ff 75 0c             	pushl  0xc(%ebp)
  8016aa:	52                   	push   %edx
  8016ab:	ff d0                	call   *%eax
  8016ad:	89 c2                	mov    %eax,%edx
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	eb 09                	jmp    8016bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b4:	89 c2                	mov    %eax,%edx
  8016b6:	eb 05                	jmp    8016bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016bd:	89 d0                	mov    %edx,%eax
  8016bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	57                   	push   %edi
  8016c8:	56                   	push   %esi
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 0c             	sub    $0xc,%esp
  8016cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d8:	eb 21                	jmp    8016fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	89 f0                	mov    %esi,%eax
  8016df:	29 d8                	sub    %ebx,%eax
  8016e1:	50                   	push   %eax
  8016e2:	89 d8                	mov    %ebx,%eax
  8016e4:	03 45 0c             	add    0xc(%ebp),%eax
  8016e7:	50                   	push   %eax
  8016e8:	57                   	push   %edi
  8016e9:	e8 45 ff ff ff       	call   801633 <read>
		if (m < 0)
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 10                	js     801705 <readn+0x41>
			return m;
		if (m == 0)
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	74 0a                	je     801703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016f9:	01 c3                	add    %eax,%ebx
  8016fb:	39 f3                	cmp    %esi,%ebx
  8016fd:	72 db                	jb     8016da <readn+0x16>
  8016ff:	89 d8                	mov    %ebx,%eax
  801701:	eb 02                	jmp    801705 <readn+0x41>
  801703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801708:	5b                   	pop    %ebx
  801709:	5e                   	pop    %esi
  80170a:	5f                   	pop    %edi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	53                   	push   %ebx
  801711:	83 ec 14             	sub    $0x14,%esp
  801714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171a:	50                   	push   %eax
  80171b:	53                   	push   %ebx
  80171c:	e8 ac fc ff ff       	call   8013cd <fd_lookup>
  801721:	83 c4 08             	add    $0x8,%esp
  801724:	89 c2                	mov    %eax,%edx
  801726:	85 c0                	test   %eax,%eax
  801728:	78 68                	js     801792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801730:	50                   	push   %eax
  801731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801734:	ff 30                	pushl  (%eax)
  801736:	e8 e8 fc ff ff       	call   801423 <dev_lookup>
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 47                	js     801789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801749:	75 21                	jne    80176c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80174b:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801750:	8b 40 48             	mov    0x48(%eax),%eax
  801753:	83 ec 04             	sub    $0x4,%esp
  801756:	53                   	push   %ebx
  801757:	50                   	push   %eax
  801758:	68 2c 2d 80 00       	push   $0x802d2c
  80175d:	e8 6e ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80176a:	eb 26                	jmp    801792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80176c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176f:	8b 52 0c             	mov    0xc(%edx),%edx
  801772:	85 d2                	test   %edx,%edx
  801774:	74 17                	je     80178d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801776:	83 ec 04             	sub    $0x4,%esp
  801779:	ff 75 10             	pushl  0x10(%ebp)
  80177c:	ff 75 0c             	pushl  0xc(%ebp)
  80177f:	50                   	push   %eax
  801780:	ff d2                	call   *%edx
  801782:	89 c2                	mov    %eax,%edx
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	eb 09                	jmp    801792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801789:	89 c2                	mov    %eax,%edx
  80178b:	eb 05                	jmp    801792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80178d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801792:	89 d0                	mov    %edx,%eax
  801794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <seek>:

int
seek(int fdnum, off_t offset)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80179f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017a2:	50                   	push   %eax
  8017a3:	ff 75 08             	pushl  0x8(%ebp)
  8017a6:	e8 22 fc ff ff       	call   8013cd <fd_lookup>
  8017ab:	83 c4 08             	add    $0x8,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 0e                	js     8017c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    

008017c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	53                   	push   %ebx
  8017c6:	83 ec 14             	sub    $0x14,%esp
  8017c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cf:	50                   	push   %eax
  8017d0:	53                   	push   %ebx
  8017d1:	e8 f7 fb ff ff       	call   8013cd <fd_lookup>
  8017d6:	83 c4 08             	add    $0x8,%esp
  8017d9:	89 c2                	mov    %eax,%edx
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 65                	js     801844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017df:	83 ec 08             	sub    $0x8,%esp
  8017e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e5:	50                   	push   %eax
  8017e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e9:	ff 30                	pushl  (%eax)
  8017eb:	e8 33 fc ff ff       	call   801423 <dev_lookup>
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 44                	js     80183b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017fe:	75 21                	jne    801821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801800:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801805:	8b 40 48             	mov    0x48(%eax),%eax
  801808:	83 ec 04             	sub    $0x4,%esp
  80180b:	53                   	push   %ebx
  80180c:	50                   	push   %eax
  80180d:	68 ec 2c 80 00       	push   $0x802cec
  801812:	e8 b9 ee ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80181f:	eb 23                	jmp    801844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801824:	8b 52 18             	mov    0x18(%edx),%edx
  801827:	85 d2                	test   %edx,%edx
  801829:	74 14                	je     80183f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	ff 75 0c             	pushl  0xc(%ebp)
  801831:	50                   	push   %eax
  801832:	ff d2                	call   *%edx
  801834:	89 c2                	mov    %eax,%edx
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	eb 09                	jmp    801844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183b:	89 c2                	mov    %eax,%edx
  80183d:	eb 05                	jmp    801844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80183f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801844:	89 d0                	mov    %edx,%eax
  801846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 14             	sub    $0x14,%esp
  801852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801858:	50                   	push   %eax
  801859:	ff 75 08             	pushl  0x8(%ebp)
  80185c:	e8 6c fb ff ff       	call   8013cd <fd_lookup>
  801861:	83 c4 08             	add    $0x8,%esp
  801864:	89 c2                	mov    %eax,%edx
  801866:	85 c0                	test   %eax,%eax
  801868:	78 58                	js     8018c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801870:	50                   	push   %eax
  801871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801874:	ff 30                	pushl  (%eax)
  801876:	e8 a8 fb ff ff       	call   801423 <dev_lookup>
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	85 c0                	test   %eax,%eax
  801880:	78 37                	js     8018b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801889:	74 32                	je     8018bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80188b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80188e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801895:	00 00 00 
	stat->st_isdir = 0;
  801898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80189f:	00 00 00 
	stat->st_dev = dev;
  8018a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	53                   	push   %ebx
  8018ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8018af:	ff 50 14             	call   *0x14(%eax)
  8018b2:	89 c2                	mov    %eax,%edx
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	eb 09                	jmp    8018c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b9:	89 c2                	mov    %eax,%edx
  8018bb:	eb 05                	jmp    8018c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018c2:	89 d0                	mov    %edx,%eax
  8018c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	56                   	push   %esi
  8018cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018ce:	83 ec 08             	sub    $0x8,%esp
  8018d1:	6a 00                	push   $0x0
  8018d3:	ff 75 08             	pushl  0x8(%ebp)
  8018d6:	e8 d6 01 00 00       	call   801ab1 <open>
  8018db:	89 c3                	mov    %eax,%ebx
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 1b                	js     8018ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ea:	50                   	push   %eax
  8018eb:	e8 5b ff ff ff       	call   80184b <fstat>
  8018f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8018f2:	89 1c 24             	mov    %ebx,(%esp)
  8018f5:	e8 fd fb ff ff       	call   8014f7 <close>
	return r;
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	89 f0                	mov    %esi,%eax
}
  8018ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801902:	5b                   	pop    %ebx
  801903:	5e                   	pop    %esi
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	56                   	push   %esi
  80190a:	53                   	push   %ebx
  80190b:	89 c6                	mov    %eax,%esi
  80190d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80190f:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801916:	75 12                	jne    80192a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	6a 01                	push   $0x1
  80191d:	e8 34 0c 00 00       	call   802556 <ipc_find_env>
  801922:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801927:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80192a:	6a 07                	push   $0x7
  80192c:	68 00 50 80 00       	push   $0x805000
  801931:	56                   	push   %esi
  801932:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801938:	e8 c5 0b 00 00       	call   802502 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80193d:	83 c4 0c             	add    $0xc,%esp
  801940:	6a 00                	push   $0x0
  801942:	53                   	push   %ebx
  801943:	6a 00                	push   $0x0
  801945:	e8 51 0b 00 00       	call   80249b <ipc_recv>
}
  80194a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194d:	5b                   	pop    %ebx
  80194e:	5e                   	pop    %esi
  80194f:	5d                   	pop    %ebp
  801950:	c3                   	ret    

00801951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
  80195a:	8b 40 0c             	mov    0xc(%eax),%eax
  80195d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801962:	8b 45 0c             	mov    0xc(%ebp),%eax
  801965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80196a:	ba 00 00 00 00       	mov    $0x0,%edx
  80196f:	b8 02 00 00 00       	mov    $0x2,%eax
  801974:	e8 8d ff ff ff       	call   801906 <fsipc>
}
  801979:	c9                   	leave  
  80197a:	c3                   	ret    

0080197b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801981:	8b 45 08             	mov    0x8(%ebp),%eax
  801984:	8b 40 0c             	mov    0xc(%eax),%eax
  801987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80198c:	ba 00 00 00 00       	mov    $0x0,%edx
  801991:	b8 06 00 00 00       	mov    $0x6,%eax
  801996:	e8 6b ff ff ff       	call   801906 <fsipc>
}
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    

0080199d <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	53                   	push   %ebx
  8019a1:	83 ec 04             	sub    $0x4,%esp
  8019a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8019bc:	e8 45 ff ff ff       	call   801906 <fsipc>
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	78 2c                	js     8019f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019c5:	83 ec 08             	sub    $0x8,%esp
  8019c8:	68 00 50 80 00       	push   $0x805000
  8019cd:	53                   	push   %ebx
  8019ce:	e8 82 f2 ff ff       	call   800c55 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8019d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019de:	a1 84 50 80 00       	mov    0x805084,%eax
  8019e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801a02:	8b 52 0c             	mov    0xc(%edx),%edx
  801a05:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a0b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a10:	50                   	push   %eax
  801a11:	ff 75 0c             	pushl  0xc(%ebp)
  801a14:	68 08 50 80 00       	push   $0x805008
  801a19:	e8 c9 f3 ff ff       	call   800de7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a23:	b8 04 00 00 00       	mov    $0x4,%eax
  801a28:	e8 d9 fe ff ff       	call   801906 <fsipc>

}
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a37:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a42:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a48:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4d:	b8 03 00 00 00       	mov    $0x3,%eax
  801a52:	e8 af fe ff ff       	call   801906 <fsipc>
  801a57:	89 c3                	mov    %eax,%ebx
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	78 4b                	js     801aa8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a5d:	39 c6                	cmp    %eax,%esi
  801a5f:	73 16                	jae    801a77 <devfile_read+0x48>
  801a61:	68 60 2d 80 00       	push   $0x802d60
  801a66:	68 67 2d 80 00       	push   $0x802d67
  801a6b:	6a 7c                	push   $0x7c
  801a6d:	68 7c 2d 80 00       	push   $0x802d7c
  801a72:	e8 80 eb ff ff       	call   8005f7 <_panic>
	assert(r <= PGSIZE);
  801a77:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a7c:	7e 16                	jle    801a94 <devfile_read+0x65>
  801a7e:	68 87 2d 80 00       	push   $0x802d87
  801a83:	68 67 2d 80 00       	push   $0x802d67
  801a88:	6a 7d                	push   $0x7d
  801a8a:	68 7c 2d 80 00       	push   $0x802d7c
  801a8f:	e8 63 eb ff ff       	call   8005f7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	50                   	push   %eax
  801a98:	68 00 50 80 00       	push   $0x805000
  801a9d:	ff 75 0c             	pushl  0xc(%ebp)
  801aa0:	e8 42 f3 ff ff       	call   800de7 <memmove>
	return r;
  801aa5:	83 c4 10             	add    $0x10,%esp
}
  801aa8:	89 d8                	mov    %ebx,%eax
  801aaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 20             	sub    $0x20,%esp
  801ab8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801abb:	53                   	push   %ebx
  801abc:	e8 5b f1 ff ff       	call   800c1c <strlen>
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ac9:	7f 67                	jg     801b32 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801acb:	83 ec 0c             	sub    $0xc,%esp
  801ace:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad1:	50                   	push   %eax
  801ad2:	e8 a7 f8 ff ff       	call   80137e <fd_alloc>
  801ad7:	83 c4 10             	add    $0x10,%esp
		return r;
  801ada:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801adc:	85 c0                	test   %eax,%eax
  801ade:	78 57                	js     801b37 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	53                   	push   %ebx
  801ae4:	68 00 50 80 00       	push   $0x805000
  801ae9:	e8 67 f1 ff ff       	call   800c55 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801af6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801af9:	b8 01 00 00 00       	mov    $0x1,%eax
  801afe:	e8 03 fe ff ff       	call   801906 <fsipc>
  801b03:	89 c3                	mov    %eax,%ebx
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	79 14                	jns    801b20 <open+0x6f>
		fd_close(fd, 0);
  801b0c:	83 ec 08             	sub    $0x8,%esp
  801b0f:	6a 00                	push   $0x0
  801b11:	ff 75 f4             	pushl  -0xc(%ebp)
  801b14:	e8 5d f9 ff ff       	call   801476 <fd_close>
		return r;
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	89 da                	mov    %ebx,%edx
  801b1e:	eb 17                	jmp    801b37 <open+0x86>
	}

	return fd2num(fd);
  801b20:	83 ec 0c             	sub    $0xc,%esp
  801b23:	ff 75 f4             	pushl  -0xc(%ebp)
  801b26:	e8 2c f8 ff ff       	call   801357 <fd2num>
  801b2b:	89 c2                	mov    %eax,%edx
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	eb 05                	jmp    801b37 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b32:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b37:	89 d0                	mov    %edx,%eax
  801b39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b44:	ba 00 00 00 00       	mov    $0x0,%edx
  801b49:	b8 08 00 00 00       	mov    $0x8,%eax
  801b4e:	e8 b3 fd ff ff       	call   801906 <fsipc>
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b5b:	68 93 2d 80 00       	push   $0x802d93
  801b60:	ff 75 0c             	pushl  0xc(%ebp)
  801b63:	e8 ed f0 ff ff       	call   800c55 <strcpy>
	return 0;
}
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6d:	c9                   	leave  
  801b6e:	c3                   	ret    

00801b6f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	53                   	push   %ebx
  801b73:	83 ec 10             	sub    $0x10,%esp
  801b76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b79:	53                   	push   %ebx
  801b7a:	e8 10 0a 00 00       	call   80258f <pageref>
  801b7f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b82:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b87:	83 f8 01             	cmp    $0x1,%eax
  801b8a:	75 10                	jne    801b9c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	ff 73 0c             	pushl  0xc(%ebx)
  801b92:	e8 c0 02 00 00       	call   801e57 <nsipc_close>
  801b97:	89 c2                	mov    %eax,%edx
  801b99:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b9c:	89 d0                	mov    %edx,%eax
  801b9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba1:	c9                   	leave  
  801ba2:	c3                   	ret    

00801ba3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ba9:	6a 00                	push   $0x0
  801bab:	ff 75 10             	pushl  0x10(%ebp)
  801bae:	ff 75 0c             	pushl  0xc(%ebp)
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	ff 70 0c             	pushl  0xc(%eax)
  801bb7:	e8 78 03 00 00       	call   801f34 <nsipc_send>
}
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bc4:	6a 00                	push   $0x0
  801bc6:	ff 75 10             	pushl  0x10(%ebp)
  801bc9:	ff 75 0c             	pushl  0xc(%ebp)
  801bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcf:	ff 70 0c             	pushl  0xc(%eax)
  801bd2:	e8 f1 02 00 00       	call   801ec8 <nsipc_recv>
}
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    

00801bd9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bdf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801be2:	52                   	push   %edx
  801be3:	50                   	push   %eax
  801be4:	e8 e4 f7 ff ff       	call   8013cd <fd_lookup>
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	85 c0                	test   %eax,%eax
  801bee:	78 17                	js     801c07 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf3:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801bf9:	39 08                	cmp    %ecx,(%eax)
  801bfb:	75 05                	jne    801c02 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bfd:	8b 40 0c             	mov    0xc(%eax),%eax
  801c00:	eb 05                	jmp    801c07 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c02:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	56                   	push   %esi
  801c0d:	53                   	push   %ebx
  801c0e:	83 ec 1c             	sub    $0x1c,%esp
  801c11:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c16:	50                   	push   %eax
  801c17:	e8 62 f7 ff ff       	call   80137e <fd_alloc>
  801c1c:	89 c3                	mov    %eax,%ebx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	85 c0                	test   %eax,%eax
  801c23:	78 1b                	js     801c40 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c25:	83 ec 04             	sub    $0x4,%esp
  801c28:	68 07 04 00 00       	push   $0x407
  801c2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c30:	6a 00                	push   $0x0
  801c32:	e8 21 f4 ff ff       	call   801058 <sys_page_alloc>
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	79 10                	jns    801c50 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	56                   	push   %esi
  801c44:	e8 0e 02 00 00       	call   801e57 <nsipc_close>
		return r;
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	89 d8                	mov    %ebx,%eax
  801c4e:	eb 24                	jmp    801c74 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c50:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c59:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c65:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c68:	83 ec 0c             	sub    $0xc,%esp
  801c6b:	50                   	push   %eax
  801c6c:	e8 e6 f6 ff ff       	call   801357 <fd2num>
  801c71:	83 c4 10             	add    $0x10,%esp
}
  801c74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c77:	5b                   	pop    %ebx
  801c78:	5e                   	pop    %esi
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c81:	8b 45 08             	mov    0x8(%ebp),%eax
  801c84:	e8 50 ff ff ff       	call   801bd9 <fd2sockid>
		return r;
  801c89:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	78 1f                	js     801cae <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c8f:	83 ec 04             	sub    $0x4,%esp
  801c92:	ff 75 10             	pushl  0x10(%ebp)
  801c95:	ff 75 0c             	pushl  0xc(%ebp)
  801c98:	50                   	push   %eax
  801c99:	e8 12 01 00 00       	call   801db0 <nsipc_accept>
  801c9e:	83 c4 10             	add    $0x10,%esp
		return r;
  801ca1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	78 07                	js     801cae <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ca7:	e8 5d ff ff ff       	call   801c09 <alloc_sockfd>
  801cac:	89 c1                	mov    %eax,%ecx
}
  801cae:	89 c8                	mov    %ecx,%eax
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbb:	e8 19 ff ff ff       	call   801bd9 <fd2sockid>
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	78 12                	js     801cd6 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801cc4:	83 ec 04             	sub    $0x4,%esp
  801cc7:	ff 75 10             	pushl  0x10(%ebp)
  801cca:	ff 75 0c             	pushl  0xc(%ebp)
  801ccd:	50                   	push   %eax
  801cce:	e8 2d 01 00 00       	call   801e00 <nsipc_bind>
  801cd3:	83 c4 10             	add    $0x10,%esp
}
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <shutdown>:

int
shutdown(int s, int how)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	e8 f3 fe ff ff       	call   801bd9 <fd2sockid>
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	78 0f                	js     801cf9 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cea:	83 ec 08             	sub    $0x8,%esp
  801ced:	ff 75 0c             	pushl  0xc(%ebp)
  801cf0:	50                   	push   %eax
  801cf1:	e8 3f 01 00 00       	call   801e35 <nsipc_shutdown>
  801cf6:	83 c4 10             	add    $0x10,%esp
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	e8 d0 fe ff ff       	call   801bd9 <fd2sockid>
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	78 12                	js     801d1f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801d0d:	83 ec 04             	sub    $0x4,%esp
  801d10:	ff 75 10             	pushl  0x10(%ebp)
  801d13:	ff 75 0c             	pushl  0xc(%ebp)
  801d16:	50                   	push   %eax
  801d17:	e8 55 01 00 00       	call   801e71 <nsipc_connect>
  801d1c:	83 c4 10             	add    $0x10,%esp
}
  801d1f:	c9                   	leave  
  801d20:	c3                   	ret    

00801d21 <listen>:

int
listen(int s, int backlog)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2a:	e8 aa fe ff ff       	call   801bd9 <fd2sockid>
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	78 0f                	js     801d42 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d33:	83 ec 08             	sub    $0x8,%esp
  801d36:	ff 75 0c             	pushl  0xc(%ebp)
  801d39:	50                   	push   %eax
  801d3a:	e8 67 01 00 00       	call   801ea6 <nsipc_listen>
  801d3f:	83 c4 10             	add    $0x10,%esp
}
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d4a:	ff 75 10             	pushl  0x10(%ebp)
  801d4d:	ff 75 0c             	pushl  0xc(%ebp)
  801d50:	ff 75 08             	pushl  0x8(%ebp)
  801d53:	e8 3a 02 00 00       	call   801f92 <nsipc_socket>
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	78 05                	js     801d64 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d5f:	e8 a5 fe ff ff       	call   801c09 <alloc_sockfd>
}
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    

00801d66 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	53                   	push   %ebx
  801d6a:	83 ec 04             	sub    $0x4,%esp
  801d6d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d6f:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  801d76:	75 12                	jne    801d8a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d78:	83 ec 0c             	sub    $0xc,%esp
  801d7b:	6a 02                	push   $0x2
  801d7d:	e8 d4 07 00 00       	call   802556 <ipc_find_env>
  801d82:	a3 b0 40 80 00       	mov    %eax,0x8040b0
  801d87:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d8a:	6a 07                	push   $0x7
  801d8c:	68 00 60 80 00       	push   $0x806000
  801d91:	53                   	push   %ebx
  801d92:	ff 35 b0 40 80 00    	pushl  0x8040b0
  801d98:	e8 65 07 00 00       	call   802502 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d9d:	83 c4 0c             	add    $0xc,%esp
  801da0:	6a 00                	push   $0x0
  801da2:	6a 00                	push   $0x0
  801da4:	6a 00                	push   $0x0
  801da6:	e8 f0 06 00 00       	call   80249b <ipc_recv>
}
  801dab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dae:	c9                   	leave  
  801daf:	c3                   	ret    

00801db0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	56                   	push   %esi
  801db4:	53                   	push   %ebx
  801db5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801dc0:	8b 06                	mov    (%esi),%eax
  801dc2:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801dc7:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcc:	e8 95 ff ff ff       	call   801d66 <nsipc>
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	78 20                	js     801df7 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801dd7:	83 ec 04             	sub    $0x4,%esp
  801dda:	ff 35 10 60 80 00    	pushl  0x806010
  801de0:	68 00 60 80 00       	push   $0x806000
  801de5:	ff 75 0c             	pushl  0xc(%ebp)
  801de8:	e8 fa ef ff ff       	call   800de7 <memmove>
		*addrlen = ret->ret_addrlen;
  801ded:	a1 10 60 80 00       	mov    0x806010,%eax
  801df2:	89 06                	mov    %eax,(%esi)
  801df4:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801df7:	89 d8                	mov    %ebx,%eax
  801df9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	53                   	push   %ebx
  801e04:	83 ec 08             	sub    $0x8,%esp
  801e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e12:	53                   	push   %ebx
  801e13:	ff 75 0c             	pushl  0xc(%ebp)
  801e16:	68 04 60 80 00       	push   $0x806004
  801e1b:	e8 c7 ef ff ff       	call   800de7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e20:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e26:	b8 02 00 00 00       	mov    $0x2,%eax
  801e2b:	e8 36 ff ff ff       	call   801d66 <nsipc>
}
  801e30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    

00801e35 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e46:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e4b:	b8 03 00 00 00       	mov    $0x3,%eax
  801e50:	e8 11 ff ff ff       	call   801d66 <nsipc>
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <nsipc_close>:

int
nsipc_close(int s)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e60:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e65:	b8 04 00 00 00       	mov    $0x4,%eax
  801e6a:	e8 f7 fe ff ff       	call   801d66 <nsipc>
}
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	53                   	push   %ebx
  801e75:	83 ec 08             	sub    $0x8,%esp
  801e78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e83:	53                   	push   %ebx
  801e84:	ff 75 0c             	pushl  0xc(%ebp)
  801e87:	68 04 60 80 00       	push   $0x806004
  801e8c:	e8 56 ef ff ff       	call   800de7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e91:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e97:	b8 05 00 00 00       	mov    $0x5,%eax
  801e9c:	e8 c5 fe ff ff       	call   801d66 <nsipc>
}
  801ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801eac:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ebc:	b8 06 00 00 00       	mov    $0x6,%eax
  801ec1:	e8 a0 fe ff ff       	call   801d66 <nsipc>
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	56                   	push   %esi
  801ecc:	53                   	push   %ebx
  801ecd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ed8:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ede:	8b 45 14             	mov    0x14(%ebp),%eax
  801ee1:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ee6:	b8 07 00 00 00       	mov    $0x7,%eax
  801eeb:	e8 76 fe ff ff       	call   801d66 <nsipc>
  801ef0:	89 c3                	mov    %eax,%ebx
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	78 35                	js     801f2b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ef6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801efb:	7f 04                	jg     801f01 <nsipc_recv+0x39>
  801efd:	39 c6                	cmp    %eax,%esi
  801eff:	7d 16                	jge    801f17 <nsipc_recv+0x4f>
  801f01:	68 9f 2d 80 00       	push   $0x802d9f
  801f06:	68 67 2d 80 00       	push   $0x802d67
  801f0b:	6a 62                	push   $0x62
  801f0d:	68 b4 2d 80 00       	push   $0x802db4
  801f12:	e8 e0 e6 ff ff       	call   8005f7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f17:	83 ec 04             	sub    $0x4,%esp
  801f1a:	50                   	push   %eax
  801f1b:	68 00 60 80 00       	push   $0x806000
  801f20:	ff 75 0c             	pushl  0xc(%ebp)
  801f23:	e8 bf ee ff ff       	call   800de7 <memmove>
  801f28:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f2b:	89 d8                	mov    %ebx,%eax
  801f2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f30:	5b                   	pop    %ebx
  801f31:	5e                   	pop    %esi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    

00801f34 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	53                   	push   %ebx
  801f38:	83 ec 04             	sub    $0x4,%esp
  801f3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f41:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f46:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f4c:	7e 16                	jle    801f64 <nsipc_send+0x30>
  801f4e:	68 c0 2d 80 00       	push   $0x802dc0
  801f53:	68 67 2d 80 00       	push   $0x802d67
  801f58:	6a 6d                	push   $0x6d
  801f5a:	68 b4 2d 80 00       	push   $0x802db4
  801f5f:	e8 93 e6 ff ff       	call   8005f7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f64:	83 ec 04             	sub    $0x4,%esp
  801f67:	53                   	push   %ebx
  801f68:	ff 75 0c             	pushl  0xc(%ebp)
  801f6b:	68 0c 60 80 00       	push   $0x80600c
  801f70:	e8 72 ee ff ff       	call   800de7 <memmove>
	nsipcbuf.send.req_size = size;
  801f75:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f7b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f7e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f83:	b8 08 00 00 00       	mov    $0x8,%eax
  801f88:	e8 d9 fd ff ff       	call   801d66 <nsipc>
}
  801f8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f98:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801fa8:	8b 45 10             	mov    0x10(%ebp),%eax
  801fab:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801fb0:	b8 09 00 00 00       	mov    $0x9,%eax
  801fb5:	e8 ac fd ff ff       	call   801d66 <nsipc>
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	56                   	push   %esi
  801fc0:	53                   	push   %ebx
  801fc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fc4:	83 ec 0c             	sub    $0xc,%esp
  801fc7:	ff 75 08             	pushl  0x8(%ebp)
  801fca:	e8 98 f3 ff ff       	call   801367 <fd2data>
  801fcf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fd1:	83 c4 08             	add    $0x8,%esp
  801fd4:	68 cc 2d 80 00       	push   $0x802dcc
  801fd9:	53                   	push   %ebx
  801fda:	e8 76 ec ff ff       	call   800c55 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fdf:	8b 46 04             	mov    0x4(%esi),%eax
  801fe2:	2b 06                	sub    (%esi),%eax
  801fe4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ff1:	00 00 00 
	stat->st_dev = &devpipe;
  801ff4:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ffb:	30 80 00 
	return 0;
}
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
  802003:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    

0080200a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	53                   	push   %ebx
  80200e:	83 ec 0c             	sub    $0xc,%esp
  802011:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802014:	53                   	push   %ebx
  802015:	6a 00                	push   $0x0
  802017:	e8 c1 f0 ff ff       	call   8010dd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80201c:	89 1c 24             	mov    %ebx,(%esp)
  80201f:	e8 43 f3 ff ff       	call   801367 <fd2data>
  802024:	83 c4 08             	add    $0x8,%esp
  802027:	50                   	push   %eax
  802028:	6a 00                	push   $0x0
  80202a:	e8 ae f0 ff ff       	call   8010dd <sys_page_unmap>
}
  80202f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802032:	c9                   	leave  
  802033:	c3                   	ret    

00802034 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	57                   	push   %edi
  802038:	56                   	push   %esi
  802039:	53                   	push   %ebx
  80203a:	83 ec 1c             	sub    $0x1c,%esp
  80203d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802040:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802042:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802047:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80204a:	83 ec 0c             	sub    $0xc,%esp
  80204d:	ff 75 e0             	pushl  -0x20(%ebp)
  802050:	e8 3a 05 00 00       	call   80258f <pageref>
  802055:	89 c3                	mov    %eax,%ebx
  802057:	89 3c 24             	mov    %edi,(%esp)
  80205a:	e8 30 05 00 00       	call   80258f <pageref>
  80205f:	83 c4 10             	add    $0x10,%esp
  802062:	39 c3                	cmp    %eax,%ebx
  802064:	0f 94 c1             	sete   %cl
  802067:	0f b6 c9             	movzbl %cl,%ecx
  80206a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80206d:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  802073:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802076:	39 ce                	cmp    %ecx,%esi
  802078:	74 1b                	je     802095 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80207a:	39 c3                	cmp    %eax,%ebx
  80207c:	75 c4                	jne    802042 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80207e:	8b 42 58             	mov    0x58(%edx),%eax
  802081:	ff 75 e4             	pushl  -0x1c(%ebp)
  802084:	50                   	push   %eax
  802085:	56                   	push   %esi
  802086:	68 d3 2d 80 00       	push   $0x802dd3
  80208b:	e8 40 e6 ff ff       	call   8006d0 <cprintf>
  802090:	83 c4 10             	add    $0x10,%esp
  802093:	eb ad                	jmp    802042 <_pipeisclosed+0xe>
	}
}
  802095:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209b:	5b                   	pop    %ebx
  80209c:	5e                   	pop    %esi
  80209d:	5f                   	pop    %edi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    

008020a0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	57                   	push   %edi
  8020a4:	56                   	push   %esi
  8020a5:	53                   	push   %ebx
  8020a6:	83 ec 28             	sub    $0x28,%esp
  8020a9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020ac:	56                   	push   %esi
  8020ad:	e8 b5 f2 ff ff       	call   801367 <fd2data>
  8020b2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020b4:	83 c4 10             	add    $0x10,%esp
  8020b7:	bf 00 00 00 00       	mov    $0x0,%edi
  8020bc:	eb 4b                	jmp    802109 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020be:	89 da                	mov    %ebx,%edx
  8020c0:	89 f0                	mov    %esi,%eax
  8020c2:	e8 6d ff ff ff       	call   802034 <_pipeisclosed>
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	75 48                	jne    802113 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020cb:	e8 69 ef ff ff       	call   801039 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020d0:	8b 43 04             	mov    0x4(%ebx),%eax
  8020d3:	8b 0b                	mov    (%ebx),%ecx
  8020d5:	8d 51 20             	lea    0x20(%ecx),%edx
  8020d8:	39 d0                	cmp    %edx,%eax
  8020da:	73 e2                	jae    8020be <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020df:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020e3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020e6:	89 c2                	mov    %eax,%edx
  8020e8:	c1 fa 1f             	sar    $0x1f,%edx
  8020eb:	89 d1                	mov    %edx,%ecx
  8020ed:	c1 e9 1b             	shr    $0x1b,%ecx
  8020f0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020f3:	83 e2 1f             	and    $0x1f,%edx
  8020f6:	29 ca                	sub    %ecx,%edx
  8020f8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020fc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802100:	83 c0 01             	add    $0x1,%eax
  802103:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802106:	83 c7 01             	add    $0x1,%edi
  802109:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80210c:	75 c2                	jne    8020d0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80210e:	8b 45 10             	mov    0x10(%ebp),%eax
  802111:	eb 05                	jmp    802118 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802113:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80211b:	5b                   	pop    %ebx
  80211c:	5e                   	pop    %esi
  80211d:	5f                   	pop    %edi
  80211e:	5d                   	pop    %ebp
  80211f:	c3                   	ret    

00802120 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	57                   	push   %edi
  802124:	56                   	push   %esi
  802125:	53                   	push   %ebx
  802126:	83 ec 18             	sub    $0x18,%esp
  802129:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80212c:	57                   	push   %edi
  80212d:	e8 35 f2 ff ff       	call   801367 <fd2data>
  802132:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	bb 00 00 00 00       	mov    $0x0,%ebx
  80213c:	eb 3d                	jmp    80217b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80213e:	85 db                	test   %ebx,%ebx
  802140:	74 04                	je     802146 <devpipe_read+0x26>
				return i;
  802142:	89 d8                	mov    %ebx,%eax
  802144:	eb 44                	jmp    80218a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802146:	89 f2                	mov    %esi,%edx
  802148:	89 f8                	mov    %edi,%eax
  80214a:	e8 e5 fe ff ff       	call   802034 <_pipeisclosed>
  80214f:	85 c0                	test   %eax,%eax
  802151:	75 32                	jne    802185 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802153:	e8 e1 ee ff ff       	call   801039 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802158:	8b 06                	mov    (%esi),%eax
  80215a:	3b 46 04             	cmp    0x4(%esi),%eax
  80215d:	74 df                	je     80213e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80215f:	99                   	cltd   
  802160:	c1 ea 1b             	shr    $0x1b,%edx
  802163:	01 d0                	add    %edx,%eax
  802165:	83 e0 1f             	and    $0x1f,%eax
  802168:	29 d0                	sub    %edx,%eax
  80216a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80216f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802172:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802175:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802178:	83 c3 01             	add    $0x1,%ebx
  80217b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80217e:	75 d8                	jne    802158 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802180:	8b 45 10             	mov    0x10(%ebp),%eax
  802183:	eb 05                	jmp    80218a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802185:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80218a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    

00802192 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
  802195:	56                   	push   %esi
  802196:	53                   	push   %ebx
  802197:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80219a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80219d:	50                   	push   %eax
  80219e:	e8 db f1 ff ff       	call   80137e <fd_alloc>
  8021a3:	83 c4 10             	add    $0x10,%esp
  8021a6:	89 c2                	mov    %eax,%edx
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	0f 88 2c 01 00 00    	js     8022dc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b0:	83 ec 04             	sub    $0x4,%esp
  8021b3:	68 07 04 00 00       	push   $0x407
  8021b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8021bb:	6a 00                	push   $0x0
  8021bd:	e8 96 ee ff ff       	call   801058 <sys_page_alloc>
  8021c2:	83 c4 10             	add    $0x10,%esp
  8021c5:	89 c2                	mov    %eax,%edx
  8021c7:	85 c0                	test   %eax,%eax
  8021c9:	0f 88 0d 01 00 00    	js     8022dc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021cf:	83 ec 0c             	sub    $0xc,%esp
  8021d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021d5:	50                   	push   %eax
  8021d6:	e8 a3 f1 ff ff       	call   80137e <fd_alloc>
  8021db:	89 c3                	mov    %eax,%ebx
  8021dd:	83 c4 10             	add    $0x10,%esp
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	0f 88 e2 00 00 00    	js     8022ca <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e8:	83 ec 04             	sub    $0x4,%esp
  8021eb:	68 07 04 00 00       	push   $0x407
  8021f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f3:	6a 00                	push   $0x0
  8021f5:	e8 5e ee ff ff       	call   801058 <sys_page_alloc>
  8021fa:	89 c3                	mov    %eax,%ebx
  8021fc:	83 c4 10             	add    $0x10,%esp
  8021ff:	85 c0                	test   %eax,%eax
  802201:	0f 88 c3 00 00 00    	js     8022ca <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802207:	83 ec 0c             	sub    $0xc,%esp
  80220a:	ff 75 f4             	pushl  -0xc(%ebp)
  80220d:	e8 55 f1 ff ff       	call   801367 <fd2data>
  802212:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802214:	83 c4 0c             	add    $0xc,%esp
  802217:	68 07 04 00 00       	push   $0x407
  80221c:	50                   	push   %eax
  80221d:	6a 00                	push   $0x0
  80221f:	e8 34 ee ff ff       	call   801058 <sys_page_alloc>
  802224:	89 c3                	mov    %eax,%ebx
  802226:	83 c4 10             	add    $0x10,%esp
  802229:	85 c0                	test   %eax,%eax
  80222b:	0f 88 89 00 00 00    	js     8022ba <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802231:	83 ec 0c             	sub    $0xc,%esp
  802234:	ff 75 f0             	pushl  -0x10(%ebp)
  802237:	e8 2b f1 ff ff       	call   801367 <fd2data>
  80223c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802243:	50                   	push   %eax
  802244:	6a 00                	push   $0x0
  802246:	56                   	push   %esi
  802247:	6a 00                	push   $0x0
  802249:	e8 4d ee ff ff       	call   80109b <sys_page_map>
  80224e:	89 c3                	mov    %eax,%ebx
  802250:	83 c4 20             	add    $0x20,%esp
  802253:	85 c0                	test   %eax,%eax
  802255:	78 55                	js     8022ac <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802257:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80225d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802260:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802262:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802265:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80226c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802272:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802275:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802277:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80227a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802281:	83 ec 0c             	sub    $0xc,%esp
  802284:	ff 75 f4             	pushl  -0xc(%ebp)
  802287:	e8 cb f0 ff ff       	call   801357 <fd2num>
  80228c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80228f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802291:	83 c4 04             	add    $0x4,%esp
  802294:	ff 75 f0             	pushl  -0x10(%ebp)
  802297:	e8 bb f0 ff ff       	call   801357 <fd2num>
  80229c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80229f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022a2:	83 c4 10             	add    $0x10,%esp
  8022a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8022aa:	eb 30                	jmp    8022dc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8022ac:	83 ec 08             	sub    $0x8,%esp
  8022af:	56                   	push   %esi
  8022b0:	6a 00                	push   $0x0
  8022b2:	e8 26 ee ff ff       	call   8010dd <sys_page_unmap>
  8022b7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8022ba:	83 ec 08             	sub    $0x8,%esp
  8022bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8022c0:	6a 00                	push   $0x0
  8022c2:	e8 16 ee ff ff       	call   8010dd <sys_page_unmap>
  8022c7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8022ca:	83 ec 08             	sub    $0x8,%esp
  8022cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8022d0:	6a 00                	push   $0x0
  8022d2:	e8 06 ee ff ff       	call   8010dd <sys_page_unmap>
  8022d7:	83 c4 10             	add    $0x10,%esp
  8022da:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8022dc:	89 d0                	mov    %edx,%eax
  8022de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e1:	5b                   	pop    %ebx
  8022e2:	5e                   	pop    %esi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    

008022e5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022e5:	55                   	push   %ebp
  8022e6:	89 e5                	mov    %esp,%ebp
  8022e8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ee:	50                   	push   %eax
  8022ef:	ff 75 08             	pushl  0x8(%ebp)
  8022f2:	e8 d6 f0 ff ff       	call   8013cd <fd_lookup>
  8022f7:	83 c4 10             	add    $0x10,%esp
  8022fa:	85 c0                	test   %eax,%eax
  8022fc:	78 18                	js     802316 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022fe:	83 ec 0c             	sub    $0xc,%esp
  802301:	ff 75 f4             	pushl  -0xc(%ebp)
  802304:	e8 5e f0 ff ff       	call   801367 <fd2data>
	return _pipeisclosed(fd, p);
  802309:	89 c2                	mov    %eax,%edx
  80230b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230e:	e8 21 fd ff ff       	call   802034 <_pipeisclosed>
  802313:	83 c4 10             	add    $0x10,%esp
}
  802316:	c9                   	leave  
  802317:	c3                   	ret    

00802318 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80231b:	b8 00 00 00 00       	mov    $0x0,%eax
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    

00802322 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802322:	55                   	push   %ebp
  802323:	89 e5                	mov    %esp,%ebp
  802325:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802328:	68 eb 2d 80 00       	push   $0x802deb
  80232d:	ff 75 0c             	pushl  0xc(%ebp)
  802330:	e8 20 e9 ff ff       	call   800c55 <strcpy>
	return 0;
}
  802335:	b8 00 00 00 00       	mov    $0x0,%eax
  80233a:	c9                   	leave  
  80233b:	c3                   	ret    

0080233c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80233c:	55                   	push   %ebp
  80233d:	89 e5                	mov    %esp,%ebp
  80233f:	57                   	push   %edi
  802340:	56                   	push   %esi
  802341:	53                   	push   %ebx
  802342:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802348:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80234d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802353:	eb 2d                	jmp    802382 <devcons_write+0x46>
		m = n - tot;
  802355:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802358:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80235a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80235d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802362:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802365:	83 ec 04             	sub    $0x4,%esp
  802368:	53                   	push   %ebx
  802369:	03 45 0c             	add    0xc(%ebp),%eax
  80236c:	50                   	push   %eax
  80236d:	57                   	push   %edi
  80236e:	e8 74 ea ff ff       	call   800de7 <memmove>
		sys_cputs(buf, m);
  802373:	83 c4 08             	add    $0x8,%esp
  802376:	53                   	push   %ebx
  802377:	57                   	push   %edi
  802378:	e8 1f ec ff ff       	call   800f9c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80237d:	01 de                	add    %ebx,%esi
  80237f:	83 c4 10             	add    $0x10,%esp
  802382:	89 f0                	mov    %esi,%eax
  802384:	3b 75 10             	cmp    0x10(%ebp),%esi
  802387:	72 cc                	jb     802355 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802389:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80238c:	5b                   	pop    %ebx
  80238d:	5e                   	pop    %esi
  80238e:	5f                   	pop    %edi
  80238f:	5d                   	pop    %ebp
  802390:	c3                   	ret    

00802391 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
  802394:	83 ec 08             	sub    $0x8,%esp
  802397:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80239c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023a0:	74 2a                	je     8023cc <devcons_read+0x3b>
  8023a2:	eb 05                	jmp    8023a9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023a4:	e8 90 ec ff ff       	call   801039 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023a9:	e8 0c ec ff ff       	call   800fba <sys_cgetc>
  8023ae:	85 c0                	test   %eax,%eax
  8023b0:	74 f2                	je     8023a4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023b2:	85 c0                	test   %eax,%eax
  8023b4:	78 16                	js     8023cc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023b6:	83 f8 04             	cmp    $0x4,%eax
  8023b9:	74 0c                	je     8023c7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023be:	88 02                	mov    %al,(%edx)
	return 1;
  8023c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c5:	eb 05                	jmp    8023cc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023c7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023cc:	c9                   	leave  
  8023cd:	c3                   	ret    

008023ce <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023da:	6a 01                	push   $0x1
  8023dc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023df:	50                   	push   %eax
  8023e0:	e8 b7 eb ff ff       	call   800f9c <sys_cputs>
}
  8023e5:	83 c4 10             	add    $0x10,%esp
  8023e8:	c9                   	leave  
  8023e9:	c3                   	ret    

008023ea <getchar>:

int
getchar(void)
{
  8023ea:	55                   	push   %ebp
  8023eb:	89 e5                	mov    %esp,%ebp
  8023ed:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023f0:	6a 01                	push   $0x1
  8023f2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023f5:	50                   	push   %eax
  8023f6:	6a 00                	push   $0x0
  8023f8:	e8 36 f2 ff ff       	call   801633 <read>
	if (r < 0)
  8023fd:	83 c4 10             	add    $0x10,%esp
  802400:	85 c0                	test   %eax,%eax
  802402:	78 0f                	js     802413 <getchar+0x29>
		return r;
	if (r < 1)
  802404:	85 c0                	test   %eax,%eax
  802406:	7e 06                	jle    80240e <getchar+0x24>
		return -E_EOF;
	return c;
  802408:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80240c:	eb 05                	jmp    802413 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80240e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802413:	c9                   	leave  
  802414:	c3                   	ret    

00802415 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802415:	55                   	push   %ebp
  802416:	89 e5                	mov    %esp,%ebp
  802418:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80241b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80241e:	50                   	push   %eax
  80241f:	ff 75 08             	pushl  0x8(%ebp)
  802422:	e8 a6 ef ff ff       	call   8013cd <fd_lookup>
  802427:	83 c4 10             	add    $0x10,%esp
  80242a:	85 c0                	test   %eax,%eax
  80242c:	78 11                	js     80243f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80242e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802431:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802437:	39 10                	cmp    %edx,(%eax)
  802439:	0f 94 c0             	sete   %al
  80243c:	0f b6 c0             	movzbl %al,%eax
}
  80243f:	c9                   	leave  
  802440:	c3                   	ret    

00802441 <opencons>:

int
opencons(void)
{
  802441:	55                   	push   %ebp
  802442:	89 e5                	mov    %esp,%ebp
  802444:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802447:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80244a:	50                   	push   %eax
  80244b:	e8 2e ef ff ff       	call   80137e <fd_alloc>
  802450:	83 c4 10             	add    $0x10,%esp
		return r;
  802453:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802455:	85 c0                	test   %eax,%eax
  802457:	78 3e                	js     802497 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802459:	83 ec 04             	sub    $0x4,%esp
  80245c:	68 07 04 00 00       	push   $0x407
  802461:	ff 75 f4             	pushl  -0xc(%ebp)
  802464:	6a 00                	push   $0x0
  802466:	e8 ed eb ff ff       	call   801058 <sys_page_alloc>
  80246b:	83 c4 10             	add    $0x10,%esp
		return r;
  80246e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802470:	85 c0                	test   %eax,%eax
  802472:	78 23                	js     802497 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802474:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80247a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80247f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802482:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802489:	83 ec 0c             	sub    $0xc,%esp
  80248c:	50                   	push   %eax
  80248d:	e8 c5 ee ff ff       	call   801357 <fd2num>
  802492:	89 c2                	mov    %eax,%edx
  802494:	83 c4 10             	add    $0x10,%esp
}
  802497:	89 d0                	mov    %edx,%eax
  802499:	c9                   	leave  
  80249a:	c3                   	ret    

0080249b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80249b:	55                   	push   %ebp
  80249c:	89 e5                	mov    %esp,%ebp
  80249e:	56                   	push   %esi
  80249f:	53                   	push   %ebx
  8024a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8024a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8024a9:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8024ab:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024b0:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8024b3:	83 ec 0c             	sub    $0xc,%esp
  8024b6:	50                   	push   %eax
  8024b7:	e8 4c ed ff ff       	call   801208 <sys_ipc_recv>

	if (from_env_store != NULL)
  8024bc:	83 c4 10             	add    $0x10,%esp
  8024bf:	85 f6                	test   %esi,%esi
  8024c1:	74 14                	je     8024d7 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8024c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8024c8:	85 c0                	test   %eax,%eax
  8024ca:	78 09                	js     8024d5 <ipc_recv+0x3a>
  8024cc:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  8024d2:	8b 52 74             	mov    0x74(%edx),%edx
  8024d5:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8024d7:	85 db                	test   %ebx,%ebx
  8024d9:	74 14                	je     8024ef <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8024db:	ba 00 00 00 00       	mov    $0x0,%edx
  8024e0:	85 c0                	test   %eax,%eax
  8024e2:	78 09                	js     8024ed <ipc_recv+0x52>
  8024e4:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  8024ea:	8b 52 78             	mov    0x78(%edx),%edx
  8024ed:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8024ef:	85 c0                	test   %eax,%eax
  8024f1:	78 08                	js     8024fb <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8024f3:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8024f8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024fe:	5b                   	pop    %ebx
  8024ff:	5e                   	pop    %esi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    

00802502 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802502:	55                   	push   %ebp
  802503:	89 e5                	mov    %esp,%ebp
  802505:	57                   	push   %edi
  802506:	56                   	push   %esi
  802507:	53                   	push   %ebx
  802508:	83 ec 0c             	sub    $0xc,%esp
  80250b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80250e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802511:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802514:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802516:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80251b:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80251e:	ff 75 14             	pushl  0x14(%ebp)
  802521:	53                   	push   %ebx
  802522:	56                   	push   %esi
  802523:	57                   	push   %edi
  802524:	e8 bc ec ff ff       	call   8011e5 <sys_ipc_try_send>

		if (err < 0) {
  802529:	83 c4 10             	add    $0x10,%esp
  80252c:	85 c0                	test   %eax,%eax
  80252e:	79 1e                	jns    80254e <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802530:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802533:	75 07                	jne    80253c <ipc_send+0x3a>
				sys_yield();
  802535:	e8 ff ea ff ff       	call   801039 <sys_yield>
  80253a:	eb e2                	jmp    80251e <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80253c:	50                   	push   %eax
  80253d:	68 f7 2d 80 00       	push   $0x802df7
  802542:	6a 49                	push   $0x49
  802544:	68 04 2e 80 00       	push   $0x802e04
  802549:	e8 a9 e0 ff ff       	call   8005f7 <_panic>
		}

	} while (err < 0);

}
  80254e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802551:	5b                   	pop    %ebx
  802552:	5e                   	pop    %esi
  802553:	5f                   	pop    %edi
  802554:	5d                   	pop    %ebp
  802555:	c3                   	ret    

00802556 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802556:	55                   	push   %ebp
  802557:	89 e5                	mov    %esp,%ebp
  802559:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80255c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802561:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802564:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80256a:	8b 52 50             	mov    0x50(%edx),%edx
  80256d:	39 ca                	cmp    %ecx,%edx
  80256f:	75 0d                	jne    80257e <ipc_find_env+0x28>
			return envs[i].env_id;
  802571:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802574:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802579:	8b 40 48             	mov    0x48(%eax),%eax
  80257c:	eb 0f                	jmp    80258d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80257e:	83 c0 01             	add    $0x1,%eax
  802581:	3d 00 04 00 00       	cmp    $0x400,%eax
  802586:	75 d9                	jne    802561 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802588:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80258d:	5d                   	pop    %ebp
  80258e:	c3                   	ret    

0080258f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80258f:	55                   	push   %ebp
  802590:	89 e5                	mov    %esp,%ebp
  802592:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802595:	89 d0                	mov    %edx,%eax
  802597:	c1 e8 16             	shr    $0x16,%eax
  80259a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025a1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025a6:	f6 c1 01             	test   $0x1,%cl
  8025a9:	74 1d                	je     8025c8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025ab:	c1 ea 0c             	shr    $0xc,%edx
  8025ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025b5:	f6 c2 01             	test   $0x1,%dl
  8025b8:	74 0e                	je     8025c8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025ba:	c1 ea 0c             	shr    $0xc,%edx
  8025bd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025c4:	ef 
  8025c5:	0f b7 c0             	movzwl %ax,%eax
}
  8025c8:	5d                   	pop    %ebp
  8025c9:	c3                   	ret    
  8025ca:	66 90                	xchg   %ax,%ax
  8025cc:	66 90                	xchg   %ax,%ax
  8025ce:	66 90                	xchg   %ax,%ax

008025d0 <__udivdi3>:
  8025d0:	55                   	push   %ebp
  8025d1:	57                   	push   %edi
  8025d2:	56                   	push   %esi
  8025d3:	53                   	push   %ebx
  8025d4:	83 ec 1c             	sub    $0x1c,%esp
  8025d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025e7:	85 f6                	test   %esi,%esi
  8025e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025ed:	89 ca                	mov    %ecx,%edx
  8025ef:	89 f8                	mov    %edi,%eax
  8025f1:	75 3d                	jne    802630 <__udivdi3+0x60>
  8025f3:	39 cf                	cmp    %ecx,%edi
  8025f5:	0f 87 c5 00 00 00    	ja     8026c0 <__udivdi3+0xf0>
  8025fb:	85 ff                	test   %edi,%edi
  8025fd:	89 fd                	mov    %edi,%ebp
  8025ff:	75 0b                	jne    80260c <__udivdi3+0x3c>
  802601:	b8 01 00 00 00       	mov    $0x1,%eax
  802606:	31 d2                	xor    %edx,%edx
  802608:	f7 f7                	div    %edi
  80260a:	89 c5                	mov    %eax,%ebp
  80260c:	89 c8                	mov    %ecx,%eax
  80260e:	31 d2                	xor    %edx,%edx
  802610:	f7 f5                	div    %ebp
  802612:	89 c1                	mov    %eax,%ecx
  802614:	89 d8                	mov    %ebx,%eax
  802616:	89 cf                	mov    %ecx,%edi
  802618:	f7 f5                	div    %ebp
  80261a:	89 c3                	mov    %eax,%ebx
  80261c:	89 d8                	mov    %ebx,%eax
  80261e:	89 fa                	mov    %edi,%edx
  802620:	83 c4 1c             	add    $0x1c,%esp
  802623:	5b                   	pop    %ebx
  802624:	5e                   	pop    %esi
  802625:	5f                   	pop    %edi
  802626:	5d                   	pop    %ebp
  802627:	c3                   	ret    
  802628:	90                   	nop
  802629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802630:	39 ce                	cmp    %ecx,%esi
  802632:	77 74                	ja     8026a8 <__udivdi3+0xd8>
  802634:	0f bd fe             	bsr    %esi,%edi
  802637:	83 f7 1f             	xor    $0x1f,%edi
  80263a:	0f 84 98 00 00 00    	je     8026d8 <__udivdi3+0x108>
  802640:	bb 20 00 00 00       	mov    $0x20,%ebx
  802645:	89 f9                	mov    %edi,%ecx
  802647:	89 c5                	mov    %eax,%ebp
  802649:	29 fb                	sub    %edi,%ebx
  80264b:	d3 e6                	shl    %cl,%esi
  80264d:	89 d9                	mov    %ebx,%ecx
  80264f:	d3 ed                	shr    %cl,%ebp
  802651:	89 f9                	mov    %edi,%ecx
  802653:	d3 e0                	shl    %cl,%eax
  802655:	09 ee                	or     %ebp,%esi
  802657:	89 d9                	mov    %ebx,%ecx
  802659:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80265d:	89 d5                	mov    %edx,%ebp
  80265f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802663:	d3 ed                	shr    %cl,%ebp
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e2                	shl    %cl,%edx
  802669:	89 d9                	mov    %ebx,%ecx
  80266b:	d3 e8                	shr    %cl,%eax
  80266d:	09 c2                	or     %eax,%edx
  80266f:	89 d0                	mov    %edx,%eax
  802671:	89 ea                	mov    %ebp,%edx
  802673:	f7 f6                	div    %esi
  802675:	89 d5                	mov    %edx,%ebp
  802677:	89 c3                	mov    %eax,%ebx
  802679:	f7 64 24 0c          	mull   0xc(%esp)
  80267d:	39 d5                	cmp    %edx,%ebp
  80267f:	72 10                	jb     802691 <__udivdi3+0xc1>
  802681:	8b 74 24 08          	mov    0x8(%esp),%esi
  802685:	89 f9                	mov    %edi,%ecx
  802687:	d3 e6                	shl    %cl,%esi
  802689:	39 c6                	cmp    %eax,%esi
  80268b:	73 07                	jae    802694 <__udivdi3+0xc4>
  80268d:	39 d5                	cmp    %edx,%ebp
  80268f:	75 03                	jne    802694 <__udivdi3+0xc4>
  802691:	83 eb 01             	sub    $0x1,%ebx
  802694:	31 ff                	xor    %edi,%edi
  802696:	89 d8                	mov    %ebx,%eax
  802698:	89 fa                	mov    %edi,%edx
  80269a:	83 c4 1c             	add    $0x1c,%esp
  80269d:	5b                   	pop    %ebx
  80269e:	5e                   	pop    %esi
  80269f:	5f                   	pop    %edi
  8026a0:	5d                   	pop    %ebp
  8026a1:	c3                   	ret    
  8026a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026a8:	31 ff                	xor    %edi,%edi
  8026aa:	31 db                	xor    %ebx,%ebx
  8026ac:	89 d8                	mov    %ebx,%eax
  8026ae:	89 fa                	mov    %edi,%edx
  8026b0:	83 c4 1c             	add    $0x1c,%esp
  8026b3:	5b                   	pop    %ebx
  8026b4:	5e                   	pop    %esi
  8026b5:	5f                   	pop    %edi
  8026b6:	5d                   	pop    %ebp
  8026b7:	c3                   	ret    
  8026b8:	90                   	nop
  8026b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	89 d8                	mov    %ebx,%eax
  8026c2:	f7 f7                	div    %edi
  8026c4:	31 ff                	xor    %edi,%edi
  8026c6:	89 c3                	mov    %eax,%ebx
  8026c8:	89 d8                	mov    %ebx,%eax
  8026ca:	89 fa                	mov    %edi,%edx
  8026cc:	83 c4 1c             	add    $0x1c,%esp
  8026cf:	5b                   	pop    %ebx
  8026d0:	5e                   	pop    %esi
  8026d1:	5f                   	pop    %edi
  8026d2:	5d                   	pop    %ebp
  8026d3:	c3                   	ret    
  8026d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d8:	39 ce                	cmp    %ecx,%esi
  8026da:	72 0c                	jb     8026e8 <__udivdi3+0x118>
  8026dc:	31 db                	xor    %ebx,%ebx
  8026de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026e2:	0f 87 34 ff ff ff    	ja     80261c <__udivdi3+0x4c>
  8026e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026ed:	e9 2a ff ff ff       	jmp    80261c <__udivdi3+0x4c>
  8026f2:	66 90                	xchg   %ax,%ax
  8026f4:	66 90                	xchg   %ax,%ax
  8026f6:	66 90                	xchg   %ax,%ax
  8026f8:	66 90                	xchg   %ax,%ax
  8026fa:	66 90                	xchg   %ax,%ax
  8026fc:	66 90                	xchg   %ax,%ax
  8026fe:	66 90                	xchg   %ax,%ax

00802700 <__umoddi3>:
  802700:	55                   	push   %ebp
  802701:	57                   	push   %edi
  802702:	56                   	push   %esi
  802703:	53                   	push   %ebx
  802704:	83 ec 1c             	sub    $0x1c,%esp
  802707:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80270b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80270f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802713:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802717:	85 d2                	test   %edx,%edx
  802719:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80271d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802721:	89 f3                	mov    %esi,%ebx
  802723:	89 3c 24             	mov    %edi,(%esp)
  802726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80272a:	75 1c                	jne    802748 <__umoddi3+0x48>
  80272c:	39 f7                	cmp    %esi,%edi
  80272e:	76 50                	jbe    802780 <__umoddi3+0x80>
  802730:	89 c8                	mov    %ecx,%eax
  802732:	89 f2                	mov    %esi,%edx
  802734:	f7 f7                	div    %edi
  802736:	89 d0                	mov    %edx,%eax
  802738:	31 d2                	xor    %edx,%edx
  80273a:	83 c4 1c             	add    $0x1c,%esp
  80273d:	5b                   	pop    %ebx
  80273e:	5e                   	pop    %esi
  80273f:	5f                   	pop    %edi
  802740:	5d                   	pop    %ebp
  802741:	c3                   	ret    
  802742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802748:	39 f2                	cmp    %esi,%edx
  80274a:	89 d0                	mov    %edx,%eax
  80274c:	77 52                	ja     8027a0 <__umoddi3+0xa0>
  80274e:	0f bd ea             	bsr    %edx,%ebp
  802751:	83 f5 1f             	xor    $0x1f,%ebp
  802754:	75 5a                	jne    8027b0 <__umoddi3+0xb0>
  802756:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80275a:	0f 82 e0 00 00 00    	jb     802840 <__umoddi3+0x140>
  802760:	39 0c 24             	cmp    %ecx,(%esp)
  802763:	0f 86 d7 00 00 00    	jbe    802840 <__umoddi3+0x140>
  802769:	8b 44 24 08          	mov    0x8(%esp),%eax
  80276d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802771:	83 c4 1c             	add    $0x1c,%esp
  802774:	5b                   	pop    %ebx
  802775:	5e                   	pop    %esi
  802776:	5f                   	pop    %edi
  802777:	5d                   	pop    %ebp
  802778:	c3                   	ret    
  802779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802780:	85 ff                	test   %edi,%edi
  802782:	89 fd                	mov    %edi,%ebp
  802784:	75 0b                	jne    802791 <__umoddi3+0x91>
  802786:	b8 01 00 00 00       	mov    $0x1,%eax
  80278b:	31 d2                	xor    %edx,%edx
  80278d:	f7 f7                	div    %edi
  80278f:	89 c5                	mov    %eax,%ebp
  802791:	89 f0                	mov    %esi,%eax
  802793:	31 d2                	xor    %edx,%edx
  802795:	f7 f5                	div    %ebp
  802797:	89 c8                	mov    %ecx,%eax
  802799:	f7 f5                	div    %ebp
  80279b:	89 d0                	mov    %edx,%eax
  80279d:	eb 99                	jmp    802738 <__umoddi3+0x38>
  80279f:	90                   	nop
  8027a0:	89 c8                	mov    %ecx,%eax
  8027a2:	89 f2                	mov    %esi,%edx
  8027a4:	83 c4 1c             	add    $0x1c,%esp
  8027a7:	5b                   	pop    %ebx
  8027a8:	5e                   	pop    %esi
  8027a9:	5f                   	pop    %edi
  8027aa:	5d                   	pop    %ebp
  8027ab:	c3                   	ret    
  8027ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027b0:	8b 34 24             	mov    (%esp),%esi
  8027b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8027b8:	89 e9                	mov    %ebp,%ecx
  8027ba:	29 ef                	sub    %ebp,%edi
  8027bc:	d3 e0                	shl    %cl,%eax
  8027be:	89 f9                	mov    %edi,%ecx
  8027c0:	89 f2                	mov    %esi,%edx
  8027c2:	d3 ea                	shr    %cl,%edx
  8027c4:	89 e9                	mov    %ebp,%ecx
  8027c6:	09 c2                	or     %eax,%edx
  8027c8:	89 d8                	mov    %ebx,%eax
  8027ca:	89 14 24             	mov    %edx,(%esp)
  8027cd:	89 f2                	mov    %esi,%edx
  8027cf:	d3 e2                	shl    %cl,%edx
  8027d1:	89 f9                	mov    %edi,%ecx
  8027d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027db:	d3 e8                	shr    %cl,%eax
  8027dd:	89 e9                	mov    %ebp,%ecx
  8027df:	89 c6                	mov    %eax,%esi
  8027e1:	d3 e3                	shl    %cl,%ebx
  8027e3:	89 f9                	mov    %edi,%ecx
  8027e5:	89 d0                	mov    %edx,%eax
  8027e7:	d3 e8                	shr    %cl,%eax
  8027e9:	89 e9                	mov    %ebp,%ecx
  8027eb:	09 d8                	or     %ebx,%eax
  8027ed:	89 d3                	mov    %edx,%ebx
  8027ef:	89 f2                	mov    %esi,%edx
  8027f1:	f7 34 24             	divl   (%esp)
  8027f4:	89 d6                	mov    %edx,%esi
  8027f6:	d3 e3                	shl    %cl,%ebx
  8027f8:	f7 64 24 04          	mull   0x4(%esp)
  8027fc:	39 d6                	cmp    %edx,%esi
  8027fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802802:	89 d1                	mov    %edx,%ecx
  802804:	89 c3                	mov    %eax,%ebx
  802806:	72 08                	jb     802810 <__umoddi3+0x110>
  802808:	75 11                	jne    80281b <__umoddi3+0x11b>
  80280a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80280e:	73 0b                	jae    80281b <__umoddi3+0x11b>
  802810:	2b 44 24 04          	sub    0x4(%esp),%eax
  802814:	1b 14 24             	sbb    (%esp),%edx
  802817:	89 d1                	mov    %edx,%ecx
  802819:	89 c3                	mov    %eax,%ebx
  80281b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80281f:	29 da                	sub    %ebx,%edx
  802821:	19 ce                	sbb    %ecx,%esi
  802823:	89 f9                	mov    %edi,%ecx
  802825:	89 f0                	mov    %esi,%eax
  802827:	d3 e0                	shl    %cl,%eax
  802829:	89 e9                	mov    %ebp,%ecx
  80282b:	d3 ea                	shr    %cl,%edx
  80282d:	89 e9                	mov    %ebp,%ecx
  80282f:	d3 ee                	shr    %cl,%esi
  802831:	09 d0                	or     %edx,%eax
  802833:	89 f2                	mov    %esi,%edx
  802835:	83 c4 1c             	add    $0x1c,%esp
  802838:	5b                   	pop    %ebx
  802839:	5e                   	pop    %esi
  80283a:	5f                   	pop    %edi
  80283b:	5d                   	pop    %ebp
  80283c:	c3                   	ret    
  80283d:	8d 76 00             	lea    0x0(%esi),%esi
  802840:	29 f9                	sub    %edi,%ecx
  802842:	19 d6                	sbb    %edx,%esi
  802844:	89 74 24 04          	mov    %esi,0x4(%esp)
  802848:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80284c:	e9 18 ff ff ff       	jmp    802769 <__umoddi3+0x69>
