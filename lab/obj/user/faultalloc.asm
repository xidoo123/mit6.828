
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
  800040:	68 80 1e 80 00       	push   $0x801e80
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
  80006a:	68 a0 1e 80 00       	push   $0x801ea0
  80006f:	6a 0e                	push   $0xe
  800071:	68 8a 1e 80 00       	push   $0x801e8a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 1e 80 00       	push   $0x801ecc
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
  80009c:	e8 db 0c 00 00       	call   800d7c <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 9c 1e 80 00       	push   $0x801e9c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 9c 1e 80 00       	push   $0x801e9c
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
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800116:	e8 97 0e 00 00       	call   800fb2 <close_all>
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
  800148:	68 f8 1e 80 00       	push   $0x801ef8
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 45 23 80 00 	movl   $0x802345,(%esp)
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
  800266:	e8 75 19 00 00       	call   801be0 <__udivdi3>
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
  8002a9:	e8 62 1a 00 00       	call   801d10 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 1b 1f 80 00 	movsbl 0x801f1b(%eax),%eax
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
  8003ad:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
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
  800471:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	75 18                	jne    800494 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80047c:	50                   	push   %eax
  80047d:	68 33 1f 80 00       	push   $0x801f33
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
  800495:	68 1e 23 80 00       	push   $0x80231e
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
  8004b9:	b8 2c 1f 80 00       	mov    $0x801f2c,%eax
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
  800b34:	68 1f 22 80 00       	push   $0x80221f
  800b39:	6a 23                	push   $0x23
  800b3b:	68 3c 22 80 00       	push   $0x80223c
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
  800bb5:	68 1f 22 80 00       	push   $0x80221f
  800bba:	6a 23                	push   $0x23
  800bbc:	68 3c 22 80 00       	push   $0x80223c
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
  800bf7:	68 1f 22 80 00       	push   $0x80221f
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 3c 22 80 00       	push   $0x80223c
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
  800c39:	68 1f 22 80 00       	push   $0x80221f
  800c3e:	6a 23                	push   $0x23
  800c40:	68 3c 22 80 00       	push   $0x80223c
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
  800c7b:	68 1f 22 80 00       	push   $0x80221f
  800c80:	6a 23                	push   $0x23
  800c82:	68 3c 22 80 00       	push   $0x80223c
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
  800cbd:	68 1f 22 80 00       	push   $0x80221f
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 3c 22 80 00       	push   $0x80223c
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
  800cff:	68 1f 22 80 00       	push   $0x80221f
  800d04:	6a 23                	push   $0x23
  800d06:	68 3c 22 80 00       	push   $0x80223c
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
  800d63:	68 1f 22 80 00       	push   $0x80221f
  800d68:	6a 23                	push   $0x23
  800d6a:	68 3c 22 80 00       	push   $0x80223c
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

00800d7c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d82:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d89:	75 2e                	jne    800db9 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800d8b:	e8 bd fd ff ff       	call   800b4d <sys_getenvid>
  800d90:	83 ec 04             	sub    $0x4,%esp
  800d93:	68 07 0e 00 00       	push   $0xe07
  800d98:	68 00 f0 bf ee       	push   $0xeebff000
  800d9d:	50                   	push   %eax
  800d9e:	e8 e8 fd ff ff       	call   800b8b <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800da3:	e8 a5 fd ff ff       	call   800b4d <sys_getenvid>
  800da8:	83 c4 08             	add    $0x8,%esp
  800dab:	68 c3 0d 80 00       	push   $0x800dc3
  800db0:	50                   	push   %eax
  800db1:	e8 20 ff ff ff       	call   800cd6 <sys_env_set_pgfault_upcall>
  800db6:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dc3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dc4:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800dc9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dcb:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  800dce:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800dd2:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800dd6:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800dd9:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800ddc:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  800ddd:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800de0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800de1:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800de2:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800de6:	c3                   	ret    

00800de7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ded:	05 00 00 00 30       	add    $0x30000000,%eax
  800df2:	c1 e8 0c             	shr    $0xc,%eax
}
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	05 00 00 00 30       	add    $0x30000000,%eax
  800e02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e07:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e14:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e19:	89 c2                	mov    %eax,%edx
  800e1b:	c1 ea 16             	shr    $0x16,%edx
  800e1e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e25:	f6 c2 01             	test   $0x1,%dl
  800e28:	74 11                	je     800e3b <fd_alloc+0x2d>
  800e2a:	89 c2                	mov    %eax,%edx
  800e2c:	c1 ea 0c             	shr    $0xc,%edx
  800e2f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e36:	f6 c2 01             	test   $0x1,%dl
  800e39:	75 09                	jne    800e44 <fd_alloc+0x36>
			*fd_store = fd;
  800e3b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e42:	eb 17                	jmp    800e5b <fd_alloc+0x4d>
  800e44:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e49:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e4e:	75 c9                	jne    800e19 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e50:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e56:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e63:	83 f8 1f             	cmp    $0x1f,%eax
  800e66:	77 36                	ja     800e9e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e68:	c1 e0 0c             	shl    $0xc,%eax
  800e6b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e70:	89 c2                	mov    %eax,%edx
  800e72:	c1 ea 16             	shr    $0x16,%edx
  800e75:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7c:	f6 c2 01             	test   $0x1,%dl
  800e7f:	74 24                	je     800ea5 <fd_lookup+0x48>
  800e81:	89 c2                	mov    %eax,%edx
  800e83:	c1 ea 0c             	shr    $0xc,%edx
  800e86:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8d:	f6 c2 01             	test   $0x1,%dl
  800e90:	74 1a                	je     800eac <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e95:	89 02                	mov    %eax,(%edx)
	return 0;
  800e97:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9c:	eb 13                	jmp    800eb1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea3:	eb 0c                	jmp    800eb1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eaa:	eb 05                	jmp    800eb1 <fd_lookup+0x54>
  800eac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	83 ec 08             	sub    $0x8,%esp
  800eb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebc:	ba cc 22 80 00       	mov    $0x8022cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ec1:	eb 13                	jmp    800ed6 <dev_lookup+0x23>
  800ec3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ec6:	39 08                	cmp    %ecx,(%eax)
  800ec8:	75 0c                	jne    800ed6 <dev_lookup+0x23>
			*dev = devtab[i];
  800eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed4:	eb 2e                	jmp    800f04 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed6:	8b 02                	mov    (%edx),%eax
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	75 e7                	jne    800ec3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800edc:	a1 04 40 80 00       	mov    0x804004,%eax
  800ee1:	8b 40 48             	mov    0x48(%eax),%eax
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	51                   	push   %ecx
  800ee8:	50                   	push   %eax
  800ee9:	68 4c 22 80 00       	push   $0x80224c
  800eee:	e8 10 f3 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800efc:	83 c4 10             	add    $0x10,%esp
  800eff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 10             	sub    $0x10,%esp
  800f0e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f17:	50                   	push   %eax
  800f18:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f1e:	c1 e8 0c             	shr    $0xc,%eax
  800f21:	50                   	push   %eax
  800f22:	e8 36 ff ff ff       	call   800e5d <fd_lookup>
  800f27:	83 c4 08             	add    $0x8,%esp
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	78 05                	js     800f33 <fd_close+0x2d>
	    || fd != fd2)
  800f2e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f31:	74 0c                	je     800f3f <fd_close+0x39>
		return (must_exist ? r : 0);
  800f33:	84 db                	test   %bl,%bl
  800f35:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3a:	0f 44 c2             	cmove  %edx,%eax
  800f3d:	eb 41                	jmp    800f80 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f3f:	83 ec 08             	sub    $0x8,%esp
  800f42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f45:	50                   	push   %eax
  800f46:	ff 36                	pushl  (%esi)
  800f48:	e8 66 ff ff ff       	call   800eb3 <dev_lookup>
  800f4d:	89 c3                	mov    %eax,%ebx
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	78 1a                	js     800f70 <fd_close+0x6a>
		if (dev->dev_close)
  800f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f59:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f5c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f61:	85 c0                	test   %eax,%eax
  800f63:	74 0b                	je     800f70 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f65:	83 ec 0c             	sub    $0xc,%esp
  800f68:	56                   	push   %esi
  800f69:	ff d0                	call   *%eax
  800f6b:	89 c3                	mov    %eax,%ebx
  800f6d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f70:	83 ec 08             	sub    $0x8,%esp
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	e8 95 fc ff ff       	call   800c10 <sys_page_unmap>
	return r;
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	89 d8                	mov    %ebx,%eax
}
  800f80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f90:	50                   	push   %eax
  800f91:	ff 75 08             	pushl  0x8(%ebp)
  800f94:	e8 c4 fe ff ff       	call   800e5d <fd_lookup>
  800f99:	83 c4 08             	add    $0x8,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 10                	js     800fb0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fa0:	83 ec 08             	sub    $0x8,%esp
  800fa3:	6a 01                	push   $0x1
  800fa5:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa8:	e8 59 ff ff ff       	call   800f06 <fd_close>
  800fad:	83 c4 10             	add    $0x10,%esp
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <close_all>:

