
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
  800045:	68 60 23 80 00       	push   $0x802360
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
  80006c:	e8 1e 0d 00 00       	call   800d8f <set_pgfault_handler>
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
  8000cc:	e8 f4 0e 00 00       	call   800fc5 <close_all>
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
  8001d6:	e8 e5 1e 00 00       	call   8020c0 <__udivdi3>
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
  800219:	e8 d2 1f 00 00       	call   8021f0 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 86 23 80 00 	movsbl 0x802386(%eax),%eax
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
  80031d:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
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
  8003e1:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	75 18                	jne    800404 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ec:	50                   	push   %eax
  8003ed:	68 9e 23 80 00       	push   $0x80239e
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
  800405:	68 55 27 80 00       	push   $0x802755
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
  800429:	b8 97 23 80 00       	mov    $0x802397,%eax
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
  800aa4:	68 7f 26 80 00       	push   $0x80267f
  800aa9:	6a 23                	push   $0x23
  800aab:	68 9c 26 80 00       	push   $0x80269c
  800ab0:	e8 89 14 00 00       	call   801f3e <_panic>

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
  800b25:	68 7f 26 80 00       	push   $0x80267f
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 9c 26 80 00       	push   $0x80269c
  800b31:	e8 08 14 00 00       	call   801f3e <_panic>

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
  800b67:	68 7f 26 80 00       	push   $0x80267f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 9c 26 80 00       	push   $0x80269c
  800b73:	e8 c6 13 00 00       	call   801f3e <_panic>

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
  800ba9:	68 7f 26 80 00       	push   $0x80267f
  800bae:	6a 23                	push   $0x23
  800bb0:	68 9c 26 80 00       	push   $0x80269c
  800bb5:	e8 84 13 00 00       	call   801f3e <_panic>

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
  800beb:	68 7f 26 80 00       	push   $0x80267f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 9c 26 80 00       	push   $0x80269c
  800bf7:	e8 42 13 00 00       	call   801f3e <_panic>

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
  800c2d:	68 7f 26 80 00       	push   $0x80267f
  800c32:	6a 23                	push   $0x23
  800c34:	68 9c 26 80 00       	push   $0x80269c
  800c39:	e8 00 13 00 00       	call   801f3e <_panic>

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
  800c6f:	68 7f 26 80 00       	push   $0x80267f
  800c74:	6a 23                	push   $0x23
  800c76:	68 9c 26 80 00       	push   $0x80269c
  800c7b:	e8 be 12 00 00       	call   801f3e <_panic>

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
  800cd3:	68 7f 26 80 00       	push   $0x80267f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 9c 26 80 00       	push   $0x80269c
  800cdf:	e8 5a 12 00 00       	call   801f3e <_panic>

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
  800d34:	68 7f 26 80 00       	push   $0x80267f
  800d39:	6a 23                	push   $0x23
  800d3b:	68 9c 26 80 00       	push   $0x80269c
  800d40:	e8 f9 11 00 00       	call   801f3e <_panic>

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

00800d4d <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5b:	b8 10 00 00 00       	mov    $0x10,%eax
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	89 df                	mov    %ebx,%edi
  800d68:	89 de                	mov    %ebx,%esi
  800d6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 17                	jle    800d87 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 10                	push   $0x10
  800d76:	68 7f 26 80 00       	push   $0x80267f
  800d7b:	6a 23                	push   $0x23
  800d7d:	68 9c 26 80 00       	push   $0x80269c
  800d82:	e8 b7 11 00 00       	call   801f3e <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d95:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800d9c:	75 2e                	jne    800dcc <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800d9e:	e8 1a fd ff ff       	call   800abd <sys_getenvid>
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	68 07 0e 00 00       	push   $0xe07
  800dab:	68 00 f0 bf ee       	push   $0xeebff000
  800db0:	50                   	push   %eax
  800db1:	e8 45 fd ff ff       	call   800afb <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800db6:	e8 02 fd ff ff       	call   800abd <sys_getenvid>
  800dbb:	83 c4 08             	add    $0x8,%esp
  800dbe:	68 d6 0d 80 00       	push   $0x800dd6
  800dc3:	50                   	push   %eax
  800dc4:	e8 7d fe ff ff       	call   800c46 <sys_env_set_pgfault_upcall>
  800dc9:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcf:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    

00800dd6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dd6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dd7:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800ddc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dde:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  800de1:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800de5:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800de9:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800dec:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800def:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  800df0:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800df3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800df4:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800df5:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800df9:	c3                   	ret    

00800dfa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	05 00 00 00 30       	add    $0x30000000,%eax
  800e05:	c1 e8 0c             	shr    $0xc,%eax
}
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	05 00 00 00 30       	add    $0x30000000,%eax
  800e15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e1a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e27:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e2c:	89 c2                	mov    %eax,%edx
  800e2e:	c1 ea 16             	shr    $0x16,%edx
  800e31:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e38:	f6 c2 01             	test   $0x1,%dl
  800e3b:	74 11                	je     800e4e <fd_alloc+0x2d>
  800e3d:	89 c2                	mov    %eax,%edx
  800e3f:	c1 ea 0c             	shr    $0xc,%edx
  800e42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e49:	f6 c2 01             	test   $0x1,%dl
  800e4c:	75 09                	jne    800e57 <fd_alloc+0x36>
			*fd_store = fd;
  800e4e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e50:	b8 00 00 00 00       	mov    $0x0,%eax
  800e55:	eb 17                	jmp    800e6e <fd_alloc+0x4d>
  800e57:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e5c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e61:	75 c9                	jne    800e2c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e63:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e69:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e76:	83 f8 1f             	cmp    $0x1f,%eax
  800e79:	77 36                	ja     800eb1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e7b:	c1 e0 0c             	shl    $0xc,%eax
  800e7e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e83:	89 c2                	mov    %eax,%edx
  800e85:	c1 ea 16             	shr    $0x16,%edx
  800e88:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8f:	f6 c2 01             	test   $0x1,%dl
  800e92:	74 24                	je     800eb8 <fd_lookup+0x48>
  800e94:	89 c2                	mov    %eax,%edx
  800e96:	c1 ea 0c             	shr    $0xc,%edx
  800e99:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea0:	f6 c2 01             	test   $0x1,%dl
  800ea3:	74 1a                	je     800ebf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ea5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea8:	89 02                	mov    %eax,(%edx)
	return 0;
  800eaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaf:	eb 13                	jmp    800ec4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb6:	eb 0c                	jmp    800ec4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebd:	eb 05                	jmp    800ec4 <fd_lookup+0x54>
  800ebf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	83 ec 08             	sub    $0x8,%esp
  800ecc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ecf:	ba 28 27 80 00       	mov    $0x802728,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ed4:	eb 13                	jmp    800ee9 <dev_lookup+0x23>
  800ed6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ed9:	39 08                	cmp    %ecx,(%eax)
  800edb:	75 0c                	jne    800ee9 <dev_lookup+0x23>
			*dev = devtab[i];
  800edd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee7:	eb 2e                	jmp    800f17 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ee9:	8b 02                	mov    (%edx),%eax
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	75 e7                	jne    800ed6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eef:	a1 08 40 80 00       	mov    0x804008,%eax
  800ef4:	8b 40 48             	mov    0x48(%eax),%eax
  800ef7:	83 ec 04             	sub    $0x4,%esp
  800efa:	51                   	push   %ecx
  800efb:	50                   	push   %eax
  800efc:	68 ac 26 80 00       	push   $0x8026ac
  800f01:	e8 6d f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800f06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    

00800f19 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	56                   	push   %esi
  800f1d:	53                   	push   %ebx
  800f1e:	83 ec 10             	sub    $0x10,%esp
  800f21:	8b 75 08             	mov    0x8(%ebp),%esi
  800f24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2a:	50                   	push   %eax
  800f2b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f31:	c1 e8 0c             	shr    $0xc,%eax
  800f34:	50                   	push   %eax
  800f35:	e8 36 ff ff ff       	call   800e70 <fd_lookup>
  800f3a:	83 c4 08             	add    $0x8,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	78 05                	js     800f46 <fd_close+0x2d>
	    || fd != fd2)
  800f41:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f44:	74 0c                	je     800f52 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f46:	84 db                	test   %bl,%bl
  800f48:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4d:	0f 44 c2             	cmove  %edx,%eax
  800f50:	eb 41                	jmp    800f93 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f52:	83 ec 08             	sub    $0x8,%esp
  800f55:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f58:	50                   	push   %eax
  800f59:	ff 36                	pushl  (%esi)
  800f5b:	e8 66 ff ff ff       	call   800ec6 <dev_lookup>
  800f60:	89 c3                	mov    %eax,%ebx
  800f62:	83 c4 10             	add    $0x10,%esp
  800f65:	85 c0                	test   %eax,%eax
  800f67:	78 1a                	js     800f83 <fd_close+0x6a>
		if (dev->dev_close)
  800f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f6f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f74:	85 c0                	test   %eax,%eax
  800f76:	74 0b                	je     800f83 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	56                   	push   %esi
  800f7c:	ff d0                	call   *%eax
  800f7e:	89 c3                	mov    %eax,%ebx
  800f80:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f83:	83 ec 08             	sub    $0x8,%esp
  800f86:	56                   	push   %esi
  800f87:	6a 00                	push   $0x0
  800f89:	e8 f2 fb ff ff       	call   800b80 <sys_page_unmap>
	return r;
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	89 d8                	mov    %ebx,%eax
}
  800f93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f96:	5b                   	pop    %ebx
  800f97:	5e                   	pop    %esi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa3:	50                   	push   %eax
  800fa4:	ff 75 08             	pushl  0x8(%ebp)
  800fa7:	e8 c4 fe ff ff       	call   800e70 <fd_lookup>
  800fac:	83 c4 08             	add    $0x8,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 10                	js     800fc3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fb3:	83 ec 08             	sub    $0x8,%esp
  800fb6:	6a 01                	push   $0x1
  800fb8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fbb:	e8 59 ff ff ff       	call   800f19 <fd_close>
  800fc0:	83 c4 10             	add    $0x10,%esp
}
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    

