
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
  800081:	68 0c 27 80 00       	push   $0x80270c
  800086:	6a 13                	push   $0x13
  800088:	68 1f 27 80 00       	push   $0x80271f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 6c 0e 00 00       	call   800f03 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 33 27 80 00       	push   $0x802733
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 1f 27 80 00       	push   $0x80271f
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
  8000d2:	e8 28 20 00 00       	call   8020ff <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 06 27 80 00       	mov    $0x802706,%edx
  8000f4:	b8 00 27 80 00       	mov    $0x802700,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 3c 27 80 00       	push   $0x80273c
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 57 27 80 00       	push   $0x802757
  80010e:	68 5c 27 80 00       	push   $0x80275c
  800113:	68 5b 27 80 00       	push   $0x80275b
  800118:	e8 13 1c 00 00       	call   801d30 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 69 27 80 00       	push   $0x802769
  80012a:	6a 21                	push   $0x21
  80012c:	68 1f 27 80 00       	push   $0x80271f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 c0 1f 00 00       	call   8020ff <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 06 27 80 00       	mov    $0x802706,%edx
  80015c:	b8 00 27 80 00       	mov    $0x802700,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 73 27 80 00       	push   $0x802773
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
  8001c4:	e8 86 10 00 00       	call   80124f <close_all>
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
  8001f6:	68 b8 27 80 00       	push   $0x8027b8
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 58 2d 80 00 	movl   $0x802d58,(%esp)
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
  800314:	e8 57 21 00 00       	call   802470 <__udivdi3>
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
  800357:	e8 44 22 00 00       	call   8025a0 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 db 27 80 00 	movsbl 0x8027db(%eax),%eax
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
  80045b:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
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
  80051f:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 f3 27 80 00       	push   $0x8027f3
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
  800543:	68 92 2c 80 00       	push   $0x802c92
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
  800567:	b8 ec 27 80 00       	mov    $0x8027ec,%eax
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
  800be2:	68 df 2a 80 00       	push   $0x802adf
  800be7:	6a 23                	push   $0x23
  800be9:	68 fc 2a 80 00       	push   $0x802afc
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
  800c63:	68 df 2a 80 00       	push   $0x802adf
  800c68:	6a 23                	push   $0x23
  800c6a:	68 fc 2a 80 00       	push   $0x802afc
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
  800ca5:	68 df 2a 80 00       	push   $0x802adf
  800caa:	6a 23                	push   $0x23
  800cac:	68 fc 2a 80 00       	push   $0x802afc
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
  800ce7:	68 df 2a 80 00       	push   $0x802adf
  800cec:	6a 23                	push   $0x23
  800cee:	68 fc 2a 80 00       	push   $0x802afc
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
  800d29:	68 df 2a 80 00       	push   $0x802adf
  800d2e:	6a 23                	push   $0x23
  800d30:	68 fc 2a 80 00       	push   $0x802afc
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
  800d6b:	68 df 2a 80 00       	push   $0x802adf
  800d70:	6a 23                	push   $0x23
  800d72:	68 fc 2a 80 00       	push   $0x802afc
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
  800dad:	68 df 2a 80 00       	push   $0x802adf
  800db2:	6a 23                	push   $0x23
  800db4:	68 fc 2a 80 00       	push   $0x802afc
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
  800e11:	68 df 2a 80 00       	push   $0x802adf
  800e16:	6a 23                	push   $0x23
  800e18:	68 fc 2a 80 00       	push   $0x802afc
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
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e32:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e34:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e38:	75 25                	jne    800e5f <pgfault+0x35>
  800e3a:	89 d8                	mov    %ebx,%eax
  800e3c:	c1 e8 0c             	shr    $0xc,%eax
  800e3f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e46:	f6 c4 08             	test   $0x8,%ah
  800e49:	75 14                	jne    800e5f <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e4b:	83 ec 04             	sub    $0x4,%esp
  800e4e:	68 0c 2b 80 00       	push   $0x802b0c
  800e53:	6a 1e                	push   $0x1e
  800e55:	68 a0 2b 80 00       	push   $0x802ba0
  800e5a:	e8 79 f3 ff ff       	call   8001d8 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e5f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e65:	e8 91 fd ff ff       	call   800bfb <sys_getenvid>
  800e6a:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	6a 07                	push   $0x7
  800e71:	68 00 f0 7f 00       	push   $0x7ff000
  800e76:	50                   	push   %eax
  800e77:	e8 bd fd ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	79 12                	jns    800e95 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e83:	50                   	push   %eax
  800e84:	68 38 2b 80 00       	push   $0x802b38
  800e89:	6a 31                	push   $0x31
  800e8b:	68 a0 2b 80 00       	push   $0x802ba0
  800e90:	e8 43 f3 ff ff       	call   8001d8 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	68 00 10 00 00       	push   $0x1000
  800e9d:	53                   	push   %ebx
  800e9e:	68 00 f0 7f 00       	push   $0x7ff000
  800ea3:	e8 88 fb ff ff       	call   800a30 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800ea8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eaf:	53                   	push   %ebx
  800eb0:	56                   	push   %esi
  800eb1:	68 00 f0 7f 00       	push   $0x7ff000
  800eb6:	56                   	push   %esi
  800eb7:	e8 c0 fd ff ff       	call   800c7c <sys_page_map>
	if (r < 0)
  800ebc:	83 c4 20             	add    $0x20,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	79 12                	jns    800ed5 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800ec3:	50                   	push   %eax
  800ec4:	68 5c 2b 80 00       	push   $0x802b5c
  800ec9:	6a 39                	push   $0x39
  800ecb:	68 a0 2b 80 00       	push   $0x802ba0
  800ed0:	e8 03 f3 ff ff       	call   8001d8 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800ed5:	83 ec 08             	sub    $0x8,%esp
  800ed8:	68 00 f0 7f 00       	push   $0x7ff000
  800edd:	56                   	push   %esi
  800ede:	e8 db fd ff ff       	call   800cbe <sys_page_unmap>
	if (r < 0)
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	79 12                	jns    800efc <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800eea:	50                   	push   %eax
  800eeb:	68 80 2b 80 00       	push   $0x802b80
  800ef0:	6a 3e                	push   $0x3e
  800ef2:	68 a0 2b 80 00       	push   $0x802ba0
  800ef7:	e8 dc f2 ff ff       	call   8001d8 <_panic>
}
  800efc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eff:	5b                   	pop    %ebx
  800f00:	5e                   	pop    %esi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f0c:	68 2a 0e 80 00       	push   $0x800e2a
  800f11:	e8 bb 13 00 00       	call   8022d1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f16:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1b:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	0f 88 3a 01 00 00    	js     801062 <fork+0x15f>
  800f28:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f2d:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f32:	85 c0                	test   %eax,%eax
  800f34:	75 21                	jne    800f57 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f36:	e8 c0 fc ff ff       	call   800bfb <sys_getenvid>
  800f3b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f48:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f52:	e9 0b 01 00 00       	jmp    801062 <fork+0x15f>
  800f57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f5a:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f5c:	89 d8                	mov    %ebx,%eax
  800f5e:	c1 e8 16             	shr    $0x16,%eax
  800f61:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f68:	a8 01                	test   $0x1,%al
  800f6a:	0f 84 99 00 00 00    	je     801009 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f70:	89 d8                	mov    %ebx,%eax
  800f72:	c1 e8 0c             	shr    $0xc,%eax
  800f75:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f7c:	f6 c2 01             	test   $0x1,%dl
  800f7f:	0f 84 84 00 00 00    	je     801009 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800f85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8c:	a9 02 08 00 00       	test   $0x802,%eax
  800f91:	74 76                	je     801009 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f93:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f9a:	a8 02                	test   $0x2,%al
  800f9c:	75 0c                	jne    800faa <fork+0xa7>
  800f9e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa5:	f6 c4 08             	test   $0x8,%ah
  800fa8:	74 3f                	je     800fe9 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	68 05 08 00 00       	push   $0x805
  800fb2:	53                   	push   %ebx
  800fb3:	57                   	push   %edi
  800fb4:	53                   	push   %ebx
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 c0 fc ff ff       	call   800c7c <sys_page_map>
		if (r < 0)
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	0f 88 9b 00 00 00    	js     801062 <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	68 05 08 00 00       	push   $0x805
  800fcf:	53                   	push   %ebx
  800fd0:	6a 00                	push   $0x0
  800fd2:	53                   	push   %ebx
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 a2 fc ff ff       	call   800c7c <sys_page_map>
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe4:	0f 4f c1             	cmovg  %ecx,%eax
  800fe7:	eb 1c                	jmp    801005 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800fe9:	83 ec 0c             	sub    $0xc,%esp
  800fec:	6a 05                	push   $0x5
  800fee:	53                   	push   %ebx
  800fef:	57                   	push   %edi
  800ff0:	53                   	push   %ebx
  800ff1:	6a 00                	push   $0x0
  800ff3:	e8 84 fc ff ff       	call   800c7c <sys_page_map>
  800ff8:	83 c4 20             	add    $0x20,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801002:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	78 59                	js     801062 <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801009:	83 c6 01             	add    $0x1,%esi
  80100c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801012:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801018:	0f 85 3e ff ff ff    	jne    800f5c <fork+0x59>
  80101e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801021:	83 ec 04             	sub    $0x4,%esp
  801024:	6a 07                	push   $0x7
  801026:	68 00 f0 bf ee       	push   $0xeebff000
  80102b:	57                   	push   %edi
  80102c:	e8 08 fc ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	78 2a                	js     801062 <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801038:	83 ec 08             	sub    $0x8,%esp
  80103b:	68 18 23 80 00       	push   $0x802318
  801040:	57                   	push   %edi
  801041:	e8 3e fd ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	78 15                	js     801062 <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80104d:	83 ec 08             	sub    $0x8,%esp
  801050:	6a 02                	push   $0x2
  801052:	57                   	push   %edi
  801053:	e8 a8 fc ff ff       	call   800d00 <sys_env_set_status>
	if (r < 0)
  801058:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  80105b:	85 c0                	test   %eax,%eax
  80105d:	0f 49 c7             	cmovns %edi,%eax
  801060:	eb 00                	jmp    801062 <fork+0x15f>
	// panic("fork not implemented");
}
  801062:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <sfork>:

// Challenge!
int
sfork(void)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801070:	68 ab 2b 80 00       	push   $0x802bab
  801075:	68 c3 00 00 00       	push   $0xc3
  80107a:	68 a0 2b 80 00       	push   $0x802ba0
  80107f:	e8 54 f1 ff ff       	call   8001d8 <_panic>

