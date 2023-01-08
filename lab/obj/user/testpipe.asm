
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 e0 	movl   $0x8027e0,0x803004
  800042:	27 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 99 1b 00 00       	call   801be7 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 ec 27 80 00       	push   $0x8027ec
  80005d:	6a 0e                	push   $0xe
  80005f:	68 f5 27 80 00       	push   $0x8027f5
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 ee 0f 00 00       	call   80105c <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 05 28 80 00       	push   $0x802805
  80007a:	6a 11                	push   $0x11
  80007c:	68 f5 27 80 00       	push   $0x8027f5
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 08 40 80 00       	mov    0x804008,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 0e 28 80 00       	push   $0x80280e
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 01 13 00 00       	call   8013b3 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 2b 28 80 00       	push   $0x80282b
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 a4 14 00 00       	call   801580 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 48 28 80 00       	push   $0x802848
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 f5 27 80 00       	push   $0x8027f5
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 0c 09 00 00       	call   800a1a <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 51 28 80 00       	push   $0x802851
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 6d 28 80 00       	push   $0x80286d
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 08 40 80 00       	mov    0x804008,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 0e 28 80 00       	push   $0x80280e
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 49 12 00 00       	call   8013b3 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 08 40 80 00       	mov    0x804008,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 80 28 80 00       	push   $0x802880
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a6 07 00 00       	call   800937 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 26 14 00 00       	call   8015c9 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 84 07 00 00       	call   800937 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 9d 28 80 00       	push   $0x80289d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 f5 27 80 00       	push   $0x8027f5
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 dc 11 00 00       	call   8013b3 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 8a 1b 00 00       	call   801d6d <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 a7 	movl   $0x8028a7,0x803004
  8001ea:	28 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 ef 19 00 00       	call   801be7 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 ec 27 80 00       	push   $0x8027ec
  800207:	6a 2c                	push   $0x2c
  800209:	68 f5 27 80 00       	push   $0x8027f5
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 44 0e 00 00       	call   80105c <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 05 28 80 00       	push   $0x802805
  800224:	6a 2f                	push   $0x2f
  800226:	68 f5 27 80 00       	push   $0x8027f5
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 74 11 00 00       	call   8013b3 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 b4 28 80 00       	push   $0x8028b4
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 b6 28 80 00       	push   $0x8028b6
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 68 13 00 00       	call   8015c9 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 b8 28 80 00       	push   $0x8028b8
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 2a 11 00 00       	call   8013b3 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 1f 11 00 00       	call   8013b3 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 d1 1a 00 00       	call   801d6d <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 73 0a 00 00       	call   800d35 <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 db 10 00 00       	call   8013de <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 e7 09 00 00       	call   800cf4 <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 10 0a 00 00       	call   800d35 <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 38 29 80 00       	push   $0x802938
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 29 28 80 00 	movl   $0x802829,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 2f 09 00 00       	call   800cb7 <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 54 01 00 00       	call   800522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 d4 08 00 00       	call   800cb7 <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 ed 20 00 00       	call   802540 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 da 21 00 00       	call   802670 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 5b 29 80 00 	movsbl 0x80295b(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b1:	83 fa 01             	cmp    $0x1,%edx
  8004b4:	7e 0e                	jle    8004c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	8b 52 04             	mov    0x4(%edx),%edx
  8004c2:	eb 22                	jmp    8004e6 <getuint+0x38>
	else if (lflag)
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 10                	je     8004d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	eb 0e                	jmp    8004e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e6:	5d                   	pop    %ebp
  8004e7:	c3                   	ret    

008004e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f7:	73 0a                	jae    800503 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	88 02                	mov    %al,(%edx)
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050e:	50                   	push   %eax
  80050f:	ff 75 10             	pushl  0x10(%ebp)
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 05 00 00 00       	call   800522 <vprintfmt>
	va_end(ap);
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 2c             	sub    $0x2c,%esp
  80052b:	8b 75 08             	mov    0x8(%ebp),%esi
  80052e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800531:	8b 7d 10             	mov    0x10(%ebp),%edi
  800534:	eb 12                	jmp    800548 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 89 03 00 00    	je     8008c7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	50                   	push   %eax
  800543:	ff d6                	call   *%esi
  800545:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800548:	83 c7 01             	add    $0x1,%edi
  80054b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e2                	jne    800536 <vprintfmt+0x14>
  800554:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800558:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800566:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056d:	ba 00 00 00 00       	mov    $0x0,%edx
  800572:	eb 07                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800577:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8d 47 01             	lea    0x1(%edi),%eax
  80057e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800581:	0f b6 07             	movzbl (%edi),%eax
  800584:	0f b6 c8             	movzbl %al,%ecx
  800587:	83 e8 23             	sub    $0x23,%eax
  80058a:	3c 55                	cmp    $0x55,%al
  80058c:	0f 87 1a 03 00 00    	ja     8008ac <vprintfmt+0x38a>
  800592:	0f b6 c0             	movzbl %al,%eax
  800595:	ff 24 85 a0 2a 80 00 	jmp    *0x802aa0(,%eax,4)
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a3:	eb d6                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ba:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bd:	83 fa 09             	cmp    $0x9,%edx
  8005c0:	77 39                	ja     8005fb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c5:	eb e9                	jmp    8005b0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d8:	eb 27                	jmp    800601 <vprintfmt+0xdf>
  8005da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	0f 49 c8             	cmovns %eax,%ecx
  8005e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ed:	eb 8c                	jmp    80057b <vprintfmt+0x59>
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f9:	eb 80                	jmp    80057b <vprintfmt+0x59>
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800605:	0f 89 70 ff ff ff    	jns    80057b <vprintfmt+0x59>
				width = precision, precision = -1;
  80060b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800611:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800618:	e9 5e ff ff ff       	jmp    80057b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800623:	e9 53 ff ff ff       	jmp    80057b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	ff 30                	pushl  (%eax)
  800637:	ff d6                	call   *%esi
			break;
  800639:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063f:	e9 04 ff ff ff       	jmp    800548 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	99                   	cltd   
  800650:	31 d0                	xor    %edx,%eax
  800652:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800654:	83 f8 0f             	cmp    $0xf,%eax
  800657:	7f 0b                	jg     800664 <vprintfmt+0x142>
  800659:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 73 29 80 00       	push   $0x802973
  80066a:	53                   	push   %ebx
  80066b:	56                   	push   %esi
  80066c:	e8 94 fe ff ff       	call   800505 <printfmt>
  800671:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800677:	e9 cc fe ff ff       	jmp    800548 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067c:	52                   	push   %edx
  80067d:	68 f1 2d 80 00       	push   $0x802df1
  800682:	53                   	push   %ebx
  800683:	56                   	push   %esi
  800684:	e8 7c fe ff ff       	call   800505 <printfmt>
  800689:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068f:	e9 b4 fe ff ff       	jmp    800548 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069f:	85 ff                	test   %edi,%edi
  8006a1:	b8 6c 29 80 00       	mov    $0x80296c,%eax
  8006a6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ad:	0f 8e 94 00 00 00    	jle    800747 <vprintfmt+0x225>
  8006b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b7:	0f 84 98 00 00 00    	je     800755 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c3:	57                   	push   %edi
  8006c4:	e8 86 02 00 00       	call   80094f <strnlen>
  8006c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cc:	29 c1                	sub    %eax,%ecx
  8006ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006de:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	eb 0f                	jmp    8006f1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 ff                	test   %edi,%edi
  8006f3:	7f ed                	jg     8006e2 <vprintfmt+0x1c0>
  8006f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800702:	0f 49 c1             	cmovns %ecx,%eax
  800705:	29 c1                	sub    %eax,%ecx
  800707:	89 75 08             	mov    %esi,0x8(%ebp)
  80070a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800710:	89 cb                	mov    %ecx,%ebx
  800712:	eb 4d                	jmp    800761 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800714:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800718:	74 1b                	je     800735 <vprintfmt+0x213>
  80071a:	0f be c0             	movsbl %al,%eax
  80071d:	83 e8 20             	sub    $0x20,%eax
  800720:	83 f8 5e             	cmp    $0x5e,%eax
  800723:	76 10                	jbe    800735 <vprintfmt+0x213>
					putch('?', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	6a 3f                	push   $0x3f
  80072d:	ff 55 08             	call   *0x8(%ebp)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	52                   	push   %edx
  80073c:	ff 55 08             	call   *0x8(%ebp)
  80073f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800742:	83 eb 01             	sub    $0x1,%ebx
  800745:	eb 1a                	jmp    800761 <vprintfmt+0x23f>
  800747:	89 75 08             	mov    %esi,0x8(%ebp)
  80074a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800750:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800753:	eb 0c                	jmp    800761 <vprintfmt+0x23f>
  800755:	89 75 08             	mov    %esi,0x8(%ebp)
  800758:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800761:	83 c7 01             	add    $0x1,%edi
  800764:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800768:	0f be d0             	movsbl %al,%edx
  80076b:	85 d2                	test   %edx,%edx
  80076d:	74 23                	je     800792 <vprintfmt+0x270>
  80076f:	85 f6                	test   %esi,%esi
  800771:	78 a1                	js     800714 <vprintfmt+0x1f2>
  800773:	83 ee 01             	sub    $0x1,%esi
  800776:	79 9c                	jns    800714 <vprintfmt+0x1f2>
  800778:	89 df                	mov    %ebx,%edi
  80077a:	8b 75 08             	mov    0x8(%ebp),%esi
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800780:	eb 18                	jmp    80079a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	53                   	push   %ebx
  800786:	6a 20                	push   $0x20
  800788:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078a:	83 ef 01             	sub    $0x1,%edi
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	eb 08                	jmp    80079a <vprintfmt+0x278>
  800792:	89 df                	mov    %ebx,%edi
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	85 ff                	test   %edi,%edi
  80079c:	7f e4                	jg     800782 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a1:	e9 a2 fd ff ff       	jmp    800548 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a6:	83 fa 01             	cmp    $0x1,%edx
  8007a9:	7e 16                	jle    8007c1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 08             	lea    0x8(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 50 04             	mov    0x4(%eax),%edx
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bf:	eb 32                	jmp    8007f3 <vprintfmt+0x2d1>
	else if (lflag)
  8007c1:	85 d2                	test   %edx,%edx
  8007c3:	74 18                	je     8007dd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 04             	lea    0x4(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 00                	mov    (%eax),%eax
  8007d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d3:	89 c1                	mov    %eax,%ecx
  8007d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007db:	eb 16                	jmp    8007f3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 c1                	mov    %eax,%ecx
  8007ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800802:	79 74                	jns    800878 <vprintfmt+0x356>
				putch('-', putdat);
  800804:	83 ec 08             	sub    $0x8,%esp
  800807:	53                   	push   %ebx
  800808:	6a 2d                	push   $0x2d
  80080a:	ff d6                	call   *%esi
				num = -(long long) num;
  80080c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800812:	f7 d8                	neg    %eax
  800814:	83 d2 00             	adc    $0x0,%edx
  800817:	f7 da                	neg    %edx
  800819:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800821:	eb 55                	jmp    800878 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	e8 83 fc ff ff       	call   8004ae <getuint>
			base = 10;
  80082b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800830:	eb 46                	jmp    800878 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800832:	8d 45 14             	lea    0x14(%ebp),%eax
  800835:	e8 74 fc ff ff       	call   8004ae <getuint>
			base = 8;
  80083a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80083f:	eb 37                	jmp    800878 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	53                   	push   %ebx
  800845:	6a 30                	push   $0x30
  800847:	ff d6                	call   *%esi
			putch('x', putdat);
  800849:	83 c4 08             	add    $0x8,%esp
  80084c:	53                   	push   %ebx
  80084d:	6a 78                	push   $0x78
  80084f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8d 50 04             	lea    0x4(%eax),%edx
  800857:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085a:	8b 00                	mov    (%eax),%eax
  80085c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800861:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800864:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800869:	eb 0d                	jmp    800878 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
  80086e:	e8 3b fc ff ff       	call   8004ae <getuint>
			base = 16;
  800873:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800878:	83 ec 0c             	sub    $0xc,%esp
  80087b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80087f:	57                   	push   %edi
  800880:	ff 75 e0             	pushl  -0x20(%ebp)
  800883:	51                   	push   %ecx
  800884:	52                   	push   %edx
  800885:	50                   	push   %eax
  800886:	89 da                	mov    %ebx,%edx
  800888:	89 f0                	mov    %esi,%eax
  80088a:	e8 70 fb ff ff       	call   8003ff <printnum>
			break;
  80088f:	83 c4 20             	add    $0x20,%esp
  800892:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800895:	e9 ae fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	53                   	push   %ebx
  80089e:	51                   	push   %ecx
  80089f:	ff d6                	call   *%esi
			break;
  8008a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a7:	e9 9c fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	6a 25                	push   $0x25
  8008b2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 03                	jmp    8008bc <vprintfmt+0x39a>
  8008b9:	83 ef 01             	sub    $0x1,%edi
  8008bc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c0:	75 f7                	jne    8008b9 <vprintfmt+0x397>
  8008c2:	e9 81 fc ff ff       	jmp    800548 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	83 ec 18             	sub    $0x18,%esp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ec:	85 c0                	test   %eax,%eax
  8008ee:	74 26                	je     800916 <vsnprintf+0x47>
  8008f0:	85 d2                	test   %edx,%edx
  8008f2:	7e 22                	jle    800916 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f4:	ff 75 14             	pushl  0x14(%ebp)
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fd:	50                   	push   %eax
  8008fe:	68 e8 04 80 00       	push   $0x8004e8
  800903:	e8 1a fc ff ff       	call   800522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800908:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	eb 05                	jmp    80091b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800916:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800923:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800926:	50                   	push   %eax
  800927:	ff 75 10             	pushl  0x10(%ebp)
  80092a:	ff 75 0c             	pushl  0xc(%ebp)
  80092d:	ff 75 08             	pushl  0x8(%ebp)
  800930:	e8 9a ff ff ff       	call   8008cf <vsnprintf>
	va_end(ap);

	return rc;
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
  800942:	eb 03                	jmp    800947 <strlen+0x10>
		n++;
  800944:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800947:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80094b:	75 f7                	jne    800944 <strlen+0xd>
		n++;
	return n;
}
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800958:	ba 00 00 00 00       	mov    $0x0,%edx
  80095d:	eb 03                	jmp    800962 <strnlen+0x13>
		n++;
  80095f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800962:	39 c2                	cmp    %eax,%edx
  800964:	74 08                	je     80096e <strnlen+0x1f>
  800966:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096a:	75 f3                	jne    80095f <strnlen+0x10>
  80096c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	83 c1 01             	add    $0x1,%ecx
  800982:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800986:	88 5a ff             	mov    %bl,-0x1(%edx)
  800989:	84 db                	test   %bl,%bl
  80098b:	75 ef                	jne    80097c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098d:	5b                   	pop    %ebx
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800997:	53                   	push   %ebx
  800998:	e8 9a ff ff ff       	call   800937 <strlen>
  80099d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a0:	ff 75 0c             	pushl  0xc(%ebp)
  8009a3:	01 d8                	add    %ebx,%eax
  8009a5:	50                   	push   %eax
  8009a6:	e8 c5 ff ff ff       	call   800970 <strcpy>
	return dst;
}
  8009ab:	89 d8                	mov    %ebx,%eax
  8009ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bd:	89 f3                	mov    %esi,%ebx
  8009bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c2:	89 f2                	mov    %esi,%edx
  8009c4:	eb 0f                	jmp    8009d5 <strncpy+0x23>
		*dst++ = *src;
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	0f b6 01             	movzbl (%ecx),%eax
  8009cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d5:	39 da                	cmp    %ebx,%edx
  8009d7:	75 ed                	jne    8009c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d9:	89 f0                	mov    %esi,%eax
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ed:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ef:	85 d2                	test   %edx,%edx
  8009f1:	74 21                	je     800a14 <strlcpy+0x35>
  8009f3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f7:	89 f2                	mov    %esi,%edx
  8009f9:	eb 09                	jmp    800a04 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a04:	39 c2                	cmp    %eax,%edx
  800a06:	74 09                	je     800a11 <strlcpy+0x32>
  800a08:	0f b6 19             	movzbl (%ecx),%ebx
  800a0b:	84 db                	test   %bl,%bl
  800a0d:	75 ec                	jne    8009fb <strlcpy+0x1c>
  800a0f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a11:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a14:	29 f0                	sub    %esi,%eax
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a23:	eb 06                	jmp    800a2b <strcmp+0x11>
		p++, q++;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2b:	0f b6 01             	movzbl (%ecx),%eax
  800a2e:	84 c0                	test   %al,%al
  800a30:	74 04                	je     800a36 <strcmp+0x1c>
  800a32:	3a 02                	cmp    (%edx),%al
  800a34:	74 ef                	je     800a25 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a36:	0f b6 c0             	movzbl %al,%eax
  800a39:	0f b6 12             	movzbl (%edx),%edx
  800a3c:	29 d0                	sub    %edx,%eax
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4a:	89 c3                	mov    %eax,%ebx
  800a4c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a4f:	eb 06                	jmp    800a57 <strncmp+0x17>
		n--, p++, q++;
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a57:	39 d8                	cmp    %ebx,%eax
  800a59:	74 15                	je     800a70 <strncmp+0x30>
  800a5b:	0f b6 08             	movzbl (%eax),%ecx
  800a5e:	84 c9                	test   %cl,%cl
  800a60:	74 04                	je     800a66 <strncmp+0x26>
  800a62:	3a 0a                	cmp    (%edx),%cl
  800a64:	74 eb                	je     800a51 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a66:	0f b6 00             	movzbl (%eax),%eax
  800a69:	0f b6 12             	movzbl (%edx),%edx
  800a6c:	29 d0                	sub    %edx,%eax
  800a6e:	eb 05                	jmp    800a75 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a75:	5b                   	pop    %ebx
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a82:	eb 07                	jmp    800a8b <strchr+0x13>
		if (*s == c)
  800a84:	38 ca                	cmp    %cl,%dl
  800a86:	74 0f                	je     800a97 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a88:	83 c0 01             	add    $0x1,%eax
  800a8b:	0f b6 10             	movzbl (%eax),%edx
  800a8e:	84 d2                	test   %dl,%dl
  800a90:	75 f2                	jne    800a84 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa3:	eb 03                	jmp    800aa8 <strfind+0xf>
  800aa5:	83 c0 01             	add    $0x1,%eax
  800aa8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aab:	38 ca                	cmp    %cl,%dl
  800aad:	74 04                	je     800ab3 <strfind+0x1a>
  800aaf:	84 d2                	test   %dl,%dl
  800ab1:	75 f2                	jne    800aa5 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac1:	85 c9                	test   %ecx,%ecx
  800ac3:	74 36                	je     800afb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acb:	75 28                	jne    800af5 <memset+0x40>
  800acd:	f6 c1 03             	test   $0x3,%cl
  800ad0:	75 23                	jne    800af5 <memset+0x40>
		c &= 0xFF;
  800ad2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	c1 e3 08             	shl    $0x8,%ebx
  800adb:	89 d6                	mov    %edx,%esi
  800add:	c1 e6 18             	shl    $0x18,%esi
  800ae0:	89 d0                	mov    %edx,%eax
  800ae2:	c1 e0 10             	shl    $0x10,%eax
  800ae5:	09 f0                	or     %esi,%eax
  800ae7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ae9:	89 d8                	mov    %ebx,%eax
  800aeb:	09 d0                	or     %edx,%eax
  800aed:	c1 e9 02             	shr    $0x2,%ecx
  800af0:	fc                   	cld    
  800af1:	f3 ab                	rep stos %eax,%es:(%edi)
  800af3:	eb 06                	jmp    800afb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af8:	fc                   	cld    
  800af9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afb:	89 f8                	mov    %edi,%eax
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b10:	39 c6                	cmp    %eax,%esi
  800b12:	73 35                	jae    800b49 <memmove+0x47>
  800b14:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b17:	39 d0                	cmp    %edx,%eax
  800b19:	73 2e                	jae    800b49 <memmove+0x47>
		s += n;
		d += n;
  800b1b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	09 fe                	or     %edi,%esi
  800b22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b28:	75 13                	jne    800b3d <memmove+0x3b>
  800b2a:	f6 c1 03             	test   $0x3,%cl
  800b2d:	75 0e                	jne    800b3d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b2f:	83 ef 04             	sub    $0x4,%edi
  800b32:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b35:	c1 e9 02             	shr    $0x2,%ecx
  800b38:	fd                   	std    
  800b39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3b:	eb 09                	jmp    800b46 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3d:	83 ef 01             	sub    $0x1,%edi
  800b40:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b43:	fd                   	std    
  800b44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b46:	fc                   	cld    
  800b47:	eb 1d                	jmp    800b66 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b49:	89 f2                	mov    %esi,%edx
  800b4b:	09 c2                	or     %eax,%edx
  800b4d:	f6 c2 03             	test   $0x3,%dl
  800b50:	75 0f                	jne    800b61 <memmove+0x5f>
  800b52:	f6 c1 03             	test   $0x3,%cl
  800b55:	75 0a                	jne    800b61 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b57:	c1 e9 02             	shr    $0x2,%ecx
  800b5a:	89 c7                	mov    %eax,%edi
  800b5c:	fc                   	cld    
  800b5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5f:	eb 05                	jmp    800b66 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	fc                   	cld    
  800b64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6d:	ff 75 10             	pushl  0x10(%ebp)
  800b70:	ff 75 0c             	pushl  0xc(%ebp)
  800b73:	ff 75 08             	pushl  0x8(%ebp)
  800b76:	e8 87 ff ff ff       	call   800b02 <memmove>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b88:	89 c6                	mov    %eax,%esi
  800b8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8d:	eb 1a                	jmp    800ba9 <memcmp+0x2c>
		if (*s1 != *s2)
  800b8f:	0f b6 08             	movzbl (%eax),%ecx
  800b92:	0f b6 1a             	movzbl (%edx),%ebx
  800b95:	38 d9                	cmp    %bl,%cl
  800b97:	74 0a                	je     800ba3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b99:	0f b6 c1             	movzbl %cl,%eax
  800b9c:	0f b6 db             	movzbl %bl,%ebx
  800b9f:	29 d8                	sub    %ebx,%eax
  800ba1:	eb 0f                	jmp    800bb2 <memcmp+0x35>
		s1++, s2++;
  800ba3:	83 c0 01             	add    $0x1,%eax
  800ba6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba9:	39 f0                	cmp    %esi,%eax
  800bab:	75 e2                	jne    800b8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	53                   	push   %ebx
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bbd:	89 c1                	mov    %eax,%ecx
  800bbf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc6:	eb 0a                	jmp    800bd2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc8:	0f b6 10             	movzbl (%eax),%edx
  800bcb:	39 da                	cmp    %ebx,%edx
  800bcd:	74 07                	je     800bd6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcf:	83 c0 01             	add    $0x1,%eax
  800bd2:	39 c8                	cmp    %ecx,%eax
  800bd4:	72 f2                	jb     800bc8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be5:	eb 03                	jmp    800bea <strtol+0x11>
		s++;
  800be7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	0f b6 01             	movzbl (%ecx),%eax
  800bed:	3c 20                	cmp    $0x20,%al
  800bef:	74 f6                	je     800be7 <strtol+0xe>
  800bf1:	3c 09                	cmp    $0x9,%al
  800bf3:	74 f2                	je     800be7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf5:	3c 2b                	cmp    $0x2b,%al
  800bf7:	75 0a                	jne    800c03 <strtol+0x2a>
		s++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bfc:	bf 00 00 00 00       	mov    $0x0,%edi
  800c01:	eb 11                	jmp    800c14 <strtol+0x3b>
  800c03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c08:	3c 2d                	cmp    $0x2d,%al
  800c0a:	75 08                	jne    800c14 <strtol+0x3b>
		s++, neg = 1;
  800c0c:	83 c1 01             	add    $0x1,%ecx
  800c0f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1a:	75 15                	jne    800c31 <strtol+0x58>
  800c1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1f:	75 10                	jne    800c31 <strtol+0x58>
  800c21:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c25:	75 7c                	jne    800ca3 <strtol+0xca>
		s += 2, base = 16;
  800c27:	83 c1 02             	add    $0x2,%ecx
  800c2a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c2f:	eb 16                	jmp    800c47 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c31:	85 db                	test   %ebx,%ebx
  800c33:	75 12                	jne    800c47 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c35:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3d:	75 08                	jne    800c47 <strtol+0x6e>
		s++, base = 8;
  800c3f:	83 c1 01             	add    $0x1,%ecx
  800c42:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c47:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c4f:	0f b6 11             	movzbl (%ecx),%edx
  800c52:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c55:	89 f3                	mov    %esi,%ebx
  800c57:	80 fb 09             	cmp    $0x9,%bl
  800c5a:	77 08                	ja     800c64 <strtol+0x8b>
			dig = *s - '0';
  800c5c:	0f be d2             	movsbl %dl,%edx
  800c5f:	83 ea 30             	sub    $0x30,%edx
  800c62:	eb 22                	jmp    800c86 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c64:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 19             	cmp    $0x19,%bl
  800c6c:	77 08                	ja     800c76 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 57             	sub    $0x57,%edx
  800c74:	eb 10                	jmp    800c86 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c76:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 16                	ja     800c96 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c86:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c89:	7d 0b                	jge    800c96 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c8b:	83 c1 01             	add    $0x1,%ecx
  800c8e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c92:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c94:	eb b9                	jmp    800c4f <strtol+0x76>

	if (endptr)
  800c96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9a:	74 0d                	je     800ca9 <strtol+0xd0>
		*endptr = (char *) s;
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	89 0e                	mov    %ecx,(%esi)
  800ca1:	eb 06                	jmp    800ca9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca3:	85 db                	test   %ebx,%ebx
  800ca5:	74 98                	je     800c3f <strtol+0x66>
  800ca7:	eb 9e                	jmp    800c47 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	f7 da                	neg    %edx
  800cad:	85 ff                	test   %edi,%edi
  800caf:	0f 45 c2             	cmovne %edx,%eax
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 c3                	mov    %eax,%ebx
  800cca:	89 c7                	mov    %eax,%edi
  800ccc:	89 c6                	mov    %eax,%esi
  800cce:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	89 d3                	mov    %edx,%ebx
  800ce9:	89 d7                	mov    %edx,%edi
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d02:	b8 03 00 00 00       	mov    $0x3,%eax
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 cb                	mov    %ecx,%ebx
  800d0c:	89 cf                	mov    %ecx,%edi
  800d0e:	89 ce                	mov    %ecx,%esi
  800d10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d12:	85 c0                	test   %eax,%eax
  800d14:	7e 17                	jle    800d2d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d16:	83 ec 0c             	sub    $0xc,%esp
  800d19:	50                   	push   %eax
  800d1a:	6a 03                	push   $0x3
  800d1c:	68 5f 2c 80 00       	push   $0x802c5f
  800d21:	6a 23                	push   $0x23
  800d23:	68 7c 2c 80 00       	push   $0x802c7c
  800d28:	e8 e5 f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 02 00 00 00       	mov    $0x2,%eax
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	89 d7                	mov    %edx,%edi
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_yield>:

void
sys_yield(void)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d64:	89 d1                	mov    %edx,%ecx
  800d66:	89 d3                	mov    %edx,%ebx
  800d68:	89 d7                	mov    %edx,%edi
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	be 00 00 00 00       	mov    $0x0,%esi
  800d81:	b8 04 00 00 00       	mov    $0x4,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8f:	89 f7                	mov    %esi,%edi
  800d91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 17                	jle    800dae <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 04                	push   $0x4
  800d9d:	68 5f 2c 80 00       	push   $0x802c5f
  800da2:	6a 23                	push   $0x23
  800da4:	68 7c 2c 80 00       	push   $0x802c7c
  800da9:	e8 64 f5 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd0:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 17                	jle    800df0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	6a 05                	push   $0x5
  800ddf:	68 5f 2c 80 00       	push   $0x802c5f
  800de4:	6a 23                	push   $0x23
  800de6:	68 7c 2c 80 00       	push   $0x802c7c
  800deb:	e8 22 f5 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e06:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	89 de                	mov    %ebx,%esi
  800e15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 17                	jle    800e32 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	50                   	push   %eax
  800e1f:	6a 06                	push   $0x6
  800e21:	68 5f 2c 80 00       	push   $0x802c5f
  800e26:	6a 23                	push   $0x23
  800e28:	68 7c 2c 80 00       	push   $0x802c7c
  800e2d:	e8 e0 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	b8 08 00 00 00       	mov    $0x8,%eax
  800e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 df                	mov    %ebx,%edi
  800e55:	89 de                	mov    %ebx,%esi
  800e57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	7e 17                	jle    800e74 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	50                   	push   %eax
  800e61:	6a 08                	push   $0x8
  800e63:	68 5f 2c 80 00       	push   $0x802c5f
  800e68:	6a 23                	push   $0x23
  800e6a:	68 7c 2c 80 00       	push   $0x802c7c
  800e6f:	e8 9e f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	57                   	push   %edi
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
  800e82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	89 df                	mov    %ebx,%edi
  800e97:	89 de                	mov    %ebx,%esi
  800e99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	7e 17                	jle    800eb6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9f:	83 ec 0c             	sub    $0xc,%esp
  800ea2:	50                   	push   %eax
  800ea3:	6a 09                	push   $0x9
  800ea5:	68 5f 2c 80 00       	push   $0x802c5f
  800eaa:	6a 23                	push   $0x23
  800eac:	68 7c 2c 80 00       	push   $0x802c7c
  800eb1:	e8 5c f4 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed7:	89 df                	mov    %ebx,%edi
  800ed9:	89 de                	mov    %ebx,%esi
  800edb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800edd:	85 c0                	test   %eax,%eax
  800edf:	7e 17                	jle    800ef8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee1:	83 ec 0c             	sub    $0xc,%esp
  800ee4:	50                   	push   %eax
  800ee5:	6a 0a                	push   $0xa
  800ee7:	68 5f 2c 80 00       	push   $0x802c5f
  800eec:	6a 23                	push   $0x23
  800eee:	68 7c 2c 80 00       	push   $0x802c7c
  800ef3:	e8 1a f4 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	be 00 00 00 00       	mov    $0x0,%esi
  800f0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f19:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	89 cb                	mov    %ecx,%ebx
  800f3b:	89 cf                	mov    %ecx,%edi
  800f3d:	89 ce                	mov    %ecx,%esi
  800f3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 17                	jle    800f5c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f45:	83 ec 0c             	sub    $0xc,%esp
  800f48:	50                   	push   %eax
  800f49:	6a 0d                	push   $0xd
  800f4b:	68 5f 2c 80 00       	push   $0x802c5f
  800f50:	6a 23                	push   $0x23
  800f52:	68 7c 2c 80 00       	push   $0x802c7c
  800f57:	e8 b6 f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f74:	89 d1                	mov    %edx,%ecx
  800f76:	89 d3                	mov    %edx,%ebx
  800f78:	89 d7                	mov    %edx,%edi
  800f7a:	89 d6                	mov    %edx,%esi
  800f7c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f8b:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800f8d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f91:	75 25                	jne    800fb8 <pgfault+0x35>
  800f93:	89 d8                	mov    %ebx,%eax
  800f95:	c1 e8 0c             	shr    $0xc,%eax
  800f98:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9f:	f6 c4 08             	test   $0x8,%ah
  800fa2:	75 14                	jne    800fb8 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	68 8c 2c 80 00       	push   $0x802c8c
  800fac:	6a 1e                	push   $0x1e
  800fae:	68 20 2d 80 00       	push   $0x802d20
  800fb3:	e8 5a f3 ff ff       	call   800312 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800fb8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800fbe:	e8 72 fd ff ff       	call   800d35 <sys_getenvid>
  800fc3:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800fc5:	83 ec 04             	sub    $0x4,%esp
  800fc8:	6a 07                	push   $0x7
  800fca:	68 00 f0 7f 00       	push   $0x7ff000
  800fcf:	50                   	push   %eax
  800fd0:	e8 9e fd ff ff       	call   800d73 <sys_page_alloc>
	if (r < 0)
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	79 12                	jns    800fee <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800fdc:	50                   	push   %eax
  800fdd:	68 b8 2c 80 00       	push   $0x802cb8
  800fe2:	6a 33                	push   $0x33
  800fe4:	68 20 2d 80 00       	push   $0x802d20
  800fe9:	e8 24 f3 ff ff       	call   800312 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 00 10 00 00       	push   $0x1000
  800ff6:	53                   	push   %ebx
  800ff7:	68 00 f0 7f 00       	push   $0x7ff000
  800ffc:	e8 69 fb ff ff       	call   800b6a <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  801001:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801008:	53                   	push   %ebx
  801009:	56                   	push   %esi
  80100a:	68 00 f0 7f 00       	push   $0x7ff000
  80100f:	56                   	push   %esi
  801010:	e8 a1 fd ff ff       	call   800db6 <sys_page_map>
	if (r < 0)
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	79 12                	jns    80102e <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  80101c:	50                   	push   %eax
  80101d:	68 dc 2c 80 00       	push   $0x802cdc
  801022:	6a 3b                	push   $0x3b
  801024:	68 20 2d 80 00       	push   $0x802d20
  801029:	e8 e4 f2 ff ff       	call   800312 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	68 00 f0 7f 00       	push   $0x7ff000
  801036:	56                   	push   %esi
  801037:	e8 bc fd ff ff       	call   800df8 <sys_page_unmap>
	if (r < 0)
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	79 12                	jns    801055 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  801043:	50                   	push   %eax
  801044:	68 00 2d 80 00       	push   $0x802d00
  801049:	6a 40                	push   $0x40
  80104b:	68 20 2d 80 00       	push   $0x802d20
  801050:	e8 bd f2 ff ff       	call   800312 <_panic>
}
  801055:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	57                   	push   %edi
  801060:	56                   	push   %esi
  801061:	53                   	push   %ebx
  801062:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  801065:	68 83 0f 80 00       	push   $0x800f83
  80106a:	e8 37 13 00 00       	call   8023a6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80106f:	b8 07 00 00 00       	mov    $0x7,%eax
  801074:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	85 c0                	test   %eax,%eax
  80107b:	0f 88 64 01 00 00    	js     8011e5 <fork+0x189>
  801081:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801086:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80108b:	85 c0                	test   %eax,%eax
  80108d:	75 21                	jne    8010b0 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  80108f:	e8 a1 fc ff ff       	call   800d35 <sys_getenvid>
  801094:	25 ff 03 00 00       	and    $0x3ff,%eax
  801099:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80109c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a1:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  8010a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ab:	e9 3f 01 00 00       	jmp    8011ef <fork+0x193>
  8010b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010b3:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8010b5:	89 d8                	mov    %ebx,%eax
  8010b7:	c1 e8 16             	shr    $0x16,%eax
  8010ba:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010c1:	a8 01                	test   $0x1,%al
  8010c3:	0f 84 bd 00 00 00    	je     801186 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  8010c9:	89 d8                	mov    %ebx,%eax
  8010cb:	c1 e8 0c             	shr    $0xc,%eax
  8010ce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d5:	f6 c2 01             	test   $0x1,%dl
  8010d8:	0f 84 a8 00 00 00    	je     801186 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  8010de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e5:	a8 04                	test   $0x4,%al
  8010e7:	0f 84 99 00 00 00    	je     801186 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  8010ed:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010f4:	f6 c4 04             	test   $0x4,%ah
  8010f7:	74 17                	je     801110 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  8010f9:	83 ec 0c             	sub    $0xc,%esp
  8010fc:	68 07 0e 00 00       	push   $0xe07
  801101:	53                   	push   %ebx
  801102:	57                   	push   %edi
  801103:	53                   	push   %ebx
  801104:	6a 00                	push   $0x0
  801106:	e8 ab fc ff ff       	call   800db6 <sys_page_map>
  80110b:	83 c4 20             	add    $0x20,%esp
  80110e:	eb 76                	jmp    801186 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801110:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801117:	a8 02                	test   $0x2,%al
  801119:	75 0c                	jne    801127 <fork+0xcb>
  80111b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801122:	f6 c4 08             	test   $0x8,%ah
  801125:	74 3f                	je     801166 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	68 05 08 00 00       	push   $0x805
  80112f:	53                   	push   %ebx
  801130:	57                   	push   %edi
  801131:	53                   	push   %ebx
  801132:	6a 00                	push   $0x0
  801134:	e8 7d fc ff ff       	call   800db6 <sys_page_map>
		if (r < 0)
  801139:	83 c4 20             	add    $0x20,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	0f 88 a5 00 00 00    	js     8011e9 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	68 05 08 00 00       	push   $0x805
  80114c:	53                   	push   %ebx
  80114d:	6a 00                	push   $0x0
  80114f:	53                   	push   %ebx
  801150:	6a 00                	push   $0x0
  801152:	e8 5f fc ff ff       	call   800db6 <sys_page_map>
  801157:	83 c4 20             	add    $0x20,%esp
  80115a:	85 c0                	test   %eax,%eax
  80115c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801161:	0f 4f c1             	cmovg  %ecx,%eax
  801164:	eb 1c                	jmp    801182 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801166:	83 ec 0c             	sub    $0xc,%esp
  801169:	6a 05                	push   $0x5
  80116b:	53                   	push   %ebx
  80116c:	57                   	push   %edi
  80116d:	53                   	push   %ebx
  80116e:	6a 00                	push   $0x0
  801170:	e8 41 fc ff ff       	call   800db6 <sys_page_map>
  801175:	83 c4 20             	add    $0x20,%esp
  801178:	85 c0                	test   %eax,%eax
  80117a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80117f:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801182:	85 c0                	test   %eax,%eax
  801184:	78 67                	js     8011ed <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801186:	83 c6 01             	add    $0x1,%esi
  801189:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80118f:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801195:	0f 85 1a ff ff ff    	jne    8010b5 <fork+0x59>
  80119b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	6a 07                	push   $0x7
  8011a3:	68 00 f0 bf ee       	push   $0xeebff000
  8011a8:	57                   	push   %edi
  8011a9:	e8 c5 fb ff ff       	call   800d73 <sys_page_alloc>
	if (r < 0)
  8011ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8011b1:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 38                	js     8011ef <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011b7:	83 ec 08             	sub    $0x8,%esp
  8011ba:	68 ed 23 80 00       	push   $0x8023ed
  8011bf:	57                   	push   %edi
  8011c0:	e8 f9 fc ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
	if (r < 0)
  8011c5:	83 c4 10             	add    $0x10,%esp
		return r;
  8011c8:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 21                	js     8011ef <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	6a 02                	push   $0x2
  8011d3:	57                   	push   %edi
  8011d4:	e8 61 fc ff ff       	call   800e3a <sys_env_set_status>
	if (r < 0)
  8011d9:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	0f 48 f8             	cmovs  %eax,%edi
  8011e1:	89 fa                	mov    %edi,%edx
  8011e3:	eb 0a                	jmp    8011ef <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8011e5:	89 c2                	mov    %eax,%edx
  8011e7:	eb 06                	jmp    8011ef <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	eb 02                	jmp    8011ef <fork+0x193>
  8011ed:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8011ef:	89 d0                	mov    %edx,%eax
  8011f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <sfork>:

// Challenge!
int
sfork(void)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011ff:	68 2b 2d 80 00       	push   $0x802d2b
  801204:	68 c9 00 00 00       	push   $0xc9
  801209:	68 20 2d 80 00       	push   $0x802d20
  80120e:	e8 ff f0 ff ff       	call   800312 <_panic>

00801213 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801216:	8b 45 08             	mov    0x8(%ebp),%eax
  801219:	05 00 00 00 30       	add    $0x30000000,%eax
  80121e:	c1 e8 0c             	shr    $0xc,%eax
}
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	05 00 00 00 30       	add    $0x30000000,%eax
  80122e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801233:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801240:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801245:	89 c2                	mov    %eax,%edx
  801247:	c1 ea 16             	shr    $0x16,%edx
  80124a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801251:	f6 c2 01             	test   $0x1,%dl
  801254:	74 11                	je     801267 <fd_alloc+0x2d>
  801256:	89 c2                	mov    %eax,%edx
  801258:	c1 ea 0c             	shr    $0xc,%edx
  80125b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801262:	f6 c2 01             	test   $0x1,%dl
  801265:	75 09                	jne    801270 <fd_alloc+0x36>
			*fd_store = fd;
  801267:	89 01                	mov    %eax,(%ecx)
			return 0;
  801269:	b8 00 00 00 00       	mov    $0x0,%eax
  80126e:	eb 17                	jmp    801287 <fd_alloc+0x4d>
  801270:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801275:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80127a:	75 c9                	jne    801245 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80127c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801282:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80128f:	83 f8 1f             	cmp    $0x1f,%eax
  801292:	77 36                	ja     8012ca <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801294:	c1 e0 0c             	shl    $0xc,%eax
  801297:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80129c:	89 c2                	mov    %eax,%edx
  80129e:	c1 ea 16             	shr    $0x16,%edx
  8012a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a8:	f6 c2 01             	test   $0x1,%dl
  8012ab:	74 24                	je     8012d1 <fd_lookup+0x48>
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	c1 ea 0c             	shr    $0xc,%edx
  8012b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b9:	f6 c2 01             	test   $0x1,%dl
  8012bc:	74 1a                	je     8012d8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c1:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c8:	eb 13                	jmp    8012dd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cf:	eb 0c                	jmp    8012dd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d6:	eb 05                	jmp    8012dd <fd_lookup+0x54>
  8012d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    