00800fc5 <close_all>:

void
close_all(void)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	53                   	push   %ebx
  800fc9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fcc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	53                   	push   %ebx
  800fd5:	e8 c0 ff ff ff       	call   800f9a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fda:	83 c3 01             	add    $0x1,%ebx
  800fdd:	83 c4 10             	add    $0x10,%esp
  800fe0:	83 fb 20             	cmp    $0x20,%ebx
  800fe3:	75 ec                	jne    800fd1 <close_all+0xc>
		close(i);
}
  800fe5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe8:	c9                   	leave  
  800fe9:	c3                   	ret    

00800fea <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	83 ec 2c             	sub    $0x2c,%esp
  800ff3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ff6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff9:	50                   	push   %eax
  800ffa:	ff 75 08             	pushl  0x8(%ebp)
  800ffd:	e8 6e fe ff ff       	call   800e70 <fd_lookup>
  801002:	83 c4 08             	add    $0x8,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	0f 88 c1 00 00 00    	js     8010ce <dup+0xe4>
		return r;
	close(newfdnum);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	56                   	push   %esi
  801011:	e8 84 ff ff ff       	call   800f9a <close>

	newfd = INDEX2FD(newfdnum);
  801016:	89 f3                	mov    %esi,%ebx
  801018:	c1 e3 0c             	shl    $0xc,%ebx
  80101b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801021:	83 c4 04             	add    $0x4,%esp
  801024:	ff 75 e4             	pushl  -0x1c(%ebp)
  801027:	e8 de fd ff ff       	call   800e0a <fd2data>
  80102c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80102e:	89 1c 24             	mov    %ebx,(%esp)
  801031:	e8 d4 fd ff ff       	call   800e0a <fd2data>
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80103c:	89 f8                	mov    %edi,%eax
  80103e:	c1 e8 16             	shr    $0x16,%eax
  801041:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801048:	a8 01                	test   $0x1,%al
  80104a:	74 37                	je     801083 <dup+0x99>
  80104c:	89 f8                	mov    %edi,%eax
  80104e:	c1 e8 0c             	shr    $0xc,%eax
  801051:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801058:	f6 c2 01             	test   $0x1,%dl
  80105b:	74 26                	je     801083 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80105d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	25 07 0e 00 00       	and    $0xe07,%eax
  80106c:	50                   	push   %eax
  80106d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801070:	6a 00                	push   $0x0
  801072:	57                   	push   %edi
  801073:	6a 00                	push   $0x0
  801075:	e8 c4 fa ff ff       	call   800b3e <sys_page_map>
  80107a:	89 c7                	mov    %eax,%edi
  80107c:	83 c4 20             	add    $0x20,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	78 2e                	js     8010b1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801083:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801086:	89 d0                	mov    %edx,%eax
  801088:	c1 e8 0c             	shr    $0xc,%eax
  80108b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	25 07 0e 00 00       	and    $0xe07,%eax
  80109a:	50                   	push   %eax
  80109b:	53                   	push   %ebx
  80109c:	6a 00                	push   $0x0
  80109e:	52                   	push   %edx
  80109f:	6a 00                	push   $0x0
  8010a1:	e8 98 fa ff ff       	call   800b3e <sys_page_map>
  8010a6:	89 c7                	mov    %eax,%edi
  8010a8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010ab:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ad:	85 ff                	test   %edi,%edi
  8010af:	79 1d                	jns    8010ce <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b1:	83 ec 08             	sub    $0x8,%esp
  8010b4:	53                   	push   %ebx
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 c4 fa ff ff       	call   800b80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010bc:	83 c4 08             	add    $0x8,%esp
  8010bf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c2:	6a 00                	push   $0x0
  8010c4:	e8 b7 fa ff ff       	call   800b80 <sys_page_unmap>
	return r;
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	89 f8                	mov    %edi,%eax
}
  8010ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	53                   	push   %ebx
  8010da:	83 ec 14             	sub    $0x14,%esp
  8010dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e3:	50                   	push   %eax
  8010e4:	53                   	push   %ebx
  8010e5:	e8 86 fd ff ff       	call   800e70 <fd_lookup>
  8010ea:	83 c4 08             	add    $0x8,%esp
  8010ed:	89 c2                	mov    %eax,%edx
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	78 6d                	js     801160 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f3:	83 ec 08             	sub    $0x8,%esp
  8010f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f9:	50                   	push   %eax
  8010fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010fd:	ff 30                	pushl  (%eax)
  8010ff:	e8 c2 fd ff ff       	call   800ec6 <dev_lookup>
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	85 c0                	test   %eax,%eax
  801109:	78 4c                	js     801157 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80110b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80110e:	8b 42 08             	mov    0x8(%edx),%eax
  801111:	83 e0 03             	and    $0x3,%eax
  801114:	83 f8 01             	cmp    $0x1,%eax
  801117:	75 21                	jne    80113a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801119:	a1 08 40 80 00       	mov    0x804008,%eax
  80111e:	8b 40 48             	mov    0x48(%eax),%eax
  801121:	83 ec 04             	sub    $0x4,%esp
  801124:	53                   	push   %ebx
  801125:	50                   	push   %eax
  801126:	68 ed 26 80 00       	push   $0x8026ed
  80112b:	e8 43 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801138:	eb 26                	jmp    801160 <read+0x8a>
	}
	if (!dev->dev_read)
  80113a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113d:	8b 40 08             	mov    0x8(%eax),%eax
  801140:	85 c0                	test   %eax,%eax
  801142:	74 17                	je     80115b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	ff 75 10             	pushl  0x10(%ebp)
  80114a:	ff 75 0c             	pushl  0xc(%ebp)
  80114d:	52                   	push   %edx
  80114e:	ff d0                	call   *%eax
  801150:	89 c2                	mov    %eax,%edx
  801152:	83 c4 10             	add    $0x10,%esp
  801155:	eb 09                	jmp    801160 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801157:	89 c2                	mov    %eax,%edx
  801159:	eb 05                	jmp    801160 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80115b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801160:	89 d0                	mov    %edx,%eax
  801162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	8b 7d 08             	mov    0x8(%ebp),%edi
  801173:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801176:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117b:	eb 21                	jmp    80119e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80117d:	83 ec 04             	sub    $0x4,%esp
  801180:	89 f0                	mov    %esi,%eax
  801182:	29 d8                	sub    %ebx,%eax
  801184:	50                   	push   %eax
  801185:	89 d8                	mov    %ebx,%eax
  801187:	03 45 0c             	add    0xc(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	57                   	push   %edi
  80118c:	e8 45 ff ff ff       	call   8010d6 <read>
		if (m < 0)
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	85 c0                	test   %eax,%eax
  801196:	78 10                	js     8011a8 <readn+0x41>
			return m;
		if (m == 0)
  801198:	85 c0                	test   %eax,%eax
  80119a:	74 0a                	je     8011a6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80119c:	01 c3                	add    %eax,%ebx
  80119e:	39 f3                	cmp    %esi,%ebx
  8011a0:	72 db                	jb     80117d <readn+0x16>
  8011a2:	89 d8                	mov    %ebx,%eax
  8011a4:	eb 02                	jmp    8011a8 <readn+0x41>
  8011a6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	53                   	push   %ebx
  8011b4:	83 ec 14             	sub    $0x14,%esp
  8011b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bd:	50                   	push   %eax
  8011be:	53                   	push   %ebx
  8011bf:	e8 ac fc ff ff       	call   800e70 <fd_lookup>
  8011c4:	83 c4 08             	add    $0x8,%esp
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 68                	js     801235 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d7:	ff 30                	pushl  (%eax)
  8011d9:	e8 e8 fc ff ff       	call   800ec6 <dev_lookup>
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 47                	js     80122c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ec:	75 21                	jne    80120f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f3:	8b 40 48             	mov    0x48(%eax),%eax
  8011f6:	83 ec 04             	sub    $0x4,%esp
  8011f9:	53                   	push   %ebx
  8011fa:	50                   	push   %eax
  8011fb:	68 09 27 80 00       	push   $0x802709
  801200:	e8 6e ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80120d:	eb 26                	jmp    801235 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80120f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801212:	8b 52 0c             	mov    0xc(%edx),%edx
  801215:	85 d2                	test   %edx,%edx
  801217:	74 17                	je     801230 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801219:	83 ec 04             	sub    $0x4,%esp
  80121c:	ff 75 10             	pushl  0x10(%ebp)
  80121f:	ff 75 0c             	pushl  0xc(%ebp)
  801222:	50                   	push   %eax
  801223:	ff d2                	call   *%edx
  801225:	89 c2                	mov    %eax,%edx
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	eb 09                	jmp    801235 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	eb 05                	jmp    801235 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801230:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801235:	89 d0                	mov    %edx,%eax
  801237:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123a:	c9                   	leave  
  80123b:	c3                   	ret    

0080123c <seek>:

int
seek(int fdnum, off_t offset)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801242:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801245:	50                   	push   %eax
  801246:	ff 75 08             	pushl  0x8(%ebp)
  801249:	e8 22 fc ff ff       	call   800e70 <fd_lookup>
  80124e:	83 c4 08             	add    $0x8,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	78 0e                	js     801263 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801255:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801258:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80125e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801263:	c9                   	leave  
  801264:	c3                   	ret    

00801265 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	53                   	push   %ebx
  801269:	83 ec 14             	sub    $0x14,%esp
  80126c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	53                   	push   %ebx
  801274:	e8 f7 fb ff ff       	call   800e70 <fd_lookup>
  801279:	83 c4 08             	add    $0x8,%esp
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 65                	js     8012e7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801282:	83 ec 08             	sub    $0x8,%esp
  801285:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801288:	50                   	push   %eax
  801289:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128c:	ff 30                	pushl  (%eax)
  80128e:	e8 33 fc ff ff       	call   800ec6 <dev_lookup>
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	78 44                	js     8012de <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a1:	75 21                	jne    8012c4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012a3:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012a8:	8b 40 48             	mov    0x48(%eax),%eax
  8012ab:	83 ec 04             	sub    $0x4,%esp
  8012ae:	53                   	push   %ebx
  8012af:	50                   	push   %eax
  8012b0:	68 cc 26 80 00       	push   $0x8026cc
  8012b5:	e8 b9 ee ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c2:	eb 23                	jmp    8012e7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c7:	8b 52 18             	mov    0x18(%edx),%edx
  8012ca:	85 d2                	test   %edx,%edx
  8012cc:	74 14                	je     8012e2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	ff 75 0c             	pushl  0xc(%ebp)
  8012d4:	50                   	push   %eax
  8012d5:	ff d2                	call   *%edx
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	eb 09                	jmp    8012e7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	eb 05                	jmp    8012e7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012e7:	89 d0                	mov    %edx,%eax
  8012e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	53                   	push   %ebx
  8012f2:	83 ec 14             	sub    $0x14,%esp
  8012f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fb:	50                   	push   %eax
  8012fc:	ff 75 08             	pushl  0x8(%ebp)
  8012ff:	e8 6c fb ff ff       	call   800e70 <fd_lookup>
  801304:	83 c4 08             	add    $0x8,%esp
  801307:	89 c2                	mov    %eax,%edx
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 58                	js     801365 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801313:	50                   	push   %eax
  801314:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801317:	ff 30                	pushl  (%eax)
  801319:	e8 a8 fb ff ff       	call   800ec6 <dev_lookup>
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	78 37                	js     80135c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801325:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801328:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80132c:	74 32                	je     801360 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80132e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801331:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801338:	00 00 00 
	stat->st_isdir = 0;
  80133b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801342:	00 00 00 
	stat->st_dev = dev;
  801345:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80134b:	83 ec 08             	sub    $0x8,%esp
  80134e:	53                   	push   %ebx
  80134f:	ff 75 f0             	pushl  -0x10(%ebp)
  801352:	ff 50 14             	call   *0x14(%eax)
  801355:	89 c2                	mov    %eax,%edx
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	eb 09                	jmp    801365 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135c:	89 c2                	mov    %eax,%edx
  80135e:	eb 05                	jmp    801365 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801360:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801365:	89 d0                	mov    %edx,%eax
  801367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136a:	c9                   	leave  
  80136b:	c3                   	ret    

0080136c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	56                   	push   %esi
  801370:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	6a 00                	push   $0x0
  801376:	ff 75 08             	pushl  0x8(%ebp)
  801379:	e8 d6 01 00 00       	call   801554 <open>
  80137e:	89 c3                	mov    %eax,%ebx
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 1b                	js     8013a2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	ff 75 0c             	pushl  0xc(%ebp)
  80138d:	50                   	push   %eax
  80138e:	e8 5b ff ff ff       	call   8012ee <fstat>
  801393:	89 c6                	mov    %eax,%esi
	close(fd);
  801395:	89 1c 24             	mov    %ebx,(%esp)
  801398:	e8 fd fb ff ff       	call   800f9a <close>
	return r;
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	89 f0                	mov    %esi,%eax
}
  8013a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5e                   	pop    %esi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	56                   	push   %esi
  8013ad:	53                   	push   %ebx
  8013ae:	89 c6                	mov    %eax,%esi
  8013b0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013b9:	75 12                	jne    8013cd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013bb:	83 ec 0c             	sub    $0xc,%esp
  8013be:	6a 01                	push   $0x1
  8013c0:	e8 7a 0c 00 00       	call   80203f <ipc_find_env>
  8013c5:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ca:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013cd:	6a 07                	push   $0x7
  8013cf:	68 00 50 80 00       	push   $0x805000
  8013d4:	56                   	push   %esi
  8013d5:	ff 35 00 40 80 00    	pushl  0x804000
  8013db:	e8 0b 0c 00 00       	call   801feb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e0:	83 c4 0c             	add    $0xc,%esp
  8013e3:	6a 00                	push   $0x0
  8013e5:	53                   	push   %ebx
  8013e6:	6a 00                	push   $0x0
  8013e8:	e8 97 0b 00 00       	call   801f84 <ipc_recv>
}
  8013ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f0:	5b                   	pop    %ebx
  8013f1:	5e                   	pop    %esi
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    

