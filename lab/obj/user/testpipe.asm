
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
  80003b:	c7 05 04 30 80 00 60 	movl   $0x802860,0x803004
  800042:	28 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 84 20 00 00       	call   8020d2 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 6c 28 80 00       	push   $0x80286c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 75 28 80 00       	push   $0x802875
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 72 10 00 00       	call   8010e0 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 85 28 80 00       	push   $0x802885
  80007a:	6a 11                	push   $0x11
  80007c:	68 75 28 80 00       	push   $0x802875
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
  80009d:	68 8e 28 80 00       	push   $0x80288e
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 85 13 00 00       	call   801437 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 ab 28 80 00       	push   $0x8028ab
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 28 15 00 00       	call   801604 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 c8 28 80 00       	push   $0x8028c8
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 75 28 80 00       	push   $0x802875
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
  800118:	68 d1 28 80 00       	push   $0x8028d1
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 ed 28 80 00       	push   $0x8028ed
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
  800155:	68 8e 28 80 00       	push   $0x80288e
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 cd 12 00 00       	call   801437 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 08 40 80 00       	mov    0x804008,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 00 29 80 00       	push   $0x802900
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a6 07 00 00       	call   800937 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 aa 14 00 00       	call   80164d <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 84 07 00 00       	call   800937 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 1d 29 80 00       	push   $0x80291d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 75 28 80 00       	push   $0x802875
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 60 12 00 00       	call   801437 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 75 20 00 00       	call   802258 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 27 	movl   $0x802927,0x803004
  8001ea:	29 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 da 1e 00 00       	call   8020d2 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 6c 28 80 00       	push   $0x80286c
  800207:	6a 2c                	push   $0x2c
  800209:	68 75 28 80 00       	push   $0x802875
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 c8 0e 00 00       	call   8010e0 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 85 28 80 00       	push   $0x802885
  800224:	6a 2f                	push   $0x2f
  800226:	68 75 28 80 00       	push   $0x802875
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 f8 11 00 00       	call   801437 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 34 29 80 00       	push   $0x802934
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 36 29 80 00       	push   $0x802936
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 ec 13 00 00       	call   80164d <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 38 29 80 00       	push   $0x802938
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 ae 11 00 00       	call   801437 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 a3 11 00 00       	call   801437 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 bc 1f 00 00       	call   802258 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 55 29 80 00 	movl   $0x802955,(%esp)
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
  8002fe:	e8 5f 11 00 00       	call   801462 <close_all>
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
  800330:	68 b8 29 80 00       	push   $0x8029b8
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 a9 28 80 00 	movl   $0x8028a9,(%esp)
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
  80044e:	e8 7d 21 00 00       	call   8025d0 <__udivdi3>
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
  800491:	e8 6a 22 00 00       	call   802700 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 db 29 80 00 	movsbl 0x8029db(%eax),%eax
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
  800595:	ff 24 85 20 2b 80 00 	jmp    *0x802b20(,%eax,4)
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
  800659:	8b 14 85 80 2c 80 00 	mov    0x802c80(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 f3 29 80 00       	push   $0x8029f3
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
  80067d:	68 71 2e 80 00       	push   $0x802e71
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
  8006a1:	b8 ec 29 80 00       	mov    $0x8029ec,%eax
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
  800d1c:	68 df 2c 80 00       	push   $0x802cdf
  800d21:	6a 23                	push   $0x23
  800d23:	68 fc 2c 80 00       	push   $0x802cfc
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
  800d9d:	68 df 2c 80 00       	push   $0x802cdf
  800da2:	6a 23                	push   $0x23
  800da4:	68 fc 2c 80 00       	push   $0x802cfc
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
  800ddf:	68 df 2c 80 00       	push   $0x802cdf
  800de4:	6a 23                	push   $0x23
  800de6:	68 fc 2c 80 00       	push   $0x802cfc
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
  800e21:	68 df 2c 80 00       	push   $0x802cdf
  800e26:	6a 23                	push   $0x23
  800e28:	68 fc 2c 80 00       	push   $0x802cfc
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
  800e63:	68 df 2c 80 00       	push   $0x802cdf
  800e68:	6a 23                	push   $0x23
  800e6a:	68 fc 2c 80 00       	push   $0x802cfc
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
  800ea5:	68 df 2c 80 00       	push   $0x802cdf
  800eaa:	6a 23                	push   $0x23
  800eac:	68 fc 2c 80 00       	push   $0x802cfc
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
  800ee7:	68 df 2c 80 00       	push   $0x802cdf
  800eec:	6a 23                	push   $0x23
  800eee:	68 fc 2c 80 00       	push   $0x802cfc
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
  800f4b:	68 df 2c 80 00       	push   $0x802cdf
  800f50:	6a 23                	push   $0x23
  800f52:	68 fc 2c 80 00       	push   $0x802cfc
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

00800f83 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f91:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	89 df                	mov    %ebx,%edi
  800f9e:	89 de                	mov    %ebx,%esi
  800fa0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	7e 17                	jle    800fbd <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa6:	83 ec 0c             	sub    $0xc,%esp
  800fa9:	50                   	push   %eax
  800faa:	6a 0f                	push   $0xf
  800fac:	68 df 2c 80 00       	push   $0x802cdf
  800fb1:	6a 23                	push   $0x23
  800fb3:	68 fc 2c 80 00       	push   $0x802cfc
  800fb8:	e8 55 f3 ff ff       	call   800312 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800fbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	57                   	push   %edi
  800fc9:	56                   	push   %esi
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd3:	b8 10 00 00 00       	mov    $0x10,%eax
  800fd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fde:	89 df                	mov    %ebx,%edi
  800fe0:	89 de                	mov    %ebx,%esi
  800fe2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	7e 17                	jle    800fff <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	50                   	push   %eax
  800fec:	6a 10                	push   $0x10
  800fee:	68 df 2c 80 00       	push   $0x802cdf
  800ff3:	6a 23                	push   $0x23
  800ff5:	68 fc 2c 80 00       	push   $0x802cfc
  800ffa:	e8 13 f3 ff ff       	call   800312 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800fff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5f                   	pop    %edi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
  80100c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80100f:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  801011:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801015:	75 25                	jne    80103c <pgfault+0x35>
  801017:	89 d8                	mov    %ebx,%eax
  801019:	c1 e8 0c             	shr    $0xc,%eax
  80101c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801023:	f6 c4 08             	test   $0x8,%ah
  801026:	75 14                	jne    80103c <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	68 0c 2d 80 00       	push   $0x802d0c
  801030:	6a 1e                	push   $0x1e
  801032:	68 a0 2d 80 00       	push   $0x802da0
  801037:	e8 d6 f2 ff ff       	call   800312 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  80103c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  801042:	e8 ee fc ff ff       	call   800d35 <sys_getenvid>
  801047:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  801049:	83 ec 04             	sub    $0x4,%esp
  80104c:	6a 07                	push   $0x7
  80104e:	68 00 f0 7f 00       	push   $0x7ff000
  801053:	50                   	push   %eax
  801054:	e8 1a fd ff ff       	call   800d73 <sys_page_alloc>
	if (r < 0)
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	79 12                	jns    801072 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  801060:	50                   	push   %eax
  801061:	68 38 2d 80 00       	push   $0x802d38
  801066:	6a 33                	push   $0x33
  801068:	68 a0 2d 80 00       	push   $0x802da0
  80106d:	e8 a0 f2 ff ff       	call   800312 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	68 00 10 00 00       	push   $0x1000
  80107a:	53                   	push   %ebx
  80107b:	68 00 f0 7f 00       	push   $0x7ff000
  801080:	e8 e5 fa ff ff       	call   800b6a <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  801085:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80108c:	53                   	push   %ebx
  80108d:	56                   	push   %esi
  80108e:	68 00 f0 7f 00       	push   $0x7ff000
  801093:	56                   	push   %esi
  801094:	e8 1d fd ff ff       	call   800db6 <sys_page_map>
	if (r < 0)
  801099:	83 c4 20             	add    $0x20,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	79 12                	jns    8010b2 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  8010a0:	50                   	push   %eax
  8010a1:	68 5c 2d 80 00       	push   $0x802d5c
  8010a6:	6a 3b                	push   $0x3b
  8010a8:	68 a0 2d 80 00       	push   $0x802da0
  8010ad:	e8 60 f2 ff ff       	call   800312 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  8010b2:	83 ec 08             	sub    $0x8,%esp
  8010b5:	68 00 f0 7f 00       	push   $0x7ff000
  8010ba:	56                   	push   %esi
  8010bb:	e8 38 fd ff ff       	call   800df8 <sys_page_unmap>
	if (r < 0)
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	79 12                	jns    8010d9 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  8010c7:	50                   	push   %eax
  8010c8:	68 80 2d 80 00       	push   $0x802d80
  8010cd:	6a 40                	push   $0x40
  8010cf:	68 a0 2d 80 00       	push   $0x802da0
  8010d4:	e8 39 f2 ff ff       	call   800312 <_panic>
}
  8010d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  8010e9:	68 07 10 80 00       	push   $0x801007
  8010ee:	e8 37 13 00 00       	call   80242a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010f3:	b8 07 00 00 00       	mov    $0x7,%eax
  8010f8:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	0f 88 64 01 00 00    	js     801269 <fork+0x189>
  801105:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80110a:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80110f:	85 c0                	test   %eax,%eax
  801111:	75 21                	jne    801134 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801113:	e8 1d fc ff ff       	call   800d35 <sys_getenvid>
  801118:	25 ff 03 00 00       	and    $0x3ff,%eax
  80111d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801125:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  80112a:	ba 00 00 00 00       	mov    $0x0,%edx
  80112f:	e9 3f 01 00 00       	jmp    801273 <fork+0x193>
  801134:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801137:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801139:	89 d8                	mov    %ebx,%eax
  80113b:	c1 e8 16             	shr    $0x16,%eax
  80113e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801145:	a8 01                	test   $0x1,%al
  801147:	0f 84 bd 00 00 00    	je     80120a <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80114d:	89 d8                	mov    %ebx,%eax
  80114f:	c1 e8 0c             	shr    $0xc,%eax
  801152:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801159:	f6 c2 01             	test   $0x1,%dl
  80115c:	0f 84 a8 00 00 00    	je     80120a <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801162:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801169:	a8 04                	test   $0x4,%al
  80116b:	0f 84 99 00 00 00    	je     80120a <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801171:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801178:	f6 c4 04             	test   $0x4,%ah
  80117b:	74 17                	je     801194 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	68 07 0e 00 00       	push   $0xe07
  801185:	53                   	push   %ebx
  801186:	57                   	push   %edi
  801187:	53                   	push   %ebx
  801188:	6a 00                	push   $0x0
  80118a:	e8 27 fc ff ff       	call   800db6 <sys_page_map>
  80118f:	83 c4 20             	add    $0x20,%esp
  801192:	eb 76                	jmp    80120a <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801194:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80119b:	a8 02                	test   $0x2,%al
  80119d:	75 0c                	jne    8011ab <fork+0xcb>
  80119f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011a6:	f6 c4 08             	test   $0x8,%ah
  8011a9:	74 3f                	je     8011ea <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	68 05 08 00 00       	push   $0x805
  8011b3:	53                   	push   %ebx
  8011b4:	57                   	push   %edi
  8011b5:	53                   	push   %ebx
  8011b6:	6a 00                	push   $0x0
  8011b8:	e8 f9 fb ff ff       	call   800db6 <sys_page_map>
		if (r < 0)
  8011bd:	83 c4 20             	add    $0x20,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	0f 88 a5 00 00 00    	js     80126d <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8011c8:	83 ec 0c             	sub    $0xc,%esp
  8011cb:	68 05 08 00 00       	push   $0x805
  8011d0:	53                   	push   %ebx
  8011d1:	6a 00                	push   $0x0
  8011d3:	53                   	push   %ebx
  8011d4:	6a 00                	push   $0x0
  8011d6:	e8 db fb ff ff       	call   800db6 <sys_page_map>
  8011db:	83 c4 20             	add    $0x20,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e5:	0f 4f c1             	cmovg  %ecx,%eax
  8011e8:	eb 1c                	jmp    801206 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8011ea:	83 ec 0c             	sub    $0xc,%esp
  8011ed:	6a 05                	push   $0x5
  8011ef:	53                   	push   %ebx
  8011f0:	57                   	push   %edi
  8011f1:	53                   	push   %ebx
  8011f2:	6a 00                	push   $0x0
  8011f4:	e8 bd fb ff ff       	call   800db6 <sys_page_map>
  8011f9:	83 c4 20             	add    $0x20,%esp
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801203:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801206:	85 c0                	test   %eax,%eax
  801208:	78 67                	js     801271 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80120a:	83 c6 01             	add    $0x1,%esi
  80120d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801213:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801219:	0f 85 1a ff ff ff    	jne    801139 <fork+0x59>
  80121f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	6a 07                	push   $0x7
  801227:	68 00 f0 bf ee       	push   $0xeebff000
  80122c:	57                   	push   %edi
  80122d:	e8 41 fb ff ff       	call   800d73 <sys_page_alloc>
	if (r < 0)
  801232:	83 c4 10             	add    $0x10,%esp
		return r;
  801235:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801237:	85 c0                	test   %eax,%eax
  801239:	78 38                	js     801273 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	68 71 24 80 00       	push   $0x802471
  801243:	57                   	push   %edi
  801244:	e8 75 fc ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
	if (r < 0)
  801249:	83 c4 10             	add    $0x10,%esp
		return r;
  80124c:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 21                	js     801273 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801252:	83 ec 08             	sub    $0x8,%esp
  801255:	6a 02                	push   $0x2
  801257:	57                   	push   %edi
  801258:	e8 dd fb ff ff       	call   800e3a <sys_env_set_status>
	if (r < 0)
  80125d:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801260:	85 c0                	test   %eax,%eax
  801262:	0f 48 f8             	cmovs  %eax,%edi
  801265:	89 fa                	mov    %edi,%edx
  801267:	eb 0a                	jmp    801273 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801269:	89 c2                	mov    %eax,%edx
  80126b:	eb 06                	jmp    801273 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	eb 02                	jmp    801273 <fork+0x193>
  801271:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801273:	89 d0                	mov    %edx,%eax
  801275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sfork>:

