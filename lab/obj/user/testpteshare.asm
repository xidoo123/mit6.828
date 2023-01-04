
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
  800081:	68 2c 28 80 00       	push   $0x80282c
  800086:	6a 13                	push   $0x13
  800088:	68 3f 28 80 00       	push   $0x80283f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 6c 0e 00 00       	call   800f03 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 53 28 80 00       	push   $0x802853
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 3f 28 80 00       	push   $0x80283f
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
  8000d2:	e8 30 21 00 00       	call   802207 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 26 28 80 00       	mov    $0x802826,%edx
  8000f4:	b8 20 28 80 00       	mov    $0x802820,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 5c 28 80 00       	push   $0x80285c
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 77 28 80 00       	push   $0x802877
  80010e:	68 7c 28 80 00       	push   $0x80287c
  800113:	68 7b 28 80 00       	push   $0x80287b
  800118:	e8 1b 1d 00 00       	call   801e38 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 89 28 80 00       	push   $0x802889
  80012a:	6a 21                	push   $0x21
  80012c:	68 3f 28 80 00       	push   $0x80283f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 c8 20 00 00       	call   802207 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 26 28 80 00       	mov    $0x802826,%edx
  80015c:	b8 20 28 80 00       	mov    $0x802820,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 93 28 80 00       	push   $0x802893
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
  8001c4:	e8 bf 10 00 00       	call   801288 <close_all>
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
  8001f6:	68 d8 28 80 00       	push   $0x8028d8
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 70 2e 80 00 	movl   $0x802e70,(%esp)
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
  800314:	e8 67 22 00 00       	call   802580 <__udivdi3>
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
  800357:	e8 54 23 00 00       	call   8026b0 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 fb 28 80 00 	movsbl 0x8028fb(%eax),%eax
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
  80045b:	ff 24 85 40 2a 80 00 	jmp    *0x802a40(,%eax,4)
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
  80051f:	8b 14 85 a0 2b 80 00 	mov    0x802ba0(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 13 29 80 00       	push   $0x802913
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
  800543:	68 89 2d 80 00       	push   $0x802d89
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
  800567:	b8 0c 29 80 00       	mov    $0x80290c,%eax
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
  800be2:	68 ff 2b 80 00       	push   $0x802bff
  800be7:	6a 23                	push   $0x23
  800be9:	68 1c 2c 80 00       	push   $0x802c1c
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
  800c63:	68 ff 2b 80 00       	push   $0x802bff
  800c68:	6a 23                	push   $0x23
  800c6a:	68 1c 2c 80 00       	push   $0x802c1c
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
  800ca5:	68 ff 2b 80 00       	push   $0x802bff
  800caa:	6a 23                	push   $0x23
  800cac:	68 1c 2c 80 00       	push   $0x802c1c
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
  800ce7:	68 ff 2b 80 00       	push   $0x802bff
  800cec:	6a 23                	push   $0x23
  800cee:	68 1c 2c 80 00       	push   $0x802c1c
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
  800d29:	68 ff 2b 80 00       	push   $0x802bff
  800d2e:	6a 23                	push   $0x23
  800d30:	68 1c 2c 80 00       	push   $0x802c1c
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
  800d6b:	68 ff 2b 80 00       	push   $0x802bff
  800d70:	6a 23                	push   $0x23
  800d72:	68 1c 2c 80 00       	push   $0x802c1c
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
  800dad:	68 ff 2b 80 00       	push   $0x802bff
  800db2:	6a 23                	push   $0x23
  800db4:	68 1c 2c 80 00       	push   $0x802c1c
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
  800e11:	68 ff 2b 80 00       	push   $0x802bff
  800e16:	6a 23                	push   $0x23
  800e18:	68 1c 2c 80 00       	push   $0x802c1c
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
  800e4e:	68 2c 2c 80 00       	push   $0x802c2c
  800e53:	6a 1e                	push   $0x1e
  800e55:	68 c0 2c 80 00       	push   $0x802cc0
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
  800e84:	68 58 2c 80 00       	push   $0x802c58
  800e89:	6a 31                	push   $0x31
  800e8b:	68 c0 2c 80 00       	push   $0x802cc0
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
  800ec4:	68 7c 2c 80 00       	push   $0x802c7c
  800ec9:	6a 39                	push   $0x39
  800ecb:	68 c0 2c 80 00       	push   $0x802cc0
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
  800eeb:	68 a0 2c 80 00       	push   $0x802ca0
  800ef0:	6a 3e                	push   $0x3e
  800ef2:	68 c0 2c 80 00       	push   $0x802cc0
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
  800f11:	e8 c3 14 00 00       	call   8023d9 <set_pgfault_handler>
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
  800f22:	0f 88 67 01 00 00    	js     80108f <fork+0x18c>
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
  800f4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f52:	e9 42 01 00 00       	jmp    801099 <fork+0x196>
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
  800f6a:	0f 84 c0 00 00 00    	je     801030 <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f70:	89 d8                	mov    %ebx,%eax
  800f72:	c1 e8 0c             	shr    $0xc,%eax
  800f75:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f7c:	f6 c2 01             	test   $0x1,%dl
  800f7f:	0f 84 ab 00 00 00    	je     801030 <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800f85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8c:	a9 02 08 00 00       	test   $0x802,%eax
  800f91:	0f 84 99 00 00 00    	je     801030 <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f97:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f9e:	f6 c4 04             	test   $0x4,%ah
  800fa1:	74 17                	je     800fba <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	68 07 0e 00 00       	push   $0xe07
  800fab:	53                   	push   %ebx
  800fac:	57                   	push   %edi
  800fad:	53                   	push   %ebx
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 c7 fc ff ff       	call   800c7c <sys_page_map>
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	eb 76                	jmp    801030 <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fba:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fc1:	a8 02                	test   $0x2,%al
  800fc3:	75 0c                	jne    800fd1 <fork+0xce>
  800fc5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fcc:	f6 c4 08             	test   $0x8,%ah
  800fcf:	74 3f                	je     801010 <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	68 05 08 00 00       	push   $0x805
  800fd9:	53                   	push   %ebx
  800fda:	57                   	push   %edi
  800fdb:	53                   	push   %ebx
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 99 fc ff ff       	call   800c7c <sys_page_map>
		if (r < 0)
  800fe3:	83 c4 20             	add    $0x20,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	0f 88 a5 00 00 00    	js     801093 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	68 05 08 00 00       	push   $0x805
  800ff6:	53                   	push   %ebx
  800ff7:	6a 00                	push   $0x0
  800ff9:	53                   	push   %ebx
  800ffa:	6a 00                	push   $0x0
  800ffc:	e8 7b fc ff ff       	call   800c7c <sys_page_map>
  801001:	83 c4 20             	add    $0x20,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100b:	0f 4f c1             	cmovg  %ecx,%eax
  80100e:	eb 1c                	jmp    80102c <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	6a 05                	push   $0x5
  801015:	53                   	push   %ebx
  801016:	57                   	push   %edi
  801017:	53                   	push   %ebx
  801018:	6a 00                	push   $0x0
  80101a:	e8 5d fc ff ff       	call   800c7c <sys_page_map>
  80101f:	83 c4 20             	add    $0x20,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	b9 00 00 00 00       	mov    $0x0,%ecx
  801029:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80102c:	85 c0                	test   %eax,%eax
  80102e:	78 67                	js     801097 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801030:	83 c6 01             	add    $0x1,%esi
  801033:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801039:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80103f:	0f 85 17 ff ff ff    	jne    800f5c <fork+0x59>
  801045:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801048:	83 ec 04             	sub    $0x4,%esp
  80104b:	6a 07                	push   $0x7
  80104d:	68 00 f0 bf ee       	push   $0xeebff000
  801052:	57                   	push   %edi
  801053:	e8 e1 fb ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  801058:	83 c4 10             	add    $0x10,%esp
		return r;
  80105b:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80105d:	85 c0                	test   %eax,%eax
  80105f:	78 38                	js     801099 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801061:	83 ec 08             	sub    $0x8,%esp
  801064:	68 20 24 80 00       	push   $0x802420
  801069:	57                   	push   %edi
  80106a:	e8 15 fd ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80106f:	83 c4 10             	add    $0x10,%esp
		return r;
  801072:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801074:	85 c0                	test   %eax,%eax
  801076:	78 21                	js     801099 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801078:	83 ec 08             	sub    $0x8,%esp
  80107b:	6a 02                	push   $0x2
  80107d:	57                   	push   %edi
  80107e:	e8 7d fc ff ff       	call   800d00 <sys_env_set_status>
	if (r < 0)
  801083:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801086:	85 c0                	test   %eax,%eax
  801088:	0f 48 f8             	cmovs  %eax,%edi
  80108b:	89 fa                	mov    %edi,%edx
  80108d:	eb 0a                	jmp    801099 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80108f:	89 c2                	mov    %eax,%edx
  801091:	eb 06                	jmp    801099 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801093:	89 c2                	mov    %eax,%edx
  801095:	eb 02                	jmp    801099 <fork+0x196>
  801097:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801099:	89 d0                	mov    %edx,%eax
  80109b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sfork>:

// Challenge!
int
sfork(void)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010a9:	68 cb 2c 80 00       	push   $0x802ccb
  8010ae:	68 c6 00 00 00       	push   $0xc6
  8010b3:	68 c0 2c 80 00       	push   $0x802cc0
  8010b8:	e8 1b f1 ff ff       	call   8001d8 <_panic>

008010bd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c8:	c1 e8 0c             	shr    $0xc,%eax
}
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010dd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	c1 ea 16             	shr    $0x16,%edx
  8010f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010fb:	f6 c2 01             	test   $0x1,%dl
  8010fe:	74 11                	je     801111 <fd_alloc+0x2d>
  801100:	89 c2                	mov    %eax,%edx
  801102:	c1 ea 0c             	shr    $0xc,%edx
  801105:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80110c:	f6 c2 01             	test   $0x1,%dl
  80110f:	75 09                	jne    80111a <fd_alloc+0x36>
			*fd_store = fd;
  801111:	89 01                	mov    %eax,(%ecx)
			return 0;
  801113:	b8 00 00 00 00       	mov    $0x0,%eax
  801118:	eb 17                	jmp    801131 <fd_alloc+0x4d>
  80111a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80111f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801124:	75 c9                	jne    8010ef <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801126:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80112c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801139:	83 f8 1f             	cmp    $0x1f,%eax
  80113c:	77 36                	ja     801174 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80113e:	c1 e0 0c             	shl    $0xc,%eax
  801141:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801146:	89 c2                	mov    %eax,%edx
  801148:	c1 ea 16             	shr    $0x16,%edx
  80114b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801152:	f6 c2 01             	test   $0x1,%dl
  801155:	74 24                	je     80117b <fd_lookup+0x48>
  801157:	89 c2                	mov    %eax,%edx
  801159:	c1 ea 0c             	shr    $0xc,%edx
  80115c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801163:	f6 c2 01             	test   $0x1,%dl
  801166:	74 1a                	je     801182 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801168:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116b:	89 02                	mov    %eax,(%edx)
	return 0;
  80116d:	b8 00 00 00 00       	mov    $0x0,%eax
  801172:	eb 13                	jmp    801187 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801174:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801179:	eb 0c                	jmp    801187 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80117b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801180:	eb 05                	jmp    801187 <fd_lookup+0x54>
  801182:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801192:	ba 60 2d 80 00       	mov    $0x802d60,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801197:	eb 13                	jmp    8011ac <dev_lookup+0x23>
  801199:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80119c:	39 08                	cmp    %ecx,(%eax)
  80119e:	75 0c                	jne    8011ac <dev_lookup+0x23>
			*dev = devtab[i];
  8011a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011aa:	eb 2e                	jmp    8011da <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011ac:	8b 02                	mov    (%edx),%eax
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	75 e7                	jne    801199 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	51                   	push   %ecx
  8011be:	50                   	push   %eax
  8011bf:	68 e4 2c 80 00       	push   $0x802ce4
  8011c4:	e8 e8 f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  8011c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011da:	c9                   	leave  
  8011db:	c3                   	ret    

