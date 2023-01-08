
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
  800081:	68 ac 2c 80 00       	push   $0x802cac
  800086:	6a 13                	push   $0x13
  800088:	68 bf 2c 80 00       	push   $0x802cbf
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 8b 0e 00 00       	call   800f22 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 d3 2c 80 00       	push   $0x802cd3
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 bf 2c 80 00       	push   $0x802cbf
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
  8000d2:	e8 b3 25 00 00       	call   80268a <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba a6 2c 80 00       	mov    $0x802ca6,%edx
  8000f4:	b8 a0 2c 80 00       	mov    $0x802ca0,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 dc 2c 80 00       	push   $0x802cdc
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 f7 2c 80 00       	push   $0x802cf7
  80010e:	68 fc 2c 80 00       	push   $0x802cfc
  800113:	68 fb 2c 80 00       	push   $0x802cfb
  800118:	e8 37 1d 00 00       	call   801e54 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 09 2d 80 00       	push   $0x802d09
  80012a:	6a 21                	push   $0x21
  80012c:	68 bf 2c 80 00       	push   $0x802cbf
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 4b 25 00 00       	call   80268a <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba a6 2c 80 00       	mov    $0x802ca6,%edx
  80015c:	b8 a0 2c 80 00       	mov    $0x802ca0,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 13 2d 80 00       	push   $0x802d13
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
  8001c4:	e8 db 10 00 00       	call   8012a4 <close_all>
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
  8001f6:	68 58 2d 80 00       	push   $0x802d58
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 2d 33 80 00 	movl   $0x80332d,(%esp)
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
  800314:	e8 e7 26 00 00       	call   802a00 <__udivdi3>
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
  800357:	e8 d4 27 00 00       	call   802b30 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 7b 2d 80 00 	movsbl 0x802d7b(%eax),%eax
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
  80045b:	ff 24 85 c0 2e 80 00 	jmp    *0x802ec0(,%eax,4)
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
  80051f:	8b 14 85 20 30 80 00 	mov    0x803020(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 93 2d 80 00       	push   $0x802d93
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
  800543:	68 0d 32 80 00       	push   $0x80320d
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
  800567:	b8 8c 2d 80 00       	mov    $0x802d8c,%eax
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
  800be2:	68 7f 30 80 00       	push   $0x80307f
  800be7:	6a 23                	push   $0x23
  800be9:	68 9c 30 80 00       	push   $0x80309c
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
  800c63:	68 7f 30 80 00       	push   $0x80307f
  800c68:	6a 23                	push   $0x23
  800c6a:	68 9c 30 80 00       	push   $0x80309c
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
  800ca5:	68 7f 30 80 00       	push   $0x80307f
  800caa:	6a 23                	push   $0x23
  800cac:	68 9c 30 80 00       	push   $0x80309c
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
  800ce7:	68 7f 30 80 00       	push   $0x80307f
  800cec:	6a 23                	push   $0x23
  800cee:	68 9c 30 80 00       	push   $0x80309c
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
  800d29:	68 7f 30 80 00       	push   $0x80307f
  800d2e:	6a 23                	push   $0x23
  800d30:	68 9c 30 80 00       	push   $0x80309c
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
  800d6b:	68 7f 30 80 00       	push   $0x80307f
  800d70:	6a 23                	push   $0x23
  800d72:	68 9c 30 80 00       	push   $0x80309c
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
  800dad:	68 7f 30 80 00       	push   $0x80307f
  800db2:	6a 23                	push   $0x23
  800db4:	68 9c 30 80 00       	push   $0x80309c
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
  800e11:	68 7f 30 80 00       	push   $0x80307f
  800e16:	6a 23                	push   $0x23
  800e18:	68 9c 30 80 00       	push   $0x80309c
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

00800e49 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e51:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e53:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e57:	75 25                	jne    800e7e <pgfault+0x35>
  800e59:	89 d8                	mov    %ebx,%eax
  800e5b:	c1 e8 0c             	shr    $0xc,%eax
  800e5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e65:	f6 c4 08             	test   $0x8,%ah
  800e68:	75 14                	jne    800e7e <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e6a:	83 ec 04             	sub    $0x4,%esp
  800e6d:	68 ac 30 80 00       	push   $0x8030ac
  800e72:	6a 1e                	push   $0x1e
  800e74:	68 40 31 80 00       	push   $0x803140
  800e79:	e8 5a f3 ff ff       	call   8001d8 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e7e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e84:	e8 72 fd ff ff       	call   800bfb <sys_getenvid>
  800e89:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	6a 07                	push   $0x7
  800e90:	68 00 f0 7f 00       	push   $0x7ff000
  800e95:	50                   	push   %eax
  800e96:	e8 9e fd ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  800e9b:	83 c4 10             	add    $0x10,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	79 12                	jns    800eb4 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ea2:	50                   	push   %eax
  800ea3:	68 d8 30 80 00       	push   $0x8030d8
  800ea8:	6a 33                	push   $0x33
  800eaa:	68 40 31 80 00       	push   $0x803140
  800eaf:	e8 24 f3 ff ff       	call   8001d8 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800eb4:	83 ec 04             	sub    $0x4,%esp
  800eb7:	68 00 10 00 00       	push   $0x1000
  800ebc:	53                   	push   %ebx
  800ebd:	68 00 f0 7f 00       	push   $0x7ff000
  800ec2:	e8 69 fb ff ff       	call   800a30 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800ec7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ece:	53                   	push   %ebx
  800ecf:	56                   	push   %esi
  800ed0:	68 00 f0 7f 00       	push   $0x7ff000
  800ed5:	56                   	push   %esi
  800ed6:	e8 a1 fd ff ff       	call   800c7c <sys_page_map>
	if (r < 0)
  800edb:	83 c4 20             	add    $0x20,%esp
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	79 12                	jns    800ef4 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800ee2:	50                   	push   %eax
  800ee3:	68 fc 30 80 00       	push   $0x8030fc
  800ee8:	6a 3b                	push   $0x3b
  800eea:	68 40 31 80 00       	push   $0x803140
  800eef:	e8 e4 f2 ff ff       	call   8001d8 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800ef4:	83 ec 08             	sub    $0x8,%esp
  800ef7:	68 00 f0 7f 00       	push   $0x7ff000
  800efc:	56                   	push   %esi
  800efd:	e8 bc fd ff ff       	call   800cbe <sys_page_unmap>
	if (r < 0)
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	79 12                	jns    800f1b <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f09:	50                   	push   %eax
  800f0a:	68 20 31 80 00       	push   $0x803120
  800f0f:	6a 40                	push   $0x40
  800f11:	68 40 31 80 00       	push   $0x803140
  800f16:	e8 bd f2 ff ff       	call   8001d8 <_panic>
}
  800f1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	57                   	push   %edi
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f2b:	68 49 0e 80 00       	push   $0x800e49
  800f30:	e8 27 19 00 00       	call   80285c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f35:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3a:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	0f 88 64 01 00 00    	js     8010ab <fork+0x189>
  800f47:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f4c:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f51:	85 c0                	test   %eax,%eax
  800f53:	75 21                	jne    800f76 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f55:	e8 a1 fc ff ff       	call   800bfb <sys_getenvid>
  800f5a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f5f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f62:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f67:	a3 08 50 80 00       	mov    %eax,0x805008
        return 0;
  800f6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f71:	e9 3f 01 00 00       	jmp    8010b5 <fork+0x193>
  800f76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f79:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	c1 e8 16             	shr    $0x16,%eax
  800f80:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f87:	a8 01                	test   $0x1,%al
  800f89:	0f 84 bd 00 00 00    	je     80104c <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f8f:	89 d8                	mov    %ebx,%eax
  800f91:	c1 e8 0c             	shr    $0xc,%eax
  800f94:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9b:	f6 c2 01             	test   $0x1,%dl
  800f9e:	0f 84 a8 00 00 00    	je     80104c <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800fa4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fab:	a8 04                	test   $0x4,%al
  800fad:	0f 84 99 00 00 00    	je     80104c <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800fb3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fba:	f6 c4 04             	test   $0x4,%ah
  800fbd:	74 17                	je     800fd6 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	68 07 0e 00 00       	push   $0xe07
  800fc7:	53                   	push   %ebx
  800fc8:	57                   	push   %edi
  800fc9:	53                   	push   %ebx
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 ab fc ff ff       	call   800c7c <sys_page_map>
  800fd1:	83 c4 20             	add    $0x20,%esp
  800fd4:	eb 76                	jmp    80104c <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fd6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fdd:	a8 02                	test   $0x2,%al
  800fdf:	75 0c                	jne    800fed <fork+0xcb>
  800fe1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fe8:	f6 c4 08             	test   $0x8,%ah
  800feb:	74 3f                	je     80102c <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	68 05 08 00 00       	push   $0x805
  800ff5:	53                   	push   %ebx
  800ff6:	57                   	push   %edi
  800ff7:	53                   	push   %ebx
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 7d fc ff ff       	call   800c7c <sys_page_map>
		if (r < 0)
  800fff:	83 c4 20             	add    $0x20,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	0f 88 a5 00 00 00    	js     8010af <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	68 05 08 00 00       	push   $0x805
  801012:	53                   	push   %ebx
  801013:	6a 00                	push   $0x0
  801015:	53                   	push   %ebx
  801016:	6a 00                	push   $0x0
  801018:	e8 5f fc ff ff       	call   800c7c <sys_page_map>
  80101d:	83 c4 20             	add    $0x20,%esp
  801020:	85 c0                	test   %eax,%eax
  801022:	b9 00 00 00 00       	mov    $0x0,%ecx
  801027:	0f 4f c1             	cmovg  %ecx,%eax
  80102a:	eb 1c                	jmp    801048 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	6a 05                	push   $0x5
  801031:	53                   	push   %ebx
  801032:	57                   	push   %edi
  801033:	53                   	push   %ebx
  801034:	6a 00                	push   $0x0
  801036:	e8 41 fc ff ff       	call   800c7c <sys_page_map>
  80103b:	83 c4 20             	add    $0x20,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	b9 00 00 00 00       	mov    $0x0,%ecx
  801045:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801048:	85 c0                	test   %eax,%eax
  80104a:	78 67                	js     8010b3 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80104c:	83 c6 01             	add    $0x1,%esi
  80104f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801055:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80105b:	0f 85 1a ff ff ff    	jne    800f7b <fork+0x59>
  801061:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801064:	83 ec 04             	sub    $0x4,%esp
  801067:	6a 07                	push   $0x7
  801069:	68 00 f0 bf ee       	push   $0xeebff000
  80106e:	57                   	push   %edi
  80106f:	e8 c5 fb ff ff       	call   800c39 <sys_page_alloc>
	if (r < 0)
  801074:	83 c4 10             	add    $0x10,%esp
		return r;
  801077:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 38                	js     8010b5 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80107d:	83 ec 08             	sub    $0x8,%esp
  801080:	68 a3 28 80 00       	push   $0x8028a3
  801085:	57                   	push   %edi
  801086:	e8 f9 fc ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80108b:	83 c4 10             	add    $0x10,%esp
		return r;
  80108e:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801090:	85 c0                	test   %eax,%eax
  801092:	78 21                	js     8010b5 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801094:	83 ec 08             	sub    $0x8,%esp
  801097:	6a 02                	push   $0x2
  801099:	57                   	push   %edi
  80109a:	e8 61 fc ff ff       	call   800d00 <sys_env_set_status>
	if (r < 0)
  80109f:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	0f 48 f8             	cmovs  %eax,%edi
  8010a7:	89 fa                	mov    %edi,%edx
  8010a9:	eb 0a                	jmp    8010b5 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	eb 06                	jmp    8010b5 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010af:	89 c2                	mov    %eax,%edx
  8010b1:	eb 02                	jmp    8010b5 <fork+0x193>
  8010b3:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8010b5:	89 d0                	mov    %edx,%eax
  8010b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ba:	5b                   	pop    %ebx
  8010bb:	5e                   	pop    %esi
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <sfork>:

// Challenge!
int
sfork(void)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c5:	68 4b 31 80 00       	push   $0x80314b
  8010ca:	68 c9 00 00 00       	push   $0xc9
  8010cf:	68 40 31 80 00       	push   $0x803140
  8010d4:	e8 ff f0 ff ff       	call   8001d8 <_panic>

