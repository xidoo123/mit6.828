
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 c0 22 80 00       	push   $0x8022c0
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 69 0a 00 00       	call   800abd <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 20 0a 00 00       	call   800a7c <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 9a 0c 00 00       	call   800d0b <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 2d 0a 00 00       	call   800abd <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 70 0e 00 00       	call   800f41 <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 a1 09 00 00       	call   800a7c <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 2f 09 00 00       	call   800a3f <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 54 01 00 00       	call   8002aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 d4 08 00 00       	call   800a3f <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 55 1e 00 00       	call   802030 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 42 1f 00 00       	call   802160 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 e6 22 80 00 	movsbl 0x8022e6(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800239:	83 fa 01             	cmp    $0x1,%edx
  80023c:	7e 0e                	jle    80024c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 08             	lea    0x8(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	8b 52 04             	mov    0x4(%edx),%edx
  80024a:	eb 22                	jmp    80026e <getuint+0x38>
	else if (lflag)
  80024c:	85 d2                	test   %edx,%edx
  80024e:	74 10                	je     800260 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 04             	lea    0x4(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	eb 0e                	jmp    80026e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800276:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	3b 50 04             	cmp    0x4(%eax),%edx
  80027f:	73 0a                	jae    80028b <sprintputch+0x1b>
		*b->buf++ = ch;
  800281:	8d 4a 01             	lea    0x1(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	88 02                	mov    %al,(%edx)
}
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800293:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 10             	pushl  0x10(%ebp)
  80029a:	ff 75 0c             	pushl  0xc(%ebp)
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 05 00 00 00       	call   8002aa <vprintfmt>
	va_end(ap);
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 2c             	sub    $0x2c,%esp
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bc:	eb 12                	jmp    8002d0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	0f 84 89 03 00 00    	je     80064f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	53                   	push   %ebx
  8002ca:	50                   	push   %eax
  8002cb:	ff d6                	call   *%esi
  8002cd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d0:	83 c7 01             	add    $0x1,%edi
  8002d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d7:	83 f8 25             	cmp    $0x25,%eax
  8002da:	75 e2                	jne    8002be <vprintfmt+0x14>
  8002dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fa:	eb 07                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8d 47 01             	lea    0x1(%edi),%eax
  800306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800309:	0f b6 07             	movzbl (%edi),%eax
  80030c:	0f b6 c8             	movzbl %al,%ecx
  80030f:	83 e8 23             	sub    $0x23,%eax
  800312:	3c 55                	cmp    $0x55,%al
  800314:	0f 87 1a 03 00 00    	ja     800634 <vprintfmt+0x38a>
  80031a:	0f b6 c0             	movzbl %al,%eax
  80031d:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800327:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032b:	eb d6                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800330:	b8 00 00 00 00       	mov    $0x0,%eax
  800335:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800338:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80033f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800342:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800345:	83 fa 09             	cmp    $0x9,%edx
  800348:	77 39                	ja     800383 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80034d:	eb e9                	jmp    800338 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034f:	8b 45 14             	mov    0x14(%ebp),%eax
  800352:	8d 48 04             	lea    0x4(%eax),%ecx
  800355:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800358:	8b 00                	mov    (%eax),%eax
  80035a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800360:	eb 27                	jmp    800389 <vprintfmt+0xdf>
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	85 c0                	test   %eax,%eax
  800367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036c:	0f 49 c8             	cmovns %eax,%ecx
  80036f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	eb 8c                	jmp    800303 <vprintfmt+0x59>
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800381:	eb 80                	jmp    800303 <vprintfmt+0x59>
  800383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800386:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800389:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038d:	0f 89 70 ff ff ff    	jns    800303 <vprintfmt+0x59>
				width = precision, precision = -1;
  800393:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800399:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a0:	e9 5e ff ff ff       	jmp    800303 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ab:	e9 53 ff ff ff       	jmp    800303 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 50 04             	lea    0x4(%eax),%edx
  8003b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	53                   	push   %ebx
  8003bd:	ff 30                	pushl  (%eax)
  8003bf:	ff d6                	call   *%esi
			break;
  8003c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c7:	e9 04 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	99                   	cltd   
  8003d8:	31 d0                	xor    %edx,%eax
  8003da:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dc:	83 f8 0f             	cmp    $0xf,%eax
  8003df:	7f 0b                	jg     8003ec <vprintfmt+0x142>
  8003e1:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	75 18                	jne    800404 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ec:	50                   	push   %eax
  8003ed:	68 fe 22 80 00       	push   $0x8022fe
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	e8 94 fe ff ff       	call   80028d <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ff:	e9 cc fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800404:	52                   	push   %edx
  800405:	68 b5 26 80 00       	push   $0x8026b5
  80040a:	53                   	push   %ebx
  80040b:	56                   	push   %esi
  80040c:	e8 7c fe ff ff       	call   80028d <printfmt>
  800411:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	e9 b4 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800427:	85 ff                	test   %edi,%edi
  800429:	b8 f7 22 80 00       	mov    $0x8022f7,%eax
  80042e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	0f 8e 94 00 00 00    	jle    8004cf <vprintfmt+0x225>
  80043b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80043f:	0f 84 98 00 00 00    	je     8004dd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	ff 75 d0             	pushl  -0x30(%ebp)
  80044b:	57                   	push   %edi
  80044c:	e8 86 02 00 00       	call   8006d7 <strnlen>
  800451:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800454:	29 c1                	sub    %eax,%ecx
  800456:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800459:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800463:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800466:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	eb 0f                	jmp    800479 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	53                   	push   %ebx
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	83 ef 01             	sub    $0x1,%edi
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	85 ff                	test   %edi,%edi
  80047b:	7f ed                	jg     80046a <vprintfmt+0x1c0>
  80047d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800480:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800483:	85 c9                	test   %ecx,%ecx
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	0f 49 c1             	cmovns %ecx,%eax
  80048d:	29 c1                	sub    %eax,%ecx
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800498:	89 cb                	mov    %ecx,%ebx
  80049a:	eb 4d                	jmp    8004e9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a0:	74 1b                	je     8004bd <vprintfmt+0x213>
  8004a2:	0f be c0             	movsbl %al,%eax
  8004a5:	83 e8 20             	sub    $0x20,%eax
  8004a8:	83 f8 5e             	cmp    $0x5e,%eax
  8004ab:	76 10                	jbe    8004bd <vprintfmt+0x213>
					putch('?', putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff 55 08             	call   *0x8(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb 0d                	jmp    8004ca <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	52                   	push   %edx
  8004c4:	ff 55 08             	call   *0x8(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	83 eb 01             	sub    $0x1,%ebx
  8004cd:	eb 1a                	jmp    8004e9 <vprintfmt+0x23f>
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004db:	eb 0c                	jmp    8004e9 <vprintfmt+0x23f>
  8004dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	0f be d0             	movsbl %al,%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 23                	je     80051a <vprintfmt+0x270>
  8004f7:	85 f6                	test   %esi,%esi
  8004f9:	78 a1                	js     80049c <vprintfmt+0x1f2>
  8004fb:	83 ee 01             	sub    $0x1,%esi
  8004fe:	79 9c                	jns    80049c <vprintfmt+0x1f2>
  800500:	89 df                	mov    %ebx,%edi
  800502:	8b 75 08             	mov    0x8(%ebp),%esi
  800505:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800508:	eb 18                	jmp    800522 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	53                   	push   %ebx
  80050e:	6a 20                	push   $0x20
  800510:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800512:	83 ef 01             	sub    $0x1,%edi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	eb 08                	jmp    800522 <vprintfmt+0x278>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	85 ff                	test   %edi,%edi
  800524:	7f e4                	jg     80050a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800529:	e9 a2 fd ff ff       	jmp    8002d0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052e:	83 fa 01             	cmp    $0x1,%edx
  800531:	7e 16                	jle    800549 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 08             	lea    0x8(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 50 04             	mov    0x4(%eax),%edx
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800547:	eb 32                	jmp    80057b <vprintfmt+0x2d1>
	else if (lflag)
  800549:	85 d2                	test   %edx,%edx
  80054b:	74 18                	je     800565 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055b:	89 c1                	mov    %eax,%ecx
  80055d:	c1 f9 1f             	sar    $0x1f,%ecx
  800560:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800563:	eb 16                	jmp    80057b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	89 c1                	mov    %eax,%ecx
  800575:	c1 f9 1f             	sar    $0x1f,%ecx
  800578:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800586:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058a:	79 74                	jns    800600 <vprintfmt+0x356>
				putch('-', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 2d                	push   $0x2d
  800592:	ff d6                	call   *%esi
				num = -(long long) num;
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059a:	f7 d8                	neg    %eax
  80059c:	83 d2 00             	adc    $0x0,%edx
  80059f:	f7 da                	neg    %edx
  8005a1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005a9:	eb 55                	jmp    800600 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 83 fc ff ff       	call   800236 <getuint>
			base = 10;
  8005b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005b8:	eb 46                	jmp    800600 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 74 fc ff ff       	call   800236 <getuint>
			base = 8;
  8005c2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005c7:	eb 37                	jmp    800600 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 30                	push   $0x30
  8005cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d1:	83 c4 08             	add    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 78                	push   $0x78
  8005d7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f1:	eb 0d                	jmp    800600 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 3b fc ff ff       	call   800236 <getuint>
			base = 16;
  8005fb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800600:	83 ec 0c             	sub    $0xc,%esp
  800603:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800607:	57                   	push   %edi
  800608:	ff 75 e0             	pushl  -0x20(%ebp)
  80060b:	51                   	push   %ecx
  80060c:	52                   	push   %edx
  80060d:	50                   	push   %eax
  80060e:	89 da                	mov    %ebx,%edx
  800610:	89 f0                	mov    %esi,%eax
  800612:	e8 70 fb ff ff       	call   800187 <printnum>
			break;
  800617:	83 c4 20             	add    $0x20,%esp
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061d:	e9 ae fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	51                   	push   %ecx
  800627:	ff d6                	call   *%esi
			break;
  800629:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062f:	e9 9c fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 25                	push   $0x25
  80063a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	eb 03                	jmp    800644 <vprintfmt+0x39a>
  800641:	83 ef 01             	sub    $0x1,%edi
  800644:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800648:	75 f7                	jne    800641 <vprintfmt+0x397>
  80064a:	e9 81 fc ff ff       	jmp    8002d0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80064f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800652:	5b                   	pop    %ebx
  800653:	5e                   	pop    %esi
  800654:	5f                   	pop    %edi
  800655:	5d                   	pop    %ebp
  800656:	c3                   	ret    

00800657 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	83 ec 18             	sub    $0x18,%esp
  80065d:	8b 45 08             	mov    0x8(%ebp),%eax
  800660:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800663:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800666:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800674:	85 c0                	test   %eax,%eax
  800676:	74 26                	je     80069e <vsnprintf+0x47>
  800678:	85 d2                	test   %edx,%edx
  80067a:	7e 22                	jle    80069e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067c:	ff 75 14             	pushl  0x14(%ebp)
  80067f:	ff 75 10             	pushl  0x10(%ebp)
  800682:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800685:	50                   	push   %eax
  800686:	68 70 02 80 00       	push   $0x800270
  80068b:	e8 1a fc ff ff       	call   8002aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800690:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800693:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	eb 05                	jmp    8006a3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a3:	c9                   	leave  
  8006a4:	c3                   	ret    

008006a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ae:	50                   	push   %eax
  8006af:	ff 75 10             	pushl  0x10(%ebp)
  8006b2:	ff 75 0c             	pushl  0xc(%ebp)
  8006b5:	ff 75 08             	pushl  0x8(%ebp)
  8006b8:	e8 9a ff ff ff       	call   800657 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ca:	eb 03                	jmp    8006cf <strlen+0x10>
		n++;
  8006cc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d3:	75 f7                	jne    8006cc <strlen+0xd>
		n++;
	return n;
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e5:	eb 03                	jmp    8006ea <strnlen+0x13>
		n++;
  8006e7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ea:	39 c2                	cmp    %eax,%edx
  8006ec:	74 08                	je     8006f6 <strnlen+0x1f>
  8006ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f2:	75 f3                	jne    8006e7 <strnlen+0x10>
  8006f4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800702:	89 c2                	mov    %eax,%edx
  800704:	83 c2 01             	add    $0x1,%edx
  800707:	83 c1 01             	add    $0x1,%ecx
  80070a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800711:	84 db                	test   %bl,%bl
  800713:	75 ef                	jne    800704 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800715:	5b                   	pop    %ebx
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071f:	53                   	push   %ebx
  800720:	e8 9a ff ff ff       	call   8006bf <strlen>
  800725:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	01 d8                	add    %ebx,%eax
  80072d:	50                   	push   %eax
  80072e:	e8 c5 ff ff ff       	call   8006f8 <strcpy>
	return dst;
}
  800733:	89 d8                	mov    %ebx,%eax
  800735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	56                   	push   %esi
  80073e:	53                   	push   %ebx
  80073f:	8b 75 08             	mov    0x8(%ebp),%esi
  800742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800745:	89 f3                	mov    %esi,%ebx
  800747:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074a:	89 f2                	mov    %esi,%edx
  80074c:	eb 0f                	jmp    80075d <strncpy+0x23>
		*dst++ = *src;
  80074e:	83 c2 01             	add    $0x1,%edx
  800751:	0f b6 01             	movzbl (%ecx),%eax
  800754:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800757:	80 39 01             	cmpb   $0x1,(%ecx)
  80075a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075d:	39 da                	cmp    %ebx,%edx
  80075f:	75 ed                	jne    80074e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800761:	89 f0                	mov    %esi,%eax
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800772:	8b 55 10             	mov    0x10(%ebp),%edx
  800775:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800777:	85 d2                	test   %edx,%edx
  800779:	74 21                	je     80079c <strlcpy+0x35>
  80077b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077f:	89 f2                	mov    %esi,%edx
  800781:	eb 09                	jmp    80078c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	74 09                	je     800799 <strlcpy+0x32>
  800790:	0f b6 19             	movzbl (%ecx),%ebx
  800793:	84 db                	test   %bl,%bl
  800795:	75 ec                	jne    800783 <strlcpy+0x1c>
  800797:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800799:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079c:	29 f0                	sub    %esi,%eax
}
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ab:	eb 06                	jmp    8007b3 <strcmp+0x11>
		p++, q++;
  8007ad:	83 c1 01             	add    $0x1,%ecx
  8007b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b3:	0f b6 01             	movzbl (%ecx),%eax
  8007b6:	84 c0                	test   %al,%al
  8007b8:	74 04                	je     8007be <strcmp+0x1c>
  8007ba:	3a 02                	cmp    (%edx),%al
  8007bc:	74 ef                	je     8007ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007be:	0f b6 c0             	movzbl %al,%eax
  8007c1:	0f b6 12             	movzbl (%edx),%edx
  8007c4:	29 d0                	sub    %edx,%eax
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	89 c3                	mov    %eax,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d7:	eb 06                	jmp    8007df <strncmp+0x17>
		n--, p++, q++;
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007df:	39 d8                	cmp    %ebx,%eax
  8007e1:	74 15                	je     8007f8 <strncmp+0x30>
  8007e3:	0f b6 08             	movzbl (%eax),%ecx
  8007e6:	84 c9                	test   %cl,%cl
  8007e8:	74 04                	je     8007ee <strncmp+0x26>
  8007ea:	3a 0a                	cmp    (%edx),%cl
  8007ec:	74 eb                	je     8007d9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ee:	0f b6 00             	movzbl (%eax),%eax
  8007f1:	0f b6 12             	movzbl (%edx),%edx
  8007f4:	29 d0                	sub    %edx,%eax
  8007f6:	eb 05                	jmp    8007fd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080a:	eb 07                	jmp    800813 <strchr+0x13>
		if (*s == c)
  80080c:	38 ca                	cmp    %cl,%dl
  80080e:	74 0f                	je     80081f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	0f b6 10             	movzbl (%eax),%edx
  800816:	84 d2                	test   %dl,%dl
  800818:	75 f2                	jne    80080c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 03                	jmp    800830 <strfind+0xf>
  80082d:	83 c0 01             	add    $0x1,%eax
  800830:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800833:	38 ca                	cmp    %cl,%dl
  800835:	74 04                	je     80083b <strfind+0x1a>
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f2                	jne    80082d <strfind+0xc>
			break;
	return (char *) s;
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	57                   	push   %edi
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 7d 08             	mov    0x8(%ebp),%edi
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 36                	je     800883 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800853:	75 28                	jne    80087d <memset+0x40>
  800855:	f6 c1 03             	test   $0x3,%cl
  800858:	75 23                	jne    80087d <memset+0x40>
		c &= 0xFF;
  80085a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085e:	89 d3                	mov    %edx,%ebx
  800860:	c1 e3 08             	shl    $0x8,%ebx
  800863:	89 d6                	mov    %edx,%esi
  800865:	c1 e6 18             	shl    $0x18,%esi
  800868:	89 d0                	mov    %edx,%eax
  80086a:	c1 e0 10             	shl    $0x10,%eax
  80086d:	09 f0                	or     %esi,%eax
  80086f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800871:	89 d8                	mov    %ebx,%eax
  800873:	09 d0                	or     %edx,%eax
  800875:	c1 e9 02             	shr    $0x2,%ecx
  800878:	fc                   	cld    
  800879:	f3 ab                	rep stos %eax,%es:(%edi)
  80087b:	eb 06                	jmp    800883 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	fc                   	cld    
  800881:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800883:	89 f8                	mov    %edi,%eax
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 75 0c             	mov    0xc(%ebp),%esi
  800895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800898:	39 c6                	cmp    %eax,%esi
  80089a:	73 35                	jae    8008d1 <memmove+0x47>
  80089c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089f:	39 d0                	cmp    %edx,%eax
  8008a1:	73 2e                	jae    8008d1 <memmove+0x47>
		s += n;
		d += n;
  8008a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a6:	89 d6                	mov    %edx,%esi
  8008a8:	09 fe                	or     %edi,%esi
  8008aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b0:	75 13                	jne    8008c5 <memmove+0x3b>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 0e                	jne    8008c5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b7:	83 ef 04             	sub    $0x4,%edi
  8008ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
  8008c0:	fd                   	std    
  8008c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c3:	eb 09                	jmp    8008ce <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c5:	83 ef 01             	sub    $0x1,%edi
  8008c8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008cb:	fd                   	std    
  8008cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ce:	fc                   	cld    
  8008cf:	eb 1d                	jmp    8008ee <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d1:	89 f2                	mov    %esi,%edx
  8008d3:	09 c2                	or     %eax,%edx
  8008d5:	f6 c2 03             	test   $0x3,%dl
  8008d8:	75 0f                	jne    8008e9 <memmove+0x5f>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 0a                	jne    8008e9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008df:	c1 e9 02             	shr    $0x2,%ecx
  8008e2:	89 c7                	mov    %eax,%edi
  8008e4:	fc                   	cld    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 05                	jmp    8008ee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e9:	89 c7                	mov    %eax,%edi
  8008eb:	fc                   	cld    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f5:	ff 75 10             	pushl  0x10(%ebp)
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 87 ff ff ff       	call   80088a <memmove>
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c6                	mov    %eax,%esi
  800912:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800915:	eb 1a                	jmp    800931 <memcmp+0x2c>
		if (*s1 != *s2)
  800917:	0f b6 08             	movzbl (%eax),%ecx
  80091a:	0f b6 1a             	movzbl (%edx),%ebx
  80091d:	38 d9                	cmp    %bl,%cl
  80091f:	74 0a                	je     80092b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800921:	0f b6 c1             	movzbl %cl,%eax
  800924:	0f b6 db             	movzbl %bl,%ebx
  800927:	29 d8                	sub    %ebx,%eax
  800929:	eb 0f                	jmp    80093a <memcmp+0x35>
		s1++, s2++;
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800931:	39 f0                	cmp    %esi,%eax
  800933:	75 e2                	jne    800917 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800945:	89 c1                	mov    %eax,%ecx
  800947:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094e:	eb 0a                	jmp    80095a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	39 da                	cmp    %ebx,%edx
  800955:	74 07                	je     80095e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	39 c8                	cmp    %ecx,%eax
  80095c:	72 f2                	jb     800950 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096d:	eb 03                	jmp    800972 <strtol+0x11>
		s++;
  80096f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	3c 20                	cmp    $0x20,%al
  800977:	74 f6                	je     80096f <strtol+0xe>
  800979:	3c 09                	cmp    $0x9,%al
  80097b:	74 f2                	je     80096f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097d:	3c 2b                	cmp    $0x2b,%al
  80097f:	75 0a                	jne    80098b <strtol+0x2a>
		s++;
  800981:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800984:	bf 00 00 00 00       	mov    $0x0,%edi
  800989:	eb 11                	jmp    80099c <strtol+0x3b>
  80098b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800990:	3c 2d                	cmp    $0x2d,%al
  800992:	75 08                	jne    80099c <strtol+0x3b>
		s++, neg = 1;
  800994:	83 c1 01             	add    $0x1,%ecx
  800997:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a2:	75 15                	jne    8009b9 <strtol+0x58>
  8009a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a7:	75 10                	jne    8009b9 <strtol+0x58>
  8009a9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ad:	75 7c                	jne    800a2b <strtol+0xca>
		s += 2, base = 16;
  8009af:	83 c1 02             	add    $0x2,%ecx
  8009b2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b7:	eb 16                	jmp    8009cf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b9:	85 db                	test   %ebx,%ebx
  8009bb:	75 12                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c5:	75 08                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d7:	0f b6 11             	movzbl (%ecx),%edx
  8009da:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	80 fb 09             	cmp    $0x9,%bl
  8009e2:	77 08                	ja     8009ec <strtol+0x8b>
			dig = *s - '0';
  8009e4:	0f be d2             	movsbl %dl,%edx
  8009e7:	83 ea 30             	sub    $0x30,%edx
  8009ea:	eb 22                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ec:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f6:	0f be d2             	movsbl %dl,%edx
  8009f9:	83 ea 57             	sub    $0x57,%edx
  8009fc:	eb 10                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009fe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 19             	cmp    $0x19,%bl
  800a06:	77 16                	ja     800a1e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a11:	7d 0b                	jge    800a1e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1c:	eb b9                	jmp    8009d7 <strtol+0x76>

	if (endptr)
  800a1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a22:	74 0d                	je     800a31 <strtol+0xd0>
		*endptr = (char *) s;
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	89 0e                	mov    %ecx,(%esi)
  800a29:	eb 06                	jmp    800a31 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2b:	85 db                	test   %ebx,%ebx
  800a2d:	74 98                	je     8009c7 <strtol+0x66>
  800a2f:	eb 9e                	jmp    8009cf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	f7 da                	neg    %edx
  800a35:	85 ff                	test   %edi,%edi
  800a37:	0f 45 c2             	cmovne %edx,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	89 c3                	mov    %eax,%ebx
  800a52:	89 c7                	mov    %eax,%edi
  800a54:	89 c6                	mov    %eax,%esi
  800a56:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6d:	89 d1                	mov    %edx,%ecx
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	89 d7                	mov    %edx,%edi
  800a73:	89 d6                	mov    %edx,%esi
  800a75:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a92:	89 cb                	mov    %ecx,%ebx
  800a94:	89 cf                	mov    %ecx,%edi
  800a96:	89 ce                	mov    %ecx,%esi
  800a98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	7e 17                	jle    800ab5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9e:	83 ec 0c             	sub    $0xc,%esp
  800aa1:	50                   	push   %eax
  800aa2:	6a 03                	push   $0x3
  800aa4:	68 df 25 80 00       	push   $0x8025df
  800aa9:	6a 23                	push   $0x23
  800aab:	68 fc 25 80 00       	push   $0x8025fc
  800ab0:	e8 05 14 00 00       	call   801eba <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 02 00 00 00       	mov    $0x2,%eax
  800acd:	89 d1                	mov    %edx,%ecx
  800acf:	89 d3                	mov    %edx,%ebx
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_yield>:

void
sys_yield(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	be 00 00 00 00       	mov    $0x0,%esi
  800b09:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b17:	89 f7                	mov    %esi,%edi
  800b19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 04                	push   $0x4
  800b25:	68 df 25 80 00       	push   $0x8025df
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 fc 25 80 00       	push   $0x8025fc
  800b31:	e8 84 13 00 00       	call   801eba <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b58:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 05                	push   $0x5
  800b67:	68 df 25 80 00       	push   $0x8025df
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 fc 25 80 00       	push   $0x8025fc
  800b73:	e8 42 13 00 00       	call   801eba <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 df                	mov    %ebx,%edi
  800b9b:	89 de                	mov    %ebx,%esi
  800b9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 06                	push   $0x6
  800ba9:	68 df 25 80 00       	push   $0x8025df
  800bae:	6a 23                	push   $0x23
  800bb0:	68 fc 25 80 00       	push   $0x8025fc
  800bb5:	e8 00 13 00 00       	call   801eba <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 df                	mov    %ebx,%edi
  800bdd:	89 de                	mov    %ebx,%esi
  800bdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 08                	push   $0x8
  800beb:	68 df 25 80 00       	push   $0x8025df
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 fc 25 80 00       	push   $0x8025fc
  800bf7:	e8 be 12 00 00       	call   801eba <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 09 00 00 00       	mov    $0x9,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 09                	push   $0x9
  800c2d:	68 df 25 80 00       	push   $0x8025df
  800c32:	6a 23                	push   $0x23
  800c34:	68 fc 25 80 00       	push   $0x8025fc
  800c39:	e8 7c 12 00 00       	call   801eba <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 0a                	push   $0xa
  800c6f:	68 df 25 80 00       	push   $0x8025df
  800c74:	6a 23                	push   $0x23
  800c76:	68 fc 25 80 00       	push   $0x8025fc
  800c7b:	e8 3a 12 00 00       	call   801eba <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 cb                	mov    %ecx,%ebx
  800cc3:	89 cf                	mov    %ecx,%edi
  800cc5:	89 ce                	mov    %ecx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 0d                	push   $0xd
  800cd3:	68 df 25 80 00       	push   $0x8025df
  800cd8:	6a 23                	push   $0x23
  800cda:	68 fc 25 80 00       	push   $0x8025fc
  800cdf:	e8 d6 11 00 00       	call   801eba <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cfc:	89 d1                	mov    %edx,%ecx
  800cfe:	89 d3                	mov    %edx,%ebx
  800d00:	89 d7                	mov    %edx,%edi
  800d02:	89 d6                	mov    %edx,%esi
  800d04:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d11:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800d18:	75 2e                	jne    800d48 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800d1a:	e8 9e fd ff ff       	call   800abd <sys_getenvid>
  800d1f:	83 ec 04             	sub    $0x4,%esp
  800d22:	68 07 0e 00 00       	push   $0xe07
  800d27:	68 00 f0 bf ee       	push   $0xeebff000
  800d2c:	50                   	push   %eax
  800d2d:	e8 c9 fd ff ff       	call   800afb <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800d32:	e8 86 fd ff ff       	call   800abd <sys_getenvid>
  800d37:	83 c4 08             	add    $0x8,%esp
  800d3a:	68 52 0d 80 00       	push   $0x800d52
  800d3f:	50                   	push   %eax
  800d40:	e8 01 ff ff ff       	call   800c46 <sys_env_set_pgfault_upcall>
  800d45:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800d50:	c9                   	leave  
  800d51:	c3                   	ret    

00800d52 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d52:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d53:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800d58:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d5a:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  800d5d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800d61:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800d65:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800d68:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800d6b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  800d6c:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800d6f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800d70:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800d71:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800d75:	c3                   	ret    

00800d76 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d81:	c1 e8 0c             	shr    $0xc,%eax
}
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d96:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da8:	89 c2                	mov    %eax,%edx
  800daa:	c1 ea 16             	shr    $0x16,%edx
  800dad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db4:	f6 c2 01             	test   $0x1,%dl
  800db7:	74 11                	je     800dca <fd_alloc+0x2d>
  800db9:	89 c2                	mov    %eax,%edx
  800dbb:	c1 ea 0c             	shr    $0xc,%edx
  800dbe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc5:	f6 c2 01             	test   $0x1,%dl
  800dc8:	75 09                	jne    800dd3 <fd_alloc+0x36>
			*fd_store = fd;
  800dca:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd1:	eb 17                	jmp    800dea <fd_alloc+0x4d>
  800dd3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ddd:	75 c9                	jne    800da8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ddf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800de5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df2:	83 f8 1f             	cmp    $0x1f,%eax
  800df5:	77 36                	ja     800e2d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df7:	c1 e0 0c             	shl    $0xc,%eax
  800dfa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dff:	89 c2                	mov    %eax,%edx
  800e01:	c1 ea 16             	shr    $0x16,%edx
  800e04:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e0b:	f6 c2 01             	test   $0x1,%dl
  800e0e:	74 24                	je     800e34 <fd_lookup+0x48>
  800e10:	89 c2                	mov    %eax,%edx
  800e12:	c1 ea 0c             	shr    $0xc,%edx
  800e15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1c:	f6 c2 01             	test   $0x1,%dl
  800e1f:	74 1a                	je     800e3b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e24:	89 02                	mov    %eax,(%edx)
	return 0;
  800e26:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2b:	eb 13                	jmp    800e40 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e32:	eb 0c                	jmp    800e40 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e34:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e39:	eb 05                	jmp    800e40 <fd_lookup+0x54>
  800e3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	83 ec 08             	sub    $0x8,%esp
  800e48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4b:	ba 88 26 80 00       	mov    $0x802688,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e50:	eb 13                	jmp    800e65 <dev_lookup+0x23>
  800e52:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e55:	39 08                	cmp    %ecx,(%eax)
  800e57:	75 0c                	jne    800e65 <dev_lookup+0x23>
			*dev = devtab[i];
  800e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e63:	eb 2e                	jmp    800e93 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e65:	8b 02                	mov    (%edx),%eax
  800e67:	85 c0                	test   %eax,%eax
  800e69:	75 e7                	jne    800e52 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6b:	a1 08 40 80 00       	mov    0x804008,%eax
  800e70:	8b 40 48             	mov    0x48(%eax),%eax
  800e73:	83 ec 04             	sub    $0x4,%esp
  800e76:	51                   	push   %ecx
  800e77:	50                   	push   %eax
  800e78:	68 0c 26 80 00       	push   $0x80260c
  800e7d:	e8 f1 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800e82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e85:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e8b:	83 c4 10             	add    $0x10,%esp
  800e8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
  800e9a:	83 ec 10             	sub    $0x10,%esp
  800e9d:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea6:	50                   	push   %eax
  800ea7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ead:	c1 e8 0c             	shr    $0xc,%eax
  800eb0:	50                   	push   %eax
  800eb1:	e8 36 ff ff ff       	call   800dec <fd_lookup>
  800eb6:	83 c4 08             	add    $0x8,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	78 05                	js     800ec2 <fd_close+0x2d>
	    || fd != fd2)
  800ebd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ec0:	74 0c                	je     800ece <fd_close+0x39>
		return (must_exist ? r : 0);
  800ec2:	84 db                	test   %bl,%bl
  800ec4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec9:	0f 44 c2             	cmove  %edx,%eax
  800ecc:	eb 41                	jmp    800f0f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ed4:	50                   	push   %eax
  800ed5:	ff 36                	pushl  (%esi)
  800ed7:	e8 66 ff ff ff       	call   800e42 <dev_lookup>
  800edc:	89 c3                	mov    %eax,%ebx
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	78 1a                	js     800eff <fd_close+0x6a>
		if (dev->dev_close)
  800ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eeb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	74 0b                	je     800eff <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ef4:	83 ec 0c             	sub    $0xc,%esp
  800ef7:	56                   	push   %esi
  800ef8:	ff d0                	call   *%eax
  800efa:	89 c3                	mov    %eax,%ebx
  800efc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	56                   	push   %esi
  800f03:	6a 00                	push   $0x0
  800f05:	e8 76 fc ff ff       	call   800b80 <sys_page_unmap>
	return r;
  800f0a:	83 c4 10             	add    $0x10,%esp
  800f0d:	89 d8                	mov    %ebx,%eax
}
  800f0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1f:	50                   	push   %eax
  800f20:	ff 75 08             	pushl  0x8(%ebp)
  800f23:	e8 c4 fe ff ff       	call   800dec <fd_lookup>
  800f28:	83 c4 08             	add    $0x8,%esp
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	78 10                	js     800f3f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f2f:	83 ec 08             	sub    $0x8,%esp
  800f32:	6a 01                	push   $0x1
  800f34:	ff 75 f4             	pushl  -0xc(%ebp)
  800f37:	e8 59 ff ff ff       	call   800e95 <fd_close>
  800f3c:	83 c4 10             	add    $0x10,%esp
}
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <close_all>:

void
close_all(void)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	53                   	push   %ebx
  800f45:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f48:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	53                   	push   %ebx
  800f51:	e8 c0 ff ff ff       	call   800f16 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f56:	83 c3 01             	add    $0x1,%ebx
  800f59:	83 c4 10             	add    $0x10,%esp
  800f5c:	83 fb 20             	cmp    $0x20,%ebx
  800f5f:	75 ec                	jne    800f4d <close_all+0xc>
		close(i);
}
  800f61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f64:	c9                   	leave  
  800f65:	c3                   	ret    

00800f66 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
  800f6c:	83 ec 2c             	sub    $0x2c,%esp
  800f6f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f72:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f75:	50                   	push   %eax
  800f76:	ff 75 08             	pushl  0x8(%ebp)
  800f79:	e8 6e fe ff ff       	call   800dec <fd_lookup>
  800f7e:	83 c4 08             	add    $0x8,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	0f 88 c1 00 00 00    	js     80104a <dup+0xe4>
		return r;
	close(newfdnum);
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	56                   	push   %esi
  800f8d:	e8 84 ff ff ff       	call   800f16 <close>

	newfd = INDEX2FD(newfdnum);
  800f92:	89 f3                	mov    %esi,%ebx
  800f94:	c1 e3 0c             	shl    $0xc,%ebx
  800f97:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f9d:	83 c4 04             	add    $0x4,%esp
  800fa0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa3:	e8 de fd ff ff       	call   800d86 <fd2data>
  800fa8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800faa:	89 1c 24             	mov    %ebx,(%esp)
  800fad:	e8 d4 fd ff ff       	call   800d86 <fd2data>
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fb8:	89 f8                	mov    %edi,%eax
  800fba:	c1 e8 16             	shr    $0x16,%eax
  800fbd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc4:	a8 01                	test   $0x1,%al
  800fc6:	74 37                	je     800fff <dup+0x99>
  800fc8:	89 f8                	mov    %edi,%eax
  800fca:	c1 e8 0c             	shr    $0xc,%eax
  800fcd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd4:	f6 c2 01             	test   $0x1,%dl
  800fd7:	74 26                	je     800fff <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fd9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe8:	50                   	push   %eax
  800fe9:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fec:	6a 00                	push   $0x0
  800fee:	57                   	push   %edi
  800fef:	6a 00                	push   $0x0
  800ff1:	e8 48 fb ff ff       	call   800b3e <sys_page_map>
  800ff6:	89 c7                	mov    %eax,%edi
  800ff8:	83 c4 20             	add    $0x20,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	78 2e                	js     80102d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801002:	89 d0                	mov    %edx,%eax
  801004:	c1 e8 0c             	shr    $0xc,%eax
  801007:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	25 07 0e 00 00       	and    $0xe07,%eax
  801016:	50                   	push   %eax
  801017:	53                   	push   %ebx
  801018:	6a 00                	push   $0x0
  80101a:	52                   	push   %edx
  80101b:	6a 00                	push   $0x0
  80101d:	e8 1c fb ff ff       	call   800b3e <sys_page_map>
  801022:	89 c7                	mov    %eax,%edi
  801024:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801027:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801029:	85 ff                	test   %edi,%edi
  80102b:	79 1d                	jns    80104a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80102d:	83 ec 08             	sub    $0x8,%esp
  801030:	53                   	push   %ebx
  801031:	6a 00                	push   $0x0
  801033:	e8 48 fb ff ff       	call   800b80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801038:	83 c4 08             	add    $0x8,%esp
  80103b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80103e:	6a 00                	push   $0x0
  801040:	e8 3b fb ff ff       	call   800b80 <sys_page_unmap>
	return r;
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	89 f8                	mov    %edi,%eax
}
  80104a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	53                   	push   %ebx
  801056:	83 ec 14             	sub    $0x14,%esp
  801059:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80105c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80105f:	50                   	push   %eax
  801060:	53                   	push   %ebx
  801061:	e8 86 fd ff ff       	call   800dec <fd_lookup>
  801066:	83 c4 08             	add    $0x8,%esp
  801069:	89 c2                	mov    %eax,%edx
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 6d                	js     8010dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801079:	ff 30                	pushl  (%eax)
  80107b:	e8 c2 fd ff ff       	call   800e42 <dev_lookup>
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	78 4c                	js     8010d3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801087:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108a:	8b 42 08             	mov    0x8(%edx),%eax
  80108d:	83 e0 03             	and    $0x3,%eax
  801090:	83 f8 01             	cmp    $0x1,%eax
  801093:	75 21                	jne    8010b6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801095:	a1 08 40 80 00       	mov    0x804008,%eax
  80109a:	8b 40 48             	mov    0x48(%eax),%eax
  80109d:	83 ec 04             	sub    $0x4,%esp
  8010a0:	53                   	push   %ebx
  8010a1:	50                   	push   %eax
  8010a2:	68 4d 26 80 00       	push   $0x80264d
  8010a7:	e8 c7 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010b4:	eb 26                	jmp    8010dc <read+0x8a>
	}
	if (!dev->dev_read)
  8010b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b9:	8b 40 08             	mov    0x8(%eax),%eax
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	74 17                	je     8010d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010c0:	83 ec 04             	sub    $0x4,%esp
  8010c3:	ff 75 10             	pushl  0x10(%ebp)
  8010c6:	ff 75 0c             	pushl  0xc(%ebp)
  8010c9:	52                   	push   %edx
  8010ca:	ff d0                	call   *%eax
  8010cc:	89 c2                	mov    %eax,%edx
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	eb 09                	jmp    8010dc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d3:	89 c2                	mov    %eax,%edx
  8010d5:	eb 05                	jmp    8010dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010dc:	89 d0                	mov    %edx,%eax
  8010de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f7:	eb 21                	jmp    80111a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f9:	83 ec 04             	sub    $0x4,%esp
  8010fc:	89 f0                	mov    %esi,%eax
  8010fe:	29 d8                	sub    %ebx,%eax
  801100:	50                   	push   %eax
  801101:	89 d8                	mov    %ebx,%eax
  801103:	03 45 0c             	add    0xc(%ebp),%eax
  801106:	50                   	push   %eax
  801107:	57                   	push   %edi
  801108:	e8 45 ff ff ff       	call   801052 <read>
		if (m < 0)
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	85 c0                	test   %eax,%eax
  801112:	78 10                	js     801124 <readn+0x41>
			return m;
		if (m == 0)
  801114:	85 c0                	test   %eax,%eax
  801116:	74 0a                	je     801122 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801118:	01 c3                	add    %eax,%ebx
  80111a:	39 f3                	cmp    %esi,%ebx
  80111c:	72 db                	jb     8010f9 <readn+0x16>
  80111e:	89 d8                	mov    %ebx,%eax
  801120:	eb 02                	jmp    801124 <readn+0x41>
  801122:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	53                   	push   %ebx
  801130:	83 ec 14             	sub    $0x14,%esp
  801133:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801136:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801139:	50                   	push   %eax
  80113a:	53                   	push   %ebx
  80113b:	e8 ac fc ff ff       	call   800dec <fd_lookup>
  801140:	83 c4 08             	add    $0x8,%esp
  801143:	89 c2                	mov    %eax,%edx
  801145:	85 c0                	test   %eax,%eax
  801147:	78 68                	js     8011b1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801149:	83 ec 08             	sub    $0x8,%esp
  80114c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114f:	50                   	push   %eax
  801150:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801153:	ff 30                	pushl  (%eax)
  801155:	e8 e8 fc ff ff       	call   800e42 <dev_lookup>
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 47                	js     8011a8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801164:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801168:	75 21                	jne    80118b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80116a:	a1 08 40 80 00       	mov    0x804008,%eax
  80116f:	8b 40 48             	mov    0x48(%eax),%eax
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	53                   	push   %ebx
  801176:	50                   	push   %eax
  801177:	68 69 26 80 00       	push   $0x802669
  80117c:	e8 f2 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801189:	eb 26                	jmp    8011b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80118b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80118e:	8b 52 0c             	mov    0xc(%edx),%edx
  801191:	85 d2                	test   %edx,%edx
  801193:	74 17                	je     8011ac <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801195:	83 ec 04             	sub    $0x4,%esp
  801198:	ff 75 10             	pushl  0x10(%ebp)
  80119b:	ff 75 0c             	pushl  0xc(%ebp)
  80119e:	50                   	push   %eax
  80119f:	ff d2                	call   *%edx
  8011a1:	89 c2                	mov    %eax,%edx
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	eb 09                	jmp    8011b1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a8:	89 c2                	mov    %eax,%edx
  8011aa:	eb 05                	jmp    8011b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011b1:	89 d0                	mov    %edx,%eax
  8011b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b6:	c9                   	leave  
  8011b7:	c3                   	ret    

