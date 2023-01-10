
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
  800045:	68 20 23 80 00       	push   $0x802320
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
  80006c:	e8 dc 0c 00 00       	call   800d4d <set_pgfault_handler>
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
  8000cc:	e8 b2 0e 00 00       	call   800f83 <close_all>
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
  8001d6:	e8 a5 1e 00 00       	call   802080 <__udivdi3>
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
  800219:	e8 92 1f 00 00       	call   8021b0 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 46 23 80 00 	movsbl 0x802346(%eax),%eax
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
  80031d:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
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
  8003e1:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	75 18                	jne    800404 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ec:	50                   	push   %eax
  8003ed:	68 5e 23 80 00       	push   $0x80235e
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
  800405:	68 15 27 80 00       	push   $0x802715
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
  800429:	b8 57 23 80 00       	mov    $0x802357,%eax
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
  800aa4:	68 3f 26 80 00       	push   $0x80263f
  800aa9:	6a 23                	push   $0x23
  800aab:	68 5c 26 80 00       	push   $0x80265c
  800ab0:	e8 47 14 00 00       	call   801efc <_panic>

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
  800b25:	68 3f 26 80 00       	push   $0x80263f
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 5c 26 80 00       	push   $0x80265c
  800b31:	e8 c6 13 00 00       	call   801efc <_panic>

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
  800b67:	68 3f 26 80 00       	push   $0x80263f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 5c 26 80 00       	push   $0x80265c
  800b73:	e8 84 13 00 00       	call   801efc <_panic>

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
  800ba9:	68 3f 26 80 00       	push   $0x80263f
  800bae:	6a 23                	push   $0x23
  800bb0:	68 5c 26 80 00       	push   $0x80265c
  800bb5:	e8 42 13 00 00       	call   801efc <_panic>

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
  800beb:	68 3f 26 80 00       	push   $0x80263f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 5c 26 80 00       	push   $0x80265c
  800bf7:	e8 00 13 00 00       	call   801efc <_panic>

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
  800c2d:	68 3f 26 80 00       	push   $0x80263f
  800c32:	6a 23                	push   $0x23
  800c34:	68 5c 26 80 00       	push   $0x80265c
  800c39:	e8 be 12 00 00       	call   801efc <_panic>

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
  800c6f:	68 3f 26 80 00       	push   $0x80263f
  800c74:	6a 23                	push   $0x23
  800c76:	68 5c 26 80 00       	push   $0x80265c
  800c7b:	e8 7c 12 00 00       	call   801efc <_panic>

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
  800cd3:	68 3f 26 80 00       	push   $0x80263f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 5c 26 80 00       	push   $0x80265c
  800cdf:	e8 18 12 00 00       	call   801efc <_panic>

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

00800d0b <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d19:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 df                	mov    %ebx,%edi
  800d26:	89 de                	mov    %ebx,%esi
  800d28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 17                	jle    800d45 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 0f                	push   $0xf
  800d34:	68 3f 26 80 00       	push   $0x80263f
  800d39:	6a 23                	push   $0x23
  800d3b:	68 5c 26 80 00       	push   $0x80265c
  800d40:	e8 b7 11 00 00       	call   801efc <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d53:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800d5a:	75 2e                	jne    800d8a <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800d5c:	e8 5c fd ff ff       	call   800abd <sys_getenvid>
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	68 07 0e 00 00       	push   $0xe07
  800d69:	68 00 f0 bf ee       	push   $0xeebff000
  800d6e:	50                   	push   %eax
  800d6f:	e8 87 fd ff ff       	call   800afb <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800d74:	e8 44 fd ff ff       	call   800abd <sys_getenvid>
  800d79:	83 c4 08             	add    $0x8,%esp
  800d7c:	68 94 0d 80 00       	push   $0x800d94
  800d81:	50                   	push   %eax
  800d82:	e8 bf fe ff ff       	call   800c46 <sys_env_set_pgfault_upcall>
  800d87:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800d92:	c9                   	leave  
  800d93:	c3                   	ret    

00800d94 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d94:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d95:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800d9a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d9c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  800d9f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800da3:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800da7:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800daa:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800dad:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  800dae:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800db1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800db2:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800db3:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800db7:	c3                   	ret    

00800db8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc3:	c1 e8 0c             	shr    $0xc,%eax
}
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	05 00 00 00 30       	add    $0x30000000,%eax
  800dd3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dd8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dea:	89 c2                	mov    %eax,%edx
  800dec:	c1 ea 16             	shr    $0x16,%edx
  800def:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df6:	f6 c2 01             	test   $0x1,%dl
  800df9:	74 11                	je     800e0c <fd_alloc+0x2d>
  800dfb:	89 c2                	mov    %eax,%edx
  800dfd:	c1 ea 0c             	shr    $0xc,%edx
  800e00:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e07:	f6 c2 01             	test   $0x1,%dl
  800e0a:	75 09                	jne    800e15 <fd_alloc+0x36>
			*fd_store = fd;
  800e0c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e13:	eb 17                	jmp    800e2c <fd_alloc+0x4d>
  800e15:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e1a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e1f:	75 c9                	jne    800dea <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e21:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e27:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e34:	83 f8 1f             	cmp    $0x1f,%eax
  800e37:	77 36                	ja     800e6f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e39:	c1 e0 0c             	shl    $0xc,%eax
  800e3c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e41:	89 c2                	mov    %eax,%edx
  800e43:	c1 ea 16             	shr    $0x16,%edx
  800e46:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4d:	f6 c2 01             	test   $0x1,%dl
  800e50:	74 24                	je     800e76 <fd_lookup+0x48>
  800e52:	89 c2                	mov    %eax,%edx
  800e54:	c1 ea 0c             	shr    $0xc,%edx
  800e57:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5e:	f6 c2 01             	test   $0x1,%dl
  800e61:	74 1a                	je     800e7d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e66:	89 02                	mov    %eax,(%edx)
	return 0;
  800e68:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6d:	eb 13                	jmp    800e82 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e74:	eb 0c                	jmp    800e82 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e7b:	eb 05                	jmp    800e82 <fd_lookup+0x54>
  800e7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 08             	sub    $0x8,%esp
  800e8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8d:	ba e8 26 80 00       	mov    $0x8026e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e92:	eb 13                	jmp    800ea7 <dev_lookup+0x23>
  800e94:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e97:	39 08                	cmp    %ecx,(%eax)
  800e99:	75 0c                	jne    800ea7 <dev_lookup+0x23>
			*dev = devtab[i];
  800e9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea5:	eb 2e                	jmp    800ed5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ea7:	8b 02                	mov    (%edx),%eax
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	75 e7                	jne    800e94 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ead:	a1 08 40 80 00       	mov    0x804008,%eax
  800eb2:	8b 40 48             	mov    0x48(%eax),%eax
  800eb5:	83 ec 04             	sub    $0x4,%esp
  800eb8:	51                   	push   %ecx
  800eb9:	50                   	push   %eax
  800eba:	68 6c 26 80 00       	push   $0x80266c
  800ebf:	e8 af f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
  800edc:	83 ec 10             	sub    $0x10,%esp
  800edf:	8b 75 08             	mov    0x8(%ebp),%esi
  800ee2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ee5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee8:	50                   	push   %eax
  800ee9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eef:	c1 e8 0c             	shr    $0xc,%eax
  800ef2:	50                   	push   %eax
  800ef3:	e8 36 ff ff ff       	call   800e2e <fd_lookup>
  800ef8:	83 c4 08             	add    $0x8,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	78 05                	js     800f04 <fd_close+0x2d>
	    || fd != fd2)
  800eff:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f02:	74 0c                	je     800f10 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f04:	84 db                	test   %bl,%bl
  800f06:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0b:	0f 44 c2             	cmove  %edx,%eax
  800f0e:	eb 41                	jmp    800f51 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f10:	83 ec 08             	sub    $0x8,%esp
  800f13:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	ff 36                	pushl  (%esi)
  800f19:	e8 66 ff ff ff       	call   800e84 <dev_lookup>
  800f1e:	89 c3                	mov    %eax,%ebx
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	78 1a                	js     800f41 <fd_close+0x6a>
		if (dev->dev_close)
  800f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f2a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f2d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f32:	85 c0                	test   %eax,%eax
  800f34:	74 0b                	je     800f41 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f36:	83 ec 0c             	sub    $0xc,%esp
  800f39:	56                   	push   %esi
  800f3a:	ff d0                	call   *%eax
  800f3c:	89 c3                	mov    %eax,%ebx
  800f3e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f41:	83 ec 08             	sub    $0x8,%esp
  800f44:	56                   	push   %esi
  800f45:	6a 00                	push   $0x0
  800f47:	e8 34 fc ff ff       	call   800b80 <sys_page_unmap>
	return r;
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	89 d8                	mov    %ebx,%eax
}
  800f51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f61:	50                   	push   %eax
  800f62:	ff 75 08             	pushl  0x8(%ebp)
  800f65:	e8 c4 fe ff ff       	call   800e2e <fd_lookup>
  800f6a:	83 c4 08             	add    $0x8,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	78 10                	js     800f81 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	6a 01                	push   $0x1
  800f76:	ff 75 f4             	pushl  -0xc(%ebp)
  800f79:	e8 59 ff ff ff       	call   800ed7 <fd_close>
  800f7e:	83 c4 10             	add    $0x10,%esp
}
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <close_all>:

void
close_all(void)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	53                   	push   %ebx
  800f87:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f8a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	53                   	push   %ebx
  800f93:	e8 c0 ff ff ff       	call   800f58 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f98:	83 c3 01             	add    $0x1,%ebx
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	83 fb 20             	cmp    $0x20,%ebx
  800fa1:	75 ec                	jne    800f8f <close_all+0xc>
		close(i);
}
  800fa3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
  800fae:	83 ec 2c             	sub    $0x2c,%esp
  800fb1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fb4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fb7:	50                   	push   %eax
  800fb8:	ff 75 08             	pushl  0x8(%ebp)
  800fbb:	e8 6e fe ff ff       	call   800e2e <fd_lookup>
  800fc0:	83 c4 08             	add    $0x8,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	0f 88 c1 00 00 00    	js     80108c <dup+0xe4>
		return r;
	close(newfdnum);
  800fcb:	83 ec 0c             	sub    $0xc,%esp
  800fce:	56                   	push   %esi
  800fcf:	e8 84 ff ff ff       	call   800f58 <close>

	newfd = INDEX2FD(newfdnum);
  800fd4:	89 f3                	mov    %esi,%ebx
  800fd6:	c1 e3 0c             	shl    $0xc,%ebx
  800fd9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fdf:	83 c4 04             	add    $0x4,%esp
  800fe2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe5:	e8 de fd ff ff       	call   800dc8 <fd2data>
  800fea:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fec:	89 1c 24             	mov    %ebx,(%esp)
  800fef:	e8 d4 fd ff ff       	call   800dc8 <fd2data>
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800ffa:	89 f8                	mov    %edi,%eax
  800ffc:	c1 e8 16             	shr    $0x16,%eax
  800fff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801006:	a8 01                	test   $0x1,%al
  801008:	74 37                	je     801041 <dup+0x99>
  80100a:	89 f8                	mov    %edi,%eax
  80100c:	c1 e8 0c             	shr    $0xc,%eax
  80100f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801016:	f6 c2 01             	test   $0x1,%dl
  801019:	74 26                	je     801041 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80101b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	25 07 0e 00 00       	and    $0xe07,%eax
  80102a:	50                   	push   %eax
  80102b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80102e:	6a 00                	push   $0x0
  801030:	57                   	push   %edi
  801031:	6a 00                	push   $0x0
  801033:	e8 06 fb ff ff       	call   800b3e <sys_page_map>
  801038:	89 c7                	mov    %eax,%edi
  80103a:	83 c4 20             	add    $0x20,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 2e                	js     80106f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801041:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801044:	89 d0                	mov    %edx,%eax
  801046:	c1 e8 0c             	shr    $0xc,%eax
  801049:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	25 07 0e 00 00       	and    $0xe07,%eax
  801058:	50                   	push   %eax
  801059:	53                   	push   %ebx
  80105a:	6a 00                	push   $0x0
  80105c:	52                   	push   %edx
  80105d:	6a 00                	push   $0x0
  80105f:	e8 da fa ff ff       	call   800b3e <sys_page_map>
  801064:	89 c7                	mov    %eax,%edi
  801066:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801069:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80106b:	85 ff                	test   %edi,%edi
  80106d:	79 1d                	jns    80108c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	53                   	push   %ebx
  801073:	6a 00                	push   $0x0
  801075:	e8 06 fb ff ff       	call   800b80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80107a:	83 c4 08             	add    $0x8,%esp
  80107d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801080:	6a 00                	push   $0x0
  801082:	e8 f9 fa ff ff       	call   800b80 <sys_page_unmap>
	return r;
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	89 f8                	mov    %edi,%eax
}
  80108c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	53                   	push   %ebx
  801098:	83 ec 14             	sub    $0x14,%esp
  80109b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80109e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a1:	50                   	push   %eax
  8010a2:	53                   	push   %ebx
  8010a3:	e8 86 fd ff ff       	call   800e2e <fd_lookup>
  8010a8:	83 c4 08             	add    $0x8,%esp
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	78 6d                	js     80111e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b1:	83 ec 08             	sub    $0x8,%esp
  8010b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b7:	50                   	push   %eax
  8010b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010bb:	ff 30                	pushl  (%eax)
  8010bd:	e8 c2 fd ff ff       	call   800e84 <dev_lookup>
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	78 4c                	js     801115 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010cc:	8b 42 08             	mov    0x8(%edx),%eax
  8010cf:	83 e0 03             	and    $0x3,%eax
  8010d2:	83 f8 01             	cmp    $0x1,%eax
  8010d5:	75 21                	jne    8010f8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8010dc:	8b 40 48             	mov    0x48(%eax),%eax
  8010df:	83 ec 04             	sub    $0x4,%esp
  8010e2:	53                   	push   %ebx
  8010e3:	50                   	push   %eax
  8010e4:	68 ad 26 80 00       	push   $0x8026ad
  8010e9:	e8 85 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010f6:	eb 26                	jmp    80111e <read+0x8a>
	}
	if (!dev->dev_read)
  8010f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010fb:	8b 40 08             	mov    0x8(%eax),%eax
  8010fe:	85 c0                	test   %eax,%eax
  801100:	74 17                	je     801119 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801102:	83 ec 04             	sub    $0x4,%esp
  801105:	ff 75 10             	pushl  0x10(%ebp)
  801108:	ff 75 0c             	pushl  0xc(%ebp)
  80110b:	52                   	push   %edx
  80110c:	ff d0                	call   *%eax
  80110e:	89 c2                	mov    %eax,%edx
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	eb 09                	jmp    80111e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801115:	89 c2                	mov    %eax,%edx
  801117:	eb 05                	jmp    80111e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801119:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80111e:	89 d0                	mov    %edx,%eax
  801120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801123:	c9                   	leave  
  801124:	c3                   	ret    