008010d9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010df:	05 00 00 00 30       	add    $0x30000000,%eax
  8010e4:	c1 e8 0c             	shr    $0xc,%eax
}
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801106:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80110b:	89 c2                	mov    %eax,%edx
  80110d:	c1 ea 16             	shr    $0x16,%edx
  801110:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801117:	f6 c2 01             	test   $0x1,%dl
  80111a:	74 11                	je     80112d <fd_alloc+0x2d>
  80111c:	89 c2                	mov    %eax,%edx
  80111e:	c1 ea 0c             	shr    $0xc,%edx
  801121:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801128:	f6 c2 01             	test   $0x1,%dl
  80112b:	75 09                	jne    801136 <fd_alloc+0x36>
			*fd_store = fd;
  80112d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80112f:	b8 00 00 00 00       	mov    $0x0,%eax
  801134:	eb 17                	jmp    80114d <fd_alloc+0x4d>
  801136:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80113b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801140:	75 c9                	jne    80110b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801142:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801148:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801155:	83 f8 1f             	cmp    $0x1f,%eax
  801158:	77 36                	ja     801190 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80115a:	c1 e0 0c             	shl    $0xc,%eax
  80115d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801162:	89 c2                	mov    %eax,%edx
  801164:	c1 ea 16             	shr    $0x16,%edx
  801167:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80116e:	f6 c2 01             	test   $0x1,%dl
  801171:	74 24                	je     801197 <fd_lookup+0x48>
  801173:	89 c2                	mov    %eax,%edx
  801175:	c1 ea 0c             	shr    $0xc,%edx
  801178:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117f:	f6 c2 01             	test   $0x1,%dl
  801182:	74 1a                	je     80119e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801184:	8b 55 0c             	mov    0xc(%ebp),%edx
  801187:	89 02                	mov    %eax,(%edx)
	return 0;
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
  80118e:	eb 13                	jmp    8011a3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801190:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801195:	eb 0c                	jmp    8011a3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801197:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80119c:	eb 05                	jmp    8011a3 <fd_lookup+0x54>
  80119e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ae:	ba e0 31 80 00       	mov    $0x8031e0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011b3:	eb 13                	jmp    8011c8 <dev_lookup+0x23>
  8011b5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011b8:	39 08                	cmp    %ecx,(%eax)
  8011ba:	75 0c                	jne    8011c8 <dev_lookup+0x23>
			*dev = devtab[i];
  8011bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c6:	eb 2e                	jmp    8011f6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011c8:	8b 02                	mov    (%edx),%eax
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	75 e7                	jne    8011b5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ce:	a1 08 50 80 00       	mov    0x805008,%eax
  8011d3:	8b 40 48             	mov    0x48(%eax),%eax
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	51                   	push   %ecx
  8011da:	50                   	push   %eax
  8011db:	68 64 31 80 00       	push   $0x803164
  8011e0:	e8 cc f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  8011e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 10             	sub    $0x10,%esp
  801200:	8b 75 08             	mov    0x8(%ebp),%esi
  801203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801206:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801209:	50                   	push   %eax
  80120a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801210:	c1 e8 0c             	shr    $0xc,%eax
  801213:	50                   	push   %eax
  801214:	e8 36 ff ff ff       	call   80114f <fd_lookup>
  801219:	83 c4 08             	add    $0x8,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 05                	js     801225 <fd_close+0x2d>
	    || fd != fd2)
  801220:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801223:	74 0c                	je     801231 <fd_close+0x39>
		return (must_exist ? r : 0);
  801225:	84 db                	test   %bl,%bl
  801227:	ba 00 00 00 00       	mov    $0x0,%edx
  80122c:	0f 44 c2             	cmove  %edx,%eax
  80122f:	eb 41                	jmp    801272 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	ff 36                	pushl  (%esi)
  80123a:	e8 66 ff ff ff       	call   8011a5 <dev_lookup>
  80123f:	89 c3                	mov    %eax,%ebx
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 1a                	js     801262 <fd_close+0x6a>
		if (dev->dev_close)
  801248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80124e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801253:	85 c0                	test   %eax,%eax
  801255:	74 0b                	je     801262 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801257:	83 ec 0c             	sub    $0xc,%esp
  80125a:	56                   	push   %esi
  80125b:	ff d0                	call   *%eax
  80125d:	89 c3                	mov    %eax,%ebx
  80125f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	56                   	push   %esi
  801266:	6a 00                	push   $0x0
  801268:	e8 51 fa ff ff       	call   800cbe <sys_page_unmap>
	return r;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	89 d8                	mov    %ebx,%eax
}
  801272:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801275:	5b                   	pop    %ebx
  801276:	5e                   	pop    %esi
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80127f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	ff 75 08             	pushl  0x8(%ebp)
  801286:	e8 c4 fe ff ff       	call   80114f <fd_lookup>
  80128b:	83 c4 08             	add    $0x8,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 10                	js     8012a2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	6a 01                	push   $0x1
  801297:	ff 75 f4             	pushl  -0xc(%ebp)
  80129a:	e8 59 ff ff ff       	call   8011f8 <fd_close>
  80129f:	83 c4 10             	add    $0x10,%esp
}
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <close_all>:

void
close_all(void)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ab:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012b0:	83 ec 0c             	sub    $0xc,%esp
  8012b3:	53                   	push   %ebx
  8012b4:	e8 c0 ff ff ff       	call   801279 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b9:	83 c3 01             	add    $0x1,%ebx
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	83 fb 20             	cmp    $0x20,%ebx
  8012c2:	75 ec                	jne    8012b0 <close_all+0xc>
		close(i);
}
  8012c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    

008012c9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 2c             	sub    $0x2c,%esp
  8012d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 6e fe ff ff       	call   80114f <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	0f 88 c1 00 00 00    	js     8013ad <dup+0xe4>
		return r;
	close(newfdnum);
  8012ec:	83 ec 0c             	sub    $0xc,%esp
  8012ef:	56                   	push   %esi
  8012f0:	e8 84 ff ff ff       	call   801279 <close>

	newfd = INDEX2FD(newfdnum);
  8012f5:	89 f3                	mov    %esi,%ebx
  8012f7:	c1 e3 0c             	shl    $0xc,%ebx
  8012fa:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801300:	83 c4 04             	add    $0x4,%esp
  801303:	ff 75 e4             	pushl  -0x1c(%ebp)
  801306:	e8 de fd ff ff       	call   8010e9 <fd2data>
  80130b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80130d:	89 1c 24             	mov    %ebx,(%esp)
  801310:	e8 d4 fd ff ff       	call   8010e9 <fd2data>
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80131b:	89 f8                	mov    %edi,%eax
  80131d:	c1 e8 16             	shr    $0x16,%eax
  801320:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801327:	a8 01                	test   $0x1,%al
  801329:	74 37                	je     801362 <dup+0x99>
  80132b:	89 f8                	mov    %edi,%eax
  80132d:	c1 e8 0c             	shr    $0xc,%eax
  801330:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801337:	f6 c2 01             	test   $0x1,%dl
  80133a:	74 26                	je     801362 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80133c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801343:	83 ec 0c             	sub    $0xc,%esp
  801346:	25 07 0e 00 00       	and    $0xe07,%eax
  80134b:	50                   	push   %eax
  80134c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80134f:	6a 00                	push   $0x0
  801351:	57                   	push   %edi
  801352:	6a 00                	push   $0x0
  801354:	e8 23 f9 ff ff       	call   800c7c <sys_page_map>
  801359:	89 c7                	mov    %eax,%edi
  80135b:	83 c4 20             	add    $0x20,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 2e                	js     801390 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801362:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801365:	89 d0                	mov    %edx,%eax
  801367:	c1 e8 0c             	shr    $0xc,%eax
  80136a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	25 07 0e 00 00       	and    $0xe07,%eax
  801379:	50                   	push   %eax
  80137a:	53                   	push   %ebx
  80137b:	6a 00                	push   $0x0
  80137d:	52                   	push   %edx
  80137e:	6a 00                	push   $0x0
  801380:	e8 f7 f8 ff ff       	call   800c7c <sys_page_map>
  801385:	89 c7                	mov    %eax,%edi
  801387:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80138a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80138c:	85 ff                	test   %edi,%edi
  80138e:	79 1d                	jns    8013ad <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	53                   	push   %ebx
  801394:	6a 00                	push   $0x0
  801396:	e8 23 f9 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80139b:	83 c4 08             	add    $0x8,%esp
  80139e:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013a1:	6a 00                	push   $0x0
  8013a3:	e8 16 f9 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	89 f8                	mov    %edi,%eax
}
  8013ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 14             	sub    $0x14,%esp
  8013bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	53                   	push   %ebx
  8013c4:	e8 86 fd ff ff       	call   80114f <fd_lookup>
  8013c9:	83 c4 08             	add    $0x8,%esp
  8013cc:	89 c2                	mov    %eax,%edx
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 6d                	js     80143f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dc:	ff 30                	pushl  (%eax)
  8013de:	e8 c2 fd ff ff       	call   8011a5 <dev_lookup>
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 4c                	js     801436 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013ed:	8b 42 08             	mov    0x8(%edx),%eax
  8013f0:	83 e0 03             	and    $0x3,%eax
  8013f3:	83 f8 01             	cmp    $0x1,%eax
  8013f6:	75 21                	jne    801419 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f8:	a1 08 50 80 00       	mov    0x805008,%eax
  8013fd:	8b 40 48             	mov    0x48(%eax),%eax
  801400:	83 ec 04             	sub    $0x4,%esp
  801403:	53                   	push   %ebx
  801404:	50                   	push   %eax
  801405:	68 a5 31 80 00       	push   $0x8031a5
  80140a:	e8 a2 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801417:	eb 26                	jmp    80143f <read+0x8a>
	}
	if (!dev->dev_read)
  801419:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141c:	8b 40 08             	mov    0x8(%eax),%eax
  80141f:	85 c0                	test   %eax,%eax
  801421:	74 17                	je     80143a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801423:	83 ec 04             	sub    $0x4,%esp
  801426:	ff 75 10             	pushl  0x10(%ebp)
  801429:	ff 75 0c             	pushl  0xc(%ebp)
  80142c:	52                   	push   %edx
  80142d:	ff d0                	call   *%eax
  80142f:	89 c2                	mov    %eax,%edx
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	eb 09                	jmp    80143f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801436:	89 c2                	mov    %eax,%edx
  801438:	eb 05                	jmp    80143f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80143a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80143f:	89 d0                	mov    %edx,%eax
  801441:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801444:	c9                   	leave  
  801445:	c3                   	ret    

00801446 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	57                   	push   %edi
  80144a:	56                   	push   %esi
  80144b:	53                   	push   %ebx
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801452:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801455:	bb 00 00 00 00       	mov    $0x0,%ebx
  80145a:	eb 21                	jmp    80147d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80145c:	83 ec 04             	sub    $0x4,%esp
  80145f:	89 f0                	mov    %esi,%eax
  801461:	29 d8                	sub    %ebx,%eax
  801463:	50                   	push   %eax
  801464:	89 d8                	mov    %ebx,%eax
  801466:	03 45 0c             	add    0xc(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	57                   	push   %edi
  80146b:	e8 45 ff ff ff       	call   8013b5 <read>
		if (m < 0)
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 10                	js     801487 <readn+0x41>
			return m;
		if (m == 0)
  801477:	85 c0                	test   %eax,%eax
  801479:	74 0a                	je     801485 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80147b:	01 c3                	add    %eax,%ebx
  80147d:	39 f3                	cmp    %esi,%ebx
  80147f:	72 db                	jb     80145c <readn+0x16>
  801481:	89 d8                	mov    %ebx,%eax
  801483:	eb 02                	jmp    801487 <readn+0x41>
  801485:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801487:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148a:	5b                   	pop    %ebx
  80148b:	5e                   	pop    %esi
  80148c:	5f                   	pop    %edi
  80148d:	5d                   	pop    %ebp
  80148e:	c3                   	ret    

0080148f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	53                   	push   %ebx
  801493:	83 ec 14             	sub    $0x14,%esp
  801496:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801499:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	53                   	push   %ebx
  80149e:	e8 ac fc ff ff       	call   80114f <fd_lookup>
  8014a3:	83 c4 08             	add    $0x8,%esp
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 68                	js     801514 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b2:	50                   	push   %eax
  8014b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b6:	ff 30                	pushl  (%eax)
  8014b8:	e8 e8 fc ff ff       	call   8011a5 <dev_lookup>
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 47                	js     80150b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014cb:	75 21                	jne    8014ee <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8014d2:	8b 40 48             	mov    0x48(%eax),%eax
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	53                   	push   %ebx
  8014d9:	50                   	push   %eax
  8014da:	68 c1 31 80 00       	push   $0x8031c1
  8014df:	e8 cd ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ec:	eb 26                	jmp    801514 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8014f4:	85 d2                	test   %edx,%edx
  8014f6:	74 17                	je     80150f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	ff 75 10             	pushl  0x10(%ebp)
  8014fe:	ff 75 0c             	pushl  0xc(%ebp)
  801501:	50                   	push   %eax
  801502:	ff d2                	call   *%edx
  801504:	89 c2                	mov    %eax,%edx
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	eb 09                	jmp    801514 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	eb 05                	jmp    801514 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80150f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801514:	89 d0                	mov    %edx,%eax
  801516:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <seek>:

int
seek(int fdnum, off_t offset)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801521:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	ff 75 08             	pushl  0x8(%ebp)
  801528:	e8 22 fc ff ff       	call   80114f <fd_lookup>
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 0e                	js     801542 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801534:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801537:	8b 55 0c             	mov    0xc(%ebp),%edx
  80153a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80153d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	53                   	push   %ebx
  801548:	83 ec 14             	sub    $0x14,%esp
  80154b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	53                   	push   %ebx
  801553:	e8 f7 fb ff ff       	call   80114f <fd_lookup>
  801558:	83 c4 08             	add    $0x8,%esp
  80155b:	89 c2                	mov    %eax,%edx
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 65                	js     8015c6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801567:	50                   	push   %eax
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	ff 30                	pushl  (%eax)
  80156d:	e8 33 fc ff ff       	call   8011a5 <dev_lookup>
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	85 c0                	test   %eax,%eax
  801577:	78 44                	js     8015bd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801579:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801580:	75 21                	jne    8015a3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801582:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801587:	8b 40 48             	mov    0x48(%eax),%eax
  80158a:	83 ec 04             	sub    $0x4,%esp
  80158d:	53                   	push   %ebx
  80158e:	50                   	push   %eax
  80158f:	68 84 31 80 00       	push   $0x803184
  801594:	e8 18 ed ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a1:	eb 23                	jmp    8015c6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a6:	8b 52 18             	mov    0x18(%edx),%edx
  8015a9:	85 d2                	test   %edx,%edx
  8015ab:	74 14                	je     8015c1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	ff 75 0c             	pushl  0xc(%ebp)
  8015b3:	50                   	push   %eax
  8015b4:	ff d2                	call   *%edx
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	eb 09                	jmp    8015c6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	eb 05                	jmp    8015c6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015c6:	89 d0                	mov    %edx,%eax
  8015c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 14             	sub    $0x14,%esp
  8015d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	ff 75 08             	pushl  0x8(%ebp)
  8015de:	e8 6c fb ff ff       	call   80114f <fd_lookup>
  8015e3:	83 c4 08             	add    $0x8,%esp
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 58                	js     801644 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f2:	50                   	push   %eax
  8015f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f6:	ff 30                	pushl  (%eax)
  8015f8:	e8 a8 fb ff ff       	call   8011a5 <dev_lookup>
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	78 37                	js     80163b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801604:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801607:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80160b:	74 32                	je     80163f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80160d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801610:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801617:	00 00 00 
	stat->st_isdir = 0;
  80161a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801621:	00 00 00 
	stat->st_dev = dev;
  801624:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	53                   	push   %ebx
  80162e:	ff 75 f0             	pushl  -0x10(%ebp)
  801631:	ff 50 14             	call   *0x14(%eax)
  801634:	89 c2                	mov    %eax,%edx
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	eb 09                	jmp    801644 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163b:	89 c2                	mov    %eax,%edx
  80163d:	eb 05                	jmp    801644 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80163f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801644:	89 d0                	mov    %edx,%eax
  801646:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	56                   	push   %esi
  80164f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	6a 00                	push   $0x0
  801655:	ff 75 08             	pushl  0x8(%ebp)
  801658:	e8 d6 01 00 00       	call   801833 <open>
  80165d:	89 c3                	mov    %eax,%ebx
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	78 1b                	js     801681 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	ff 75 0c             	pushl  0xc(%ebp)
  80166c:	50                   	push   %eax
  80166d:	e8 5b ff ff ff       	call   8015cd <fstat>
  801672:	89 c6                	mov    %eax,%esi
	close(fd);
  801674:	89 1c 24             	mov    %ebx,(%esp)
  801677:	e8 fd fb ff ff       	call   801279 <close>
	return r;
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	89 f0                	mov    %esi,%eax
}
  801681:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801684:	5b                   	pop    %ebx
  801685:	5e                   	pop    %esi
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    