00801084 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	05 00 00 00 30       	add    $0x30000000,%eax
  80108f:	c1 e8 0c             	shr    $0xc,%eax
}
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801097:	8b 45 08             	mov    0x8(%ebp),%eax
  80109a:	05 00 00 00 30       	add    $0x30000000,%eax
  80109f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010a4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010b6:	89 c2                	mov    %eax,%edx
  8010b8:	c1 ea 16             	shr    $0x16,%edx
  8010bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c2:	f6 c2 01             	test   $0x1,%dl
  8010c5:	74 11                	je     8010d8 <fd_alloc+0x2d>
  8010c7:	89 c2                	mov    %eax,%edx
  8010c9:	c1 ea 0c             	shr    $0xc,%edx
  8010cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d3:	f6 c2 01             	test   $0x1,%dl
  8010d6:	75 09                	jne    8010e1 <fd_alloc+0x36>
			*fd_store = fd;
  8010d8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
  8010df:	eb 17                	jmp    8010f8 <fd_alloc+0x4d>
  8010e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010eb:	75 c9                	jne    8010b6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010ed:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801100:	83 f8 1f             	cmp    $0x1f,%eax
  801103:	77 36                	ja     80113b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801105:	c1 e0 0c             	shl    $0xc,%eax
  801108:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80110d:	89 c2                	mov    %eax,%edx
  80110f:	c1 ea 16             	shr    $0x16,%edx
  801112:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801119:	f6 c2 01             	test   $0x1,%dl
  80111c:	74 24                	je     801142 <fd_lookup+0x48>
  80111e:	89 c2                	mov    %eax,%edx
  801120:	c1 ea 0c             	shr    $0xc,%edx
  801123:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80112a:	f6 c2 01             	test   $0x1,%dl
  80112d:	74 1a                	je     801149 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80112f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801132:	89 02                	mov    %eax,(%edx)
	return 0;
  801134:	b8 00 00 00 00       	mov    $0x0,%eax
  801139:	eb 13                	jmp    80114e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80113b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801140:	eb 0c                	jmp    80114e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801142:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801147:	eb 05                	jmp    80114e <fd_lookup+0x54>
  801149:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801159:	ba 40 2c 80 00       	mov    $0x802c40,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80115e:	eb 13                	jmp    801173 <dev_lookup+0x23>
  801160:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801163:	39 08                	cmp    %ecx,(%eax)
  801165:	75 0c                	jne    801173 <dev_lookup+0x23>
			*dev = devtab[i];
  801167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80116c:	b8 00 00 00 00       	mov    $0x0,%eax
  801171:	eb 2e                	jmp    8011a1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801173:	8b 02                	mov    (%edx),%eax
  801175:	85 c0                	test   %eax,%eax
  801177:	75 e7                	jne    801160 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801179:	a1 04 40 80 00       	mov    0x804004,%eax
  80117e:	8b 40 48             	mov    0x48(%eax),%eax
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	51                   	push   %ecx
  801185:	50                   	push   %eax
  801186:	68 c4 2b 80 00       	push   $0x802bc4
  80118b:	e8 21 f1 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  801190:	8b 45 0c             	mov    0xc(%ebp),%eax
  801193:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	56                   	push   %esi
  8011a7:	53                   	push   %ebx
  8011a8:	83 ec 10             	sub    $0x10,%esp
  8011ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011bb:	c1 e8 0c             	shr    $0xc,%eax
  8011be:	50                   	push   %eax
  8011bf:	e8 36 ff ff ff       	call   8010fa <fd_lookup>
  8011c4:	83 c4 08             	add    $0x8,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 05                	js     8011d0 <fd_close+0x2d>
	    || fd != fd2)
  8011cb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ce:	74 0c                	je     8011dc <fd_close+0x39>
		return (must_exist ? r : 0);
  8011d0:	84 db                	test   %bl,%bl
  8011d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d7:	0f 44 c2             	cmove  %edx,%eax
  8011da:	eb 41                	jmp    80121d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011dc:	83 ec 08             	sub    $0x8,%esp
  8011df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	ff 36                	pushl  (%esi)
  8011e5:	e8 66 ff ff ff       	call   801150 <dev_lookup>
  8011ea:	89 c3                	mov    %eax,%ebx
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	78 1a                	js     80120d <fd_close+0x6a>
		if (dev->dev_close)
  8011f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011f9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011fe:	85 c0                	test   %eax,%eax
  801200:	74 0b                	je     80120d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801202:	83 ec 0c             	sub    $0xc,%esp
  801205:	56                   	push   %esi
  801206:	ff d0                	call   *%eax
  801208:	89 c3                	mov    %eax,%ebx
  80120a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	56                   	push   %esi
  801211:	6a 00                	push   $0x0
  801213:	e8 a6 fa ff ff       	call   800cbe <sys_page_unmap>
	return r;
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	89 d8                	mov    %ebx,%eax
}
  80121d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	ff 75 08             	pushl  0x8(%ebp)
  801231:	e8 c4 fe ff ff       	call   8010fa <fd_lookup>
  801236:	83 c4 08             	add    $0x8,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 10                	js     80124d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	6a 01                	push   $0x1
  801242:	ff 75 f4             	pushl  -0xc(%ebp)
  801245:	e8 59 ff ff ff       	call   8011a3 <fd_close>
  80124a:	83 c4 10             	add    $0x10,%esp
}
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <close_all>:

void
close_all(void)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	53                   	push   %ebx
  801253:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801256:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80125b:	83 ec 0c             	sub    $0xc,%esp
  80125e:	53                   	push   %ebx
  80125f:	e8 c0 ff ff ff       	call   801224 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801264:	83 c3 01             	add    $0x1,%ebx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	83 fb 20             	cmp    $0x20,%ebx
  80126d:	75 ec                	jne    80125b <close_all+0xc>
		close(i);
}
  80126f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	57                   	push   %edi
  801278:	56                   	push   %esi
  801279:	53                   	push   %ebx
  80127a:	83 ec 2c             	sub    $0x2c,%esp
  80127d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801280:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801283:	50                   	push   %eax
  801284:	ff 75 08             	pushl  0x8(%ebp)
  801287:	e8 6e fe ff ff       	call   8010fa <fd_lookup>
  80128c:	83 c4 08             	add    $0x8,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	0f 88 c1 00 00 00    	js     801358 <dup+0xe4>
		return r;
	close(newfdnum);
  801297:	83 ec 0c             	sub    $0xc,%esp
  80129a:	56                   	push   %esi
  80129b:	e8 84 ff ff ff       	call   801224 <close>

	newfd = INDEX2FD(newfdnum);
  8012a0:	89 f3                	mov    %esi,%ebx
  8012a2:	c1 e3 0c             	shl    $0xc,%ebx
  8012a5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012ab:	83 c4 04             	add    $0x4,%esp
  8012ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b1:	e8 de fd ff ff       	call   801094 <fd2data>
  8012b6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012b8:	89 1c 24             	mov    %ebx,(%esp)
  8012bb:	e8 d4 fd ff ff       	call   801094 <fd2data>
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012c6:	89 f8                	mov    %edi,%eax
  8012c8:	c1 e8 16             	shr    $0x16,%eax
  8012cb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d2:	a8 01                	test   $0x1,%al
  8012d4:	74 37                	je     80130d <dup+0x99>
  8012d6:	89 f8                	mov    %edi,%eax
  8012d8:	c1 e8 0c             	shr    $0xc,%eax
  8012db:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e2:	f6 c2 01             	test   $0x1,%dl
  8012e5:	74 26                	je     80130d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ee:	83 ec 0c             	sub    $0xc,%esp
  8012f1:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f6:	50                   	push   %eax
  8012f7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012fa:	6a 00                	push   $0x0
  8012fc:	57                   	push   %edi
  8012fd:	6a 00                	push   $0x0
  8012ff:	e8 78 f9 ff ff       	call   800c7c <sys_page_map>
  801304:	89 c7                	mov    %eax,%edi
  801306:	83 c4 20             	add    $0x20,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 2e                	js     80133b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801310:	89 d0                	mov    %edx,%eax
  801312:	c1 e8 0c             	shr    $0xc,%eax
  801315:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131c:	83 ec 0c             	sub    $0xc,%esp
  80131f:	25 07 0e 00 00       	and    $0xe07,%eax
  801324:	50                   	push   %eax
  801325:	53                   	push   %ebx
  801326:	6a 00                	push   $0x0
  801328:	52                   	push   %edx
  801329:	6a 00                	push   $0x0
  80132b:	e8 4c f9 ff ff       	call   800c7c <sys_page_map>
  801330:	89 c7                	mov    %eax,%edi
  801332:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801335:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801337:	85 ff                	test   %edi,%edi
  801339:	79 1d                	jns    801358 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	53                   	push   %ebx
  80133f:	6a 00                	push   $0x0
  801341:	e8 78 f9 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801346:	83 c4 08             	add    $0x8,%esp
  801349:	ff 75 d4             	pushl  -0x2c(%ebp)
  80134c:	6a 00                	push   $0x0
  80134e:	e8 6b f9 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	89 f8                	mov    %edi,%eax
}
  801358:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80135b:	5b                   	pop    %ebx
  80135c:	5e                   	pop    %esi
  80135d:	5f                   	pop    %edi
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	53                   	push   %ebx
  801364:	83 ec 14             	sub    $0x14,%esp
  801367:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136d:	50                   	push   %eax
  80136e:	53                   	push   %ebx
  80136f:	e8 86 fd ff ff       	call   8010fa <fd_lookup>
  801374:	83 c4 08             	add    $0x8,%esp
  801377:	89 c2                	mov    %eax,%edx
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 6d                	js     8013ea <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801387:	ff 30                	pushl  (%eax)
  801389:	e8 c2 fd ff ff       	call   801150 <dev_lookup>
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	85 c0                	test   %eax,%eax
  801393:	78 4c                	js     8013e1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801395:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801398:	8b 42 08             	mov    0x8(%edx),%eax
  80139b:	83 e0 03             	and    $0x3,%eax
  80139e:	83 f8 01             	cmp    $0x1,%eax
  8013a1:	75 21                	jne    8013c4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a8:	8b 40 48             	mov    0x48(%eax),%eax
  8013ab:	83 ec 04             	sub    $0x4,%esp
  8013ae:	53                   	push   %ebx
  8013af:	50                   	push   %eax
  8013b0:	68 05 2c 80 00       	push   $0x802c05
  8013b5:	e8 f7 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013c2:	eb 26                	jmp    8013ea <read+0x8a>
	}
	if (!dev->dev_read)
  8013c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c7:	8b 40 08             	mov    0x8(%eax),%eax
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	74 17                	je     8013e5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	ff 75 10             	pushl  0x10(%ebp)
  8013d4:	ff 75 0c             	pushl  0xc(%ebp)
  8013d7:	52                   	push   %edx
  8013d8:	ff d0                	call   *%eax
  8013da:	89 c2                	mov    %eax,%edx
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	eb 09                	jmp    8013ea <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	eb 05                	jmp    8013ea <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013ea:	89 d0                	mov    %edx,%eax
  8013ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	57                   	push   %edi
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801400:	bb 00 00 00 00       	mov    $0x0,%ebx
  801405:	eb 21                	jmp    801428 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801407:	83 ec 04             	sub    $0x4,%esp
  80140a:	89 f0                	mov    %esi,%eax
  80140c:	29 d8                	sub    %ebx,%eax
  80140e:	50                   	push   %eax
  80140f:	89 d8                	mov    %ebx,%eax
  801411:	03 45 0c             	add    0xc(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	57                   	push   %edi
  801416:	e8 45 ff ff ff       	call   801360 <read>
		if (m < 0)
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 10                	js     801432 <readn+0x41>
			return m;
		if (m == 0)
  801422:	85 c0                	test   %eax,%eax
  801424:	74 0a                	je     801430 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801426:	01 c3                	add    %eax,%ebx
  801428:	39 f3                	cmp    %esi,%ebx
  80142a:	72 db                	jb     801407 <readn+0x16>
  80142c:	89 d8                	mov    %ebx,%eax
  80142e:	eb 02                	jmp    801432 <readn+0x41>
  801430:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801432:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801435:	5b                   	pop    %ebx
  801436:	5e                   	pop    %esi
  801437:	5f                   	pop    %edi
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	53                   	push   %ebx
  80143e:	83 ec 14             	sub    $0x14,%esp
  801441:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801444:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801447:	50                   	push   %eax
  801448:	53                   	push   %ebx
  801449:	e8 ac fc ff ff       	call   8010fa <fd_lookup>
  80144e:	83 c4 08             	add    $0x8,%esp
  801451:	89 c2                	mov    %eax,%edx
  801453:	85 c0                	test   %eax,%eax
  801455:	78 68                	js     8014bf <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801461:	ff 30                	pushl  (%eax)
  801463:	e8 e8 fc ff ff       	call   801150 <dev_lookup>
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 47                	js     8014b6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801472:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801476:	75 21                	jne    801499 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801478:	a1 04 40 80 00       	mov    0x804004,%eax
  80147d:	8b 40 48             	mov    0x48(%eax),%eax
  801480:	83 ec 04             	sub    $0x4,%esp
  801483:	53                   	push   %ebx
  801484:	50                   	push   %eax
  801485:	68 21 2c 80 00       	push   $0x802c21
  80148a:	e8 22 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801497:	eb 26                	jmp    8014bf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801499:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80149c:	8b 52 0c             	mov    0xc(%edx),%edx
  80149f:	85 d2                	test   %edx,%edx
  8014a1:	74 17                	je     8014ba <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	ff 75 10             	pushl  0x10(%ebp)
  8014a9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ac:	50                   	push   %eax
  8014ad:	ff d2                	call   *%edx
  8014af:	89 c2                	mov    %eax,%edx
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	eb 09                	jmp    8014bf <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b6:	89 c2                	mov    %eax,%edx
  8014b8:	eb 05                	jmp    8014bf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014bf:	89 d0                	mov    %edx,%eax
  8014c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014cc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014cf:	50                   	push   %eax
  8014d0:	ff 75 08             	pushl  0x8(%ebp)
  8014d3:	e8 22 fc ff ff       	call   8010fa <fd_lookup>
  8014d8:	83 c4 08             	add    $0x8,%esp
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 0e                	js     8014ed <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ed:	c9                   	leave  
  8014ee:	c3                   	ret    

008014ef <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
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
  8014fe:	e8 f7 fb ff ff       	call   8010fa <fd_lookup>
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	89 c2                	mov    %eax,%edx
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 65                	js     801571 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801516:	ff 30                	pushl  (%eax)
  801518:	e8 33 fc ff ff       	call   801150 <dev_lookup>
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 44                	js     801568 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801524:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801527:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152b:	75 21                	jne    80154e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80152d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801532:	8b 40 48             	mov    0x48(%eax),%eax
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	53                   	push   %ebx
  801539:	50                   	push   %eax
  80153a:	68 e4 2b 80 00       	push   $0x802be4
  80153f:	e8 6d ed ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154c:	eb 23                	jmp    801571 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80154e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801551:	8b 52 18             	mov    0x18(%edx),%edx
  801554:	85 d2                	test   %edx,%edx
  801556:	74 14                	je     80156c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	ff 75 0c             	pushl  0xc(%ebp)
  80155e:	50                   	push   %eax
  80155f:	ff d2                	call   *%edx
  801561:	89 c2                	mov    %eax,%edx
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	eb 09                	jmp    801571 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801568:	89 c2                	mov    %eax,%edx
  80156a:	eb 05                	jmp    801571 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80156c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801571:	89 d0                	mov    %edx,%eax
  801573:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 14             	sub    $0x14,%esp
  80157f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801582:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	ff 75 08             	pushl  0x8(%ebp)
  801589:	e8 6c fb ff ff       	call   8010fa <fd_lookup>
  80158e:	83 c4 08             	add    $0x8,%esp
  801591:	89 c2                	mov    %eax,%edx
  801593:	85 c0                	test   %eax,%eax
  801595:	78 58                	js     8015ef <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a1:	ff 30                	pushl  (%eax)
  8015a3:	e8 a8 fb ff ff       	call   801150 <dev_lookup>
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 37                	js     8015e6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015b6:	74 32                	je     8015ea <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015b8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015bb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015c2:	00 00 00 
	stat->st_isdir = 0;
  8015c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015cc:	00 00 00 
	stat->st_dev = dev;
  8015cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	53                   	push   %ebx
  8015d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8015dc:	ff 50 14             	call   *0x14(%eax)
  8015df:	89 c2                	mov    %eax,%edx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	eb 09                	jmp    8015ef <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	eb 05                	jmp    8015ef <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015ef:	89 d0                	mov    %edx,%eax
  8015f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f4:	c9                   	leave  
  8015f5:	c3                   	ret    

008015f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	56                   	push   %esi
  8015fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	6a 00                	push   $0x0
  801600:	ff 75 08             	pushl  0x8(%ebp)
  801603:	e8 b7 01 00 00       	call   8017bf <open>
  801608:	89 c3                	mov    %eax,%ebx
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 1b                	js     80162c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	ff 75 0c             	pushl  0xc(%ebp)
  801617:	50                   	push   %eax
  801618:	e8 5b ff ff ff       	call   801578 <fstat>
  80161d:	89 c6                	mov    %eax,%esi
	close(fd);
  80161f:	89 1c 24             	mov    %ebx,(%esp)
  801622:	e8 fd fb ff ff       	call   801224 <close>
	return r;
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	89 f0                	mov    %esi,%eax
}
  80162c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162f:	5b                   	pop    %ebx
  801630:	5e                   	pop    %esi
  801631:	5d                   	pop    %ebp
  801632:	c3                   	ret    

00801633 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	56                   	push   %esi
  801637:	53                   	push   %ebx
  801638:	89 c6                	mov    %eax,%esi
  80163a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80163c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801643:	75 12                	jne    801657 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801645:	83 ec 0c             	sub    $0xc,%esp
  801648:	6a 01                	push   $0x1
  80164a:	e8 a8 0d 00 00       	call   8023f7 <ipc_find_env>
  80164f:	a3 00 40 80 00       	mov    %eax,0x804000
  801654:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801657:	6a 07                	push   $0x7
  801659:	68 00 50 80 00       	push   $0x805000
  80165e:	56                   	push   %esi
  80165f:	ff 35 00 40 80 00    	pushl  0x804000
  801665:	e8 39 0d 00 00       	call   8023a3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80166a:	83 c4 0c             	add    $0xc,%esp
  80166d:	6a 00                	push   $0x0
  80166f:	53                   	push   %ebx
  801670:	6a 00                	push   $0x0
  801672:	e8 c5 0c 00 00       	call   80233c <ipc_recv>
}
  801677:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167a:	5b                   	pop    %ebx
  80167b:	5e                   	pop    %esi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801684:	8b 45 08             	mov    0x8(%ebp),%eax
  801687:	8b 40 0c             	mov    0xc(%eax),%eax
  80168a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80168f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801692:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801697:	ba 00 00 00 00       	mov    $0x0,%edx
  80169c:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a1:	e8 8d ff ff ff       	call   801633 <fsipc>
}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016be:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c3:	e8 6b ff ff ff       	call   801633 <fsipc>
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 04             	sub    $0x4,%esp
  8016d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016da:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016df:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e9:	e8 45 ff ff ff       	call   801633 <fsipc>
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 2c                	js     80171e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	68 00 50 80 00       	push   $0x805000
  8016fa:	53                   	push   %ebx
  8016fb:	e8 36 f1 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801700:	a1 80 50 80 00       	mov    0x805080,%eax
  801705:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80170b:	a1 84 50 80 00       	mov    0x805084,%eax
  801710:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80171e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801729:	68 50 2c 80 00       	push   $0x802c50
  80172e:	68 90 00 00 00       	push   $0x90
  801733:	68 6e 2c 80 00       	push   $0x802c6e
  801738:	e8 9b ea ff ff       	call   8001d8 <_panic>