008011b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	ff 75 08             	pushl  0x8(%ebp)
  8011c5:	e8 22 fc ff ff       	call   800dec <fd_lookup>
  8011ca:	83 c4 08             	add    $0x8,%esp
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 0e                	js     8011df <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011df:	c9                   	leave  
  8011e0:	c3                   	ret    

008011e1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	53                   	push   %ebx
  8011e5:	83 ec 14             	sub    $0x14,%esp
  8011e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ee:	50                   	push   %eax
  8011ef:	53                   	push   %ebx
  8011f0:	e8 f7 fb ff ff       	call   800dec <fd_lookup>
  8011f5:	83 c4 08             	add    $0x8,%esp
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	78 65                	js     801263 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801208:	ff 30                	pushl  (%eax)
  80120a:	e8 33 fc ff ff       	call   800e42 <dev_lookup>
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	78 44                	js     80125a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801216:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801219:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121d:	75 21                	jne    801240 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80121f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801224:	8b 40 48             	mov    0x48(%eax),%eax
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	53                   	push   %ebx
  80122b:	50                   	push   %eax
  80122c:	68 2c 26 80 00       	push   $0x80262c
  801231:	e8 3d ef ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80123e:	eb 23                	jmp    801263 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801240:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801243:	8b 52 18             	mov    0x18(%edx),%edx
  801246:	85 d2                	test   %edx,%edx
  801248:	74 14                	je     80125e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	ff 75 0c             	pushl  0xc(%ebp)
  801250:	50                   	push   %eax
  801251:	ff d2                	call   *%edx
  801253:	89 c2                	mov    %eax,%edx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	eb 09                	jmp    801263 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	eb 05                	jmp    801263 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80125e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801263:	89 d0                	mov    %edx,%eax
  801265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	53                   	push   %ebx
  80126e:	83 ec 14             	sub    $0x14,%esp
  801271:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	ff 75 08             	pushl  0x8(%ebp)
  80127b:	e8 6c fb ff ff       	call   800dec <fd_lookup>
  801280:	83 c4 08             	add    $0x8,%esp
  801283:	89 c2                	mov    %eax,%edx
  801285:	85 c0                	test   %eax,%eax
  801287:	78 58                	js     8012e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801293:	ff 30                	pushl  (%eax)
  801295:	e8 a8 fb ff ff       	call   800e42 <dev_lookup>
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 37                	js     8012d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012a8:	74 32                	je     8012dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b4:	00 00 00 
	stat->st_isdir = 0;
  8012b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012be:	00 00 00 
	stat->st_dev = dev;
  8012c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	53                   	push   %ebx
  8012cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ce:	ff 50 14             	call   *0x14(%eax)
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	eb 09                	jmp    8012e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	eb 05                	jmp    8012e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012e1:	89 d0                	mov    %edx,%eax
  8012e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e6:	c9                   	leave  
  8012e7:	c3                   	ret    