void
close_all(void)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	53                   	push   %ebx
  800fc2:	e8 c0 ff ff ff       	call   800f87 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc7:	83 c3 01             	add    $0x1,%ebx
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	83 fb 20             	cmp    $0x20,%ebx
  800fd0:	75 ec                	jne    800fbe <close_all+0xc>
		close(i);
}
  800fd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	57                   	push   %edi
  800fdb:	56                   	push   %esi
  800fdc:	53                   	push   %ebx
  800fdd:	83 ec 2c             	sub    $0x2c,%esp
  800fe0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	ff 75 08             	pushl  0x8(%ebp)
  800fea:	e8 6e fe ff ff       	call   800e5d <fd_lookup>
  800fef:	83 c4 08             	add    $0x8,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	0f 88 c1 00 00 00    	js     8010bb <dup+0xe4>
		return r;
	close(newfdnum);
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	56                   	push   %esi
  800ffe:	e8 84 ff ff ff       	call   800f87 <close>

	newfd = INDEX2FD(newfdnum);
  801003:	89 f3                	mov    %esi,%ebx
  801005:	c1 e3 0c             	shl    $0xc,%ebx
  801008:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80100e:	83 c4 04             	add    $0x4,%esp
  801011:	ff 75 e4             	pushl  -0x1c(%ebp)
  801014:	e8 de fd ff ff       	call   800df7 <fd2data>
  801019:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80101b:	89 1c 24             	mov    %ebx,(%esp)
  80101e:	e8 d4 fd ff ff       	call   800df7 <fd2data>
  801023:	83 c4 10             	add    $0x10,%esp
  801026:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801029:	89 f8                	mov    %edi,%eax
  80102b:	c1 e8 16             	shr    $0x16,%eax
  80102e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801035:	a8 01                	test   $0x1,%al
  801037:	74 37                	je     801070 <dup+0x99>
  801039:	89 f8                	mov    %edi,%eax
  80103b:	c1 e8 0c             	shr    $0xc,%eax
  80103e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801045:	f6 c2 01             	test   $0x1,%dl
  801048:	74 26                	je     801070 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80104a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	25 07 0e 00 00       	and    $0xe07,%eax
  801059:	50                   	push   %eax
  80105a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80105d:	6a 00                	push   $0x0
  80105f:	57                   	push   %edi
  801060:	6a 00                	push   $0x0
  801062:	e8 67 fb ff ff       	call   800bce <sys_page_map>
  801067:	89 c7                	mov    %eax,%edi
  801069:	83 c4 20             	add    $0x20,%esp
  80106c:	85 c0                	test   %eax,%eax
  80106e:	78 2e                	js     80109e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801070:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801073:	89 d0                	mov    %edx,%eax
  801075:	c1 e8 0c             	shr    $0xc,%eax
  801078:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107f:	83 ec 0c             	sub    $0xc,%esp
  801082:	25 07 0e 00 00       	and    $0xe07,%eax
  801087:	50                   	push   %eax
  801088:	53                   	push   %ebx
  801089:	6a 00                	push   $0x0
  80108b:	52                   	push   %edx
  80108c:	6a 00                	push   $0x0
  80108e:	e8 3b fb ff ff       	call   800bce <sys_page_map>
  801093:	89 c7                	mov    %eax,%edi
  801095:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801098:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80109a:	85 ff                	test   %edi,%edi
  80109c:	79 1d                	jns    8010bb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80109e:	83 ec 08             	sub    $0x8,%esp
  8010a1:	53                   	push   %ebx
  8010a2:	6a 00                	push   $0x0
  8010a4:	e8 67 fb ff ff       	call   800c10 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010a9:	83 c4 08             	add    $0x8,%esp
  8010ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010af:	6a 00                	push   $0x0
  8010b1:	e8 5a fb ff ff       	call   800c10 <sys_page_unmap>
	return r;
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	89 f8                	mov    %edi,%eax
}
  8010bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010be:	5b                   	pop    %ebx
  8010bf:	5e                   	pop    %esi
  8010c0:	5f                   	pop    %edi
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	53                   	push   %ebx
  8010c7:	83 ec 14             	sub    $0x14,%esp
  8010ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d0:	50                   	push   %eax
  8010d1:	53                   	push   %ebx
  8010d2:	e8 86 fd ff ff       	call   800e5d <fd_lookup>
  8010d7:	83 c4 08             	add    $0x8,%esp
  8010da:	89 c2                	mov    %eax,%edx
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	78 6d                	js     80114d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ea:	ff 30                	pushl  (%eax)
  8010ec:	e8 c2 fd ff ff       	call   800eb3 <dev_lookup>
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 4c                	js     801144 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010fb:	8b 42 08             	mov    0x8(%edx),%eax
  8010fe:	83 e0 03             	and    $0x3,%eax
  801101:	83 f8 01             	cmp    $0x1,%eax
  801104:	75 21                	jne    801127 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801106:	a1 04 40 80 00       	mov    0x804004,%eax
  80110b:	8b 40 48             	mov    0x48(%eax),%eax
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	53                   	push   %ebx
  801112:	50                   	push   %eax
  801113:	68 90 22 80 00       	push   $0x802290
  801118:	e8 e6 f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801125:	eb 26                	jmp    80114d <read+0x8a>
	}
	if (!dev->dev_read)
  801127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112a:	8b 40 08             	mov    0x8(%eax),%eax
  80112d:	85 c0                	test   %eax,%eax
  80112f:	74 17                	je     801148 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801131:	83 ec 04             	sub    $0x4,%esp
  801134:	ff 75 10             	pushl  0x10(%ebp)
  801137:	ff 75 0c             	pushl  0xc(%ebp)
  80113a:	52                   	push   %edx
  80113b:	ff d0                	call   *%eax
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	83 c4 10             	add    $0x10,%esp
  801142:	eb 09                	jmp    80114d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801144:	89 c2                	mov    %eax,%edx
  801146:	eb 05                	jmp    80114d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801148:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80114d:	89 d0                	mov    %edx,%eax
  80114f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801152:	c9                   	leave  
  801153:	c3                   	ret    

