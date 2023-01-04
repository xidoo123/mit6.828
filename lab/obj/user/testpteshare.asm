
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 ed 07 00 00       	call   800836 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 c0 0b 00 00       	call   800c39 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 6c 28 80 00       	push   $0x80286c
  800086:	6a 13                	push   $0x13
  800088:	68 7f 28 80 00       	push   $0x80287f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 aa 0e 00 00       	call   800f41 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 93 28 80 00       	push   $0x802893
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 7f 28 80 00       	push   $0x80287f
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 70 07 00 00       	call   800836 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 6e 21 00 00       	call   802245 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 66 28 80 00       	mov    $0x802866,%edx
  8000f4:	b8 60 28 80 00       	mov    $0x802860,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 9c 28 80 00       	push   $0x80289c
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 b7 28 80 00       	push   $0x8028b7
  80010e:	68 bc 28 80 00       	push   $0x8028bc
  800113:	68 bb 28 80 00       	push   $0x8028bb
  800118:	e8 59 1d 00 00       	call   801e76 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 c9 28 80 00       	push   $0x8028c9
  80012a:	6a 21                	push   $0x21
  80012c:	68 7f 28 80 00       	push   $0x80287f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 06 21 00 00       	call   802245 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 66 28 80 00       	mov    $0x802866,%edx
  80015c:	b8 60 28 80 00       	mov    $0x802860,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 d3 28 80 00       	push   $0x8028d3
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800183:	e8 73 0a 00 00       	call   800bfb <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 fd 10 00 00       	call   8012c6 <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 e7 09 00 00       	call   800bba <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8001e6:	e8 10 0a 00 00       	call   800bfb <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 18 29 80 00       	push   $0x802918
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 29 2d 80 00 	movl   $0x802d29,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 2f 09 00 00       	call   800b7d <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 54 01 00 00       	call   8003e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 d4 08 00 00       	call   800b7d <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 a7 22 00 00       	call   8025c0 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 94 23 00 00       	call   8026f0 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 3b 29 80 00 	movsbl 0x80293b(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800377:	83 fa 01             	cmp    $0x1,%edx
  80037a:	7e 0e                	jle    80038a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	8b 52 04             	mov    0x4(%edx),%edx
  800388:	eb 22                	jmp    8003ac <getuint+0x38>
	else if (lflag)
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 10                	je     80039e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 04             	lea    0x4(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 0e                	jmp    8003ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bd:	73 0a                	jae    8003c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	88 02                	mov    %al,(%edx)
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d4:	50                   	push   %eax
  8003d5:	ff 75 10             	pushl  0x10(%ebp)
  8003d8:	ff 75 0c             	pushl  0xc(%ebp)
  8003db:	ff 75 08             	pushl  0x8(%ebp)
  8003de:	e8 05 00 00 00       	call   8003e8 <vprintfmt>
	va_end(ap);
}
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	57                   	push   %edi
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	83 ec 2c             	sub    $0x2c,%esp
  8003f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003fa:	eb 12                	jmp    80040e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	0f 84 89 03 00 00    	je     80078d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	50                   	push   %eax
  800409:	ff d6                	call   *%esi
  80040b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040e:	83 c7 01             	add    $0x1,%edi
  800411:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800415:	83 f8 25             	cmp    $0x25,%eax
  800418:	75 e2                	jne    8003fc <vprintfmt+0x14>
  80041a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800425:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800433:	ba 00 00 00 00       	mov    $0x0,%edx
  800438:	eb 07                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8d 47 01             	lea    0x1(%edi),%eax
  800444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800447:	0f b6 07             	movzbl (%edi),%eax
  80044a:	0f b6 c8             	movzbl %al,%ecx
  80044d:	83 e8 23             	sub    $0x23,%eax
  800450:	3c 55                	cmp    $0x55,%al
  800452:	0f 87 1a 03 00 00    	ja     800772 <vprintfmt+0x38a>
  800458:	0f b6 c0             	movzbl %al,%eax
  80045b:	ff 24 85 80 2a 80 00 	jmp    *0x802a80(,%eax,4)
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800465:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800469:	eb d6                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800476:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800479:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800480:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800483:	83 fa 09             	cmp    $0x9,%edx
  800486:	77 39                	ja     8004c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800488:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048b:	eb e9                	jmp    800476 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 48 04             	lea    0x4(%eax),%ecx
  800493:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049e:	eb 27                	jmp    8004c7 <vprintfmt+0xdf>
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004aa:	0f 49 c8             	cmovns %eax,%ecx
  8004ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b3:	eb 8c                	jmp    800441 <vprintfmt+0x59>
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bf:	eb 80                	jmp    800441 <vprintfmt+0x59>
  8004c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cb:	0f 89 70 ff ff ff    	jns    800441 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004de:	e9 5e ff ff ff       	jmp    800441 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e9:	e9 53 ff ff ff       	jmp    800441 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 50 04             	lea    0x4(%eax),%edx
  8004f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 30                	pushl  (%eax)
  8004fd:	ff d6                	call   *%esi
			break;
  8004ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800505:	e9 04 ff ff ff       	jmp    80040e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	99                   	cltd   
  800516:	31 d0                	xor    %edx,%eax
  800518:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051a:	83 f8 0f             	cmp    $0xf,%eax
  80051d:	7f 0b                	jg     80052a <vprintfmt+0x142>
  80051f:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 53 29 80 00       	push   $0x802953
  800530:	53                   	push   %ebx
  800531:	56                   	push   %esi
  800532:	e8 94 fe ff ff       	call   8003cb <printfmt>
  800537:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053d:	e9 cc fe ff ff       	jmp    80040e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800542:	52                   	push   %edx
  800543:	68 e9 2d 80 00       	push   $0x802de9
  800548:	53                   	push   %ebx
  800549:	56                   	push   %esi
  80054a:	e8 7c fe ff ff       	call   8003cb <printfmt>
  80054f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800555:	e9 b4 fe ff ff       	jmp    80040e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800565:	85 ff                	test   %edi,%edi
  800567:	b8 4c 29 80 00       	mov    $0x80294c,%eax
  80056c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800573:	0f 8e 94 00 00 00    	jle    80060d <vprintfmt+0x225>
  800579:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057d:	0f 84 98 00 00 00    	je     80061b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	ff 75 d0             	pushl  -0x30(%ebp)
  800589:	57                   	push   %edi
  80058a:	e8 86 02 00 00       	call   800815 <strnlen>
  80058f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800592:	29 c1                	sub    %eax,%ecx
  800594:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800597:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80059e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a6:	eb 0f                	jmp    8005b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8005af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 ff                	test   %edi,%edi
  8005b9:	7f ed                	jg     8005a8 <vprintfmt+0x1c0>
  8005bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c1:	85 c9                	test   %ecx,%ecx
  8005c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c8:	0f 49 c1             	cmovns %ecx,%eax
  8005cb:	29 c1                	sub    %eax,%ecx
  8005cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d6:	89 cb                	mov    %ecx,%ebx
  8005d8:	eb 4d                	jmp    800627 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005de:	74 1b                	je     8005fb <vprintfmt+0x213>
  8005e0:	0f be c0             	movsbl %al,%eax
  8005e3:	83 e8 20             	sub    $0x20,%eax
  8005e6:	83 f8 5e             	cmp    $0x5e,%eax
  8005e9:	76 10                	jbe    8005fb <vprintfmt+0x213>
					putch('?', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	ff 75 0c             	pushl  0xc(%ebp)
  8005f1:	6a 3f                	push   $0x3f
  8005f3:	ff 55 08             	call   *0x8(%ebp)
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	eb 0d                	jmp    800608 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	ff 75 0c             	pushl  0xc(%ebp)
  800601:	52                   	push   %edx
  800602:	ff 55 08             	call   *0x8(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800608:	83 eb 01             	sub    $0x1,%ebx
  80060b:	eb 1a                	jmp    800627 <vprintfmt+0x23f>
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800619:	eb 0c                	jmp    800627 <vprintfmt+0x23f>
  80061b:	89 75 08             	mov    %esi,0x8(%ebp)
  80061e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800621:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800624:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800627:	83 c7 01             	add    $0x1,%edi
  80062a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062e:	0f be d0             	movsbl %al,%edx
  800631:	85 d2                	test   %edx,%edx
  800633:	74 23                	je     800658 <vprintfmt+0x270>
  800635:	85 f6                	test   %esi,%esi
  800637:	78 a1                	js     8005da <vprintfmt+0x1f2>
  800639:	83 ee 01             	sub    $0x1,%esi
  80063c:	79 9c                	jns    8005da <vprintfmt+0x1f2>
  80063e:	89 df                	mov    %ebx,%edi
  800640:	8b 75 08             	mov    0x8(%ebp),%esi
  800643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800646:	eb 18                	jmp    800660 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 20                	push   $0x20
  80064e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800650:	83 ef 01             	sub    $0x1,%edi
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb 08                	jmp    800660 <vprintfmt+0x278>
  800658:	89 df                	mov    %ebx,%edi
  80065a:	8b 75 08             	mov    0x8(%ebp),%esi
  80065d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800660:	85 ff                	test   %edi,%edi
  800662:	7f e4                	jg     800648 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800667:	e9 a2 fd ff ff       	jmp    80040e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066c:	83 fa 01             	cmp    $0x1,%edx
  80066f:	7e 16                	jle    800687 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 08             	lea    0x8(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 50 04             	mov    0x4(%eax),%edx
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800682:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800685:	eb 32                	jmp    8006b9 <vprintfmt+0x2d1>
	else if (lflag)
  800687:	85 d2                	test   %edx,%edx
  800689:	74 18                	je     8006a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	89 c1                	mov    %eax,%ecx
  80069b:	c1 f9 1f             	sar    $0x1f,%ecx
  80069e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a1:	eb 16                	jmp    8006b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 50 04             	lea    0x4(%eax),%edx
  8006a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ac:	8b 00                	mov    (%eax),%eax
  8006ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b1:	89 c1                	mov    %eax,%ecx
  8006b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c8:	79 74                	jns    80073e <vprintfmt+0x356>
				putch('-', putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 2d                	push   $0x2d
  8006d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d8:	f7 d8                	neg    %eax
  8006da:	83 d2 00             	adc    $0x0,%edx
  8006dd:	f7 da                	neg    %edx
  8006df:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e7:	eb 55                	jmp    80073e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ec:	e8 83 fc ff ff       	call   800374 <getuint>
			base = 10;
  8006f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f6:	eb 46                	jmp    80073e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fb:	e8 74 fc ff ff       	call   800374 <getuint>
			base = 8;
  800700:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800705:	eb 37                	jmp    80073e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	6a 30                	push   $0x30
  80070d:	ff d6                	call   *%esi
			putch('x', putdat);
  80070f:	83 c4 08             	add    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	6a 78                	push   $0x78
  800715:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 50 04             	lea    0x4(%eax),%edx
  80071d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800720:	8b 00                	mov    (%eax),%eax
  800722:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800727:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80072f:	eb 0d                	jmp    80073e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
  800734:	e8 3b fc ff ff       	call   800374 <getuint>
			base = 16;
  800739:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073e:	83 ec 0c             	sub    $0xc,%esp
  800741:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800745:	57                   	push   %edi
  800746:	ff 75 e0             	pushl  -0x20(%ebp)
  800749:	51                   	push   %ecx
  80074a:	52                   	push   %edx
  80074b:	50                   	push   %eax
  80074c:	89 da                	mov    %ebx,%edx
  80074e:	89 f0                	mov    %esi,%eax
  800750:	e8 70 fb ff ff       	call   8002c5 <printnum>
			break;
  800755:	83 c4 20             	add    $0x20,%esp
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 ae fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	53                   	push   %ebx
  800764:	51                   	push   %ecx
  800765:	ff d6                	call   *%esi
			break;
  800767:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076d:	e9 9c fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 25                	push   $0x25
  800778:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	eb 03                	jmp    800782 <vprintfmt+0x39a>
  80077f:	83 ef 01             	sub    $0x1,%edi
  800782:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800786:	75 f7                	jne    80077f <vprintfmt+0x397>
  800788:	e9 81 fc ff ff       	jmp    80040e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800790:	5b                   	pop    %ebx
  800791:	5e                   	pop    %esi
  800792:	5f                   	pop    %edi
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 18             	sub    $0x18,%esp
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	74 26                	je     8007dc <vsnprintf+0x47>
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	7e 22                	jle    8007dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ba:	ff 75 14             	pushl  0x14(%ebp)
  8007bd:	ff 75 10             	pushl  0x10(%ebp)
  8007c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	68 ae 03 80 00       	push   $0x8003ae
  8007c9:	e8 1a fc ff ff       	call   8003e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	eb 05                	jmp    8007e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ec:	50                   	push   %eax
  8007ed:	ff 75 10             	pushl  0x10(%ebp)
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	ff 75 08             	pushl  0x8(%ebp)
  8007f6:	e8 9a ff ff ff       	call   800795 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	eb 03                	jmp    80080d <strlen+0x10>
		n++;
  80080a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800811:	75 f7                	jne    80080a <strlen+0xd>
		n++;
	return n;
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081e:	ba 00 00 00 00       	mov    $0x0,%edx
  800823:	eb 03                	jmp    800828 <strnlen+0x13>
		n++;
  800825:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800828:	39 c2                	cmp    %eax,%edx
  80082a:	74 08                	je     800834 <strnlen+0x1f>
  80082c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800830:	75 f3                	jne    800825 <strnlen+0x10>
  800832:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800840:	89 c2                	mov    %eax,%edx
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084f:	84 db                	test   %bl,%bl
  800851:	75 ef                	jne    800842 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085d:	53                   	push   %ebx
  80085e:	e8 9a ff ff ff       	call   8007fd <strlen>
  800863:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	01 d8                	add    %ebx,%eax
  80086b:	50                   	push   %eax
  80086c:	e8 c5 ff ff ff       	call   800836 <strcpy>
	return dst;
}
  800871:	89 d8                	mov    %ebx,%eax
  800873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800883:	89 f3                	mov    %esi,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	89 f2                	mov    %esi,%edx
  80088a:	eb 0f                	jmp    80089b <strncpy+0x23>
		*dst++ = *src;
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800895:	80 39 01             	cmpb   $0x1,(%ecx)
  800898:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089b:	39 da                	cmp    %ebx,%edx
  80089d:	75 ed                	jne    80088c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089f:	89 f0                	mov    %esi,%eax
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	74 21                	je     8008da <strlcpy+0x35>
  8008b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bd:	89 f2                	mov    %esi,%edx
  8008bf:	eb 09                	jmp    8008ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ca:	39 c2                	cmp    %eax,%edx
  8008cc:	74 09                	je     8008d7 <strlcpy+0x32>
  8008ce:	0f b6 19             	movzbl (%ecx),%ebx
  8008d1:	84 db                	test   %bl,%bl
  8008d3:	75 ec                	jne    8008c1 <strlcpy+0x1c>
  8008d5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008da:	29 f0                	sub    %esi,%eax
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e9:	eb 06                	jmp    8008f1 <strcmp+0x11>
		p++, q++;
  8008eb:	83 c1 01             	add    $0x1,%ecx
  8008ee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f1:	0f b6 01             	movzbl (%ecx),%eax
  8008f4:	84 c0                	test   %al,%al
  8008f6:	74 04                	je     8008fc <strcmp+0x1c>
  8008f8:	3a 02                	cmp    (%edx),%al
  8008fa:	74 ef                	je     8008eb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fc:	0f b6 c0             	movzbl %al,%eax
  8008ff:	0f b6 12             	movzbl (%edx),%edx
  800902:	29 d0                	sub    %edx,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c3                	mov    %eax,%ebx
  800912:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800915:	eb 06                	jmp    80091d <strncmp+0x17>
		n--, p++, q++;
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091d:	39 d8                	cmp    %ebx,%eax
  80091f:	74 15                	je     800936 <strncmp+0x30>
  800921:	0f b6 08             	movzbl (%eax),%ecx
  800924:	84 c9                	test   %cl,%cl
  800926:	74 04                	je     80092c <strncmp+0x26>
  800928:	3a 0a                	cmp    (%edx),%cl
  80092a:	74 eb                	je     800917 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092c:	0f b6 00             	movzbl (%eax),%eax
  80092f:	0f b6 12             	movzbl (%edx),%edx
  800932:	29 d0                	sub    %edx,%eax
  800934:	eb 05                	jmp    80093b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093b:	5b                   	pop    %ebx
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800948:	eb 07                	jmp    800951 <strchr+0x13>
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 0f                	je     80095d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	0f b6 10             	movzbl (%eax),%edx
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f2                	jne    80094a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800969:	eb 03                	jmp    80096e <strfind+0xf>
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 04                	je     800979 <strfind+0x1a>
  800975:	84 d2                	test   %dl,%dl
  800977:	75 f2                	jne    80096b <strfind+0xc>
			break;
	return (char *) s;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 7d 08             	mov    0x8(%ebp),%edi
  800984:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800987:	85 c9                	test   %ecx,%ecx
  800989:	74 36                	je     8009c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800991:	75 28                	jne    8009bb <memset+0x40>
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	75 23                	jne    8009bb <memset+0x40>
		c &= 0xFF;
  800998:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099c:	89 d3                	mov    %edx,%ebx
  80099e:	c1 e3 08             	shl    $0x8,%ebx
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	c1 e6 18             	shl    $0x18,%esi
  8009a6:	89 d0                	mov    %edx,%eax
  8009a8:	c1 e0 10             	shl    $0x10,%eax
  8009ab:	09 f0                	or     %esi,%eax
  8009ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009af:	89 d8                	mov    %ebx,%eax
  8009b1:	09 d0                	or     %edx,%eax
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
  8009b6:	fc                   	cld    
  8009b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b9:	eb 06                	jmp    8009c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	fc                   	cld    
  8009bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c1:	89 f8                	mov    %edi,%eax
  8009c3:	5b                   	pop    %ebx
  8009c4:	5e                   	pop    %esi
  8009c5:	5f                   	pop    %edi
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d6:	39 c6                	cmp    %eax,%esi
  8009d8:	73 35                	jae    800a0f <memmove+0x47>
  8009da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dd:	39 d0                	cmp    %edx,%eax
  8009df:	73 2e                	jae    800a0f <memmove+0x47>
		s += n;
		d += n;
  8009e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	89 d6                	mov    %edx,%esi
  8009e6:	09 fe                	or     %edi,%esi
  8009e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ee:	75 13                	jne    800a03 <memmove+0x3b>
  8009f0:	f6 c1 03             	test   $0x3,%cl
  8009f3:	75 0e                	jne    800a03 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f5:	83 ef 04             	sub    $0x4,%edi
  8009f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
  8009fe:	fd                   	std    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb 09                	jmp    800a0c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a03:	83 ef 01             	sub    $0x1,%edi
  800a06:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a09:	fd                   	std    
  800a0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0c:	fc                   	cld    
  800a0d:	eb 1d                	jmp    800a2c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	89 f2                	mov    %esi,%edx
  800a11:	09 c2                	or     %eax,%edx
  800a13:	f6 c2 03             	test   $0x3,%dl
  800a16:	75 0f                	jne    800a27 <memmove+0x5f>
  800a18:	f6 c1 03             	test   $0x3,%cl
  800a1b:	75 0a                	jne    800a27 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1d:	c1 e9 02             	shr    $0x2,%ecx
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb 05                	jmp    800a2c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a27:	89 c7                	mov    %eax,%edi
  800a29:	fc                   	cld    
  800a2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a33:	ff 75 10             	pushl  0x10(%ebp)
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	ff 75 08             	pushl  0x8(%ebp)
  800a3c:	e8 87 ff ff ff       	call   8009c8 <memmove>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4e:	89 c6                	mov    %eax,%esi
  800a50:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a53:	eb 1a                	jmp    800a6f <memcmp+0x2c>
		if (*s1 != *s2)
  800a55:	0f b6 08             	movzbl (%eax),%ecx
  800a58:	0f b6 1a             	movzbl (%edx),%ebx
  800a5b:	38 d9                	cmp    %bl,%cl
  800a5d:	74 0a                	je     800a69 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5f:	0f b6 c1             	movzbl %cl,%eax
  800a62:	0f b6 db             	movzbl %bl,%ebx
  800a65:	29 d8                	sub    %ebx,%eax
  800a67:	eb 0f                	jmp    800a78 <memcmp+0x35>
		s1++, s2++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6f:	39 f0                	cmp    %esi,%eax
  800a71:	75 e2                	jne    800a55 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a83:	89 c1                	mov    %eax,%ecx
  800a85:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a88:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8c:	eb 0a                	jmp    800a98 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	0f b6 10             	movzbl (%eax),%edx
  800a91:	39 da                	cmp    %ebx,%edx
  800a93:	74 07                	je     800a9c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a95:	83 c0 01             	add    $0x1,%eax
  800a98:	39 c8                	cmp    %ecx,%eax
  800a9a:	72 f2                	jb     800a8e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aab:	eb 03                	jmp    800ab0 <strtol+0x11>
		s++;
  800aad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab0:	0f b6 01             	movzbl (%ecx),%eax
  800ab3:	3c 20                	cmp    $0x20,%al
  800ab5:	74 f6                	je     800aad <strtol+0xe>
  800ab7:	3c 09                	cmp    $0x9,%al
  800ab9:	74 f2                	je     800aad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abb:	3c 2b                	cmp    $0x2b,%al
  800abd:	75 0a                	jne    800ac9 <strtol+0x2a>
		s++;
  800abf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac7:	eb 11                	jmp    800ada <strtol+0x3b>
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ace:	3c 2d                	cmp    $0x2d,%al
  800ad0:	75 08                	jne    800ada <strtol+0x3b>
		s++, neg = 1;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae0:	75 15                	jne    800af7 <strtol+0x58>
  800ae2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae5:	75 10                	jne    800af7 <strtol+0x58>
  800ae7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aeb:	75 7c                	jne    800b69 <strtol+0xca>
		s += 2, base = 16;
  800aed:	83 c1 02             	add    $0x2,%ecx
  800af0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af5:	eb 16                	jmp    800b0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af7:	85 db                	test   %ebx,%ebx
  800af9:	75 12                	jne    800b0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b00:	80 39 30             	cmpb   $0x30,(%ecx)
  800b03:	75 08                	jne    800b0d <strtol+0x6e>
		s++, base = 8;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b15:	0f b6 11             	movzbl (%ecx),%edx
  800b18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1b:	89 f3                	mov    %esi,%ebx
  800b1d:	80 fb 09             	cmp    $0x9,%bl
  800b20:	77 08                	ja     800b2a <strtol+0x8b>
			dig = *s - '0';
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 30             	sub    $0x30,%edx
  800b28:	eb 22                	jmp    800b4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 19             	cmp    $0x19,%bl
  800b32:	77 08                	ja     800b3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	83 ea 57             	sub    $0x57,%edx
  800b3a:	eb 10                	jmp    800b4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 16                	ja     800b5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4f:	7d 0b                	jge    800b5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5a:	eb b9                	jmp    800b15 <strtol+0x76>

	if (endptr)
  800b5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b60:	74 0d                	je     800b6f <strtol+0xd0>
		*endptr = (char *) s;
  800b62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b65:	89 0e                	mov    %ecx,(%esi)
  800b67:	eb 06                	jmp    800b6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b69:	85 db                	test   %ebx,%ebx
  800b6b:	74 98                	je     800b05 <strtol+0x66>
  800b6d:	eb 9e                	jmp    800b0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	f7 da                	neg    %edx
  800b73:	85 ff                	test   %edi,%edi
  800b75:	0f 45 c2             	cmovne %edx,%eax
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	89 c3                	mov    %eax,%ebx
  800b90:	89 c7                	mov    %eax,%edi
  800b92:	89 c6                	mov    %eax,%esi
  800b94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	89 cb                	mov    %ecx,%ebx
  800bd2:	89 cf                	mov    %ecx,%edi
  800bd4:	89 ce                	mov    %ecx,%esi
  800bd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 03                	push   $0x3
  800be2:	68 3f 2c 80 00       	push   $0x802c3f
  800be7:	6a 23                	push   $0x23
  800be9:	68 5c 2c 80 00       	push   $0x802c5c
  800bee:	e8 e5 f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	ba 00 00 00 00       	mov    $0x0,%edx
  800c06:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0b:	89 d1                	mov    %edx,%ecx
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	89 d7                	mov    %edx,%edi
  800c11:	89 d6                	mov    %edx,%esi
  800c13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_yield>:

void
sys_yield(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	be 00 00 00 00       	mov    $0x0,%esi
  800c47:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c55:	89 f7                	mov    %esi,%edi
  800c57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 17                	jle    800c74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 04                	push   $0x4
  800c63:	68 3f 2c 80 00       	push   $0x802c3f
  800c68:	6a 23                	push   $0x23
  800c6a:	68 5c 2c 80 00       	push   $0x802c5c
  800c6f:	e8 64 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c96:	8b 75 18             	mov    0x18(%ebp),%esi
  800c99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 17                	jle    800cb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 05                	push   $0x5
  800ca5:	68 3f 2c 80 00       	push   $0x802c3f
  800caa:	6a 23                	push   $0x23
  800cac:	68 5c 2c 80 00       	push   $0x802c5c
  800cb1:	e8 22 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 df                	mov    %ebx,%edi
  800cd9:	89 de                	mov    %ebx,%esi
  800cdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 17                	jle    800cf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 06                	push   $0x6
  800ce7:	68 3f 2c 80 00       	push   $0x802c3f
  800cec:	6a 23                	push   $0x23
  800cee:	68 5c 2c 80 00       	push   $0x802c5c
  800cf3:	e8 e0 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 17                	jle    800d3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 08                	push   $0x8
  800d29:	68 3f 2c 80 00       	push   $0x802c3f
  800d2e:	6a 23                	push   $0x23
  800d30:	68 5c 2c 80 00       	push   $0x802c5c
  800d35:	e8 9e f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d50:	b8 09 00 00 00       	mov    $0x9,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 df                	mov    %ebx,%edi
  800d5d:	89 de                	mov    %ebx,%esi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 09                	push   $0x9
  800d6b:	68 3f 2c 80 00       	push   $0x802c3f
  800d70:	6a 23                	push   $0x23
  800d72:	68 5c 2c 80 00       	push   $0x802c5c
  800d77:	e8 5c f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 df                	mov    %ebx,%edi
  800d9f:	89 de                	mov    %ebx,%esi
  800da1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 17                	jle    800dbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 0a                	push   $0xa
  800dad:	68 3f 2c 80 00       	push   $0x802c3f
  800db2:	6a 23                	push   $0x23
  800db4:	68 5c 2c 80 00       	push   $0x802c5c
  800db9:	e8 1a f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	be 00 00 00 00       	mov    $0x0,%esi
  800dd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 cb                	mov    %ecx,%ebx
  800e01:	89 cf                	mov    %ecx,%edi
  800e03:	89 ce                	mov    %ecx,%esi
  800e05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 0d                	push   $0xd
  800e11:	68 3f 2c 80 00       	push   $0x802c3f
  800e16:	6a 23                	push   $0x23
  800e18:	68 5c 2c 80 00       	push   $0x802c5c
  800e1d:	e8 b6 f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 0c             	sub    $0xc,%esp
  800e33:	8b 75 08             	mov    0x8(%ebp),%esi
	void *addr = (void *) utf->utf_fault_va;
  800e36:	8b 1e                	mov    (%esi),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e38:	f6 46 04 02          	testb  $0x2,0x4(%esi)
  800e3c:	75 25                	jne    800e63 <pgfault+0x39>
  800e3e:	89 d8                	mov    %ebx,%eax
  800e40:	c1 e8 0c             	shr    $0xc,%eax
  800e43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e4a:	f6 c4 08             	test   $0x8,%ah
  800e4d:	75 14                	jne    800e63 <pgfault+0x39>
		panic("pgfault: not due to a write or a COW page");
  800e4f:	83 ec 04             	sub    $0x4,%esp
  800e52:	68 6c 2c 80 00       	push   $0x802c6c
  800e57:	6a 1e                	push   $0x1e
  800e59:	68 00 2d 80 00       	push   $0x802d00
  800e5e:	e8 75 f3 ff ff       	call   8001d8 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e63:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e69:	e8 8d fd ff ff       	call   800bfb <sys_getenvid>
  800e6e:	89 c7                	mov    %eax,%edi

	if ( (uint32_t)addr ==  0xeebfd000) {
  800e70:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  800e76:	75 31                	jne    800ea9 <pgfault+0x7f>
		cprintf("[hit %e]\n", utf->utf_err);
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	ff 76 04             	pushl  0x4(%esi)
  800e7e:	68 0b 2d 80 00       	push   $0x802d0b
  800e83:	e8 29 f4 ff ff       	call   8002b1 <cprintf>
		cprintf("[hit 0x%x]\n", utf->utf_eip);
  800e88:	83 c4 08             	add    $0x8,%esp
  800e8b:	ff 76 28             	pushl  0x28(%esi)
  800e8e:	68 15 2d 80 00       	push   $0x802d15
  800e93:	e8 19 f4 ff ff       	call   8002b1 <cprintf>
		cprintf("[hit %d]\n", envid);
  800e98:	83 c4 08             	add    $0x8,%esp
  800e9b:	57                   	push   %edi
  800e9c:	68 21 2d 80 00       	push   $0x802d21
  800ea1:	e8 0b f4 ff ff       	call   8002b1 <cprintf>
  800ea6:	83 c4 10             	add    $0x10,%esp
	}

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	6a 07                	push   $0x7
  800eae:	68 00 f0 7f 00       	push   $0x7ff000
  800eb3:	57                   	push   %edi
  800eb4:	e8 80 fd ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	79 12                	jns    800ed2 <pgfault+0xa8>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ec0:	50                   	push   %eax
  800ec1:	68 98 2c 80 00       	push   $0x802c98
  800ec6:	6a 39                	push   $0x39
  800ec8:	68 00 2d 80 00       	push   $0x802d00
  800ecd:	e8 06 f3 ff ff       	call   8001d8 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	68 00 10 00 00       	push   $0x1000
  800eda:	53                   	push   %ebx
  800edb:	68 00 f0 7f 00       	push   $0x7ff000
  800ee0:	e8 4b fb ff ff       	call   800a30 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800ee5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eec:	53                   	push   %ebx
  800eed:	57                   	push   %edi
  800eee:	68 00 f0 7f 00       	push   $0x7ff000
  800ef3:	57                   	push   %edi
  800ef4:	e8 83 fd ff ff       	call   800c7c <sys_page_map>
	if (r < 0)
  800ef9:	83 c4 20             	add    $0x20,%esp
  800efc:	85 c0                	test   %eax,%eax
  800efe:	79 12                	jns    800f12 <pgfault+0xe8>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f00:	50                   	push   %eax
  800f01:	68 bc 2c 80 00       	push   $0x802cbc
  800f06:	6a 41                	push   $0x41
  800f08:	68 00 2d 80 00       	push   $0x802d00
  800f0d:	e8 c6 f2 ff ff       	call   8001d8 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f12:	83 ec 08             	sub    $0x8,%esp
  800f15:	68 00 f0 7f 00       	push   $0x7ff000
  800f1a:	57                   	push   %edi
  800f1b:	e8 9e fd ff ff       	call   800cbe <sys_page_unmap>
	if (r < 0)
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	79 12                	jns    800f39 <pgfault+0x10f>
        panic("pgfault: page unmap failed: %e\n", r);
  800f27:	50                   	push   %eax
  800f28:	68 e0 2c 80 00       	push   $0x802ce0
  800f2d:	6a 46                	push   $0x46
  800f2f:	68 00 2d 80 00       	push   $0x802d00
  800f34:	e8 9f f2 ff ff       	call   8001d8 <_panic>
}
  800f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	57                   	push   %edi
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
  800f47:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f4a:	68 2a 0e 80 00       	push   $0x800e2a
  800f4f:	e8 c3 14 00 00       	call   802417 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f54:	b8 07 00 00 00       	mov    $0x7,%eax
  800f59:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	0f 88 67 01 00 00    	js     8010cd <fork+0x18c>
  800f66:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f6b:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f70:	85 c0                	test   %eax,%eax
  800f72:	75 21                	jne    800f95 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f74:	e8 82 fc ff ff       	call   800bfb <sys_getenvid>
  800f79:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f81:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f86:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800f8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f90:	e9 42 01 00 00       	jmp    8010d7 <fork+0x196>
  800f95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f98:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f9a:	89 d8                	mov    %ebx,%eax
  800f9c:	c1 e8 16             	shr    $0x16,%eax
  800f9f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa6:	a8 01                	test   $0x1,%al
  800fa8:	0f 84 c0 00 00 00    	je     80106e <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fae:	89 d8                	mov    %ebx,%eax
  800fb0:	c1 e8 0c             	shr    $0xc,%eax
  800fb3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fba:	f6 c2 01             	test   $0x1,%dl
  800fbd:	0f 84 ab 00 00 00    	je     80106e <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800fc3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fca:	a9 02 08 00 00       	test   $0x802,%eax
  800fcf:	0f 84 99 00 00 00    	je     80106e <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800fd5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fdc:	f6 c4 04             	test   $0x4,%ah
  800fdf:	74 17                	je     800ff8 <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	68 07 0e 00 00       	push   $0xe07
  800fe9:	53                   	push   %ebx
  800fea:	57                   	push   %edi
  800feb:	53                   	push   %ebx
  800fec:	6a 00                	push   $0x0
  800fee:	e8 89 fc ff ff       	call   800c7c <sys_page_map>
  800ff3:	83 c4 20             	add    $0x20,%esp
  800ff6:	eb 76                	jmp    80106e <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ff8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fff:	a8 02                	test   $0x2,%al
  801001:	75 0c                	jne    80100f <fork+0xce>
  801003:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100a:	f6 c4 08             	test   $0x8,%ah
  80100d:	74 3f                	je     80104e <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	68 05 08 00 00       	push   $0x805
  801017:	53                   	push   %ebx
  801018:	57                   	push   %edi
  801019:	53                   	push   %ebx
  80101a:	6a 00                	push   $0x0
  80101c:	e8 5b fc ff ff       	call   800c7c <sys_page_map>
		if (r < 0)
  801021:	83 c4 20             	add    $0x20,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	0f 88 a5 00 00 00    	js     8010d1 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	68 05 08 00 00       	push   $0x805
  801034:	53                   	push   %ebx
  801035:	6a 00                	push   $0x0
  801037:	53                   	push   %ebx
  801038:	6a 00                	push   $0x0
  80103a:	e8 3d fc ff ff       	call   800c7c <sys_page_map>
  80103f:	83 c4 20             	add    $0x20,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	b9 00 00 00 00       	mov    $0x0,%ecx
  801049:	0f 4f c1             	cmovg  %ecx,%eax
  80104c:	eb 1c                	jmp    80106a <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	6a 05                	push   $0x5
  801053:	53                   	push   %ebx
  801054:	57                   	push   %edi
  801055:	53                   	push   %ebx
  801056:	6a 00                	push   $0x0
  801058:	e8 1f fc ff ff       	call   800c7c <sys_page_map>
  80105d:	83 c4 20             	add    $0x20,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	b9 00 00 00 00       	mov    $0x0,%ecx
  801067:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 67                	js     8010d5 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80106e:	83 c6 01             	add    $0x1,%esi
  801071:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801077:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80107d:	0f 85 17 ff ff ff    	jne    800f9a <fork+0x59>
  801083:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801086:	83 ec 04             	sub    $0x4,%esp
  801089:	6a 07                	push   $0x7
  80108b:	68 00 f0 bf ee       	push   $0xeebff000
  801090:	57                   	push   %edi
  801091:	e8 a3 fb ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  801096:	83 c4 10             	add    $0x10,%esp
		return r;
  801099:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80109b:	85 c0                	test   %eax,%eax
  80109d:	78 38                	js     8010d7 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	68 5e 24 80 00       	push   $0x80245e
  8010a7:	57                   	push   %edi
  8010a8:	e8 d7 fc ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010ad:	83 c4 10             	add    $0x10,%esp
		return r;
  8010b0:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	78 21                	js     8010d7 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010b6:	83 ec 08             	sub    $0x8,%esp
  8010b9:	6a 02                	push   $0x2
  8010bb:	57                   	push   %edi
  8010bc:	e8 3f fc ff ff       	call   800d00 <sys_env_set_status>
	if (r < 0)
  8010c1:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	0f 48 f8             	cmovs  %eax,%edi
  8010c9:	89 fa                	mov    %edi,%edx
  8010cb:	eb 0a                	jmp    8010d7 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8010cd:	89 c2                	mov    %eax,%edx
  8010cf:	eb 06                	jmp    8010d7 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010d1:	89 c2                	mov    %eax,%edx
  8010d3:	eb 02                	jmp    8010d7 <fork+0x196>
  8010d5:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8010d7:	89 d0                	mov    %edx,%eax
  8010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e7:	68 2b 2d 80 00       	push   $0x802d2b
  8010ec:	68 ce 00 00 00       	push   $0xce
  8010f1:	68 00 2d 80 00       	push   $0x802d00
  8010f6:	e8 dd f0 ff ff       	call   8001d8 <_panic>

008010fb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801101:	05 00 00 00 30       	add    $0x30000000,%eax
  801106:	c1 e8 0c             	shr    $0xc,%eax
}
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
  801111:	05 00 00 00 30       	add    $0x30000000,%eax
  801116:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80111b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801128:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	c1 ea 16             	shr    $0x16,%edx
  801132:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801139:	f6 c2 01             	test   $0x1,%dl
  80113c:	74 11                	je     80114f <fd_alloc+0x2d>
  80113e:	89 c2                	mov    %eax,%edx
  801140:	c1 ea 0c             	shr    $0xc,%edx
  801143:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114a:	f6 c2 01             	test   $0x1,%dl
  80114d:	75 09                	jne    801158 <fd_alloc+0x36>
			*fd_store = fd;
  80114f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801151:	b8 00 00 00 00       	mov    $0x0,%eax
  801156:	eb 17                	jmp    80116f <fd_alloc+0x4d>
  801158:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80115d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801162:	75 c9                	jne    80112d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801164:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80116a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801177:	83 f8 1f             	cmp    $0x1f,%eax
  80117a:	77 36                	ja     8011b2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117c:	c1 e0 0c             	shl    $0xc,%eax
  80117f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801184:	89 c2                	mov    %eax,%edx
  801186:	c1 ea 16             	shr    $0x16,%edx
  801189:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801190:	f6 c2 01             	test   $0x1,%dl
  801193:	74 24                	je     8011b9 <fd_lookup+0x48>
  801195:	89 c2                	mov    %eax,%edx
  801197:	c1 ea 0c             	shr    $0xc,%edx
  80119a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a1:	f6 c2 01             	test   $0x1,%dl
  8011a4:	74 1a                	je     8011c0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a9:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b0:	eb 13                	jmp    8011c5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b7:	eb 0c                	jmp    8011c5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011be:	eb 05                	jmp    8011c5 <fd_lookup+0x54>
  8011c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d0:	ba c0 2d 80 00       	mov    $0x802dc0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d5:	eb 13                	jmp    8011ea <dev_lookup+0x23>
  8011d7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011da:	39 08                	cmp    %ecx,(%eax)
  8011dc:	75 0c                	jne    8011ea <dev_lookup+0x23>
			*dev = devtab[i];
  8011de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e8:	eb 2e                	jmp    801218 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011ea:	8b 02                	mov    (%edx),%eax
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	75 e7                	jne    8011d7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f5:	8b 40 48             	mov    0x48(%eax),%eax
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	51                   	push   %ecx
  8011fc:	50                   	push   %eax
  8011fd:	68 44 2d 80 00       	push   $0x802d44
  801202:	e8 aa f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  801207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
  80121f:	83 ec 10             	sub    $0x10,%esp
  801222:	8b 75 08             	mov    0x8(%ebp),%esi
  801225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801228:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122b:	50                   	push   %eax
  80122c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801232:	c1 e8 0c             	shr    $0xc,%eax
  801235:	50                   	push   %eax
  801236:	e8 36 ff ff ff       	call   801171 <fd_lookup>
  80123b:	83 c4 08             	add    $0x8,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 05                	js     801247 <fd_close+0x2d>
	    || fd != fd2)
  801242:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801245:	74 0c                	je     801253 <fd_close+0x39>
		return (must_exist ? r : 0);
  801247:	84 db                	test   %bl,%bl
  801249:	ba 00 00 00 00       	mov    $0x0,%edx
  80124e:	0f 44 c2             	cmove  %edx,%eax
  801251:	eb 41                	jmp    801294 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801253:	83 ec 08             	sub    $0x8,%esp
  801256:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	ff 36                	pushl  (%esi)
  80125c:	e8 66 ff ff ff       	call   8011c7 <dev_lookup>
  801261:	89 c3                	mov    %eax,%ebx
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 1a                	js     801284 <fd_close+0x6a>
		if (dev->dev_close)
  80126a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801270:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801275:	85 c0                	test   %eax,%eax
  801277:	74 0b                	je     801284 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801279:	83 ec 0c             	sub    $0xc,%esp
  80127c:	56                   	push   %esi
  80127d:	ff d0                	call   *%eax
  80127f:	89 c3                	mov    %eax,%ebx
  801281:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	56                   	push   %esi
  801288:	6a 00                	push   $0x0
  80128a:	e8 2f fa ff ff       	call   800cbe <sys_page_unmap>
	return r;
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	89 d8                	mov    %ebx,%eax
}
  801294:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801297:	5b                   	pop    %ebx
  801298:	5e                   	pop    %esi
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    

0080129b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a4:	50                   	push   %eax
  8012a5:	ff 75 08             	pushl  0x8(%ebp)
  8012a8:	e8 c4 fe ff ff       	call   801171 <fd_lookup>
  8012ad:	83 c4 08             	add    $0x8,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 10                	js     8012c4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	6a 01                	push   $0x1
  8012b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012bc:	e8 59 ff ff ff       	call   80121a <fd_close>
  8012c1:	83 c4 10             	add    $0x10,%esp
}
  8012c4:	c9                   	leave  
  8012c5:	c3                   	ret    