// Challenge!
int
sfork(void)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801283:	68 ab 2d 80 00       	push   $0x802dab
  801288:	68 c9 00 00 00       	push   $0xc9
  80128d:	68 a0 2d 80 00       	push   $0x802da0
  801292:	e8 7b f0 ff ff       	call   800312 <_panic>

00801297 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80129a:	8b 45 08             	mov    0x8(%ebp),%eax
  80129d:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a2:	c1 e8 0c             	shr    $0xc,%eax
}
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8012b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012b7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	c1 ea 16             	shr    $0x16,%edx
  8012ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d5:	f6 c2 01             	test   $0x1,%dl
  8012d8:	74 11                	je     8012eb <fd_alloc+0x2d>
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	c1 ea 0c             	shr    $0xc,%edx
  8012df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e6:	f6 c2 01             	test   $0x1,%dl
  8012e9:	75 09                	jne    8012f4 <fd_alloc+0x36>
			*fd_store = fd;
  8012eb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f2:	eb 17                	jmp    80130b <fd_alloc+0x4d>
  8012f4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012f9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012fe:	75 c9                	jne    8012c9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801300:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801306:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801313:	83 f8 1f             	cmp    $0x1f,%eax
  801316:	77 36                	ja     80134e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801318:	c1 e0 0c             	shl    $0xc,%eax
  80131b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801320:	89 c2                	mov    %eax,%edx
  801322:	c1 ea 16             	shr    $0x16,%edx
  801325:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80132c:	f6 c2 01             	test   $0x1,%dl
  80132f:	74 24                	je     801355 <fd_lookup+0x48>
  801331:	89 c2                	mov    %eax,%edx
  801333:	c1 ea 0c             	shr    $0xc,%edx
  801336:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80133d:	f6 c2 01             	test   $0x1,%dl
  801340:	74 1a                	je     80135c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801342:	8b 55 0c             	mov    0xc(%ebp),%edx
  801345:	89 02                	mov    %eax,(%edx)
	return 0;
  801347:	b8 00 00 00 00       	mov    $0x0,%eax
  80134c:	eb 13                	jmp    801361 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80134e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801353:	eb 0c                	jmp    801361 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801355:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135a:	eb 05                	jmp    801361 <fd_lookup+0x54>
  80135c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136c:	ba 44 2e 80 00       	mov    $0x802e44,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801371:	eb 13                	jmp    801386 <dev_lookup+0x23>
  801373:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801376:	39 08                	cmp    %ecx,(%eax)
  801378:	75 0c                	jne    801386 <dev_lookup+0x23>
			*dev = devtab[i];
  80137a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80137f:	b8 00 00 00 00       	mov    $0x0,%eax
  801384:	eb 2e                	jmp    8013b4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801386:	8b 02                	mov    (%edx),%eax
  801388:	85 c0                	test   %eax,%eax
  80138a:	75 e7                	jne    801373 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80138c:	a1 08 40 80 00       	mov    0x804008,%eax
  801391:	8b 40 48             	mov    0x48(%eax),%eax
  801394:	83 ec 04             	sub    $0x4,%esp
  801397:	51                   	push   %ecx
  801398:	50                   	push   %eax
  801399:	68 c4 2d 80 00       	push   $0x802dc4
  80139e:	e8 48 f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  8013a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013b4:	c9                   	leave  
  8013b5:	c3                   	ret    

008013b6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	56                   	push   %esi
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 10             	sub    $0x10,%esp
  8013be:	8b 75 08             	mov    0x8(%ebp),%esi
  8013c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c7:	50                   	push   %eax
  8013c8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ce:	c1 e8 0c             	shr    $0xc,%eax
  8013d1:	50                   	push   %eax
  8013d2:	e8 36 ff ff ff       	call   80130d <fd_lookup>
  8013d7:	83 c4 08             	add    $0x8,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 05                	js     8013e3 <fd_close+0x2d>
	    || fd != fd2)
  8013de:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013e1:	74 0c                	je     8013ef <fd_close+0x39>
		return (must_exist ? r : 0);
  8013e3:	84 db                	test   %bl,%bl
  8013e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ea:	0f 44 c2             	cmove  %edx,%eax
  8013ed:	eb 41                	jmp    801430 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	ff 36                	pushl  (%esi)
  8013f8:	e8 66 ff ff ff       	call   801363 <dev_lookup>
  8013fd:	89 c3                	mov    %eax,%ebx
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	85 c0                	test   %eax,%eax
  801404:	78 1a                	js     801420 <fd_close+0x6a>
		if (dev->dev_close)
  801406:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801409:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80140c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801411:	85 c0                	test   %eax,%eax
  801413:	74 0b                	je     801420 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801415:	83 ec 0c             	sub    $0xc,%esp
  801418:	56                   	push   %esi
  801419:	ff d0                	call   *%eax
  80141b:	89 c3                	mov    %eax,%ebx
  80141d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	56                   	push   %esi
  801424:	6a 00                	push   $0x0
  801426:	e8 cd f9 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	89 d8                	mov    %ebx,%eax
}
  801430:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801433:	5b                   	pop    %ebx
  801434:	5e                   	pop    %esi
  801435:	5d                   	pop    %ebp
  801436:	c3                   	ret    

00801437 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	ff 75 08             	pushl  0x8(%ebp)
  801444:	e8 c4 fe ff ff       	call   80130d <fd_lookup>
  801449:	83 c4 08             	add    $0x8,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 10                	js     801460 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	6a 01                	push   $0x1
  801455:	ff 75 f4             	pushl  -0xc(%ebp)
  801458:	e8 59 ff ff ff       	call   8013b6 <fd_close>
  80145d:	83 c4 10             	add    $0x10,%esp
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <close_all>:

void
close_all(void)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	53                   	push   %ebx
  801466:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801469:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80146e:	83 ec 0c             	sub    $0xc,%esp
  801471:	53                   	push   %ebx
  801472:	e8 c0 ff ff ff       	call   801437 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801477:	83 c3 01             	add    $0x1,%ebx
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	83 fb 20             	cmp    $0x20,%ebx
  801480:	75 ec                	jne    80146e <close_all+0xc>
		close(i);
}
  801482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801485:	c9                   	leave  
  801486:	c3                   	ret    

00801487 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	57                   	push   %edi
  80148b:	56                   	push   %esi
  80148c:	53                   	push   %ebx
  80148d:	83 ec 2c             	sub    $0x2c,%esp
  801490:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801493:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	ff 75 08             	pushl  0x8(%ebp)
  80149a:	e8 6e fe ff ff       	call   80130d <fd_lookup>
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	0f 88 c1 00 00 00    	js     80156b <dup+0xe4>
		return r;
	close(newfdnum);
  8014aa:	83 ec 0c             	sub    $0xc,%esp
  8014ad:	56                   	push   %esi
  8014ae:	e8 84 ff ff ff       	call   801437 <close>

	newfd = INDEX2FD(newfdnum);
  8014b3:	89 f3                	mov    %esi,%ebx
  8014b5:	c1 e3 0c             	shl    $0xc,%ebx
  8014b8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014be:	83 c4 04             	add    $0x4,%esp
  8014c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c4:	e8 de fd ff ff       	call   8012a7 <fd2data>
  8014c9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014cb:	89 1c 24             	mov    %ebx,(%esp)
  8014ce:	e8 d4 fd ff ff       	call   8012a7 <fd2data>
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014d9:	89 f8                	mov    %edi,%eax
  8014db:	c1 e8 16             	shr    $0x16,%eax
  8014de:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014e5:	a8 01                	test   $0x1,%al
  8014e7:	74 37                	je     801520 <dup+0x99>
  8014e9:	89 f8                	mov    %edi,%eax
  8014eb:	c1 e8 0c             	shr    $0xc,%eax
  8014ee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014f5:	f6 c2 01             	test   $0x1,%dl
  8014f8:	74 26                	je     801520 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801501:	83 ec 0c             	sub    $0xc,%esp
  801504:	25 07 0e 00 00       	and    $0xe07,%eax
  801509:	50                   	push   %eax
  80150a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80150d:	6a 00                	push   $0x0
  80150f:	57                   	push   %edi
  801510:	6a 00                	push   $0x0
  801512:	e8 9f f8 ff ff       	call   800db6 <sys_page_map>
  801517:	89 c7                	mov    %eax,%edi
  801519:	83 c4 20             	add    $0x20,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 2e                	js     80154e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801520:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801523:	89 d0                	mov    %edx,%eax
  801525:	c1 e8 0c             	shr    $0xc,%eax
  801528:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	25 07 0e 00 00       	and    $0xe07,%eax
  801537:	50                   	push   %eax
  801538:	53                   	push   %ebx
  801539:	6a 00                	push   $0x0
  80153b:	52                   	push   %edx
  80153c:	6a 00                	push   $0x0
  80153e:	e8 73 f8 ff ff       	call   800db6 <sys_page_map>
  801543:	89 c7                	mov    %eax,%edi
  801545:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801548:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80154a:	85 ff                	test   %edi,%edi
  80154c:	79 1d                	jns    80156b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	53                   	push   %ebx
  801552:	6a 00                	push   $0x0
  801554:	e8 9f f8 ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801559:	83 c4 08             	add    $0x8,%esp
  80155c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80155f:	6a 00                	push   $0x0
  801561:	e8 92 f8 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	89 f8                	mov    %edi,%eax
}
  80156b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 14             	sub    $0x14,%esp
  80157a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	53                   	push   %ebx
  801582:	e8 86 fd ff ff       	call   80130d <fd_lookup>
  801587:	83 c4 08             	add    $0x8,%esp
  80158a:	89 c2                	mov    %eax,%edx
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 6d                	js     8015fd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801590:	83 ec 08             	sub    $0x8,%esp
  801593:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159a:	ff 30                	pushl  (%eax)
  80159c:	e8 c2 fd ff ff       	call   801363 <dev_lookup>
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 4c                	js     8015f4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ab:	8b 42 08             	mov    0x8(%edx),%eax
  8015ae:	83 e0 03             	and    $0x3,%eax
  8015b1:	83 f8 01             	cmp    $0x1,%eax
  8015b4:	75 21                	jne    8015d7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b6:	a1 08 40 80 00       	mov    0x804008,%eax
  8015bb:	8b 40 48             	mov    0x48(%eax),%eax
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	50                   	push   %eax
  8015c3:	68 08 2e 80 00       	push   $0x802e08
  8015c8:	e8 1e ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d5:	eb 26                	jmp    8015fd <read+0x8a>
	}
	if (!dev->dev_read)
  8015d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015da:	8b 40 08             	mov    0x8(%eax),%eax
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	74 17                	je     8015f8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015e1:	83 ec 04             	sub    $0x4,%esp
  8015e4:	ff 75 10             	pushl  0x10(%ebp)
  8015e7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ea:	52                   	push   %edx
  8015eb:	ff d0                	call   *%eax
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	eb 09                	jmp    8015fd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f4:	89 c2                	mov    %eax,%edx
  8015f6:	eb 05                	jmp    8015fd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015fd:	89 d0                	mov    %edx,%eax
  8015ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	57                   	push   %edi
  801608:	56                   	push   %esi
  801609:	53                   	push   %ebx
  80160a:	83 ec 0c             	sub    $0xc,%esp
  80160d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801610:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801613:	bb 00 00 00 00       	mov    $0x0,%ebx
  801618:	eb 21                	jmp    80163b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80161a:	83 ec 04             	sub    $0x4,%esp
  80161d:	89 f0                	mov    %esi,%eax
  80161f:	29 d8                	sub    %ebx,%eax
  801621:	50                   	push   %eax
  801622:	89 d8                	mov    %ebx,%eax
  801624:	03 45 0c             	add    0xc(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	57                   	push   %edi
  801629:	e8 45 ff ff ff       	call   801573 <read>
		if (m < 0)
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 10                	js     801645 <readn+0x41>
			return m;
		if (m == 0)
  801635:	85 c0                	test   %eax,%eax
  801637:	74 0a                	je     801643 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801639:	01 c3                	add    %eax,%ebx
  80163b:	39 f3                	cmp    %esi,%ebx
  80163d:	72 db                	jb     80161a <readn+0x16>
  80163f:	89 d8                	mov    %ebx,%eax
  801641:	eb 02                	jmp    801645 <readn+0x41>
  801643:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801645:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801648:	5b                   	pop    %ebx
  801649:	5e                   	pop    %esi
  80164a:	5f                   	pop    %edi
  80164b:	5d                   	pop    %ebp
  80164c:	c3                   	ret    

0080164d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	53                   	push   %ebx
  801651:	83 ec 14             	sub    $0x14,%esp
  801654:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801657:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165a:	50                   	push   %eax
  80165b:	53                   	push   %ebx
  80165c:	e8 ac fc ff ff       	call   80130d <fd_lookup>
  801661:	83 c4 08             	add    $0x8,%esp
  801664:	89 c2                	mov    %eax,%edx
  801666:	85 c0                	test   %eax,%eax
  801668:	78 68                	js     8016d2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801674:	ff 30                	pushl  (%eax)
  801676:	e8 e8 fc ff ff       	call   801363 <dev_lookup>
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 47                	js     8016c9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801682:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801685:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801689:	75 21                	jne    8016ac <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80168b:	a1 08 40 80 00       	mov    0x804008,%eax
  801690:	8b 40 48             	mov    0x48(%eax),%eax
  801693:	83 ec 04             	sub    $0x4,%esp
  801696:	53                   	push   %ebx
  801697:	50                   	push   %eax
  801698:	68 24 2e 80 00       	push   $0x802e24
  80169d:	e8 49 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016aa:	eb 26                	jmp    8016d2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016af:	8b 52 0c             	mov    0xc(%edx),%edx
  8016b2:	85 d2                	test   %edx,%edx
  8016b4:	74 17                	je     8016cd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016b6:	83 ec 04             	sub    $0x4,%esp
  8016b9:	ff 75 10             	pushl  0x10(%ebp)
  8016bc:	ff 75 0c             	pushl  0xc(%ebp)
  8016bf:	50                   	push   %eax
  8016c0:	ff d2                	call   *%edx
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	eb 09                	jmp    8016d2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	eb 05                	jmp    8016d2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016d2:	89 d0                	mov    %edx,%eax
  8016d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016df:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	ff 75 08             	pushl  0x8(%ebp)
  8016e6:	e8 22 fc ff ff       	call   80130d <fd_lookup>
  8016eb:	83 c4 08             	add    $0x8,%esp
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 0e                	js     801700 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801700:	c9                   	leave  
  801701:	c3                   	ret    

00801702 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	53                   	push   %ebx
  801706:	83 ec 14             	sub    $0x14,%esp
  801709:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	53                   	push   %ebx
  801711:	e8 f7 fb ff ff       	call   80130d <fd_lookup>
  801716:	83 c4 08             	add    $0x8,%esp
  801719:	89 c2                	mov    %eax,%edx
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 65                	js     801784 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801729:	ff 30                	pushl  (%eax)
  80172b:	e8 33 fc ff ff       	call   801363 <dev_lookup>
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	85 c0                	test   %eax,%eax
  801735:	78 44                	js     80177b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80173e:	75 21                	jne    801761 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801740:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801745:	8b 40 48             	mov    0x48(%eax),%eax
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	53                   	push   %ebx
  80174c:	50                   	push   %eax
  80174d:	68 e4 2d 80 00       	push   $0x802de4
  801752:	e8 94 ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80175f:	eb 23                	jmp    801784 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801761:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801764:	8b 52 18             	mov    0x18(%edx),%edx
  801767:	85 d2                	test   %edx,%edx
  801769:	74 14                	je     80177f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	ff 75 0c             	pushl  0xc(%ebp)
  801771:	50                   	push   %eax
  801772:	ff d2                	call   *%edx
  801774:	89 c2                	mov    %eax,%edx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	eb 09                	jmp    801784 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	eb 05                	jmp    801784 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80177f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801784:	89 d0                	mov    %edx,%eax
  801786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	53                   	push   %ebx
  80178f:	83 ec 14             	sub    $0x14,%esp
  801792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801795:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801798:	50                   	push   %eax
  801799:	ff 75 08             	pushl  0x8(%ebp)
  80179c:	e8 6c fb ff ff       	call   80130d <fd_lookup>
  8017a1:	83 c4 08             	add    $0x8,%esp
  8017a4:	89 c2                	mov    %eax,%edx
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 58                	js     801802 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b0:	50                   	push   %eax
  8017b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b4:	ff 30                	pushl  (%eax)
  8017b6:	e8 a8 fb ff ff       	call   801363 <dev_lookup>
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 37                	js     8017f9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017c9:	74 32                	je     8017fd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017cb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ce:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017d5:	00 00 00 
	stat->st_isdir = 0;
  8017d8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017df:	00 00 00 
	stat->st_dev = dev;
  8017e2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	53                   	push   %ebx
  8017ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ef:	ff 50 14             	call   *0x14(%eax)
  8017f2:	89 c2                	mov    %eax,%edx
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	eb 09                	jmp    801802 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f9:	89 c2                	mov    %eax,%edx
  8017fb:	eb 05                	jmp    801802 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801802:	89 d0                	mov    %edx,%eax
  801804:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	56                   	push   %esi
  80180d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	6a 00                	push   $0x0
  801813:	ff 75 08             	pushl  0x8(%ebp)
  801816:	e8 d6 01 00 00       	call   8019f1 <open>
  80181b:	89 c3                	mov    %eax,%ebx
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	85 c0                	test   %eax,%eax
  801822:	78 1b                	js     80183f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	ff 75 0c             	pushl  0xc(%ebp)
  80182a:	50                   	push   %eax
  80182b:	e8 5b ff ff ff       	call   80178b <fstat>
  801830:	89 c6                	mov    %eax,%esi
	close(fd);
  801832:	89 1c 24             	mov    %ebx,(%esp)
  801835:	e8 fd fb ff ff       	call   801437 <close>
	return r;
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	89 f0                	mov    %esi,%eax
}
  80183f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	89 c6                	mov    %eax,%esi
  80184d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80184f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801856:	75 12                	jne    80186a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801858:	83 ec 0c             	sub    $0xc,%esp
  80185b:	6a 01                	push   $0x1
  80185d:	e8 ee 0c 00 00       	call   802550 <ipc_find_env>
  801862:	a3 00 40 80 00       	mov    %eax,0x804000
  801867:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80186a:	6a 07                	push   $0x7
  80186c:	68 00 50 80 00       	push   $0x805000
  801871:	56                   	push   %esi
  801872:	ff 35 00 40 80 00    	pushl  0x804000
  801878:	e8 7f 0c 00 00       	call   8024fc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80187d:	83 c4 0c             	add    $0xc,%esp
  801880:	6a 00                	push   $0x0
  801882:	53                   	push   %ebx
  801883:	6a 00                	push   $0x0
  801885:	e8 0b 0c 00 00       	call   802495 <ipc_recv>
}
  80188a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188d:	5b                   	pop    %ebx
  80188e:	5e                   	pop    %esi
  80188f:	5d                   	pop    %ebp
  801890:	c3                   	ret    