00801154 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
  80115a:	83 ec 0c             	sub    $0xc,%esp
  80115d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801160:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801163:	bb 00 00 00 00       	mov    $0x0,%ebx
  801168:	eb 21                	jmp    80118b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	89 f0                	mov    %esi,%eax
  80116f:	29 d8                	sub    %ebx,%eax
  801171:	50                   	push   %eax
  801172:	89 d8                	mov    %ebx,%eax
  801174:	03 45 0c             	add    0xc(%ebp),%eax
  801177:	50                   	push   %eax
  801178:	57                   	push   %edi
  801179:	e8 45 ff ff ff       	call   8010c3 <read>
		if (m < 0)
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	85 c0                	test   %eax,%eax
  801183:	78 10                	js     801195 <readn+0x41>
			return m;
		if (m == 0)
  801185:	85 c0                	test   %eax,%eax
  801187:	74 0a                	je     801193 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801189:	01 c3                	add    %eax,%ebx
  80118b:	39 f3                	cmp    %esi,%ebx
  80118d:	72 db                	jb     80116a <readn+0x16>
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	eb 02                	jmp    801195 <readn+0x41>
  801193:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 14             	sub    $0x14,%esp
  8011a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011aa:	50                   	push   %eax
  8011ab:	53                   	push   %ebx
  8011ac:	e8 ac fc ff ff       	call   800e5d <fd_lookup>
  8011b1:	83 c4 08             	add    $0x8,%esp
  8011b4:	89 c2                	mov    %eax,%edx
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 68                	js     801222 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	ff 30                	pushl  (%eax)
  8011c6:	e8 e8 fc ff ff       	call   800eb3 <dev_lookup>
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 47                	js     801219 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d9:	75 21                	jne    8011fc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011db:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e0:	8b 40 48             	mov    0x48(%eax),%eax
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	53                   	push   %ebx
  8011e7:	50                   	push   %eax
  8011e8:	68 ac 22 80 00       	push   $0x8022ac
  8011ed:	e8 11 f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011fa:	eb 26                	jmp    801222 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801202:	85 d2                	test   %edx,%edx
  801204:	74 17                	je     80121d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801206:	83 ec 04             	sub    $0x4,%esp
  801209:	ff 75 10             	pushl  0x10(%ebp)
  80120c:	ff 75 0c             	pushl  0xc(%ebp)
  80120f:	50                   	push   %eax
  801210:	ff d2                	call   *%edx
  801212:	89 c2                	mov    %eax,%edx
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	eb 09                	jmp    801222 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801219:	89 c2                	mov    %eax,%edx
  80121b:	eb 05                	jmp    801222 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80121d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801222:	89 d0                	mov    %edx,%eax
  801224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801227:	c9                   	leave  
  801228:	c3                   	ret    

00801229 <seek>:

int
seek(int fdnum, off_t offset)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801232:	50                   	push   %eax
  801233:	ff 75 08             	pushl  0x8(%ebp)
  801236:	e8 22 fc ff ff       	call   800e5d <fd_lookup>
  80123b:	83 c4 08             	add    $0x8,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 0e                	js     801250 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801242:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801245:	8b 55 0c             	mov    0xc(%ebp),%edx
  801248:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80124b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801250:	c9                   	leave  
  801251:	c3                   	ret    

00801252 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	53                   	push   %ebx
  801256:	83 ec 14             	sub    $0x14,%esp
  801259:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125f:	50                   	push   %eax
  801260:	53                   	push   %ebx
  801261:	e8 f7 fb ff ff       	call   800e5d <fd_lookup>
  801266:	83 c4 08             	add    $0x8,%esp
  801269:	89 c2                	mov    %eax,%edx
  80126b:	85 c0                	test   %eax,%eax
  80126d:	78 65                	js     8012d4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126f:	83 ec 08             	sub    $0x8,%esp
  801272:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801275:	50                   	push   %eax
  801276:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801279:	ff 30                	pushl  (%eax)
  80127b:	e8 33 fc ff ff       	call   800eb3 <dev_lookup>
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	85 c0                	test   %eax,%eax
  801285:	78 44                	js     8012cb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801287:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128e:	75 21                	jne    8012b1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801290:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801295:	8b 40 48             	mov    0x48(%eax),%eax
  801298:	83 ec 04             	sub    $0x4,%esp
  80129b:	53                   	push   %ebx
  80129c:	50                   	push   %eax
  80129d:	68 6c 22 80 00       	push   $0x80226c
  8012a2:	e8 5c ef ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012af:	eb 23                	jmp    8012d4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b4:	8b 52 18             	mov    0x18(%edx),%edx
  8012b7:	85 d2                	test   %edx,%edx
  8012b9:	74 14                	je     8012cf <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	ff 75 0c             	pushl  0xc(%ebp)
  8012c1:	50                   	push   %eax
  8012c2:	ff d2                	call   *%edx
  8012c4:	89 c2                	mov    %eax,%edx
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	eb 09                	jmp    8012d4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cb:	89 c2                	mov    %eax,%edx
  8012cd:	eb 05                	jmp    8012d4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012d4:	89 d0                	mov    %edx,%eax
  8012d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d9:	c9                   	leave  
  8012da:	c3                   	ret    