008012c6 <close_all>:

void
close_all(void)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	53                   	push   %ebx
  8012ca:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012cd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d2:	83 ec 0c             	sub    $0xc,%esp
  8012d5:	53                   	push   %ebx
  8012d6:	e8 c0 ff ff ff       	call   80129b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012db:	83 c3 01             	add    $0x1,%ebx
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	83 fb 20             	cmp    $0x20,%ebx
  8012e4:	75 ec                	jne    8012d2 <close_all+0xc>
		close(i);
}
  8012e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    

008012eb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	57                   	push   %edi
  8012ef:	56                   	push   %esi
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 2c             	sub    $0x2c,%esp
  8012f4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012fa:	50                   	push   %eax
  8012fb:	ff 75 08             	pushl  0x8(%ebp)
  8012fe:	e8 6e fe ff ff       	call   801171 <fd_lookup>
  801303:	83 c4 08             	add    $0x8,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	0f 88 c1 00 00 00    	js     8013cf <dup+0xe4>
		return r;
	close(newfdnum);
  80130e:	83 ec 0c             	sub    $0xc,%esp
  801311:	56                   	push   %esi
  801312:	e8 84 ff ff ff       	call   80129b <close>

	newfd = INDEX2FD(newfdnum);
  801317:	89 f3                	mov    %esi,%ebx
  801319:	c1 e3 0c             	shl    $0xc,%ebx
  80131c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801322:	83 c4 04             	add    $0x4,%esp
  801325:	ff 75 e4             	pushl  -0x1c(%ebp)
  801328:	e8 de fd ff ff       	call   80110b <fd2data>
  80132d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80132f:	89 1c 24             	mov    %ebx,(%esp)
  801332:	e8 d4 fd ff ff       	call   80110b <fd2data>
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80133d:	89 f8                	mov    %edi,%eax
  80133f:	c1 e8 16             	shr    $0x16,%eax
  801342:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801349:	a8 01                	test   $0x1,%al
  80134b:	74 37                	je     801384 <dup+0x99>
  80134d:	89 f8                	mov    %edi,%eax
  80134f:	c1 e8 0c             	shr    $0xc,%eax
  801352:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801359:	f6 c2 01             	test   $0x1,%dl
  80135c:	74 26                	je     801384 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80135e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	25 07 0e 00 00       	and    $0xe07,%eax
  80136d:	50                   	push   %eax
  80136e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801371:	6a 00                	push   $0x0
  801373:	57                   	push   %edi
  801374:	6a 00                	push   $0x0
  801376:	e8 01 f9 ff ff       	call   800c7c <sys_page_map>
  80137b:	89 c7                	mov    %eax,%edi
  80137d:	83 c4 20             	add    $0x20,%esp
  801380:	85 c0                	test   %eax,%eax
  801382:	78 2e                	js     8013b2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801384:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801387:	89 d0                	mov    %edx,%eax
  801389:	c1 e8 0c             	shr    $0xc,%eax
  80138c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	25 07 0e 00 00       	and    $0xe07,%eax
  80139b:	50                   	push   %eax
  80139c:	53                   	push   %ebx
  80139d:	6a 00                	push   $0x0
  80139f:	52                   	push   %edx
  8013a0:	6a 00                	push   $0x0
  8013a2:	e8 d5 f8 ff ff       	call   800c7c <sys_page_map>
  8013a7:	89 c7                	mov    %eax,%edi
  8013a9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ac:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ae:	85 ff                	test   %edi,%edi
  8013b0:	79 1d                	jns    8013cf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013b2:	83 ec 08             	sub    $0x8,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	6a 00                	push   $0x0
  8013b8:	e8 01 f9 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013bd:	83 c4 08             	add    $0x8,%esp
  8013c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c3:	6a 00                	push   $0x0
  8013c5:	e8 f4 f8 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	89 f8                	mov    %edi,%eax
}
  8013cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d2:	5b                   	pop    %ebx
  8013d3:	5e                   	pop    %esi
  8013d4:	5f                   	pop    %edi
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    

