
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
  80003b:	c7 05 04 30 80 00 20 	movl   $0x802820,0x803004
  800042:	28 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 42 20 00 00       	call   802090 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 2c 28 80 00       	push   $0x80282c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 35 28 80 00       	push   $0x802835
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 30 10 00 00       	call   80109e <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 45 28 80 00       	push   $0x802845
  80007a:	6a 11                	push   $0x11
  80007c:	68 35 28 80 00       	push   $0x802835
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
  80009d:	68 4e 28 80 00       	push   $0x80284e
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 43 13 00 00       	call   8013f5 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 6b 28 80 00       	push   $0x80286b
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 e6 14 00 00       	call   8015c2 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 88 28 80 00       	push   $0x802888
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 35 28 80 00       	push   $0x802835
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
  800118:	68 91 28 80 00       	push   $0x802891
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 ad 28 80 00       	push   $0x8028ad
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
  800155:	68 4e 28 80 00       	push   $0x80284e
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 8b 12 00 00       	call   8013f5 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 08 40 80 00       	mov    0x804008,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 c0 28 80 00       	push   $0x8028c0
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a6 07 00 00       	call   800937 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 68 14 00 00       	call   80160b <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 84 07 00 00       	call   800937 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 dd 28 80 00       	push   $0x8028dd
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 35 28 80 00       	push   $0x802835
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 1e 12 00 00       	call   8013f5 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 33 20 00 00       	call   802216 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 e7 	movl   $0x8028e7,0x803004
  8001ea:	28 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 98 1e 00 00       	call   802090 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 2c 28 80 00       	push   $0x80282c
  800207:	6a 2c                	push   $0x2c
  800209:	68 35 28 80 00       	push   $0x802835
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 86 0e 00 00       	call   80109e <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 45 28 80 00       	push   $0x802845
  800224:	6a 2f                	push   $0x2f
  800226:	68 35 28 80 00       	push   $0x802835
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 b6 11 00 00       	call   8013f5 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 f4 28 80 00       	push   $0x8028f4
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 f6 28 80 00       	push   $0x8028f6
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 aa 13 00 00       	call   80160b <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 f8 28 80 00       	push   $0x8028f8
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 6c 11 00 00       	call   8013f5 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 61 11 00 00       	call   8013f5 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 7a 1f 00 00       	call   802216 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 15 29 80 00 	movl   $0x802915,(%esp)
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
  8002fe:	e8 1d 11 00 00       	call   801420 <close_all>
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
  800330:	68 78 29 80 00       	push   $0x802978
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 69 28 80 00 	movl   $0x802869,(%esp)
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
  80044e:	e8 3d 21 00 00       	call   802590 <__udivdi3>
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
  800491:	e8 2a 22 00 00       	call   8026c0 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 9b 29 80 00 	movsbl 0x80299b(%eax),%eax
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
  800595:	ff 24 85 e0 2a 80 00 	jmp    *0x802ae0(,%eax,4)
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
  800659:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 b3 29 80 00       	push   $0x8029b3
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
  80067d:	68 31 2e 80 00       	push   $0x802e31
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
  8006a1:	b8 ac 29 80 00       	mov    $0x8029ac,%eax
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
  800d1c:	68 9f 2c 80 00       	push   $0x802c9f
  800d21:	6a 23                	push   $0x23
  800d23:	68 bc 2c 80 00       	push   $0x802cbc
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
  800d9d:	68 9f 2c 80 00       	push   $0x802c9f
  800da2:	6a 23                	push   $0x23
  800da4:	68 bc 2c 80 00       	push   $0x802cbc
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
  800ddf:	68 9f 2c 80 00       	push   $0x802c9f
  800de4:	6a 23                	push   $0x23
  800de6:	68 bc 2c 80 00       	push   $0x802cbc
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
  800e21:	68 9f 2c 80 00       	push   $0x802c9f
  800e26:	6a 23                	push   $0x23
  800e28:	68 bc 2c 80 00       	push   $0x802cbc
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
  800e63:	68 9f 2c 80 00       	push   $0x802c9f
  800e68:	6a 23                	push   $0x23
  800e6a:	68 bc 2c 80 00       	push   $0x802cbc
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
  800ea5:	68 9f 2c 80 00       	push   $0x802c9f
  800eaa:	6a 23                	push   $0x23
  800eac:	68 bc 2c 80 00       	push   $0x802cbc
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
  800ee7:	68 9f 2c 80 00       	push   $0x802c9f
  800eec:	6a 23                	push   $0x23
  800eee:	68 bc 2c 80 00       	push   $0x802cbc
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
  800f4b:	68 9f 2c 80 00       	push   $0x802c9f
  800f50:	6a 23                	push   $0x23
  800f52:	68 bc 2c 80 00       	push   $0x802cbc
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
  800fac:	68 9f 2c 80 00       	push   $0x802c9f
  800fb1:	6a 23                	push   $0x23
  800fb3:	68 bc 2c 80 00       	push   $0x802cbc
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

00800fc5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
  800fca:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fcd:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800fcf:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fd3:	75 25                	jne    800ffa <pgfault+0x35>
  800fd5:	89 d8                	mov    %ebx,%eax
  800fd7:	c1 e8 0c             	shr    $0xc,%eax
  800fda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe1:	f6 c4 08             	test   $0x8,%ah
  800fe4:	75 14                	jne    800ffa <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	68 cc 2c 80 00       	push   $0x802ccc
  800fee:	6a 1e                	push   $0x1e
  800ff0:	68 60 2d 80 00       	push   $0x802d60
  800ff5:	e8 18 f3 ff ff       	call   800312 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800ffa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  801000:	e8 30 fd ff ff       	call   800d35 <sys_getenvid>
  801005:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	6a 07                	push   $0x7
  80100c:	68 00 f0 7f 00       	push   $0x7ff000
  801011:	50                   	push   %eax
  801012:	e8 5c fd ff ff       	call   800d73 <sys_page_alloc>
	if (r < 0)
  801017:	83 c4 10             	add    $0x10,%esp
  80101a:	85 c0                	test   %eax,%eax
  80101c:	79 12                	jns    801030 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  80101e:	50                   	push   %eax
  80101f:	68 f8 2c 80 00       	push   $0x802cf8
  801024:	6a 33                	push   $0x33
  801026:	68 60 2d 80 00       	push   $0x802d60
  80102b:	e8 e2 f2 ff ff       	call   800312 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  801030:	83 ec 04             	sub    $0x4,%esp
  801033:	68 00 10 00 00       	push   $0x1000
  801038:	53                   	push   %ebx
  801039:	68 00 f0 7f 00       	push   $0x7ff000
  80103e:	e8 27 fb ff ff       	call   800b6a <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  801043:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80104a:	53                   	push   %ebx
  80104b:	56                   	push   %esi
  80104c:	68 00 f0 7f 00       	push   $0x7ff000
  801051:	56                   	push   %esi
  801052:	e8 5f fd ff ff       	call   800db6 <sys_page_map>
	if (r < 0)
  801057:	83 c4 20             	add    $0x20,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	79 12                	jns    801070 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  80105e:	50                   	push   %eax
  80105f:	68 1c 2d 80 00       	push   $0x802d1c
  801064:	6a 3b                	push   $0x3b
  801066:	68 60 2d 80 00       	push   $0x802d60
  80106b:	e8 a2 f2 ff ff       	call   800312 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	68 00 f0 7f 00       	push   $0x7ff000
  801078:	56                   	push   %esi
  801079:	e8 7a fd ff ff       	call   800df8 <sys_page_unmap>
	if (r < 0)
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	79 12                	jns    801097 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  801085:	50                   	push   %eax
  801086:	68 40 2d 80 00       	push   $0x802d40
  80108b:	6a 40                	push   $0x40
  80108d:	68 60 2d 80 00       	push   $0x802d60
  801092:	e8 7b f2 ff ff       	call   800312 <_panic>
}
  801097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109a:	5b                   	pop    %ebx
  80109b:	5e                   	pop    %esi
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  8010a7:	68 c5 0f 80 00       	push   $0x800fc5
  8010ac:	e8 37 13 00 00       	call   8023e8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010b1:	b8 07 00 00 00       	mov    $0x7,%eax
  8010b6:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	0f 88 64 01 00 00    	js     801227 <fork+0x189>
  8010c3:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8010c8:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	75 21                	jne    8010f2 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010d1:	e8 5f fc ff ff       	call   800d35 <sys_getenvid>
  8010d6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010db:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010de:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010e3:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  8010e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ed:	e9 3f 01 00 00       	jmp    801231 <fork+0x193>
  8010f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010f5:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8010f7:	89 d8                	mov    %ebx,%eax
  8010f9:	c1 e8 16             	shr    $0x16,%eax
  8010fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801103:	a8 01                	test   $0x1,%al
  801105:	0f 84 bd 00 00 00    	je     8011c8 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80110b:	89 d8                	mov    %ebx,%eax
  80110d:	c1 e8 0c             	shr    $0xc,%eax
  801110:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801117:	f6 c2 01             	test   $0x1,%dl
  80111a:	0f 84 a8 00 00 00    	je     8011c8 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801120:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801127:	a8 04                	test   $0x4,%al
  801129:	0f 84 99 00 00 00    	je     8011c8 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  80112f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801136:	f6 c4 04             	test   $0x4,%ah
  801139:	74 17                	je     801152 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	68 07 0e 00 00       	push   $0xe07
  801143:	53                   	push   %ebx
  801144:	57                   	push   %edi
  801145:	53                   	push   %ebx
  801146:	6a 00                	push   $0x0
  801148:	e8 69 fc ff ff       	call   800db6 <sys_page_map>
  80114d:	83 c4 20             	add    $0x20,%esp
  801150:	eb 76                	jmp    8011c8 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801152:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801159:	a8 02                	test   $0x2,%al
  80115b:	75 0c                	jne    801169 <fork+0xcb>
  80115d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801164:	f6 c4 08             	test   $0x8,%ah
  801167:	74 3f                	je     8011a8 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801169:	83 ec 0c             	sub    $0xc,%esp
  80116c:	68 05 08 00 00       	push   $0x805
  801171:	53                   	push   %ebx
  801172:	57                   	push   %edi
  801173:	53                   	push   %ebx
  801174:	6a 00                	push   $0x0
  801176:	e8 3b fc ff ff       	call   800db6 <sys_page_map>
		if (r < 0)
  80117b:	83 c4 20             	add    $0x20,%esp
  80117e:	85 c0                	test   %eax,%eax
  801180:	0f 88 a5 00 00 00    	js     80122b <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	68 05 08 00 00       	push   $0x805
  80118e:	53                   	push   %ebx
  80118f:	6a 00                	push   $0x0
  801191:	53                   	push   %ebx
  801192:	6a 00                	push   $0x0
  801194:	e8 1d fc ff ff       	call   800db6 <sys_page_map>
  801199:	83 c4 20             	add    $0x20,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a3:	0f 4f c1             	cmovg  %ecx,%eax
  8011a6:	eb 1c                	jmp    8011c4 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8011a8:	83 ec 0c             	sub    $0xc,%esp
  8011ab:	6a 05                	push   $0x5
  8011ad:	53                   	push   %ebx
  8011ae:	57                   	push   %edi
  8011af:	53                   	push   %ebx
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 ff fb ff ff       	call   800db6 <sys_page_map>
  8011b7:	83 c4 20             	add    $0x20,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011c1:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 67                	js     80122f <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8011c8:	83 c6 01             	add    $0x1,%esi
  8011cb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011d1:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8011d7:	0f 85 1a ff ff ff    	jne    8010f7 <fork+0x59>
  8011dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8011e0:	83 ec 04             	sub    $0x4,%esp
  8011e3:	6a 07                	push   $0x7
  8011e5:	68 00 f0 bf ee       	push   $0xeebff000
  8011ea:	57                   	push   %edi
  8011eb:	e8 83 fb ff ff       	call   800d73 <sys_page_alloc>
	if (r < 0)
  8011f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8011f3:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	78 38                	js     801231 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	68 2f 24 80 00       	push   $0x80242f
  801201:	57                   	push   %edi
  801202:	e8 b7 fc ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
	if (r < 0)
  801207:	83 c4 10             	add    $0x10,%esp
		return r;
  80120a:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  80120c:	85 c0                	test   %eax,%eax
  80120e:	78 21                	js     801231 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	6a 02                	push   $0x2
  801215:	57                   	push   %edi
  801216:	e8 1f fc ff ff       	call   800e3a <sys_env_set_status>
	if (r < 0)
  80121b:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  80121e:	85 c0                	test   %eax,%eax
  801220:	0f 48 f8             	cmovs  %eax,%edi
  801223:	89 fa                	mov    %edi,%edx
  801225:	eb 0a                	jmp    801231 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801227:	89 c2                	mov    %eax,%edx
  801229:	eb 06                	jmp    801231 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80122b:	89 c2                	mov    %eax,%edx
  80122d:	eb 02                	jmp    801231 <fork+0x193>
  80122f:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801231:	89 d0                	mov    %edx,%eax
  801233:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801236:	5b                   	pop    %ebx
  801237:	5e                   	pop    %esi
  801238:	5f                   	pop    %edi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <sfork>:

// Challenge!
int
sfork(void)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801241:	68 6b 2d 80 00       	push   $0x802d6b
  801246:	68 c9 00 00 00       	push   $0xc9
  80124b:	68 60 2d 80 00       	push   $0x802d60
  801250:	e8 bd f0 ff ff       	call   800312 <_panic>

00801255 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801258:	8b 45 08             	mov    0x8(%ebp),%eax
  80125b:	05 00 00 00 30       	add    $0x30000000,%eax
  801260:	c1 e8 0c             	shr    $0xc,%eax
}
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
  80126b:	05 00 00 00 30       	add    $0x30000000,%eax
  801270:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801275:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801282:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801287:	89 c2                	mov    %eax,%edx
  801289:	c1 ea 16             	shr    $0x16,%edx
  80128c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801293:	f6 c2 01             	test   $0x1,%dl
  801296:	74 11                	je     8012a9 <fd_alloc+0x2d>
  801298:	89 c2                	mov    %eax,%edx
  80129a:	c1 ea 0c             	shr    $0xc,%edx
  80129d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a4:	f6 c2 01             	test   $0x1,%dl
  8012a7:	75 09                	jne    8012b2 <fd_alloc+0x36>
			*fd_store = fd;
  8012a9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b0:	eb 17                	jmp    8012c9 <fd_alloc+0x4d>
  8012b2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012bc:	75 c9                	jne    801287 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012be:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012c4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d1:	83 f8 1f             	cmp    $0x1f,%eax
  8012d4:	77 36                	ja     80130c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d6:	c1 e0 0c             	shl    $0xc,%eax
  8012d9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	c1 ea 16             	shr    $0x16,%edx
  8012e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ea:	f6 c2 01             	test   $0x1,%dl
  8012ed:	74 24                	je     801313 <fd_lookup+0x48>
  8012ef:	89 c2                	mov    %eax,%edx
  8012f1:	c1 ea 0c             	shr    $0xc,%edx
  8012f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fb:	f6 c2 01             	test   $0x1,%dl
  8012fe:	74 1a                	je     80131a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801300:	8b 55 0c             	mov    0xc(%ebp),%edx
  801303:	89 02                	mov    %eax,(%edx)
	return 0;
  801305:	b8 00 00 00 00       	mov    $0x0,%eax
  80130a:	eb 13                	jmp    80131f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801311:	eb 0c                	jmp    80131f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801318:	eb 05                	jmp    80131f <fd_lookup+0x54>
  80131a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    

00801321 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132a:	ba 04 2e 80 00       	mov    $0x802e04,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80132f:	eb 13                	jmp    801344 <dev_lookup+0x23>
  801331:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801334:	39 08                	cmp    %ecx,(%eax)
  801336:	75 0c                	jne    801344 <dev_lookup+0x23>
			*dev = devtab[i];
  801338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80133d:	b8 00 00 00 00       	mov    $0x0,%eax
  801342:	eb 2e                	jmp    801372 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801344:	8b 02                	mov    (%edx),%eax
  801346:	85 c0                	test   %eax,%eax
  801348:	75 e7                	jne    801331 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80134a:	a1 08 40 80 00       	mov    0x804008,%eax
  80134f:	8b 40 48             	mov    0x48(%eax),%eax
  801352:	83 ec 04             	sub    $0x4,%esp
  801355:	51                   	push   %ecx
  801356:	50                   	push   %eax
  801357:	68 84 2d 80 00       	push   $0x802d84
  80135c:	e8 8a f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  801361:	8b 45 0c             	mov    0xc(%ebp),%eax
  801364:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801372:	c9                   	leave  
  801373:	c3                   	ret    

00801374 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	56                   	push   %esi
  801378:	53                   	push   %ebx
  801379:	83 ec 10             	sub    $0x10,%esp
  80137c:	8b 75 08             	mov    0x8(%ebp),%esi
  80137f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801385:	50                   	push   %eax
  801386:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80138c:	c1 e8 0c             	shr    $0xc,%eax
  80138f:	50                   	push   %eax
  801390:	e8 36 ff ff ff       	call   8012cb <fd_lookup>
  801395:	83 c4 08             	add    $0x8,%esp
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 05                	js     8013a1 <fd_close+0x2d>
	    || fd != fd2)
  80139c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80139f:	74 0c                	je     8013ad <fd_close+0x39>
		return (must_exist ? r : 0);
  8013a1:	84 db                	test   %bl,%bl
  8013a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a8:	0f 44 c2             	cmove  %edx,%eax
  8013ab:	eb 41                	jmp    8013ee <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 36                	pushl  (%esi)
  8013b6:	e8 66 ff ff ff       	call   801321 <dev_lookup>
  8013bb:	89 c3                	mov    %eax,%ebx
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 1a                	js     8013de <fd_close+0x6a>
		if (dev->dev_close)
  8013c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013ca:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	74 0b                	je     8013de <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013d3:	83 ec 0c             	sub    $0xc,%esp
  8013d6:	56                   	push   %esi
  8013d7:	ff d0                	call   *%eax
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	56                   	push   %esi
  8013e2:	6a 00                	push   $0x0
  8013e4:	e8 0f fa ff ff       	call   800df8 <sys_page_unmap>
	return r;
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	89 d8                	mov    %ebx,%eax
}
  8013ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5e                   	pop    %esi
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	ff 75 08             	pushl  0x8(%ebp)
  801402:	e8 c4 fe ff ff       	call   8012cb <fd_lookup>
  801407:	83 c4 08             	add    $0x8,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 10                	js     80141e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	6a 01                	push   $0x1
  801413:	ff 75 f4             	pushl  -0xc(%ebp)
  801416:	e8 59 ff ff ff       	call   801374 <fd_close>
  80141b:	83 c4 10             	add    $0x10,%esp
}
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <close_all>:

void
close_all(void)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	53                   	push   %ebx
  801424:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801427:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80142c:	83 ec 0c             	sub    $0xc,%esp
  80142f:	53                   	push   %ebx
  801430:	e8 c0 ff ff ff       	call   8013f5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801435:	83 c3 01             	add    $0x1,%ebx
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	83 fb 20             	cmp    $0x20,%ebx
  80143e:	75 ec                	jne    80142c <close_all+0xc>
		close(i);
}
  801440:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	57                   	push   %edi
  801449:	56                   	push   %esi
  80144a:	53                   	push   %ebx
  80144b:	83 ec 2c             	sub    $0x2c,%esp
  80144e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801451:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	ff 75 08             	pushl  0x8(%ebp)
  801458:	e8 6e fe ff ff       	call   8012cb <fd_lookup>
  80145d:	83 c4 08             	add    $0x8,%esp
  801460:	85 c0                	test   %eax,%eax
  801462:	0f 88 c1 00 00 00    	js     801529 <dup+0xe4>
		return r;
	close(newfdnum);
  801468:	83 ec 0c             	sub    $0xc,%esp
  80146b:	56                   	push   %esi
  80146c:	e8 84 ff ff ff       	call   8013f5 <close>

	newfd = INDEX2FD(newfdnum);
  801471:	89 f3                	mov    %esi,%ebx
  801473:	c1 e3 0c             	shl    $0xc,%ebx
  801476:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80147c:	83 c4 04             	add    $0x4,%esp
  80147f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801482:	e8 de fd ff ff       	call   801265 <fd2data>
  801487:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801489:	89 1c 24             	mov    %ebx,(%esp)
  80148c:	e8 d4 fd ff ff       	call   801265 <fd2data>
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801497:	89 f8                	mov    %edi,%eax
  801499:	c1 e8 16             	shr    $0x16,%eax
  80149c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a3:	a8 01                	test   $0x1,%al
  8014a5:	74 37                	je     8014de <dup+0x99>
  8014a7:	89 f8                	mov    %edi,%eax
  8014a9:	c1 e8 0c             	shr    $0xc,%eax
  8014ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b3:	f6 c2 01             	test   $0x1,%dl
  8014b6:	74 26                	je     8014de <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bf:	83 ec 0c             	sub    $0xc,%esp
  8014c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c7:	50                   	push   %eax
  8014c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014cb:	6a 00                	push   $0x0
  8014cd:	57                   	push   %edi
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 e1 f8 ff ff       	call   800db6 <sys_page_map>
  8014d5:	89 c7                	mov    %eax,%edi
  8014d7:	83 c4 20             	add    $0x20,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 2e                	js     80150c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014e1:	89 d0                	mov    %edx,%eax
  8014e3:	c1 e8 0c             	shr    $0xc,%eax
  8014e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f5:	50                   	push   %eax
  8014f6:	53                   	push   %ebx
  8014f7:	6a 00                	push   $0x0
  8014f9:	52                   	push   %edx
  8014fa:	6a 00                	push   $0x0
  8014fc:	e8 b5 f8 ff ff       	call   800db6 <sys_page_map>
  801501:	89 c7                	mov    %eax,%edi
  801503:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801506:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801508:	85 ff                	test   %edi,%edi
  80150a:	79 1d                	jns    801529 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	53                   	push   %ebx
  801510:	6a 00                	push   $0x0
  801512:	e8 e1 f8 ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80151d:	6a 00                	push   $0x0
  80151f:	e8 d4 f8 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	89 f8                	mov    %edi,%eax
}
  801529:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5e                   	pop    %esi
  80152e:	5f                   	pop    %edi
  80152f:	5d                   	pop    %ebp
  801530:	c3                   	ret    