008012df <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e8:	ba c4 2d 80 00       	mov    $0x802dc4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ed:	eb 13                	jmp    801302 <dev_lookup+0x23>
  8012ef:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012f2:	39 08                	cmp    %ecx,(%eax)
  8012f4:	75 0c                	jne    801302 <dev_lookup+0x23>
			*dev = devtab[i];
  8012f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801300:	eb 2e                	jmp    801330 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801302:	8b 02                	mov    (%edx),%eax
  801304:	85 c0                	test   %eax,%eax
  801306:	75 e7                	jne    8012ef <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801308:	a1 08 40 80 00       	mov    0x804008,%eax
  80130d:	8b 40 48             	mov    0x48(%eax),%eax
  801310:	83 ec 04             	sub    $0x4,%esp
  801313:	51                   	push   %ecx
  801314:	50                   	push   %eax
  801315:	68 44 2d 80 00       	push   $0x802d44
  80131a:	e8 cc f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  80131f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801322:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	56                   	push   %esi
  801336:	53                   	push   %ebx
  801337:	83 ec 10             	sub    $0x10,%esp
  80133a:	8b 75 08             	mov    0x8(%ebp),%esi
  80133d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801340:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801343:	50                   	push   %eax
  801344:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80134a:	c1 e8 0c             	shr    $0xc,%eax
  80134d:	50                   	push   %eax
  80134e:	e8 36 ff ff ff       	call   801289 <fd_lookup>
  801353:	83 c4 08             	add    $0x8,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 05                	js     80135f <fd_close+0x2d>
	    || fd != fd2)
  80135a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80135d:	74 0c                	je     80136b <fd_close+0x39>
		return (must_exist ? r : 0);
  80135f:	84 db                	test   %bl,%bl
  801361:	ba 00 00 00 00       	mov    $0x0,%edx
  801366:	0f 44 c2             	cmove  %edx,%eax
  801369:	eb 41                	jmp    8013ac <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	ff 36                	pushl  (%esi)
  801374:	e8 66 ff ff ff       	call   8012df <dev_lookup>
  801379:	89 c3                	mov    %eax,%ebx
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 1a                	js     80139c <fd_close+0x6a>
		if (dev->dev_close)
  801382:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801385:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801388:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80138d:	85 c0                	test   %eax,%eax
  80138f:	74 0b                	je     80139c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	56                   	push   %esi
  801395:	ff d0                	call   *%eax
  801397:	89 c3                	mov    %eax,%ebx
  801399:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	56                   	push   %esi
  8013a0:	6a 00                	push   $0x0
  8013a2:	e8 51 fa ff ff       	call   800df8 <sys_page_unmap>
	return r;
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	89 d8                	mov    %ebx,%eax
}
  8013ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013af:	5b                   	pop    %ebx
  8013b0:	5e                   	pop    %esi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    