008013d7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	53                   	push   %ebx
  8013db:	83 ec 14             	sub    $0x14,%esp
  8013de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e4:	50                   	push   %eax
  8013e5:	53                   	push   %ebx
  8013e6:	e8 86 fd ff ff       	call   801171 <fd_lookup>
  8013eb:	83 c4 08             	add    $0x8,%esp
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 6d                	js     801461 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fa:	50                   	push   %eax
  8013fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fe:	ff 30                	pushl  (%eax)
  801400:	e8 c2 fd ff ff       	call   8011c7 <dev_lookup>
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	85 c0                	test   %eax,%eax
  80140a:	78 4c                	js     801458 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80140c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80140f:	8b 42 08             	mov    0x8(%edx),%eax
  801412:	83 e0 03             	and    $0x3,%eax
  801415:	83 f8 01             	cmp    $0x1,%eax
  801418:	75 21                	jne    80143b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80141a:	a1 04 40 80 00       	mov    0x804004,%eax
  80141f:	8b 40 48             	mov    0x48(%eax),%eax
  801422:	83 ec 04             	sub    $0x4,%esp
  801425:	53                   	push   %ebx
  801426:	50                   	push   %eax
  801427:	68 85 2d 80 00       	push   $0x802d85
  80142c:	e8 80 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801439:	eb 26                	jmp    801461 <read+0x8a>
	}
	if (!dev->dev_read)
  80143b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143e:	8b 40 08             	mov    0x8(%eax),%eax
  801441:	85 c0                	test   %eax,%eax
  801443:	74 17                	je     80145c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801445:	83 ec 04             	sub    $0x4,%esp
  801448:	ff 75 10             	pushl  0x10(%ebp)
  80144b:	ff 75 0c             	pushl  0xc(%ebp)
  80144e:	52                   	push   %edx
  80144f:	ff d0                	call   *%eax
  801451:	89 c2                	mov    %eax,%edx
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	eb 09                	jmp    801461 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801458:	89 c2                	mov    %eax,%edx
  80145a:	eb 05                	jmp    801461 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80145c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801461:	89 d0                	mov    %edx,%eax
  801463:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	57                   	push   %edi
  80146c:	56                   	push   %esi
  80146d:	53                   	push   %ebx
  80146e:	83 ec 0c             	sub    $0xc,%esp
  801471:	8b 7d 08             	mov    0x8(%ebp),%edi
  801474:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801477:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147c:	eb 21                	jmp    80149f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80147e:	83 ec 04             	sub    $0x4,%esp
  801481:	89 f0                	mov    %esi,%eax
  801483:	29 d8                	sub    %ebx,%eax
  801485:	50                   	push   %eax
  801486:	89 d8                	mov    %ebx,%eax
  801488:	03 45 0c             	add    0xc(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	57                   	push   %edi
  80148d:	e8 45 ff ff ff       	call   8013d7 <read>
		if (m < 0)
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	85 c0                	test   %eax,%eax
  801497:	78 10                	js     8014a9 <readn+0x41>
			return m;
		if (m == 0)
  801499:	85 c0                	test   %eax,%eax
  80149b:	74 0a                	je     8014a7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80149d:	01 c3                	add    %eax,%ebx
  80149f:	39 f3                	cmp    %esi,%ebx
  8014a1:	72 db                	jb     80147e <readn+0x16>
  8014a3:	89 d8                	mov    %ebx,%eax
  8014a5:	eb 02                	jmp    8014a9 <readn+0x41>
  8014a7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ac:	5b                   	pop    %ebx
  8014ad:	5e                   	pop    %esi
  8014ae:	5f                   	pop    %edi
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	53                   	push   %ebx
  8014b5:	83 ec 14             	sub    $0x14,%esp
  8014b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	53                   	push   %ebx
  8014c0:	e8 ac fc ff ff       	call   801171 <fd_lookup>
  8014c5:	83 c4 08             	add    $0x8,%esp
  8014c8:	89 c2                	mov    %eax,%edx
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 68                	js     801536 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d8:	ff 30                	pushl  (%eax)
  8014da:	e8 e8 fc ff ff       	call   8011c7 <dev_lookup>
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 47                	js     80152d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ed:	75 21                	jne    801510 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f4:	8b 40 48             	mov    0x48(%eax),%eax
  8014f7:	83 ec 04             	sub    $0x4,%esp
  8014fa:	53                   	push   %ebx
  8014fb:	50                   	push   %eax
  8014fc:	68 a1 2d 80 00       	push   $0x802da1
  801501:	e8 ab ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80150e:	eb 26                	jmp    801536 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801510:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801513:	8b 52 0c             	mov    0xc(%edx),%edx
  801516:	85 d2                	test   %edx,%edx
  801518:	74 17                	je     801531 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151a:	83 ec 04             	sub    $0x4,%esp
  80151d:	ff 75 10             	pushl  0x10(%ebp)
  801520:	ff 75 0c             	pushl  0xc(%ebp)
  801523:	50                   	push   %eax
  801524:	ff d2                	call   *%edx
  801526:	89 c2                	mov    %eax,%edx
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	eb 09                	jmp    801536 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	eb 05                	jmp    801536 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801531:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801536:	89 d0                	mov    %edx,%eax
  801538:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <seek>:

int
seek(int fdnum, off_t offset)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801543:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	ff 75 08             	pushl  0x8(%ebp)
  80154a:	e8 22 fc ff ff       	call   801171 <fd_lookup>
  80154f:	83 c4 08             	add    $0x8,%esp
  801552:	85 c0                	test   %eax,%eax
  801554:	78 0e                	js     801564 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801556:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801559:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80155f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801564:	c9                   	leave  
  801565:	c3                   	ret    

00801566 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	53                   	push   %ebx
  80156a:	83 ec 14             	sub    $0x14,%esp
  80156d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801570:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	53                   	push   %ebx
  801575:	e8 f7 fb ff ff       	call   801171 <fd_lookup>
  80157a:	83 c4 08             	add    $0x8,%esp
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 65                	js     8015e8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158d:	ff 30                	pushl  (%eax)
  80158f:	e8 33 fc ff ff       	call   8011c7 <dev_lookup>
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 44                	js     8015df <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a2:	75 21                	jne    8015c5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a9:	8b 40 48             	mov    0x48(%eax),%eax
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	53                   	push   %ebx
  8015b0:	50                   	push   %eax
  8015b1:	68 64 2d 80 00       	push   $0x802d64
  8015b6:	e8 f6 ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c3:	eb 23                	jmp    8015e8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c8:	8b 52 18             	mov    0x18(%edx),%edx
  8015cb:	85 d2                	test   %edx,%edx
  8015cd:	74 14                	je     8015e3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	ff 75 0c             	pushl  0xc(%ebp)
  8015d5:	50                   	push   %eax
  8015d6:	ff d2                	call   *%edx
  8015d8:	89 c2                	mov    %eax,%edx
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	eb 09                	jmp    8015e8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015df:	89 c2                	mov    %eax,%edx
  8015e1:	eb 05                	jmp    8015e8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015e8:	89 d0                	mov    %edx,%eax
  8015ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 14             	sub    $0x14,%esp
  8015f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	ff 75 08             	pushl  0x8(%ebp)
  801600:	e8 6c fb ff ff       	call   801171 <fd_lookup>
  801605:	83 c4 08             	add    $0x8,%esp
  801608:	89 c2                	mov    %eax,%edx
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 58                	js     801666 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801618:	ff 30                	pushl  (%eax)
  80161a:	e8 a8 fb ff ff       	call   8011c7 <dev_lookup>
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	78 37                	js     80165d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801626:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801629:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80162d:	74 32                	je     801661 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80162f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801632:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801639:	00 00 00 
	stat->st_isdir = 0;
  80163c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801643:	00 00 00 
	stat->st_dev = dev;
  801646:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	53                   	push   %ebx
  801650:	ff 75 f0             	pushl  -0x10(%ebp)
  801653:	ff 50 14             	call   *0x14(%eax)
  801656:	89 c2                	mov    %eax,%edx
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	eb 09                	jmp    801666 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	eb 05                	jmp    801666 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801661:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801666:	89 d0                	mov    %edx,%eax
  801668:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    

0080166d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801672:	83 ec 08             	sub    $0x8,%esp
  801675:	6a 00                	push   $0x0
  801677:	ff 75 08             	pushl  0x8(%ebp)
  80167a:	e8 d6 01 00 00       	call   801855 <open>
  80167f:	89 c3                	mov    %eax,%ebx
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	78 1b                	js     8016a3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	ff 75 0c             	pushl  0xc(%ebp)
  80168e:	50                   	push   %eax
  80168f:	e8 5b ff ff ff       	call   8015ef <fstat>
  801694:	89 c6                	mov    %eax,%esi
	close(fd);
  801696:	89 1c 24             	mov    %ebx,(%esp)
  801699:	e8 fd fb ff ff       	call   80129b <close>
	return r;
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	89 f0                	mov    %esi,%eax
}
  8016a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	56                   	push   %esi
  8016ae:	53                   	push   %ebx
  8016af:	89 c6                	mov    %eax,%esi
  8016b1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016ba:	75 12                	jne    8016ce <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016bc:	83 ec 0c             	sub    $0xc,%esp
  8016bf:	6a 01                	push   $0x1
  8016c1:	e8 77 0e 00 00       	call   80253d <ipc_find_env>
  8016c6:	a3 00 40 80 00       	mov    %eax,0x804000
  8016cb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ce:	6a 07                	push   $0x7
  8016d0:	68 00 50 80 00       	push   $0x805000
  8016d5:	56                   	push   %esi
  8016d6:	ff 35 00 40 80 00    	pushl  0x804000
  8016dc:	e8 08 0e 00 00       	call   8024e9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e1:	83 c4 0c             	add    $0xc,%esp
  8016e4:	6a 00                	push   $0x0
  8016e6:	53                   	push   %ebx
  8016e7:	6a 00                	push   $0x0
  8016e9:	e8 94 0d 00 00       	call   802482 <ipc_recv>
}
  8016ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801701:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801706:	8b 45 0c             	mov    0xc(%ebp),%eax
  801709:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80170e:	ba 00 00 00 00       	mov    $0x0,%edx
  801713:	b8 02 00 00 00       	mov    $0x2,%eax
  801718:	e8 8d ff ff ff       	call   8016aa <fsipc>
}
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801725:	8b 45 08             	mov    0x8(%ebp),%eax
  801728:	8b 40 0c             	mov    0xc(%eax),%eax
  80172b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801730:	ba 00 00 00 00       	mov    $0x0,%edx
  801735:	b8 06 00 00 00       	mov    $0x6,%eax
  80173a:	e8 6b ff ff ff       	call   8016aa <fsipc>
}
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	53                   	push   %ebx
  801745:	83 ec 04             	sub    $0x4,%esp
  801748:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174b:	8b 45 08             	mov    0x8(%ebp),%eax
  80174e:	8b 40 0c             	mov    0xc(%eax),%eax
  801751:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801756:	ba 00 00 00 00       	mov    $0x0,%edx
  80175b:	b8 05 00 00 00       	mov    $0x5,%eax
  801760:	e8 45 ff ff ff       	call   8016aa <fsipc>
  801765:	85 c0                	test   %eax,%eax
  801767:	78 2c                	js     801795 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801769:	83 ec 08             	sub    $0x8,%esp
  80176c:	68 00 50 80 00       	push   $0x805000
  801771:	53                   	push   %ebx
  801772:	e8 bf f0 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801777:	a1 80 50 80 00       	mov    0x805080,%eax
  80177c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801782:	a1 84 50 80 00       	mov    0x805084,%eax
  801787:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801795:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017af:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017b4:	50                   	push   %eax
  8017b5:	ff 75 0c             	pushl  0xc(%ebp)
  8017b8:	68 08 50 80 00       	push   $0x805008
  8017bd:	e8 06 f2 ff ff       	call   8009c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8017cc:	e8 d9 fe ff ff       	call   8016aa <fsipc>

}
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
  8017d8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017e6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8017f6:	e8 af fe ff ff       	call   8016aa <fsipc>
  8017fb:	89 c3                	mov    %eax,%ebx
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 4b                	js     80184c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801801:	39 c6                	cmp    %eax,%esi
  801803:	73 16                	jae    80181b <devfile_read+0x48>
  801805:	68 d0 2d 80 00       	push   $0x802dd0
  80180a:	68 d7 2d 80 00       	push   $0x802dd7
  80180f:	6a 7c                	push   $0x7c
  801811:	68 ec 2d 80 00       	push   $0x802dec
  801816:	e8 bd e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  80181b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801820:	7e 16                	jle    801838 <devfile_read+0x65>
  801822:	68 f7 2d 80 00       	push   $0x802df7
  801827:	68 d7 2d 80 00       	push   $0x802dd7
  80182c:	6a 7d                	push   $0x7d
  80182e:	68 ec 2d 80 00       	push   $0x802dec
  801833:	e8 a0 e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801838:	83 ec 04             	sub    $0x4,%esp
  80183b:	50                   	push   %eax
  80183c:	68 00 50 80 00       	push   $0x805000
  801841:	ff 75 0c             	pushl  0xc(%ebp)
  801844:	e8 7f f1 ff ff       	call   8009c8 <memmove>
	return r;
  801849:	83 c4 10             	add    $0x10,%esp
}
  80184c:	89 d8                	mov    %ebx,%eax
  80184e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801851:	5b                   	pop    %ebx
  801852:	5e                   	pop    %esi
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	53                   	push   %ebx
  801859:	83 ec 20             	sub    $0x20,%esp
  80185c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80185f:	53                   	push   %ebx
  801860:	e8 98 ef ff ff       	call   8007fd <strlen>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80186d:	7f 67                	jg     8018d6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801875:	50                   	push   %eax
  801876:	e8 a7 f8 ff ff       	call   801122 <fd_alloc>
  80187b:	83 c4 10             	add    $0x10,%esp
		return r;
  80187e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801880:	85 c0                	test   %eax,%eax
  801882:	78 57                	js     8018db <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801884:	83 ec 08             	sub    $0x8,%esp
  801887:	53                   	push   %ebx
  801888:	68 00 50 80 00       	push   $0x805000
  80188d:	e8 a4 ef ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801892:	8b 45 0c             	mov    0xc(%ebp),%eax
  801895:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80189a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189d:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a2:	e8 03 fe ff ff       	call   8016aa <fsipc>
  8018a7:	89 c3                	mov    %eax,%ebx
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	79 14                	jns    8018c4 <open+0x6f>
		fd_close(fd, 0);
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	6a 00                	push   $0x0
  8018b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b8:	e8 5d f9 ff ff       	call   80121a <fd_close>
		return r;
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	89 da                	mov    %ebx,%edx
  8018c2:	eb 17                	jmp    8018db <open+0x86>
	}

	return fd2num(fd);
  8018c4:	83 ec 0c             	sub    $0xc,%esp
  8018c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ca:	e8 2c f8 ff ff       	call   8010fb <fd2num>
  8018cf:	89 c2                	mov    %eax,%edx
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	eb 05                	jmp    8018db <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018d6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018db:	89 d0                	mov    %edx,%eax
  8018dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ed:	b8 08 00 00 00       	mov    $0x8,%eax
  8018f2:	e8 b3 fd ff ff       	call   8016aa <fsipc>
}
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    

