
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
  800081:	68 ec 2c 80 00       	push   $0x802cec
  800086:	6a 13                	push   $0x13
  800088:	68 ff 2c 80 00       	push   $0x802cff
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 cd 0e 00 00       	call   800f64 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 13 2d 80 00       	push   $0x802d13
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 ff 2c 80 00       	push   $0x802cff
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
  8000d2:	e8 f5 25 00 00       	call   8026cc <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba e6 2c 80 00       	mov    $0x802ce6,%edx
  8000f4:	b8 e0 2c 80 00       	mov    $0x802ce0,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 1c 2d 80 00       	push   $0x802d1c
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 37 2d 80 00       	push   $0x802d37
  80010e:	68 3c 2d 80 00       	push   $0x802d3c
  800113:	68 3b 2d 80 00       	push   $0x802d3b
  800118:	e8 79 1d 00 00       	call   801e96 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 49 2d 80 00       	push   $0x802d49
  80012a:	6a 21                	push   $0x21
  80012c:	68 ff 2c 80 00       	push   $0x802cff
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 8d 25 00 00       	call   8026cc <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba e6 2c 80 00       	mov    $0x802ce6,%edx
  80015c:	b8 e0 2c 80 00       	mov    $0x802ce0,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 53 2d 80 00       	push   $0x802d53
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
  8001c4:	e8 1d 11 00 00       	call   8012e6 <close_all>
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
  8001f6:	68 98 2d 80 00       	push   $0x802d98
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 6d 33 80 00 	movl   $0x80336d,(%esp)
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
  800314:	e8 27 27 00 00       	call   802a40 <__udivdi3>
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
  800357:	e8 14 28 00 00       	call   802b70 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 bb 2d 80 00 	movsbl 0x802dbb(%eax),%eax
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
  80045b:	ff 24 85 00 2f 80 00 	jmp    *0x802f00(,%eax,4)
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
  80051f:	8b 14 85 60 30 80 00 	mov    0x803060(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 d3 2d 80 00       	push   $0x802dd3
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
  800543:	68 4d 32 80 00       	push   $0x80324d
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
  800567:	b8 cc 2d 80 00       	mov    $0x802dcc,%eax
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
  800be2:	68 bf 30 80 00       	push   $0x8030bf
  800be7:	6a 23                	push   $0x23
  800be9:	68 dc 30 80 00       	push   $0x8030dc
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
  800c63:	68 bf 30 80 00       	push   $0x8030bf
  800c68:	6a 23                	push   $0x23
  800c6a:	68 dc 30 80 00       	push   $0x8030dc
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
  800ca5:	68 bf 30 80 00       	push   $0x8030bf
  800caa:	6a 23                	push   $0x23
  800cac:	68 dc 30 80 00       	push   $0x8030dc
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
  800ce7:	68 bf 30 80 00       	push   $0x8030bf
  800cec:	6a 23                	push   $0x23
  800cee:	68 dc 30 80 00       	push   $0x8030dc
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
  800d29:	68 bf 30 80 00       	push   $0x8030bf
  800d2e:	6a 23                	push   $0x23
  800d30:	68 dc 30 80 00       	push   $0x8030dc
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
  800d6b:	68 bf 30 80 00       	push   $0x8030bf
  800d70:	6a 23                	push   $0x23
  800d72:	68 dc 30 80 00       	push   $0x8030dc
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
  800dad:	68 bf 30 80 00       	push   $0x8030bf
  800db2:	6a 23                	push   $0x23
  800db4:	68 dc 30 80 00       	push   $0x8030dc
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
  800e11:	68 bf 30 80 00       	push   $0x8030bf
  800e16:	6a 23                	push   $0x23
  800e18:	68 dc 30 80 00       	push   $0x8030dc
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
  800e72:	68 bf 30 80 00       	push   $0x8030bf
  800e77:	6a 23                	push   $0x23
  800e79:	68 dc 30 80 00       	push   $0x8030dc
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

00800e8b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	56                   	push   %esi
  800e8f:	53                   	push   %ebx
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e93:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e95:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e99:	75 25                	jne    800ec0 <pgfault+0x35>
  800e9b:	89 d8                	mov    %ebx,%eax
  800e9d:	c1 e8 0c             	shr    $0xc,%eax
  800ea0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea7:	f6 c4 08             	test   $0x8,%ah
  800eaa:	75 14                	jne    800ec0 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	68 ec 30 80 00       	push   $0x8030ec
  800eb4:	6a 1e                	push   $0x1e
  800eb6:	68 80 31 80 00       	push   $0x803180
  800ebb:	e8 18 f3 ff ff       	call   8001d8 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800ec0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ec6:	e8 30 fd ff ff       	call   800bfb <sys_getenvid>
  800ecb:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	6a 07                	push   $0x7
  800ed2:	68 00 f0 7f 00       	push   $0x7ff000
  800ed7:	50                   	push   %eax
  800ed8:	e8 5c fd ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	79 12                	jns    800ef6 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ee4:	50                   	push   %eax
  800ee5:	68 18 31 80 00       	push   $0x803118
  800eea:	6a 33                	push   $0x33
  800eec:	68 80 31 80 00       	push   $0x803180
  800ef1:	e8 e2 f2 ff ff       	call   8001d8 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	68 00 10 00 00       	push   $0x1000
  800efe:	53                   	push   %ebx
  800eff:	68 00 f0 7f 00       	push   $0x7ff000
  800f04:	e8 27 fb ff ff       	call   800a30 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f09:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f10:	53                   	push   %ebx
  800f11:	56                   	push   %esi
  800f12:	68 00 f0 7f 00       	push   $0x7ff000
  800f17:	56                   	push   %esi
  800f18:	e8 5f fd ff ff       	call   800c7c <sys_page_map>
	if (r < 0)
  800f1d:	83 c4 20             	add    $0x20,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	79 12                	jns    800f36 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f24:	50                   	push   %eax
  800f25:	68 3c 31 80 00       	push   $0x80313c
  800f2a:	6a 3b                	push   $0x3b
  800f2c:	68 80 31 80 00       	push   $0x803180
  800f31:	e8 a2 f2 ff ff       	call   8001d8 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f36:	83 ec 08             	sub    $0x8,%esp
  800f39:	68 00 f0 7f 00       	push   $0x7ff000
  800f3e:	56                   	push   %esi
  800f3f:	e8 7a fd ff ff       	call   800cbe <sys_page_unmap>
	if (r < 0)
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	85 c0                	test   %eax,%eax
  800f49:	79 12                	jns    800f5d <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f4b:	50                   	push   %eax
  800f4c:	68 60 31 80 00       	push   $0x803160
  800f51:	6a 40                	push   $0x40
  800f53:	68 80 31 80 00       	push   $0x803180
  800f58:	e8 7b f2 ff ff       	call   8001d8 <_panic>
}
  800f5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
  800f6a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f6d:	68 8b 0e 80 00       	push   $0x800e8b
  800f72:	e8 27 19 00 00       	call   80289e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f77:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7c:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	0f 88 64 01 00 00    	js     8010ed <fork+0x189>
  800f89:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f8e:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f93:	85 c0                	test   %eax,%eax
  800f95:	75 21                	jne    800fb8 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f97:	e8 5f fc ff ff       	call   800bfb <sys_getenvid>
  800f9c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa9:	a3 08 50 80 00       	mov    %eax,0x805008
        return 0;
  800fae:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb3:	e9 3f 01 00 00       	jmp    8010f7 <fork+0x193>
  800fb8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fbb:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800fbd:	89 d8                	mov    %ebx,%eax
  800fbf:	c1 e8 16             	shr    $0x16,%eax
  800fc2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc9:	a8 01                	test   $0x1,%al
  800fcb:	0f 84 bd 00 00 00    	je     80108e <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fd1:	89 d8                	mov    %ebx,%eax
  800fd3:	c1 e8 0c             	shr    $0xc,%eax
  800fd6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fdd:	f6 c2 01             	test   $0x1,%dl
  800fe0:	0f 84 a8 00 00 00    	je     80108e <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800fe6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fed:	a8 04                	test   $0x4,%al
  800fef:	0f 84 99 00 00 00    	je     80108e <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800ff5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ffc:	f6 c4 04             	test   $0x4,%ah
  800fff:	74 17                	je     801018 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	68 07 0e 00 00       	push   $0xe07
  801009:	53                   	push   %ebx
  80100a:	57                   	push   %edi
  80100b:	53                   	push   %ebx
  80100c:	6a 00                	push   $0x0
  80100e:	e8 69 fc ff ff       	call   800c7c <sys_page_map>
  801013:	83 c4 20             	add    $0x20,%esp
  801016:	eb 76                	jmp    80108e <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801018:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80101f:	a8 02                	test   $0x2,%al
  801021:	75 0c                	jne    80102f <fork+0xcb>
  801023:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80102a:	f6 c4 08             	test   $0x8,%ah
  80102d:	74 3f                	je     80106e <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	68 05 08 00 00       	push   $0x805
  801037:	53                   	push   %ebx
  801038:	57                   	push   %edi
  801039:	53                   	push   %ebx
  80103a:	6a 00                	push   $0x0
  80103c:	e8 3b fc ff ff       	call   800c7c <sys_page_map>
		if (r < 0)
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	0f 88 a5 00 00 00    	js     8010f1 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	68 05 08 00 00       	push   $0x805
  801054:	53                   	push   %ebx
  801055:	6a 00                	push   $0x0
  801057:	53                   	push   %ebx
  801058:	6a 00                	push   $0x0
  80105a:	e8 1d fc ff ff       	call   800c7c <sys_page_map>
  80105f:	83 c4 20             	add    $0x20,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	b9 00 00 00 00       	mov    $0x0,%ecx
  801069:	0f 4f c1             	cmovg  %ecx,%eax
  80106c:	eb 1c                	jmp    80108a <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	6a 05                	push   $0x5
  801073:	53                   	push   %ebx
  801074:	57                   	push   %edi
  801075:	53                   	push   %ebx
  801076:	6a 00                	push   $0x0
  801078:	e8 ff fb ff ff       	call   800c7c <sys_page_map>
  80107d:	83 c4 20             	add    $0x20,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	b9 00 00 00 00       	mov    $0x0,%ecx
  801087:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80108a:	85 c0                	test   %eax,%eax
  80108c:	78 67                	js     8010f5 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80108e:	83 c6 01             	add    $0x1,%esi
  801091:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801097:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80109d:	0f 85 1a ff ff ff    	jne    800fbd <fork+0x59>
  8010a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	6a 07                	push   $0x7
  8010ab:	68 00 f0 bf ee       	push   $0xeebff000
  8010b0:	57                   	push   %edi
  8010b1:	e8 83 fb ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  8010b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8010b9:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	78 38                	js     8010f7 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010bf:	83 ec 08             	sub    $0x8,%esp
  8010c2:	68 e5 28 80 00       	push   $0x8028e5
  8010c7:	57                   	push   %edi
  8010c8:	e8 b7 fc ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010cd:	83 c4 10             	add    $0x10,%esp
		return r;
  8010d0:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	78 21                	js     8010f7 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	6a 02                	push   $0x2
  8010db:	57                   	push   %edi
  8010dc:	e8 1f fc ff ff       	call   800d00 <sys_env_set_status>
	if (r < 0)
  8010e1:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	0f 48 f8             	cmovs  %eax,%edi
  8010e9:	89 fa                	mov    %edi,%edx
  8010eb:	eb 0a                	jmp    8010f7 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8010ed:	89 c2                	mov    %eax,%edx
  8010ef:	eb 06                	jmp    8010f7 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010f1:	89 c2                	mov    %eax,%edx
  8010f3:	eb 02                	jmp    8010f7 <fork+0x193>
  8010f5:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8010f7:	89 d0                	mov    %edx,%eax
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sfork>:

// Challenge!
int
sfork(void)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801107:	68 8b 31 80 00       	push   $0x80318b
  80110c:	68 c9 00 00 00       	push   $0xc9
  801111:	68 80 31 80 00       	push   $0x803180
  801116:	e8 bd f0 ff ff       	call   8001d8 <_panic>