008013b3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	ff 75 08             	pushl  0x8(%ebp)
  8013c0:	e8 c4 fe ff ff       	call   801289 <fd_lookup>
  8013c5:	83 c4 08             	add    $0x8,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 10                	js     8013dc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	6a 01                	push   $0x1
  8013d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d4:	e8 59 ff ff ff       	call   801332 <fd_close>
  8013d9:	83 c4 10             	add    $0x10,%esp
}
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    

008013de <close_all>:

void
close_all(void)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	53                   	push   %ebx
  8013ee:	e8 c0 ff ff ff       	call   8013b3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f3:	83 c3 01             	add    $0x1,%ebx
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	83 fb 20             	cmp    $0x20,%ebx
  8013fc:	75 ec                	jne    8013ea <close_all+0xc>
		close(i);
}
  8013fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	57                   	push   %edi
  801407:	56                   	push   %esi
  801408:	53                   	push   %ebx
  801409:	83 ec 2c             	sub    $0x2c,%esp
  80140c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80140f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801412:	50                   	push   %eax
  801413:	ff 75 08             	pushl  0x8(%ebp)
  801416:	e8 6e fe ff ff       	call   801289 <fd_lookup>
  80141b:	83 c4 08             	add    $0x8,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	0f 88 c1 00 00 00    	js     8014e7 <dup+0xe4>
		return r;
	close(newfdnum);
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	56                   	push   %esi
  80142a:	e8 84 ff ff ff       	call   8013b3 <close>

	newfd = INDEX2FD(newfdnum);
  80142f:	89 f3                	mov    %esi,%ebx
  801431:	c1 e3 0c             	shl    $0xc,%ebx
  801434:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80143a:	83 c4 04             	add    $0x4,%esp
  80143d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801440:	e8 de fd ff ff       	call   801223 <fd2data>
  801445:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801447:	89 1c 24             	mov    %ebx,(%esp)
  80144a:	e8 d4 fd ff ff       	call   801223 <fd2data>
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801455:	89 f8                	mov    %edi,%eax
  801457:	c1 e8 16             	shr    $0x16,%eax
  80145a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801461:	a8 01                	test   $0x1,%al
  801463:	74 37                	je     80149c <dup+0x99>
  801465:	89 f8                	mov    %edi,%eax
  801467:	c1 e8 0c             	shr    $0xc,%eax
  80146a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801471:	f6 c2 01             	test   $0x1,%dl
  801474:	74 26                	je     80149c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801476:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	25 07 0e 00 00       	and    $0xe07,%eax
  801485:	50                   	push   %eax
  801486:	ff 75 d4             	pushl  -0x2c(%ebp)
  801489:	6a 00                	push   $0x0
  80148b:	57                   	push   %edi
  80148c:	6a 00                	push   $0x0
  80148e:	e8 23 f9 ff ff       	call   800db6 <sys_page_map>
  801493:	89 c7                	mov    %eax,%edi
  801495:	83 c4 20             	add    $0x20,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 2e                	js     8014ca <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80149f:	89 d0                	mov    %edx,%eax
  8014a1:	c1 e8 0c             	shr    $0xc,%eax
  8014a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b3:	50                   	push   %eax
  8014b4:	53                   	push   %ebx
  8014b5:	6a 00                	push   $0x0
  8014b7:	52                   	push   %edx
  8014b8:	6a 00                	push   $0x0
  8014ba:	e8 f7 f8 ff ff       	call   800db6 <sys_page_map>
  8014bf:	89 c7                	mov    %eax,%edi
  8014c1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014c4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c6:	85 ff                	test   %edi,%edi
  8014c8:	79 1d                	jns    8014e7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 23 f9 ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014d5:	83 c4 08             	add    $0x8,%esp
  8014d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014db:	6a 00                	push   $0x0
  8014dd:	e8 16 f9 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	89 f8                	mov    %edi,%eax
}
  8014e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ea:	5b                   	pop    %ebx
  8014eb:	5e                   	pop    %esi
  8014ec:	5f                   	pop    %edi
  8014ed:	5d                   	pop    %ebp
  8014ee:	c3                   	ret    

