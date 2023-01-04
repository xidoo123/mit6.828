
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
  800045:	68 20 1e 80 00       	push   $0x801e20
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
  80006c:	e8 7b 0c 00 00       	call   800cec <set_pgfault_handler>
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
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8000cc:	e8 51 0e 00 00       	call   800f22 <close_all>
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
  8001d6:	e8 b5 19 00 00       	call   801b90 <__udivdi3>
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
  800219:	e8 a2 1a 00 00       	call   801cc0 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 46 1e 80 00 	movsbl 0x801e46(%eax),%eax
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
  80031d:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
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
  8003e1:	8b 14 85 e0 20 80 00 	mov    0x8020e0(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	75 18                	jne    800404 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ec:	50                   	push   %eax
  8003ed:	68 5e 1e 80 00       	push   $0x801e5e
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
  800405:	68 3a 22 80 00       	push   $0x80223a
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
  800429:	b8 57 1e 80 00       	mov    $0x801e57,%eax
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
  800aa4:	68 3f 21 80 00       	push   $0x80213f
  800aa9:	6a 23                	push   $0x23
  800aab:	68 5c 21 80 00       	push   $0x80215c
  800ab0:	e8 60 0f 00 00       	call   801a15 <_panic>

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
  800b25:	68 3f 21 80 00       	push   $0x80213f
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 5c 21 80 00       	push   $0x80215c
  800b31:	e8 df 0e 00 00       	call   801a15 <_panic>

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
  800b67:	68 3f 21 80 00       	push   $0x80213f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 5c 21 80 00       	push   $0x80215c
  800b73:	e8 9d 0e 00 00       	call   801a15 <_panic>

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
  800ba9:	68 3f 21 80 00       	push   $0x80213f
  800bae:	6a 23                	push   $0x23
  800bb0:	68 5c 21 80 00       	push   $0x80215c
  800bb5:	e8 5b 0e 00 00       	call   801a15 <_panic>

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
  800beb:	68 3f 21 80 00       	push   $0x80213f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 5c 21 80 00       	push   $0x80215c
  800bf7:	e8 19 0e 00 00       	call   801a15 <_panic>

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
  800c2d:	68 3f 21 80 00       	push   $0x80213f
  800c32:	6a 23                	push   $0x23
  800c34:	68 5c 21 80 00       	push   $0x80215c
  800c39:	e8 d7 0d 00 00       	call   801a15 <_panic>

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
  800c6f:	68 3f 21 80 00       	push   $0x80213f
  800c74:	6a 23                	push   $0x23
  800c76:	68 5c 21 80 00       	push   $0x80215c
  800c7b:	e8 95 0d 00 00       	call   801a15 <_panic>

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
  800cd3:	68 3f 21 80 00       	push   $0x80213f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 5c 21 80 00       	push   $0x80215c
  800cdf:	e8 31 0d 00 00       	call   801a15 <_panic>

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

00800cec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cf2:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800cf9:	75 2e                	jne    800d29 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800cfb:	e8 bd fd ff ff       	call   800abd <sys_getenvid>
  800d00:	83 ec 04             	sub    $0x4,%esp
  800d03:	68 07 0e 00 00       	push   $0xe07
  800d08:	68 00 f0 bf ee       	push   $0xeebff000
  800d0d:	50                   	push   %eax
  800d0e:	e8 e8 fd ff ff       	call   800afb <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800d13:	e8 a5 fd ff ff       	call   800abd <sys_getenvid>
  800d18:	83 c4 08             	add    $0x8,%esp
  800d1b:	68 33 0d 80 00       	push   $0x800d33
  800d20:	50                   	push   %eax
  800d21:	e8 20 ff ff ff       	call   800c46 <sys_env_set_pgfault_upcall>
  800d26:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    

00800d33 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d33:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d34:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800d39:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d3b:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  800d3e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800d42:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800d46:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800d49:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800d4c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  800d4d:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800d50:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800d51:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800d52:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800d56:	c3                   	ret    

00800d57 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d62:	c1 e8 0c             	shr    $0xc,%eax
}
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d77:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d84:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	c1 ea 16             	shr    $0x16,%edx
  800d8e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d95:	f6 c2 01             	test   $0x1,%dl
  800d98:	74 11                	je     800dab <fd_alloc+0x2d>
  800d9a:	89 c2                	mov    %eax,%edx
  800d9c:	c1 ea 0c             	shr    $0xc,%edx
  800d9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da6:	f6 c2 01             	test   $0x1,%dl
  800da9:	75 09                	jne    800db4 <fd_alloc+0x36>
			*fd_store = fd;
  800dab:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dad:	b8 00 00 00 00       	mov    $0x0,%eax
  800db2:	eb 17                	jmp    800dcb <fd_alloc+0x4d>
  800db4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800db9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dbe:	75 c9                	jne    800d89 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dc0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dc6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dd3:	83 f8 1f             	cmp    $0x1f,%eax
  800dd6:	77 36                	ja     800e0e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dd8:	c1 e0 0c             	shl    $0xc,%eax
  800ddb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800de0:	89 c2                	mov    %eax,%edx
  800de2:	c1 ea 16             	shr    $0x16,%edx
  800de5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dec:	f6 c2 01             	test   $0x1,%dl
  800def:	74 24                	je     800e15 <fd_lookup+0x48>
  800df1:	89 c2                	mov    %eax,%edx
  800df3:	c1 ea 0c             	shr    $0xc,%edx
  800df6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dfd:	f6 c2 01             	test   $0x1,%dl
  800e00:	74 1a                	je     800e1c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e02:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e05:	89 02                	mov    %eax,(%edx)
	return 0;
  800e07:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0c:	eb 13                	jmp    800e21 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e13:	eb 0c                	jmp    800e21 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1a:	eb 05                	jmp    800e21 <fd_lookup+0x54>
  800e1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	83 ec 08             	sub    $0x8,%esp
  800e29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2c:	ba e8 21 80 00       	mov    $0x8021e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e31:	eb 13                	jmp    800e46 <dev_lookup+0x23>
  800e33:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e36:	39 08                	cmp    %ecx,(%eax)
  800e38:	75 0c                	jne    800e46 <dev_lookup+0x23>
			*dev = devtab[i];
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e44:	eb 2e                	jmp    800e74 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e46:	8b 02                	mov    (%edx),%eax
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	75 e7                	jne    800e33 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e4c:	a1 04 40 80 00       	mov    0x804004,%eax
  800e51:	8b 40 48             	mov    0x48(%eax),%eax
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	51                   	push   %ecx
  800e58:	50                   	push   %eax
  800e59:	68 6c 21 80 00       	push   $0x80216c
  800e5e:	e8 10 f3 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800e63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e74:	c9                   	leave  
  800e75:	c3                   	ret    

