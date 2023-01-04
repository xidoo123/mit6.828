
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
  80003b:	c7 05 04 30 80 00 20 	movl   $0x802320,0x803004
  800042:	23 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 44 1b 00 00       	call   801b92 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 2c 23 80 00       	push   $0x80232c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 35 23 80 00       	push   $0x802335
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 cf 0f 00 00       	call   80103d <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 45 23 80 00       	push   $0x802345
  80007a:	6a 11                	push   $0x11
  80007c:	68 35 23 80 00       	push   $0x802335
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 4e 23 80 00       	push   $0x80234e
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 ac 12 00 00       	call   80135e <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 6b 23 80 00       	push   $0x80236b
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 4f 14 00 00       	call   80152b <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 88 23 80 00       	push   $0x802388
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 35 23 80 00       	push   $0x802335
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
  800118:	68 91 23 80 00       	push   $0x802391
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 ad 23 80 00       	push   $0x8023ad
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 4e 23 80 00       	push   $0x80234e
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 f4 11 00 00       	call   80135e <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 c0 23 80 00       	push   $0x8023c0
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a6 07 00 00       	call   800937 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 d1 13 00 00       	call   801574 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 84 07 00 00       	call   800937 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 dd 23 80 00       	push   $0x8023dd
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 35 23 80 00       	push   $0x802335
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 87 11 00 00       	call   80135e <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 35 1b 00 00       	call   801d18 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 e7 	movl   $0x8023e7,0x803004
  8001ea:	23 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 9a 19 00 00       	call   801b92 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 2c 23 80 00       	push   $0x80232c
  800207:	6a 2c                	push   $0x2c
  800209:	68 35 23 80 00       	push   $0x802335
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 25 0e 00 00       	call   80103d <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 45 23 80 00       	push   $0x802345
  800224:	6a 2f                	push   $0x2f
  800226:	68 35 23 80 00       	push   $0x802335
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 1f 11 00 00       	call   80135e <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 f4 23 80 00       	push   $0x8023f4
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 f6 23 80 00       	push   $0x8023f6
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 13 13 00 00       	call   801574 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 f8 23 80 00       	push   $0x8023f8
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 d5 10 00 00       	call   80135e <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 ca 10 00 00       	call   80135e <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 7c 1a 00 00       	call   801d18 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 15 24 80 00 	movl   $0x802415,(%esp)
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
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8002fe:	e8 86 10 00 00       	call   801389 <close_all>
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
  800330:	68 78 24 80 00       	push   $0x802478
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 69 23 80 00 	movl   $0x802369,(%esp)
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
  80044e:	e8 3d 1c 00 00       	call   802090 <__udivdi3>
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
  800491:	e8 2a 1d 00 00       	call   8021c0 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 9b 24 80 00 	movsbl 0x80249b(%eax),%eax
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
  800595:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
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
  800659:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 b3 24 80 00       	push   $0x8024b3
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
  80067d:	68 2d 29 80 00       	push   $0x80292d
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
  8006a1:	b8 ac 24 80 00       	mov    $0x8024ac,%eax
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
  800d1c:	68 9f 27 80 00       	push   $0x80279f
  800d21:	6a 23                	push   $0x23
  800d23:	68 bc 27 80 00       	push   $0x8027bc
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
  800d9d:	68 9f 27 80 00       	push   $0x80279f
  800da2:	6a 23                	push   $0x23
  800da4:	68 bc 27 80 00       	push   $0x8027bc
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
  800ddf:	68 9f 27 80 00       	push   $0x80279f
  800de4:	6a 23                	push   $0x23
  800de6:	68 bc 27 80 00       	push   $0x8027bc
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
  800e21:	68 9f 27 80 00       	push   $0x80279f
  800e26:	6a 23                	push   $0x23
  800e28:	68 bc 27 80 00       	push   $0x8027bc
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
  800e63:	68 9f 27 80 00       	push   $0x80279f
  800e68:	6a 23                	push   $0x23
  800e6a:	68 bc 27 80 00       	push   $0x8027bc
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
  800ea5:	68 9f 27 80 00       	push   $0x80279f
  800eaa:	6a 23                	push   $0x23
  800eac:	68 bc 27 80 00       	push   $0x8027bc
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
  800ee7:	68 9f 27 80 00       	push   $0x80279f
  800eec:	6a 23                	push   $0x23
  800eee:	68 bc 27 80 00       	push   $0x8027bc
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
  800f4b:	68 9f 27 80 00       	push   $0x80279f
  800f50:	6a 23                	push   $0x23
  800f52:	68 bc 27 80 00       	push   $0x8027bc
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