008013f4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801400:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801405:	8b 45 0c             	mov    0xc(%ebp),%eax
  801408:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	b8 02 00 00 00       	mov    $0x2,%eax
  801417:	e8 8d ff ff ff       	call   8013a9 <fsipc>
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	8b 40 0c             	mov    0xc(%eax),%eax
  80142a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80142f:	ba 00 00 00 00       	mov    $0x0,%edx
  801434:	b8 06 00 00 00       	mov    $0x6,%eax
  801439:	e8 6b ff ff ff       	call   8013a9 <fsipc>
}
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    

00801440 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	53                   	push   %ebx
  801444:	83 ec 04             	sub    $0x4,%esp
  801447:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80144a:	8b 45 08             	mov    0x8(%ebp),%eax
  80144d:	8b 40 0c             	mov    0xc(%eax),%eax
  801450:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801455:	ba 00 00 00 00       	mov    $0x0,%edx
  80145a:	b8 05 00 00 00       	mov    $0x5,%eax
  80145f:	e8 45 ff ff ff       	call   8013a9 <fsipc>
  801464:	85 c0                	test   %eax,%eax
  801466:	78 2c                	js     801494 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	68 00 50 80 00       	push   $0x805000
  801470:	53                   	push   %ebx
  801471:	e8 82 f2 ff ff       	call   8006f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801476:	a1 80 50 80 00       	mov    0x805080,%eax
  80147b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801481:	a1 84 50 80 00       	mov    0x805084,%eax
  801486:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801494:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801497:	c9                   	leave  
  801498:	c3                   	ret    

00801499 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	83 ec 0c             	sub    $0xc,%esp
  80149f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014ae:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014b3:	50                   	push   %eax
  8014b4:	ff 75 0c             	pushl  0xc(%ebp)
  8014b7:	68 08 50 80 00       	push   $0x805008
  8014bc:	e8 c9 f3 ff ff       	call   80088a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c6:	b8 04 00 00 00       	mov    $0x4,%eax
  8014cb:	e8 d9 fe ff ff       	call   8013a9 <fsipc>

}
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    

008014d2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	56                   	push   %esi
  8014d6:	53                   	push   %ebx
  8014d7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014da:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014e5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8014f5:	e8 af fe ff ff       	call   8013a9 <fsipc>
  8014fa:	89 c3                	mov    %eax,%ebx
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 4b                	js     80154b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801500:	39 c6                	cmp    %eax,%esi
  801502:	73 16                	jae    80151a <devfile_read+0x48>
  801504:	68 3c 27 80 00       	push   $0x80273c
  801509:	68 43 27 80 00       	push   $0x802743
  80150e:	6a 7c                	push   $0x7c
  801510:	68 58 27 80 00       	push   $0x802758
  801515:	e8 24 0a 00 00       	call   801f3e <_panic>
	assert(r <= PGSIZE);
  80151a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80151f:	7e 16                	jle    801537 <devfile_read+0x65>
  801521:	68 63 27 80 00       	push   $0x802763
  801526:	68 43 27 80 00       	push   $0x802743
  80152b:	6a 7d                	push   $0x7d
  80152d:	68 58 27 80 00       	push   $0x802758
  801532:	e8 07 0a 00 00       	call   801f3e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801537:	83 ec 04             	sub    $0x4,%esp
  80153a:	50                   	push   %eax
  80153b:	68 00 50 80 00       	push   $0x805000
  801540:	ff 75 0c             	pushl  0xc(%ebp)
  801543:	e8 42 f3 ff ff       	call   80088a <memmove>
	return r;
  801548:	83 c4 10             	add    $0x10,%esp
}
  80154b:	89 d8                	mov    %ebx,%eax
  80154d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801550:	5b                   	pop    %ebx
  801551:	5e                   	pop    %esi
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    