008014ef <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	53                   	push   %ebx
  8014f3:	83 ec 14             	sub    $0x14,%esp
  8014f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	53                   	push   %ebx
  8014fe:	e8 86 fd ff ff       	call   801289 <fd_lookup>
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	89 c2                	mov    %eax,%edx
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 6d                	js     801579 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801516:	ff 30                	pushl  (%eax)
  801518:	e8 c2 fd ff ff       	call   8012df <dev_lookup>
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 4c                	js     801570 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801524:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801527:	8b 42 08             	mov    0x8(%edx),%eax
  80152a:	83 e0 03             	and    $0x3,%eax
  80152d:	83 f8 01             	cmp    $0x1,%eax
  801530:	75 21                	jne    801553 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801532:	a1 08 40 80 00       	mov    0x804008,%eax
  801537:	8b 40 48             	mov    0x48(%eax),%eax
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	53                   	push   %ebx
  80153e:	50                   	push   %eax
  80153f:	68 88 2d 80 00       	push   $0x802d88
  801544:	e8 a2 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801551:	eb 26                	jmp    801579 <read+0x8a>
	}
	if (!dev->dev_read)
  801553:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801556:	8b 40 08             	mov    0x8(%eax),%eax
  801559:	85 c0                	test   %eax,%eax
  80155b:	74 17                	je     801574 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	ff 75 10             	pushl  0x10(%ebp)
  801563:	ff 75 0c             	pushl  0xc(%ebp)
  801566:	52                   	push   %edx
  801567:	ff d0                	call   *%eax
  801569:	89 c2                	mov    %eax,%edx
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	eb 09                	jmp    801579 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801570:	89 c2                	mov    %eax,%edx
  801572:	eb 05                	jmp    801579 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801574:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801579:	89 d0                	mov    %edx,%eax
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	57                   	push   %edi
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	83 ec 0c             	sub    $0xc,%esp
  801589:	8b 7d 08             	mov    0x8(%ebp),%edi
  80158c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80158f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801594:	eb 21                	jmp    8015b7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801596:	83 ec 04             	sub    $0x4,%esp
  801599:	89 f0                	mov    %esi,%eax
  80159b:	29 d8                	sub    %ebx,%eax
  80159d:	50                   	push   %eax
  80159e:	89 d8                	mov    %ebx,%eax
  8015a0:	03 45 0c             	add    0xc(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	57                   	push   %edi
  8015a5:	e8 45 ff ff ff       	call   8014ef <read>
		if (m < 0)
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 10                	js     8015c1 <readn+0x41>
			return m;
		if (m == 0)
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	74 0a                	je     8015bf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b5:	01 c3                	add    %eax,%ebx
  8015b7:	39 f3                	cmp    %esi,%ebx
  8015b9:	72 db                	jb     801596 <readn+0x16>
  8015bb:	89 d8                	mov    %ebx,%eax
  8015bd:	eb 02                	jmp    8015c1 <readn+0x41>
  8015bf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 14             	sub    $0x14,%esp
  8015d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	53                   	push   %ebx
  8015d8:	e8 ac fc ff ff       	call   801289 <fd_lookup>
  8015dd:	83 c4 08             	add    $0x8,%esp
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 68                	js     80164e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f0:	ff 30                	pushl  (%eax)
  8015f2:	e8 e8 fc ff ff       	call   8012df <dev_lookup>
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 47                	js     801645 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801601:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801605:	75 21                	jne    801628 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801607:	a1 08 40 80 00       	mov    0x804008,%eax
  80160c:	8b 40 48             	mov    0x48(%eax),%eax
  80160f:	83 ec 04             	sub    $0x4,%esp
  801612:	53                   	push   %ebx
  801613:	50                   	push   %eax
  801614:	68 a4 2d 80 00       	push   $0x802da4
  801619:	e8 cd ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801626:	eb 26                	jmp    80164e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801628:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162b:	8b 52 0c             	mov    0xc(%edx),%edx
  80162e:	85 d2                	test   %edx,%edx
  801630:	74 17                	je     801649 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801632:	83 ec 04             	sub    $0x4,%esp
  801635:	ff 75 10             	pushl  0x10(%ebp)
  801638:	ff 75 0c             	pushl  0xc(%ebp)
  80163b:	50                   	push   %eax
  80163c:	ff d2                	call   *%edx
  80163e:	89 c2                	mov    %eax,%edx
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	eb 09                	jmp    80164e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801645:	89 c2                	mov    %eax,%edx
  801647:	eb 05                	jmp    80164e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801649:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80164e:	89 d0                	mov    %edx,%eax
  801650:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <seek>:

int
seek(int fdnum, off_t offset)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80165b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80165e:	50                   	push   %eax
  80165f:	ff 75 08             	pushl  0x8(%ebp)
  801662:	e8 22 fc ff ff       	call   801289 <fd_lookup>
  801667:	83 c4 08             	add    $0x8,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 0e                	js     80167c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80166e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801671:	8b 55 0c             	mov    0xc(%ebp),%edx
  801674:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801677:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	53                   	push   %ebx
  801682:	83 ec 14             	sub    $0x14,%esp
  801685:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801688:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	53                   	push   %ebx
  80168d:	e8 f7 fb ff ff       	call   801289 <fd_lookup>
  801692:	83 c4 08             	add    $0x8,%esp
  801695:	89 c2                	mov    %eax,%edx
  801697:	85 c0                	test   %eax,%eax
  801699:	78 65                	js     801700 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	ff 30                	pushl  (%eax)
  8016a7:	e8 33 fc ff ff       	call   8012df <dev_lookup>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 44                	js     8016f7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ba:	75 21                	jne    8016dd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016bc:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c1:	8b 40 48             	mov    0x48(%eax),%eax
  8016c4:	83 ec 04             	sub    $0x4,%esp
  8016c7:	53                   	push   %ebx
  8016c8:	50                   	push   %eax
  8016c9:	68 64 2d 80 00       	push   $0x802d64
  8016ce:	e8 18 ed ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016db:	eb 23                	jmp    801700 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e0:	8b 52 18             	mov    0x18(%edx),%edx
  8016e3:	85 d2                	test   %edx,%edx
  8016e5:	74 14                	je     8016fb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	ff 75 0c             	pushl  0xc(%ebp)
  8016ed:	50                   	push   %eax
  8016ee:	ff d2                	call   *%edx
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	eb 09                	jmp    801700 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	eb 05                	jmp    801700 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801700:	89 d0                	mov    %edx,%eax
  801702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	53                   	push   %ebx
  80170b:	83 ec 14             	sub    $0x14,%esp
  80170e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801711:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801714:	50                   	push   %eax
  801715:	ff 75 08             	pushl  0x8(%ebp)
  801718:	e8 6c fb ff ff       	call   801289 <fd_lookup>
  80171d:	83 c4 08             	add    $0x8,%esp
  801720:	89 c2                	mov    %eax,%edx
  801722:	85 c0                	test   %eax,%eax
  801724:	78 58                	js     80177e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172c:	50                   	push   %eax
  80172d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801730:	ff 30                	pushl  (%eax)
  801732:	e8 a8 fb ff ff       	call   8012df <dev_lookup>
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 37                	js     801775 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80173e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801741:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801745:	74 32                	je     801779 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801747:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80174a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801751:	00 00 00 
	stat->st_isdir = 0;
  801754:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80175b:	00 00 00 
	stat->st_dev = dev;
  80175e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801764:	83 ec 08             	sub    $0x8,%esp
  801767:	53                   	push   %ebx
  801768:	ff 75 f0             	pushl  -0x10(%ebp)
  80176b:	ff 50 14             	call   *0x14(%eax)
  80176e:	89 c2                	mov    %eax,%edx
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	eb 09                	jmp    80177e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801775:	89 c2                	mov    %eax,%edx
  801777:	eb 05                	jmp    80177e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801779:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80177e:	89 d0                	mov    %edx,%eax
  801780:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801783:	c9                   	leave  
  801784:	c3                   	ret    

00801785 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	56                   	push   %esi
  801789:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	6a 00                	push   $0x0
  80178f:	ff 75 08             	pushl  0x8(%ebp)
  801792:	e8 d6 01 00 00       	call   80196d <open>
  801797:	89 c3                	mov    %eax,%ebx
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 1b                	js     8017bb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	ff 75 0c             	pushl  0xc(%ebp)
  8017a6:	50                   	push   %eax
  8017a7:	e8 5b ff ff ff       	call   801707 <fstat>
  8017ac:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ae:	89 1c 24             	mov    %ebx,(%esp)
  8017b1:	e8 fd fb ff ff       	call   8013b3 <close>
	return r;
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	89 f0                	mov    %esi,%eax
}
  8017bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	56                   	push   %esi
  8017c6:	53                   	push   %ebx
  8017c7:	89 c6                	mov    %eax,%esi
  8017c9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017cb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017d2:	75 12                	jne    8017e6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017d4:	83 ec 0c             	sub    $0xc,%esp
  8017d7:	6a 01                	push   $0x1
  8017d9:	e8 ee 0c 00 00       	call   8024cc <ipc_find_env>
  8017de:	a3 00 40 80 00       	mov    %eax,0x804000
  8017e3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017e6:	6a 07                	push   $0x7
  8017e8:	68 00 50 80 00       	push   $0x805000
  8017ed:	56                   	push   %esi
  8017ee:	ff 35 00 40 80 00    	pushl  0x804000
  8017f4:	e8 7f 0c 00 00       	call   802478 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017f9:	83 c4 0c             	add    $0xc,%esp
  8017fc:	6a 00                	push   $0x0
  8017fe:	53                   	push   %ebx
  8017ff:	6a 00                	push   $0x0
  801801:	e8 0b 0c 00 00       	call   802411 <ipc_recv>
}
  801806:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	8b 40 0c             	mov    0xc(%eax),%eax
  801819:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80181e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801821:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801826:	ba 00 00 00 00       	mov    $0x0,%edx
  80182b:	b8 02 00 00 00       	mov    $0x2,%eax
  801830:	e8 8d ff ff ff       	call   8017c2 <fsipc>
}
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80183d:	8b 45 08             	mov    0x8(%ebp),%eax
  801840:	8b 40 0c             	mov    0xc(%eax),%eax
  801843:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801848:	ba 00 00 00 00       	mov    $0x0,%edx
  80184d:	b8 06 00 00 00       	mov    $0x6,%eax
  801852:	e8 6b ff ff ff       	call   8017c2 <fsipc>
}
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	53                   	push   %ebx
  80185d:	83 ec 04             	sub    $0x4,%esp
  801860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	8b 40 0c             	mov    0xc(%eax),%eax
  801869:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80186e:	ba 00 00 00 00       	mov    $0x0,%edx
  801873:	b8 05 00 00 00       	mov    $0x5,%eax
  801878:	e8 45 ff ff ff       	call   8017c2 <fsipc>
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 2c                	js     8018ad <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801881:	83 ec 08             	sub    $0x8,%esp
  801884:	68 00 50 80 00       	push   $0x805000
  801889:	53                   	push   %ebx
  80188a:	e8 e1 f0 ff ff       	call   800970 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80188f:	a1 80 50 80 00       	mov    0x805080,%eax
  801894:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80189a:	a1 84 50 80 00       	mov    0x805084,%eax
  80189f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	83 ec 0c             	sub    $0xc,%esp
  8018b8:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8018be:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018c7:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018cc:	50                   	push   %eax
  8018cd:	ff 75 0c             	pushl  0xc(%ebp)
  8018d0:	68 08 50 80 00       	push   $0x805008
  8018d5:	e8 28 f2 ff ff       	call   800b02 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018da:	ba 00 00 00 00       	mov    $0x0,%edx
  8018df:	b8 04 00 00 00       	mov    $0x4,%eax
  8018e4:	e8 d9 fe ff ff       	call   8017c2 <fsipc>

}
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	56                   	push   %esi
  8018ef:	53                   	push   %ebx
  8018f0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018fe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801904:	ba 00 00 00 00       	mov    $0x0,%edx
  801909:	b8 03 00 00 00       	mov    $0x3,%eax
  80190e:	e8 af fe ff ff       	call   8017c2 <fsipc>
  801913:	89 c3                	mov    %eax,%ebx
  801915:	85 c0                	test   %eax,%eax
  801917:	78 4b                	js     801964 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801919:	39 c6                	cmp    %eax,%esi
  80191b:	73 16                	jae    801933 <devfile_read+0x48>
  80191d:	68 d8 2d 80 00       	push   $0x802dd8
  801922:	68 df 2d 80 00       	push   $0x802ddf
  801927:	6a 7c                	push   $0x7c
  801929:	68 f4 2d 80 00       	push   $0x802df4
  80192e:	e8 df e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801933:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801938:	7e 16                	jle    801950 <devfile_read+0x65>
  80193a:	68 ff 2d 80 00       	push   $0x802dff
  80193f:	68 df 2d 80 00       	push   $0x802ddf
  801944:	6a 7d                	push   $0x7d
  801946:	68 f4 2d 80 00       	push   $0x802df4
  80194b:	e8 c2 e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801950:	83 ec 04             	sub    $0x4,%esp
  801953:	50                   	push   %eax
  801954:	68 00 50 80 00       	push   $0x805000
  801959:	ff 75 0c             	pushl  0xc(%ebp)
  80195c:	e8 a1 f1 ff ff       	call   800b02 <memmove>
	return r;
  801961:	83 c4 10             	add    $0x10,%esp
}
  801964:	89 d8                	mov    %ebx,%eax
  801966:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801969:	5b                   	pop    %ebx
  80196a:	5e                   	pop    %esi
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	53                   	push   %ebx
  801971:	83 ec 20             	sub    $0x20,%esp
  801974:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801977:	53                   	push   %ebx
  801978:	e8 ba ef ff ff       	call   800937 <strlen>
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801985:	7f 67                	jg     8019ee <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198d:	50                   	push   %eax
  80198e:	e8 a7 f8 ff ff       	call   80123a <fd_alloc>
  801993:	83 c4 10             	add    $0x10,%esp
		return r;
  801996:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801998:	85 c0                	test   %eax,%eax
  80199a:	78 57                	js     8019f3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80199c:	83 ec 08             	sub    $0x8,%esp
  80199f:	53                   	push   %ebx
  8019a0:	68 00 50 80 00       	push   $0x805000
  8019a5:	e8 c6 ef ff ff       	call   800970 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ad:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ba:	e8 03 fe ff ff       	call   8017c2 <fsipc>
  8019bf:	89 c3                	mov    %eax,%ebx
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	79 14                	jns    8019dc <open+0x6f>
		fd_close(fd, 0);
  8019c8:	83 ec 08             	sub    $0x8,%esp
  8019cb:	6a 00                	push   $0x0
  8019cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d0:	e8 5d f9 ff ff       	call   801332 <fd_close>
		return r;
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	89 da                	mov    %ebx,%edx
  8019da:	eb 17                	jmp    8019f3 <open+0x86>
	}

	return fd2num(fd);
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e2:	e8 2c f8 ff ff       	call   801213 <fd2num>
  8019e7:	89 c2                	mov    %eax,%edx
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	eb 05                	jmp    8019f3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ee:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019f3:	89 d0                	mov    %edx,%eax
  8019f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a00:	ba 00 00 00 00       	mov    $0x0,%edx
  801a05:	b8 08 00 00 00       	mov    $0x8,%eax
  801a0a:	e8 b3 fd ff ff       	call   8017c2 <fsipc>
}
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	ff 75 08             	pushl  0x8(%ebp)
  801a1f:	e8 ff f7 ff ff       	call   801223 <fd2data>
  801a24:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a26:	83 c4 08             	add    $0x8,%esp
  801a29:	68 0b 2e 80 00       	push   $0x802e0b
  801a2e:	53                   	push   %ebx
  801a2f:	e8 3c ef ff ff       	call   800970 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a34:	8b 46 04             	mov    0x4(%esi),%eax
  801a37:	2b 06                	sub    (%esi),%eax
  801a39:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a3f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a46:	00 00 00 
	stat->st_dev = &devpipe;
  801a49:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801a50:	30 80 00 
	return 0;
}
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
  801a58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5b:	5b                   	pop    %ebx
  801a5c:	5e                   	pop    %esi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	53                   	push   %ebx
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a69:	53                   	push   %ebx
  801a6a:	6a 00                	push   $0x0
  801a6c:	e8 87 f3 ff ff       	call   800df8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a71:	89 1c 24             	mov    %ebx,(%esp)
  801a74:	e8 aa f7 ff ff       	call   801223 <fd2data>
  801a79:	83 c4 08             	add    $0x8,%esp
  801a7c:	50                   	push   %eax
  801a7d:	6a 00                	push   $0x0
  801a7f:	e8 74 f3 ff ff       	call   800df8 <sys_page_unmap>
}
  801a84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	57                   	push   %edi
  801a8d:	56                   	push   %esi
  801a8e:	53                   	push   %ebx
  801a8f:	83 ec 1c             	sub    $0x1c,%esp
  801a92:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a95:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a97:	a1 08 40 80 00       	mov    0x804008,%eax
  801a9c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	ff 75 e0             	pushl  -0x20(%ebp)
  801aa5:	e8 5b 0a 00 00       	call   802505 <pageref>
  801aaa:	89 c3                	mov    %eax,%ebx
  801aac:	89 3c 24             	mov    %edi,(%esp)
  801aaf:	e8 51 0a 00 00       	call   802505 <pageref>
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	39 c3                	cmp    %eax,%ebx
  801ab9:	0f 94 c1             	sete   %cl
  801abc:	0f b6 c9             	movzbl %cl,%ecx
  801abf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ac2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ac8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801acb:	39 ce                	cmp    %ecx,%esi
  801acd:	74 1b                	je     801aea <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801acf:	39 c3                	cmp    %eax,%ebx
  801ad1:	75 c4                	jne    801a97 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ad3:	8b 42 58             	mov    0x58(%edx),%eax
  801ad6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ad9:	50                   	push   %eax
  801ada:	56                   	push   %esi
  801adb:	68 12 2e 80 00       	push   $0x802e12
  801ae0:	e8 06 e9 ff ff       	call   8003eb <cprintf>
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	eb ad                	jmp    801a97 <_pipeisclosed+0xe>
	}
}
  801aea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5e                   	pop    %esi
  801af2:	5f                   	pop    %edi
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	57                   	push   %edi
  801af9:	56                   	push   %esi
  801afa:	53                   	push   %ebx
  801afb:	83 ec 28             	sub    $0x28,%esp
  801afe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b01:	56                   	push   %esi
  801b02:	e8 1c f7 ff ff       	call   801223 <fd2data>
  801b07:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	bf 00 00 00 00       	mov    $0x0,%edi
  801b11:	eb 4b                	jmp    801b5e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b13:	89 da                	mov    %ebx,%edx
  801b15:	89 f0                	mov    %esi,%eax
  801b17:	e8 6d ff ff ff       	call   801a89 <_pipeisclosed>
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	75 48                	jne    801b68 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b20:	e8 2f f2 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b25:	8b 43 04             	mov    0x4(%ebx),%eax
  801b28:	8b 0b                	mov    (%ebx),%ecx
  801b2a:	8d 51 20             	lea    0x20(%ecx),%edx
  801b2d:	39 d0                	cmp    %edx,%eax
  801b2f:	73 e2                	jae    801b13 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b34:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b38:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b3b:	89 c2                	mov    %eax,%edx
  801b3d:	c1 fa 1f             	sar    $0x1f,%edx
  801b40:	89 d1                	mov    %edx,%ecx
  801b42:	c1 e9 1b             	shr    $0x1b,%ecx
  801b45:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b48:	83 e2 1f             	and    $0x1f,%edx
  801b4b:	29 ca                	sub    %ecx,%edx
  801b4d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b51:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b55:	83 c0 01             	add    $0x1,%eax
  801b58:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5b:	83 c7 01             	add    $0x1,%edi
  801b5e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b61:	75 c2                	jne    801b25 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b63:	8b 45 10             	mov    0x10(%ebp),%eax
  801b66:	eb 05                	jmp    801b6d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5e                   	pop    %esi
  801b72:	5f                   	pop    %edi
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	57                   	push   %edi
  801b79:	56                   	push   %esi
  801b7a:	53                   	push   %ebx
  801b7b:	83 ec 18             	sub    $0x18,%esp
  801b7e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b81:	57                   	push   %edi
  801b82:	e8 9c f6 ff ff       	call   801223 <fd2data>
  801b87:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b91:	eb 3d                	jmp    801bd0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b93:	85 db                	test   %ebx,%ebx
  801b95:	74 04                	je     801b9b <devpipe_read+0x26>
				return i;
  801b97:	89 d8                	mov    %ebx,%eax
  801b99:	eb 44                	jmp    801bdf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b9b:	89 f2                	mov    %esi,%edx
  801b9d:	89 f8                	mov    %edi,%eax
  801b9f:	e8 e5 fe ff ff       	call   801a89 <_pipeisclosed>
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	75 32                	jne    801bda <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ba8:	e8 a7 f1 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bad:	8b 06                	mov    (%esi),%eax
  801baf:	3b 46 04             	cmp    0x4(%esi),%eax
  801bb2:	74 df                	je     801b93 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bb4:	99                   	cltd   
  801bb5:	c1 ea 1b             	shr    $0x1b,%edx
  801bb8:	01 d0                	add    %edx,%eax
  801bba:	83 e0 1f             	and    $0x1f,%eax
  801bbd:	29 d0                	sub    %edx,%eax
  801bbf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bca:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bcd:	83 c3 01             	add    $0x1,%ebx
  801bd0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bd3:	75 d8                	jne    801bad <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bd5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd8:	eb 05                	jmp    801bdf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bda:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be2:	5b                   	pop    %ebx
  801be3:	5e                   	pop    %esi
  801be4:	5f                   	pop    %edi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	56                   	push   %esi
  801beb:	53                   	push   %ebx
  801bec:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf2:	50                   	push   %eax
  801bf3:	e8 42 f6 ff ff       	call   80123a <fd_alloc>
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	89 c2                	mov    %eax,%edx
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	0f 88 2c 01 00 00    	js     801d31 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c05:	83 ec 04             	sub    $0x4,%esp
  801c08:	68 07 04 00 00       	push   $0x407
  801c0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c10:	6a 00                	push   $0x0
  801c12:	e8 5c f1 ff ff       	call   800d73 <sys_page_alloc>
  801c17:	83 c4 10             	add    $0x10,%esp
  801c1a:	89 c2                	mov    %eax,%edx
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	0f 88 0d 01 00 00    	js     801d31 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c24:	83 ec 0c             	sub    $0xc,%esp
  801c27:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c2a:	50                   	push   %eax
  801c2b:	e8 0a f6 ff ff       	call   80123a <fd_alloc>
  801c30:	89 c3                	mov    %eax,%ebx
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	85 c0                	test   %eax,%eax
  801c37:	0f 88 e2 00 00 00    	js     801d1f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3d:	83 ec 04             	sub    $0x4,%esp
  801c40:	68 07 04 00 00       	push   $0x407
  801c45:	ff 75 f0             	pushl  -0x10(%ebp)
  801c48:	6a 00                	push   $0x0
  801c4a:	e8 24 f1 ff ff       	call   800d73 <sys_page_alloc>
  801c4f:	89 c3                	mov    %eax,%ebx
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	85 c0                	test   %eax,%eax
  801c56:	0f 88 c3 00 00 00    	js     801d1f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c5c:	83 ec 0c             	sub    $0xc,%esp
  801c5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c62:	e8 bc f5 ff ff       	call   801223 <fd2data>
  801c67:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c69:	83 c4 0c             	add    $0xc,%esp
  801c6c:	68 07 04 00 00       	push   $0x407
  801c71:	50                   	push   %eax
  801c72:	6a 00                	push   $0x0
  801c74:	e8 fa f0 ff ff       	call   800d73 <sys_page_alloc>
  801c79:	89 c3                	mov    %eax,%ebx
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	0f 88 89 00 00 00    	js     801d0f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8c:	e8 92 f5 ff ff       	call   801223 <fd2data>
  801c91:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c98:	50                   	push   %eax
  801c99:	6a 00                	push   $0x0
  801c9b:	56                   	push   %esi
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 13 f1 ff ff       	call   800db6 <sys_page_map>
  801ca3:	89 c3                	mov    %eax,%ebx
  801ca5:	83 c4 20             	add    $0x20,%esp
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	78 55                	js     801d01 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cac:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cc1:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cca:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ccf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cd6:	83 ec 0c             	sub    $0xc,%esp
  801cd9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdc:	e8 32 f5 ff ff       	call   801213 <fd2num>
  801ce1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ce6:	83 c4 04             	add    $0x4,%esp
  801ce9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cec:	e8 22 f5 ff ff       	call   801213 <fd2num>
  801cf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	ba 00 00 00 00       	mov    $0x0,%edx
  801cff:	eb 30                	jmp    801d31 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d01:	83 ec 08             	sub    $0x8,%esp
  801d04:	56                   	push   %esi
  801d05:	6a 00                	push   $0x0
  801d07:	e8 ec f0 ff ff       	call   800df8 <sys_page_unmap>
  801d0c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d0f:	83 ec 08             	sub    $0x8,%esp
  801d12:	ff 75 f0             	pushl  -0x10(%ebp)
  801d15:	6a 00                	push   $0x0
  801d17:	e8 dc f0 ff ff       	call   800df8 <sys_page_unmap>
  801d1c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d1f:	83 ec 08             	sub    $0x8,%esp
  801d22:	ff 75 f4             	pushl  -0xc(%ebp)
  801d25:	6a 00                	push   $0x0
  801d27:	e8 cc f0 ff ff       	call   800df8 <sys_page_unmap>
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d31:	89 d0                	mov    %edx,%eax
  801d33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d36:	5b                   	pop    %ebx
  801d37:	5e                   	pop    %esi
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d43:	50                   	push   %eax
  801d44:	ff 75 08             	pushl  0x8(%ebp)
  801d47:	e8 3d f5 ff ff       	call   801289 <fd_lookup>
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	78 18                	js     801d6b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d53:	83 ec 0c             	sub    $0xc,%esp
  801d56:	ff 75 f4             	pushl  -0xc(%ebp)
  801d59:	e8 c5 f4 ff ff       	call   801223 <fd2data>
	return _pipeisclosed(fd, p);
  801d5e:	89 c2                	mov    %eax,%edx
  801d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d63:	e8 21 fd ff ff       	call   801a89 <_pipeisclosed>
  801d68:	83 c4 10             	add    $0x10,%esp
}
  801d6b:	c9                   	leave  
  801d6c:	c3                   	ret    