00800f64 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f6c:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800f6e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f72:	75 25                	jne    800f99 <pgfault+0x35>
  800f74:	89 d8                	mov    %ebx,%eax
  800f76:	c1 e8 0c             	shr    $0xc,%eax
  800f79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f80:	f6 c4 08             	test   $0x8,%ah
  800f83:	75 14                	jne    800f99 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	68 cc 27 80 00       	push   $0x8027cc
  800f8d:	6a 1e                	push   $0x1e
  800f8f:	68 60 28 80 00       	push   $0x802860
  800f94:	e8 79 f3 ff ff       	call   800312 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f99:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f9f:	e8 91 fd ff ff       	call   800d35 <sys_getenvid>
  800fa4:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	6a 07                	push   $0x7
  800fab:	68 00 f0 7f 00       	push   $0x7ff000
  800fb0:	50                   	push   %eax
  800fb1:	e8 bd fd ff ff       	call   800d73 <sys_page_alloc>
	if (r < 0)
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	79 12                	jns    800fcf <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800fbd:	50                   	push   %eax
  800fbe:	68 f8 27 80 00       	push   $0x8027f8
  800fc3:	6a 31                	push   $0x31
  800fc5:	68 60 28 80 00       	push   $0x802860
  800fca:	e8 43 f3 ff ff       	call   800312 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	68 00 10 00 00       	push   $0x1000
  800fd7:	53                   	push   %ebx
  800fd8:	68 00 f0 7f 00       	push   $0x7ff000
  800fdd:	e8 88 fb ff ff       	call   800b6a <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800fe2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fe9:	53                   	push   %ebx
  800fea:	56                   	push   %esi
  800feb:	68 00 f0 7f 00       	push   $0x7ff000
  800ff0:	56                   	push   %esi
  800ff1:	e8 c0 fd ff ff       	call   800db6 <sys_page_map>
	if (r < 0)
  800ff6:	83 c4 20             	add    $0x20,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	79 12                	jns    80100f <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800ffd:	50                   	push   %eax
  800ffe:	68 1c 28 80 00       	push   $0x80281c
  801003:	6a 39                	push   $0x39
  801005:	68 60 28 80 00       	push   $0x802860
  80100a:	e8 03 f3 ff ff       	call   800312 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  80100f:	83 ec 08             	sub    $0x8,%esp
  801012:	68 00 f0 7f 00       	push   $0x7ff000
  801017:	56                   	push   %esi
  801018:	e8 db fd ff ff       	call   800df8 <sys_page_unmap>
	if (r < 0)
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	85 c0                	test   %eax,%eax
  801022:	79 12                	jns    801036 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  801024:	50                   	push   %eax
  801025:	68 40 28 80 00       	push   $0x802840
  80102a:	6a 3e                	push   $0x3e
  80102c:	68 60 28 80 00       	push   $0x802860
  801031:	e8 dc f2 ff ff       	call   800312 <_panic>
}
  801036:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801039:	5b                   	pop    %ebx
  80103a:	5e                   	pop    %esi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	57                   	push   %edi
  801041:	56                   	push   %esi
  801042:	53                   	push   %ebx
  801043:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  801046:	68 64 0f 80 00       	push   $0x800f64
  80104b:	e8 9a 0e 00 00       	call   801eea <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801050:	b8 07 00 00 00       	mov    $0x7,%eax
  801055:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	0f 88 3a 01 00 00    	js     80119c <fork+0x15f>
  801062:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801067:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80106c:	85 c0                	test   %eax,%eax
  80106e:	75 21                	jne    801091 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801070:	e8 c0 fc ff ff       	call   800d35 <sys_getenvid>
  801075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80107a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80107d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801082:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  801087:	b8 00 00 00 00       	mov    $0x0,%eax
  80108c:	e9 0b 01 00 00       	jmp    80119c <fork+0x15f>
  801091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801094:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801096:	89 d8                	mov    %ebx,%eax
  801098:	c1 e8 16             	shr    $0x16,%eax
  80109b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a2:	a8 01                	test   $0x1,%al
  8010a4:	0f 84 99 00 00 00    	je     801143 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  8010aa:	89 d8                	mov    %ebx,%eax
  8010ac:	c1 e8 0c             	shr    $0xc,%eax
  8010af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b6:	f6 c2 01             	test   $0x1,%dl
  8010b9:	0f 84 84 00 00 00    	je     801143 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  8010bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c6:	a9 02 08 00 00       	test   $0x802,%eax
  8010cb:	74 76                	je     801143 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010cd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d4:	a8 02                	test   $0x2,%al
  8010d6:	75 0c                	jne    8010e4 <fork+0xa7>
  8010d8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010df:	f6 c4 08             	test   $0x8,%ah
  8010e2:	74 3f                	je     801123 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	68 05 08 00 00       	push   $0x805
  8010ec:	53                   	push   %ebx
  8010ed:	57                   	push   %edi
  8010ee:	53                   	push   %ebx
  8010ef:	6a 00                	push   $0x0
  8010f1:	e8 c0 fc ff ff       	call   800db6 <sys_page_map>
		if (r < 0)
  8010f6:	83 c4 20             	add    $0x20,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	0f 88 9b 00 00 00    	js     80119c <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801101:	83 ec 0c             	sub    $0xc,%esp
  801104:	68 05 08 00 00       	push   $0x805
  801109:	53                   	push   %ebx
  80110a:	6a 00                	push   $0x0
  80110c:	53                   	push   %ebx
  80110d:	6a 00                	push   $0x0
  80110f:	e8 a2 fc ff ff       	call   800db6 <sys_page_map>
  801114:	83 c4 20             	add    $0x20,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111e:	0f 4f c1             	cmovg  %ecx,%eax
  801121:	eb 1c                	jmp    80113f <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	6a 05                	push   $0x5
  801128:	53                   	push   %ebx
  801129:	57                   	push   %edi
  80112a:	53                   	push   %ebx
  80112b:	6a 00                	push   $0x0
  80112d:	e8 84 fc ff ff       	call   800db6 <sys_page_map>
  801132:	83 c4 20             	add    $0x20,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	b9 00 00 00 00       	mov    $0x0,%ecx
  80113c:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 59                	js     80119c <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801143:	83 c6 01             	add    $0x1,%esi
  801146:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80114c:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801152:	0f 85 3e ff ff ff    	jne    801096 <fork+0x59>
  801158:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	6a 07                	push   $0x7
  801160:	68 00 f0 bf ee       	push   $0xeebff000
  801165:	57                   	push   %edi
  801166:	e8 08 fc ff ff       	call   800d73 <sys_page_alloc>
	if (r < 0)
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 2a                	js     80119c <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801172:	83 ec 08             	sub    $0x8,%esp
  801175:	68 31 1f 80 00       	push   $0x801f31
  80117a:	57                   	push   %edi
  80117b:	e8 3e fd ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
	if (r < 0)
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	78 15                	js     80119c <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	6a 02                	push   $0x2
  80118c:	57                   	push   %edi
  80118d:	e8 a8 fc ff ff       	call   800e3a <sys_env_set_status>
	if (r < 0)
  801192:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801195:	85 c0                	test   %eax,%eax
  801197:	0f 49 c7             	cmovns %edi,%eax
  80119a:	eb 00                	jmp    80119c <fork+0x15f>
	// panic("fork not implemented");
}
  80119c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5e                   	pop    %esi
  8011a1:	5f                   	pop    %edi
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011aa:	68 6b 28 80 00       	push   $0x80286b
  8011af:	68 c3 00 00 00       	push   $0xc3
  8011b4:	68 60 28 80 00       	push   $0x802860
  8011b9:	e8 54 f1 ff ff       	call   800312 <_panic>

008011be <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c4:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c9:	c1 e8 0c             	shr    $0xc,%eax
}
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d4:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011de:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011eb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f0:	89 c2                	mov    %eax,%edx
  8011f2:	c1 ea 16             	shr    $0x16,%edx
  8011f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fc:	f6 c2 01             	test   $0x1,%dl
  8011ff:	74 11                	je     801212 <fd_alloc+0x2d>
  801201:	89 c2                	mov    %eax,%edx
  801203:	c1 ea 0c             	shr    $0xc,%edx
  801206:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120d:	f6 c2 01             	test   $0x1,%dl
  801210:	75 09                	jne    80121b <fd_alloc+0x36>
			*fd_store = fd;
  801212:	89 01                	mov    %eax,(%ecx)
			return 0;
  801214:	b8 00 00 00 00       	mov    $0x0,%eax
  801219:	eb 17                	jmp    801232 <fd_alloc+0x4d>
  80121b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801220:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801225:	75 c9                	jne    8011f0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801227:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80122d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80123a:	83 f8 1f             	cmp    $0x1f,%eax
  80123d:	77 36                	ja     801275 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123f:	c1 e0 0c             	shl    $0xc,%eax
  801242:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801247:	89 c2                	mov    %eax,%edx
  801249:	c1 ea 16             	shr    $0x16,%edx
  80124c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801253:	f6 c2 01             	test   $0x1,%dl
  801256:	74 24                	je     80127c <fd_lookup+0x48>
  801258:	89 c2                	mov    %eax,%edx
  80125a:	c1 ea 0c             	shr    $0xc,%edx
  80125d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801264:	f6 c2 01             	test   $0x1,%dl
  801267:	74 1a                	je     801283 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801269:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126c:	89 02                	mov    %eax,(%edx)
	return 0;
  80126e:	b8 00 00 00 00       	mov    $0x0,%eax
  801273:	eb 13                	jmp    801288 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801275:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127a:	eb 0c                	jmp    801288 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801281:	eb 05                	jmp    801288 <fd_lookup+0x54>
  801283:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801293:	ba 04 29 80 00       	mov    $0x802904,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801298:	eb 13                	jmp    8012ad <dev_lookup+0x23>
  80129a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80129d:	39 08                	cmp    %ecx,(%eax)
  80129f:	75 0c                	jne    8012ad <dev_lookup+0x23>
			*dev = devtab[i];
  8012a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ab:	eb 2e                	jmp    8012db <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ad:	8b 02                	mov    (%edx),%eax
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	75 e7                	jne    80129a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b8:	8b 40 48             	mov    0x48(%eax),%eax
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	51                   	push   %ecx
  8012bf:	50                   	push   %eax
  8012c0:	68 84 28 80 00       	push   $0x802884
  8012c5:	e8 21 f1 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  8012ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    

008012dd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	56                   	push   %esi
  8012e1:	53                   	push   %ebx
  8012e2:	83 ec 10             	sub    $0x10,%esp
  8012e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012f5:	c1 e8 0c             	shr    $0xc,%eax
  8012f8:	50                   	push   %eax
  8012f9:	e8 36 ff ff ff       	call   801234 <fd_lookup>
  8012fe:	83 c4 08             	add    $0x8,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	78 05                	js     80130a <fd_close+0x2d>
	    || fd != fd2)
  801305:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801308:	74 0c                	je     801316 <fd_close+0x39>
		return (must_exist ? r : 0);
  80130a:	84 db                	test   %bl,%bl
  80130c:	ba 00 00 00 00       	mov    $0x0,%edx
  801311:	0f 44 c2             	cmove  %edx,%eax
  801314:	eb 41                	jmp    801357 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801316:	83 ec 08             	sub    $0x8,%esp
  801319:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	ff 36                	pushl  (%esi)
  80131f:	e8 66 ff ff ff       	call   80128a <dev_lookup>
  801324:	89 c3                	mov    %eax,%ebx
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 1a                	js     801347 <fd_close+0x6a>
		if (dev->dev_close)
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801333:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801338:	85 c0                	test   %eax,%eax
  80133a:	74 0b                	je     801347 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	56                   	push   %esi
  801340:	ff d0                	call   *%eax
  801342:	89 c3                	mov    %eax,%ebx
  801344:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	56                   	push   %esi
  80134b:	6a 00                	push   $0x0
  80134d:	e8 a6 fa ff ff       	call   800df8 <sys_page_unmap>
	return r;
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	89 d8                	mov    %ebx,%eax
}
  801357:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135a:	5b                   	pop    %ebx
  80135b:	5e                   	pop    %esi
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 75 08             	pushl  0x8(%ebp)
  80136b:	e8 c4 fe ff ff       	call   801234 <fd_lookup>
  801370:	83 c4 08             	add    $0x8,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 10                	js     801387 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	6a 01                	push   $0x1
  80137c:	ff 75 f4             	pushl  -0xc(%ebp)
  80137f:	e8 59 ff ff ff       	call   8012dd <fd_close>
  801384:	83 c4 10             	add    $0x10,%esp
}
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <close_all>:

void
close_all(void)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	53                   	push   %ebx
  80138d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801390:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	53                   	push   %ebx
  801399:	e8 c0 ff ff ff       	call   80135e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80139e:	83 c3 01             	add    $0x1,%ebx
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	83 fb 20             	cmp    $0x20,%ebx
  8013a7:	75 ec                	jne    801395 <close_all+0xc>
		close(i);
}
  8013a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	57                   	push   %edi
  8013b2:	56                   	push   %esi
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 2c             	sub    $0x2c,%esp
  8013b7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	ff 75 08             	pushl  0x8(%ebp)
  8013c1:	e8 6e fe ff ff       	call   801234 <fd_lookup>
  8013c6:	83 c4 08             	add    $0x8,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	0f 88 c1 00 00 00    	js     801492 <dup+0xe4>
		return r;
	close(newfdnum);
  8013d1:	83 ec 0c             	sub    $0xc,%esp
  8013d4:	56                   	push   %esi
  8013d5:	e8 84 ff ff ff       	call   80135e <close>

	newfd = INDEX2FD(newfdnum);
  8013da:	89 f3                	mov    %esi,%ebx
  8013dc:	c1 e3 0c             	shl    $0xc,%ebx
  8013df:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013e5:	83 c4 04             	add    $0x4,%esp
  8013e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013eb:	e8 de fd ff ff       	call   8011ce <fd2data>
  8013f0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013f2:	89 1c 24             	mov    %ebx,(%esp)
  8013f5:	e8 d4 fd ff ff       	call   8011ce <fd2data>
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801400:	89 f8                	mov    %edi,%eax
  801402:	c1 e8 16             	shr    $0x16,%eax
  801405:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80140c:	a8 01                	test   $0x1,%al
  80140e:	74 37                	je     801447 <dup+0x99>
  801410:	89 f8                	mov    %edi,%eax
  801412:	c1 e8 0c             	shr    $0xc,%eax
  801415:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80141c:	f6 c2 01             	test   $0x1,%dl
  80141f:	74 26                	je     801447 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801421:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	25 07 0e 00 00       	and    $0xe07,%eax
  801430:	50                   	push   %eax
  801431:	ff 75 d4             	pushl  -0x2c(%ebp)
  801434:	6a 00                	push   $0x0
  801436:	57                   	push   %edi
  801437:	6a 00                	push   $0x0
  801439:	e8 78 f9 ff ff       	call   800db6 <sys_page_map>
  80143e:	89 c7                	mov    %eax,%edi
  801440:	83 c4 20             	add    $0x20,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 2e                	js     801475 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801447:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80144a:	89 d0                	mov    %edx,%eax
  80144c:	c1 e8 0c             	shr    $0xc,%eax
  80144f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	25 07 0e 00 00       	and    $0xe07,%eax
  80145e:	50                   	push   %eax
  80145f:	53                   	push   %ebx
  801460:	6a 00                	push   $0x0
  801462:	52                   	push   %edx
  801463:	6a 00                	push   $0x0
  801465:	e8 4c f9 ff ff       	call   800db6 <sys_page_map>
  80146a:	89 c7                	mov    %eax,%edi
  80146c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80146f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801471:	85 ff                	test   %edi,%edi
  801473:	79 1d                	jns    801492 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	53                   	push   %ebx
  801479:	6a 00                	push   $0x0
  80147b:	e8 78 f9 ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801480:	83 c4 08             	add    $0x8,%esp
  801483:	ff 75 d4             	pushl  -0x2c(%ebp)
  801486:	6a 00                	push   $0x0
  801488:	e8 6b f9 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	89 f8                	mov    %edi,%eax
}
  801492:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801495:	5b                   	pop    %ebx
  801496:	5e                   	pop    %esi
  801497:	5f                   	pop    %edi
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    