008012db <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	53                   	push   %ebx
  8012df:	83 ec 14             	sub    $0x14,%esp
  8012e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e8:	50                   	push   %eax
  8012e9:	ff 75 08             	pushl  0x8(%ebp)
  8012ec:	e8 6c fb ff ff       	call   800e5d <fd_lookup>
  8012f1:	83 c4 08             	add    $0x8,%esp
  8012f4:	89 c2                	mov    %eax,%edx
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 58                	js     801352 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801304:	ff 30                	pushl  (%eax)
  801306:	e8 a8 fb ff ff       	call   800eb3 <dev_lookup>
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 37                	js     801349 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801312:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801315:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801319:	74 32                	je     80134d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80131b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80131e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801325:	00 00 00 
	stat->st_isdir = 0;
  801328:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80132f:	00 00 00 
	stat->st_dev = dev;
  801332:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	53                   	push   %ebx
  80133c:	ff 75 f0             	pushl  -0x10(%ebp)
  80133f:	ff 50 14             	call   *0x14(%eax)
  801342:	89 c2                	mov    %eax,%edx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	eb 09                	jmp    801352 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801349:	89 c2                	mov    %eax,%edx
  80134b:	eb 05                	jmp    801352 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80134d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801352:	89 d0                	mov    %edx,%eax
  801354:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	56                   	push   %esi
  80135d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	6a 00                	push   $0x0
  801363:	ff 75 08             	pushl  0x8(%ebp)
  801366:	e8 b7 01 00 00       	call   801522 <open>
  80136b:	89 c3                	mov    %eax,%ebx
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	85 c0                	test   %eax,%eax
  801372:	78 1b                	js     80138f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	ff 75 0c             	pushl  0xc(%ebp)
  80137a:	50                   	push   %eax
  80137b:	e8 5b ff ff ff       	call   8012db <fstat>
  801380:	89 c6                	mov    %eax,%esi
	close(fd);
  801382:	89 1c 24             	mov    %ebx,(%esp)
  801385:	e8 fd fb ff ff       	call   800f87 <close>
	return r;
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	89 f0                	mov    %esi,%eax
}
  80138f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801392:	5b                   	pop    %ebx
  801393:	5e                   	pop    %esi
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	56                   	push   %esi
  80139a:	53                   	push   %ebx
  80139b:	89 c6                	mov    %eax,%esi
  80139d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80139f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013a6:	75 12                	jne    8013ba <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	6a 01                	push   $0x1
  8013ad:	e8 ae 07 00 00       	call   801b60 <ipc_find_env>
  8013b2:	a3 00 40 80 00       	mov    %eax,0x804000
  8013b7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ba:	6a 07                	push   $0x7
  8013bc:	68 00 50 80 00       	push   $0x805000
  8013c1:	56                   	push   %esi
  8013c2:	ff 35 00 40 80 00    	pushl  0x804000
  8013c8:	e8 3f 07 00 00       	call   801b0c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013cd:	83 c4 0c             	add    $0xc,%esp
  8013d0:	6a 00                	push   $0x0
  8013d2:	53                   	push   %ebx
  8013d3:	6a 00                	push   $0x0
  8013d5:	e8 cb 06 00 00       	call   801aa5 <ipc_recv>
}
  8013da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ed:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801404:	e8 8d ff ff ff       	call   801396 <fsipc>
}
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	8b 40 0c             	mov    0xc(%eax),%eax
  801417:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80141c:	ba 00 00 00 00       	mov    $0x0,%edx
  801421:	b8 06 00 00 00       	mov    $0x6,%eax
  801426:	e8 6b ff ff ff       	call   801396 <fsipc>
}
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    

0080142d <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	53                   	push   %ebx
  801431:	83 ec 04             	sub    $0x4,%esp
  801434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801437:	8b 45 08             	mov    0x8(%ebp),%eax
  80143a:	8b 40 0c             	mov    0xc(%eax),%eax
  80143d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801442:	ba 00 00 00 00       	mov    $0x0,%edx
  801447:	b8 05 00 00 00       	mov    $0x5,%eax
  80144c:	e8 45 ff ff ff       	call   801396 <fsipc>
  801451:	85 c0                	test   %eax,%eax
  801453:	78 2c                	js     801481 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	68 00 50 80 00       	push   $0x805000
  80145d:	53                   	push   %ebx
  80145e:	e8 25 f3 ff ff       	call   800788 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801463:	a1 80 50 80 00       	mov    0x805080,%eax
  801468:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80146e:	a1 84 50 80 00       	mov    0x805084,%eax
  801473:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801481:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80148c:	68 dc 22 80 00       	push   $0x8022dc
  801491:	68 90 00 00 00       	push   $0x90
  801496:	68 fa 22 80 00       	push   $0x8022fa
  80149b:	e8 8a ec ff ff       	call   80012a <_panic>