00801125 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	57                   	push   %edi
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801131:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801134:	bb 00 00 00 00       	mov    $0x0,%ebx
  801139:	eb 21                	jmp    80115c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80113b:	83 ec 04             	sub    $0x4,%esp
  80113e:	89 f0                	mov    %esi,%eax
  801140:	29 d8                	sub    %ebx,%eax
  801142:	50                   	push   %eax
  801143:	89 d8                	mov    %ebx,%eax
  801145:	03 45 0c             	add    0xc(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	57                   	push   %edi
  80114a:	e8 45 ff ff ff       	call   801094 <read>
		if (m < 0)
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 10                	js     801166 <readn+0x41>
			return m;
		if (m == 0)
  801156:	85 c0                	test   %eax,%eax
  801158:	74 0a                	je     801164 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80115a:	01 c3                	add    %eax,%ebx
  80115c:	39 f3                	cmp    %esi,%ebx
  80115e:	72 db                	jb     80113b <readn+0x16>
  801160:	89 d8                	mov    %ebx,%eax
  801162:	eb 02                	jmp    801166 <readn+0x41>
  801164:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	53                   	push   %ebx
  801172:	83 ec 14             	sub    $0x14,%esp
  801175:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801178:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117b:	50                   	push   %eax
  80117c:	53                   	push   %ebx
  80117d:	e8 ac fc ff ff       	call   800e2e <fd_lookup>
  801182:	83 c4 08             	add    $0x8,%esp
  801185:	89 c2                	mov    %eax,%edx
  801187:	85 c0                	test   %eax,%eax
  801189:	78 68                	js     8011f3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118b:	83 ec 08             	sub    $0x8,%esp
  80118e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801191:	50                   	push   %eax
  801192:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801195:	ff 30                	pushl  (%eax)
  801197:	e8 e8 fc ff ff       	call   800e84 <dev_lookup>
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 47                	js     8011ea <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011aa:	75 21                	jne    8011cd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ac:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b1:	8b 40 48             	mov    0x48(%eax),%eax
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	53                   	push   %ebx
  8011b8:	50                   	push   %eax
  8011b9:	68 c9 26 80 00       	push   $0x8026c9
  8011be:	e8 b0 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011cb:	eb 26                	jmp    8011f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8011d3:	85 d2                	test   %edx,%edx
  8011d5:	74 17                	je     8011ee <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	ff 75 10             	pushl  0x10(%ebp)
  8011dd:	ff 75 0c             	pushl  0xc(%ebp)
  8011e0:	50                   	push   %eax
  8011e1:	ff d2                	call   *%edx
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	eb 09                	jmp    8011f3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	eb 05                	jmp    8011f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011f3:	89 d0                	mov    %edx,%eax
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <seek>:

int
seek(int fdnum, off_t offset)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801200:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801203:	50                   	push   %eax
  801204:	ff 75 08             	pushl  0x8(%ebp)
  801207:	e8 22 fc ff ff       	call   800e2e <fd_lookup>
  80120c:	83 c4 08             	add    $0x8,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 0e                	js     801221 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801213:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801216:	8b 55 0c             	mov    0xc(%ebp),%edx
  801219:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80121c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801221:	c9                   	leave  
  801222:	c3                   	ret    

00801223 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	53                   	push   %ebx
  801227:	83 ec 14             	sub    $0x14,%esp
  80122a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	53                   	push   %ebx
  801232:	e8 f7 fb ff ff       	call   800e2e <fd_lookup>
  801237:	83 c4 08             	add    $0x8,%esp
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 65                	js     8012a5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124a:	ff 30                	pushl  (%eax)
  80124c:	e8 33 fc ff ff       	call   800e84 <dev_lookup>
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 44                	js     80129c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801258:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80125f:	75 21                	jne    801282 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801261:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801266:	8b 40 48             	mov    0x48(%eax),%eax
  801269:	83 ec 04             	sub    $0x4,%esp
  80126c:	53                   	push   %ebx
  80126d:	50                   	push   %eax
  80126e:	68 8c 26 80 00       	push   $0x80268c
  801273:	e8 fb ee ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801280:	eb 23                	jmp    8012a5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801282:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801285:	8b 52 18             	mov    0x18(%edx),%edx
  801288:	85 d2                	test   %edx,%edx
  80128a:	74 14                	je     8012a0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80128c:	83 ec 08             	sub    $0x8,%esp
  80128f:	ff 75 0c             	pushl  0xc(%ebp)
  801292:	50                   	push   %eax
  801293:	ff d2                	call   *%edx
  801295:	89 c2                	mov    %eax,%edx
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	eb 09                	jmp    8012a5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129c:	89 c2                	mov    %eax,%edx
  80129e:	eb 05                	jmp    8012a5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012a5:	89 d0                	mov    %edx,%eax
  8012a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012aa:	c9                   	leave  
  8012ab:	c3                   	ret    

008012ac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	53                   	push   %ebx
  8012b0:	83 ec 14             	sub    $0x14,%esp
  8012b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b9:	50                   	push   %eax
  8012ba:	ff 75 08             	pushl  0x8(%ebp)
  8012bd:	e8 6c fb ff ff       	call   800e2e <fd_lookup>
  8012c2:	83 c4 08             	add    $0x8,%esp
  8012c5:	89 c2                	mov    %eax,%edx
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	78 58                	js     801323 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cb:	83 ec 08             	sub    $0x8,%esp
  8012ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d5:	ff 30                	pushl  (%eax)
  8012d7:	e8 a8 fb ff ff       	call   800e84 <dev_lookup>
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 37                	js     80131a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ea:	74 32                	je     80131e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012f6:	00 00 00 
	stat->st_isdir = 0;
  8012f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801300:	00 00 00 
	stat->st_dev = dev;
  801303:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	53                   	push   %ebx
  80130d:	ff 75 f0             	pushl  -0x10(%ebp)
  801310:	ff 50 14             	call   *0x14(%eax)
  801313:	89 c2                	mov    %eax,%edx
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	eb 09                	jmp    801323 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131a:	89 c2                	mov    %eax,%edx
  80131c:	eb 05                	jmp    801323 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80131e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801323:	89 d0                	mov    %edx,%eax
  801325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801328:	c9                   	leave  
  801329:	c3                   	ret    

0080132a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	56                   	push   %esi
  80132e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	6a 00                	push   $0x0
  801334:	ff 75 08             	pushl  0x8(%ebp)
  801337:	e8 d6 01 00 00       	call   801512 <open>
  80133c:	89 c3                	mov    %eax,%ebx
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	78 1b                	js     801360 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	ff 75 0c             	pushl  0xc(%ebp)
  80134b:	50                   	push   %eax
  80134c:	e8 5b ff ff ff       	call   8012ac <fstat>
  801351:	89 c6                	mov    %eax,%esi
	close(fd);
  801353:	89 1c 24             	mov    %ebx,(%esp)
  801356:	e8 fd fb ff ff       	call   800f58 <close>
	return r;
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	89 f0                	mov    %esi,%eax
}
  801360:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801363:	5b                   	pop    %ebx
  801364:	5e                   	pop    %esi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	56                   	push   %esi
  80136b:	53                   	push   %ebx
  80136c:	89 c6                	mov    %eax,%esi
  80136e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801370:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801377:	75 12                	jne    80138b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801379:	83 ec 0c             	sub    $0xc,%esp
  80137c:	6a 01                	push   $0x1
  80137e:	e8 7a 0c 00 00       	call   801ffd <ipc_find_env>
  801383:	a3 00 40 80 00       	mov    %eax,0x804000
  801388:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80138b:	6a 07                	push   $0x7
  80138d:	68 00 50 80 00       	push   $0x805000
  801392:	56                   	push   %esi
  801393:	ff 35 00 40 80 00    	pushl  0x804000
  801399:	e8 0b 0c 00 00       	call   801fa9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80139e:	83 c4 0c             	add    $0xc,%esp
  8013a1:	6a 00                	push   $0x0
  8013a3:	53                   	push   %ebx
  8013a4:	6a 00                	push   $0x0
  8013a6:	e8 97 0b 00 00       	call   801f42 <ipc_recv>
}
  8013ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8013d5:	e8 8d ff ff ff       	call   801367 <fsipc>
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8013f7:	e8 6b ff ff ff       	call   801367 <fsipc>
}
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	53                   	push   %ebx
  801402:	83 ec 04             	sub    $0x4,%esp
  801405:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801408:	8b 45 08             	mov    0x8(%ebp),%eax
  80140b:	8b 40 0c             	mov    0xc(%eax),%eax
  80140e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801413:	ba 00 00 00 00       	mov    $0x0,%edx
  801418:	b8 05 00 00 00       	mov    $0x5,%eax
  80141d:	e8 45 ff ff ff       	call   801367 <fsipc>
  801422:	85 c0                	test   %eax,%eax
  801424:	78 2c                	js     801452 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	68 00 50 80 00       	push   $0x805000
  80142e:	53                   	push   %ebx
  80142f:	e8 c4 f2 ff ff       	call   8006f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801434:	a1 80 50 80 00       	mov    0x805080,%eax
  801439:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80143f:	a1 84 50 80 00       	mov    0x805084,%eax
  801444:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801452:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 0c             	sub    $0xc,%esp
  80145d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801460:	8b 55 08             	mov    0x8(%ebp),%edx
  801463:	8b 52 0c             	mov    0xc(%edx),%edx
  801466:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80146c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801471:	50                   	push   %eax
  801472:	ff 75 0c             	pushl  0xc(%ebp)
  801475:	68 08 50 80 00       	push   $0x805008
  80147a:	e8 0b f4 ff ff       	call   80088a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80147f:	ba 00 00 00 00       	mov    $0x0,%edx
  801484:	b8 04 00 00 00       	mov    $0x4,%eax
  801489:	e8 d9 fe ff ff       	call   801367 <fsipc>

}
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	56                   	push   %esi
  801494:	53                   	push   %ebx
  801495:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801498:	8b 45 08             	mov    0x8(%ebp),%eax
  80149b:	8b 40 0c             	mov    0xc(%eax),%eax
  80149e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b3:	e8 af fe ff ff       	call   801367 <fsipc>
  8014b8:	89 c3                	mov    %eax,%ebx
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 4b                	js     801509 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014be:	39 c6                	cmp    %eax,%esi
  8014c0:	73 16                	jae    8014d8 <devfile_read+0x48>
  8014c2:	68 fc 26 80 00       	push   $0x8026fc
  8014c7:	68 03 27 80 00       	push   $0x802703
  8014cc:	6a 7c                	push   $0x7c
  8014ce:	68 18 27 80 00       	push   $0x802718
  8014d3:	e8 24 0a 00 00       	call   801efc <_panic>
	assert(r <= PGSIZE);
  8014d8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014dd:	7e 16                	jle    8014f5 <devfile_read+0x65>
  8014df:	68 23 27 80 00       	push   $0x802723
  8014e4:	68 03 27 80 00       	push   $0x802703
  8014e9:	6a 7d                	push   $0x7d
  8014eb:	68 18 27 80 00       	push   $0x802718
  8014f0:	e8 07 0a 00 00       	call   801efc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014f5:	83 ec 04             	sub    $0x4,%esp
  8014f8:	50                   	push   %eax
  8014f9:	68 00 50 80 00       	push   $0x805000
  8014fe:	ff 75 0c             	pushl  0xc(%ebp)
  801501:	e8 84 f3 ff ff       	call   80088a <memmove>
	return r;
  801506:	83 c4 10             	add    $0x10,%esp
}
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150e:	5b                   	pop    %ebx
  80150f:	5e                   	pop    %esi
  801510:	5d                   	pop    %ebp
  801511:	c3                   	ret    