008011dc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 10             	sub    $0x10,%esp
  8011e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ed:	50                   	push   %eax
  8011ee:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011f4:	c1 e8 0c             	shr    $0xc,%eax
  8011f7:	50                   	push   %eax
  8011f8:	e8 36 ff ff ff       	call   801133 <fd_lookup>
  8011fd:	83 c4 08             	add    $0x8,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 05                	js     801209 <fd_close+0x2d>
	    || fd != fd2)
  801204:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801207:	74 0c                	je     801215 <fd_close+0x39>
		return (must_exist ? r : 0);
  801209:	84 db                	test   %bl,%bl
  80120b:	ba 00 00 00 00       	mov    $0x0,%edx
  801210:	0f 44 c2             	cmove  %edx,%eax
  801213:	eb 41                	jmp    801256 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801215:	83 ec 08             	sub    $0x8,%esp
  801218:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	ff 36                	pushl  (%esi)
  80121e:	e8 66 ff ff ff       	call   801189 <dev_lookup>
  801223:	89 c3                	mov    %eax,%ebx
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 1a                	js     801246 <fd_close+0x6a>
		if (dev->dev_close)
  80122c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801232:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801237:	85 c0                	test   %eax,%eax
  801239:	74 0b                	je     801246 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80123b:	83 ec 0c             	sub    $0xc,%esp
  80123e:	56                   	push   %esi
  80123f:	ff d0                	call   *%eax
  801241:	89 c3                	mov    %eax,%ebx
  801243:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801246:	83 ec 08             	sub    $0x8,%esp
  801249:	56                   	push   %esi
  80124a:	6a 00                	push   $0x0
  80124c:	e8 6d fa ff ff       	call   800cbe <sys_page_unmap>
	return r;
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	89 d8                	mov    %ebx,%eax
}
  801256:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801259:	5b                   	pop    %ebx
  80125a:	5e                   	pop    %esi
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	ff 75 08             	pushl  0x8(%ebp)
  80126a:	e8 c4 fe ff ff       	call   801133 <fd_lookup>
  80126f:	83 c4 08             	add    $0x8,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 10                	js     801286 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	6a 01                	push   $0x1
  80127b:	ff 75 f4             	pushl  -0xc(%ebp)
  80127e:	e8 59 ff ff ff       	call   8011dc <fd_close>
  801283:	83 c4 10             	add    $0x10,%esp
}
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <close_all>:

void
close_all(void)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	53                   	push   %ebx
  80128c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80128f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801294:	83 ec 0c             	sub    $0xc,%esp
  801297:	53                   	push   %ebx
  801298:	e8 c0 ff ff ff       	call   80125d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80129d:	83 c3 01             	add    $0x1,%ebx
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	83 fb 20             	cmp    $0x20,%ebx
  8012a6:	75 ec                	jne    801294 <close_all+0xc>
		close(i);
}
  8012a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ab:	c9                   	leave  
  8012ac:	c3                   	ret    

008012ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	57                   	push   %edi
  8012b1:	56                   	push   %esi
  8012b2:	53                   	push   %ebx
  8012b3:	83 ec 2c             	sub    $0x2c,%esp
  8012b6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012bc:	50                   	push   %eax
  8012bd:	ff 75 08             	pushl  0x8(%ebp)
  8012c0:	e8 6e fe ff ff       	call   801133 <fd_lookup>
  8012c5:	83 c4 08             	add    $0x8,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	0f 88 c1 00 00 00    	js     801391 <dup+0xe4>
		return r;
	close(newfdnum);
  8012d0:	83 ec 0c             	sub    $0xc,%esp
  8012d3:	56                   	push   %esi
  8012d4:	e8 84 ff ff ff       	call   80125d <close>

	newfd = INDEX2FD(newfdnum);
  8012d9:	89 f3                	mov    %esi,%ebx
  8012db:	c1 e3 0c             	shl    $0xc,%ebx
  8012de:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012e4:	83 c4 04             	add    $0x4,%esp
  8012e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ea:	e8 de fd ff ff       	call   8010cd <fd2data>
  8012ef:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012f1:	89 1c 24             	mov    %ebx,(%esp)
  8012f4:	e8 d4 fd ff ff       	call   8010cd <fd2data>
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012ff:	89 f8                	mov    %edi,%eax
  801301:	c1 e8 16             	shr    $0x16,%eax
  801304:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80130b:	a8 01                	test   $0x1,%al
  80130d:	74 37                	je     801346 <dup+0x99>
  80130f:	89 f8                	mov    %edi,%eax
  801311:	c1 e8 0c             	shr    $0xc,%eax
  801314:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80131b:	f6 c2 01             	test   $0x1,%dl
  80131e:	74 26                	je     801346 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801320:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	25 07 0e 00 00       	and    $0xe07,%eax
  80132f:	50                   	push   %eax
  801330:	ff 75 d4             	pushl  -0x2c(%ebp)
  801333:	6a 00                	push   $0x0
  801335:	57                   	push   %edi
  801336:	6a 00                	push   $0x0
  801338:	e8 3f f9 ff ff       	call   800c7c <sys_page_map>
  80133d:	89 c7                	mov    %eax,%edi
  80133f:	83 c4 20             	add    $0x20,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	78 2e                	js     801374 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801346:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801349:	89 d0                	mov    %edx,%eax
  80134b:	c1 e8 0c             	shr    $0xc,%eax
  80134e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801355:	83 ec 0c             	sub    $0xc,%esp
  801358:	25 07 0e 00 00       	and    $0xe07,%eax
  80135d:	50                   	push   %eax
  80135e:	53                   	push   %ebx
  80135f:	6a 00                	push   $0x0
  801361:	52                   	push   %edx
  801362:	6a 00                	push   $0x0
  801364:	e8 13 f9 ff ff       	call   800c7c <sys_page_map>
  801369:	89 c7                	mov    %eax,%edi
  80136b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80136e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801370:	85 ff                	test   %edi,%edi
  801372:	79 1d                	jns    801391 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	53                   	push   %ebx
  801378:	6a 00                	push   $0x0
  80137a:	e8 3f f9 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80137f:	83 c4 08             	add    $0x8,%esp
  801382:	ff 75 d4             	pushl  -0x2c(%ebp)
  801385:	6a 00                	push   $0x0
  801387:	e8 32 f9 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	89 f8                	mov    %edi,%eax
}
  801391:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    