00801531 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 14             	sub    $0x14,%esp
  801538:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153e:	50                   	push   %eax
  80153f:	53                   	push   %ebx
  801540:	e8 86 fd ff ff       	call   8012cb <fd_lookup>
  801545:	83 c4 08             	add    $0x8,%esp
  801548:	89 c2                	mov    %eax,%edx
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 6d                	js     8015bb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801558:	ff 30                	pushl  (%eax)
  80155a:	e8 c2 fd ff ff       	call   801321 <dev_lookup>
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	78 4c                	js     8015b2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801566:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801569:	8b 42 08             	mov    0x8(%edx),%eax
  80156c:	83 e0 03             	and    $0x3,%eax
  80156f:	83 f8 01             	cmp    $0x1,%eax
  801572:	75 21                	jne    801595 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801574:	a1 08 40 80 00       	mov    0x804008,%eax
  801579:	8b 40 48             	mov    0x48(%eax),%eax
  80157c:	83 ec 04             	sub    $0x4,%esp
  80157f:	53                   	push   %ebx
  801580:	50                   	push   %eax
  801581:	68 c8 2d 80 00       	push   $0x802dc8
  801586:	e8 60 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801593:	eb 26                	jmp    8015bb <read+0x8a>
	}
	if (!dev->dev_read)
  801595:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801598:	8b 40 08             	mov    0x8(%eax),%eax
  80159b:	85 c0                	test   %eax,%eax
  80159d:	74 17                	je     8015b6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	ff 75 10             	pushl  0x10(%ebp)
  8015a5:	ff 75 0c             	pushl  0xc(%ebp)
  8015a8:	52                   	push   %edx
  8015a9:	ff d0                	call   *%eax
  8015ab:	89 c2                	mov    %eax,%edx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	eb 09                	jmp    8015bb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b2:	89 c2                	mov    %eax,%edx
  8015b4:	eb 05                	jmp    8015bb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015bb:	89 d0                	mov    %edx,%eax
  8015bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	57                   	push   %edi
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d6:	eb 21                	jmp    8015f9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d8:	83 ec 04             	sub    $0x4,%esp
  8015db:	89 f0                	mov    %esi,%eax
  8015dd:	29 d8                	sub    %ebx,%eax
  8015df:	50                   	push   %eax
  8015e0:	89 d8                	mov    %ebx,%eax
  8015e2:	03 45 0c             	add    0xc(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	57                   	push   %edi
  8015e7:	e8 45 ff ff ff       	call   801531 <read>
		if (m < 0)
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 10                	js     801603 <readn+0x41>
			return m;
		if (m == 0)
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	74 0a                	je     801601 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f7:	01 c3                	add    %eax,%ebx
  8015f9:	39 f3                	cmp    %esi,%ebx
  8015fb:	72 db                	jb     8015d8 <readn+0x16>
  8015fd:	89 d8                	mov    %ebx,%eax
  8015ff:	eb 02                	jmp    801603 <readn+0x41>
  801601:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5f                   	pop    %edi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	53                   	push   %ebx
  80160f:	83 ec 14             	sub    $0x14,%esp
  801612:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801615:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	53                   	push   %ebx
  80161a:	e8 ac fc ff ff       	call   8012cb <fd_lookup>
  80161f:	83 c4 08             	add    $0x8,%esp
  801622:	89 c2                	mov    %eax,%edx
  801624:	85 c0                	test   %eax,%eax
  801626:	78 68                	js     801690 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801632:	ff 30                	pushl  (%eax)
  801634:	e8 e8 fc ff ff       	call   801321 <dev_lookup>
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 47                	js     801687 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801640:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801643:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801647:	75 21                	jne    80166a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801649:	a1 08 40 80 00       	mov    0x804008,%eax
  80164e:	8b 40 48             	mov    0x48(%eax),%eax
  801651:	83 ec 04             	sub    $0x4,%esp
  801654:	53                   	push   %ebx
  801655:	50                   	push   %eax
  801656:	68 e4 2d 80 00       	push   $0x802de4
  80165b:	e8 8b ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801668:	eb 26                	jmp    801690 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80166a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166d:	8b 52 0c             	mov    0xc(%edx),%edx
  801670:	85 d2                	test   %edx,%edx
  801672:	74 17                	je     80168b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801674:	83 ec 04             	sub    $0x4,%esp
  801677:	ff 75 10             	pushl  0x10(%ebp)
  80167a:	ff 75 0c             	pushl  0xc(%ebp)
  80167d:	50                   	push   %eax
  80167e:	ff d2                	call   *%edx
  801680:	89 c2                	mov    %eax,%edx
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	eb 09                	jmp    801690 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801687:	89 c2                	mov    %eax,%edx
  801689:	eb 05                	jmp    801690 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80168b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801690:	89 d0                	mov    %edx,%eax
  801692:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <seek>:

int
seek(int fdnum, off_t offset)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016a0:	50                   	push   %eax
  8016a1:	ff 75 08             	pushl  0x8(%ebp)
  8016a4:	e8 22 fc ff ff       	call   8012cb <fd_lookup>
  8016a9:	83 c4 08             	add    $0x8,%esp
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 0e                	js     8016be <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 14             	sub    $0x14,%esp
  8016c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cd:	50                   	push   %eax
  8016ce:	53                   	push   %ebx
  8016cf:	e8 f7 fb ff ff       	call   8012cb <fd_lookup>
  8016d4:	83 c4 08             	add    $0x8,%esp
  8016d7:	89 c2                	mov    %eax,%edx
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 65                	js     801742 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e3:	50                   	push   %eax
  8016e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e7:	ff 30                	pushl  (%eax)
  8016e9:	e8 33 fc ff ff       	call   801321 <dev_lookup>
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 44                	js     801739 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016fc:	75 21                	jne    80171f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016fe:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801703:	8b 40 48             	mov    0x48(%eax),%eax
  801706:	83 ec 04             	sub    $0x4,%esp
  801709:	53                   	push   %ebx
  80170a:	50                   	push   %eax
  80170b:	68 a4 2d 80 00       	push   $0x802da4
  801710:	e8 d6 ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80171d:	eb 23                	jmp    801742 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80171f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801722:	8b 52 18             	mov    0x18(%edx),%edx
  801725:	85 d2                	test   %edx,%edx
  801727:	74 14                	je     80173d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	ff 75 0c             	pushl  0xc(%ebp)
  80172f:	50                   	push   %eax
  801730:	ff d2                	call   *%edx
  801732:	89 c2                	mov    %eax,%edx
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	eb 09                	jmp    801742 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801739:	89 c2                	mov    %eax,%edx
  80173b:	eb 05                	jmp    801742 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80173d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801742:	89 d0                	mov    %edx,%eax
  801744:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801747:	c9                   	leave  
  801748:	c3                   	ret    

00801749 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	53                   	push   %ebx
  80174d:	83 ec 14             	sub    $0x14,%esp
  801750:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801753:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	ff 75 08             	pushl  0x8(%ebp)
  80175a:	e8 6c fb ff ff       	call   8012cb <fd_lookup>
  80175f:	83 c4 08             	add    $0x8,%esp
  801762:	89 c2                	mov    %eax,%edx
  801764:	85 c0                	test   %eax,%eax
  801766:	78 58                	js     8017c0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801768:	83 ec 08             	sub    $0x8,%esp
  80176b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176e:	50                   	push   %eax
  80176f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801772:	ff 30                	pushl  (%eax)
  801774:	e8 a8 fb ff ff       	call   801321 <dev_lookup>
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 37                	js     8017b7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801780:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801783:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801787:	74 32                	je     8017bb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801789:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80178c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801793:	00 00 00 
	stat->st_isdir = 0;
  801796:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80179d:	00 00 00 
	stat->st_dev = dev;
  8017a0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	53                   	push   %ebx
  8017aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ad:	ff 50 14             	call   *0x14(%eax)
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	eb 09                	jmp    8017c0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	eb 05                	jmp    8017c0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017c0:	89 d0                	mov    %edx,%eax
  8017c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	56                   	push   %esi
  8017cb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	6a 00                	push   $0x0
  8017d1:	ff 75 08             	pushl  0x8(%ebp)
  8017d4:	e8 d6 01 00 00       	call   8019af <open>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 1b                	js     8017fd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	ff 75 0c             	pushl  0xc(%ebp)
  8017e8:	50                   	push   %eax
  8017e9:	e8 5b ff ff ff       	call   801749 <fstat>
  8017ee:	89 c6                	mov    %eax,%esi
	close(fd);
  8017f0:	89 1c 24             	mov    %ebx,(%esp)
  8017f3:	e8 fd fb ff ff       	call   8013f5 <close>
	return r;
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	89 f0                	mov    %esi,%eax
}
  8017fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	89 c6                	mov    %eax,%esi
  80180b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80180d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801814:	75 12                	jne    801828 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801816:	83 ec 0c             	sub    $0xc,%esp
  801819:	6a 01                	push   $0x1
  80181b:	e8 ee 0c 00 00       	call   80250e <ipc_find_env>
  801820:	a3 00 40 80 00       	mov    %eax,0x804000
  801825:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801828:	6a 07                	push   $0x7
  80182a:	68 00 50 80 00       	push   $0x805000
  80182f:	56                   	push   %esi
  801830:	ff 35 00 40 80 00    	pushl  0x804000
  801836:	e8 7f 0c 00 00       	call   8024ba <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80183b:	83 c4 0c             	add    $0xc,%esp
  80183e:	6a 00                	push   $0x0
  801840:	53                   	push   %ebx
  801841:	6a 00                	push   $0x0
  801843:	e8 0b 0c 00 00       	call   802453 <ipc_recv>
}
  801848:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5e                   	pop    %esi
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	8b 40 0c             	mov    0xc(%eax),%eax
  80185b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801860:	8b 45 0c             	mov    0xc(%ebp),%eax
  801863:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801868:	ba 00 00 00 00       	mov    $0x0,%edx
  80186d:	b8 02 00 00 00       	mov    $0x2,%eax
  801872:	e8 8d ff ff ff       	call   801804 <fsipc>
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80187f:	8b 45 08             	mov    0x8(%ebp),%eax
  801882:	8b 40 0c             	mov    0xc(%eax),%eax
  801885:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80188a:	ba 00 00 00 00       	mov    $0x0,%edx
  80188f:	b8 06 00 00 00       	mov    $0x6,%eax
  801894:	e8 6b ff ff ff       	call   801804 <fsipc>
}
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	53                   	push   %ebx
  80189f:	83 ec 04             	sub    $0x4,%esp
  8018a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ba:	e8 45 ff ff ff       	call   801804 <fsipc>
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	78 2c                	js     8018ef <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	68 00 50 80 00       	push   $0x805000
  8018cb:	53                   	push   %ebx
  8018cc:	e8 9f f0 ff ff       	call   800970 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d1:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018dc:	a1 84 50 80 00       	mov    0x805084,%eax
  8018e1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801900:	8b 52 0c             	mov    0xc(%edx),%edx
  801903:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801909:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80190e:	50                   	push   %eax
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	68 08 50 80 00       	push   $0x805008
  801917:	e8 e6 f1 ff ff       	call   800b02 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80191c:	ba 00 00 00 00       	mov    $0x0,%edx
  801921:	b8 04 00 00 00       	mov    $0x4,%eax
  801926:	e8 d9 fe ff ff       	call   801804 <fsipc>

}
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
  801932:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801935:	8b 45 08             	mov    0x8(%ebp),%eax
  801938:	8b 40 0c             	mov    0xc(%eax),%eax
  80193b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801940:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801946:	ba 00 00 00 00       	mov    $0x0,%edx
  80194b:	b8 03 00 00 00       	mov    $0x3,%eax
  801950:	e8 af fe ff ff       	call   801804 <fsipc>
  801955:	89 c3                	mov    %eax,%ebx
  801957:	85 c0                	test   %eax,%eax
  801959:	78 4b                	js     8019a6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80195b:	39 c6                	cmp    %eax,%esi
  80195d:	73 16                	jae    801975 <devfile_read+0x48>
  80195f:	68 18 2e 80 00       	push   $0x802e18
  801964:	68 1f 2e 80 00       	push   $0x802e1f
  801969:	6a 7c                	push   $0x7c
  80196b:	68 34 2e 80 00       	push   $0x802e34
  801970:	e8 9d e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801975:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80197a:	7e 16                	jle    801992 <devfile_read+0x65>
  80197c:	68 3f 2e 80 00       	push   $0x802e3f
  801981:	68 1f 2e 80 00       	push   $0x802e1f
  801986:	6a 7d                	push   $0x7d
  801988:	68 34 2e 80 00       	push   $0x802e34
  80198d:	e8 80 e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801992:	83 ec 04             	sub    $0x4,%esp
  801995:	50                   	push   %eax
  801996:	68 00 50 80 00       	push   $0x805000
  80199b:	ff 75 0c             	pushl  0xc(%ebp)
  80199e:	e8 5f f1 ff ff       	call   800b02 <memmove>
	return r;
  8019a3:	83 c4 10             	add    $0x10,%esp
}
  8019a6:	89 d8                	mov    %ebx,%eax
  8019a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	53                   	push   %ebx
  8019b3:	83 ec 20             	sub    $0x20,%esp
  8019b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019b9:	53                   	push   %ebx
  8019ba:	e8 78 ef ff ff       	call   800937 <strlen>
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c7:	7f 67                	jg     801a30 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cf:	50                   	push   %eax
  8019d0:	e8 a7 f8 ff ff       	call   80127c <fd_alloc>
  8019d5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 57                	js     801a35 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	53                   	push   %ebx
  8019e2:	68 00 50 80 00       	push   $0x805000
  8019e7:	e8 84 ef ff ff       	call   800970 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ef:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fc:	e8 03 fe ff ff       	call   801804 <fsipc>
  801a01:	89 c3                	mov    %eax,%ebx
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	85 c0                	test   %eax,%eax
  801a08:	79 14                	jns    801a1e <open+0x6f>
		fd_close(fd, 0);
  801a0a:	83 ec 08             	sub    $0x8,%esp
  801a0d:	6a 00                	push   $0x0
  801a0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a12:	e8 5d f9 ff ff       	call   801374 <fd_close>
		return r;
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	89 da                	mov    %ebx,%edx
  801a1c:	eb 17                	jmp    801a35 <open+0x86>
	}

	return fd2num(fd);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	ff 75 f4             	pushl  -0xc(%ebp)
  801a24:	e8 2c f8 ff ff       	call   801255 <fd2num>
  801a29:	89 c2                	mov    %eax,%edx
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	eb 05                	jmp    801a35 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a30:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a35:	89 d0                	mov    %edx,%eax
  801a37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a42:	ba 00 00 00 00       	mov    $0x0,%edx
  801a47:	b8 08 00 00 00       	mov    $0x8,%eax
  801a4c:	e8 b3 fd ff ff       	call   801804 <fsipc>
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a59:	68 4b 2e 80 00       	push   $0x802e4b
  801a5e:	ff 75 0c             	pushl  0xc(%ebp)
  801a61:	e8 0a ef ff ff       	call   800970 <strcpy>
	return 0;
}
  801a66:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	53                   	push   %ebx
  801a71:	83 ec 10             	sub    $0x10,%esp
  801a74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a77:	53                   	push   %ebx
  801a78:	e8 ca 0a 00 00       	call   802547 <pageref>
  801a7d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a80:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a85:	83 f8 01             	cmp    $0x1,%eax
  801a88:	75 10                	jne    801a9a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	ff 73 0c             	pushl  0xc(%ebx)
  801a90:	e8 c0 02 00 00       	call   801d55 <nsipc_close>
  801a95:	89 c2                	mov    %eax,%edx
  801a97:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a9a:	89 d0                	mov    %edx,%eax
  801a9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    