00801891 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801897:	8b 45 08             	mov    0x8(%ebp),%eax
  80189a:	8b 40 0c             	mov    0xc(%eax),%eax
  80189d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018af:	b8 02 00 00 00       	mov    $0x2,%eax
  8018b4:	e8 8d ff ff ff       	call   801846 <fsipc>
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d1:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d6:	e8 6b ff ff ff       	call   801846 <fsipc>
}
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 04             	sub    $0x4,%esp
  8018e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018fc:	e8 45 ff ff ff       	call   801846 <fsipc>
  801901:	85 c0                	test   %eax,%eax
  801903:	78 2c                	js     801931 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801905:	83 ec 08             	sub    $0x8,%esp
  801908:	68 00 50 80 00       	push   $0x805000
  80190d:	53                   	push   %ebx
  80190e:	e8 5d f0 ff ff       	call   800970 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801913:	a1 80 50 80 00       	mov    0x805080,%eax
  801918:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80191e:	a1 84 50 80 00       	mov    0x805084,%eax
  801923:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 0c             	sub    $0xc,%esp
  80193c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80193f:	8b 55 08             	mov    0x8(%ebp),%edx
  801942:	8b 52 0c             	mov    0xc(%edx),%edx
  801945:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80194b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801950:	50                   	push   %eax
  801951:	ff 75 0c             	pushl  0xc(%ebp)
  801954:	68 08 50 80 00       	push   $0x805008
  801959:	e8 a4 f1 ff ff       	call   800b02 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80195e:	ba 00 00 00 00       	mov    $0x0,%edx
  801963:	b8 04 00 00 00       	mov    $0x4,%eax
  801968:	e8 d9 fe ff ff       	call   801846 <fsipc>

}
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801977:	8b 45 08             	mov    0x8(%ebp),%eax
  80197a:	8b 40 0c             	mov    0xc(%eax),%eax
  80197d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801982:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801988:	ba 00 00 00 00       	mov    $0x0,%edx
  80198d:	b8 03 00 00 00       	mov    $0x3,%eax
  801992:	e8 af fe ff ff       	call   801846 <fsipc>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 4b                	js     8019e8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80199d:	39 c6                	cmp    %eax,%esi
  80199f:	73 16                	jae    8019b7 <devfile_read+0x48>
  8019a1:	68 58 2e 80 00       	push   $0x802e58
  8019a6:	68 5f 2e 80 00       	push   $0x802e5f
  8019ab:	6a 7c                	push   $0x7c
  8019ad:	68 74 2e 80 00       	push   $0x802e74
  8019b2:	e8 5b e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  8019b7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019bc:	7e 16                	jle    8019d4 <devfile_read+0x65>
  8019be:	68 7f 2e 80 00       	push   $0x802e7f
  8019c3:	68 5f 2e 80 00       	push   $0x802e5f
  8019c8:	6a 7d                	push   $0x7d
  8019ca:	68 74 2e 80 00       	push   $0x802e74
  8019cf:	e8 3e e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019d4:	83 ec 04             	sub    $0x4,%esp
  8019d7:	50                   	push   %eax
  8019d8:	68 00 50 80 00       	push   $0x805000
  8019dd:	ff 75 0c             	pushl  0xc(%ebp)
  8019e0:	e8 1d f1 ff ff       	call   800b02 <memmove>
	return r;
  8019e5:	83 c4 10             	add    $0x10,%esp
}
  8019e8:	89 d8                	mov    %ebx,%eax
  8019ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ed:	5b                   	pop    %ebx
  8019ee:	5e                   	pop    %esi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	53                   	push   %ebx
  8019f5:	83 ec 20             	sub    $0x20,%esp
  8019f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019fb:	53                   	push   %ebx
  8019fc:	e8 36 ef ff ff       	call   800937 <strlen>
  801a01:	83 c4 10             	add    $0x10,%esp
  801a04:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a09:	7f 67                	jg     801a72 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0b:	83 ec 0c             	sub    $0xc,%esp
  801a0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a11:	50                   	push   %eax
  801a12:	e8 a7 f8 ff ff       	call   8012be <fd_alloc>
  801a17:	83 c4 10             	add    $0x10,%esp
		return r;
  801a1a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	78 57                	js     801a77 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a20:	83 ec 08             	sub    $0x8,%esp
  801a23:	53                   	push   %ebx
  801a24:	68 00 50 80 00       	push   $0x805000
  801a29:	e8 42 ef ff ff       	call   800970 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a31:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a39:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3e:	e8 03 fe ff ff       	call   801846 <fsipc>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	79 14                	jns    801a60 <open+0x6f>
		fd_close(fd, 0);
  801a4c:	83 ec 08             	sub    $0x8,%esp
  801a4f:	6a 00                	push   $0x0
  801a51:	ff 75 f4             	pushl  -0xc(%ebp)
  801a54:	e8 5d f9 ff ff       	call   8013b6 <fd_close>
		return r;
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	89 da                	mov    %ebx,%edx
  801a5e:	eb 17                	jmp    801a77 <open+0x86>
	}

	return fd2num(fd);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	ff 75 f4             	pushl  -0xc(%ebp)
  801a66:	e8 2c f8 ff ff       	call   801297 <fd2num>
  801a6b:	89 c2                	mov    %eax,%edx
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	eb 05                	jmp    801a77 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a72:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a77:	89 d0                	mov    %edx,%eax
  801a79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a84:	ba 00 00 00 00       	mov    $0x0,%edx
  801a89:	b8 08 00 00 00       	mov    $0x8,%eax
  801a8e:	e8 b3 fd ff ff       	call   801846 <fsipc>
}
  801a93:	c9                   	leave  
  801a94:	c3                   	ret    

00801a95 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a9b:	68 8b 2e 80 00       	push   $0x802e8b
  801aa0:	ff 75 0c             	pushl  0xc(%ebp)
  801aa3:	e8 c8 ee ff ff       	call   800970 <strcpy>
	return 0;
}
  801aa8:	b8 00 00 00 00       	mov    $0x0,%eax
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    