008012e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	56                   	push   %esi
  8012ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	6a 00                	push   $0x0
  8012f2:	ff 75 08             	pushl  0x8(%ebp)
  8012f5:	e8 d6 01 00 00       	call   8014d0 <open>
  8012fa:	89 c3                	mov    %eax,%ebx
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 1b                	js     80131e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	ff 75 0c             	pushl  0xc(%ebp)
  801309:	50                   	push   %eax
  80130a:	e8 5b ff ff ff       	call   80126a <fstat>
  80130f:	89 c6                	mov    %eax,%esi
	close(fd);
  801311:	89 1c 24             	mov    %ebx,(%esp)
  801314:	e8 fd fb ff ff       	call   800f16 <close>
	return r;
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	89 f0                	mov    %esi,%eax
}
  80131e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	56                   	push   %esi
  801329:	53                   	push   %ebx
  80132a:	89 c6                	mov    %eax,%esi
  80132c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80132e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801335:	75 12                	jne    801349 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	6a 01                	push   $0x1
  80133c:	e8 7a 0c 00 00       	call   801fbb <ipc_find_env>
  801341:	a3 00 40 80 00       	mov    %eax,0x804000
  801346:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801349:	6a 07                	push   $0x7
  80134b:	68 00 50 80 00       	push   $0x805000
  801350:	56                   	push   %esi
  801351:	ff 35 00 40 80 00    	pushl  0x804000
  801357:	e8 0b 0c 00 00       	call   801f67 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80135c:	83 c4 0c             	add    $0xc,%esp
  80135f:	6a 00                	push   $0x0
  801361:	53                   	push   %ebx
  801362:	6a 00                	push   $0x0
  801364:	e8 97 0b 00 00       	call   801f00 <ipc_recv>
}
  801369:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136c:	5b                   	pop    %ebx
  80136d:	5e                   	pop    %esi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801376:	8b 45 08             	mov    0x8(%ebp),%eax
  801379:	8b 40 0c             	mov    0xc(%eax),%eax
  80137c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801381:	8b 45 0c             	mov    0xc(%ebp),%eax
  801384:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801389:	ba 00 00 00 00       	mov    $0x0,%edx
  80138e:	b8 02 00 00 00       	mov    $0x2,%eax
  801393:	e8 8d ff ff ff       	call   801325 <fsipc>
}
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b5:	e8 6b ff ff ff       	call   801325 <fsipc>
}
  8013ba:	c9                   	leave  
  8013bb:	c3                   	ret    