0080149a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	53                   	push   %ebx
  80149e:	83 ec 14             	sub    $0x14,%esp
  8014a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	53                   	push   %ebx
  8014a9:	e8 86 fd ff ff       	call   801234 <fd_lookup>
  8014ae:	83 c4 08             	add    $0x8,%esp
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 6d                	js     801524 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	ff 30                	pushl  (%eax)
  8014c3:	e8 c2 fd ff ff       	call   80128a <dev_lookup>
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 4c                	js     80151b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d2:	8b 42 08             	mov    0x8(%edx),%eax
  8014d5:	83 e0 03             	and    $0x3,%eax
  8014d8:	83 f8 01             	cmp    $0x1,%eax
  8014db:	75 21                	jne    8014fe <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e2:	8b 40 48             	mov    0x48(%eax),%eax
  8014e5:	83 ec 04             	sub    $0x4,%esp
  8014e8:	53                   	push   %ebx
  8014e9:	50                   	push   %eax
  8014ea:	68 c8 28 80 00       	push   $0x8028c8
  8014ef:	e8 f7 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fc:	eb 26                	jmp    801524 <read+0x8a>
	}
	if (!dev->dev_read)
  8014fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801501:	8b 40 08             	mov    0x8(%eax),%eax
  801504:	85 c0                	test   %eax,%eax
  801506:	74 17                	je     80151f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801508:	83 ec 04             	sub    $0x4,%esp
  80150b:	ff 75 10             	pushl  0x10(%ebp)
  80150e:	ff 75 0c             	pushl  0xc(%ebp)
  801511:	52                   	push   %edx
  801512:	ff d0                	call   *%eax
  801514:	89 c2                	mov    %eax,%edx
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	eb 09                	jmp    801524 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	eb 05                	jmp    801524 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80151f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801524:	89 d0                	mov    %edx,%eax
  801526:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	57                   	push   %edi
  80152f:	56                   	push   %esi
  801530:	53                   	push   %ebx
  801531:	83 ec 0c             	sub    $0xc,%esp
  801534:	8b 7d 08             	mov    0x8(%ebp),%edi
  801537:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153f:	eb 21                	jmp    801562 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801541:	83 ec 04             	sub    $0x4,%esp
  801544:	89 f0                	mov    %esi,%eax
  801546:	29 d8                	sub    %ebx,%eax
  801548:	50                   	push   %eax
  801549:	89 d8                	mov    %ebx,%eax
  80154b:	03 45 0c             	add    0xc(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	57                   	push   %edi
  801550:	e8 45 ff ff ff       	call   80149a <read>
		if (m < 0)
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 10                	js     80156c <readn+0x41>
			return m;
		if (m == 0)
  80155c:	85 c0                	test   %eax,%eax
  80155e:	74 0a                	je     80156a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801560:	01 c3                	add    %eax,%ebx
  801562:	39 f3                	cmp    %esi,%ebx
  801564:	72 db                	jb     801541 <readn+0x16>
  801566:	89 d8                	mov    %ebx,%eax
  801568:	eb 02                	jmp    80156c <readn+0x41>
  80156a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80156c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156f:	5b                   	pop    %ebx
  801570:	5e                   	pop    %esi
  801571:	5f                   	pop    %edi
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    

00801574 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	53                   	push   %ebx
  801578:	83 ec 14             	sub    $0x14,%esp
  80157b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	53                   	push   %ebx
  801583:	e8 ac fc ff ff       	call   801234 <fd_lookup>
  801588:	83 c4 08             	add    $0x8,%esp
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 68                	js     8015f9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	ff 30                	pushl  (%eax)
  80159d:	e8 e8 fc ff ff       	call   80128a <dev_lookup>
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 47                	js     8015f0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b0:	75 21                	jne    8015d3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b7:	8b 40 48             	mov    0x48(%eax),%eax
  8015ba:	83 ec 04             	sub    $0x4,%esp
  8015bd:	53                   	push   %ebx
  8015be:	50                   	push   %eax
  8015bf:	68 e4 28 80 00       	push   $0x8028e4
  8015c4:	e8 22 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d1:	eb 26                	jmp    8015f9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d9:	85 d2                	test   %edx,%edx
  8015db:	74 17                	je     8015f4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015dd:	83 ec 04             	sub    $0x4,%esp
  8015e0:	ff 75 10             	pushl  0x10(%ebp)
  8015e3:	ff 75 0c             	pushl  0xc(%ebp)
  8015e6:	50                   	push   %eax
  8015e7:	ff d2                	call   *%edx
  8015e9:	89 c2                	mov    %eax,%edx
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	eb 09                	jmp    8015f9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f0:	89 c2                	mov    %eax,%edx
  8015f2:	eb 05                	jmp    8015f9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015f9:	89 d0                	mov    %edx,%eax
  8015fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <seek>:

int
seek(int fdnum, off_t offset)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801606:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	ff 75 08             	pushl  0x8(%ebp)
  80160d:	e8 22 fc ff ff       	call   801234 <fd_lookup>
  801612:	83 c4 08             	add    $0x8,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 0e                	js     801627 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801619:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80161c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801622:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801627:	c9                   	leave  
  801628:	c3                   	ret    

00801629 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	53                   	push   %ebx
  80162d:	83 ec 14             	sub    $0x14,%esp
  801630:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801633:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801636:	50                   	push   %eax
  801637:	53                   	push   %ebx
  801638:	e8 f7 fb ff ff       	call   801234 <fd_lookup>
  80163d:	83 c4 08             	add    $0x8,%esp
  801640:	89 c2                	mov    %eax,%edx
  801642:	85 c0                	test   %eax,%eax
  801644:	78 65                	js     8016ab <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801646:	83 ec 08             	sub    $0x8,%esp
  801649:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164c:	50                   	push   %eax
  80164d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801650:	ff 30                	pushl  (%eax)
  801652:	e8 33 fc ff ff       	call   80128a <dev_lookup>
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 44                	js     8016a2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801661:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801665:	75 21                	jne    801688 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801667:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80166c:	8b 40 48             	mov    0x48(%eax),%eax
  80166f:	83 ec 04             	sub    $0x4,%esp
  801672:	53                   	push   %ebx
  801673:	50                   	push   %eax
  801674:	68 a4 28 80 00       	push   $0x8028a4
  801679:	e8 6d ed ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801686:	eb 23                	jmp    8016ab <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801688:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168b:	8b 52 18             	mov    0x18(%edx),%edx
  80168e:	85 d2                	test   %edx,%edx
  801690:	74 14                	je     8016a6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	ff 75 0c             	pushl  0xc(%ebp)
  801698:	50                   	push   %eax
  801699:	ff d2                	call   *%edx
  80169b:	89 c2                	mov    %eax,%edx
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	eb 09                	jmp    8016ab <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	eb 05                	jmp    8016ab <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ab:	89 d0                	mov    %edx,%eax
  8016ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 14             	sub    $0x14,%esp
  8016b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bf:	50                   	push   %eax
  8016c0:	ff 75 08             	pushl  0x8(%ebp)
  8016c3:	e8 6c fb ff ff       	call   801234 <fd_lookup>
  8016c8:	83 c4 08             	add    $0x8,%esp
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 58                	js     801729 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d7:	50                   	push   %eax
  8016d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016db:	ff 30                	pushl  (%eax)
  8016dd:	e8 a8 fb ff ff       	call   80128a <dev_lookup>
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 37                	js     801720 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ec:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f0:	74 32                	je     801724 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016fc:	00 00 00 
	stat->st_isdir = 0;
  8016ff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801706:	00 00 00 
	stat->st_dev = dev;
  801709:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80170f:	83 ec 08             	sub    $0x8,%esp
  801712:	53                   	push   %ebx
  801713:	ff 75 f0             	pushl  -0x10(%ebp)
  801716:	ff 50 14             	call   *0x14(%eax)
  801719:	89 c2                	mov    %eax,%edx
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	eb 09                	jmp    801729 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801720:	89 c2                	mov    %eax,%edx
  801722:	eb 05                	jmp    801729 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801724:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801729:	89 d0                	mov    %edx,%eax
  80172b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	6a 00                	push   $0x0
  80173a:	ff 75 08             	pushl  0x8(%ebp)
  80173d:	e8 d6 01 00 00       	call   801918 <open>
  801742:	89 c3                	mov    %eax,%ebx
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	78 1b                	js     801766 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	ff 75 0c             	pushl  0xc(%ebp)
  801751:	50                   	push   %eax
  801752:	e8 5b ff ff ff       	call   8016b2 <fstat>
  801757:	89 c6                	mov    %eax,%esi
	close(fd);
  801759:	89 1c 24             	mov    %ebx,(%esp)
  80175c:	e8 fd fb ff ff       	call   80135e <close>
	return r;
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	89 f0                	mov    %esi,%eax
}
  801766:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801769:	5b                   	pop    %ebx
  80176a:	5e                   	pop    %esi
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    