00800e76 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
  800e7b:	83 ec 10             	sub    $0x10,%esp
  800e7e:	8b 75 08             	mov    0x8(%ebp),%esi
  800e81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e87:	50                   	push   %eax
  800e88:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e8e:	c1 e8 0c             	shr    $0xc,%eax
  800e91:	50                   	push   %eax
  800e92:	e8 36 ff ff ff       	call   800dcd <fd_lookup>
  800e97:	83 c4 08             	add    $0x8,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	78 05                	js     800ea3 <fd_close+0x2d>
	    || fd != fd2)
  800e9e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ea1:	74 0c                	je     800eaf <fd_close+0x39>
		return (must_exist ? r : 0);
  800ea3:	84 db                	test   %bl,%bl
  800ea5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaa:	0f 44 c2             	cmove  %edx,%eax
  800ead:	eb 41                	jmp    800ef0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eb5:	50                   	push   %eax
  800eb6:	ff 36                	pushl  (%esi)
  800eb8:	e8 66 ff ff ff       	call   800e23 <dev_lookup>
  800ebd:	89 c3                	mov    %eax,%ebx
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	78 1a                	js     800ee0 <fd_close+0x6a>
		if (dev->dev_close)
  800ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	74 0b                	je     800ee0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	56                   	push   %esi
  800ed9:	ff d0                	call   *%eax
  800edb:	89 c3                	mov    %eax,%ebx
  800edd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	56                   	push   %esi
  800ee4:	6a 00                	push   $0x0
  800ee6:	e8 95 fc ff ff       	call   800b80 <sys_page_unmap>
	return r;
  800eeb:	83 c4 10             	add    $0x10,%esp
  800eee:	89 d8                	mov    %ebx,%eax
}
  800ef0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800efd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f00:	50                   	push   %eax
  800f01:	ff 75 08             	pushl  0x8(%ebp)
  800f04:	e8 c4 fe ff ff       	call   800dcd <fd_lookup>
  800f09:	83 c4 08             	add    $0x8,%esp
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	78 10                	js     800f20 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f10:	83 ec 08             	sub    $0x8,%esp
  800f13:	6a 01                	push   $0x1
  800f15:	ff 75 f4             	pushl  -0xc(%ebp)
  800f18:	e8 59 ff ff ff       	call   800e76 <fd_close>
  800f1d:	83 c4 10             	add    $0x10,%esp
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <close_all>:

void
close_all(void)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	53                   	push   %ebx
  800f26:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f29:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	53                   	push   %ebx
  800f32:	e8 c0 ff ff ff       	call   800ef7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f37:	83 c3 01             	add    $0x1,%ebx
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	83 fb 20             	cmp    $0x20,%ebx
  800f40:	75 ec                	jne    800f2e <close_all+0xc>
		close(i);
}
  800f42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 2c             	sub    $0x2c,%esp
  800f50:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f53:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f56:	50                   	push   %eax
  800f57:	ff 75 08             	pushl  0x8(%ebp)
  800f5a:	e8 6e fe ff ff       	call   800dcd <fd_lookup>
  800f5f:	83 c4 08             	add    $0x8,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	0f 88 c1 00 00 00    	js     80102b <dup+0xe4>
		return r;
	close(newfdnum);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	56                   	push   %esi
  800f6e:	e8 84 ff ff ff       	call   800ef7 <close>

	newfd = INDEX2FD(newfdnum);
  800f73:	89 f3                	mov    %esi,%ebx
  800f75:	c1 e3 0c             	shl    $0xc,%ebx
  800f78:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f7e:	83 c4 04             	add    $0x4,%esp
  800f81:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f84:	e8 de fd ff ff       	call   800d67 <fd2data>
  800f89:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f8b:	89 1c 24             	mov    %ebx,(%esp)
  800f8e:	e8 d4 fd ff ff       	call   800d67 <fd2data>
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f99:	89 f8                	mov    %edi,%eax
  800f9b:	c1 e8 16             	shr    $0x16,%eax
  800f9e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa5:	a8 01                	test   $0x1,%al
  800fa7:	74 37                	je     800fe0 <dup+0x99>
  800fa9:	89 f8                	mov    %edi,%eax
  800fab:	c1 e8 0c             	shr    $0xc,%eax
  800fae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb5:	f6 c2 01             	test   $0x1,%dl
  800fb8:	74 26                	je     800fe0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc1:	83 ec 0c             	sub    $0xc,%esp
  800fc4:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc9:	50                   	push   %eax
  800fca:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fcd:	6a 00                	push   $0x0
  800fcf:	57                   	push   %edi
  800fd0:	6a 00                	push   $0x0
  800fd2:	e8 67 fb ff ff       	call   800b3e <sys_page_map>
  800fd7:	89 c7                	mov    %eax,%edi
  800fd9:	83 c4 20             	add    $0x20,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	78 2e                	js     80100e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fe3:	89 d0                	mov    %edx,%eax
  800fe5:	c1 e8 0c             	shr    $0xc,%eax
  800fe8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff7:	50                   	push   %eax
  800ff8:	53                   	push   %ebx
  800ff9:	6a 00                	push   $0x0
  800ffb:	52                   	push   %edx
  800ffc:	6a 00                	push   $0x0
  800ffe:	e8 3b fb ff ff       	call   800b3e <sys_page_map>
  801003:	89 c7                	mov    %eax,%edi
  801005:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801008:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80100a:	85 ff                	test   %edi,%edi
  80100c:	79 1d                	jns    80102b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80100e:	83 ec 08             	sub    $0x8,%esp
  801011:	53                   	push   %ebx
  801012:	6a 00                	push   $0x0
  801014:	e8 67 fb ff ff       	call   800b80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801019:	83 c4 08             	add    $0x8,%esp
  80101c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80101f:	6a 00                	push   $0x0
  801021:	e8 5a fb ff ff       	call   800b80 <sys_page_unmap>
	return r;
  801026:	83 c4 10             	add    $0x10,%esp
  801029:	89 f8                	mov    %edi,%eax
}
  80102b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	53                   	push   %ebx
  801037:	83 ec 14             	sub    $0x14,%esp
  80103a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80103d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801040:	50                   	push   %eax
  801041:	53                   	push   %ebx
  801042:	e8 86 fd ff ff       	call   800dcd <fd_lookup>
  801047:	83 c4 08             	add    $0x8,%esp
  80104a:	89 c2                	mov    %eax,%edx
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 6d                	js     8010bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801050:	83 ec 08             	sub    $0x8,%esp
  801053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801056:	50                   	push   %eax
  801057:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80105a:	ff 30                	pushl  (%eax)
  80105c:	e8 c2 fd ff ff       	call   800e23 <dev_lookup>
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	78 4c                	js     8010b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801068:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80106b:	8b 42 08             	mov    0x8(%edx),%eax
  80106e:	83 e0 03             	and    $0x3,%eax
  801071:	83 f8 01             	cmp    $0x1,%eax
  801074:	75 21                	jne    801097 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801076:	a1 04 40 80 00       	mov    0x804004,%eax
  80107b:	8b 40 48             	mov    0x48(%eax),%eax
  80107e:	83 ec 04             	sub    $0x4,%esp
  801081:	53                   	push   %ebx
  801082:	50                   	push   %eax
  801083:	68 ad 21 80 00       	push   $0x8021ad
  801088:	e8 e6 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801095:	eb 26                	jmp    8010bd <read+0x8a>
	}
	if (!dev->dev_read)
  801097:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109a:	8b 40 08             	mov    0x8(%eax),%eax
  80109d:	85 c0                	test   %eax,%eax
  80109f:	74 17                	je     8010b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010a1:	83 ec 04             	sub    $0x4,%esp
  8010a4:	ff 75 10             	pushl  0x10(%ebp)
  8010a7:	ff 75 0c             	pushl  0xc(%ebp)
  8010aa:	52                   	push   %edx
  8010ab:	ff d0                	call   *%eax
  8010ad:	89 c2                	mov    %eax,%edx
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	eb 09                	jmp    8010bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b4:	89 c2                	mov    %eax,%edx
  8010b6:	eb 05                	jmp    8010bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010bd:	89 d0                	mov    %edx,%eax
  8010bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d8:	eb 21                	jmp    8010fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010da:	83 ec 04             	sub    $0x4,%esp
  8010dd:	89 f0                	mov    %esi,%eax
  8010df:	29 d8                	sub    %ebx,%eax
  8010e1:	50                   	push   %eax
  8010e2:	89 d8                	mov    %ebx,%eax
  8010e4:	03 45 0c             	add    0xc(%ebp),%eax
  8010e7:	50                   	push   %eax
  8010e8:	57                   	push   %edi
  8010e9:	e8 45 ff ff ff       	call   801033 <read>
		if (m < 0)
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 10                	js     801105 <readn+0x41>
			return m;
		if (m == 0)
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	74 0a                	je     801103 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f9:	01 c3                	add    %eax,%ebx
  8010fb:	39 f3                	cmp    %esi,%ebx
  8010fd:	72 db                	jb     8010da <readn+0x16>
  8010ff:	89 d8                	mov    %ebx,%eax
  801101:	eb 02                	jmp    801105 <readn+0x41>
  801103:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	53                   	push   %ebx
  801111:	83 ec 14             	sub    $0x14,%esp
  801114:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801117:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111a:	50                   	push   %eax
  80111b:	53                   	push   %ebx
  80111c:	e8 ac fc ff ff       	call   800dcd <fd_lookup>
  801121:	83 c4 08             	add    $0x8,%esp
  801124:	89 c2                	mov    %eax,%edx
  801126:	85 c0                	test   %eax,%eax
  801128:	78 68                	js     801192 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801134:	ff 30                	pushl  (%eax)
  801136:	e8 e8 fc ff ff       	call   800e23 <dev_lookup>
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 47                	js     801189 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801142:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801145:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801149:	75 21                	jne    80116c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80114b:	a1 04 40 80 00       	mov    0x804004,%eax
  801150:	8b 40 48             	mov    0x48(%eax),%eax
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	53                   	push   %ebx
  801157:	50                   	push   %eax
  801158:	68 c9 21 80 00       	push   $0x8021c9
  80115d:	e8 11 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116a:	eb 26                	jmp    801192 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80116c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80116f:	8b 52 0c             	mov    0xc(%edx),%edx
  801172:	85 d2                	test   %edx,%edx
  801174:	74 17                	je     80118d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801176:	83 ec 04             	sub    $0x4,%esp
  801179:	ff 75 10             	pushl  0x10(%ebp)
  80117c:	ff 75 0c             	pushl  0xc(%ebp)
  80117f:	50                   	push   %eax
  801180:	ff d2                	call   *%edx
  801182:	89 c2                	mov    %eax,%edx
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	eb 09                	jmp    801192 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801189:	89 c2                	mov    %eax,%edx
  80118b:	eb 05                	jmp    801192 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80118d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801192:	89 d0                	mov    %edx,%eax
  801194:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801197:	c9                   	leave  
  801198:	c3                   	ret    