008018f9 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	57                   	push   %edi
  8018fd:	56                   	push   %esi
  8018fe:	53                   	push   %ebx
  8018ff:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801905:	6a 00                	push   $0x0
  801907:	ff 75 08             	pushl  0x8(%ebp)
  80190a:	e8 46 ff ff ff       	call   801855 <open>
  80190f:	89 c7                	mov    %eax,%edi
  801911:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	85 c0                	test   %eax,%eax
  80191c:	0f 88 97 04 00 00    	js     801db9 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801922:	83 ec 04             	sub    $0x4,%esp
  801925:	68 00 02 00 00       	push   $0x200
  80192a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801930:	50                   	push   %eax
  801931:	57                   	push   %edi
  801932:	e8 31 fb ff ff       	call   801468 <readn>
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	3d 00 02 00 00       	cmp    $0x200,%eax
  80193f:	75 0c                	jne    80194d <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801941:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801948:	45 4c 46 
  80194b:	74 33                	je     801980 <spawn+0x87>
		close(fd);
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801956:	e8 40 f9 ff ff       	call   80129b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80195b:	83 c4 0c             	add    $0xc,%esp
  80195e:	68 7f 45 4c 46       	push   $0x464c457f
  801963:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801969:	68 03 2e 80 00       	push   $0x802e03
  80196e:	e8 3e e9 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80197b:	e9 ec 04 00 00       	jmp    801e6c <spawn+0x573>
  801980:	b8 07 00 00 00       	mov    $0x7,%eax
  801985:	cd 30                	int    $0x30
  801987:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80198d:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801993:	85 c0                	test   %eax,%eax
  801995:	0f 88 29 04 00 00    	js     801dc4 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80199b:	89 c6                	mov    %eax,%esi
  80199d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019a3:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8019a6:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019ac:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019b2:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019b9:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019bf:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019c5:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019ca:	be 00 00 00 00       	mov    $0x0,%esi
  8019cf:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019d2:	eb 13                	jmp    8019e7 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019d4:	83 ec 0c             	sub    $0xc,%esp
  8019d7:	50                   	push   %eax
  8019d8:	e8 20 ee ff ff       	call   8007fd <strlen>
  8019dd:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019e1:	83 c3 01             	add    $0x1,%ebx
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019ee:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	75 df                	jne    8019d4 <spawn+0xdb>
  8019f5:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019fb:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a01:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a06:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a08:	89 fa                	mov    %edi,%edx
  801a0a:	83 e2 fc             	and    $0xfffffffc,%edx
  801a0d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a14:	29 c2                	sub    %eax,%edx
  801a16:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a1c:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a1f:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a24:	0f 86 b0 03 00 00    	jbe    801dda <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	6a 07                	push   $0x7
  801a2f:	68 00 00 40 00       	push   $0x400000
  801a34:	6a 00                	push   $0x0
  801a36:	e8 fe f1 ff ff       	call   800c39 <sys_page_alloc>
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	0f 88 9e 03 00 00    	js     801de4 <spawn+0x4eb>
  801a46:	be 00 00 00 00       	mov    $0x0,%esi
  801a4b:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a54:	eb 30                	jmp    801a86 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a56:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a5c:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a62:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a65:	83 ec 08             	sub    $0x8,%esp
  801a68:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a6b:	57                   	push   %edi
  801a6c:	e8 c5 ed ff ff       	call   800836 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a71:	83 c4 04             	add    $0x4,%esp
  801a74:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a77:	e8 81 ed ff ff       	call   8007fd <strlen>
  801a7c:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a80:	83 c6 01             	add    $0x1,%esi
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a8c:	7f c8                	jg     801a56 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a8e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a94:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801a9a:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801aa1:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801aa7:	74 19                	je     801ac2 <spawn+0x1c9>
  801aa9:	68 90 2e 80 00       	push   $0x802e90
  801aae:	68 d7 2d 80 00       	push   $0x802dd7
  801ab3:	68 f2 00 00 00       	push   $0xf2
  801ab8:	68 1d 2e 80 00       	push   $0x802e1d
  801abd:	e8 16 e7 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ac2:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801ac8:	89 f8                	mov    %edi,%eax
  801aca:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801acf:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801ad2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ad8:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801adb:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801ae1:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	6a 07                	push   $0x7
  801aec:	68 00 d0 bf ee       	push   $0xeebfd000
  801af1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801af7:	68 00 00 40 00       	push   $0x400000
  801afc:	6a 00                	push   $0x0
  801afe:	e8 79 f1 ff ff       	call   800c7c <sys_page_map>
  801b03:	89 c3                	mov    %eax,%ebx
  801b05:	83 c4 20             	add    $0x20,%esp
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	0f 88 4a 03 00 00    	js     801e5a <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b10:	83 ec 08             	sub    $0x8,%esp
  801b13:	68 00 00 40 00       	push   $0x400000
  801b18:	6a 00                	push   $0x0
  801b1a:	e8 9f f1 ff ff       	call   800cbe <sys_page_unmap>
  801b1f:	89 c3                	mov    %eax,%ebx
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	85 c0                	test   %eax,%eax
  801b26:	0f 88 2e 03 00 00    	js     801e5a <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b2c:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b32:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b39:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b3f:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b46:	00 00 00 
  801b49:	e9 8a 01 00 00       	jmp    801cd8 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801b4e:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b54:	83 38 01             	cmpl   $0x1,(%eax)
  801b57:	0f 85 6d 01 00 00    	jne    801cca <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b5d:	89 c7                	mov    %eax,%edi
  801b5f:	8b 40 18             	mov    0x18(%eax),%eax
  801b62:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b68:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b6b:	83 f8 01             	cmp    $0x1,%eax
  801b6e:	19 c0                	sbb    %eax,%eax
  801b70:	83 e0 fe             	and    $0xfffffffe,%eax
  801b73:	83 c0 07             	add    $0x7,%eax
  801b76:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b7c:	89 f8                	mov    %edi,%eax
  801b7e:	8b 7f 04             	mov    0x4(%edi),%edi
  801b81:	89 f9                	mov    %edi,%ecx
  801b83:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b89:	8b 78 10             	mov    0x10(%eax),%edi
  801b8c:	8b 70 14             	mov    0x14(%eax),%esi
  801b8f:	89 f3                	mov    %esi,%ebx
  801b91:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b97:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b9a:	89 f0                	mov    %esi,%eax
  801b9c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ba1:	74 14                	je     801bb7 <spawn+0x2be>
		va -= i;
  801ba3:	29 c6                	sub    %eax,%esi
		memsz += i;
  801ba5:	01 c3                	add    %eax,%ebx
  801ba7:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801bad:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801baf:	29 c1                	sub    %eax,%ecx
  801bb1:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bbc:	e9 f7 00 00 00       	jmp    801cb8 <spawn+0x3bf>
		if (i >= filesz) {
  801bc1:	39 df                	cmp    %ebx,%edi
  801bc3:	77 27                	ja     801bec <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801bc5:	83 ec 04             	sub    $0x4,%esp
  801bc8:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bce:	56                   	push   %esi
  801bcf:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bd5:	e8 5f f0 ff ff       	call   800c39 <sys_page_alloc>
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	0f 89 c7 00 00 00    	jns    801cac <spawn+0x3b3>
  801be5:	89 c3                	mov    %eax,%ebx
  801be7:	e9 09 02 00 00       	jmp    801df5 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bec:	83 ec 04             	sub    $0x4,%esp
  801bef:	6a 07                	push   $0x7
  801bf1:	68 00 00 40 00       	push   $0x400000
  801bf6:	6a 00                	push   $0x0
  801bf8:	e8 3c f0 ff ff       	call   800c39 <sys_page_alloc>
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	85 c0                	test   %eax,%eax
  801c02:	0f 88 e3 01 00 00    	js     801deb <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c11:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c17:	50                   	push   %eax
  801c18:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c1e:	e8 1a f9 ff ff       	call   80153d <seek>
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	0f 88 c1 01 00 00    	js     801def <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c2e:	83 ec 04             	sub    $0x4,%esp
  801c31:	89 f8                	mov    %edi,%eax
  801c33:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c39:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c3e:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c43:	0f 47 c1             	cmova  %ecx,%eax
  801c46:	50                   	push   %eax
  801c47:	68 00 00 40 00       	push   $0x400000
  801c4c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c52:	e8 11 f8 ff ff       	call   801468 <readn>
  801c57:	83 c4 10             	add    $0x10,%esp
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	0f 88 91 01 00 00    	js     801df3 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c62:	83 ec 0c             	sub    $0xc,%esp
  801c65:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c6b:	56                   	push   %esi
  801c6c:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c72:	68 00 00 40 00       	push   $0x400000
  801c77:	6a 00                	push   $0x0
  801c79:	e8 fe ef ff ff       	call   800c7c <sys_page_map>
  801c7e:	83 c4 20             	add    $0x20,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	79 15                	jns    801c9a <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801c85:	50                   	push   %eax
  801c86:	68 29 2e 80 00       	push   $0x802e29
  801c8b:	68 25 01 00 00       	push   $0x125
  801c90:	68 1d 2e 80 00       	push   $0x802e1d
  801c95:	e8 3e e5 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801c9a:	83 ec 08             	sub    $0x8,%esp
  801c9d:	68 00 00 40 00       	push   $0x400000
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 15 f0 ff ff       	call   800cbe <sys_page_unmap>
  801ca9:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cb2:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cb8:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801cbe:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801cc4:	0f 87 f7 fe ff ff    	ja     801bc1 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cca:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801cd1:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801cd8:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cdf:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801ce5:	0f 8c 63 fe ff ff    	jl     801b4e <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cf4:	e8 a2 f5 ff ff       	call   80129b <close>
  801cf9:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801cfc:	bb 00 08 00 00       	mov    $0x800,%ebx
  801d01:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  801d07:	89 d8                	mov    %ebx,%eax
  801d09:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801d0c:	89 c2                	mov    %eax,%edx
  801d0e:	c1 ea 16             	shr    $0x16,%edx
  801d11:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d18:	f6 c2 01             	test   $0x1,%dl
  801d1b:	74 4b                	je     801d68 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801d1d:	89 c2                	mov    %eax,%edx
  801d1f:	c1 ea 0c             	shr    $0xc,%edx
  801d22:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801d29:	f6 c1 01             	test   $0x1,%cl
  801d2c:	74 3a                	je     801d68 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801d2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d35:	f6 c6 04             	test   $0x4,%dh
  801d38:	74 2e                	je     801d68 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801d3a:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801d41:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801d47:	8b 49 48             	mov    0x48(%ecx),%ecx
  801d4a:	83 ec 0c             	sub    $0xc,%esp
  801d4d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d53:	52                   	push   %edx
  801d54:	50                   	push   %eax
  801d55:	56                   	push   %esi
  801d56:	50                   	push   %eax
  801d57:	51                   	push   %ecx
  801d58:	e8 1f ef ff ff       	call   800c7c <sys_page_map>
					if (r < 0)
  801d5d:	83 c4 20             	add    $0x20,%esp
  801d60:	85 c0                	test   %eax,%eax
  801d62:	0f 88 ae 00 00 00    	js     801e16 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801d68:	83 c3 01             	add    $0x1,%ebx
  801d6b:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801d71:	75 94                	jne    801d07 <spawn+0x40e>
  801d73:	e9 b3 00 00 00       	jmp    801e2b <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d78:	50                   	push   %eax
  801d79:	68 46 2e 80 00       	push   $0x802e46
  801d7e:	68 86 00 00 00       	push   $0x86
  801d83:	68 1d 2e 80 00       	push   $0x802e1d
  801d88:	e8 4b e4 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d8d:	83 ec 08             	sub    $0x8,%esp
  801d90:	6a 02                	push   $0x2
  801d92:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d98:	e8 63 ef ff ff       	call   800d00 <sys_env_set_status>
  801d9d:	83 c4 10             	add    $0x10,%esp
  801da0:	85 c0                	test   %eax,%eax
  801da2:	79 2b                	jns    801dcf <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801da4:	50                   	push   %eax
  801da5:	68 60 2e 80 00       	push   $0x802e60
  801daa:	68 89 00 00 00       	push   $0x89
  801daf:	68 1d 2e 80 00       	push   $0x802e1d
  801db4:	e8 1f e4 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801db9:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801dbf:	e9 a8 00 00 00       	jmp    801e6c <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801dc4:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801dca:	e9 9d 00 00 00       	jmp    801e6c <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801dcf:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801dd5:	e9 92 00 00 00       	jmp    801e6c <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801dda:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801ddf:	e9 88 00 00 00       	jmp    801e6c <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	e9 81 00 00 00       	jmp    801e6c <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801deb:	89 c3                	mov    %eax,%ebx
  801ded:	eb 06                	jmp    801df5 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801def:	89 c3                	mov    %eax,%ebx
  801df1:	eb 02                	jmp    801df5 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801df3:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801df5:	83 ec 0c             	sub    $0xc,%esp
  801df8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dfe:	e8 b7 ed ff ff       	call   800bba <sys_env_destroy>
	close(fd);
  801e03:	83 c4 04             	add    $0x4,%esp
  801e06:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e0c:	e8 8a f4 ff ff       	call   80129b <close>
	return r;
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	eb 56                	jmp    801e6c <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e16:	50                   	push   %eax
  801e17:	68 77 2e 80 00       	push   $0x802e77
  801e1c:	68 82 00 00 00       	push   $0x82
  801e21:	68 1d 2e 80 00       	push   $0x802e1d
  801e26:	e8 ad e3 ff ff       	call   8001d8 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e2b:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e32:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e35:	83 ec 08             	sub    $0x8,%esp
  801e38:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e3e:	50                   	push   %eax
  801e3f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e45:	e8 f8 ee ff ff       	call   800d42 <sys_env_set_trapframe>
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	0f 89 38 ff ff ff    	jns    801d8d <spawn+0x494>
  801e55:	e9 1e ff ff ff       	jmp    801d78 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e5a:	83 ec 08             	sub    $0x8,%esp
  801e5d:	68 00 00 40 00       	push   $0x400000
  801e62:	6a 00                	push   $0x0
  801e64:	e8 55 ee ff ff       	call   800cbe <sys_page_unmap>
  801e69:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e6c:	89 d8                	mov    %ebx,%eax
  801e6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e71:	5b                   	pop    %ebx
  801e72:	5e                   	pop    %esi
  801e73:	5f                   	pop    %edi
  801e74:	5d                   	pop    %ebp
  801e75:	c3                   	ret    

00801e76 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	56                   	push   %esi
  801e7a:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e7b:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e7e:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e83:	eb 03                	jmp    801e88 <spawnl+0x12>
		argc++;
  801e85:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e88:	83 c2 04             	add    $0x4,%edx
  801e8b:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e8f:	75 f4                	jne    801e85 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e91:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e98:	83 e2 f0             	and    $0xfffffff0,%edx
  801e9b:	29 d4                	sub    %edx,%esp
  801e9d:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ea1:	c1 ea 02             	shr    $0x2,%edx
  801ea4:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801eab:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eb0:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801eb7:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ebe:	00 
  801ebf:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec6:	eb 0a                	jmp    801ed2 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ec8:	83 c0 01             	add    $0x1,%eax
  801ecb:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ecf:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ed2:	39 d0                	cmp    %edx,%eax
  801ed4:	75 f2                	jne    801ec8 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801ed6:	83 ec 08             	sub    $0x8,%esp
  801ed9:	56                   	push   %esi
  801eda:	ff 75 08             	pushl  0x8(%ebp)
  801edd:	e8 17 fa ff ff       	call   8018f9 <spawn>
}
  801ee2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee5:	5b                   	pop    %ebx
  801ee6:	5e                   	pop    %esi
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	56                   	push   %esi
  801eed:	53                   	push   %ebx
  801eee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	ff 75 08             	pushl  0x8(%ebp)
  801ef7:	e8 0f f2 ff ff       	call   80110b <fd2data>
  801efc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801efe:	83 c4 08             	add    $0x8,%esp
  801f01:	68 b8 2e 80 00       	push   $0x802eb8
  801f06:	53                   	push   %ebx
  801f07:	e8 2a e9 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f0c:	8b 46 04             	mov    0x4(%esi),%eax
  801f0f:	2b 06                	sub    (%esi),%eax
  801f11:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f17:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f1e:	00 00 00 
	stat->st_dev = &devpipe;
  801f21:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801f28:	30 80 00 
	return 0;
}
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	53                   	push   %ebx
  801f3b:	83 ec 0c             	sub    $0xc,%esp
  801f3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f41:	53                   	push   %ebx
  801f42:	6a 00                	push   $0x0
  801f44:	e8 75 ed ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f49:	89 1c 24             	mov    %ebx,(%esp)
  801f4c:	e8 ba f1 ff ff       	call   80110b <fd2data>
  801f51:	83 c4 08             	add    $0x8,%esp
  801f54:	50                   	push   %eax
  801f55:	6a 00                	push   $0x0
  801f57:	e8 62 ed ff ff       	call   800cbe <sys_page_unmap>
}
  801f5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    