0080111b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80111e:	8b 45 08             	mov    0x8(%ebp),%eax
  801121:	05 00 00 00 30       	add    $0x30000000,%eax
  801126:	c1 e8 0c             	shr    $0xc,%eax
}
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	05 00 00 00 30       	add    $0x30000000,%eax
  801136:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80113b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801148:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	c1 ea 16             	shr    $0x16,%edx
  801152:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801159:	f6 c2 01             	test   $0x1,%dl
  80115c:	74 11                	je     80116f <fd_alloc+0x2d>
  80115e:	89 c2                	mov    %eax,%edx
  801160:	c1 ea 0c             	shr    $0xc,%edx
  801163:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80116a:	f6 c2 01             	test   $0x1,%dl
  80116d:	75 09                	jne    801178 <fd_alloc+0x36>
			*fd_store = fd;
  80116f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801171:	b8 00 00 00 00       	mov    $0x0,%eax
  801176:	eb 17                	jmp    80118f <fd_alloc+0x4d>
  801178:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80117d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801182:	75 c9                	jne    80114d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801184:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80118a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801197:	83 f8 1f             	cmp    $0x1f,%eax
  80119a:	77 36                	ja     8011d2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80119c:	c1 e0 0c             	shl    $0xc,%eax
  80119f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 ea 16             	shr    $0x16,%edx
  8011a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b0:	f6 c2 01             	test   $0x1,%dl
  8011b3:	74 24                	je     8011d9 <fd_lookup+0x48>
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	c1 ea 0c             	shr    $0xc,%edx
  8011ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c1:	f6 c2 01             	test   $0x1,%dl
  8011c4:	74 1a                	je     8011e0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c9:	89 02                	mov    %eax,(%edx)
	return 0;
  8011cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d0:	eb 13                	jmp    8011e5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d7:	eb 0c                	jmp    8011e5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011de:	eb 05                	jmp    8011e5 <fd_lookup+0x54>
  8011e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f0:	ba 20 32 80 00       	mov    $0x803220,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011f5:	eb 13                	jmp    80120a <dev_lookup+0x23>
  8011f7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011fa:	39 08                	cmp    %ecx,(%eax)
  8011fc:	75 0c                	jne    80120a <dev_lookup+0x23>
			*dev = devtab[i];
  8011fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801201:	89 01                	mov    %eax,(%ecx)
			return 0;
  801203:	b8 00 00 00 00       	mov    $0x0,%eax
  801208:	eb 2e                	jmp    801238 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80120a:	8b 02                	mov    (%edx),%eax
  80120c:	85 c0                	test   %eax,%eax
  80120e:	75 e7                	jne    8011f7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801210:	a1 08 50 80 00       	mov    0x805008,%eax
  801215:	8b 40 48             	mov    0x48(%eax),%eax
  801218:	83 ec 04             	sub    $0x4,%esp
  80121b:	51                   	push   %ecx
  80121c:	50                   	push   %eax
  80121d:	68 a4 31 80 00       	push   $0x8031a4
  801222:	e8 8a f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  801227:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	56                   	push   %esi
  80123e:	53                   	push   %ebx
  80123f:	83 ec 10             	sub    $0x10,%esp
  801242:	8b 75 08             	mov    0x8(%ebp),%esi
  801245:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801248:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124b:	50                   	push   %eax
  80124c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801252:	c1 e8 0c             	shr    $0xc,%eax
  801255:	50                   	push   %eax
  801256:	e8 36 ff ff ff       	call   801191 <fd_lookup>
  80125b:	83 c4 08             	add    $0x8,%esp
  80125e:	85 c0                	test   %eax,%eax
  801260:	78 05                	js     801267 <fd_close+0x2d>
	    || fd != fd2)
  801262:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801265:	74 0c                	je     801273 <fd_close+0x39>
		return (must_exist ? r : 0);
  801267:	84 db                	test   %bl,%bl
  801269:	ba 00 00 00 00       	mov    $0x0,%edx
  80126e:	0f 44 c2             	cmove  %edx,%eax
  801271:	eb 41                	jmp    8012b4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801273:	83 ec 08             	sub    $0x8,%esp
  801276:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	ff 36                	pushl  (%esi)
  80127c:	e8 66 ff ff ff       	call   8011e7 <dev_lookup>
  801281:	89 c3                	mov    %eax,%ebx
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 1a                	js     8012a4 <fd_close+0x6a>
		if (dev->dev_close)
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801290:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801295:	85 c0                	test   %eax,%eax
  801297:	74 0b                	je     8012a4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801299:	83 ec 0c             	sub    $0xc,%esp
  80129c:	56                   	push   %esi
  80129d:	ff d0                	call   *%eax
  80129f:	89 c3                	mov    %eax,%ebx
  8012a1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	56                   	push   %esi
  8012a8:	6a 00                	push   $0x0
  8012aa:	e8 0f fa ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	89 d8                	mov    %ebx,%eax
}
  8012b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	ff 75 08             	pushl  0x8(%ebp)
  8012c8:	e8 c4 fe ff ff       	call   801191 <fd_lookup>
  8012cd:	83 c4 08             	add    $0x8,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 10                	js     8012e4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	6a 01                	push   $0x1
  8012d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012dc:	e8 59 ff ff ff       	call   80123a <fd_close>
  8012e1:	83 c4 10             	add    $0x10,%esp
}
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <close_all>:

void
close_all(void)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012f2:	83 ec 0c             	sub    $0xc,%esp
  8012f5:	53                   	push   %ebx
  8012f6:	e8 c0 ff ff ff       	call   8012bb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012fb:	83 c3 01             	add    $0x1,%ebx
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	83 fb 20             	cmp    $0x20,%ebx
  801304:	75 ec                	jne    8012f2 <close_all+0xc>
		close(i);
}
  801306:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	57                   	push   %edi
  80130f:	56                   	push   %esi
  801310:	53                   	push   %ebx
  801311:	83 ec 2c             	sub    $0x2c,%esp
  801314:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801317:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	ff 75 08             	pushl  0x8(%ebp)
  80131e:	e8 6e fe ff ff       	call   801191 <fd_lookup>
  801323:	83 c4 08             	add    $0x8,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	0f 88 c1 00 00 00    	js     8013ef <dup+0xe4>
		return r;
	close(newfdnum);
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	56                   	push   %esi
  801332:	e8 84 ff ff ff       	call   8012bb <close>

	newfd = INDEX2FD(newfdnum);
  801337:	89 f3                	mov    %esi,%ebx
  801339:	c1 e3 0c             	shl    $0xc,%ebx
  80133c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801342:	83 c4 04             	add    $0x4,%esp
  801345:	ff 75 e4             	pushl  -0x1c(%ebp)
  801348:	e8 de fd ff ff       	call   80112b <fd2data>
  80134d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80134f:	89 1c 24             	mov    %ebx,(%esp)
  801352:	e8 d4 fd ff ff       	call   80112b <fd2data>
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80135d:	89 f8                	mov    %edi,%eax
  80135f:	c1 e8 16             	shr    $0x16,%eax
  801362:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801369:	a8 01                	test   $0x1,%al
  80136b:	74 37                	je     8013a4 <dup+0x99>
  80136d:	89 f8                	mov    %edi,%eax
  80136f:	c1 e8 0c             	shr    $0xc,%eax
  801372:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801379:	f6 c2 01             	test   $0x1,%dl
  80137c:	74 26                	je     8013a4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80137e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801385:	83 ec 0c             	sub    $0xc,%esp
  801388:	25 07 0e 00 00       	and    $0xe07,%eax
  80138d:	50                   	push   %eax
  80138e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801391:	6a 00                	push   $0x0
  801393:	57                   	push   %edi
  801394:	6a 00                	push   $0x0
  801396:	e8 e1 f8 ff ff       	call   800c7c <sys_page_map>
  80139b:	89 c7                	mov    %eax,%edi
  80139d:	83 c4 20             	add    $0x20,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 2e                	js     8013d2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013a7:	89 d0                	mov    %edx,%eax
  8013a9:	c1 e8 0c             	shr    $0xc,%eax
  8013ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bb:	50                   	push   %eax
  8013bc:	53                   	push   %ebx
  8013bd:	6a 00                	push   $0x0
  8013bf:	52                   	push   %edx
  8013c0:	6a 00                	push   $0x0
  8013c2:	e8 b5 f8 ff ff       	call   800c7c <sys_page_map>
  8013c7:	89 c7                	mov    %eax,%edi
  8013c9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013cc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ce:	85 ff                	test   %edi,%edi
  8013d0:	79 1d                	jns    8013ef <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	53                   	push   %ebx
  8013d6:	6a 00                	push   $0x0
  8013d8:	e8 e1 f8 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013dd:	83 c4 08             	add    $0x8,%esp
  8013e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e3:	6a 00                	push   $0x0
  8013e5:	e8 d4 f8 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	89 f8                	mov    %edi,%eax
}
  8013ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5e                   	pop    %esi
  8013f4:	5f                   	pop    %edi
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	53                   	push   %ebx
  8013fb:	83 ec 14             	sub    $0x14,%esp
  8013fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801401:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801404:	50                   	push   %eax
  801405:	53                   	push   %ebx
  801406:	e8 86 fd ff ff       	call   801191 <fd_lookup>
  80140b:	83 c4 08             	add    $0x8,%esp
  80140e:	89 c2                	mov    %eax,%edx
  801410:	85 c0                	test   %eax,%eax
  801412:	78 6d                	js     801481 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141e:	ff 30                	pushl  (%eax)
  801420:	e8 c2 fd ff ff       	call   8011e7 <dev_lookup>
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 4c                	js     801478 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80142c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80142f:	8b 42 08             	mov    0x8(%edx),%eax
  801432:	83 e0 03             	and    $0x3,%eax
  801435:	83 f8 01             	cmp    $0x1,%eax
  801438:	75 21                	jne    80145b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80143a:	a1 08 50 80 00       	mov    0x805008,%eax
  80143f:	8b 40 48             	mov    0x48(%eax),%eax
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	53                   	push   %ebx
  801446:	50                   	push   %eax
  801447:	68 e5 31 80 00       	push   $0x8031e5
  80144c:	e8 60 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801459:	eb 26                	jmp    801481 <read+0x8a>
	}
	if (!dev->dev_read)
  80145b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145e:	8b 40 08             	mov    0x8(%eax),%eax
  801461:	85 c0                	test   %eax,%eax
  801463:	74 17                	je     80147c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801465:	83 ec 04             	sub    $0x4,%esp
  801468:	ff 75 10             	pushl  0x10(%ebp)
  80146b:	ff 75 0c             	pushl  0xc(%ebp)
  80146e:	52                   	push   %edx
  80146f:	ff d0                	call   *%eax
  801471:	89 c2                	mov    %eax,%edx
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	eb 09                	jmp    801481 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801478:	89 c2                	mov    %eax,%edx
  80147a:	eb 05                	jmp    801481 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80147c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801481:	89 d0                	mov    %edx,%eax
  801483:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	57                   	push   %edi
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	8b 7d 08             	mov    0x8(%ebp),%edi
  801494:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801497:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149c:	eb 21                	jmp    8014bf <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	89 f0                	mov    %esi,%eax
  8014a3:	29 d8                	sub    %ebx,%eax
  8014a5:	50                   	push   %eax
  8014a6:	89 d8                	mov    %ebx,%eax
  8014a8:	03 45 0c             	add    0xc(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	57                   	push   %edi
  8014ad:	e8 45 ff ff ff       	call   8013f7 <read>
		if (m < 0)
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 10                	js     8014c9 <readn+0x41>
			return m;
		if (m == 0)
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	74 0a                	je     8014c7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014bd:	01 c3                	add    %eax,%ebx
  8014bf:	39 f3                	cmp    %esi,%ebx
  8014c1:	72 db                	jb     80149e <readn+0x16>
  8014c3:	89 d8                	mov    %ebx,%eax
  8014c5:	eb 02                	jmp    8014c9 <readn+0x41>
  8014c7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014cc:	5b                   	pop    %ebx
  8014cd:	5e                   	pop    %esi
  8014ce:	5f                   	pop    %edi
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    

008014d1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 14             	sub    $0x14,%esp
  8014d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014de:	50                   	push   %eax
  8014df:	53                   	push   %ebx
  8014e0:	e8 ac fc ff ff       	call   801191 <fd_lookup>
  8014e5:	83 c4 08             	add    $0x8,%esp
  8014e8:	89 c2                	mov    %eax,%edx
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 68                	js     801556 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f4:	50                   	push   %eax
  8014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f8:	ff 30                	pushl  (%eax)
  8014fa:	e8 e8 fc ff ff       	call   8011e7 <dev_lookup>
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 47                	js     80154d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801506:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801509:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150d:	75 21                	jne    801530 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80150f:	a1 08 50 80 00       	mov    0x805008,%eax
  801514:	8b 40 48             	mov    0x48(%eax),%eax
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	53                   	push   %ebx
  80151b:	50                   	push   %eax
  80151c:	68 01 32 80 00       	push   $0x803201
  801521:	e8 8b ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80152e:	eb 26                	jmp    801556 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801530:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801533:	8b 52 0c             	mov    0xc(%edx),%edx
  801536:	85 d2                	test   %edx,%edx
  801538:	74 17                	je     801551 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	ff 75 10             	pushl  0x10(%ebp)
  801540:	ff 75 0c             	pushl  0xc(%ebp)
  801543:	50                   	push   %eax
  801544:	ff d2                	call   *%edx
  801546:	89 c2                	mov    %eax,%edx
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	eb 09                	jmp    801556 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	eb 05                	jmp    801556 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801551:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801556:	89 d0                	mov    %edx,%eax
  801558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <seek>:

int
seek(int fdnum, off_t offset)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801563:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801566:	50                   	push   %eax
  801567:	ff 75 08             	pushl  0x8(%ebp)
  80156a:	e8 22 fc ff ff       	call   801191 <fd_lookup>
  80156f:	83 c4 08             	add    $0x8,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	78 0e                	js     801584 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801576:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801579:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80157f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801584:	c9                   	leave  
  801585:	c3                   	ret    

00801586 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	53                   	push   %ebx
  80158a:	83 ec 14             	sub    $0x14,%esp
  80158d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801590:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	53                   	push   %ebx
  801595:	e8 f7 fb ff ff       	call   801191 <fd_lookup>
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 65                	js     801608 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	ff 30                	pushl  (%eax)
  8015af:	e8 33 fc ff ff       	call   8011e7 <dev_lookup>
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 44                	js     8015ff <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c2:	75 21                	jne    8015e5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015c4:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c9:	8b 40 48             	mov    0x48(%eax),%eax
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	53                   	push   %ebx
  8015d0:	50                   	push   %eax
  8015d1:	68 c4 31 80 00       	push   $0x8031c4
  8015d6:	e8 d6 ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e3:	eb 23                	jmp    801608 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e8:	8b 52 18             	mov    0x18(%edx),%edx
  8015eb:	85 d2                	test   %edx,%edx
  8015ed:	74 14                	je     801603 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	ff 75 0c             	pushl  0xc(%ebp)
  8015f5:	50                   	push   %eax
  8015f6:	ff d2                	call   *%edx
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	eb 09                	jmp    801608 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	eb 05                	jmp    801608 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801603:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801608:	89 d0                	mov    %edx,%eax
  80160a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	53                   	push   %ebx
  801613:	83 ec 14             	sub    $0x14,%esp
  801616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801619:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	ff 75 08             	pushl  0x8(%ebp)
  801620:	e8 6c fb ff ff       	call   801191 <fd_lookup>
  801625:	83 c4 08             	add    $0x8,%esp
  801628:	89 c2                	mov    %eax,%edx
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 58                	js     801686 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162e:	83 ec 08             	sub    $0x8,%esp
  801631:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801638:	ff 30                	pushl  (%eax)
  80163a:	e8 a8 fb ff ff       	call   8011e7 <dev_lookup>
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	85 c0                	test   %eax,%eax
  801644:	78 37                	js     80167d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801649:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80164d:	74 32                	je     801681 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80164f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801652:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801659:	00 00 00 
	stat->st_isdir = 0;
  80165c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801663:	00 00 00 
	stat->st_dev = dev;
  801666:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	53                   	push   %ebx
  801670:	ff 75 f0             	pushl  -0x10(%ebp)
  801673:	ff 50 14             	call   *0x14(%eax)
  801676:	89 c2                	mov    %eax,%edx
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	eb 09                	jmp    801686 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	eb 05                	jmp    801686 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801681:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801686:	89 d0                	mov    %edx,%eax
  801688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	56                   	push   %esi
  801691:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	6a 00                	push   $0x0
  801697:	ff 75 08             	pushl  0x8(%ebp)
  80169a:	e8 d6 01 00 00       	call   801875 <open>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 1b                	js     8016c3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	ff 75 0c             	pushl  0xc(%ebp)
  8016ae:	50                   	push   %eax
  8016af:	e8 5b ff ff ff       	call   80160f <fstat>
  8016b4:	89 c6                	mov    %eax,%esi
	close(fd);
  8016b6:	89 1c 24             	mov    %ebx,(%esp)
  8016b9:	e8 fd fb ff ff       	call   8012bb <close>
	return r;
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	89 f0                	mov    %esi,%eax
}
  8016c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	56                   	push   %esi
  8016ce:	53                   	push   %ebx
  8016cf:	89 c6                	mov    %eax,%esi
  8016d1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016d3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8016da:	75 12                	jne    8016ee <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016dc:	83 ec 0c             	sub    $0xc,%esp
  8016df:	6a 01                	push   $0x1
  8016e1:	e8 de 12 00 00       	call   8029c4 <ipc_find_env>
  8016e6:	a3 00 50 80 00       	mov    %eax,0x805000
  8016eb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ee:	6a 07                	push   $0x7
  8016f0:	68 00 60 80 00       	push   $0x806000
  8016f5:	56                   	push   %esi
  8016f6:	ff 35 00 50 80 00    	pushl  0x805000
  8016fc:	e8 6f 12 00 00       	call   802970 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801701:	83 c4 0c             	add    $0xc,%esp
  801704:	6a 00                	push   $0x0
  801706:	53                   	push   %ebx
  801707:	6a 00                	push   $0x0
  801709:	e8 fb 11 00 00       	call   802909 <ipc_recv>
}
  80170e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801711:	5b                   	pop    %ebx
  801712:	5e                   	pop    %esi
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80171b:	8b 45 08             	mov    0x8(%ebp),%eax
  80171e:	8b 40 0c             	mov    0xc(%eax),%eax
  801721:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801726:	8b 45 0c             	mov    0xc(%ebp),%eax
  801729:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80172e:	ba 00 00 00 00       	mov    $0x0,%edx
  801733:	b8 02 00 00 00       	mov    $0x2,%eax
  801738:	e8 8d ff ff ff       	call   8016ca <fsipc>
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801745:	8b 45 08             	mov    0x8(%ebp),%eax
  801748:	8b 40 0c             	mov    0xc(%eax),%eax
  80174b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801750:	ba 00 00 00 00       	mov    $0x0,%edx
  801755:	b8 06 00 00 00       	mov    $0x6,%eax
  80175a:	e8 6b ff ff ff       	call   8016ca <fsipc>
}
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	53                   	push   %ebx
  801765:	83 ec 04             	sub    $0x4,%esp
  801768:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	8b 40 0c             	mov    0xc(%eax),%eax
  801771:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801776:	ba 00 00 00 00       	mov    $0x0,%edx
  80177b:	b8 05 00 00 00       	mov    $0x5,%eax
  801780:	e8 45 ff ff ff       	call   8016ca <fsipc>
  801785:	85 c0                	test   %eax,%eax
  801787:	78 2c                	js     8017b5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801789:	83 ec 08             	sub    $0x8,%esp
  80178c:	68 00 60 80 00       	push   $0x806000
  801791:	53                   	push   %ebx
  801792:	e8 9f f0 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801797:	a1 80 60 80 00       	mov    0x806080,%eax
  80179c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017a2:	a1 84 60 80 00       	mov    0x806084,%eax
  8017a7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    