00801688 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
  80168d:	89 c6                	mov    %eax,%esi
  80168f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801691:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801698:	75 12                	jne    8016ac <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80169a:	83 ec 0c             	sub    $0xc,%esp
  80169d:	6a 01                	push   $0x1
  80169f:	e8 de 12 00 00       	call   802982 <ipc_find_env>
  8016a4:	a3 00 50 80 00       	mov    %eax,0x805000
  8016a9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ac:	6a 07                	push   $0x7
  8016ae:	68 00 60 80 00       	push   $0x806000
  8016b3:	56                   	push   %esi
  8016b4:	ff 35 00 50 80 00    	pushl  0x805000
  8016ba:	e8 6f 12 00 00       	call   80292e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016bf:	83 c4 0c             	add    $0xc,%esp
  8016c2:	6a 00                	push   $0x0
  8016c4:	53                   	push   %ebx
  8016c5:	6a 00                	push   $0x0
  8016c7:	e8 fb 11 00 00       	call   8028c7 <ipc_recv>
}
  8016cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5e                   	pop    %esi
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016df:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8016e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e7:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f1:	b8 02 00 00 00       	mov    $0x2,%eax
  8016f6:	e8 8d ff ff ff       	call   801688 <fsipc>
}
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    

008016fd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	8b 40 0c             	mov    0xc(%eax),%eax
  801709:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80170e:	ba 00 00 00 00       	mov    $0x0,%edx
  801713:	b8 06 00 00 00       	mov    $0x6,%eax
  801718:	e8 6b ff ff ff       	call   801688 <fsipc>
}
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	53                   	push   %ebx
  801723:	83 ec 04             	sub    $0x4,%esp
  801726:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	8b 40 0c             	mov    0xc(%eax),%eax
  80172f:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
  801739:	b8 05 00 00 00       	mov    $0x5,%eax
  80173e:	e8 45 ff ff ff       	call   801688 <fsipc>
  801743:	85 c0                	test   %eax,%eax
  801745:	78 2c                	js     801773 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801747:	83 ec 08             	sub    $0x8,%esp
  80174a:	68 00 60 80 00       	push   $0x806000
  80174f:	53                   	push   %ebx
  801750:	e8 e1 f0 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801755:	a1 80 60 80 00       	mov    0x806080,%eax
  80175a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801760:	a1 84 60 80 00       	mov    0x806084,%eax
  801765:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	83 ec 0c             	sub    $0xc,%esp
  80177e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801781:	8b 55 08             	mov    0x8(%ebp),%edx
  801784:	8b 52 0c             	mov    0xc(%edx),%edx
  801787:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  80178d:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801792:	50                   	push   %eax
  801793:	ff 75 0c             	pushl  0xc(%ebp)
  801796:	68 08 60 80 00       	push   $0x806008
  80179b:	e8 28 f2 ff ff       	call   8009c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a5:	b8 04 00 00 00       	mov    $0x4,%eax
  8017aa:	e8 d9 fe ff ff       	call   801688 <fsipc>

}
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bf:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8017c4:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d4:	e8 af fe ff ff       	call   801688 <fsipc>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 4b                	js     80182a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017df:	39 c6                	cmp    %eax,%esi
  8017e1:	73 16                	jae    8017f9 <devfile_read+0x48>
  8017e3:	68 f4 31 80 00       	push   $0x8031f4
  8017e8:	68 fb 31 80 00       	push   $0x8031fb
  8017ed:	6a 7c                	push   $0x7c
  8017ef:	68 10 32 80 00       	push   $0x803210
  8017f4:	e8 df e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  8017f9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017fe:	7e 16                	jle    801816 <devfile_read+0x65>
  801800:	68 1b 32 80 00       	push   $0x80321b
  801805:	68 fb 31 80 00       	push   $0x8031fb
  80180a:	6a 7d                	push   $0x7d
  80180c:	68 10 32 80 00       	push   $0x803210
  801811:	e8 c2 e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801816:	83 ec 04             	sub    $0x4,%esp
  801819:	50                   	push   %eax
  80181a:	68 00 60 80 00       	push   $0x806000
  80181f:	ff 75 0c             	pushl  0xc(%ebp)
  801822:	e8 a1 f1 ff ff       	call   8009c8 <memmove>
	return r;
  801827:	83 c4 10             	add    $0x10,%esp
}
  80182a:	89 d8                	mov    %ebx,%eax
  80182c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	53                   	push   %ebx
  801837:	83 ec 20             	sub    $0x20,%esp
  80183a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80183d:	53                   	push   %ebx
  80183e:	e8 ba ef ff ff       	call   8007fd <strlen>
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80184b:	7f 67                	jg     8018b4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80184d:	83 ec 0c             	sub    $0xc,%esp
  801850:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801853:	50                   	push   %eax
  801854:	e8 a7 f8 ff ff       	call   801100 <fd_alloc>
  801859:	83 c4 10             	add    $0x10,%esp
		return r;
  80185c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 57                	js     8018b9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	53                   	push   %ebx
  801866:	68 00 60 80 00       	push   $0x806000
  80186b:	e8 c6 ef ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801870:	8b 45 0c             	mov    0xc(%ebp),%eax
  801873:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801878:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187b:	b8 01 00 00 00       	mov    $0x1,%eax
  801880:	e8 03 fe ff ff       	call   801688 <fsipc>
  801885:	89 c3                	mov    %eax,%ebx
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	85 c0                	test   %eax,%eax
  80188c:	79 14                	jns    8018a2 <open+0x6f>
		fd_close(fd, 0);
  80188e:	83 ec 08             	sub    $0x8,%esp
  801891:	6a 00                	push   $0x0
  801893:	ff 75 f4             	pushl  -0xc(%ebp)
  801896:	e8 5d f9 ff ff       	call   8011f8 <fd_close>
		return r;
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	89 da                	mov    %ebx,%edx
  8018a0:	eb 17                	jmp    8018b9 <open+0x86>
	}

	return fd2num(fd);
  8018a2:	83 ec 0c             	sub    $0xc,%esp
  8018a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a8:	e8 2c f8 ff ff       	call   8010d9 <fd2num>
  8018ad:	89 c2                	mov    %eax,%edx
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	eb 05                	jmp    8018b9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018b9:	89 d0                	mov    %edx,%eax
  8018bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d0:	e8 b3 fd ff ff       	call   801688 <fsipc>
}
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	57                   	push   %edi
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018e3:	6a 00                	push   $0x0
  8018e5:	ff 75 08             	pushl  0x8(%ebp)
  8018e8:	e8 46 ff ff ff       	call   801833 <open>
  8018ed:	89 c7                	mov    %eax,%edi
  8018ef:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	0f 88 97 04 00 00    	js     801d97 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	68 00 02 00 00       	push   $0x200
  801908:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80190e:	50                   	push   %eax
  80190f:	57                   	push   %edi
  801910:	e8 31 fb ff ff       	call   801446 <readn>
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	3d 00 02 00 00       	cmp    $0x200,%eax
  80191d:	75 0c                	jne    80192b <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80191f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801926:	45 4c 46 
  801929:	74 33                	je     80195e <spawn+0x87>
		close(fd);
  80192b:	83 ec 0c             	sub    $0xc,%esp
  80192e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801934:	e8 40 f9 ff ff       	call   801279 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801939:	83 c4 0c             	add    $0xc,%esp
  80193c:	68 7f 45 4c 46       	push   $0x464c457f
  801941:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801947:	68 27 32 80 00       	push   $0x803227
  80194c:	e8 60 e9 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801959:	e9 ec 04 00 00       	jmp    801e4a <spawn+0x573>
  80195e:	b8 07 00 00 00       	mov    $0x7,%eax
  801963:	cd 30                	int    $0x30
  801965:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80196b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801971:	85 c0                	test   %eax,%eax
  801973:	0f 88 29 04 00 00    	js     801da2 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801979:	89 c6                	mov    %eax,%esi
  80197b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801981:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801984:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80198a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801990:	b9 11 00 00 00       	mov    $0x11,%ecx
  801995:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801997:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80199d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019a3:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019a8:	be 00 00 00 00       	mov    $0x0,%esi
  8019ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019b0:	eb 13                	jmp    8019c5 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	50                   	push   %eax
  8019b6:	e8 42 ee ff ff       	call   8007fd <strlen>
  8019bb:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019bf:	83 c3 01             	add    $0x1,%ebx
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019cc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	75 df                	jne    8019b2 <spawn+0xdb>
  8019d3:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019d9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019df:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019e4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019e6:	89 fa                	mov    %edi,%edx
  8019e8:	83 e2 fc             	and    $0xfffffffc,%edx
  8019eb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019f2:	29 c2                	sub    %eax,%edx
  8019f4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019fa:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019fd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a02:	0f 86 b0 03 00 00    	jbe    801db8 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a08:	83 ec 04             	sub    $0x4,%esp
  801a0b:	6a 07                	push   $0x7
  801a0d:	68 00 00 40 00       	push   $0x400000
  801a12:	6a 00                	push   $0x0
  801a14:	e8 20 f2 ff ff       	call   800c39 <sys_page_alloc>
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	0f 88 9e 03 00 00    	js     801dc2 <spawn+0x4eb>
  801a24:	be 00 00 00 00       	mov    $0x0,%esi
  801a29:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a32:	eb 30                	jmp    801a64 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a34:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a3a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a40:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a43:	83 ec 08             	sub    $0x8,%esp
  801a46:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a49:	57                   	push   %edi
  801a4a:	e8 e7 ed ff ff       	call   800836 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a4f:	83 c4 04             	add    $0x4,%esp
  801a52:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a55:	e8 a3 ed ff ff       	call   8007fd <strlen>
  801a5a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a5e:	83 c6 01             	add    $0x1,%esi
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a6a:	7f c8                	jg     801a34 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a6c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a72:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801a78:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a7f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a85:	74 19                	je     801aa0 <spawn+0x1c9>
  801a87:	68 b4 32 80 00       	push   $0x8032b4
  801a8c:	68 fb 31 80 00       	push   $0x8031fb
  801a91:	68 f2 00 00 00       	push   $0xf2
  801a96:	68 41 32 80 00       	push   $0x803241
  801a9b:	e8 38 e7 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801aa0:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801aa6:	89 f8                	mov    %edi,%eax
  801aa8:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801aad:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801ab0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ab6:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ab9:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801abf:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ac5:	83 ec 0c             	sub    $0xc,%esp
  801ac8:	6a 07                	push   $0x7
  801aca:	68 00 d0 bf ee       	push   $0xeebfd000
  801acf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ad5:	68 00 00 40 00       	push   $0x400000
  801ada:	6a 00                	push   $0x0
  801adc:	e8 9b f1 ff ff       	call   800c7c <sys_page_map>
  801ae1:	89 c3                	mov    %eax,%ebx
  801ae3:	83 c4 20             	add    $0x20,%esp
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	0f 88 4a 03 00 00    	js     801e38 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	68 00 00 40 00       	push   $0x400000
  801af6:	6a 00                	push   $0x0
  801af8:	e8 c1 f1 ff ff       	call   800cbe <sys_page_unmap>
  801afd:	89 c3                	mov    %eax,%ebx
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	85 c0                	test   %eax,%eax
  801b04:	0f 88 2e 03 00 00    	js     801e38 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b0a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b10:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b17:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b1d:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b24:	00 00 00 
  801b27:	e9 8a 01 00 00       	jmp    801cb6 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801b2c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b32:	83 38 01             	cmpl   $0x1,(%eax)
  801b35:	0f 85 6d 01 00 00    	jne    801ca8 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b3b:	89 c7                	mov    %eax,%edi
  801b3d:	8b 40 18             	mov    0x18(%eax),%eax
  801b40:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b46:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b49:	83 f8 01             	cmp    $0x1,%eax
  801b4c:	19 c0                	sbb    %eax,%eax
  801b4e:	83 e0 fe             	and    $0xfffffffe,%eax
  801b51:	83 c0 07             	add    $0x7,%eax
  801b54:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b5a:	89 f8                	mov    %edi,%eax
  801b5c:	8b 7f 04             	mov    0x4(%edi),%edi
  801b5f:	89 f9                	mov    %edi,%ecx
  801b61:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b67:	8b 78 10             	mov    0x10(%eax),%edi
  801b6a:	8b 70 14             	mov    0x14(%eax),%esi
  801b6d:	89 f3                	mov    %esi,%ebx
  801b6f:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b75:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b78:	89 f0                	mov    %esi,%eax
  801b7a:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b7f:	74 14                	je     801b95 <spawn+0x2be>
		va -= i;
  801b81:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b83:	01 c3                	add    %eax,%ebx
  801b85:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801b8b:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b8d:	29 c1                	sub    %eax,%ecx
  801b8f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b95:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b9a:	e9 f7 00 00 00       	jmp    801c96 <spawn+0x3bf>
		if (i >= filesz) {
  801b9f:	39 df                	cmp    %ebx,%edi
  801ba1:	77 27                	ja     801bca <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ba3:	83 ec 04             	sub    $0x4,%esp
  801ba6:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bac:	56                   	push   %esi
  801bad:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bb3:	e8 81 f0 ff ff       	call   800c39 <sys_page_alloc>
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	0f 89 c7 00 00 00    	jns    801c8a <spawn+0x3b3>
  801bc3:	89 c3                	mov    %eax,%ebx
  801bc5:	e9 09 02 00 00       	jmp    801dd3 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bca:	83 ec 04             	sub    $0x4,%esp
  801bcd:	6a 07                	push   $0x7
  801bcf:	68 00 00 40 00       	push   $0x400000
  801bd4:	6a 00                	push   $0x0
  801bd6:	e8 5e f0 ff ff       	call   800c39 <sys_page_alloc>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	85 c0                	test   %eax,%eax
  801be0:	0f 88 e3 01 00 00    	js     801dc9 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801be6:	83 ec 08             	sub    $0x8,%esp
  801be9:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bef:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bf5:	50                   	push   %eax
  801bf6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bfc:	e8 1a f9 ff ff       	call   80151b <seek>
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 c1 01 00 00    	js     801dcd <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c17:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c1c:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c21:	0f 47 c1             	cmova  %ecx,%eax
  801c24:	50                   	push   %eax
  801c25:	68 00 00 40 00       	push   $0x400000
  801c2a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c30:	e8 11 f8 ff ff       	call   801446 <readn>
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	0f 88 91 01 00 00    	js     801dd1 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c49:	56                   	push   %esi
  801c4a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c50:	68 00 00 40 00       	push   $0x400000
  801c55:	6a 00                	push   $0x0
  801c57:	e8 20 f0 ff ff       	call   800c7c <sys_page_map>
  801c5c:	83 c4 20             	add    $0x20,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	79 15                	jns    801c78 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801c63:	50                   	push   %eax
  801c64:	68 4d 32 80 00       	push   $0x80324d
  801c69:	68 25 01 00 00       	push   $0x125
  801c6e:	68 41 32 80 00       	push   $0x803241
  801c73:	e8 60 e5 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801c78:	83 ec 08             	sub    $0x8,%esp
  801c7b:	68 00 00 40 00       	push   $0x400000
  801c80:	6a 00                	push   $0x0
  801c82:	e8 37 f0 ff ff       	call   800cbe <sys_page_unmap>
  801c87:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c8a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c90:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c96:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c9c:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801ca2:	0f 87 f7 fe ff ff    	ja     801b9f <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ca8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801caf:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801cb6:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cbd:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801cc3:	0f 8c 63 fe ff ff    	jl     801b2c <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801cc9:	83 ec 0c             	sub    $0xc,%esp
  801ccc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cd2:	e8 a2 f5 ff ff       	call   801279 <close>
  801cd7:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801cda:	bb 00 08 00 00       	mov    $0x800,%ebx
  801cdf:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  801ce5:	89 d8                	mov    %ebx,%eax
  801ce7:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801cea:	89 c2                	mov    %eax,%edx
  801cec:	c1 ea 16             	shr    $0x16,%edx
  801cef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cf6:	f6 c2 01             	test   $0x1,%dl
  801cf9:	74 4b                	je     801d46 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801cfb:	89 c2                	mov    %eax,%edx
  801cfd:	c1 ea 0c             	shr    $0xc,%edx
  801d00:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801d07:	f6 c1 01             	test   $0x1,%cl
  801d0a:	74 3a                	je     801d46 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801d0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d13:	f6 c6 04             	test   $0x4,%dh
  801d16:	74 2e                	je     801d46 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801d18:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801d1f:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  801d25:	8b 49 48             	mov    0x48(%ecx),%ecx
  801d28:	83 ec 0c             	sub    $0xc,%esp
  801d2b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d31:	52                   	push   %edx
  801d32:	50                   	push   %eax
  801d33:	56                   	push   %esi
  801d34:	50                   	push   %eax
  801d35:	51                   	push   %ecx
  801d36:	e8 41 ef ff ff       	call   800c7c <sys_page_map>
					if (r < 0)
  801d3b:	83 c4 20             	add    $0x20,%esp
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	0f 88 ae 00 00 00    	js     801df4 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801d46:	83 c3 01             	add    $0x1,%ebx
  801d49:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801d4f:	75 94                	jne    801ce5 <spawn+0x40e>
  801d51:	e9 b3 00 00 00       	jmp    801e09 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d56:	50                   	push   %eax
  801d57:	68 6a 32 80 00       	push   $0x80326a
  801d5c:	68 86 00 00 00       	push   $0x86
  801d61:	68 41 32 80 00       	push   $0x803241
  801d66:	e8 6d e4 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d6b:	83 ec 08             	sub    $0x8,%esp
  801d6e:	6a 02                	push   $0x2
  801d70:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d76:	e8 85 ef ff ff       	call   800d00 <sys_env_set_status>
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	79 2b                	jns    801dad <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801d82:	50                   	push   %eax
  801d83:	68 84 32 80 00       	push   $0x803284
  801d88:	68 89 00 00 00       	push   $0x89
  801d8d:	68 41 32 80 00       	push   $0x803241
  801d92:	e8 41 e4 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d97:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d9d:	e9 a8 00 00 00       	jmp    801e4a <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801da2:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801da8:	e9 9d 00 00 00       	jmp    801e4a <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801dad:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801db3:	e9 92 00 00 00       	jmp    801e4a <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801db8:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801dbd:	e9 88 00 00 00       	jmp    801e4a <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801dc2:	89 c3                	mov    %eax,%ebx
  801dc4:	e9 81 00 00 00       	jmp    801e4a <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dc9:	89 c3                	mov    %eax,%ebx
  801dcb:	eb 06                	jmp    801dd3 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801dcd:	89 c3                	mov    %eax,%ebx
  801dcf:	eb 02                	jmp    801dd3 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801dd1:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801dd3:	83 ec 0c             	sub    $0xc,%esp
  801dd6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ddc:	e8 d9 ed ff ff       	call   800bba <sys_env_destroy>
	close(fd);
  801de1:	83 c4 04             	add    $0x4,%esp
  801de4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dea:	e8 8a f4 ff ff       	call   801279 <close>
	return r;
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	eb 56                	jmp    801e4a <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801df4:	50                   	push   %eax
  801df5:	68 9b 32 80 00       	push   $0x80329b
  801dfa:	68 82 00 00 00       	push   $0x82
  801dff:	68 41 32 80 00       	push   $0x803241
  801e04:	e8 cf e3 ff ff       	call   8001d8 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e09:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e10:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e13:	83 ec 08             	sub    $0x8,%esp
  801e16:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e1c:	50                   	push   %eax
  801e1d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e23:	e8 1a ef ff ff       	call   800d42 <sys_env_set_trapframe>
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	0f 89 38 ff ff ff    	jns    801d6b <spawn+0x494>
  801e33:	e9 1e ff ff ff       	jmp    801d56 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e38:	83 ec 08             	sub    $0x8,%esp
  801e3b:	68 00 00 40 00       	push   $0x400000
  801e40:	6a 00                	push   $0x0
  801e42:	e8 77 ee ff ff       	call   800cbe <sys_page_unmap>
  801e47:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e4a:	89 d8                	mov    %ebx,%eax
  801e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	56                   	push   %esi
  801e58:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e59:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e5c:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e61:	eb 03                	jmp    801e66 <spawnl+0x12>
		argc++;
  801e63:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e66:	83 c2 04             	add    $0x4,%edx
  801e69:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e6d:	75 f4                	jne    801e63 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e6f:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e76:	83 e2 f0             	and    $0xfffffff0,%edx
  801e79:	29 d4                	sub    %edx,%esp
  801e7b:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e7f:	c1 ea 02             	shr    $0x2,%edx
  801e82:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e89:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e8e:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e95:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e9c:	00 
  801e9d:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea4:	eb 0a                	jmp    801eb0 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ea6:	83 c0 01             	add    $0x1,%eax
  801ea9:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ead:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801eb0:	39 d0                	cmp    %edx,%eax
  801eb2:	75 f2                	jne    801ea6 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801eb4:	83 ec 08             	sub    $0x8,%esp
  801eb7:	56                   	push   %esi
  801eb8:	ff 75 08             	pushl  0x8(%ebp)
  801ebb:	e8 17 fa ff ff       	call   8018d7 <spawn>
}
  801ec0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec3:	5b                   	pop    %ebx
  801ec4:	5e                   	pop    %esi
  801ec5:	5d                   	pop    %ebp
  801ec6:	c3                   	ret    

