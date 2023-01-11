
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
  800039:	ff 35 00 40 80 00    	pushl  0x804000
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
  800081:	68 2c 2d 80 00       	push   $0x802d2c
  800086:	6a 13                	push   $0x13
  800088:	68 3f 2d 80 00       	push   $0x802d3f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 0f 0f 00 00       	call   800fa6 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 53 2d 80 00       	push   $0x802d53
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 3f 2d 80 00       	push   $0x802d3f
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 70 07 00 00       	call   800836 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 37 26 00 00       	call   80270e <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 26 2d 80 00       	mov    $0x802d26,%edx
  8000f4:	b8 20 2d 80 00       	mov    $0x802d20,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 5c 2d 80 00       	push   $0x802d5c
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 77 2d 80 00       	push   $0x802d77
  80010e:	68 7c 2d 80 00       	push   $0x802d7c
  800113:	68 7b 2d 80 00       	push   $0x802d7b
  800118:	e8 bb 1d 00 00       	call   801ed8 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 89 2d 80 00       	push   $0x802d89
  80012a:	6a 21                	push   $0x21
  80012c:	68 3f 2d 80 00       	push   $0x802d3f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 cf 25 00 00       	call   80270e <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 26 2d 80 00       	mov    $0x802d26,%edx
  80015c:	b8 20 2d 80 00       	mov    $0x802d20,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 93 2d 80 00       	push   $0x802d93
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
  800195:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8001c4:	e8 5f 11 00 00       	call   801328 <close_all>
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
  8001e0:	8b 35 08 40 80 00    	mov    0x804008,%esi
  8001e6:	e8 10 0a 00 00       	call   800bfb <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 d8 2d 80 00       	push   $0x802dd8
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 ad 33 80 00 	movl   $0x8033ad,(%esp)
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
  800314:	e8 67 27 00 00       	call   802a80 <__udivdi3>
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
  800357:	e8 54 28 00 00       	call   802bb0 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 fb 2d 80 00 	movsbl 0x802dfb(%eax),%eax
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
  80045b:	ff 24 85 40 2f 80 00 	jmp    *0x802f40(,%eax,4)
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
  80051f:	8b 14 85 a0 30 80 00 	mov    0x8030a0(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 13 2e 80 00       	push   $0x802e13
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
  800543:	68 8d 32 80 00       	push   $0x80328d
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
  800567:	b8 0c 2e 80 00       	mov    $0x802e0c,%eax
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
  800be2:	68 ff 30 80 00       	push   $0x8030ff
  800be7:	6a 23                	push   $0x23
  800be9:	68 1c 31 80 00       	push   $0x80311c
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
  800c63:	68 ff 30 80 00       	push   $0x8030ff
  800c68:	6a 23                	push   $0x23
  800c6a:	68 1c 31 80 00       	push   $0x80311c
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
  800ca5:	68 ff 30 80 00       	push   $0x8030ff
  800caa:	6a 23                	push   $0x23
  800cac:	68 1c 31 80 00       	push   $0x80311c
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
  800ce7:	68 ff 30 80 00       	push   $0x8030ff
  800cec:	6a 23                	push   $0x23
  800cee:	68 1c 31 80 00       	push   $0x80311c
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
  800d29:	68 ff 30 80 00       	push   $0x8030ff
  800d2e:	6a 23                	push   $0x23
  800d30:	68 1c 31 80 00       	push   $0x80311c
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
  800d6b:	68 ff 30 80 00       	push   $0x8030ff
  800d70:	6a 23                	push   $0x23
  800d72:	68 1c 31 80 00       	push   $0x80311c
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
  800dad:	68 ff 30 80 00       	push   $0x8030ff
  800db2:	6a 23                	push   $0x23
  800db4:	68 1c 31 80 00       	push   $0x80311c
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
  800e11:	68 ff 30 80 00       	push   $0x8030ff
  800e16:	6a 23                	push   $0x23
  800e18:	68 1c 31 80 00       	push   $0x80311c
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

00800e2a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	ba 00 00 00 00       	mov    $0x0,%edx
  800e35:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e3a:	89 d1                	mov    %edx,%ecx
  800e3c:	89 d3                	mov    %edx,%ebx
  800e3e:	89 d7                	mov    %edx,%edi
  800e40:	89 d6                	mov    %edx,%esi
  800e42:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e57:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	89 df                	mov    %ebx,%edi
  800e64:	89 de                	mov    %ebx,%esi
  800e66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	7e 17                	jle    800e83 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	50                   	push   %eax
  800e70:	6a 0f                	push   $0xf
  800e72:	68 ff 30 80 00       	push   $0x8030ff
  800e77:	6a 23                	push   $0x23
  800e79:	68 1c 31 80 00       	push   $0x80311c
  800e7e:	e8 55 f3 ff ff       	call   8001d8 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800e83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e99:	b8 10 00 00 00       	mov    $0x10,%eax
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	89 df                	mov    %ebx,%edi
  800ea6:	89 de                	mov    %ebx,%esi
  800ea8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	7e 17                	jle    800ec5 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eae:	83 ec 0c             	sub    $0xc,%esp
  800eb1:	50                   	push   %eax
  800eb2:	6a 10                	push   $0x10
  800eb4:	68 ff 30 80 00       	push   $0x8030ff
  800eb9:	6a 23                	push   $0x23
  800ebb:	68 1c 31 80 00       	push   $0x80311c
  800ec0:	e8 13 f3 ff ff       	call   8001d8 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800ec5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	56                   	push   %esi
  800ed1:	53                   	push   %ebx
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ed5:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800ed7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800edb:	75 25                	jne    800f02 <pgfault+0x35>
  800edd:	89 d8                	mov    %ebx,%eax
  800edf:	c1 e8 0c             	shr    $0xc,%eax
  800ee2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee9:	f6 c4 08             	test   $0x8,%ah
  800eec:	75 14                	jne    800f02 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	68 2c 31 80 00       	push   $0x80312c
  800ef6:	6a 1e                	push   $0x1e
  800ef8:	68 c0 31 80 00       	push   $0x8031c0
  800efd:	e8 d6 f2 ff ff       	call   8001d8 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f02:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f08:	e8 ee fc ff ff       	call   800bfb <sys_getenvid>
  800f0d:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800f0f:	83 ec 04             	sub    $0x4,%esp
  800f12:	6a 07                	push   $0x7
  800f14:	68 00 f0 7f 00       	push   $0x7ff000
  800f19:	50                   	push   %eax
  800f1a:	e8 1a fd ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	79 12                	jns    800f38 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f26:	50                   	push   %eax
  800f27:	68 58 31 80 00       	push   $0x803158
  800f2c:	6a 33                	push   $0x33
  800f2e:	68 c0 31 80 00       	push   $0x8031c0
  800f33:	e8 a0 f2 ff ff       	call   8001d8 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	68 00 10 00 00       	push   $0x1000
  800f40:	53                   	push   %ebx
  800f41:	68 00 f0 7f 00       	push   $0x7ff000
  800f46:	e8 e5 fa ff ff       	call   800a30 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f4b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f52:	53                   	push   %ebx
  800f53:	56                   	push   %esi
  800f54:	68 00 f0 7f 00       	push   $0x7ff000
  800f59:	56                   	push   %esi
  800f5a:	e8 1d fd ff ff       	call   800c7c <sys_page_map>
	if (r < 0)
  800f5f:	83 c4 20             	add    $0x20,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	79 12                	jns    800f78 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f66:	50                   	push   %eax
  800f67:	68 7c 31 80 00       	push   $0x80317c
  800f6c:	6a 3b                	push   $0x3b
  800f6e:	68 c0 31 80 00       	push   $0x8031c0
  800f73:	e8 60 f2 ff ff       	call   8001d8 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f78:	83 ec 08             	sub    $0x8,%esp
  800f7b:	68 00 f0 7f 00       	push   $0x7ff000
  800f80:	56                   	push   %esi
  800f81:	e8 38 fd ff ff       	call   800cbe <sys_page_unmap>
	if (r < 0)
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	79 12                	jns    800f9f <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f8d:	50                   	push   %eax
  800f8e:	68 a0 31 80 00       	push   $0x8031a0
  800f93:	6a 40                	push   $0x40
  800f95:	68 c0 31 80 00       	push   $0x8031c0
  800f9a:	e8 39 f2 ff ff       	call   8001d8 <_panic>
}
  800f9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa2:	5b                   	pop    %ebx
  800fa3:	5e                   	pop    %esi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800faf:	68 cd 0e 80 00       	push   $0x800ecd
  800fb4:	e8 27 19 00 00       	call   8028e0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb9:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbe:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	0f 88 64 01 00 00    	js     80112f <fork+0x189>
  800fcb:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800fd0:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	75 21                	jne    800ffa <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd9:	e8 1d fc ff ff       	call   800bfb <sys_getenvid>
  800fde:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800feb:	a3 08 50 80 00       	mov    %eax,0x805008
        return 0;
  800ff0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff5:	e9 3f 01 00 00       	jmp    801139 <fork+0x193>
  800ffa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ffd:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800fff:	89 d8                	mov    %ebx,%eax
  801001:	c1 e8 16             	shr    $0x16,%eax
  801004:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100b:	a8 01                	test   $0x1,%al
  80100d:	0f 84 bd 00 00 00    	je     8010d0 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801013:	89 d8                	mov    %ebx,%eax
  801015:	c1 e8 0c             	shr    $0xc,%eax
  801018:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101f:	f6 c2 01             	test   $0x1,%dl
  801022:	0f 84 a8 00 00 00    	je     8010d0 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801028:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102f:	a8 04                	test   $0x4,%al
  801031:	0f 84 99 00 00 00    	je     8010d0 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801037:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103e:	f6 c4 04             	test   $0x4,%ah
  801041:	74 17                	je     80105a <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	68 07 0e 00 00       	push   $0xe07
  80104b:	53                   	push   %ebx
  80104c:	57                   	push   %edi
  80104d:	53                   	push   %ebx
  80104e:	6a 00                	push   $0x0
  801050:	e8 27 fc ff ff       	call   800c7c <sys_page_map>
  801055:	83 c4 20             	add    $0x20,%esp
  801058:	eb 76                	jmp    8010d0 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80105a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801061:	a8 02                	test   $0x2,%al
  801063:	75 0c                	jne    801071 <fork+0xcb>
  801065:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80106c:	f6 c4 08             	test   $0x8,%ah
  80106f:	74 3f                	je     8010b0 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	68 05 08 00 00       	push   $0x805
  801079:	53                   	push   %ebx
  80107a:	57                   	push   %edi
  80107b:	53                   	push   %ebx
  80107c:	6a 00                	push   $0x0
  80107e:	e8 f9 fb ff ff       	call   800c7c <sys_page_map>
		if (r < 0)
  801083:	83 c4 20             	add    $0x20,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	0f 88 a5 00 00 00    	js     801133 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	68 05 08 00 00       	push   $0x805
  801096:	53                   	push   %ebx
  801097:	6a 00                	push   $0x0
  801099:	53                   	push   %ebx
  80109a:	6a 00                	push   $0x0
  80109c:	e8 db fb ff ff       	call   800c7c <sys_page_map>
  8010a1:	83 c4 20             	add    $0x20,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ab:	0f 4f c1             	cmovg  %ecx,%eax
  8010ae:	eb 1c                	jmp    8010cc <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	6a 05                	push   $0x5
  8010b5:	53                   	push   %ebx
  8010b6:	57                   	push   %edi
  8010b7:	53                   	push   %ebx
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 bd fb ff ff       	call   800c7c <sys_page_map>
  8010bf:	83 c4 20             	add    $0x20,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c9:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	78 67                	js     801137 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8010d0:	83 c6 01             	add    $0x1,%esi
  8010d3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010d9:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8010df:	0f 85 1a ff ff ff    	jne    800fff <fork+0x59>
  8010e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8010e8:	83 ec 04             	sub    $0x4,%esp
  8010eb:	6a 07                	push   $0x7
  8010ed:	68 00 f0 bf ee       	push   $0xeebff000
  8010f2:	57                   	push   %edi
  8010f3:	e8 41 fb ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  8010f8:	83 c4 10             	add    $0x10,%esp
		return r;
  8010fb:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	78 38                	js     801139 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	68 27 29 80 00       	push   $0x802927
  801109:	57                   	push   %edi
  80110a:	e8 75 fc ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80110f:	83 c4 10             	add    $0x10,%esp
		return r;
  801112:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801114:	85 c0                	test   %eax,%eax
  801116:	78 21                	js     801139 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801118:	83 ec 08             	sub    $0x8,%esp
  80111b:	6a 02                	push   $0x2
  80111d:	57                   	push   %edi
  80111e:	e8 dd fb ff ff       	call   800d00 <sys_env_set_status>
	if (r < 0)
  801123:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801126:	85 c0                	test   %eax,%eax
  801128:	0f 48 f8             	cmovs  %eax,%edi
  80112b:	89 fa                	mov    %edi,%edx
  80112d:	eb 0a                	jmp    801139 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80112f:	89 c2                	mov    %eax,%edx
  801131:	eb 06                	jmp    801139 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801133:	89 c2                	mov    %eax,%edx
  801135:	eb 02                	jmp    801139 <fork+0x193>
  801137:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801139:	89 d0                	mov    %edx,%eax
  80113b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sfork>:

// Challenge!
int
sfork(void)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801149:	68 cb 31 80 00       	push   $0x8031cb
  80114e:	68 c9 00 00 00       	push   $0xc9
  801153:	68 c0 31 80 00       	push   $0x8031c0
  801158:	e8 7b f0 ff ff       	call   8001d8 <_panic>