008017ba <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	83 ec 0c             	sub    $0xc,%esp
  8017c0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c9:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  8017cf:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017d4:	50                   	push   %eax
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	68 08 60 80 00       	push   $0x806008
  8017dd:	e8 e6 f1 ff ff       	call   8009c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ec:	e8 d9 fe ff ff       	call   8016ca <fsipc>

}
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801801:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801806:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80180c:	ba 00 00 00 00       	mov    $0x0,%edx
  801811:	b8 03 00 00 00       	mov    $0x3,%eax
  801816:	e8 af fe ff ff       	call   8016ca <fsipc>
  80181b:	89 c3                	mov    %eax,%ebx
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 4b                	js     80186c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801821:	39 c6                	cmp    %eax,%esi
  801823:	73 16                	jae    80183b <devfile_read+0x48>
  801825:	68 34 32 80 00       	push   $0x803234
  80182a:	68 3b 32 80 00       	push   $0x80323b
  80182f:	6a 7c                	push   $0x7c
  801831:	68 50 32 80 00       	push   $0x803250
  801836:	e8 9d e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  80183b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801840:	7e 16                	jle    801858 <devfile_read+0x65>
  801842:	68 5b 32 80 00       	push   $0x80325b
  801847:	68 3b 32 80 00       	push   $0x80323b
  80184c:	6a 7d                	push   $0x7d
  80184e:	68 50 32 80 00       	push   $0x803250
  801853:	e8 80 e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801858:	83 ec 04             	sub    $0x4,%esp
  80185b:	50                   	push   %eax
  80185c:	68 00 60 80 00       	push   $0x806000
  801861:	ff 75 0c             	pushl  0xc(%ebp)
  801864:	e8 5f f1 ff ff       	call   8009c8 <memmove>
	return r;
  801869:	83 c4 10             	add    $0x10,%esp
}
  80186c:	89 d8                	mov    %ebx,%eax
  80186e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801871:	5b                   	pop    %ebx
  801872:	5e                   	pop    %esi
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    