00801d6d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	56                   	push   %esi
  801d71:	53                   	push   %ebx
  801d72:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d75:	85 f6                	test   %esi,%esi
  801d77:	75 16                	jne    801d8f <wait+0x22>
  801d79:	68 2a 2e 80 00       	push   $0x802e2a
  801d7e:	68 df 2d 80 00       	push   $0x802ddf
  801d83:	6a 09                	push   $0x9
  801d85:	68 35 2e 80 00       	push   $0x802e35
  801d8a:	e8 83 e5 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801d8f:	89 f3                	mov    %esi,%ebx
  801d91:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d97:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d9a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801da0:	eb 05                	jmp    801da7 <wait+0x3a>
		sys_yield();
  801da2:	e8 ad ef ff ff       	call   800d54 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801da7:	8b 43 48             	mov    0x48(%ebx),%eax
  801daa:	39 c6                	cmp    %eax,%esi
  801dac:	75 07                	jne    801db5 <wait+0x48>
  801dae:	8b 43 54             	mov    0x54(%ebx),%eax
  801db1:	85 c0                	test   %eax,%eax
  801db3:	75 ed                	jne    801da2 <wait+0x35>
		sys_yield();
}
  801db5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    

00801dbc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801dc2:	68 40 2e 80 00       	push   $0x802e40
  801dc7:	ff 75 0c             	pushl  0xc(%ebp)
  801dca:	e8 a1 eb ff ff       	call   800970 <strcpy>
	return 0;
}
  801dcf:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	53                   	push   %ebx
  801dda:	83 ec 10             	sub    $0x10,%esp
  801ddd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801de0:	53                   	push   %ebx
  801de1:	e8 1f 07 00 00       	call   802505 <pageref>
  801de6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801de9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801dee:	83 f8 01             	cmp    $0x1,%eax
  801df1:	75 10                	jne    801e03 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	ff 73 0c             	pushl  0xc(%ebx)
  801df9:	e8 c0 02 00 00       	call   8020be <nsipc_close>
  801dfe:	89 c2                	mov    %eax,%edx
  801e00:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801e03:	89 d0                	mov    %edx,%eax
  801e05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e10:	6a 00                	push   $0x0
  801e12:	ff 75 10             	pushl  0x10(%ebp)
  801e15:	ff 75 0c             	pushl  0xc(%ebp)
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	ff 70 0c             	pushl  0xc(%eax)
  801e1e:	e8 78 03 00 00       	call   80219b <nsipc_send>
}
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    