00801199 <seek>:

int
seek(int fdnum, off_t offset)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80119f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	ff 75 08             	pushl  0x8(%ebp)
  8011a6:	e8 22 fc ff ff       	call   800dcd <fd_lookup>
  8011ab:	83 c4 08             	add    $0x8,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 0e                	js     8011c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    

008011c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 14             	sub    $0x14,%esp
  8011c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	53                   	push   %ebx
  8011d1:	e8 f7 fb ff ff       	call   800dcd <fd_lookup>
  8011d6:	83 c4 08             	add    $0x8,%esp
  8011d9:	89 c2                	mov    %eax,%edx
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 65                	js     801244 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011df:	83 ec 08             	sub    $0x8,%esp
  8011e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e9:	ff 30                	pushl  (%eax)
  8011eb:	e8 33 fc ff ff       	call   800e23 <dev_lookup>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 44                	js     80123b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011fe:	75 21                	jne    801221 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801200:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801205:	8b 40 48             	mov    0x48(%eax),%eax
  801208:	83 ec 04             	sub    $0x4,%esp
  80120b:	53                   	push   %ebx
  80120c:	50                   	push   %eax
  80120d:	68 8c 21 80 00       	push   $0x80218c
  801212:	e8 5c ef ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80121f:	eb 23                	jmp    801244 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801221:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801224:	8b 52 18             	mov    0x18(%edx),%edx
  801227:	85 d2                	test   %edx,%edx
  801229:	74 14                	je     80123f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	ff 75 0c             	pushl  0xc(%ebp)
  801231:	50                   	push   %eax
  801232:	ff d2                	call   *%edx
  801234:	89 c2                	mov    %eax,%edx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	eb 09                	jmp    801244 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123b:	89 c2                	mov    %eax,%edx
  80123d:	eb 05                	jmp    801244 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80123f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801244:	89 d0                	mov    %edx,%eax
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	53                   	push   %ebx
  80124f:	83 ec 14             	sub    $0x14,%esp
  801252:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801255:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	ff 75 08             	pushl  0x8(%ebp)
  80125c:	e8 6c fb ff ff       	call   800dcd <fd_lookup>
  801261:	83 c4 08             	add    $0x8,%esp
  801264:	89 c2                	mov    %eax,%edx
  801266:	85 c0                	test   %eax,%eax
  801268:	78 58                	js     8012c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801270:	50                   	push   %eax
  801271:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801274:	ff 30                	pushl  (%eax)
  801276:	e8 a8 fb ff ff       	call   800e23 <dev_lookup>
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 37                	js     8012b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801282:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801285:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801289:	74 32                	je     8012bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80128b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80128e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801295:	00 00 00 
	stat->st_isdir = 0;
  801298:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80129f:	00 00 00 
	stat->st_dev = dev;
  8012a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	53                   	push   %ebx
  8012ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8012af:	ff 50 14             	call   *0x14(%eax)
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	eb 09                	jmp    8012c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b9:	89 c2                	mov    %eax,%edx
  8012bb:	eb 05                	jmp    8012c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012c2:	89 d0                	mov    %edx,%eax
  8012c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    

008012c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	56                   	push   %esi
  8012cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	6a 00                	push   $0x0
  8012d3:	ff 75 08             	pushl  0x8(%ebp)
  8012d6:	e8 b7 01 00 00       	call   801492 <open>
  8012db:	89 c3                	mov    %eax,%ebx
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 1b                	js     8012ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	ff 75 0c             	pushl  0xc(%ebp)
  8012ea:	50                   	push   %eax
  8012eb:	e8 5b ff ff ff       	call   80124b <fstat>
  8012f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8012f2:	89 1c 24             	mov    %ebx,(%esp)
  8012f5:	e8 fd fb ff ff       	call   800ef7 <close>
	return r;
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	89 f0                	mov    %esi,%eax
}
  8012ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801302:	5b                   	pop    %ebx
  801303:	5e                   	pop    %esi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    