00801aa1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801aa7:	6a 00                	push   $0x0
  801aa9:	ff 75 10             	pushl  0x10(%ebp)
  801aac:	ff 75 0c             	pushl  0xc(%ebp)
  801aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab2:	ff 70 0c             	pushl  0xc(%eax)
  801ab5:	e8 78 03 00 00       	call   801e32 <nsipc_send>
}
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    

00801abc <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ac2:	6a 00                	push   $0x0
  801ac4:	ff 75 10             	pushl  0x10(%ebp)
  801ac7:	ff 75 0c             	pushl  0xc(%ebp)
  801aca:	8b 45 08             	mov    0x8(%ebp),%eax
  801acd:	ff 70 0c             	pushl  0xc(%eax)
  801ad0:	e8 f1 02 00 00       	call   801dc6 <nsipc_recv>
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801add:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ae0:	52                   	push   %edx
  801ae1:	50                   	push   %eax
  801ae2:	e8 e4 f7 ff ff       	call   8012cb <fd_lookup>
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 17                	js     801b05 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af1:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801af7:	39 08                	cmp    %ecx,(%eax)
  801af9:	75 05                	jne    801b00 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801afb:	8b 40 0c             	mov    0xc(%eax),%eax
  801afe:	eb 05                	jmp    801b05 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b00:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	83 ec 1c             	sub    $0x1c,%esp
  801b0f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b14:	50                   	push   %eax
  801b15:	e8 62 f7 ff ff       	call   80127c <fd_alloc>
  801b1a:	89 c3                	mov    %eax,%ebx
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	78 1b                	js     801b3e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b23:	83 ec 04             	sub    $0x4,%esp
  801b26:	68 07 04 00 00       	push   $0x407
  801b2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 3e f2 ff ff       	call   800d73 <sys_page_alloc>
  801b35:	89 c3                	mov    %eax,%ebx
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	79 10                	jns    801b4e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b3e:	83 ec 0c             	sub    $0xc,%esp
  801b41:	56                   	push   %esi
  801b42:	e8 0e 02 00 00       	call   801d55 <nsipc_close>
		return r;
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	89 d8                	mov    %ebx,%eax
  801b4c:	eb 24                	jmp    801b72 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b4e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b57:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b63:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b66:	83 ec 0c             	sub    $0xc,%esp
  801b69:	50                   	push   %eax
  801b6a:	e8 e6 f6 ff ff       	call   801255 <fd2num>
  801b6f:	83 c4 10             	add    $0x10,%esp
}
  801b72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b82:	e8 50 ff ff ff       	call   801ad7 <fd2sockid>
		return r;
  801b87:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	78 1f                	js     801bac <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b8d:	83 ec 04             	sub    $0x4,%esp
  801b90:	ff 75 10             	pushl  0x10(%ebp)
  801b93:	ff 75 0c             	pushl  0xc(%ebp)
  801b96:	50                   	push   %eax
  801b97:	e8 12 01 00 00       	call   801cae <nsipc_accept>
  801b9c:	83 c4 10             	add    $0x10,%esp
		return r;
  801b9f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 07                	js     801bac <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ba5:	e8 5d ff ff ff       	call   801b07 <alloc_sockfd>
  801baa:	89 c1                	mov    %eax,%ecx
}
  801bac:	89 c8                	mov    %ecx,%eax
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb9:	e8 19 ff ff ff       	call   801ad7 <fd2sockid>
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 12                	js     801bd4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801bc2:	83 ec 04             	sub    $0x4,%esp
  801bc5:	ff 75 10             	pushl  0x10(%ebp)
  801bc8:	ff 75 0c             	pushl  0xc(%ebp)
  801bcb:	50                   	push   %eax
  801bcc:	e8 2d 01 00 00       	call   801cfe <nsipc_bind>
  801bd1:	83 c4 10             	add    $0x10,%esp
}
  801bd4:	c9                   	leave  
  801bd5:	c3                   	ret    

00801bd6 <shutdown>:

int
shutdown(int s, int how)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdf:	e8 f3 fe ff ff       	call   801ad7 <fd2sockid>
  801be4:	85 c0                	test   %eax,%eax
  801be6:	78 0f                	js     801bf7 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801be8:	83 ec 08             	sub    $0x8,%esp
  801beb:	ff 75 0c             	pushl  0xc(%ebp)
  801bee:	50                   	push   %eax
  801bef:	e8 3f 01 00 00       	call   801d33 <nsipc_shutdown>
  801bf4:	83 c4 10             	add    $0x10,%esp
}
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bff:	8b 45 08             	mov    0x8(%ebp),%eax
  801c02:	e8 d0 fe ff ff       	call   801ad7 <fd2sockid>
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 12                	js     801c1d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c0b:	83 ec 04             	sub    $0x4,%esp
  801c0e:	ff 75 10             	pushl  0x10(%ebp)
  801c11:	ff 75 0c             	pushl  0xc(%ebp)
  801c14:	50                   	push   %eax
  801c15:	e8 55 01 00 00       	call   801d6f <nsipc_connect>
  801c1a:	83 c4 10             	add    $0x10,%esp
}
  801c1d:	c9                   	leave  
  801c1e:	c3                   	ret    

00801c1f <listen>:

int
listen(int s, int backlog)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	e8 aa fe ff ff       	call   801ad7 <fd2sockid>
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	78 0f                	js     801c40 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c31:	83 ec 08             	sub    $0x8,%esp
  801c34:	ff 75 0c             	pushl  0xc(%ebp)
  801c37:	50                   	push   %eax
  801c38:	e8 67 01 00 00       	call   801da4 <nsipc_listen>
  801c3d:	83 c4 10             	add    $0x10,%esp
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c48:	ff 75 10             	pushl  0x10(%ebp)
  801c4b:	ff 75 0c             	pushl  0xc(%ebp)
  801c4e:	ff 75 08             	pushl  0x8(%ebp)
  801c51:	e8 3a 02 00 00       	call   801e90 <nsipc_socket>
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 05                	js     801c62 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c5d:	e8 a5 fe ff ff       	call   801b07 <alloc_sockfd>
}
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    

00801c64 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	53                   	push   %ebx
  801c68:	83 ec 04             	sub    $0x4,%esp
  801c6b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c6d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c74:	75 12                	jne    801c88 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c76:	83 ec 0c             	sub    $0xc,%esp
  801c79:	6a 02                	push   $0x2
  801c7b:	e8 8e 08 00 00       	call   80250e <ipc_find_env>
  801c80:	a3 04 40 80 00       	mov    %eax,0x804004
  801c85:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c88:	6a 07                	push   $0x7
  801c8a:	68 00 60 80 00       	push   $0x806000
  801c8f:	53                   	push   %ebx
  801c90:	ff 35 04 40 80 00    	pushl  0x804004
  801c96:	e8 1f 08 00 00       	call   8024ba <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c9b:	83 c4 0c             	add    $0xc,%esp
  801c9e:	6a 00                	push   $0x0
  801ca0:	6a 00                	push   $0x0
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 aa 07 00 00       	call   802453 <ipc_recv>
}
  801ca9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cac:	c9                   	leave  
  801cad:	c3                   	ret    