0080176d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	56                   	push   %esi
  801771:	53                   	push   %ebx
  801772:	89 c6                	mov    %eax,%esi
  801774:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801776:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80177d:	75 12                	jne    801791 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177f:	83 ec 0c             	sub    $0xc,%esp
  801782:	6a 01                	push   $0x1
  801784:	e8 87 08 00 00       	call   802010 <ipc_find_env>
  801789:	a3 00 40 80 00       	mov    %eax,0x804000
  80178e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801791:	6a 07                	push   $0x7
  801793:	68 00 50 80 00       	push   $0x805000
  801798:	56                   	push   %esi
  801799:	ff 35 00 40 80 00    	pushl  0x804000
  80179f:	e8 18 08 00 00       	call   801fbc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a4:	83 c4 0c             	add    $0xc,%esp
  8017a7:	6a 00                	push   $0x0
  8017a9:	53                   	push   %ebx
  8017aa:	6a 00                	push   $0x0
  8017ac:	e8 a4 07 00 00       	call   801f55 <ipc_recv>
}
  8017b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b4:	5b                   	pop    %ebx
  8017b5:	5e                   	pop    %esi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d6:	b8 02 00 00 00       	mov    $0x2,%eax
  8017db:	e8 8d ff ff ff       	call   80176d <fsipc>
}
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ee:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f8:	b8 06 00 00 00       	mov    $0x6,%eax
  8017fd:	e8 6b ff ff ff       	call   80176d <fsipc>
}
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	53                   	push   %ebx
  801808:	83 ec 04             	sub    $0x4,%esp
  80180b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	8b 40 0c             	mov    0xc(%eax),%eax
  801814:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801819:	ba 00 00 00 00       	mov    $0x0,%edx
  80181e:	b8 05 00 00 00       	mov    $0x5,%eax
  801823:	e8 45 ff ff ff       	call   80176d <fsipc>
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 2c                	js     801858 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	68 00 50 80 00       	push   $0x805000
  801834:	53                   	push   %ebx
  801835:	e8 36 f1 ff ff       	call   800970 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80183a:	a1 80 50 80 00       	mov    0x805080,%eax
  80183f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801845:	a1 84 50 80 00       	mov    0x805084,%eax
  80184a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801858:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	83 ec 0c             	sub    $0xc,%esp
  801863:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801866:	8b 55 08             	mov    0x8(%ebp),%edx
  801869:	8b 52 0c             	mov    0xc(%edx),%edx
  80186c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801872:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801877:	50                   	push   %eax
  801878:	ff 75 0c             	pushl  0xc(%ebp)
  80187b:	68 08 50 80 00       	push   $0x805008
  801880:	e8 7d f2 ff ff       	call   800b02 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801885:	ba 00 00 00 00       	mov    $0x0,%edx
  80188a:	b8 04 00 00 00       	mov    $0x4,%eax
  80188f:	e8 d9 fe ff ff       	call   80176d <fsipc>

}
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
  80189b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80189e:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018af:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b9:	e8 af fe ff ff       	call   80176d <fsipc>
  8018be:	89 c3                	mov    %eax,%ebx
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 4b                	js     80190f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018c4:	39 c6                	cmp    %eax,%esi
  8018c6:	73 16                	jae    8018de <devfile_read+0x48>
  8018c8:	68 14 29 80 00       	push   $0x802914
  8018cd:	68 1b 29 80 00       	push   $0x80291b
  8018d2:	6a 7c                	push   $0x7c
  8018d4:	68 30 29 80 00       	push   $0x802930
  8018d9:	e8 34 ea ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  8018de:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018e3:	7e 16                	jle    8018fb <devfile_read+0x65>
  8018e5:	68 3b 29 80 00       	push   $0x80293b
  8018ea:	68 1b 29 80 00       	push   $0x80291b
  8018ef:	6a 7d                	push   $0x7d
  8018f1:	68 30 29 80 00       	push   $0x802930
  8018f6:	e8 17 ea ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018fb:	83 ec 04             	sub    $0x4,%esp
  8018fe:	50                   	push   %eax
  8018ff:	68 00 50 80 00       	push   $0x805000
  801904:	ff 75 0c             	pushl  0xc(%ebp)
  801907:	e8 f6 f1 ff ff       	call   800b02 <memmove>
	return r;
  80190c:	83 c4 10             	add    $0x10,%esp
}
  80190f:	89 d8                	mov    %ebx,%eax
  801911:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801914:	5b                   	pop    %ebx
  801915:	5e                   	pop    %esi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	53                   	push   %ebx
  80191c:	83 ec 20             	sub    $0x20,%esp
  80191f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801922:	53                   	push   %ebx
  801923:	e8 0f f0 ff ff       	call   800937 <strlen>
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801930:	7f 67                	jg     801999 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801938:	50                   	push   %eax
  801939:	e8 a7 f8 ff ff       	call   8011e5 <fd_alloc>
  80193e:	83 c4 10             	add    $0x10,%esp
		return r;
  801941:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801943:	85 c0                	test   %eax,%eax
  801945:	78 57                	js     80199e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	53                   	push   %ebx
  80194b:	68 00 50 80 00       	push   $0x805000
  801950:	e8 1b f0 ff ff       	call   800970 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801955:	8b 45 0c             	mov    0xc(%ebp),%eax
  801958:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80195d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801960:	b8 01 00 00 00       	mov    $0x1,%eax
  801965:	e8 03 fe ff ff       	call   80176d <fsipc>
  80196a:	89 c3                	mov    %eax,%ebx
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	79 14                	jns    801987 <open+0x6f>
		fd_close(fd, 0);
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	6a 00                	push   $0x0
  801978:	ff 75 f4             	pushl  -0xc(%ebp)
  80197b:	e8 5d f9 ff ff       	call   8012dd <fd_close>
		return r;
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	89 da                	mov    %ebx,%edx
  801985:	eb 17                	jmp    80199e <open+0x86>
	}

	return fd2num(fd);
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	ff 75 f4             	pushl  -0xc(%ebp)
  80198d:	e8 2c f8 ff ff       	call   8011be <fd2num>
  801992:	89 c2                	mov    %eax,%edx
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	eb 05                	jmp    80199e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801999:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80199e:	89 d0                	mov    %edx,%eax
  8019a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019b5:	e8 b3 fd ff ff       	call   80176d <fsipc>
}
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019c4:	83 ec 0c             	sub    $0xc,%esp
  8019c7:	ff 75 08             	pushl  0x8(%ebp)
  8019ca:	e8 ff f7 ff ff       	call   8011ce <fd2data>
  8019cf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d1:	83 c4 08             	add    $0x8,%esp
  8019d4:	68 47 29 80 00       	push   $0x802947
  8019d9:	53                   	push   %ebx
  8019da:	e8 91 ef ff ff       	call   800970 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019df:	8b 46 04             	mov    0x4(%esi),%eax
  8019e2:	2b 06                	sub    (%esi),%eax
  8019e4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f1:	00 00 00 
	stat->st_dev = &devpipe;
  8019f4:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8019fb:	30 80 00 
	return 0;
}
  8019fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801a03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    

00801a0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a14:	53                   	push   %ebx
  801a15:	6a 00                	push   $0x0
  801a17:	e8 dc f3 ff ff       	call   800df8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a1c:	89 1c 24             	mov    %ebx,(%esp)
  801a1f:	e8 aa f7 ff ff       	call   8011ce <fd2data>
  801a24:	83 c4 08             	add    $0x8,%esp
  801a27:	50                   	push   %eax
  801a28:	6a 00                	push   $0x0
  801a2a:	e8 c9 f3 ff ff       	call   800df8 <sys_page_unmap>
}
  801a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	57                   	push   %edi
  801a38:	56                   	push   %esi
  801a39:	53                   	push   %ebx
  801a3a:	83 ec 1c             	sub    $0x1c,%esp
  801a3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a40:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a42:	a1 04 40 80 00       	mov    0x804004,%eax
  801a47:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a50:	e8 f4 05 00 00       	call   802049 <pageref>
  801a55:	89 c3                	mov    %eax,%ebx
  801a57:	89 3c 24             	mov    %edi,(%esp)
  801a5a:	e8 ea 05 00 00       	call   802049 <pageref>
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	39 c3                	cmp    %eax,%ebx
  801a64:	0f 94 c1             	sete   %cl
  801a67:	0f b6 c9             	movzbl %cl,%ecx
  801a6a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a6d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a73:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a76:	39 ce                	cmp    %ecx,%esi
  801a78:	74 1b                	je     801a95 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a7a:	39 c3                	cmp    %eax,%ebx
  801a7c:	75 c4                	jne    801a42 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a7e:	8b 42 58             	mov    0x58(%edx),%eax
  801a81:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a84:	50                   	push   %eax
  801a85:	56                   	push   %esi
  801a86:	68 4e 29 80 00       	push   $0x80294e
  801a8b:	e8 5b e9 ff ff       	call   8003eb <cprintf>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	eb ad                	jmp    801a42 <_pipeisclosed+0xe>
	}
}
  801a95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9b:	5b                   	pop    %ebx
  801a9c:	5e                   	pop    %esi
  801a9d:	5f                   	pop    %edi
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    

00801aa0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	57                   	push   %edi
  801aa4:	56                   	push   %esi
  801aa5:	53                   	push   %ebx
  801aa6:	83 ec 28             	sub    $0x28,%esp
  801aa9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aac:	56                   	push   %esi
  801aad:	e8 1c f7 ff ff       	call   8011ce <fd2data>
  801ab2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	bf 00 00 00 00       	mov    $0x0,%edi
  801abc:	eb 4b                	jmp    801b09 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801abe:	89 da                	mov    %ebx,%edx
  801ac0:	89 f0                	mov    %esi,%eax
  801ac2:	e8 6d ff ff ff       	call   801a34 <_pipeisclosed>
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	75 48                	jne    801b13 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801acb:	e8 84 f2 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad3:	8b 0b                	mov    (%ebx),%ecx
  801ad5:	8d 51 20             	lea    0x20(%ecx),%edx
  801ad8:	39 d0                	cmp    %edx,%eax
  801ada:	73 e2                	jae    801abe <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801adf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ae3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ae6:	89 c2                	mov    %eax,%edx
  801ae8:	c1 fa 1f             	sar    $0x1f,%edx
  801aeb:	89 d1                	mov    %edx,%ecx
  801aed:	c1 e9 1b             	shr    $0x1b,%ecx
  801af0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801af3:	83 e2 1f             	and    $0x1f,%edx
  801af6:	29 ca                	sub    %ecx,%edx
  801af8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801afc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b00:	83 c0 01             	add    $0x1,%eax
  801b03:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b06:	83 c7 01             	add    $0x1,%edi
  801b09:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b0c:	75 c2                	jne    801ad0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b0e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b11:	eb 05                	jmp    801b18 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1b:	5b                   	pop    %ebx
  801b1c:	5e                   	pop    %esi
  801b1d:	5f                   	pop    %edi
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	57                   	push   %edi
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	83 ec 18             	sub    $0x18,%esp
  801b29:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b2c:	57                   	push   %edi
  801b2d:	e8 9c f6 ff ff       	call   8011ce <fd2data>
  801b32:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b3c:	eb 3d                	jmp    801b7b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b3e:	85 db                	test   %ebx,%ebx
  801b40:	74 04                	je     801b46 <devpipe_read+0x26>
				return i;
  801b42:	89 d8                	mov    %ebx,%eax
  801b44:	eb 44                	jmp    801b8a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b46:	89 f2                	mov    %esi,%edx
  801b48:	89 f8                	mov    %edi,%eax
  801b4a:	e8 e5 fe ff ff       	call   801a34 <_pipeisclosed>
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	75 32                	jne    801b85 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b53:	e8 fc f1 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b58:	8b 06                	mov    (%esi),%eax
  801b5a:	3b 46 04             	cmp    0x4(%esi),%eax
  801b5d:	74 df                	je     801b3e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b5f:	99                   	cltd   
  801b60:	c1 ea 1b             	shr    $0x1b,%edx
  801b63:	01 d0                	add    %edx,%eax
  801b65:	83 e0 1f             	and    $0x1f,%eax
  801b68:	29 d0                	sub    %edx,%eax
  801b6a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b72:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b75:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b78:	83 c3 01             	add    $0x1,%ebx
  801b7b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b7e:	75 d8                	jne    801b58 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b80:	8b 45 10             	mov    0x10(%ebp),%eax
  801b83:	eb 05                	jmp    801b8a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b85:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8d:	5b                   	pop    %ebx
  801b8e:	5e                   	pop    %esi
  801b8f:	5f                   	pop    %edi
  801b90:	5d                   	pop    %ebp
  801b91:	c3                   	ret    

