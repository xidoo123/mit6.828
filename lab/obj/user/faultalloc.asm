
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 a0 23 80 00       	push   $0x8023a0
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 2d 0b 00 00       	call   800b8b <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 c0 23 80 00       	push   $0x8023c0
  80006f:	6a 0e                	push   $0xe
  800071:	68 aa 23 80 00       	push   $0x8023aa
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ec 23 80 00       	push   $0x8023ec
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 ac 06 00 00       	call   800735 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 7e 0d 00 00       	call   800e1f <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 bc 23 80 00       	push   $0x8023bc
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 bc 23 80 00       	push   $0x8023bc
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 73 0a 00 00       	call   800b4d <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 3a 0f 00 00       	call   801055 <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 e7 09 00 00       	call   800b0c <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 10 0a 00 00       	call   800b4d <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 18 24 80 00       	push   $0x802418
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 84 28 80 00 	movl   $0x802884,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 2f 09 00 00       	call   800acf <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 54 01 00 00       	call   80033a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 d4 08 00 00       	call   800acf <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 95 1e 00 00       	call   802100 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 82 1f 00 00       	call   802230 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 3b 24 80 00 	movsbl 0x80243b(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1b>
		*b->buf++ = ch;
  800311:	8d 4a 01             	lea    0x1(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	88 02                	mov    %al,(%edx)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800323:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 10             	pushl  0x10(%ebp)
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	e8 05 00 00 00       	call   80033a <vprintfmt>
	va_end(ap);
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	57                   	push   %edi
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
  800340:	83 ec 2c             	sub    $0x2c,%esp
  800343:	8b 75 08             	mov    0x8(%ebp),%esi
  800346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800349:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034c:	eb 12                	jmp    800360 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034e:	85 c0                	test   %eax,%eax
  800350:	0f 84 89 03 00 00    	je     8006df <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	53                   	push   %ebx
  80035a:	50                   	push   %eax
  80035b:	ff d6                	call   *%esi
  80035d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800360:	83 c7 01             	add    $0x1,%edi
  800363:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800367:	83 f8 25             	cmp    $0x25,%eax
  80036a:	75 e2                	jne    80034e <vprintfmt+0x14>
  80036c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800370:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
  80038a:	eb 07                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8d 47 01             	lea    0x1(%edi),%eax
  800396:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800399:	0f b6 07             	movzbl (%edi),%eax
  80039c:	0f b6 c8             	movzbl %al,%ecx
  80039f:	83 e8 23             	sub    $0x23,%eax
  8003a2:	3c 55                	cmp    $0x55,%al
  8003a4:	0f 87 1a 03 00 00    	ja     8006c4 <vprintfmt+0x38a>
  8003aa:	0f b6 c0             	movzbl %al,%eax
  8003ad:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bb:	eb d6                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cf:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d5:	83 fa 09             	cmp    $0x9,%edx
  8003d8:	77 39                	ja     800413 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003da:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003dd:	eb e9                	jmp    8003c8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f0:	eb 27                	jmp    800419 <vprintfmt+0xdf>
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fc:	0f 49 c8             	cmovns %eax,%ecx
  8003ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800405:	eb 8c                	jmp    800393 <vprintfmt+0x59>
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800411:	eb 80                	jmp    800393 <vprintfmt+0x59>
  800413:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800416:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800419:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041d:	0f 89 70 ff ff ff    	jns    800393 <vprintfmt+0x59>
				width = precision, precision = -1;
  800423:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800426:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800429:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800430:	e9 5e ff ff ff       	jmp    800393 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800435:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043b:	e9 53 ff ff ff       	jmp    800393 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	53                   	push   %ebx
  80044d:	ff 30                	pushl  (%eax)
  80044f:	ff d6                	call   *%esi
			break;
  800451:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800457:	e9 04 ff ff ff       	jmp    800360 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 00                	mov    (%eax),%eax
  800467:	99                   	cltd   
  800468:	31 d0                	xor    %edx,%eax
  80046a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046c:	83 f8 0f             	cmp    $0xf,%eax
  80046f:	7f 0b                	jg     80047c <vprintfmt+0x142>
  800471:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	75 18                	jne    800494 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80047c:	50                   	push   %eax
  80047d:	68 53 24 80 00       	push   $0x802453
  800482:	53                   	push   %ebx
  800483:	56                   	push   %esi
  800484:	e8 94 fe ff ff       	call   80031d <printfmt>
  800489:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048f:	e9 cc fe ff ff       	jmp    800360 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800494:	52                   	push   %edx
  800495:	68 19 28 80 00       	push   $0x802819
  80049a:	53                   	push   %ebx
  80049b:	56                   	push   %esi
  80049c:	e8 7c fe ff ff       	call   80031d <printfmt>
  8004a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a7:	e9 b4 fe ff ff       	jmp    800360 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	b8 4c 24 80 00       	mov    $0x80244c,%eax
  8004be:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	0f 8e 94 00 00 00    	jle    80055f <vprintfmt+0x225>
  8004cb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cf:	0f 84 98 00 00 00    	je     80056d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004db:	57                   	push   %edi
  8004dc:	e8 86 02 00 00       	call   800767 <strnlen>
  8004e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	eb 0f                	jmp    800509 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 ff                	test   %edi,%edi
  80050b:	7f ed                	jg     8004fa <vprintfmt+0x1c0>
  80050d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800510:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800513:	85 c9                	test   %ecx,%ecx
  800515:	b8 00 00 00 00       	mov    $0x0,%eax
  80051a:	0f 49 c1             	cmovns %ecx,%eax
  80051d:	29 c1                	sub    %eax,%ecx
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	89 cb                	mov    %ecx,%ebx
  80052a:	eb 4d                	jmp    800579 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800530:	74 1b                	je     80054d <vprintfmt+0x213>
  800532:	0f be c0             	movsbl %al,%eax
  800535:	83 e8 20             	sub    $0x20,%eax
  800538:	83 f8 5e             	cmp    $0x5e,%eax
  80053b:	76 10                	jbe    80054d <vprintfmt+0x213>
					putch('?', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	6a 3f                	push   $0x3f
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	52                   	push   %edx
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 eb 01             	sub    $0x1,%ebx
  80055d:	eb 1a                	jmp    800579 <vprintfmt+0x23f>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	eb 0c                	jmp    800579 <vprintfmt+0x23f>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	83 c7 01             	add    $0x1,%edi
  80057c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800580:	0f be d0             	movsbl %al,%edx
  800583:	85 d2                	test   %edx,%edx
  800585:	74 23                	je     8005aa <vprintfmt+0x270>
  800587:	85 f6                	test   %esi,%esi
  800589:	78 a1                	js     80052c <vprintfmt+0x1f2>
  80058b:	83 ee 01             	sub    $0x1,%esi
  80058e:	79 9c                	jns    80052c <vprintfmt+0x1f2>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	eb 18                	jmp    8005b2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 20                	push   $0x20
  8005a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 ef 01             	sub    $0x1,%edi
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	eb 08                	jmp    8005b2 <vprintfmt+0x278>
  8005aa:	89 df                	mov    %ebx,%edi
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	7f e4                	jg     80059a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b9:	e9 a2 fd ff ff       	jmp    800360 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005be:	83 fa 01             	cmp    $0x1,%edx
  8005c1:	7e 16                	jle    8005d9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 08             	lea    0x8(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 50 04             	mov    0x4(%eax),%edx
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d7:	eb 32                	jmp    80060b <vprintfmt+0x2d1>
	else if (lflag)
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	74 18                	je     8005f5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005eb:	89 c1                	mov    %eax,%ecx
  8005ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f3:	eb 16                	jmp    80060b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 c1                	mov    %eax,%ecx
  800605:	c1 f9 1f             	sar    $0x1f,%ecx
  800608:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800611:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800616:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061a:	79 74                	jns    800690 <vprintfmt+0x356>
				putch('-', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 2d                	push   $0x2d
  800622:	ff d6                	call   *%esi
				num = -(long long) num;
  800624:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800627:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062a:	f7 d8                	neg    %eax
  80062c:	83 d2 00             	adc    $0x0,%edx
  80062f:	f7 da                	neg    %edx
  800631:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800639:	eb 55                	jmp    800690 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 83 fc ff ff       	call   8002c6 <getuint>
			base = 10;
  800643:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800648:	eb 46                	jmp    800690 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 74 fc ff ff       	call   8002c6 <getuint>
			base = 8;
  800652:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800657:	eb 37                	jmp    800690 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 30                	push   $0x30
  80065f:	ff d6                	call   *%esi
			putch('x', putdat);
  800661:	83 c4 08             	add    $0x8,%esp
  800664:	53                   	push   %ebx
  800665:	6a 78                	push   $0x78
  800667:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800672:	8b 00                	mov    (%eax),%eax
  800674:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800679:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800681:	eb 0d                	jmp    800690 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 3b fc ff ff       	call   8002c6 <getuint>
			base = 16;
  80068b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800697:	57                   	push   %edi
  800698:	ff 75 e0             	pushl  -0x20(%ebp)
  80069b:	51                   	push   %ecx
  80069c:	52                   	push   %edx
  80069d:	50                   	push   %eax
  80069e:	89 da                	mov    %ebx,%edx
  8006a0:	89 f0                	mov    %esi,%eax
  8006a2:	e8 70 fb ff ff       	call   800217 <printnum>
			break;
  8006a7:	83 c4 20             	add    $0x20,%esp
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ad:	e9 ae fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	51                   	push   %ecx
  8006b7:	ff d6                	call   *%esi
			break;
  8006b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006bf:	e9 9c fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	6a 25                	push   $0x25
  8006ca:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	eb 03                	jmp    8006d4 <vprintfmt+0x39a>
  8006d1:	83 ef 01             	sub    $0x1,%edi
  8006d4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d8:	75 f7                	jne    8006d1 <vprintfmt+0x397>
  8006da:	e9 81 fc ff ff       	jmp    800360 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e2:	5b                   	pop    %ebx
  8006e3:	5e                   	pop    %esi
  8006e4:	5f                   	pop    %edi
  8006e5:	5d                   	pop    %ebp
  8006e6:	c3                   	ret    

008006e7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	83 ec 18             	sub    $0x18,%esp
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800704:	85 c0                	test   %eax,%eax
  800706:	74 26                	je     80072e <vsnprintf+0x47>
  800708:	85 d2                	test   %edx,%edx
  80070a:	7e 22                	jle    80072e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070c:	ff 75 14             	pushl  0x14(%ebp)
  80070f:	ff 75 10             	pushl  0x10(%ebp)
  800712:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	68 00 03 80 00       	push   $0x800300
  80071b:	e8 1a fc ff ff       	call   80033a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800720:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800723:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	eb 05                	jmp    800733 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073e:	50                   	push   %eax
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	ff 75 08             	pushl  0x8(%ebp)
  800748:	e8 9a ff ff ff       	call   8006e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
  80075a:	eb 03                	jmp    80075f <strlen+0x10>
		n++;
  80075c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800763:	75 f7                	jne    80075c <strlen+0xd>
		n++;
	return n;
}
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800770:	ba 00 00 00 00       	mov    $0x0,%edx
  800775:	eb 03                	jmp    80077a <strnlen+0x13>
		n++;
  800777:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077a:	39 c2                	cmp    %eax,%edx
  80077c:	74 08                	je     800786 <strnlen+0x1f>
  80077e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800782:	75 f3                	jne    800777 <strnlen+0x10>
  800784:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800792:	89 c2                	mov    %eax,%edx
  800794:	83 c2 01             	add    $0x1,%edx
  800797:	83 c1 01             	add    $0x1,%ecx
  80079a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079e:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a1:	84 db                	test   %bl,%bl
  8007a3:	75 ef                	jne    800794 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a5:	5b                   	pop    %ebx
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007af:	53                   	push   %ebx
  8007b0:	e8 9a ff ff ff       	call   80074f <strlen>
  8007b5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b8:	ff 75 0c             	pushl  0xc(%ebp)
  8007bb:	01 d8                	add    %ebx,%eax
  8007bd:	50                   	push   %eax
  8007be:	e8 c5 ff ff ff       	call   800788 <strcpy>
	return dst;
}
  8007c3:	89 d8                	mov    %ebx,%eax
  8007c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d5:	89 f3                	mov    %esi,%ebx
  8007d7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007da:	89 f2                	mov    %esi,%edx
  8007dc:	eb 0f                	jmp    8007ed <strncpy+0x23>
		*dst++ = *src;
  8007de:	83 c2 01             	add    $0x1,%edx
  8007e1:	0f b6 01             	movzbl (%ecx),%eax
  8007e4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ea:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ed:	39 da                	cmp    %ebx,%edx
  8007ef:	75 ed                	jne    8007de <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f1:	89 f0                	mov    %esi,%eax
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	8b 55 10             	mov    0x10(%ebp),%edx
  800805:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800807:	85 d2                	test   %edx,%edx
  800809:	74 21                	je     80082c <strlcpy+0x35>
  80080b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080f:	89 f2                	mov    %esi,%edx
  800811:	eb 09                	jmp    80081c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	83 c1 01             	add    $0x1,%ecx
  800819:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081c:	39 c2                	cmp    %eax,%edx
  80081e:	74 09                	je     800829 <strlcpy+0x32>
  800820:	0f b6 19             	movzbl (%ecx),%ebx
  800823:	84 db                	test   %bl,%bl
  800825:	75 ec                	jne    800813 <strlcpy+0x1c>
  800827:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800829:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082c:	29 f0                	sub    %esi,%eax
}
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083b:	eb 06                	jmp    800843 <strcmp+0x11>
		p++, q++;
  80083d:	83 c1 01             	add    $0x1,%ecx
  800840:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800843:	0f b6 01             	movzbl (%ecx),%eax
  800846:	84 c0                	test   %al,%al
  800848:	74 04                	je     80084e <strcmp+0x1c>
  80084a:	3a 02                	cmp    (%edx),%al
  80084c:	74 ef                	je     80083d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084e:	0f b6 c0             	movzbl %al,%eax
  800851:	0f b6 12             	movzbl (%edx),%edx
  800854:	29 d0                	sub    %edx,%eax
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	89 c3                	mov    %eax,%ebx
  800864:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800867:	eb 06                	jmp    80086f <strncmp+0x17>
		n--, p++, q++;
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086f:	39 d8                	cmp    %ebx,%eax
  800871:	74 15                	je     800888 <strncmp+0x30>
  800873:	0f b6 08             	movzbl (%eax),%ecx
  800876:	84 c9                	test   %cl,%cl
  800878:	74 04                	je     80087e <strncmp+0x26>
  80087a:	3a 0a                	cmp    (%edx),%cl
  80087c:	74 eb                	je     800869 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087e:	0f b6 00             	movzbl (%eax),%eax
  800881:	0f b6 12             	movzbl (%edx),%edx
  800884:	29 d0                	sub    %edx,%eax
  800886:	eb 05                	jmp    80088d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800888:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088d:	5b                   	pop    %ebx
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089a:	eb 07                	jmp    8008a3 <strchr+0x13>
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	74 0f                	je     8008af <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a0:	83 c0 01             	add    $0x1,%eax
  8008a3:	0f b6 10             	movzbl (%eax),%edx
  8008a6:	84 d2                	test   %dl,%dl
  8008a8:	75 f2                	jne    80089c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bb:	eb 03                	jmp    8008c0 <strfind+0xf>
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c3:	38 ca                	cmp    %cl,%dl
  8008c5:	74 04                	je     8008cb <strfind+0x1a>
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	75 f2                	jne    8008bd <strfind+0xc>
			break;
	return (char *) s;
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	57                   	push   %edi
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d9:	85 c9                	test   %ecx,%ecx
  8008db:	74 36                	je     800913 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e3:	75 28                	jne    80090d <memset+0x40>
  8008e5:	f6 c1 03             	test   $0x3,%cl
  8008e8:	75 23                	jne    80090d <memset+0x40>
		c &= 0xFF;
  8008ea:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ee:	89 d3                	mov    %edx,%ebx
  8008f0:	c1 e3 08             	shl    $0x8,%ebx
  8008f3:	89 d6                	mov    %edx,%esi
  8008f5:	c1 e6 18             	shl    $0x18,%esi
  8008f8:	89 d0                	mov    %edx,%eax
  8008fa:	c1 e0 10             	shl    $0x10,%eax
  8008fd:	09 f0                	or     %esi,%eax
  8008ff:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800901:	89 d8                	mov    %ebx,%eax
  800903:	09 d0                	or     %edx,%eax
  800905:	c1 e9 02             	shr    $0x2,%ecx
  800908:	fc                   	cld    
  800909:	f3 ab                	rep stos %eax,%es:(%edi)
  80090b:	eb 06                	jmp    800913 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800910:	fc                   	cld    
  800911:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800913:	89 f8                	mov    %edi,%eax
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 75 0c             	mov    0xc(%ebp),%esi
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800928:	39 c6                	cmp    %eax,%esi
  80092a:	73 35                	jae    800961 <memmove+0x47>
  80092c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092f:	39 d0                	cmp    %edx,%eax
  800931:	73 2e                	jae    800961 <memmove+0x47>
		s += n;
		d += n;
  800933:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	89 d6                	mov    %edx,%esi
  800938:	09 fe                	or     %edi,%esi
  80093a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800940:	75 13                	jne    800955 <memmove+0x3b>
  800942:	f6 c1 03             	test   $0x3,%cl
  800945:	75 0e                	jne    800955 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800947:	83 ef 04             	sub    $0x4,%edi
  80094a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094d:	c1 e9 02             	shr    $0x2,%ecx
  800950:	fd                   	std    
  800951:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800953:	eb 09                	jmp    80095e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800955:	83 ef 01             	sub    $0x1,%edi
  800958:	8d 72 ff             	lea    -0x1(%edx),%esi
  80095b:	fd                   	std    
  80095c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095e:	fc                   	cld    
  80095f:	eb 1d                	jmp    80097e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	89 f2                	mov    %esi,%edx
  800963:	09 c2                	or     %eax,%edx
  800965:	f6 c2 03             	test   $0x3,%dl
  800968:	75 0f                	jne    800979 <memmove+0x5f>
  80096a:	f6 c1 03             	test   $0x3,%cl
  80096d:	75 0a                	jne    800979 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80096f:	c1 e9 02             	shr    $0x2,%ecx
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 05                	jmp    80097e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800979:	89 c7                	mov    %eax,%edi
  80097b:	fc                   	cld    
  80097c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800985:	ff 75 10             	pushl  0x10(%ebp)
  800988:	ff 75 0c             	pushl  0xc(%ebp)
  80098b:	ff 75 08             	pushl  0x8(%ebp)
  80098e:	e8 87 ff ff ff       	call   80091a <memmove>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	89 c6                	mov    %eax,%esi
  8009a2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a5:	eb 1a                	jmp    8009c1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009a7:	0f b6 08             	movzbl (%eax),%ecx
  8009aa:	0f b6 1a             	movzbl (%edx),%ebx
  8009ad:	38 d9                	cmp    %bl,%cl
  8009af:	74 0a                	je     8009bb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b1:	0f b6 c1             	movzbl %cl,%eax
  8009b4:	0f b6 db             	movzbl %bl,%ebx
  8009b7:	29 d8                	sub    %ebx,%eax
  8009b9:	eb 0f                	jmp    8009ca <memcmp+0x35>
		s1++, s2++;
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c1:	39 f0                	cmp    %esi,%eax
  8009c3:	75 e2                	jne    8009a7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d5:	89 c1                	mov    %eax,%ecx
  8009d7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009da:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009de:	eb 0a                	jmp    8009ea <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e0:	0f b6 10             	movzbl (%eax),%edx
  8009e3:	39 da                	cmp    %ebx,%edx
  8009e5:	74 07                	je     8009ee <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e7:	83 c0 01             	add    $0x1,%eax
  8009ea:	39 c8                	cmp    %ecx,%eax
  8009ec:	72 f2                	jb     8009e0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	57                   	push   %edi
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fd:	eb 03                	jmp    800a02 <strtol+0x11>
		s++;
  8009ff:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a02:	0f b6 01             	movzbl (%ecx),%eax
  800a05:	3c 20                	cmp    $0x20,%al
  800a07:	74 f6                	je     8009ff <strtol+0xe>
  800a09:	3c 09                	cmp    $0x9,%al
  800a0b:	74 f2                	je     8009ff <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0d:	3c 2b                	cmp    $0x2b,%al
  800a0f:	75 0a                	jne    800a1b <strtol+0x2a>
		s++;
  800a11:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
  800a19:	eb 11                	jmp    800a2c <strtol+0x3b>
  800a1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a20:	3c 2d                	cmp    $0x2d,%al
  800a22:	75 08                	jne    800a2c <strtol+0x3b>
		s++, neg = 1;
  800a24:	83 c1 01             	add    $0x1,%ecx
  800a27:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a32:	75 15                	jne    800a49 <strtol+0x58>
  800a34:	80 39 30             	cmpb   $0x30,(%ecx)
  800a37:	75 10                	jne    800a49 <strtol+0x58>
  800a39:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3d:	75 7c                	jne    800abb <strtol+0xca>
		s += 2, base = 16;
  800a3f:	83 c1 02             	add    $0x2,%ecx
  800a42:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a47:	eb 16                	jmp    800a5f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a49:	85 db                	test   %ebx,%ebx
  800a4b:	75 12                	jne    800a5f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a52:	80 39 30             	cmpb   $0x30,(%ecx)
  800a55:	75 08                	jne    800a5f <strtol+0x6e>
		s++, base = 8;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a67:	0f b6 11             	movzbl (%ecx),%edx
  800a6a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 09             	cmp    $0x9,%bl
  800a72:	77 08                	ja     800a7c <strtol+0x8b>
			dig = *s - '0';
  800a74:	0f be d2             	movsbl %dl,%edx
  800a77:	83 ea 30             	sub    $0x30,%edx
  800a7a:	eb 22                	jmp    800a9e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a7c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 08                	ja     800a8e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 57             	sub    $0x57,%edx
  800a8c:	eb 10                	jmp    800a9e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a8e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 19             	cmp    $0x19,%bl
  800a96:	77 16                	ja     800aae <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa1:	7d 0b                	jge    800aae <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aaa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aac:	eb b9                	jmp    800a67 <strtol+0x76>

	if (endptr)
  800aae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab2:	74 0d                	je     800ac1 <strtol+0xd0>
		*endptr = (char *) s;
  800ab4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab7:	89 0e                	mov    %ecx,(%esi)
  800ab9:	eb 06                	jmp    800ac1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	74 98                	je     800a57 <strtol+0x66>
  800abf:	eb 9e                	jmp    800a5f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	f7 da                	neg    %edx
  800ac5:	85 ff                	test   %edi,%edi
  800ac7:	0f 45 c2             	cmovne %edx,%eax
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	89 c3                	mov    %eax,%ebx
  800ae2:	89 c7                	mov    %eax,%edi
  800ae4:	89 c6                	mov    %eax,%esi
  800ae6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_cgetc>:

int
sys_cgetc(void)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af3:	ba 00 00 00 00       	mov    $0x0,%edx
  800af8:	b8 01 00 00 00       	mov    $0x1,%eax
  800afd:	89 d1                	mov    %edx,%ecx
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	89 d7                	mov    %edx,%edi
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b22:	89 cb                	mov    %ecx,%ebx
  800b24:	89 cf                	mov    %ecx,%edi
  800b26:	89 ce                	mov    %ecx,%esi
  800b28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	7e 17                	jle    800b45 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	50                   	push   %eax
  800b32:	6a 03                	push   $0x3
  800b34:	68 3f 27 80 00       	push   $0x80273f
  800b39:	6a 23                	push   $0x23
  800b3b:	68 5c 27 80 00       	push   $0x80275c
  800b40:	e8 e5 f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5d:	89 d1                	mov    %edx,%ecx
  800b5f:	89 d3                	mov    %edx,%ebx
  800b61:	89 d7                	mov    %edx,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_yield>:

void
sys_yield(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	be 00 00 00 00       	mov    $0x0,%esi
  800b99:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba7:	89 f7                	mov    %esi,%edi
  800ba9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 17                	jle    800bc6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 04                	push   $0x4
  800bb5:	68 3f 27 80 00       	push   $0x80273f
  800bba:	6a 23                	push   $0x23
  800bbc:	68 5c 27 80 00       	push   $0x80275c
  800bc1:	e8 64 f5 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be8:	8b 75 18             	mov    0x18(%ebp),%esi
  800beb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7e 17                	jle    800c08 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 05                	push   $0x5
  800bf7:	68 3f 27 80 00       	push   $0x80273f
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 5c 27 80 00       	push   $0x80275c
  800c03:	e8 22 f5 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 df                	mov    %ebx,%edi
  800c2b:	89 de                	mov    %ebx,%esi
  800c2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7e 17                	jle    800c4a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 06                	push   $0x6
  800c39:	68 3f 27 80 00       	push   $0x80273f
  800c3e:	6a 23                	push   $0x23
  800c40:	68 5c 27 80 00       	push   $0x80275c
  800c45:	e8 e0 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	b8 08 00 00 00       	mov    $0x8,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 17                	jle    800c8c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	50                   	push   %eax
  800c79:	6a 08                	push   $0x8
  800c7b:	68 3f 27 80 00       	push   $0x80273f
  800c80:	6a 23                	push   $0x23
  800c82:	68 5c 27 80 00       	push   $0x80275c
  800c87:	e8 9e f4 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 17                	jle    800cce <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 09                	push   $0x9
  800cbd:	68 3f 27 80 00       	push   $0x80273f
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 5c 27 80 00       	push   $0x80275c
  800cc9:	e8 5c f4 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	8b 55 08             	mov    0x8(%ebp),%edx
  800cef:	89 df                	mov    %ebx,%edi
  800cf1:	89 de                	mov    %ebx,%esi
  800cf3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7e 17                	jle    800d10 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 0a                	push   $0xa
  800cff:	68 3f 27 80 00       	push   $0x80273f
  800d04:	6a 23                	push   $0x23
  800d06:	68 5c 27 80 00       	push   $0x80275c
  800d0b:	e8 1a f4 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	be 00 00 00 00       	mov    $0x0,%esi
  800d23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d31:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d34:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d49:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	89 cb                	mov    %ecx,%ebx
  800d53:	89 cf                	mov    %ecx,%edi
  800d55:	89 ce                	mov    %ecx,%esi
  800d57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 17                	jle    800d74 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 0d                	push   $0xd
  800d63:	68 3f 27 80 00       	push   $0x80273f
  800d68:	6a 23                	push   $0x23
  800d6a:	68 5c 27 80 00       	push   $0x80275c
  800d6f:	e8 b6 f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d8c:	89 d1                	mov    %edx,%ecx
  800d8e:	89 d3                	mov    %edx,%ebx
  800d90:	89 d7                	mov    %edx,%edi
  800d92:	89 d6                	mov    %edx,%esi
  800d94:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7e 17                	jle    800dd5 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	50                   	push   %eax
  800dc2:	6a 0f                	push   $0xf
  800dc4:	68 3f 27 80 00       	push   $0x80273f
  800dc9:	6a 23                	push   $0x23
  800dcb:	68 5c 27 80 00       	push   $0x80275c
  800dd0:	e8 55 f3 ff ff       	call   80012a <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	b8 10 00 00 00       	mov    $0x10,%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	8b 55 08             	mov    0x8(%ebp),%edx
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7e 17                	jle    800e17 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e00:	83 ec 0c             	sub    $0xc,%esp
  800e03:	50                   	push   %eax
  800e04:	6a 10                	push   $0x10
  800e06:	68 3f 27 80 00       	push   $0x80273f
  800e0b:	6a 23                	push   $0x23
  800e0d:	68 5c 27 80 00       	push   $0x80275c
  800e12:	e8 13 f3 ff ff       	call   80012a <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e25:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e2c:	75 2e                	jne    800e5c <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800e2e:	e8 1a fd ff ff       	call   800b4d <sys_getenvid>
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	68 07 0e 00 00       	push   $0xe07
  800e3b:	68 00 f0 bf ee       	push   $0xeebff000
  800e40:	50                   	push   %eax
  800e41:	e8 45 fd ff ff       	call   800b8b <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800e46:	e8 02 fd ff ff       	call   800b4d <sys_getenvid>
  800e4b:	83 c4 08             	add    $0x8,%esp
  800e4e:	68 66 0e 80 00       	push   $0x800e66
  800e53:	50                   	push   %eax
  800e54:	e8 7d fe ff ff       	call   800cd6 <sys_env_set_pgfault_upcall>
  800e59:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5f:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e66:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e67:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e6c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e6e:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  800e71:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800e75:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800e79:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800e7c:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800e7f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  800e80:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800e83:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800e84:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800e85:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800e89:	c3                   	ret    

00800e8a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e90:	05 00 00 00 30       	add    $0x30000000,%eax
  800e95:	c1 e8 0c             	shr    $0xc,%eax
}
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eaa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ebc:	89 c2                	mov    %eax,%edx
  800ebe:	c1 ea 16             	shr    $0x16,%edx
  800ec1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec8:	f6 c2 01             	test   $0x1,%dl
  800ecb:	74 11                	je     800ede <fd_alloc+0x2d>
  800ecd:	89 c2                	mov    %eax,%edx
  800ecf:	c1 ea 0c             	shr    $0xc,%edx
  800ed2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed9:	f6 c2 01             	test   $0x1,%dl
  800edc:	75 09                	jne    800ee7 <fd_alloc+0x36>
			*fd_store = fd;
  800ede:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	eb 17                	jmp    800efe <fd_alloc+0x4d>
  800ee7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eec:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef1:	75 c9                	jne    800ebc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ef9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f06:	83 f8 1f             	cmp    $0x1f,%eax
  800f09:	77 36                	ja     800f41 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0b:	c1 e0 0c             	shl    $0xc,%eax
  800f0e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f13:	89 c2                	mov    %eax,%edx
  800f15:	c1 ea 16             	shr    $0x16,%edx
  800f18:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1f:	f6 c2 01             	test   $0x1,%dl
  800f22:	74 24                	je     800f48 <fd_lookup+0x48>
  800f24:	89 c2                	mov    %eax,%edx
  800f26:	c1 ea 0c             	shr    $0xc,%edx
  800f29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f30:	f6 c2 01             	test   $0x1,%dl
  800f33:	74 1a                	je     800f4f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f38:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3f:	eb 13                	jmp    800f54 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f46:	eb 0c                	jmp    800f54 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4d:	eb 05                	jmp    800f54 <fd_lookup+0x54>
  800f4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	83 ec 08             	sub    $0x8,%esp
  800f5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5f:	ba ec 27 80 00       	mov    $0x8027ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f64:	eb 13                	jmp    800f79 <dev_lookup+0x23>
  800f66:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f69:	39 08                	cmp    %ecx,(%eax)
  800f6b:	75 0c                	jne    800f79 <dev_lookup+0x23>
			*dev = devtab[i];
  800f6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f70:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
  800f77:	eb 2e                	jmp    800fa7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f79:	8b 02                	mov    (%edx),%eax
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	75 e7                	jne    800f66 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f7f:	a1 08 40 80 00       	mov    0x804008,%eax
  800f84:	8b 40 48             	mov    0x48(%eax),%eax
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	51                   	push   %ecx
  800f8b:	50                   	push   %eax
  800f8c:	68 6c 27 80 00       	push   $0x80276c
  800f91:	e8 6d f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800f96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    

00800fa9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
  800fae:	83 ec 10             	sub    $0x10,%esp
  800fb1:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fba:	50                   	push   %eax
  800fbb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc1:	c1 e8 0c             	shr    $0xc,%eax
  800fc4:	50                   	push   %eax
  800fc5:	e8 36 ff ff ff       	call   800f00 <fd_lookup>
  800fca:	83 c4 08             	add    $0x8,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 05                	js     800fd6 <fd_close+0x2d>
	    || fd != fd2)
  800fd1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd4:	74 0c                	je     800fe2 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fd6:	84 db                	test   %bl,%bl
  800fd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdd:	0f 44 c2             	cmove  %edx,%eax
  800fe0:	eb 41                	jmp    801023 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe2:	83 ec 08             	sub    $0x8,%esp
  800fe5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe8:	50                   	push   %eax
  800fe9:	ff 36                	pushl  (%esi)
  800feb:	e8 66 ff ff ff       	call   800f56 <dev_lookup>
  800ff0:	89 c3                	mov    %eax,%ebx
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	78 1a                	js     801013 <fd_close+0x6a>
		if (dev->dev_close)
  800ff9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ffc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fff:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801004:	85 c0                	test   %eax,%eax
  801006:	74 0b                	je     801013 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	56                   	push   %esi
  80100c:	ff d0                	call   *%eax
  80100e:	89 c3                	mov    %eax,%ebx
  801010:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801013:	83 ec 08             	sub    $0x8,%esp
  801016:	56                   	push   %esi
  801017:	6a 00                	push   $0x0
  801019:	e8 f2 fb ff ff       	call   800c10 <sys_page_unmap>
	return r;
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	89 d8                	mov    %ebx,%eax
}
  801023:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801026:	5b                   	pop    %ebx
  801027:	5e                   	pop    %esi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801030:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801033:	50                   	push   %eax
  801034:	ff 75 08             	pushl  0x8(%ebp)
  801037:	e8 c4 fe ff ff       	call   800f00 <fd_lookup>
  80103c:	83 c4 08             	add    $0x8,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 10                	js     801053 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	6a 01                	push   $0x1
  801048:	ff 75 f4             	pushl  -0xc(%ebp)
  80104b:	e8 59 ff ff ff       	call   800fa9 <fd_close>
  801050:	83 c4 10             	add    $0x10,%esp
}
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <close_all>:

void
close_all(void)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	53                   	push   %ebx
  801059:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	53                   	push   %ebx
  801065:	e8 c0 ff ff ff       	call   80102a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80106a:	83 c3 01             	add    $0x1,%ebx
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	83 fb 20             	cmp    $0x20,%ebx
  801073:	75 ec                	jne    801061 <close_all+0xc>
		close(i);
}
  801075:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801078:	c9                   	leave  
  801079:	c3                   	ret    

0080107a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	57                   	push   %edi
  80107e:	56                   	push   %esi
  80107f:	53                   	push   %ebx
  801080:	83 ec 2c             	sub    $0x2c,%esp
  801083:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801086:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801089:	50                   	push   %eax
  80108a:	ff 75 08             	pushl  0x8(%ebp)
  80108d:	e8 6e fe ff ff       	call   800f00 <fd_lookup>
  801092:	83 c4 08             	add    $0x8,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	0f 88 c1 00 00 00    	js     80115e <dup+0xe4>
		return r;
	close(newfdnum);
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	56                   	push   %esi
  8010a1:	e8 84 ff ff ff       	call   80102a <close>

	newfd = INDEX2FD(newfdnum);
  8010a6:	89 f3                	mov    %esi,%ebx
  8010a8:	c1 e3 0c             	shl    $0xc,%ebx
  8010ab:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010b1:	83 c4 04             	add    $0x4,%esp
  8010b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b7:	e8 de fd ff ff       	call   800e9a <fd2data>
  8010bc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010be:	89 1c 24             	mov    %ebx,(%esp)
  8010c1:	e8 d4 fd ff ff       	call   800e9a <fd2data>
  8010c6:	83 c4 10             	add    $0x10,%esp
  8010c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010cc:	89 f8                	mov    %edi,%eax
  8010ce:	c1 e8 16             	shr    $0x16,%eax
  8010d1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d8:	a8 01                	test   $0x1,%al
  8010da:	74 37                	je     801113 <dup+0x99>
  8010dc:	89 f8                	mov    %edi,%eax
  8010de:	c1 e8 0c             	shr    $0xc,%eax
  8010e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e8:	f6 c2 01             	test   $0x1,%dl
  8010eb:	74 26                	je     801113 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f4:	83 ec 0c             	sub    $0xc,%esp
  8010f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fc:	50                   	push   %eax
  8010fd:	ff 75 d4             	pushl  -0x2c(%ebp)
  801100:	6a 00                	push   $0x0
  801102:	57                   	push   %edi
  801103:	6a 00                	push   $0x0
  801105:	e8 c4 fa ff ff       	call   800bce <sys_page_map>
  80110a:	89 c7                	mov    %eax,%edi
  80110c:	83 c4 20             	add    $0x20,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 2e                	js     801141 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801113:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801116:	89 d0                	mov    %edx,%eax
  801118:	c1 e8 0c             	shr    $0xc,%eax
  80111b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	25 07 0e 00 00       	and    $0xe07,%eax
  80112a:	50                   	push   %eax
  80112b:	53                   	push   %ebx
  80112c:	6a 00                	push   $0x0
  80112e:	52                   	push   %edx
  80112f:	6a 00                	push   $0x0
  801131:	e8 98 fa ff ff       	call   800bce <sys_page_map>
  801136:	89 c7                	mov    %eax,%edi
  801138:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80113b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113d:	85 ff                	test   %edi,%edi
  80113f:	79 1d                	jns    80115e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	53                   	push   %ebx
  801145:	6a 00                	push   $0x0
  801147:	e8 c4 fa ff ff       	call   800c10 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114c:	83 c4 08             	add    $0x8,%esp
  80114f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801152:	6a 00                	push   $0x0
  801154:	e8 b7 fa ff ff       	call   800c10 <sys_page_unmap>
	return r;
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	89 f8                	mov    %edi,%eax
}
  80115e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801161:	5b                   	pop    %ebx
  801162:	5e                   	pop    %esi
  801163:	5f                   	pop    %edi
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	53                   	push   %ebx
  80116a:	83 ec 14             	sub    $0x14,%esp
  80116d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801170:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801173:	50                   	push   %eax
  801174:	53                   	push   %ebx
  801175:	e8 86 fd ff ff       	call   800f00 <fd_lookup>
  80117a:	83 c4 08             	add    $0x8,%esp
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	85 c0                	test   %eax,%eax
  801181:	78 6d                	js     8011f0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801183:	83 ec 08             	sub    $0x8,%esp
  801186:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801189:	50                   	push   %eax
  80118a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118d:	ff 30                	pushl  (%eax)
  80118f:	e8 c2 fd ff ff       	call   800f56 <dev_lookup>
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	78 4c                	js     8011e7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80119b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80119e:	8b 42 08             	mov    0x8(%edx),%eax
  8011a1:	83 e0 03             	and    $0x3,%eax
  8011a4:	83 f8 01             	cmp    $0x1,%eax
  8011a7:	75 21                	jne    8011ca <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ae:	8b 40 48             	mov    0x48(%eax),%eax
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	53                   	push   %ebx
  8011b5:	50                   	push   %eax
  8011b6:	68 b0 27 80 00       	push   $0x8027b0
  8011bb:	e8 43 f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c8:	eb 26                	jmp    8011f0 <read+0x8a>
	}
	if (!dev->dev_read)
  8011ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cd:	8b 40 08             	mov    0x8(%eax),%eax
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	74 17                	je     8011eb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	ff 75 10             	pushl  0x10(%ebp)
  8011da:	ff 75 0c             	pushl  0xc(%ebp)
  8011dd:	52                   	push   %edx
  8011de:	ff d0                	call   *%eax
  8011e0:	89 c2                	mov    %eax,%edx
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	eb 09                	jmp    8011f0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	eb 05                	jmp    8011f0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011f0:	89 d0                	mov    %edx,%eax
  8011f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    