0080115d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801160:	8b 45 08             	mov    0x8(%ebp),%eax
  801163:	05 00 00 00 30       	add    $0x30000000,%eax
  801168:	c1 e8 0c             	shr    $0xc,%eax
}
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	05 00 00 00 30       	add    $0x30000000,%eax
  801178:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80117d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80118f:	89 c2                	mov    %eax,%edx
  801191:	c1 ea 16             	shr    $0x16,%edx
  801194:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119b:	f6 c2 01             	test   $0x1,%dl
  80119e:	74 11                	je     8011b1 <fd_alloc+0x2d>
  8011a0:	89 c2                	mov    %eax,%edx
  8011a2:	c1 ea 0c             	shr    $0xc,%edx
  8011a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ac:	f6 c2 01             	test   $0x1,%dl
  8011af:	75 09                	jne    8011ba <fd_alloc+0x36>
			*fd_store = fd;
  8011b1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b8:	eb 17                	jmp    8011d1 <fd_alloc+0x4d>
  8011ba:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011bf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c4:	75 c9                	jne    80118f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011c6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011cc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d9:	83 f8 1f             	cmp    $0x1f,%eax
  8011dc:	77 36                	ja     801214 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011de:	c1 e0 0c             	shl    $0xc,%eax
  8011e1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	c1 ea 16             	shr    $0x16,%edx
  8011eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f2:	f6 c2 01             	test   $0x1,%dl
  8011f5:	74 24                	je     80121b <fd_lookup+0x48>
  8011f7:	89 c2                	mov    %eax,%edx
  8011f9:	c1 ea 0c             	shr    $0xc,%edx
  8011fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801203:	f6 c2 01             	test   $0x1,%dl
  801206:	74 1a                	je     801222 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801208:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120b:	89 02                	mov    %eax,(%edx)
	return 0;
  80120d:	b8 00 00 00 00       	mov    $0x0,%eax
  801212:	eb 13                	jmp    801227 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801214:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801219:	eb 0c                	jmp    801227 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80121b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801220:	eb 05                	jmp    801227 <fd_lookup+0x54>
  801222:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	83 ec 08             	sub    $0x8,%esp
  80122f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801232:	ba 60 32 80 00       	mov    $0x803260,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801237:	eb 13                	jmp    80124c <dev_lookup+0x23>
  801239:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80123c:	39 08                	cmp    %ecx,(%eax)
  80123e:	75 0c                	jne    80124c <dev_lookup+0x23>
			*dev = devtab[i];
  801240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801243:	89 01                	mov    %eax,(%ecx)
			return 0;
  801245:	b8 00 00 00 00       	mov    $0x0,%eax
  80124a:	eb 2e                	jmp    80127a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80124c:	8b 02                	mov    (%edx),%eax
  80124e:	85 c0                	test   %eax,%eax
  801250:	75 e7                	jne    801239 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801252:	a1 08 50 80 00       	mov    0x805008,%eax
  801257:	8b 40 48             	mov    0x48(%eax),%eax
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	51                   	push   %ecx
  80125e:	50                   	push   %eax
  80125f:	68 e4 31 80 00       	push   $0x8031e4
  801264:	e8 48 f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  801269:	8b 45 0c             	mov    0xc(%ebp),%eax
  80126c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	56                   	push   %esi
  801280:	53                   	push   %ebx
  801281:	83 ec 10             	sub    $0x10,%esp
  801284:	8b 75 08             	mov    0x8(%ebp),%esi
  801287:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80128a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801294:	c1 e8 0c             	shr    $0xc,%eax
  801297:	50                   	push   %eax
  801298:	e8 36 ff ff ff       	call   8011d3 <fd_lookup>
  80129d:	83 c4 08             	add    $0x8,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	78 05                	js     8012a9 <fd_close+0x2d>
	    || fd != fd2)
  8012a4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012a7:	74 0c                	je     8012b5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012a9:	84 db                	test   %bl,%bl
  8012ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b0:	0f 44 c2             	cmove  %edx,%eax
  8012b3:	eb 41                	jmp    8012f6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012b5:	83 ec 08             	sub    $0x8,%esp
  8012b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012bb:	50                   	push   %eax
  8012bc:	ff 36                	pushl  (%esi)
  8012be:	e8 66 ff ff ff       	call   801229 <dev_lookup>
  8012c3:	89 c3                	mov    %eax,%ebx
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 1a                	js     8012e6 <fd_close+0x6a>
		if (dev->dev_close)
  8012cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012d2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	74 0b                	je     8012e6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012db:	83 ec 0c             	sub    $0xc,%esp
  8012de:	56                   	push   %esi
  8012df:	ff d0                	call   *%eax
  8012e1:	89 c3                	mov    %eax,%ebx
  8012e3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	56                   	push   %esi
  8012ea:	6a 00                	push   $0x0
  8012ec:	e8 cd f9 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	89 d8                	mov    %ebx,%eax
}
  8012f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801303:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	ff 75 08             	pushl  0x8(%ebp)
  80130a:	e8 c4 fe ff ff       	call   8011d3 <fd_lookup>
  80130f:	83 c4 08             	add    $0x8,%esp
  801312:	85 c0                	test   %eax,%eax
  801314:	78 10                	js     801326 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801316:	83 ec 08             	sub    $0x8,%esp
  801319:	6a 01                	push   $0x1
  80131b:	ff 75 f4             	pushl  -0xc(%ebp)
  80131e:	e8 59 ff ff ff       	call   80127c <fd_close>
  801323:	83 c4 10             	add    $0x10,%esp
}
  801326:	c9                   	leave  
  801327:	c3                   	ret    

00801328 <close_all>:

void
close_all(void)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	53                   	push   %ebx
  80132c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80132f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801334:	83 ec 0c             	sub    $0xc,%esp
  801337:	53                   	push   %ebx
  801338:	e8 c0 ff ff ff       	call   8012fd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80133d:	83 c3 01             	add    $0x1,%ebx
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	83 fb 20             	cmp    $0x20,%ebx
  801346:	75 ec                	jne    801334 <close_all+0xc>
		close(i);
}
  801348:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134b:	c9                   	leave  
  80134c:	c3                   	ret    

0080134d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	57                   	push   %edi
  801351:	56                   	push   %esi
  801352:	53                   	push   %ebx
  801353:	83 ec 2c             	sub    $0x2c,%esp
  801356:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801359:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	ff 75 08             	pushl  0x8(%ebp)
  801360:	e8 6e fe ff ff       	call   8011d3 <fd_lookup>
  801365:	83 c4 08             	add    $0x8,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	0f 88 c1 00 00 00    	js     801431 <dup+0xe4>
		return r;
	close(newfdnum);
  801370:	83 ec 0c             	sub    $0xc,%esp
  801373:	56                   	push   %esi
  801374:	e8 84 ff ff ff       	call   8012fd <close>

	newfd = INDEX2FD(newfdnum);
  801379:	89 f3                	mov    %esi,%ebx
  80137b:	c1 e3 0c             	shl    $0xc,%ebx
  80137e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801384:	83 c4 04             	add    $0x4,%esp
  801387:	ff 75 e4             	pushl  -0x1c(%ebp)
  80138a:	e8 de fd ff ff       	call   80116d <fd2data>
  80138f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801391:	89 1c 24             	mov    %ebx,(%esp)
  801394:	e8 d4 fd ff ff       	call   80116d <fd2data>
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80139f:	89 f8                	mov    %edi,%eax
  8013a1:	c1 e8 16             	shr    $0x16,%eax
  8013a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ab:	a8 01                	test   $0x1,%al
  8013ad:	74 37                	je     8013e6 <dup+0x99>
  8013af:	89 f8                	mov    %edi,%eax
  8013b1:	c1 e8 0c             	shr    $0xc,%eax
  8013b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013bb:	f6 c2 01             	test   $0x1,%dl
  8013be:	74 26                	je     8013e6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c7:	83 ec 0c             	sub    $0xc,%esp
  8013ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8013cf:	50                   	push   %eax
  8013d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d3:	6a 00                	push   $0x0
  8013d5:	57                   	push   %edi
  8013d6:	6a 00                	push   $0x0
  8013d8:	e8 9f f8 ff ff       	call   800c7c <sys_page_map>
  8013dd:	89 c7                	mov    %eax,%edi
  8013df:	83 c4 20             	add    $0x20,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 2e                	js     801414 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013e9:	89 d0                	mov    %edx,%eax
  8013eb:	c1 e8 0c             	shr    $0xc,%eax
  8013ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f5:	83 ec 0c             	sub    $0xc,%esp
  8013f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013fd:	50                   	push   %eax
  8013fe:	53                   	push   %ebx
  8013ff:	6a 00                	push   $0x0
  801401:	52                   	push   %edx
  801402:	6a 00                	push   $0x0
  801404:	e8 73 f8 ff ff       	call   800c7c <sys_page_map>
  801409:	89 c7                	mov    %eax,%edi
  80140b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80140e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801410:	85 ff                	test   %edi,%edi
  801412:	79 1d                	jns    801431 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	53                   	push   %ebx
  801418:	6a 00                	push   $0x0
  80141a:	e8 9f f8 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80141f:	83 c4 08             	add    $0x8,%esp
  801422:	ff 75 d4             	pushl  -0x2c(%ebp)
  801425:	6a 00                	push   $0x0
  801427:	e8 92 f8 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	89 f8                	mov    %edi,%eax
}
  801431:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801434:	5b                   	pop    %ebx
  801435:	5e                   	pop    %esi
  801436:	5f                   	pop    %edi
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	53                   	push   %ebx
  80143d:	83 ec 14             	sub    $0x14,%esp
  801440:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801443:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801446:	50                   	push   %eax
  801447:	53                   	push   %ebx
  801448:	e8 86 fd ff ff       	call   8011d3 <fd_lookup>
  80144d:	83 c4 08             	add    $0x8,%esp
  801450:	89 c2                	mov    %eax,%edx
  801452:	85 c0                	test   %eax,%eax
  801454:	78 6d                	js     8014c3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801460:	ff 30                	pushl  (%eax)
  801462:	e8 c2 fd ff ff       	call   801229 <dev_lookup>
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 4c                	js     8014ba <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80146e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801471:	8b 42 08             	mov    0x8(%edx),%eax
  801474:	83 e0 03             	and    $0x3,%eax
  801477:	83 f8 01             	cmp    $0x1,%eax
  80147a:	75 21                	jne    80149d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80147c:	a1 08 50 80 00       	mov    0x805008,%eax
  801481:	8b 40 48             	mov    0x48(%eax),%eax
  801484:	83 ec 04             	sub    $0x4,%esp
  801487:	53                   	push   %ebx
  801488:	50                   	push   %eax
  801489:	68 25 32 80 00       	push   $0x803225
  80148e:	e8 1e ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80149b:	eb 26                	jmp    8014c3 <read+0x8a>
	}
	if (!dev->dev_read)
  80149d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a0:	8b 40 08             	mov    0x8(%eax),%eax
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	74 17                	je     8014be <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a7:	83 ec 04             	sub    $0x4,%esp
  8014aa:	ff 75 10             	pushl  0x10(%ebp)
  8014ad:	ff 75 0c             	pushl  0xc(%ebp)
  8014b0:	52                   	push   %edx
  8014b1:	ff d0                	call   *%eax
  8014b3:	89 c2                	mov    %eax,%edx
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	eb 09                	jmp    8014c3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ba:	89 c2                	mov    %eax,%edx
  8014bc:	eb 05                	jmp    8014c3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014c3:	89 d0                	mov    %edx,%eax
  8014c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	57                   	push   %edi
  8014ce:	56                   	push   %esi
  8014cf:	53                   	push   %ebx
  8014d0:	83 ec 0c             	sub    $0xc,%esp
  8014d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014de:	eb 21                	jmp    801501 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e0:	83 ec 04             	sub    $0x4,%esp
  8014e3:	89 f0                	mov    %esi,%eax
  8014e5:	29 d8                	sub    %ebx,%eax
  8014e7:	50                   	push   %eax
  8014e8:	89 d8                	mov    %ebx,%eax
  8014ea:	03 45 0c             	add    0xc(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	57                   	push   %edi
  8014ef:	e8 45 ff ff ff       	call   801439 <read>
		if (m < 0)
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 10                	js     80150b <readn+0x41>
			return m;
		if (m == 0)
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	74 0a                	je     801509 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ff:	01 c3                	add    %eax,%ebx
  801501:	39 f3                	cmp    %esi,%ebx
  801503:	72 db                	jb     8014e0 <readn+0x16>
  801505:	89 d8                	mov    %ebx,%eax
  801507:	eb 02                	jmp    80150b <readn+0x41>
  801509:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80150b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150e:	5b                   	pop    %ebx
  80150f:	5e                   	pop    %esi
  801510:	5f                   	pop    %edi
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    

00801513 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	53                   	push   %ebx
  801517:	83 ec 14             	sub    $0x14,%esp
  80151a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801520:	50                   	push   %eax
  801521:	53                   	push   %ebx
  801522:	e8 ac fc ff ff       	call   8011d3 <fd_lookup>
  801527:	83 c4 08             	add    $0x8,%esp
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 68                	js     801598 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801536:	50                   	push   %eax
  801537:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153a:	ff 30                	pushl  (%eax)
  80153c:	e8 e8 fc ff ff       	call   801229 <dev_lookup>
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	78 47                	js     80158f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801548:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154f:	75 21                	jne    801572 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801551:	a1 08 50 80 00       	mov    0x805008,%eax
  801556:	8b 40 48             	mov    0x48(%eax),%eax
  801559:	83 ec 04             	sub    $0x4,%esp
  80155c:	53                   	push   %ebx
  80155d:	50                   	push   %eax
  80155e:	68 41 32 80 00       	push   $0x803241
  801563:	e8 49 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801570:	eb 26                	jmp    801598 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801572:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801575:	8b 52 0c             	mov    0xc(%edx),%edx
  801578:	85 d2                	test   %edx,%edx
  80157a:	74 17                	je     801593 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80157c:	83 ec 04             	sub    $0x4,%esp
  80157f:	ff 75 10             	pushl  0x10(%ebp)
  801582:	ff 75 0c             	pushl  0xc(%ebp)
  801585:	50                   	push   %eax
  801586:	ff d2                	call   *%edx
  801588:	89 c2                	mov    %eax,%edx
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	eb 09                	jmp    801598 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158f:	89 c2                	mov    %eax,%edx
  801591:	eb 05                	jmp    801598 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801593:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801598:	89 d0                	mov    %edx,%eax
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <seek>:

int
seek(int fdnum, off_t offset)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015a8:	50                   	push   %eax
  8015a9:	ff 75 08             	pushl  0x8(%ebp)
  8015ac:	e8 22 fc ff ff       	call   8011d3 <fd_lookup>
  8015b1:	83 c4 08             	add    $0x8,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 0e                	js     8015c6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015be:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 14             	sub    $0x14,%esp
  8015cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	53                   	push   %ebx
  8015d7:	e8 f7 fb ff ff       	call   8011d3 <fd_lookup>
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	89 c2                	mov    %eax,%edx
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 65                	js     80164a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e5:	83 ec 08             	sub    $0x8,%esp
  8015e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015eb:	50                   	push   %eax
  8015ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ef:	ff 30                	pushl  (%eax)
  8015f1:	e8 33 fc ff ff       	call   801229 <dev_lookup>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 44                	js     801641 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801600:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801604:	75 21                	jne    801627 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801606:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80160b:	8b 40 48             	mov    0x48(%eax),%eax
  80160e:	83 ec 04             	sub    $0x4,%esp
  801611:	53                   	push   %ebx
  801612:	50                   	push   %eax
  801613:	68 04 32 80 00       	push   $0x803204
  801618:	e8 94 ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801625:	eb 23                	jmp    80164a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801627:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162a:	8b 52 18             	mov    0x18(%edx),%edx
  80162d:	85 d2                	test   %edx,%edx
  80162f:	74 14                	je     801645 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	ff 75 0c             	pushl  0xc(%ebp)
  801637:	50                   	push   %eax
  801638:	ff d2                	call   *%edx
  80163a:	89 c2                	mov    %eax,%edx
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	eb 09                	jmp    80164a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801641:	89 c2                	mov    %eax,%edx
  801643:	eb 05                	jmp    80164a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801645:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80164a:	89 d0                	mov    %edx,%eax
  80164c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164f:	c9                   	leave  
  801650:	c3                   	ret    

00801651 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	53                   	push   %ebx
  801655:	83 ec 14             	sub    $0x14,%esp
  801658:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165e:	50                   	push   %eax
  80165f:	ff 75 08             	pushl  0x8(%ebp)
  801662:	e8 6c fb ff ff       	call   8011d3 <fd_lookup>
  801667:	83 c4 08             	add    $0x8,%esp
  80166a:	89 c2                	mov    %eax,%edx
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 58                	js     8016c8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801670:	83 ec 08             	sub    $0x8,%esp
  801673:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801676:	50                   	push   %eax
  801677:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167a:	ff 30                	pushl  (%eax)
  80167c:	e8 a8 fb ff ff       	call   801229 <dev_lookup>
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	78 37                	js     8016bf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80168f:	74 32                	je     8016c3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801691:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801694:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80169b:	00 00 00 
	stat->st_isdir = 0;
  80169e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a5:	00 00 00 
	stat->st_dev = dev;
  8016a8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	53                   	push   %ebx
  8016b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016b5:	ff 50 14             	call   *0x14(%eax)
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	eb 09                	jmp    8016c8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	eb 05                	jmp    8016c8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016c8:	89 d0                	mov    %edx,%eax
  8016ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	56                   	push   %esi
  8016d3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016d4:	83 ec 08             	sub    $0x8,%esp
  8016d7:	6a 00                	push   $0x0
  8016d9:	ff 75 08             	pushl  0x8(%ebp)
  8016dc:	e8 d6 01 00 00       	call   8018b7 <open>
  8016e1:	89 c3                	mov    %eax,%ebx
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	78 1b                	js     801705 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	ff 75 0c             	pushl  0xc(%ebp)
  8016f0:	50                   	push   %eax
  8016f1:	e8 5b ff ff ff       	call   801651 <fstat>
  8016f6:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f8:	89 1c 24             	mov    %ebx,(%esp)
  8016fb:	e8 fd fb ff ff       	call   8012fd <close>
	return r;
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	89 f0                	mov    %esi,%eax
}
  801705:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801708:	5b                   	pop    %ebx
  801709:	5e                   	pop    %esi
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	56                   	push   %esi
  801710:	53                   	push   %ebx
  801711:	89 c6                	mov    %eax,%esi
  801713:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801715:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80171c:	75 12                	jne    801730 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80171e:	83 ec 0c             	sub    $0xc,%esp
  801721:	6a 01                	push   $0x1
  801723:	e8 de 12 00 00       	call   802a06 <ipc_find_env>
  801728:	a3 00 50 80 00       	mov    %eax,0x805000
  80172d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801730:	6a 07                	push   $0x7
  801732:	68 00 60 80 00       	push   $0x806000
  801737:	56                   	push   %esi
  801738:	ff 35 00 50 80 00    	pushl  0x805000
  80173e:	e8 6f 12 00 00       	call   8029b2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801743:	83 c4 0c             	add    $0xc,%esp
  801746:	6a 00                	push   $0x0
  801748:	53                   	push   %ebx
  801749:	6a 00                	push   $0x0
  80174b:	e8 fb 11 00 00       	call   80294b <ipc_recv>
}
  801750:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80175d:	8b 45 08             	mov    0x8(%ebp),%eax
  801760:	8b 40 0c             	mov    0xc(%eax),%eax
  801763:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801768:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176b:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801770:	ba 00 00 00 00       	mov    $0x0,%edx
  801775:	b8 02 00 00 00       	mov    $0x2,%eax
  80177a:	e8 8d ff ff ff       	call   80170c <fsipc>
}
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801787:	8b 45 08             	mov    0x8(%ebp),%eax
  80178a:	8b 40 0c             	mov    0xc(%eax),%eax
  80178d:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801792:	ba 00 00 00 00       	mov    $0x0,%edx
  801797:	b8 06 00 00 00       	mov    $0x6,%eax
  80179c:	e8 6b ff ff ff       	call   80170c <fsipc>
}
  8017a1:	c9                   	leave  
  8017a2:	c3                   	ret    