008014a0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	56                   	push   %esi
  8014a4:	53                   	push   %ebx
  8014a5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014b3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014be:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c3:	e8 ce fe ff ff       	call   801396 <fsipc>
  8014c8:	89 c3                	mov    %eax,%ebx
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 4b                	js     801519 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014ce:	39 c6                	cmp    %eax,%esi
  8014d0:	73 16                	jae    8014e8 <devfile_read+0x48>
  8014d2:	68 05 23 80 00       	push   $0x802305
  8014d7:	68 0c 23 80 00       	push   $0x80230c
  8014dc:	6a 7c                	push   $0x7c
  8014de:	68 fa 22 80 00       	push   $0x8022fa
  8014e3:	e8 42 ec ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  8014e8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ed:	7e 16                	jle    801505 <devfile_read+0x65>
  8014ef:	68 21 23 80 00       	push   $0x802321
  8014f4:	68 0c 23 80 00       	push   $0x80230c
  8014f9:	6a 7d                	push   $0x7d
  8014fb:	68 fa 22 80 00       	push   $0x8022fa
  801500:	e8 25 ec ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801505:	83 ec 04             	sub    $0x4,%esp
  801508:	50                   	push   %eax
  801509:	68 00 50 80 00       	push   $0x805000
  80150e:	ff 75 0c             	pushl  0xc(%ebp)
  801511:	e8 04 f4 ff ff       	call   80091a <memmove>
	return r;
  801516:	83 c4 10             	add    $0x10,%esp
}
  801519:	89 d8                	mov    %ebx,%eax
  80151b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5e                   	pop    %esi
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	53                   	push   %ebx
  801526:	83 ec 20             	sub    $0x20,%esp
  801529:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80152c:	53                   	push   %ebx
  80152d:	e8 1d f2 ff ff       	call   80074f <strlen>
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80153a:	7f 67                	jg     8015a3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153c:	83 ec 0c             	sub    $0xc,%esp
  80153f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801542:	50                   	push   %eax
  801543:	e8 c6 f8 ff ff       	call   800e0e <fd_alloc>
  801548:	83 c4 10             	add    $0x10,%esp
		return r;
  80154b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 57                	js     8015a8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	53                   	push   %ebx
  801555:	68 00 50 80 00       	push   $0x805000
  80155a:	e8 29 f2 ff ff       	call   800788 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80155f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801562:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801567:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156a:	b8 01 00 00 00       	mov    $0x1,%eax
  80156f:	e8 22 fe ff ff       	call   801396 <fsipc>
  801574:	89 c3                	mov    %eax,%ebx
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	85 c0                	test   %eax,%eax
  80157b:	79 14                	jns    801591 <open+0x6f>
		fd_close(fd, 0);
  80157d:	83 ec 08             	sub    $0x8,%esp
  801580:	6a 00                	push   $0x0
  801582:	ff 75 f4             	pushl  -0xc(%ebp)
  801585:	e8 7c f9 ff ff       	call   800f06 <fd_close>
		return r;
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	89 da                	mov    %ebx,%edx
  80158f:	eb 17                	jmp    8015a8 <open+0x86>
	}

	return fd2num(fd);
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	ff 75 f4             	pushl  -0xc(%ebp)
  801597:	e8 4b f8 ff ff       	call   800de7 <fd2num>
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	eb 05                	jmp    8015a8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015a3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015a8:	89 d0                	mov    %edx,%eax
  8015aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8015bf:	e8 d2 fd ff ff       	call   801396 <fsipc>
}
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	56                   	push   %esi
  8015ca:	53                   	push   %ebx
  8015cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015ce:	83 ec 0c             	sub    $0xc,%esp
  8015d1:	ff 75 08             	pushl  0x8(%ebp)
  8015d4:	e8 1e f8 ff ff       	call   800df7 <fd2data>
  8015d9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015db:	83 c4 08             	add    $0x8,%esp
  8015de:	68 2d 23 80 00       	push   $0x80232d
  8015e3:	53                   	push   %ebx
  8015e4:	e8 9f f1 ff ff       	call   800788 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015e9:	8b 46 04             	mov    0x4(%esi),%eax
  8015ec:	2b 06                	sub    (%esi),%eax
  8015ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015fb:	00 00 00 
	stat->st_dev = &devpipe;
  8015fe:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801605:	30 80 00 
	return 0;
}
  801608:	b8 00 00 00 00       	mov    $0x0,%eax
  80160d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	53                   	push   %ebx
  801618:	83 ec 0c             	sub    $0xc,%esp
  80161b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80161e:	53                   	push   %ebx
  80161f:	6a 00                	push   $0x0
  801621:	e8 ea f5 ff ff       	call   800c10 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801626:	89 1c 24             	mov    %ebx,(%esp)
  801629:	e8 c9 f7 ff ff       	call   800df7 <fd2data>
  80162e:	83 c4 08             	add    $0x8,%esp
  801631:	50                   	push   %eax
  801632:	6a 00                	push   $0x0
  801634:	e8 d7 f5 ff ff       	call   800c10 <sys_page_unmap>
}
  801639:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	57                   	push   %edi
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	83 ec 1c             	sub    $0x1c,%esp
  801647:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80164a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80164c:	a1 04 40 80 00       	mov    0x804004,%eax
  801651:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801654:	83 ec 0c             	sub    $0xc,%esp
  801657:	ff 75 e0             	pushl  -0x20(%ebp)
  80165a:	e8 3a 05 00 00       	call   801b99 <pageref>
  80165f:	89 c3                	mov    %eax,%ebx
  801661:	89 3c 24             	mov    %edi,(%esp)
  801664:	e8 30 05 00 00       	call   801b99 <pageref>
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	39 c3                	cmp    %eax,%ebx
  80166e:	0f 94 c1             	sete   %cl
  801671:	0f b6 c9             	movzbl %cl,%ecx
  801674:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801677:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80167d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801680:	39 ce                	cmp    %ecx,%esi
  801682:	74 1b                	je     80169f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801684:	39 c3                	cmp    %eax,%ebx
  801686:	75 c4                	jne    80164c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801688:	8b 42 58             	mov    0x58(%edx),%eax
  80168b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80168e:	50                   	push   %eax
  80168f:	56                   	push   %esi
  801690:	68 34 23 80 00       	push   $0x802334
  801695:	e8 69 eb ff ff       	call   800203 <cprintf>
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	eb ad                	jmp    80164c <_pipeisclosed+0xe>
	}
}
  80169f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a5:	5b                   	pop    %ebx
  8016a6:	5e                   	pop    %esi
  8016a7:	5f                   	pop    %edi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	57                   	push   %edi
  8016ae:	56                   	push   %esi
  8016af:	53                   	push   %ebx
  8016b0:	83 ec 28             	sub    $0x28,%esp
  8016b3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016b6:	56                   	push   %esi
  8016b7:	e8 3b f7 ff ff       	call   800df7 <fd2data>
  8016bc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	bf 00 00 00 00       	mov    $0x0,%edi
  8016c6:	eb 4b                	jmp    801713 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016c8:	89 da                	mov    %ebx,%edx
  8016ca:	89 f0                	mov    %esi,%eax
  8016cc:	e8 6d ff ff ff       	call   80163e <_pipeisclosed>
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	75 48                	jne    80171d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016d5:	e8 92 f4 ff ff       	call   800b6c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016da:	8b 43 04             	mov    0x4(%ebx),%eax
  8016dd:	8b 0b                	mov    (%ebx),%ecx
  8016df:	8d 51 20             	lea    0x20(%ecx),%edx
  8016e2:	39 d0                	cmp    %edx,%eax
  8016e4:	73 e2                	jae    8016c8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016ed:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	c1 fa 1f             	sar    $0x1f,%edx
  8016f5:	89 d1                	mov    %edx,%ecx
  8016f7:	c1 e9 1b             	shr    $0x1b,%ecx
  8016fa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016fd:	83 e2 1f             	and    $0x1f,%edx
  801700:	29 ca                	sub    %ecx,%edx
  801702:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801706:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80170a:	83 c0 01             	add    $0x1,%eax
  80170d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801710:	83 c7 01             	add    $0x1,%edi
  801713:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801716:	75 c2                	jne    8016da <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801718:	8b 45 10             	mov    0x10(%ebp),%eax
  80171b:	eb 05                	jmp    801722 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80171d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801722:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801725:	5b                   	pop    %ebx
  801726:	5e                   	pop    %esi
  801727:	5f                   	pop    %edi
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	57                   	push   %edi
  80172e:	56                   	push   %esi
  80172f:	53                   	push   %ebx
  801730:	83 ec 18             	sub    $0x18,%esp
  801733:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801736:	57                   	push   %edi
  801737:	e8 bb f6 ff ff       	call   800df7 <fd2data>
  80173c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	bb 00 00 00 00       	mov    $0x0,%ebx
  801746:	eb 3d                	jmp    801785 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801748:	85 db                	test   %ebx,%ebx
  80174a:	74 04                	je     801750 <devpipe_read+0x26>
				return i;
  80174c:	89 d8                	mov    %ebx,%eax
  80174e:	eb 44                	jmp    801794 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801750:	89 f2                	mov    %esi,%edx
  801752:	89 f8                	mov    %edi,%eax
  801754:	e8 e5 fe ff ff       	call   80163e <_pipeisclosed>
  801759:	85 c0                	test   %eax,%eax
  80175b:	75 32                	jne    80178f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80175d:	e8 0a f4 ff ff       	call   800b6c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801762:	8b 06                	mov    (%esi),%eax
  801764:	3b 46 04             	cmp    0x4(%esi),%eax
  801767:	74 df                	je     801748 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801769:	99                   	cltd   
  80176a:	c1 ea 1b             	shr    $0x1b,%edx
  80176d:	01 d0                	add    %edx,%eax
  80176f:	83 e0 1f             	and    $0x1f,%eax
  801772:	29 d0                	sub    %edx,%eax
  801774:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80177f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801782:	83 c3 01             	add    $0x1,%ebx
  801785:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801788:	75 d8                	jne    801762 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80178a:	8b 45 10             	mov    0x10(%ebp),%eax
  80178d:	eb 05                	jmp    801794 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80178f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801794:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801797:	5b                   	pop    %ebx
  801798:	5e                   	pop    %esi
  801799:	5f                   	pop    %edi
  80179a:	5d                   	pop    %ebp
  80179b:	c3                   	ret    