00801aaf <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 10             	sub    $0x10,%esp
  801ab6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ab9:	53                   	push   %ebx
  801aba:	e8 ca 0a 00 00       	call   802589 <pageref>
  801abf:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ac2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ac7:	83 f8 01             	cmp    $0x1,%eax
  801aca:	75 10                	jne    801adc <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	ff 73 0c             	pushl  0xc(%ebx)
  801ad2:	e8 c0 02 00 00       	call   801d97 <nsipc_close>
  801ad7:	89 c2                	mov    %eax,%edx
  801ad9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801adc:	89 d0                	mov    %edx,%eax
  801ade:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ae9:	6a 00                	push   $0x0
  801aeb:	ff 75 10             	pushl  0x10(%ebp)
  801aee:	ff 75 0c             	pushl  0xc(%ebp)
  801af1:	8b 45 08             	mov    0x8(%ebp),%eax
  801af4:	ff 70 0c             	pushl  0xc(%eax)
  801af7:	e8 78 03 00 00       	call   801e74 <nsipc_send>
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b04:	6a 00                	push   $0x0
  801b06:	ff 75 10             	pushl  0x10(%ebp)
  801b09:	ff 75 0c             	pushl  0xc(%ebp)
  801b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0f:	ff 70 0c             	pushl  0xc(%eax)
  801b12:	e8 f1 02 00 00       	call   801e08 <nsipc_recv>
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b1f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b22:	52                   	push   %edx
  801b23:	50                   	push   %eax
  801b24:	e8 e4 f7 ff ff       	call   80130d <fd_lookup>
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	78 17                	js     801b47 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b33:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801b39:	39 08                	cmp    %ecx,(%eax)
  801b3b:	75 05                	jne    801b42 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b40:	eb 05                	jmp    801b47 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b42:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	83 ec 1c             	sub    $0x1c,%esp
  801b51:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b56:	50                   	push   %eax
  801b57:	e8 62 f7 ff ff       	call   8012be <fd_alloc>
  801b5c:	89 c3                	mov    %eax,%ebx
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	85 c0                	test   %eax,%eax
  801b63:	78 1b                	js     801b80 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b65:	83 ec 04             	sub    $0x4,%esp
  801b68:	68 07 04 00 00       	push   $0x407
  801b6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b70:	6a 00                	push   $0x0
  801b72:	e8 fc f1 ff ff       	call   800d73 <sys_page_alloc>
  801b77:	89 c3                	mov    %eax,%ebx
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	79 10                	jns    801b90 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	56                   	push   %esi
  801b84:	e8 0e 02 00 00       	call   801d97 <nsipc_close>
		return r;
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	eb 24                	jmp    801bb4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b90:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b99:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ba5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ba8:	83 ec 0c             	sub    $0xc,%esp
  801bab:	50                   	push   %eax
  801bac:	e8 e6 f6 ff ff       	call   801297 <fd2num>
  801bb1:	83 c4 10             	add    $0x10,%esp
}
  801bb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb7:	5b                   	pop    %ebx
  801bb8:	5e                   	pop    %esi
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc4:	e8 50 ff ff ff       	call   801b19 <fd2sockid>
		return r;
  801bc9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	78 1f                	js     801bee <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bcf:	83 ec 04             	sub    $0x4,%esp
  801bd2:	ff 75 10             	pushl  0x10(%ebp)
  801bd5:	ff 75 0c             	pushl  0xc(%ebp)
  801bd8:	50                   	push   %eax
  801bd9:	e8 12 01 00 00       	call   801cf0 <nsipc_accept>
  801bde:	83 c4 10             	add    $0x10,%esp
		return r;
  801be1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801be3:	85 c0                	test   %eax,%eax
  801be5:	78 07                	js     801bee <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801be7:	e8 5d ff ff ff       	call   801b49 <alloc_sockfd>
  801bec:	89 c1                	mov    %eax,%ecx
}
  801bee:	89 c8                	mov    %ecx,%eax
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfb:	e8 19 ff ff ff       	call   801b19 <fd2sockid>
  801c00:	85 c0                	test   %eax,%eax
  801c02:	78 12                	js     801c16 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	ff 75 10             	pushl  0x10(%ebp)
  801c0a:	ff 75 0c             	pushl  0xc(%ebp)
  801c0d:	50                   	push   %eax
  801c0e:	e8 2d 01 00 00       	call   801d40 <nsipc_bind>
  801c13:	83 c4 10             	add    $0x10,%esp
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <shutdown>:

int
shutdown(int s, int how)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	e8 f3 fe ff ff       	call   801b19 <fd2sockid>
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 0f                	js     801c39 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c2a:	83 ec 08             	sub    $0x8,%esp
  801c2d:	ff 75 0c             	pushl  0xc(%ebp)
  801c30:	50                   	push   %eax
  801c31:	e8 3f 01 00 00       	call   801d75 <nsipc_shutdown>
  801c36:	83 c4 10             	add    $0x10,%esp
}
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    

00801c3b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c41:	8b 45 08             	mov    0x8(%ebp),%eax
  801c44:	e8 d0 fe ff ff       	call   801b19 <fd2sockid>
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	78 12                	js     801c5f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c4d:	83 ec 04             	sub    $0x4,%esp
  801c50:	ff 75 10             	pushl  0x10(%ebp)
  801c53:	ff 75 0c             	pushl  0xc(%ebp)
  801c56:	50                   	push   %eax
  801c57:	e8 55 01 00 00       	call   801db1 <nsipc_connect>
  801c5c:	83 c4 10             	add    $0x10,%esp
}
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    

00801c61 <listen>:

int
listen(int s, int backlog)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6a:	e8 aa fe ff ff       	call   801b19 <fd2sockid>
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 0f                	js     801c82 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c73:	83 ec 08             	sub    $0x8,%esp
  801c76:	ff 75 0c             	pushl  0xc(%ebp)
  801c79:	50                   	push   %eax
  801c7a:	e8 67 01 00 00       	call   801de6 <nsipc_listen>
  801c7f:	83 c4 10             	add    $0x10,%esp
}
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c8a:	ff 75 10             	pushl  0x10(%ebp)
  801c8d:	ff 75 0c             	pushl  0xc(%ebp)
  801c90:	ff 75 08             	pushl  0x8(%ebp)
  801c93:	e8 3a 02 00 00       	call   801ed2 <nsipc_socket>
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 05                	js     801ca4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c9f:	e8 a5 fe ff ff       	call   801b49 <alloc_sockfd>
}
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	53                   	push   %ebx
  801caa:	83 ec 04             	sub    $0x4,%esp
  801cad:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801caf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801cb6:	75 12                	jne    801cca <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cb8:	83 ec 0c             	sub    $0xc,%esp
  801cbb:	6a 02                	push   $0x2
  801cbd:	e8 8e 08 00 00       	call   802550 <ipc_find_env>
  801cc2:	a3 04 40 80 00       	mov    %eax,0x804004
  801cc7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cca:	6a 07                	push   $0x7
  801ccc:	68 00 60 80 00       	push   $0x806000
  801cd1:	53                   	push   %ebx
  801cd2:	ff 35 04 40 80 00    	pushl  0x804004
  801cd8:	e8 1f 08 00 00       	call   8024fc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cdd:	83 c4 0c             	add    $0xc,%esp
  801ce0:	6a 00                	push   $0x0
  801ce2:	6a 00                	push   $0x0
  801ce4:	6a 00                	push   $0x0
  801ce6:	e8 aa 07 00 00       	call   802495 <ipc_recv>
}
  801ceb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cee:	c9                   	leave  
  801cef:	c3                   	ret    

00801cf0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	56                   	push   %esi
  801cf4:	53                   	push   %ebx
  801cf5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d00:	8b 06                	mov    (%esi),%eax
  801d02:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d07:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0c:	e8 95 ff ff ff       	call   801ca6 <nsipc>
  801d11:	89 c3                	mov    %eax,%ebx
  801d13:	85 c0                	test   %eax,%eax
  801d15:	78 20                	js     801d37 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d17:	83 ec 04             	sub    $0x4,%esp
  801d1a:	ff 35 10 60 80 00    	pushl  0x806010
  801d20:	68 00 60 80 00       	push   $0x806000
  801d25:	ff 75 0c             	pushl  0xc(%ebp)
  801d28:	e8 d5 ed ff ff       	call   800b02 <memmove>
		*addrlen = ret->ret_addrlen;
  801d2d:	a1 10 60 80 00       	mov    0x806010,%eax
  801d32:	89 06                	mov    %eax,(%esi)
  801d34:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d37:	89 d8                	mov    %ebx,%eax
  801d39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3c:	5b                   	pop    %ebx
  801d3d:	5e                   	pop    %esi
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	53                   	push   %ebx
  801d44:	83 ec 08             	sub    $0x8,%esp
  801d47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d52:	53                   	push   %ebx
  801d53:	ff 75 0c             	pushl  0xc(%ebp)
  801d56:	68 04 60 80 00       	push   $0x806004
  801d5b:	e8 a2 ed ff ff       	call   800b02 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d60:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d66:	b8 02 00 00 00       	mov    $0x2,%eax
  801d6b:	e8 36 ff ff ff       	call   801ca6 <nsipc>
}
  801d70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d83:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d86:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d8b:	b8 03 00 00 00       	mov    $0x3,%eax
  801d90:	e8 11 ff ff ff       	call   801ca6 <nsipc>
}
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <nsipc_close>:

int
nsipc_close(int s)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801da0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801da5:	b8 04 00 00 00       	mov    $0x4,%eax
  801daa:	e8 f7 fe ff ff       	call   801ca6 <nsipc>
}
  801daf:	c9                   	leave  
  801db0:	c3                   	ret    

00801db1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	53                   	push   %ebx
  801db5:	83 ec 08             	sub    $0x8,%esp
  801db8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbe:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dc3:	53                   	push   %ebx
  801dc4:	ff 75 0c             	pushl  0xc(%ebp)
  801dc7:	68 04 60 80 00       	push   $0x806004
  801dcc:	e8 31 ed ff ff       	call   800b02 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dd1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801dd7:	b8 05 00 00 00       	mov    $0x5,%eax
  801ddc:	e8 c5 fe ff ff       	call   801ca6 <nsipc>
}
  801de1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de4:	c9                   	leave  
  801de5:	c3                   	ret    