00801306 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
  80130b:	89 c6                	mov    %eax,%esi
  80130d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80130f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801316:	75 12                	jne    80132a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801318:	83 ec 0c             	sub    $0xc,%esp
  80131b:	6a 01                	push   $0x1
  80131d:	e8 f4 07 00 00       	call   801b16 <ipc_find_env>
  801322:	a3 00 40 80 00       	mov    %eax,0x804000
  801327:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80132a:	6a 07                	push   $0x7
  80132c:	68 00 50 80 00       	push   $0x805000
  801331:	56                   	push   %esi
  801332:	ff 35 00 40 80 00    	pushl  0x804000
  801338:	e8 85 07 00 00       	call   801ac2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80133d:	83 c4 0c             	add    $0xc,%esp
  801340:	6a 00                	push   $0x0
  801342:	53                   	push   %ebx
  801343:	6a 00                	push   $0x0
  801345:	e8 11 07 00 00       	call   801a5b <ipc_recv>
}
  80134a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801357:	8b 45 08             	mov    0x8(%ebp),%eax
  80135a:	8b 40 0c             	mov    0xc(%eax),%eax
  80135d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801362:	8b 45 0c             	mov    0xc(%ebp),%eax
  801365:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80136a:	ba 00 00 00 00       	mov    $0x0,%edx
  80136f:	b8 02 00 00 00       	mov    $0x2,%eax
  801374:	e8 8d ff ff ff       	call   801306 <fsipc>
}
  801379:	c9                   	leave  
  80137a:	c3                   	ret    

0080137b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801381:	8b 45 08             	mov    0x8(%ebp),%eax
  801384:	8b 40 0c             	mov    0xc(%eax),%eax
  801387:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80138c:	ba 00 00 00 00       	mov    $0x0,%edx
  801391:	b8 06 00 00 00       	mov    $0x6,%eax
  801396:	e8 6b ff ff ff       	call   801306 <fsipc>
}
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 04             	sub    $0x4,%esp
  8013a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8013bc:	e8 45 ff ff ff       	call   801306 <fsipc>
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 2c                	js     8013f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	68 00 50 80 00       	push   $0x805000
  8013cd:	53                   	push   %ebx
  8013ce:	e8 25 f3 ff ff       	call   8006f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8013d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013de:	a1 84 50 80 00       	mov    0x805084,%eax
  8013e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8013fc:	68 f8 21 80 00       	push   $0x8021f8
  801401:	68 90 00 00 00       	push   $0x90
  801406:	68 16 22 80 00       	push   $0x802216
  80140b:	e8 05 06 00 00       	call   801a15 <_panic>

00801410 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	56                   	push   %esi
  801414:	53                   	push   %ebx
  801415:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801418:	8b 45 08             	mov    0x8(%ebp),%eax
  80141b:	8b 40 0c             	mov    0xc(%eax),%eax
  80141e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801423:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801429:	ba 00 00 00 00       	mov    $0x0,%edx
  80142e:	b8 03 00 00 00       	mov    $0x3,%eax
  801433:	e8 ce fe ff ff       	call   801306 <fsipc>
  801438:	89 c3                	mov    %eax,%ebx
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 4b                	js     801489 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80143e:	39 c6                	cmp    %eax,%esi
  801440:	73 16                	jae    801458 <devfile_read+0x48>
  801442:	68 21 22 80 00       	push   $0x802221
  801447:	68 28 22 80 00       	push   $0x802228
  80144c:	6a 7c                	push   $0x7c
  80144e:	68 16 22 80 00       	push   $0x802216
  801453:	e8 bd 05 00 00       	call   801a15 <_panic>
	assert(r <= PGSIZE);
  801458:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80145d:	7e 16                	jle    801475 <devfile_read+0x65>
  80145f:	68 3d 22 80 00       	push   $0x80223d
  801464:	68 28 22 80 00       	push   $0x802228
  801469:	6a 7d                	push   $0x7d
  80146b:	68 16 22 80 00       	push   $0x802216
  801470:	e8 a0 05 00 00       	call   801a15 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801475:	83 ec 04             	sub    $0x4,%esp
  801478:	50                   	push   %eax
  801479:	68 00 50 80 00       	push   $0x805000
  80147e:	ff 75 0c             	pushl  0xc(%ebp)
  801481:	e8 04 f4 ff ff       	call   80088a <memmove>
	return r;
  801486:	83 c4 10             	add    $0x10,%esp
}
  801489:	89 d8                	mov    %ebx,%eax
  80148b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5e                   	pop    %esi
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	53                   	push   %ebx
  801496:	83 ec 20             	sub    $0x20,%esp
  801499:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80149c:	53                   	push   %ebx
  80149d:	e8 1d f2 ff ff       	call   8006bf <strlen>
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014aa:	7f 67                	jg     801513 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b2:	50                   	push   %eax
  8014b3:	e8 c6 f8 ff ff       	call   800d7e <fd_alloc>
  8014b8:	83 c4 10             	add    $0x10,%esp
		return r;
  8014bb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 57                	js     801518 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	53                   	push   %ebx
  8014c5:	68 00 50 80 00       	push   $0x805000
  8014ca:	e8 29 f2 ff ff       	call   8006f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014da:	b8 01 00 00 00       	mov    $0x1,%eax
  8014df:	e8 22 fe ff ff       	call   801306 <fsipc>
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	79 14                	jns    801501 <open+0x6f>
		fd_close(fd, 0);
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	6a 00                	push   $0x0
  8014f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f5:	e8 7c f9 ff ff       	call   800e76 <fd_close>
		return r;
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	89 da                	mov    %ebx,%edx
  8014ff:	eb 17                	jmp    801518 <open+0x86>
	}

	return fd2num(fd);
  801501:	83 ec 0c             	sub    $0xc,%esp
  801504:	ff 75 f4             	pushl  -0xc(%ebp)
  801507:	e8 4b f8 ff ff       	call   800d57 <fd2num>
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	eb 05                	jmp    801518 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801513:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801518:	89 d0                	mov    %edx,%eax
  80151a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801525:	ba 00 00 00 00       	mov    $0x0,%edx
  80152a:	b8 08 00 00 00       	mov    $0x8,%eax
  80152f:	e8 d2 fd ff ff       	call   801306 <fsipc>
}
  801534:	c9                   	leave  
  801535:	c3                   	ret    