00801b92 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9d:	50                   	push   %eax
  801b9e:	e8 42 f6 ff ff       	call   8011e5 <fd_alloc>
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	89 c2                	mov    %eax,%edx
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	0f 88 2c 01 00 00    	js     801cdc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb0:	83 ec 04             	sub    $0x4,%esp
  801bb3:	68 07 04 00 00       	push   $0x407
  801bb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbb:	6a 00                	push   $0x0
  801bbd:	e8 b1 f1 ff ff       	call   800d73 <sys_page_alloc>
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	89 c2                	mov    %eax,%edx
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	0f 88 0d 01 00 00    	js     801cdc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd5:	50                   	push   %eax
  801bd6:	e8 0a f6 ff ff       	call   8011e5 <fd_alloc>
  801bdb:	89 c3                	mov    %eax,%ebx
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	85 c0                	test   %eax,%eax
  801be2:	0f 88 e2 00 00 00    	js     801cca <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be8:	83 ec 04             	sub    $0x4,%esp
  801beb:	68 07 04 00 00       	push   $0x407
  801bf0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 79 f1 ff ff       	call   800d73 <sys_page_alloc>
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	0f 88 c3 00 00 00    	js     801cca <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c07:	83 ec 0c             	sub    $0xc,%esp
  801c0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0d:	e8 bc f5 ff ff       	call   8011ce <fd2data>
  801c12:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c14:	83 c4 0c             	add    $0xc,%esp
  801c17:	68 07 04 00 00       	push   $0x407
  801c1c:	50                   	push   %eax
  801c1d:	6a 00                	push   $0x0
  801c1f:	e8 4f f1 ff ff       	call   800d73 <sys_page_alloc>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	0f 88 89 00 00 00    	js     801cba <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c31:	83 ec 0c             	sub    $0xc,%esp
  801c34:	ff 75 f0             	pushl  -0x10(%ebp)
  801c37:	e8 92 f5 ff ff       	call   8011ce <fd2data>
  801c3c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c43:	50                   	push   %eax
  801c44:	6a 00                	push   $0x0
  801c46:	56                   	push   %esi
  801c47:	6a 00                	push   $0x0
  801c49:	e8 68 f1 ff ff       	call   800db6 <sys_page_map>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	83 c4 20             	add    $0x20,%esp
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 55                	js     801cac <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c57:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c60:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c65:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c6c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c75:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c81:	83 ec 0c             	sub    $0xc,%esp
  801c84:	ff 75 f4             	pushl  -0xc(%ebp)
  801c87:	e8 32 f5 ff ff       	call   8011be <fd2num>
  801c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c91:	83 c4 04             	add    $0x4,%esp
  801c94:	ff 75 f0             	pushl  -0x10(%ebp)
  801c97:	e8 22 f5 ff ff       	call   8011be <fd2num>
  801c9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	ba 00 00 00 00       	mov    $0x0,%edx
  801caa:	eb 30                	jmp    801cdc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cac:	83 ec 08             	sub    $0x8,%esp
  801caf:	56                   	push   %esi
  801cb0:	6a 00                	push   $0x0
  801cb2:	e8 41 f1 ff ff       	call   800df8 <sys_page_unmap>
  801cb7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cba:	83 ec 08             	sub    $0x8,%esp
  801cbd:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc0:	6a 00                	push   $0x0
  801cc2:	e8 31 f1 ff ff       	call   800df8 <sys_page_unmap>
  801cc7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cca:	83 ec 08             	sub    $0x8,%esp
  801ccd:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd0:	6a 00                	push   $0x0
  801cd2:	e8 21 f1 ff ff       	call   800df8 <sys_page_unmap>
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cdc:	89 d0                	mov    %edx,%eax
  801cde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ceb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cee:	50                   	push   %eax
  801cef:	ff 75 08             	pushl  0x8(%ebp)
  801cf2:	e8 3d f5 ff ff       	call   801234 <fd_lookup>
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 18                	js     801d16 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	ff 75 f4             	pushl  -0xc(%ebp)
  801d04:	e8 c5 f4 ff ff       	call   8011ce <fd2data>
	return _pipeisclosed(fd, p);
  801d09:	89 c2                	mov    %eax,%edx
  801d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0e:	e8 21 fd ff ff       	call   801a34 <_pipeisclosed>
  801d13:	83 c4 10             	add    $0x10,%esp
}
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	56                   	push   %esi
  801d1c:	53                   	push   %ebx
  801d1d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d20:	85 f6                	test   %esi,%esi
  801d22:	75 16                	jne    801d3a <wait+0x22>
  801d24:	68 66 29 80 00       	push   $0x802966
  801d29:	68 1b 29 80 00       	push   $0x80291b
  801d2e:	6a 09                	push   $0x9
  801d30:	68 71 29 80 00       	push   $0x802971
  801d35:	e8 d8 e5 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801d3a:	89 f3                	mov    %esi,%ebx
  801d3c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d42:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d45:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d4b:	eb 05                	jmp    801d52 <wait+0x3a>
		sys_yield();
  801d4d:	e8 02 f0 ff ff       	call   800d54 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d52:	8b 43 48             	mov    0x48(%ebx),%eax
  801d55:	39 c6                	cmp    %eax,%esi
  801d57:	75 07                	jne    801d60 <wait+0x48>
  801d59:	8b 43 54             	mov    0x54(%ebx),%eax
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	75 ed                	jne    801d4d <wait+0x35>
		sys_yield();
}
  801d60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d77:	68 7c 29 80 00       	push   $0x80297c
  801d7c:	ff 75 0c             	pushl  0xc(%ebp)
  801d7f:	e8 ec eb ff ff       	call   800970 <strcpy>
	return 0;
}
  801d84:	b8 00 00 00 00       	mov    $0x0,%eax
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    

00801d8b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	57                   	push   %edi
  801d8f:	56                   	push   %esi
  801d90:	53                   	push   %ebx
  801d91:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d97:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d9c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da2:	eb 2d                	jmp    801dd1 <devcons_write+0x46>
		m = n - tot;
  801da4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801da7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801da9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dac:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801db1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db4:	83 ec 04             	sub    $0x4,%esp
  801db7:	53                   	push   %ebx
  801db8:	03 45 0c             	add    0xc(%ebp),%eax
  801dbb:	50                   	push   %eax
  801dbc:	57                   	push   %edi
  801dbd:	e8 40 ed ff ff       	call   800b02 <memmove>
		sys_cputs(buf, m);
  801dc2:	83 c4 08             	add    $0x8,%esp
  801dc5:	53                   	push   %ebx
  801dc6:	57                   	push   %edi
  801dc7:	e8 eb ee ff ff       	call   800cb7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcc:	01 de                	add    %ebx,%esi
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	89 f0                	mov    %esi,%eax
  801dd3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dd6:	72 cc                	jb     801da4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5f                   	pop    %edi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801deb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801def:	74 2a                	je     801e1b <devcons_read+0x3b>
  801df1:	eb 05                	jmp    801df8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801df3:	e8 5c ef ff ff       	call   800d54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801df8:	e8 d8 ee ff ff       	call   800cd5 <sys_cgetc>
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	74 f2                	je     801df3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e01:	85 c0                	test   %eax,%eax
  801e03:	78 16                	js     801e1b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e05:	83 f8 04             	cmp    $0x4,%eax
  801e08:	74 0c                	je     801e16 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e0d:	88 02                	mov    %al,(%edx)
	return 1;
  801e0f:	b8 01 00 00 00       	mov    $0x1,%eax
  801e14:	eb 05                	jmp    801e1b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e16:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e1b:	c9                   	leave  
  801e1c:	c3                   	ret    