00801512 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	53                   	push   %ebx
  801516:	83 ec 20             	sub    $0x20,%esp
  801519:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80151c:	53                   	push   %ebx
  80151d:	e8 9d f1 ff ff       	call   8006bf <strlen>
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80152a:	7f 67                	jg     801593 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80152c:	83 ec 0c             	sub    $0xc,%esp
  80152f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	e8 a7 f8 ff ff       	call   800ddf <fd_alloc>
  801538:	83 c4 10             	add    $0x10,%esp
		return r;
  80153b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153d:	85 c0                	test   %eax,%eax
  80153f:	78 57                	js     801598 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801541:	83 ec 08             	sub    $0x8,%esp
  801544:	53                   	push   %ebx
  801545:	68 00 50 80 00       	push   $0x805000
  80154a:	e8 a9 f1 ff ff       	call   8006f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80154f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801552:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801557:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155a:	b8 01 00 00 00       	mov    $0x1,%eax
  80155f:	e8 03 fe ff ff       	call   801367 <fsipc>
  801564:	89 c3                	mov    %eax,%ebx
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	79 14                	jns    801581 <open+0x6f>
		fd_close(fd, 0);
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	6a 00                	push   $0x0
  801572:	ff 75 f4             	pushl  -0xc(%ebp)
  801575:	e8 5d f9 ff ff       	call   800ed7 <fd_close>
		return r;
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	89 da                	mov    %ebx,%edx
  80157f:	eb 17                	jmp    801598 <open+0x86>
	}

	return fd2num(fd);
  801581:	83 ec 0c             	sub    $0xc,%esp
  801584:	ff 75 f4             	pushl  -0xc(%ebp)
  801587:	e8 2c f8 ff ff       	call   800db8 <fd2num>
  80158c:	89 c2                	mov    %eax,%edx
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	eb 05                	jmp    801598 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801593:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801598:	89 d0                	mov    %edx,%eax
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8015af:	e8 b3 fd ff ff       	call   801367 <fsipc>
}
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015bc:	68 2f 27 80 00       	push   $0x80272f
  8015c1:	ff 75 0c             	pushl  0xc(%ebp)
  8015c4:	e8 2f f1 ff ff       	call   8006f8 <strcpy>
	return 0;
}
  8015c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 10             	sub    $0x10,%esp
  8015d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015da:	53                   	push   %ebx
  8015db:	e8 56 0a 00 00       	call   802036 <pageref>
  8015e0:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015e3:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015e8:	83 f8 01             	cmp    $0x1,%eax
  8015eb:	75 10                	jne    8015fd <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	ff 73 0c             	pushl  0xc(%ebx)
  8015f3:	e8 c0 02 00 00       	call   8018b8 <nsipc_close>
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015fd:	89 d0                	mov    %edx,%eax
  8015ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80160a:	6a 00                	push   $0x0
  80160c:	ff 75 10             	pushl  0x10(%ebp)
  80160f:	ff 75 0c             	pushl  0xc(%ebp)
  801612:	8b 45 08             	mov    0x8(%ebp),%eax
  801615:	ff 70 0c             	pushl  0xc(%eax)
  801618:	e8 78 03 00 00       	call   801995 <nsipc_send>
}
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801625:	6a 00                	push   $0x0
  801627:	ff 75 10             	pushl  0x10(%ebp)
  80162a:	ff 75 0c             	pushl  0xc(%ebp)
  80162d:	8b 45 08             	mov    0x8(%ebp),%eax
  801630:	ff 70 0c             	pushl  0xc(%eax)
  801633:	e8 f1 02 00 00       	call   801929 <nsipc_recv>
}
  801638:	c9                   	leave  
  801639:	c3                   	ret    