00801875 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	53                   	push   %ebx
  801879:	83 ec 20             	sub    $0x20,%esp
  80187c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80187f:	53                   	push   %ebx
  801880:	e8 78 ef ff ff       	call   8007fd <strlen>
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80188d:	7f 67                	jg     8018f6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188f:	83 ec 0c             	sub    $0xc,%esp
  801892:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801895:	50                   	push   %eax
  801896:	e8 a7 f8 ff ff       	call   801142 <fd_alloc>
  80189b:	83 c4 10             	add    $0x10,%esp
		return r;
  80189e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	78 57                	js     8018fb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	53                   	push   %ebx
  8018a8:	68 00 60 80 00       	push   $0x806000
  8018ad:	e8 84 ef ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b5:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c2:	e8 03 fe ff ff       	call   8016ca <fsipc>
  8018c7:	89 c3                	mov    %eax,%ebx
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	79 14                	jns    8018e4 <open+0x6f>
		fd_close(fd, 0);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	6a 00                	push   $0x0
  8018d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d8:	e8 5d f9 ff ff       	call   80123a <fd_close>
		return r;
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	89 da                	mov    %ebx,%edx
  8018e2:	eb 17                	jmp    8018fb <open+0x86>
	}

	return fd2num(fd);
  8018e4:	83 ec 0c             	sub    $0xc,%esp
  8018e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ea:	e8 2c f8 ff ff       	call   80111b <fd2num>
  8018ef:	89 c2                	mov    %eax,%edx
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	eb 05                	jmp    8018fb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018f6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018fb:	89 d0                	mov    %edx,%eax
  8018fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801908:	ba 00 00 00 00       	mov    $0x0,%edx
  80190d:	b8 08 00 00 00       	mov    $0x8,%eax
  801912:	e8 b3 fd ff ff       	call   8016ca <fsipc>
}
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	57                   	push   %edi
  80191d:	56                   	push   %esi
  80191e:	53                   	push   %ebx
  80191f:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801925:	6a 00                	push   $0x0
  801927:	ff 75 08             	pushl  0x8(%ebp)
  80192a:	e8 46 ff ff ff       	call   801875 <open>
  80192f:	89 c7                	mov    %eax,%edi
  801931:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	85 c0                	test   %eax,%eax
  80193c:	0f 88 97 04 00 00    	js     801dd9 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801942:	83 ec 04             	sub    $0x4,%esp
  801945:	68 00 02 00 00       	push   $0x200
  80194a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801950:	50                   	push   %eax
  801951:	57                   	push   %edi
  801952:	e8 31 fb ff ff       	call   801488 <readn>
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	3d 00 02 00 00       	cmp    $0x200,%eax
  80195f:	75 0c                	jne    80196d <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801961:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801968:	45 4c 46 
  80196b:	74 33                	je     8019a0 <spawn+0x87>
		close(fd);
  80196d:	83 ec 0c             	sub    $0xc,%esp
  801970:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801976:	e8 40 f9 ff ff       	call   8012bb <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80197b:	83 c4 0c             	add    $0xc,%esp
  80197e:	68 7f 45 4c 46       	push   $0x464c457f
  801983:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801989:	68 67 32 80 00       	push   $0x803267
  80198e:	e8 1e e9 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80199b:	e9 ec 04 00 00       	jmp    801e8c <spawn+0x573>
  8019a0:	b8 07 00 00 00       	mov    $0x7,%eax
  8019a5:	cd 30                	int    $0x30
  8019a7:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019ad:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	0f 88 29 04 00 00    	js     801de4 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019bb:	89 c6                	mov    %eax,%esi
  8019bd:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019c3:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8019c6:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019cc:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019d2:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019d9:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019df:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019e5:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019ea:	be 00 00 00 00       	mov    $0x0,%esi
  8019ef:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019f2:	eb 13                	jmp    801a07 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	50                   	push   %eax
  8019f8:	e8 00 ee ff ff       	call   8007fd <strlen>
  8019fd:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a01:	83 c3 01             	add    $0x1,%ebx
  801a04:	83 c4 10             	add    $0x10,%esp
  801a07:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a0e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a11:	85 c0                	test   %eax,%eax
  801a13:	75 df                	jne    8019f4 <spawn+0xdb>
  801a15:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a1b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a21:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a26:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a28:	89 fa                	mov    %edi,%edx
  801a2a:	83 e2 fc             	and    $0xfffffffc,%edx
  801a2d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a34:	29 c2                	sub    %eax,%edx
  801a36:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a3c:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a3f:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a44:	0f 86 b0 03 00 00    	jbe    801dfa <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a4a:	83 ec 04             	sub    $0x4,%esp
  801a4d:	6a 07                	push   $0x7
  801a4f:	68 00 00 40 00       	push   $0x400000
  801a54:	6a 00                	push   $0x0
  801a56:	e8 de f1 ff ff       	call   800c39 <sys_page_alloc>
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	0f 88 9e 03 00 00    	js     801e04 <spawn+0x4eb>
  801a66:	be 00 00 00 00       	mov    $0x0,%esi
  801a6b:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a74:	eb 30                	jmp    801aa6 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a76:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a7c:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a82:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a85:	83 ec 08             	sub    $0x8,%esp
  801a88:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a8b:	57                   	push   %edi
  801a8c:	e8 a5 ed ff ff       	call   800836 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a91:	83 c4 04             	add    $0x4,%esp
  801a94:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a97:	e8 61 ed ff ff       	call   8007fd <strlen>
  801a9c:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801aa0:	83 c6 01             	add    $0x1,%esi
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801aac:	7f c8                	jg     801a76 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801aae:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801ab4:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801aba:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ac1:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801ac7:	74 19                	je     801ae2 <spawn+0x1c9>
  801ac9:	68 f4 32 80 00       	push   $0x8032f4
  801ace:	68 3b 32 80 00       	push   $0x80323b
  801ad3:	68 f2 00 00 00       	push   $0xf2
  801ad8:	68 81 32 80 00       	push   $0x803281
  801add:	e8 f6 e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ae2:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801ae8:	89 f8                	mov    %edi,%eax
  801aea:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801aef:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801af2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801af8:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801afb:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b01:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b07:	83 ec 0c             	sub    $0xc,%esp
  801b0a:	6a 07                	push   $0x7
  801b0c:	68 00 d0 bf ee       	push   $0xeebfd000
  801b11:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b17:	68 00 00 40 00       	push   $0x400000
  801b1c:	6a 00                	push   $0x0
  801b1e:	e8 59 f1 ff ff       	call   800c7c <sys_page_map>
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	83 c4 20             	add    $0x20,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	0f 88 4a 03 00 00    	js     801e7a <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b30:	83 ec 08             	sub    $0x8,%esp
  801b33:	68 00 00 40 00       	push   $0x400000
  801b38:	6a 00                	push   $0x0
  801b3a:	e8 7f f1 ff ff       	call   800cbe <sys_page_unmap>
  801b3f:	89 c3                	mov    %eax,%ebx
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	0f 88 2e 03 00 00    	js     801e7a <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b4c:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b52:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b59:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b5f:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b66:	00 00 00 
  801b69:	e9 8a 01 00 00       	jmp    801cf8 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801b6e:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b74:	83 38 01             	cmpl   $0x1,(%eax)
  801b77:	0f 85 6d 01 00 00    	jne    801cea <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b7d:	89 c7                	mov    %eax,%edi
  801b7f:	8b 40 18             	mov    0x18(%eax),%eax
  801b82:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b88:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b8b:	83 f8 01             	cmp    $0x1,%eax
  801b8e:	19 c0                	sbb    %eax,%eax
  801b90:	83 e0 fe             	and    $0xfffffffe,%eax
  801b93:	83 c0 07             	add    $0x7,%eax
  801b96:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b9c:	89 f8                	mov    %edi,%eax
  801b9e:	8b 7f 04             	mov    0x4(%edi),%edi
  801ba1:	89 f9                	mov    %edi,%ecx
  801ba3:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801ba9:	8b 78 10             	mov    0x10(%eax),%edi
  801bac:	8b 70 14             	mov    0x14(%eax),%esi
  801baf:	89 f3                	mov    %esi,%ebx
  801bb1:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801bb7:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801bba:	89 f0                	mov    %esi,%eax
  801bbc:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bc1:	74 14                	je     801bd7 <spawn+0x2be>
		va -= i;
  801bc3:	29 c6                	sub    %eax,%esi
		memsz += i;
  801bc5:	01 c3                	add    %eax,%ebx
  801bc7:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801bcd:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801bcf:	29 c1                	sub    %eax,%ecx
  801bd1:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bdc:	e9 f7 00 00 00       	jmp    801cd8 <spawn+0x3bf>
		if (i >= filesz) {
  801be1:	39 df                	cmp    %ebx,%edi
  801be3:	77 27                	ja     801c0c <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801be5:	83 ec 04             	sub    $0x4,%esp
  801be8:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bee:	56                   	push   %esi
  801bef:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bf5:	e8 3f f0 ff ff       	call   800c39 <sys_page_alloc>
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	0f 89 c7 00 00 00    	jns    801ccc <spawn+0x3b3>
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	e9 09 02 00 00       	jmp    801e15 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	6a 07                	push   $0x7
  801c11:	68 00 00 40 00       	push   $0x400000
  801c16:	6a 00                	push   $0x0
  801c18:	e8 1c f0 ff ff       	call   800c39 <sys_page_alloc>
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	0f 88 e3 01 00 00    	js     801e0b <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c28:	83 ec 08             	sub    $0x8,%esp
  801c2b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c31:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c37:	50                   	push   %eax
  801c38:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c3e:	e8 1a f9 ff ff       	call   80155d <seek>
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	85 c0                	test   %eax,%eax
  801c48:	0f 88 c1 01 00 00    	js     801e0f <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c4e:	83 ec 04             	sub    $0x4,%esp
  801c51:	89 f8                	mov    %edi,%eax
  801c53:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c59:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c5e:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c63:	0f 47 c1             	cmova  %ecx,%eax
  801c66:	50                   	push   %eax
  801c67:	68 00 00 40 00       	push   $0x400000
  801c6c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c72:	e8 11 f8 ff ff       	call   801488 <readn>
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	0f 88 91 01 00 00    	js     801e13 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c82:	83 ec 0c             	sub    $0xc,%esp
  801c85:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c8b:	56                   	push   %esi
  801c8c:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c92:	68 00 00 40 00       	push   $0x400000
  801c97:	6a 00                	push   $0x0
  801c99:	e8 de ef ff ff       	call   800c7c <sys_page_map>
  801c9e:	83 c4 20             	add    $0x20,%esp
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	79 15                	jns    801cba <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801ca5:	50                   	push   %eax
  801ca6:	68 8d 32 80 00       	push   $0x80328d
  801cab:	68 25 01 00 00       	push   $0x125
  801cb0:	68 81 32 80 00       	push   $0x803281
  801cb5:	e8 1e e5 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801cba:	83 ec 08             	sub    $0x8,%esp
  801cbd:	68 00 00 40 00       	push   $0x400000
  801cc2:	6a 00                	push   $0x0
  801cc4:	e8 f5 ef ff ff       	call   800cbe <sys_page_unmap>
  801cc9:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ccc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cd2:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cd8:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801cde:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801ce4:	0f 87 f7 fe ff ff    	ja     801be1 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cea:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801cf1:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801cf8:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cff:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d05:	0f 8c 63 fe ff ff    	jl     801b6e <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d0b:	83 ec 0c             	sub    $0xc,%esp
  801d0e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d14:	e8 a2 f5 ff ff       	call   8012bb <close>
  801d19:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801d1c:	bb 00 08 00 00       	mov    $0x800,%ebx
  801d21:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  801d27:	89 d8                	mov    %ebx,%eax
  801d29:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801d2c:	89 c2                	mov    %eax,%edx
  801d2e:	c1 ea 16             	shr    $0x16,%edx
  801d31:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d38:	f6 c2 01             	test   $0x1,%dl
  801d3b:	74 4b                	je     801d88 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801d3d:	89 c2                	mov    %eax,%edx
  801d3f:	c1 ea 0c             	shr    $0xc,%edx
  801d42:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801d49:	f6 c1 01             	test   $0x1,%cl
  801d4c:	74 3a                	je     801d88 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801d4e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d55:	f6 c6 04             	test   $0x4,%dh
  801d58:	74 2e                	je     801d88 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801d5a:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801d61:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  801d67:	8b 49 48             	mov    0x48(%ecx),%ecx
  801d6a:	83 ec 0c             	sub    $0xc,%esp
  801d6d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d73:	52                   	push   %edx
  801d74:	50                   	push   %eax
  801d75:	56                   	push   %esi
  801d76:	50                   	push   %eax
  801d77:	51                   	push   %ecx
  801d78:	e8 ff ee ff ff       	call   800c7c <sys_page_map>
					if (r < 0)
  801d7d:	83 c4 20             	add    $0x20,%esp
  801d80:	85 c0                	test   %eax,%eax
  801d82:	0f 88 ae 00 00 00    	js     801e36 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801d88:	83 c3 01             	add    $0x1,%ebx
  801d8b:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801d91:	75 94                	jne    801d27 <spawn+0x40e>
  801d93:	e9 b3 00 00 00       	jmp    801e4b <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d98:	50                   	push   %eax
  801d99:	68 aa 32 80 00       	push   $0x8032aa
  801d9e:	68 86 00 00 00       	push   $0x86
  801da3:	68 81 32 80 00       	push   $0x803281
  801da8:	e8 2b e4 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801dad:	83 ec 08             	sub    $0x8,%esp
  801db0:	6a 02                	push   $0x2
  801db2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801db8:	e8 43 ef ff ff       	call   800d00 <sys_env_set_status>
  801dbd:	83 c4 10             	add    $0x10,%esp
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	79 2b                	jns    801def <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801dc4:	50                   	push   %eax
  801dc5:	68 c4 32 80 00       	push   $0x8032c4
  801dca:	68 89 00 00 00       	push   $0x89
  801dcf:	68 81 32 80 00       	push   $0x803281
  801dd4:	e8 ff e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801dd9:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801ddf:	e9 a8 00 00 00       	jmp    801e8c <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801de4:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801dea:	e9 9d 00 00 00       	jmp    801e8c <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801def:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801df5:	e9 92 00 00 00       	jmp    801e8c <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801dfa:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801dff:	e9 88 00 00 00       	jmp    801e8c <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	e9 81 00 00 00       	jmp    801e8c <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e0b:	89 c3                	mov    %eax,%ebx
  801e0d:	eb 06                	jmp    801e15 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e0f:	89 c3                	mov    %eax,%ebx
  801e11:	eb 02                	jmp    801e15 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e13:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e15:	83 ec 0c             	sub    $0xc,%esp
  801e18:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e1e:	e8 97 ed ff ff       	call   800bba <sys_env_destroy>
	close(fd);
  801e23:	83 c4 04             	add    $0x4,%esp
  801e26:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e2c:	e8 8a f4 ff ff       	call   8012bb <close>
	return r;
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	eb 56                	jmp    801e8c <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e36:	50                   	push   %eax
  801e37:	68 db 32 80 00       	push   $0x8032db
  801e3c:	68 82 00 00 00       	push   $0x82
  801e41:	68 81 32 80 00       	push   $0x803281
  801e46:	e8 8d e3 ff ff       	call   8001d8 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e4b:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e52:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e55:	83 ec 08             	sub    $0x8,%esp
  801e58:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e5e:	50                   	push   %eax
  801e5f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e65:	e8 d8 ee ff ff       	call   800d42 <sys_env_set_trapframe>
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	0f 89 38 ff ff ff    	jns    801dad <spawn+0x494>
  801e75:	e9 1e ff ff ff       	jmp    801d98 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e7a:	83 ec 08             	sub    $0x8,%esp
  801e7d:	68 00 00 40 00       	push   $0x400000
  801e82:	6a 00                	push   $0x0
  801e84:	e8 35 ee ff ff       	call   800cbe <sys_page_unmap>
  801e89:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e8c:	89 d8                	mov    %ebx,%eax
  801e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5f                   	pop    %edi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    

00801e96 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	56                   	push   %esi
  801e9a:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e9b:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e9e:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ea3:	eb 03                	jmp    801ea8 <spawnl+0x12>
		argc++;
  801ea5:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ea8:	83 c2 04             	add    $0x4,%edx
  801eab:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801eaf:	75 f4                	jne    801ea5 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801eb1:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801eb8:	83 e2 f0             	and    $0xfffffff0,%edx
  801ebb:	29 d4                	sub    %edx,%esp
  801ebd:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ec1:	c1 ea 02             	shr    $0x2,%edx
  801ec4:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ecb:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ecd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ed0:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ed7:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ede:	00 
  801edf:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee6:	eb 0a                	jmp    801ef2 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ee8:	83 c0 01             	add    $0x1,%eax
  801eeb:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801eef:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ef2:	39 d0                	cmp    %edx,%eax
  801ef4:	75 f2                	jne    801ee8 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	56                   	push   %esi
  801efa:	ff 75 08             	pushl  0x8(%ebp)
  801efd:	e8 17 fa ff ff       	call   801919 <spawn>
}
  801f02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f05:	5b                   	pop    %ebx
  801f06:	5e                   	pop    %esi
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    

00801f09 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801f0f:	68 1c 33 80 00       	push   $0x80331c
  801f14:	ff 75 0c             	pushl  0xc(%ebp)
  801f17:	e8 1a e9 ff ff       	call   800836 <strcpy>
	return 0;
}
  801f1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f21:	c9                   	leave  
  801f22:	c3                   	ret    

00801f23 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	53                   	push   %ebx
  801f27:	83 ec 10             	sub    $0x10,%esp
  801f2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f2d:	53                   	push   %ebx
  801f2e:	e8 ca 0a 00 00       	call   8029fd <pageref>
  801f33:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801f36:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801f3b:	83 f8 01             	cmp    $0x1,%eax
  801f3e:	75 10                	jne    801f50 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801f40:	83 ec 0c             	sub    $0xc,%esp
  801f43:	ff 73 0c             	pushl  0xc(%ebx)
  801f46:	e8 c0 02 00 00       	call   80220b <nsipc_close>
  801f4b:	89 c2                	mov    %eax,%edx
  801f4d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801f50:	89 d0                	mov    %edx,%eax
  801f52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f55:	c9                   	leave  
  801f56:	c3                   	ret    

00801f57 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f5d:	6a 00                	push   $0x0
  801f5f:	ff 75 10             	pushl  0x10(%ebp)
  801f62:	ff 75 0c             	pushl  0xc(%ebp)
  801f65:	8b 45 08             	mov    0x8(%ebp),%eax
  801f68:	ff 70 0c             	pushl  0xc(%eax)
  801f6b:	e8 78 03 00 00       	call   8022e8 <nsipc_send>
}
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f78:	6a 00                	push   $0x0
  801f7a:	ff 75 10             	pushl  0x10(%ebp)
  801f7d:	ff 75 0c             	pushl  0xc(%ebp)
  801f80:	8b 45 08             	mov    0x8(%ebp),%eax
  801f83:	ff 70 0c             	pushl  0xc(%eax)
  801f86:	e8 f1 02 00 00       	call   80227c <nsipc_recv>
}
  801f8b:	c9                   	leave  
  801f8c:	c3                   	ret    

00801f8d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f8d:	55                   	push   %ebp
  801f8e:	89 e5                	mov    %esp,%ebp
  801f90:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f93:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f96:	52                   	push   %edx
  801f97:	50                   	push   %eax
  801f98:	e8 f4 f1 ff ff       	call   801191 <fd_lookup>
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 17                	js     801fbb <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa7:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  801fad:	39 08                	cmp    %ecx,(%eax)
  801faf:	75 05                	jne    801fb6 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801fb1:	8b 40 0c             	mov    0xc(%eax),%eax
  801fb4:	eb 05                	jmp    801fbb <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801fb6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801fbb:	c9                   	leave  
  801fbc:	c3                   	ret    

00801fbd <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
  801fc0:	56                   	push   %esi
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 1c             	sub    $0x1c,%esp
  801fc5:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801fc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fca:	50                   	push   %eax
  801fcb:	e8 72 f1 ff ff       	call   801142 <fd_alloc>
  801fd0:	89 c3                	mov    %eax,%ebx
  801fd2:	83 c4 10             	add    $0x10,%esp
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	78 1b                	js     801ff4 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801fd9:	83 ec 04             	sub    $0x4,%esp
  801fdc:	68 07 04 00 00       	push   $0x407
  801fe1:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe4:	6a 00                	push   $0x0
  801fe6:	e8 4e ec ff ff       	call   800c39 <sys_page_alloc>
  801feb:	89 c3                	mov    %eax,%ebx
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	85 c0                	test   %eax,%eax
  801ff2:	79 10                	jns    802004 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ff4:	83 ec 0c             	sub    $0xc,%esp
  801ff7:	56                   	push   %esi
  801ff8:	e8 0e 02 00 00       	call   80220b <nsipc_close>
		return r;
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	89 d8                	mov    %ebx,%eax
  802002:	eb 24                	jmp    802028 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802004:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80200a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80200f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802012:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802019:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80201c:	83 ec 0c             	sub    $0xc,%esp
  80201f:	50                   	push   %eax
  802020:	e8 f6 f0 ff ff       	call   80111b <fd2num>
  802025:	83 c4 10             	add    $0x10,%esp
}
  802028:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80202b:	5b                   	pop    %ebx
  80202c:	5e                   	pop    %esi
  80202d:	5d                   	pop    %ebp
  80202e:	c3                   	ret    