008011f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	57                   	push   %edi
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	8b 7d 08             	mov    0x8(%ebp),%edi
  801203:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801206:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120b:	eb 21                	jmp    80122e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	89 f0                	mov    %esi,%eax
  801212:	29 d8                	sub    %ebx,%eax
  801214:	50                   	push   %eax
  801215:	89 d8                	mov    %ebx,%eax
  801217:	03 45 0c             	add    0xc(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	57                   	push   %edi
  80121c:	e8 45 ff ff ff       	call   801166 <read>
		if (m < 0)
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 10                	js     801238 <readn+0x41>
			return m;
		if (m == 0)
  801228:	85 c0                	test   %eax,%eax
  80122a:	74 0a                	je     801236 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122c:	01 c3                	add    %eax,%ebx
  80122e:	39 f3                	cmp    %esi,%ebx
  801230:	72 db                	jb     80120d <readn+0x16>
  801232:	89 d8                	mov    %ebx,%eax
  801234:	eb 02                	jmp    801238 <readn+0x41>
  801236:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5f                   	pop    %edi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	53                   	push   %ebx
  801244:	83 ec 14             	sub    $0x14,%esp
  801247:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124d:	50                   	push   %eax
  80124e:	53                   	push   %ebx
  80124f:	e8 ac fc ff ff       	call   800f00 <fd_lookup>
  801254:	83 c4 08             	add    $0x8,%esp
  801257:	89 c2                	mov    %eax,%edx
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 68                	js     8012c5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125d:	83 ec 08             	sub    $0x8,%esp
  801260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801263:	50                   	push   %eax
  801264:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801267:	ff 30                	pushl  (%eax)
  801269:	e8 e8 fc ff ff       	call   800f56 <dev_lookup>
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	85 c0                	test   %eax,%eax
  801273:	78 47                	js     8012bc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801275:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801278:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127c:	75 21                	jne    80129f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80127e:	a1 08 40 80 00       	mov    0x804008,%eax
  801283:	8b 40 48             	mov    0x48(%eax),%eax
  801286:	83 ec 04             	sub    $0x4,%esp
  801289:	53                   	push   %ebx
  80128a:	50                   	push   %eax
  80128b:	68 cc 27 80 00       	push   $0x8027cc
  801290:	e8 6e ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129d:	eb 26                	jmp    8012c5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80129f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a2:	8b 52 0c             	mov    0xc(%edx),%edx
  8012a5:	85 d2                	test   %edx,%edx
  8012a7:	74 17                	je     8012c0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012a9:	83 ec 04             	sub    $0x4,%esp
  8012ac:	ff 75 10             	pushl  0x10(%ebp)
  8012af:	ff 75 0c             	pushl  0xc(%ebp)
  8012b2:	50                   	push   %eax
  8012b3:	ff d2                	call   *%edx
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	eb 09                	jmp    8012c5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bc:	89 c2                	mov    %eax,%edx
  8012be:	eb 05                	jmp    8012c5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012c5:	89 d0                	mov    %edx,%eax
  8012c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    

008012cc <seek>:

int
seek(int fdnum, off_t offset)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	ff 75 08             	pushl  0x8(%ebp)
  8012d9:	e8 22 fc ff ff       	call   800f00 <fd_lookup>
  8012de:	83 c4 08             	add    $0x8,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 0e                	js     8012f3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012eb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f3:	c9                   	leave  
  8012f4:	c3                   	ret    

008012f5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	53                   	push   %ebx
  8012f9:	83 ec 14             	sub    $0x14,%esp
  8012fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801302:	50                   	push   %eax
  801303:	53                   	push   %ebx
  801304:	e8 f7 fb ff ff       	call   800f00 <fd_lookup>
  801309:	83 c4 08             	add    $0x8,%esp
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 65                	js     801377 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131c:	ff 30                	pushl  (%eax)
  80131e:	e8 33 fc ff ff       	call   800f56 <dev_lookup>
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	78 44                	js     80136e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801331:	75 21                	jne    801354 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801333:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801338:	8b 40 48             	mov    0x48(%eax),%eax
  80133b:	83 ec 04             	sub    $0x4,%esp
  80133e:	53                   	push   %ebx
  80133f:	50                   	push   %eax
  801340:	68 8c 27 80 00       	push   $0x80278c
  801345:	e8 b9 ee ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801352:	eb 23                	jmp    801377 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801354:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801357:	8b 52 18             	mov    0x18(%edx),%edx
  80135a:	85 d2                	test   %edx,%edx
  80135c:	74 14                	je     801372 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	ff 75 0c             	pushl  0xc(%ebp)
  801364:	50                   	push   %eax
  801365:	ff d2                	call   *%edx
  801367:	89 c2                	mov    %eax,%edx
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	eb 09                	jmp    801377 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136e:	89 c2                	mov    %eax,%edx
  801370:	eb 05                	jmp    801377 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801372:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801377:	89 d0                	mov    %edx,%eax
  801379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137c:	c9                   	leave  
  80137d:	c3                   	ret    

0080137e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	53                   	push   %ebx
  801382:	83 ec 14             	sub    $0x14,%esp
  801385:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801388:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138b:	50                   	push   %eax
  80138c:	ff 75 08             	pushl  0x8(%ebp)
  80138f:	e8 6c fb ff ff       	call   800f00 <fd_lookup>
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	89 c2                	mov    %eax,%edx
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 58                	js     8013f5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a7:	ff 30                	pushl  (%eax)
  8013a9:	e8 a8 fb ff ff       	call   800f56 <dev_lookup>
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 37                	js     8013ec <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013bc:	74 32                	je     8013f0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013be:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c8:	00 00 00 
	stat->st_isdir = 0;
  8013cb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d2:	00 00 00 
	stat->st_dev = dev;
  8013d5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	53                   	push   %ebx
  8013df:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e2:	ff 50 14             	call   *0x14(%eax)
  8013e5:	89 c2                	mov    %eax,%edx
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	eb 09                	jmp    8013f5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ec:	89 c2                	mov    %eax,%edx
  8013ee:	eb 05                	jmp    8013f5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f5:	89 d0                	mov    %edx,%eax
  8013f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	56                   	push   %esi
  801400:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801401:	83 ec 08             	sub    $0x8,%esp
  801404:	6a 00                	push   $0x0
  801406:	ff 75 08             	pushl  0x8(%ebp)
  801409:	e8 d6 01 00 00       	call   8015e4 <open>
  80140e:	89 c3                	mov    %eax,%ebx
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	78 1b                	js     801432 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	ff 75 0c             	pushl  0xc(%ebp)
  80141d:	50                   	push   %eax
  80141e:	e8 5b ff ff ff       	call   80137e <fstat>
  801423:	89 c6                	mov    %eax,%esi
	close(fd);
  801425:	89 1c 24             	mov    %ebx,(%esp)
  801428:	e8 fd fb ff ff       	call   80102a <close>
	return r;
  80142d:	83 c4 10             	add    $0x10,%esp
  801430:	89 f0                	mov    %esi,%eax
}
  801432:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801435:	5b                   	pop    %ebx
  801436:	5e                   	pop    %esi
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	56                   	push   %esi
  80143d:	53                   	push   %ebx
  80143e:	89 c6                	mov    %eax,%esi
  801440:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801442:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801449:	75 12                	jne    80145d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80144b:	83 ec 0c             	sub    $0xc,%esp
  80144e:	6a 01                	push   $0x1
  801450:	e8 34 0c 00 00       	call   802089 <ipc_find_env>
  801455:	a3 00 40 80 00       	mov    %eax,0x804000
  80145a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80145d:	6a 07                	push   $0x7
  80145f:	68 00 50 80 00       	push   $0x805000
  801464:	56                   	push   %esi
  801465:	ff 35 00 40 80 00    	pushl  0x804000
  80146b:	e8 c5 0b 00 00       	call   802035 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801470:	83 c4 0c             	add    $0xc,%esp
  801473:	6a 00                	push   $0x0
  801475:	53                   	push   %ebx
  801476:	6a 00                	push   $0x0
  801478:	e8 51 0b 00 00       	call   801fce <ipc_recv>
}
  80147d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801480:	5b                   	pop    %ebx
  801481:	5e                   	pop    %esi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80148a:	8b 45 08             	mov    0x8(%ebp),%eax
  80148d:	8b 40 0c             	mov    0xc(%eax),%eax
  801490:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801495:	8b 45 0c             	mov    0xc(%ebp),%eax
  801498:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80149d:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a7:	e8 8d ff ff ff       	call   801439 <fsipc>
}
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    