008017a3 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 04             	sub    $0x4,%esp
  8017aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b3:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8017c2:	e8 45 ff ff ff       	call   80170c <fsipc>
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 2c                	js     8017f7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	68 00 60 80 00       	push   $0x806000
  8017d3:	53                   	push   %ebx
  8017d4:	e8 5d f0 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d9:	a1 80 60 80 00       	mov    0x806080,%eax
  8017de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e4:	a1 84 60 80 00       	mov    0x806084,%eax
  8017e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	83 ec 0c             	sub    $0xc,%esp
  801802:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801805:	8b 55 08             	mov    0x8(%ebp),%edx
  801808:	8b 52 0c             	mov    0xc(%edx),%edx
  80180b:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801811:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801816:	50                   	push   %eax
  801817:	ff 75 0c             	pushl  0xc(%ebp)
  80181a:	68 08 60 80 00       	push   $0x806008
  80181f:	e8 a4 f1 ff ff       	call   8009c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801824:	ba 00 00 00 00       	mov    $0x0,%edx
  801829:	b8 04 00 00 00       	mov    $0x4,%eax
  80182e:	e8 d9 fe ff ff       	call   80170c <fsipc>

}
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	56                   	push   %esi
  801839:	53                   	push   %ebx
  80183a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80183d:	8b 45 08             	mov    0x8(%ebp),%eax
  801840:	8b 40 0c             	mov    0xc(%eax),%eax
  801843:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801848:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80184e:	ba 00 00 00 00       	mov    $0x0,%edx
  801853:	b8 03 00 00 00       	mov    $0x3,%eax
  801858:	e8 af fe ff ff       	call   80170c <fsipc>
  80185d:	89 c3                	mov    %eax,%ebx
  80185f:	85 c0                	test   %eax,%eax
  801861:	78 4b                	js     8018ae <devfile_read+0x79>
		return r;
	assert(r <= n);
  801863:	39 c6                	cmp    %eax,%esi
  801865:	73 16                	jae    80187d <devfile_read+0x48>
  801867:	68 74 32 80 00       	push   $0x803274
  80186c:	68 7b 32 80 00       	push   $0x80327b
  801871:	6a 7c                	push   $0x7c
  801873:	68 90 32 80 00       	push   $0x803290
  801878:	e8 5b e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  80187d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801882:	7e 16                	jle    80189a <devfile_read+0x65>
  801884:	68 9b 32 80 00       	push   $0x80329b
  801889:	68 7b 32 80 00       	push   $0x80327b
  80188e:	6a 7d                	push   $0x7d
  801890:	68 90 32 80 00       	push   $0x803290
  801895:	e8 3e e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80189a:	83 ec 04             	sub    $0x4,%esp
  80189d:	50                   	push   %eax
  80189e:	68 00 60 80 00       	push   $0x806000
  8018a3:	ff 75 0c             	pushl  0xc(%ebp)
  8018a6:	e8 1d f1 ff ff       	call   8009c8 <memmove>
	return r;
  8018ab:	83 c4 10             	add    $0x10,%esp
}
  8018ae:	89 d8                	mov    %ebx,%eax
  8018b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b3:	5b                   	pop    %ebx
  8018b4:	5e                   	pop    %esi
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	53                   	push   %ebx
  8018bb:	83 ec 20             	sub    $0x20,%esp
  8018be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018c1:	53                   	push   %ebx
  8018c2:	e8 36 ef ff ff       	call   8007fd <strlen>
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018cf:	7f 67                	jg     801938 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d1:	83 ec 0c             	sub    $0xc,%esp
  8018d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d7:	50                   	push   %eax
  8018d8:	e8 a7 f8 ff ff       	call   801184 <fd_alloc>
  8018dd:	83 c4 10             	add    $0x10,%esp
		return r;
  8018e0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	78 57                	js     80193d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	53                   	push   %ebx
  8018ea:	68 00 60 80 00       	push   $0x806000
  8018ef:	e8 42 ef ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f7:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ff:	b8 01 00 00 00       	mov    $0x1,%eax
  801904:	e8 03 fe ff ff       	call   80170c <fsipc>
  801909:	89 c3                	mov    %eax,%ebx
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	85 c0                	test   %eax,%eax
  801910:	79 14                	jns    801926 <open+0x6f>
		fd_close(fd, 0);
  801912:	83 ec 08             	sub    $0x8,%esp
  801915:	6a 00                	push   $0x0
  801917:	ff 75 f4             	pushl  -0xc(%ebp)
  80191a:	e8 5d f9 ff ff       	call   80127c <fd_close>
		return r;
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	89 da                	mov    %ebx,%edx
  801924:	eb 17                	jmp    80193d <open+0x86>
	}

	return fd2num(fd);
  801926:	83 ec 0c             	sub    $0xc,%esp
  801929:	ff 75 f4             	pushl  -0xc(%ebp)
  80192c:	e8 2c f8 ff ff       	call   80115d <fd2num>
  801931:	89 c2                	mov    %eax,%edx
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	eb 05                	jmp    80193d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801938:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80193d:	89 d0                	mov    %edx,%eax
  80193f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80194a:	ba 00 00 00 00       	mov    $0x0,%edx
  80194f:	b8 08 00 00 00       	mov    $0x8,%eax
  801954:	e8 b3 fd ff ff       	call   80170c <fsipc>
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	57                   	push   %edi
  80195f:	56                   	push   %esi
  801960:	53                   	push   %ebx
  801961:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801967:	6a 00                	push   $0x0
  801969:	ff 75 08             	pushl  0x8(%ebp)
  80196c:	e8 46 ff ff ff       	call   8018b7 <open>
  801971:	89 c7                	mov    %eax,%edi
  801973:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	85 c0                	test   %eax,%eax
  80197e:	0f 88 97 04 00 00    	js     801e1b <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801984:	83 ec 04             	sub    $0x4,%esp
  801987:	68 00 02 00 00       	push   $0x200
  80198c:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801992:	50                   	push   %eax
  801993:	57                   	push   %edi
  801994:	e8 31 fb ff ff       	call   8014ca <readn>
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019a1:	75 0c                	jne    8019af <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019a3:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019aa:	45 4c 46 
  8019ad:	74 33                	je     8019e2 <spawn+0x87>
		close(fd);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019b8:	e8 40 f9 ff ff       	call   8012fd <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019bd:	83 c4 0c             	add    $0xc,%esp
  8019c0:	68 7f 45 4c 46       	push   $0x464c457f
  8019c5:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019cb:	68 a7 32 80 00       	push   $0x8032a7
  8019d0:	e8 dc e8 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8019dd:	e9 ec 04 00 00       	jmp    801ece <spawn+0x573>
  8019e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8019e7:	cd 30                	int    $0x30
  8019e9:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019ef:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	0f 88 29 04 00 00    	js     801e26 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019fd:	89 c6                	mov    %eax,%esi
  8019ff:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a05:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a08:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a0e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a14:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a1b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a21:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a27:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a2c:	be 00 00 00 00       	mov    $0x0,%esi
  801a31:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a34:	eb 13                	jmp    801a49 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	50                   	push   %eax
  801a3a:	e8 be ed ff ff       	call   8007fd <strlen>
  801a3f:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a43:	83 c3 01             	add    $0x1,%ebx
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a50:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a53:	85 c0                	test   %eax,%eax
  801a55:	75 df                	jne    801a36 <spawn+0xdb>
  801a57:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a5d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a63:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a68:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a6a:	89 fa                	mov    %edi,%edx
  801a6c:	83 e2 fc             	and    $0xfffffffc,%edx
  801a6f:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a76:	29 c2                	sub    %eax,%edx
  801a78:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a7e:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a81:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a86:	0f 86 b0 03 00 00    	jbe    801e3c <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a8c:	83 ec 04             	sub    $0x4,%esp
  801a8f:	6a 07                	push   $0x7
  801a91:	68 00 00 40 00       	push   $0x400000
  801a96:	6a 00                	push   $0x0
  801a98:	e8 9c f1 ff ff       	call   800c39 <sys_page_alloc>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	0f 88 9e 03 00 00    	js     801e46 <spawn+0x4eb>
  801aa8:	be 00 00 00 00       	mov    $0x0,%esi
  801aad:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801ab3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ab6:	eb 30                	jmp    801ae8 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801ab8:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801abe:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801ac4:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801ac7:	83 ec 08             	sub    $0x8,%esp
  801aca:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801acd:	57                   	push   %edi
  801ace:	e8 63 ed ff ff       	call   800836 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801ad3:	83 c4 04             	add    $0x4,%esp
  801ad6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ad9:	e8 1f ed ff ff       	call   8007fd <strlen>
  801ade:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ae2:	83 c6 01             	add    $0x1,%esi
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801aee:	7f c8                	jg     801ab8 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801af0:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801af6:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801afc:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b03:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b09:	74 19                	je     801b24 <spawn+0x1c9>
  801b0b:	68 34 33 80 00       	push   $0x803334
  801b10:	68 7b 32 80 00       	push   $0x80327b
  801b15:	68 f2 00 00 00       	push   $0xf2
  801b1a:	68 c1 32 80 00       	push   $0x8032c1
  801b1f:	e8 b4 e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b24:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b2a:	89 f8                	mov    %edi,%eax
  801b2c:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b31:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b34:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b3a:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b3d:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b43:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b49:	83 ec 0c             	sub    $0xc,%esp
  801b4c:	6a 07                	push   $0x7
  801b4e:	68 00 d0 bf ee       	push   $0xeebfd000
  801b53:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b59:	68 00 00 40 00       	push   $0x400000
  801b5e:	6a 00                	push   $0x0
  801b60:	e8 17 f1 ff ff       	call   800c7c <sys_page_map>
  801b65:	89 c3                	mov    %eax,%ebx
  801b67:	83 c4 20             	add    $0x20,%esp
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	0f 88 4a 03 00 00    	js     801ebc <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b72:	83 ec 08             	sub    $0x8,%esp
  801b75:	68 00 00 40 00       	push   $0x400000
  801b7a:	6a 00                	push   $0x0
  801b7c:	e8 3d f1 ff ff       	call   800cbe <sys_page_unmap>
  801b81:	89 c3                	mov    %eax,%ebx
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	85 c0                	test   %eax,%eax
  801b88:	0f 88 2e 03 00 00    	js     801ebc <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b8e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b94:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b9b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ba1:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801ba8:	00 00 00 
  801bab:	e9 8a 01 00 00       	jmp    801d3a <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801bb0:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801bb6:	83 38 01             	cmpl   $0x1,(%eax)
  801bb9:	0f 85 6d 01 00 00    	jne    801d2c <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bbf:	89 c7                	mov    %eax,%edi
  801bc1:	8b 40 18             	mov    0x18(%eax),%eax
  801bc4:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bca:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801bcd:	83 f8 01             	cmp    $0x1,%eax
  801bd0:	19 c0                	sbb    %eax,%eax
  801bd2:	83 e0 fe             	and    $0xfffffffe,%eax
  801bd5:	83 c0 07             	add    $0x7,%eax
  801bd8:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bde:	89 f8                	mov    %edi,%eax
  801be0:	8b 7f 04             	mov    0x4(%edi),%edi
  801be3:	89 f9                	mov    %edi,%ecx
  801be5:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801beb:	8b 78 10             	mov    0x10(%eax),%edi
  801bee:	8b 70 14             	mov    0x14(%eax),%esi
  801bf1:	89 f3                	mov    %esi,%ebx
  801bf3:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801bf9:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801bfc:	89 f0                	mov    %esi,%eax
  801bfe:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c03:	74 14                	je     801c19 <spawn+0x2be>
		va -= i;
  801c05:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c07:	01 c3                	add    %eax,%ebx
  801c09:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801c0f:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c11:	29 c1                	sub    %eax,%ecx
  801c13:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c1e:	e9 f7 00 00 00       	jmp    801d1a <spawn+0x3bf>
		if (i >= filesz) {
  801c23:	39 df                	cmp    %ebx,%edi
  801c25:	77 27                	ja     801c4e <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c27:	83 ec 04             	sub    $0x4,%esp
  801c2a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c30:	56                   	push   %esi
  801c31:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c37:	e8 fd ef ff ff       	call   800c39 <sys_page_alloc>
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	0f 89 c7 00 00 00    	jns    801d0e <spawn+0x3b3>
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	e9 09 02 00 00       	jmp    801e57 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c4e:	83 ec 04             	sub    $0x4,%esp
  801c51:	6a 07                	push   $0x7
  801c53:	68 00 00 40 00       	push   $0x400000
  801c58:	6a 00                	push   $0x0
  801c5a:	e8 da ef ff ff       	call   800c39 <sys_page_alloc>
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	85 c0                	test   %eax,%eax
  801c64:	0f 88 e3 01 00 00    	js     801e4d <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c6a:	83 ec 08             	sub    $0x8,%esp
  801c6d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c73:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c79:	50                   	push   %eax
  801c7a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c80:	e8 1a f9 ff ff       	call   80159f <seek>
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	0f 88 c1 01 00 00    	js     801e51 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c90:	83 ec 04             	sub    $0x4,%esp
  801c93:	89 f8                	mov    %edi,%eax
  801c95:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c9b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ca0:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801ca5:	0f 47 c1             	cmova  %ecx,%eax
  801ca8:	50                   	push   %eax
  801ca9:	68 00 00 40 00       	push   $0x400000
  801cae:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cb4:	e8 11 f8 ff ff       	call   8014ca <readn>
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	0f 88 91 01 00 00    	js     801e55 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801cc4:	83 ec 0c             	sub    $0xc,%esp
  801cc7:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ccd:	56                   	push   %esi
  801cce:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cd4:	68 00 00 40 00       	push   $0x400000
  801cd9:	6a 00                	push   $0x0
  801cdb:	e8 9c ef ff ff       	call   800c7c <sys_page_map>
  801ce0:	83 c4 20             	add    $0x20,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	79 15                	jns    801cfc <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801ce7:	50                   	push   %eax
  801ce8:	68 cd 32 80 00       	push   $0x8032cd
  801ced:	68 25 01 00 00       	push   $0x125
  801cf2:	68 c1 32 80 00       	push   $0x8032c1
  801cf7:	e8 dc e4 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801cfc:	83 ec 08             	sub    $0x8,%esp
  801cff:	68 00 00 40 00       	push   $0x400000
  801d04:	6a 00                	push   $0x0
  801d06:	e8 b3 ef ff ff       	call   800cbe <sys_page_unmap>
  801d0b:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d0e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d14:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d1a:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d20:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801d26:	0f 87 f7 fe ff ff    	ja     801c23 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d2c:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d33:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d3a:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d41:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d47:	0f 8c 63 fe ff ff    	jl     801bb0 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d56:	e8 a2 f5 ff ff       	call   8012fd <close>
  801d5b:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801d5e:	bb 00 08 00 00       	mov    $0x800,%ebx
  801d63:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  801d69:	89 d8                	mov    %ebx,%eax
  801d6b:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801d6e:	89 c2                	mov    %eax,%edx
  801d70:	c1 ea 16             	shr    $0x16,%edx
  801d73:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d7a:	f6 c2 01             	test   $0x1,%dl
  801d7d:	74 4b                	je     801dca <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801d7f:	89 c2                	mov    %eax,%edx
  801d81:	c1 ea 0c             	shr    $0xc,%edx
  801d84:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801d8b:	f6 c1 01             	test   $0x1,%cl
  801d8e:	74 3a                	je     801dca <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801d90:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d97:	f6 c6 04             	test   $0x4,%dh
  801d9a:	74 2e                	je     801dca <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801d9c:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801da3:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  801da9:	8b 49 48             	mov    0x48(%ecx),%ecx
  801dac:	83 ec 0c             	sub    $0xc,%esp
  801daf:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801db5:	52                   	push   %edx
  801db6:	50                   	push   %eax
  801db7:	56                   	push   %esi
  801db8:	50                   	push   %eax
  801db9:	51                   	push   %ecx
  801dba:	e8 bd ee ff ff       	call   800c7c <sys_page_map>
					if (r < 0)
  801dbf:	83 c4 20             	add    $0x20,%esp
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	0f 88 ae 00 00 00    	js     801e78 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801dca:	83 c3 01             	add    $0x1,%ebx
  801dcd:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801dd3:	75 94                	jne    801d69 <spawn+0x40e>
  801dd5:	e9 b3 00 00 00       	jmp    801e8d <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801dda:	50                   	push   %eax
  801ddb:	68 ea 32 80 00       	push   $0x8032ea
  801de0:	68 86 00 00 00       	push   $0x86
  801de5:	68 c1 32 80 00       	push   $0x8032c1
  801dea:	e8 e9 e3 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801def:	83 ec 08             	sub    $0x8,%esp
  801df2:	6a 02                	push   $0x2
  801df4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dfa:	e8 01 ef ff ff       	call   800d00 <sys_env_set_status>
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	85 c0                	test   %eax,%eax
  801e04:	79 2b                	jns    801e31 <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801e06:	50                   	push   %eax
  801e07:	68 04 33 80 00       	push   $0x803304
  801e0c:	68 89 00 00 00       	push   $0x89
  801e11:	68 c1 32 80 00       	push   $0x8032c1
  801e16:	e8 bd e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e1b:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e21:	e9 a8 00 00 00       	jmp    801ece <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e26:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e2c:	e9 9d 00 00 00       	jmp    801ece <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e31:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e37:	e9 92 00 00 00       	jmp    801ece <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e3c:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e41:	e9 88 00 00 00       	jmp    801ece <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e46:	89 c3                	mov    %eax,%ebx
  801e48:	e9 81 00 00 00       	jmp    801ece <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	eb 06                	jmp    801e57 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e51:	89 c3                	mov    %eax,%ebx
  801e53:	eb 02                	jmp    801e57 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e55:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e57:	83 ec 0c             	sub    $0xc,%esp
  801e5a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e60:	e8 55 ed ff ff       	call   800bba <sys_env_destroy>
	close(fd);
  801e65:	83 c4 04             	add    $0x4,%esp
  801e68:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e6e:	e8 8a f4 ff ff       	call   8012fd <close>
	return r;
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	eb 56                	jmp    801ece <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e78:	50                   	push   %eax
  801e79:	68 1b 33 80 00       	push   $0x80331b
  801e7e:	68 82 00 00 00       	push   $0x82
  801e83:	68 c1 32 80 00       	push   $0x8032c1
  801e88:	e8 4b e3 ff ff       	call   8001d8 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e8d:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e94:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e97:	83 ec 08             	sub    $0x8,%esp
  801e9a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ea0:	50                   	push   %eax
  801ea1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ea7:	e8 96 ee ff ff       	call   800d42 <sys_env_set_trapframe>
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	0f 89 38 ff ff ff    	jns    801def <spawn+0x494>
  801eb7:	e9 1e ff ff ff       	jmp    801dda <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ebc:	83 ec 08             	sub    $0x8,%esp
  801ebf:	68 00 00 40 00       	push   $0x400000
  801ec4:	6a 00                	push   $0x0
  801ec6:	e8 f3 ed ff ff       	call   800cbe <sys_page_unmap>
  801ecb:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ece:	89 d8                	mov    %ebx,%eax
  801ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	56                   	push   %esi
  801edc:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801edd:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ee0:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ee5:	eb 03                	jmp    801eea <spawnl+0x12>
		argc++;
  801ee7:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801eea:	83 c2 04             	add    $0x4,%edx
  801eed:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ef1:	75 f4                	jne    801ee7 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ef3:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801efa:	83 e2 f0             	and    $0xfffffff0,%edx
  801efd:	29 d4                	sub    %edx,%esp
  801eff:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f03:	c1 ea 02             	shr    $0x2,%edx
  801f06:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f0d:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f12:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f19:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f20:	00 
  801f21:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
  801f28:	eb 0a                	jmp    801f34 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f2a:	83 c0 01             	add    $0x1,%eax
  801f2d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f31:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f34:	39 d0                	cmp    %edx,%eax
  801f36:	75 f2                	jne    801f2a <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f38:	83 ec 08             	sub    $0x8,%esp
  801f3b:	56                   	push   %esi
  801f3c:	ff 75 08             	pushl  0x8(%ebp)
  801f3f:	e8 17 fa ff ff       	call   80195b <spawn>
}
  801f44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    