0080179c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	56                   	push   %esi
  8017a0:	53                   	push   %ebx
  8017a1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a7:	50                   	push   %eax
  8017a8:	e8 61 f6 ff ff       	call   800e0e <fd_alloc>
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	0f 88 2c 01 00 00    	js     8018e6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ba:	83 ec 04             	sub    $0x4,%esp
  8017bd:	68 07 04 00 00       	push   $0x407
  8017c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c5:	6a 00                	push   $0x0
  8017c7:	e8 bf f3 ff ff       	call   800b8b <sys_page_alloc>
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	89 c2                	mov    %eax,%edx
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	0f 88 0d 01 00 00    	js     8018e6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017df:	50                   	push   %eax
  8017e0:	e8 29 f6 ff ff       	call   800e0e <fd_alloc>
  8017e5:	89 c3                	mov    %eax,%ebx
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	0f 88 e2 00 00 00    	js     8018d4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f2:	83 ec 04             	sub    $0x4,%esp
  8017f5:	68 07 04 00 00       	push   $0x407
  8017fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8017fd:	6a 00                	push   $0x0
  8017ff:	e8 87 f3 ff ff       	call   800b8b <sys_page_alloc>
  801804:	89 c3                	mov    %eax,%ebx
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	85 c0                	test   %eax,%eax
  80180b:	0f 88 c3 00 00 00    	js     8018d4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801811:	83 ec 0c             	sub    $0xc,%esp
  801814:	ff 75 f4             	pushl  -0xc(%ebp)
  801817:	e8 db f5 ff ff       	call   800df7 <fd2data>
  80181c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181e:	83 c4 0c             	add    $0xc,%esp
  801821:	68 07 04 00 00       	push   $0x407
  801826:	50                   	push   %eax
  801827:	6a 00                	push   $0x0
  801829:	e8 5d f3 ff ff       	call   800b8b <sys_page_alloc>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	0f 88 89 00 00 00    	js     8018c4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80183b:	83 ec 0c             	sub    $0xc,%esp
  80183e:	ff 75 f0             	pushl  -0x10(%ebp)
  801841:	e8 b1 f5 ff ff       	call   800df7 <fd2data>
  801846:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80184d:	50                   	push   %eax
  80184e:	6a 00                	push   $0x0
  801850:	56                   	push   %esi
  801851:	6a 00                	push   $0x0
  801853:	e8 76 f3 ff ff       	call   800bce <sys_page_map>
  801858:	89 c3                	mov    %eax,%ebx
  80185a:	83 c4 20             	add    $0x20,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 55                	js     8018b6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801861:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801867:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80186c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801876:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80187c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801881:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801884:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	ff 75 f4             	pushl  -0xc(%ebp)
  801891:	e8 51 f5 ff ff       	call   800de7 <fd2num>
  801896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801899:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80189b:	83 c4 04             	add    $0x4,%esp
  80189e:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a1:	e8 41 f5 ff ff       	call   800de7 <fd2num>
  8018a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018a9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b4:	eb 30                	jmp    8018e6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018b6:	83 ec 08             	sub    $0x8,%esp
  8018b9:	56                   	push   %esi
  8018ba:	6a 00                	push   $0x0
  8018bc:	e8 4f f3 ff ff       	call   800c10 <sys_page_unmap>
  8018c1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ca:	6a 00                	push   $0x0
  8018cc:	e8 3f f3 ff ff       	call   800c10 <sys_page_unmap>
  8018d1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018da:	6a 00                	push   $0x0
  8018dc:	e8 2f f3 ff ff       	call   800c10 <sys_page_unmap>
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018e6:	89 d0                	mov    %edx,%eax
  8018e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018eb:	5b                   	pop    %ebx
  8018ec:	5e                   	pop    %esi
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f8:	50                   	push   %eax
  8018f9:	ff 75 08             	pushl  0x8(%ebp)
  8018fc:	e8 5c f5 ff ff       	call   800e5d <fd_lookup>
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	78 18                	js     801920 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	ff 75 f4             	pushl  -0xc(%ebp)
  80190e:	e8 e4 f4 ff ff       	call   800df7 <fd2data>
	return _pipeisclosed(fd, p);
  801913:	89 c2                	mov    %eax,%edx
  801915:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801918:	e8 21 fd ff ff       	call   80163e <_pipeisclosed>
  80191d:	83 c4 10             	add    $0x10,%esp
}
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801932:	68 4c 23 80 00       	push   $0x80234c
  801937:	ff 75 0c             	pushl  0xc(%ebp)
  80193a:	e8 49 ee ff ff       	call   800788 <strcpy>
	return 0;
}
  80193f:	b8 00 00 00 00       	mov    $0x0,%eax
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	57                   	push   %edi
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
  80194c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801952:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801957:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80195d:	eb 2d                	jmp    80198c <devcons_write+0x46>
		m = n - tot;
  80195f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801962:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801964:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801967:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80196c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80196f:	83 ec 04             	sub    $0x4,%esp
  801972:	53                   	push   %ebx
  801973:	03 45 0c             	add    0xc(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	57                   	push   %edi
  801978:	e8 9d ef ff ff       	call   80091a <memmove>
		sys_cputs(buf, m);
  80197d:	83 c4 08             	add    $0x8,%esp
  801980:	53                   	push   %ebx
  801981:	57                   	push   %edi
  801982:	e8 48 f1 ff ff       	call   800acf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801987:	01 de                	add    %ebx,%esi
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	89 f0                	mov    %esi,%eax
  80198e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801991:	72 cc                	jb     80195f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801993:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801996:	5b                   	pop    %ebx
  801997:	5e                   	pop    %esi
  801998:	5f                   	pop    %edi
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019aa:	74 2a                	je     8019d6 <devcons_read+0x3b>
  8019ac:	eb 05                	jmp    8019b3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019ae:	e8 b9 f1 ff ff       	call   800b6c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019b3:	e8 35 f1 ff ff       	call   800aed <sys_cgetc>
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	74 f2                	je     8019ae <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 16                	js     8019d6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019c0:	83 f8 04             	cmp    $0x4,%eax
  8019c3:	74 0c                	je     8019d1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c8:	88 02                	mov    %al,(%edx)
	return 1;
  8019ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cf:	eb 05                	jmp    8019d6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019d1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019de:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019e4:	6a 01                	push   $0x1
  8019e6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019e9:	50                   	push   %eax
  8019ea:	e8 e0 f0 ff ff       	call   800acf <sys_cputs>
}
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <getchar>:

int
getchar(void)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019fa:	6a 01                	push   $0x1
  8019fc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019ff:	50                   	push   %eax
  801a00:	6a 00                	push   $0x0
  801a02:	e8 bc f6 ff ff       	call   8010c3 <read>
	if (r < 0)
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 0f                	js     801a1d <getchar+0x29>
		return r;
	if (r < 1)
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	7e 06                	jle    801a18 <getchar+0x24>
		return -E_EOF;
	return c;
  801a12:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a16:	eb 05                	jmp    801a1d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a18:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a1d:	c9                   	leave  
  801a1e:	c3                   	ret    

00801a1f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a28:	50                   	push   %eax
  801a29:	ff 75 08             	pushl  0x8(%ebp)
  801a2c:	e8 2c f4 ff ff       	call   800e5d <fd_lookup>
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 11                	js     801a49 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a41:	39 10                	cmp    %edx,(%eax)
  801a43:	0f 94 c0             	sete   %al
  801a46:	0f b6 c0             	movzbl %al,%eax
}
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <opencons>:

int
opencons(void)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a54:	50                   	push   %eax
  801a55:	e8 b4 f3 ff ff       	call   800e0e <fd_alloc>
  801a5a:	83 c4 10             	add    $0x10,%esp
		return r;
  801a5d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	78 3e                	js     801aa1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a63:	83 ec 04             	sub    $0x4,%esp
  801a66:	68 07 04 00 00       	push   $0x407
  801a6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6e:	6a 00                	push   $0x0
  801a70:	e8 16 f1 ff ff       	call   800b8b <sys_page_alloc>
  801a75:	83 c4 10             	add    $0x10,%esp
		return r;
  801a78:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 23                	js     801aa1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a7e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a87:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	50                   	push   %eax
  801a97:	e8 4b f3 ff ff       	call   800de7 <fd2num>
  801a9c:	89 c2                	mov    %eax,%edx
  801a9e:	83 c4 10             	add    $0x10,%esp
}
  801aa1:	89 d0                	mov    %edx,%eax
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	8b 75 08             	mov    0x8(%ebp),%esi
  801aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ab3:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ab5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801aba:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	50                   	push   %eax
  801ac1:	e8 75 f2 ff ff       	call   800d3b <sys_ipc_recv>

	if (from_env_store != NULL)
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	85 f6                	test   %esi,%esi
  801acb:	74 14                	je     801ae1 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801acd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	78 09                	js     801adf <ipc_recv+0x3a>
  801ad6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801adc:	8b 52 74             	mov    0x74(%edx),%edx
  801adf:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ae1:	85 db                	test   %ebx,%ebx
  801ae3:	74 14                	je     801af9 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 09                	js     801af7 <ipc_recv+0x52>
  801aee:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801af4:	8b 52 78             	mov    0x78(%edx),%edx
  801af7:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801af9:	85 c0                	test   %eax,%eax
  801afb:	78 08                	js     801b05 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801afd:	a1 04 40 80 00       	mov    0x804004,%eax
  801b02:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b08:	5b                   	pop    %ebx
  801b09:	5e                   	pop    %esi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	57                   	push   %edi
  801b10:	56                   	push   %esi
  801b11:	53                   	push   %ebx
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b18:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801b1e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801b20:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b25:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801b28:	ff 75 14             	pushl  0x14(%ebp)
  801b2b:	53                   	push   %ebx
  801b2c:	56                   	push   %esi
  801b2d:	57                   	push   %edi
  801b2e:	e8 e5 f1 ff ff       	call   800d18 <sys_ipc_try_send>

		if (err < 0) {
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	85 c0                	test   %eax,%eax
  801b38:	79 1e                	jns    801b58 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801b3a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b3d:	75 07                	jne    801b46 <ipc_send+0x3a>
				sys_yield();
  801b3f:	e8 28 f0 ff ff       	call   800b6c <sys_yield>
  801b44:	eb e2                	jmp    801b28 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801b46:	50                   	push   %eax
  801b47:	68 58 23 80 00       	push   $0x802358
  801b4c:	6a 49                	push   $0x49
  801b4e:	68 65 23 80 00       	push   $0x802365
  801b53:	e8 d2 e5 ff ff       	call   80012a <_panic>
		}

	} while (err < 0);

}
  801b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b6b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b6e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b74:	8b 52 50             	mov    0x50(%edx),%edx
  801b77:	39 ca                	cmp    %ecx,%edx
  801b79:	75 0d                	jne    801b88 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b7e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b83:	8b 40 48             	mov    0x48(%eax),%eax
  801b86:	eb 0f                	jmp    801b97 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b88:	83 c0 01             	add    $0x1,%eax
  801b8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b90:	75 d9                	jne    801b6b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b97:	5d                   	pop    %ebp
  801b98:	c3                   	ret    