00801554 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	53                   	push   %ebx
  801558:	83 ec 20             	sub    $0x20,%esp
  80155b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80155e:	53                   	push   %ebx
  80155f:	e8 5b f1 ff ff       	call   8006bf <strlen>
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80156c:	7f 67                	jg     8015d5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80156e:	83 ec 0c             	sub    $0xc,%esp
  801571:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	e8 a7 f8 ff ff       	call   800e21 <fd_alloc>
  80157a:	83 c4 10             	add    $0x10,%esp
		return r;
  80157d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 57                	js     8015da <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	53                   	push   %ebx
  801587:	68 00 50 80 00       	push   $0x805000
  80158c:	e8 67 f1 ff ff       	call   8006f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801591:	8b 45 0c             	mov    0xc(%ebp),%eax
  801594:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801599:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159c:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a1:	e8 03 fe ff ff       	call   8013a9 <fsipc>
  8015a6:	89 c3                	mov    %eax,%ebx
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	79 14                	jns    8015c3 <open+0x6f>
		fd_close(fd, 0);
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	6a 00                	push   $0x0
  8015b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b7:	e8 5d f9 ff ff       	call   800f19 <fd_close>
		return r;
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	89 da                	mov    %ebx,%edx
  8015c1:	eb 17                	jmp    8015da <open+0x86>
	}

	return fd2num(fd);
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c9:	e8 2c f8 ff ff       	call   800dfa <fd2num>
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	eb 05                	jmp    8015da <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015d5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015da:	89 d0                	mov    %edx,%eax
  8015dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ec:	b8 08 00 00 00       	mov    $0x8,%eax
  8015f1:	e8 b3 fd ff ff       	call   8013a9 <fsipc>
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015fe:	68 6f 27 80 00       	push   $0x80276f
  801603:	ff 75 0c             	pushl  0xc(%ebp)
  801606:	e8 ed f0 ff ff       	call   8006f8 <strcpy>
	return 0;
}
  80160b:	b8 00 00 00 00       	mov    $0x0,%eax
  801610:	c9                   	leave  
  801611:	c3                   	ret    

00801612 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	53                   	push   %ebx
  801616:	83 ec 10             	sub    $0x10,%esp
  801619:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80161c:	53                   	push   %ebx
  80161d:	e8 56 0a 00 00       	call   802078 <pageref>
  801622:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801625:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80162a:	83 f8 01             	cmp    $0x1,%eax
  80162d:	75 10                	jne    80163f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80162f:	83 ec 0c             	sub    $0xc,%esp
  801632:	ff 73 0c             	pushl  0xc(%ebx)
  801635:	e8 c0 02 00 00       	call   8018fa <nsipc_close>
  80163a:	89 c2                	mov    %eax,%edx
  80163c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80163f:	89 d0                	mov    %edx,%eax
  801641:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80164c:	6a 00                	push   $0x0
  80164e:	ff 75 10             	pushl  0x10(%ebp)
  801651:	ff 75 0c             	pushl  0xc(%ebp)
  801654:	8b 45 08             	mov    0x8(%ebp),%eax
  801657:	ff 70 0c             	pushl  0xc(%eax)
  80165a:	e8 78 03 00 00       	call   8019d7 <nsipc_send>
}
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801667:	6a 00                	push   $0x0
  801669:	ff 75 10             	pushl  0x10(%ebp)
  80166c:	ff 75 0c             	pushl  0xc(%ebp)
  80166f:	8b 45 08             	mov    0x8(%ebp),%eax
  801672:	ff 70 0c             	pushl  0xc(%eax)
  801675:	e8 f1 02 00 00       	call   80196b <nsipc_recv>
}
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801682:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801685:	52                   	push   %edx
  801686:	50                   	push   %eax
  801687:	e8 e4 f7 ff ff       	call   800e70 <fd_lookup>
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 17                	js     8016aa <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801693:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801696:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80169c:	39 08                	cmp    %ecx,(%eax)
  80169e:	75 05                	jne    8016a5 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a3:	eb 05                	jmp    8016aa <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8016a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 1c             	sub    $0x1c,%esp
  8016b4:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8016b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b9:	50                   	push   %eax
  8016ba:	e8 62 f7 ff ff       	call   800e21 <fd_alloc>
  8016bf:	89 c3                	mov    %eax,%ebx
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 1b                	js     8016e3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016c8:	83 ec 04             	sub    $0x4,%esp
  8016cb:	68 07 04 00 00       	push   $0x407
  8016d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d3:	6a 00                	push   $0x0
  8016d5:	e8 21 f4 ff ff       	call   800afb <sys_page_alloc>
  8016da:	89 c3                	mov    %eax,%ebx
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	79 10                	jns    8016f3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016e3:	83 ec 0c             	sub    $0xc,%esp
  8016e6:	56                   	push   %esi
  8016e7:	e8 0e 02 00 00       	call   8018fa <nsipc_close>
		return r;
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	89 d8                	mov    %ebx,%eax
  8016f1:	eb 24                	jmp    801717 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016f3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801701:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801708:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80170b:	83 ec 0c             	sub    $0xc,%esp
  80170e:	50                   	push   %eax
  80170f:	e8 e6 f6 ff ff       	call   800dfa <fd2num>
  801714:	83 c4 10             	add    $0x10,%esp
}
  801717:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171a:	5b                   	pop    %ebx
  80171b:	5e                   	pop    %esi
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801724:	8b 45 08             	mov    0x8(%ebp),%eax
  801727:	e8 50 ff ff ff       	call   80167c <fd2sockid>
		return r;
  80172c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 1f                	js     801751 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801732:	83 ec 04             	sub    $0x4,%esp
  801735:	ff 75 10             	pushl  0x10(%ebp)
  801738:	ff 75 0c             	pushl  0xc(%ebp)
  80173b:	50                   	push   %eax
  80173c:	e8 12 01 00 00       	call   801853 <nsipc_accept>
  801741:	83 c4 10             	add    $0x10,%esp
		return r;
  801744:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801746:	85 c0                	test   %eax,%eax
  801748:	78 07                	js     801751 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80174a:	e8 5d ff ff ff       	call   8016ac <alloc_sockfd>
  80174f:	89 c1                	mov    %eax,%ecx
}
  801751:	89 c8                	mov    %ecx,%eax
  801753:	c9                   	leave  
  801754:	c3                   	ret    

00801755 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	e8 19 ff ff ff       	call   80167c <fd2sockid>
  801763:	85 c0                	test   %eax,%eax
  801765:	78 12                	js     801779 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801767:	83 ec 04             	sub    $0x4,%esp
  80176a:	ff 75 10             	pushl  0x10(%ebp)
  80176d:	ff 75 0c             	pushl  0xc(%ebp)
  801770:	50                   	push   %eax
  801771:	e8 2d 01 00 00       	call   8018a3 <nsipc_bind>
  801776:	83 c4 10             	add    $0x10,%esp
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <shutdown>:

int
shutdown(int s, int how)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801781:	8b 45 08             	mov    0x8(%ebp),%eax
  801784:	e8 f3 fe ff ff       	call   80167c <fd2sockid>
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 0f                	js     80179c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80178d:	83 ec 08             	sub    $0x8,%esp
  801790:	ff 75 0c             	pushl  0xc(%ebp)
  801793:	50                   	push   %eax
  801794:	e8 3f 01 00 00       	call   8018d8 <nsipc_shutdown>
  801799:	83 c4 10             	add    $0x10,%esp
}
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a7:	e8 d0 fe ff ff       	call   80167c <fd2sockid>
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 12                	js     8017c2 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8017b0:	83 ec 04             	sub    $0x4,%esp
  8017b3:	ff 75 10             	pushl  0x10(%ebp)
  8017b6:	ff 75 0c             	pushl  0xc(%ebp)
  8017b9:	50                   	push   %eax
  8017ba:	e8 55 01 00 00       	call   801914 <nsipc_connect>
  8017bf:	83 c4 10             	add    $0x10,%esp
}
  8017c2:	c9                   	leave  
  8017c3:	c3                   	ret    

008017c4 <listen>:

int
listen(int s, int backlog)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cd:	e8 aa fe ff ff       	call   80167c <fd2sockid>
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	78 0f                	js     8017e5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8017d6:	83 ec 08             	sub    $0x8,%esp
  8017d9:	ff 75 0c             	pushl  0xc(%ebp)
  8017dc:	50                   	push   %eax
  8017dd:	e8 67 01 00 00       	call   801949 <nsipc_listen>
  8017e2:	83 c4 10             	add    $0x10,%esp
}
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017ed:	ff 75 10             	pushl  0x10(%ebp)
  8017f0:	ff 75 0c             	pushl  0xc(%ebp)
  8017f3:	ff 75 08             	pushl  0x8(%ebp)
  8017f6:	e8 3a 02 00 00       	call   801a35 <nsipc_socket>
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 05                	js     801807 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801802:	e8 a5 fe ff ff       	call   8016ac <alloc_sockfd>
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	53                   	push   %ebx
  80180d:	83 ec 04             	sub    $0x4,%esp
  801810:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801812:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801819:	75 12                	jne    80182d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80181b:	83 ec 0c             	sub    $0xc,%esp
  80181e:	6a 02                	push   $0x2
  801820:	e8 1a 08 00 00       	call   80203f <ipc_find_env>
  801825:	a3 04 40 80 00       	mov    %eax,0x804004
  80182a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80182d:	6a 07                	push   $0x7
  80182f:	68 00 60 80 00       	push   $0x806000
  801834:	53                   	push   %ebx
  801835:	ff 35 04 40 80 00    	pushl  0x804004
  80183b:	e8 ab 07 00 00       	call   801feb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801840:	83 c4 0c             	add    $0xc,%esp
  801843:	6a 00                	push   $0x0
  801845:	6a 00                	push   $0x0
  801847:	6a 00                	push   $0x0
  801849:	e8 36 07 00 00       	call   801f84 <ipc_recv>
}
  80184e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	56                   	push   %esi
  801857:	53                   	push   %ebx
  801858:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80185b:	8b 45 08             	mov    0x8(%ebp),%eax
  80185e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801863:	8b 06                	mov    (%esi),%eax
  801865:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80186a:	b8 01 00 00 00       	mov    $0x1,%eax
  80186f:	e8 95 ff ff ff       	call   801809 <nsipc>
  801874:	89 c3                	mov    %eax,%ebx
  801876:	85 c0                	test   %eax,%eax
  801878:	78 20                	js     80189a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80187a:	83 ec 04             	sub    $0x4,%esp
  80187d:	ff 35 10 60 80 00    	pushl  0x806010
  801883:	68 00 60 80 00       	push   $0x806000
  801888:	ff 75 0c             	pushl  0xc(%ebp)
  80188b:	e8 fa ef ff ff       	call   80088a <memmove>
		*addrlen = ret->ret_addrlen;
  801890:	a1 10 60 80 00       	mov    0x806010,%eax
  801895:	89 06                	mov    %eax,(%esi)
  801897:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018b5:	53                   	push   %ebx
  8018b6:	ff 75 0c             	pushl  0xc(%ebp)
  8018b9:	68 04 60 80 00       	push   $0x806004
  8018be:	e8 c7 ef ff ff       	call   80088a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018c3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8018c9:	b8 02 00 00 00       	mov    $0x2,%eax
  8018ce:	e8 36 ff ff ff       	call   801809 <nsipc>
}
  8018d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f3:	e8 11 ff ff ff       	call   801809 <nsipc>
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <nsipc_close>:

int
nsipc_close(int s)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801900:	8b 45 08             	mov    0x8(%ebp),%eax
  801903:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801908:	b8 04 00 00 00       	mov    $0x4,%eax
  80190d:	e8 f7 fe ff ff       	call   801809 <nsipc>
}
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	53                   	push   %ebx
  801918:	83 ec 08             	sub    $0x8,%esp
  80191b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80191e:	8b 45 08             	mov    0x8(%ebp),%eax
  801921:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801926:	53                   	push   %ebx
  801927:	ff 75 0c             	pushl  0xc(%ebp)
  80192a:	68 04 60 80 00       	push   $0x806004
  80192f:	e8 56 ef ff ff       	call   80088a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801934:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80193a:	b8 05 00 00 00       	mov    $0x5,%eax
  80193f:	e8 c5 fe ff ff       	call   801809 <nsipc>
}
  801944:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801947:	c9                   	leave  
  801948:	c3                   	ret    

00801949 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80194f:	8b 45 08             	mov    0x8(%ebp),%eax
  801952:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80195f:	b8 06 00 00 00       	mov    $0x6,%eax
  801964:	e8 a0 fe ff ff       	call   801809 <nsipc>
}
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801973:	8b 45 08             	mov    0x8(%ebp),%eax
  801976:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80197b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801981:	8b 45 14             	mov    0x14(%ebp),%eax
  801984:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801989:	b8 07 00 00 00       	mov    $0x7,%eax
  80198e:	e8 76 fe ff ff       	call   801809 <nsipc>
  801993:	89 c3                	mov    %eax,%ebx
  801995:	85 c0                	test   %eax,%eax
  801997:	78 35                	js     8019ce <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801999:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80199e:	7f 04                	jg     8019a4 <nsipc_recv+0x39>
  8019a0:	39 c6                	cmp    %eax,%esi
  8019a2:	7d 16                	jge    8019ba <nsipc_recv+0x4f>
  8019a4:	68 7b 27 80 00       	push   $0x80277b
  8019a9:	68 43 27 80 00       	push   $0x802743
  8019ae:	6a 62                	push   $0x62
  8019b0:	68 90 27 80 00       	push   $0x802790
  8019b5:	e8 84 05 00 00       	call   801f3e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019ba:	83 ec 04             	sub    $0x4,%esp
  8019bd:	50                   	push   %eax
  8019be:	68 00 60 80 00       	push   $0x806000
  8019c3:	ff 75 0c             	pushl  0xc(%ebp)
  8019c6:	e8 bf ee ff ff       	call   80088a <memmove>
  8019cb:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019ce:	89 d8                	mov    %ebx,%eax
  8019d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d3:	5b                   	pop    %ebx
  8019d4:	5e                   	pop    %esi
  8019d5:	5d                   	pop    %ebp
  8019d6:	c3                   	ret    