0080173d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801745:	8b 45 08             	mov    0x8(%ebp),%eax
  801748:	8b 40 0c             	mov    0xc(%eax),%eax
  80174b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801750:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801756:	ba 00 00 00 00       	mov    $0x0,%edx
  80175b:	b8 03 00 00 00       	mov    $0x3,%eax
  801760:	e8 ce fe ff ff       	call   801633 <fsipc>
  801765:	89 c3                	mov    %eax,%ebx
  801767:	85 c0                	test   %eax,%eax
  801769:	78 4b                	js     8017b6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80176b:	39 c6                	cmp    %eax,%esi
  80176d:	73 16                	jae    801785 <devfile_read+0x48>
  80176f:	68 79 2c 80 00       	push   $0x802c79
  801774:	68 80 2c 80 00       	push   $0x802c80
  801779:	6a 7c                	push   $0x7c
  80177b:	68 6e 2c 80 00       	push   $0x802c6e
  801780:	e8 53 ea ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  801785:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80178a:	7e 16                	jle    8017a2 <devfile_read+0x65>
  80178c:	68 95 2c 80 00       	push   $0x802c95
  801791:	68 80 2c 80 00       	push   $0x802c80
  801796:	6a 7d                	push   $0x7d
  801798:	68 6e 2c 80 00       	push   $0x802c6e
  80179d:	e8 36 ea ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017a2:	83 ec 04             	sub    $0x4,%esp
  8017a5:	50                   	push   %eax
  8017a6:	68 00 50 80 00       	push   $0x805000
  8017ab:	ff 75 0c             	pushl  0xc(%ebp)
  8017ae:	e8 15 f2 ff ff       	call   8009c8 <memmove>
	return r;
  8017b3:	83 c4 10             	add    $0x10,%esp
}
  8017b6:	89 d8                	mov    %ebx,%eax
  8017b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bb:	5b                   	pop    %ebx
  8017bc:	5e                   	pop    %esi
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	53                   	push   %ebx
  8017c3:	83 ec 20             	sub    $0x20,%esp
  8017c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017c9:	53                   	push   %ebx
  8017ca:	e8 2e f0 ff ff       	call   8007fd <strlen>
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017d7:	7f 67                	jg     801840 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017df:	50                   	push   %eax
  8017e0:	e8 c6 f8 ff ff       	call   8010ab <fd_alloc>
  8017e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8017e8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 57                	js     801845 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	53                   	push   %ebx
  8017f2:	68 00 50 80 00       	push   $0x805000
  8017f7:	e8 3a f0 ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801804:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801807:	b8 01 00 00 00       	mov    $0x1,%eax
  80180c:	e8 22 fe ff ff       	call   801633 <fsipc>
  801811:	89 c3                	mov    %eax,%ebx
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	85 c0                	test   %eax,%eax
  801818:	79 14                	jns    80182e <open+0x6f>
		fd_close(fd, 0);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	6a 00                	push   $0x0
  80181f:	ff 75 f4             	pushl  -0xc(%ebp)
  801822:	e8 7c f9 ff ff       	call   8011a3 <fd_close>
		return r;
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	89 da                	mov    %ebx,%edx
  80182c:	eb 17                	jmp    801845 <open+0x86>
	}

	return fd2num(fd);
  80182e:	83 ec 0c             	sub    $0xc,%esp
  801831:	ff 75 f4             	pushl  -0xc(%ebp)
  801834:	e8 4b f8 ff ff       	call   801084 <fd2num>
  801839:	89 c2                	mov    %eax,%edx
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	eb 05                	jmp    801845 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801840:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801845:	89 d0                	mov    %edx,%eax
  801847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 08 00 00 00       	mov    $0x8,%eax
  80185c:	e8 d2 fd ff ff       	call   801633 <fsipc>
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	57                   	push   %edi
  801867:	56                   	push   %esi
  801868:	53                   	push   %ebx
  801869:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80186f:	6a 00                	push   $0x0
  801871:	ff 75 08             	pushl  0x8(%ebp)
  801874:	e8 46 ff ff ff       	call   8017bf <open>
  801879:	89 c7                	mov    %eax,%edi
  80187b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	85 c0                	test   %eax,%eax
  801886:	0f 88 3a 04 00 00    	js     801cc6 <spawn+0x463>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	68 00 02 00 00       	push   $0x200
  801894:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80189a:	50                   	push   %eax
  80189b:	57                   	push   %edi
  80189c:	e8 50 fb ff ff       	call   8013f1 <readn>
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018a9:	75 0c                	jne    8018b7 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018ab:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018b2:	45 4c 46 
  8018b5:	74 33                	je     8018ea <spawn+0x87>
		close(fd);
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018c0:	e8 5f f9 ff ff       	call   801224 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8018c5:	83 c4 0c             	add    $0xc,%esp
  8018c8:	68 7f 45 4c 46       	push   $0x464c457f
  8018cd:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8018d3:	68 a1 2c 80 00       	push   $0x802ca1
  8018d8:	e8 d4 e9 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8018e5:	e9 3c 04 00 00       	jmp    801d26 <spawn+0x4c3>
  8018ea:	b8 07 00 00 00       	mov    $0x7,%eax
  8018ef:	cd 30                	int    $0x30
  8018f1:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8018f7:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	0f 88 c9 03 00 00    	js     801cce <spawn+0x46b>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801905:	89 c6                	mov    %eax,%esi
  801907:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80190d:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801910:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801916:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80191c:	b9 11 00 00 00       	mov    $0x11,%ecx
  801921:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801923:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801929:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80192f:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801934:	be 00 00 00 00       	mov    $0x0,%esi
  801939:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80193c:	eb 13                	jmp    801951 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	50                   	push   %eax
  801942:	e8 b6 ee ff ff       	call   8007fd <strlen>
  801947:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80194b:	83 c3 01             	add    $0x1,%ebx
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801958:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80195b:	85 c0                	test   %eax,%eax
  80195d:	75 df                	jne    80193e <spawn+0xdb>
  80195f:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801965:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80196b:	bf 00 10 40 00       	mov    $0x401000,%edi
  801970:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801972:	89 fa                	mov    %edi,%edx
  801974:	83 e2 fc             	and    $0xfffffffc,%edx
  801977:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80197e:	29 c2                	sub    %eax,%edx
  801980:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801986:	8d 42 f8             	lea    -0x8(%edx),%eax
  801989:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80198e:	0f 86 4a 03 00 00    	jbe    801cde <spawn+0x47b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801994:	83 ec 04             	sub    $0x4,%esp
  801997:	6a 07                	push   $0x7
  801999:	68 00 00 40 00       	push   $0x400000
  80199e:	6a 00                	push   $0x0
  8019a0:	e8 94 f2 ff ff       	call   800c39 <sys_page_alloc>
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	0f 88 35 03 00 00    	js     801ce5 <spawn+0x482>
  8019b0:	be 00 00 00 00       	mov    $0x0,%esi
  8019b5:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019be:	eb 30                	jmp    8019f0 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8019c0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8019c6:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8019cc:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019d5:	57                   	push   %edi
  8019d6:	e8 5b ee ff ff       	call   800836 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019db:	83 c4 04             	add    $0x4,%esp
  8019de:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019e1:	e8 17 ee ff ff       	call   8007fd <strlen>
  8019e6:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8019ea:	83 c6 01             	add    $0x1,%esi
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8019f6:	7f c8                	jg     8019c0 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8019f8:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8019fe:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a04:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a0b:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a11:	74 19                	je     801a2c <spawn+0x1c9>
  801a13:	68 18 2d 80 00       	push   $0x802d18
  801a18:	68 80 2c 80 00       	push   $0x802c80
  801a1d:	68 f2 00 00 00       	push   $0xf2
  801a22:	68 bb 2c 80 00       	push   $0x802cbb
  801a27:	e8 ac e7 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a2c:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a32:	89 c8                	mov    %ecx,%eax
  801a34:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a39:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801a3c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a42:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a45:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801a4b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	6a 07                	push   $0x7
  801a56:	68 00 d0 bf ee       	push   $0xeebfd000
  801a5b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a61:	68 00 00 40 00       	push   $0x400000
  801a66:	6a 00                	push   $0x0
  801a68:	e8 0f f2 ff ff       	call   800c7c <sys_page_map>
  801a6d:	89 c3                	mov    %eax,%ebx
  801a6f:	83 c4 20             	add    $0x20,%esp
  801a72:	85 c0                	test   %eax,%eax
  801a74:	0f 88 9a 02 00 00    	js     801d14 <spawn+0x4b1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a7a:	83 ec 08             	sub    $0x8,%esp
  801a7d:	68 00 00 40 00       	push   $0x400000
  801a82:	6a 00                	push   $0x0
  801a84:	e8 35 f2 ff ff       	call   800cbe <sys_page_unmap>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	0f 88 7e 02 00 00    	js     801d14 <spawn+0x4b1>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801a96:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801a9c:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801aa3:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801aa9:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801ab0:	00 00 00 
  801ab3:	e9 86 01 00 00       	jmp    801c3e <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  801ab8:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801abe:	83 38 01             	cmpl   $0x1,(%eax)
  801ac1:	0f 85 69 01 00 00    	jne    801c30 <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ac7:	89 c1                	mov    %eax,%ecx
  801ac9:	8b 40 18             	mov    0x18(%eax),%eax
  801acc:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ad2:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ad5:	83 f8 01             	cmp    $0x1,%eax
  801ad8:	19 c0                	sbb    %eax,%eax
  801ada:	83 e0 fe             	and    $0xfffffffe,%eax
  801add:	83 c0 07             	add    $0x7,%eax
  801ae0:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ae6:	89 c8                	mov    %ecx,%eax
  801ae8:	8b 49 04             	mov    0x4(%ecx),%ecx
  801aeb:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801af1:	8b 78 10             	mov    0x10(%eax),%edi
  801af4:	8b 50 14             	mov    0x14(%eax),%edx
  801af7:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801afd:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b00:	89 f0                	mov    %esi,%eax
  801b02:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b07:	74 14                	je     801b1d <spawn+0x2ba>
		va -= i;
  801b09:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b0b:	01 c2                	add    %eax,%edx
  801b0d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b13:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b15:	29 c1                	sub    %eax,%ecx
  801b17:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b22:	e9 f7 00 00 00       	jmp    801c1e <spawn+0x3bb>
		if (i >= filesz) {
  801b27:	39 df                	cmp    %ebx,%edi
  801b29:	77 27                	ja     801b52 <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b2b:	83 ec 04             	sub    $0x4,%esp
  801b2e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b34:	56                   	push   %esi
  801b35:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b3b:	e8 f9 f0 ff ff       	call   800c39 <sys_page_alloc>
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	85 c0                	test   %eax,%eax
  801b45:	0f 89 c7 00 00 00    	jns    801c12 <spawn+0x3af>
  801b4b:	89 c3                	mov    %eax,%ebx
  801b4d:	e9 a1 01 00 00       	jmp    801cf3 <spawn+0x490>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b52:	83 ec 04             	sub    $0x4,%esp
  801b55:	6a 07                	push   $0x7
  801b57:	68 00 00 40 00       	push   $0x400000
  801b5c:	6a 00                	push   $0x0
  801b5e:	e8 d6 f0 ff ff       	call   800c39 <sys_page_alloc>
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	85 c0                	test   %eax,%eax
  801b68:	0f 88 7b 01 00 00    	js     801ce9 <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b6e:	83 ec 08             	sub    $0x8,%esp
  801b71:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b77:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801b7d:	50                   	push   %eax
  801b7e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b84:	e8 3d f9 ff ff       	call   8014c6 <seek>
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	0f 88 59 01 00 00    	js     801ced <spawn+0x48a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b94:	83 ec 04             	sub    $0x4,%esp
  801b97:	89 f8                	mov    %edi,%eax
  801b99:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801b9f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ba4:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801ba9:	0f 47 c1             	cmova  %ecx,%eax
  801bac:	50                   	push   %eax
  801bad:	68 00 00 40 00       	push   $0x400000
  801bb2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bb8:	e8 34 f8 ff ff       	call   8013f1 <readn>
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	0f 88 29 01 00 00    	js     801cf1 <spawn+0x48e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801bc8:	83 ec 0c             	sub    $0xc,%esp
  801bcb:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bd1:	56                   	push   %esi
  801bd2:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bd8:	68 00 00 40 00       	push   $0x400000
  801bdd:	6a 00                	push   $0x0
  801bdf:	e8 98 f0 ff ff       	call   800c7c <sys_page_map>
  801be4:	83 c4 20             	add    $0x20,%esp
  801be7:	85 c0                	test   %eax,%eax
  801be9:	79 15                	jns    801c00 <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  801beb:	50                   	push   %eax
  801bec:	68 c7 2c 80 00       	push   $0x802cc7
  801bf1:	68 25 01 00 00       	push   $0x125
  801bf6:	68 bb 2c 80 00       	push   $0x802cbb
  801bfb:	e8 d8 e5 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801c00:	83 ec 08             	sub    $0x8,%esp
  801c03:	68 00 00 40 00       	push   $0x400000
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 af f0 ff ff       	call   800cbe <sys_page_unmap>
  801c0f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c12:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c18:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c1e:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c24:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c2a:	0f 87 f7 fe ff ff    	ja     801b27 <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c30:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c37:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c3e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c45:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c4b:	0f 8c 67 fe ff ff    	jl     801ab8 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c51:	83 ec 0c             	sub    $0xc,%esp
  801c54:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c5a:	e8 c5 f5 ff ff       	call   801224 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801c5f:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801c66:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801c69:	83 c4 08             	add    $0x8,%esp
  801c6c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801c72:	50                   	push   %eax
  801c73:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c79:	e8 c4 f0 ff ff       	call   800d42 <sys_env_set_trapframe>
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	79 15                	jns    801c9a <spawn+0x437>
		panic("sys_env_set_trapframe: %e", r);
  801c85:	50                   	push   %eax
  801c86:	68 e4 2c 80 00       	push   $0x802ce4
  801c8b:	68 86 00 00 00       	push   $0x86
  801c90:	68 bb 2c 80 00       	push   $0x802cbb
  801c95:	e8 3e e5 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801c9a:	83 ec 08             	sub    $0x8,%esp
  801c9d:	6a 02                	push   $0x2
  801c9f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ca5:	e8 56 f0 ff ff       	call   800d00 <sys_env_set_status>
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	85 c0                	test   %eax,%eax
  801caf:	79 25                	jns    801cd6 <spawn+0x473>
		panic("sys_env_set_status: %e", r);
  801cb1:	50                   	push   %eax
  801cb2:	68 fe 2c 80 00       	push   $0x802cfe
  801cb7:	68 89 00 00 00       	push   $0x89
  801cbc:	68 bb 2c 80 00       	push   $0x802cbb
  801cc1:	e8 12 e5 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801cc6:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801ccc:	eb 58                	jmp    801d26 <spawn+0x4c3>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801cce:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801cd4:	eb 50                	jmp    801d26 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801cd6:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801cdc:	eb 48                	jmp    801d26 <spawn+0x4c3>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801cde:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801ce3:	eb 41                	jmp    801d26 <spawn+0x4c3>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801ce5:	89 c3                	mov    %eax,%ebx
  801ce7:	eb 3d                	jmp    801d26 <spawn+0x4c3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ce9:	89 c3                	mov    %eax,%ebx
  801ceb:	eb 06                	jmp    801cf3 <spawn+0x490>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ced:	89 c3                	mov    %eax,%ebx
  801cef:	eb 02                	jmp    801cf3 <spawn+0x490>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cf1:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801cf3:	83 ec 0c             	sub    $0xc,%esp
  801cf6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801cfc:	e8 b9 ee ff ff       	call   800bba <sys_env_destroy>
	close(fd);
  801d01:	83 c4 04             	add    $0x4,%esp
  801d04:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d0a:	e8 15 f5 ff ff       	call   801224 <close>
	return r;
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	eb 12                	jmp    801d26 <spawn+0x4c3>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801d14:	83 ec 08             	sub    $0x8,%esp
  801d17:	68 00 00 40 00       	push   $0x400000
  801d1c:	6a 00                	push   $0x0
  801d1e:	e8 9b ef ff ff       	call   800cbe <sys_page_unmap>
  801d23:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801d26:	89 d8                	mov    %ebx,%eax
  801d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5e                   	pop    %esi
  801d2d:	5f                   	pop    %edi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    

00801d30 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	56                   	push   %esi
  801d34:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d35:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d38:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d3d:	eb 03                	jmp    801d42 <spawnl+0x12>
		argc++;
  801d3f:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d42:	83 c2 04             	add    $0x4,%edx
  801d45:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801d49:	75 f4                	jne    801d3f <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d4b:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801d52:	83 e2 f0             	and    $0xfffffff0,%edx
  801d55:	29 d4                	sub    %edx,%esp
  801d57:	8d 54 24 03          	lea    0x3(%esp),%edx
  801d5b:	c1 ea 02             	shr    $0x2,%edx
  801d5e:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801d65:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d6a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801d71:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801d78:	00 
  801d79:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d80:	eb 0a                	jmp    801d8c <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801d82:	83 c0 01             	add    $0x1,%eax
  801d85:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801d89:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d8c:	39 d0                	cmp    %edx,%eax
  801d8e:	75 f2                	jne    801d82 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801d90:	83 ec 08             	sub    $0x8,%esp
  801d93:	56                   	push   %esi
  801d94:	ff 75 08             	pushl  0x8(%ebp)
  801d97:	e8 c7 fa ff ff       	call   801863 <spawn>
}
  801d9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	56                   	push   %esi
  801da7:	53                   	push   %ebx
  801da8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dab:	83 ec 0c             	sub    $0xc,%esp
  801dae:	ff 75 08             	pushl  0x8(%ebp)
  801db1:	e8 de f2 ff ff       	call   801094 <fd2data>
  801db6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801db8:	83 c4 08             	add    $0x8,%esp
  801dbb:	68 40 2d 80 00       	push   $0x802d40
  801dc0:	53                   	push   %ebx
  801dc1:	e8 70 ea ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dc6:	8b 46 04             	mov    0x4(%esi),%eax
  801dc9:	2b 06                	sub    (%esi),%eax
  801dcb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dd1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801dd8:	00 00 00 
	stat->st_dev = &devpipe;
  801ddb:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801de2:	30 80 00 
	return 0;
}
  801de5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	53                   	push   %ebx
  801df5:	83 ec 0c             	sub    $0xc,%esp
  801df8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dfb:	53                   	push   %ebx
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 bb ee ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e03:	89 1c 24             	mov    %ebx,(%esp)
  801e06:	e8 89 f2 ff ff       	call   801094 <fd2data>
  801e0b:	83 c4 08             	add    $0x8,%esp
  801e0e:	50                   	push   %eax
  801e0f:	6a 00                	push   $0x0
  801e11:	e8 a8 ee ff ff       	call   800cbe <sys_page_unmap>
}
  801e16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	57                   	push   %edi
  801e1f:	56                   	push   %esi
  801e20:	53                   	push   %ebx
  801e21:	83 ec 1c             	sub    $0x1c,%esp
  801e24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e27:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e29:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e31:	83 ec 0c             	sub    $0xc,%esp
  801e34:	ff 75 e0             	pushl  -0x20(%ebp)
  801e37:	e8 f4 05 00 00       	call   802430 <pageref>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	89 3c 24             	mov    %edi,(%esp)
  801e41:	e8 ea 05 00 00       	call   802430 <pageref>
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	39 c3                	cmp    %eax,%ebx
  801e4b:	0f 94 c1             	sete   %cl
  801e4e:	0f b6 c9             	movzbl %cl,%ecx
  801e51:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e54:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e5a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e5d:	39 ce                	cmp    %ecx,%esi
  801e5f:	74 1b                	je     801e7c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e61:	39 c3                	cmp    %eax,%ebx
  801e63:	75 c4                	jne    801e29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e65:	8b 42 58             	mov    0x58(%edx),%eax
  801e68:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e6b:	50                   	push   %eax
  801e6c:	56                   	push   %esi
  801e6d:	68 47 2d 80 00       	push   $0x802d47
  801e72:	e8 3a e4 ff ff       	call   8002b1 <cprintf>
  801e77:	83 c4 10             	add    $0x10,%esp
  801e7a:	eb ad                	jmp    801e29 <_pipeisclosed+0xe>
	}
}
  801e7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e82:	5b                   	pop    %ebx
  801e83:	5e                   	pop    %esi
  801e84:	5f                   	pop    %edi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	57                   	push   %edi
  801e8b:	56                   	push   %esi
  801e8c:	53                   	push   %ebx
  801e8d:	83 ec 28             	sub    $0x28,%esp
  801e90:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e93:	56                   	push   %esi
  801e94:	e8 fb f1 ff ff       	call   801094 <fd2data>
  801e99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	bf 00 00 00 00       	mov    $0x0,%edi
  801ea3:	eb 4b                	jmp    801ef0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ea5:	89 da                	mov    %ebx,%edx
  801ea7:	89 f0                	mov    %esi,%eax
  801ea9:	e8 6d ff ff ff       	call   801e1b <_pipeisclosed>
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	75 48                	jne    801efa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801eb2:	e8 63 ed ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eb7:	8b 43 04             	mov    0x4(%ebx),%eax
  801eba:	8b 0b                	mov    (%ebx),%ecx
  801ebc:	8d 51 20             	lea    0x20(%ecx),%edx
  801ebf:	39 d0                	cmp    %edx,%eax
  801ec1:	73 e2                	jae    801ea5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ec6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801eca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ecd:	89 c2                	mov    %eax,%edx
  801ecf:	c1 fa 1f             	sar    $0x1f,%edx
  801ed2:	89 d1                	mov    %edx,%ecx
  801ed4:	c1 e9 1b             	shr    $0x1b,%ecx
  801ed7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801eda:	83 e2 1f             	and    $0x1f,%edx
  801edd:	29 ca                	sub    %ecx,%edx
  801edf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ee3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ee7:	83 c0 01             	add    $0x1,%eax
  801eea:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eed:	83 c7 01             	add    $0x1,%edi
  801ef0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ef3:	75 c2                	jne    801eb7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ef5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef8:	eb 05                	jmp    801eff <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801efa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f02:	5b                   	pop    %ebx
  801f03:	5e                   	pop    %esi
  801f04:	5f                   	pop    %edi
  801f05:	5d                   	pop    %ebp
  801f06:	c3                   	ret    