00801b99 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9f:	89 d0                	mov    %edx,%eax
  801ba1:	c1 e8 16             	shr    $0x16,%eax
  801ba4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb0:	f6 c1 01             	test   $0x1,%cl
  801bb3:	74 1d                	je     801bd2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb5:	c1 ea 0c             	shr    $0xc,%edx
  801bb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bbf:	f6 c2 01             	test   $0x1,%dl
  801bc2:	74 0e                	je     801bd2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc4:	c1 ea 0c             	shr    $0xc,%edx
  801bc7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bce:	ef 
  801bcf:	0f b7 c0             	movzwl %ax,%eax
}
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    
  801bd4:	66 90                	xchg   %ax,%ax
  801bd6:	66 90                	xchg   %ax,%ax
  801bd8:	66 90                	xchg   %ax,%ax
  801bda:	66 90                	xchg   %ax,%ax
  801bdc:	66 90                	xchg   %ax,%ax
  801bde:	66 90                	xchg   %ax,%ax

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 1c             	sub    $0x1c,%esp
  801be7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801beb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bf7:	85 f6                	test   %esi,%esi
  801bf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bfd:	89 ca                	mov    %ecx,%edx
  801bff:	89 f8                	mov    %edi,%eax
  801c01:	75 3d                	jne    801c40 <__udivdi3+0x60>
  801c03:	39 cf                	cmp    %ecx,%edi
  801c05:	0f 87 c5 00 00 00    	ja     801cd0 <__udivdi3+0xf0>
  801c0b:	85 ff                	test   %edi,%edi
  801c0d:	89 fd                	mov    %edi,%ebp
  801c0f:	75 0b                	jne    801c1c <__udivdi3+0x3c>
  801c11:	b8 01 00 00 00       	mov    $0x1,%eax
  801c16:	31 d2                	xor    %edx,%edx
  801c18:	f7 f7                	div    %edi
  801c1a:	89 c5                	mov    %eax,%ebp
  801c1c:	89 c8                	mov    %ecx,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f5                	div    %ebp
  801c22:	89 c1                	mov    %eax,%ecx
  801c24:	89 d8                	mov    %ebx,%eax
  801c26:	89 cf                	mov    %ecx,%edi
  801c28:	f7 f5                	div    %ebp
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	89 fa                	mov    %edi,%edx
  801c30:	83 c4 1c             	add    $0x1c,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
  801c38:	90                   	nop
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	39 ce                	cmp    %ecx,%esi
  801c42:	77 74                	ja     801cb8 <__udivdi3+0xd8>
  801c44:	0f bd fe             	bsr    %esi,%edi
  801c47:	83 f7 1f             	xor    $0x1f,%edi
  801c4a:	0f 84 98 00 00 00    	je     801ce8 <__udivdi3+0x108>
  801c50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	89 c5                	mov    %eax,%ebp
  801c59:	29 fb                	sub    %edi,%ebx
  801c5b:	d3 e6                	shl    %cl,%esi
  801c5d:	89 d9                	mov    %ebx,%ecx
  801c5f:	d3 ed                	shr    %cl,%ebp
  801c61:	89 f9                	mov    %edi,%ecx
  801c63:	d3 e0                	shl    %cl,%eax
  801c65:	09 ee                	or     %ebp,%esi
  801c67:	89 d9                	mov    %ebx,%ecx
  801c69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6d:	89 d5                	mov    %edx,%ebp
  801c6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c73:	d3 ed                	shr    %cl,%ebp
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e2                	shl    %cl,%edx
  801c79:	89 d9                	mov    %ebx,%ecx
  801c7b:	d3 e8                	shr    %cl,%eax
  801c7d:	09 c2                	or     %eax,%edx
  801c7f:	89 d0                	mov    %edx,%eax
  801c81:	89 ea                	mov    %ebp,%edx
  801c83:	f7 f6                	div    %esi
  801c85:	89 d5                	mov    %edx,%ebp
  801c87:	89 c3                	mov    %eax,%ebx
  801c89:	f7 64 24 0c          	mull   0xc(%esp)
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	72 10                	jb     801ca1 <__udivdi3+0xc1>
  801c91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	d3 e6                	shl    %cl,%esi
  801c99:	39 c6                	cmp    %eax,%esi
  801c9b:	73 07                	jae    801ca4 <__udivdi3+0xc4>
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	75 03                	jne    801ca4 <__udivdi3+0xc4>
  801ca1:	83 eb 01             	sub    $0x1,%ebx
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	89 fa                	mov    %edi,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	31 ff                	xor    %edi,%edi
  801cba:	31 db                	xor    %ebx,%ebx
  801cbc:	89 d8                	mov    %ebx,%eax
  801cbe:	89 fa                	mov    %edi,%edx
  801cc0:	83 c4 1c             	add    $0x1c,%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    
  801cc8:	90                   	nop
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 d8                	mov    %ebx,%eax
  801cd2:	f7 f7                	div    %edi
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 c3                	mov    %eax,%ebx
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	89 fa                	mov    %edi,%edx
  801cdc:	83 c4 1c             	add    $0x1c,%esp
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	39 ce                	cmp    %ecx,%esi
  801cea:	72 0c                	jb     801cf8 <__udivdi3+0x118>
  801cec:	31 db                	xor    %ebx,%ebx
  801cee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cf2:	0f 87 34 ff ff ff    	ja     801c2c <__udivdi3+0x4c>
  801cf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cfd:	e9 2a ff ff ff       	jmp    801c2c <__udivdi3+0x4c>
  801d02:	66 90                	xchg   %ax,%ax
  801d04:	66 90                	xchg   %ax,%ax
  801d06:	66 90                	xchg   %ax,%ax
  801d08:	66 90                	xchg   %ax,%ax
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 1c             	sub    $0x1c,%esp
  801d17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d27:	85 d2                	test   %edx,%edx
  801d29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d31:	89 f3                	mov    %esi,%ebx
  801d33:	89 3c 24             	mov    %edi,(%esp)
  801d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3a:	75 1c                	jne    801d58 <__umoddi3+0x48>
  801d3c:	39 f7                	cmp    %esi,%edi
  801d3e:	76 50                	jbe    801d90 <__umoddi3+0x80>
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	f7 f7                	div    %edi
  801d46:	89 d0                	mov    %edx,%eax
  801d48:	31 d2                	xor    %edx,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	39 f2                	cmp    %esi,%edx
  801d5a:	89 d0                	mov    %edx,%eax
  801d5c:	77 52                	ja     801db0 <__umoddi3+0xa0>
  801d5e:	0f bd ea             	bsr    %edx,%ebp
  801d61:	83 f5 1f             	xor    $0x1f,%ebp
  801d64:	75 5a                	jne    801dc0 <__umoddi3+0xb0>
  801d66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d6a:	0f 82 e0 00 00 00    	jb     801e50 <__umoddi3+0x140>
  801d70:	39 0c 24             	cmp    %ecx,(%esp)
  801d73:	0f 86 d7 00 00 00    	jbe    801e50 <__umoddi3+0x140>
  801d79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d81:	83 c4 1c             	add    $0x1c,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	85 ff                	test   %edi,%edi
  801d92:	89 fd                	mov    %edi,%ebp
  801d94:	75 0b                	jne    801da1 <__umoddi3+0x91>
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f7                	div    %edi
  801d9f:	89 c5                	mov    %eax,%ebp
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f5                	div    %ebp
  801da7:	89 c8                	mov    %ecx,%eax
  801da9:	f7 f5                	div    %ebp
  801dab:	89 d0                	mov    %edx,%eax
  801dad:	eb 99                	jmp    801d48 <__umoddi3+0x38>
  801daf:	90                   	nop
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	83 c4 1c             	add    $0x1c,%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5f                   	pop    %edi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    
  801dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	8b 34 24             	mov    (%esp),%esi
  801dc3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dc8:	89 e9                	mov    %ebp,%ecx
  801dca:	29 ef                	sub    %ebp,%edi
  801dcc:	d3 e0                	shl    %cl,%eax
  801dce:	89 f9                	mov    %edi,%ecx
  801dd0:	89 f2                	mov    %esi,%edx
  801dd2:	d3 ea                	shr    %cl,%edx
  801dd4:	89 e9                	mov    %ebp,%ecx
  801dd6:	09 c2                	or     %eax,%edx
  801dd8:	89 d8                	mov    %ebx,%eax
  801dda:	89 14 24             	mov    %edx,(%esp)
  801ddd:	89 f2                	mov    %esi,%edx
  801ddf:	d3 e2                	shl    %cl,%edx
  801de1:	89 f9                	mov    %edi,%ecx
  801de3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801de7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801deb:	d3 e8                	shr    %cl,%eax
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	89 c6                	mov    %eax,%esi
  801df1:	d3 e3                	shl    %cl,%ebx
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 d0                	mov    %edx,%eax
  801df7:	d3 e8                	shr    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	09 d8                	or     %ebx,%eax
  801dfd:	89 d3                	mov    %edx,%ebx
  801dff:	89 f2                	mov    %esi,%edx
  801e01:	f7 34 24             	divl   (%esp)
  801e04:	89 d6                	mov    %edx,%esi
  801e06:	d3 e3                	shl    %cl,%ebx
  801e08:	f7 64 24 04          	mull   0x4(%esp)
  801e0c:	39 d6                	cmp    %edx,%esi
  801e0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e12:	89 d1                	mov    %edx,%ecx
  801e14:	89 c3                	mov    %eax,%ebx
  801e16:	72 08                	jb     801e20 <__umoddi3+0x110>
  801e18:	75 11                	jne    801e2b <__umoddi3+0x11b>
  801e1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e1e:	73 0b                	jae    801e2b <__umoddi3+0x11b>
  801e20:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e24:	1b 14 24             	sbb    (%esp),%edx
  801e27:	89 d1                	mov    %edx,%ecx
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e2f:	29 da                	sub    %ebx,%edx
  801e31:	19 ce                	sbb    %ecx,%esi
  801e33:	89 f9                	mov    %edi,%ecx
  801e35:	89 f0                	mov    %esi,%eax
  801e37:	d3 e0                	shl    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	d3 ea                	shr    %cl,%edx
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	d3 ee                	shr    %cl,%esi
  801e41:	09 d0                	or     %edx,%eax
  801e43:	89 f2                	mov    %esi,%edx
  801e45:	83 c4 1c             	add    $0x1c,%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    
  801e4d:	8d 76 00             	lea    0x0(%esi),%esi
  801e50:	29 f9                	sub    %edi,%ecx
  801e52:	19 d6                	sbb    %edx,%esi
  801e54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e5c:	e9 18 ff ff ff       	jmp    801d79 <__umoddi3+0x69>