0080163a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801640:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801643:	52                   	push   %edx
  801644:	50                   	push   %eax
  801645:	e8 e4 f7 ff ff       	call   800e2e <fd_lookup>
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 17                	js     801668 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801651:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801654:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80165a:	39 08                	cmp    %ecx,(%eax)
  80165c:	75 05                	jne    801663 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80165e:	8b 40 0c             	mov    0xc(%eax),%eax
  801661:	eb 05                	jmp    801668 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801663:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	56                   	push   %esi
  80166e:	53                   	push   %ebx
  80166f:	83 ec 1c             	sub    $0x1c,%esp
  801672:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801674:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	e8 62 f7 ff ff       	call   800ddf <fd_alloc>
  80167d:	89 c3                	mov    %eax,%ebx
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	85 c0                	test   %eax,%eax
  801684:	78 1b                	js     8016a1 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801686:	83 ec 04             	sub    $0x4,%esp
  801689:	68 07 04 00 00       	push   $0x407
  80168e:	ff 75 f4             	pushl  -0xc(%ebp)
  801691:	6a 00                	push   $0x0
  801693:	e8 63 f4 ff ff       	call   800afb <sys_page_alloc>
  801698:	89 c3                	mov    %eax,%ebx
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	79 10                	jns    8016b1 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016a1:	83 ec 0c             	sub    $0xc,%esp
  8016a4:	56                   	push   %esi
  8016a5:	e8 0e 02 00 00       	call   8018b8 <nsipc_close>
		return r;
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	89 d8                	mov    %ebx,%eax
  8016af:	eb 24                	jmp    8016d5 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016b1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ba:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016c6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016c9:	83 ec 0c             	sub    $0xc,%esp
  8016cc:	50                   	push   %eax
  8016cd:	e8 e6 f6 ff ff       	call   800db8 <fd2num>
  8016d2:	83 c4 10             	add    $0x10,%esp
}
  8016d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d8:	5b                   	pop    %ebx
  8016d9:	5e                   	pop    %esi
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	e8 50 ff ff ff       	call   80163a <fd2sockid>
		return r;
  8016ea:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 1f                	js     80170f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016f0:	83 ec 04             	sub    $0x4,%esp
  8016f3:	ff 75 10             	pushl  0x10(%ebp)
  8016f6:	ff 75 0c             	pushl  0xc(%ebp)
  8016f9:	50                   	push   %eax
  8016fa:	e8 12 01 00 00       	call   801811 <nsipc_accept>
  8016ff:	83 c4 10             	add    $0x10,%esp
		return r;
  801702:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801704:	85 c0                	test   %eax,%eax
  801706:	78 07                	js     80170f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801708:	e8 5d ff ff ff       	call   80166a <alloc_sockfd>
  80170d:	89 c1                	mov    %eax,%ecx
}
  80170f:	89 c8                	mov    %ecx,%eax
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	e8 19 ff ff ff       	call   80163a <fd2sockid>
  801721:	85 c0                	test   %eax,%eax
  801723:	78 12                	js     801737 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801725:	83 ec 04             	sub    $0x4,%esp
  801728:	ff 75 10             	pushl  0x10(%ebp)
  80172b:	ff 75 0c             	pushl  0xc(%ebp)
  80172e:	50                   	push   %eax
  80172f:	e8 2d 01 00 00       	call   801861 <nsipc_bind>
  801734:	83 c4 10             	add    $0x10,%esp
}
  801737:	c9                   	leave  
  801738:	c3                   	ret    

00801739 <shutdown>:

int
shutdown(int s, int how)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	e8 f3 fe ff ff       	call   80163a <fd2sockid>
  801747:	85 c0                	test   %eax,%eax
  801749:	78 0f                	js     80175a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	ff 75 0c             	pushl  0xc(%ebp)
  801751:	50                   	push   %eax
  801752:	e8 3f 01 00 00       	call   801896 <nsipc_shutdown>
  801757:	83 c4 10             	add    $0x10,%esp
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	e8 d0 fe ff ff       	call   80163a <fd2sockid>
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 12                	js     801780 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80176e:	83 ec 04             	sub    $0x4,%esp
  801771:	ff 75 10             	pushl  0x10(%ebp)
  801774:	ff 75 0c             	pushl  0xc(%ebp)
  801777:	50                   	push   %eax
  801778:	e8 55 01 00 00       	call   8018d2 <nsipc_connect>
  80177d:	83 c4 10             	add    $0x10,%esp
}
  801780:	c9                   	leave  
  801781:	c3                   	ret    

00801782 <listen>:

int
listen(int s, int backlog)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	e8 aa fe ff ff       	call   80163a <fd2sockid>
  801790:	85 c0                	test   %eax,%eax
  801792:	78 0f                	js     8017a3 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801794:	83 ec 08             	sub    $0x8,%esp
  801797:	ff 75 0c             	pushl  0xc(%ebp)
  80179a:	50                   	push   %eax
  80179b:	e8 67 01 00 00       	call   801907 <nsipc_listen>
  8017a0:	83 c4 10             	add    $0x10,%esp
}
  8017a3:	c9                   	leave  
  8017a4:	c3                   	ret    

008017a5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017ab:	ff 75 10             	pushl  0x10(%ebp)
  8017ae:	ff 75 0c             	pushl  0xc(%ebp)
  8017b1:	ff 75 08             	pushl  0x8(%ebp)
  8017b4:	e8 3a 02 00 00       	call   8019f3 <nsipc_socket>
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 05                	js     8017c5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017c0:	e8 a5 fe ff ff       	call   80166a <alloc_sockfd>
}
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 04             	sub    $0x4,%esp
  8017ce:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017d0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017d7:	75 12                	jne    8017eb <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	6a 02                	push   $0x2
  8017de:	e8 1a 08 00 00       	call   801ffd <ipc_find_env>
  8017e3:	a3 04 40 80 00       	mov    %eax,0x804004
  8017e8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017eb:	6a 07                	push   $0x7
  8017ed:	68 00 60 80 00       	push   $0x806000
  8017f2:	53                   	push   %ebx
  8017f3:	ff 35 04 40 80 00    	pushl  0x804004
  8017f9:	e8 ab 07 00 00       	call   801fa9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017fe:	83 c4 0c             	add    $0xc,%esp
  801801:	6a 00                	push   $0x0
  801803:	6a 00                	push   $0x0
  801805:	6a 00                	push   $0x0
  801807:	e8 36 07 00 00       	call   801f42 <ipc_recv>
}
  80180c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	56                   	push   %esi
  801815:	53                   	push   %ebx
  801816:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801821:	8b 06                	mov    (%esi),%eax
  801823:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801828:	b8 01 00 00 00       	mov    $0x1,%eax
  80182d:	e8 95 ff ff ff       	call   8017c7 <nsipc>
  801832:	89 c3                	mov    %eax,%ebx
  801834:	85 c0                	test   %eax,%eax
  801836:	78 20                	js     801858 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801838:	83 ec 04             	sub    $0x4,%esp
  80183b:	ff 35 10 60 80 00    	pushl  0x806010
  801841:	68 00 60 80 00       	push   $0x806000
  801846:	ff 75 0c             	pushl  0xc(%ebp)
  801849:	e8 3c f0 ff ff       	call   80088a <memmove>
		*addrlen = ret->ret_addrlen;
  80184e:	a1 10 60 80 00       	mov    0x806010,%eax
  801853:	89 06                	mov    %eax,(%esi)
  801855:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801858:	89 d8                	mov    %ebx,%eax
  80185a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185d:	5b                   	pop    %ebx
  80185e:	5e                   	pop    %esi
  80185f:	5d                   	pop    %ebp
  801860:	c3                   	ret    

00801861 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	53                   	push   %ebx
  801865:	83 ec 08             	sub    $0x8,%esp
  801868:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801873:	53                   	push   %ebx
  801874:	ff 75 0c             	pushl  0xc(%ebp)
  801877:	68 04 60 80 00       	push   $0x806004
  80187c:	e8 09 f0 ff ff       	call   80088a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801881:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801887:	b8 02 00 00 00       	mov    $0x2,%eax
  80188c:	e8 36 ff ff ff       	call   8017c7 <nsipc>
}
  801891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018ac:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b1:	e8 11 ff ff ff       	call   8017c7 <nsipc>
}
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <nsipc_close>:

int
nsipc_close(int s)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c1:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018c6:	b8 04 00 00 00       	mov    $0x4,%eax
  8018cb:	e8 f7 fe ff ff       	call   8017c7 <nsipc>
}
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018df:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018e4:	53                   	push   %ebx
  8018e5:	ff 75 0c             	pushl  0xc(%ebp)
  8018e8:	68 04 60 80 00       	push   $0x806004
  8018ed:	e8 98 ef ff ff       	call   80088a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018f2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018fd:	e8 c5 fe ff ff       	call   8017c7 <nsipc>
}
  801902:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801915:	8b 45 0c             	mov    0xc(%ebp),%eax
  801918:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80191d:	b8 06 00 00 00       	mov    $0x6,%eax
  801922:	e8 a0 fe ff ff       	call   8017c7 <nsipc>
}
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	56                   	push   %esi
  80192d:	53                   	push   %ebx
  80192e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801931:	8b 45 08             	mov    0x8(%ebp),%eax
  801934:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801939:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80193f:	8b 45 14             	mov    0x14(%ebp),%eax
  801942:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801947:	b8 07 00 00 00       	mov    $0x7,%eax
  80194c:	e8 76 fe ff ff       	call   8017c7 <nsipc>
  801951:	89 c3                	mov    %eax,%ebx
  801953:	85 c0                	test   %eax,%eax
  801955:	78 35                	js     80198c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801957:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80195c:	7f 04                	jg     801962 <nsipc_recv+0x39>
  80195e:	39 c6                	cmp    %eax,%esi
  801960:	7d 16                	jge    801978 <nsipc_recv+0x4f>
  801962:	68 3b 27 80 00       	push   $0x80273b
  801967:	68 03 27 80 00       	push   $0x802703
  80196c:	6a 62                	push   $0x62
  80196e:	68 50 27 80 00       	push   $0x802750
  801973:	e8 84 05 00 00       	call   801efc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801978:	83 ec 04             	sub    $0x4,%esp
  80197b:	50                   	push   %eax
  80197c:	68 00 60 80 00       	push   $0x806000
  801981:	ff 75 0c             	pushl  0xc(%ebp)
  801984:	e8 01 ef ff ff       	call   80088a <memmove>
  801989:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80198c:	89 d8                	mov    %ebx,%eax
  80198e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801991:	5b                   	pop    %ebx
  801992:	5e                   	pop    %esi
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	53                   	push   %ebx
  801999:	83 ec 04             	sub    $0x4,%esp
  80199c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80199f:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a2:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019a7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019ad:	7e 16                	jle    8019c5 <nsipc_send+0x30>
  8019af:	68 5c 27 80 00       	push   $0x80275c
  8019b4:	68 03 27 80 00       	push   $0x802703
  8019b9:	6a 6d                	push   $0x6d
  8019bb:	68 50 27 80 00       	push   $0x802750
  8019c0:	e8 37 05 00 00       	call   801efc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019c5:	83 ec 04             	sub    $0x4,%esp
  8019c8:	53                   	push   %ebx
  8019c9:	ff 75 0c             	pushl  0xc(%ebp)
  8019cc:	68 0c 60 80 00       	push   $0x80600c
  8019d1:	e8 b4 ee ff ff       	call   80088a <memmove>
	nsipcbuf.send.req_size = size;
  8019d6:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019df:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e9:	e8 d9 fd ff ff       	call   8017c7 <nsipc>
}
  8019ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a04:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a09:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a11:	b8 09 00 00 00       	mov    $0x9,%eax
  801a16:	e8 ac fd ff ff       	call   8017c7 <nsipc>
}
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a25:	83 ec 0c             	sub    $0xc,%esp
  801a28:	ff 75 08             	pushl  0x8(%ebp)
  801a2b:	e8 98 f3 ff ff       	call   800dc8 <fd2data>
  801a30:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a32:	83 c4 08             	add    $0x8,%esp
  801a35:	68 68 27 80 00       	push   $0x802768
  801a3a:	53                   	push   %ebx
  801a3b:	e8 b8 ec ff ff       	call   8006f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a40:	8b 46 04             	mov    0x4(%esi),%eax
  801a43:	2b 06                	sub    (%esi),%eax
  801a45:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a4b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a52:	00 00 00 
	stat->st_dev = &devpipe;
  801a55:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a5c:	30 80 00 
	return 0;
}
  801a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a75:	53                   	push   %ebx
  801a76:	6a 00                	push   $0x0
  801a78:	e8 03 f1 ff ff       	call   800b80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a7d:	89 1c 24             	mov    %ebx,(%esp)
  801a80:	e8 43 f3 ff ff       	call   800dc8 <fd2data>
  801a85:	83 c4 08             	add    $0x8,%esp
  801a88:	50                   	push   %eax
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 f0 f0 ff ff       	call   800b80 <sys_page_unmap>
}
  801a90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a93:	c9                   	leave  
  801a94:	c3                   	ret    

00801a95 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	57                   	push   %edi
  801a99:	56                   	push   %esi
  801a9a:	53                   	push   %ebx
  801a9b:	83 ec 1c             	sub    $0x1c,%esp
  801a9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa3:	a1 08 40 80 00       	mov    0x804008,%eax
  801aa8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab1:	e8 80 05 00 00       	call   802036 <pageref>
  801ab6:	89 c3                	mov    %eax,%ebx
  801ab8:	89 3c 24             	mov    %edi,(%esp)
  801abb:	e8 76 05 00 00       	call   802036 <pageref>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	39 c3                	cmp    %eax,%ebx
  801ac5:	0f 94 c1             	sete   %cl
  801ac8:	0f b6 c9             	movzbl %cl,%ecx
  801acb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ace:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ad4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ad7:	39 ce                	cmp    %ecx,%esi
  801ad9:	74 1b                	je     801af6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801adb:	39 c3                	cmp    %eax,%ebx
  801add:	75 c4                	jne    801aa3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801adf:	8b 42 58             	mov    0x58(%edx),%eax
  801ae2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae5:	50                   	push   %eax
  801ae6:	56                   	push   %esi
  801ae7:	68 6f 27 80 00       	push   $0x80276f
  801aec:	e8 82 e6 ff ff       	call   800173 <cprintf>
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	eb ad                	jmp    801aa3 <_pipeisclosed+0xe>
	}
}
  801af6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afc:	5b                   	pop    %ebx
  801afd:	5e                   	pop    %esi
  801afe:	5f                   	pop    %edi
  801aff:	5d                   	pop    %ebp
  801b00:	c3                   	ret    