00801ec7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ecd:	68 dc 32 80 00       	push   $0x8032dc
  801ed2:	ff 75 0c             	pushl  0xc(%ebp)
  801ed5:	e8 5c e9 ff ff       	call   800836 <strcpy>
	return 0;
}
  801eda:	b8 00 00 00 00       	mov    $0x0,%eax
  801edf:	c9                   	leave  
  801ee0:	c3                   	ret    

00801ee1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	53                   	push   %ebx
  801ee5:	83 ec 10             	sub    $0x10,%esp
  801ee8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801eeb:	53                   	push   %ebx
  801eec:	e8 ca 0a 00 00       	call   8029bb <pageref>
  801ef1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ef4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ef9:	83 f8 01             	cmp    $0x1,%eax
  801efc:	75 10                	jne    801f0e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801efe:	83 ec 0c             	sub    $0xc,%esp
  801f01:	ff 73 0c             	pushl  0xc(%ebx)
  801f04:	e8 c0 02 00 00       	call   8021c9 <nsipc_close>
  801f09:	89 c2                	mov    %eax,%edx
  801f0b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801f0e:	89 d0                	mov    %edx,%eax
  801f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f1b:	6a 00                	push   $0x0
  801f1d:	ff 75 10             	pushl  0x10(%ebp)
  801f20:	ff 75 0c             	pushl  0xc(%ebp)
  801f23:	8b 45 08             	mov    0x8(%ebp),%eax
  801f26:	ff 70 0c             	pushl  0xc(%eax)
  801f29:	e8 78 03 00 00       	call   8022a6 <nsipc_send>
}
  801f2e:	c9                   	leave  
  801f2f:	c3                   	ret    

00801f30 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f36:	6a 00                	push   $0x0
  801f38:	ff 75 10             	pushl  0x10(%ebp)
  801f3b:	ff 75 0c             	pushl  0xc(%ebp)
  801f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f41:	ff 70 0c             	pushl  0xc(%eax)
  801f44:	e8 f1 02 00 00       	call   80223a <nsipc_recv>
}
  801f49:	c9                   	leave  
  801f4a:	c3                   	ret    

00801f4b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f51:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f54:	52                   	push   %edx
  801f55:	50                   	push   %eax
  801f56:	e8 f4 f1 ff ff       	call   80114f <fd_lookup>
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	78 17                	js     801f79 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f65:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  801f6b:	39 08                	cmp    %ecx,(%eax)
  801f6d:	75 05                	jne    801f74 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801f72:	eb 05                	jmp    801f79 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f74:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    

00801f7b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	56                   	push   %esi
  801f7f:	53                   	push   %ebx
  801f80:	83 ec 1c             	sub    $0x1c,%esp
  801f83:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f88:	50                   	push   %eax
  801f89:	e8 72 f1 ff ff       	call   801100 <fd_alloc>
  801f8e:	89 c3                	mov    %eax,%ebx
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	85 c0                	test   %eax,%eax
  801f95:	78 1b                	js     801fb2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f97:	83 ec 04             	sub    $0x4,%esp
  801f9a:	68 07 04 00 00       	push   $0x407
  801f9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa2:	6a 00                	push   $0x0
  801fa4:	e8 90 ec ff ff       	call   800c39 <sys_page_alloc>
  801fa9:	89 c3                	mov    %eax,%ebx
  801fab:	83 c4 10             	add    $0x10,%esp
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	79 10                	jns    801fc2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801fb2:	83 ec 0c             	sub    $0xc,%esp
  801fb5:	56                   	push   %esi
  801fb6:	e8 0e 02 00 00       	call   8021c9 <nsipc_close>
		return r;
  801fbb:	83 c4 10             	add    $0x10,%esp
  801fbe:	89 d8                	mov    %ebx,%eax
  801fc0:	eb 24                	jmp    801fe6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801fc2:	8b 15 28 40 80 00    	mov    0x804028,%edx
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fd7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fda:	83 ec 0c             	sub    $0xc,%esp
  801fdd:	50                   	push   %eax
  801fde:	e8 f6 f0 ff ff       	call   8010d9 <fd2num>
  801fe3:	83 c4 10             	add    $0x10,%esp
}
  801fe6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe9:	5b                   	pop    %ebx
  801fea:	5e                   	pop    %esi
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    

00801fed <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff6:	e8 50 ff ff ff       	call   801f4b <fd2sockid>
		return r;
  801ffb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	78 1f                	js     802020 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802001:	83 ec 04             	sub    $0x4,%esp
  802004:	ff 75 10             	pushl  0x10(%ebp)
  802007:	ff 75 0c             	pushl  0xc(%ebp)
  80200a:	50                   	push   %eax
  80200b:	e8 12 01 00 00       	call   802122 <nsipc_accept>
  802010:	83 c4 10             	add    $0x10,%esp
		return r;
  802013:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802015:	85 c0                	test   %eax,%eax
  802017:	78 07                	js     802020 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802019:	e8 5d ff ff ff       	call   801f7b <alloc_sockfd>
  80201e:	89 c1                	mov    %eax,%ecx
}
  802020:	89 c8                	mov    %ecx,%eax
  802022:	c9                   	leave  
  802023:	c3                   	ret    