00801f61 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	57                   	push   %edi
  801f65:	56                   	push   %esi
  801f66:	53                   	push   %ebx
  801f67:	83 ec 1c             	sub    $0x1c,%esp
  801f6a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f6d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f6f:	a1 04 40 80 00       	mov    0x804004,%eax
  801f74:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f77:	83 ec 0c             	sub    $0xc,%esp
  801f7a:	ff 75 e0             	pushl  -0x20(%ebp)
  801f7d:	e8 f4 05 00 00       	call   802576 <pageref>
  801f82:	89 c3                	mov    %eax,%ebx
  801f84:	89 3c 24             	mov    %edi,(%esp)
  801f87:	e8 ea 05 00 00       	call   802576 <pageref>
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	39 c3                	cmp    %eax,%ebx
  801f91:	0f 94 c1             	sete   %cl
  801f94:	0f b6 c9             	movzbl %cl,%ecx
  801f97:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f9a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fa0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fa3:	39 ce                	cmp    %ecx,%esi
  801fa5:	74 1b                	je     801fc2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fa7:	39 c3                	cmp    %eax,%ebx
  801fa9:	75 c4                	jne    801f6f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fab:	8b 42 58             	mov    0x58(%edx),%eax
  801fae:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fb1:	50                   	push   %eax
  801fb2:	56                   	push   %esi
  801fb3:	68 bf 2e 80 00       	push   $0x802ebf
  801fb8:	e8 f4 e2 ff ff       	call   8002b1 <cprintf>
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	eb ad                	jmp    801f6f <_pipeisclosed+0xe>
	}
}
  801fc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc8:	5b                   	pop    %ebx
  801fc9:	5e                   	pop    %esi
  801fca:	5f                   	pop    %edi
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    