00801536 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
  80153b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	ff 75 08             	pushl  0x8(%ebp)
  801544:	e8 1e f8 ff ff       	call   800d67 <fd2data>
  801549:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80154b:	83 c4 08             	add    $0x8,%esp
  80154e:	68 49 22 80 00       	push   $0x802249
  801553:	53                   	push   %ebx
  801554:	e8 9f f1 ff ff       	call   8006f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801559:	8b 46 04             	mov    0x4(%esi),%eax
  80155c:	2b 06                	sub    (%esi),%eax
  80155e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801564:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80156b:	00 00 00 
	stat->st_dev = &devpipe;
  80156e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801575:	30 80 00 
	return 0;
}
  801578:	b8 00 00 00 00       	mov    $0x0,%eax
  80157d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801580:	5b                   	pop    %ebx
  801581:	5e                   	pop    %esi
  801582:	5d                   	pop    %ebp
  801583:	c3                   	ret    

00801584 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	53                   	push   %ebx
  801588:	83 ec 0c             	sub    $0xc,%esp
  80158b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80158e:	53                   	push   %ebx
  80158f:	6a 00                	push   $0x0
  801591:	e8 ea f5 ff ff       	call   800b80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801596:	89 1c 24             	mov    %ebx,(%esp)
  801599:	e8 c9 f7 ff ff       	call   800d67 <fd2data>
  80159e:	83 c4 08             	add    $0x8,%esp
  8015a1:	50                   	push   %eax
  8015a2:	6a 00                	push   $0x0
  8015a4:	e8 d7 f5 ff ff       	call   800b80 <sys_page_unmap>
}
  8015a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ac:	c9                   	leave  
  8015ad:	c3                   	ret    

008015ae <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	57                   	push   %edi
  8015b2:	56                   	push   %esi
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 1c             	sub    $0x1c,%esp
  8015b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015ba:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015c4:	83 ec 0c             	sub    $0xc,%esp
  8015c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ca:	e8 80 05 00 00       	call   801b4f <pageref>
  8015cf:	89 c3                	mov    %eax,%ebx
  8015d1:	89 3c 24             	mov    %edi,(%esp)
  8015d4:	e8 76 05 00 00       	call   801b4f <pageref>
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	39 c3                	cmp    %eax,%ebx
  8015de:	0f 94 c1             	sete   %cl
  8015e1:	0f b6 c9             	movzbl %cl,%ecx
  8015e4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015e7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015ed:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015f0:	39 ce                	cmp    %ecx,%esi
  8015f2:	74 1b                	je     80160f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015f4:	39 c3                	cmp    %eax,%ebx
  8015f6:	75 c4                	jne    8015bc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015f8:	8b 42 58             	mov    0x58(%edx),%eax
  8015fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015fe:	50                   	push   %eax
  8015ff:	56                   	push   %esi
  801600:	68 50 22 80 00       	push   $0x802250
  801605:	e8 69 eb ff ff       	call   800173 <cprintf>
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	eb ad                	jmp    8015bc <_pipeisclosed+0xe>
	}
}
  80160f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    

0080161a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	57                   	push   %edi
  80161e:	56                   	push   %esi
  80161f:	53                   	push   %ebx
  801620:	83 ec 28             	sub    $0x28,%esp
  801623:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801626:	56                   	push   %esi
  801627:	e8 3b f7 ff ff       	call   800d67 <fd2data>
  80162c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	bf 00 00 00 00       	mov    $0x0,%edi
  801636:	eb 4b                	jmp    801683 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801638:	89 da                	mov    %ebx,%edx
  80163a:	89 f0                	mov    %esi,%eax
  80163c:	e8 6d ff ff ff       	call   8015ae <_pipeisclosed>
  801641:	85 c0                	test   %eax,%eax
  801643:	75 48                	jne    80168d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801645:	e8 92 f4 ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80164a:	8b 43 04             	mov    0x4(%ebx),%eax
  80164d:	8b 0b                	mov    (%ebx),%ecx
  80164f:	8d 51 20             	lea    0x20(%ecx),%edx
  801652:	39 d0                	cmp    %edx,%eax
  801654:	73 e2                	jae    801638 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801656:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801659:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80165d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801660:	89 c2                	mov    %eax,%edx
  801662:	c1 fa 1f             	sar    $0x1f,%edx
  801665:	89 d1                	mov    %edx,%ecx
  801667:	c1 e9 1b             	shr    $0x1b,%ecx
  80166a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80166d:	83 e2 1f             	and    $0x1f,%edx
  801670:	29 ca                	sub    %ecx,%edx
  801672:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801676:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80167a:	83 c0 01             	add    $0x1,%eax
  80167d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801680:	83 c7 01             	add    $0x1,%edi
  801683:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801686:	75 c2                	jne    80164a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801688:	8b 45 10             	mov    0x10(%ebp),%eax
  80168b:	eb 05                	jmp    801692 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80168d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801692:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	5f                   	pop    %edi
  801698:	5d                   	pop    %ebp
  801699:	c3                   	ret    