00802024 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80202a:	8b 45 08             	mov    0x8(%ebp),%eax
  80202d:	e8 19 ff ff ff       	call   801f4b <fd2sockid>
  802032:	85 c0                	test   %eax,%eax
  802034:	78 12                	js     802048 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802036:	83 ec 04             	sub    $0x4,%esp
  802039:	ff 75 10             	pushl  0x10(%ebp)
  80203c:	ff 75 0c             	pushl  0xc(%ebp)
  80203f:	50                   	push   %eax
  802040:	e8 2d 01 00 00       	call   802172 <nsipc_bind>
  802045:	83 c4 10             	add    $0x10,%esp
}
  802048:	c9                   	leave  
  802049:	c3                   	ret    

0080204a <shutdown>:

int
shutdown(int s, int how)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802050:	8b 45 08             	mov    0x8(%ebp),%eax
  802053:	e8 f3 fe ff ff       	call   801f4b <fd2sockid>
  802058:	85 c0                	test   %eax,%eax
  80205a:	78 0f                	js     80206b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80205c:	83 ec 08             	sub    $0x8,%esp
  80205f:	ff 75 0c             	pushl  0xc(%ebp)
  802062:	50                   	push   %eax
  802063:	e8 3f 01 00 00       	call   8021a7 <nsipc_shutdown>
  802068:	83 c4 10             	add    $0x10,%esp
}
  80206b:	c9                   	leave  
  80206c:	c3                   	ret    

0080206d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802073:	8b 45 08             	mov    0x8(%ebp),%eax
  802076:	e8 d0 fe ff ff       	call   801f4b <fd2sockid>
  80207b:	85 c0                	test   %eax,%eax
  80207d:	78 12                	js     802091 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80207f:	83 ec 04             	sub    $0x4,%esp
  802082:	ff 75 10             	pushl  0x10(%ebp)
  802085:	ff 75 0c             	pushl  0xc(%ebp)
  802088:	50                   	push   %eax
  802089:	e8 55 01 00 00       	call   8021e3 <nsipc_connect>
  80208e:	83 c4 10             	add    $0x10,%esp
}
  802091:	c9                   	leave  
  802092:	c3                   	ret    

00802093 <listen>:

int
listen(int s, int backlog)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802099:	8b 45 08             	mov    0x8(%ebp),%eax
  80209c:	e8 aa fe ff ff       	call   801f4b <fd2sockid>
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	78 0f                	js     8020b4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8020a5:	83 ec 08             	sub    $0x8,%esp
  8020a8:	ff 75 0c             	pushl  0xc(%ebp)
  8020ab:	50                   	push   %eax
  8020ac:	e8 67 01 00 00       	call   802218 <nsipc_listen>
  8020b1:	83 c4 10             	add    $0x10,%esp
}
  8020b4:	c9                   	leave  
  8020b5:	c3                   	ret    

008020b6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020bc:	ff 75 10             	pushl  0x10(%ebp)
  8020bf:	ff 75 0c             	pushl  0xc(%ebp)
  8020c2:	ff 75 08             	pushl  0x8(%ebp)
  8020c5:	e8 3a 02 00 00       	call   802304 <nsipc_socket>
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 05                	js     8020d6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8020d1:	e8 a5 fe ff ff       	call   801f7b <alloc_sockfd>
}
  8020d6:	c9                   	leave  
  8020d7:	c3                   	ret    

008020d8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	53                   	push   %ebx
  8020dc:	83 ec 04             	sub    $0x4,%esp
  8020df:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020e1:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8020e8:	75 12                	jne    8020fc <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8020ea:	83 ec 0c             	sub    $0xc,%esp
  8020ed:	6a 02                	push   $0x2
  8020ef:	e8 8e 08 00 00       	call   802982 <ipc_find_env>
  8020f4:	a3 04 50 80 00       	mov    %eax,0x805004
  8020f9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8020fc:	6a 07                	push   $0x7
  8020fe:	68 00 70 80 00       	push   $0x807000
  802103:	53                   	push   %ebx
  802104:	ff 35 04 50 80 00    	pushl  0x805004
  80210a:	e8 1f 08 00 00       	call   80292e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80210f:	83 c4 0c             	add    $0xc,%esp
  802112:	6a 00                	push   $0x0
  802114:	6a 00                	push   $0x0
  802116:	6a 00                	push   $0x0
  802118:	e8 aa 07 00 00       	call   8028c7 <ipc_recv>
}
  80211d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802120:	c9                   	leave  
  802121:	c3                   	ret    

00802122 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802122:	55                   	push   %ebp
  802123:	89 e5                	mov    %esp,%ebp
  802125:	56                   	push   %esi
  802126:	53                   	push   %ebx
  802127:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80212a:	8b 45 08             	mov    0x8(%ebp),%eax
  80212d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802132:	8b 06                	mov    (%esi),%eax
  802134:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802139:	b8 01 00 00 00       	mov    $0x1,%eax
  80213e:	e8 95 ff ff ff       	call   8020d8 <nsipc>
  802143:	89 c3                	mov    %eax,%ebx
  802145:	85 c0                	test   %eax,%eax
  802147:	78 20                	js     802169 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802149:	83 ec 04             	sub    $0x4,%esp
  80214c:	ff 35 10 70 80 00    	pushl  0x807010
  802152:	68 00 70 80 00       	push   $0x807000
  802157:	ff 75 0c             	pushl  0xc(%ebp)
  80215a:	e8 69 e8 ff ff       	call   8009c8 <memmove>
		*addrlen = ret->ret_addrlen;
  80215f:	a1 10 70 80 00       	mov    0x807010,%eax
  802164:	89 06                	mov    %eax,(%esi)
  802166:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802169:	89 d8                	mov    %ebx,%eax
  80216b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216e:	5b                   	pop    %ebx
  80216f:	5e                   	pop    %esi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    

00802172 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802172:	55                   	push   %ebp
  802173:	89 e5                	mov    %esp,%ebp
  802175:	53                   	push   %ebx
  802176:	83 ec 08             	sub    $0x8,%esp
  802179:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80217c:	8b 45 08             	mov    0x8(%ebp),%eax
  80217f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802184:	53                   	push   %ebx
  802185:	ff 75 0c             	pushl  0xc(%ebp)
  802188:	68 04 70 80 00       	push   $0x807004
  80218d:	e8 36 e8 ff ff       	call   8009c8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802192:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802198:	b8 02 00 00 00       	mov    $0x2,%eax
  80219d:	e8 36 ff ff ff       	call   8020d8 <nsipc>
}
  8021a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021a5:	c9                   	leave  
  8021a6:	c3                   	ret    

008021a7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8021b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b8:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8021bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8021c2:	e8 11 ff ff ff       	call   8020d8 <nsipc>
}
  8021c7:	c9                   	leave  
  8021c8:	c3                   	ret    

008021c9 <nsipc_close>:

int
nsipc_close(int s)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8021d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8021dc:	e8 f7 fe ff ff       	call   8020d8 <nsipc>
}
  8021e1:	c9                   	leave  
  8021e2:	c3                   	ret    

008021e3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021e3:	55                   	push   %ebp
  8021e4:	89 e5                	mov    %esp,%ebp
  8021e6:	53                   	push   %ebx
  8021e7:	83 ec 08             	sub    $0x8,%esp
  8021ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8021ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8021f5:	53                   	push   %ebx
  8021f6:	ff 75 0c             	pushl  0xc(%ebp)
  8021f9:	68 04 70 80 00       	push   $0x807004
  8021fe:	e8 c5 e7 ff ff       	call   8009c8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802203:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802209:	b8 05 00 00 00       	mov    $0x5,%eax
  80220e:	e8 c5 fe ff ff       	call   8020d8 <nsipc>
}
  802213:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802216:	c9                   	leave  
  802217:	c3                   	ret    

00802218 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802218:	55                   	push   %ebp
  802219:	89 e5                	mov    %esp,%ebp
  80221b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80221e:	8b 45 08             	mov    0x8(%ebp),%eax
  802221:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802226:	8b 45 0c             	mov    0xc(%ebp),%eax
  802229:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80222e:	b8 06 00 00 00       	mov    $0x6,%eax
  802233:	e8 a0 fe ff ff       	call   8020d8 <nsipc>
}
  802238:	c9                   	leave  
  802239:	c3                   	ret    

0080223a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80223a:	55                   	push   %ebp
  80223b:	89 e5                	mov    %esp,%ebp
  80223d:	56                   	push   %esi
  80223e:	53                   	push   %ebx
  80223f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802242:	8b 45 08             	mov    0x8(%ebp),%eax
  802245:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80224a:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802250:	8b 45 14             	mov    0x14(%ebp),%eax
  802253:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802258:	b8 07 00 00 00       	mov    $0x7,%eax
  80225d:	e8 76 fe ff ff       	call   8020d8 <nsipc>
  802262:	89 c3                	mov    %eax,%ebx
  802264:	85 c0                	test   %eax,%eax
  802266:	78 35                	js     80229d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802268:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80226d:	7f 04                	jg     802273 <nsipc_recv+0x39>
  80226f:	39 c6                	cmp    %eax,%esi
  802271:	7d 16                	jge    802289 <nsipc_recv+0x4f>
  802273:	68 e8 32 80 00       	push   $0x8032e8
  802278:	68 fb 31 80 00       	push   $0x8031fb
  80227d:	6a 62                	push   $0x62
  80227f:	68 fd 32 80 00       	push   $0x8032fd
  802284:	e8 4f df ff ff       	call   8001d8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802289:	83 ec 04             	sub    $0x4,%esp
  80228c:	50                   	push   %eax
  80228d:	68 00 70 80 00       	push   $0x807000
  802292:	ff 75 0c             	pushl  0xc(%ebp)
  802295:	e8 2e e7 ff ff       	call   8009c8 <memmove>
  80229a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80229d:	89 d8                	mov    %ebx,%eax
  80229f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022a2:	5b                   	pop    %ebx
  8022a3:	5e                   	pop    %esi
  8022a4:	5d                   	pop    %ebp
  8022a5:	c3                   	ret    

008022a6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022a6:	55                   	push   %ebp
  8022a7:	89 e5                	mov    %esp,%ebp
  8022a9:	53                   	push   %ebx
  8022aa:	83 ec 04             	sub    $0x4,%esp
  8022ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b3:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8022b8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022be:	7e 16                	jle    8022d6 <nsipc_send+0x30>
  8022c0:	68 09 33 80 00       	push   $0x803309
  8022c5:	68 fb 31 80 00       	push   $0x8031fb
  8022ca:	6a 6d                	push   $0x6d
  8022cc:	68 fd 32 80 00       	push   $0x8032fd
  8022d1:	e8 02 df ff ff       	call   8001d8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022d6:	83 ec 04             	sub    $0x4,%esp
  8022d9:	53                   	push   %ebx
  8022da:	ff 75 0c             	pushl  0xc(%ebp)
  8022dd:	68 0c 70 80 00       	push   $0x80700c
  8022e2:	e8 e1 e6 ff ff       	call   8009c8 <memmove>
	nsipcbuf.send.req_size = size;
  8022e7:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8022ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8022f0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8022f5:	b8 08 00 00 00       	mov    $0x8,%eax
  8022fa:	e8 d9 fd ff ff       	call   8020d8 <nsipc>
}
  8022ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802302:	c9                   	leave  
  802303:	c3                   	ret    

00802304 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80230a:	8b 45 08             	mov    0x8(%ebp),%eax
  80230d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802312:	8b 45 0c             	mov    0xc(%ebp),%eax
  802315:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80231a:	8b 45 10             	mov    0x10(%ebp),%eax
  80231d:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802322:	b8 09 00 00 00       	mov    $0x9,%eax
  802327:	e8 ac fd ff ff       	call   8020d8 <nsipc>
}
  80232c:	c9                   	leave  
  80232d:	c3                   	ret    

0080232e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80232e:	55                   	push   %ebp
  80232f:	89 e5                	mov    %esp,%ebp
  802331:	56                   	push   %esi
  802332:	53                   	push   %ebx
  802333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802336:	83 ec 0c             	sub    $0xc,%esp
  802339:	ff 75 08             	pushl  0x8(%ebp)
  80233c:	e8 a8 ed ff ff       	call   8010e9 <fd2data>
  802341:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802343:	83 c4 08             	add    $0x8,%esp
  802346:	68 15 33 80 00       	push   $0x803315
  80234b:	53                   	push   %ebx
  80234c:	e8 e5 e4 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802351:	8b 46 04             	mov    0x4(%esi),%eax
  802354:	2b 06                	sub    (%esi),%eax
  802356:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80235c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802363:	00 00 00 
	stat->st_dev = &devpipe;
  802366:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  80236d:	40 80 00 
	return 0;
}
  802370:	b8 00 00 00 00       	mov    $0x0,%eax
  802375:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802378:	5b                   	pop    %ebx
  802379:	5e                   	pop    %esi
  80237a:	5d                   	pop    %ebp
  80237b:	c3                   	ret    

0080237c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80237c:	55                   	push   %ebp
  80237d:	89 e5                	mov    %esp,%ebp
  80237f:	53                   	push   %ebx
  802380:	83 ec 0c             	sub    $0xc,%esp
  802383:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802386:	53                   	push   %ebx
  802387:	6a 00                	push   $0x0
  802389:	e8 30 e9 ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80238e:	89 1c 24             	mov    %ebx,(%esp)
  802391:	e8 53 ed ff ff       	call   8010e9 <fd2data>
  802396:	83 c4 08             	add    $0x8,%esp
  802399:	50                   	push   %eax
  80239a:	6a 00                	push   $0x0
  80239c:	e8 1d e9 ff ff       	call   800cbe <sys_page_unmap>
}
  8023a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023a4:	c9                   	leave  
  8023a5:	c3                   	ret    