008014ae <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c9:	e8 6b ff ff ff       	call   801439 <fsipc>
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 04             	sub    $0x4,%esp
  8014d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014da:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ef:	e8 45 ff ff ff       	call   801439 <fsipc>
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 2c                	js     801524 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	68 00 50 80 00       	push   $0x805000
  801500:	53                   	push   %ebx
  801501:	e8 82 f2 ff ff       	call   800788 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801506:	a1 80 50 80 00       	mov    0x805080,%eax
  80150b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801511:	a1 84 50 80 00       	mov    0x805084,%eax
  801516:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801524:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801527:	c9                   	leave  
  801528:	c3                   	ret    

00801529 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	83 ec 0c             	sub    $0xc,%esp
  80152f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801532:	8b 55 08             	mov    0x8(%ebp),%edx
  801535:	8b 52 0c             	mov    0xc(%edx),%edx
  801538:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80153e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801543:	50                   	push   %eax
  801544:	ff 75 0c             	pushl  0xc(%ebp)
  801547:	68 08 50 80 00       	push   $0x805008
  80154c:	e8 c9 f3 ff ff       	call   80091a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801551:	ba 00 00 00 00       	mov    $0x0,%edx
  801556:	b8 04 00 00 00       	mov    $0x4,%eax
  80155b:	e8 d9 fe ff ff       	call   801439 <fsipc>

}
  801560:	c9                   	leave  
  801561:	c3                   	ret    