0080169a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	57                   	push   %edi
  80169e:	56                   	push   %esi
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 18             	sub    $0x18,%esp
  8016a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016a6:	57                   	push   %edi
  8016a7:	e8 bb f6 ff ff       	call   800d67 <fd2data>
  8016ac:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b6:	eb 3d                	jmp    8016f5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016b8:	85 db                	test   %ebx,%ebx
  8016ba:	74 04                	je     8016c0 <devpipe_read+0x26>
				return i;
  8016bc:	89 d8                	mov    %ebx,%eax
  8016be:	eb 44                	jmp    801704 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016c0:	89 f2                	mov    %esi,%edx
  8016c2:	89 f8                	mov    %edi,%eax
  8016c4:	e8 e5 fe ff ff       	call   8015ae <_pipeisclosed>
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	75 32                	jne    8016ff <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016cd:	e8 0a f4 ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016d2:	8b 06                	mov    (%esi),%eax
  8016d4:	3b 46 04             	cmp    0x4(%esi),%eax
  8016d7:	74 df                	je     8016b8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016d9:	99                   	cltd   
  8016da:	c1 ea 1b             	shr    $0x1b,%edx
  8016dd:	01 d0                	add    %edx,%eax
  8016df:	83 e0 1f             	and    $0x1f,%eax
  8016e2:	29 d0                	sub    %edx,%eax
  8016e4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ec:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016ef:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f2:	83 c3 01             	add    $0x1,%ebx
  8016f5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016f8:	75 d8                	jne    8016d2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8016fd:	eb 05                	jmp    801704 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ff:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801707:	5b                   	pop    %ebx
  801708:	5e                   	pop    %esi
  801709:	5f                   	pop    %edi
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	56                   	push   %esi
  801710:	53                   	push   %ebx
  801711:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801714:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	e8 61 f6 ff ff       	call   800d7e <fd_alloc>
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	89 c2                	mov    %eax,%edx
  801722:	85 c0                	test   %eax,%eax
  801724:	0f 88 2c 01 00 00    	js     801856 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172a:	83 ec 04             	sub    $0x4,%esp
  80172d:	68 07 04 00 00       	push   $0x407
  801732:	ff 75 f4             	pushl  -0xc(%ebp)
  801735:	6a 00                	push   $0x0
  801737:	e8 bf f3 ff ff       	call   800afb <sys_page_alloc>
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	89 c2                	mov    %eax,%edx
  801741:	85 c0                	test   %eax,%eax
  801743:	0f 88 0d 01 00 00    	js     801856 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801749:	83 ec 0c             	sub    $0xc,%esp
  80174c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174f:	50                   	push   %eax
  801750:	e8 29 f6 ff ff       	call   800d7e <fd_alloc>
  801755:	89 c3                	mov    %eax,%ebx
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 c0                	test   %eax,%eax
  80175c:	0f 88 e2 00 00 00    	js     801844 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801762:	83 ec 04             	sub    $0x4,%esp
  801765:	68 07 04 00 00       	push   $0x407
  80176a:	ff 75 f0             	pushl  -0x10(%ebp)
  80176d:	6a 00                	push   $0x0
  80176f:	e8 87 f3 ff ff       	call   800afb <sys_page_alloc>
  801774:	89 c3                	mov    %eax,%ebx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	0f 88 c3 00 00 00    	js     801844 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801781:	83 ec 0c             	sub    $0xc,%esp
  801784:	ff 75 f4             	pushl  -0xc(%ebp)
  801787:	e8 db f5 ff ff       	call   800d67 <fd2data>
  80178c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178e:	83 c4 0c             	add    $0xc,%esp
  801791:	68 07 04 00 00       	push   $0x407
  801796:	50                   	push   %eax
  801797:	6a 00                	push   $0x0
  801799:	e8 5d f3 ff ff       	call   800afb <sys_page_alloc>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	0f 88 89 00 00 00    	js     801834 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ab:	83 ec 0c             	sub    $0xc,%esp
  8017ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b1:	e8 b1 f5 ff ff       	call   800d67 <fd2data>
  8017b6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017bd:	50                   	push   %eax
  8017be:	6a 00                	push   $0x0
  8017c0:	56                   	push   %esi
  8017c1:	6a 00                	push   $0x0
  8017c3:	e8 76 f3 ff ff       	call   800b3e <sys_page_map>
  8017c8:	89 c3                	mov    %eax,%ebx
  8017ca:	83 c4 20             	add    $0x20,%esp
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 55                	js     801826 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017d1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017da:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017e6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801801:	e8 51 f5 ff ff       	call   800d57 <fd2num>
  801806:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801809:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80180b:	83 c4 04             	add    $0x4,%esp
  80180e:	ff 75 f0             	pushl  -0x10(%ebp)
  801811:	e8 41 f5 ff ff       	call   800d57 <fd2num>
  801816:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801819:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	ba 00 00 00 00       	mov    $0x0,%edx
  801824:	eb 30                	jmp    801856 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801826:	83 ec 08             	sub    $0x8,%esp
  801829:	56                   	push   %esi
  80182a:	6a 00                	push   $0x0
  80182c:	e8 4f f3 ff ff       	call   800b80 <sys_page_unmap>
  801831:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	ff 75 f0             	pushl  -0x10(%ebp)
  80183a:	6a 00                	push   $0x0
  80183c:	e8 3f f3 ff ff       	call   800b80 <sys_page_unmap>
  801841:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	ff 75 f4             	pushl  -0xc(%ebp)
  80184a:	6a 00                	push   $0x0
  80184c:	e8 2f f3 ff ff       	call   800b80 <sys_page_unmap>
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801856:	89 d0                	mov    %edx,%eax
  801858:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185b:	5b                   	pop    %ebx
  80185c:	5e                   	pop    %esi
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801868:	50                   	push   %eax
  801869:	ff 75 08             	pushl  0x8(%ebp)
  80186c:	e8 5c f5 ff ff       	call   800dcd <fd_lookup>
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	85 c0                	test   %eax,%eax
  801876:	78 18                	js     801890 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801878:	83 ec 0c             	sub    $0xc,%esp
  80187b:	ff 75 f4             	pushl  -0xc(%ebp)
  80187e:	e8 e4 f4 ff ff       	call   800d67 <fd2data>
	return _pipeisclosed(fd, p);
  801883:	89 c2                	mov    %eax,%edx
  801885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801888:	e8 21 fd ff ff       	call   8015ae <_pipeisclosed>
  80188d:	83 c4 10             	add    $0x10,%esp
}
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801895:	b8 00 00 00 00       	mov    $0x0,%eax
  80189a:	5d                   	pop    %ebp
  80189b:	c3                   	ret    

0080189c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018a2:	68 68 22 80 00       	push   $0x802268
  8018a7:	ff 75 0c             	pushl  0xc(%ebp)
  8018aa:	e8 49 ee ff ff       	call   8006f8 <strcpy>
	return 0;
}
  8018af:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	57                   	push   %edi
  8018ba:	56                   	push   %esi
  8018bb:	53                   	push   %ebx
  8018bc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018c7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018cd:	eb 2d                	jmp    8018fc <devcons_write+0x46>
		m = n - tot;
  8018cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018d2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018d4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018d7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018dc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018df:	83 ec 04             	sub    $0x4,%esp
  8018e2:	53                   	push   %ebx
  8018e3:	03 45 0c             	add    0xc(%ebp),%eax
  8018e6:	50                   	push   %eax
  8018e7:	57                   	push   %edi
  8018e8:	e8 9d ef ff ff       	call   80088a <memmove>
		sys_cputs(buf, m);
  8018ed:	83 c4 08             	add    $0x8,%esp
  8018f0:	53                   	push   %ebx
  8018f1:	57                   	push   %edi
  8018f2:	e8 48 f1 ff ff       	call   800a3f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f7:	01 de                	add    %ebx,%esi
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	89 f0                	mov    %esi,%eax
  8018fe:	3b 75 10             	cmp    0x10(%ebp),%esi
  801901:	72 cc                	jb     8018cf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801903:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5f                   	pop    %edi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	83 ec 08             	sub    $0x8,%esp
  801911:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801916:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80191a:	74 2a                	je     801946 <devcons_read+0x3b>
  80191c:	eb 05                	jmp    801923 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80191e:	e8 b9 f1 ff ff       	call   800adc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801923:	e8 35 f1 ff ff       	call   800a5d <sys_cgetc>
  801928:	85 c0                	test   %eax,%eax
  80192a:	74 f2                	je     80191e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 16                	js     801946 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801930:	83 f8 04             	cmp    $0x4,%eax
  801933:	74 0c                	je     801941 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801935:	8b 55 0c             	mov    0xc(%ebp),%edx
  801938:	88 02                	mov    %al,(%edx)
	return 1;
  80193a:	b8 01 00 00 00       	mov    $0x1,%eax
  80193f:	eb 05                	jmp    801946 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801941:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801954:	6a 01                	push   $0x1
  801956:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801959:	50                   	push   %eax
  80195a:	e8 e0 f0 ff ff       	call   800a3f <sys_cputs>
}
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <getchar>:

int
getchar(void)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80196a:	6a 01                	push   $0x1
  80196c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80196f:	50                   	push   %eax
  801970:	6a 00                	push   $0x0
  801972:	e8 bc f6 ff ff       	call   801033 <read>
	if (r < 0)
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	78 0f                	js     80198d <getchar+0x29>
		return r;
	if (r < 1)
  80197e:	85 c0                	test   %eax,%eax
  801980:	7e 06                	jle    801988 <getchar+0x24>
		return -E_EOF;
	return c;
  801982:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801986:	eb 05                	jmp    80198d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801988:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801995:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801998:	50                   	push   %eax
  801999:	ff 75 08             	pushl  0x8(%ebp)
  80199c:	e8 2c f4 ff ff       	call   800dcd <fd_lookup>
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	78 11                	js     8019b9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b1:	39 10                	cmp    %edx,(%eax)
  8019b3:	0f 94 c0             	sete   %al
  8019b6:	0f b6 c0             	movzbl %al,%eax
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <opencons>:

int
opencons(void)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c4:	50                   	push   %eax
  8019c5:	e8 b4 f3 ff ff       	call   800d7e <fd_alloc>
  8019ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8019cd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	78 3e                	js     801a11 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019d3:	83 ec 04             	sub    $0x4,%esp
  8019d6:	68 07 04 00 00       	push   $0x407
  8019db:	ff 75 f4             	pushl  -0xc(%ebp)
  8019de:	6a 00                	push   $0x0
  8019e0:	e8 16 f1 ff ff       	call   800afb <sys_page_alloc>
  8019e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 23                	js     801a11 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019ee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	50                   	push   %eax
  801a07:	e8 4b f3 ff ff       	call   800d57 <fd2num>
  801a0c:	89 c2                	mov    %eax,%edx
  801a0e:	83 c4 10             	add    $0x10,%esp
}
  801a11:	89 d0                	mov    %edx,%eax
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	56                   	push   %esi
  801a19:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a1a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a1d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a23:	e8 95 f0 ff ff       	call   800abd <sys_getenvid>
  801a28:	83 ec 0c             	sub    $0xc,%esp
  801a2b:	ff 75 0c             	pushl  0xc(%ebp)
  801a2e:	ff 75 08             	pushl  0x8(%ebp)
  801a31:	56                   	push   %esi
  801a32:	50                   	push   %eax
  801a33:	68 74 22 80 00       	push   $0x802274
  801a38:	e8 36 e7 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a3d:	83 c4 18             	add    $0x18,%esp
  801a40:	53                   	push   %ebx
  801a41:	ff 75 10             	pushl  0x10(%ebp)
  801a44:	e8 d9 e6 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801a49:	c7 04 24 61 22 80 00 	movl   $0x802261,(%esp)
  801a50:	e8 1e e7 ff ff       	call   800173 <cprintf>
  801a55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a58:	cc                   	int3   
  801a59:	eb fd                	jmp    801a58 <_panic+0x43>

00801a5b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
  801a60:	8b 75 08             	mov    0x8(%ebp),%esi
  801a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801a69:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801a6b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a70:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	50                   	push   %eax
  801a77:	e8 2f f2 ff ff       	call   800cab <sys_ipc_recv>

	if (from_env_store != NULL)
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	85 f6                	test   %esi,%esi
  801a81:	74 14                	je     801a97 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801a83:	ba 00 00 00 00       	mov    $0x0,%edx
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 09                	js     801a95 <ipc_recv+0x3a>
  801a8c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a92:	8b 52 74             	mov    0x74(%edx),%edx
  801a95:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a97:	85 db                	test   %ebx,%ebx
  801a99:	74 14                	je     801aaf <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 09                	js     801aad <ipc_recv+0x52>
  801aa4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aaa:	8b 52 78             	mov    0x78(%edx),%edx
  801aad:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	78 08                	js     801abb <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ab3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab8:	8b 40 70             	mov    0x70(%eax),%eax
}
  801abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5d                   	pop    %ebp
  801ac1:	c3                   	ret    