00801cae <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	56                   	push   %esi
  801cb2:	53                   	push   %ebx
  801cb3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cbe:	8b 06                	mov    (%esi),%eax
  801cc0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cc5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cca:	e8 95 ff ff ff       	call   801c64 <nsipc>
  801ccf:	89 c3                	mov    %eax,%ebx
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	78 20                	js     801cf5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cd5:	83 ec 04             	sub    $0x4,%esp
  801cd8:	ff 35 10 60 80 00    	pushl  0x806010
  801cde:	68 00 60 80 00       	push   $0x806000
  801ce3:	ff 75 0c             	pushl  0xc(%ebp)
  801ce6:	e8 17 ee ff ff       	call   800b02 <memmove>
		*addrlen = ret->ret_addrlen;
  801ceb:	a1 10 60 80 00       	mov    0x806010,%eax
  801cf0:	89 06                	mov    %eax,(%esi)
  801cf2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cf5:	89 d8                	mov    %ebx,%eax
  801cf7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfa:	5b                   	pop    %ebx
  801cfb:	5e                   	pop    %esi
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	53                   	push   %ebx
  801d02:	83 ec 08             	sub    $0x8,%esp
  801d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d08:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d10:	53                   	push   %ebx
  801d11:	ff 75 0c             	pushl  0xc(%ebp)
  801d14:	68 04 60 80 00       	push   $0x806004
  801d19:	e8 e4 ed ff ff       	call   800b02 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d1e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d24:	b8 02 00 00 00       	mov    $0x2,%eax
  801d29:	e8 36 ff ff ff       	call   801c64 <nsipc>
}
  801d2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    

00801d33 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d44:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d49:	b8 03 00 00 00       	mov    $0x3,%eax
  801d4e:	e8 11 ff ff ff       	call   801c64 <nsipc>
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <nsipc_close>:

int
nsipc_close(int s)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d63:	b8 04 00 00 00       	mov    $0x4,%eax
  801d68:	e8 f7 fe ff ff       	call   801c64 <nsipc>
}
  801d6d:	c9                   	leave  
  801d6e:	c3                   	ret    

00801d6f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	53                   	push   %ebx
  801d73:	83 ec 08             	sub    $0x8,%esp
  801d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d81:	53                   	push   %ebx
  801d82:	ff 75 0c             	pushl  0xc(%ebp)
  801d85:	68 04 60 80 00       	push   $0x806004
  801d8a:	e8 73 ed ff ff       	call   800b02 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d8f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d95:	b8 05 00 00 00       	mov    $0x5,%eax
  801d9a:	e8 c5 fe ff ff       	call   801c64 <nsipc>
}
  801d9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801daa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dad:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801db2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dba:	b8 06 00 00 00       	mov    $0x6,%eax
  801dbf:	e8 a0 fe ff ff       	call   801c64 <nsipc>
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	56                   	push   %esi
  801dca:	53                   	push   %ebx
  801dcb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dce:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dd6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ddc:	8b 45 14             	mov    0x14(%ebp),%eax
  801ddf:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801de4:	b8 07 00 00 00       	mov    $0x7,%eax
  801de9:	e8 76 fe ff ff       	call   801c64 <nsipc>
  801dee:	89 c3                	mov    %eax,%ebx
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 35                	js     801e29 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801df4:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801df9:	7f 04                	jg     801dff <nsipc_recv+0x39>
  801dfb:	39 c6                	cmp    %eax,%esi
  801dfd:	7d 16                	jge    801e15 <nsipc_recv+0x4f>
  801dff:	68 57 2e 80 00       	push   $0x802e57
  801e04:	68 1f 2e 80 00       	push   $0x802e1f
  801e09:	6a 62                	push   $0x62
  801e0b:	68 6c 2e 80 00       	push   $0x802e6c
  801e10:	e8 fd e4 ff ff       	call   800312 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e15:	83 ec 04             	sub    $0x4,%esp
  801e18:	50                   	push   %eax
  801e19:	68 00 60 80 00       	push   $0x806000
  801e1e:	ff 75 0c             	pushl  0xc(%ebp)
  801e21:	e8 dc ec ff ff       	call   800b02 <memmove>
  801e26:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e29:	89 d8                	mov    %ebx,%eax
  801e2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5e                   	pop    %esi
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    

00801e32 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	53                   	push   %ebx
  801e36:	83 ec 04             	sub    $0x4,%esp
  801e39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e44:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e4a:	7e 16                	jle    801e62 <nsipc_send+0x30>
  801e4c:	68 78 2e 80 00       	push   $0x802e78
  801e51:	68 1f 2e 80 00       	push   $0x802e1f
  801e56:	6a 6d                	push   $0x6d
  801e58:	68 6c 2e 80 00       	push   $0x802e6c
  801e5d:	e8 b0 e4 ff ff       	call   800312 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e62:	83 ec 04             	sub    $0x4,%esp
  801e65:	53                   	push   %ebx
  801e66:	ff 75 0c             	pushl  0xc(%ebp)
  801e69:	68 0c 60 80 00       	push   $0x80600c
  801e6e:	e8 8f ec ff ff       	call   800b02 <memmove>
	nsipcbuf.send.req_size = size;
  801e73:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e79:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e81:	b8 08 00 00 00       	mov    $0x8,%eax
  801e86:	e8 d9 fd ff ff       	call   801c64 <nsipc>
}
  801e8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e8e:	c9                   	leave  
  801e8f:	c3                   	ret    

00801e90 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e96:	8b 45 08             	mov    0x8(%ebp),%eax
  801e99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ea6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801eae:	b8 09 00 00 00       	mov    $0x9,%eax
  801eb3:	e8 ac fd ff ff       	call   801c64 <nsipc>
}
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	56                   	push   %esi
  801ebe:	53                   	push   %ebx
  801ebf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ec2:	83 ec 0c             	sub    $0xc,%esp
  801ec5:	ff 75 08             	pushl  0x8(%ebp)
  801ec8:	e8 98 f3 ff ff       	call   801265 <fd2data>
  801ecd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ecf:	83 c4 08             	add    $0x8,%esp
  801ed2:	68 84 2e 80 00       	push   $0x802e84
  801ed7:	53                   	push   %ebx
  801ed8:	e8 93 ea ff ff       	call   800970 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801edd:	8b 46 04             	mov    0x4(%esi),%eax
  801ee0:	2b 06                	sub    (%esi),%eax
  801ee2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ee8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eef:	00 00 00 
	stat->st_dev = &devpipe;
  801ef2:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801ef9:	30 80 00 
	return 0;
}
  801efc:	b8 00 00 00 00       	mov    $0x0,%eax
  801f01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f04:	5b                   	pop    %ebx
  801f05:	5e                   	pop    %esi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	53                   	push   %ebx
  801f0c:	83 ec 0c             	sub    $0xc,%esp
  801f0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f12:	53                   	push   %ebx
  801f13:	6a 00                	push   $0x0
  801f15:	e8 de ee ff ff       	call   800df8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f1a:	89 1c 24             	mov    %ebx,(%esp)
  801f1d:	e8 43 f3 ff ff       	call   801265 <fd2data>
  801f22:	83 c4 08             	add    $0x8,%esp
  801f25:	50                   	push   %eax
  801f26:	6a 00                	push   $0x0
  801f28:	e8 cb ee ff ff       	call   800df8 <sys_page_unmap>
}
  801f2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	57                   	push   %edi
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	83 ec 1c             	sub    $0x1c,%esp
  801f3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f3e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f40:	a1 08 40 80 00       	mov    0x804008,%eax
  801f45:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f48:	83 ec 0c             	sub    $0xc,%esp
  801f4b:	ff 75 e0             	pushl  -0x20(%ebp)
  801f4e:	e8 f4 05 00 00       	call   802547 <pageref>
  801f53:	89 c3                	mov    %eax,%ebx
  801f55:	89 3c 24             	mov    %edi,(%esp)
  801f58:	e8 ea 05 00 00       	call   802547 <pageref>
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	39 c3                	cmp    %eax,%ebx
  801f62:	0f 94 c1             	sete   %cl
  801f65:	0f b6 c9             	movzbl %cl,%ecx
  801f68:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f6b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f71:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f74:	39 ce                	cmp    %ecx,%esi
  801f76:	74 1b                	je     801f93 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f78:	39 c3                	cmp    %eax,%ebx
  801f7a:	75 c4                	jne    801f40 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f7c:	8b 42 58             	mov    0x58(%edx),%eax
  801f7f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f82:	50                   	push   %eax
  801f83:	56                   	push   %esi
  801f84:	68 8b 2e 80 00       	push   $0x802e8b
  801f89:	e8 5d e4 ff ff       	call   8003eb <cprintf>
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	eb ad                	jmp    801f40 <_pipeisclosed+0xe>
	}
}
  801f93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5f                   	pop    %edi
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 28             	sub    $0x28,%esp
  801fa7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801faa:	56                   	push   %esi
  801fab:	e8 b5 f2 ff ff       	call   801265 <fd2data>
  801fb0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb2:	83 c4 10             	add    $0x10,%esp
  801fb5:	bf 00 00 00 00       	mov    $0x0,%edi
  801fba:	eb 4b                	jmp    802007 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fbc:	89 da                	mov    %ebx,%edx
  801fbe:	89 f0                	mov    %esi,%eax
  801fc0:	e8 6d ff ff ff       	call   801f32 <_pipeisclosed>
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	75 48                	jne    802011 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fc9:	e8 86 ed ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fce:	8b 43 04             	mov    0x4(%ebx),%eax
  801fd1:	8b 0b                	mov    (%ebx),%ecx
  801fd3:	8d 51 20             	lea    0x20(%ecx),%edx
  801fd6:	39 d0                	cmp    %edx,%eax
  801fd8:	73 e2                	jae    801fbc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fdd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fe1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fe4:	89 c2                	mov    %eax,%edx
  801fe6:	c1 fa 1f             	sar    $0x1f,%edx
  801fe9:	89 d1                	mov    %edx,%ecx
  801feb:	c1 e9 1b             	shr    $0x1b,%ecx
  801fee:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ff1:	83 e2 1f             	and    $0x1f,%edx
  801ff4:	29 ca                	sub    %ecx,%edx
  801ff6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ffa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ffe:	83 c0 01             	add    $0x1,%eax
  802001:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802004:	83 c7 01             	add    $0x1,%edi
  802007:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80200a:	75 c2                	jne    801fce <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80200c:	8b 45 10             	mov    0x10(%ebp),%eax
  80200f:	eb 05                	jmp    802016 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802011:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802016:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802019:	5b                   	pop    %ebx
  80201a:	5e                   	pop    %esi
  80201b:	5f                   	pop    %edi
  80201c:	5d                   	pop    %ebp
  80201d:	c3                   	ret    

0080201e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 18             	sub    $0x18,%esp
  802027:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80202a:	57                   	push   %edi
  80202b:	e8 35 f2 ff ff       	call   801265 <fd2data>
  802030:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802032:	83 c4 10             	add    $0x10,%esp
  802035:	bb 00 00 00 00       	mov    $0x0,%ebx
  80203a:	eb 3d                	jmp    802079 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80203c:	85 db                	test   %ebx,%ebx
  80203e:	74 04                	je     802044 <devpipe_read+0x26>
				return i;
  802040:	89 d8                	mov    %ebx,%eax
  802042:	eb 44                	jmp    802088 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802044:	89 f2                	mov    %esi,%edx
  802046:	89 f8                	mov    %edi,%eax
  802048:	e8 e5 fe ff ff       	call   801f32 <_pipeisclosed>
  80204d:	85 c0                	test   %eax,%eax
  80204f:	75 32                	jne    802083 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802051:	e8 fe ec ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802056:	8b 06                	mov    (%esi),%eax
  802058:	3b 46 04             	cmp    0x4(%esi),%eax
  80205b:	74 df                	je     80203c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80205d:	99                   	cltd   
  80205e:	c1 ea 1b             	shr    $0x1b,%edx
  802061:	01 d0                	add    %edx,%eax
  802063:	83 e0 1f             	and    $0x1f,%eax
  802066:	29 d0                	sub    %edx,%eax
  802068:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80206d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802070:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802073:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802076:	83 c3 01             	add    $0x1,%ebx
  802079:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80207c:	75 d8                	jne    802056 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80207e:	8b 45 10             	mov    0x10(%ebp),%eax
  802081:	eb 05                	jmp    802088 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802083:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208b:	5b                   	pop    %ebx
  80208c:	5e                   	pop    %esi
  80208d:	5f                   	pop    %edi
  80208e:	5d                   	pop    %ebp
  80208f:	c3                   	ret    