00801f07 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	57                   	push   %edi
  801f0b:	56                   	push   %esi
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 18             	sub    $0x18,%esp
  801f10:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f13:	57                   	push   %edi
  801f14:	e8 7b f1 ff ff       	call   801094 <fd2data>
  801f19:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f23:	eb 3d                	jmp    801f62 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f25:	85 db                	test   %ebx,%ebx
  801f27:	74 04                	je     801f2d <devpipe_read+0x26>
				return i;
  801f29:	89 d8                	mov    %ebx,%eax
  801f2b:	eb 44                	jmp    801f71 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f2d:	89 f2                	mov    %esi,%edx
  801f2f:	89 f8                	mov    %edi,%eax
  801f31:	e8 e5 fe ff ff       	call   801e1b <_pipeisclosed>
  801f36:	85 c0                	test   %eax,%eax
  801f38:	75 32                	jne    801f6c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f3a:	e8 db ec ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f3f:	8b 06                	mov    (%esi),%eax
  801f41:	3b 46 04             	cmp    0x4(%esi),%eax
  801f44:	74 df                	je     801f25 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f46:	99                   	cltd   
  801f47:	c1 ea 1b             	shr    $0x1b,%edx
  801f4a:	01 d0                	add    %edx,%eax
  801f4c:	83 e0 1f             	and    $0x1f,%eax
  801f4f:	29 d0                	sub    %edx,%eax
  801f51:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f59:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f5c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f5f:	83 c3 01             	add    $0x1,%ebx
  801f62:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f65:	75 d8                	jne    801f3f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f67:	8b 45 10             	mov    0x10(%ebp),%eax
  801f6a:	eb 05                	jmp    801f71 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5f                   	pop    %edi
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    