00801b01 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	57                   	push   %edi
  801b05:	56                   	push   %esi
  801b06:	53                   	push   %ebx
  801b07:	83 ec 28             	sub    $0x28,%esp
  801b0a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b0d:	56                   	push   %esi
  801b0e:	e8 b5 f2 ff ff       	call   800dc8 <fd2data>
  801b13:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	bf 00 00 00 00       	mov    $0x0,%edi
  801b1d:	eb 4b                	jmp    801b6a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b1f:	89 da                	mov    %ebx,%edx
  801b21:	89 f0                	mov    %esi,%eax
  801b23:	e8 6d ff ff ff       	call   801a95 <_pipeisclosed>
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	75 48                	jne    801b74 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b2c:	e8 ab ef ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b31:	8b 43 04             	mov    0x4(%ebx),%eax
  801b34:	8b 0b                	mov    (%ebx),%ecx
  801b36:	8d 51 20             	lea    0x20(%ecx),%edx
  801b39:	39 d0                	cmp    %edx,%eax
  801b3b:	73 e2                	jae    801b1f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b40:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b44:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b47:	89 c2                	mov    %eax,%edx
  801b49:	c1 fa 1f             	sar    $0x1f,%edx
  801b4c:	89 d1                	mov    %edx,%ecx
  801b4e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b51:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b54:	83 e2 1f             	and    $0x1f,%edx
  801b57:	29 ca                	sub    %ecx,%edx
  801b59:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b5d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b61:	83 c0 01             	add    $0x1,%eax
  801b64:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b67:	83 c7 01             	add    $0x1,%edi
  801b6a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b6d:	75 c2                	jne    801b31 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b6f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b72:	eb 05                	jmp    801b79 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b74:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7c:	5b                   	pop    %ebx
  801b7d:	5e                   	pop    %esi
  801b7e:	5f                   	pop    %edi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	57                   	push   %edi
  801b85:	56                   	push   %esi
  801b86:	53                   	push   %ebx
  801b87:	83 ec 18             	sub    $0x18,%esp
  801b8a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b8d:	57                   	push   %edi
  801b8e:	e8 35 f2 ff ff       	call   800dc8 <fd2data>
  801b93:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b9d:	eb 3d                	jmp    801bdc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b9f:	85 db                	test   %ebx,%ebx
  801ba1:	74 04                	je     801ba7 <devpipe_read+0x26>
				return i;
  801ba3:	89 d8                	mov    %ebx,%eax
  801ba5:	eb 44                	jmp    801beb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ba7:	89 f2                	mov    %esi,%edx
  801ba9:	89 f8                	mov    %edi,%eax
  801bab:	e8 e5 fe ff ff       	call   801a95 <_pipeisclosed>
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	75 32                	jne    801be6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bb4:	e8 23 ef ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bb9:	8b 06                	mov    (%esi),%eax
  801bbb:	3b 46 04             	cmp    0x4(%esi),%eax
  801bbe:	74 df                	je     801b9f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc0:	99                   	cltd   
  801bc1:	c1 ea 1b             	shr    $0x1b,%edx
  801bc4:	01 d0                	add    %edx,%eax
  801bc6:	83 e0 1f             	and    $0x1f,%eax
  801bc9:	29 d0                	sub    %edx,%eax
  801bcb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bd6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd9:	83 c3 01             	add    $0x1,%ebx
  801bdc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bdf:	75 d8                	jne    801bb9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801be1:	8b 45 10             	mov    0x10(%ebp),%eax
  801be4:	eb 05                	jmp    801beb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5f                   	pop    %edi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
  801bf8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfe:	50                   	push   %eax
  801bff:	e8 db f1 ff ff       	call   800ddf <fd_alloc>
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	89 c2                	mov    %eax,%edx
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	0f 88 2c 01 00 00    	js     801d3d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c11:	83 ec 04             	sub    $0x4,%esp
  801c14:	68 07 04 00 00       	push   $0x407
  801c19:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1c:	6a 00                	push   $0x0
  801c1e:	e8 d8 ee ff ff       	call   800afb <sys_page_alloc>
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	89 c2                	mov    %eax,%edx
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	0f 88 0d 01 00 00    	js     801d3d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c30:	83 ec 0c             	sub    $0xc,%esp
  801c33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c36:	50                   	push   %eax
  801c37:	e8 a3 f1 ff ff       	call   800ddf <fd_alloc>
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	85 c0                	test   %eax,%eax
  801c43:	0f 88 e2 00 00 00    	js     801d2b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c49:	83 ec 04             	sub    $0x4,%esp
  801c4c:	68 07 04 00 00       	push   $0x407
  801c51:	ff 75 f0             	pushl  -0x10(%ebp)
  801c54:	6a 00                	push   $0x0
  801c56:	e8 a0 ee ff ff       	call   800afb <sys_page_alloc>
  801c5b:	89 c3                	mov    %eax,%ebx
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	85 c0                	test   %eax,%eax
  801c62:	0f 88 c3 00 00 00    	js     801d2b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c68:	83 ec 0c             	sub    $0xc,%esp
  801c6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6e:	e8 55 f1 ff ff       	call   800dc8 <fd2data>
  801c73:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c75:	83 c4 0c             	add    $0xc,%esp
  801c78:	68 07 04 00 00       	push   $0x407
  801c7d:	50                   	push   %eax
  801c7e:	6a 00                	push   $0x0
  801c80:	e8 76 ee ff ff       	call   800afb <sys_page_alloc>
  801c85:	89 c3                	mov    %eax,%ebx
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	0f 88 89 00 00 00    	js     801d1b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c92:	83 ec 0c             	sub    $0xc,%esp
  801c95:	ff 75 f0             	pushl  -0x10(%ebp)
  801c98:	e8 2b f1 ff ff       	call   800dc8 <fd2data>
  801c9d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ca4:	50                   	push   %eax
  801ca5:	6a 00                	push   $0x0
  801ca7:	56                   	push   %esi
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 8f ee ff ff       	call   800b3e <sys_page_map>
  801caf:	89 c3                	mov    %eax,%ebx
  801cb1:	83 c4 20             	add    $0x20,%esp
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	78 55                	js     801d0d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cb8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ccd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cdb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ce2:	83 ec 0c             	sub    $0xc,%esp
  801ce5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce8:	e8 cb f0 ff ff       	call   800db8 <fd2num>
  801ced:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cf2:	83 c4 04             	add    $0x4,%esp
  801cf5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf8:	e8 bb f0 ff ff       	call   800db8 <fd2num>
  801cfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d00:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0b:	eb 30                	jmp    801d3d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d0d:	83 ec 08             	sub    $0x8,%esp
  801d10:	56                   	push   %esi
  801d11:	6a 00                	push   $0x0
  801d13:	e8 68 ee ff ff       	call   800b80 <sys_page_unmap>
  801d18:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d1b:	83 ec 08             	sub    $0x8,%esp
  801d1e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d21:	6a 00                	push   $0x0
  801d23:	e8 58 ee ff ff       	call   800b80 <sys_page_unmap>
  801d28:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d2b:	83 ec 08             	sub    $0x8,%esp
  801d2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d31:	6a 00                	push   $0x0
  801d33:	e8 48 ee ff ff       	call   800b80 <sys_page_unmap>
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d3d:	89 d0                	mov    %edx,%eax
  801d3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d42:	5b                   	pop    %ebx
  801d43:	5e                   	pop    %esi
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    

00801d46 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4f:	50                   	push   %eax
  801d50:	ff 75 08             	pushl  0x8(%ebp)
  801d53:	e8 d6 f0 ff ff       	call   800e2e <fd_lookup>
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	78 18                	js     801d77 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d5f:	83 ec 0c             	sub    $0xc,%esp
  801d62:	ff 75 f4             	pushl  -0xc(%ebp)
  801d65:	e8 5e f0 ff ff       	call   800dc8 <fd2data>
	return _pipeisclosed(fd, p);
  801d6a:	89 c2                	mov    %eax,%edx
  801d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6f:	e8 21 fd ff ff       	call   801a95 <_pipeisclosed>
  801d74:	83 c4 10             	add    $0x10,%esp
}
  801d77:	c9                   	leave  
  801d78:	c3                   	ret    

00801d79 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d89:	68 87 27 80 00       	push   $0x802787
  801d8e:	ff 75 0c             	pushl  0xc(%ebp)
  801d91:	e8 62 e9 ff ff       	call   8006f8 <strcpy>
	return 0;
}
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	57                   	push   %edi
  801da1:	56                   	push   %esi
  801da2:	53                   	push   %ebx
  801da3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dae:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db4:	eb 2d                	jmp    801de3 <devcons_write+0x46>
		m = n - tot;
  801db6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dbb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dbe:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dc3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc6:	83 ec 04             	sub    $0x4,%esp
  801dc9:	53                   	push   %ebx
  801dca:	03 45 0c             	add    0xc(%ebp),%eax
  801dcd:	50                   	push   %eax
  801dce:	57                   	push   %edi
  801dcf:	e8 b6 ea ff ff       	call   80088a <memmove>
		sys_cputs(buf, m);
  801dd4:	83 c4 08             	add    $0x8,%esp
  801dd7:	53                   	push   %ebx
  801dd8:	57                   	push   %edi
  801dd9:	e8 61 ec ff ff       	call   800a3f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dde:	01 de                	add    %ebx,%esi
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	89 f0                	mov    %esi,%eax
  801de5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de8:	72 cc                	jb     801db6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    