00801fcd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	57                   	push   %edi
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	83 ec 28             	sub    $0x28,%esp
  801fd6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fd9:	56                   	push   %esi
  801fda:	e8 2c f1 ff ff       	call   80110b <fd2data>
  801fdf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	bf 00 00 00 00       	mov    $0x0,%edi
  801fe9:	eb 4b                	jmp    802036 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801feb:	89 da                	mov    %ebx,%edx
  801fed:	89 f0                	mov    %esi,%eax
  801fef:	e8 6d ff ff ff       	call   801f61 <_pipeisclosed>
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	75 48                	jne    802040 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ff8:	e8 1d ec ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ffd:	8b 43 04             	mov    0x4(%ebx),%eax
  802000:	8b 0b                	mov    (%ebx),%ecx
  802002:	8d 51 20             	lea    0x20(%ecx),%edx
  802005:	39 d0                	cmp    %edx,%eax
  802007:	73 e2                	jae    801feb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802009:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80200c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802010:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802013:	89 c2                	mov    %eax,%edx
  802015:	c1 fa 1f             	sar    $0x1f,%edx
  802018:	89 d1                	mov    %edx,%ecx
  80201a:	c1 e9 1b             	shr    $0x1b,%ecx
  80201d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802020:	83 e2 1f             	and    $0x1f,%edx
  802023:	29 ca                	sub    %ecx,%edx
  802025:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802029:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80202d:	83 c0 01             	add    $0x1,%eax
  802030:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802033:	83 c7 01             	add    $0x1,%edi
  802036:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802039:	75 c2                	jne    801ffd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80203b:	8b 45 10             	mov    0x10(%ebp),%eax
  80203e:	eb 05                	jmp    802045 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802040:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802045:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802048:	5b                   	pop    %ebx
  802049:	5e                   	pop    %esi
  80204a:	5f                   	pop    %edi
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    

0080204d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	57                   	push   %edi
  802051:	56                   	push   %esi
  802052:	53                   	push   %ebx
  802053:	83 ec 18             	sub    $0x18,%esp
  802056:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802059:	57                   	push   %edi
  80205a:	e8 ac f0 ff ff       	call   80110b <fd2data>
  80205f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802061:	83 c4 10             	add    $0x10,%esp
  802064:	bb 00 00 00 00       	mov    $0x0,%ebx
  802069:	eb 3d                	jmp    8020a8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80206b:	85 db                	test   %ebx,%ebx
  80206d:	74 04                	je     802073 <devpipe_read+0x26>
				return i;
  80206f:	89 d8                	mov    %ebx,%eax
  802071:	eb 44                	jmp    8020b7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802073:	89 f2                	mov    %esi,%edx
  802075:	89 f8                	mov    %edi,%eax
  802077:	e8 e5 fe ff ff       	call   801f61 <_pipeisclosed>
  80207c:	85 c0                	test   %eax,%eax
  80207e:	75 32                	jne    8020b2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802080:	e8 95 eb ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802085:	8b 06                	mov    (%esi),%eax
  802087:	3b 46 04             	cmp    0x4(%esi),%eax
  80208a:	74 df                	je     80206b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80208c:	99                   	cltd   
  80208d:	c1 ea 1b             	shr    $0x1b,%edx
  802090:	01 d0                	add    %edx,%eax
  802092:	83 e0 1f             	and    $0x1f,%eax
  802095:	29 d0                	sub    %edx,%eax
  802097:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80209c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80209f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020a2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020a5:	83 c3 01             	add    $0x1,%ebx
  8020a8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020ab:	75 d8                	jne    802085 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b0:	eb 05                	jmp    8020b7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020b2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ba:	5b                   	pop    %ebx
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    