00801399 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	53                   	push   %ebx
  80139d:	83 ec 14             	sub    $0x14,%esp
  8013a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	53                   	push   %ebx
  8013a8:	e8 86 fd ff ff       	call   801133 <fd_lookup>
  8013ad:	83 c4 08             	add    $0x8,%esp
  8013b0:	89 c2                	mov    %eax,%edx
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 6d                	js     801423 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c0:	ff 30                	pushl  (%eax)
  8013c2:	e8 c2 fd ff ff       	call   801189 <dev_lookup>
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 4c                	js     80141a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013d1:	8b 42 08             	mov    0x8(%edx),%eax
  8013d4:	83 e0 03             	and    $0x3,%eax
  8013d7:	83 f8 01             	cmp    $0x1,%eax
  8013da:	75 21                	jne    8013fd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8013e1:	8b 40 48             	mov    0x48(%eax),%eax
  8013e4:	83 ec 04             	sub    $0x4,%esp
  8013e7:	53                   	push   %ebx
  8013e8:	50                   	push   %eax
  8013e9:	68 25 2d 80 00       	push   $0x802d25
  8013ee:	e8 be ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013fb:	eb 26                	jmp    801423 <read+0x8a>
	}
	if (!dev->dev_read)
  8013fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801400:	8b 40 08             	mov    0x8(%eax),%eax
  801403:	85 c0                	test   %eax,%eax
  801405:	74 17                	je     80141e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801407:	83 ec 04             	sub    $0x4,%esp
  80140a:	ff 75 10             	pushl  0x10(%ebp)
  80140d:	ff 75 0c             	pushl  0xc(%ebp)
  801410:	52                   	push   %edx
  801411:	ff d0                	call   *%eax
  801413:	89 c2                	mov    %eax,%edx
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	eb 09                	jmp    801423 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141a:	89 c2                	mov    %eax,%edx
  80141c:	eb 05                	jmp    801423 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80141e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801423:	89 d0                	mov    %edx,%eax
  801425:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	57                   	push   %edi
  80142e:	56                   	push   %esi
  80142f:	53                   	push   %ebx
  801430:	83 ec 0c             	sub    $0xc,%esp
  801433:	8b 7d 08             	mov    0x8(%ebp),%edi
  801436:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801439:	bb 00 00 00 00       	mov    $0x0,%ebx
  80143e:	eb 21                	jmp    801461 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801440:	83 ec 04             	sub    $0x4,%esp
  801443:	89 f0                	mov    %esi,%eax
  801445:	29 d8                	sub    %ebx,%eax
  801447:	50                   	push   %eax
  801448:	89 d8                	mov    %ebx,%eax
  80144a:	03 45 0c             	add    0xc(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	57                   	push   %edi
  80144f:	e8 45 ff ff ff       	call   801399 <read>
		if (m < 0)
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 10                	js     80146b <readn+0x41>
			return m;
		if (m == 0)
  80145b:	85 c0                	test   %eax,%eax
  80145d:	74 0a                	je     801469 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80145f:	01 c3                	add    %eax,%ebx
  801461:	39 f3                	cmp    %esi,%ebx
  801463:	72 db                	jb     801440 <readn+0x16>
  801465:	89 d8                	mov    %ebx,%eax
  801467:	eb 02                	jmp    80146b <readn+0x41>
  801469:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80146b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146e:	5b                   	pop    %ebx
  80146f:	5e                   	pop    %esi
  801470:	5f                   	pop    %edi
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	53                   	push   %ebx
  801477:	83 ec 14             	sub    $0x14,%esp
  80147a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	53                   	push   %ebx
  801482:	e8 ac fc ff ff       	call   801133 <fd_lookup>
  801487:	83 c4 08             	add    $0x8,%esp
  80148a:	89 c2                	mov    %eax,%edx
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 68                	js     8014f8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149a:	ff 30                	pushl  (%eax)
  80149c:	e8 e8 fc ff ff       	call   801189 <dev_lookup>
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 47                	js     8014ef <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014af:	75 21                	jne    8014d2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b6:	8b 40 48             	mov    0x48(%eax),%eax
  8014b9:	83 ec 04             	sub    $0x4,%esp
  8014bc:	53                   	push   %ebx
  8014bd:	50                   	push   %eax
  8014be:	68 41 2d 80 00       	push   $0x802d41
  8014c3:	e8 e9 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d0:	eb 26                	jmp    8014f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d8:	85 d2                	test   %edx,%edx
  8014da:	74 17                	je     8014f3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014dc:	83 ec 04             	sub    $0x4,%esp
  8014df:	ff 75 10             	pushl  0x10(%ebp)
  8014e2:	ff 75 0c             	pushl  0xc(%ebp)
  8014e5:	50                   	push   %eax
  8014e6:	ff d2                	call   *%edx
  8014e8:	89 c2                	mov    %eax,%edx
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	eb 09                	jmp    8014f8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	eb 05                	jmp    8014f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014f8:	89 d0                	mov    %edx,%eax
  8014fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801505:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	ff 75 08             	pushl  0x8(%ebp)
  80150c:	e8 22 fc ff ff       	call   801133 <fd_lookup>
  801511:	83 c4 08             	add    $0x8,%esp
  801514:	85 c0                	test   %eax,%eax
  801516:	78 0e                	js     801526 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801518:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80151b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80151e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801521:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801526:	c9                   	leave  
  801527:	c3                   	ret    

00801528 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	53                   	push   %ebx
  80152c:	83 ec 14             	sub    $0x14,%esp
  80152f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801532:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	53                   	push   %ebx
  801537:	e8 f7 fb ff ff       	call   801133 <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	89 c2                	mov    %eax,%edx
  801541:	85 c0                	test   %eax,%eax
  801543:	78 65                	js     8015aa <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154f:	ff 30                	pushl  (%eax)
  801551:	e8 33 fc ff ff       	call   801189 <dev_lookup>
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 44                	js     8015a1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801560:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801564:	75 21                	jne    801587 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801566:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80156b:	8b 40 48             	mov    0x48(%eax),%eax
  80156e:	83 ec 04             	sub    $0x4,%esp
  801571:	53                   	push   %ebx
  801572:	50                   	push   %eax
  801573:	68 04 2d 80 00       	push   $0x802d04
  801578:	e8 34 ed ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801585:	eb 23                	jmp    8015aa <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801587:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80158a:	8b 52 18             	mov    0x18(%edx),%edx
  80158d:	85 d2                	test   %edx,%edx
  80158f:	74 14                	je     8015a5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	ff 75 0c             	pushl  0xc(%ebp)
  801597:	50                   	push   %eax
  801598:	ff d2                	call   *%edx
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	eb 09                	jmp    8015aa <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	eb 05                	jmp    8015aa <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015aa:	89 d0                	mov    %edx,%eax
  8015ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 14             	sub    $0x14,%esp
  8015b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015be:	50                   	push   %eax
  8015bf:	ff 75 08             	pushl  0x8(%ebp)
  8015c2:	e8 6c fb ff ff       	call   801133 <fd_lookup>
  8015c7:	83 c4 08             	add    $0x8,%esp
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 58                	js     801628 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	ff 30                	pushl  (%eax)
  8015dc:	e8 a8 fb ff ff       	call   801189 <dev_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 37                	js     80161f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015eb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ef:	74 32                	je     801623 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015f1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015f4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015fb:	00 00 00 
	stat->st_isdir = 0;
  8015fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801605:	00 00 00 
	stat->st_dev = dev;
  801608:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	53                   	push   %ebx
  801612:	ff 75 f0             	pushl  -0x10(%ebp)
  801615:	ff 50 14             	call   *0x14(%eax)
  801618:	89 c2                	mov    %eax,%edx
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	eb 09                	jmp    801628 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161f:	89 c2                	mov    %eax,%edx
  801621:	eb 05                	jmp    801628 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801623:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801628:	89 d0                	mov    %edx,%eax
  80162a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	56                   	push   %esi
  801633:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	6a 00                	push   $0x0
  801639:	ff 75 08             	pushl  0x8(%ebp)
  80163c:	e8 d6 01 00 00       	call   801817 <open>
  801641:	89 c3                	mov    %eax,%ebx
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	85 c0                	test   %eax,%eax
  801648:	78 1b                	js     801665 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	ff 75 0c             	pushl  0xc(%ebp)
  801650:	50                   	push   %eax
  801651:	e8 5b ff ff ff       	call   8015b1 <fstat>
  801656:	89 c6                	mov    %eax,%esi
	close(fd);
  801658:	89 1c 24             	mov    %ebx,(%esp)
  80165b:	e8 fd fb ff ff       	call   80125d <close>
	return r;
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	89 f0                	mov    %esi,%eax
}
  801665:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	56                   	push   %esi
  801670:	53                   	push   %ebx
  801671:	89 c6                	mov    %eax,%esi
  801673:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801675:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80167c:	75 12                	jne    801690 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80167e:	83 ec 0c             	sub    $0xc,%esp
  801681:	6a 01                	push   $0x1
  801683:	e8 77 0e 00 00       	call   8024ff <ipc_find_env>
  801688:	a3 00 40 80 00       	mov    %eax,0x804000
  80168d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801690:	6a 07                	push   $0x7
  801692:	68 00 50 80 00       	push   $0x805000
  801697:	56                   	push   %esi
  801698:	ff 35 00 40 80 00    	pushl  0x804000
  80169e:	e8 08 0e 00 00       	call   8024ab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016a3:	83 c4 0c             	add    $0xc,%esp
  8016a6:	6a 00                	push   $0x0
  8016a8:	53                   	push   %ebx
  8016a9:	6a 00                	push   $0x0
  8016ab:	e8 94 0d 00 00       	call   802444 <ipc_recv>
}
  8016b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b3:	5b                   	pop    %ebx
  8016b4:	5e                   	pop    %esi
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016cb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8016da:	e8 8d ff ff ff       	call   80166c <fsipc>
}
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ed:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8016fc:	e8 6b ff ff ff       	call   80166c <fsipc>
}
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	83 ec 04             	sub    $0x4,%esp
  80170a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80170d:	8b 45 08             	mov    0x8(%ebp),%eax
  801710:	8b 40 0c             	mov    0xc(%eax),%eax
  801713:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801718:	ba 00 00 00 00       	mov    $0x0,%edx
  80171d:	b8 05 00 00 00       	mov    $0x5,%eax
  801722:	e8 45 ff ff ff       	call   80166c <fsipc>
  801727:	85 c0                	test   %eax,%eax
  801729:	78 2c                	js     801757 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	68 00 50 80 00       	push   $0x805000
  801733:	53                   	push   %ebx
  801734:	e8 fd f0 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801739:	a1 80 50 80 00       	mov    0x805080,%eax
  80173e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801744:	a1 84 50 80 00       	mov    0x805084,%eax
  801749:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801757:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	83 ec 0c             	sub    $0xc,%esp
  801762:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801765:	8b 55 08             	mov    0x8(%ebp),%edx
  801768:	8b 52 0c             	mov    0xc(%edx),%edx
  80176b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801771:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801776:	50                   	push   %eax
  801777:	ff 75 0c             	pushl  0xc(%ebp)
  80177a:	68 08 50 80 00       	push   $0x805008
  80177f:	e8 44 f2 ff ff       	call   8009c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801784:	ba 00 00 00 00       	mov    $0x0,%edx
  801789:	b8 04 00 00 00       	mov    $0x4,%eax
  80178e:	e8 d9 fe ff ff       	call   80166c <fsipc>

}
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
  80179a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80179d:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017a8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b3:	b8 03 00 00 00       	mov    $0x3,%eax
  8017b8:	e8 af fe ff ff       	call   80166c <fsipc>
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	78 4b                	js     80180e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017c3:	39 c6                	cmp    %eax,%esi
  8017c5:	73 16                	jae    8017dd <devfile_read+0x48>
  8017c7:	68 70 2d 80 00       	push   $0x802d70
  8017cc:	68 77 2d 80 00       	push   $0x802d77
  8017d1:	6a 7c                	push   $0x7c
  8017d3:	68 8c 2d 80 00       	push   $0x802d8c
  8017d8:	e8 fb e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  8017dd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017e2:	7e 16                	jle    8017fa <devfile_read+0x65>
  8017e4:	68 97 2d 80 00       	push   $0x802d97
  8017e9:	68 77 2d 80 00       	push   $0x802d77
  8017ee:	6a 7d                	push   $0x7d
  8017f0:	68 8c 2d 80 00       	push   $0x802d8c
  8017f5:	e8 de e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	50                   	push   %eax
  8017fe:	68 00 50 80 00       	push   $0x805000
  801803:	ff 75 0c             	pushl  0xc(%ebp)
  801806:	e8 bd f1 ff ff       	call   8009c8 <memmove>
	return r;
  80180b:	83 c4 10             	add    $0x10,%esp
}
  80180e:	89 d8                	mov    %ebx,%eax
  801810:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801813:	5b                   	pop    %ebx
  801814:	5e                   	pop    %esi
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    