008013bc <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 04             	sub    $0x4,%esp
  8013c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8013db:	e8 45 ff ff ff       	call   801325 <fsipc>
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 2c                	js     801410 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	68 00 50 80 00       	push   $0x805000
  8013ec:	53                   	push   %ebx
  8013ed:	e8 06 f3 ff ff       	call   8006f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8013f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801402:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801410:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801413:	c9                   	leave  
  801414:	c3                   	ret    

00801415 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 0c             	sub    $0xc,%esp
  80141b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80141e:	8b 55 08             	mov    0x8(%ebp),%edx
  801421:	8b 52 0c             	mov    0xc(%edx),%edx
  801424:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80142a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80142f:	50                   	push   %eax
  801430:	ff 75 0c             	pushl  0xc(%ebp)
  801433:	68 08 50 80 00       	push   $0x805008
  801438:	e8 4d f4 ff ff       	call   80088a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80143d:	ba 00 00 00 00       	mov    $0x0,%edx
  801442:	b8 04 00 00 00       	mov    $0x4,%eax
  801447:	e8 d9 fe ff ff       	call   801325 <fsipc>

}
  80144c:	c9                   	leave  
  80144d:	c3                   	ret    

0080144e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	56                   	push   %esi
  801452:	53                   	push   %ebx
  801453:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801456:	8b 45 08             	mov    0x8(%ebp),%eax
  801459:	8b 40 0c             	mov    0xc(%eax),%eax
  80145c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801461:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801467:	ba 00 00 00 00       	mov    $0x0,%edx
  80146c:	b8 03 00 00 00       	mov    $0x3,%eax
  801471:	e8 af fe ff ff       	call   801325 <fsipc>
  801476:	89 c3                	mov    %eax,%ebx
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 4b                	js     8014c7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80147c:	39 c6                	cmp    %eax,%esi
  80147e:	73 16                	jae    801496 <devfile_read+0x48>
  801480:	68 9c 26 80 00       	push   $0x80269c
  801485:	68 a3 26 80 00       	push   $0x8026a3
  80148a:	6a 7c                	push   $0x7c
  80148c:	68 b8 26 80 00       	push   $0x8026b8
  801491:	e8 24 0a 00 00       	call   801eba <_panic>
	assert(r <= PGSIZE);
  801496:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80149b:	7e 16                	jle    8014b3 <devfile_read+0x65>
  80149d:	68 c3 26 80 00       	push   $0x8026c3
  8014a2:	68 a3 26 80 00       	push   $0x8026a3
  8014a7:	6a 7d                	push   $0x7d
  8014a9:	68 b8 26 80 00       	push   $0x8026b8
  8014ae:	e8 07 0a 00 00       	call   801eba <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014b3:	83 ec 04             	sub    $0x4,%esp
  8014b6:	50                   	push   %eax
  8014b7:	68 00 50 80 00       	push   $0x805000
  8014bc:	ff 75 0c             	pushl  0xc(%ebp)
  8014bf:	e8 c6 f3 ff ff       	call   80088a <memmove>
	return r;
  8014c4:	83 c4 10             	add    $0x10,%esp
}
  8014c7:	89 d8                	mov    %ebx,%eax
  8014c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cc:	5b                   	pop    %ebx
  8014cd:	5e                   	pop    %esi
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 20             	sub    $0x20,%esp
  8014d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014da:	53                   	push   %ebx
  8014db:	e8 df f1 ff ff       	call   8006bf <strlen>
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014e8:	7f 67                	jg     801551 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f0:	50                   	push   %eax
  8014f1:	e8 a7 f8 ff ff       	call   800d9d <fd_alloc>
  8014f6:	83 c4 10             	add    $0x10,%esp
		return r;
  8014f9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 57                	js     801556 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	53                   	push   %ebx
  801503:	68 00 50 80 00       	push   $0x805000
  801508:	e8 eb f1 ff ff       	call   8006f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80150d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801510:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801515:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801518:	b8 01 00 00 00       	mov    $0x1,%eax
  80151d:	e8 03 fe ff ff       	call   801325 <fsipc>
  801522:	89 c3                	mov    %eax,%ebx
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	79 14                	jns    80153f <open+0x6f>
		fd_close(fd, 0);
  80152b:	83 ec 08             	sub    $0x8,%esp
  80152e:	6a 00                	push   $0x0
  801530:	ff 75 f4             	pushl  -0xc(%ebp)
  801533:	e8 5d f9 ff ff       	call   800e95 <fd_close>
		return r;
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	89 da                	mov    %ebx,%edx
  80153d:	eb 17                	jmp    801556 <open+0x86>
	}

	return fd2num(fd);
  80153f:	83 ec 0c             	sub    $0xc,%esp
  801542:	ff 75 f4             	pushl  -0xc(%ebp)
  801545:	e8 2c f8 ff ff       	call   800d76 <fd2num>
  80154a:	89 c2                	mov    %eax,%edx
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	eb 05                	jmp    801556 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801551:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801556:	89 d0                	mov    %edx,%eax
  801558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 08 00 00 00       	mov    $0x8,%eax
  80156d:	e8 b3 fd ff ff       	call   801325 <fsipc>
}
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80157a:	68 cf 26 80 00       	push   $0x8026cf
  80157f:	ff 75 0c             	pushl  0xc(%ebp)
  801582:	e8 71 f1 ff ff       	call   8006f8 <strcpy>
	return 0;
}
  801587:	b8 00 00 00 00       	mov    $0x0,%eax
  80158c:	c9                   	leave  
  80158d:	c3                   	ret    