00801f4b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801f51:	68 5c 33 80 00       	push   $0x80335c
  801f56:	ff 75 0c             	pushl  0xc(%ebp)
  801f59:	e8 d8 e8 ff ff       	call   800836 <strcpy>
	return 0;
}
  801f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f63:	c9                   	leave  
  801f64:	c3                   	ret    

00801f65 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	53                   	push   %ebx
  801f69:	83 ec 10             	sub    $0x10,%esp
  801f6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f6f:	53                   	push   %ebx
  801f70:	e8 ca 0a 00 00       	call   802a3f <pageref>
  801f75:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801f78:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801f7d:	83 f8 01             	cmp    $0x1,%eax
  801f80:	75 10                	jne    801f92 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801f82:	83 ec 0c             	sub    $0xc,%esp
  801f85:	ff 73 0c             	pushl  0xc(%ebx)
  801f88:	e8 c0 02 00 00       	call   80224d <nsipc_close>
  801f8d:	89 c2                	mov    %eax,%edx
  801f8f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801f92:	89 d0                	mov    %edx,%eax
  801f94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f97:	c9                   	leave  
  801f98:	c3                   	ret    

00801f99 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f9f:	6a 00                	push   $0x0
  801fa1:	ff 75 10             	pushl  0x10(%ebp)
  801fa4:	ff 75 0c             	pushl  0xc(%ebp)
  801fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801faa:	ff 70 0c             	pushl  0xc(%eax)
  801fad:	e8 78 03 00 00       	call   80232a <nsipc_send>
}
  801fb2:	c9                   	leave  
  801fb3:	c3                   	ret    

00801fb4 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801fba:	6a 00                	push   $0x0
  801fbc:	ff 75 10             	pushl  0x10(%ebp)
  801fbf:	ff 75 0c             	pushl  0xc(%ebp)
  801fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc5:	ff 70 0c             	pushl  0xc(%eax)
  801fc8:	e8 f1 02 00 00       	call   8022be <nsipc_recv>
}
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    

00801fcf <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801fd5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801fd8:	52                   	push   %edx
  801fd9:	50                   	push   %eax
  801fda:	e8 f4 f1 ff ff       	call   8011d3 <fd_lookup>
  801fdf:	83 c4 10             	add    $0x10,%esp
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	78 17                	js     801ffd <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe9:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  801fef:	39 08                	cmp    %ecx,(%eax)
  801ff1:	75 05                	jne    801ff8 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ff3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ff6:	eb 05                	jmp    801ffd <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ff8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ffd:	c9                   	leave  
  801ffe:	c3                   	ret    