00801817 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	53                   	push   %ebx
  80181b:	83 ec 20             	sub    $0x20,%esp
  80181e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801821:	53                   	push   %ebx
  801822:	e8 d6 ef ff ff       	call   8007fd <strlen>
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80182f:	7f 67                	jg     801898 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801831:	83 ec 0c             	sub    $0xc,%esp
  801834:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801837:	50                   	push   %eax
  801838:	e8 a7 f8 ff ff       	call   8010e4 <fd_alloc>
  80183d:	83 c4 10             	add    $0x10,%esp
		return r;
  801840:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801842:	85 c0                	test   %eax,%eax
  801844:	78 57                	js     80189d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	53                   	push   %ebx
  80184a:	68 00 50 80 00       	push   $0x805000
  80184f:	e8 e2 ef ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801854:	8b 45 0c             	mov    0xc(%ebp),%eax
  801857:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80185c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185f:	b8 01 00 00 00       	mov    $0x1,%eax
  801864:	e8 03 fe ff ff       	call   80166c <fsipc>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 c0                	test   %eax,%eax
  801870:	79 14                	jns    801886 <open+0x6f>
		fd_close(fd, 0);
  801872:	83 ec 08             	sub    $0x8,%esp
  801875:	6a 00                	push   $0x0
  801877:	ff 75 f4             	pushl  -0xc(%ebp)
  80187a:	e8 5d f9 ff ff       	call   8011dc <fd_close>
		return r;
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	89 da                	mov    %ebx,%edx
  801884:	eb 17                	jmp    80189d <open+0x86>
	}

	return fd2num(fd);
  801886:	83 ec 0c             	sub    $0xc,%esp
  801889:	ff 75 f4             	pushl  -0xc(%ebp)
  80188c:	e8 2c f8 ff ff       	call   8010bd <fd2num>
  801891:	89 c2                	mov    %eax,%edx
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	eb 05                	jmp    80189d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801898:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80189d:	89 d0                	mov    %edx,%eax
  80189f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018af:	b8 08 00 00 00       	mov    $0x8,%eax
  8018b4:	e8 b3 fd ff ff       	call   80166c <fsipc>
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	57                   	push   %edi
  8018bf:	56                   	push   %esi
  8018c0:	53                   	push   %ebx
  8018c1:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018c7:	6a 00                	push   $0x0
  8018c9:	ff 75 08             	pushl  0x8(%ebp)
  8018cc:	e8 46 ff ff ff       	call   801817 <open>
  8018d1:	89 c7                	mov    %eax,%edi
  8018d3:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	0f 88 97 04 00 00    	js     801d7b <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018e4:	83 ec 04             	sub    $0x4,%esp
  8018e7:	68 00 02 00 00       	push   $0x200
  8018ec:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018f2:	50                   	push   %eax
  8018f3:	57                   	push   %edi
  8018f4:	e8 31 fb ff ff       	call   80142a <readn>
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	3d 00 02 00 00       	cmp    $0x200,%eax
  801901:	75 0c                	jne    80190f <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801903:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80190a:	45 4c 46 
  80190d:	74 33                	je     801942 <spawn+0x87>
		close(fd);
  80190f:	83 ec 0c             	sub    $0xc,%esp
  801912:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801918:	e8 40 f9 ff ff       	call   80125d <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80191d:	83 c4 0c             	add    $0xc,%esp
  801920:	68 7f 45 4c 46       	push   $0x464c457f
  801925:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80192b:	68 a3 2d 80 00       	push   $0x802da3
  801930:	e8 7c e9 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80193d:	e9 ec 04 00 00       	jmp    801e2e <spawn+0x573>
  801942:	b8 07 00 00 00       	mov    $0x7,%eax
  801947:	cd 30                	int    $0x30
  801949:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80194f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801955:	85 c0                	test   %eax,%eax
  801957:	0f 88 29 04 00 00    	js     801d86 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80195d:	89 c6                	mov    %eax,%esi
  80195f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801965:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801968:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80196e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801974:	b9 11 00 00 00       	mov    $0x11,%ecx
  801979:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80197b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801981:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801987:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80198c:	be 00 00 00 00       	mov    $0x0,%esi
  801991:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801994:	eb 13                	jmp    8019a9 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	50                   	push   %eax
  80199a:	e8 5e ee ff ff       	call   8007fd <strlen>
  80199f:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019a3:	83 c3 01             	add    $0x1,%ebx
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019b0:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	75 df                	jne    801996 <spawn+0xdb>
  8019b7:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019bd:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019c3:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019c8:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019ca:	89 fa                	mov    %edi,%edx
  8019cc:	83 e2 fc             	and    $0xfffffffc,%edx
  8019cf:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019d6:	29 c2                	sub    %eax,%edx
  8019d8:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019de:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019e1:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019e6:	0f 86 b0 03 00 00    	jbe    801d9c <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019ec:	83 ec 04             	sub    $0x4,%esp
  8019ef:	6a 07                	push   $0x7
  8019f1:	68 00 00 40 00       	push   $0x400000
  8019f6:	6a 00                	push   $0x0
  8019f8:	e8 3c f2 ff ff       	call   800c39 <sys_page_alloc>
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	0f 88 9e 03 00 00    	js     801da6 <spawn+0x4eb>
  801a08:	be 00 00 00 00       	mov    $0x0,%esi
  801a0d:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a16:	eb 30                	jmp    801a48 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a18:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a1e:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a24:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a2d:	57                   	push   %edi
  801a2e:	e8 03 ee ff ff       	call   800836 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a33:	83 c4 04             	add    $0x4,%esp
  801a36:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a39:	e8 bf ed ff ff       	call   8007fd <strlen>
  801a3e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a42:	83 c6 01             	add    $0x1,%esi
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a4e:	7f c8                	jg     801a18 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a50:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a56:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801a5c:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a63:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a69:	74 19                	je     801a84 <spawn+0x1c9>
  801a6b:	68 30 2e 80 00       	push   $0x802e30
  801a70:	68 77 2d 80 00       	push   $0x802d77
  801a75:	68 f2 00 00 00       	push   $0xf2
  801a7a:	68 bd 2d 80 00       	push   $0x802dbd
  801a7f:	e8 54 e7 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a84:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a8a:	89 f8                	mov    %edi,%eax
  801a8c:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a91:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a94:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a9a:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a9d:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801aa3:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	6a 07                	push   $0x7
  801aae:	68 00 d0 bf ee       	push   $0xeebfd000
  801ab3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ab9:	68 00 00 40 00       	push   $0x400000
  801abe:	6a 00                	push   $0x0
  801ac0:	e8 b7 f1 ff ff       	call   800c7c <sys_page_map>
  801ac5:	89 c3                	mov    %eax,%ebx
  801ac7:	83 c4 20             	add    $0x20,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	0f 88 4a 03 00 00    	js     801e1c <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ad2:	83 ec 08             	sub    $0x8,%esp
  801ad5:	68 00 00 40 00       	push   $0x400000
  801ada:	6a 00                	push   $0x0
  801adc:	e8 dd f1 ff ff       	call   800cbe <sys_page_unmap>
  801ae1:	89 c3                	mov    %eax,%ebx
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	0f 88 2e 03 00 00    	js     801e1c <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801aee:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801af4:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801afb:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b01:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b08:	00 00 00 
  801b0b:	e9 8a 01 00 00       	jmp    801c9a <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801b10:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b16:	83 38 01             	cmpl   $0x1,(%eax)
  801b19:	0f 85 6d 01 00 00    	jne    801c8c <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b1f:	89 c7                	mov    %eax,%edi
  801b21:	8b 40 18             	mov    0x18(%eax),%eax
  801b24:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b2a:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b2d:	83 f8 01             	cmp    $0x1,%eax
  801b30:	19 c0                	sbb    %eax,%eax
  801b32:	83 e0 fe             	and    $0xfffffffe,%eax
  801b35:	83 c0 07             	add    $0x7,%eax
  801b38:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b3e:	89 f8                	mov    %edi,%eax
  801b40:	8b 7f 04             	mov    0x4(%edi),%edi
  801b43:	89 f9                	mov    %edi,%ecx
  801b45:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b4b:	8b 78 10             	mov    0x10(%eax),%edi
  801b4e:	8b 70 14             	mov    0x14(%eax),%esi
  801b51:	89 f3                	mov    %esi,%ebx
  801b53:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b59:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b5c:	89 f0                	mov    %esi,%eax
  801b5e:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b63:	74 14                	je     801b79 <spawn+0x2be>
		va -= i;
  801b65:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b67:	01 c3                	add    %eax,%ebx
  801b69:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801b6f:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b71:	29 c1                	sub    %eax,%ecx
  801b73:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b79:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7e:	e9 f7 00 00 00       	jmp    801c7a <spawn+0x3bf>
		if (i >= filesz) {
  801b83:	39 df                	cmp    %ebx,%edi
  801b85:	77 27                	ja     801bae <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b87:	83 ec 04             	sub    $0x4,%esp
  801b8a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b90:	56                   	push   %esi
  801b91:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b97:	e8 9d f0 ff ff       	call   800c39 <sys_page_alloc>
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	0f 89 c7 00 00 00    	jns    801c6e <spawn+0x3b3>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	e9 09 02 00 00       	jmp    801db7 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bae:	83 ec 04             	sub    $0x4,%esp
  801bb1:	6a 07                	push   $0x7
  801bb3:	68 00 00 40 00       	push   $0x400000
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 7a f0 ff ff       	call   800c39 <sys_page_alloc>
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	0f 88 e3 01 00 00    	js     801dad <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bca:	83 ec 08             	sub    $0x8,%esp
  801bcd:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bd3:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bd9:	50                   	push   %eax
  801bda:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801be0:	e8 1a f9 ff ff       	call   8014ff <seek>
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	85 c0                	test   %eax,%eax
  801bea:	0f 88 c1 01 00 00    	js     801db1 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bf0:	83 ec 04             	sub    $0x4,%esp
  801bf3:	89 f8                	mov    %edi,%eax
  801bf5:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801bfb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c00:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c05:	0f 47 c1             	cmova  %ecx,%eax
  801c08:	50                   	push   %eax
  801c09:	68 00 00 40 00       	push   $0x400000
  801c0e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c14:	e8 11 f8 ff ff       	call   80142a <readn>
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	0f 88 91 01 00 00    	js     801db5 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c24:	83 ec 0c             	sub    $0xc,%esp
  801c27:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c2d:	56                   	push   %esi
  801c2e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c34:	68 00 00 40 00       	push   $0x400000
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 3c f0 ff ff       	call   800c7c <sys_page_map>
  801c40:	83 c4 20             	add    $0x20,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	79 15                	jns    801c5c <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801c47:	50                   	push   %eax
  801c48:	68 c9 2d 80 00       	push   $0x802dc9
  801c4d:	68 25 01 00 00       	push   $0x125
  801c52:	68 bd 2d 80 00       	push   $0x802dbd
  801c57:	e8 7c e5 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801c5c:	83 ec 08             	sub    $0x8,%esp
  801c5f:	68 00 00 40 00       	push   $0x400000
  801c64:	6a 00                	push   $0x0
  801c66:	e8 53 f0 ff ff       	call   800cbe <sys_page_unmap>
  801c6b:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c6e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c74:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c7a:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c80:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c86:	0f 87 f7 fe ff ff    	ja     801b83 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c8c:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c93:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c9a:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801ca1:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801ca7:	0f 8c 63 fe ff ff    	jl     801b10 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801cad:	83 ec 0c             	sub    $0xc,%esp
  801cb0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cb6:	e8 a2 f5 ff ff       	call   80125d <close>
  801cbb:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801cbe:	bb 00 08 00 00       	mov    $0x800,%ebx
  801cc3:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  801cc9:	89 d8                	mov    %ebx,%eax
  801ccb:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801cce:	89 c2                	mov    %eax,%edx
  801cd0:	c1 ea 16             	shr    $0x16,%edx
  801cd3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cda:	f6 c2 01             	test   $0x1,%dl
  801cdd:	74 4b                	je     801d2a <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801cdf:	89 c2                	mov    %eax,%edx
  801ce1:	c1 ea 0c             	shr    $0xc,%edx
  801ce4:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801ceb:	f6 c1 01             	test   $0x1,%cl
  801cee:	74 3a                	je     801d2a <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801cf0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cf7:	f6 c6 04             	test   $0x4,%dh
  801cfa:	74 2e                	je     801d2a <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801cfc:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801d03:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801d09:	8b 49 48             	mov    0x48(%ecx),%ecx
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d15:	52                   	push   %edx
  801d16:	50                   	push   %eax
  801d17:	56                   	push   %esi
  801d18:	50                   	push   %eax
  801d19:	51                   	push   %ecx
  801d1a:	e8 5d ef ff ff       	call   800c7c <sys_page_map>
					if (r < 0)
  801d1f:	83 c4 20             	add    $0x20,%esp
  801d22:	85 c0                	test   %eax,%eax
  801d24:	0f 88 ae 00 00 00    	js     801dd8 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801d2a:	83 c3 01             	add    $0x1,%ebx
  801d2d:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801d33:	75 94                	jne    801cc9 <spawn+0x40e>
  801d35:	e9 b3 00 00 00       	jmp    801ded <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d3a:	50                   	push   %eax
  801d3b:	68 e6 2d 80 00       	push   $0x802de6
  801d40:	68 86 00 00 00       	push   $0x86
  801d45:	68 bd 2d 80 00       	push   $0x802dbd
  801d4a:	e8 89 e4 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d4f:	83 ec 08             	sub    $0x8,%esp
  801d52:	6a 02                	push   $0x2
  801d54:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d5a:	e8 a1 ef ff ff       	call   800d00 <sys_env_set_status>
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	85 c0                	test   %eax,%eax
  801d64:	79 2b                	jns    801d91 <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801d66:	50                   	push   %eax
  801d67:	68 00 2e 80 00       	push   $0x802e00
  801d6c:	68 89 00 00 00       	push   $0x89
  801d71:	68 bd 2d 80 00       	push   $0x802dbd
  801d76:	e8 5d e4 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d7b:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d81:	e9 a8 00 00 00       	jmp    801e2e <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d86:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d8c:	e9 9d 00 00 00       	jmp    801e2e <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d91:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d97:	e9 92 00 00 00       	jmp    801e2e <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d9c:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801da1:	e9 88 00 00 00       	jmp    801e2e <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	e9 81 00 00 00       	jmp    801e2e <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dad:	89 c3                	mov    %eax,%ebx
  801daf:	eb 06                	jmp    801db7 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801db1:	89 c3                	mov    %eax,%ebx
  801db3:	eb 02                	jmp    801db7 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801db5:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801db7:	83 ec 0c             	sub    $0xc,%esp
  801dba:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dc0:	e8 f5 ed ff ff       	call   800bba <sys_env_destroy>
	close(fd);
  801dc5:	83 c4 04             	add    $0x4,%esp
  801dc8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dce:	e8 8a f4 ff ff       	call   80125d <close>
	return r;
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	eb 56                	jmp    801e2e <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801dd8:	50                   	push   %eax
  801dd9:	68 17 2e 80 00       	push   $0x802e17
  801dde:	68 82 00 00 00       	push   $0x82
  801de3:	68 bd 2d 80 00       	push   $0x802dbd
  801de8:	e8 eb e3 ff ff       	call   8001d8 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ded:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801df4:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801df7:	83 ec 08             	sub    $0x8,%esp
  801dfa:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e00:	50                   	push   %eax
  801e01:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e07:	e8 36 ef ff ff       	call   800d42 <sys_env_set_trapframe>
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	0f 89 38 ff ff ff    	jns    801d4f <spawn+0x494>
  801e17:	e9 1e ff ff ff       	jmp    801d3a <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e1c:	83 ec 08             	sub    $0x8,%esp
  801e1f:	68 00 00 40 00       	push   $0x400000
  801e24:	6a 00                	push   $0x0
  801e26:	e8 93 ee ff ff       	call   800cbe <sys_page_unmap>
  801e2b:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e2e:	89 d8                	mov    %ebx,%eax
  801e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5f                   	pop    %edi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    

00801e38 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	56                   	push   %esi
  801e3c:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e3d:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e40:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e45:	eb 03                	jmp    801e4a <spawnl+0x12>
		argc++;
  801e47:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e4a:	83 c2 04             	add    $0x4,%edx
  801e4d:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e51:	75 f4                	jne    801e47 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e53:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e5a:	83 e2 f0             	and    $0xfffffff0,%edx
  801e5d:	29 d4                	sub    %edx,%esp
  801e5f:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e63:	c1 ea 02             	shr    $0x2,%edx
  801e66:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e6d:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e72:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e79:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e80:	00 
  801e81:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
  801e88:	eb 0a                	jmp    801e94 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e8a:	83 c0 01             	add    $0x1,%eax
  801e8d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e91:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e94:	39 d0                	cmp    %edx,%eax
  801e96:	75 f2                	jne    801e8a <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e98:	83 ec 08             	sub    $0x8,%esp
  801e9b:	56                   	push   %esi
  801e9c:	ff 75 08             	pushl  0x8(%ebp)
  801e9f:	e8 17 fa ff ff       	call   8018bb <spawn>
}
  801ea4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea7:	5b                   	pop    %ebx
  801ea8:	5e                   	pop    %esi
  801ea9:	5d                   	pop    %ebp
  801eaa:	c3                   	ret    