008020bf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ca:	50                   	push   %eax
  8020cb:	e8 52 f0 ff ff       	call   801122 <fd_alloc>
  8020d0:	83 c4 10             	add    $0x10,%esp
  8020d3:	89 c2                	mov    %eax,%edx
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	0f 88 2c 01 00 00    	js     802209 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020dd:	83 ec 04             	sub    $0x4,%esp
  8020e0:	68 07 04 00 00       	push   $0x407
  8020e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e8:	6a 00                	push   $0x0
  8020ea:	e8 4a eb ff ff       	call   800c39 <sys_page_alloc>
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	89 c2                	mov    %eax,%edx
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	0f 88 0d 01 00 00    	js     802209 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020fc:	83 ec 0c             	sub    $0xc,%esp
  8020ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802102:	50                   	push   %eax
  802103:	e8 1a f0 ff ff       	call   801122 <fd_alloc>
  802108:	89 c3                	mov    %eax,%ebx
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	85 c0                	test   %eax,%eax
  80210f:	0f 88 e2 00 00 00    	js     8021f7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802115:	83 ec 04             	sub    $0x4,%esp
  802118:	68 07 04 00 00       	push   $0x407
  80211d:	ff 75 f0             	pushl  -0x10(%ebp)
  802120:	6a 00                	push   $0x0
  802122:	e8 12 eb ff ff       	call   800c39 <sys_page_alloc>
  802127:	89 c3                	mov    %eax,%ebx
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	85 c0                	test   %eax,%eax
  80212e:	0f 88 c3 00 00 00    	js     8021f7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802134:	83 ec 0c             	sub    $0xc,%esp
  802137:	ff 75 f4             	pushl  -0xc(%ebp)
  80213a:	e8 cc ef ff ff       	call   80110b <fd2data>
  80213f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802141:	83 c4 0c             	add    $0xc,%esp
  802144:	68 07 04 00 00       	push   $0x407
  802149:	50                   	push   %eax
  80214a:	6a 00                	push   $0x0
  80214c:	e8 e8 ea ff ff       	call   800c39 <sys_page_alloc>
  802151:	89 c3                	mov    %eax,%ebx
  802153:	83 c4 10             	add    $0x10,%esp
  802156:	85 c0                	test   %eax,%eax
  802158:	0f 88 89 00 00 00    	js     8021e7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80215e:	83 ec 0c             	sub    $0xc,%esp
  802161:	ff 75 f0             	pushl  -0x10(%ebp)
  802164:	e8 a2 ef ff ff       	call   80110b <fd2data>
  802169:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802170:	50                   	push   %eax
  802171:	6a 00                	push   $0x0
  802173:	56                   	push   %esi
  802174:	6a 00                	push   $0x0
  802176:	e8 01 eb ff ff       	call   800c7c <sys_page_map>
  80217b:	89 c3                	mov    %eax,%ebx
  80217d:	83 c4 20             	add    $0x20,%esp
  802180:	85 c0                	test   %eax,%eax
  802182:	78 55                	js     8021d9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802184:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80218a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80218f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802192:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802199:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80219f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021ae:	83 ec 0c             	sub    $0xc,%esp
  8021b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b4:	e8 42 ef ff ff       	call   8010fb <fd2num>
  8021b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021bc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021be:	83 c4 04             	add    $0x4,%esp
  8021c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8021c4:	e8 32 ef ff ff       	call   8010fb <fd2num>
  8021c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021cc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021cf:	83 c4 10             	add    $0x10,%esp
  8021d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8021d7:	eb 30                	jmp    802209 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021d9:	83 ec 08             	sub    $0x8,%esp
  8021dc:	56                   	push   %esi
  8021dd:	6a 00                	push   $0x0
  8021df:	e8 da ea ff ff       	call   800cbe <sys_page_unmap>
  8021e4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021e7:	83 ec 08             	sub    $0x8,%esp
  8021ea:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ed:	6a 00                	push   $0x0
  8021ef:	e8 ca ea ff ff       	call   800cbe <sys_page_unmap>
  8021f4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021f7:	83 ec 08             	sub    $0x8,%esp
  8021fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8021fd:	6a 00                	push   $0x0
  8021ff:	e8 ba ea ff ff       	call   800cbe <sys_page_unmap>
  802204:	83 c4 10             	add    $0x10,%esp
  802207:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802209:	89 d0                	mov    %edx,%eax
  80220b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80220e:	5b                   	pop    %ebx
  80220f:	5e                   	pop    %esi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    

00802212 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802212:	55                   	push   %ebp
  802213:	89 e5                	mov    %esp,%ebp
  802215:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80221b:	50                   	push   %eax
  80221c:	ff 75 08             	pushl  0x8(%ebp)
  80221f:	e8 4d ef ff ff       	call   801171 <fd_lookup>
  802224:	83 c4 10             	add    $0x10,%esp
  802227:	85 c0                	test   %eax,%eax
  802229:	78 18                	js     802243 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80222b:	83 ec 0c             	sub    $0xc,%esp
  80222e:	ff 75 f4             	pushl  -0xc(%ebp)
  802231:	e8 d5 ee ff ff       	call   80110b <fd2data>
	return _pipeisclosed(fd, p);
  802236:	89 c2                	mov    %eax,%edx
  802238:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223b:	e8 21 fd ff ff       	call   801f61 <_pipeisclosed>
  802240:	83 c4 10             	add    $0x10,%esp
}
  802243:	c9                   	leave  
  802244:	c3                   	ret    

00802245 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	56                   	push   %esi
  802249:	53                   	push   %ebx
  80224a:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80224d:	85 f6                	test   %esi,%esi
  80224f:	75 16                	jne    802267 <wait+0x22>
  802251:	68 d7 2e 80 00       	push   $0x802ed7
  802256:	68 d7 2d 80 00       	push   $0x802dd7
  80225b:	6a 09                	push   $0x9
  80225d:	68 e2 2e 80 00       	push   $0x802ee2
  802262:	e8 71 df ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  802267:	89 f3                	mov    %esi,%ebx
  802269:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80226f:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802272:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802278:	eb 05                	jmp    80227f <wait+0x3a>
		sys_yield();
  80227a:	e8 9b e9 ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80227f:	8b 43 48             	mov    0x48(%ebx),%eax
  802282:	39 c6                	cmp    %eax,%esi
  802284:	75 07                	jne    80228d <wait+0x48>
  802286:	8b 43 54             	mov    0x54(%ebx),%eax
  802289:	85 c0                	test   %eax,%eax
  80228b:	75 ed                	jne    80227a <wait+0x35>
		sys_yield();
}
  80228d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802290:	5b                   	pop    %ebx
  802291:	5e                   	pop    %esi
  802292:	5d                   	pop    %ebp
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
  8022a4:	68 ed 2e 80 00       	push   $0x802eed
  8022a9:	ff 75 0c             	pushl  0xc(%ebp)
  8022ac:	e8 85 e5 ff ff       	call   800836 <strcpy>
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
  8022ea:	e8 d9 e6 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  8022ef:	83 c4 08             	add    $0x8,%esp
  8022f2:	53                   	push   %ebx
  8022f3:	57                   	push   %edi
  8022f4:	e8 84 e8 ff ff       	call   800b7d <sys_cputs>
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
  802320:	e8 f5 e8 ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802325:	e8 71 e8 ff ff       	call   800b9b <sys_cgetc>
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
  80235c:	e8 1c e8 ff ff       	call   800b7d <sys_cputs>
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
  802374:	e8 5e f0 ff ff       	call   8013d7 <read>
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
  80239e:	e8 ce ed ff ff       	call   801171 <fd_lookup>
  8023a3:	83 c4 10             	add    $0x10,%esp
  8023a6:	85 c0                	test   %eax,%eax
  8023a8:	78 11                	js     8023bb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ad:	8b 15 44 30 80 00    	mov    0x803044,%edx
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
  8023c7:	e8 56 ed ff ff       	call   801122 <fd_alloc>
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
  8023e2:	e8 52 e8 ff ff       	call   800c39 <sys_page_alloc>
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
  8023f0:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802405:	83 ec 0c             	sub    $0xc,%esp
  802408:	50                   	push   %eax
  802409:	e8 ed ec ff ff       	call   8010fb <fd2num>
  80240e:	89 c2                	mov    %eax,%edx
  802410:	83 c4 10             	add    $0x10,%esp
}
  802413:	89 d0                	mov    %edx,%eax
  802415:	c9                   	leave  
  802416:	c3                   	ret    

00802417 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802417:	55                   	push   %ebp
  802418:	89 e5                	mov    %esp,%ebp
  80241a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80241d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802424:	75 2e                	jne    802454 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802426:	e8 d0 e7 ff ff       	call   800bfb <sys_getenvid>
  80242b:	83 ec 04             	sub    $0x4,%esp
  80242e:	68 07 0e 00 00       	push   $0xe07
  802433:	68 00 f0 bf ee       	push   $0xeebff000
  802438:	50                   	push   %eax
  802439:	e8 fb e7 ff ff       	call   800c39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80243e:	e8 b8 e7 ff ff       	call   800bfb <sys_getenvid>
  802443:	83 c4 08             	add    $0x8,%esp
  802446:	68 5e 24 80 00       	push   $0x80245e
  80244b:	50                   	push   %eax
  80244c:	e8 33 e9 ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
  802451:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802454:	8b 45 08             	mov    0x8(%ebp),%eax
  802457:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80245c:	c9                   	leave  
  80245d:	c3                   	ret    

0080245e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80245e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80245f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802464:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802466:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802469:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80246d:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802471:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802474:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802477:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802478:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80247b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80247c:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80247d:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802481:	c3                   	ret    

00802482 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802482:	55                   	push   %ebp
  802483:	89 e5                	mov    %esp,%ebp
  802485:	56                   	push   %esi
  802486:	53                   	push   %ebx
  802487:	8b 75 08             	mov    0x8(%ebp),%esi
  80248a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80248d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802490:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802492:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802497:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80249a:	83 ec 0c             	sub    $0xc,%esp
  80249d:	50                   	push   %eax
  80249e:	e8 46 e9 ff ff       	call   800de9 <sys_ipc_recv>

	if (from_env_store != NULL)
  8024a3:	83 c4 10             	add    $0x10,%esp
  8024a6:	85 f6                	test   %esi,%esi
  8024a8:	74 14                	je     8024be <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8024aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8024af:	85 c0                	test   %eax,%eax
  8024b1:	78 09                	js     8024bc <ipc_recv+0x3a>
  8024b3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8024b9:	8b 52 74             	mov    0x74(%edx),%edx
  8024bc:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8024be:	85 db                	test   %ebx,%ebx
  8024c0:	74 14                	je     8024d6 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8024c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8024c7:	85 c0                	test   %eax,%eax
  8024c9:	78 09                	js     8024d4 <ipc_recv+0x52>
  8024cb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8024d1:	8b 52 78             	mov    0x78(%edx),%edx
  8024d4:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8024d6:	85 c0                	test   %eax,%eax
  8024d8:	78 08                	js     8024e2 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8024da:	a1 04 40 80 00       	mov    0x804004,%eax
  8024df:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024e5:	5b                   	pop    %ebx
  8024e6:	5e                   	pop    %esi
  8024e7:	5d                   	pop    %ebp
  8024e8:	c3                   	ret    

008024e9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024e9:	55                   	push   %ebp
  8024ea:	89 e5                	mov    %esp,%ebp
  8024ec:	57                   	push   %edi
  8024ed:	56                   	push   %esi
  8024ee:	53                   	push   %ebx
  8024ef:	83 ec 0c             	sub    $0xc,%esp
  8024f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8024fb:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8024fd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802502:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802505:	ff 75 14             	pushl  0x14(%ebp)
  802508:	53                   	push   %ebx
  802509:	56                   	push   %esi
  80250a:	57                   	push   %edi
  80250b:	e8 b6 e8 ff ff       	call   800dc6 <sys_ipc_try_send>

		if (err < 0) {
  802510:	83 c4 10             	add    $0x10,%esp
  802513:	85 c0                	test   %eax,%eax
  802515:	79 1e                	jns    802535 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802517:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80251a:	75 07                	jne    802523 <ipc_send+0x3a>
				sys_yield();
  80251c:	e8 f9 e6 ff ff       	call   800c1a <sys_yield>
  802521:	eb e2                	jmp    802505 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802523:	50                   	push   %eax
  802524:	68 f9 2e 80 00       	push   $0x802ef9
  802529:	6a 49                	push   $0x49
  80252b:	68 06 2f 80 00       	push   $0x802f06
  802530:	e8 a3 dc ff ff       	call   8001d8 <_panic>
		}

	} while (err < 0);

}
  802535:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802538:	5b                   	pop    %ebx
  802539:	5e                   	pop    %esi
  80253a:	5f                   	pop    %edi
  80253b:	5d                   	pop    %ebp
  80253c:	c3                   	ret    

0080253d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80253d:	55                   	push   %ebp
  80253e:	89 e5                	mov    %esp,%ebp
  802540:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802543:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802548:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80254b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802551:	8b 52 50             	mov    0x50(%edx),%edx
  802554:	39 ca                	cmp    %ecx,%edx
  802556:	75 0d                	jne    802565 <ipc_find_env+0x28>
			return envs[i].env_id;
  802558:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80255b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802560:	8b 40 48             	mov    0x48(%eax),%eax
  802563:	eb 0f                	jmp    802574 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802565:	83 c0 01             	add    $0x1,%eax
  802568:	3d 00 04 00 00       	cmp    $0x400,%eax
  80256d:	75 d9                	jne    802548 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80256f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802574:	5d                   	pop    %ebp
  802575:	c3                   	ret    

00802576 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802576:	55                   	push   %ebp
  802577:	89 e5                	mov    %esp,%ebp
  802579:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80257c:	89 d0                	mov    %edx,%eax
  80257e:	c1 e8 16             	shr    $0x16,%eax
  802581:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802588:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80258d:	f6 c1 01             	test   $0x1,%cl
  802590:	74 1d                	je     8025af <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802592:	c1 ea 0c             	shr    $0xc,%edx
  802595:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80259c:	f6 c2 01             	test   $0x1,%dl
  80259f:	74 0e                	je     8025af <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025a1:	c1 ea 0c             	shr    $0xc,%edx
  8025a4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025ab:	ef 
  8025ac:	0f b7 c0             	movzwl %ax,%eax
}
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    
  8025b1:	66 90                	xchg   %ax,%ax
  8025b3:	66 90                	xchg   %ax,%ax
  8025b5:	66 90                	xchg   %ax,%ax
  8025b7:	66 90                	xchg   %ax,%ax
  8025b9:	66 90                	xchg   %ax,%ax
  8025bb:	66 90                	xchg   %ax,%ax
  8025bd:	66 90                	xchg   %ax,%ax
  8025bf:	90                   	nop