00801e25 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e2b:	6a 00                	push   $0x0
  801e2d:	ff 75 10             	pushl  0x10(%ebp)
  801e30:	ff 75 0c             	pushl  0xc(%ebp)
  801e33:	8b 45 08             	mov    0x8(%ebp),%eax
  801e36:	ff 70 0c             	pushl  0xc(%eax)
  801e39:	e8 f1 02 00 00       	call   80212f <nsipc_recv>
}
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e46:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e49:	52                   	push   %edx
  801e4a:	50                   	push   %eax
  801e4b:	e8 39 f4 ff ff       	call   801289 <fd_lookup>
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	85 c0                	test   %eax,%eax
  801e55:	78 17                	js     801e6e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5a:	8b 0d 40 30 80 00    	mov    0x803040,%ecx
  801e60:	39 08                	cmp    %ecx,(%eax)
  801e62:	75 05                	jne    801e69 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e64:	8b 40 0c             	mov    0xc(%eax),%eax
  801e67:	eb 05                	jmp    801e6e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e69:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	56                   	push   %esi
  801e74:	53                   	push   %ebx
  801e75:	83 ec 1c             	sub    $0x1c,%esp
  801e78:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7d:	50                   	push   %eax
  801e7e:	e8 b7 f3 ff ff       	call   80123a <fd_alloc>
  801e83:	89 c3                	mov    %eax,%ebx
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	78 1b                	js     801ea7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e8c:	83 ec 04             	sub    $0x4,%esp
  801e8f:	68 07 04 00 00       	push   $0x407
  801e94:	ff 75 f4             	pushl  -0xc(%ebp)
  801e97:	6a 00                	push   $0x0
  801e99:	e8 d5 ee ff ff       	call   800d73 <sys_page_alloc>
  801e9e:	89 c3                	mov    %eax,%ebx
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	79 10                	jns    801eb7 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ea7:	83 ec 0c             	sub    $0xc,%esp
  801eaa:	56                   	push   %esi
  801eab:	e8 0e 02 00 00       	call   8020be <nsipc_close>
		return r;
  801eb0:	83 c4 10             	add    $0x10,%esp
  801eb3:	89 d8                	mov    %ebx,%eax
  801eb5:	eb 24                	jmp    801edb <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801eb7:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ecc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ecf:	83 ec 0c             	sub    $0xc,%esp
  801ed2:	50                   	push   %eax
  801ed3:	e8 3b f3 ff ff       	call   801213 <fd2num>
  801ed8:	83 c4 10             	add    $0x10,%esp
}
  801edb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    

00801ee2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  801eeb:	e8 50 ff ff ff       	call   801e40 <fd2sockid>
		return r;
  801ef0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	78 1f                	js     801f15 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ef6:	83 ec 04             	sub    $0x4,%esp
  801ef9:	ff 75 10             	pushl  0x10(%ebp)
  801efc:	ff 75 0c             	pushl  0xc(%ebp)
  801eff:	50                   	push   %eax
  801f00:	e8 12 01 00 00       	call   802017 <nsipc_accept>
  801f05:	83 c4 10             	add    $0x10,%esp
		return r;
  801f08:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 07                	js     801f15 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801f0e:	e8 5d ff ff ff       	call   801e70 <alloc_sockfd>
  801f13:	89 c1                	mov    %eax,%ecx
}
  801f15:	89 c8                	mov    %ecx,%eax
  801f17:	c9                   	leave  
  801f18:	c3                   	ret    

00801f19 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f22:	e8 19 ff ff ff       	call   801e40 <fd2sockid>
  801f27:	85 c0                	test   %eax,%eax
  801f29:	78 12                	js     801f3d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801f2b:	83 ec 04             	sub    $0x4,%esp
  801f2e:	ff 75 10             	pushl  0x10(%ebp)
  801f31:	ff 75 0c             	pushl  0xc(%ebp)
  801f34:	50                   	push   %eax
  801f35:	e8 2d 01 00 00       	call   802067 <nsipc_bind>
  801f3a:	83 c4 10             	add    $0x10,%esp
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <shutdown>:

int
shutdown(int s, int how)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f45:	8b 45 08             	mov    0x8(%ebp),%eax
  801f48:	e8 f3 fe ff ff       	call   801e40 <fd2sockid>
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	78 0f                	js     801f60 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f51:	83 ec 08             	sub    $0x8,%esp
  801f54:	ff 75 0c             	pushl  0xc(%ebp)
  801f57:	50                   	push   %eax
  801f58:	e8 3f 01 00 00       	call   80209c <nsipc_shutdown>
  801f5d:	83 c4 10             	add    $0x10,%esp
}
  801f60:	c9                   	leave  
  801f61:	c3                   	ret    

00801f62 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f68:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6b:	e8 d0 fe ff ff       	call   801e40 <fd2sockid>
  801f70:	85 c0                	test   %eax,%eax
  801f72:	78 12                	js     801f86 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801f74:	83 ec 04             	sub    $0x4,%esp
  801f77:	ff 75 10             	pushl  0x10(%ebp)
  801f7a:	ff 75 0c             	pushl  0xc(%ebp)
  801f7d:	50                   	push   %eax
  801f7e:	e8 55 01 00 00       	call   8020d8 <nsipc_connect>
  801f83:	83 c4 10             	add    $0x10,%esp
}
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <listen>:

int
listen(int s, int backlog)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f91:	e8 aa fe ff ff       	call   801e40 <fd2sockid>
  801f96:	85 c0                	test   %eax,%eax
  801f98:	78 0f                	js     801fa9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f9a:	83 ec 08             	sub    $0x8,%esp
  801f9d:	ff 75 0c             	pushl  0xc(%ebp)
  801fa0:	50                   	push   %eax
  801fa1:	e8 67 01 00 00       	call   80210d <nsipc_listen>
  801fa6:	83 c4 10             	add    $0x10,%esp
}
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    

00801fab <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fb1:	ff 75 10             	pushl  0x10(%ebp)
  801fb4:	ff 75 0c             	pushl  0xc(%ebp)
  801fb7:	ff 75 08             	pushl  0x8(%ebp)
  801fba:	e8 3a 02 00 00       	call   8021f9 <nsipc_socket>
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	78 05                	js     801fcb <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801fc6:	e8 a5 fe ff ff       	call   801e70 <alloc_sockfd>
}
  801fcb:	c9                   	leave  
  801fcc:	c3                   	ret    

00801fcd <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	53                   	push   %ebx
  801fd1:	83 ec 04             	sub    $0x4,%esp
  801fd4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fd6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801fdd:	75 12                	jne    801ff1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fdf:	83 ec 0c             	sub    $0xc,%esp
  801fe2:	6a 02                	push   $0x2
  801fe4:	e8 e3 04 00 00       	call   8024cc <ipc_find_env>
  801fe9:	a3 04 40 80 00       	mov    %eax,0x804004
  801fee:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ff1:	6a 07                	push   $0x7
  801ff3:	68 00 60 80 00       	push   $0x806000
  801ff8:	53                   	push   %ebx
  801ff9:	ff 35 04 40 80 00    	pushl  0x804004
  801fff:	e8 74 04 00 00       	call   802478 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802004:	83 c4 0c             	add    $0xc,%esp
  802007:	6a 00                	push   $0x0
  802009:	6a 00                	push   $0x0
  80200b:	6a 00                	push   $0x0
  80200d:	e8 ff 03 00 00       	call   802411 <ipc_recv>
}
  802012:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802015:	c9                   	leave  
  802016:	c3                   	ret    

00802017 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	56                   	push   %esi
  80201b:	53                   	push   %ebx
  80201c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80201f:	8b 45 08             	mov    0x8(%ebp),%eax
  802022:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802027:	8b 06                	mov    (%esi),%eax
  802029:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80202e:	b8 01 00 00 00       	mov    $0x1,%eax
  802033:	e8 95 ff ff ff       	call   801fcd <nsipc>
  802038:	89 c3                	mov    %eax,%ebx
  80203a:	85 c0                	test   %eax,%eax
  80203c:	78 20                	js     80205e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80203e:	83 ec 04             	sub    $0x4,%esp
  802041:	ff 35 10 60 80 00    	pushl  0x806010
  802047:	68 00 60 80 00       	push   $0x806000
  80204c:	ff 75 0c             	pushl  0xc(%ebp)
  80204f:	e8 ae ea ff ff       	call   800b02 <memmove>
		*addrlen = ret->ret_addrlen;
  802054:	a1 10 60 80 00       	mov    0x806010,%eax
  802059:	89 06                	mov    %eax,(%esi)
  80205b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80205e:	89 d8                	mov    %ebx,%eax
  802060:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5d                   	pop    %ebp
  802066:	c3                   	ret    

00802067 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802067:	55                   	push   %ebp
  802068:	89 e5                	mov    %esp,%ebp
  80206a:	53                   	push   %ebx
  80206b:	83 ec 08             	sub    $0x8,%esp
  80206e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802071:	8b 45 08             	mov    0x8(%ebp),%eax
  802074:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802079:	53                   	push   %ebx
  80207a:	ff 75 0c             	pushl  0xc(%ebp)
  80207d:	68 04 60 80 00       	push   $0x806004
  802082:	e8 7b ea ff ff       	call   800b02 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802087:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80208d:	b8 02 00 00 00       	mov    $0x2,%eax
  802092:	e8 36 ff ff ff       	call   801fcd <nsipc>
}
  802097:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    

0080209c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8020a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8020aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ad:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8020b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8020b7:	e8 11 ff ff ff       	call   801fcd <nsipc>
}
  8020bc:	c9                   	leave  
  8020bd:	c3                   	ret    

008020be <nsipc_close>:

int
nsipc_close(int s)
{
  8020be:	55                   	push   %ebp
  8020bf:	89 e5                	mov    %esp,%ebp
  8020c1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c7:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8020cc:	b8 04 00 00 00       	mov    $0x4,%eax
  8020d1:	e8 f7 fe ff ff       	call   801fcd <nsipc>
}
  8020d6:	c9                   	leave  
  8020d7:	c3                   	ret    