00801de6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801df4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dfc:	b8 06 00 00 00       	mov    $0x6,%eax
  801e01:	e8 a0 fe ff ff       	call   801ca6 <nsipc>
}
  801e06:	c9                   	leave  
  801e07:	c3                   	ret    

00801e08 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	56                   	push   %esi
  801e0c:	53                   	push   %ebx
  801e0d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e10:	8b 45 08             	mov    0x8(%ebp),%eax
  801e13:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e18:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e1e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e21:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e26:	b8 07 00 00 00       	mov    $0x7,%eax
  801e2b:	e8 76 fe ff ff       	call   801ca6 <nsipc>
  801e30:	89 c3                	mov    %eax,%ebx
  801e32:	85 c0                	test   %eax,%eax
  801e34:	78 35                	js     801e6b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e36:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e3b:	7f 04                	jg     801e41 <nsipc_recv+0x39>
  801e3d:	39 c6                	cmp    %eax,%esi
  801e3f:	7d 16                	jge    801e57 <nsipc_recv+0x4f>
  801e41:	68 97 2e 80 00       	push   $0x802e97
  801e46:	68 5f 2e 80 00       	push   $0x802e5f
  801e4b:	6a 62                	push   $0x62
  801e4d:	68 ac 2e 80 00       	push   $0x802eac
  801e52:	e8 bb e4 ff ff       	call   800312 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e57:	83 ec 04             	sub    $0x4,%esp
  801e5a:	50                   	push   %eax
  801e5b:	68 00 60 80 00       	push   $0x806000
  801e60:	ff 75 0c             	pushl  0xc(%ebp)
  801e63:	e8 9a ec ff ff       	call   800b02 <memmove>
  801e68:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e6b:	89 d8                	mov    %ebx,%eax
  801e6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e70:	5b                   	pop    %ebx
  801e71:	5e                   	pop    %esi
  801e72:	5d                   	pop    %ebp
  801e73:	c3                   	ret    

00801e74 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	53                   	push   %ebx
  801e78:	83 ec 04             	sub    $0x4,%esp
  801e7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e81:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e86:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e8c:	7e 16                	jle    801ea4 <nsipc_send+0x30>
  801e8e:	68 b8 2e 80 00       	push   $0x802eb8
  801e93:	68 5f 2e 80 00       	push   $0x802e5f
  801e98:	6a 6d                	push   $0x6d
  801e9a:	68 ac 2e 80 00       	push   $0x802eac
  801e9f:	e8 6e e4 ff ff       	call   800312 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ea4:	83 ec 04             	sub    $0x4,%esp
  801ea7:	53                   	push   %ebx
  801ea8:	ff 75 0c             	pushl  0xc(%ebp)
  801eab:	68 0c 60 80 00       	push   $0x80600c
  801eb0:	e8 4d ec ff ff       	call   800b02 <memmove>
	nsipcbuf.send.req_size = size;
  801eb5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ebb:	8b 45 14             	mov    0x14(%ebp),%eax
  801ebe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ec3:	b8 08 00 00 00       	mov    $0x8,%eax
  801ec8:	e8 d9 fd ff ff       	call   801ca6 <nsipc>
}
  801ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  801edb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ee8:	8b 45 10             	mov    0x10(%ebp),%eax
  801eeb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ef0:	b8 09 00 00 00       	mov    $0x9,%eax
  801ef5:	e8 ac fd ff ff       	call   801ca6 <nsipc>
}
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f04:	83 ec 0c             	sub    $0xc,%esp
  801f07:	ff 75 08             	pushl  0x8(%ebp)
  801f0a:	e8 98 f3 ff ff       	call   8012a7 <fd2data>
  801f0f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f11:	83 c4 08             	add    $0x8,%esp
  801f14:	68 c4 2e 80 00       	push   $0x802ec4
  801f19:	53                   	push   %ebx
  801f1a:	e8 51 ea ff ff       	call   800970 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f1f:	8b 46 04             	mov    0x4(%esi),%eax
  801f22:	2b 06                	sub    (%esi),%eax
  801f24:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f2a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f31:	00 00 00 
	stat->st_dev = &devpipe;
  801f34:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801f3b:	30 80 00 
	return 0;
}
  801f3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    

00801f4a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	53                   	push   %ebx
  801f4e:	83 ec 0c             	sub    $0xc,%esp
  801f51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f54:	53                   	push   %ebx
  801f55:	6a 00                	push   $0x0
  801f57:	e8 9c ee ff ff       	call   800df8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f5c:	89 1c 24             	mov    %ebx,(%esp)
  801f5f:	e8 43 f3 ff ff       	call   8012a7 <fd2data>
  801f64:	83 c4 08             	add    $0x8,%esp
  801f67:	50                   	push   %eax
  801f68:	6a 00                	push   $0x0
  801f6a:	e8 89 ee ff ff       	call   800df8 <sys_page_unmap>
}
  801f6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f72:	c9                   	leave  
  801f73:	c3                   	ret    

00801f74 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	57                   	push   %edi
  801f78:	56                   	push   %esi
  801f79:	53                   	push   %ebx
  801f7a:	83 ec 1c             	sub    $0x1c,%esp
  801f7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f80:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f82:	a1 08 40 80 00       	mov    0x804008,%eax
  801f87:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f8a:	83 ec 0c             	sub    $0xc,%esp
  801f8d:	ff 75 e0             	pushl  -0x20(%ebp)
  801f90:	e8 f4 05 00 00       	call   802589 <pageref>
  801f95:	89 c3                	mov    %eax,%ebx
  801f97:	89 3c 24             	mov    %edi,(%esp)
  801f9a:	e8 ea 05 00 00       	call   802589 <pageref>
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	39 c3                	cmp    %eax,%ebx
  801fa4:	0f 94 c1             	sete   %cl
  801fa7:	0f b6 c9             	movzbl %cl,%ecx
  801faa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fad:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fb3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fb6:	39 ce                	cmp    %ecx,%esi
  801fb8:	74 1b                	je     801fd5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fba:	39 c3                	cmp    %eax,%ebx
  801fbc:	75 c4                	jne    801f82 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fbe:	8b 42 58             	mov    0x58(%edx),%eax
  801fc1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fc4:	50                   	push   %eax
  801fc5:	56                   	push   %esi
  801fc6:	68 cb 2e 80 00       	push   $0x802ecb
  801fcb:	e8 1b e4 ff ff       	call   8003eb <cprintf>
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	eb ad                	jmp    801f82 <_pipeisclosed+0xe>
	}
}
  801fd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdb:	5b                   	pop    %ebx
  801fdc:	5e                   	pop    %esi
  801fdd:	5f                   	pop    %edi
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    

00801fe0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	57                   	push   %edi
  801fe4:	56                   	push   %esi
  801fe5:	53                   	push   %ebx
  801fe6:	83 ec 28             	sub    $0x28,%esp
  801fe9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fec:	56                   	push   %esi
  801fed:	e8 b5 f2 ff ff       	call   8012a7 <fd2data>
  801ff2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	bf 00 00 00 00       	mov    $0x0,%edi
  801ffc:	eb 4b                	jmp    802049 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ffe:	89 da                	mov    %ebx,%edx
  802000:	89 f0                	mov    %esi,%eax
  802002:	e8 6d ff ff ff       	call   801f74 <_pipeisclosed>
  802007:	85 c0                	test   %eax,%eax
  802009:	75 48                	jne    802053 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80200b:	e8 44 ed ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802010:	8b 43 04             	mov    0x4(%ebx),%eax
  802013:	8b 0b                	mov    (%ebx),%ecx
  802015:	8d 51 20             	lea    0x20(%ecx),%edx
  802018:	39 d0                	cmp    %edx,%eax
  80201a:	73 e2                	jae    801ffe <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80201c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80201f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802023:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802026:	89 c2                	mov    %eax,%edx
  802028:	c1 fa 1f             	sar    $0x1f,%edx
  80202b:	89 d1                	mov    %edx,%ecx
  80202d:	c1 e9 1b             	shr    $0x1b,%ecx
  802030:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802033:	83 e2 1f             	and    $0x1f,%edx
  802036:	29 ca                	sub    %ecx,%edx
  802038:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80203c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802040:	83 c0 01             	add    $0x1,%eax
  802043:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802046:	83 c7 01             	add    $0x1,%edi
  802049:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80204c:	75 c2                	jne    802010 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80204e:	8b 45 10             	mov    0x10(%ebp),%eax
  802051:	eb 05                	jmp    802058 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802053:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205b:	5b                   	pop    %ebx
  80205c:	5e                   	pop    %esi
  80205d:	5f                   	pop    %edi
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    

00802060 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	57                   	push   %edi
  802064:	56                   	push   %esi
  802065:	53                   	push   %ebx
  802066:	83 ec 18             	sub    $0x18,%esp
  802069:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80206c:	57                   	push   %edi
  80206d:	e8 35 f2 ff ff       	call   8012a7 <fd2data>
  802072:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802074:	83 c4 10             	add    $0x10,%esp
  802077:	bb 00 00 00 00       	mov    $0x0,%ebx
  80207c:	eb 3d                	jmp    8020bb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80207e:	85 db                	test   %ebx,%ebx
  802080:	74 04                	je     802086 <devpipe_read+0x26>
				return i;
  802082:	89 d8                	mov    %ebx,%eax
  802084:	eb 44                	jmp    8020ca <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802086:	89 f2                	mov    %esi,%edx
  802088:	89 f8                	mov    %edi,%eax
  80208a:	e8 e5 fe ff ff       	call   801f74 <_pipeisclosed>
  80208f:	85 c0                	test   %eax,%eax
  802091:	75 32                	jne    8020c5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802093:	e8 bc ec ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802098:	8b 06                	mov    (%esi),%eax
  80209a:	3b 46 04             	cmp    0x4(%esi),%eax
  80209d:	74 df                	je     80207e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80209f:	99                   	cltd   
  8020a0:	c1 ea 1b             	shr    $0x1b,%edx
  8020a3:	01 d0                	add    %edx,%eax
  8020a5:	83 e0 1f             	and    $0x1f,%eax
  8020a8:	29 d0                	sub    %edx,%eax
  8020aa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020b2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020b5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020b8:	83 c3 01             	add    $0x1,%ebx
  8020bb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020be:	75 d8                	jne    802098 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c3:	eb 05                	jmp    8020ca <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020c5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    