008025c0 <__udivdi3>:
  8025c0:	55                   	push   %ebp
  8025c1:	57                   	push   %edi
  8025c2:	56                   	push   %esi
  8025c3:	53                   	push   %ebx
  8025c4:	83 ec 1c             	sub    $0x1c,%esp
  8025c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025d7:	85 f6                	test   %esi,%esi
  8025d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025dd:	89 ca                	mov    %ecx,%edx
  8025df:	89 f8                	mov    %edi,%eax
  8025e1:	75 3d                	jne    802620 <__udivdi3+0x60>
  8025e3:	39 cf                	cmp    %ecx,%edi
  8025e5:	0f 87 c5 00 00 00    	ja     8026b0 <__udivdi3+0xf0>
  8025eb:	85 ff                	test   %edi,%edi
  8025ed:	89 fd                	mov    %edi,%ebp
  8025ef:	75 0b                	jne    8025fc <__udivdi3+0x3c>
  8025f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025f6:	31 d2                	xor    %edx,%edx
  8025f8:	f7 f7                	div    %edi
  8025fa:	89 c5                	mov    %eax,%ebp
  8025fc:	89 c8                	mov    %ecx,%eax
  8025fe:	31 d2                	xor    %edx,%edx
  802600:	f7 f5                	div    %ebp
  802602:	89 c1                	mov    %eax,%ecx
  802604:	89 d8                	mov    %ebx,%eax
  802606:	89 cf                	mov    %ecx,%edi
  802608:	f7 f5                	div    %ebp
  80260a:	89 c3                	mov    %eax,%ebx
  80260c:	89 d8                	mov    %ebx,%eax
  80260e:	89 fa                	mov    %edi,%edx
  802610:	83 c4 1c             	add    $0x1c,%esp
  802613:	5b                   	pop    %ebx
  802614:	5e                   	pop    %esi
  802615:	5f                   	pop    %edi
  802616:	5d                   	pop    %ebp
  802617:	c3                   	ret    
  802618:	90                   	nop
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	39 ce                	cmp    %ecx,%esi
  802622:	77 74                	ja     802698 <__udivdi3+0xd8>
  802624:	0f bd fe             	bsr    %esi,%edi
  802627:	83 f7 1f             	xor    $0x1f,%edi
  80262a:	0f 84 98 00 00 00    	je     8026c8 <__udivdi3+0x108>
  802630:	bb 20 00 00 00       	mov    $0x20,%ebx
  802635:	89 f9                	mov    %edi,%ecx
  802637:	89 c5                	mov    %eax,%ebp
  802639:	29 fb                	sub    %edi,%ebx
  80263b:	d3 e6                	shl    %cl,%esi
  80263d:	89 d9                	mov    %ebx,%ecx
  80263f:	d3 ed                	shr    %cl,%ebp
  802641:	89 f9                	mov    %edi,%ecx
  802643:	d3 e0                	shl    %cl,%eax
  802645:	09 ee                	or     %ebp,%esi
  802647:	89 d9                	mov    %ebx,%ecx
  802649:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80264d:	89 d5                	mov    %edx,%ebp
  80264f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802653:	d3 ed                	shr    %cl,%ebp
  802655:	89 f9                	mov    %edi,%ecx
  802657:	d3 e2                	shl    %cl,%edx
  802659:	89 d9                	mov    %ebx,%ecx
  80265b:	d3 e8                	shr    %cl,%eax
  80265d:	09 c2                	or     %eax,%edx
  80265f:	89 d0                	mov    %edx,%eax
  802661:	89 ea                	mov    %ebp,%edx
  802663:	f7 f6                	div    %esi
  802665:	89 d5                	mov    %edx,%ebp
  802667:	89 c3                	mov    %eax,%ebx
  802669:	f7 64 24 0c          	mull   0xc(%esp)
  80266d:	39 d5                	cmp    %edx,%ebp
  80266f:	72 10                	jb     802681 <__udivdi3+0xc1>
  802671:	8b 74 24 08          	mov    0x8(%esp),%esi
  802675:	89 f9                	mov    %edi,%ecx
  802677:	d3 e6                	shl    %cl,%esi
  802679:	39 c6                	cmp    %eax,%esi
  80267b:	73 07                	jae    802684 <__udivdi3+0xc4>
  80267d:	39 d5                	cmp    %edx,%ebp
  80267f:	75 03                	jne    802684 <__udivdi3+0xc4>
  802681:	83 eb 01             	sub    $0x1,%ebx
  802684:	31 ff                	xor    %edi,%edi
  802686:	89 d8                	mov    %ebx,%eax
  802688:	89 fa                	mov    %edi,%edx
  80268a:	83 c4 1c             	add    $0x1c,%esp
  80268d:	5b                   	pop    %ebx
  80268e:	5e                   	pop    %esi
  80268f:	5f                   	pop    %edi
  802690:	5d                   	pop    %ebp
  802691:	c3                   	ret    
  802692:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802698:	31 ff                	xor    %edi,%edi
  80269a:	31 db                	xor    %ebx,%ebx
  80269c:	89 d8                	mov    %ebx,%eax
  80269e:	89 fa                	mov    %edi,%edx
  8026a0:	83 c4 1c             	add    $0x1c,%esp
  8026a3:	5b                   	pop    %ebx
  8026a4:	5e                   	pop    %esi
  8026a5:	5f                   	pop    %edi
  8026a6:	5d                   	pop    %ebp
  8026a7:	c3                   	ret    
  8026a8:	90                   	nop
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	89 d8                	mov    %ebx,%eax
  8026b2:	f7 f7                	div    %edi
  8026b4:	31 ff                	xor    %edi,%edi
  8026b6:	89 c3                	mov    %eax,%ebx
  8026b8:	89 d8                	mov    %ebx,%eax
  8026ba:	89 fa                	mov    %edi,%edx
  8026bc:	83 c4 1c             	add    $0x1c,%esp
  8026bf:	5b                   	pop    %ebx
  8026c0:	5e                   	pop    %esi
  8026c1:	5f                   	pop    %edi
  8026c2:	5d                   	pop    %ebp
  8026c3:	c3                   	ret    
  8026c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c8:	39 ce                	cmp    %ecx,%esi
  8026ca:	72 0c                	jb     8026d8 <__udivdi3+0x118>
  8026cc:	31 db                	xor    %ebx,%ebx
  8026ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026d2:	0f 87 34 ff ff ff    	ja     80260c <__udivdi3+0x4c>
  8026d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026dd:	e9 2a ff ff ff       	jmp    80260c <__udivdi3+0x4c>
  8026e2:	66 90                	xchg   %ax,%ax
  8026e4:	66 90                	xchg   %ax,%ax
  8026e6:	66 90                	xchg   %ax,%ax
  8026e8:	66 90                	xchg   %ax,%ax
  8026ea:	66 90                	xchg   %ax,%ax
  8026ec:	66 90                	xchg   %ax,%ax
  8026ee:	66 90                	xchg   %ax,%ax

008026f0 <__umoddi3>:
  8026f0:	55                   	push   %ebp
  8026f1:	57                   	push   %edi
  8026f2:	56                   	push   %esi
  8026f3:	53                   	push   %ebx
  8026f4:	83 ec 1c             	sub    $0x1c,%esp
  8026f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802703:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802707:	85 d2                	test   %edx,%edx
  802709:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80270d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802711:	89 f3                	mov    %esi,%ebx
  802713:	89 3c 24             	mov    %edi,(%esp)
  802716:	89 74 24 04          	mov    %esi,0x4(%esp)
  80271a:	75 1c                	jne    802738 <__umoddi3+0x48>
  80271c:	39 f7                	cmp    %esi,%edi
  80271e:	76 50                	jbe    802770 <__umoddi3+0x80>
  802720:	89 c8                	mov    %ecx,%eax
  802722:	89 f2                	mov    %esi,%edx
  802724:	f7 f7                	div    %edi
  802726:	89 d0                	mov    %edx,%eax
  802728:	31 d2                	xor    %edx,%edx
  80272a:	83 c4 1c             	add    $0x1c,%esp
  80272d:	5b                   	pop    %ebx
  80272e:	5e                   	pop    %esi
  80272f:	5f                   	pop    %edi
  802730:	5d                   	pop    %ebp
  802731:	c3                   	ret    
  802732:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802738:	39 f2                	cmp    %esi,%edx
  80273a:	89 d0                	mov    %edx,%eax
  80273c:	77 52                	ja     802790 <__umoddi3+0xa0>
  80273e:	0f bd ea             	bsr    %edx,%ebp
  802741:	83 f5 1f             	xor    $0x1f,%ebp
  802744:	75 5a                	jne    8027a0 <__umoddi3+0xb0>
  802746:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80274a:	0f 82 e0 00 00 00    	jb     802830 <__umoddi3+0x140>
  802750:	39 0c 24             	cmp    %ecx,(%esp)
  802753:	0f 86 d7 00 00 00    	jbe    802830 <__umoddi3+0x140>
  802759:	8b 44 24 08          	mov    0x8(%esp),%eax
  80275d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802761:	83 c4 1c             	add    $0x1c,%esp
  802764:	5b                   	pop    %ebx
  802765:	5e                   	pop    %esi
  802766:	5f                   	pop    %edi
  802767:	5d                   	pop    %ebp
  802768:	c3                   	ret    
  802769:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802770:	85 ff                	test   %edi,%edi
  802772:	89 fd                	mov    %edi,%ebp
  802774:	75 0b                	jne    802781 <__umoddi3+0x91>
  802776:	b8 01 00 00 00       	mov    $0x1,%eax
  80277b:	31 d2                	xor    %edx,%edx
  80277d:	f7 f7                	div    %edi
  80277f:	89 c5                	mov    %eax,%ebp
  802781:	89 f0                	mov    %esi,%eax
  802783:	31 d2                	xor    %edx,%edx
  802785:	f7 f5                	div    %ebp
  802787:	89 c8                	mov    %ecx,%eax
  802789:	f7 f5                	div    %ebp
  80278b:	89 d0                	mov    %edx,%eax
  80278d:	eb 99                	jmp    802728 <__umoddi3+0x38>
  80278f:	90                   	nop
  802790:	89 c8                	mov    %ecx,%eax
  802792:	89 f2                	mov    %esi,%edx
  802794:	83 c4 1c             	add    $0x1c,%esp
  802797:	5b                   	pop    %ebx
  802798:	5e                   	pop    %esi
  802799:	5f                   	pop    %edi
  80279a:	5d                   	pop    %ebp
  80279b:	c3                   	ret    
  80279c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	8b 34 24             	mov    (%esp),%esi
  8027a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8027a8:	89 e9                	mov    %ebp,%ecx
  8027aa:	29 ef                	sub    %ebp,%edi
  8027ac:	d3 e0                	shl    %cl,%eax
  8027ae:	89 f9                	mov    %edi,%ecx
  8027b0:	89 f2                	mov    %esi,%edx
  8027b2:	d3 ea                	shr    %cl,%edx
  8027b4:	89 e9                	mov    %ebp,%ecx
  8027b6:	09 c2                	or     %eax,%edx
  8027b8:	89 d8                	mov    %ebx,%eax
  8027ba:	89 14 24             	mov    %edx,(%esp)
  8027bd:	89 f2                	mov    %esi,%edx
  8027bf:	d3 e2                	shl    %cl,%edx
  8027c1:	89 f9                	mov    %edi,%ecx
  8027c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027cb:	d3 e8                	shr    %cl,%eax
  8027cd:	89 e9                	mov    %ebp,%ecx
  8027cf:	89 c6                	mov    %eax,%esi
  8027d1:	d3 e3                	shl    %cl,%ebx
  8027d3:	89 f9                	mov    %edi,%ecx
  8027d5:	89 d0                	mov    %edx,%eax
  8027d7:	d3 e8                	shr    %cl,%eax
  8027d9:	89 e9                	mov    %ebp,%ecx
  8027db:	09 d8                	or     %ebx,%eax
  8027dd:	89 d3                	mov    %edx,%ebx
  8027df:	89 f2                	mov    %esi,%edx
  8027e1:	f7 34 24             	divl   (%esp)
  8027e4:	89 d6                	mov    %edx,%esi
  8027e6:	d3 e3                	shl    %cl,%ebx
  8027e8:	f7 64 24 04          	mull   0x4(%esp)
  8027ec:	39 d6                	cmp    %edx,%esi
  8027ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027f2:	89 d1                	mov    %edx,%ecx
  8027f4:	89 c3                	mov    %eax,%ebx
  8027f6:	72 08                	jb     802800 <__umoddi3+0x110>
  8027f8:	75 11                	jne    80280b <__umoddi3+0x11b>
  8027fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027fe:	73 0b                	jae    80280b <__umoddi3+0x11b>
  802800:	2b 44 24 04          	sub    0x4(%esp),%eax
  802804:	1b 14 24             	sbb    (%esp),%edx
  802807:	89 d1                	mov    %edx,%ecx
  802809:	89 c3                	mov    %eax,%ebx
  80280b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80280f:	29 da                	sub    %ebx,%edx
  802811:	19 ce                	sbb    %ecx,%esi
  802813:	89 f9                	mov    %edi,%ecx
  802815:	89 f0                	mov    %esi,%eax
  802817:	d3 e0                	shl    %cl,%eax
  802819:	89 e9                	mov    %ebp,%ecx
  80281b:	d3 ea                	shr    %cl,%edx
  80281d:	89 e9                	mov    %ebp,%ecx
  80281f:	d3 ee                	shr    %cl,%esi
  802821:	09 d0                	or     %edx,%eax
  802823:	89 f2                	mov    %esi,%edx
  802825:	83 c4 1c             	add    $0x1c,%esp
  802828:	5b                   	pop    %ebx
  802829:	5e                   	pop    %esi
  80282a:	5f                   	pop    %edi
  80282b:	5d                   	pop    %ebp
  80282c:	c3                   	ret    
  80282d:	8d 76 00             	lea    0x0(%esi),%esi
  802830:	29 f9                	sub    %edi,%ecx
  802832:	19 d6                	sbb    %edx,%esi
  802834:	89 74 24 04          	mov    %esi,0x4(%esp)
  802838:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80283c:	e9 18 ff ff ff       	jmp    802759 <__umoddi3+0x69>