00801e1d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e23:	8b 45 08             	mov    0x8(%ebp),%eax
  801e26:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e29:	6a 01                	push   $0x1
  801e2b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2e:	50                   	push   %eax
  801e2f:	e8 83 ee ff ff       	call   800cb7 <sys_cputs>
}
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    

00801e39 <getchar>:

int
getchar(void)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e3f:	6a 01                	push   $0x1
  801e41:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e44:	50                   	push   %eax
  801e45:	6a 00                	push   $0x0
  801e47:	e8 4e f6 ff ff       	call   80149a <read>
	if (r < 0)
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 0f                	js     801e62 <getchar+0x29>
		return r;
	if (r < 1)
  801e53:	85 c0                	test   %eax,%eax
  801e55:	7e 06                	jle    801e5d <getchar+0x24>
		return -E_EOF;
	return c;
  801e57:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e5b:	eb 05                	jmp    801e62 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e5d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e62:	c9                   	leave  
  801e63:	c3                   	ret    

00801e64 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6d:	50                   	push   %eax
  801e6e:	ff 75 08             	pushl  0x8(%ebp)
  801e71:	e8 be f3 ff ff       	call   801234 <fd_lookup>
  801e76:	83 c4 10             	add    $0x10,%esp
  801e79:	85 c0                	test   %eax,%eax
  801e7b:	78 11                	js     801e8e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e80:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e86:	39 10                	cmp    %edx,(%eax)
  801e88:	0f 94 c0             	sete   %al
  801e8b:	0f b6 c0             	movzbl %al,%eax
}
  801e8e:	c9                   	leave  
  801e8f:	c3                   	ret    

00801e90 <opencons>:

int
opencons(void)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e99:	50                   	push   %eax
  801e9a:	e8 46 f3 ff ff       	call   8011e5 <fd_alloc>
  801e9f:	83 c4 10             	add    $0x10,%esp
		return r;
  801ea2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	78 3e                	js     801ee6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea8:	83 ec 04             	sub    $0x4,%esp
  801eab:	68 07 04 00 00       	push   $0x407
  801eb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb3:	6a 00                	push   $0x0
  801eb5:	e8 b9 ee ff ff       	call   800d73 <sys_page_alloc>
  801eba:	83 c4 10             	add    $0x10,%esp
		return r;
  801ebd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 23                	js     801ee6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ec3:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ed8:	83 ec 0c             	sub    $0xc,%esp
  801edb:	50                   	push   %eax
  801edc:	e8 dd f2 ff ff       	call   8011be <fd2num>
  801ee1:	89 c2                	mov    %eax,%edx
  801ee3:	83 c4 10             	add    $0x10,%esp
}
  801ee6:	89 d0                	mov    %edx,%eax
  801ee8:	c9                   	leave  
  801ee9:	c3                   	ret    

00801eea <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ef0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ef7:	75 2e                	jne    801f27 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801ef9:	e8 37 ee ff ff       	call   800d35 <sys_getenvid>
  801efe:	83 ec 04             	sub    $0x4,%esp
  801f01:	68 07 0e 00 00       	push   $0xe07
  801f06:	68 00 f0 bf ee       	push   $0xeebff000
  801f0b:	50                   	push   %eax
  801f0c:	e8 62 ee ff ff       	call   800d73 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801f11:	e8 1f ee ff ff       	call   800d35 <sys_getenvid>
  801f16:	83 c4 08             	add    $0x8,%esp
  801f19:	68 31 1f 80 00       	push   $0x801f31
  801f1e:	50                   	push   %eax
  801f1f:	e8 9a ef ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
  801f24:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f27:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f31:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f32:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f37:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f39:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801f3c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801f40:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801f44:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801f47:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801f4a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801f4b:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801f4e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801f4f:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801f50:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801f54:	c3                   	ret    

00801f55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	56                   	push   %esi
  801f59:	53                   	push   %ebx
  801f5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f63:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f65:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f6a:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f6d:	83 ec 0c             	sub    $0xc,%esp
  801f70:	50                   	push   %eax
  801f71:	e8 ad ef ff ff       	call   800f23 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	85 f6                	test   %esi,%esi
  801f7b:	74 14                	je     801f91 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f82:	85 c0                	test   %eax,%eax
  801f84:	78 09                	js     801f8f <ipc_recv+0x3a>
  801f86:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f8c:	8b 52 74             	mov    0x74(%edx),%edx
  801f8f:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f91:	85 db                	test   %ebx,%ebx
  801f93:	74 14                	je     801fa9 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f95:	ba 00 00 00 00       	mov    $0x0,%edx
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	78 09                	js     801fa7 <ipc_recv+0x52>
  801f9e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fa4:	8b 52 78             	mov    0x78(%edx),%edx
  801fa7:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	78 08                	js     801fb5 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801fad:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    

00801fbc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	57                   	push   %edi
  801fc0:	56                   	push   %esi
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 0c             	sub    $0xc,%esp
  801fc5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801fce:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801fd0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fd5:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801fd8:	ff 75 14             	pushl  0x14(%ebp)
  801fdb:	53                   	push   %ebx
  801fdc:	56                   	push   %esi
  801fdd:	57                   	push   %edi
  801fde:	e8 1d ef ff ff       	call   800f00 <sys_ipc_try_send>

		if (err < 0) {
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	79 1e                	jns    802008 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801fea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fed:	75 07                	jne    801ff6 <ipc_send+0x3a>
				sys_yield();
  801fef:	e8 60 ed ff ff       	call   800d54 <sys_yield>
  801ff4:	eb e2                	jmp    801fd8 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801ff6:	50                   	push   %eax
  801ff7:	68 88 29 80 00       	push   $0x802988
  801ffc:	6a 49                	push   $0x49
  801ffe:	68 95 29 80 00       	push   $0x802995
  802003:	e8 0a e3 ff ff       	call   800312 <_panic>
		}

	} while (err < 0);

}
  802008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5e                   	pop    %esi
  80200d:	5f                   	pop    %edi
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    

00802010 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802016:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80201b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80201e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802024:	8b 52 50             	mov    0x50(%edx),%edx
  802027:	39 ca                	cmp    %ecx,%edx
  802029:	75 0d                	jne    802038 <ipc_find_env+0x28>
			return envs[i].env_id;
  80202b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80202e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802033:	8b 40 48             	mov    0x48(%eax),%eax
  802036:	eb 0f                	jmp    802047 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802038:	83 c0 01             	add    $0x1,%eax
  80203b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802040:	75 d9                	jne    80201b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802042:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    