00801fff <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
  802007:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802009:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200c:	50                   	push   %eax
  80200d:	e8 72 f1 ff ff       	call   801184 <fd_alloc>
  802012:	89 c3                	mov    %eax,%ebx
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	85 c0                	test   %eax,%eax
  802019:	78 1b                	js     802036 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80201b:	83 ec 04             	sub    $0x4,%esp
  80201e:	68 07 04 00 00       	push   $0x407
  802023:	ff 75 f4             	pushl  -0xc(%ebp)
  802026:	6a 00                	push   $0x0
  802028:	e8 0c ec ff ff       	call   800c39 <sys_page_alloc>
  80202d:	89 c3                	mov    %eax,%ebx
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	85 c0                	test   %eax,%eax
  802034:	79 10                	jns    802046 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802036:	83 ec 0c             	sub    $0xc,%esp
  802039:	56                   	push   %esi
  80203a:	e8 0e 02 00 00       	call   80224d <nsipc_close>
		return r;
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	89 d8                	mov    %ebx,%eax
  802044:	eb 24                	jmp    80206a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802046:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80204c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802051:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802054:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80205b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80205e:	83 ec 0c             	sub    $0xc,%esp
  802061:	50                   	push   %eax
  802062:	e8 f6 f0 ff ff       	call   80115d <fd2num>
  802067:	83 c4 10             	add    $0x10,%esp
}
  80206a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5d                   	pop    %ebp
  802070:	c3                   	ret    

00802071 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802077:	8b 45 08             	mov    0x8(%ebp),%eax
  80207a:	e8 50 ff ff ff       	call   801fcf <fd2sockid>
		return r;
  80207f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802081:	85 c0                	test   %eax,%eax
  802083:	78 1f                	js     8020a4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802085:	83 ec 04             	sub    $0x4,%esp
  802088:	ff 75 10             	pushl  0x10(%ebp)
  80208b:	ff 75 0c             	pushl  0xc(%ebp)
  80208e:	50                   	push   %eax
  80208f:	e8 12 01 00 00       	call   8021a6 <nsipc_accept>
  802094:	83 c4 10             	add    $0x10,%esp
		return r;
  802097:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802099:	85 c0                	test   %eax,%eax
  80209b:	78 07                	js     8020a4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80209d:	e8 5d ff ff ff       	call   801fff <alloc_sockfd>
  8020a2:	89 c1                	mov    %eax,%ecx
}
  8020a4:	89 c8                	mov    %ecx,%eax
  8020a6:	c9                   	leave  
  8020a7:	c3                   	ret    

008020a8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b1:	e8 19 ff ff ff       	call   801fcf <fd2sockid>
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	78 12                	js     8020cc <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8020ba:	83 ec 04             	sub    $0x4,%esp
  8020bd:	ff 75 10             	pushl  0x10(%ebp)
  8020c0:	ff 75 0c             	pushl  0xc(%ebp)
  8020c3:	50                   	push   %eax
  8020c4:	e8 2d 01 00 00       	call   8021f6 <nsipc_bind>
  8020c9:	83 c4 10             	add    $0x10,%esp
}
  8020cc:	c9                   	leave  
  8020cd:	c3                   	ret    

008020ce <shutdown>:

int
shutdown(int s, int how)
{
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
  8020d1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d7:	e8 f3 fe ff ff       	call   801fcf <fd2sockid>
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	78 0f                	js     8020ef <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8020e0:	83 ec 08             	sub    $0x8,%esp
  8020e3:	ff 75 0c             	pushl  0xc(%ebp)
  8020e6:	50                   	push   %eax
  8020e7:	e8 3f 01 00 00       	call   80222b <nsipc_shutdown>
  8020ec:	83 c4 10             	add    $0x10,%esp
}
  8020ef:	c9                   	leave  
  8020f0:	c3                   	ret    

008020f1 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fa:	e8 d0 fe ff ff       	call   801fcf <fd2sockid>
  8020ff:	85 c0                	test   %eax,%eax
  802101:	78 12                	js     802115 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802103:	83 ec 04             	sub    $0x4,%esp
  802106:	ff 75 10             	pushl  0x10(%ebp)
  802109:	ff 75 0c             	pushl  0xc(%ebp)
  80210c:	50                   	push   %eax
  80210d:	e8 55 01 00 00       	call   802267 <nsipc_connect>
  802112:	83 c4 10             	add    $0x10,%esp
}
  802115:	c9                   	leave  
  802116:	c3                   	ret    

00802117 <listen>:

int
listen(int s, int backlog)
{
  802117:	55                   	push   %ebp
  802118:	89 e5                	mov    %esp,%ebp
  80211a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80211d:	8b 45 08             	mov    0x8(%ebp),%eax
  802120:	e8 aa fe ff ff       	call   801fcf <fd2sockid>
  802125:	85 c0                	test   %eax,%eax
  802127:	78 0f                	js     802138 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802129:	83 ec 08             	sub    $0x8,%esp
  80212c:	ff 75 0c             	pushl  0xc(%ebp)
  80212f:	50                   	push   %eax
  802130:	e8 67 01 00 00       	call   80229c <nsipc_listen>
  802135:	83 c4 10             	add    $0x10,%esp
}
  802138:	c9                   	leave  
  802139:	c3                   	ret    

0080213a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802140:	ff 75 10             	pushl  0x10(%ebp)
  802143:	ff 75 0c             	pushl  0xc(%ebp)
  802146:	ff 75 08             	pushl  0x8(%ebp)
  802149:	e8 3a 02 00 00       	call   802388 <nsipc_socket>
  80214e:	83 c4 10             	add    $0x10,%esp
  802151:	85 c0                	test   %eax,%eax
  802153:	78 05                	js     80215a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802155:	e8 a5 fe ff ff       	call   801fff <alloc_sockfd>
}
  80215a:	c9                   	leave  
  80215b:	c3                   	ret    

0080215c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	53                   	push   %ebx
  802160:	83 ec 04             	sub    $0x4,%esp
  802163:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802165:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80216c:	75 12                	jne    802180 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80216e:	83 ec 0c             	sub    $0xc,%esp
  802171:	6a 02                	push   $0x2
  802173:	e8 8e 08 00 00       	call   802a06 <ipc_find_env>
  802178:	a3 04 50 80 00       	mov    %eax,0x805004
  80217d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802180:	6a 07                	push   $0x7
  802182:	68 00 70 80 00       	push   $0x807000
  802187:	53                   	push   %ebx
  802188:	ff 35 04 50 80 00    	pushl  0x805004
  80218e:	e8 1f 08 00 00       	call   8029b2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802193:	83 c4 0c             	add    $0xc,%esp
  802196:	6a 00                	push   $0x0
  802198:	6a 00                	push   $0x0
  80219a:	6a 00                	push   $0x0
  80219c:	e8 aa 07 00 00       	call   80294b <ipc_recv>
}
  8021a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021a4:	c9                   	leave  
  8021a5:	c3                   	ret    

008021a6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	56                   	push   %esi
  8021aa:	53                   	push   %ebx
  8021ab:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8021ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8021b6:	8b 06                	mov    (%esi),%eax
  8021b8:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8021bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c2:	e8 95 ff ff ff       	call   80215c <nsipc>
  8021c7:	89 c3                	mov    %eax,%ebx
  8021c9:	85 c0                	test   %eax,%eax
  8021cb:	78 20                	js     8021ed <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021cd:	83 ec 04             	sub    $0x4,%esp
  8021d0:	ff 35 10 70 80 00    	pushl  0x807010
  8021d6:	68 00 70 80 00       	push   $0x807000
  8021db:	ff 75 0c             	pushl  0xc(%ebp)
  8021de:	e8 e5 e7 ff ff       	call   8009c8 <memmove>
		*addrlen = ret->ret_addrlen;
  8021e3:	a1 10 70 80 00       	mov    0x807010,%eax
  8021e8:	89 06                	mov    %eax,(%esi)
  8021ea:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8021ed:	89 d8                	mov    %ebx,%eax
  8021ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f2:	5b                   	pop    %ebx
  8021f3:	5e                   	pop    %esi
  8021f4:	5d                   	pop    %ebp
  8021f5:	c3                   	ret    

008021f6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8021f6:	55                   	push   %ebp
  8021f7:	89 e5                	mov    %esp,%ebp
  8021f9:	53                   	push   %ebx
  8021fa:	83 ec 08             	sub    $0x8,%esp
  8021fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802200:	8b 45 08             	mov    0x8(%ebp),%eax
  802203:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802208:	53                   	push   %ebx
  802209:	ff 75 0c             	pushl  0xc(%ebp)
  80220c:	68 04 70 80 00       	push   $0x807004
  802211:	e8 b2 e7 ff ff       	call   8009c8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802216:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80221c:	b8 02 00 00 00       	mov    $0x2,%eax
  802221:	e8 36 ff ff ff       	call   80215c <nsipc>
}
  802226:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802229:	c9                   	leave  
  80222a:	c3                   	ret    

0080222b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802231:	8b 45 08             	mov    0x8(%ebp),%eax
  802234:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802239:	8b 45 0c             	mov    0xc(%ebp),%eax
  80223c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802241:	b8 03 00 00 00       	mov    $0x3,%eax
  802246:	e8 11 ff ff ff       	call   80215c <nsipc>
}
  80224b:	c9                   	leave  
  80224c:	c3                   	ret    

0080224d <nsipc_close>:

int
nsipc_close(int s)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802253:	8b 45 08             	mov    0x8(%ebp),%eax
  802256:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80225b:	b8 04 00 00 00       	mov    $0x4,%eax
  802260:	e8 f7 fe ff ff       	call   80215c <nsipc>
}
  802265:	c9                   	leave  
  802266:	c3                   	ret    

00802267 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
  80226a:	53                   	push   %ebx
  80226b:	83 ec 08             	sub    $0x8,%esp
  80226e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802271:	8b 45 08             	mov    0x8(%ebp),%eax
  802274:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802279:	53                   	push   %ebx
  80227a:	ff 75 0c             	pushl  0xc(%ebp)
  80227d:	68 04 70 80 00       	push   $0x807004
  802282:	e8 41 e7 ff ff       	call   8009c8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802287:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80228d:	b8 05 00 00 00       	mov    $0x5,%eax
  802292:	e8 c5 fe ff ff       	call   80215c <nsipc>
}
  802297:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80229a:	c9                   	leave  
  80229b:	c3                   	ret    

0080229c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8022aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ad:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8022b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8022b7:	e8 a0 fe ff ff       	call   80215c <nsipc>
}
  8022bc:	c9                   	leave  
  8022bd:	c3                   	ret    

008022be <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022be:	55                   	push   %ebp
  8022bf:	89 e5                	mov    %esp,%ebp
  8022c1:	56                   	push   %esi
  8022c2:	53                   	push   %ebx
  8022c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8022ce:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8022d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8022d7:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022dc:	b8 07 00 00 00       	mov    $0x7,%eax
  8022e1:	e8 76 fe ff ff       	call   80215c <nsipc>
  8022e6:	89 c3                	mov    %eax,%ebx
  8022e8:	85 c0                	test   %eax,%eax
  8022ea:	78 35                	js     802321 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8022ec:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022f1:	7f 04                	jg     8022f7 <nsipc_recv+0x39>
  8022f3:	39 c6                	cmp    %eax,%esi
  8022f5:	7d 16                	jge    80230d <nsipc_recv+0x4f>
  8022f7:	68 68 33 80 00       	push   $0x803368
  8022fc:	68 7b 32 80 00       	push   $0x80327b
  802301:	6a 62                	push   $0x62
  802303:	68 7d 33 80 00       	push   $0x80337d
  802308:	e8 cb de ff ff       	call   8001d8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80230d:	83 ec 04             	sub    $0x4,%esp
  802310:	50                   	push   %eax
  802311:	68 00 70 80 00       	push   $0x807000
  802316:	ff 75 0c             	pushl  0xc(%ebp)
  802319:	e8 aa e6 ff ff       	call   8009c8 <memmove>
  80231e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802321:	89 d8                	mov    %ebx,%eax
  802323:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802326:	5b                   	pop    %ebx
  802327:	5e                   	pop    %esi
  802328:	5d                   	pop    %ebp
  802329:	c3                   	ret    

0080232a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80232a:	55                   	push   %ebp
  80232b:	89 e5                	mov    %esp,%ebp
  80232d:	53                   	push   %ebx
  80232e:	83 ec 04             	sub    $0x4,%esp
  802331:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802334:	8b 45 08             	mov    0x8(%ebp),%eax
  802337:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80233c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802342:	7e 16                	jle    80235a <nsipc_send+0x30>
  802344:	68 89 33 80 00       	push   $0x803389
  802349:	68 7b 32 80 00       	push   $0x80327b
  80234e:	6a 6d                	push   $0x6d
  802350:	68 7d 33 80 00       	push   $0x80337d
  802355:	e8 7e de ff ff       	call   8001d8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80235a:	83 ec 04             	sub    $0x4,%esp
  80235d:	53                   	push   %ebx
  80235e:	ff 75 0c             	pushl  0xc(%ebp)
  802361:	68 0c 70 80 00       	push   $0x80700c
  802366:	e8 5d e6 ff ff       	call   8009c8 <memmove>
	nsipcbuf.send.req_size = size;
  80236b:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802371:	8b 45 14             	mov    0x14(%ebp),%eax
  802374:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802379:	b8 08 00 00 00       	mov    $0x8,%eax
  80237e:	e8 d9 fd ff ff       	call   80215c <nsipc>
}
  802383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802386:	c9                   	leave  
  802387:	c3                   	ret    

00802388 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802388:	55                   	push   %ebp
  802389:	89 e5                	mov    %esp,%ebp
  80238b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80238e:	8b 45 08             	mov    0x8(%ebp),%eax
  802391:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802396:	8b 45 0c             	mov    0xc(%ebp),%eax
  802399:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80239e:	8b 45 10             	mov    0x10(%ebp),%eax
  8023a1:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8023a6:	b8 09 00 00 00       	mov    $0x9,%eax
  8023ab:	e8 ac fd ff ff       	call   80215c <nsipc>
}
  8023b0:	c9                   	leave  
  8023b1:	c3                   	ret    

008023b2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023b2:	55                   	push   %ebp
  8023b3:	89 e5                	mov    %esp,%ebp
  8023b5:	56                   	push   %esi
  8023b6:	53                   	push   %ebx
  8023b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023ba:	83 ec 0c             	sub    $0xc,%esp
  8023bd:	ff 75 08             	pushl  0x8(%ebp)
  8023c0:	e8 a8 ed ff ff       	call   80116d <fd2data>
  8023c5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8023c7:	83 c4 08             	add    $0x8,%esp
  8023ca:	68 95 33 80 00       	push   $0x803395
  8023cf:	53                   	push   %ebx
  8023d0:	e8 61 e4 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8023d5:	8b 46 04             	mov    0x4(%esi),%eax
  8023d8:	2b 06                	sub    (%esi),%eax
  8023da:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8023e0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8023e7:	00 00 00 
	stat->st_dev = &devpipe;
  8023ea:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  8023f1:	40 80 00 
	return 0;
}
  8023f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8023f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023fc:	5b                   	pop    %ebx
  8023fd:	5e                   	pop    %esi
  8023fe:	5d                   	pop    %ebp
  8023ff:	c3                   	ret    