0080202f <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802035:	8b 45 08             	mov    0x8(%ebp),%eax
  802038:	e8 50 ff ff ff       	call   801f8d <fd2sockid>
		return r;
  80203d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80203f:	85 c0                	test   %eax,%eax
  802041:	78 1f                	js     802062 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802043:	83 ec 04             	sub    $0x4,%esp
  802046:	ff 75 10             	pushl  0x10(%ebp)
  802049:	ff 75 0c             	pushl  0xc(%ebp)
  80204c:	50                   	push   %eax
  80204d:	e8 12 01 00 00       	call   802164 <nsipc_accept>
  802052:	83 c4 10             	add    $0x10,%esp
		return r;
  802055:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802057:	85 c0                	test   %eax,%eax
  802059:	78 07                	js     802062 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80205b:	e8 5d ff ff ff       	call   801fbd <alloc_sockfd>
  802060:	89 c1                	mov    %eax,%ecx
}
  802062:	89 c8                	mov    %ecx,%eax
  802064:	c9                   	leave  
  802065:	c3                   	ret    

00802066 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802066:	55                   	push   %ebp
  802067:	89 e5                	mov    %esp,%ebp
  802069:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80206c:	8b 45 08             	mov    0x8(%ebp),%eax
  80206f:	e8 19 ff ff ff       	call   801f8d <fd2sockid>
  802074:	85 c0                	test   %eax,%eax
  802076:	78 12                	js     80208a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802078:	83 ec 04             	sub    $0x4,%esp
  80207b:	ff 75 10             	pushl  0x10(%ebp)
  80207e:	ff 75 0c             	pushl  0xc(%ebp)
  802081:	50                   	push   %eax
  802082:	e8 2d 01 00 00       	call   8021b4 <nsipc_bind>
  802087:	83 c4 10             	add    $0x10,%esp
}
  80208a:	c9                   	leave  
  80208b:	c3                   	ret    

0080208c <shutdown>:

int
shutdown(int s, int how)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802092:	8b 45 08             	mov    0x8(%ebp),%eax
  802095:	e8 f3 fe ff ff       	call   801f8d <fd2sockid>
  80209a:	85 c0                	test   %eax,%eax
  80209c:	78 0f                	js     8020ad <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80209e:	83 ec 08             	sub    $0x8,%esp
  8020a1:	ff 75 0c             	pushl  0xc(%ebp)
  8020a4:	50                   	push   %eax
  8020a5:	e8 3f 01 00 00       	call   8021e9 <nsipc_shutdown>
  8020aa:	83 c4 10             	add    $0x10,%esp
}
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    

008020af <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b8:	e8 d0 fe ff ff       	call   801f8d <fd2sockid>
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	78 12                	js     8020d3 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8020c1:	83 ec 04             	sub    $0x4,%esp
  8020c4:	ff 75 10             	pushl  0x10(%ebp)
  8020c7:	ff 75 0c             	pushl  0xc(%ebp)
  8020ca:	50                   	push   %eax
  8020cb:	e8 55 01 00 00       	call   802225 <nsipc_connect>
  8020d0:	83 c4 10             	add    $0x10,%esp
}
  8020d3:	c9                   	leave  
  8020d4:	c3                   	ret    

008020d5 <listen>:

int
listen(int s, int backlog)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020db:	8b 45 08             	mov    0x8(%ebp),%eax
  8020de:	e8 aa fe ff ff       	call   801f8d <fd2sockid>
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	78 0f                	js     8020f6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8020e7:	83 ec 08             	sub    $0x8,%esp
  8020ea:	ff 75 0c             	pushl  0xc(%ebp)
  8020ed:	50                   	push   %eax
  8020ee:	e8 67 01 00 00       	call   80225a <nsipc_listen>
  8020f3:	83 c4 10             	add    $0x10,%esp
}
  8020f6:	c9                   	leave  
  8020f7:	c3                   	ret    

008020f8 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020fe:	ff 75 10             	pushl  0x10(%ebp)
  802101:	ff 75 0c             	pushl  0xc(%ebp)
  802104:	ff 75 08             	pushl  0x8(%ebp)
  802107:	e8 3a 02 00 00       	call   802346 <nsipc_socket>
  80210c:	83 c4 10             	add    $0x10,%esp
  80210f:	85 c0                	test   %eax,%eax
  802111:	78 05                	js     802118 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802113:	e8 a5 fe ff ff       	call   801fbd <alloc_sockfd>
}
  802118:	c9                   	leave  
  802119:	c3                   	ret    

0080211a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80211a:	55                   	push   %ebp
  80211b:	89 e5                	mov    %esp,%ebp
  80211d:	53                   	push   %ebx
  80211e:	83 ec 04             	sub    $0x4,%esp
  802121:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802123:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80212a:	75 12                	jne    80213e <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80212c:	83 ec 0c             	sub    $0xc,%esp
  80212f:	6a 02                	push   $0x2
  802131:	e8 8e 08 00 00       	call   8029c4 <ipc_find_env>
  802136:	a3 04 50 80 00       	mov    %eax,0x805004
  80213b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80213e:	6a 07                	push   $0x7
  802140:	68 00 70 80 00       	push   $0x807000
  802145:	53                   	push   %ebx
  802146:	ff 35 04 50 80 00    	pushl  0x805004
  80214c:	e8 1f 08 00 00       	call   802970 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802151:	83 c4 0c             	add    $0xc,%esp
  802154:	6a 00                	push   $0x0
  802156:	6a 00                	push   $0x0
  802158:	6a 00                	push   $0x0
  80215a:	e8 aa 07 00 00       	call   802909 <ipc_recv>
}
  80215f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802162:	c9                   	leave  
  802163:	c3                   	ret    

00802164 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	56                   	push   %esi
  802168:	53                   	push   %ebx
  802169:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80216c:	8b 45 08             	mov    0x8(%ebp),%eax
  80216f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802174:	8b 06                	mov    (%esi),%eax
  802176:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80217b:	b8 01 00 00 00       	mov    $0x1,%eax
  802180:	e8 95 ff ff ff       	call   80211a <nsipc>
  802185:	89 c3                	mov    %eax,%ebx
  802187:	85 c0                	test   %eax,%eax
  802189:	78 20                	js     8021ab <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80218b:	83 ec 04             	sub    $0x4,%esp
  80218e:	ff 35 10 70 80 00    	pushl  0x807010
  802194:	68 00 70 80 00       	push   $0x807000
  802199:	ff 75 0c             	pushl  0xc(%ebp)
  80219c:	e8 27 e8 ff ff       	call   8009c8 <memmove>
		*addrlen = ret->ret_addrlen;
  8021a1:	a1 10 70 80 00       	mov    0x807010,%eax
  8021a6:	89 06                	mov    %eax,(%esi)
  8021a8:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8021ab:	89 d8                	mov    %ebx,%eax
  8021ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b0:	5b                   	pop    %ebx
  8021b1:	5e                   	pop    %esi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    

008021b4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8021b4:	55                   	push   %ebp
  8021b5:	89 e5                	mov    %esp,%ebp
  8021b7:	53                   	push   %ebx
  8021b8:	83 ec 08             	sub    $0x8,%esp
  8021bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8021be:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c1:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8021c6:	53                   	push   %ebx
  8021c7:	ff 75 0c             	pushl  0xc(%ebp)
  8021ca:	68 04 70 80 00       	push   $0x807004
  8021cf:	e8 f4 e7 ff ff       	call   8009c8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8021d4:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8021da:	b8 02 00 00 00       	mov    $0x2,%eax
  8021df:	e8 36 ff ff ff       	call   80211a <nsipc>
}
  8021e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021e7:	c9                   	leave  
  8021e8:	c3                   	ret    

008021e9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8021e9:	55                   	push   %ebp
  8021ea:	89 e5                	mov    %esp,%ebp
  8021ec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8021f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021fa:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8021ff:	b8 03 00 00 00       	mov    $0x3,%eax
  802204:	e8 11 ff ff ff       	call   80211a <nsipc>
}
  802209:	c9                   	leave  
  80220a:	c3                   	ret    

0080220b <nsipc_close>:

int
nsipc_close(int s)
{
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802211:	8b 45 08             	mov    0x8(%ebp),%eax
  802214:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802219:	b8 04 00 00 00       	mov    $0x4,%eax
  80221e:	e8 f7 fe ff ff       	call   80211a <nsipc>
}
  802223:	c9                   	leave  
  802224:	c3                   	ret    

00802225 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	53                   	push   %ebx
  802229:	83 ec 08             	sub    $0x8,%esp
  80222c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80222f:	8b 45 08             	mov    0x8(%ebp),%eax
  802232:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802237:	53                   	push   %ebx
  802238:	ff 75 0c             	pushl  0xc(%ebp)
  80223b:	68 04 70 80 00       	push   $0x807004
  802240:	e8 83 e7 ff ff       	call   8009c8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802245:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80224b:	b8 05 00 00 00       	mov    $0x5,%eax
  802250:	e8 c5 fe ff ff       	call   80211a <nsipc>
}
  802255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802258:	c9                   	leave  
  802259:	c3                   	ret    

0080225a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80225a:	55                   	push   %ebp
  80225b:	89 e5                	mov    %esp,%ebp
  80225d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802260:	8b 45 08             	mov    0x8(%ebp),%eax
  802263:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802268:	8b 45 0c             	mov    0xc(%ebp),%eax
  80226b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802270:	b8 06 00 00 00       	mov    $0x6,%eax
  802275:	e8 a0 fe ff ff       	call   80211a <nsipc>
}
  80227a:	c9                   	leave  
  80227b:	c3                   	ret    

0080227c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	56                   	push   %esi
  802280:	53                   	push   %ebx
  802281:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802284:	8b 45 08             	mov    0x8(%ebp),%eax
  802287:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80228c:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802292:	8b 45 14             	mov    0x14(%ebp),%eax
  802295:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80229a:	b8 07 00 00 00       	mov    $0x7,%eax
  80229f:	e8 76 fe ff ff       	call   80211a <nsipc>
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	85 c0                	test   %eax,%eax
  8022a8:	78 35                	js     8022df <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8022aa:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022af:	7f 04                	jg     8022b5 <nsipc_recv+0x39>
  8022b1:	39 c6                	cmp    %eax,%esi
  8022b3:	7d 16                	jge    8022cb <nsipc_recv+0x4f>
  8022b5:	68 28 33 80 00       	push   $0x803328
  8022ba:	68 3b 32 80 00       	push   $0x80323b
  8022bf:	6a 62                	push   $0x62
  8022c1:	68 3d 33 80 00       	push   $0x80333d
  8022c6:	e8 0d df ff ff       	call   8001d8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8022cb:	83 ec 04             	sub    $0x4,%esp
  8022ce:	50                   	push   %eax
  8022cf:	68 00 70 80 00       	push   $0x807000
  8022d4:	ff 75 0c             	pushl  0xc(%ebp)
  8022d7:	e8 ec e6 ff ff       	call   8009c8 <memmove>
  8022dc:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8022df:	89 d8                	mov    %ebx,%eax
  8022e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e4:	5b                   	pop    %ebx
  8022e5:	5e                   	pop    %esi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    

008022e8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
  8022eb:	53                   	push   %ebx
  8022ec:	83 ec 04             	sub    $0x4,%esp
  8022ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f5:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8022fa:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802300:	7e 16                	jle    802318 <nsipc_send+0x30>
  802302:	68 49 33 80 00       	push   $0x803349
  802307:	68 3b 32 80 00       	push   $0x80323b
  80230c:	6a 6d                	push   $0x6d
  80230e:	68 3d 33 80 00       	push   $0x80333d
  802313:	e8 c0 de ff ff       	call   8001d8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802318:	83 ec 04             	sub    $0x4,%esp
  80231b:	53                   	push   %ebx
  80231c:	ff 75 0c             	pushl  0xc(%ebp)
  80231f:	68 0c 70 80 00       	push   $0x80700c
  802324:	e8 9f e6 ff ff       	call   8009c8 <memmove>
	nsipcbuf.send.req_size = size;
  802329:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80232f:	8b 45 14             	mov    0x14(%ebp),%eax
  802332:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802337:	b8 08 00 00 00       	mov    $0x8,%eax
  80233c:	e8 d9 fd ff ff       	call   80211a <nsipc>
}
  802341:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802344:	c9                   	leave  
  802345:	c3                   	ret    

00802346 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802346:	55                   	push   %ebp
  802347:	89 e5                	mov    %esp,%ebp
  802349:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80234c:	8b 45 08             	mov    0x8(%ebp),%eax
  80234f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802354:	8b 45 0c             	mov    0xc(%ebp),%eax
  802357:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80235c:	8b 45 10             	mov    0x10(%ebp),%eax
  80235f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802364:	b8 09 00 00 00       	mov    $0x9,%eax
  802369:	e8 ac fd ff ff       	call   80211a <nsipc>
}
  80236e:	c9                   	leave  
  80236f:	c3                   	ret    

00802370 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	56                   	push   %esi
  802374:	53                   	push   %ebx
  802375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802378:	83 ec 0c             	sub    $0xc,%esp
  80237b:	ff 75 08             	pushl  0x8(%ebp)
  80237e:	e8 a8 ed ff ff       	call   80112b <fd2data>
  802383:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802385:	83 c4 08             	add    $0x8,%esp
  802388:	68 55 33 80 00       	push   $0x803355
  80238d:	53                   	push   %ebx
  80238e:	e8 a3 e4 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802393:	8b 46 04             	mov    0x4(%esi),%eax
  802396:	2b 06                	sub    (%esi),%eax
  802398:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80239e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8023a5:	00 00 00 
	stat->st_dev = &devpipe;
  8023a8:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  8023af:	40 80 00 
	return 0;
}
  8023b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ba:	5b                   	pop    %ebx
  8023bb:	5e                   	pop    %esi
  8023bc:	5d                   	pop    %ebp
  8023bd:	c3                   	ret    

008023be <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	53                   	push   %ebx
  8023c2:	83 ec 0c             	sub    $0xc,%esp
  8023c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8023c8:	53                   	push   %ebx
  8023c9:	6a 00                	push   $0x0
  8023cb:	e8 ee e8 ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8023d0:	89 1c 24             	mov    %ebx,(%esp)
  8023d3:	e8 53 ed ff ff       	call   80112b <fd2data>
  8023d8:	83 c4 08             	add    $0x8,%esp
  8023db:	50                   	push   %eax
  8023dc:	6a 00                	push   $0x0
  8023de:	e8 db e8 ff ff       	call   800cbe <sys_page_unmap>
}
  8023e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023e6:	c9                   	leave  
  8023e7:	c3                   	ret    