00801562 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	56                   	push   %esi
  801566:	53                   	push   %ebx
  801567:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80156a:	8b 45 08             	mov    0x8(%ebp),%eax
  80156d:	8b 40 0c             	mov    0xc(%eax),%eax
  801570:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801575:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80157b:	ba 00 00 00 00       	mov    $0x0,%edx
  801580:	b8 03 00 00 00       	mov    $0x3,%eax
  801585:	e8 af fe ff ff       	call   801439 <fsipc>
  80158a:	89 c3                	mov    %eax,%ebx
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 4b                	js     8015db <devfile_read+0x79>
		return r;
	assert(r <= n);
  801590:	39 c6                	cmp    %eax,%esi
  801592:	73 16                	jae    8015aa <devfile_read+0x48>
  801594:	68 00 28 80 00       	push   $0x802800
  801599:	68 07 28 80 00       	push   $0x802807
  80159e:	6a 7c                	push   $0x7c
  8015a0:	68 1c 28 80 00       	push   $0x80281c
  8015a5:	e8 80 eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  8015aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015af:	7e 16                	jle    8015c7 <devfile_read+0x65>
  8015b1:	68 27 28 80 00       	push   $0x802827
  8015b6:	68 07 28 80 00       	push   $0x802807
  8015bb:	6a 7d                	push   $0x7d
  8015bd:	68 1c 28 80 00       	push   $0x80281c
  8015c2:	e8 63 eb ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	50                   	push   %eax
  8015cb:	68 00 50 80 00       	push   $0x805000
  8015d0:	ff 75 0c             	pushl  0xc(%ebp)
  8015d3:	e8 42 f3 ff ff       	call   80091a <memmove>
	return r;
  8015d8:	83 c4 10             	add    $0x10,%esp
}
  8015db:	89 d8                	mov    %ebx,%eax
  8015dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	53                   	push   %ebx
  8015e8:	83 ec 20             	sub    $0x20,%esp
  8015eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ee:	53                   	push   %ebx
  8015ef:	e8 5b f1 ff ff       	call   80074f <strlen>
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015fc:	7f 67                	jg     801665 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801604:	50                   	push   %eax
  801605:	e8 a7 f8 ff ff       	call   800eb1 <fd_alloc>
  80160a:	83 c4 10             	add    $0x10,%esp
		return r;
  80160d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 57                	js     80166a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	53                   	push   %ebx
  801617:	68 00 50 80 00       	push   $0x805000
  80161c:	e8 67 f1 ff ff       	call   800788 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801621:	8b 45 0c             	mov    0xc(%ebp),%eax
  801624:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801629:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162c:	b8 01 00 00 00       	mov    $0x1,%eax
  801631:	e8 03 fe ff ff       	call   801439 <fsipc>
  801636:	89 c3                	mov    %eax,%ebx
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	79 14                	jns    801653 <open+0x6f>
		fd_close(fd, 0);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	6a 00                	push   $0x0
  801644:	ff 75 f4             	pushl  -0xc(%ebp)
  801647:	e8 5d f9 ff ff       	call   800fa9 <fd_close>
		return r;
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	89 da                	mov    %ebx,%edx
  801651:	eb 17                	jmp    80166a <open+0x86>
	}

	return fd2num(fd);
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	ff 75 f4             	pushl  -0xc(%ebp)
  801659:	e8 2c f8 ff ff       	call   800e8a <fd2num>
  80165e:	89 c2                	mov    %eax,%edx
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	eb 05                	jmp    80166a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801665:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80166a:	89 d0                	mov    %edx,%eax
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801677:	ba 00 00 00 00       	mov    $0x0,%edx
  80167c:	b8 08 00 00 00       	mov    $0x8,%eax
  801681:	e8 b3 fd ff ff       	call   801439 <fsipc>
}
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80168e:	68 33 28 80 00       	push   $0x802833
  801693:	ff 75 0c             	pushl  0xc(%ebp)
  801696:	e8 ed f0 ff ff       	call   800788 <strcpy>
	return 0;
}
  80169b:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 10             	sub    $0x10,%esp
  8016a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016ac:	53                   	push   %ebx
  8016ad:	e8 10 0a 00 00       	call   8020c2 <pageref>
  8016b2:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8016b5:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8016ba:	83 f8 01             	cmp    $0x1,%eax
  8016bd:	75 10                	jne    8016cf <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	ff 73 0c             	pushl  0xc(%ebx)
  8016c5:	e8 c0 02 00 00       	call   80198a <nsipc_close>
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016cf:	89 d0                	mov    %edx,%eax
  8016d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016dc:	6a 00                	push   $0x0
  8016de:	ff 75 10             	pushl  0x10(%ebp)
  8016e1:	ff 75 0c             	pushl  0xc(%ebp)
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	ff 70 0c             	pushl  0xc(%eax)
  8016ea:	e8 78 03 00 00       	call   801a67 <nsipc_send>
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016f7:	6a 00                	push   $0x0
  8016f9:	ff 75 10             	pushl  0x10(%ebp)
  8016fc:	ff 75 0c             	pushl  0xc(%ebp)
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	ff 70 0c             	pushl  0xc(%eax)
  801705:	e8 f1 02 00 00       	call   8019fb <nsipc_recv>
}
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801712:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801715:	52                   	push   %edx
  801716:	50                   	push   %eax
  801717:	e8 e4 f7 ff ff       	call   800f00 <fd_lookup>
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 17                	js     80173a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801726:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80172c:	39 08                	cmp    %ecx,(%eax)
  80172e:	75 05                	jne    801735 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801730:	8b 40 0c             	mov    0xc(%eax),%eax
  801733:	eb 05                	jmp    80173a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801735:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	56                   	push   %esi
  801740:	53                   	push   %ebx
  801741:	83 ec 1c             	sub    $0x1c,%esp
  801744:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801746:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	e8 62 f7 ff ff       	call   800eb1 <fd_alloc>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	78 1b                	js     801773 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801758:	83 ec 04             	sub    $0x4,%esp
  80175b:	68 07 04 00 00       	push   $0x407
  801760:	ff 75 f4             	pushl  -0xc(%ebp)
  801763:	6a 00                	push   $0x0
  801765:	e8 21 f4 ff ff       	call   800b8b <sys_page_alloc>
  80176a:	89 c3                	mov    %eax,%ebx
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	79 10                	jns    801783 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	56                   	push   %esi
  801777:	e8 0e 02 00 00       	call   80198a <nsipc_close>
		return r;
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	89 d8                	mov    %ebx,%eax
  801781:	eb 24                	jmp    8017a7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801783:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80178e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801791:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801798:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80179b:	83 ec 0c             	sub    $0xc,%esp
  80179e:	50                   	push   %eax
  80179f:	e8 e6 f6 ff ff       	call   800e8a <fd2num>
  8017a4:	83 c4 10             	add    $0x10,%esp
}
  8017a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017aa:	5b                   	pop    %ebx
  8017ab:	5e                   	pop    %esi
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b7:	e8 50 ff ff ff       	call   80170c <fd2sockid>
		return r;
  8017bc:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 1f                	js     8017e1 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	ff 75 10             	pushl  0x10(%ebp)
  8017c8:	ff 75 0c             	pushl  0xc(%ebp)
  8017cb:	50                   	push   %eax
  8017cc:	e8 12 01 00 00       	call   8018e3 <nsipc_accept>
  8017d1:	83 c4 10             	add    $0x10,%esp
		return r;
  8017d4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 07                	js     8017e1 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017da:	e8 5d ff ff ff       	call   80173c <alloc_sockfd>
  8017df:	89 c1                	mov    %eax,%ecx
}
  8017e1:	89 c8                	mov    %ecx,%eax
  8017e3:	c9                   	leave  
  8017e4:	c3                   	ret    

008017e5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	e8 19 ff ff ff       	call   80170c <fd2sockid>
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 12                	js     801809 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017f7:	83 ec 04             	sub    $0x4,%esp
  8017fa:	ff 75 10             	pushl  0x10(%ebp)
  8017fd:	ff 75 0c             	pushl  0xc(%ebp)
  801800:	50                   	push   %eax
  801801:	e8 2d 01 00 00       	call   801933 <nsipc_bind>
  801806:	83 c4 10             	add    $0x10,%esp
}
  801809:	c9                   	leave  
  80180a:	c3                   	ret    

0080180b <shutdown>:

int
shutdown(int s, int how)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	e8 f3 fe ff ff       	call   80170c <fd2sockid>
  801819:	85 c0                	test   %eax,%eax
  80181b:	78 0f                	js     80182c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80181d:	83 ec 08             	sub    $0x8,%esp
  801820:	ff 75 0c             	pushl  0xc(%ebp)
  801823:	50                   	push   %eax
  801824:	e8 3f 01 00 00       	call   801968 <nsipc_shutdown>
  801829:	83 c4 10             	add    $0x10,%esp
}
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801834:	8b 45 08             	mov    0x8(%ebp),%eax
  801837:	e8 d0 fe ff ff       	call   80170c <fd2sockid>
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 12                	js     801852 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801840:	83 ec 04             	sub    $0x4,%esp
  801843:	ff 75 10             	pushl  0x10(%ebp)
  801846:	ff 75 0c             	pushl  0xc(%ebp)
  801849:	50                   	push   %eax
  80184a:	e8 55 01 00 00       	call   8019a4 <nsipc_connect>
  80184f:	83 c4 10             	add    $0x10,%esp
}
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <listen>:

int
listen(int s, int backlog)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	e8 aa fe ff ff       	call   80170c <fd2sockid>
  801862:	85 c0                	test   %eax,%eax
  801864:	78 0f                	js     801875 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	ff 75 0c             	pushl  0xc(%ebp)
  80186c:	50                   	push   %eax
  80186d:	e8 67 01 00 00       	call   8019d9 <nsipc_listen>
  801872:	83 c4 10             	add    $0x10,%esp
}
  801875:	c9                   	leave  
  801876:	c3                   	ret    

00801877 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80187d:	ff 75 10             	pushl  0x10(%ebp)
  801880:	ff 75 0c             	pushl  0xc(%ebp)
  801883:	ff 75 08             	pushl  0x8(%ebp)
  801886:	e8 3a 02 00 00       	call   801ac5 <nsipc_socket>
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 05                	js     801897 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801892:	e8 a5 fe ff ff       	call   80173c <alloc_sockfd>
}
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	53                   	push   %ebx
  80189d:	83 ec 04             	sub    $0x4,%esp
  8018a0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018a2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018a9:	75 12                	jne    8018bd <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018ab:	83 ec 0c             	sub    $0xc,%esp
  8018ae:	6a 02                	push   $0x2
  8018b0:	e8 d4 07 00 00       	call   802089 <ipc_find_env>
  8018b5:	a3 04 40 80 00       	mov    %eax,0x804004
  8018ba:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018bd:	6a 07                	push   $0x7
  8018bf:	68 00 60 80 00       	push   $0x806000
  8018c4:	53                   	push   %ebx
  8018c5:	ff 35 04 40 80 00    	pushl  0x804004
  8018cb:	e8 65 07 00 00       	call   802035 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018d0:	83 c4 0c             	add    $0xc,%esp
  8018d3:	6a 00                	push   $0x0
  8018d5:	6a 00                	push   $0x0
  8018d7:	6a 00                	push   $0x0
  8018d9:	e8 f0 06 00 00       	call   801fce <ipc_recv>
}
  8018de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e1:	c9                   	leave  
  8018e2:	c3                   	ret    