0080158e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	53                   	push   %ebx
  801592:	83 ec 10             	sub    $0x10,%esp
  801595:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801598:	53                   	push   %ebx
  801599:	e8 56 0a 00 00       	call   801ff4 <pageref>
  80159e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015a1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015a6:	83 f8 01             	cmp    $0x1,%eax
  8015a9:	75 10                	jne    8015bb <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015ab:	83 ec 0c             	sub    $0xc,%esp
  8015ae:	ff 73 0c             	pushl  0xc(%ebx)
  8015b1:	e8 c0 02 00 00       	call   801876 <nsipc_close>
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015bb:	89 d0                	mov    %edx,%eax
  8015bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015c8:	6a 00                	push   $0x0
  8015ca:	ff 75 10             	pushl  0x10(%ebp)
  8015cd:	ff 75 0c             	pushl  0xc(%ebp)
  8015d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d3:	ff 70 0c             	pushl  0xc(%eax)
  8015d6:	e8 78 03 00 00       	call   801953 <nsipc_send>
}
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015e3:	6a 00                	push   $0x0
  8015e5:	ff 75 10             	pushl  0x10(%ebp)
  8015e8:	ff 75 0c             	pushl  0xc(%ebp)
  8015eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ee:	ff 70 0c             	pushl  0xc(%eax)
  8015f1:	e8 f1 02 00 00       	call   8018e7 <nsipc_recv>
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015fe:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801601:	52                   	push   %edx
  801602:	50                   	push   %eax
  801603:	e8 e4 f7 ff ff       	call   800dec <fd_lookup>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 17                	js     801626 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80160f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801612:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801618:	39 08                	cmp    %ecx,(%eax)
  80161a:	75 05                	jne    801621 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80161c:	8b 40 0c             	mov    0xc(%eax),%eax
  80161f:	eb 05                	jmp    801626 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801621:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801626:	c9                   	leave  
  801627:	c3                   	ret    

00801628 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	56                   	push   %esi
  80162c:	53                   	push   %ebx
  80162d:	83 ec 1c             	sub    $0x1c,%esp
  801630:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	e8 62 f7 ff ff       	call   800d9d <fd_alloc>
  80163b:	89 c3                	mov    %eax,%ebx
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	78 1b                	js     80165f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801644:	83 ec 04             	sub    $0x4,%esp
  801647:	68 07 04 00 00       	push   $0x407
  80164c:	ff 75 f4             	pushl  -0xc(%ebp)
  80164f:	6a 00                	push   $0x0
  801651:	e8 a5 f4 ff ff       	call   800afb <sys_page_alloc>
  801656:	89 c3                	mov    %eax,%ebx
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	79 10                	jns    80166f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80165f:	83 ec 0c             	sub    $0xc,%esp
  801662:	56                   	push   %esi
  801663:	e8 0e 02 00 00       	call   801876 <nsipc_close>
		return r;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	89 d8                	mov    %ebx,%eax
  80166d:	eb 24                	jmp    801693 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80166f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801678:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80167a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801684:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801687:	83 ec 0c             	sub    $0xc,%esp
  80168a:	50                   	push   %eax
  80168b:	e8 e6 f6 ff ff       	call   800d76 <fd2num>
  801690:	83 c4 10             	add    $0x10,%esp
}
  801693:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801696:	5b                   	pop    %ebx
  801697:	5e                   	pop    %esi
  801698:	5d                   	pop    %ebp
  801699:	c3                   	ret    

0080169a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a3:	e8 50 ff ff ff       	call   8015f8 <fd2sockid>
		return r;
  8016a8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 1f                	js     8016cd <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	ff 75 10             	pushl  0x10(%ebp)
  8016b4:	ff 75 0c             	pushl  0xc(%ebp)
  8016b7:	50                   	push   %eax
  8016b8:	e8 12 01 00 00       	call   8017cf <nsipc_accept>
  8016bd:	83 c4 10             	add    $0x10,%esp
		return r;
  8016c0:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 07                	js     8016cd <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016c6:	e8 5d ff ff ff       	call   801628 <alloc_sockfd>
  8016cb:	89 c1                	mov    %eax,%ecx
}
  8016cd:	89 c8                	mov    %ecx,%eax
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	e8 19 ff ff ff       	call   8015f8 <fd2sockid>
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 12                	js     8016f5 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	ff 75 10             	pushl  0x10(%ebp)
  8016e9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ec:	50                   	push   %eax
  8016ed:	e8 2d 01 00 00       	call   80181f <nsipc_bind>
  8016f2:	83 c4 10             	add    $0x10,%esp
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <shutdown>:

int
shutdown(int s, int how)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801700:	e8 f3 fe ff ff       	call   8015f8 <fd2sockid>
  801705:	85 c0                	test   %eax,%eax
  801707:	78 0f                	js     801718 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	50                   	push   %eax
  801710:	e8 3f 01 00 00       	call   801854 <nsipc_shutdown>
  801715:	83 c4 10             	add    $0x10,%esp
}
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801720:	8b 45 08             	mov    0x8(%ebp),%eax
  801723:	e8 d0 fe ff ff       	call   8015f8 <fd2sockid>
  801728:	85 c0                	test   %eax,%eax
  80172a:	78 12                	js     80173e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80172c:	83 ec 04             	sub    $0x4,%esp
  80172f:	ff 75 10             	pushl  0x10(%ebp)
  801732:	ff 75 0c             	pushl  0xc(%ebp)
  801735:	50                   	push   %eax
  801736:	e8 55 01 00 00       	call   801890 <nsipc_connect>
  80173b:	83 c4 10             	add    $0x10,%esp
}
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <listen>:

int
listen(int s, int backlog)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801746:	8b 45 08             	mov    0x8(%ebp),%eax
  801749:	e8 aa fe ff ff       	call   8015f8 <fd2sockid>
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 0f                	js     801761 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801752:	83 ec 08             	sub    $0x8,%esp
  801755:	ff 75 0c             	pushl  0xc(%ebp)
  801758:	50                   	push   %eax
  801759:	e8 67 01 00 00       	call   8018c5 <nsipc_listen>
  80175e:	83 c4 10             	add    $0x10,%esp
}
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801769:	ff 75 10             	pushl  0x10(%ebp)
  80176c:	ff 75 0c             	pushl  0xc(%ebp)
  80176f:	ff 75 08             	pushl  0x8(%ebp)
  801772:	e8 3a 02 00 00       	call   8019b1 <nsipc_socket>
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 05                	js     801783 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80177e:	e8 a5 fe ff ff       	call   801628 <alloc_sockfd>
}
  801783:	c9                   	leave  
  801784:	c3                   	ret    

00801785 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	53                   	push   %ebx
  801789:	83 ec 04             	sub    $0x4,%esp
  80178c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80178e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801795:	75 12                	jne    8017a9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801797:	83 ec 0c             	sub    $0xc,%esp
  80179a:	6a 02                	push   $0x2
  80179c:	e8 1a 08 00 00       	call   801fbb <ipc_find_env>
  8017a1:	a3 04 40 80 00       	mov    %eax,0x804004
  8017a6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017a9:	6a 07                	push   $0x7
  8017ab:	68 00 60 80 00       	push   $0x806000
  8017b0:	53                   	push   %ebx
  8017b1:	ff 35 04 40 80 00    	pushl  0x804004
  8017b7:	e8 ab 07 00 00       	call   801f67 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017bc:	83 c4 0c             	add    $0xc,%esp
  8017bf:	6a 00                	push   $0x0
  8017c1:	6a 00                	push   $0x0
  8017c3:	6a 00                	push   $0x0
  8017c5:	e8 36 07 00 00       	call   801f00 <ipc_recv>
}
  8017ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	56                   	push   %esi
  8017d3:	53                   	push   %ebx
  8017d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017df:	8b 06                	mov    (%esi),%eax
  8017e1:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8017eb:	e8 95 ff ff ff       	call   801785 <nsipc>
  8017f0:	89 c3                	mov    %eax,%ebx
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	78 20                	js     801816 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017f6:	83 ec 04             	sub    $0x4,%esp
  8017f9:	ff 35 10 60 80 00    	pushl  0x806010
  8017ff:	68 00 60 80 00       	push   $0x806000
  801804:	ff 75 0c             	pushl  0xc(%ebp)
  801807:	e8 7e f0 ff ff       	call   80088a <memmove>
		*addrlen = ret->ret_addrlen;
  80180c:	a1 10 60 80 00       	mov    0x806010,%eax
  801811:	89 06                	mov    %eax,(%esi)
  801813:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801816:	89 d8                	mov    %ebx,%eax
  801818:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5e                   	pop    %esi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801831:	53                   	push   %ebx
  801832:	ff 75 0c             	pushl  0xc(%ebp)
  801835:	68 04 60 80 00       	push   $0x806004
  80183a:	e8 4b f0 ff ff       	call   80088a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80183f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801845:	b8 02 00 00 00       	mov    $0x2,%eax
  80184a:	e8 36 ff ff ff       	call   801785 <nsipc>
}
  80184f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801862:	8b 45 0c             	mov    0xc(%ebp),%eax
  801865:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80186a:	b8 03 00 00 00       	mov    $0x3,%eax
  80186f:	e8 11 ff ff ff       	call   801785 <nsipc>
}
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <nsipc_close>:

int
nsipc_close(int s)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80187c:	8b 45 08             	mov    0x8(%ebp),%eax
  80187f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801884:	b8 04 00 00 00       	mov    $0x4,%eax
  801889:	e8 f7 fe ff ff       	call   801785 <nsipc>
}
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	53                   	push   %ebx
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018a2:	53                   	push   %ebx
  8018a3:	ff 75 0c             	pushl  0xc(%ebp)
  8018a6:	68 04 60 80 00       	push   $0x806004
  8018ab:	e8 da ef ff ff       	call   80088a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018b0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8018bb:	e8 c5 fe ff ff       	call   801785 <nsipc>
}
  8018c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8018d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8018db:	b8 06 00 00 00       	mov    $0x6,%eax
  8018e0:	e8 a0 fe ff ff       	call   801785 <nsipc>
}
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    

008018e7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	56                   	push   %esi
  8018eb:	53                   	push   %ebx
  8018ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8018f7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8018fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801900:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801905:	b8 07 00 00 00       	mov    $0x7,%eax
  80190a:	e8 76 fe ff ff       	call   801785 <nsipc>
  80190f:	89 c3                	mov    %eax,%ebx
  801911:	85 c0                	test   %eax,%eax
  801913:	78 35                	js     80194a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801915:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80191a:	7f 04                	jg     801920 <nsipc_recv+0x39>
  80191c:	39 c6                	cmp    %eax,%esi
  80191e:	7d 16                	jge    801936 <nsipc_recv+0x4f>
  801920:	68 db 26 80 00       	push   $0x8026db
  801925:	68 a3 26 80 00       	push   $0x8026a3
  80192a:	6a 62                	push   $0x62
  80192c:	68 f0 26 80 00       	push   $0x8026f0
  801931:	e8 84 05 00 00       	call   801eba <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801936:	83 ec 04             	sub    $0x4,%esp
  801939:	50                   	push   %eax
  80193a:	68 00 60 80 00       	push   $0x806000
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	e8 43 ef ff ff       	call   80088a <memmove>
  801947:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80194a:	89 d8                	mov    %ebx,%eax
  80194c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5d                   	pop    %ebp
  801952:	c3                   	ret    