008023e8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8023e8:	55                   	push   %ebp
  8023e9:	89 e5                	mov    %esp,%ebp
  8023eb:	57                   	push   %edi
  8023ec:	56                   	push   %esi
  8023ed:	53                   	push   %ebx
  8023ee:	83 ec 1c             	sub    $0x1c,%esp
  8023f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8023f4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8023f6:	a1 08 50 80 00       	mov    0x805008,%eax
  8023fb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8023fe:	83 ec 0c             	sub    $0xc,%esp
  802401:	ff 75 e0             	pushl  -0x20(%ebp)
  802404:	e8 f4 05 00 00       	call   8029fd <pageref>
  802409:	89 c3                	mov    %eax,%ebx
  80240b:	89 3c 24             	mov    %edi,(%esp)
  80240e:	e8 ea 05 00 00       	call   8029fd <pageref>
  802413:	83 c4 10             	add    $0x10,%esp
  802416:	39 c3                	cmp    %eax,%ebx
  802418:	0f 94 c1             	sete   %cl
  80241b:	0f b6 c9             	movzbl %cl,%ecx
  80241e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802421:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802427:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80242a:	39 ce                	cmp    %ecx,%esi
  80242c:	74 1b                	je     802449 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80242e:	39 c3                	cmp    %eax,%ebx
  802430:	75 c4                	jne    8023f6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802432:	8b 42 58             	mov    0x58(%edx),%eax
  802435:	ff 75 e4             	pushl  -0x1c(%ebp)
  802438:	50                   	push   %eax
  802439:	56                   	push   %esi
  80243a:	68 5c 33 80 00       	push   $0x80335c
  80243f:	e8 6d de ff ff       	call   8002b1 <cprintf>
  802444:	83 c4 10             	add    $0x10,%esp
  802447:	eb ad                	jmp    8023f6 <_pipeisclosed+0xe>
	}
}
  802449:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80244c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80244f:	5b                   	pop    %ebx
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    

00802454 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	57                   	push   %edi
  802458:	56                   	push   %esi
  802459:	53                   	push   %ebx
  80245a:	83 ec 28             	sub    $0x28,%esp
  80245d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802460:	56                   	push   %esi
  802461:	e8 c5 ec ff ff       	call   80112b <fd2data>
  802466:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802468:	83 c4 10             	add    $0x10,%esp
  80246b:	bf 00 00 00 00       	mov    $0x0,%edi
  802470:	eb 4b                	jmp    8024bd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802472:	89 da                	mov    %ebx,%edx
  802474:	89 f0                	mov    %esi,%eax
  802476:	e8 6d ff ff ff       	call   8023e8 <_pipeisclosed>
  80247b:	85 c0                	test   %eax,%eax
  80247d:	75 48                	jne    8024c7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80247f:	e8 96 e7 ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802484:	8b 43 04             	mov    0x4(%ebx),%eax
  802487:	8b 0b                	mov    (%ebx),%ecx
  802489:	8d 51 20             	lea    0x20(%ecx),%edx
  80248c:	39 d0                	cmp    %edx,%eax
  80248e:	73 e2                	jae    802472 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802490:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802493:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802497:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80249a:	89 c2                	mov    %eax,%edx
  80249c:	c1 fa 1f             	sar    $0x1f,%edx
  80249f:	89 d1                	mov    %edx,%ecx
  8024a1:	c1 e9 1b             	shr    $0x1b,%ecx
  8024a4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8024a7:	83 e2 1f             	and    $0x1f,%edx
  8024aa:	29 ca                	sub    %ecx,%edx
  8024ac:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8024b0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8024b4:	83 c0 01             	add    $0x1,%eax
  8024b7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024ba:	83 c7 01             	add    $0x1,%edi
  8024bd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8024c0:	75 c2                	jne    802484 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8024c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8024c5:	eb 05                	jmp    8024cc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024c7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8024cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024cf:	5b                   	pop    %ebx
  8024d0:	5e                   	pop    %esi
  8024d1:	5f                   	pop    %edi
  8024d2:	5d                   	pop    %ebp
  8024d3:	c3                   	ret    

008024d4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024d4:	55                   	push   %ebp
  8024d5:	89 e5                	mov    %esp,%ebp
  8024d7:	57                   	push   %edi
  8024d8:	56                   	push   %esi
  8024d9:	53                   	push   %ebx
  8024da:	83 ec 18             	sub    $0x18,%esp
  8024dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8024e0:	57                   	push   %edi
  8024e1:	e8 45 ec ff ff       	call   80112b <fd2data>
  8024e6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024e8:	83 c4 10             	add    $0x10,%esp
  8024eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024f0:	eb 3d                	jmp    80252f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8024f2:	85 db                	test   %ebx,%ebx
  8024f4:	74 04                	je     8024fa <devpipe_read+0x26>
				return i;
  8024f6:	89 d8                	mov    %ebx,%eax
  8024f8:	eb 44                	jmp    80253e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8024fa:	89 f2                	mov    %esi,%edx
  8024fc:	89 f8                	mov    %edi,%eax
  8024fe:	e8 e5 fe ff ff       	call   8023e8 <_pipeisclosed>
  802503:	85 c0                	test   %eax,%eax
  802505:	75 32                	jne    802539 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802507:	e8 0e e7 ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80250c:	8b 06                	mov    (%esi),%eax
  80250e:	3b 46 04             	cmp    0x4(%esi),%eax
  802511:	74 df                	je     8024f2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802513:	99                   	cltd   
  802514:	c1 ea 1b             	shr    $0x1b,%edx
  802517:	01 d0                	add    %edx,%eax
  802519:	83 e0 1f             	and    $0x1f,%eax
  80251c:	29 d0                	sub    %edx,%eax
  80251e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802523:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802526:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802529:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80252c:	83 c3 01             	add    $0x1,%ebx
  80252f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802532:	75 d8                	jne    80250c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802534:	8b 45 10             	mov    0x10(%ebp),%eax
  802537:	eb 05                	jmp    80253e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802539:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80253e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802541:	5b                   	pop    %ebx
  802542:	5e                   	pop    %esi
  802543:	5f                   	pop    %edi
  802544:	5d                   	pop    %ebp
  802545:	c3                   	ret    

00802546 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802546:	55                   	push   %ebp
  802547:	89 e5                	mov    %esp,%ebp
  802549:	56                   	push   %esi
  80254a:	53                   	push   %ebx
  80254b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80254e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802551:	50                   	push   %eax
  802552:	e8 eb eb ff ff       	call   801142 <fd_alloc>
  802557:	83 c4 10             	add    $0x10,%esp
  80255a:	89 c2                	mov    %eax,%edx
  80255c:	85 c0                	test   %eax,%eax
  80255e:	0f 88 2c 01 00 00    	js     802690 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802564:	83 ec 04             	sub    $0x4,%esp
  802567:	68 07 04 00 00       	push   $0x407
  80256c:	ff 75 f4             	pushl  -0xc(%ebp)
  80256f:	6a 00                	push   $0x0
  802571:	e8 c3 e6 ff ff       	call   800c39 <sys_page_alloc>
  802576:	83 c4 10             	add    $0x10,%esp
  802579:	89 c2                	mov    %eax,%edx
  80257b:	85 c0                	test   %eax,%eax
  80257d:	0f 88 0d 01 00 00    	js     802690 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802583:	83 ec 0c             	sub    $0xc,%esp
  802586:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802589:	50                   	push   %eax
  80258a:	e8 b3 eb ff ff       	call   801142 <fd_alloc>
  80258f:	89 c3                	mov    %eax,%ebx
  802591:	83 c4 10             	add    $0x10,%esp
  802594:	85 c0                	test   %eax,%eax
  802596:	0f 88 e2 00 00 00    	js     80267e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80259c:	83 ec 04             	sub    $0x4,%esp
  80259f:	68 07 04 00 00       	push   $0x407
  8025a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8025a7:	6a 00                	push   $0x0
  8025a9:	e8 8b e6 ff ff       	call   800c39 <sys_page_alloc>
  8025ae:	89 c3                	mov    %eax,%ebx
  8025b0:	83 c4 10             	add    $0x10,%esp
  8025b3:	85 c0                	test   %eax,%eax
  8025b5:	0f 88 c3 00 00 00    	js     80267e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8025bb:	83 ec 0c             	sub    $0xc,%esp
  8025be:	ff 75 f4             	pushl  -0xc(%ebp)
  8025c1:	e8 65 eb ff ff       	call   80112b <fd2data>
  8025c6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025c8:	83 c4 0c             	add    $0xc,%esp
  8025cb:	68 07 04 00 00       	push   $0x407
  8025d0:	50                   	push   %eax
  8025d1:	6a 00                	push   $0x0
  8025d3:	e8 61 e6 ff ff       	call   800c39 <sys_page_alloc>
  8025d8:	89 c3                	mov    %eax,%ebx
  8025da:	83 c4 10             	add    $0x10,%esp
  8025dd:	85 c0                	test   %eax,%eax
  8025df:	0f 88 89 00 00 00    	js     80266e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025e5:	83 ec 0c             	sub    $0xc,%esp
  8025e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8025eb:	e8 3b eb ff ff       	call   80112b <fd2data>
  8025f0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8025f7:	50                   	push   %eax
  8025f8:	6a 00                	push   $0x0
  8025fa:	56                   	push   %esi
  8025fb:	6a 00                	push   $0x0
  8025fd:	e8 7a e6 ff ff       	call   800c7c <sys_page_map>
  802602:	89 c3                	mov    %eax,%ebx
  802604:	83 c4 20             	add    $0x20,%esp
  802607:	85 c0                	test   %eax,%eax
  802609:	78 55                	js     802660 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80260b:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802611:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802614:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802616:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802619:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802620:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802626:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802629:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80262b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80262e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802635:	83 ec 0c             	sub    $0xc,%esp
  802638:	ff 75 f4             	pushl  -0xc(%ebp)
  80263b:	e8 db ea ff ff       	call   80111b <fd2num>
  802640:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802643:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802645:	83 c4 04             	add    $0x4,%esp
  802648:	ff 75 f0             	pushl  -0x10(%ebp)
  80264b:	e8 cb ea ff ff       	call   80111b <fd2num>
  802650:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802653:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802656:	83 c4 10             	add    $0x10,%esp
  802659:	ba 00 00 00 00       	mov    $0x0,%edx
  80265e:	eb 30                	jmp    802690 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802660:	83 ec 08             	sub    $0x8,%esp
  802663:	56                   	push   %esi
  802664:	6a 00                	push   $0x0
  802666:	e8 53 e6 ff ff       	call   800cbe <sys_page_unmap>
  80266b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80266e:	83 ec 08             	sub    $0x8,%esp
  802671:	ff 75 f0             	pushl  -0x10(%ebp)
  802674:	6a 00                	push   $0x0
  802676:	e8 43 e6 ff ff       	call   800cbe <sys_page_unmap>
  80267b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80267e:	83 ec 08             	sub    $0x8,%esp
  802681:	ff 75 f4             	pushl  -0xc(%ebp)
  802684:	6a 00                	push   $0x0
  802686:	e8 33 e6 ff ff       	call   800cbe <sys_page_unmap>
  80268b:	83 c4 10             	add    $0x10,%esp
  80268e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802690:	89 d0                	mov    %edx,%eax
  802692:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802695:	5b                   	pop    %ebx
  802696:	5e                   	pop    %esi
  802697:	5d                   	pop    %ebp
  802698:	c3                   	ret    

00802699 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802699:	55                   	push   %ebp
  80269a:	89 e5                	mov    %esp,%ebp
  80269c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80269f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026a2:	50                   	push   %eax
  8026a3:	ff 75 08             	pushl  0x8(%ebp)
  8026a6:	e8 e6 ea ff ff       	call   801191 <fd_lookup>
  8026ab:	83 c4 10             	add    $0x10,%esp
  8026ae:	85 c0                	test   %eax,%eax
  8026b0:	78 18                	js     8026ca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8026b2:	83 ec 0c             	sub    $0xc,%esp
  8026b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8026b8:	e8 6e ea ff ff       	call   80112b <fd2data>
	return _pipeisclosed(fd, p);
  8026bd:	89 c2                	mov    %eax,%edx
  8026bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026c2:	e8 21 fd ff ff       	call   8023e8 <_pipeisclosed>
  8026c7:	83 c4 10             	add    $0x10,%esp
}
  8026ca:	c9                   	leave  
  8026cb:	c3                   	ret    

008026cc <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8026cc:	55                   	push   %ebp
  8026cd:	89 e5                	mov    %esp,%ebp
  8026cf:	56                   	push   %esi
  8026d0:	53                   	push   %ebx
  8026d1:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8026d4:	85 f6                	test   %esi,%esi
  8026d6:	75 16                	jne    8026ee <wait+0x22>
  8026d8:	68 74 33 80 00       	push   $0x803374
  8026dd:	68 3b 32 80 00       	push   $0x80323b
  8026e2:	6a 09                	push   $0x9
  8026e4:	68 7f 33 80 00       	push   $0x80337f
  8026e9:	e8 ea da ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  8026ee:	89 f3                	mov    %esi,%ebx
  8026f0:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026f6:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8026f9:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8026ff:	eb 05                	jmp    802706 <wait+0x3a>
		sys_yield();
  802701:	e8 14 e5 ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802706:	8b 43 48             	mov    0x48(%ebx),%eax
  802709:	39 c6                	cmp    %eax,%esi
  80270b:	75 07                	jne    802714 <wait+0x48>
  80270d:	8b 43 54             	mov    0x54(%ebx),%eax
  802710:	85 c0                	test   %eax,%eax
  802712:	75 ed                	jne    802701 <wait+0x35>
		sys_yield();
}
  802714:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802717:	5b                   	pop    %ebx
  802718:	5e                   	pop    %esi
  802719:	5d                   	pop    %ebp
  80271a:	c3                   	ret    