00801f79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	56                   	push   %esi
  801f7d:	53                   	push   %ebx
  801f7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f84:	50                   	push   %eax
  801f85:	e8 21 f1 ff ff       	call   8010ab <fd_alloc>
  801f8a:	83 c4 10             	add    $0x10,%esp
  801f8d:	89 c2                	mov    %eax,%edx
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	0f 88 2c 01 00 00    	js     8020c3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f97:	83 ec 04             	sub    $0x4,%esp
  801f9a:	68 07 04 00 00       	push   $0x407
  801f9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa2:	6a 00                	push   $0x0
  801fa4:	e8 90 ec ff ff       	call   800c39 <sys_page_alloc>
  801fa9:	83 c4 10             	add    $0x10,%esp
  801fac:	89 c2                	mov    %eax,%edx
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	0f 88 0d 01 00 00    	js     8020c3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fb6:	83 ec 0c             	sub    $0xc,%esp
  801fb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fbc:	50                   	push   %eax
  801fbd:	e8 e9 f0 ff ff       	call   8010ab <fd_alloc>
  801fc2:	89 c3                	mov    %eax,%ebx
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	0f 88 e2 00 00 00    	js     8020b1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fcf:	83 ec 04             	sub    $0x4,%esp
  801fd2:	68 07 04 00 00       	push   $0x407
  801fd7:	ff 75 f0             	pushl  -0x10(%ebp)
  801fda:	6a 00                	push   $0x0
  801fdc:	e8 58 ec ff ff       	call   800c39 <sys_page_alloc>
  801fe1:	89 c3                	mov    %eax,%ebx
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	0f 88 c3 00 00 00    	js     8020b1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fee:	83 ec 0c             	sub    $0xc,%esp
  801ff1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff4:	e8 9b f0 ff ff       	call   801094 <fd2data>
  801ff9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ffb:	83 c4 0c             	add    $0xc,%esp
  801ffe:	68 07 04 00 00       	push   $0x407
  802003:	50                   	push   %eax
  802004:	6a 00                	push   $0x0
  802006:	e8 2e ec ff ff       	call   800c39 <sys_page_alloc>
  80200b:	89 c3                	mov    %eax,%ebx
  80200d:	83 c4 10             	add    $0x10,%esp
  802010:	85 c0                	test   %eax,%eax
  802012:	0f 88 89 00 00 00    	js     8020a1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802018:	83 ec 0c             	sub    $0xc,%esp
  80201b:	ff 75 f0             	pushl  -0x10(%ebp)
  80201e:	e8 71 f0 ff ff       	call   801094 <fd2data>
  802023:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80202a:	50                   	push   %eax
  80202b:	6a 00                	push   $0x0
  80202d:	56                   	push   %esi
  80202e:	6a 00                	push   $0x0
  802030:	e8 47 ec ff ff       	call   800c7c <sys_page_map>
  802035:	89 c3                	mov    %eax,%ebx
  802037:	83 c4 20             	add    $0x20,%esp
  80203a:	85 c0                	test   %eax,%eax
  80203c:	78 55                	js     802093 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80203e:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802044:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802047:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802049:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802053:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802059:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80205c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80205e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802061:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802068:	83 ec 0c             	sub    $0xc,%esp
  80206b:	ff 75 f4             	pushl  -0xc(%ebp)
  80206e:	e8 11 f0 ff ff       	call   801084 <fd2num>
  802073:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802076:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802078:	83 c4 04             	add    $0x4,%esp
  80207b:	ff 75 f0             	pushl  -0x10(%ebp)
  80207e:	e8 01 f0 ff ff       	call   801084 <fd2num>
  802083:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802086:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802089:	83 c4 10             	add    $0x10,%esp
  80208c:	ba 00 00 00 00       	mov    $0x0,%edx
  802091:	eb 30                	jmp    8020c3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802093:	83 ec 08             	sub    $0x8,%esp
  802096:	56                   	push   %esi
  802097:	6a 00                	push   $0x0
  802099:	e8 20 ec ff ff       	call   800cbe <sys_page_unmap>
  80209e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020a1:	83 ec 08             	sub    $0x8,%esp
  8020a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8020a7:	6a 00                	push   $0x0
  8020a9:	e8 10 ec ff ff       	call   800cbe <sys_page_unmap>
  8020ae:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020b1:	83 ec 08             	sub    $0x8,%esp
  8020b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b7:	6a 00                	push   $0x0
  8020b9:	e8 00 ec ff ff       	call   800cbe <sys_page_unmap>
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020c3:	89 d0                	mov    %edx,%eax
  8020c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020c8:	5b                   	pop    %ebx
  8020c9:	5e                   	pop    %esi
  8020ca:	5d                   	pop    %ebp
  8020cb:	c3                   	ret    

008020cc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d5:	50                   	push   %eax
  8020d6:	ff 75 08             	pushl  0x8(%ebp)
  8020d9:	e8 1c f0 ff ff       	call   8010fa <fd_lookup>
  8020de:	83 c4 10             	add    $0x10,%esp
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 18                	js     8020fd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020e5:	83 ec 0c             	sub    $0xc,%esp
  8020e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020eb:	e8 a4 ef ff ff       	call   801094 <fd2data>
	return _pipeisclosed(fd, p);
  8020f0:	89 c2                	mov    %eax,%edx
  8020f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f5:	e8 21 fd ff ff       	call   801e1b <_pipeisclosed>
  8020fa:	83 c4 10             	add    $0x10,%esp
}
  8020fd:	c9                   	leave  
  8020fe:	c3                   	ret    

008020ff <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802107:	85 f6                	test   %esi,%esi
  802109:	75 16                	jne    802121 <wait+0x22>
  80210b:	68 5f 2d 80 00       	push   $0x802d5f
  802110:	68 80 2c 80 00       	push   $0x802c80
  802115:	6a 09                	push   $0x9
  802117:	68 6a 2d 80 00       	push   $0x802d6a
  80211c:	e8 b7 e0 ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  802121:	89 f3                	mov    %esi,%ebx
  802123:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802129:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80212c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802132:	eb 05                	jmp    802139 <wait+0x3a>
		sys_yield();
  802134:	e8 e1 ea ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802139:	8b 43 48             	mov    0x48(%ebx),%eax
  80213c:	39 c6                	cmp    %eax,%esi
  80213e:	75 07                	jne    802147 <wait+0x48>
  802140:	8b 43 54             	mov    0x54(%ebx),%eax
  802143:	85 c0                	test   %eax,%eax
  802145:	75 ed                	jne    802134 <wait+0x35>
		sys_yield();
}
  802147:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214a:	5b                   	pop    %ebx
  80214b:	5e                   	pop    %esi
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    

0080214e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802151:	b8 00 00 00 00       	mov    $0x0,%eax
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    

00802158 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80215e:	68 75 2d 80 00       	push   $0x802d75
  802163:	ff 75 0c             	pushl  0xc(%ebp)
  802166:	e8 cb e6 ff ff       	call   800836 <strcpy>
	return 0;
}
  80216b:	b8 00 00 00 00       	mov    $0x0,%eax
  802170:	c9                   	leave  
  802171:	c3                   	ret    

00802172 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802172:	55                   	push   %ebp
  802173:	89 e5                	mov    %esp,%ebp
  802175:	57                   	push   %edi
  802176:	56                   	push   %esi
  802177:	53                   	push   %ebx
  802178:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80217e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802183:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802189:	eb 2d                	jmp    8021b8 <devcons_write+0x46>
		m = n - tot;
  80218b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80218e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802190:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802193:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802198:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80219b:	83 ec 04             	sub    $0x4,%esp
  80219e:	53                   	push   %ebx
  80219f:	03 45 0c             	add    0xc(%ebp),%eax
  8021a2:	50                   	push   %eax
  8021a3:	57                   	push   %edi
  8021a4:	e8 1f e8 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  8021a9:	83 c4 08             	add    $0x8,%esp
  8021ac:	53                   	push   %ebx
  8021ad:	57                   	push   %edi
  8021ae:	e8 ca e9 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b3:	01 de                	add    %ebx,%esi
  8021b5:	83 c4 10             	add    $0x10,%esp
  8021b8:	89 f0                	mov    %esi,%eax
  8021ba:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021bd:	72 cc                	jb     80218b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c2:	5b                   	pop    %ebx
  8021c3:	5e                   	pop    %esi
  8021c4:	5f                   	pop    %edi
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    

008021c7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	83 ec 08             	sub    $0x8,%esp
  8021cd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d6:	74 2a                	je     802202 <devcons_read+0x3b>
  8021d8:	eb 05                	jmp    8021df <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021da:	e8 3b ea ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021df:	e8 b7 e9 ff ff       	call   800b9b <sys_cgetc>
  8021e4:	85 c0                	test   %eax,%eax
  8021e6:	74 f2                	je     8021da <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021e8:	85 c0                	test   %eax,%eax
  8021ea:	78 16                	js     802202 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021ec:	83 f8 04             	cmp    $0x4,%eax
  8021ef:	74 0c                	je     8021fd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f4:	88 02                	mov    %al,(%edx)
	return 1;
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	eb 05                	jmp    802202 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021fd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802202:	c9                   	leave  
  802203:	c3                   	ret    