00801df2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 08             	sub    $0x8,%esp
  801df8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dfd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e01:	74 2a                	je     801e2d <devcons_read+0x3b>
  801e03:	eb 05                	jmp    801e0a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e05:	e8 d2 ec ff ff       	call   800adc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e0a:	e8 4e ec ff ff       	call   800a5d <sys_cgetc>
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	74 f2                	je     801e05 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e13:	85 c0                	test   %eax,%eax
  801e15:	78 16                	js     801e2d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e17:	83 f8 04             	cmp    $0x4,%eax
  801e1a:	74 0c                	je     801e28 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1f:	88 02                	mov    %al,(%edx)
	return 1;
  801e21:	b8 01 00 00 00       	mov    $0x1,%eax
  801e26:	eb 05                	jmp    801e2d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e28:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e35:	8b 45 08             	mov    0x8(%ebp),%eax
  801e38:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e3b:	6a 01                	push   $0x1
  801e3d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e40:	50                   	push   %eax
  801e41:	e8 f9 eb ff ff       	call   800a3f <sys_cputs>
}
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <getchar>:

int
getchar(void)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e51:	6a 01                	push   $0x1
  801e53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e56:	50                   	push   %eax
  801e57:	6a 00                	push   $0x0
  801e59:	e8 36 f2 ff ff       	call   801094 <read>
	if (r < 0)
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 0f                	js     801e74 <getchar+0x29>
		return r;
	if (r < 1)
  801e65:	85 c0                	test   %eax,%eax
  801e67:	7e 06                	jle    801e6f <getchar+0x24>
		return -E_EOF;
	return c;
  801e69:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e6d:	eb 05                	jmp    801e74 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e6f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7f:	50                   	push   %eax
  801e80:	ff 75 08             	pushl  0x8(%ebp)
  801e83:	e8 a6 ef ff ff       	call   800e2e <fd_lookup>
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	78 11                	js     801ea0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e92:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e98:	39 10                	cmp    %edx,(%eax)
  801e9a:	0f 94 c0             	sete   %al
  801e9d:	0f b6 c0             	movzbl %al,%eax
}
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <opencons>:

int
opencons(void)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eab:	50                   	push   %eax
  801eac:	e8 2e ef ff ff       	call   800ddf <fd_alloc>
  801eb1:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 3e                	js     801ef8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eba:	83 ec 04             	sub    $0x4,%esp
  801ebd:	68 07 04 00 00       	push   $0x407
  801ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec5:	6a 00                	push   $0x0
  801ec7:	e8 2f ec ff ff       	call   800afb <sys_page_alloc>
  801ecc:	83 c4 10             	add    $0x10,%esp
		return r;
  801ecf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 23                	js     801ef8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ede:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	50                   	push   %eax
  801eee:	e8 c5 ee ff ff       	call   800db8 <fd2num>
  801ef3:	89 c2                	mov    %eax,%edx
  801ef5:	83 c4 10             	add    $0x10,%esp
}
  801ef8:	89 d0                	mov    %edx,%eax
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f01:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f04:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f0a:	e8 ae eb ff ff       	call   800abd <sys_getenvid>
  801f0f:	83 ec 0c             	sub    $0xc,%esp
  801f12:	ff 75 0c             	pushl  0xc(%ebp)
  801f15:	ff 75 08             	pushl  0x8(%ebp)
  801f18:	56                   	push   %esi
  801f19:	50                   	push   %eax
  801f1a:	68 94 27 80 00       	push   $0x802794
  801f1f:	e8 4f e2 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f24:	83 c4 18             	add    $0x18,%esp
  801f27:	53                   	push   %ebx
  801f28:	ff 75 10             	pushl  0x10(%ebp)
  801f2b:	e8 f2 e1 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801f30:	c7 04 24 80 27 80 00 	movl   $0x802780,(%esp)
  801f37:	e8 37 e2 ff ff       	call   800173 <cprintf>
  801f3c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f3f:	cc                   	int3   
  801f40:	eb fd                	jmp    801f3f <_panic+0x43>

00801f42 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	56                   	push   %esi
  801f46:	53                   	push   %ebx
  801f47:	8b 75 08             	mov    0x8(%ebp),%esi
  801f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f50:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f52:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f57:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f5a:	83 ec 0c             	sub    $0xc,%esp
  801f5d:	50                   	push   %eax
  801f5e:	e8 48 ed ff ff       	call   800cab <sys_ipc_recv>

	if (from_env_store != NULL)
  801f63:	83 c4 10             	add    $0x10,%esp
  801f66:	85 f6                	test   %esi,%esi
  801f68:	74 14                	je     801f7e <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	78 09                	js     801f7c <ipc_recv+0x3a>
  801f73:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f79:	8b 52 74             	mov    0x74(%edx),%edx
  801f7c:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f7e:	85 db                	test   %ebx,%ebx
  801f80:	74 14                	je     801f96 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f82:	ba 00 00 00 00       	mov    $0x0,%edx
  801f87:	85 c0                	test   %eax,%eax
  801f89:	78 09                	js     801f94 <ipc_recv+0x52>
  801f8b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f91:	8b 52 78             	mov    0x78(%edx),%edx
  801f94:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f96:	85 c0                	test   %eax,%eax
  801f98:	78 08                	js     801fa2 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f9a:	a1 08 40 80 00       	mov    0x804008,%eax
  801f9f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa5:	5b                   	pop    %ebx
  801fa6:	5e                   	pop    %esi
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    

00801fa9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	57                   	push   %edi
  801fad:	56                   	push   %esi
  801fae:	53                   	push   %ebx
  801faf:	83 ec 0c             	sub    $0xc,%esp
  801fb2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801fbb:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801fbd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fc2:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801fc5:	ff 75 14             	pushl  0x14(%ebp)
  801fc8:	53                   	push   %ebx
  801fc9:	56                   	push   %esi
  801fca:	57                   	push   %edi
  801fcb:	e8 b8 ec ff ff       	call   800c88 <sys_ipc_try_send>

		if (err < 0) {
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	79 1e                	jns    801ff5 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801fd7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fda:	75 07                	jne    801fe3 <ipc_send+0x3a>
				sys_yield();
  801fdc:	e8 fb ea ff ff       	call   800adc <sys_yield>
  801fe1:	eb e2                	jmp    801fc5 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801fe3:	50                   	push   %eax
  801fe4:	68 b8 27 80 00       	push   $0x8027b8
  801fe9:	6a 49                	push   $0x49
  801feb:	68 c5 27 80 00       	push   $0x8027c5
  801ff0:	e8 07 ff ff ff       	call   801efc <_panic>
		}

	} while (err < 0);

}
  801ff5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff8:	5b                   	pop    %ebx
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    

00801ffd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802008:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80200b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802011:	8b 52 50             	mov    0x50(%edx),%edx
  802014:	39 ca                	cmp    %ecx,%edx
  802016:	75 0d                	jne    802025 <ipc_find_env+0x28>
			return envs[i].env_id;
  802018:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80201b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802020:	8b 40 48             	mov    0x48(%eax),%eax
  802023:	eb 0f                	jmp    802034 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802025:	83 c0 01             	add    $0x1,%eax
  802028:	3d 00 04 00 00       	cmp    $0x400,%eax
  80202d:	75 d9                	jne    802008 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80202f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    

00802036 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203c:	89 d0                	mov    %edx,%eax
  80203e:	c1 e8 16             	shr    $0x16,%eax
  802041:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802048:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204d:	f6 c1 01             	test   $0x1,%cl
  802050:	74 1d                	je     80206f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802052:	c1 ea 0c             	shr    $0xc,%edx
  802055:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80205c:	f6 c2 01             	test   $0x1,%dl
  80205f:	74 0e                	je     80206f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802061:	c1 ea 0c             	shr    $0xc,%edx
  802064:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80206b:	ef 
  80206c:	0f b7 c0             	movzwl %ax,%eax
}
  80206f:	5d                   	pop    %ebp
  802070:	c3                   	ret    
  802071:	66 90                	xchg   %ax,%ax
  802073:	66 90                	xchg   %ax,%ax
  802075:	66 90                	xchg   %ax,%ax
  802077:	66 90                	xchg   %ax,%ax
  802079:	66 90                	xchg   %ax,%ax
  80207b:	66 90                	xchg   %ax,%ax
  80207d:	66 90                	xchg   %ax,%ax
  80207f:	90                   	nop

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