008023a6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8023a6:	55                   	push   %ebp
  8023a7:	89 e5                	mov    %esp,%ebp
  8023a9:	57                   	push   %edi
  8023aa:	56                   	push   %esi
  8023ab:	53                   	push   %ebx
  8023ac:	83 ec 1c             	sub    $0x1c,%esp
  8023af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8023b2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8023b4:	a1 08 50 80 00       	mov    0x805008,%eax
  8023b9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8023bc:	83 ec 0c             	sub    $0xc,%esp
  8023bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8023c2:	e8 f4 05 00 00       	call   8029bb <pageref>
  8023c7:	89 c3                	mov    %eax,%ebx
  8023c9:	89 3c 24             	mov    %edi,(%esp)
  8023cc:	e8 ea 05 00 00       	call   8029bb <pageref>
  8023d1:	83 c4 10             	add    $0x10,%esp
  8023d4:	39 c3                	cmp    %eax,%ebx
  8023d6:	0f 94 c1             	sete   %cl
  8023d9:	0f b6 c9             	movzbl %cl,%ecx
  8023dc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8023df:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8023e5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8023e8:	39 ce                	cmp    %ecx,%esi
  8023ea:	74 1b                	je     802407 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8023ec:	39 c3                	cmp    %eax,%ebx
  8023ee:	75 c4                	jne    8023b4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8023f0:	8b 42 58             	mov    0x58(%edx),%eax
  8023f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023f6:	50                   	push   %eax
  8023f7:	56                   	push   %esi
  8023f8:	68 1c 33 80 00       	push   $0x80331c
  8023fd:	e8 af de ff ff       	call   8002b1 <cprintf>
  802402:	83 c4 10             	add    $0x10,%esp
  802405:	eb ad                	jmp    8023b4 <_pipeisclosed+0xe>
	}
}
  802407:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80240a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80240d:	5b                   	pop    %ebx
  80240e:	5e                   	pop    %esi
  80240f:	5f                   	pop    %edi
  802410:	5d                   	pop    %ebp
  802411:	c3                   	ret    

00802412 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802412:	55                   	push   %ebp
  802413:	89 e5                	mov    %esp,%ebp
  802415:	57                   	push   %edi
  802416:	56                   	push   %esi
  802417:	53                   	push   %ebx
  802418:	83 ec 28             	sub    $0x28,%esp
  80241b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80241e:	56                   	push   %esi
  80241f:	e8 c5 ec ff ff       	call   8010e9 <fd2data>
  802424:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802426:	83 c4 10             	add    $0x10,%esp
  802429:	bf 00 00 00 00       	mov    $0x0,%edi
  80242e:	eb 4b                	jmp    80247b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802430:	89 da                	mov    %ebx,%edx
  802432:	89 f0                	mov    %esi,%eax
  802434:	e8 6d ff ff ff       	call   8023a6 <_pipeisclosed>
  802439:	85 c0                	test   %eax,%eax
  80243b:	75 48                	jne    802485 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80243d:	e8 d8 e7 ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802442:	8b 43 04             	mov    0x4(%ebx),%eax
  802445:	8b 0b                	mov    (%ebx),%ecx
  802447:	8d 51 20             	lea    0x20(%ecx),%edx
  80244a:	39 d0                	cmp    %edx,%eax
  80244c:	73 e2                	jae    802430 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80244e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802451:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802455:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802458:	89 c2                	mov    %eax,%edx
  80245a:	c1 fa 1f             	sar    $0x1f,%edx
  80245d:	89 d1                	mov    %edx,%ecx
  80245f:	c1 e9 1b             	shr    $0x1b,%ecx
  802462:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802465:	83 e2 1f             	and    $0x1f,%edx
  802468:	29 ca                	sub    %ecx,%edx
  80246a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80246e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802472:	83 c0 01             	add    $0x1,%eax
  802475:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802478:	83 c7 01             	add    $0x1,%edi
  80247b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80247e:	75 c2                	jne    802442 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802480:	8b 45 10             	mov    0x10(%ebp),%eax
  802483:	eb 05                	jmp    80248a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802485:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80248a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80248d:	5b                   	pop    %ebx
  80248e:	5e                   	pop    %esi
  80248f:	5f                   	pop    %edi
  802490:	5d                   	pop    %ebp
  802491:	c3                   	ret    

00802492 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802492:	55                   	push   %ebp
  802493:	89 e5                	mov    %esp,%ebp
  802495:	57                   	push   %edi
  802496:	56                   	push   %esi
  802497:	53                   	push   %ebx
  802498:	83 ec 18             	sub    $0x18,%esp
  80249b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80249e:	57                   	push   %edi
  80249f:	e8 45 ec ff ff       	call   8010e9 <fd2data>
  8024a4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024a6:	83 c4 10             	add    $0x10,%esp
  8024a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024ae:	eb 3d                	jmp    8024ed <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8024b0:	85 db                	test   %ebx,%ebx
  8024b2:	74 04                	je     8024b8 <devpipe_read+0x26>
				return i;
  8024b4:	89 d8                	mov    %ebx,%eax
  8024b6:	eb 44                	jmp    8024fc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8024b8:	89 f2                	mov    %esi,%edx
  8024ba:	89 f8                	mov    %edi,%eax
  8024bc:	e8 e5 fe ff ff       	call   8023a6 <_pipeisclosed>
  8024c1:	85 c0                	test   %eax,%eax
  8024c3:	75 32                	jne    8024f7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8024c5:	e8 50 e7 ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8024ca:	8b 06                	mov    (%esi),%eax
  8024cc:	3b 46 04             	cmp    0x4(%esi),%eax
  8024cf:	74 df                	je     8024b0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8024d1:	99                   	cltd   
  8024d2:	c1 ea 1b             	shr    $0x1b,%edx
  8024d5:	01 d0                	add    %edx,%eax
  8024d7:	83 e0 1f             	and    $0x1f,%eax
  8024da:	29 d0                	sub    %edx,%eax
  8024dc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8024e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024e4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8024e7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024ea:	83 c3 01             	add    $0x1,%ebx
  8024ed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8024f0:	75 d8                	jne    8024ca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8024f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8024f5:	eb 05                	jmp    8024fc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024f7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8024fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024ff:	5b                   	pop    %ebx
  802500:	5e                   	pop    %esi
  802501:	5f                   	pop    %edi
  802502:	5d                   	pop    %ebp
  802503:	c3                   	ret    

00802504 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802504:	55                   	push   %ebp
  802505:	89 e5                	mov    %esp,%ebp
  802507:	56                   	push   %esi
  802508:	53                   	push   %ebx
  802509:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80250c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80250f:	50                   	push   %eax
  802510:	e8 eb eb ff ff       	call   801100 <fd_alloc>
  802515:	83 c4 10             	add    $0x10,%esp
  802518:	89 c2                	mov    %eax,%edx
  80251a:	85 c0                	test   %eax,%eax
  80251c:	0f 88 2c 01 00 00    	js     80264e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802522:	83 ec 04             	sub    $0x4,%esp
  802525:	68 07 04 00 00       	push   $0x407
  80252a:	ff 75 f4             	pushl  -0xc(%ebp)
  80252d:	6a 00                	push   $0x0
  80252f:	e8 05 e7 ff ff       	call   800c39 <sys_page_alloc>
  802534:	83 c4 10             	add    $0x10,%esp
  802537:	89 c2                	mov    %eax,%edx
  802539:	85 c0                	test   %eax,%eax
  80253b:	0f 88 0d 01 00 00    	js     80264e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802541:	83 ec 0c             	sub    $0xc,%esp
  802544:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802547:	50                   	push   %eax
  802548:	e8 b3 eb ff ff       	call   801100 <fd_alloc>
  80254d:	89 c3                	mov    %eax,%ebx
  80254f:	83 c4 10             	add    $0x10,%esp
  802552:	85 c0                	test   %eax,%eax
  802554:	0f 88 e2 00 00 00    	js     80263c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80255a:	83 ec 04             	sub    $0x4,%esp
  80255d:	68 07 04 00 00       	push   $0x407
  802562:	ff 75 f0             	pushl  -0x10(%ebp)
  802565:	6a 00                	push   $0x0
  802567:	e8 cd e6 ff ff       	call   800c39 <sys_page_alloc>
  80256c:	89 c3                	mov    %eax,%ebx
  80256e:	83 c4 10             	add    $0x10,%esp
  802571:	85 c0                	test   %eax,%eax
  802573:	0f 88 c3 00 00 00    	js     80263c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802579:	83 ec 0c             	sub    $0xc,%esp
  80257c:	ff 75 f4             	pushl  -0xc(%ebp)
  80257f:	e8 65 eb ff ff       	call   8010e9 <fd2data>
  802584:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802586:	83 c4 0c             	add    $0xc,%esp
  802589:	68 07 04 00 00       	push   $0x407
  80258e:	50                   	push   %eax
  80258f:	6a 00                	push   $0x0
  802591:	e8 a3 e6 ff ff       	call   800c39 <sys_page_alloc>
  802596:	89 c3                	mov    %eax,%ebx
  802598:	83 c4 10             	add    $0x10,%esp
  80259b:	85 c0                	test   %eax,%eax
  80259d:	0f 88 89 00 00 00    	js     80262c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025a3:	83 ec 0c             	sub    $0xc,%esp
  8025a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8025a9:	e8 3b eb ff ff       	call   8010e9 <fd2data>
  8025ae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8025b5:	50                   	push   %eax
  8025b6:	6a 00                	push   $0x0
  8025b8:	56                   	push   %esi
  8025b9:	6a 00                	push   $0x0
  8025bb:	e8 bc e6 ff ff       	call   800c7c <sys_page_map>
  8025c0:	89 c3                	mov    %eax,%ebx
  8025c2:	83 c4 20             	add    $0x20,%esp
  8025c5:	85 c0                	test   %eax,%eax
  8025c7:	78 55                	js     80261e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025c9:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8025cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8025d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8025de:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8025e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025e7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8025e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025ec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8025f3:	83 ec 0c             	sub    $0xc,%esp
  8025f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8025f9:	e8 db ea ff ff       	call   8010d9 <fd2num>
  8025fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802601:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802603:	83 c4 04             	add    $0x4,%esp
  802606:	ff 75 f0             	pushl  -0x10(%ebp)
  802609:	e8 cb ea ff ff       	call   8010d9 <fd2num>
  80260e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802611:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802614:	83 c4 10             	add    $0x10,%esp
  802617:	ba 00 00 00 00       	mov    $0x0,%edx
  80261c:	eb 30                	jmp    80264e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80261e:	83 ec 08             	sub    $0x8,%esp
  802621:	56                   	push   %esi
  802622:	6a 00                	push   $0x0
  802624:	e8 95 e6 ff ff       	call   800cbe <sys_page_unmap>
  802629:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80262c:	83 ec 08             	sub    $0x8,%esp
  80262f:	ff 75 f0             	pushl  -0x10(%ebp)
  802632:	6a 00                	push   $0x0
  802634:	e8 85 e6 ff ff       	call   800cbe <sys_page_unmap>
  802639:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80263c:	83 ec 08             	sub    $0x8,%esp
  80263f:	ff 75 f4             	pushl  -0xc(%ebp)
  802642:	6a 00                	push   $0x0
  802644:	e8 75 e6 ff ff       	call   800cbe <sys_page_unmap>
  802649:	83 c4 10             	add    $0x10,%esp
  80264c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80264e:	89 d0                	mov    %edx,%eax
  802650:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802653:	5b                   	pop    %ebx
  802654:	5e                   	pop    %esi
  802655:	5d                   	pop    %ebp
  802656:	c3                   	ret    

00802657 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802657:	55                   	push   %ebp
  802658:	89 e5                	mov    %esp,%ebp
  80265a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80265d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802660:	50                   	push   %eax
  802661:	ff 75 08             	pushl  0x8(%ebp)
  802664:	e8 e6 ea ff ff       	call   80114f <fd_lookup>
  802669:	83 c4 10             	add    $0x10,%esp
  80266c:	85 c0                	test   %eax,%eax
  80266e:	78 18                	js     802688 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802670:	83 ec 0c             	sub    $0xc,%esp
  802673:	ff 75 f4             	pushl  -0xc(%ebp)
  802676:	e8 6e ea ff ff       	call   8010e9 <fd2data>
	return _pipeisclosed(fd, p);
  80267b:	89 c2                	mov    %eax,%edx
  80267d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802680:	e8 21 fd ff ff       	call   8023a6 <_pipeisclosed>
  802685:	83 c4 10             	add    $0x10,%esp
}
  802688:	c9                   	leave  
  802689:	c3                   	ret    

0080268a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80268a:	55                   	push   %ebp
  80268b:	89 e5                	mov    %esp,%ebp
  80268d:	56                   	push   %esi
  80268e:	53                   	push   %ebx
  80268f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802692:	85 f6                	test   %esi,%esi
  802694:	75 16                	jne    8026ac <wait+0x22>
  802696:	68 34 33 80 00       	push   $0x803334
  80269b:	68 fb 31 80 00       	push   $0x8031fb
  8026a0:	6a 09                	push   $0x9
  8026a2:	68 3f 33 80 00       	push   $0x80333f
  8026a7:	e8 2c db ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  8026ac:	89 f3                	mov    %esi,%ebx
  8026ae:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026b4:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8026b7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8026bd:	eb 05                	jmp    8026c4 <wait+0x3a>
		sys_yield();
  8026bf:	e8 56 e5 ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026c4:	8b 43 48             	mov    0x48(%ebx),%eax
  8026c7:	39 c6                	cmp    %eax,%esi
  8026c9:	75 07                	jne    8026d2 <wait+0x48>
  8026cb:	8b 43 54             	mov    0x54(%ebx),%eax
  8026ce:	85 c0                	test   %eax,%eax
  8026d0:	75 ed                	jne    8026bf <wait+0x35>
		sys_yield();
}
  8026d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026d5:	5b                   	pop    %ebx
  8026d6:	5e                   	pop    %esi
  8026d7:	5d                   	pop    %ebp
  8026d8:	c3                   	ret    