008020d8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	53                   	push   %ebx
  8020dc:	83 ec 08             	sub    $0x8,%esp
  8020df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020ea:	53                   	push   %ebx
  8020eb:	ff 75 0c             	pushl  0xc(%ebp)
  8020ee:	68 04 60 80 00       	push   $0x806004
  8020f3:	e8 0a ea ff ff       	call   800b02 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020f8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8020fe:	b8 05 00 00 00       	mov    $0x5,%eax
  802103:	e8 c5 fe ff ff       	call   801fcd <nsipc>
}
  802108:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80210b:	c9                   	leave  
  80210c:	c3                   	ret    

0080210d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80210d:	55                   	push   %ebp
  80210e:	89 e5                	mov    %esp,%ebp
  802110:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802113:	8b 45 08             	mov    0x8(%ebp),%eax
  802116:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80211b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80211e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802123:	b8 06 00 00 00       	mov    $0x6,%eax
  802128:	e8 a0 fe ff ff       	call   801fcd <nsipc>
}
  80212d:	c9                   	leave  
  80212e:	c3                   	ret    

0080212f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80212f:	55                   	push   %ebp
  802130:	89 e5                	mov    %esp,%ebp
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802137:	8b 45 08             	mov    0x8(%ebp),%eax
  80213a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80213f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802145:	8b 45 14             	mov    0x14(%ebp),%eax
  802148:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80214d:	b8 07 00 00 00       	mov    $0x7,%eax
  802152:	e8 76 fe ff ff       	call   801fcd <nsipc>
  802157:	89 c3                	mov    %eax,%ebx
  802159:	85 c0                	test   %eax,%eax
  80215b:	78 35                	js     802192 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80215d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802162:	7f 04                	jg     802168 <nsipc_recv+0x39>
  802164:	39 c6                	cmp    %eax,%esi
  802166:	7d 16                	jge    80217e <nsipc_recv+0x4f>
  802168:	68 4c 2e 80 00       	push   $0x802e4c
  80216d:	68 df 2d 80 00       	push   $0x802ddf
  802172:	6a 62                	push   $0x62
  802174:	68 61 2e 80 00       	push   $0x802e61
  802179:	e8 94 e1 ff ff       	call   800312 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80217e:	83 ec 04             	sub    $0x4,%esp
  802181:	50                   	push   %eax
  802182:	68 00 60 80 00       	push   $0x806000
  802187:	ff 75 0c             	pushl  0xc(%ebp)
  80218a:	e8 73 e9 ff ff       	call   800b02 <memmove>
  80218f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802192:	89 d8                	mov    %ebx,%eax
  802194:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    

0080219b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	53                   	push   %ebx
  80219f:	83 ec 04             	sub    $0x4,%esp
  8021a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8021ad:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021b3:	7e 16                	jle    8021cb <nsipc_send+0x30>
  8021b5:	68 6d 2e 80 00       	push   $0x802e6d
  8021ba:	68 df 2d 80 00       	push   $0x802ddf
  8021bf:	6a 6d                	push   $0x6d
  8021c1:	68 61 2e 80 00       	push   $0x802e61
  8021c6:	e8 47 e1 ff ff       	call   800312 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021cb:	83 ec 04             	sub    $0x4,%esp
  8021ce:	53                   	push   %ebx
  8021cf:	ff 75 0c             	pushl  0xc(%ebp)
  8021d2:	68 0c 60 80 00       	push   $0x80600c
  8021d7:	e8 26 e9 ff ff       	call   800b02 <memmove>
	nsipcbuf.send.req_size = size;
  8021dc:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8021e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8021ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8021ef:	e8 d9 fd ff ff       	call   801fcd <nsipc>
}
  8021f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021f7:	c9                   	leave  
  8021f8:	c3                   	ret    

008021f9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802202:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80220f:	8b 45 10             	mov    0x10(%ebp),%eax
  802212:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802217:	b8 09 00 00 00       	mov    $0x9,%eax
  80221c:	e8 ac fd ff ff       	call   801fcd <nsipc>
}
  802221:	c9                   	leave  
  802222:	c3                   	ret    

00802223 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802223:	55                   	push   %ebp
  802224:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802226:	b8 00 00 00 00       	mov    $0x0,%eax
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    

0080222d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80222d:	55                   	push   %ebp
  80222e:	89 e5                	mov    %esp,%ebp
  802230:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802233:	68 79 2e 80 00       	push   $0x802e79
  802238:	ff 75 0c             	pushl  0xc(%ebp)
  80223b:	e8 30 e7 ff ff       	call   800970 <strcpy>
	return 0;
}
  802240:	b8 00 00 00 00       	mov    $0x0,%eax
  802245:	c9                   	leave  
  802246:	c3                   	ret    

00802247 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802247:	55                   	push   %ebp
  802248:	89 e5                	mov    %esp,%ebp
  80224a:	57                   	push   %edi
  80224b:	56                   	push   %esi
  80224c:	53                   	push   %ebx
  80224d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802253:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802258:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80225e:	eb 2d                	jmp    80228d <devcons_write+0x46>
		m = n - tot;
  802260:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802263:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802265:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802268:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80226d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802270:	83 ec 04             	sub    $0x4,%esp
  802273:	53                   	push   %ebx
  802274:	03 45 0c             	add    0xc(%ebp),%eax
  802277:	50                   	push   %eax
  802278:	57                   	push   %edi
  802279:	e8 84 e8 ff ff       	call   800b02 <memmove>
		sys_cputs(buf, m);
  80227e:	83 c4 08             	add    $0x8,%esp
  802281:	53                   	push   %ebx
  802282:	57                   	push   %edi
  802283:	e8 2f ea ff ff       	call   800cb7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802288:	01 de                	add    %ebx,%esi
  80228a:	83 c4 10             	add    $0x10,%esp
  80228d:	89 f0                	mov    %esi,%eax
  80228f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802292:	72 cc                	jb     802260 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    

0080229c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	83 ec 08             	sub    $0x8,%esp
  8022a2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ab:	74 2a                	je     8022d7 <devcons_read+0x3b>
  8022ad:	eb 05                	jmp    8022b4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022af:	e8 a0 ea ff ff       	call   800d54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022b4:	e8 1c ea ff ff       	call   800cd5 <sys_cgetc>
  8022b9:	85 c0                	test   %eax,%eax
  8022bb:	74 f2                	je     8022af <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022bd:	85 c0                	test   %eax,%eax
  8022bf:	78 16                	js     8022d7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022c1:	83 f8 04             	cmp    $0x4,%eax
  8022c4:	74 0c                	je     8022d2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022c9:	88 02                	mov    %al,(%edx)
	return 1;
  8022cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d0:	eb 05                	jmp    8022d7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022d2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022d7:	c9                   	leave  
  8022d8:	c3                   	ret    

008022d9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022df:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022e5:	6a 01                	push   $0x1
  8022e7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ea:	50                   	push   %eax
  8022eb:	e8 c7 e9 ff ff       	call   800cb7 <sys_cputs>
}
  8022f0:	83 c4 10             	add    $0x10,%esp
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    

008022f5 <getchar>:

int
getchar(void)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022fb:	6a 01                	push   $0x1
  8022fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802300:	50                   	push   %eax
  802301:	6a 00                	push   $0x0
  802303:	e8 e7 f1 ff ff       	call   8014ef <read>
	if (r < 0)
  802308:	83 c4 10             	add    $0x10,%esp
  80230b:	85 c0                	test   %eax,%eax
  80230d:	78 0f                	js     80231e <getchar+0x29>
		return r;
	if (r < 1)
  80230f:	85 c0                	test   %eax,%eax
  802311:	7e 06                	jle    802319 <getchar+0x24>
		return -E_EOF;
	return c;
  802313:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802317:	eb 05                	jmp    80231e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802319:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80231e:	c9                   	leave  
  80231f:	c3                   	ret    

00802320 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802326:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802329:	50                   	push   %eax
  80232a:	ff 75 08             	pushl  0x8(%ebp)
  80232d:	e8 57 ef ff ff       	call   801289 <fd_lookup>
  802332:	83 c4 10             	add    $0x10,%esp
  802335:	85 c0                	test   %eax,%eax
  802337:	78 11                	js     80234a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802339:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233c:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802342:	39 10                	cmp    %edx,(%eax)
  802344:	0f 94 c0             	sete   %al
  802347:	0f b6 c0             	movzbl %al,%eax
}
  80234a:	c9                   	leave  
  80234b:	c3                   	ret    

0080234c <opencons>:

int
opencons(void)
{
  80234c:	55                   	push   %ebp
  80234d:	89 e5                	mov    %esp,%ebp
  80234f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802352:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802355:	50                   	push   %eax
  802356:	e8 df ee ff ff       	call   80123a <fd_alloc>
  80235b:	83 c4 10             	add    $0x10,%esp
		return r;
  80235e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802360:	85 c0                	test   %eax,%eax
  802362:	78 3e                	js     8023a2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802364:	83 ec 04             	sub    $0x4,%esp
  802367:	68 07 04 00 00       	push   $0x407
  80236c:	ff 75 f4             	pushl  -0xc(%ebp)
  80236f:	6a 00                	push   $0x0
  802371:	e8 fd e9 ff ff       	call   800d73 <sys_page_alloc>
  802376:	83 c4 10             	add    $0x10,%esp
		return r;
  802379:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80237b:	85 c0                	test   %eax,%eax
  80237d:	78 23                	js     8023a2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80237f:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802385:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802388:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80238a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802394:	83 ec 0c             	sub    $0xc,%esp
  802397:	50                   	push   %eax
  802398:	e8 76 ee ff ff       	call   801213 <fd2num>
  80239d:	89 c2                	mov    %eax,%edx
  80239f:	83 c4 10             	add    $0x10,%esp
}
  8023a2:	89 d0                	mov    %edx,%eax
  8023a4:	c9                   	leave  
  8023a5:	c3                   	ret    

008023a6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023a6:	55                   	push   %ebp
  8023a7:	89 e5                	mov    %esp,%ebp
  8023a9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023ac:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023b3:	75 2e                	jne    8023e3 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8023b5:	e8 7b e9 ff ff       	call   800d35 <sys_getenvid>
  8023ba:	83 ec 04             	sub    $0x4,%esp
  8023bd:	68 07 0e 00 00       	push   $0xe07
  8023c2:	68 00 f0 bf ee       	push   $0xeebff000
  8023c7:	50                   	push   %eax
  8023c8:	e8 a6 e9 ff ff       	call   800d73 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8023cd:	e8 63 e9 ff ff       	call   800d35 <sys_getenvid>
  8023d2:	83 c4 08             	add    $0x8,%esp
  8023d5:	68 ed 23 80 00       	push   $0x8023ed
  8023da:	50                   	push   %eax
  8023db:	e8 de ea ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
  8023e0:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e6:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023eb:	c9                   	leave  
  8023ec:	c3                   	ret    

008023ed <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023ed:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023ee:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023f3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023f5:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8023f8:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8023fc:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802400:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802403:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802406:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802407:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80240a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80240b:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80240c:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802410:	c3                   	ret    

00802411 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802411:	55                   	push   %ebp
  802412:	89 e5                	mov    %esp,%ebp
  802414:	56                   	push   %esi
  802415:	53                   	push   %ebx
  802416:	8b 75 08             	mov    0x8(%ebp),%esi
  802419:	8b 45 0c             	mov    0xc(%ebp),%eax
  80241c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80241f:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802421:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802426:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802429:	83 ec 0c             	sub    $0xc,%esp
  80242c:	50                   	push   %eax
  80242d:	e8 f1 ea ff ff       	call   800f23 <sys_ipc_recv>

	if (from_env_store != NULL)
  802432:	83 c4 10             	add    $0x10,%esp
  802435:	85 f6                	test   %esi,%esi
  802437:	74 14                	je     80244d <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802439:	ba 00 00 00 00       	mov    $0x0,%edx
  80243e:	85 c0                	test   %eax,%eax
  802440:	78 09                	js     80244b <ipc_recv+0x3a>
  802442:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802448:	8b 52 74             	mov    0x74(%edx),%edx
  80244b:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80244d:	85 db                	test   %ebx,%ebx
  80244f:	74 14                	je     802465 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802451:	ba 00 00 00 00       	mov    $0x0,%edx
  802456:	85 c0                	test   %eax,%eax
  802458:	78 09                	js     802463 <ipc_recv+0x52>
  80245a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802460:	8b 52 78             	mov    0x78(%edx),%edx
  802463:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802465:	85 c0                	test   %eax,%eax
  802467:	78 08                	js     802471 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802469:	a1 08 40 80 00       	mov    0x804008,%eax
  80246e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802471:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802474:	5b                   	pop    %ebx
  802475:	5e                   	pop    %esi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    

00802478 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802478:	55                   	push   %ebp
  802479:	89 e5                	mov    %esp,%ebp
  80247b:	57                   	push   %edi
  80247c:	56                   	push   %esi
  80247d:	53                   	push   %ebx
  80247e:	83 ec 0c             	sub    $0xc,%esp
  802481:	8b 7d 08             	mov    0x8(%ebp),%edi
  802484:	8b 75 0c             	mov    0xc(%ebp),%esi
  802487:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80248a:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80248c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802491:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802494:	ff 75 14             	pushl  0x14(%ebp)
  802497:	53                   	push   %ebx
  802498:	56                   	push   %esi
  802499:	57                   	push   %edi
  80249a:	e8 61 ea ff ff       	call   800f00 <sys_ipc_try_send>

		if (err < 0) {
  80249f:	83 c4 10             	add    $0x10,%esp
  8024a2:	85 c0                	test   %eax,%eax
  8024a4:	79 1e                	jns    8024c4 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8024a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024a9:	75 07                	jne    8024b2 <ipc_send+0x3a>
				sys_yield();
  8024ab:	e8 a4 e8 ff ff       	call   800d54 <sys_yield>
  8024b0:	eb e2                	jmp    802494 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8024b2:	50                   	push   %eax
  8024b3:	68 85 2e 80 00       	push   $0x802e85
  8024b8:	6a 49                	push   $0x49
  8024ba:	68 92 2e 80 00       	push   $0x802e92
  8024bf:	e8 4e de ff ff       	call   800312 <_panic>
		}

	} while (err < 0);

}
  8024c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024c7:	5b                   	pop    %ebx
  8024c8:	5e                   	pop    %esi
  8024c9:	5f                   	pop    %edi
  8024ca:	5d                   	pop    %ebp
  8024cb:	c3                   	ret    