008018e3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
  8018e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018f3:	8b 06                	mov    (%esi),%eax
  8018f5:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ff:	e8 95 ff ff ff       	call   801899 <nsipc>
  801904:	89 c3                	mov    %eax,%ebx
  801906:	85 c0                	test   %eax,%eax
  801908:	78 20                	js     80192a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80190a:	83 ec 04             	sub    $0x4,%esp
  80190d:	ff 35 10 60 80 00    	pushl  0x806010
  801913:	68 00 60 80 00       	push   $0x806000
  801918:	ff 75 0c             	pushl  0xc(%ebp)
  80191b:	e8 fa ef ff ff       	call   80091a <memmove>
		*addrlen = ret->ret_addrlen;
  801920:	a1 10 60 80 00       	mov    0x806010,%eax
  801925:	89 06                	mov    %eax,(%esi)
  801927:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80192a:	89 d8                	mov    %ebx,%eax
  80192c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192f:	5b                   	pop    %ebx
  801930:	5e                   	pop    %esi
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    

00801933 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	53                   	push   %ebx
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801945:	53                   	push   %ebx
  801946:	ff 75 0c             	pushl  0xc(%ebp)
  801949:	68 04 60 80 00       	push   $0x806004
  80194e:	e8 c7 ef ff ff       	call   80091a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801953:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801959:	b8 02 00 00 00       	mov    $0x2,%eax
  80195e:	e8 36 ff ff ff       	call   801899 <nsipc>
}
  801963:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801966:	c9                   	leave  
  801967:	c3                   	ret    

00801968 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801976:	8b 45 0c             	mov    0xc(%ebp),%eax
  801979:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80197e:	b8 03 00 00 00       	mov    $0x3,%eax
  801983:	e8 11 ff ff ff       	call   801899 <nsipc>
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <nsipc_close>:

int
nsipc_close(int s)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801990:	8b 45 08             	mov    0x8(%ebp),%eax
  801993:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801998:	b8 04 00 00 00       	mov    $0x4,%eax
  80199d:	e8 f7 fe ff ff       	call   801899 <nsipc>
}
  8019a2:	c9                   	leave  
  8019a3:	c3                   	ret    

008019a4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 08             	sub    $0x8,%esp
  8019ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019b6:	53                   	push   %ebx
  8019b7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ba:	68 04 60 80 00       	push   $0x806004
  8019bf:	e8 56 ef ff ff       	call   80091a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019c4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8019cf:	e8 c5 fe ff ff       	call   801899 <nsipc>
}
  8019d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    

008019d9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ea:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8019f4:	e8 a0 fe ff ff       	call   801899 <nsipc>
}
  8019f9:	c9                   	leave  
  8019fa:	c3                   	ret    

008019fb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	56                   	push   %esi
  8019ff:	53                   	push   %ebx
  801a00:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a0b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a11:	8b 45 14             	mov    0x14(%ebp),%eax
  801a14:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a19:	b8 07 00 00 00       	mov    $0x7,%eax
  801a1e:	e8 76 fe ff ff       	call   801899 <nsipc>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 35                	js     801a5e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a29:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a2e:	7f 04                	jg     801a34 <nsipc_recv+0x39>
  801a30:	39 c6                	cmp    %eax,%esi
  801a32:	7d 16                	jge    801a4a <nsipc_recv+0x4f>
  801a34:	68 3f 28 80 00       	push   $0x80283f
  801a39:	68 07 28 80 00       	push   $0x802807
  801a3e:	6a 62                	push   $0x62
  801a40:	68 54 28 80 00       	push   $0x802854
  801a45:	e8 e0 e6 ff ff       	call   80012a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a4a:	83 ec 04             	sub    $0x4,%esp
  801a4d:	50                   	push   %eax
  801a4e:	68 00 60 80 00       	push   $0x806000
  801a53:	ff 75 0c             	pushl  0xc(%ebp)
  801a56:	e8 bf ee ff ff       	call   80091a <memmove>
  801a5b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a5e:	89 d8                	mov    %ebx,%eax
  801a60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a63:	5b                   	pop    %ebx
  801a64:	5e                   	pop    %esi
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    

00801a67 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	53                   	push   %ebx
  801a6b:	83 ec 04             	sub    $0x4,%esp
  801a6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a71:	8b 45 08             	mov    0x8(%ebp),%eax
  801a74:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a79:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a7f:	7e 16                	jle    801a97 <nsipc_send+0x30>
  801a81:	68 60 28 80 00       	push   $0x802860
  801a86:	68 07 28 80 00       	push   $0x802807
  801a8b:	6a 6d                	push   $0x6d
  801a8d:	68 54 28 80 00       	push   $0x802854
  801a92:	e8 93 e6 ff ff       	call   80012a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a97:	83 ec 04             	sub    $0x4,%esp
  801a9a:	53                   	push   %ebx
  801a9b:	ff 75 0c             	pushl  0xc(%ebp)
  801a9e:	68 0c 60 80 00       	push   $0x80600c
  801aa3:	e8 72 ee ff ff       	call   80091a <memmove>
	nsipcbuf.send.req_size = size;
  801aa8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801aae:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ab6:	b8 08 00 00 00       	mov    $0x8,%eax
  801abb:	e8 d9 fd ff ff       	call   801899 <nsipc>
}
  801ac0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac3:	c9                   	leave  
  801ac4:	c3                   	ret    

00801ac5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801acb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ace:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad6:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801adb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ade:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ae3:	b8 09 00 00 00       	mov    $0x9,%eax
  801ae8:	e8 ac fd ff ff       	call   801899 <nsipc>
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	ff 75 08             	pushl  0x8(%ebp)
  801afd:	e8 98 f3 ff ff       	call   800e9a <fd2data>
  801b02:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b04:	83 c4 08             	add    $0x8,%esp
  801b07:	68 6c 28 80 00       	push   $0x80286c
  801b0c:	53                   	push   %ebx
  801b0d:	e8 76 ec ff ff       	call   800788 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b12:	8b 46 04             	mov    0x4(%esi),%eax
  801b15:	2b 06                	sub    (%esi),%eax
  801b17:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b1d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b24:	00 00 00 
	stat->st_dev = &devpipe;
  801b27:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b2e:	30 80 00 
	return 0;
}
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
  801b36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	53                   	push   %ebx
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b47:	53                   	push   %ebx
  801b48:	6a 00                	push   $0x0
  801b4a:	e8 c1 f0 ff ff       	call   800c10 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b4f:	89 1c 24             	mov    %ebx,(%esp)
  801b52:	e8 43 f3 ff ff       	call   800e9a <fd2data>
  801b57:	83 c4 08             	add    $0x8,%esp
  801b5a:	50                   	push   %eax
  801b5b:	6a 00                	push   $0x0
  801b5d:	e8 ae f0 ff ff       	call   800c10 <sys_page_unmap>
}
  801b62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    

00801b67 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	57                   	push   %edi
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 1c             	sub    $0x1c,%esp
  801b70:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b73:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b75:	a1 08 40 80 00       	mov    0x804008,%eax
  801b7a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	ff 75 e0             	pushl  -0x20(%ebp)
  801b83:	e8 3a 05 00 00       	call   8020c2 <pageref>
  801b88:	89 c3                	mov    %eax,%ebx
  801b8a:	89 3c 24             	mov    %edi,(%esp)
  801b8d:	e8 30 05 00 00       	call   8020c2 <pageref>
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	39 c3                	cmp    %eax,%ebx
  801b97:	0f 94 c1             	sete   %cl
  801b9a:	0f b6 c9             	movzbl %cl,%ecx
  801b9d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ba0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ba6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ba9:	39 ce                	cmp    %ecx,%esi
  801bab:	74 1b                	je     801bc8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bad:	39 c3                	cmp    %eax,%ebx
  801baf:	75 c4                	jne    801b75 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bb1:	8b 42 58             	mov    0x58(%edx),%eax
  801bb4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb7:	50                   	push   %eax
  801bb8:	56                   	push   %esi
  801bb9:	68 73 28 80 00       	push   $0x802873
  801bbe:	e8 40 e6 ff ff       	call   800203 <cprintf>
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	eb ad                	jmp    801b75 <_pipeisclosed+0xe>
	}
}
  801bc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bce:	5b                   	pop    %ebx
  801bcf:	5e                   	pop    %esi
  801bd0:	5f                   	pop    %edi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	57                   	push   %edi
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 28             	sub    $0x28,%esp
  801bdc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bdf:	56                   	push   %esi
  801be0:	e8 b5 f2 ff ff       	call   800e9a <fd2data>
  801be5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	bf 00 00 00 00       	mov    $0x0,%edi
  801bef:	eb 4b                	jmp    801c3c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bf1:	89 da                	mov    %ebx,%edx
  801bf3:	89 f0                	mov    %esi,%eax
  801bf5:	e8 6d ff ff ff       	call   801b67 <_pipeisclosed>
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	75 48                	jne    801c46 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bfe:	e8 69 ef ff ff       	call   800b6c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c03:	8b 43 04             	mov    0x4(%ebx),%eax
  801c06:	8b 0b                	mov    (%ebx),%ecx
  801c08:	8d 51 20             	lea    0x20(%ecx),%edx
  801c0b:	39 d0                	cmp    %edx,%eax
  801c0d:	73 e2                	jae    801bf1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c12:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c16:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c19:	89 c2                	mov    %eax,%edx
  801c1b:	c1 fa 1f             	sar    $0x1f,%edx
  801c1e:	89 d1                	mov    %edx,%ecx
  801c20:	c1 e9 1b             	shr    $0x1b,%ecx
  801c23:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c26:	83 e2 1f             	and    $0x1f,%edx
  801c29:	29 ca                	sub    %ecx,%edx
  801c2b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c2f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c33:	83 c0 01             	add    $0x1,%eax
  801c36:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c39:	83 c7 01             	add    $0x1,%edi
  801c3c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c3f:	75 c2                	jne    801c03 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c41:	8b 45 10             	mov    0x10(%ebp),%eax
  801c44:	eb 05                	jmp    801c4b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c46:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4e:	5b                   	pop    %ebx
  801c4f:	5e                   	pop    %esi
  801c50:	5f                   	pop    %edi
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    