008026d9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8026d9:	55                   	push   %ebp
  8026da:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8026dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8026e1:	5d                   	pop    %ebp
  8026e2:	c3                   	ret    

008026e3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8026e3:	55                   	push   %ebp
  8026e4:	89 e5                	mov    %esp,%ebp
  8026e6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8026e9:	68 4a 33 80 00       	push   $0x80334a
  8026ee:	ff 75 0c             	pushl  0xc(%ebp)
  8026f1:	e8 40 e1 ff ff       	call   800836 <strcpy>
	return 0;
}
  8026f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8026fb:	c9                   	leave  
  8026fc:	c3                   	ret    

008026fd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8026fd:	55                   	push   %ebp
  8026fe:	89 e5                	mov    %esp,%ebp
  802700:	57                   	push   %edi
  802701:	56                   	push   %esi
  802702:	53                   	push   %ebx
  802703:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802709:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80270e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802714:	eb 2d                	jmp    802743 <devcons_write+0x46>
		m = n - tot;
  802716:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802719:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80271b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80271e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802723:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802726:	83 ec 04             	sub    $0x4,%esp
  802729:	53                   	push   %ebx
  80272a:	03 45 0c             	add    0xc(%ebp),%eax
  80272d:	50                   	push   %eax
  80272e:	57                   	push   %edi
  80272f:	e8 94 e2 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  802734:	83 c4 08             	add    $0x8,%esp
  802737:	53                   	push   %ebx
  802738:	57                   	push   %edi
  802739:	e8 3f e4 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80273e:	01 de                	add    %ebx,%esi
  802740:	83 c4 10             	add    $0x10,%esp
  802743:	89 f0                	mov    %esi,%eax
  802745:	3b 75 10             	cmp    0x10(%ebp),%esi
  802748:	72 cc                	jb     802716 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80274a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80274d:	5b                   	pop    %ebx
  80274e:	5e                   	pop    %esi
  80274f:	5f                   	pop    %edi
  802750:	5d                   	pop    %ebp
  802751:	c3                   	ret    

00802752 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802752:	55                   	push   %ebp
  802753:	89 e5                	mov    %esp,%ebp
  802755:	83 ec 08             	sub    $0x8,%esp
  802758:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80275d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802761:	74 2a                	je     80278d <devcons_read+0x3b>
  802763:	eb 05                	jmp    80276a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802765:	e8 b0 e4 ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80276a:	e8 2c e4 ff ff       	call   800b9b <sys_cgetc>
  80276f:	85 c0                	test   %eax,%eax
  802771:	74 f2                	je     802765 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802773:	85 c0                	test   %eax,%eax
  802775:	78 16                	js     80278d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802777:	83 f8 04             	cmp    $0x4,%eax
  80277a:	74 0c                	je     802788 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80277c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80277f:	88 02                	mov    %al,(%edx)
	return 1;
  802781:	b8 01 00 00 00       	mov    $0x1,%eax
  802786:	eb 05                	jmp    80278d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802788:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80278d:	c9                   	leave  
  80278e:	c3                   	ret    

0080278f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80278f:	55                   	push   %ebp
  802790:	89 e5                	mov    %esp,%ebp
  802792:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802795:	8b 45 08             	mov    0x8(%ebp),%eax
  802798:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80279b:	6a 01                	push   $0x1
  80279d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8027a0:	50                   	push   %eax
  8027a1:	e8 d7 e3 ff ff       	call   800b7d <sys_cputs>
}
  8027a6:	83 c4 10             	add    $0x10,%esp
  8027a9:	c9                   	leave  
  8027aa:	c3                   	ret    

008027ab <getchar>:

int
getchar(void)
{
  8027ab:	55                   	push   %ebp
  8027ac:	89 e5                	mov    %esp,%ebp
  8027ae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8027b1:	6a 01                	push   $0x1
  8027b3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8027b6:	50                   	push   %eax
  8027b7:	6a 00                	push   $0x0
  8027b9:	e8 f7 eb ff ff       	call   8013b5 <read>
	if (r < 0)
  8027be:	83 c4 10             	add    $0x10,%esp
  8027c1:	85 c0                	test   %eax,%eax
  8027c3:	78 0f                	js     8027d4 <getchar+0x29>
		return r;
	if (r < 1)
  8027c5:	85 c0                	test   %eax,%eax
  8027c7:	7e 06                	jle    8027cf <getchar+0x24>
		return -E_EOF;
	return c;
  8027c9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8027cd:	eb 05                	jmp    8027d4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8027cf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8027d4:	c9                   	leave  
  8027d5:	c3                   	ret    

008027d6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8027d6:	55                   	push   %ebp
  8027d7:	89 e5                	mov    %esp,%ebp
  8027d9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027df:	50                   	push   %eax
  8027e0:	ff 75 08             	pushl  0x8(%ebp)
  8027e3:	e8 67 e9 ff ff       	call   80114f <fd_lookup>
  8027e8:	83 c4 10             	add    $0x10,%esp
  8027eb:	85 c0                	test   %eax,%eax
  8027ed:	78 11                	js     802800 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8027ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027f2:	8b 15 60 40 80 00    	mov    0x804060,%edx
  8027f8:	39 10                	cmp    %edx,(%eax)
  8027fa:	0f 94 c0             	sete   %al
  8027fd:	0f b6 c0             	movzbl %al,%eax
}
  802800:	c9                   	leave  
  802801:	c3                   	ret    

00802802 <opencons>:

int
opencons(void)
{
  802802:	55                   	push   %ebp
  802803:	89 e5                	mov    %esp,%ebp
  802805:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802808:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80280b:	50                   	push   %eax
  80280c:	e8 ef e8 ff ff       	call   801100 <fd_alloc>
  802811:	83 c4 10             	add    $0x10,%esp
		return r;
  802814:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802816:	85 c0                	test   %eax,%eax
  802818:	78 3e                	js     802858 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80281a:	83 ec 04             	sub    $0x4,%esp
  80281d:	68 07 04 00 00       	push   $0x407
  802822:	ff 75 f4             	pushl  -0xc(%ebp)
  802825:	6a 00                	push   $0x0
  802827:	e8 0d e4 ff ff       	call   800c39 <sys_page_alloc>
  80282c:	83 c4 10             	add    $0x10,%esp
		return r;
  80282f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802831:	85 c0                	test   %eax,%eax
  802833:	78 23                	js     802858 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802835:	8b 15 60 40 80 00    	mov    0x804060,%edx
  80283b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80283e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802843:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80284a:	83 ec 0c             	sub    $0xc,%esp
  80284d:	50                   	push   %eax
  80284e:	e8 86 e8 ff ff       	call   8010d9 <fd2num>
  802853:	89 c2                	mov    %eax,%edx
  802855:	83 c4 10             	add    $0x10,%esp
}
  802858:	89 d0                	mov    %edx,%eax
  80285a:	c9                   	leave  
  80285b:	c3                   	ret    

0080285c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80285c:	55                   	push   %ebp
  80285d:	89 e5                	mov    %esp,%ebp
  80285f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802862:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802869:	75 2e                	jne    802899 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80286b:	e8 8b e3 ff ff       	call   800bfb <sys_getenvid>
  802870:	83 ec 04             	sub    $0x4,%esp
  802873:	68 07 0e 00 00       	push   $0xe07
  802878:	68 00 f0 bf ee       	push   $0xeebff000
  80287d:	50                   	push   %eax
  80287e:	e8 b6 e3 ff ff       	call   800c39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802883:	e8 73 e3 ff ff       	call   800bfb <sys_getenvid>
  802888:	83 c4 08             	add    $0x8,%esp
  80288b:	68 a3 28 80 00       	push   $0x8028a3
  802890:	50                   	push   %eax
  802891:	e8 ee e4 ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
  802896:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802899:	8b 45 08             	mov    0x8(%ebp),%eax
  80289c:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8028a1:	c9                   	leave  
  8028a2:	c3                   	ret    

008028a3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8028a3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8028a4:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8028a9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8028ab:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8028ae:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8028b2:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8028b6:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8028b9:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8028bc:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8028bd:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8028c0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8028c1:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8028c2:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8028c6:	c3                   	ret    

008028c7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028c7:	55                   	push   %ebp
  8028c8:	89 e5                	mov    %esp,%ebp
  8028ca:	56                   	push   %esi
  8028cb:	53                   	push   %ebx
  8028cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8028cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8028d5:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8028d7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8028dc:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8028df:	83 ec 0c             	sub    $0xc,%esp
  8028e2:	50                   	push   %eax
  8028e3:	e8 01 e5 ff ff       	call   800de9 <sys_ipc_recv>

	if (from_env_store != NULL)
  8028e8:	83 c4 10             	add    $0x10,%esp
  8028eb:	85 f6                	test   %esi,%esi
  8028ed:	74 14                	je     802903 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8028ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8028f4:	85 c0                	test   %eax,%eax
  8028f6:	78 09                	js     802901 <ipc_recv+0x3a>
  8028f8:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8028fe:	8b 52 74             	mov    0x74(%edx),%edx
  802901:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802903:	85 db                	test   %ebx,%ebx
  802905:	74 14                	je     80291b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802907:	ba 00 00 00 00       	mov    $0x0,%edx
  80290c:	85 c0                	test   %eax,%eax
  80290e:	78 09                	js     802919 <ipc_recv+0x52>
  802910:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802916:	8b 52 78             	mov    0x78(%edx),%edx
  802919:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80291b:	85 c0                	test   %eax,%eax
  80291d:	78 08                	js     802927 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80291f:	a1 08 50 80 00       	mov    0x805008,%eax
  802924:	8b 40 70             	mov    0x70(%eax),%eax
}
  802927:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80292a:	5b                   	pop    %ebx
  80292b:	5e                   	pop    %esi
  80292c:	5d                   	pop    %ebp
  80292d:	c3                   	ret    

0080292e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80292e:	55                   	push   %ebp
  80292f:	89 e5                	mov    %esp,%ebp
  802931:	57                   	push   %edi
  802932:	56                   	push   %esi
  802933:	53                   	push   %ebx
  802934:	83 ec 0c             	sub    $0xc,%esp
  802937:	8b 7d 08             	mov    0x8(%ebp),%edi
  80293a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80293d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802940:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802942:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802947:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80294a:	ff 75 14             	pushl  0x14(%ebp)
  80294d:	53                   	push   %ebx
  80294e:	56                   	push   %esi
  80294f:	57                   	push   %edi
  802950:	e8 71 e4 ff ff       	call   800dc6 <sys_ipc_try_send>

		if (err < 0) {
  802955:	83 c4 10             	add    $0x10,%esp
  802958:	85 c0                	test   %eax,%eax
  80295a:	79 1e                	jns    80297a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80295c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80295f:	75 07                	jne    802968 <ipc_send+0x3a>
				sys_yield();
  802961:	e8 b4 e2 ff ff       	call   800c1a <sys_yield>
  802966:	eb e2                	jmp    80294a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802968:	50                   	push   %eax
  802969:	68 56 33 80 00       	push   $0x803356
  80296e:	6a 49                	push   $0x49
  802970:	68 63 33 80 00       	push   $0x803363
  802975:	e8 5e d8 ff ff       	call   8001d8 <_panic>
		}

	} while (err < 0);

}
  80297a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80297d:	5b                   	pop    %ebx
  80297e:	5e                   	pop    %esi
  80297f:	5f                   	pop    %edi
  802980:	5d                   	pop    %ebp
  802981:	c3                   	ret    

00802982 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802982:	55                   	push   %ebp
  802983:	89 e5                	mov    %esp,%ebp
  802985:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802988:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80298d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802990:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802996:	8b 52 50             	mov    0x50(%edx),%edx
  802999:	39 ca                	cmp    %ecx,%edx
  80299b:	75 0d                	jne    8029aa <ipc_find_env+0x28>
			return envs[i].env_id;
  80299d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029a5:	8b 40 48             	mov    0x48(%eax),%eax
  8029a8:	eb 0f                	jmp    8029b9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8029aa:	83 c0 01             	add    $0x1,%eax
  8029ad:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029b2:	75 d9                	jne    80298d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8029b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029b9:	5d                   	pop    %ebp
  8029ba:	c3                   	ret    

008029bb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029bb:	55                   	push   %ebp
  8029bc:	89 e5                	mov    %esp,%ebp
  8029be:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029c1:	89 d0                	mov    %edx,%eax
  8029c3:	c1 e8 16             	shr    $0x16,%eax
  8029c6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8029cd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029d2:	f6 c1 01             	test   $0x1,%cl
  8029d5:	74 1d                	je     8029f4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029d7:	c1 ea 0c             	shr    $0xc,%edx
  8029da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8029e1:	f6 c2 01             	test   $0x1,%dl
  8029e4:	74 0e                	je     8029f4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029e6:	c1 ea 0c             	shr    $0xc,%edx
  8029e9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8029f0:	ef 
  8029f1:	0f b7 c0             	movzwl %ax,%eax
}
  8029f4:	5d                   	pop    %ebp
  8029f5:	c3                   	ret    
  8029f6:	66 90                	xchg   %ax,%ax
  8029f8:	66 90                	xchg   %ax,%ax
  8029fa:	66 90                	xchg   %ax,%ax
  8029fc:	66 90                	xchg   %ax,%ax
  8029fe:	66 90                	xchg   %ax,%ax