008024cc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024cc:	55                   	push   %ebp
  8024cd:	89 e5                	mov    %esp,%ebp
  8024cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024d2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024d7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024da:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024e0:	8b 52 50             	mov    0x50(%edx),%edx
  8024e3:	39 ca                	cmp    %ecx,%edx
  8024e5:	75 0d                	jne    8024f4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8024e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024ef:	8b 40 48             	mov    0x48(%eax),%eax
  8024f2:	eb 0f                	jmp    802503 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024f4:	83 c0 01             	add    $0x1,%eax
  8024f7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024fc:	75 d9                	jne    8024d7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    

00802505 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802505:	55                   	push   %ebp
  802506:	89 e5                	mov    %esp,%ebp
  802508:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80250b:	89 d0                	mov    %edx,%eax
  80250d:	c1 e8 16             	shr    $0x16,%eax
  802510:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802517:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80251c:	f6 c1 01             	test   $0x1,%cl
  80251f:	74 1d                	je     80253e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802521:	c1 ea 0c             	shr    $0xc,%edx
  802524:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80252b:	f6 c2 01             	test   $0x1,%dl
  80252e:	74 0e                	je     80253e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802530:	c1 ea 0c             	shr    $0xc,%edx
  802533:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80253a:	ef 
  80253b:	0f b7 c0             	movzwl %ax,%eax
}
  80253e:	5d                   	pop    %ebp
  80253f:	c3                   	ret    

00802540 <__udivdi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	83 ec 1c             	sub    $0x1c,%esp
  802547:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80254b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80254f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802557:	85 f6                	test   %esi,%esi
  802559:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80255d:	89 ca                	mov    %ecx,%edx
  80255f:	89 f8                	mov    %edi,%eax
  802561:	75 3d                	jne    8025a0 <__udivdi3+0x60>
  802563:	39 cf                	cmp    %ecx,%edi
  802565:	0f 87 c5 00 00 00    	ja     802630 <__udivdi3+0xf0>
  80256b:	85 ff                	test   %edi,%edi
  80256d:	89 fd                	mov    %edi,%ebp
  80256f:	75 0b                	jne    80257c <__udivdi3+0x3c>
  802571:	b8 01 00 00 00       	mov    $0x1,%eax
  802576:	31 d2                	xor    %edx,%edx
  802578:	f7 f7                	div    %edi
  80257a:	89 c5                	mov    %eax,%ebp
  80257c:	89 c8                	mov    %ecx,%eax
  80257e:	31 d2                	xor    %edx,%edx
  802580:	f7 f5                	div    %ebp
  802582:	89 c1                	mov    %eax,%ecx
  802584:	89 d8                	mov    %ebx,%eax
  802586:	89 cf                	mov    %ecx,%edi
  802588:	f7 f5                	div    %ebp
  80258a:	89 c3                	mov    %eax,%ebx
  80258c:	89 d8                	mov    %ebx,%eax
  80258e:	89 fa                	mov    %edi,%edx
  802590:	83 c4 1c             	add    $0x1c,%esp
  802593:	5b                   	pop    %ebx
  802594:	5e                   	pop    %esi
  802595:	5f                   	pop    %edi
  802596:	5d                   	pop    %ebp
  802597:	c3                   	ret    
  802598:	90                   	nop
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	39 ce                	cmp    %ecx,%esi
  8025a2:	77 74                	ja     802618 <__udivdi3+0xd8>
  8025a4:	0f bd fe             	bsr    %esi,%edi
  8025a7:	83 f7 1f             	xor    $0x1f,%edi
  8025aa:	0f 84 98 00 00 00    	je     802648 <__udivdi3+0x108>
  8025b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025b5:	89 f9                	mov    %edi,%ecx
  8025b7:	89 c5                	mov    %eax,%ebp
  8025b9:	29 fb                	sub    %edi,%ebx
  8025bb:	d3 e6                	shl    %cl,%esi
  8025bd:	89 d9                	mov    %ebx,%ecx
  8025bf:	d3 ed                	shr    %cl,%ebp
  8025c1:	89 f9                	mov    %edi,%ecx
  8025c3:	d3 e0                	shl    %cl,%eax
  8025c5:	09 ee                	or     %ebp,%esi
  8025c7:	89 d9                	mov    %ebx,%ecx
  8025c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025cd:	89 d5                	mov    %edx,%ebp
  8025cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025d3:	d3 ed                	shr    %cl,%ebp
  8025d5:	89 f9                	mov    %edi,%ecx
  8025d7:	d3 e2                	shl    %cl,%edx
  8025d9:	89 d9                	mov    %ebx,%ecx
  8025db:	d3 e8                	shr    %cl,%eax
  8025dd:	09 c2                	or     %eax,%edx
  8025df:	89 d0                	mov    %edx,%eax
  8025e1:	89 ea                	mov    %ebp,%edx
  8025e3:	f7 f6                	div    %esi
  8025e5:	89 d5                	mov    %edx,%ebp
  8025e7:	89 c3                	mov    %eax,%ebx
  8025e9:	f7 64 24 0c          	mull   0xc(%esp)
  8025ed:	39 d5                	cmp    %edx,%ebp
  8025ef:	72 10                	jb     802601 <__udivdi3+0xc1>
  8025f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025f5:	89 f9                	mov    %edi,%ecx
  8025f7:	d3 e6                	shl    %cl,%esi
  8025f9:	39 c6                	cmp    %eax,%esi
  8025fb:	73 07                	jae    802604 <__udivdi3+0xc4>
  8025fd:	39 d5                	cmp    %edx,%ebp
  8025ff:	75 03                	jne    802604 <__udivdi3+0xc4>
  802601:	83 eb 01             	sub    $0x1,%ebx
  802604:	31 ff                	xor    %edi,%edi
  802606:	89 d8                	mov    %ebx,%eax
  802608:	89 fa                	mov    %edi,%edx
  80260a:	83 c4 1c             	add    $0x1c,%esp
  80260d:	5b                   	pop    %ebx
  80260e:	5e                   	pop    %esi
  80260f:	5f                   	pop    %edi
  802610:	5d                   	pop    %ebp
  802611:	c3                   	ret    
  802612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802618:	31 ff                	xor    %edi,%edi
  80261a:	31 db                	xor    %ebx,%ebx
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
  802630:	89 d8                	mov    %ebx,%eax
  802632:	f7 f7                	div    %edi
  802634:	31 ff                	xor    %edi,%edi
  802636:	89 c3                	mov    %eax,%ebx
  802638:	89 d8                	mov    %ebx,%eax
  80263a:	89 fa                	mov    %edi,%edx
  80263c:	83 c4 1c             	add    $0x1c,%esp
  80263f:	5b                   	pop    %ebx
  802640:	5e                   	pop    %esi
  802641:	5f                   	pop    %edi
  802642:	5d                   	pop    %ebp
  802643:	c3                   	ret    
  802644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802648:	39 ce                	cmp    %ecx,%esi
  80264a:	72 0c                	jb     802658 <__udivdi3+0x118>
  80264c:	31 db                	xor    %ebx,%ebx
  80264e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802652:	0f 87 34 ff ff ff    	ja     80258c <__udivdi3+0x4c>
  802658:	bb 01 00 00 00       	mov    $0x1,%ebx
  80265d:	e9 2a ff ff ff       	jmp    80258c <__udivdi3+0x4c>
  802662:	66 90                	xchg   %ax,%ax
  802664:	66 90                	xchg   %ax,%ax
  802666:	66 90                	xchg   %ax,%ax
  802668:	66 90                	xchg   %ax,%ax
  80266a:	66 90                	xchg   %ax,%ax
  80266c:	66 90                	xchg   %ax,%ax
  80266e:	66 90                	xchg   %ax,%ax

00802670 <__umoddi3>:
  802670:	55                   	push   %ebp
  802671:	57                   	push   %edi
  802672:	56                   	push   %esi
  802673:	53                   	push   %ebx
  802674:	83 ec 1c             	sub    $0x1c,%esp
  802677:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80267b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80267f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802683:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802687:	85 d2                	test   %edx,%edx
  802689:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80268d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802691:	89 f3                	mov    %esi,%ebx
  802693:	89 3c 24             	mov    %edi,(%esp)
  802696:	89 74 24 04          	mov    %esi,0x4(%esp)
  80269a:	75 1c                	jne    8026b8 <__umoddi3+0x48>
  80269c:	39 f7                	cmp    %esi,%edi
  80269e:	76 50                	jbe    8026f0 <__umoddi3+0x80>
  8026a0:	89 c8                	mov    %ecx,%eax
  8026a2:	89 f2                	mov    %esi,%edx
  8026a4:	f7 f7                	div    %edi
  8026a6:	89 d0                	mov    %edx,%eax
  8026a8:	31 d2                	xor    %edx,%edx
  8026aa:	83 c4 1c             	add    $0x1c,%esp
  8026ad:	5b                   	pop    %ebx
  8026ae:	5e                   	pop    %esi
  8026af:	5f                   	pop    %edi
  8026b0:	5d                   	pop    %ebp
  8026b1:	c3                   	ret    
  8026b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026b8:	39 f2                	cmp    %esi,%edx
  8026ba:	89 d0                	mov    %edx,%eax
  8026bc:	77 52                	ja     802710 <__umoddi3+0xa0>
  8026be:	0f bd ea             	bsr    %edx,%ebp
  8026c1:	83 f5 1f             	xor    $0x1f,%ebp
  8026c4:	75 5a                	jne    802720 <__umoddi3+0xb0>
  8026c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026ca:	0f 82 e0 00 00 00    	jb     8027b0 <__umoddi3+0x140>
  8026d0:	39 0c 24             	cmp    %ecx,(%esp)
  8026d3:	0f 86 d7 00 00 00    	jbe    8027b0 <__umoddi3+0x140>
  8026d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026e1:	83 c4 1c             	add    $0x1c,%esp
  8026e4:	5b                   	pop    %ebx
  8026e5:	5e                   	pop    %esi
  8026e6:	5f                   	pop    %edi
  8026e7:	5d                   	pop    %ebp
  8026e8:	c3                   	ret    
  8026e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026f0:	85 ff                	test   %edi,%edi
  8026f2:	89 fd                	mov    %edi,%ebp
  8026f4:	75 0b                	jne    802701 <__umoddi3+0x91>
  8026f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026fb:	31 d2                	xor    %edx,%edx
  8026fd:	f7 f7                	div    %edi
  8026ff:	89 c5                	mov    %eax,%ebp
  802701:	89 f0                	mov    %esi,%eax
  802703:	31 d2                	xor    %edx,%edx
  802705:	f7 f5                	div    %ebp
  802707:	89 c8                	mov    %ecx,%eax
  802709:	f7 f5                	div    %ebp
  80270b:	89 d0                	mov    %edx,%eax
  80270d:	eb 99                	jmp    8026a8 <__umoddi3+0x38>
  80270f:	90                   	nop
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 f2                	mov    %esi,%edx
  802714:	83 c4 1c             	add    $0x1c,%esp
  802717:	5b                   	pop    %ebx
  802718:	5e                   	pop    %esi
  802719:	5f                   	pop    %edi
  80271a:	5d                   	pop    %ebp
  80271b:	c3                   	ret    
  80271c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802720:	8b 34 24             	mov    (%esp),%esi
  802723:	bf 20 00 00 00       	mov    $0x20,%edi
  802728:	89 e9                	mov    %ebp,%ecx
  80272a:	29 ef                	sub    %ebp,%edi
  80272c:	d3 e0                	shl    %cl,%eax
  80272e:	89 f9                	mov    %edi,%ecx
  802730:	89 f2                	mov    %esi,%edx
  802732:	d3 ea                	shr    %cl,%edx
  802734:	89 e9                	mov    %ebp,%ecx
  802736:	09 c2                	or     %eax,%edx
  802738:	89 d8                	mov    %ebx,%eax
  80273a:	89 14 24             	mov    %edx,(%esp)
  80273d:	89 f2                	mov    %esi,%edx
  80273f:	d3 e2                	shl    %cl,%edx
  802741:	89 f9                	mov    %edi,%ecx
  802743:	89 54 24 04          	mov    %edx,0x4(%esp)
  802747:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80274b:	d3 e8                	shr    %cl,%eax
  80274d:	89 e9                	mov    %ebp,%ecx
  80274f:	89 c6                	mov    %eax,%esi
  802751:	d3 e3                	shl    %cl,%ebx
  802753:	89 f9                	mov    %edi,%ecx
  802755:	89 d0                	mov    %edx,%eax
  802757:	d3 e8                	shr    %cl,%eax
  802759:	89 e9                	mov    %ebp,%ecx
  80275b:	09 d8                	or     %ebx,%eax
  80275d:	89 d3                	mov    %edx,%ebx
  80275f:	89 f2                	mov    %esi,%edx
  802761:	f7 34 24             	divl   (%esp)
  802764:	89 d6                	mov    %edx,%esi
  802766:	d3 e3                	shl    %cl,%ebx
  802768:	f7 64 24 04          	mull   0x4(%esp)
  80276c:	39 d6                	cmp    %edx,%esi
  80276e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802772:	89 d1                	mov    %edx,%ecx
  802774:	89 c3                	mov    %eax,%ebx
  802776:	72 08                	jb     802780 <__umoddi3+0x110>
  802778:	75 11                	jne    80278b <__umoddi3+0x11b>
  80277a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80277e:	73 0b                	jae    80278b <__umoddi3+0x11b>
  802780:	2b 44 24 04          	sub    0x4(%esp),%eax
  802784:	1b 14 24             	sbb    (%esp),%edx
  802787:	89 d1                	mov    %edx,%ecx
  802789:	89 c3                	mov    %eax,%ebx
  80278b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80278f:	29 da                	sub    %ebx,%edx
  802791:	19 ce                	sbb    %ecx,%esi
  802793:	89 f9                	mov    %edi,%ecx
  802795:	89 f0                	mov    %esi,%eax
  802797:	d3 e0                	shl    %cl,%eax
  802799:	89 e9                	mov    %ebp,%ecx
  80279b:	d3 ea                	shr    %cl,%edx
  80279d:	89 e9                	mov    %ebp,%ecx
  80279f:	d3 ee                	shr    %cl,%esi
  8027a1:	09 d0                	or     %edx,%eax
  8027a3:	89 f2                	mov    %esi,%edx
  8027a5:	83 c4 1c             	add    $0x1c,%esp
  8027a8:	5b                   	pop    %ebx
  8027a9:	5e                   	pop    %esi
  8027aa:	5f                   	pop    %edi
  8027ab:	5d                   	pop    %ebp
  8027ac:	c3                   	ret    
  8027ad:	8d 76 00             	lea    0x0(%esi),%esi
  8027b0:	29 f9                	sub    %edi,%ecx
  8027b2:	19 d6                	sbb    %edx,%esi
  8027b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027bc:	e9 18 ff ff ff       	jmp    8026d9 <__umoddi3+0x69>