008020d2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020d2:	55                   	push   %ebp
  8020d3:	89 e5                	mov    %esp,%ebp
  8020d5:	56                   	push   %esi
  8020d6:	53                   	push   %ebx
  8020d7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020dd:	50                   	push   %eax
  8020de:	e8 db f1 ff ff       	call   8012be <fd_alloc>
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	89 c2                	mov    %eax,%edx
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	0f 88 2c 01 00 00    	js     80221c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f0:	83 ec 04             	sub    $0x4,%esp
  8020f3:	68 07 04 00 00       	push   $0x407
  8020f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020fb:	6a 00                	push   $0x0
  8020fd:	e8 71 ec ff ff       	call   800d73 <sys_page_alloc>
  802102:	83 c4 10             	add    $0x10,%esp
  802105:	89 c2                	mov    %eax,%edx
  802107:	85 c0                	test   %eax,%eax
  802109:	0f 88 0d 01 00 00    	js     80221c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80210f:	83 ec 0c             	sub    $0xc,%esp
  802112:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802115:	50                   	push   %eax
  802116:	e8 a3 f1 ff ff       	call   8012be <fd_alloc>
  80211b:	89 c3                	mov    %eax,%ebx
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	85 c0                	test   %eax,%eax
  802122:	0f 88 e2 00 00 00    	js     80220a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802128:	83 ec 04             	sub    $0x4,%esp
  80212b:	68 07 04 00 00       	push   $0x407
  802130:	ff 75 f0             	pushl  -0x10(%ebp)
  802133:	6a 00                	push   $0x0
  802135:	e8 39 ec ff ff       	call   800d73 <sys_page_alloc>
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	85 c0                	test   %eax,%eax
  802141:	0f 88 c3 00 00 00    	js     80220a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802147:	83 ec 0c             	sub    $0xc,%esp
  80214a:	ff 75 f4             	pushl  -0xc(%ebp)
  80214d:	e8 55 f1 ff ff       	call   8012a7 <fd2data>
  802152:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802154:	83 c4 0c             	add    $0xc,%esp
  802157:	68 07 04 00 00       	push   $0x407
  80215c:	50                   	push   %eax
  80215d:	6a 00                	push   $0x0
  80215f:	e8 0f ec ff ff       	call   800d73 <sys_page_alloc>
  802164:	89 c3                	mov    %eax,%ebx
  802166:	83 c4 10             	add    $0x10,%esp
  802169:	85 c0                	test   %eax,%eax
  80216b:	0f 88 89 00 00 00    	js     8021fa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802171:	83 ec 0c             	sub    $0xc,%esp
  802174:	ff 75 f0             	pushl  -0x10(%ebp)
  802177:	e8 2b f1 ff ff       	call   8012a7 <fd2data>
  80217c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802183:	50                   	push   %eax
  802184:	6a 00                	push   $0x0
  802186:	56                   	push   %esi
  802187:	6a 00                	push   $0x0
  802189:	e8 28 ec ff ff       	call   800db6 <sys_page_map>
  80218e:	89 c3                	mov    %eax,%ebx
  802190:	83 c4 20             	add    $0x20,%esp
  802193:	85 c0                	test   %eax,%eax
  802195:	78 55                	js     8021ec <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802197:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80219d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021ac:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021c1:	83 ec 0c             	sub    $0xc,%esp
  8021c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c7:	e8 cb f0 ff ff       	call   801297 <fd2num>
  8021cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021cf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021d1:	83 c4 04             	add    $0x4,%esp
  8021d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d7:	e8 bb f0 ff ff       	call   801297 <fd2num>
  8021dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021df:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021e2:	83 c4 10             	add    $0x10,%esp
  8021e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8021ea:	eb 30                	jmp    80221c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021ec:	83 ec 08             	sub    $0x8,%esp
  8021ef:	56                   	push   %esi
  8021f0:	6a 00                	push   $0x0
  8021f2:	e8 01 ec ff ff       	call   800df8 <sys_page_unmap>
  8021f7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021fa:	83 ec 08             	sub    $0x8,%esp
  8021fd:	ff 75 f0             	pushl  -0x10(%ebp)
  802200:	6a 00                	push   $0x0
  802202:	e8 f1 eb ff ff       	call   800df8 <sys_page_unmap>
  802207:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80220a:	83 ec 08             	sub    $0x8,%esp
  80220d:	ff 75 f4             	pushl  -0xc(%ebp)
  802210:	6a 00                	push   $0x0
  802212:	e8 e1 eb ff ff       	call   800df8 <sys_page_unmap>
  802217:	83 c4 10             	add    $0x10,%esp
  80221a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80221c:	89 d0                	mov    %edx,%eax
  80221e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    

00802225 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80222b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222e:	50                   	push   %eax
  80222f:	ff 75 08             	pushl  0x8(%ebp)
  802232:	e8 d6 f0 ff ff       	call   80130d <fd_lookup>
  802237:	83 c4 10             	add    $0x10,%esp
  80223a:	85 c0                	test   %eax,%eax
  80223c:	78 18                	js     802256 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80223e:	83 ec 0c             	sub    $0xc,%esp
  802241:	ff 75 f4             	pushl  -0xc(%ebp)
  802244:	e8 5e f0 ff ff       	call   8012a7 <fd2data>
	return _pipeisclosed(fd, p);
  802249:	89 c2                	mov    %eax,%edx
  80224b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224e:	e8 21 fd ff ff       	call   801f74 <_pipeisclosed>
  802253:	83 c4 10             	add    $0x10,%esp
}
  802256:	c9                   	leave  
  802257:	c3                   	ret    

00802258 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	56                   	push   %esi
  80225c:	53                   	push   %ebx
  80225d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802260:	85 f6                	test   %esi,%esi
  802262:	75 16                	jne    80227a <wait+0x22>
  802264:	68 e3 2e 80 00       	push   $0x802ee3
  802269:	68 5f 2e 80 00       	push   $0x802e5f
  80226e:	6a 09                	push   $0x9
  802270:	68 ee 2e 80 00       	push   $0x802eee
  802275:	e8 98 e0 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  80227a:	89 f3                	mov    %esi,%ebx
  80227c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802282:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802285:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80228b:	eb 05                	jmp    802292 <wait+0x3a>
		sys_yield();
  80228d:	e8 c2 ea ff ff       	call   800d54 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802292:	8b 43 48             	mov    0x48(%ebx),%eax
  802295:	39 c6                	cmp    %eax,%esi
  802297:	75 07                	jne    8022a0 <wait+0x48>
  802299:	8b 43 54             	mov    0x54(%ebx),%eax
  80229c:	85 c0                	test   %eax,%eax
  80229e:	75 ed                	jne    80228d <wait+0x35>
		sys_yield();
}
  8022a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5d                   	pop    %ebp
  8022a6:	c3                   	ret    

008022a7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022a7:	55                   	push   %ebp
  8022a8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8022af:	5d                   	pop    %ebp
  8022b0:	c3                   	ret    

008022b1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022b1:	55                   	push   %ebp
  8022b2:	89 e5                	mov    %esp,%ebp
  8022b4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022b7:	68 f9 2e 80 00       	push   $0x802ef9
  8022bc:	ff 75 0c             	pushl  0xc(%ebp)
  8022bf:	e8 ac e6 ff ff       	call   800970 <strcpy>
	return 0;
}
  8022c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c9:	c9                   	leave  
  8022ca:	c3                   	ret    

008022cb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	57                   	push   %edi
  8022cf:	56                   	push   %esi
  8022d0:	53                   	push   %ebx
  8022d1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022d7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022dc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022e2:	eb 2d                	jmp    802311 <devcons_write+0x46>
		m = n - tot;
  8022e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022e7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022e9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022ec:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022f1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022f4:	83 ec 04             	sub    $0x4,%esp
  8022f7:	53                   	push   %ebx
  8022f8:	03 45 0c             	add    0xc(%ebp),%eax
  8022fb:	50                   	push   %eax
  8022fc:	57                   	push   %edi
  8022fd:	e8 00 e8 ff ff       	call   800b02 <memmove>
		sys_cputs(buf, m);
  802302:	83 c4 08             	add    $0x8,%esp
  802305:	53                   	push   %ebx
  802306:	57                   	push   %edi
  802307:	e8 ab e9 ff ff       	call   800cb7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80230c:	01 de                	add    %ebx,%esi
  80230e:	83 c4 10             	add    $0x10,%esp
  802311:	89 f0                	mov    %esi,%eax
  802313:	3b 75 10             	cmp    0x10(%ebp),%esi
  802316:	72 cc                	jb     8022e4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80231b:	5b                   	pop    %ebx
  80231c:	5e                   	pop    %esi
  80231d:	5f                   	pop    %edi
  80231e:	5d                   	pop    %ebp
  80231f:	c3                   	ret    