00802a00 <__udivdi3>:
  802a00:	55                   	push   %ebp
  802a01:	57                   	push   %edi
  802a02:	56                   	push   %esi
  802a03:	53                   	push   %ebx
  802a04:	83 ec 1c             	sub    $0x1c,%esp
  802a07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802a0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802a0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802a13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a17:	85 f6                	test   %esi,%esi
  802a19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a1d:	89 ca                	mov    %ecx,%edx
  802a1f:	89 f8                	mov    %edi,%eax
  802a21:	75 3d                	jne    802a60 <__udivdi3+0x60>
  802a23:	39 cf                	cmp    %ecx,%edi
  802a25:	0f 87 c5 00 00 00    	ja     802af0 <__udivdi3+0xf0>
  802a2b:	85 ff                	test   %edi,%edi
  802a2d:	89 fd                	mov    %edi,%ebp
  802a2f:	75 0b                	jne    802a3c <__udivdi3+0x3c>
  802a31:	b8 01 00 00 00       	mov    $0x1,%eax
  802a36:	31 d2                	xor    %edx,%edx
  802a38:	f7 f7                	div    %edi
  802a3a:	89 c5                	mov    %eax,%ebp
  802a3c:	89 c8                	mov    %ecx,%eax
  802a3e:	31 d2                	xor    %edx,%edx
  802a40:	f7 f5                	div    %ebp
  802a42:	89 c1                	mov    %eax,%ecx
  802a44:	89 d8                	mov    %ebx,%eax
  802a46:	89 cf                	mov    %ecx,%edi
  802a48:	f7 f5                	div    %ebp
  802a4a:	89 c3                	mov    %eax,%ebx
  802a4c:	89 d8                	mov    %ebx,%eax
  802a4e:	89 fa                	mov    %edi,%edx
  802a50:	83 c4 1c             	add    $0x1c,%esp
  802a53:	5b                   	pop    %ebx
  802a54:	5e                   	pop    %esi
  802a55:	5f                   	pop    %edi
  802a56:	5d                   	pop    %ebp
  802a57:	c3                   	ret    
  802a58:	90                   	nop
  802a59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a60:	39 ce                	cmp    %ecx,%esi
  802a62:	77 74                	ja     802ad8 <__udivdi3+0xd8>
  802a64:	0f bd fe             	bsr    %esi,%edi
  802a67:	83 f7 1f             	xor    $0x1f,%edi
  802a6a:	0f 84 98 00 00 00    	je     802b08 <__udivdi3+0x108>
  802a70:	bb 20 00 00 00       	mov    $0x20,%ebx
  802a75:	89 f9                	mov    %edi,%ecx
  802a77:	89 c5                	mov    %eax,%ebp
  802a79:	29 fb                	sub    %edi,%ebx
  802a7b:	d3 e6                	shl    %cl,%esi
  802a7d:	89 d9                	mov    %ebx,%ecx
  802a7f:	d3 ed                	shr    %cl,%ebp
  802a81:	89 f9                	mov    %edi,%ecx
  802a83:	d3 e0                	shl    %cl,%eax
  802a85:	09 ee                	or     %ebp,%esi
  802a87:	89 d9                	mov    %ebx,%ecx
  802a89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a8d:	89 d5                	mov    %edx,%ebp
  802a8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a93:	d3 ed                	shr    %cl,%ebp
  802a95:	89 f9                	mov    %edi,%ecx
  802a97:	d3 e2                	shl    %cl,%edx
  802a99:	89 d9                	mov    %ebx,%ecx
  802a9b:	d3 e8                	shr    %cl,%eax
  802a9d:	09 c2                	or     %eax,%edx
  802a9f:	89 d0                	mov    %edx,%eax
  802aa1:	89 ea                	mov    %ebp,%edx
  802aa3:	f7 f6                	div    %esi
  802aa5:	89 d5                	mov    %edx,%ebp
  802aa7:	89 c3                	mov    %eax,%ebx
  802aa9:	f7 64 24 0c          	mull   0xc(%esp)
  802aad:	39 d5                	cmp    %edx,%ebp
  802aaf:	72 10                	jb     802ac1 <__udivdi3+0xc1>
  802ab1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802ab5:	89 f9                	mov    %edi,%ecx
  802ab7:	d3 e6                	shl    %cl,%esi
  802ab9:	39 c6                	cmp    %eax,%esi
  802abb:	73 07                	jae    802ac4 <__udivdi3+0xc4>
  802abd:	39 d5                	cmp    %edx,%ebp
  802abf:	75 03                	jne    802ac4 <__udivdi3+0xc4>
  802ac1:	83 eb 01             	sub    $0x1,%ebx
  802ac4:	31 ff                	xor    %edi,%edi
  802ac6:	89 d8                	mov    %ebx,%eax
  802ac8:	89 fa                	mov    %edi,%edx
  802aca:	83 c4 1c             	add    $0x1c,%esp
  802acd:	5b                   	pop    %ebx
  802ace:	5e                   	pop    %esi
  802acf:	5f                   	pop    %edi
  802ad0:	5d                   	pop    %ebp
  802ad1:	c3                   	ret    
  802ad2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ad8:	31 ff                	xor    %edi,%edi
  802ada:	31 db                	xor    %ebx,%ebx
  802adc:	89 d8                	mov    %ebx,%eax
  802ade:	89 fa                	mov    %edi,%edx
  802ae0:	83 c4 1c             	add    $0x1c,%esp
  802ae3:	5b                   	pop    %ebx
  802ae4:	5e                   	pop    %esi
  802ae5:	5f                   	pop    %edi
  802ae6:	5d                   	pop    %ebp
  802ae7:	c3                   	ret    
  802ae8:	90                   	nop
  802ae9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802af0:	89 d8                	mov    %ebx,%eax
  802af2:	f7 f7                	div    %edi
  802af4:	31 ff                	xor    %edi,%edi
  802af6:	89 c3                	mov    %eax,%ebx
  802af8:	89 d8                	mov    %ebx,%eax
  802afa:	89 fa                	mov    %edi,%edx
  802afc:	83 c4 1c             	add    $0x1c,%esp
  802aff:	5b                   	pop    %ebx
  802b00:	5e                   	pop    %esi
  802b01:	5f                   	pop    %edi
  802b02:	5d                   	pop    %ebp
  802b03:	c3                   	ret    
  802b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b08:	39 ce                	cmp    %ecx,%esi
  802b0a:	72 0c                	jb     802b18 <__udivdi3+0x118>
  802b0c:	31 db                	xor    %ebx,%ebx
  802b0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802b12:	0f 87 34 ff ff ff    	ja     802a4c <__udivdi3+0x4c>
  802b18:	bb 01 00 00 00       	mov    $0x1,%ebx
  802b1d:	e9 2a ff ff ff       	jmp    802a4c <__udivdi3+0x4c>
  802b22:	66 90                	xchg   %ax,%ax
  802b24:	66 90                	xchg   %ax,%ax
  802b26:	66 90                	xchg   %ax,%ax
  802b28:	66 90                	xchg   %ax,%ax
  802b2a:	66 90                	xchg   %ax,%ax
  802b2c:	66 90                	xchg   %ax,%ax
  802b2e:	66 90                	xchg   %ax,%ax

00802b30 <__umoddi3>:
  802b30:	55                   	push   %ebp
  802b31:	57                   	push   %edi
  802b32:	56                   	push   %esi
  802b33:	53                   	push   %ebx
  802b34:	83 ec 1c             	sub    $0x1c,%esp
  802b37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802b3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802b3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b47:	85 d2                	test   %edx,%edx
  802b49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802b4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b51:	89 f3                	mov    %esi,%ebx
  802b53:	89 3c 24             	mov    %edi,(%esp)
  802b56:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b5a:	75 1c                	jne    802b78 <__umoddi3+0x48>
  802b5c:	39 f7                	cmp    %esi,%edi
  802b5e:	76 50                	jbe    802bb0 <__umoddi3+0x80>
  802b60:	89 c8                	mov    %ecx,%eax
  802b62:	89 f2                	mov    %esi,%edx
  802b64:	f7 f7                	div    %edi
  802b66:	89 d0                	mov    %edx,%eax
  802b68:	31 d2                	xor    %edx,%edx
  802b6a:	83 c4 1c             	add    $0x1c,%esp
  802b6d:	5b                   	pop    %ebx
  802b6e:	5e                   	pop    %esi
  802b6f:	5f                   	pop    %edi
  802b70:	5d                   	pop    %ebp
  802b71:	c3                   	ret    
  802b72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b78:	39 f2                	cmp    %esi,%edx
  802b7a:	89 d0                	mov    %edx,%eax
  802b7c:	77 52                	ja     802bd0 <__umoddi3+0xa0>
  802b7e:	0f bd ea             	bsr    %edx,%ebp
  802b81:	83 f5 1f             	xor    $0x1f,%ebp
  802b84:	75 5a                	jne    802be0 <__umoddi3+0xb0>
  802b86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802b8a:	0f 82 e0 00 00 00    	jb     802c70 <__umoddi3+0x140>
  802b90:	39 0c 24             	cmp    %ecx,(%esp)
  802b93:	0f 86 d7 00 00 00    	jbe    802c70 <__umoddi3+0x140>
  802b99:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802ba1:	83 c4 1c             	add    $0x1c,%esp
  802ba4:	5b                   	pop    %ebx
  802ba5:	5e                   	pop    %esi
  802ba6:	5f                   	pop    %edi
  802ba7:	5d                   	pop    %ebp
  802ba8:	c3                   	ret    
  802ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bb0:	85 ff                	test   %edi,%edi
  802bb2:	89 fd                	mov    %edi,%ebp
  802bb4:	75 0b                	jne    802bc1 <__umoddi3+0x91>
  802bb6:	b8 01 00 00 00       	mov    $0x1,%eax
  802bbb:	31 d2                	xor    %edx,%edx
  802bbd:	f7 f7                	div    %edi
  802bbf:	89 c5                	mov    %eax,%ebp
  802bc1:	89 f0                	mov    %esi,%eax
  802bc3:	31 d2                	xor    %edx,%edx
  802bc5:	f7 f5                	div    %ebp
  802bc7:	89 c8                	mov    %ecx,%eax
  802bc9:	f7 f5                	div    %ebp
  802bcb:	89 d0                	mov    %edx,%eax
  802bcd:	eb 99                	jmp    802b68 <__umoddi3+0x38>
  802bcf:	90                   	nop
  802bd0:	89 c8                	mov    %ecx,%eax
  802bd2:	89 f2                	mov    %esi,%edx
  802bd4:	83 c4 1c             	add    $0x1c,%esp
  802bd7:	5b                   	pop    %ebx
  802bd8:	5e                   	pop    %esi
  802bd9:	5f                   	pop    %edi
  802bda:	5d                   	pop    %ebp
  802bdb:	c3                   	ret    
  802bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802be0:	8b 34 24             	mov    (%esp),%esi
  802be3:	bf 20 00 00 00       	mov    $0x20,%edi
  802be8:	89 e9                	mov    %ebp,%ecx
  802bea:	29 ef                	sub    %ebp,%edi
  802bec:	d3 e0                	shl    %cl,%eax
  802bee:	89 f9                	mov    %edi,%ecx
  802bf0:	89 f2                	mov    %esi,%edx
  802bf2:	d3 ea                	shr    %cl,%edx
  802bf4:	89 e9                	mov    %ebp,%ecx
  802bf6:	09 c2                	or     %eax,%edx
  802bf8:	89 d8                	mov    %ebx,%eax
  802bfa:	89 14 24             	mov    %edx,(%esp)
  802bfd:	89 f2                	mov    %esi,%edx
  802bff:	d3 e2                	shl    %cl,%edx
  802c01:	89 f9                	mov    %edi,%ecx
  802c03:	89 54 24 04          	mov    %edx,0x4(%esp)
  802c07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c0b:	d3 e8                	shr    %cl,%eax
  802c0d:	89 e9                	mov    %ebp,%ecx
  802c0f:	89 c6                	mov    %eax,%esi
  802c11:	d3 e3                	shl    %cl,%ebx
  802c13:	89 f9                	mov    %edi,%ecx
  802c15:	89 d0                	mov    %edx,%eax
  802c17:	d3 e8                	shr    %cl,%eax
  802c19:	89 e9                	mov    %ebp,%ecx
  802c1b:	09 d8                	or     %ebx,%eax
  802c1d:	89 d3                	mov    %edx,%ebx
  802c1f:	89 f2                	mov    %esi,%edx
  802c21:	f7 34 24             	divl   (%esp)
  802c24:	89 d6                	mov    %edx,%esi
  802c26:	d3 e3                	shl    %cl,%ebx
  802c28:	f7 64 24 04          	mull   0x4(%esp)
  802c2c:	39 d6                	cmp    %edx,%esi
  802c2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c32:	89 d1                	mov    %edx,%ecx
  802c34:	89 c3                	mov    %eax,%ebx
  802c36:	72 08                	jb     802c40 <__umoddi3+0x110>
  802c38:	75 11                	jne    802c4b <__umoddi3+0x11b>
  802c3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802c3e:	73 0b                	jae    802c4b <__umoddi3+0x11b>
  802c40:	2b 44 24 04          	sub    0x4(%esp),%eax
  802c44:	1b 14 24             	sbb    (%esp),%edx
  802c47:	89 d1                	mov    %edx,%ecx
  802c49:	89 c3                	mov    %eax,%ebx
  802c4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802c4f:	29 da                	sub    %ebx,%edx
  802c51:	19 ce                	sbb    %ecx,%esi
  802c53:	89 f9                	mov    %edi,%ecx
  802c55:	89 f0                	mov    %esi,%eax
  802c57:	d3 e0                	shl    %cl,%eax
  802c59:	89 e9                	mov    %ebp,%ecx
  802c5b:	d3 ea                	shr    %cl,%edx
  802c5d:	89 e9                	mov    %ebp,%ecx
  802c5f:	d3 ee                	shr    %cl,%esi
  802c61:	09 d0                	or     %edx,%eax
  802c63:	89 f2                	mov    %esi,%edx
  802c65:	83 c4 1c             	add    $0x1c,%esp
  802c68:	5b                   	pop    %ebx
  802c69:	5e                   	pop    %esi
  802c6a:	5f                   	pop    %edi
  802c6b:	5d                   	pop    %ebp
  802c6c:	c3                   	ret    
  802c6d:	8d 76 00             	lea    0x0(%esi),%esi
  802c70:	29 f9                	sub    %edi,%ecx
  802c72:	19 d6                	sbb    %edx,%esi
  802c74:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c7c:	e9 18 ff ff ff       	jmp    802b99 <__umoddi3+0x69>