008019d7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	53                   	push   %ebx
  8019db:	83 ec 04             	sub    $0x4,%esp
  8019de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019e9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019ef:	7e 16                	jle    801a07 <nsipc_send+0x30>
  8019f1:	68 9c 27 80 00       	push   $0x80279c
  8019f6:	68 43 27 80 00       	push   $0x802743
  8019fb:	6a 6d                	push   $0x6d
  8019fd:	68 90 27 80 00       	push   $0x802790
  801a02:	e8 37 05 00 00       	call   801f3e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a07:	83 ec 04             	sub    $0x4,%esp
  801a0a:	53                   	push   %ebx
  801a0b:	ff 75 0c             	pushl  0xc(%ebp)
  801a0e:	68 0c 60 80 00       	push   $0x80600c
  801a13:	e8 72 ee ff ff       	call   80088a <memmove>
	nsipcbuf.send.req_size = size;
  801a18:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a1e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a21:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a26:	b8 08 00 00 00       	mov    $0x8,%eax
  801a2b:	e8 d9 fd ff ff       	call   801809 <nsipc>
}
  801a30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a46:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a4e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a53:	b8 09 00 00 00       	mov    $0x9,%eax
  801a58:	e8 ac fd ff ff       	call   801809 <nsipc>
}
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a67:	83 ec 0c             	sub    $0xc,%esp
  801a6a:	ff 75 08             	pushl  0x8(%ebp)
  801a6d:	e8 98 f3 ff ff       	call   800e0a <fd2data>
  801a72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a74:	83 c4 08             	add    $0x8,%esp
  801a77:	68 a8 27 80 00       	push   $0x8027a8
  801a7c:	53                   	push   %ebx
  801a7d:	e8 76 ec ff ff       	call   8006f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a82:	8b 46 04             	mov    0x4(%esi),%eax
  801a85:	2b 06                	sub    (%esi),%eax
  801a87:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a8d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a94:	00 00 00 
	stat->st_dev = &devpipe;
  801a97:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a9e:	30 80 00 
	return 0;
}
  801aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	53                   	push   %ebx
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ab7:	53                   	push   %ebx
  801ab8:	6a 00                	push   $0x0
  801aba:	e8 c1 f0 ff ff       	call   800b80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801abf:	89 1c 24             	mov    %ebx,(%esp)
  801ac2:	e8 43 f3 ff ff       	call   800e0a <fd2data>
  801ac7:	83 c4 08             	add    $0x8,%esp
  801aca:	50                   	push   %eax
  801acb:	6a 00                	push   $0x0
  801acd:	e8 ae f0 ff ff       	call   800b80 <sys_page_unmap>
}
  801ad2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	57                   	push   %edi
  801adb:	56                   	push   %esi
  801adc:	53                   	push   %ebx
  801add:	83 ec 1c             	sub    $0x1c,%esp
  801ae0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ae3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ae5:	a1 08 40 80 00       	mov    0x804008,%eax
  801aea:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aed:	83 ec 0c             	sub    $0xc,%esp
  801af0:	ff 75 e0             	pushl  -0x20(%ebp)
  801af3:	e8 80 05 00 00       	call   802078 <pageref>
  801af8:	89 c3                	mov    %eax,%ebx
  801afa:	89 3c 24             	mov    %edi,(%esp)
  801afd:	e8 76 05 00 00       	call   802078 <pageref>
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	39 c3                	cmp    %eax,%ebx
  801b07:	0f 94 c1             	sete   %cl
  801b0a:	0f b6 c9             	movzbl %cl,%ecx
  801b0d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b10:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b16:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b19:	39 ce                	cmp    %ecx,%esi
  801b1b:	74 1b                	je     801b38 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b1d:	39 c3                	cmp    %eax,%ebx
  801b1f:	75 c4                	jne    801ae5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b21:	8b 42 58             	mov    0x58(%edx),%eax
  801b24:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b27:	50                   	push   %eax
  801b28:	56                   	push   %esi
  801b29:	68 af 27 80 00       	push   $0x8027af
  801b2e:	e8 40 e6 ff ff       	call   800173 <cprintf>
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	eb ad                	jmp    801ae5 <_pipeisclosed+0xe>
	}
}
  801b38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3e:	5b                   	pop    %ebx
  801b3f:	5e                   	pop    %esi
  801b40:	5f                   	pop    %edi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	57                   	push   %edi
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
  801b49:	83 ec 28             	sub    $0x28,%esp
  801b4c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b4f:	56                   	push   %esi
  801b50:	e8 b5 f2 ff ff       	call   800e0a <fd2data>
  801b55:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	bf 00 00 00 00       	mov    $0x0,%edi
  801b5f:	eb 4b                	jmp    801bac <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b61:	89 da                	mov    %ebx,%edx
  801b63:	89 f0                	mov    %esi,%eax
  801b65:	e8 6d ff ff ff       	call   801ad7 <_pipeisclosed>
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	75 48                	jne    801bb6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b6e:	e8 69 ef ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b73:	8b 43 04             	mov    0x4(%ebx),%eax
  801b76:	8b 0b                	mov    (%ebx),%ecx
  801b78:	8d 51 20             	lea    0x20(%ecx),%edx
  801b7b:	39 d0                	cmp    %edx,%eax
  801b7d:	73 e2                	jae    801b61 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b82:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b86:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b89:	89 c2                	mov    %eax,%edx
  801b8b:	c1 fa 1f             	sar    $0x1f,%edx
  801b8e:	89 d1                	mov    %edx,%ecx
  801b90:	c1 e9 1b             	shr    $0x1b,%ecx
  801b93:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b96:	83 e2 1f             	and    $0x1f,%edx
  801b99:	29 ca                	sub    %ecx,%edx
  801b9b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b9f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ba3:	83 c0 01             	add    $0x1,%eax
  801ba6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba9:	83 c7 01             	add    $0x1,%edi
  801bac:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801baf:	75 c2                	jne    801b73 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bb1:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb4:	eb 05                	jmp    801bbb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbe:	5b                   	pop    %ebx
  801bbf:	5e                   	pop    %esi
  801bc0:	5f                   	pop    %edi
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	57                   	push   %edi
  801bc7:	56                   	push   %esi
  801bc8:	53                   	push   %ebx
  801bc9:	83 ec 18             	sub    $0x18,%esp
  801bcc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bcf:	57                   	push   %edi
  801bd0:	e8 35 f2 ff ff       	call   800e0a <fd2data>
  801bd5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bdf:	eb 3d                	jmp    801c1e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801be1:	85 db                	test   %ebx,%ebx
  801be3:	74 04                	je     801be9 <devpipe_read+0x26>
				return i;
  801be5:	89 d8                	mov    %ebx,%eax
  801be7:	eb 44                	jmp    801c2d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801be9:	89 f2                	mov    %esi,%edx
  801beb:	89 f8                	mov    %edi,%eax
  801bed:	e8 e5 fe ff ff       	call   801ad7 <_pipeisclosed>
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	75 32                	jne    801c28 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bf6:	e8 e1 ee ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bfb:	8b 06                	mov    (%esi),%eax
  801bfd:	3b 46 04             	cmp    0x4(%esi),%eax
  801c00:	74 df                	je     801be1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c02:	99                   	cltd   
  801c03:	c1 ea 1b             	shr    $0x1b,%edx
  801c06:	01 d0                	add    %edx,%eax
  801c08:	83 e0 1f             	and    $0x1f,%eax
  801c0b:	29 d0                	sub    %edx,%eax
  801c0d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c15:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c18:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c1b:	83 c3 01             	add    $0x1,%ebx
  801c1e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c21:	75 d8                	jne    801bfb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c23:	8b 45 10             	mov    0x10(%ebp),%eax
  801c26:	eb 05                	jmp    801c2d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c28:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	56                   	push   %esi
  801c39:	53                   	push   %ebx
  801c3a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c40:	50                   	push   %eax
  801c41:	e8 db f1 ff ff       	call   800e21 <fd_alloc>
  801c46:	83 c4 10             	add    $0x10,%esp
  801c49:	89 c2                	mov    %eax,%edx
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	0f 88 2c 01 00 00    	js     801d7f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c53:	83 ec 04             	sub    $0x4,%esp
  801c56:	68 07 04 00 00       	push   $0x407
  801c5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5e:	6a 00                	push   $0x0
  801c60:	e8 96 ee ff ff       	call   800afb <sys_page_alloc>
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	89 c2                	mov    %eax,%edx
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	0f 88 0d 01 00 00    	js     801d7f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c72:	83 ec 0c             	sub    $0xc,%esp
  801c75:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c78:	50                   	push   %eax
  801c79:	e8 a3 f1 ff ff       	call   800e21 <fd_alloc>
  801c7e:	89 c3                	mov    %eax,%ebx
  801c80:	83 c4 10             	add    $0x10,%esp
  801c83:	85 c0                	test   %eax,%eax
  801c85:	0f 88 e2 00 00 00    	js     801d6d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8b:	83 ec 04             	sub    $0x4,%esp
  801c8e:	68 07 04 00 00       	push   $0x407
  801c93:	ff 75 f0             	pushl  -0x10(%ebp)
  801c96:	6a 00                	push   $0x0
  801c98:	e8 5e ee ff ff       	call   800afb <sys_page_alloc>
  801c9d:	89 c3                	mov    %eax,%ebx
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	0f 88 c3 00 00 00    	js     801d6d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801caa:	83 ec 0c             	sub    $0xc,%esp
  801cad:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb0:	e8 55 f1 ff ff       	call   800e0a <fd2data>
  801cb5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb7:	83 c4 0c             	add    $0xc,%esp
  801cba:	68 07 04 00 00       	push   $0x407
  801cbf:	50                   	push   %eax
  801cc0:	6a 00                	push   $0x0
  801cc2:	e8 34 ee ff ff       	call   800afb <sys_page_alloc>
  801cc7:	89 c3                	mov    %eax,%ebx
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	0f 88 89 00 00 00    	js     801d5d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd4:	83 ec 0c             	sub    $0xc,%esp
  801cd7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cda:	e8 2b f1 ff ff       	call   800e0a <fd2data>
  801cdf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ce6:	50                   	push   %eax
  801ce7:	6a 00                	push   $0x0
  801ce9:	56                   	push   %esi
  801cea:	6a 00                	push   $0x0
  801cec:	e8 4d ee ff ff       	call   800b3e <sys_page_map>
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	83 c4 20             	add    $0x20,%esp
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 55                	js     801d4f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cfa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d03:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d08:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d0f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d18:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d24:	83 ec 0c             	sub    $0xc,%esp
  801d27:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2a:	e8 cb f0 ff ff       	call   800dfa <fd2num>
  801d2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d32:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d34:	83 c4 04             	add    $0x4,%esp
  801d37:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3a:	e8 bb f0 ff ff       	call   800dfa <fd2num>
  801d3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d42:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	ba 00 00 00 00       	mov    $0x0,%edx
  801d4d:	eb 30                	jmp    801d7f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d4f:	83 ec 08             	sub    $0x8,%esp
  801d52:	56                   	push   %esi
  801d53:	6a 00                	push   $0x0
  801d55:	e8 26 ee ff ff       	call   800b80 <sys_page_unmap>
  801d5a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d5d:	83 ec 08             	sub    $0x8,%esp
  801d60:	ff 75 f0             	pushl  -0x10(%ebp)
  801d63:	6a 00                	push   $0x0
  801d65:	e8 16 ee ff ff       	call   800b80 <sys_page_unmap>
  801d6a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d6d:	83 ec 08             	sub    $0x8,%esp
  801d70:	ff 75 f4             	pushl  -0xc(%ebp)
  801d73:	6a 00                	push   $0x0
  801d75:	e8 06 ee ff ff       	call   800b80 <sys_page_unmap>
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d7f:	89 d0                	mov    %edx,%eax
  801d81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d91:	50                   	push   %eax
  801d92:	ff 75 08             	pushl  0x8(%ebp)
  801d95:	e8 d6 f0 ff ff       	call   800e70 <fd_lookup>
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	78 18                	js     801db9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801da1:	83 ec 0c             	sub    $0xc,%esp
  801da4:	ff 75 f4             	pushl  -0xc(%ebp)
  801da7:	e8 5e f0 ff ff       	call   800e0a <fd2data>
	return _pipeisclosed(fd, p);
  801dac:	89 c2                	mov    %eax,%edx
  801dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db1:	e8 21 fd ff ff       	call   801ad7 <_pipeisclosed>
  801db6:	83 c4 10             	add    $0x10,%esp
}
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    