00802320 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	83 ec 08             	sub    $0x8,%esp
  802326:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80232b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80232f:	74 2a                	je     80235b <devcons_read+0x3b>
  802331:	eb 05                	jmp    802338 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802333:	e8 1c ea ff ff       	call   800d54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802338:	e8 98 e9 ff ff       	call   800cd5 <sys_cgetc>
  80233d:	85 c0                	test   %eax,%eax
  80233f:	74 f2                	je     802333 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802341:	85 c0                	test   %eax,%eax
  802343:	78 16                	js     80235b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802345:	83 f8 04             	cmp    $0x4,%eax
  802348:	74 0c                	je     802356 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80234a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80234d:	88 02                	mov    %al,(%edx)
	return 1;
  80234f:	b8 01 00 00 00       	mov    $0x1,%eax
  802354:	eb 05                	jmp    80235b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802356:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80235b:	c9                   	leave  
  80235c:	c3                   	ret    

0080235d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80235d:	55                   	push   %ebp
  80235e:	89 e5                	mov    %esp,%ebp
  802360:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802363:	8b 45 08             	mov    0x8(%ebp),%eax
  802366:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802369:	6a 01                	push   $0x1
  80236b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80236e:	50                   	push   %eax
  80236f:	e8 43 e9 ff ff       	call   800cb7 <sys_cputs>
}
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	c9                   	leave  
  802378:	c3                   	ret    

00802379 <getchar>:

int
getchar(void)
{
  802379:	55                   	push   %ebp
  80237a:	89 e5                	mov    %esp,%ebp
  80237c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80237f:	6a 01                	push   $0x1
  802381:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802384:	50                   	push   %eax
  802385:	6a 00                	push   $0x0
  802387:	e8 e7 f1 ff ff       	call   801573 <read>
	if (r < 0)
  80238c:	83 c4 10             	add    $0x10,%esp
  80238f:	85 c0                	test   %eax,%eax
  802391:	78 0f                	js     8023a2 <getchar+0x29>
		return r;
	if (r < 1)
  802393:	85 c0                	test   %eax,%eax
  802395:	7e 06                	jle    80239d <getchar+0x24>
		return -E_EOF;
	return c;
  802397:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80239b:	eb 05                	jmp    8023a2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80239d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023a2:	c9                   	leave  
  8023a3:	c3                   	ret    

008023a4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ad:	50                   	push   %eax
  8023ae:	ff 75 08             	pushl  0x8(%ebp)
  8023b1:	e8 57 ef ff ff       	call   80130d <fd_lookup>
  8023b6:	83 c4 10             	add    $0x10,%esp
  8023b9:	85 c0                	test   %eax,%eax
  8023bb:	78 11                	js     8023ce <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c0:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8023c6:	39 10                	cmp    %edx,(%eax)
  8023c8:	0f 94 c0             	sete   %al
  8023cb:	0f b6 c0             	movzbl %al,%eax
}
  8023ce:	c9                   	leave  
  8023cf:	c3                   	ret    

008023d0 <opencons>:

int
opencons(void)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d9:	50                   	push   %eax
  8023da:	e8 df ee ff ff       	call   8012be <fd_alloc>
  8023df:	83 c4 10             	add    $0x10,%esp
		return r;
  8023e2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023e4:	85 c0                	test   %eax,%eax
  8023e6:	78 3e                	js     802426 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023e8:	83 ec 04             	sub    $0x4,%esp
  8023eb:	68 07 04 00 00       	push   $0x407
  8023f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f3:	6a 00                	push   $0x0
  8023f5:	e8 79 e9 ff ff       	call   800d73 <sys_page_alloc>
  8023fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8023fd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ff:	85 c0                	test   %eax,%eax
  802401:	78 23                	js     802426 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802403:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802409:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80240e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802411:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802418:	83 ec 0c             	sub    $0xc,%esp
  80241b:	50                   	push   %eax
  80241c:	e8 76 ee ff ff       	call   801297 <fd2num>
  802421:	89 c2                	mov    %eax,%edx
  802423:	83 c4 10             	add    $0x10,%esp
}
  802426:	89 d0                	mov    %edx,%eax
  802428:	c9                   	leave  
  802429:	c3                   	ret    

0080242a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80242a:	55                   	push   %ebp
  80242b:	89 e5                	mov    %esp,%ebp
  80242d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802430:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802437:	75 2e                	jne    802467 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802439:	e8 f7 e8 ff ff       	call   800d35 <sys_getenvid>
  80243e:	83 ec 04             	sub    $0x4,%esp
  802441:	68 07 0e 00 00       	push   $0xe07
  802446:	68 00 f0 bf ee       	push   $0xeebff000
  80244b:	50                   	push   %eax
  80244c:	e8 22 e9 ff ff       	call   800d73 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802451:	e8 df e8 ff ff       	call   800d35 <sys_getenvid>
  802456:	83 c4 08             	add    $0x8,%esp
  802459:	68 71 24 80 00       	push   $0x802471
  80245e:	50                   	push   %eax
  80245f:	e8 5a ea ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
  802464:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802467:	8b 45 08             	mov    0x8(%ebp),%eax
  80246a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80246f:	c9                   	leave  
  802470:	c3                   	ret    

00802471 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802471:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802472:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802477:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802479:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80247c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802480:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802484:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802487:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80248a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80248b:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80248e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80248f:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802490:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802494:	c3                   	ret    

00802495 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802495:	55                   	push   %ebp
  802496:	89 e5                	mov    %esp,%ebp
  802498:	56                   	push   %esi
  802499:	53                   	push   %ebx
  80249a:	8b 75 08             	mov    0x8(%ebp),%esi
  80249d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8024a3:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8024a5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024aa:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8024ad:	83 ec 0c             	sub    $0xc,%esp
  8024b0:	50                   	push   %eax
  8024b1:	e8 6d ea ff ff       	call   800f23 <sys_ipc_recv>

	if (from_env_store != NULL)
  8024b6:	83 c4 10             	add    $0x10,%esp
  8024b9:	85 f6                	test   %esi,%esi
  8024bb:	74 14                	je     8024d1 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8024bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8024c2:	85 c0                	test   %eax,%eax
  8024c4:	78 09                	js     8024cf <ipc_recv+0x3a>
  8024c6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8024cc:	8b 52 74             	mov    0x74(%edx),%edx
  8024cf:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8024d1:	85 db                	test   %ebx,%ebx
  8024d3:	74 14                	je     8024e9 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8024d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8024da:	85 c0                	test   %eax,%eax
  8024dc:	78 09                	js     8024e7 <ipc_recv+0x52>
  8024de:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8024e4:	8b 52 78             	mov    0x78(%edx),%edx
  8024e7:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8024e9:	85 c0                	test   %eax,%eax
  8024eb:	78 08                	js     8024f5 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8024ed:	a1 08 40 80 00       	mov    0x804008,%eax
  8024f2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024f8:	5b                   	pop    %ebx
  8024f9:	5e                   	pop    %esi
  8024fa:	5d                   	pop    %ebp
  8024fb:	c3                   	ret    

008024fc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024fc:	55                   	push   %ebp
  8024fd:	89 e5                	mov    %esp,%ebp
  8024ff:	57                   	push   %edi
  802500:	56                   	push   %esi
  802501:	53                   	push   %ebx
  802502:	83 ec 0c             	sub    $0xc,%esp
  802505:	8b 7d 08             	mov    0x8(%ebp),%edi
  802508:	8b 75 0c             	mov    0xc(%ebp),%esi
  80250b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80250e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802510:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802515:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802518:	ff 75 14             	pushl  0x14(%ebp)
  80251b:	53                   	push   %ebx
  80251c:	56                   	push   %esi
  80251d:	57                   	push   %edi
  80251e:	e8 dd e9 ff ff       	call   800f00 <sys_ipc_try_send>

		if (err < 0) {
  802523:	83 c4 10             	add    $0x10,%esp
  802526:	85 c0                	test   %eax,%eax
  802528:	79 1e                	jns    802548 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80252a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80252d:	75 07                	jne    802536 <ipc_send+0x3a>
				sys_yield();
  80252f:	e8 20 e8 ff ff       	call   800d54 <sys_yield>
  802534:	eb e2                	jmp    802518 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802536:	50                   	push   %eax
  802537:	68 05 2f 80 00       	push   $0x802f05
  80253c:	6a 49                	push   $0x49
  80253e:	68 12 2f 80 00       	push   $0x802f12
  802543:	e8 ca dd ff ff       	call   800312 <_panic>
		}

	} while (err < 0);

}
  802548:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80254b:	5b                   	pop    %ebx
  80254c:	5e                   	pop    %esi
  80254d:	5f                   	pop    %edi
  80254e:	5d                   	pop    %ebp
  80254f:	c3                   	ret    

00802550 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
  802553:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802556:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80255b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80255e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802564:	8b 52 50             	mov    0x50(%edx),%edx
  802567:	39 ca                	cmp    %ecx,%edx
  802569:	75 0d                	jne    802578 <ipc_find_env+0x28>
			return envs[i].env_id;
  80256b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80256e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802573:	8b 40 48             	mov    0x48(%eax),%eax
  802576:	eb 0f                	jmp    802587 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802578:	83 c0 01             	add    $0x1,%eax
  80257b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802580:	75 d9                	jne    80255b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802582:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802587:	5d                   	pop    %ebp
  802588:	c3                   	ret    

00802589 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802589:	55                   	push   %ebp
  80258a:	89 e5                	mov    %esp,%ebp
  80258c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80258f:	89 d0                	mov    %edx,%eax
  802591:	c1 e8 16             	shr    $0x16,%eax
  802594:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80259b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025a0:	f6 c1 01             	test   $0x1,%cl
  8025a3:	74 1d                	je     8025c2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025a5:	c1 ea 0c             	shr    $0xc,%edx
  8025a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025af:	f6 c2 01             	test   $0x1,%dl
  8025b2:	74 0e                	je     8025c2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025b4:	c1 ea 0c             	shr    $0xc,%edx
  8025b7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025be:	ef 
  8025bf:	0f b7 c0             	movzwl %ax,%eax
}
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    
  8025c4:	66 90                	xchg   %ax,%ax
  8025c6:	66 90                	xchg   %ax,%ax
  8025c8:	66 90                	xchg   %ax,%ax
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