00801eab <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	56                   	push   %esi
  801eaf:	53                   	push   %ebx
  801eb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801eb3:	83 ec 0c             	sub    $0xc,%esp
  801eb6:	ff 75 08             	pushl  0x8(%ebp)
  801eb9:	e8 0f f2 ff ff       	call   8010cd <fd2data>
  801ebe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ec0:	83 c4 08             	add    $0x8,%esp
  801ec3:	68 58 2e 80 00       	push   $0x802e58
  801ec8:	53                   	push   %ebx
  801ec9:	e8 68 e9 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ece:	8b 46 04             	mov    0x4(%esi),%eax
  801ed1:	2b 06                	sub    (%esi),%eax
  801ed3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ed9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ee0:	00 00 00 
	stat->st_dev = &devpipe;
  801ee3:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801eea:	30 80 00 
	return 0;
}
  801eed:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	53                   	push   %ebx
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f03:	53                   	push   %ebx
  801f04:	6a 00                	push   $0x0
  801f06:	e8 b3 ed ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f0b:	89 1c 24             	mov    %ebx,(%esp)
  801f0e:	e8 ba f1 ff ff       	call   8010cd <fd2data>
  801f13:	83 c4 08             	add    $0x8,%esp
  801f16:	50                   	push   %eax
  801f17:	6a 00                	push   $0x0
  801f19:	e8 a0 ed ff ff       	call   800cbe <sys_page_unmap>
}
  801f1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f21:	c9                   	leave  
  801f22:	c3                   	ret    

00801f23 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	57                   	push   %edi
  801f27:	56                   	push   %esi
  801f28:	53                   	push   %ebx
  801f29:	83 ec 1c             	sub    $0x1c,%esp
  801f2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f2f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f31:	a1 04 40 80 00       	mov    0x804004,%eax
  801f36:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f39:	83 ec 0c             	sub    $0xc,%esp
  801f3c:	ff 75 e0             	pushl  -0x20(%ebp)
  801f3f:	e8 f4 05 00 00       	call   802538 <pageref>
  801f44:	89 c3                	mov    %eax,%ebx
  801f46:	89 3c 24             	mov    %edi,(%esp)
  801f49:	e8 ea 05 00 00       	call   802538 <pageref>
  801f4e:	83 c4 10             	add    $0x10,%esp
  801f51:	39 c3                	cmp    %eax,%ebx
  801f53:	0f 94 c1             	sete   %cl
  801f56:	0f b6 c9             	movzbl %cl,%ecx
  801f59:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f5c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f62:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f65:	39 ce                	cmp    %ecx,%esi
  801f67:	74 1b                	je     801f84 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f69:	39 c3                	cmp    %eax,%ebx
  801f6b:	75 c4                	jne    801f31 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f6d:	8b 42 58             	mov    0x58(%edx),%eax
  801f70:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f73:	50                   	push   %eax
  801f74:	56                   	push   %esi
  801f75:	68 5f 2e 80 00       	push   $0x802e5f
  801f7a:	e8 32 e3 ff ff       	call   8002b1 <cprintf>
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	eb ad                	jmp    801f31 <_pipeisclosed+0xe>
	}
}
  801f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8a:	5b                   	pop    %ebx
  801f8b:	5e                   	pop    %esi
  801f8c:	5f                   	pop    %edi
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    

00801f8f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	57                   	push   %edi
  801f93:	56                   	push   %esi
  801f94:	53                   	push   %ebx
  801f95:	83 ec 28             	sub    $0x28,%esp
  801f98:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f9b:	56                   	push   %esi
  801f9c:	e8 2c f1 ff ff       	call   8010cd <fd2data>
  801fa1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa3:	83 c4 10             	add    $0x10,%esp
  801fa6:	bf 00 00 00 00       	mov    $0x0,%edi
  801fab:	eb 4b                	jmp    801ff8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fad:	89 da                	mov    %ebx,%edx
  801faf:	89 f0                	mov    %esi,%eax
  801fb1:	e8 6d ff ff ff       	call   801f23 <_pipeisclosed>
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	75 48                	jne    802002 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fba:	e8 5b ec ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fbf:	8b 43 04             	mov    0x4(%ebx),%eax
  801fc2:	8b 0b                	mov    (%ebx),%ecx
  801fc4:	8d 51 20             	lea    0x20(%ecx),%edx
  801fc7:	39 d0                	cmp    %edx,%eax
  801fc9:	73 e2                	jae    801fad <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fce:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fd2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fd5:	89 c2                	mov    %eax,%edx
  801fd7:	c1 fa 1f             	sar    $0x1f,%edx
  801fda:	89 d1                	mov    %edx,%ecx
  801fdc:	c1 e9 1b             	shr    $0x1b,%ecx
  801fdf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fe2:	83 e2 1f             	and    $0x1f,%edx
  801fe5:	29 ca                	sub    %ecx,%edx
  801fe7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801feb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fef:	83 c0 01             	add    $0x1,%eax
  801ff2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff5:	83 c7 01             	add    $0x1,%edi
  801ff8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ffb:	75 c2                	jne    801fbf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ffd:	8b 45 10             	mov    0x10(%ebp),%eax
  802000:	eb 05                	jmp    802007 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802002:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200a:	5b                   	pop    %ebx
  80200b:	5e                   	pop    %esi
  80200c:	5f                   	pop    %edi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    

0080200f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	57                   	push   %edi
  802013:	56                   	push   %esi
  802014:	53                   	push   %ebx
  802015:	83 ec 18             	sub    $0x18,%esp
  802018:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80201b:	57                   	push   %edi
  80201c:	e8 ac f0 ff ff       	call   8010cd <fd2data>
  802021:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802023:	83 c4 10             	add    $0x10,%esp
  802026:	bb 00 00 00 00       	mov    $0x0,%ebx
  80202b:	eb 3d                	jmp    80206a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80202d:	85 db                	test   %ebx,%ebx
  80202f:	74 04                	je     802035 <devpipe_read+0x26>
				return i;
  802031:	89 d8                	mov    %ebx,%eax
  802033:	eb 44                	jmp    802079 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802035:	89 f2                	mov    %esi,%edx
  802037:	89 f8                	mov    %edi,%eax
  802039:	e8 e5 fe ff ff       	call   801f23 <_pipeisclosed>
  80203e:	85 c0                	test   %eax,%eax
  802040:	75 32                	jne    802074 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802042:	e8 d3 eb ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802047:	8b 06                	mov    (%esi),%eax
  802049:	3b 46 04             	cmp    0x4(%esi),%eax
  80204c:	74 df                	je     80202d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80204e:	99                   	cltd   
  80204f:	c1 ea 1b             	shr    $0x1b,%edx
  802052:	01 d0                	add    %edx,%eax
  802054:	83 e0 1f             	and    $0x1f,%eax
  802057:	29 d0                	sub    %edx,%eax
  802059:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80205e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802061:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802064:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802067:	83 c3 01             	add    $0x1,%ebx
  80206a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80206d:	75 d8                	jne    802047 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80206f:	8b 45 10             	mov    0x10(%ebp),%eax
  802072:	eb 05                	jmp    802079 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802074:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802079:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207c:	5b                   	pop    %ebx
  80207d:	5e                   	pop    %esi
  80207e:	5f                   	pop    %edi
  80207f:	5d                   	pop    %ebp
  802080:	c3                   	ret    