00801dbb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dcb:	68 c7 27 80 00       	push   $0x8027c7
  801dd0:	ff 75 0c             	pushl  0xc(%ebp)
  801dd3:	e8 20 e9 ff ff       	call   8006f8 <strcpy>
	return 0;
}
  801dd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ddd:	c9                   	leave  
  801dde:	c3                   	ret    

00801ddf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	57                   	push   %edi
  801de3:	56                   	push   %esi
  801de4:	53                   	push   %ebx
  801de5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801deb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df6:	eb 2d                	jmp    801e25 <devcons_write+0x46>
		m = n - tot;
  801df8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dfb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dfd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e00:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e05:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e08:	83 ec 04             	sub    $0x4,%esp
  801e0b:	53                   	push   %ebx
  801e0c:	03 45 0c             	add    0xc(%ebp),%eax
  801e0f:	50                   	push   %eax
  801e10:	57                   	push   %edi
  801e11:	e8 74 ea ff ff       	call   80088a <memmove>
		sys_cputs(buf, m);
  801e16:	83 c4 08             	add    $0x8,%esp
  801e19:	53                   	push   %ebx
  801e1a:	57                   	push   %edi
  801e1b:	e8 1f ec ff ff       	call   800a3f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e20:	01 de                	add    %ebx,%esi
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e2a:	72 cc                	jb     801df8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2f:	5b                   	pop    %ebx
  801e30:	5e                   	pop    %esi
  801e31:	5f                   	pop    %edi
  801e32:	5d                   	pop    %ebp
  801e33:	c3                   	ret    

00801e34 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	83 ec 08             	sub    $0x8,%esp
  801e3a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e43:	74 2a                	je     801e6f <devcons_read+0x3b>
  801e45:	eb 05                	jmp    801e4c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e47:	e8 90 ec ff ff       	call   800adc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e4c:	e8 0c ec ff ff       	call   800a5d <sys_cgetc>
  801e51:	85 c0                	test   %eax,%eax
  801e53:	74 f2                	je     801e47 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e55:	85 c0                	test   %eax,%eax
  801e57:	78 16                	js     801e6f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e59:	83 f8 04             	cmp    $0x4,%eax
  801e5c:	74 0c                	je     801e6a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e61:	88 02                	mov    %al,(%edx)
	return 1;
  801e63:	b8 01 00 00 00       	mov    $0x1,%eax
  801e68:	eb 05                	jmp    801e6f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e6a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e77:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e7d:	6a 01                	push   $0x1
  801e7f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e82:	50                   	push   %eax
  801e83:	e8 b7 eb ff ff       	call   800a3f <sys_cputs>
}
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	c9                   	leave  
  801e8c:	c3                   	ret    

00801e8d <getchar>:

int
getchar(void)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e93:	6a 01                	push   $0x1
  801e95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e98:	50                   	push   %eax
  801e99:	6a 00                	push   $0x0
  801e9b:	e8 36 f2 ff ff       	call   8010d6 <read>
	if (r < 0)
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	78 0f                	js     801eb6 <getchar+0x29>
		return r;
	if (r < 1)
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	7e 06                	jle    801eb1 <getchar+0x24>
		return -E_EOF;
	return c;
  801eab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eaf:	eb 05                	jmp    801eb6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eb1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ebe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec1:	50                   	push   %eax
  801ec2:	ff 75 08             	pushl  0x8(%ebp)
  801ec5:	e8 a6 ef ff ff       	call   800e70 <fd_lookup>
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	78 11                	js     801ee2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eda:	39 10                	cmp    %edx,(%eax)
  801edc:	0f 94 c0             	sete   %al
  801edf:	0f b6 c0             	movzbl %al,%eax
}
  801ee2:	c9                   	leave  
  801ee3:	c3                   	ret    

00801ee4 <opencons>:

int
opencons(void)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eed:	50                   	push   %eax
  801eee:	e8 2e ef ff ff       	call   800e21 <fd_alloc>
  801ef3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ef6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	78 3e                	js     801f3a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801efc:	83 ec 04             	sub    $0x4,%esp
  801eff:	68 07 04 00 00       	push   $0x407
  801f04:	ff 75 f4             	pushl  -0xc(%ebp)
  801f07:	6a 00                	push   $0x0
  801f09:	e8 ed eb ff ff       	call   800afb <sys_page_alloc>
  801f0e:	83 c4 10             	add    $0x10,%esp
		return r;
  801f11:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f13:	85 c0                	test   %eax,%eax
  801f15:	78 23                	js     801f3a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f17:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f20:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f25:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f2c:	83 ec 0c             	sub    $0xc,%esp
  801f2f:	50                   	push   %eax
  801f30:	e8 c5 ee ff ff       	call   800dfa <fd2num>
  801f35:	89 c2                	mov    %eax,%edx
  801f37:	83 c4 10             	add    $0x10,%esp
}
  801f3a:	89 d0                	mov    %edx,%eax
  801f3c:	c9                   	leave  
  801f3d:	c3                   	ret    

00801f3e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	56                   	push   %esi
  801f42:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f43:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f46:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f4c:	e8 6c eb ff ff       	call   800abd <sys_getenvid>
  801f51:	83 ec 0c             	sub    $0xc,%esp
  801f54:	ff 75 0c             	pushl  0xc(%ebp)
  801f57:	ff 75 08             	pushl  0x8(%ebp)
  801f5a:	56                   	push   %esi
  801f5b:	50                   	push   %eax
  801f5c:	68 d4 27 80 00       	push   $0x8027d4
  801f61:	e8 0d e2 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f66:	83 c4 18             	add    $0x18,%esp
  801f69:	53                   	push   %ebx
  801f6a:	ff 75 10             	pushl  0x10(%ebp)
  801f6d:	e8 b0 e1 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801f72:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  801f79:	e8 f5 e1 ff ff       	call   800173 <cprintf>
  801f7e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f81:	cc                   	int3   
  801f82:	eb fd                	jmp    801f81 <_panic+0x43>

00801f84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	56                   	push   %esi
  801f88:	53                   	push   %ebx
  801f89:	8b 75 08             	mov    0x8(%ebp),%esi
  801f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f92:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f94:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f99:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	50                   	push   %eax
  801fa0:	e8 06 ed ff ff       	call   800cab <sys_ipc_recv>

	if (from_env_store != NULL)
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	85 f6                	test   %esi,%esi
  801faa:	74 14                	je     801fc0 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801fac:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	78 09                	js     801fbe <ipc_recv+0x3a>
  801fb5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fbb:	8b 52 74             	mov    0x74(%edx),%edx
  801fbe:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801fc0:	85 db                	test   %ebx,%ebx
  801fc2:	74 14                	je     801fd8 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	78 09                	js     801fd6 <ipc_recv+0x52>
  801fcd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fd3:	8b 52 78             	mov    0x78(%edx),%edx
  801fd6:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 08                	js     801fe4 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801fdc:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe1:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fe4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe7:	5b                   	pop    %ebx
  801fe8:	5e                   	pop    %esi
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    

00801feb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	57                   	push   %edi
  801fef:	56                   	push   %esi
  801ff0:	53                   	push   %ebx
  801ff1:	83 ec 0c             	sub    $0xc,%esp
  801ff4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ff7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ffa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ffd:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801fff:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802004:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802007:	ff 75 14             	pushl  0x14(%ebp)
  80200a:	53                   	push   %ebx
  80200b:	56                   	push   %esi
  80200c:	57                   	push   %edi
  80200d:	e8 76 ec ff ff       	call   800c88 <sys_ipc_try_send>

		if (err < 0) {
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	85 c0                	test   %eax,%eax
  802017:	79 1e                	jns    802037 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802019:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80201c:	75 07                	jne    802025 <ipc_send+0x3a>
				sys_yield();
  80201e:	e8 b9 ea ff ff       	call   800adc <sys_yield>
  802023:	eb e2                	jmp    802007 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802025:	50                   	push   %eax
  802026:	68 f8 27 80 00       	push   $0x8027f8
  80202b:	6a 49                	push   $0x49
  80202d:	68 05 28 80 00       	push   $0x802805
  802032:	e8 07 ff ff ff       	call   801f3e <_panic>
		}

	} while (err < 0);

}
  802037:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5f                   	pop    %edi
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    

0080203f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802045:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80204a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80204d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802053:	8b 52 50             	mov    0x50(%edx),%edx
  802056:	39 ca                	cmp    %ecx,%edx
  802058:	75 0d                	jne    802067 <ipc_find_env+0x28>
			return envs[i].env_id;
  80205a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80205d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802062:	8b 40 48             	mov    0x48(%eax),%eax
  802065:	eb 0f                	jmp    802076 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802067:	83 c0 01             	add    $0x1,%eax
  80206a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80206f:	75 d9                	jne    80204a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802071:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    