00801953 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	53                   	push   %ebx
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80195d:	8b 45 08             	mov    0x8(%ebp),%eax
  801960:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801965:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80196b:	7e 16                	jle    801983 <nsipc_send+0x30>
  80196d:	68 fc 26 80 00       	push   $0x8026fc
  801972:	68 a3 26 80 00       	push   $0x8026a3
  801977:	6a 6d                	push   $0x6d
  801979:	68 f0 26 80 00       	push   $0x8026f0
  80197e:	e8 37 05 00 00       	call   801eba <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801983:	83 ec 04             	sub    $0x4,%esp
  801986:	53                   	push   %ebx
  801987:	ff 75 0c             	pushl  0xc(%ebp)
  80198a:	68 0c 60 80 00       	push   $0x80600c
  80198f:	e8 f6 ee ff ff       	call   80088a <memmove>
	nsipcbuf.send.req_size = size;
  801994:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80199a:	8b 45 14             	mov    0x14(%ebp),%eax
  80199d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019a2:	b8 08 00 00 00       	mov    $0x8,%eax
  8019a7:	e8 d9 fd ff ff       	call   801785 <nsipc>
}
  8019ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c2:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ca:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019cf:	b8 09 00 00 00       	mov    $0x9,%eax
  8019d4:	e8 ac fd ff ff       	call   801785 <nsipc>
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019e3:	83 ec 0c             	sub    $0xc,%esp
  8019e6:	ff 75 08             	pushl  0x8(%ebp)
  8019e9:	e8 98 f3 ff ff       	call   800d86 <fd2data>
  8019ee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019f0:	83 c4 08             	add    $0x8,%esp
  8019f3:	68 08 27 80 00       	push   $0x802708
  8019f8:	53                   	push   %ebx
  8019f9:	e8 fa ec ff ff       	call   8006f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019fe:	8b 46 04             	mov    0x4(%esi),%eax
  801a01:	2b 06                	sub    (%esi),%eax
  801a03:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a09:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a10:	00 00 00 
	stat->st_dev = &devpipe;
  801a13:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a1a:	30 80 00 
	return 0;
}
  801a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	53                   	push   %ebx
  801a2d:	83 ec 0c             	sub    $0xc,%esp
  801a30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a33:	53                   	push   %ebx
  801a34:	6a 00                	push   $0x0
  801a36:	e8 45 f1 ff ff       	call   800b80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a3b:	89 1c 24             	mov    %ebx,(%esp)
  801a3e:	e8 43 f3 ff ff       	call   800d86 <fd2data>
  801a43:	83 c4 08             	add    $0x8,%esp
  801a46:	50                   	push   %eax
  801a47:	6a 00                	push   $0x0
  801a49:	e8 32 f1 ff ff       	call   800b80 <sys_page_unmap>
}
  801a4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	57                   	push   %edi
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	83 ec 1c             	sub    $0x1c,%esp
  801a5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a5f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a61:	a1 08 40 80 00       	mov    0x804008,%eax
  801a66:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a69:	83 ec 0c             	sub    $0xc,%esp
  801a6c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a6f:	e8 80 05 00 00       	call   801ff4 <pageref>
  801a74:	89 c3                	mov    %eax,%ebx
  801a76:	89 3c 24             	mov    %edi,(%esp)
  801a79:	e8 76 05 00 00       	call   801ff4 <pageref>
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	39 c3                	cmp    %eax,%ebx
  801a83:	0f 94 c1             	sete   %cl
  801a86:	0f b6 c9             	movzbl %cl,%ecx
  801a89:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a8c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a92:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a95:	39 ce                	cmp    %ecx,%esi
  801a97:	74 1b                	je     801ab4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a99:	39 c3                	cmp    %eax,%ebx
  801a9b:	75 c4                	jne    801a61 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a9d:	8b 42 58             	mov    0x58(%edx),%eax
  801aa0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aa3:	50                   	push   %eax
  801aa4:	56                   	push   %esi
  801aa5:	68 0f 27 80 00       	push   $0x80270f
  801aaa:	e8 c4 e6 ff ff       	call   800173 <cprintf>
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	eb ad                	jmp    801a61 <_pipeisclosed+0xe>
	}
}
  801ab4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5f                   	pop    %edi
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	57                   	push   %edi
  801ac3:	56                   	push   %esi
  801ac4:	53                   	push   %ebx
  801ac5:	83 ec 28             	sub    $0x28,%esp
  801ac8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801acb:	56                   	push   %esi
  801acc:	e8 b5 f2 ff ff       	call   800d86 <fd2data>
  801ad1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	bf 00 00 00 00       	mov    $0x0,%edi
  801adb:	eb 4b                	jmp    801b28 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801add:	89 da                	mov    %ebx,%edx
  801adf:	89 f0                	mov    %esi,%eax
  801ae1:	e8 6d ff ff ff       	call   801a53 <_pipeisclosed>
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	75 48                	jne    801b32 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aea:	e8 ed ef ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aef:	8b 43 04             	mov    0x4(%ebx),%eax
  801af2:	8b 0b                	mov    (%ebx),%ecx
  801af4:	8d 51 20             	lea    0x20(%ecx),%edx
  801af7:	39 d0                	cmp    %edx,%eax
  801af9:	73 e2                	jae    801add <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b02:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b05:	89 c2                	mov    %eax,%edx
  801b07:	c1 fa 1f             	sar    $0x1f,%edx
  801b0a:	89 d1                	mov    %edx,%ecx
  801b0c:	c1 e9 1b             	shr    $0x1b,%ecx
  801b0f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b12:	83 e2 1f             	and    $0x1f,%edx
  801b15:	29 ca                	sub    %ecx,%edx
  801b17:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b1b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b1f:	83 c0 01             	add    $0x1,%eax
  801b22:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b25:	83 c7 01             	add    $0x1,%edi
  801b28:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b2b:	75 c2                	jne    801aef <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b30:	eb 05                	jmp    801b37 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5e                   	pop    %esi
  801b3c:	5f                   	pop    %edi
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	57                   	push   %edi
  801b43:	56                   	push   %esi
  801b44:	53                   	push   %ebx
  801b45:	83 ec 18             	sub    $0x18,%esp
  801b48:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b4b:	57                   	push   %edi
  801b4c:	e8 35 f2 ff ff       	call   800d86 <fd2data>
  801b51:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b5b:	eb 3d                	jmp    801b9a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b5d:	85 db                	test   %ebx,%ebx
  801b5f:	74 04                	je     801b65 <devpipe_read+0x26>
				return i;
  801b61:	89 d8                	mov    %ebx,%eax
  801b63:	eb 44                	jmp    801ba9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b65:	89 f2                	mov    %esi,%edx
  801b67:	89 f8                	mov    %edi,%eax
  801b69:	e8 e5 fe ff ff       	call   801a53 <_pipeisclosed>
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	75 32                	jne    801ba4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b72:	e8 65 ef ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b77:	8b 06                	mov    (%esi),%eax
  801b79:	3b 46 04             	cmp    0x4(%esi),%eax
  801b7c:	74 df                	je     801b5d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7e:	99                   	cltd   
  801b7f:	c1 ea 1b             	shr    $0x1b,%edx
  801b82:	01 d0                	add    %edx,%eax
  801b84:	83 e0 1f             	and    $0x1f,%eax
  801b87:	29 d0                	sub    %edx,%eax
  801b89:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b91:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b94:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b97:	83 c3 01             	add    $0x1,%ebx
  801b9a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b9d:	75 d8                	jne    801b77 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba2:	eb 05                	jmp    801ba9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bac:	5b                   	pop    %ebx
  801bad:	5e                   	pop    %esi
  801bae:	5f                   	pop    %edi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	56                   	push   %esi
  801bb5:	53                   	push   %ebx
  801bb6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbc:	50                   	push   %eax
  801bbd:	e8 db f1 ff ff       	call   800d9d <fd_alloc>
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	89 c2                	mov    %eax,%edx
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	0f 88 2c 01 00 00    	js     801cfb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcf:	83 ec 04             	sub    $0x4,%esp
  801bd2:	68 07 04 00 00       	push   $0x407
  801bd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bda:	6a 00                	push   $0x0
  801bdc:	e8 1a ef ff ff       	call   800afb <sys_page_alloc>
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	89 c2                	mov    %eax,%edx
  801be6:	85 c0                	test   %eax,%eax
  801be8:	0f 88 0d 01 00 00    	js     801cfb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bee:	83 ec 0c             	sub    $0xc,%esp
  801bf1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf4:	50                   	push   %eax
  801bf5:	e8 a3 f1 ff ff       	call   800d9d <fd_alloc>
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	0f 88 e2 00 00 00    	js     801ce9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c07:	83 ec 04             	sub    $0x4,%esp
  801c0a:	68 07 04 00 00       	push   $0x407
  801c0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c12:	6a 00                	push   $0x0
  801c14:	e8 e2 ee ff ff       	call   800afb <sys_page_alloc>
  801c19:	89 c3                	mov    %eax,%ebx
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	0f 88 c3 00 00 00    	js     801ce9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c26:	83 ec 0c             	sub    $0xc,%esp
  801c29:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2c:	e8 55 f1 ff ff       	call   800d86 <fd2data>
  801c31:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c33:	83 c4 0c             	add    $0xc,%esp
  801c36:	68 07 04 00 00       	push   $0x407
  801c3b:	50                   	push   %eax
  801c3c:	6a 00                	push   $0x0
  801c3e:	e8 b8 ee ff ff       	call   800afb <sys_page_alloc>
  801c43:	89 c3                	mov    %eax,%ebx
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	0f 88 89 00 00 00    	js     801cd9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	ff 75 f0             	pushl  -0x10(%ebp)
  801c56:	e8 2b f1 ff ff       	call   800d86 <fd2data>
  801c5b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c62:	50                   	push   %eax
  801c63:	6a 00                	push   $0x0
  801c65:	56                   	push   %esi
  801c66:	6a 00                	push   $0x0
  801c68:	e8 d1 ee ff ff       	call   800b3e <sys_page_map>
  801c6d:	89 c3                	mov    %eax,%ebx
  801c6f:	83 c4 20             	add    $0x20,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	78 55                	js     801ccb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c76:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c84:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c8b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c94:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c99:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ca0:	83 ec 0c             	sub    $0xc,%esp
  801ca3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca6:	e8 cb f0 ff ff       	call   800d76 <fd2num>
  801cab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cae:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cb0:	83 c4 04             	add    $0x4,%esp
  801cb3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb6:	e8 bb f0 ff ff       	call   800d76 <fd2num>
  801cbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbe:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc9:	eb 30                	jmp    801cfb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ccb:	83 ec 08             	sub    $0x8,%esp
  801cce:	56                   	push   %esi
  801ccf:	6a 00                	push   $0x0
  801cd1:	e8 aa ee ff ff       	call   800b80 <sys_page_unmap>
  801cd6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cd9:	83 ec 08             	sub    $0x8,%esp
  801cdc:	ff 75 f0             	pushl  -0x10(%ebp)
  801cdf:	6a 00                	push   $0x0
  801ce1:	e8 9a ee ff ff       	call   800b80 <sys_page_unmap>
  801ce6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ce9:	83 ec 08             	sub    $0x8,%esp
  801cec:	ff 75 f4             	pushl  -0xc(%ebp)
  801cef:	6a 00                	push   $0x0
  801cf1:	e8 8a ee ff ff       	call   800b80 <sys_page_unmap>
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cfb:	89 d0                	mov    %edx,%eax
  801cfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    

00801d04 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0d:	50                   	push   %eax
  801d0e:	ff 75 08             	pushl  0x8(%ebp)
  801d11:	e8 d6 f0 ff ff       	call   800dec <fd_lookup>
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	78 18                	js     801d35 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d1d:	83 ec 0c             	sub    $0xc,%esp
  801d20:	ff 75 f4             	pushl  -0xc(%ebp)
  801d23:	e8 5e f0 ff ff       	call   800d86 <fd2data>
	return _pipeisclosed(fd, p);
  801d28:	89 c2                	mov    %eax,%edx
  801d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2d:	e8 21 fd ff ff       	call   801a53 <_pipeisclosed>
  801d32:	83 c4 10             	add    $0x10,%esp
}
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d47:	68 27 27 80 00       	push   $0x802727
  801d4c:	ff 75 0c             	pushl  0xc(%ebp)
  801d4f:	e8 a4 e9 ff ff       	call   8006f8 <strcpy>
	return 0;
}
  801d54:	b8 00 00 00 00       	mov    $0x0,%eax
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	57                   	push   %edi
  801d5f:	56                   	push   %esi
  801d60:	53                   	push   %ebx
  801d61:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d67:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d72:	eb 2d                	jmp    801da1 <devcons_write+0x46>
		m = n - tot;
  801d74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d77:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d79:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d7c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d81:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d84:	83 ec 04             	sub    $0x4,%esp
  801d87:	53                   	push   %ebx
  801d88:	03 45 0c             	add    0xc(%ebp),%eax
  801d8b:	50                   	push   %eax
  801d8c:	57                   	push   %edi
  801d8d:	e8 f8 ea ff ff       	call   80088a <memmove>
		sys_cputs(buf, m);
  801d92:	83 c4 08             	add    $0x8,%esp
  801d95:	53                   	push   %ebx
  801d96:	57                   	push   %edi
  801d97:	e8 a3 ec ff ff       	call   800a3f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9c:	01 de                	add    %ebx,%esi
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801da6:	72 cc                	jb     801d74 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dab:	5b                   	pop    %ebx
  801dac:	5e                   	pop    %esi
  801dad:	5f                   	pop    %edi
  801dae:	5d                   	pop    %ebp
  801daf:	c3                   	ret    

00801db0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	83 ec 08             	sub    $0x8,%esp
  801db6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dbf:	74 2a                	je     801deb <devcons_read+0x3b>
  801dc1:	eb 05                	jmp    801dc8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dc3:	e8 14 ed ff ff       	call   800adc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dc8:	e8 90 ec ff ff       	call   800a5d <sys_cgetc>
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	74 f2                	je     801dc3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	78 16                	js     801deb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dd5:	83 f8 04             	cmp    $0x4,%eax
  801dd8:	74 0c                	je     801de6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dda:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ddd:	88 02                	mov    %al,(%edx)
	return 1;
  801ddf:	b8 01 00 00 00       	mov    $0x1,%eax
  801de4:	eb 05                	jmp    801deb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801de6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801deb:	c9                   	leave  
  801dec:	c3                   	ret    

00801ded <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801df3:	8b 45 08             	mov    0x8(%ebp),%eax
  801df6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801df9:	6a 01                	push   $0x1
  801dfb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	e8 3b ec ff ff       	call   800a3f <sys_cputs>
}
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	c9                   	leave  
  801e08:	c3                   	ret    

00801e09 <getchar>:

int
getchar(void)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e0f:	6a 01                	push   $0x1
  801e11:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e14:	50                   	push   %eax
  801e15:	6a 00                	push   $0x0
  801e17:	e8 36 f2 ff ff       	call   801052 <read>
	if (r < 0)
  801e1c:	83 c4 10             	add    $0x10,%esp
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	78 0f                	js     801e32 <getchar+0x29>
		return r;
	if (r < 1)
  801e23:	85 c0                	test   %eax,%eax
  801e25:	7e 06                	jle    801e2d <getchar+0x24>
		return -E_EOF;
	return c;
  801e27:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e2b:	eb 05                	jmp    801e32 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e2d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e32:	c9                   	leave  
  801e33:	c3                   	ret    

00801e34 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3d:	50                   	push   %eax
  801e3e:	ff 75 08             	pushl  0x8(%ebp)
  801e41:	e8 a6 ef ff ff       	call   800dec <fd_lookup>
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	78 11                	js     801e5e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e50:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e56:	39 10                	cmp    %edx,(%eax)
  801e58:	0f 94 c0             	sete   %al
  801e5b:	0f b6 c0             	movzbl %al,%eax
}
  801e5e:	c9                   	leave  
  801e5f:	c3                   	ret    

00801e60 <opencons>:

int
opencons(void)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e69:	50                   	push   %eax
  801e6a:	e8 2e ef ff ff       	call   800d9d <fd_alloc>
  801e6f:	83 c4 10             	add    $0x10,%esp
		return r;
  801e72:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e74:	85 c0                	test   %eax,%eax
  801e76:	78 3e                	js     801eb6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e78:	83 ec 04             	sub    $0x4,%esp
  801e7b:	68 07 04 00 00       	push   $0x407
  801e80:	ff 75 f4             	pushl  -0xc(%ebp)
  801e83:	6a 00                	push   $0x0
  801e85:	e8 71 ec ff ff       	call   800afb <sys_page_alloc>
  801e8a:	83 c4 10             	add    $0x10,%esp
		return r;
  801e8d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	78 23                	js     801eb6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e93:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ea8:	83 ec 0c             	sub    $0xc,%esp
  801eab:	50                   	push   %eax
  801eac:	e8 c5 ee ff ff       	call   800d76 <fd2num>
  801eb1:	89 c2                	mov    %eax,%edx
  801eb3:	83 c4 10             	add    $0x10,%esp
}
  801eb6:	89 d0                	mov    %edx,%eax
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	56                   	push   %esi
  801ebe:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ebf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ec2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ec8:	e8 f0 eb ff ff       	call   800abd <sys_getenvid>
  801ecd:	83 ec 0c             	sub    $0xc,%esp
  801ed0:	ff 75 0c             	pushl  0xc(%ebp)
  801ed3:	ff 75 08             	pushl  0x8(%ebp)
  801ed6:	56                   	push   %esi
  801ed7:	50                   	push   %eax
  801ed8:	68 34 27 80 00       	push   $0x802734
  801edd:	e8 91 e2 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ee2:	83 c4 18             	add    $0x18,%esp
  801ee5:	53                   	push   %ebx
  801ee6:	ff 75 10             	pushl  0x10(%ebp)
  801ee9:	e8 34 e2 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801eee:	c7 04 24 20 27 80 00 	movl   $0x802720,(%esp)
  801ef5:	e8 79 e2 ff ff       	call   800173 <cprintf>
  801efa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801efd:	cc                   	int3   
  801efe:	eb fd                	jmp    801efd <_panic+0x43>

00801f00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	8b 75 08             	mov    0x8(%ebp),%esi
  801f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f0e:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f10:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f15:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	50                   	push   %eax
  801f1c:	e8 8a ed ff ff       	call   800cab <sys_ipc_recv>

	if (from_env_store != NULL)
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	85 f6                	test   %esi,%esi
  801f26:	74 14                	je     801f3c <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f28:	ba 00 00 00 00       	mov    $0x0,%edx
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	78 09                	js     801f3a <ipc_recv+0x3a>
  801f31:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f37:	8b 52 74             	mov    0x74(%edx),%edx
  801f3a:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f3c:	85 db                	test   %ebx,%ebx
  801f3e:	74 14                	je     801f54 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f40:	ba 00 00 00 00       	mov    $0x0,%edx
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 09                	js     801f52 <ipc_recv+0x52>
  801f49:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f4f:	8b 52 78             	mov    0x78(%edx),%edx
  801f52:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f54:	85 c0                	test   %eax,%eax
  801f56:	78 08                	js     801f60 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f58:	a1 08 40 80 00       	mov    0x804008,%eax
  801f5d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5d                   	pop    %ebp
  801f66:	c3                   	ret    

00801f67 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	57                   	push   %edi
  801f6b:	56                   	push   %esi
  801f6c:	53                   	push   %ebx
  801f6d:	83 ec 0c             	sub    $0xc,%esp
  801f70:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f73:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f79:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f7b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f80:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f83:	ff 75 14             	pushl  0x14(%ebp)
  801f86:	53                   	push   %ebx
  801f87:	56                   	push   %esi
  801f88:	57                   	push   %edi
  801f89:	e8 fa ec ff ff       	call   800c88 <sys_ipc_try_send>

		if (err < 0) {
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	85 c0                	test   %eax,%eax
  801f93:	79 1e                	jns    801fb3 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f95:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f98:	75 07                	jne    801fa1 <ipc_send+0x3a>
				sys_yield();
  801f9a:	e8 3d eb ff ff       	call   800adc <sys_yield>
  801f9f:	eb e2                	jmp    801f83 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801fa1:	50                   	push   %eax
  801fa2:	68 58 27 80 00       	push   $0x802758
  801fa7:	6a 49                	push   $0x49
  801fa9:	68 65 27 80 00       	push   $0x802765
  801fae:	e8 07 ff ff ff       	call   801eba <_panic>
		}

	} while (err < 0);

}
  801fb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb6:	5b                   	pop    %ebx
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fc6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fc9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fcf:	8b 52 50             	mov    0x50(%edx),%edx
  801fd2:	39 ca                	cmp    %ecx,%edx
  801fd4:	75 0d                	jne    801fe3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fd6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fd9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fde:	8b 40 48             	mov    0x48(%eax),%eax
  801fe1:	eb 0f                	jmp    801ff2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe3:	83 c0 01             	add    $0x1,%eax
  801fe6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801feb:	75 d9                	jne    801fc6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ff2:	5d                   	pop    %ebp
  801ff3:	c3                   	ret    

00801ff4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ffa:	89 d0                	mov    %edx,%eax
  801ffc:	c1 e8 16             	shr    $0x16,%eax
  801fff:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802006:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80200b:	f6 c1 01             	test   $0x1,%cl
  80200e:	74 1d                	je     80202d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802010:	c1 ea 0c             	shr    $0xc,%edx
  802013:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80201a:	f6 c2 01             	test   $0x1,%dl
  80201d:	74 0e                	je     80202d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80201f:	c1 ea 0c             	shr    $0xc,%edx
  802022:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802029:	ef 
  80202a:	0f b7 c0             	movzwl %ax,%eax
}
  80202d:	5d                   	pop    %ebp
  80202e:	c3                   	ret    
  80202f:	90                   	nop

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80203b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80203f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 f6                	test   %esi,%esi
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 ca                	mov    %ecx,%edx
  80204f:	89 f8                	mov    %edi,%eax
  802051:	75 3d                	jne    802090 <__udivdi3+0x60>
  802053:	39 cf                	cmp    %ecx,%edi
  802055:	0f 87 c5 00 00 00    	ja     802120 <__udivdi3+0xf0>
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 fd                	mov    %edi,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f7                	div    %edi
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 c8                	mov    %ecx,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c1                	mov    %eax,%ecx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	89 cf                	mov    %ecx,%edi
  802078:	f7 f5                	div    %ebp
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	39 ce                	cmp    %ecx,%esi
  802092:	77 74                	ja     802108 <__udivdi3+0xd8>
  802094:	0f bd fe             	bsr    %esi,%edi
  802097:	83 f7 1f             	xor    $0x1f,%edi
  80209a:	0f 84 98 00 00 00    	je     802138 <__udivdi3+0x108>
  8020a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	89 c5                	mov    %eax,%ebp
  8020a9:	29 fb                	sub    %edi,%ebx
  8020ab:	d3 e6                	shl    %cl,%esi
  8020ad:	89 d9                	mov    %ebx,%ecx
  8020af:	d3 ed                	shr    %cl,%ebp
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	09 ee                	or     %ebp,%esi
  8020b7:	89 d9                	mov    %ebx,%ecx
  8020b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bd:	89 d5                	mov    %edx,%ebp
  8020bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c3:	d3 ed                	shr    %cl,%ebp
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e2                	shl    %cl,%edx
  8020c9:	89 d9                	mov    %ebx,%ecx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	89 ea                	mov    %ebp,%edx
  8020d3:	f7 f6                	div    %esi
  8020d5:	89 d5                	mov    %edx,%ebp
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	f7 64 24 0c          	mull   0xc(%esp)
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	72 10                	jb     8020f1 <__udivdi3+0xc1>
  8020e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e6                	shl    %cl,%esi
  8020e9:	39 c6                	cmp    %eax,%esi
  8020eb:	73 07                	jae    8020f4 <__udivdi3+0xc4>
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	75 03                	jne    8020f4 <__udivdi3+0xc4>
  8020f1:	83 eb 01             	sub    $0x1,%ebx
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	89 fa                	mov    %edi,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	31 ff                	xor    %edi,%edi
  80210a:	31 db                	xor    %ebx,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d8                	mov    %ebx,%eax
  802122:	f7 f7                	div    %edi
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 c3                	mov    %eax,%ebx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 fa                	mov    %edi,%edx
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 ce                	cmp    %ecx,%esi
  80213a:	72 0c                	jb     802148 <__udivdi3+0x118>
  80213c:	31 db                	xor    %ebx,%ebx
  80213e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802142:	0f 87 34 ff ff ff    	ja     80207c <__udivdi3+0x4c>
  802148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80214d:	e9 2a ff ff ff       	jmp    80207c <__udivdi3+0x4c>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 d2                	test   %edx,%edx
  802179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f3                	mov    %esi,%ebx
  802183:	89 3c 24             	mov    %edi,(%esp)
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	75 1c                	jne    8021a8 <__umoddi3+0x48>
  80218c:	39 f7                	cmp    %esi,%edi
  80218e:	76 50                	jbe    8021e0 <__umoddi3+0x80>
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	f7 f7                	div    %edi
  802196:	89 d0                	mov    %edx,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	77 52                	ja     802200 <__umoddi3+0xa0>
  8021ae:	0f bd ea             	bsr    %edx,%ebp
  8021b1:	83 f5 1f             	xor    $0x1f,%ebp
  8021b4:	75 5a                	jne    802210 <__umoddi3+0xb0>
  8021b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ba:	0f 82 e0 00 00 00    	jb     8022a0 <__umoddi3+0x140>
  8021c0:	39 0c 24             	cmp    %ecx,(%esp)
  8021c3:	0f 86 d7 00 00 00    	jbe    8022a0 <__umoddi3+0x140>
  8021c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	89 fd                	mov    %edi,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x91>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f7                	div    %edi
  8021ef:	89 c5                	mov    %eax,%ebp
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f5                	div    %ebp
  8021f7:	89 c8                	mov    %ecx,%eax
  8021f9:	f7 f5                	div    %ebp
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	eb 99                	jmp    802198 <__umoddi3+0x38>
  8021ff:	90                   	nop
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	8b 34 24             	mov    (%esp),%esi
  802213:	bf 20 00 00 00       	mov    $0x20,%edi
  802218:	89 e9                	mov    %ebp,%ecx
  80221a:	29 ef                	sub    %ebp,%edi
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 f9                	mov    %edi,%ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	d3 ea                	shr    %cl,%edx
  802224:	89 e9                	mov    %ebp,%ecx
  802226:	09 c2                	or     %eax,%edx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 14 24             	mov    %edx,(%esp)
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
  802231:	89 f9                	mov    %edi,%ecx
  802233:	89 54 24 04          	mov    %edx,0x4(%esp)
  802237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	89 c6                	mov    %eax,%esi
  802241:	d3 e3                	shl    %cl,%ebx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 d0                	mov    %edx,%eax
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	09 d8                	or     %ebx,%eax
  80224d:	89 d3                	mov    %edx,%ebx
  80224f:	89 f2                	mov    %esi,%edx
  802251:	f7 34 24             	divl   (%esp)
  802254:	89 d6                	mov    %edx,%esi
  802256:	d3 e3                	shl    %cl,%ebx
  802258:	f7 64 24 04          	mull   0x4(%esp)
  80225c:	39 d6                	cmp    %edx,%esi
  80225e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802262:	89 d1                	mov    %edx,%ecx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	72 08                	jb     802270 <__umoddi3+0x110>
  802268:	75 11                	jne    80227b <__umoddi3+0x11b>
  80226a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80226e:	73 0b                	jae    80227b <__umoddi3+0x11b>
  802270:	2b 44 24 04          	sub    0x4(%esp),%eax
  802274:	1b 14 24             	sbb    (%esp),%edx
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80227f:	29 da                	sub    %ebx,%edx
  802281:	19 ce                	sbb    %ecx,%esi
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 f0                	mov    %esi,%eax
  802287:	d3 e0                	shl    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	d3 ea                	shr    %cl,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 ee                	shr    %cl,%esi
  802291:	09 d0                	or     %edx,%eax
  802293:	89 f2                	mov    %esi,%edx
  802295:	83 c4 1c             	add    $0x1c,%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	29 f9                	sub    %edi,%ecx
  8022a2:	19 d6                	sbb    %edx,%esi
  8022a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ac:	e9 18 ff ff ff       	jmp    8021c9 <__umoddi3+0x69>