0080271b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80271b:	55                   	push   %ebp
  80271c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80271e:	b8 00 00 00 00       	mov    $0x0,%eax
  802723:	5d                   	pop    %ebp
  802724:	c3                   	ret    

00802725 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802725:	55                   	push   %ebp
  802726:	89 e5                	mov    %esp,%ebp
  802728:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80272b:	68 8a 33 80 00       	push   $0x80338a
  802730:	ff 75 0c             	pushl  0xc(%ebp)
  802733:	e8 fe e0 ff ff       	call   800836 <strcpy>
	return 0;
}
  802738:	b8 00 00 00 00       	mov    $0x0,%eax
  80273d:	c9                   	leave  
  80273e:	c3                   	ret    

0080273f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80273f:	55                   	push   %ebp
  802740:	89 e5                	mov    %esp,%ebp
  802742:	57                   	push   %edi
  802743:	56                   	push   %esi
  802744:	53                   	push   %ebx
  802745:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80274b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802750:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802756:	eb 2d                	jmp    802785 <devcons_write+0x46>
		m = n - tot;
  802758:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80275b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80275d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802760:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802765:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802768:	83 ec 04             	sub    $0x4,%esp
  80276b:	53                   	push   %ebx
  80276c:	03 45 0c             	add    0xc(%ebp),%eax
  80276f:	50                   	push   %eax
  802770:	57                   	push   %edi
  802771:	e8 52 e2 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  802776:	83 c4 08             	add    $0x8,%esp
  802779:	53                   	push   %ebx
  80277a:	57                   	push   %edi
  80277b:	e8 fd e3 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802780:	01 de                	add    %ebx,%esi
  802782:	83 c4 10             	add    $0x10,%esp
  802785:	89 f0                	mov    %esi,%eax
  802787:	3b 75 10             	cmp    0x10(%ebp),%esi
  80278a:	72 cc                	jb     802758 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80278c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80278f:	5b                   	pop    %ebx
  802790:	5e                   	pop    %esi
  802791:	5f                   	pop    %edi
  802792:	5d                   	pop    %ebp
  802793:	c3                   	ret    

00802794 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802794:	55                   	push   %ebp
  802795:	89 e5                	mov    %esp,%ebp
  802797:	83 ec 08             	sub    $0x8,%esp
  80279a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80279f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027a3:	74 2a                	je     8027cf <devcons_read+0x3b>
  8027a5:	eb 05                	jmp    8027ac <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8027a7:	e8 6e e4 ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8027ac:	e8 ea e3 ff ff       	call   800b9b <sys_cgetc>
  8027b1:	85 c0                	test   %eax,%eax
  8027b3:	74 f2                	je     8027a7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8027b5:	85 c0                	test   %eax,%eax
  8027b7:	78 16                	js     8027cf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8027b9:	83 f8 04             	cmp    $0x4,%eax
  8027bc:	74 0c                	je     8027ca <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8027be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027c1:	88 02                	mov    %al,(%edx)
	return 1;
  8027c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8027c8:	eb 05                	jmp    8027cf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8027ca:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8027cf:	c9                   	leave  
  8027d0:	c3                   	ret    

008027d1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8027d1:	55                   	push   %ebp
  8027d2:	89 e5                	mov    %esp,%ebp
  8027d4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8027d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8027da:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8027dd:	6a 01                	push   $0x1
  8027df:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8027e2:	50                   	push   %eax
  8027e3:	e8 95 e3 ff ff       	call   800b7d <sys_cputs>
}
  8027e8:	83 c4 10             	add    $0x10,%esp
  8027eb:	c9                   	leave  
  8027ec:	c3                   	ret    

008027ed <getchar>:

int
getchar(void)
{
  8027ed:	55                   	push   %ebp
  8027ee:	89 e5                	mov    %esp,%ebp
  8027f0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8027f3:	6a 01                	push   $0x1
  8027f5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8027f8:	50                   	push   %eax
  8027f9:	6a 00                	push   $0x0
  8027fb:	e8 f7 eb ff ff       	call   8013f7 <read>
	if (r < 0)
  802800:	83 c4 10             	add    $0x10,%esp
  802803:	85 c0                	test   %eax,%eax
  802805:	78 0f                	js     802816 <getchar+0x29>
		return r;
	if (r < 1)
  802807:	85 c0                	test   %eax,%eax
  802809:	7e 06                	jle    802811 <getchar+0x24>
		return -E_EOF;
	return c;
  80280b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80280f:	eb 05                	jmp    802816 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802811:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802816:	c9                   	leave  
  802817:	c3                   	ret    

00802818 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802818:	55                   	push   %ebp
  802819:	89 e5                	mov    %esp,%ebp
  80281b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80281e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802821:	50                   	push   %eax
  802822:	ff 75 08             	pushl  0x8(%ebp)
  802825:	e8 67 e9 ff ff       	call   801191 <fd_lookup>
  80282a:	83 c4 10             	add    $0x10,%esp
  80282d:	85 c0                	test   %eax,%eax
  80282f:	78 11                	js     802842 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802831:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802834:	8b 15 60 40 80 00    	mov    0x804060,%edx
  80283a:	39 10                	cmp    %edx,(%eax)
  80283c:	0f 94 c0             	sete   %al
  80283f:	0f b6 c0             	movzbl %al,%eax
}
  802842:	c9                   	leave  
  802843:	c3                   	ret    

00802844 <opencons>:

int
opencons(void)
{
  802844:	55                   	push   %ebp
  802845:	89 e5                	mov    %esp,%ebp
  802847:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80284a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80284d:	50                   	push   %eax
  80284e:	e8 ef e8 ff ff       	call   801142 <fd_alloc>
  802853:	83 c4 10             	add    $0x10,%esp
		return r;
  802856:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802858:	85 c0                	test   %eax,%eax
  80285a:	78 3e                	js     80289a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80285c:	83 ec 04             	sub    $0x4,%esp
  80285f:	68 07 04 00 00       	push   $0x407
  802864:	ff 75 f4             	pushl  -0xc(%ebp)
  802867:	6a 00                	push   $0x0
  802869:	e8 cb e3 ff ff       	call   800c39 <sys_page_alloc>
  80286e:	83 c4 10             	add    $0x10,%esp
		return r;
  802871:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802873:	85 c0                	test   %eax,%eax
  802875:	78 23                	js     80289a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802877:	8b 15 60 40 80 00    	mov    0x804060,%edx
  80287d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802880:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802885:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80288c:	83 ec 0c             	sub    $0xc,%esp
  80288f:	50                   	push   %eax
  802890:	e8 86 e8 ff ff       	call   80111b <fd2num>
  802895:	89 c2                	mov    %eax,%edx
  802897:	83 c4 10             	add    $0x10,%esp
}
  80289a:	89 d0                	mov    %edx,%eax
  80289c:	c9                   	leave  
  80289d:	c3                   	ret    

0080289e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80289e:	55                   	push   %ebp
  80289f:	89 e5                	mov    %esp,%ebp
  8028a1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028a4:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8028ab:	75 2e                	jne    8028db <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8028ad:	e8 49 e3 ff ff       	call   800bfb <sys_getenvid>
  8028b2:	83 ec 04             	sub    $0x4,%esp
  8028b5:	68 07 0e 00 00       	push   $0xe07
  8028ba:	68 00 f0 bf ee       	push   $0xeebff000
  8028bf:	50                   	push   %eax
  8028c0:	e8 74 e3 ff ff       	call   800c39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8028c5:	e8 31 e3 ff ff       	call   800bfb <sys_getenvid>
  8028ca:	83 c4 08             	add    $0x8,%esp
  8028cd:	68 e5 28 80 00       	push   $0x8028e5
  8028d2:	50                   	push   %eax
  8028d3:	e8 ac e4 ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
  8028d8:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8028db:	8b 45 08             	mov    0x8(%ebp),%eax
  8028de:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8028e3:	c9                   	leave  
  8028e4:	c3                   	ret    

008028e5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8028e5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8028e6:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8028eb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8028ed:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8028f0:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8028f4:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8028f8:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8028fb:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8028fe:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8028ff:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802902:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802903:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802904:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802908:	c3                   	ret    

00802909 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802909:	55                   	push   %ebp
  80290a:	89 e5                	mov    %esp,%ebp
  80290c:	56                   	push   %esi
  80290d:	53                   	push   %ebx
  80290e:	8b 75 08             	mov    0x8(%ebp),%esi
  802911:	8b 45 0c             	mov    0xc(%ebp),%eax
  802914:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802917:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802919:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80291e:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802921:	83 ec 0c             	sub    $0xc,%esp
  802924:	50                   	push   %eax
  802925:	e8 bf e4 ff ff       	call   800de9 <sys_ipc_recv>

	if (from_env_store != NULL)
  80292a:	83 c4 10             	add    $0x10,%esp
  80292d:	85 f6                	test   %esi,%esi
  80292f:	74 14                	je     802945 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802931:	ba 00 00 00 00       	mov    $0x0,%edx
  802936:	85 c0                	test   %eax,%eax
  802938:	78 09                	js     802943 <ipc_recv+0x3a>
  80293a:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802940:	8b 52 74             	mov    0x74(%edx),%edx
  802943:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802945:	85 db                	test   %ebx,%ebx
  802947:	74 14                	je     80295d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802949:	ba 00 00 00 00       	mov    $0x0,%edx
  80294e:	85 c0                	test   %eax,%eax
  802950:	78 09                	js     80295b <ipc_recv+0x52>
  802952:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802958:	8b 52 78             	mov    0x78(%edx),%edx
  80295b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80295d:	85 c0                	test   %eax,%eax
  80295f:	78 08                	js     802969 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802961:	a1 08 50 80 00       	mov    0x805008,%eax
  802966:	8b 40 70             	mov    0x70(%eax),%eax
}
  802969:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80296c:	5b                   	pop    %ebx
  80296d:	5e                   	pop    %esi
  80296e:	5d                   	pop    %ebp
  80296f:	c3                   	ret    

00802970 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802970:	55                   	push   %ebp
  802971:	89 e5                	mov    %esp,%ebp
  802973:	57                   	push   %edi
  802974:	56                   	push   %esi
  802975:	53                   	push   %ebx
  802976:	83 ec 0c             	sub    $0xc,%esp
  802979:	8b 7d 08             	mov    0x8(%ebp),%edi
  80297c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80297f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802982:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802984:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802989:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80298c:	ff 75 14             	pushl  0x14(%ebp)
  80298f:	53                   	push   %ebx
  802990:	56                   	push   %esi
  802991:	57                   	push   %edi
  802992:	e8 2f e4 ff ff       	call   800dc6 <sys_ipc_try_send>

		if (err < 0) {
  802997:	83 c4 10             	add    $0x10,%esp
  80299a:	85 c0                	test   %eax,%eax
  80299c:	79 1e                	jns    8029bc <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80299e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029a1:	75 07                	jne    8029aa <ipc_send+0x3a>
				sys_yield();
  8029a3:	e8 72 e2 ff ff       	call   800c1a <sys_yield>
  8029a8:	eb e2                	jmp    80298c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8029aa:	50                   	push   %eax
  8029ab:	68 96 33 80 00       	push   $0x803396
  8029b0:	6a 49                	push   $0x49
  8029b2:	68 a3 33 80 00       	push   $0x8033a3
  8029b7:	e8 1c d8 ff ff       	call   8001d8 <_panic>
		}

	} while (err < 0);

}
  8029bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029bf:	5b                   	pop    %ebx
  8029c0:	5e                   	pop    %esi
  8029c1:	5f                   	pop    %edi
  8029c2:	5d                   	pop    %ebp
  8029c3:	c3                   	ret    

008029c4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8029c4:	55                   	push   %ebp
  8029c5:	89 e5                	mov    %esp,%ebp
  8029c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8029ca:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8029cf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8029d2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029d8:	8b 52 50             	mov    0x50(%edx),%edx
  8029db:	39 ca                	cmp    %ecx,%edx
  8029dd:	75 0d                	jne    8029ec <ipc_find_env+0x28>
			return envs[i].env_id;
  8029df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029e7:	8b 40 48             	mov    0x48(%eax),%eax
  8029ea:	eb 0f                	jmp    8029fb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8029ec:	83 c0 01             	add    $0x1,%eax
  8029ef:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029f4:	75 d9                	jne    8029cf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8029f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029fb:	5d                   	pop    %ebp
  8029fc:	c3                   	ret    

008029fd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029fd:	55                   	push   %ebp
  8029fe:	89 e5                	mov    %esp,%ebp
  802a00:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a03:	89 d0                	mov    %edx,%eax
  802a05:	c1 e8 16             	shr    $0x16,%eax
  802a08:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802a0f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a14:	f6 c1 01             	test   $0x1,%cl
  802a17:	74 1d                	je     802a36 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a19:	c1 ea 0c             	shr    $0xc,%edx
  802a1c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a23:	f6 c2 01             	test   $0x1,%dl
  802a26:	74 0e                	je     802a36 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a28:	c1 ea 0c             	shr    $0xc,%edx
  802a2b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802a32:	ef 
  802a33:	0f b7 c0             	movzwl %ax,%eax
}
  802a36:	5d                   	pop    %ebp
  802a37:	c3                   	ret    
  802a38:	66 90                	xchg   %ax,%ax
  802a3a:	66 90                	xchg   %ax,%ax
  802a3c:	66 90                	xchg   %ax,%ax
  802a3e:	66 90                	xchg   %ax,%ax