00802400 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	53                   	push   %ebx
  802404:	83 ec 0c             	sub    $0xc,%esp
  802407:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80240a:	53                   	push   %ebx
  80240b:	6a 00                	push   $0x0
  80240d:	e8 ac e8 ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802412:	89 1c 24             	mov    %ebx,(%esp)
  802415:	e8 53 ed ff ff       	call   80116d <fd2data>
  80241a:	83 c4 08             	add    $0x8,%esp
  80241d:	50                   	push   %eax
  80241e:	6a 00                	push   $0x0
  802420:	e8 99 e8 ff ff       	call   800cbe <sys_page_unmap>
}
  802425:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802428:	c9                   	leave  
  802429:	c3                   	ret    

0080242a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80242a:	55                   	push   %ebp
  80242b:	89 e5                	mov    %esp,%ebp
  80242d:	57                   	push   %edi
  80242e:	56                   	push   %esi
  80242f:	53                   	push   %ebx
  802430:	83 ec 1c             	sub    $0x1c,%esp
  802433:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802436:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802438:	a1 08 50 80 00       	mov    0x805008,%eax
  80243d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802440:	83 ec 0c             	sub    $0xc,%esp
  802443:	ff 75 e0             	pushl  -0x20(%ebp)
  802446:	e8 f4 05 00 00       	call   802a3f <pageref>
  80244b:	89 c3                	mov    %eax,%ebx
  80244d:	89 3c 24             	mov    %edi,(%esp)
  802450:	e8 ea 05 00 00       	call   802a3f <pageref>
  802455:	83 c4 10             	add    $0x10,%esp
  802458:	39 c3                	cmp    %eax,%ebx
  80245a:	0f 94 c1             	sete   %cl
  80245d:	0f b6 c9             	movzbl %cl,%ecx
  802460:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802463:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802469:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80246c:	39 ce                	cmp    %ecx,%esi
  80246e:	74 1b                	je     80248b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802470:	39 c3                	cmp    %eax,%ebx
  802472:	75 c4                	jne    802438 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802474:	8b 42 58             	mov    0x58(%edx),%eax
  802477:	ff 75 e4             	pushl  -0x1c(%ebp)
  80247a:	50                   	push   %eax
  80247b:	56                   	push   %esi
  80247c:	68 9c 33 80 00       	push   $0x80339c
  802481:	e8 2b de ff ff       	call   8002b1 <cprintf>
  802486:	83 c4 10             	add    $0x10,%esp
  802489:	eb ad                	jmp    802438 <_pipeisclosed+0xe>
	}
}
  80248b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80248e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802491:	5b                   	pop    %ebx
  802492:	5e                   	pop    %esi
  802493:	5f                   	pop    %edi
  802494:	5d                   	pop    %ebp
  802495:	c3                   	ret    

00802496 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802496:	55                   	push   %ebp
  802497:	89 e5                	mov    %esp,%ebp
  802499:	57                   	push   %edi
  80249a:	56                   	push   %esi
  80249b:	53                   	push   %ebx
  80249c:	83 ec 28             	sub    $0x28,%esp
  80249f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8024a2:	56                   	push   %esi
  8024a3:	e8 c5 ec ff ff       	call   80116d <fd2data>
  8024a8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024aa:	83 c4 10             	add    $0x10,%esp
  8024ad:	bf 00 00 00 00       	mov    $0x0,%edi
  8024b2:	eb 4b                	jmp    8024ff <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8024b4:	89 da                	mov    %ebx,%edx
  8024b6:	89 f0                	mov    %esi,%eax
  8024b8:	e8 6d ff ff ff       	call   80242a <_pipeisclosed>
  8024bd:	85 c0                	test   %eax,%eax
  8024bf:	75 48                	jne    802509 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8024c1:	e8 54 e7 ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8024c6:	8b 43 04             	mov    0x4(%ebx),%eax
  8024c9:	8b 0b                	mov    (%ebx),%ecx
  8024cb:	8d 51 20             	lea    0x20(%ecx),%edx
  8024ce:	39 d0                	cmp    %edx,%eax
  8024d0:	73 e2                	jae    8024b4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8024d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024d5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8024d9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8024dc:	89 c2                	mov    %eax,%edx
  8024de:	c1 fa 1f             	sar    $0x1f,%edx
  8024e1:	89 d1                	mov    %edx,%ecx
  8024e3:	c1 e9 1b             	shr    $0x1b,%ecx
  8024e6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8024e9:	83 e2 1f             	and    $0x1f,%edx
  8024ec:	29 ca                	sub    %ecx,%edx
  8024ee:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8024f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8024f6:	83 c0 01             	add    $0x1,%eax
  8024f9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024fc:	83 c7 01             	add    $0x1,%edi
  8024ff:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802502:	75 c2                	jne    8024c6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802504:	8b 45 10             	mov    0x10(%ebp),%eax
  802507:	eb 05                	jmp    80250e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802509:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80250e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802511:	5b                   	pop    %ebx
  802512:	5e                   	pop    %esi
  802513:	5f                   	pop    %edi
  802514:	5d                   	pop    %ebp
  802515:	c3                   	ret    

00802516 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802516:	55                   	push   %ebp
  802517:	89 e5                	mov    %esp,%ebp
  802519:	57                   	push   %edi
  80251a:	56                   	push   %esi
  80251b:	53                   	push   %ebx
  80251c:	83 ec 18             	sub    $0x18,%esp
  80251f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802522:	57                   	push   %edi
  802523:	e8 45 ec ff ff       	call   80116d <fd2data>
  802528:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80252a:	83 c4 10             	add    $0x10,%esp
  80252d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802532:	eb 3d                	jmp    802571 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802534:	85 db                	test   %ebx,%ebx
  802536:	74 04                	je     80253c <devpipe_read+0x26>
				return i;
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	eb 44                	jmp    802580 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80253c:	89 f2                	mov    %esi,%edx
  80253e:	89 f8                	mov    %edi,%eax
  802540:	e8 e5 fe ff ff       	call   80242a <_pipeisclosed>
  802545:	85 c0                	test   %eax,%eax
  802547:	75 32                	jne    80257b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802549:	e8 cc e6 ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80254e:	8b 06                	mov    (%esi),%eax
  802550:	3b 46 04             	cmp    0x4(%esi),%eax
  802553:	74 df                	je     802534 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802555:	99                   	cltd   
  802556:	c1 ea 1b             	shr    $0x1b,%edx
  802559:	01 d0                	add    %edx,%eax
  80255b:	83 e0 1f             	and    $0x1f,%eax
  80255e:	29 d0                	sub    %edx,%eax
  802560:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802565:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802568:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80256b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80256e:	83 c3 01             	add    $0x1,%ebx
  802571:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802574:	75 d8                	jne    80254e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802576:	8b 45 10             	mov    0x10(%ebp),%eax
  802579:	eb 05                	jmp    802580 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80257b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802580:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802583:	5b                   	pop    %ebx
  802584:	5e                   	pop    %esi
  802585:	5f                   	pop    %edi
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    

00802588 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802588:	55                   	push   %ebp
  802589:	89 e5                	mov    %esp,%ebp
  80258b:	56                   	push   %esi
  80258c:	53                   	push   %ebx
  80258d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802590:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802593:	50                   	push   %eax
  802594:	e8 eb eb ff ff       	call   801184 <fd_alloc>
  802599:	83 c4 10             	add    $0x10,%esp
  80259c:	89 c2                	mov    %eax,%edx
  80259e:	85 c0                	test   %eax,%eax
  8025a0:	0f 88 2c 01 00 00    	js     8026d2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025a6:	83 ec 04             	sub    $0x4,%esp
  8025a9:	68 07 04 00 00       	push   $0x407
  8025ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8025b1:	6a 00                	push   $0x0
  8025b3:	e8 81 e6 ff ff       	call   800c39 <sys_page_alloc>
  8025b8:	83 c4 10             	add    $0x10,%esp
  8025bb:	89 c2                	mov    %eax,%edx
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	0f 88 0d 01 00 00    	js     8026d2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8025c5:	83 ec 0c             	sub    $0xc,%esp
  8025c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8025cb:	50                   	push   %eax
  8025cc:	e8 b3 eb ff ff       	call   801184 <fd_alloc>
  8025d1:	89 c3                	mov    %eax,%ebx
  8025d3:	83 c4 10             	add    $0x10,%esp
  8025d6:	85 c0                	test   %eax,%eax
  8025d8:	0f 88 e2 00 00 00    	js     8026c0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025de:	83 ec 04             	sub    $0x4,%esp
  8025e1:	68 07 04 00 00       	push   $0x407
  8025e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8025e9:	6a 00                	push   $0x0
  8025eb:	e8 49 e6 ff ff       	call   800c39 <sys_page_alloc>
  8025f0:	89 c3                	mov    %eax,%ebx
  8025f2:	83 c4 10             	add    $0x10,%esp
  8025f5:	85 c0                	test   %eax,%eax
  8025f7:	0f 88 c3 00 00 00    	js     8026c0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8025fd:	83 ec 0c             	sub    $0xc,%esp
  802600:	ff 75 f4             	pushl  -0xc(%ebp)
  802603:	e8 65 eb ff ff       	call   80116d <fd2data>
  802608:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80260a:	83 c4 0c             	add    $0xc,%esp
  80260d:	68 07 04 00 00       	push   $0x407
  802612:	50                   	push   %eax
  802613:	6a 00                	push   $0x0
  802615:	e8 1f e6 ff ff       	call   800c39 <sys_page_alloc>
  80261a:	89 c3                	mov    %eax,%ebx
  80261c:	83 c4 10             	add    $0x10,%esp
  80261f:	85 c0                	test   %eax,%eax
  802621:	0f 88 89 00 00 00    	js     8026b0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802627:	83 ec 0c             	sub    $0xc,%esp
  80262a:	ff 75 f0             	pushl  -0x10(%ebp)
  80262d:	e8 3b eb ff ff       	call   80116d <fd2data>
  802632:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802639:	50                   	push   %eax
  80263a:	6a 00                	push   $0x0
  80263c:	56                   	push   %esi
  80263d:	6a 00                	push   $0x0
  80263f:	e8 38 e6 ff ff       	call   800c7c <sys_page_map>
  802644:	89 c3                	mov    %eax,%ebx
  802646:	83 c4 20             	add    $0x20,%esp
  802649:	85 c0                	test   %eax,%eax
  80264b:	78 55                	js     8026a2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80264d:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802656:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802658:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80265b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802662:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802668:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80266b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80266d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802670:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802677:	83 ec 0c             	sub    $0xc,%esp
  80267a:	ff 75 f4             	pushl  -0xc(%ebp)
  80267d:	e8 db ea ff ff       	call   80115d <fd2num>
  802682:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802685:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802687:	83 c4 04             	add    $0x4,%esp
  80268a:	ff 75 f0             	pushl  -0x10(%ebp)
  80268d:	e8 cb ea ff ff       	call   80115d <fd2num>
  802692:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802695:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802698:	83 c4 10             	add    $0x10,%esp
  80269b:	ba 00 00 00 00       	mov    $0x0,%edx
  8026a0:	eb 30                	jmp    8026d2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8026a2:	83 ec 08             	sub    $0x8,%esp
  8026a5:	56                   	push   %esi
  8026a6:	6a 00                	push   $0x0
  8026a8:	e8 11 e6 ff ff       	call   800cbe <sys_page_unmap>
  8026ad:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8026b0:	83 ec 08             	sub    $0x8,%esp
  8026b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8026b6:	6a 00                	push   $0x0
  8026b8:	e8 01 e6 ff ff       	call   800cbe <sys_page_unmap>
  8026bd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8026c0:	83 ec 08             	sub    $0x8,%esp
  8026c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8026c6:	6a 00                	push   $0x0
  8026c8:	e8 f1 e5 ff ff       	call   800cbe <sys_page_unmap>
  8026cd:	83 c4 10             	add    $0x10,%esp
  8026d0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8026d2:	89 d0                	mov    %edx,%eax
  8026d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026d7:	5b                   	pop    %ebx
  8026d8:	5e                   	pop    %esi
  8026d9:	5d                   	pop    %ebp
  8026da:	c3                   	ret    

008026db <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8026db:	55                   	push   %ebp
  8026dc:	89 e5                	mov    %esp,%ebp
  8026de:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026e4:	50                   	push   %eax
  8026e5:	ff 75 08             	pushl  0x8(%ebp)
  8026e8:	e8 e6 ea ff ff       	call   8011d3 <fd_lookup>
  8026ed:	83 c4 10             	add    $0x10,%esp
  8026f0:	85 c0                	test   %eax,%eax
  8026f2:	78 18                	js     80270c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8026f4:	83 ec 0c             	sub    $0xc,%esp
  8026f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8026fa:	e8 6e ea ff ff       	call   80116d <fd2data>
	return _pipeisclosed(fd, p);
  8026ff:	89 c2                	mov    %eax,%edx
  802701:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802704:	e8 21 fd ff ff       	call   80242a <_pipeisclosed>
  802709:	83 c4 10             	add    $0x10,%esp
}
  80270c:	c9                   	leave  
  80270d:	c3                   	ret    