00802090 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	56                   	push   %esi
  802094:	53                   	push   %ebx
  802095:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802098:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209b:	50                   	push   %eax
  80209c:	e8 db f1 ff ff       	call   80127c <fd_alloc>
  8020a1:	83 c4 10             	add    $0x10,%esp
  8020a4:	89 c2                	mov    %eax,%edx
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	0f 88 2c 01 00 00    	js     8021da <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ae:	83 ec 04             	sub    $0x4,%esp
  8020b1:	68 07 04 00 00       	push   $0x407
  8020b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b9:	6a 00                	push   $0x0
  8020bb:	e8 b3 ec ff ff       	call   800d73 <sys_page_alloc>
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	89 c2                	mov    %eax,%edx
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	0f 88 0d 01 00 00    	js     8021da <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020cd:	83 ec 0c             	sub    $0xc,%esp
  8020d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020d3:	50                   	push   %eax
  8020d4:	e8 a3 f1 ff ff       	call   80127c <fd_alloc>
  8020d9:	89 c3                	mov    %eax,%ebx
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	0f 88 e2 00 00 00    	js     8021c8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e6:	83 ec 04             	sub    $0x4,%esp
  8020e9:	68 07 04 00 00       	push   $0x407
  8020ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f1:	6a 00                	push   $0x0
  8020f3:	e8 7b ec ff ff       	call   800d73 <sys_page_alloc>
  8020f8:	89 c3                	mov    %eax,%ebx
  8020fa:	83 c4 10             	add    $0x10,%esp
  8020fd:	85 c0                	test   %eax,%eax
  8020ff:	0f 88 c3 00 00 00    	js     8021c8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802105:	83 ec 0c             	sub    $0xc,%esp
  802108:	ff 75 f4             	pushl  -0xc(%ebp)
  80210b:	e8 55 f1 ff ff       	call   801265 <fd2data>
  802110:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802112:	83 c4 0c             	add    $0xc,%esp
  802115:	68 07 04 00 00       	push   $0x407
  80211a:	50                   	push   %eax
  80211b:	6a 00                	push   $0x0
  80211d:	e8 51 ec ff ff       	call   800d73 <sys_page_alloc>
  802122:	89 c3                	mov    %eax,%ebx
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	85 c0                	test   %eax,%eax
  802129:	0f 88 89 00 00 00    	js     8021b8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212f:	83 ec 0c             	sub    $0xc,%esp
  802132:	ff 75 f0             	pushl  -0x10(%ebp)
  802135:	e8 2b f1 ff ff       	call   801265 <fd2data>
  80213a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802141:	50                   	push   %eax
  802142:	6a 00                	push   $0x0
  802144:	56                   	push   %esi
  802145:	6a 00                	push   $0x0
  802147:	e8 6a ec ff ff       	call   800db6 <sys_page_map>
  80214c:	89 c3                	mov    %eax,%ebx
  80214e:	83 c4 20             	add    $0x20,%esp
  802151:	85 c0                	test   %eax,%eax
  802153:	78 55                	js     8021aa <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802155:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80215b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802160:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802163:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80216a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802170:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802173:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802175:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802178:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80217f:	83 ec 0c             	sub    $0xc,%esp
  802182:	ff 75 f4             	pushl  -0xc(%ebp)
  802185:	e8 cb f0 ff ff       	call   801255 <fd2num>
  80218a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80218f:	83 c4 04             	add    $0x4,%esp
  802192:	ff 75 f0             	pushl  -0x10(%ebp)
  802195:	e8 bb f0 ff ff       	call   801255 <fd2num>
  80219a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8021a8:	eb 30                	jmp    8021da <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021aa:	83 ec 08             	sub    $0x8,%esp
  8021ad:	56                   	push   %esi
  8021ae:	6a 00                	push   $0x0
  8021b0:	e8 43 ec ff ff       	call   800df8 <sys_page_unmap>
  8021b5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021b8:	83 ec 08             	sub    $0x8,%esp
  8021bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8021be:	6a 00                	push   $0x0
  8021c0:	e8 33 ec ff ff       	call   800df8 <sys_page_unmap>
  8021c5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021c8:	83 ec 08             	sub    $0x8,%esp
  8021cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ce:	6a 00                	push   $0x0
  8021d0:	e8 23 ec ff ff       	call   800df8 <sys_page_unmap>
  8021d5:	83 c4 10             	add    $0x10,%esp
  8021d8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    

008021e3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021e3:	55                   	push   %ebp
  8021e4:	89 e5                	mov    %esp,%ebp
  8021e6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ec:	50                   	push   %eax
  8021ed:	ff 75 08             	pushl  0x8(%ebp)
  8021f0:	e8 d6 f0 ff ff       	call   8012cb <fd_lookup>
  8021f5:	83 c4 10             	add    $0x10,%esp
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	78 18                	js     802214 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021fc:	83 ec 0c             	sub    $0xc,%esp
  8021ff:	ff 75 f4             	pushl  -0xc(%ebp)
  802202:	e8 5e f0 ff ff       	call   801265 <fd2data>
	return _pipeisclosed(fd, p);
  802207:	89 c2                	mov    %eax,%edx
  802209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220c:	e8 21 fd ff ff       	call   801f32 <_pipeisclosed>
  802211:	83 c4 10             	add    $0x10,%esp
}
  802214:	c9                   	leave  
  802215:	c3                   	ret    

00802216 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	56                   	push   %esi
  80221a:	53                   	push   %ebx
  80221b:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80221e:	85 f6                	test   %esi,%esi
  802220:	75 16                	jne    802238 <wait+0x22>
  802222:	68 a3 2e 80 00       	push   $0x802ea3
  802227:	68 1f 2e 80 00       	push   $0x802e1f
  80222c:	6a 09                	push   $0x9
  80222e:	68 ae 2e 80 00       	push   $0x802eae
  802233:	e8 da e0 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  802238:	89 f3                	mov    %esi,%ebx
  80223a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802240:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802243:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802249:	eb 05                	jmp    802250 <wait+0x3a>
		sys_yield();
  80224b:	e8 04 eb ff ff       	call   800d54 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802250:	8b 43 48             	mov    0x48(%ebx),%eax
  802253:	39 c6                	cmp    %eax,%esi
  802255:	75 07                	jne    80225e <wait+0x48>
  802257:	8b 43 54             	mov    0x54(%ebx),%eax
  80225a:	85 c0                	test   %eax,%eax
  80225c:	75 ed                	jne    80224b <wait+0x35>
		sys_yield();
}
  80225e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802261:	5b                   	pop    %ebx
  802262:	5e                   	pop    %esi
  802263:	5d                   	pop    %ebp
  802264:	c3                   	ret    

00802265 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802265:	55                   	push   %ebp
  802266:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802268:	b8 00 00 00 00       	mov    $0x0,%eax
  80226d:	5d                   	pop    %ebp
  80226e:	c3                   	ret    

0080226f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80226f:	55                   	push   %ebp
  802270:	89 e5                	mov    %esp,%ebp
  802272:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802275:	68 b9 2e 80 00       	push   $0x802eb9
  80227a:	ff 75 0c             	pushl  0xc(%ebp)
  80227d:	e8 ee e6 ff ff       	call   800970 <strcpy>
	return 0;
}
  802282:	b8 00 00 00 00       	mov    $0x0,%eax
  802287:	c9                   	leave  
  802288:	c3                   	ret    

00802289 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802289:	55                   	push   %ebp
  80228a:	89 e5                	mov    %esp,%ebp
  80228c:	57                   	push   %edi
  80228d:	56                   	push   %esi
  80228e:	53                   	push   %ebx
  80228f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802295:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80229a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022a0:	eb 2d                	jmp    8022cf <devcons_write+0x46>
		m = n - tot;
  8022a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022a5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022a7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022aa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022af:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022b2:	83 ec 04             	sub    $0x4,%esp
  8022b5:	53                   	push   %ebx
  8022b6:	03 45 0c             	add    0xc(%ebp),%eax
  8022b9:	50                   	push   %eax
  8022ba:	57                   	push   %edi
  8022bb:	e8 42 e8 ff ff       	call   800b02 <memmove>
		sys_cputs(buf, m);
  8022c0:	83 c4 08             	add    $0x8,%esp
  8022c3:	53                   	push   %ebx
  8022c4:	57                   	push   %edi
  8022c5:	e8 ed e9 ff ff       	call   800cb7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022ca:	01 de                	add    %ebx,%esi
  8022cc:	83 c4 10             	add    $0x10,%esp
  8022cf:	89 f0                	mov    %esi,%eax
  8022d1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022d4:	72 cc                	jb     8022a2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022d9:	5b                   	pop    %ebx
  8022da:	5e                   	pop    %esi
  8022db:	5f                   	pop    %edi
  8022dc:	5d                   	pop    %ebp
  8022dd:	c3                   	ret    

008022de <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022de:	55                   	push   %ebp
  8022df:	89 e5                	mov    %esp,%ebp
  8022e1:	83 ec 08             	sub    $0x8,%esp
  8022e4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ed:	74 2a                	je     802319 <devcons_read+0x3b>
  8022ef:	eb 05                	jmp    8022f6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022f1:	e8 5e ea ff ff       	call   800d54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022f6:	e8 da e9 ff ff       	call   800cd5 <sys_cgetc>
  8022fb:	85 c0                	test   %eax,%eax
  8022fd:	74 f2                	je     8022f1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022ff:	85 c0                	test   %eax,%eax
  802301:	78 16                	js     802319 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802303:	83 f8 04             	cmp    $0x4,%eax
  802306:	74 0c                	je     802314 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802308:	8b 55 0c             	mov    0xc(%ebp),%edx
  80230b:	88 02                	mov    %al,(%edx)
	return 1;
  80230d:	b8 01 00 00 00       	mov    $0x1,%eax
  802312:	eb 05                	jmp    802319 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802314:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802319:	c9                   	leave  
  80231a:	c3                   	ret    

0080231b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80231b:	55                   	push   %ebp
  80231c:	89 e5                	mov    %esp,%ebp
  80231e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802321:	8b 45 08             	mov    0x8(%ebp),%eax
  802324:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802327:	6a 01                	push   $0x1
  802329:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80232c:	50                   	push   %eax
  80232d:	e8 85 e9 ff ff       	call   800cb7 <sys_cputs>
}
  802332:	83 c4 10             	add    $0x10,%esp
  802335:	c9                   	leave  
  802336:	c3                   	ret    

00802337 <getchar>:

int
getchar(void)
{
  802337:	55                   	push   %ebp
  802338:	89 e5                	mov    %esp,%ebp
  80233a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80233d:	6a 01                	push   $0x1
  80233f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802342:	50                   	push   %eax
  802343:	6a 00                	push   $0x0
  802345:	e8 e7 f1 ff ff       	call   801531 <read>
	if (r < 0)
  80234a:	83 c4 10             	add    $0x10,%esp
  80234d:	85 c0                	test   %eax,%eax
  80234f:	78 0f                	js     802360 <getchar+0x29>
		return r;
	if (r < 1)
  802351:	85 c0                	test   %eax,%eax
  802353:	7e 06                	jle    80235b <getchar+0x24>
		return -E_EOF;
	return c;
  802355:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802359:	eb 05                	jmp    802360 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80235b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802360:	c9                   	leave  
  802361:	c3                   	ret    

00802362 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802362:	55                   	push   %ebp
  802363:	89 e5                	mov    %esp,%ebp
  802365:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802368:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236b:	50                   	push   %eax
  80236c:	ff 75 08             	pushl  0x8(%ebp)
  80236f:	e8 57 ef ff ff       	call   8012cb <fd_lookup>
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	85 c0                	test   %eax,%eax
  802379:	78 11                	js     80238c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80237b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237e:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802384:	39 10                	cmp    %edx,(%eax)
  802386:	0f 94 c0             	sete   %al
  802389:	0f b6 c0             	movzbl %al,%eax
}
  80238c:	c9                   	leave  
  80238d:	c3                   	ret    

0080238e <opencons>:

int
opencons(void)
{
  80238e:	55                   	push   %ebp
  80238f:	89 e5                	mov    %esp,%ebp
  802391:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802394:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802397:	50                   	push   %eax
  802398:	e8 df ee ff ff       	call   80127c <fd_alloc>
  80239d:	83 c4 10             	add    $0x10,%esp
		return r;
  8023a0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023a2:	85 c0                	test   %eax,%eax
  8023a4:	78 3e                	js     8023e4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023a6:	83 ec 04             	sub    $0x4,%esp
  8023a9:	68 07 04 00 00       	push   $0x407
  8023ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b1:	6a 00                	push   $0x0
  8023b3:	e8 bb e9 ff ff       	call   800d73 <sys_page_alloc>
  8023b8:	83 c4 10             	add    $0x10,%esp
		return r;
  8023bb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023bd:	85 c0                	test   %eax,%eax
  8023bf:	78 23                	js     8023e4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023c1:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8023c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023cf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023d6:	83 ec 0c             	sub    $0xc,%esp
  8023d9:	50                   	push   %eax
  8023da:	e8 76 ee ff ff       	call   801255 <fd2num>
  8023df:	89 c2                	mov    %eax,%edx
  8023e1:	83 c4 10             	add    $0x10,%esp
}
  8023e4:	89 d0                	mov    %edx,%eax
  8023e6:	c9                   	leave  
  8023e7:	c3                   	ret    

008023e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023e8:	55                   	push   %ebp
  8023e9:	89 e5                	mov    %esp,%ebp
  8023eb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023ee:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023f5:	75 2e                	jne    802425 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8023f7:	e8 39 e9 ff ff       	call   800d35 <sys_getenvid>
  8023fc:	83 ec 04             	sub    $0x4,%esp
  8023ff:	68 07 0e 00 00       	push   $0xe07
  802404:	68 00 f0 bf ee       	push   $0xeebff000
  802409:	50                   	push   %eax
  80240a:	e8 64 e9 ff ff       	call   800d73 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80240f:	e8 21 e9 ff ff       	call   800d35 <sys_getenvid>
  802414:	83 c4 08             	add    $0x8,%esp
  802417:	68 2f 24 80 00       	push   $0x80242f
  80241c:	50                   	push   %eax
  80241d:	e8 9c ea ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
  802422:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802425:	8b 45 08             	mov    0x8(%ebp),%eax
  802428:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80242d:	c9                   	leave  
  80242e:	c3                   	ret    

0080242f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80242f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802430:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802435:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802437:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80243a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80243e:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802442:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802445:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802448:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802449:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80244c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80244d:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80244e:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802452:	c3                   	ret    

00802453 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802453:	55                   	push   %ebp
  802454:	89 e5                	mov    %esp,%ebp
  802456:	56                   	push   %esi
  802457:	53                   	push   %ebx
  802458:	8b 75 08             	mov    0x8(%ebp),%esi
  80245b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80245e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802461:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802463:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802468:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80246b:	83 ec 0c             	sub    $0xc,%esp
  80246e:	50                   	push   %eax
  80246f:	e8 af ea ff ff       	call   800f23 <sys_ipc_recv>

	if (from_env_store != NULL)
  802474:	83 c4 10             	add    $0x10,%esp
  802477:	85 f6                	test   %esi,%esi
  802479:	74 14                	je     80248f <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80247b:	ba 00 00 00 00       	mov    $0x0,%edx
  802480:	85 c0                	test   %eax,%eax
  802482:	78 09                	js     80248d <ipc_recv+0x3a>
  802484:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80248a:	8b 52 74             	mov    0x74(%edx),%edx
  80248d:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80248f:	85 db                	test   %ebx,%ebx
  802491:	74 14                	je     8024a7 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802493:	ba 00 00 00 00       	mov    $0x0,%edx
  802498:	85 c0                	test   %eax,%eax
  80249a:	78 09                	js     8024a5 <ipc_recv+0x52>
  80249c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8024a2:	8b 52 78             	mov    0x78(%edx),%edx
  8024a5:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8024a7:	85 c0                	test   %eax,%eax
  8024a9:	78 08                	js     8024b3 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8024ab:	a1 08 40 80 00       	mov    0x804008,%eax
  8024b0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b6:	5b                   	pop    %ebx
  8024b7:	5e                   	pop    %esi
  8024b8:	5d                   	pop    %ebp
  8024b9:	c3                   	ret    

008024ba <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024ba:	55                   	push   %ebp
  8024bb:	89 e5                	mov    %esp,%ebp
  8024bd:	57                   	push   %edi
  8024be:	56                   	push   %esi
  8024bf:	53                   	push   %ebx
  8024c0:	83 ec 0c             	sub    $0xc,%esp
  8024c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8024cc:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8024ce:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024d3:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8024d6:	ff 75 14             	pushl  0x14(%ebp)
  8024d9:	53                   	push   %ebx
  8024da:	56                   	push   %esi
  8024db:	57                   	push   %edi
  8024dc:	e8 1f ea ff ff       	call   800f00 <sys_ipc_try_send>

		if (err < 0) {
  8024e1:	83 c4 10             	add    $0x10,%esp
  8024e4:	85 c0                	test   %eax,%eax
  8024e6:	79 1e                	jns    802506 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8024e8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024eb:	75 07                	jne    8024f4 <ipc_send+0x3a>
				sys_yield();
  8024ed:	e8 62 e8 ff ff       	call   800d54 <sys_yield>
  8024f2:	eb e2                	jmp    8024d6 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8024f4:	50                   	push   %eax
  8024f5:	68 c5 2e 80 00       	push   $0x802ec5
  8024fa:	6a 49                	push   $0x49
  8024fc:	68 d2 2e 80 00       	push   $0x802ed2
  802501:	e8 0c de ff ff       	call   800312 <_panic>
		}

	} while (err < 0);

}
  802506:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802509:	5b                   	pop    %ebx
  80250a:	5e                   	pop    %esi
  80250b:	5f                   	pop    %edi
  80250c:	5d                   	pop    %ebp
  80250d:	c3                   	ret    

0080250e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80250e:	55                   	push   %ebp
  80250f:	89 e5                	mov    %esp,%ebp
  802511:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802514:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802519:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80251c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802522:	8b 52 50             	mov    0x50(%edx),%edx
  802525:	39 ca                	cmp    %ecx,%edx
  802527:	75 0d                	jne    802536 <ipc_find_env+0x28>
			return envs[i].env_id;
  802529:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80252c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802531:	8b 40 48             	mov    0x48(%eax),%eax
  802534:	eb 0f                	jmp    802545 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802536:	83 c0 01             	add    $0x1,%eax
  802539:	3d 00 04 00 00       	cmp    $0x400,%eax
  80253e:	75 d9                	jne    802519 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802540:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802545:	5d                   	pop    %ebp
  802546:	c3                   	ret    