00802081 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	56                   	push   %esi
  802085:	53                   	push   %ebx
  802086:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802089:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208c:	50                   	push   %eax
  80208d:	e8 52 f0 ff ff       	call   8010e4 <fd_alloc>
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	89 c2                	mov    %eax,%edx
  802097:	85 c0                	test   %eax,%eax
  802099:	0f 88 2c 01 00 00    	js     8021cb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209f:	83 ec 04             	sub    $0x4,%esp
  8020a2:	68 07 04 00 00       	push   $0x407
  8020a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020aa:	6a 00                	push   $0x0
  8020ac:	e8 88 eb ff ff       	call   800c39 <sys_page_alloc>
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	89 c2                	mov    %eax,%edx
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	0f 88 0d 01 00 00    	js     8021cb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020be:	83 ec 0c             	sub    $0xc,%esp
  8020c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020c4:	50                   	push   %eax
  8020c5:	e8 1a f0 ff ff       	call   8010e4 <fd_alloc>
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	83 c4 10             	add    $0x10,%esp
  8020cf:	85 c0                	test   %eax,%eax
  8020d1:	0f 88 e2 00 00 00    	js     8021b9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d7:	83 ec 04             	sub    $0x4,%esp
  8020da:	68 07 04 00 00       	push   $0x407
  8020df:	ff 75 f0             	pushl  -0x10(%ebp)
  8020e2:	6a 00                	push   $0x0
  8020e4:	e8 50 eb ff ff       	call   800c39 <sys_page_alloc>
  8020e9:	89 c3                	mov    %eax,%ebx
  8020eb:	83 c4 10             	add    $0x10,%esp
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	0f 88 c3 00 00 00    	js     8021b9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020f6:	83 ec 0c             	sub    $0xc,%esp
  8020f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8020fc:	e8 cc ef ff ff       	call   8010cd <fd2data>
  802101:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802103:	83 c4 0c             	add    $0xc,%esp
  802106:	68 07 04 00 00       	push   $0x407
  80210b:	50                   	push   %eax
  80210c:	6a 00                	push   $0x0
  80210e:	e8 26 eb ff ff       	call   800c39 <sys_page_alloc>
  802113:	89 c3                	mov    %eax,%ebx
  802115:	83 c4 10             	add    $0x10,%esp
  802118:	85 c0                	test   %eax,%eax
  80211a:	0f 88 89 00 00 00    	js     8021a9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802120:	83 ec 0c             	sub    $0xc,%esp
  802123:	ff 75 f0             	pushl  -0x10(%ebp)
  802126:	e8 a2 ef ff ff       	call   8010cd <fd2data>
  80212b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802132:	50                   	push   %eax
  802133:	6a 00                	push   $0x0
  802135:	56                   	push   %esi
  802136:	6a 00                	push   $0x0
  802138:	e8 3f eb ff ff       	call   800c7c <sys_page_map>
  80213d:	89 c3                	mov    %eax,%ebx
  80213f:	83 c4 20             	add    $0x20,%esp
  802142:	85 c0                	test   %eax,%eax
  802144:	78 55                	js     80219b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802146:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80214c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802151:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802154:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80215b:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802164:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802166:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802169:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802170:	83 ec 0c             	sub    $0xc,%esp
  802173:	ff 75 f4             	pushl  -0xc(%ebp)
  802176:	e8 42 ef ff ff       	call   8010bd <fd2num>
  80217b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80217e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802180:	83 c4 04             	add    $0x4,%esp
  802183:	ff 75 f0             	pushl  -0x10(%ebp)
  802186:	e8 32 ef ff ff       	call   8010bd <fd2num>
  80218b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802191:	83 c4 10             	add    $0x10,%esp
  802194:	ba 00 00 00 00       	mov    $0x0,%edx
  802199:	eb 30                	jmp    8021cb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80219b:	83 ec 08             	sub    $0x8,%esp
  80219e:	56                   	push   %esi
  80219f:	6a 00                	push   $0x0
  8021a1:	e8 18 eb ff ff       	call   800cbe <sys_page_unmap>
  8021a6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021a9:	83 ec 08             	sub    $0x8,%esp
  8021ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8021af:	6a 00                	push   $0x0
  8021b1:	e8 08 eb ff ff       	call   800cbe <sys_page_unmap>
  8021b6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021b9:	83 ec 08             	sub    $0x8,%esp
  8021bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8021bf:	6a 00                	push   $0x0
  8021c1:	e8 f8 ea ff ff       	call   800cbe <sys_page_unmap>
  8021c6:	83 c4 10             	add    $0x10,%esp
  8021c9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5e                   	pop    %esi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    

008021d4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021d4:	55                   	push   %ebp
  8021d5:	89 e5                	mov    %esp,%ebp
  8021d7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021dd:	50                   	push   %eax
  8021de:	ff 75 08             	pushl  0x8(%ebp)
  8021e1:	e8 4d ef ff ff       	call   801133 <fd_lookup>
  8021e6:	83 c4 10             	add    $0x10,%esp
  8021e9:	85 c0                	test   %eax,%eax
  8021eb:	78 18                	js     802205 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021ed:	83 ec 0c             	sub    $0xc,%esp
  8021f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f3:	e8 d5 ee ff ff       	call   8010cd <fd2data>
	return _pipeisclosed(fd, p);
  8021f8:	89 c2                	mov    %eax,%edx
  8021fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fd:	e8 21 fd ff ff       	call   801f23 <_pipeisclosed>
  802202:	83 c4 10             	add    $0x10,%esp
}
  802205:	c9                   	leave  
  802206:	c3                   	ret    

00802207 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802207:	55                   	push   %ebp
  802208:	89 e5                	mov    %esp,%ebp
  80220a:	56                   	push   %esi
  80220b:	53                   	push   %ebx
  80220c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80220f:	85 f6                	test   %esi,%esi
  802211:	75 16                	jne    802229 <wait+0x22>
  802213:	68 77 2e 80 00       	push   $0x802e77
  802218:	68 77 2d 80 00       	push   $0x802d77
  80221d:	6a 09                	push   $0x9
  80221f:	68 82 2e 80 00       	push   $0x802e82
  802224:	e8 af df ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  802229:	89 f3                	mov    %esi,%ebx
  80222b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802231:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802234:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80223a:	eb 05                	jmp    802241 <wait+0x3a>
		sys_yield();
  80223c:	e8 d9 e9 ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802241:	8b 43 48             	mov    0x48(%ebx),%eax
  802244:	39 c6                	cmp    %eax,%esi
  802246:	75 07                	jne    80224f <wait+0x48>
  802248:	8b 43 54             	mov    0x54(%ebx),%eax
  80224b:	85 c0                	test   %eax,%eax
  80224d:	75 ed                	jne    80223c <wait+0x35>
		sys_yield();
}
  80224f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802252:	5b                   	pop    %ebx
  802253:	5e                   	pop    %esi
  802254:	5d                   	pop    %ebp
  802255:	c3                   	ret    

00802256 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802256:	55                   	push   %ebp
  802257:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802259:	b8 00 00 00 00       	mov    $0x0,%eax
  80225e:	5d                   	pop    %ebp
  80225f:	c3                   	ret    

00802260 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802266:	68 8d 2e 80 00       	push   $0x802e8d
  80226b:	ff 75 0c             	pushl  0xc(%ebp)
  80226e:	e8 c3 e5 ff ff       	call   800836 <strcpy>
	return 0;
}
  802273:	b8 00 00 00 00       	mov    $0x0,%eax
  802278:	c9                   	leave  
  802279:	c3                   	ret    

0080227a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80227a:	55                   	push   %ebp
  80227b:	89 e5                	mov    %esp,%ebp
  80227d:	57                   	push   %edi
  80227e:	56                   	push   %esi
  80227f:	53                   	push   %ebx
  802280:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802286:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80228b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802291:	eb 2d                	jmp    8022c0 <devcons_write+0x46>
		m = n - tot;
  802293:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802296:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802298:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80229b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022a0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022a3:	83 ec 04             	sub    $0x4,%esp
  8022a6:	53                   	push   %ebx
  8022a7:	03 45 0c             	add    0xc(%ebp),%eax
  8022aa:	50                   	push   %eax
  8022ab:	57                   	push   %edi
  8022ac:	e8 17 e7 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  8022b1:	83 c4 08             	add    $0x8,%esp
  8022b4:	53                   	push   %ebx
  8022b5:	57                   	push   %edi
  8022b6:	e8 c2 e8 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022bb:	01 de                	add    %ebx,%esi
  8022bd:	83 c4 10             	add    $0x10,%esp
  8022c0:	89 f0                	mov    %esi,%eax
  8022c2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022c5:	72 cc                	jb     802293 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022ca:	5b                   	pop    %ebx
  8022cb:	5e                   	pop    %esi
  8022cc:	5f                   	pop    %edi
  8022cd:	5d                   	pop    %ebp
  8022ce:	c3                   	ret    

008022cf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022cf:	55                   	push   %ebp
  8022d0:	89 e5                	mov    %esp,%ebp
  8022d2:	83 ec 08             	sub    $0x8,%esp
  8022d5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022de:	74 2a                	je     80230a <devcons_read+0x3b>
  8022e0:	eb 05                	jmp    8022e7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022e2:	e8 33 e9 ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022e7:	e8 af e8 ff ff       	call   800b9b <sys_cgetc>
  8022ec:	85 c0                	test   %eax,%eax
  8022ee:	74 f2                	je     8022e2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022f0:	85 c0                	test   %eax,%eax
  8022f2:	78 16                	js     80230a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022f4:	83 f8 04             	cmp    $0x4,%eax
  8022f7:	74 0c                	je     802305 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022fc:	88 02                	mov    %al,(%edx)
	return 1;
  8022fe:	b8 01 00 00 00       	mov    $0x1,%eax
  802303:	eb 05                	jmp    80230a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802305:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80230a:	c9                   	leave  
  80230b:	c3                   	ret    

0080230c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80230c:	55                   	push   %ebp
  80230d:	89 e5                	mov    %esp,%ebp
  80230f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802312:	8b 45 08             	mov    0x8(%ebp),%eax
  802315:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802318:	6a 01                	push   $0x1
  80231a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80231d:	50                   	push   %eax
  80231e:	e8 5a e8 ff ff       	call   800b7d <sys_cputs>
}
  802323:	83 c4 10             	add    $0x10,%esp
  802326:	c9                   	leave  
  802327:	c3                   	ret    

00802328 <getchar>:

int
getchar(void)
{
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80232e:	6a 01                	push   $0x1
  802330:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802333:	50                   	push   %eax
  802334:	6a 00                	push   $0x0
  802336:	e8 5e f0 ff ff       	call   801399 <read>
	if (r < 0)
  80233b:	83 c4 10             	add    $0x10,%esp
  80233e:	85 c0                	test   %eax,%eax
  802340:	78 0f                	js     802351 <getchar+0x29>
		return r;
	if (r < 1)
  802342:	85 c0                	test   %eax,%eax
  802344:	7e 06                	jle    80234c <getchar+0x24>
		return -E_EOF;
	return c;
  802346:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80234a:	eb 05                	jmp    802351 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80234c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802351:	c9                   	leave  
  802352:	c3                   	ret    

00802353 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802353:	55                   	push   %ebp
  802354:	89 e5                	mov    %esp,%ebp
  802356:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80235c:	50                   	push   %eax
  80235d:	ff 75 08             	pushl  0x8(%ebp)
  802360:	e8 ce ed ff ff       	call   801133 <fd_lookup>
  802365:	83 c4 10             	add    $0x10,%esp
  802368:	85 c0                	test   %eax,%eax
  80236a:	78 11                	js     80237d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80236c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80236f:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802375:	39 10                	cmp    %edx,(%eax)
  802377:	0f 94 c0             	sete   %al
  80237a:	0f b6 c0             	movzbl %al,%eax
}
  80237d:	c9                   	leave  
  80237e:	c3                   	ret    