00802204 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80220a:	8b 45 08             	mov    0x8(%ebp),%eax
  80220d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802210:	6a 01                	push   $0x1
  802212:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802215:	50                   	push   %eax
  802216:	e8 62 e9 ff ff       	call   800b7d <sys_cputs>
}
  80221b:	83 c4 10             	add    $0x10,%esp
  80221e:	c9                   	leave  
  80221f:	c3                   	ret    

00802220 <getchar>:

int
getchar(void)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802226:	6a 01                	push   $0x1
  802228:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80222b:	50                   	push   %eax
  80222c:	6a 00                	push   $0x0
  80222e:	e8 2d f1 ff ff       	call   801360 <read>
	if (r < 0)
  802233:	83 c4 10             	add    $0x10,%esp
  802236:	85 c0                	test   %eax,%eax
  802238:	78 0f                	js     802249 <getchar+0x29>
		return r;
	if (r < 1)
  80223a:	85 c0                	test   %eax,%eax
  80223c:	7e 06                	jle    802244 <getchar+0x24>
		return -E_EOF;
	return c;
  80223e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802242:	eb 05                	jmp    802249 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802244:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802249:	c9                   	leave  
  80224a:	c3                   	ret    

0080224b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802251:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802254:	50                   	push   %eax
  802255:	ff 75 08             	pushl  0x8(%ebp)
  802258:	e8 9d ee ff ff       	call   8010fa <fd_lookup>
  80225d:	83 c4 10             	add    $0x10,%esp
  802260:	85 c0                	test   %eax,%eax
  802262:	78 11                	js     802275 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802264:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802267:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80226d:	39 10                	cmp    %edx,(%eax)
  80226f:	0f 94 c0             	sete   %al
  802272:	0f b6 c0             	movzbl %al,%eax
}
  802275:	c9                   	leave  
  802276:	c3                   	ret    

00802277 <opencons>:

int
opencons(void)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80227d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802280:	50                   	push   %eax
  802281:	e8 25 ee ff ff       	call   8010ab <fd_alloc>
  802286:	83 c4 10             	add    $0x10,%esp
		return r;
  802289:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80228b:	85 c0                	test   %eax,%eax
  80228d:	78 3e                	js     8022cd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80228f:	83 ec 04             	sub    $0x4,%esp
  802292:	68 07 04 00 00       	push   $0x407
  802297:	ff 75 f4             	pushl  -0xc(%ebp)
  80229a:	6a 00                	push   $0x0
  80229c:	e8 98 e9 ff ff       	call   800c39 <sys_page_alloc>
  8022a1:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a6:	85 c0                	test   %eax,%eax
  8022a8:	78 23                	js     8022cd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022aa:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8022b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022bf:	83 ec 0c             	sub    $0xc,%esp
  8022c2:	50                   	push   %eax
  8022c3:	e8 bc ed ff ff       	call   801084 <fd2num>
  8022c8:	89 c2                	mov    %eax,%edx
  8022ca:	83 c4 10             	add    $0x10,%esp
}
  8022cd:	89 d0                	mov    %edx,%eax
  8022cf:	c9                   	leave  
  8022d0:	c3                   	ret    

008022d1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022d7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8022de:	75 2e                	jne    80230e <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8022e0:	e8 16 e9 ff ff       	call   800bfb <sys_getenvid>
  8022e5:	83 ec 04             	sub    $0x4,%esp
  8022e8:	68 07 0e 00 00       	push   $0xe07
  8022ed:	68 00 f0 bf ee       	push   $0xeebff000
  8022f2:	50                   	push   %eax
  8022f3:	e8 41 e9 ff ff       	call   800c39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8022f8:	e8 fe e8 ff ff       	call   800bfb <sys_getenvid>
  8022fd:	83 c4 08             	add    $0x8,%esp
  802300:	68 18 23 80 00       	push   $0x802318
  802305:	50                   	push   %eax
  802306:	e8 79 ea ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
  80230b:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80230e:	8b 45 08             	mov    0x8(%ebp),%eax
  802311:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802316:	c9                   	leave  
  802317:	c3                   	ret    

00802318 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802318:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802319:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80231e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802320:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802323:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802327:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80232b:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80232e:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802331:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802332:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802335:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802336:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802337:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80233b:	c3                   	ret    

0080233c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80233c:	55                   	push   %ebp
  80233d:	89 e5                	mov    %esp,%ebp
  80233f:	56                   	push   %esi
  802340:	53                   	push   %ebx
  802341:	8b 75 08             	mov    0x8(%ebp),%esi
  802344:	8b 45 0c             	mov    0xc(%ebp),%eax
  802347:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80234a:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80234c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802351:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802354:	83 ec 0c             	sub    $0xc,%esp
  802357:	50                   	push   %eax
  802358:	e8 8c ea ff ff       	call   800de9 <sys_ipc_recv>

	if (from_env_store != NULL)
  80235d:	83 c4 10             	add    $0x10,%esp
  802360:	85 f6                	test   %esi,%esi
  802362:	74 14                	je     802378 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802364:	ba 00 00 00 00       	mov    $0x0,%edx
  802369:	85 c0                	test   %eax,%eax
  80236b:	78 09                	js     802376 <ipc_recv+0x3a>
  80236d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802373:	8b 52 74             	mov    0x74(%edx),%edx
  802376:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802378:	85 db                	test   %ebx,%ebx
  80237a:	74 14                	je     802390 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80237c:	ba 00 00 00 00       	mov    $0x0,%edx
  802381:	85 c0                	test   %eax,%eax
  802383:	78 09                	js     80238e <ipc_recv+0x52>
  802385:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80238b:	8b 52 78             	mov    0x78(%edx),%edx
  80238e:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802390:	85 c0                	test   %eax,%eax
  802392:	78 08                	js     80239c <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802394:	a1 04 40 80 00       	mov    0x804004,%eax
  802399:	8b 40 70             	mov    0x70(%eax),%eax
}
  80239c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80239f:	5b                   	pop    %ebx
  8023a0:	5e                   	pop    %esi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    

008023a3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023a3:	55                   	push   %ebp
  8023a4:	89 e5                	mov    %esp,%ebp
  8023a6:	57                   	push   %edi
  8023a7:	56                   	push   %esi
  8023a8:	53                   	push   %ebx
  8023a9:	83 ec 0c             	sub    $0xc,%esp
  8023ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8023b5:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8023b7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023bc:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8023bf:	ff 75 14             	pushl  0x14(%ebp)
  8023c2:	53                   	push   %ebx
  8023c3:	56                   	push   %esi
  8023c4:	57                   	push   %edi
  8023c5:	e8 fc e9 ff ff       	call   800dc6 <sys_ipc_try_send>

		if (err < 0) {
  8023ca:	83 c4 10             	add    $0x10,%esp
  8023cd:	85 c0                	test   %eax,%eax
  8023cf:	79 1e                	jns    8023ef <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8023d1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023d4:	75 07                	jne    8023dd <ipc_send+0x3a>
				sys_yield();
  8023d6:	e8 3f e8 ff ff       	call   800c1a <sys_yield>
  8023db:	eb e2                	jmp    8023bf <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8023dd:	50                   	push   %eax
  8023de:	68 81 2d 80 00       	push   $0x802d81
  8023e3:	6a 49                	push   $0x49
  8023e5:	68 8e 2d 80 00       	push   $0x802d8e
  8023ea:	e8 e9 dd ff ff       	call   8001d8 <_panic>
		}

	} while (err < 0);

}
  8023ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023f2:	5b                   	pop    %ebx
  8023f3:	5e                   	pop    %esi
  8023f4:	5f                   	pop    %edi
  8023f5:	5d                   	pop    %ebp
  8023f6:	c3                   	ret    

008023f7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023f7:	55                   	push   %ebp
  8023f8:	89 e5                	mov    %esp,%ebp
  8023fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023fd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802402:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802405:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80240b:	8b 52 50             	mov    0x50(%edx),%edx
  80240e:	39 ca                	cmp    %ecx,%edx
  802410:	75 0d                	jne    80241f <ipc_find_env+0x28>
			return envs[i].env_id;
  802412:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802415:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80241a:	8b 40 48             	mov    0x48(%eax),%eax
  80241d:	eb 0f                	jmp    80242e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80241f:	83 c0 01             	add    $0x1,%eax
  802422:	3d 00 04 00 00       	cmp    $0x400,%eax
  802427:	75 d9                	jne    802402 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802429:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    

00802430 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802430:	55                   	push   %ebp
  802431:	89 e5                	mov    %esp,%ebp
  802433:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802436:	89 d0                	mov    %edx,%eax
  802438:	c1 e8 16             	shr    $0x16,%eax
  80243b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802442:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802447:	f6 c1 01             	test   $0x1,%cl
  80244a:	74 1d                	je     802469 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80244c:	c1 ea 0c             	shr    $0xc,%edx
  80244f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802456:	f6 c2 01             	test   $0x1,%dl
  802459:	74 0e                	je     802469 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80245b:	c1 ea 0c             	shr    $0xc,%edx
  80245e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802465:	ef 
  802466:	0f b7 c0             	movzwl %ax,%eax
}
  802469:	5d                   	pop    %ebp
  80246a:	c3                   	ret    
  80246b:	66 90                	xchg   %ax,%ax
  80246d:	66 90                	xchg   %ax,%ax
  80246f:	90                   	nop