00802547 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802547:	55                   	push   %ebp
  802548:	89 e5                	mov    %esp,%ebp
  80254a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80254d:	89 d0                	mov    %edx,%eax
  80254f:	c1 e8 16             	shr    $0x16,%eax
  802552:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802559:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80255e:	f6 c1 01             	test   $0x1,%cl
  802561:	74 1d                	je     802580 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802563:	c1 ea 0c             	shr    $0xc,%edx
  802566:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80256d:	f6 c2 01             	test   $0x1,%dl
  802570:	74 0e                	je     802580 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802572:	c1 ea 0c             	shr    $0xc,%edx
  802575:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80257c:	ef 
  80257d:	0f b7 c0             	movzwl %ax,%eax
}
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	66 90                	xchg   %ax,%ax
  802584:	66 90                	xchg   %ax,%ax
  802586:	66 90                	xchg   %ax,%ax
  802588:	66 90                	xchg   %ax,%ax
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <__udivdi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	83 ec 1c             	sub    $0x1c,%esp
  802597:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80259b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80259f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025a7:	85 f6                	test   %esi,%esi
  8025a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025ad:	89 ca                	mov    %ecx,%edx
  8025af:	89 f8                	mov    %edi,%eax
  8025b1:	75 3d                	jne    8025f0 <__udivdi3+0x60>
  8025b3:	39 cf                	cmp    %ecx,%edi
  8025b5:	0f 87 c5 00 00 00    	ja     802680 <__udivdi3+0xf0>
  8025bb:	85 ff                	test   %edi,%edi
  8025bd:	89 fd                	mov    %edi,%ebp
  8025bf:	75 0b                	jne    8025cc <__udivdi3+0x3c>
  8025c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c6:	31 d2                	xor    %edx,%edx
  8025c8:	f7 f7                	div    %edi
  8025ca:	89 c5                	mov    %eax,%ebp
  8025cc:	89 c8                	mov    %ecx,%eax
  8025ce:	31 d2                	xor    %edx,%edx
  8025d0:	f7 f5                	div    %ebp
  8025d2:	89 c1                	mov    %eax,%ecx
  8025d4:	89 d8                	mov    %ebx,%eax
  8025d6:	89 cf                	mov    %ecx,%edi
  8025d8:	f7 f5                	div    %ebp
  8025da:	89 c3                	mov    %eax,%ebx
  8025dc:	89 d8                	mov    %ebx,%eax
  8025de:	89 fa                	mov    %edi,%edx
  8025e0:	83 c4 1c             	add    $0x1c,%esp
  8025e3:	5b                   	pop    %ebx
  8025e4:	5e                   	pop    %esi
  8025e5:	5f                   	pop    %edi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	90                   	nop
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	39 ce                	cmp    %ecx,%esi
  8025f2:	77 74                	ja     802668 <__udivdi3+0xd8>
  8025f4:	0f bd fe             	bsr    %esi,%edi
  8025f7:	83 f7 1f             	xor    $0x1f,%edi
  8025fa:	0f 84 98 00 00 00    	je     802698 <__udivdi3+0x108>
  802600:	bb 20 00 00 00       	mov    $0x20,%ebx
  802605:	89 f9                	mov    %edi,%ecx
  802607:	89 c5                	mov    %eax,%ebp
  802609:	29 fb                	sub    %edi,%ebx
  80260b:	d3 e6                	shl    %cl,%esi
  80260d:	89 d9                	mov    %ebx,%ecx
  80260f:	d3 ed                	shr    %cl,%ebp
  802611:	89 f9                	mov    %edi,%ecx
  802613:	d3 e0                	shl    %cl,%eax
  802615:	09 ee                	or     %ebp,%esi
  802617:	89 d9                	mov    %ebx,%ecx
  802619:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80261d:	89 d5                	mov    %edx,%ebp
  80261f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802623:	d3 ed                	shr    %cl,%ebp
  802625:	89 f9                	mov    %edi,%ecx
  802627:	d3 e2                	shl    %cl,%edx
  802629:	89 d9                	mov    %ebx,%ecx
  80262b:	d3 e8                	shr    %cl,%eax
  80262d:	09 c2                	or     %eax,%edx
  80262f:	89 d0                	mov    %edx,%eax
  802631:	89 ea                	mov    %ebp,%edx
  802633:	f7 f6                	div    %esi
  802635:	89 d5                	mov    %edx,%ebp
  802637:	89 c3                	mov    %eax,%ebx
  802639:	f7 64 24 0c          	mull   0xc(%esp)
  80263d:	39 d5                	cmp    %edx,%ebp
  80263f:	72 10                	jb     802651 <__udivdi3+0xc1>
  802641:	8b 74 24 08          	mov    0x8(%esp),%esi
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e6                	shl    %cl,%esi
  802649:	39 c6                	cmp    %eax,%esi
  80264b:	73 07                	jae    802654 <__udivdi3+0xc4>
  80264d:	39 d5                	cmp    %edx,%ebp
  80264f:	75 03                	jne    802654 <__udivdi3+0xc4>
  802651:	83 eb 01             	sub    $0x1,%ebx
  802654:	31 ff                	xor    %edi,%edi
  802656:	89 d8                	mov    %ebx,%eax
  802658:	89 fa                	mov    %edi,%edx
  80265a:	83 c4 1c             	add    $0x1c,%esp
  80265d:	5b                   	pop    %ebx
  80265e:	5e                   	pop    %esi
  80265f:	5f                   	pop    %edi
  802660:	5d                   	pop    %ebp
  802661:	c3                   	ret    
  802662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802668:	31 ff                	xor    %edi,%edi
  80266a:	31 db                	xor    %ebx,%ebx
  80266c:	89 d8                	mov    %ebx,%eax
  80266e:	89 fa                	mov    %edi,%edx
  802670:	83 c4 1c             	add    $0x1c,%esp
  802673:	5b                   	pop    %ebx
  802674:	5e                   	pop    %esi
  802675:	5f                   	pop    %edi
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    
  802678:	90                   	nop
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	89 d8                	mov    %ebx,%eax
  802682:	f7 f7                	div    %edi
  802684:	31 ff                	xor    %edi,%edi
  802686:	89 c3                	mov    %eax,%ebx
  802688:	89 d8                	mov    %ebx,%eax
  80268a:	89 fa                	mov    %edi,%edx
  80268c:	83 c4 1c             	add    $0x1c,%esp
  80268f:	5b                   	pop    %ebx
  802690:	5e                   	pop    %esi
  802691:	5f                   	pop    %edi
  802692:	5d                   	pop    %ebp
  802693:	c3                   	ret    
  802694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802698:	39 ce                	cmp    %ecx,%esi
  80269a:	72 0c                	jb     8026a8 <__udivdi3+0x118>
  80269c:	31 db                	xor    %ebx,%ebx
  80269e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026a2:	0f 87 34 ff ff ff    	ja     8025dc <__udivdi3+0x4c>
  8026a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026ad:	e9 2a ff ff ff       	jmp    8025dc <__udivdi3+0x4c>
  8026b2:	66 90                	xchg   %ax,%ax
  8026b4:	66 90                	xchg   %ax,%ax
  8026b6:	66 90                	xchg   %ax,%ax
  8026b8:	66 90                	xchg   %ax,%ax
  8026ba:	66 90                	xchg   %ax,%ax
  8026bc:	66 90                	xchg   %ax,%ax
  8026be:	66 90                	xchg   %ax,%ax

008026c0 <__umoddi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	57                   	push   %edi
  8026c2:	56                   	push   %esi
  8026c3:	53                   	push   %ebx
  8026c4:	83 ec 1c             	sub    $0x1c,%esp
  8026c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026d7:	85 d2                	test   %edx,%edx
  8026d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026e1:	89 f3                	mov    %esi,%ebx
  8026e3:	89 3c 24             	mov    %edi,(%esp)
  8026e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ea:	75 1c                	jne    802708 <__umoddi3+0x48>
  8026ec:	39 f7                	cmp    %esi,%edi
  8026ee:	76 50                	jbe    802740 <__umoddi3+0x80>
  8026f0:	89 c8                	mov    %ecx,%eax
  8026f2:	89 f2                	mov    %esi,%edx
  8026f4:	f7 f7                	div    %edi
  8026f6:	89 d0                	mov    %edx,%eax
  8026f8:	31 d2                	xor    %edx,%edx
  8026fa:	83 c4 1c             	add    $0x1c,%esp
  8026fd:	5b                   	pop    %ebx
  8026fe:	5e                   	pop    %esi
  8026ff:	5f                   	pop    %edi
  802700:	5d                   	pop    %ebp
  802701:	c3                   	ret    
  802702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802708:	39 f2                	cmp    %esi,%edx
  80270a:	89 d0                	mov    %edx,%eax
  80270c:	77 52                	ja     802760 <__umoddi3+0xa0>
  80270e:	0f bd ea             	bsr    %edx,%ebp
  802711:	83 f5 1f             	xor    $0x1f,%ebp
  802714:	75 5a                	jne    802770 <__umoddi3+0xb0>
  802716:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80271a:	0f 82 e0 00 00 00    	jb     802800 <__umoddi3+0x140>
  802720:	39 0c 24             	cmp    %ecx,(%esp)
  802723:	0f 86 d7 00 00 00    	jbe    802800 <__umoddi3+0x140>
  802729:	8b 44 24 08          	mov    0x8(%esp),%eax
  80272d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802731:	83 c4 1c             	add    $0x1c,%esp
  802734:	5b                   	pop    %ebx
  802735:	5e                   	pop    %esi
  802736:	5f                   	pop    %edi
  802737:	5d                   	pop    %ebp
  802738:	c3                   	ret    
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	85 ff                	test   %edi,%edi
  802742:	89 fd                	mov    %edi,%ebp
  802744:	75 0b                	jne    802751 <__umoddi3+0x91>
  802746:	b8 01 00 00 00       	mov    $0x1,%eax
  80274b:	31 d2                	xor    %edx,%edx
  80274d:	f7 f7                	div    %edi
  80274f:	89 c5                	mov    %eax,%ebp
  802751:	89 f0                	mov    %esi,%eax
  802753:	31 d2                	xor    %edx,%edx
  802755:	f7 f5                	div    %ebp
  802757:	89 c8                	mov    %ecx,%eax
  802759:	f7 f5                	div    %ebp
  80275b:	89 d0                	mov    %edx,%eax
  80275d:	eb 99                	jmp    8026f8 <__umoddi3+0x38>
  80275f:	90                   	nop
  802760:	89 c8                	mov    %ecx,%eax
  802762:	89 f2                	mov    %esi,%edx
  802764:	83 c4 1c             	add    $0x1c,%esp
  802767:	5b                   	pop    %ebx
  802768:	5e                   	pop    %esi
  802769:	5f                   	pop    %edi
  80276a:	5d                   	pop    %ebp
  80276b:	c3                   	ret    
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	8b 34 24             	mov    (%esp),%esi
  802773:	bf 20 00 00 00       	mov    $0x20,%edi
  802778:	89 e9                	mov    %ebp,%ecx
  80277a:	29 ef                	sub    %ebp,%edi
  80277c:	d3 e0                	shl    %cl,%eax
  80277e:	89 f9                	mov    %edi,%ecx
  802780:	89 f2                	mov    %esi,%edx
  802782:	d3 ea                	shr    %cl,%edx
  802784:	89 e9                	mov    %ebp,%ecx
  802786:	09 c2                	or     %eax,%edx
  802788:	89 d8                	mov    %ebx,%eax
  80278a:	89 14 24             	mov    %edx,(%esp)
  80278d:	89 f2                	mov    %esi,%edx
  80278f:	d3 e2                	shl    %cl,%edx
  802791:	89 f9                	mov    %edi,%ecx
  802793:	89 54 24 04          	mov    %edx,0x4(%esp)
  802797:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80279b:	d3 e8                	shr    %cl,%eax
  80279d:	89 e9                	mov    %ebp,%ecx
  80279f:	89 c6                	mov    %eax,%esi
  8027a1:	d3 e3                	shl    %cl,%ebx
  8027a3:	89 f9                	mov    %edi,%ecx
  8027a5:	89 d0                	mov    %edx,%eax
  8027a7:	d3 e8                	shr    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	09 d8                	or     %ebx,%eax
  8027ad:	89 d3                	mov    %edx,%ebx
  8027af:	89 f2                	mov    %esi,%edx
  8027b1:	f7 34 24             	divl   (%esp)
  8027b4:	89 d6                	mov    %edx,%esi
  8027b6:	d3 e3                	shl    %cl,%ebx
  8027b8:	f7 64 24 04          	mull   0x4(%esp)
  8027bc:	39 d6                	cmp    %edx,%esi
  8027be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027c2:	89 d1                	mov    %edx,%ecx
  8027c4:	89 c3                	mov    %eax,%ebx
  8027c6:	72 08                	jb     8027d0 <__umoddi3+0x110>
  8027c8:	75 11                	jne    8027db <__umoddi3+0x11b>
  8027ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ce:	73 0b                	jae    8027db <__umoddi3+0x11b>
  8027d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027d4:	1b 14 24             	sbb    (%esp),%edx
  8027d7:	89 d1                	mov    %edx,%ecx
  8027d9:	89 c3                	mov    %eax,%ebx
  8027db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027df:	29 da                	sub    %ebx,%edx
  8027e1:	19 ce                	sbb    %ecx,%esi
  8027e3:	89 f9                	mov    %edi,%ecx
  8027e5:	89 f0                	mov    %esi,%eax
  8027e7:	d3 e0                	shl    %cl,%eax
  8027e9:	89 e9                	mov    %ebp,%ecx
  8027eb:	d3 ea                	shr    %cl,%edx
  8027ed:	89 e9                	mov    %ebp,%ecx
  8027ef:	d3 ee                	shr    %cl,%esi
  8027f1:	09 d0                	or     %edx,%eax
  8027f3:	89 f2                	mov    %esi,%edx
  8027f5:	83 c4 1c             	add    $0x1c,%esp
  8027f8:	5b                   	pop    %ebx
  8027f9:	5e                   	pop    %esi
  8027fa:	5f                   	pop    %edi
  8027fb:	5d                   	pop    %ebp
  8027fc:	c3                   	ret    
  8027fd:	8d 76 00             	lea    0x0(%esi),%esi
  802800:	29 f9                	sub    %edi,%ecx
  802802:	19 d6                	sbb    %edx,%esi
  802804:	89 74 24 04          	mov    %esi,0x4(%esp)
  802808:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80280c:	e9 18 ff ff ff       	jmp    802729 <__umoddi3+0x69>