0080270e <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80270e:	55                   	push   %ebp
  80270f:	89 e5                	mov    %esp,%ebp
  802711:	56                   	push   %esi
  802712:	53                   	push   %ebx
  802713:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802716:	85 f6                	test   %esi,%esi
  802718:	75 16                	jne    802730 <wait+0x22>
  80271a:	68 b4 33 80 00       	push   $0x8033b4
  80271f:	68 7b 32 80 00       	push   $0x80327b
  802724:	6a 09                	push   $0x9
  802726:	68 bf 33 80 00       	push   $0x8033bf
  80272b:	e8 a8 da ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  802730:	89 f3                	mov    %esi,%ebx
  802732:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802738:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80273b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802741:	eb 05                	jmp    802748 <wait+0x3a>
		sys_yield();
  802743:	e8 d2 e4 ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802748:	8b 43 48             	mov    0x48(%ebx),%eax
  80274b:	39 c6                	cmp    %eax,%esi
  80274d:	75 07                	jne    802756 <wait+0x48>
  80274f:	8b 43 54             	mov    0x54(%ebx),%eax
  802752:	85 c0                	test   %eax,%eax
  802754:	75 ed                	jne    802743 <wait+0x35>
		sys_yield();
}
  802756:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802759:	5b                   	pop    %ebx
  80275a:	5e                   	pop    %esi
  80275b:	5d                   	pop    %ebp
  80275c:	c3                   	ret    

0080275d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80275d:	55                   	push   %ebp
  80275e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802760:	b8 00 00 00 00       	mov    $0x0,%eax
  802765:	5d                   	pop    %ebp
  802766:	c3                   	ret    

00802767 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802767:	55                   	push   %ebp
  802768:	89 e5                	mov    %esp,%ebp
  80276a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80276d:	68 ca 33 80 00       	push   $0x8033ca
  802772:	ff 75 0c             	pushl  0xc(%ebp)
  802775:	e8 bc e0 ff ff       	call   800836 <strcpy>
	return 0;
}
  80277a:	b8 00 00 00 00       	mov    $0x0,%eax
  80277f:	c9                   	leave  
  802780:	c3                   	ret    

00802781 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802781:	55                   	push   %ebp
  802782:	89 e5                	mov    %esp,%ebp
  802784:	57                   	push   %edi
  802785:	56                   	push   %esi
  802786:	53                   	push   %ebx
  802787:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80278d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802792:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802798:	eb 2d                	jmp    8027c7 <devcons_write+0x46>
		m = n - tot;
  80279a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80279d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80279f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8027a2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8027a7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027aa:	83 ec 04             	sub    $0x4,%esp
  8027ad:	53                   	push   %ebx
  8027ae:	03 45 0c             	add    0xc(%ebp),%eax
  8027b1:	50                   	push   %eax
  8027b2:	57                   	push   %edi
  8027b3:	e8 10 e2 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  8027b8:	83 c4 08             	add    $0x8,%esp
  8027bb:	53                   	push   %ebx
  8027bc:	57                   	push   %edi
  8027bd:	e8 bb e3 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027c2:	01 de                	add    %ebx,%esi
  8027c4:	83 c4 10             	add    $0x10,%esp
  8027c7:	89 f0                	mov    %esi,%eax
  8027c9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027cc:	72 cc                	jb     80279a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8027ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027d1:	5b                   	pop    %ebx
  8027d2:	5e                   	pop    %esi
  8027d3:	5f                   	pop    %edi
  8027d4:	5d                   	pop    %ebp
  8027d5:	c3                   	ret    

008027d6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027d6:	55                   	push   %ebp
  8027d7:	89 e5                	mov    %esp,%ebp
  8027d9:	83 ec 08             	sub    $0x8,%esp
  8027dc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8027e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027e5:	74 2a                	je     802811 <devcons_read+0x3b>
  8027e7:	eb 05                	jmp    8027ee <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8027e9:	e8 2c e4 ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8027ee:	e8 a8 e3 ff ff       	call   800b9b <sys_cgetc>
  8027f3:	85 c0                	test   %eax,%eax
  8027f5:	74 f2                	je     8027e9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8027f7:	85 c0                	test   %eax,%eax
  8027f9:	78 16                	js     802811 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8027fb:	83 f8 04             	cmp    $0x4,%eax
  8027fe:	74 0c                	je     80280c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802800:	8b 55 0c             	mov    0xc(%ebp),%edx
  802803:	88 02                	mov    %al,(%edx)
	return 1;
  802805:	b8 01 00 00 00       	mov    $0x1,%eax
  80280a:	eb 05                	jmp    802811 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80280c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802811:	c9                   	leave  
  802812:	c3                   	ret    

00802813 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802813:	55                   	push   %ebp
  802814:	89 e5                	mov    %esp,%ebp
  802816:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802819:	8b 45 08             	mov    0x8(%ebp),%eax
  80281c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80281f:	6a 01                	push   $0x1
  802821:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802824:	50                   	push   %eax
  802825:	e8 53 e3 ff ff       	call   800b7d <sys_cputs>
}
  80282a:	83 c4 10             	add    $0x10,%esp
  80282d:	c9                   	leave  
  80282e:	c3                   	ret    

0080282f <getchar>:

int
getchar(void)
{
  80282f:	55                   	push   %ebp
  802830:	89 e5                	mov    %esp,%ebp
  802832:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802835:	6a 01                	push   $0x1
  802837:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80283a:	50                   	push   %eax
  80283b:	6a 00                	push   $0x0
  80283d:	e8 f7 eb ff ff       	call   801439 <read>
	if (r < 0)
  802842:	83 c4 10             	add    $0x10,%esp
  802845:	85 c0                	test   %eax,%eax
  802847:	78 0f                	js     802858 <getchar+0x29>
		return r;
	if (r < 1)
  802849:	85 c0                	test   %eax,%eax
  80284b:	7e 06                	jle    802853 <getchar+0x24>
		return -E_EOF;
	return c;
  80284d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802851:	eb 05                	jmp    802858 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802853:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802858:	c9                   	leave  
  802859:	c3                   	ret    

0080285a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80285a:	55                   	push   %ebp
  80285b:	89 e5                	mov    %esp,%ebp
  80285d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802863:	50                   	push   %eax
  802864:	ff 75 08             	pushl  0x8(%ebp)
  802867:	e8 67 e9 ff ff       	call   8011d3 <fd_lookup>
  80286c:	83 c4 10             	add    $0x10,%esp
  80286f:	85 c0                	test   %eax,%eax
  802871:	78 11                	js     802884 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802876:	8b 15 60 40 80 00    	mov    0x804060,%edx
  80287c:	39 10                	cmp    %edx,(%eax)
  80287e:	0f 94 c0             	sete   %al
  802881:	0f b6 c0             	movzbl %al,%eax
}
  802884:	c9                   	leave  
  802885:	c3                   	ret    

00802886 <opencons>:

int
opencons(void)
{
  802886:	55                   	push   %ebp
  802887:	89 e5                	mov    %esp,%ebp
  802889:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80288c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80288f:	50                   	push   %eax
  802890:	e8 ef e8 ff ff       	call   801184 <fd_alloc>
  802895:	83 c4 10             	add    $0x10,%esp
		return r;
  802898:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80289a:	85 c0                	test   %eax,%eax
  80289c:	78 3e                	js     8028dc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80289e:	83 ec 04             	sub    $0x4,%esp
  8028a1:	68 07 04 00 00       	push   $0x407
  8028a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8028a9:	6a 00                	push   $0x0
  8028ab:	e8 89 e3 ff ff       	call   800c39 <sys_page_alloc>
  8028b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8028b3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028b5:	85 c0                	test   %eax,%eax
  8028b7:	78 23                	js     8028dc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8028b9:	8b 15 60 40 80 00    	mov    0x804060,%edx
  8028bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028c2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028c7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028ce:	83 ec 0c             	sub    $0xc,%esp
  8028d1:	50                   	push   %eax
  8028d2:	e8 86 e8 ff ff       	call   80115d <fd2num>
  8028d7:	89 c2                	mov    %eax,%edx
  8028d9:	83 c4 10             	add    $0x10,%esp
}
  8028dc:	89 d0                	mov    %edx,%eax
  8028de:	c9                   	leave  
  8028df:	c3                   	ret    

008028e0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028e0:	55                   	push   %ebp
  8028e1:	89 e5                	mov    %esp,%ebp
  8028e3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028e6:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8028ed:	75 2e                	jne    80291d <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8028ef:	e8 07 e3 ff ff       	call   800bfb <sys_getenvid>
  8028f4:	83 ec 04             	sub    $0x4,%esp
  8028f7:	68 07 0e 00 00       	push   $0xe07
  8028fc:	68 00 f0 bf ee       	push   $0xeebff000
  802901:	50                   	push   %eax
  802902:	e8 32 e3 ff ff       	call   800c39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802907:	e8 ef e2 ff ff       	call   800bfb <sys_getenvid>
  80290c:	83 c4 08             	add    $0x8,%esp
  80290f:	68 27 29 80 00       	push   $0x802927
  802914:	50                   	push   %eax
  802915:	e8 6a e4 ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
  80291a:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80291d:	8b 45 08             	mov    0x8(%ebp),%eax
  802920:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802925:	c9                   	leave  
  802926:	c3                   	ret    

00802927 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802927:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802928:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80292d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80292f:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802932:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802936:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80293a:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80293d:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802940:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802941:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802944:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802945:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802946:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80294a:	c3                   	ret    

0080294b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80294b:	55                   	push   %ebp
  80294c:	89 e5                	mov    %esp,%ebp
  80294e:	56                   	push   %esi
  80294f:	53                   	push   %ebx
  802950:	8b 75 08             	mov    0x8(%ebp),%esi
  802953:	8b 45 0c             	mov    0xc(%ebp),%eax
  802956:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802959:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80295b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802960:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802963:	83 ec 0c             	sub    $0xc,%esp
  802966:	50                   	push   %eax
  802967:	e8 7d e4 ff ff       	call   800de9 <sys_ipc_recv>

	if (from_env_store != NULL)
  80296c:	83 c4 10             	add    $0x10,%esp
  80296f:	85 f6                	test   %esi,%esi
  802971:	74 14                	je     802987 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802973:	ba 00 00 00 00       	mov    $0x0,%edx
  802978:	85 c0                	test   %eax,%eax
  80297a:	78 09                	js     802985 <ipc_recv+0x3a>
  80297c:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802982:	8b 52 74             	mov    0x74(%edx),%edx
  802985:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802987:	85 db                	test   %ebx,%ebx
  802989:	74 14                	je     80299f <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80298b:	ba 00 00 00 00       	mov    $0x0,%edx
  802990:	85 c0                	test   %eax,%eax
  802992:	78 09                	js     80299d <ipc_recv+0x52>
  802994:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80299a:	8b 52 78             	mov    0x78(%edx),%edx
  80299d:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80299f:	85 c0                	test   %eax,%eax
  8029a1:	78 08                	js     8029ab <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8029a3:	a1 08 50 80 00       	mov    0x805008,%eax
  8029a8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8029ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029ae:	5b                   	pop    %ebx
  8029af:	5e                   	pop    %esi
  8029b0:	5d                   	pop    %ebp
  8029b1:	c3                   	ret    

008029b2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029b2:	55                   	push   %ebp
  8029b3:	89 e5                	mov    %esp,%ebp
  8029b5:	57                   	push   %edi
  8029b6:	56                   	push   %esi
  8029b7:	53                   	push   %ebx
  8029b8:	83 ec 0c             	sub    $0xc,%esp
  8029bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8029be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8029c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8029c4:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8029c6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8029cb:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8029ce:	ff 75 14             	pushl  0x14(%ebp)
  8029d1:	53                   	push   %ebx
  8029d2:	56                   	push   %esi
  8029d3:	57                   	push   %edi
  8029d4:	e8 ed e3 ff ff       	call   800dc6 <sys_ipc_try_send>

		if (err < 0) {
  8029d9:	83 c4 10             	add    $0x10,%esp
  8029dc:	85 c0                	test   %eax,%eax
  8029de:	79 1e                	jns    8029fe <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8029e0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029e3:	75 07                	jne    8029ec <ipc_send+0x3a>
				sys_yield();
  8029e5:	e8 30 e2 ff ff       	call   800c1a <sys_yield>
  8029ea:	eb e2                	jmp    8029ce <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8029ec:	50                   	push   %eax
  8029ed:	68 d6 33 80 00       	push   $0x8033d6
  8029f2:	6a 49                	push   $0x49
  8029f4:	68 e3 33 80 00       	push   $0x8033e3
  8029f9:	e8 da d7 ff ff       	call   8001d8 <_panic>
		}

	} while (err < 0);

}
  8029fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a01:	5b                   	pop    %ebx
  802a02:	5e                   	pop    %esi
  802a03:	5f                   	pop    %edi
  802a04:	5d                   	pop    %ebp
  802a05:	c3                   	ret    

00802a06 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a06:	55                   	push   %ebp
  802a07:	89 e5                	mov    %esp,%ebp
  802a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a0c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a11:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a14:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a1a:	8b 52 50             	mov    0x50(%edx),%edx
  802a1d:	39 ca                	cmp    %ecx,%edx
  802a1f:	75 0d                	jne    802a2e <ipc_find_env+0x28>
			return envs[i].env_id;
  802a21:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a29:	8b 40 48             	mov    0x48(%eax),%eax
  802a2c:	eb 0f                	jmp    802a3d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a2e:	83 c0 01             	add    $0x1,%eax
  802a31:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a36:	75 d9                	jne    802a11 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a3d:	5d                   	pop    %ebp
  802a3e:	c3                   	ret    

00802a3f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a3f:	55                   	push   %ebp
  802a40:	89 e5                	mov    %esp,%ebp
  802a42:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a45:	89 d0                	mov    %edx,%eax
  802a47:	c1 e8 16             	shr    $0x16,%eax
  802a4a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802a51:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a56:	f6 c1 01             	test   $0x1,%cl
  802a59:	74 1d                	je     802a78 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a5b:	c1 ea 0c             	shr    $0xc,%edx
  802a5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a65:	f6 c2 01             	test   $0x1,%dl
  802a68:	74 0e                	je     802a78 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a6a:	c1 ea 0c             	shr    $0xc,%edx
  802a6d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802a74:	ef 
  802a75:	0f b7 c0             	movzwl %ax,%eax
}
  802a78:	5d                   	pop    %ebp
  802a79:	c3                   	ret    
  802a7a:	66 90                	xchg   %ax,%ax
  802a7c:	66 90                	xchg   %ax,%ax
  802a7e:	66 90                	xchg   %ax,%ax