00802078 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80207e:	89 d0                	mov    %edx,%eax
  802080:	c1 e8 16             	shr    $0x16,%eax
  802083:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80208a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208f:	f6 c1 01             	test   $0x1,%cl
  802092:	74 1d                	je     8020b1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802094:	c1 ea 0c             	shr    $0xc,%edx
  802097:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80209e:	f6 c2 01             	test   $0x1,%dl
  8020a1:	74 0e                	je     8020b1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020a3:	c1 ea 0c             	shr    $0xc,%edx
  8020a6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020ad:	ef 
  8020ae:	0f b7 c0             	movzwl %ax,%eax
}
  8020b1:	5d                   	pop    %ebp
  8020b2:	c3                   	ret    
  8020b3:	66 90                	xchg   %ax,%ax
  8020b5:	66 90                	xchg   %ax,%ax
  8020b7:	66 90                	xchg   %ax,%ax
  8020b9:	66 90                	xchg   %ax,%ax
  8020bb:	66 90                	xchg   %ax,%ax
  8020bd:	66 90                	xchg   %ax,%ax
  8020bf:	90                   	nop

008020c0 <__udivdi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020dd:	89 ca                	mov    %ecx,%edx
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	75 3d                	jne    802120 <__udivdi3+0x60>
  8020e3:	39 cf                	cmp    %ecx,%edi
  8020e5:	0f 87 c5 00 00 00    	ja     8021b0 <__udivdi3+0xf0>
  8020eb:	85 ff                	test   %edi,%edi
  8020ed:	89 fd                	mov    %edi,%ebp
  8020ef:	75 0b                	jne    8020fc <__udivdi3+0x3c>
  8020f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f6:	31 d2                	xor    %edx,%edx
  8020f8:	f7 f7                	div    %edi
  8020fa:	89 c5                	mov    %eax,%ebp
  8020fc:	89 c8                	mov    %ecx,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	f7 f5                	div    %ebp
  802102:	89 c1                	mov    %eax,%ecx
  802104:	89 d8                	mov    %ebx,%eax
  802106:	89 cf                	mov    %ecx,%edi
  802108:	f7 f5                	div    %ebp
  80210a:	89 c3                	mov    %eax,%ebx
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
  802120:	39 ce                	cmp    %ecx,%esi
  802122:	77 74                	ja     802198 <__udivdi3+0xd8>
  802124:	0f bd fe             	bsr    %esi,%edi
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	0f 84 98 00 00 00    	je     8021c8 <__udivdi3+0x108>
  802130:	bb 20 00 00 00       	mov    $0x20,%ebx
  802135:	89 f9                	mov    %edi,%ecx
  802137:	89 c5                	mov    %eax,%ebp
  802139:	29 fb                	sub    %edi,%ebx
  80213b:	d3 e6                	shl    %cl,%esi
  80213d:	89 d9                	mov    %ebx,%ecx
  80213f:	d3 ed                	shr    %cl,%ebp
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 e0                	shl    %cl,%eax
  802145:	09 ee                	or     %ebp,%esi
  802147:	89 d9                	mov    %ebx,%ecx
  802149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214d:	89 d5                	mov    %edx,%ebp
  80214f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802153:	d3 ed                	shr    %cl,%ebp
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e2                	shl    %cl,%edx
  802159:	89 d9                	mov    %ebx,%ecx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	09 c2                	or     %eax,%edx
  80215f:	89 d0                	mov    %edx,%eax
  802161:	89 ea                	mov    %ebp,%edx
  802163:	f7 f6                	div    %esi
  802165:	89 d5                	mov    %edx,%ebp
  802167:	89 c3                	mov    %eax,%ebx
  802169:	f7 64 24 0c          	mull   0xc(%esp)
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	72 10                	jb     802181 <__udivdi3+0xc1>
  802171:	8b 74 24 08          	mov    0x8(%esp),%esi
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e6                	shl    %cl,%esi
  802179:	39 c6                	cmp    %eax,%esi
  80217b:	73 07                	jae    802184 <__udivdi3+0xc4>
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	75 03                	jne    802184 <__udivdi3+0xc4>
  802181:	83 eb 01             	sub    $0x1,%ebx
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 d8                	mov    %ebx,%eax
  802188:	89 fa                	mov    %edi,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	31 ff                	xor    %edi,%edi
  80219a:	31 db                	xor    %ebx,%ebx
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	89 fa                	mov    %edi,%edx
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 d8                	mov    %ebx,%eax
  8021b2:	f7 f7                	div    %edi
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 c3                	mov    %eax,%ebx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 fa                	mov    %edi,%edx
  8021bc:	83 c4 1c             	add    $0x1c,%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	39 ce                	cmp    %ecx,%esi
  8021ca:	72 0c                	jb     8021d8 <__udivdi3+0x118>
  8021cc:	31 db                	xor    %ebx,%ebx
  8021ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021d2:	0f 87 34 ff ff ff    	ja     80210c <__udivdi3+0x4c>
  8021d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021dd:	e9 2a ff ff ff       	jmp    80210c <__udivdi3+0x4c>
  8021e2:	66 90                	xchg   %ax,%ax
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 d2                	test   %edx,%edx
  802209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f3                	mov    %esi,%ebx
  802213:	89 3c 24             	mov    %edi,(%esp)
  802216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80221a:	75 1c                	jne    802238 <__umoddi3+0x48>
  80221c:	39 f7                	cmp    %esi,%edi
  80221e:	76 50                	jbe    802270 <__umoddi3+0x80>
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	f7 f7                	div    %edi
  802226:	89 d0                	mov    %edx,%eax
  802228:	31 d2                	xor    %edx,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	39 f2                	cmp    %esi,%edx
  80223a:	89 d0                	mov    %edx,%eax
  80223c:	77 52                	ja     802290 <__umoddi3+0xa0>
  80223e:	0f bd ea             	bsr    %edx,%ebp
  802241:	83 f5 1f             	xor    $0x1f,%ebp
  802244:	75 5a                	jne    8022a0 <__umoddi3+0xb0>
  802246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80224a:	0f 82 e0 00 00 00    	jb     802330 <__umoddi3+0x140>
  802250:	39 0c 24             	cmp    %ecx,(%esp)
  802253:	0f 86 d7 00 00 00    	jbe    802330 <__umoddi3+0x140>
  802259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	85 ff                	test   %edi,%edi
  802272:	89 fd                	mov    %edi,%ebp
  802274:	75 0b                	jne    802281 <__umoddi3+0x91>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f7                	div    %edi
  80227f:	89 c5                	mov    %eax,%ebp
  802281:	89 f0                	mov    %esi,%eax
  802283:	31 d2                	xor    %edx,%edx
  802285:	f7 f5                	div    %ebp
  802287:	89 c8                	mov    %ecx,%eax
  802289:	f7 f5                	div    %ebp
  80228b:	89 d0                	mov    %edx,%eax
  80228d:	eb 99                	jmp    802228 <__umoddi3+0x38>
  80228f:	90                   	nop
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 1c             	add    $0x1c,%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	8b 34 24             	mov    (%esp),%esi
  8022a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022a8:	89 e9                	mov    %ebp,%ecx
  8022aa:	29 ef                	sub    %ebp,%edi
  8022ac:	d3 e0                	shl    %cl,%eax
  8022ae:	89 f9                	mov    %edi,%ecx
  8022b0:	89 f2                	mov    %esi,%edx
  8022b2:	d3 ea                	shr    %cl,%edx
  8022b4:	89 e9                	mov    %ebp,%ecx
  8022b6:	09 c2                	or     %eax,%edx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 14 24             	mov    %edx,(%esp)
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	d3 e2                	shl    %cl,%edx
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	89 c6                	mov    %eax,%esi
  8022d1:	d3 e3                	shl    %cl,%ebx
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 d0                	mov    %edx,%eax
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	09 d8                	or     %ebx,%eax
  8022dd:	89 d3                	mov    %edx,%ebx
  8022df:	89 f2                	mov    %esi,%edx
  8022e1:	f7 34 24             	divl   (%esp)
  8022e4:	89 d6                	mov    %edx,%esi
  8022e6:	d3 e3                	shl    %cl,%ebx
  8022e8:	f7 64 24 04          	mull   0x4(%esp)
  8022ec:	39 d6                	cmp    %edx,%esi
  8022ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022f2:	89 d1                	mov    %edx,%ecx
  8022f4:	89 c3                	mov    %eax,%ebx
  8022f6:	72 08                	jb     802300 <__umoddi3+0x110>
  8022f8:	75 11                	jne    80230b <__umoddi3+0x11b>
  8022fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022fe:	73 0b                	jae    80230b <__umoddi3+0x11b>
  802300:	2b 44 24 04          	sub    0x4(%esp),%eax
  802304:	1b 14 24             	sbb    (%esp),%edx
  802307:	89 d1                	mov    %edx,%ecx
  802309:	89 c3                	mov    %eax,%ebx
  80230b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80230f:	29 da                	sub    %ebx,%edx
  802311:	19 ce                	sbb    %ecx,%esi
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 f0                	mov    %esi,%eax
  802317:	d3 e0                	shl    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	d3 ea                	shr    %cl,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	d3 ee                	shr    %cl,%esi
  802321:	09 d0                	or     %edx,%eax
  802323:	89 f2                	mov    %esi,%edx
  802325:	83 c4 1c             	add    $0x1c,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	29 f9                	sub    %edi,%ecx
  802332:	19 d6                	sbb    %edx,%esi
  802334:	89 74 24 04          	mov    %esi,0x4(%esp)
  802338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80233c:	e9 18 ff ff ff       	jmp    802259 <__umoddi3+0x69>