00802470 <__udivdi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	53                   	push   %ebx
  802474:	83 ec 1c             	sub    $0x1c,%esp
  802477:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80247b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80247f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802487:	85 f6                	test   %esi,%esi
  802489:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80248d:	89 ca                	mov    %ecx,%edx
  80248f:	89 f8                	mov    %edi,%eax
  802491:	75 3d                	jne    8024d0 <__udivdi3+0x60>
  802493:	39 cf                	cmp    %ecx,%edi
  802495:	0f 87 c5 00 00 00    	ja     802560 <__udivdi3+0xf0>
  80249b:	85 ff                	test   %edi,%edi
  80249d:	89 fd                	mov    %edi,%ebp
  80249f:	75 0b                	jne    8024ac <__udivdi3+0x3c>
  8024a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a6:	31 d2                	xor    %edx,%edx
  8024a8:	f7 f7                	div    %edi
  8024aa:	89 c5                	mov    %eax,%ebp
  8024ac:	89 c8                	mov    %ecx,%eax
  8024ae:	31 d2                	xor    %edx,%edx
  8024b0:	f7 f5                	div    %ebp
  8024b2:	89 c1                	mov    %eax,%ecx
  8024b4:	89 d8                	mov    %ebx,%eax
  8024b6:	89 cf                	mov    %ecx,%edi
  8024b8:	f7 f5                	div    %ebp
  8024ba:	89 c3                	mov    %eax,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	39 ce                	cmp    %ecx,%esi
  8024d2:	77 74                	ja     802548 <__udivdi3+0xd8>
  8024d4:	0f bd fe             	bsr    %esi,%edi
  8024d7:	83 f7 1f             	xor    $0x1f,%edi
  8024da:	0f 84 98 00 00 00    	je     802578 <__udivdi3+0x108>
  8024e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	89 c5                	mov    %eax,%ebp
  8024e9:	29 fb                	sub    %edi,%ebx
  8024eb:	d3 e6                	shl    %cl,%esi
  8024ed:	89 d9                	mov    %ebx,%ecx
  8024ef:	d3 ed                	shr    %cl,%ebp
  8024f1:	89 f9                	mov    %edi,%ecx
  8024f3:	d3 e0                	shl    %cl,%eax
  8024f5:	09 ee                	or     %ebp,%esi
  8024f7:	89 d9                	mov    %ebx,%ecx
  8024f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024fd:	89 d5                	mov    %edx,%ebp
  8024ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802503:	d3 ed                	shr    %cl,%ebp
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e2                	shl    %cl,%edx
  802509:	89 d9                	mov    %ebx,%ecx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	09 c2                	or     %eax,%edx
  80250f:	89 d0                	mov    %edx,%eax
  802511:	89 ea                	mov    %ebp,%edx
  802513:	f7 f6                	div    %esi
  802515:	89 d5                	mov    %edx,%ebp
  802517:	89 c3                	mov    %eax,%ebx
  802519:	f7 64 24 0c          	mull   0xc(%esp)
  80251d:	39 d5                	cmp    %edx,%ebp
  80251f:	72 10                	jb     802531 <__udivdi3+0xc1>
  802521:	8b 74 24 08          	mov    0x8(%esp),%esi
  802525:	89 f9                	mov    %edi,%ecx
  802527:	d3 e6                	shl    %cl,%esi
  802529:	39 c6                	cmp    %eax,%esi
  80252b:	73 07                	jae    802534 <__udivdi3+0xc4>
  80252d:	39 d5                	cmp    %edx,%ebp
  80252f:	75 03                	jne    802534 <__udivdi3+0xc4>
  802531:	83 eb 01             	sub    $0x1,%ebx
  802534:	31 ff                	xor    %edi,%edi
  802536:	89 d8                	mov    %ebx,%eax
  802538:	89 fa                	mov    %edi,%edx
  80253a:	83 c4 1c             	add    $0x1c,%esp
  80253d:	5b                   	pop    %ebx
  80253e:	5e                   	pop    %esi
  80253f:	5f                   	pop    %edi
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    
  802542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802548:	31 ff                	xor    %edi,%edi
  80254a:	31 db                	xor    %ebx,%ebx
  80254c:	89 d8                	mov    %ebx,%eax
  80254e:	89 fa                	mov    %edi,%edx
  802550:	83 c4 1c             	add    $0x1c,%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5f                   	pop    %edi
  802556:	5d                   	pop    %ebp
  802557:	c3                   	ret    
  802558:	90                   	nop
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	89 d8                	mov    %ebx,%eax
  802562:	f7 f7                	div    %edi
  802564:	31 ff                	xor    %edi,%edi
  802566:	89 c3                	mov    %eax,%ebx
  802568:	89 d8                	mov    %ebx,%eax
  80256a:	89 fa                	mov    %edi,%edx
  80256c:	83 c4 1c             	add    $0x1c,%esp
  80256f:	5b                   	pop    %ebx
  802570:	5e                   	pop    %esi
  802571:	5f                   	pop    %edi
  802572:	5d                   	pop    %ebp
  802573:	c3                   	ret    
  802574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802578:	39 ce                	cmp    %ecx,%esi
  80257a:	72 0c                	jb     802588 <__udivdi3+0x118>
  80257c:	31 db                	xor    %ebx,%ebx
  80257e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802582:	0f 87 34 ff ff ff    	ja     8024bc <__udivdi3+0x4c>
  802588:	bb 01 00 00 00       	mov    $0x1,%ebx
  80258d:	e9 2a ff ff ff       	jmp    8024bc <__udivdi3+0x4c>
  802592:	66 90                	xchg   %ax,%ax
  802594:	66 90                	xchg   %ax,%ax
  802596:	66 90                	xchg   %ax,%ax
  802598:	66 90                	xchg   %ax,%ax
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__umoddi3>:
  8025a0:	55                   	push   %ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
  8025a4:	83 ec 1c             	sub    $0x1c,%esp
  8025a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025b7:	85 d2                	test   %edx,%edx
  8025b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025c1:	89 f3                	mov    %esi,%ebx
  8025c3:	89 3c 24             	mov    %edi,(%esp)
  8025c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ca:	75 1c                	jne    8025e8 <__umoddi3+0x48>
  8025cc:	39 f7                	cmp    %esi,%edi
  8025ce:	76 50                	jbe    802620 <__umoddi3+0x80>
  8025d0:	89 c8                	mov    %ecx,%eax
  8025d2:	89 f2                	mov    %esi,%edx
  8025d4:	f7 f7                	div    %edi
  8025d6:	89 d0                	mov    %edx,%eax
  8025d8:	31 d2                	xor    %edx,%edx
  8025da:	83 c4 1c             	add    $0x1c,%esp
  8025dd:	5b                   	pop    %ebx
  8025de:	5e                   	pop    %esi
  8025df:	5f                   	pop    %edi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    
  8025e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e8:	39 f2                	cmp    %esi,%edx
  8025ea:	89 d0                	mov    %edx,%eax
  8025ec:	77 52                	ja     802640 <__umoddi3+0xa0>
  8025ee:	0f bd ea             	bsr    %edx,%ebp
  8025f1:	83 f5 1f             	xor    $0x1f,%ebp
  8025f4:	75 5a                	jne    802650 <__umoddi3+0xb0>
  8025f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025fa:	0f 82 e0 00 00 00    	jb     8026e0 <__umoddi3+0x140>
  802600:	39 0c 24             	cmp    %ecx,(%esp)
  802603:	0f 86 d7 00 00 00    	jbe    8026e0 <__umoddi3+0x140>
  802609:	8b 44 24 08          	mov    0x8(%esp),%eax
  80260d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802611:	83 c4 1c             	add    $0x1c,%esp
  802614:	5b                   	pop    %ebx
  802615:	5e                   	pop    %esi
  802616:	5f                   	pop    %edi
  802617:	5d                   	pop    %ebp
  802618:	c3                   	ret    
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	85 ff                	test   %edi,%edi
  802622:	89 fd                	mov    %edi,%ebp
  802624:	75 0b                	jne    802631 <__umoddi3+0x91>
  802626:	b8 01 00 00 00       	mov    $0x1,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	f7 f7                	div    %edi
  80262f:	89 c5                	mov    %eax,%ebp
  802631:	89 f0                	mov    %esi,%eax
  802633:	31 d2                	xor    %edx,%edx
  802635:	f7 f5                	div    %ebp
  802637:	89 c8                	mov    %ecx,%eax
  802639:	f7 f5                	div    %ebp
  80263b:	89 d0                	mov    %edx,%eax
  80263d:	eb 99                	jmp    8025d8 <__umoddi3+0x38>
  80263f:	90                   	nop
  802640:	89 c8                	mov    %ecx,%eax
  802642:	89 f2                	mov    %esi,%edx
  802644:	83 c4 1c             	add    $0x1c,%esp
  802647:	5b                   	pop    %ebx
  802648:	5e                   	pop    %esi
  802649:	5f                   	pop    %edi
  80264a:	5d                   	pop    %ebp
  80264b:	c3                   	ret    
  80264c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802650:	8b 34 24             	mov    (%esp),%esi
  802653:	bf 20 00 00 00       	mov    $0x20,%edi
  802658:	89 e9                	mov    %ebp,%ecx
  80265a:	29 ef                	sub    %ebp,%edi
  80265c:	d3 e0                	shl    %cl,%eax
  80265e:	89 f9                	mov    %edi,%ecx
  802660:	89 f2                	mov    %esi,%edx
  802662:	d3 ea                	shr    %cl,%edx
  802664:	89 e9                	mov    %ebp,%ecx
  802666:	09 c2                	or     %eax,%edx
  802668:	89 d8                	mov    %ebx,%eax
  80266a:	89 14 24             	mov    %edx,(%esp)
  80266d:	89 f2                	mov    %esi,%edx
  80266f:	d3 e2                	shl    %cl,%edx
  802671:	89 f9                	mov    %edi,%ecx
  802673:	89 54 24 04          	mov    %edx,0x4(%esp)
  802677:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80267b:	d3 e8                	shr    %cl,%eax
  80267d:	89 e9                	mov    %ebp,%ecx
  80267f:	89 c6                	mov    %eax,%esi
  802681:	d3 e3                	shl    %cl,%ebx
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 d0                	mov    %edx,%eax
  802687:	d3 e8                	shr    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	09 d8                	or     %ebx,%eax
  80268d:	89 d3                	mov    %edx,%ebx
  80268f:	89 f2                	mov    %esi,%edx
  802691:	f7 34 24             	divl   (%esp)
  802694:	89 d6                	mov    %edx,%esi
  802696:	d3 e3                	shl    %cl,%ebx
  802698:	f7 64 24 04          	mull   0x4(%esp)
  80269c:	39 d6                	cmp    %edx,%esi
  80269e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026a2:	89 d1                	mov    %edx,%ecx
  8026a4:	89 c3                	mov    %eax,%ebx
  8026a6:	72 08                	jb     8026b0 <__umoddi3+0x110>
  8026a8:	75 11                	jne    8026bb <__umoddi3+0x11b>
  8026aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ae:	73 0b                	jae    8026bb <__umoddi3+0x11b>
  8026b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026b4:	1b 14 24             	sbb    (%esp),%edx
  8026b7:	89 d1                	mov    %edx,%ecx
  8026b9:	89 c3                	mov    %eax,%ebx
  8026bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026bf:	29 da                	sub    %ebx,%edx
  8026c1:	19 ce                	sbb    %ecx,%esi
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 f0                	mov    %esi,%eax
  8026c7:	d3 e0                	shl    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	d3 ea                	shr    %cl,%edx
  8026cd:	89 e9                	mov    %ebp,%ecx
  8026cf:	d3 ee                	shr    %cl,%esi
  8026d1:	09 d0                	or     %edx,%eax
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	83 c4 1c             	add    $0x1c,%esp
  8026d8:	5b                   	pop    %ebx
  8026d9:	5e                   	pop    %esi
  8026da:	5f                   	pop    %edi
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    
  8026dd:	8d 76 00             	lea    0x0(%esi),%esi
  8026e0:	29 f9                	sub    %edi,%ecx
  8026e2:	19 d6                	sbb    %edx,%esi
  8026e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ec:	e9 18 ff ff ff       	jmp    802609 <__umoddi3+0x69>