00801ac2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	57                   	push   %edi
  801ac6:	56                   	push   %esi
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 0c             	sub    $0xc,%esp
  801acb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ace:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ad4:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ad6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801adb:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ade:	ff 75 14             	pushl  0x14(%ebp)
  801ae1:	53                   	push   %ebx
  801ae2:	56                   	push   %esi
  801ae3:	57                   	push   %edi
  801ae4:	e8 9f f1 ff ff       	call   800c88 <sys_ipc_try_send>

		if (err < 0) {
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	85 c0                	test   %eax,%eax
  801aee:	79 1e                	jns    801b0e <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801af0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af3:	75 07                	jne    801afc <ipc_send+0x3a>
				sys_yield();
  801af5:	e8 e2 ef ff ff       	call   800adc <sys_yield>
  801afa:	eb e2                	jmp    801ade <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801afc:	50                   	push   %eax
  801afd:	68 98 22 80 00       	push   $0x802298
  801b02:	6a 49                	push   $0x49
  801b04:	68 a5 22 80 00       	push   $0x8022a5
  801b09:	e8 07 ff ff ff       	call   801a15 <_panic>
		}

	} while (err < 0);

}
  801b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5f                   	pop    %edi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b21:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b24:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b2a:	8b 52 50             	mov    0x50(%edx),%edx
  801b2d:	39 ca                	cmp    %ecx,%edx
  801b2f:	75 0d                	jne    801b3e <ipc_find_env+0x28>
			return envs[i].env_id;
  801b31:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b39:	8b 40 48             	mov    0x48(%eax),%eax
  801b3c:	eb 0f                	jmp    801b4d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b3e:	83 c0 01             	add    $0x1,%eax
  801b41:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b46:	75 d9                	jne    801b21 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b55:	89 d0                	mov    %edx,%eax
  801b57:	c1 e8 16             	shr    $0x16,%eax
  801b5a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b66:	f6 c1 01             	test   $0x1,%cl
  801b69:	74 1d                	je     801b88 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b6b:	c1 ea 0c             	shr    $0xc,%edx
  801b6e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b75:	f6 c2 01             	test   $0x1,%dl
  801b78:	74 0e                	je     801b88 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7a:	c1 ea 0c             	shr    $0xc,%edx
  801b7d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b84:	ef 
  801b85:	0f b7 c0             	movzwl %ax,%eax
}
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    
  801b8a:	66 90                	xchg   %ax,%ax
  801b8c:	66 90                	xchg   %ax,%ax
  801b8e:	66 90                	xchg   %ax,%ax

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ba7:	85 f6                	test   %esi,%esi
  801ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bad:	89 ca                	mov    %ecx,%edx
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	75 3d                	jne    801bf0 <__udivdi3+0x60>
  801bb3:	39 cf                	cmp    %ecx,%edi
  801bb5:	0f 87 c5 00 00 00    	ja     801c80 <__udivdi3+0xf0>
  801bbb:	85 ff                	test   %edi,%edi
  801bbd:	89 fd                	mov    %edi,%ebp
  801bbf:	75 0b                	jne    801bcc <__udivdi3+0x3c>
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	31 d2                	xor    %edx,%edx
  801bc8:	f7 f7                	div    %edi
  801bca:	89 c5                	mov    %eax,%ebp
  801bcc:	89 c8                	mov    %ecx,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f5                	div    %ebp
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	89 cf                	mov    %ecx,%edi
  801bd8:	f7 f5                	div    %ebp
  801bda:	89 c3                	mov    %eax,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	39 ce                	cmp    %ecx,%esi
  801bf2:	77 74                	ja     801c68 <__udivdi3+0xd8>
  801bf4:	0f bd fe             	bsr    %esi,%edi
  801bf7:	83 f7 1f             	xor    $0x1f,%edi
  801bfa:	0f 84 98 00 00 00    	je     801c98 <__udivdi3+0x108>
  801c00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	89 c5                	mov    %eax,%ebp
  801c09:	29 fb                	sub    %edi,%ebx
  801c0b:	d3 e6                	shl    %cl,%esi
  801c0d:	89 d9                	mov    %ebx,%ecx
  801c0f:	d3 ed                	shr    %cl,%ebp
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e0                	shl    %cl,%eax
  801c15:	09 ee                	or     %ebp,%esi
  801c17:	89 d9                	mov    %ebx,%ecx
  801c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1d:	89 d5                	mov    %edx,%ebp
  801c1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c23:	d3 ed                	shr    %cl,%ebp
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	d3 e2                	shl    %cl,%edx
  801c29:	89 d9                	mov    %ebx,%ecx
  801c2b:	d3 e8                	shr    %cl,%eax
  801c2d:	09 c2                	or     %eax,%edx
  801c2f:	89 d0                	mov    %edx,%eax
  801c31:	89 ea                	mov    %ebp,%edx
  801c33:	f7 f6                	div    %esi
  801c35:	89 d5                	mov    %edx,%ebp
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	f7 64 24 0c          	mull   0xc(%esp)
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	72 10                	jb     801c51 <__udivdi3+0xc1>
  801c41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e6                	shl    %cl,%esi
  801c49:	39 c6                	cmp    %eax,%esi
  801c4b:	73 07                	jae    801c54 <__udivdi3+0xc4>
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	75 03                	jne    801c54 <__udivdi3+0xc4>
  801c51:	83 eb 01             	sub    $0x1,%ebx
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 d8                	mov    %ebx,%eax
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	31 ff                	xor    %edi,%edi
  801c6a:	31 db                	xor    %ebx,%ebx
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	89 fa                	mov    %edi,%edx
  801c70:	83 c4 1c             	add    $0x1c,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	90                   	nop
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	f7 f7                	div    %edi
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	89 fa                	mov    %edi,%edx
  801c8c:	83 c4 1c             	add    $0x1c,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
  801c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c98:	39 ce                	cmp    %ecx,%esi
  801c9a:	72 0c                	jb     801ca8 <__udivdi3+0x118>
  801c9c:	31 db                	xor    %ebx,%ebx
  801c9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ca2:	0f 87 34 ff ff ff    	ja     801bdc <__udivdi3+0x4c>
  801ca8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cad:	e9 2a ff ff ff       	jmp    801bdc <__udivdi3+0x4c>
  801cb2:	66 90                	xchg   %ax,%ax
  801cb4:	66 90                	xchg   %ax,%ax
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ccb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 d2                	test   %edx,%edx
  801cd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ce1:	89 f3                	mov    %esi,%ebx
  801ce3:	89 3c 24             	mov    %edi,(%esp)
  801ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cea:	75 1c                	jne    801d08 <__umoddi3+0x48>
  801cec:	39 f7                	cmp    %esi,%edi
  801cee:	76 50                	jbe    801d40 <__umoddi3+0x80>
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	f7 f7                	div    %edi
  801cf6:	89 d0                	mov    %edx,%eax
  801cf8:	31 d2                	xor    %edx,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	39 f2                	cmp    %esi,%edx
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	77 52                	ja     801d60 <__umoddi3+0xa0>
  801d0e:	0f bd ea             	bsr    %edx,%ebp
  801d11:	83 f5 1f             	xor    $0x1f,%ebp
  801d14:	75 5a                	jne    801d70 <__umoddi3+0xb0>
  801d16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d1a:	0f 82 e0 00 00 00    	jb     801e00 <__umoddi3+0x140>
  801d20:	39 0c 24             	cmp    %ecx,(%esp)
  801d23:	0f 86 d7 00 00 00    	jbe    801e00 <__umoddi3+0x140>
  801d29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	85 ff                	test   %edi,%edi
  801d42:	89 fd                	mov    %edi,%ebp
  801d44:	75 0b                	jne    801d51 <__umoddi3+0x91>
  801d46:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4b:	31 d2                	xor    %edx,%edx
  801d4d:	f7 f7                	div    %edi
  801d4f:	89 c5                	mov    %eax,%ebp
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	f7 f5                	div    %ebp
  801d57:	89 c8                	mov    %ecx,%eax
  801d59:	f7 f5                	div    %ebp
  801d5b:	89 d0                	mov    %edx,%eax
  801d5d:	eb 99                	jmp    801cf8 <__umoddi3+0x38>
  801d5f:	90                   	nop
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 1c             	add    $0x1c,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	8b 34 24             	mov    (%esp),%esi
  801d73:	bf 20 00 00 00       	mov    $0x20,%edi
  801d78:	89 e9                	mov    %ebp,%ecx
  801d7a:	29 ef                	sub    %ebp,%edi
  801d7c:	d3 e0                	shl    %cl,%eax
  801d7e:	89 f9                	mov    %edi,%ecx
  801d80:	89 f2                	mov    %esi,%edx
  801d82:	d3 ea                	shr    %cl,%edx
  801d84:	89 e9                	mov    %ebp,%ecx
  801d86:	09 c2                	or     %eax,%edx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 14 24             	mov    %edx,(%esp)
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	d3 e2                	shl    %cl,%edx
  801d91:	89 f9                	mov    %edi,%ecx
  801d93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d9b:	d3 e8                	shr    %cl,%eax
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	d3 e3                	shl    %cl,%ebx
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 d0                	mov    %edx,%eax
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	09 d8                	or     %ebx,%eax
  801dad:	89 d3                	mov    %edx,%ebx
  801daf:	89 f2                	mov    %esi,%edx
  801db1:	f7 34 24             	divl   (%esp)
  801db4:	89 d6                	mov    %edx,%esi
  801db6:	d3 e3                	shl    %cl,%ebx
  801db8:	f7 64 24 04          	mull   0x4(%esp)
  801dbc:	39 d6                	cmp    %edx,%esi
  801dbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc2:	89 d1                	mov    %edx,%ecx
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	72 08                	jb     801dd0 <__umoddi3+0x110>
  801dc8:	75 11                	jne    801ddb <__umoddi3+0x11b>
  801dca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dce:	73 0b                	jae    801ddb <__umoddi3+0x11b>
  801dd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dd4:	1b 14 24             	sbb    (%esp),%edx
  801dd7:	89 d1                	mov    %edx,%ecx
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ddf:	29 da                	sub    %ebx,%edx
  801de1:	19 ce                	sbb    %ecx,%esi
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 f0                	mov    %esi,%eax
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	d3 ea                	shr    %cl,%edx
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	d3 ee                	shr    %cl,%esi
  801df1:	09 d0                	or     %edx,%eax
  801df3:	89 f2                	mov    %esi,%edx
  801df5:	83 c4 1c             	add    $0x1c,%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	29 f9                	sub    %edi,%ecx
  801e02:	19 d6                	sbb    %edx,%esi
  801e04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e0c:	e9 18 ff ff ff       	jmp    801d29 <__umoddi3+0x69>