00802a80 <__udivdi3>:
  802a80:	55                   	push   %ebp
  802a81:	57                   	push   %edi
  802a82:	56                   	push   %esi
  802a83:	53                   	push   %ebx
  802a84:	83 ec 1c             	sub    $0x1c,%esp
  802a87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802a8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802a8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802a93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a97:	85 f6                	test   %esi,%esi
  802a99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a9d:	89 ca                	mov    %ecx,%edx
  802a9f:	89 f8                	mov    %edi,%eax
  802aa1:	75 3d                	jne    802ae0 <__udivdi3+0x60>
  802aa3:	39 cf                	cmp    %ecx,%edi
  802aa5:	0f 87 c5 00 00 00    	ja     802b70 <__udivdi3+0xf0>
  802aab:	85 ff                	test   %edi,%edi
  802aad:	89 fd                	mov    %edi,%ebp
  802aaf:	75 0b                	jne    802abc <__udivdi3+0x3c>
  802ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  802ab6:	31 d2                	xor    %edx,%edx
  802ab8:	f7 f7                	div    %edi
  802aba:	89 c5                	mov    %eax,%ebp
  802abc:	89 c8                	mov    %ecx,%eax
  802abe:	31 d2                	xor    %edx,%edx
  802ac0:	f7 f5                	div    %ebp
  802ac2:	89 c1                	mov    %eax,%ecx
  802ac4:	89 d8                	mov    %ebx,%eax
  802ac6:	89 cf                	mov    %ecx,%edi
  802ac8:	f7 f5                	div    %ebp
  802aca:	89 c3                	mov    %eax,%ebx
  802acc:	89 d8                	mov    %ebx,%eax
  802ace:	89 fa                	mov    %edi,%edx
  802ad0:	83 c4 1c             	add    $0x1c,%esp
  802ad3:	5b                   	pop    %ebx
  802ad4:	5e                   	pop    %esi
  802ad5:	5f                   	pop    %edi
  802ad6:	5d                   	pop    %ebp
  802ad7:	c3                   	ret    
  802ad8:	90                   	nop
  802ad9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ae0:	39 ce                	cmp    %ecx,%esi
  802ae2:	77 74                	ja     802b58 <__udivdi3+0xd8>
  802ae4:	0f bd fe             	bsr    %esi,%edi
  802ae7:	83 f7 1f             	xor    $0x1f,%edi
  802aea:	0f 84 98 00 00 00    	je     802b88 <__udivdi3+0x108>
  802af0:	bb 20 00 00 00       	mov    $0x20,%ebx
  802af5:	89 f9                	mov    %edi,%ecx
  802af7:	89 c5                	mov    %eax,%ebp
  802af9:	29 fb                	sub    %edi,%ebx
  802afb:	d3 e6                	shl    %cl,%esi
  802afd:	89 d9                	mov    %ebx,%ecx
  802aff:	d3 ed                	shr    %cl,%ebp
  802b01:	89 f9                	mov    %edi,%ecx
  802b03:	d3 e0                	shl    %cl,%eax
  802b05:	09 ee                	or     %ebp,%esi
  802b07:	89 d9                	mov    %ebx,%ecx
  802b09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b0d:	89 d5                	mov    %edx,%ebp
  802b0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b13:	d3 ed                	shr    %cl,%ebp
  802b15:	89 f9                	mov    %edi,%ecx
  802b17:	d3 e2                	shl    %cl,%edx
  802b19:	89 d9                	mov    %ebx,%ecx
  802b1b:	d3 e8                	shr    %cl,%eax
  802b1d:	09 c2                	or     %eax,%edx
  802b1f:	89 d0                	mov    %edx,%eax
  802b21:	89 ea                	mov    %ebp,%edx
  802b23:	f7 f6                	div    %esi
  802b25:	89 d5                	mov    %edx,%ebp
  802b27:	89 c3                	mov    %eax,%ebx
  802b29:	f7 64 24 0c          	mull   0xc(%esp)
  802b2d:	39 d5                	cmp    %edx,%ebp
  802b2f:	72 10                	jb     802b41 <__udivdi3+0xc1>
  802b31:	8b 74 24 08          	mov    0x8(%esp),%esi
  802b35:	89 f9                	mov    %edi,%ecx
  802b37:	d3 e6                	shl    %cl,%esi
  802b39:	39 c6                	cmp    %eax,%esi
  802b3b:	73 07                	jae    802b44 <__udivdi3+0xc4>
  802b3d:	39 d5                	cmp    %edx,%ebp
  802b3f:	75 03                	jne    802b44 <__udivdi3+0xc4>
  802b41:	83 eb 01             	sub    $0x1,%ebx
  802b44:	31 ff                	xor    %edi,%edi
  802b46:	89 d8                	mov    %ebx,%eax
  802b48:	89 fa                	mov    %edi,%edx
  802b4a:	83 c4 1c             	add    $0x1c,%esp
  802b4d:	5b                   	pop    %ebx
  802b4e:	5e                   	pop    %esi
  802b4f:	5f                   	pop    %edi
  802b50:	5d                   	pop    %ebp
  802b51:	c3                   	ret    
  802b52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b58:	31 ff                	xor    %edi,%edi
  802b5a:	31 db                	xor    %ebx,%ebx
  802b5c:	89 d8                	mov    %ebx,%eax
  802b5e:	89 fa                	mov    %edi,%edx
  802b60:	83 c4 1c             	add    $0x1c,%esp
  802b63:	5b                   	pop    %ebx
  802b64:	5e                   	pop    %esi
  802b65:	5f                   	pop    %edi
  802b66:	5d                   	pop    %ebp
  802b67:	c3                   	ret    
  802b68:	90                   	nop
  802b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b70:	89 d8                	mov    %ebx,%eax
  802b72:	f7 f7                	div    %edi
  802b74:	31 ff                	xor    %edi,%edi
  802b76:	89 c3                	mov    %eax,%ebx
  802b78:	89 d8                	mov    %ebx,%eax
  802b7a:	89 fa                	mov    %edi,%edx
  802b7c:	83 c4 1c             	add    $0x1c,%esp
  802b7f:	5b                   	pop    %ebx
  802b80:	5e                   	pop    %esi
  802b81:	5f                   	pop    %edi
  802b82:	5d                   	pop    %ebp
  802b83:	c3                   	ret    
  802b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b88:	39 ce                	cmp    %ecx,%esi
  802b8a:	72 0c                	jb     802b98 <__udivdi3+0x118>
  802b8c:	31 db                	xor    %ebx,%ebx
  802b8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802b92:	0f 87 34 ff ff ff    	ja     802acc <__udivdi3+0x4c>
  802b98:	bb 01 00 00 00       	mov    $0x1,%ebx
  802b9d:	e9 2a ff ff ff       	jmp    802acc <__udivdi3+0x4c>
  802ba2:	66 90                	xchg   %ax,%ax
  802ba4:	66 90                	xchg   %ax,%ax
  802ba6:	66 90                	xchg   %ax,%ax
  802ba8:	66 90                	xchg   %ax,%ax
  802baa:	66 90                	xchg   %ax,%ax
  802bac:	66 90                	xchg   %ax,%ax
  802bae:	66 90                	xchg   %ax,%ax

00802bb0 <__umoddi3>:
  802bb0:	55                   	push   %ebp
  802bb1:	57                   	push   %edi
  802bb2:	56                   	push   %esi
  802bb3:	53                   	push   %ebx
  802bb4:	83 ec 1c             	sub    $0x1c,%esp
  802bb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802bbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802bbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  802bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802bc7:	85 d2                	test   %edx,%edx
  802bc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802bcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bd1:	89 f3                	mov    %esi,%ebx
  802bd3:	89 3c 24             	mov    %edi,(%esp)
  802bd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802bda:	75 1c                	jne    802bf8 <__umoddi3+0x48>
  802bdc:	39 f7                	cmp    %esi,%edi
  802bde:	76 50                	jbe    802c30 <__umoddi3+0x80>
  802be0:	89 c8                	mov    %ecx,%eax
  802be2:	89 f2                	mov    %esi,%edx
  802be4:	f7 f7                	div    %edi
  802be6:	89 d0                	mov    %edx,%eax
  802be8:	31 d2                	xor    %edx,%edx
  802bea:	83 c4 1c             	add    $0x1c,%esp
  802bed:	5b                   	pop    %ebx
  802bee:	5e                   	pop    %esi
  802bef:	5f                   	pop    %edi
  802bf0:	5d                   	pop    %ebp
  802bf1:	c3                   	ret    
  802bf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802bf8:	39 f2                	cmp    %esi,%edx
  802bfa:	89 d0                	mov    %edx,%eax
  802bfc:	77 52                	ja     802c50 <__umoddi3+0xa0>
  802bfe:	0f bd ea             	bsr    %edx,%ebp
  802c01:	83 f5 1f             	xor    $0x1f,%ebp
  802c04:	75 5a                	jne    802c60 <__umoddi3+0xb0>
  802c06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802c0a:	0f 82 e0 00 00 00    	jb     802cf0 <__umoddi3+0x140>
  802c10:	39 0c 24             	cmp    %ecx,(%esp)
  802c13:	0f 86 d7 00 00 00    	jbe    802cf0 <__umoddi3+0x140>
  802c19:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c21:	83 c4 1c             	add    $0x1c,%esp
  802c24:	5b                   	pop    %ebx
  802c25:	5e                   	pop    %esi
  802c26:	5f                   	pop    %edi
  802c27:	5d                   	pop    %ebp
  802c28:	c3                   	ret    
  802c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c30:	85 ff                	test   %edi,%edi
  802c32:	89 fd                	mov    %edi,%ebp
  802c34:	75 0b                	jne    802c41 <__umoddi3+0x91>
  802c36:	b8 01 00 00 00       	mov    $0x1,%eax
  802c3b:	31 d2                	xor    %edx,%edx
  802c3d:	f7 f7                	div    %edi
  802c3f:	89 c5                	mov    %eax,%ebp
  802c41:	89 f0                	mov    %esi,%eax
  802c43:	31 d2                	xor    %edx,%edx
  802c45:	f7 f5                	div    %ebp
  802c47:	89 c8                	mov    %ecx,%eax
  802c49:	f7 f5                	div    %ebp
  802c4b:	89 d0                	mov    %edx,%eax
  802c4d:	eb 99                	jmp    802be8 <__umoddi3+0x38>
  802c4f:	90                   	nop
  802c50:	89 c8                	mov    %ecx,%eax
  802c52:	89 f2                	mov    %esi,%edx
  802c54:	83 c4 1c             	add    $0x1c,%esp
  802c57:	5b                   	pop    %ebx
  802c58:	5e                   	pop    %esi
  802c59:	5f                   	pop    %edi
  802c5a:	5d                   	pop    %ebp
  802c5b:	c3                   	ret    
  802c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c60:	8b 34 24             	mov    (%esp),%esi
  802c63:	bf 20 00 00 00       	mov    $0x20,%edi
  802c68:	89 e9                	mov    %ebp,%ecx
  802c6a:	29 ef                	sub    %ebp,%edi
  802c6c:	d3 e0                	shl    %cl,%eax
  802c6e:	89 f9                	mov    %edi,%ecx
  802c70:	89 f2                	mov    %esi,%edx
  802c72:	d3 ea                	shr    %cl,%edx
  802c74:	89 e9                	mov    %ebp,%ecx
  802c76:	09 c2                	or     %eax,%edx
  802c78:	89 d8                	mov    %ebx,%eax
  802c7a:	89 14 24             	mov    %edx,(%esp)
  802c7d:	89 f2                	mov    %esi,%edx
  802c7f:	d3 e2                	shl    %cl,%edx
  802c81:	89 f9                	mov    %edi,%ecx
  802c83:	89 54 24 04          	mov    %edx,0x4(%esp)
  802c87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c8b:	d3 e8                	shr    %cl,%eax
  802c8d:	89 e9                	mov    %ebp,%ecx
  802c8f:	89 c6                	mov    %eax,%esi
  802c91:	d3 e3                	shl    %cl,%ebx
  802c93:	89 f9                	mov    %edi,%ecx
  802c95:	89 d0                	mov    %edx,%eax
  802c97:	d3 e8                	shr    %cl,%eax
  802c99:	89 e9                	mov    %ebp,%ecx
  802c9b:	09 d8                	or     %ebx,%eax
  802c9d:	89 d3                	mov    %edx,%ebx
  802c9f:	89 f2                	mov    %esi,%edx
  802ca1:	f7 34 24             	divl   (%esp)
  802ca4:	89 d6                	mov    %edx,%esi
  802ca6:	d3 e3                	shl    %cl,%ebx
  802ca8:	f7 64 24 04          	mull   0x4(%esp)
  802cac:	39 d6                	cmp    %edx,%esi
  802cae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802cb2:	89 d1                	mov    %edx,%ecx
  802cb4:	89 c3                	mov    %eax,%ebx
  802cb6:	72 08                	jb     802cc0 <__umoddi3+0x110>
  802cb8:	75 11                	jne    802ccb <__umoddi3+0x11b>
  802cba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802cbe:	73 0b                	jae    802ccb <__umoddi3+0x11b>
  802cc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802cc4:	1b 14 24             	sbb    (%esp),%edx
  802cc7:	89 d1                	mov    %edx,%ecx
  802cc9:	89 c3                	mov    %eax,%ebx
  802ccb:	8b 54 24 08          	mov    0x8(%esp),%edx
  802ccf:	29 da                	sub    %ebx,%edx
  802cd1:	19 ce                	sbb    %ecx,%esi
  802cd3:	89 f9                	mov    %edi,%ecx
  802cd5:	89 f0                	mov    %esi,%eax
  802cd7:	d3 e0                	shl    %cl,%eax
  802cd9:	89 e9                	mov    %ebp,%ecx
  802cdb:	d3 ea                	shr    %cl,%edx
  802cdd:	89 e9                	mov    %ebp,%ecx
  802cdf:	d3 ee                	shr    %cl,%esi
  802ce1:	09 d0                	or     %edx,%eax
  802ce3:	89 f2                	mov    %esi,%edx
  802ce5:	83 c4 1c             	add    $0x1c,%esp
  802ce8:	5b                   	pop    %ebx
  802ce9:	5e                   	pop    %esi
  802cea:	5f                   	pop    %edi
  802ceb:	5d                   	pop    %ebp
  802cec:	c3                   	ret    
  802ced:	8d 76 00             	lea    0x0(%esi),%esi
  802cf0:	29 f9                	sub    %edi,%ecx
  802cf2:	19 d6                	sbb    %edx,%esi
  802cf4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cf8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cfc:	e9 18 ff ff ff       	jmp    802c19 <__umoddi3+0x69>