00801c53 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	57                   	push   %edi
  801c57:	56                   	push   %esi
  801c58:	53                   	push   %ebx
  801c59:	83 ec 18             	sub    $0x18,%esp
  801c5c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c5f:	57                   	push   %edi
  801c60:	e8 35 f2 ff ff       	call   800e9a <fd2data>
  801c65:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c67:	83 c4 10             	add    $0x10,%esp
  801c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6f:	eb 3d                	jmp    801cae <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c71:	85 db                	test   %ebx,%ebx
  801c73:	74 04                	je     801c79 <devpipe_read+0x26>
				return i;
  801c75:	89 d8                	mov    %ebx,%eax
  801c77:	eb 44                	jmp    801cbd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c79:	89 f2                	mov    %esi,%edx
  801c7b:	89 f8                	mov    %edi,%eax
  801c7d:	e8 e5 fe ff ff       	call   801b67 <_pipeisclosed>
  801c82:	85 c0                	test   %eax,%eax
  801c84:	75 32                	jne    801cb8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c86:	e8 e1 ee ff ff       	call   800b6c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c8b:	8b 06                	mov    (%esi),%eax
  801c8d:	3b 46 04             	cmp    0x4(%esi),%eax
  801c90:	74 df                	je     801c71 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c92:	99                   	cltd   
  801c93:	c1 ea 1b             	shr    $0x1b,%edx
  801c96:	01 d0                	add    %edx,%eax
  801c98:	83 e0 1f             	and    $0x1f,%eax
  801c9b:	29 d0                	sub    %edx,%eax
  801c9d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ca8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cab:	83 c3 01             	add    $0x1,%ebx
  801cae:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cb1:	75 d8                	jne    801c8b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cb3:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb6:	eb 05                	jmp    801cbd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	56                   	push   %esi
  801cc9:	53                   	push   %ebx
  801cca:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ccd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd0:	50                   	push   %eax
  801cd1:	e8 db f1 ff ff       	call   800eb1 <fd_alloc>
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	89 c2                	mov    %eax,%edx
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	0f 88 2c 01 00 00    	js     801e0f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce3:	83 ec 04             	sub    $0x4,%esp
  801ce6:	68 07 04 00 00       	push   $0x407
  801ceb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 96 ee ff ff       	call   800b8b <sys_page_alloc>
  801cf5:	83 c4 10             	add    $0x10,%esp
  801cf8:	89 c2                	mov    %eax,%edx
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	0f 88 0d 01 00 00    	js     801e0f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d02:	83 ec 0c             	sub    $0xc,%esp
  801d05:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d08:	50                   	push   %eax
  801d09:	e8 a3 f1 ff ff       	call   800eb1 <fd_alloc>
  801d0e:	89 c3                	mov    %eax,%ebx
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	85 c0                	test   %eax,%eax
  801d15:	0f 88 e2 00 00 00    	js     801dfd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1b:	83 ec 04             	sub    $0x4,%esp
  801d1e:	68 07 04 00 00       	push   $0x407
  801d23:	ff 75 f0             	pushl  -0x10(%ebp)
  801d26:	6a 00                	push   $0x0
  801d28:	e8 5e ee ff ff       	call   800b8b <sys_page_alloc>
  801d2d:	89 c3                	mov    %eax,%ebx
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	85 c0                	test   %eax,%eax
  801d34:	0f 88 c3 00 00 00    	js     801dfd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d3a:	83 ec 0c             	sub    $0xc,%esp
  801d3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d40:	e8 55 f1 ff ff       	call   800e9a <fd2data>
  801d45:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d47:	83 c4 0c             	add    $0xc,%esp
  801d4a:	68 07 04 00 00       	push   $0x407
  801d4f:	50                   	push   %eax
  801d50:	6a 00                	push   $0x0
  801d52:	e8 34 ee ff ff       	call   800b8b <sys_page_alloc>
  801d57:	89 c3                	mov    %eax,%ebx
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	0f 88 89 00 00 00    	js     801ded <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d64:	83 ec 0c             	sub    $0xc,%esp
  801d67:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6a:	e8 2b f1 ff ff       	call   800e9a <fd2data>
  801d6f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d76:	50                   	push   %eax
  801d77:	6a 00                	push   $0x0
  801d79:	56                   	push   %esi
  801d7a:	6a 00                	push   $0x0
  801d7c:	e8 4d ee ff ff       	call   800bce <sys_page_map>
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	83 c4 20             	add    $0x20,%esp
  801d86:	85 c0                	test   %eax,%eax
  801d88:	78 55                	js     801ddf <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d8a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d93:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d98:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d9f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801daa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dad:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801db4:	83 ec 0c             	sub    $0xc,%esp
  801db7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dba:	e8 cb f0 ff ff       	call   800e8a <fd2num>
  801dbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc4:	83 c4 04             	add    $0x4,%esp
  801dc7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dca:	e8 bb f0 ff ff       	call   800e8a <fd2num>
  801dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dd5:	83 c4 10             	add    $0x10,%esp
  801dd8:	ba 00 00 00 00       	mov    $0x0,%edx
  801ddd:	eb 30                	jmp    801e0f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ddf:	83 ec 08             	sub    $0x8,%esp
  801de2:	56                   	push   %esi
  801de3:	6a 00                	push   $0x0
  801de5:	e8 26 ee ff ff       	call   800c10 <sys_page_unmap>
  801dea:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ded:	83 ec 08             	sub    $0x8,%esp
  801df0:	ff 75 f0             	pushl  -0x10(%ebp)
  801df3:	6a 00                	push   $0x0
  801df5:	e8 16 ee ff ff       	call   800c10 <sys_page_unmap>
  801dfa:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dfd:	83 ec 08             	sub    $0x8,%esp
  801e00:	ff 75 f4             	pushl  -0xc(%ebp)
  801e03:	6a 00                	push   $0x0
  801e05:	e8 06 ee ff ff       	call   800c10 <sys_page_unmap>
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e0f:	89 d0                	mov    %edx,%eax
  801e11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5e                   	pop    %esi
  801e16:	5d                   	pop    %ebp
  801e17:	c3                   	ret    

00801e18 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e21:	50                   	push   %eax
  801e22:	ff 75 08             	pushl  0x8(%ebp)
  801e25:	e8 d6 f0 ff ff       	call   800f00 <fd_lookup>
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	78 18                	js     801e49 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e31:	83 ec 0c             	sub    $0xc,%esp
  801e34:	ff 75 f4             	pushl  -0xc(%ebp)
  801e37:	e8 5e f0 ff ff       	call   800e9a <fd2data>
	return _pipeisclosed(fd, p);
  801e3c:	89 c2                	mov    %eax,%edx
  801e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e41:	e8 21 fd ff ff       	call   801b67 <_pipeisclosed>
  801e46:	83 c4 10             	add    $0x10,%esp
}
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    

00801e55 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e5b:	68 8b 28 80 00       	push   $0x80288b
  801e60:	ff 75 0c             	pushl  0xc(%ebp)
  801e63:	e8 20 e9 ff ff       	call   800788 <strcpy>
	return 0;
}
  801e68:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	57                   	push   %edi
  801e73:	56                   	push   %esi
  801e74:	53                   	push   %ebx
  801e75:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e80:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e86:	eb 2d                	jmp    801eb5 <devcons_write+0x46>
		m = n - tot;
  801e88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e8b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e8d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e90:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e95:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e98:	83 ec 04             	sub    $0x4,%esp
  801e9b:	53                   	push   %ebx
  801e9c:	03 45 0c             	add    0xc(%ebp),%eax
  801e9f:	50                   	push   %eax
  801ea0:	57                   	push   %edi
  801ea1:	e8 74 ea ff ff       	call   80091a <memmove>
		sys_cputs(buf, m);
  801ea6:	83 c4 08             	add    $0x8,%esp
  801ea9:	53                   	push   %ebx
  801eaa:	57                   	push   %edi
  801eab:	e8 1f ec ff ff       	call   800acf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb0:	01 de                	add    %ebx,%esi
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	89 f0                	mov    %esi,%eax
  801eb7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eba:	72 cc                	jb     801e88 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5f                   	pop    %edi
  801ec2:	5d                   	pop    %ebp
  801ec3:	c3                   	ret    

00801ec4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 08             	sub    $0x8,%esp
  801eca:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ecf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed3:	74 2a                	je     801eff <devcons_read+0x3b>
  801ed5:	eb 05                	jmp    801edc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ed7:	e8 90 ec ff ff       	call   800b6c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801edc:	e8 0c ec ff ff       	call   800aed <sys_cgetc>
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	74 f2                	je     801ed7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 16                	js     801eff <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ee9:	83 f8 04             	cmp    $0x4,%eax
  801eec:	74 0c                	je     801efa <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eee:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef1:	88 02                	mov    %al,(%edx)
	return 1;
  801ef3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef8:	eb 05                	jmp    801eff <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801efa:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eff:	c9                   	leave  
  801f00:	c3                   	ret    

00801f01 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f07:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f0d:	6a 01                	push   $0x1
  801f0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f12:	50                   	push   %eax
  801f13:	e8 b7 eb ff ff       	call   800acf <sys_cputs>
}
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	c9                   	leave  
  801f1c:	c3                   	ret    

00801f1d <getchar>:

int
getchar(void)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f23:	6a 01                	push   $0x1
  801f25:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f28:	50                   	push   %eax
  801f29:	6a 00                	push   $0x0
  801f2b:	e8 36 f2 ff ff       	call   801166 <read>
	if (r < 0)
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	78 0f                	js     801f46 <getchar+0x29>
		return r;
	if (r < 1)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	7e 06                	jle    801f41 <getchar+0x24>
		return -E_EOF;
	return c;
  801f3b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f3f:	eb 05                	jmp    801f46 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f41:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f46:	c9                   	leave  
  801f47:	c3                   	ret    

00801f48 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f51:	50                   	push   %eax
  801f52:	ff 75 08             	pushl  0x8(%ebp)
  801f55:	e8 a6 ef ff ff       	call   800f00 <fd_lookup>
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 11                	js     801f72 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f64:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f6a:	39 10                	cmp    %edx,(%eax)
  801f6c:	0f 94 c0             	sete   %al
  801f6f:	0f b6 c0             	movzbl %al,%eax
}
  801f72:	c9                   	leave  
  801f73:	c3                   	ret    

00801f74 <opencons>:

int
opencons(void)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7d:	50                   	push   %eax
  801f7e:	e8 2e ef ff ff       	call   800eb1 <fd_alloc>
  801f83:	83 c4 10             	add    $0x10,%esp
		return r;
  801f86:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	78 3e                	js     801fca <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8c:	83 ec 04             	sub    $0x4,%esp
  801f8f:	68 07 04 00 00       	push   $0x407
  801f94:	ff 75 f4             	pushl  -0xc(%ebp)
  801f97:	6a 00                	push   $0x0
  801f99:	e8 ed eb ff ff       	call   800b8b <sys_page_alloc>
  801f9e:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	78 23                	js     801fca <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fa7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fbc:	83 ec 0c             	sub    $0xc,%esp
  801fbf:	50                   	push   %eax
  801fc0:	e8 c5 ee ff ff       	call   800e8a <fd2num>
  801fc5:	89 c2                	mov    %eax,%edx
  801fc7:	83 c4 10             	add    $0x10,%esp
}
  801fca:	89 d0                	mov    %edx,%eax
  801fcc:	c9                   	leave  
  801fcd:	c3                   	ret    

00801fce <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801fdc:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801fde:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fe3:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801fe6:	83 ec 0c             	sub    $0xc,%esp
  801fe9:	50                   	push   %eax
  801fea:	e8 4c ed ff ff       	call   800d3b <sys_ipc_recv>

	if (from_env_store != NULL)
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	85 f6                	test   %esi,%esi
  801ff4:	74 14                	je     80200a <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801ff6:	ba 00 00 00 00       	mov    $0x0,%edx
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	78 09                	js     802008 <ipc_recv+0x3a>
  801fff:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802005:	8b 52 74             	mov    0x74(%edx),%edx
  802008:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80200a:	85 db                	test   %ebx,%ebx
  80200c:	74 14                	je     802022 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80200e:	ba 00 00 00 00       	mov    $0x0,%edx
  802013:	85 c0                	test   %eax,%eax
  802015:	78 09                	js     802020 <ipc_recv+0x52>
  802017:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80201d:	8b 52 78             	mov    0x78(%edx),%edx
  802020:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802022:	85 c0                	test   %eax,%eax
  802024:	78 08                	js     80202e <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802026:	a1 08 40 80 00       	mov    0x804008,%eax
  80202b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80202e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802031:	5b                   	pop    %ebx
  802032:	5e                   	pop    %esi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    

00802035 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	57                   	push   %edi
  802039:	56                   	push   %esi
  80203a:	53                   	push   %ebx
  80203b:	83 ec 0c             	sub    $0xc,%esp
  80203e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802041:	8b 75 0c             	mov    0xc(%ebp),%esi
  802044:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802047:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802049:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80204e:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802051:	ff 75 14             	pushl  0x14(%ebp)
  802054:	53                   	push   %ebx
  802055:	56                   	push   %esi
  802056:	57                   	push   %edi
  802057:	e8 bc ec ff ff       	call   800d18 <sys_ipc_try_send>

		if (err < 0) {
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	85 c0                	test   %eax,%eax
  802061:	79 1e                	jns    802081 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802063:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802066:	75 07                	jne    80206f <ipc_send+0x3a>
				sys_yield();
  802068:	e8 ff ea ff ff       	call   800b6c <sys_yield>
  80206d:	eb e2                	jmp    802051 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80206f:	50                   	push   %eax
  802070:	68 97 28 80 00       	push   $0x802897
  802075:	6a 49                	push   $0x49
  802077:	68 a4 28 80 00       	push   $0x8028a4
  80207c:	e8 a9 e0 ff ff       	call   80012a <_panic>
		}

	} while (err < 0);

}
  802081:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    