0080237f <opencons>:

int
opencons(void)
{
  80237f:	55                   	push   %ebp
  802380:	89 e5                	mov    %esp,%ebp
  802382:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802388:	50                   	push   %eax
  802389:	e8 56 ed ff ff       	call   8010e4 <fd_alloc>
  80238e:	83 c4 10             	add    $0x10,%esp
		return r;
  802391:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802393:	85 c0                	test   %eax,%eax
  802395:	78 3e                	js     8023d5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802397:	83 ec 04             	sub    $0x4,%esp
  80239a:	68 07 04 00 00       	push   $0x407
  80239f:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a2:	6a 00                	push   $0x0
  8023a4:	e8 90 e8 ff ff       	call   800c39 <sys_page_alloc>
  8023a9:	83 c4 10             	add    $0x10,%esp
		return r;
  8023ac:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ae:	85 c0                	test   %eax,%eax
  8023b0:	78 23                	js     8023d5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023b2:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023bb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023c7:	83 ec 0c             	sub    $0xc,%esp
  8023ca:	50                   	push   %eax
  8023cb:	e8 ed ec ff ff       	call   8010bd <fd2num>
  8023d0:	89 c2                	mov    %eax,%edx
  8023d2:	83 c4 10             	add    $0x10,%esp
}
  8023d5:	89 d0                	mov    %edx,%eax
  8023d7:	c9                   	leave  
  8023d8:	c3                   	ret    

008023d9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023d9:	55                   	push   %ebp
  8023da:	89 e5                	mov    %esp,%ebp
  8023dc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023df:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8023e6:	75 2e                	jne    802416 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8023e8:	e8 0e e8 ff ff       	call   800bfb <sys_getenvid>
  8023ed:	83 ec 04             	sub    $0x4,%esp
  8023f0:	68 07 0e 00 00       	push   $0xe07
  8023f5:	68 00 f0 bf ee       	push   $0xeebff000
  8023fa:	50                   	push   %eax
  8023fb:	e8 39 e8 ff ff       	call   800c39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802400:	e8 f6 e7 ff ff       	call   800bfb <sys_getenvid>
  802405:	83 c4 08             	add    $0x8,%esp
  802408:	68 20 24 80 00       	push   $0x802420
  80240d:	50                   	push   %eax
  80240e:	e8 71 e9 ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
  802413:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802416:	8b 45 08             	mov    0x8(%ebp),%eax
  802419:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80241e:	c9                   	leave  
  80241f:	c3                   	ret    

00802420 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802420:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802421:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802426:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802428:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80242b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80242f:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802433:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802436:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802439:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80243a:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80243d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80243e:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80243f:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802443:	c3                   	ret    

00802444 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802444:	55                   	push   %ebp
  802445:	89 e5                	mov    %esp,%ebp
  802447:	56                   	push   %esi
  802448:	53                   	push   %ebx
  802449:	8b 75 08             	mov    0x8(%ebp),%esi
  80244c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80244f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802452:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802454:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802459:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80245c:	83 ec 0c             	sub    $0xc,%esp
  80245f:	50                   	push   %eax
  802460:	e8 84 e9 ff ff       	call   800de9 <sys_ipc_recv>

	if (from_env_store != NULL)
  802465:	83 c4 10             	add    $0x10,%esp
  802468:	85 f6                	test   %esi,%esi
  80246a:	74 14                	je     802480 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80246c:	ba 00 00 00 00       	mov    $0x0,%edx
  802471:	85 c0                	test   %eax,%eax
  802473:	78 09                	js     80247e <ipc_recv+0x3a>
  802475:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80247b:	8b 52 74             	mov    0x74(%edx),%edx
  80247e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802480:	85 db                	test   %ebx,%ebx
  802482:	74 14                	je     802498 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802484:	ba 00 00 00 00       	mov    $0x0,%edx
  802489:	85 c0                	test   %eax,%eax
  80248b:	78 09                	js     802496 <ipc_recv+0x52>
  80248d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802493:	8b 52 78             	mov    0x78(%edx),%edx
  802496:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802498:	85 c0                	test   %eax,%eax
  80249a:	78 08                	js     8024a4 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80249c:	a1 04 40 80 00       	mov    0x804004,%eax
  8024a1:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024a7:	5b                   	pop    %ebx
  8024a8:	5e                   	pop    %esi
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    

008024ab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	57                   	push   %edi
  8024af:	56                   	push   %esi
  8024b0:	53                   	push   %ebx
  8024b1:	83 ec 0c             	sub    $0xc,%esp
  8024b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8024bd:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8024bf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024c4:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8024c7:	ff 75 14             	pushl  0x14(%ebp)
  8024ca:	53                   	push   %ebx
  8024cb:	56                   	push   %esi
  8024cc:	57                   	push   %edi
  8024cd:	e8 f4 e8 ff ff       	call   800dc6 <sys_ipc_try_send>

		if (err < 0) {
  8024d2:	83 c4 10             	add    $0x10,%esp
  8024d5:	85 c0                	test   %eax,%eax
  8024d7:	79 1e                	jns    8024f7 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8024d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024dc:	75 07                	jne    8024e5 <ipc_send+0x3a>
				sys_yield();
  8024de:	e8 37 e7 ff ff       	call   800c1a <sys_yield>
  8024e3:	eb e2                	jmp    8024c7 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8024e5:	50                   	push   %eax
  8024e6:	68 99 2e 80 00       	push   $0x802e99
  8024eb:	6a 49                	push   $0x49
  8024ed:	68 a6 2e 80 00       	push   $0x802ea6
  8024f2:	e8 e1 dc ff ff       	call   8001d8 <_panic>
		}

	} while (err < 0);

}
  8024f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024fa:	5b                   	pop    %ebx
  8024fb:	5e                   	pop    %esi
  8024fc:	5f                   	pop    %edi
  8024fd:	5d                   	pop    %ebp
  8024fe:	c3                   	ret    

008024ff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024ff:	55                   	push   %ebp
  802500:	89 e5                	mov    %esp,%ebp
  802502:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802505:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80250a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80250d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802513:	8b 52 50             	mov    0x50(%edx),%edx
  802516:	39 ca                	cmp    %ecx,%edx
  802518:	75 0d                	jne    802527 <ipc_find_env+0x28>
			return envs[i].env_id;
  80251a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80251d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802522:	8b 40 48             	mov    0x48(%eax),%eax
  802525:	eb 0f                	jmp    802536 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802527:	83 c0 01             	add    $0x1,%eax
  80252a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80252f:	75 d9                	jne    80250a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802531:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    

00802538 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802538:	55                   	push   %ebp
  802539:	89 e5                	mov    %esp,%ebp
  80253b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80253e:	89 d0                	mov    %edx,%eax
  802540:	c1 e8 16             	shr    $0x16,%eax
  802543:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80254a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80254f:	f6 c1 01             	test   $0x1,%cl
  802552:	74 1d                	je     802571 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802554:	c1 ea 0c             	shr    $0xc,%edx
  802557:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80255e:	f6 c2 01             	test   $0x1,%dl
  802561:	74 0e                	je     802571 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802563:	c1 ea 0c             	shr    $0xc,%edx
  802566:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80256d:	ef 
  80256e:	0f b7 c0             	movzwl %ax,%eax
}
  802571:	5d                   	pop    %ebp
  802572:	c3                   	ret    
  802573:	66 90                	xchg   %ax,%ax
  802575:	66 90                	xchg   %ax,%ax
  802577:	66 90                	xchg   %ax,%ax
  802579:	66 90                	xchg   %ax,%ax
  80257b:	66 90                	xchg   %ax,%ax
  80257d:	66 90                	xchg   %ax,%ax
  80257f:	90                   	nop