00802a40 <__udivdi3>:
  802a40:	55                   	push   %ebp
  802a41:	57                   	push   %edi
  802a42:	56                   	push   %esi
  802a43:	53                   	push   %ebx
  802a44:	83 ec 1c             	sub    $0x1c,%esp
  802a47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802a4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802a4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802a53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a57:	85 f6                	test   %esi,%esi
  802a59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a5d:	89 ca                	mov    %ecx,%edx
  802a5f:	89 f8                	mov    %edi,%eax
  802a61:	75 3d                	jne    802aa0 <__udivdi3+0x60>
  802a63:	39 cf                	cmp    %ecx,%edi
  802a65:	0f 87 c5 00 00 00    	ja     802b30 <__udivdi3+0xf0>
  802a6b:	85 ff                	test   %edi,%edi
  802a6d:	89 fd                	mov    %edi,%ebp
  802a6f:	75 0b                	jne    802a7c <__udivdi3+0x3c>
  802a71:	b8 01 00 00 00       	mov    $0x1,%eax
  802a76:	31 d2                	xor    %edx,%edx
  802a78:	f7 f7                	div    %edi
  802a7a:	89 c5                	mov    %eax,%ebp
  802a7c:	89 c8                	mov    %ecx,%eax
  802a7e:	31 d2                	xor    %edx,%edx
  802a80:	f7 f5                	div    %ebp
  802a82:	89 c1                	mov    %eax,%ecx
  802a84:	89 d8                	mov    %ebx,%eax
  802a86:	89 cf                	mov    %ecx,%edi
  802a88:	f7 f5                	div    %ebp
  802a8a:	89 c3                	mov    %eax,%ebx
  802a8c:	89 d8                	mov    %ebx,%eax
  802a8e:	89 fa                	mov    %edi,%edx
  802a90:	83 c4 1c             	add    $0x1c,%esp
  802a93:	5b                   	pop    %ebx
  802a94:	5e                   	pop    %esi
  802a95:	5f                   	pop    %edi
  802a96:	5d                   	pop    %ebp
  802a97:	c3                   	ret    
  802a98:	90                   	nop
  802a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802aa0:	39 ce                	cmp    %ecx,%esi
  802aa2:	77 74                	ja     802b18 <__udivdi3+0xd8>
  802aa4:	0f bd fe             	bsr    %esi,%edi
  802aa7:	83 f7 1f             	xor    $0x1f,%edi
  802aaa:	0f 84 98 00 00 00    	je     802b48 <__udivdi3+0x108>
  802ab0:	bb 20 00 00 00       	mov    $0x20,%ebx
  802ab5:	89 f9                	mov    %edi,%ecx
  802ab7:	89 c5                	mov    %eax,%ebp
  802ab9:	29 fb                	sub    %edi,%ebx
  802abb:	d3 e6                	shl    %cl,%esi
  802abd:	89 d9                	mov    %ebx,%ecx
  802abf:	d3 ed                	shr    %cl,%ebp
  802ac1:	89 f9                	mov    %edi,%ecx
  802ac3:	d3 e0                	shl    %cl,%eax
  802ac5:	09 ee                	or     %ebp,%esi
  802ac7:	89 d9                	mov    %ebx,%ecx
  802ac9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802acd:	89 d5                	mov    %edx,%ebp
  802acf:	8b 44 24 08          	mov    0x8(%esp),%eax
  802ad3:	d3 ed                	shr    %cl,%ebp
  802ad5:	89 f9                	mov    %edi,%ecx
  802ad7:	d3 e2                	shl    %cl,%edx
  802ad9:	89 d9                	mov    %ebx,%ecx
  802adb:	d3 e8                	shr    %cl,%eax
  802add:	09 c2                	or     %eax,%edx
  802adf:	89 d0                	mov    %edx,%eax
  802ae1:	89 ea                	mov    %ebp,%edx
  802ae3:	f7 f6                	div    %esi
  802ae5:	89 d5                	mov    %edx,%ebp
  802ae7:	89 c3                	mov    %eax,%ebx
  802ae9:	f7 64 24 0c          	mull   0xc(%esp)
  802aed:	39 d5                	cmp    %edx,%ebp
  802aef:	72 10                	jb     802b01 <__udivdi3+0xc1>
  802af1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802af5:	89 f9                	mov    %edi,%ecx
  802af7:	d3 e6                	shl    %cl,%esi
  802af9:	39 c6                	cmp    %eax,%esi
  802afb:	73 07                	jae    802b04 <__udivdi3+0xc4>
  802afd:	39 d5                	cmp    %edx,%ebp
  802aff:	75 03                	jne    802b04 <__udivdi3+0xc4>
  802b01:	83 eb 01             	sub    $0x1,%ebx
  802b04:	31 ff                	xor    %edi,%edi
  802b06:	89 d8                	mov    %ebx,%eax
  802b08:	89 fa                	mov    %edi,%edx
  802b0a:	83 c4 1c             	add    $0x1c,%esp
  802b0d:	5b                   	pop    %ebx
  802b0e:	5e                   	pop    %esi
  802b0f:	5f                   	pop    %edi
  802b10:	5d                   	pop    %ebp
  802b11:	c3                   	ret    
  802b12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b18:	31 ff                	xor    %edi,%edi
  802b1a:	31 db                	xor    %ebx,%ebx
  802b1c:	89 d8                	mov    %ebx,%eax
  802b1e:	89 fa                	mov    %edi,%edx
  802b20:	83 c4 1c             	add    $0x1c,%esp
  802b23:	5b                   	pop    %ebx
  802b24:	5e                   	pop    %esi
  802b25:	5f                   	pop    %edi
  802b26:	5d                   	pop    %ebp
  802b27:	c3                   	ret    
  802b28:	90                   	nop
  802b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b30:	89 d8                	mov    %ebx,%eax
  802b32:	f7 f7                	div    %edi
  802b34:	31 ff                	xor    %edi,%edi
  802b36:	89 c3                	mov    %eax,%ebx
  802b38:	89 d8                	mov    %ebx,%eax
  802b3a:	89 fa                	mov    %edi,%edx
  802b3c:	83 c4 1c             	add    $0x1c,%esp
  802b3f:	5b                   	pop    %ebx
  802b40:	5e                   	pop    %esi
  802b41:	5f                   	pop    %edi
  802b42:	5d                   	pop    %ebp
  802b43:	c3                   	ret    
  802b44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b48:	39 ce                	cmp    %ecx,%esi
  802b4a:	72 0c                	jb     802b58 <__udivdi3+0x118>
  802b4c:	31 db                	xor    %ebx,%ebx
  802b4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802b52:	0f 87 34 ff ff ff    	ja     802a8c <__udivdi3+0x4c>
  802b58:	bb 01 00 00 00       	mov    $0x1,%ebx
  802b5d:	e9 2a ff ff ff       	jmp    802a8c <__udivdi3+0x4c>
  802b62:	66 90                	xchg   %ax,%ax
  802b64:	66 90                	xchg   %ax,%ax
  802b66:	66 90                	xchg   %ax,%ax
  802b68:	66 90                	xchg   %ax,%ax
  802b6a:	66 90                	xchg   %ax,%ax
  802b6c:	66 90                	xchg   %ax,%ax
  802b6e:	66 90                	xchg   %ax,%ax

00802b70 <__umoddi3>:
  802b70:	55                   	push   %ebp
  802b71:	57                   	push   %edi
  802b72:	56                   	push   %esi
  802b73:	53                   	push   %ebx
  802b74:	83 ec 1c             	sub    $0x1c,%esp
  802b77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802b7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802b7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b87:	85 d2                	test   %edx,%edx
  802b89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802b8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b91:	89 f3                	mov    %esi,%ebx
  802b93:	89 3c 24             	mov    %edi,(%esp)
  802b96:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b9a:	75 1c                	jne    802bb8 <__umoddi3+0x48>
  802b9c:	39 f7                	cmp    %esi,%edi
  802b9e:	76 50                	jbe    802bf0 <__umoddi3+0x80>
  802ba0:	89 c8                	mov    %ecx,%eax
  802ba2:	89 f2                	mov    %esi,%edx
  802ba4:	f7 f7                	div    %edi
  802ba6:	89 d0                	mov    %edx,%eax
  802ba8:	31 d2                	xor    %edx,%edx
  802baa:	83 c4 1c             	add    $0x1c,%esp
  802bad:	5b                   	pop    %ebx
  802bae:	5e                   	pop    %esi
  802baf:	5f                   	pop    %edi
  802bb0:	5d                   	pop    %ebp
  802bb1:	c3                   	ret    
  802bb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802bb8:	39 f2                	cmp    %esi,%edx
  802bba:	89 d0                	mov    %edx,%eax
  802bbc:	77 52                	ja     802c10 <__umoddi3+0xa0>
  802bbe:	0f bd ea             	bsr    %edx,%ebp
  802bc1:	83 f5 1f             	xor    $0x1f,%ebp
  802bc4:	75 5a                	jne    802c20 <__umoddi3+0xb0>
  802bc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802bca:	0f 82 e0 00 00 00    	jb     802cb0 <__umoddi3+0x140>
  802bd0:	39 0c 24             	cmp    %ecx,(%esp)
  802bd3:	0f 86 d7 00 00 00    	jbe    802cb0 <__umoddi3+0x140>
  802bd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  802bdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802be1:	83 c4 1c             	add    $0x1c,%esp
  802be4:	5b                   	pop    %ebx
  802be5:	5e                   	pop    %esi
  802be6:	5f                   	pop    %edi
  802be7:	5d                   	pop    %ebp
  802be8:	c3                   	ret    
  802be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bf0:	85 ff                	test   %edi,%edi
  802bf2:	89 fd                	mov    %edi,%ebp
  802bf4:	75 0b                	jne    802c01 <__umoddi3+0x91>
  802bf6:	b8 01 00 00 00       	mov    $0x1,%eax
  802bfb:	31 d2                	xor    %edx,%edx
  802bfd:	f7 f7                	div    %edi
  802bff:	89 c5                	mov    %eax,%ebp
  802c01:	89 f0                	mov    %esi,%eax
  802c03:	31 d2                	xor    %edx,%edx
  802c05:	f7 f5                	div    %ebp
  802c07:	89 c8                	mov    %ecx,%eax
  802c09:	f7 f5                	div    %ebp
  802c0b:	89 d0                	mov    %edx,%eax
  802c0d:	eb 99                	jmp    802ba8 <__umoddi3+0x38>
  802c0f:	90                   	nop
  802c10:	89 c8                	mov    %ecx,%eax
  802c12:	89 f2                	mov    %esi,%edx
  802c14:	83 c4 1c             	add    $0x1c,%esp
  802c17:	5b                   	pop    %ebx
  802c18:	5e                   	pop    %esi
  802c19:	5f                   	pop    %edi
  802c1a:	5d                   	pop    %ebp
  802c1b:	c3                   	ret    
  802c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c20:	8b 34 24             	mov    (%esp),%esi
  802c23:	bf 20 00 00 00       	mov    $0x20,%edi
  802c28:	89 e9                	mov    %ebp,%ecx
  802c2a:	29 ef                	sub    %ebp,%edi
  802c2c:	d3 e0                	shl    %cl,%eax
  802c2e:	89 f9                	mov    %edi,%ecx
  802c30:	89 f2                	mov    %esi,%edx
  802c32:	d3 ea                	shr    %cl,%edx
  802c34:	89 e9                	mov    %ebp,%ecx
  802c36:	09 c2                	or     %eax,%edx
  802c38:	89 d8                	mov    %ebx,%eax
  802c3a:	89 14 24             	mov    %edx,(%esp)
  802c3d:	89 f2                	mov    %esi,%edx
  802c3f:	d3 e2                	shl    %cl,%edx
  802c41:	89 f9                	mov    %edi,%ecx
  802c43:	89 54 24 04          	mov    %edx,0x4(%esp)
  802c47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c4b:	d3 e8                	shr    %cl,%eax
  802c4d:	89 e9                	mov    %ebp,%ecx
  802c4f:	89 c6                	mov    %eax,%esi
  802c51:	d3 e3                	shl    %cl,%ebx
  802c53:	89 f9                	mov    %edi,%ecx
  802c55:	89 d0                	mov    %edx,%eax
  802c57:	d3 e8                	shr    %cl,%eax
  802c59:	89 e9                	mov    %ebp,%ecx
  802c5b:	09 d8                	or     %ebx,%eax
  802c5d:	89 d3                	mov    %edx,%ebx
  802c5f:	89 f2                	mov    %esi,%edx
  802c61:	f7 34 24             	divl   (%esp)
  802c64:	89 d6                	mov    %edx,%esi
  802c66:	d3 e3                	shl    %cl,%ebx
  802c68:	f7 64 24 04          	mull   0x4(%esp)
  802c6c:	39 d6                	cmp    %edx,%esi
  802c6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c72:	89 d1                	mov    %edx,%ecx
  802c74:	89 c3                	mov    %eax,%ebx
  802c76:	72 08                	jb     802c80 <__umoddi3+0x110>
  802c78:	75 11                	jne    802c8b <__umoddi3+0x11b>
  802c7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802c7e:	73 0b                	jae    802c8b <__umoddi3+0x11b>
  802c80:	2b 44 24 04          	sub    0x4(%esp),%eax
  802c84:	1b 14 24             	sbb    (%esp),%edx
  802c87:	89 d1                	mov    %edx,%ecx
  802c89:	89 c3                	mov    %eax,%ebx
  802c8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802c8f:	29 da                	sub    %ebx,%edx
  802c91:	19 ce                	sbb    %ecx,%esi
  802c93:	89 f9                	mov    %edi,%ecx
  802c95:	89 f0                	mov    %esi,%eax
  802c97:	d3 e0                	shl    %cl,%eax
  802c99:	89 e9                	mov    %ebp,%ecx
  802c9b:	d3 ea                	shr    %cl,%edx
  802c9d:	89 e9                	mov    %ebp,%ecx
  802c9f:	d3 ee                	shr    %cl,%esi
  802ca1:	09 d0                	or     %edx,%eax
  802ca3:	89 f2                	mov    %esi,%edx
  802ca5:	83 c4 1c             	add    $0x1c,%esp
  802ca8:	5b                   	pop    %ebx
  802ca9:	5e                   	pop    %esi
  802caa:	5f                   	pop    %edi
  802cab:	5d                   	pop    %ebp
  802cac:	c3                   	ret    
  802cad:	8d 76 00             	lea    0x0(%esi),%esi
  802cb0:	29 f9                	sub    %edi,%ecx
  802cb2:	19 d6                	sbb    %edx,%esi
  802cb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cbc:	e9 18 ff ff ff       	jmp    802bd9 <__umoddi3+0x69>