00802089 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80208f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802094:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802097:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80209d:	8b 52 50             	mov    0x50(%edx),%edx
  8020a0:	39 ca                	cmp    %ecx,%edx
  8020a2:	75 0d                	jne    8020b1 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020a4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020ac:	8b 40 48             	mov    0x48(%eax),%eax
  8020af:	eb 0f                	jmp    8020c0 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020b1:	83 c0 01             	add    $0x1,%eax
  8020b4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020b9:	75 d9                	jne    802094 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    

008020c2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c8:	89 d0                	mov    %edx,%eax
  8020ca:	c1 e8 16             	shr    $0x16,%eax
  8020cd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020d4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d9:	f6 c1 01             	test   $0x1,%cl
  8020dc:	74 1d                	je     8020fb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020de:	c1 ea 0c             	shr    $0xc,%edx
  8020e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020e8:	f6 c2 01             	test   $0x1,%dl
  8020eb:	74 0e                	je     8020fb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020ed:	c1 ea 0c             	shr    $0xc,%edx
  8020f0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020f7:	ef 
  8020f8:	0f b7 c0             	movzwl %ax,%eax
}
  8020fb:	5d                   	pop    %ebp
  8020fc:	c3                   	ret    
  8020fd:	66 90                	xchg   %ax,%ax
  8020ff:	90                   	nop

00802100 <__udivdi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80210b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80210f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 f6                	test   %esi,%esi
  802119:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80211d:	89 ca                	mov    %ecx,%edx
  80211f:	89 f8                	mov    %edi,%eax
  802121:	75 3d                	jne    802160 <__udivdi3+0x60>
  802123:	39 cf                	cmp    %ecx,%edi
  802125:	0f 87 c5 00 00 00    	ja     8021f0 <__udivdi3+0xf0>
  80212b:	85 ff                	test   %edi,%edi
  80212d:	89 fd                	mov    %edi,%ebp
  80212f:	75 0b                	jne    80213c <__udivdi3+0x3c>
  802131:	b8 01 00 00 00       	mov    $0x1,%eax
  802136:	31 d2                	xor    %edx,%edx
  802138:	f7 f7                	div    %edi
  80213a:	89 c5                	mov    %eax,%ebp
  80213c:	89 c8                	mov    %ecx,%eax
  80213e:	31 d2                	xor    %edx,%edx
  802140:	f7 f5                	div    %ebp
  802142:	89 c1                	mov    %eax,%ecx
  802144:	89 d8                	mov    %ebx,%eax
  802146:	89 cf                	mov    %ecx,%edi
  802148:	f7 f5                	div    %ebp
  80214a:	89 c3                	mov    %eax,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	39 ce                	cmp    %ecx,%esi
  802162:	77 74                	ja     8021d8 <__udivdi3+0xd8>
  802164:	0f bd fe             	bsr    %esi,%edi
  802167:	83 f7 1f             	xor    $0x1f,%edi
  80216a:	0f 84 98 00 00 00    	je     802208 <__udivdi3+0x108>
  802170:	bb 20 00 00 00       	mov    $0x20,%ebx
  802175:	89 f9                	mov    %edi,%ecx
  802177:	89 c5                	mov    %eax,%ebp
  802179:	29 fb                	sub    %edi,%ebx
  80217b:	d3 e6                	shl    %cl,%esi
  80217d:	89 d9                	mov    %ebx,%ecx
  80217f:	d3 ed                	shr    %cl,%ebp
  802181:	89 f9                	mov    %edi,%ecx
  802183:	d3 e0                	shl    %cl,%eax
  802185:	09 ee                	or     %ebp,%esi
  802187:	89 d9                	mov    %ebx,%ecx
  802189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80218d:	89 d5                	mov    %edx,%ebp
  80218f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802193:	d3 ed                	shr    %cl,%ebp
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e2                	shl    %cl,%edx
  802199:	89 d9                	mov    %ebx,%ecx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	09 c2                	or     %eax,%edx
  80219f:	89 d0                	mov    %edx,%eax
  8021a1:	89 ea                	mov    %ebp,%edx
  8021a3:	f7 f6                	div    %esi
  8021a5:	89 d5                	mov    %edx,%ebp
  8021a7:	89 c3                	mov    %eax,%ebx
  8021a9:	f7 64 24 0c          	mull   0xc(%esp)
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	72 10                	jb     8021c1 <__udivdi3+0xc1>
  8021b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e6                	shl    %cl,%esi
  8021b9:	39 c6                	cmp    %eax,%esi
  8021bb:	73 07                	jae    8021c4 <__udivdi3+0xc4>
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	75 03                	jne    8021c4 <__udivdi3+0xc4>
  8021c1:	83 eb 01             	sub    $0x1,%ebx
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 d8                	mov    %ebx,%eax
  8021c8:	89 fa                	mov    %edi,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	31 ff                	xor    %edi,%edi
  8021da:	31 db                	xor    %ebx,%ebx
  8021dc:	89 d8                	mov    %ebx,%eax
  8021de:	89 fa                	mov    %edi,%edx
  8021e0:	83 c4 1c             	add    $0x1c,%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5e                   	pop    %esi
  8021e5:	5f                   	pop    %edi
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    
  8021e8:	90                   	nop
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 d8                	mov    %ebx,%eax
  8021f2:	f7 f7                	div    %edi
  8021f4:	31 ff                	xor    %edi,%edi
  8021f6:	89 c3                	mov    %eax,%ebx
  8021f8:	89 d8                	mov    %ebx,%eax
  8021fa:	89 fa                	mov    %edi,%edx
  8021fc:	83 c4 1c             	add    $0x1c,%esp
  8021ff:	5b                   	pop    %ebx
  802200:	5e                   	pop    %esi
  802201:	5f                   	pop    %edi
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	39 ce                	cmp    %ecx,%esi
  80220a:	72 0c                	jb     802218 <__udivdi3+0x118>
  80220c:	31 db                	xor    %ebx,%ebx
  80220e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802212:	0f 87 34 ff ff ff    	ja     80214c <__udivdi3+0x4c>
  802218:	bb 01 00 00 00       	mov    $0x1,%ebx
  80221d:	e9 2a ff ff ff       	jmp    80214c <__udivdi3+0x4c>
  802222:	66 90                	xchg   %ax,%ax
  802224:	66 90                	xchg   %ax,%ax
  802226:	66 90                	xchg   %ax,%ax
  802228:	66 90                	xchg   %ax,%ax
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__umoddi3>:
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	83 ec 1c             	sub    $0x1c,%esp
  802237:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80223b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80223f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802247:	85 d2                	test   %edx,%edx
  802249:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80224d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802251:	89 f3                	mov    %esi,%ebx
  802253:	89 3c 24             	mov    %edi,(%esp)
  802256:	89 74 24 04          	mov    %esi,0x4(%esp)
  80225a:	75 1c                	jne    802278 <__umoddi3+0x48>
  80225c:	39 f7                	cmp    %esi,%edi
  80225e:	76 50                	jbe    8022b0 <__umoddi3+0x80>
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	f7 f7                	div    %edi
  802266:	89 d0                	mov    %edx,%eax
  802268:	31 d2                	xor    %edx,%edx
  80226a:	83 c4 1c             	add    $0x1c,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802278:	39 f2                	cmp    %esi,%edx
  80227a:	89 d0                	mov    %edx,%eax
  80227c:	77 52                	ja     8022d0 <__umoddi3+0xa0>
  80227e:	0f bd ea             	bsr    %edx,%ebp
  802281:	83 f5 1f             	xor    $0x1f,%ebp
  802284:	75 5a                	jne    8022e0 <__umoddi3+0xb0>
  802286:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80228a:	0f 82 e0 00 00 00    	jb     802370 <__umoddi3+0x140>
  802290:	39 0c 24             	cmp    %ecx,(%esp)
  802293:	0f 86 d7 00 00 00    	jbe    802370 <__umoddi3+0x140>
  802299:	8b 44 24 08          	mov    0x8(%esp),%eax
  80229d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022a1:	83 c4 1c             	add    $0x1c,%esp
  8022a4:	5b                   	pop    %ebx
  8022a5:	5e                   	pop    %esi
  8022a6:	5f                   	pop    %edi
  8022a7:	5d                   	pop    %ebp
  8022a8:	c3                   	ret    
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	85 ff                	test   %edi,%edi
  8022b2:	89 fd                	mov    %edi,%ebp
  8022b4:	75 0b                	jne    8022c1 <__umoddi3+0x91>
  8022b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	f7 f7                	div    %edi
  8022bf:	89 c5                	mov    %eax,%ebp
  8022c1:	89 f0                	mov    %esi,%eax
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	f7 f5                	div    %ebp
  8022c7:	89 c8                	mov    %ecx,%eax
  8022c9:	f7 f5                	div    %ebp
  8022cb:	89 d0                	mov    %edx,%eax
  8022cd:	eb 99                	jmp    802268 <__umoddi3+0x38>
  8022cf:	90                   	nop
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	83 c4 1c             	add    $0x1c,%esp
  8022d7:	5b                   	pop    %ebx
  8022d8:	5e                   	pop    %esi
  8022d9:	5f                   	pop    %edi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	8b 34 24             	mov    (%esp),%esi
  8022e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022e8:	89 e9                	mov    %ebp,%ecx
  8022ea:	29 ef                	sub    %ebp,%edi
  8022ec:	d3 e0                	shl    %cl,%eax
  8022ee:	89 f9                	mov    %edi,%ecx
  8022f0:	89 f2                	mov    %esi,%edx
  8022f2:	d3 ea                	shr    %cl,%edx
  8022f4:	89 e9                	mov    %ebp,%ecx
  8022f6:	09 c2                	or     %eax,%edx
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	89 14 24             	mov    %edx,(%esp)
  8022fd:	89 f2                	mov    %esi,%edx
  8022ff:	d3 e2                	shl    %cl,%edx
  802301:	89 f9                	mov    %edi,%ecx
  802303:	89 54 24 04          	mov    %edx,0x4(%esp)
  802307:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80230b:	d3 e8                	shr    %cl,%eax
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	89 c6                	mov    %eax,%esi
  802311:	d3 e3                	shl    %cl,%ebx
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 d0                	mov    %edx,%eax
  802317:	d3 e8                	shr    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	09 d8                	or     %ebx,%eax
  80231d:	89 d3                	mov    %edx,%ebx
  80231f:	89 f2                	mov    %esi,%edx
  802321:	f7 34 24             	divl   (%esp)
  802324:	89 d6                	mov    %edx,%esi
  802326:	d3 e3                	shl    %cl,%ebx
  802328:	f7 64 24 04          	mull   0x4(%esp)
  80232c:	39 d6                	cmp    %edx,%esi
  80232e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802332:	89 d1                	mov    %edx,%ecx
  802334:	89 c3                	mov    %eax,%ebx
  802336:	72 08                	jb     802340 <__umoddi3+0x110>
  802338:	75 11                	jne    80234b <__umoddi3+0x11b>
  80233a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80233e:	73 0b                	jae    80234b <__umoddi3+0x11b>
  802340:	2b 44 24 04          	sub    0x4(%esp),%eax
  802344:	1b 14 24             	sbb    (%esp),%edx
  802347:	89 d1                	mov    %edx,%ecx
  802349:	89 c3                	mov    %eax,%ebx
  80234b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80234f:	29 da                	sub    %ebx,%edx
  802351:	19 ce                	sbb    %ecx,%esi
  802353:	89 f9                	mov    %edi,%ecx
  802355:	89 f0                	mov    %esi,%eax
  802357:	d3 e0                	shl    %cl,%eax
  802359:	89 e9                	mov    %ebp,%ecx
  80235b:	d3 ea                	shr    %cl,%edx
  80235d:	89 e9                	mov    %ebp,%ecx
  80235f:	d3 ee                	shr    %cl,%esi
  802361:	09 d0                	or     %edx,%eax
  802363:	89 f2                	mov    %esi,%edx
  802365:	83 c4 1c             	add    $0x1c,%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
  802370:	29 f9                	sub    %edi,%ecx
  802372:	19 d6                	sbb    %edx,%esi
  802374:	89 74 24 04          	mov    %esi,0x4(%esp)
  802378:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80237c:	e9 18 ff ff ff       	jmp    802299 <__umoddi3+0x69>