00802580 <__udivdi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 1c             	sub    $0x1c,%esp
  802587:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80258b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80258f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802593:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802597:	85 f6                	test   %esi,%esi
  802599:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80259d:	89 ca                	mov    %ecx,%edx
  80259f:	89 f8                	mov    %edi,%eax
  8025a1:	75 3d                	jne    8025e0 <__udivdi3+0x60>
  8025a3:	39 cf                	cmp    %ecx,%edi
  8025a5:	0f 87 c5 00 00 00    	ja     802670 <__udivdi3+0xf0>
  8025ab:	85 ff                	test   %edi,%edi
  8025ad:	89 fd                	mov    %edi,%ebp
  8025af:	75 0b                	jne    8025bc <__udivdi3+0x3c>
  8025b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b6:	31 d2                	xor    %edx,%edx
  8025b8:	f7 f7                	div    %edi
  8025ba:	89 c5                	mov    %eax,%ebp
  8025bc:	89 c8                	mov    %ecx,%eax
  8025be:	31 d2                	xor    %edx,%edx
  8025c0:	f7 f5                	div    %ebp
  8025c2:	89 c1                	mov    %eax,%ecx
  8025c4:	89 d8                	mov    %ebx,%eax
  8025c6:	89 cf                	mov    %ecx,%edi
  8025c8:	f7 f5                	div    %ebp
  8025ca:	89 c3                	mov    %eax,%ebx
  8025cc:	89 d8                	mov    %ebx,%eax
  8025ce:	89 fa                	mov    %edi,%edx
  8025d0:	83 c4 1c             	add    $0x1c,%esp
  8025d3:	5b                   	pop    %ebx
  8025d4:	5e                   	pop    %esi
  8025d5:	5f                   	pop    %edi
  8025d6:	5d                   	pop    %ebp
  8025d7:	c3                   	ret    
  8025d8:	90                   	nop
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	39 ce                	cmp    %ecx,%esi
  8025e2:	77 74                	ja     802658 <__udivdi3+0xd8>
  8025e4:	0f bd fe             	bsr    %esi,%edi
  8025e7:	83 f7 1f             	xor    $0x1f,%edi
  8025ea:	0f 84 98 00 00 00    	je     802688 <__udivdi3+0x108>
  8025f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025f5:	89 f9                	mov    %edi,%ecx
  8025f7:	89 c5                	mov    %eax,%ebp
  8025f9:	29 fb                	sub    %edi,%ebx
  8025fb:	d3 e6                	shl    %cl,%esi
  8025fd:	89 d9                	mov    %ebx,%ecx
  8025ff:	d3 ed                	shr    %cl,%ebp
  802601:	89 f9                	mov    %edi,%ecx
  802603:	d3 e0                	shl    %cl,%eax
  802605:	09 ee                	or     %ebp,%esi
  802607:	89 d9                	mov    %ebx,%ecx
  802609:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80260d:	89 d5                	mov    %edx,%ebp
  80260f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802613:	d3 ed                	shr    %cl,%ebp
  802615:	89 f9                	mov    %edi,%ecx
  802617:	d3 e2                	shl    %cl,%edx
  802619:	89 d9                	mov    %ebx,%ecx
  80261b:	d3 e8                	shr    %cl,%eax
  80261d:	09 c2                	or     %eax,%edx
  80261f:	89 d0                	mov    %edx,%eax
  802621:	89 ea                	mov    %ebp,%edx
  802623:	f7 f6                	div    %esi
  802625:	89 d5                	mov    %edx,%ebp
  802627:	89 c3                	mov    %eax,%ebx
  802629:	f7 64 24 0c          	mull   0xc(%esp)
  80262d:	39 d5                	cmp    %edx,%ebp
  80262f:	72 10                	jb     802641 <__udivdi3+0xc1>
  802631:	8b 74 24 08          	mov    0x8(%esp),%esi
  802635:	89 f9                	mov    %edi,%ecx
  802637:	d3 e6                	shl    %cl,%esi
  802639:	39 c6                	cmp    %eax,%esi
  80263b:	73 07                	jae    802644 <__udivdi3+0xc4>
  80263d:	39 d5                	cmp    %edx,%ebp
  80263f:	75 03                	jne    802644 <__udivdi3+0xc4>
  802641:	83 eb 01             	sub    $0x1,%ebx
  802644:	31 ff                	xor    %edi,%edi
  802646:	89 d8                	mov    %ebx,%eax
  802648:	89 fa                	mov    %edi,%edx
  80264a:	83 c4 1c             	add    $0x1c,%esp
  80264d:	5b                   	pop    %ebx
  80264e:	5e                   	pop    %esi
  80264f:	5f                   	pop    %edi
  802650:	5d                   	pop    %ebp
  802651:	c3                   	ret    
  802652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802658:	31 ff                	xor    %edi,%edi
  80265a:	31 db                	xor    %ebx,%ebx
  80265c:	89 d8                	mov    %ebx,%eax
  80265e:	89 fa                	mov    %edi,%edx
  802660:	83 c4 1c             	add    $0x1c,%esp
  802663:	5b                   	pop    %ebx
  802664:	5e                   	pop    %esi
  802665:	5f                   	pop    %edi
  802666:	5d                   	pop    %ebp
  802667:	c3                   	ret    
  802668:	90                   	nop
  802669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802670:	89 d8                	mov    %ebx,%eax
  802672:	f7 f7                	div    %edi
  802674:	31 ff                	xor    %edi,%edi
  802676:	89 c3                	mov    %eax,%ebx
  802678:	89 d8                	mov    %ebx,%eax
  80267a:	89 fa                	mov    %edi,%edx
  80267c:	83 c4 1c             	add    $0x1c,%esp
  80267f:	5b                   	pop    %ebx
  802680:	5e                   	pop    %esi
  802681:	5f                   	pop    %edi
  802682:	5d                   	pop    %ebp
  802683:	c3                   	ret    
  802684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802688:	39 ce                	cmp    %ecx,%esi
  80268a:	72 0c                	jb     802698 <__udivdi3+0x118>
  80268c:	31 db                	xor    %ebx,%ebx
  80268e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802692:	0f 87 34 ff ff ff    	ja     8025cc <__udivdi3+0x4c>
  802698:	bb 01 00 00 00       	mov    $0x1,%ebx
  80269d:	e9 2a ff ff ff       	jmp    8025cc <__udivdi3+0x4c>
  8026a2:	66 90                	xchg   %ax,%ax
  8026a4:	66 90                	xchg   %ax,%ax
  8026a6:	66 90                	xchg   %ax,%ax
  8026a8:	66 90                	xchg   %ax,%ax
  8026aa:	66 90                	xchg   %ax,%ax
  8026ac:	66 90                	xchg   %ax,%ax
  8026ae:	66 90                	xchg   %ax,%ax

008026b0 <__umoddi3>:
  8026b0:	55                   	push   %ebp
  8026b1:	57                   	push   %edi
  8026b2:	56                   	push   %esi
  8026b3:	53                   	push   %ebx
  8026b4:	83 ec 1c             	sub    $0x1c,%esp
  8026b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026c7:	85 d2                	test   %edx,%edx
  8026c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026d1:	89 f3                	mov    %esi,%ebx
  8026d3:	89 3c 24             	mov    %edi,(%esp)
  8026d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026da:	75 1c                	jne    8026f8 <__umoddi3+0x48>
  8026dc:	39 f7                	cmp    %esi,%edi
  8026de:	76 50                	jbe    802730 <__umoddi3+0x80>
  8026e0:	89 c8                	mov    %ecx,%eax
  8026e2:	89 f2                	mov    %esi,%edx
  8026e4:	f7 f7                	div    %edi
  8026e6:	89 d0                	mov    %edx,%eax
  8026e8:	31 d2                	xor    %edx,%edx
  8026ea:	83 c4 1c             	add    $0x1c,%esp
  8026ed:	5b                   	pop    %ebx
  8026ee:	5e                   	pop    %esi
  8026ef:	5f                   	pop    %edi
  8026f0:	5d                   	pop    %ebp
  8026f1:	c3                   	ret    
  8026f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026f8:	39 f2                	cmp    %esi,%edx
  8026fa:	89 d0                	mov    %edx,%eax
  8026fc:	77 52                	ja     802750 <__umoddi3+0xa0>
  8026fe:	0f bd ea             	bsr    %edx,%ebp
  802701:	83 f5 1f             	xor    $0x1f,%ebp
  802704:	75 5a                	jne    802760 <__umoddi3+0xb0>
  802706:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80270a:	0f 82 e0 00 00 00    	jb     8027f0 <__umoddi3+0x140>
  802710:	39 0c 24             	cmp    %ecx,(%esp)
  802713:	0f 86 d7 00 00 00    	jbe    8027f0 <__umoddi3+0x140>
  802719:	8b 44 24 08          	mov    0x8(%esp),%eax
  80271d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802721:	83 c4 1c             	add    $0x1c,%esp
  802724:	5b                   	pop    %ebx
  802725:	5e                   	pop    %esi
  802726:	5f                   	pop    %edi
  802727:	5d                   	pop    %ebp
  802728:	c3                   	ret    
  802729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802730:	85 ff                	test   %edi,%edi
  802732:	89 fd                	mov    %edi,%ebp
  802734:	75 0b                	jne    802741 <__umoddi3+0x91>
  802736:	b8 01 00 00 00       	mov    $0x1,%eax
  80273b:	31 d2                	xor    %edx,%edx
  80273d:	f7 f7                	div    %edi
  80273f:	89 c5                	mov    %eax,%ebp
  802741:	89 f0                	mov    %esi,%eax
  802743:	31 d2                	xor    %edx,%edx
  802745:	f7 f5                	div    %ebp
  802747:	89 c8                	mov    %ecx,%eax
  802749:	f7 f5                	div    %ebp
  80274b:	89 d0                	mov    %edx,%eax
  80274d:	eb 99                	jmp    8026e8 <__umoddi3+0x38>
  80274f:	90                   	nop
  802750:	89 c8                	mov    %ecx,%eax
  802752:	89 f2                	mov    %esi,%edx
  802754:	83 c4 1c             	add    $0x1c,%esp
  802757:	5b                   	pop    %ebx
  802758:	5e                   	pop    %esi
  802759:	5f                   	pop    %edi
  80275a:	5d                   	pop    %ebp
  80275b:	c3                   	ret    
  80275c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802760:	8b 34 24             	mov    (%esp),%esi
  802763:	bf 20 00 00 00       	mov    $0x20,%edi
  802768:	89 e9                	mov    %ebp,%ecx
  80276a:	29 ef                	sub    %ebp,%edi
  80276c:	d3 e0                	shl    %cl,%eax
  80276e:	89 f9                	mov    %edi,%ecx
  802770:	89 f2                	mov    %esi,%edx
  802772:	d3 ea                	shr    %cl,%edx
  802774:	89 e9                	mov    %ebp,%ecx
  802776:	09 c2                	or     %eax,%edx
  802778:	89 d8                	mov    %ebx,%eax
  80277a:	89 14 24             	mov    %edx,(%esp)
  80277d:	89 f2                	mov    %esi,%edx
  80277f:	d3 e2                	shl    %cl,%edx
  802781:	89 f9                	mov    %edi,%ecx
  802783:	89 54 24 04          	mov    %edx,0x4(%esp)
  802787:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80278b:	d3 e8                	shr    %cl,%eax
  80278d:	89 e9                	mov    %ebp,%ecx
  80278f:	89 c6                	mov    %eax,%esi
  802791:	d3 e3                	shl    %cl,%ebx
  802793:	89 f9                	mov    %edi,%ecx
  802795:	89 d0                	mov    %edx,%eax
  802797:	d3 e8                	shr    %cl,%eax
  802799:	89 e9                	mov    %ebp,%ecx
  80279b:	09 d8                	or     %ebx,%eax
  80279d:	89 d3                	mov    %edx,%ebx
  80279f:	89 f2                	mov    %esi,%edx
  8027a1:	f7 34 24             	divl   (%esp)
  8027a4:	89 d6                	mov    %edx,%esi
  8027a6:	d3 e3                	shl    %cl,%ebx
  8027a8:	f7 64 24 04          	mull   0x4(%esp)
  8027ac:	39 d6                	cmp    %edx,%esi
  8027ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027b2:	89 d1                	mov    %edx,%ecx
  8027b4:	89 c3                	mov    %eax,%ebx
  8027b6:	72 08                	jb     8027c0 <__umoddi3+0x110>
  8027b8:	75 11                	jne    8027cb <__umoddi3+0x11b>
  8027ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027be:	73 0b                	jae    8027cb <__umoddi3+0x11b>
  8027c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027c4:	1b 14 24             	sbb    (%esp),%edx
  8027c7:	89 d1                	mov    %edx,%ecx
  8027c9:	89 c3                	mov    %eax,%ebx
  8027cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027cf:	29 da                	sub    %ebx,%edx
  8027d1:	19 ce                	sbb    %ecx,%esi
  8027d3:	89 f9                	mov    %edi,%ecx
  8027d5:	89 f0                	mov    %esi,%eax
  8027d7:	d3 e0                	shl    %cl,%eax
  8027d9:	89 e9                	mov    %ebp,%ecx
  8027db:	d3 ea                	shr    %cl,%edx
  8027dd:	89 e9                	mov    %ebp,%ecx
  8027df:	d3 ee                	shr    %cl,%esi
  8027e1:	09 d0                	or     %edx,%eax
  8027e3:	89 f2                	mov    %esi,%edx
  8027e5:	83 c4 1c             	add    $0x1c,%esp
  8027e8:	5b                   	pop    %ebx
  8027e9:	5e                   	pop    %esi
  8027ea:	5f                   	pop    %edi
  8027eb:	5d                   	pop    %ebp
  8027ec:	c3                   	ret    
  8027ed:	8d 76 00             	lea    0x0(%esi),%esi
  8027f0:	29 f9                	sub    %edi,%ecx
  8027f2:	19 d6                	sbb    %edx,%esi
  8027f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027fc:	e9 18 ff ff ff       	jmp    802719 <__umoddi3+0x69>