00802049 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204f:	89 d0                	mov    %edx,%eax
  802051:	c1 e8 16             	shr    $0x16,%eax
  802054:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80205b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802060:	f6 c1 01             	test   $0x1,%cl
  802063:	74 1d                	je     802082 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802065:	c1 ea 0c             	shr    $0xc,%edx
  802068:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80206f:	f6 c2 01             	test   $0x1,%dl
  802072:	74 0e                	je     802082 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802074:	c1 ea 0c             	shr    $0xc,%edx
  802077:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80207e:	ef 
  80207f:	0f b7 c0             	movzwl %ax,%eax
}
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	66 90                	xchg   %ax,%ax
  802086:	66 90                	xchg   %ax,%ax
  802088:	66 90                	xchg   %ax,%ax
  80208a:	66 90                	xchg   %ax,%ax
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__udivdi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80209b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80209f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 f6                	test   %esi,%esi
  8020a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ad:	89 ca                	mov    %ecx,%edx
  8020af:	89 f8                	mov    %edi,%eax
  8020b1:	75 3d                	jne    8020f0 <__udivdi3+0x60>
  8020b3:	39 cf                	cmp    %ecx,%edi
  8020b5:	0f 87 c5 00 00 00    	ja     802180 <__udivdi3+0xf0>
  8020bb:	85 ff                	test   %edi,%edi
  8020bd:	89 fd                	mov    %edi,%ebp
  8020bf:	75 0b                	jne    8020cc <__udivdi3+0x3c>
  8020c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c6:	31 d2                	xor    %edx,%edx
  8020c8:	f7 f7                	div    %edi
  8020ca:	89 c5                	mov    %eax,%ebp
  8020cc:	89 c8                	mov    %ecx,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	f7 f5                	div    %ebp
  8020d2:	89 c1                	mov    %eax,%ecx
  8020d4:	89 d8                	mov    %ebx,%eax
  8020d6:	89 cf                	mov    %ecx,%edi
  8020d8:	f7 f5                	div    %ebp
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	39 ce                	cmp    %ecx,%esi
  8020f2:	77 74                	ja     802168 <__udivdi3+0xd8>
  8020f4:	0f bd fe             	bsr    %esi,%edi
  8020f7:	83 f7 1f             	xor    $0x1f,%edi
  8020fa:	0f 84 98 00 00 00    	je     802198 <__udivdi3+0x108>
  802100:	bb 20 00 00 00       	mov    $0x20,%ebx
  802105:	89 f9                	mov    %edi,%ecx
  802107:	89 c5                	mov    %eax,%ebp
  802109:	29 fb                	sub    %edi,%ebx
  80210b:	d3 e6                	shl    %cl,%esi
  80210d:	89 d9                	mov    %ebx,%ecx
  80210f:	d3 ed                	shr    %cl,%ebp
  802111:	89 f9                	mov    %edi,%ecx
  802113:	d3 e0                	shl    %cl,%eax
  802115:	09 ee                	or     %ebp,%esi
  802117:	89 d9                	mov    %ebx,%ecx
  802119:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80211d:	89 d5                	mov    %edx,%ebp
  80211f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802123:	d3 ed                	shr    %cl,%ebp
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e2                	shl    %cl,%edx
  802129:	89 d9                	mov    %ebx,%ecx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	09 c2                	or     %eax,%edx
  80212f:	89 d0                	mov    %edx,%eax
  802131:	89 ea                	mov    %ebp,%edx
  802133:	f7 f6                	div    %esi
  802135:	89 d5                	mov    %edx,%ebp
  802137:	89 c3                	mov    %eax,%ebx
  802139:	f7 64 24 0c          	mull   0xc(%esp)
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	72 10                	jb     802151 <__udivdi3+0xc1>
  802141:	8b 74 24 08          	mov    0x8(%esp),%esi
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e6                	shl    %cl,%esi
  802149:	39 c6                	cmp    %eax,%esi
  80214b:	73 07                	jae    802154 <__udivdi3+0xc4>
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	75 03                	jne    802154 <__udivdi3+0xc4>
  802151:	83 eb 01             	sub    $0x1,%ebx
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 d8                	mov    %ebx,%eax
  802158:	89 fa                	mov    %edi,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	31 ff                	xor    %edi,%edi
  80216a:	31 db                	xor    %ebx,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d8                	mov    %ebx,%eax
  802182:	f7 f7                	div    %edi
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 c3                	mov    %eax,%ebx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 fa                	mov    %edi,%edx
  80218c:	83 c4 1c             	add    $0x1c,%esp
  80218f:	5b                   	pop    %ebx
  802190:	5e                   	pop    %esi
  802191:	5f                   	pop    %edi
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	39 ce                	cmp    %ecx,%esi
  80219a:	72 0c                	jb     8021a8 <__udivdi3+0x118>
  80219c:	31 db                	xor    %ebx,%ebx
  80219e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021a2:	0f 87 34 ff ff ff    	ja     8020dc <__udivdi3+0x4c>
  8021a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ad:	e9 2a ff ff ff       	jmp    8020dc <__udivdi3+0x4c>
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 d2                	test   %edx,%edx
  8021d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021e1:	89 f3                	mov    %esi,%ebx
  8021e3:	89 3c 24             	mov    %edi,(%esp)
  8021e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ea:	75 1c                	jne    802208 <__umoddi3+0x48>
  8021ec:	39 f7                	cmp    %esi,%edi
  8021ee:	76 50                	jbe    802240 <__umoddi3+0x80>
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	f7 f7                	div    %edi
  8021f6:	89 d0                	mov    %edx,%eax
  8021f8:	31 d2                	xor    %edx,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	89 d0                	mov    %edx,%eax
  80220c:	77 52                	ja     802260 <__umoddi3+0xa0>
  80220e:	0f bd ea             	bsr    %edx,%ebp
  802211:	83 f5 1f             	xor    $0x1f,%ebp
  802214:	75 5a                	jne    802270 <__umoddi3+0xb0>
  802216:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80221a:	0f 82 e0 00 00 00    	jb     802300 <__umoddi3+0x140>
  802220:	39 0c 24             	cmp    %ecx,(%esp)
  802223:	0f 86 d7 00 00 00    	jbe    802300 <__umoddi3+0x140>
  802229:	8b 44 24 08          	mov    0x8(%esp),%eax
  80222d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	85 ff                	test   %edi,%edi
  802242:	89 fd                	mov    %edi,%ebp
  802244:	75 0b                	jne    802251 <__umoddi3+0x91>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f7                	div    %edi
  80224f:	89 c5                	mov    %eax,%ebp
  802251:	89 f0                	mov    %esi,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 f5                	div    %ebp
  802257:	89 c8                	mov    %ecx,%eax
  802259:	f7 f5                	div    %ebp
  80225b:	89 d0                	mov    %edx,%eax
  80225d:	eb 99                	jmp    8021f8 <__umoddi3+0x38>
  80225f:	90                   	nop
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 1c             	add    $0x1c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	8b 34 24             	mov    (%esp),%esi
  802273:	bf 20 00 00 00       	mov    $0x20,%edi
  802278:	89 e9                	mov    %ebp,%ecx
  80227a:	29 ef                	sub    %ebp,%edi
  80227c:	d3 e0                	shl    %cl,%eax
  80227e:	89 f9                	mov    %edi,%ecx
  802280:	89 f2                	mov    %esi,%edx
  802282:	d3 ea                	shr    %cl,%edx
  802284:	89 e9                	mov    %ebp,%ecx
  802286:	09 c2                	or     %eax,%edx
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	89 14 24             	mov    %edx,(%esp)
  80228d:	89 f2                	mov    %esi,%edx
  80228f:	d3 e2                	shl    %cl,%edx
  802291:	89 f9                	mov    %edi,%ecx
  802293:	89 54 24 04          	mov    %edx,0x4(%esp)
  802297:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	89 c6                	mov    %eax,%esi
  8022a1:	d3 e3                	shl    %cl,%ebx
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 d0                	mov    %edx,%eax
  8022a7:	d3 e8                	shr    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	09 d8                	or     %ebx,%eax
  8022ad:	89 d3                	mov    %edx,%ebx
  8022af:	89 f2                	mov    %esi,%edx
  8022b1:	f7 34 24             	divl   (%esp)
  8022b4:	89 d6                	mov    %edx,%esi
  8022b6:	d3 e3                	shl    %cl,%ebx
  8022b8:	f7 64 24 04          	mull   0x4(%esp)
  8022bc:	39 d6                	cmp    %edx,%esi
  8022be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022c2:	89 d1                	mov    %edx,%ecx
  8022c4:	89 c3                	mov    %eax,%ebx
  8022c6:	72 08                	jb     8022d0 <__umoddi3+0x110>
  8022c8:	75 11                	jne    8022db <__umoddi3+0x11b>
  8022ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ce:	73 0b                	jae    8022db <__umoddi3+0x11b>
  8022d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022d4:	1b 14 24             	sbb    (%esp),%edx
  8022d7:	89 d1                	mov    %edx,%ecx
  8022d9:	89 c3                	mov    %eax,%ebx
  8022db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022df:	29 da                	sub    %ebx,%edx
  8022e1:	19 ce                	sbb    %ecx,%esi
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 f0                	mov    %esi,%eax
  8022e7:	d3 e0                	shl    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	d3 ea                	shr    %cl,%edx
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	d3 ee                	shr    %cl,%esi
  8022f1:	09 d0                	or     %edx,%eax
  8022f3:	89 f2                	mov    %esi,%edx
  8022f5:	83 c4 1c             	add    $0x1c,%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5e                   	pop    %esi
  8022fa:	5f                   	pop    %edi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    
  8022fd:	8d 76 00             	lea    0x0(%esi),%esi
  802300:	29 f9                	sub    %edi,%ecx
  802302:	19 d6                	sbb    %edx,%esi
  802304:	89 74 24 04          	mov    %esi,0x4(%esp)
  802308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80230c:	e9 18 ff ff ff       	jmp    802229 <__umoddi3+0x69>
