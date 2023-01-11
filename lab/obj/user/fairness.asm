
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 9e 0a 00 00       	call   800ade <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 52 0d 00 00       	call   800db0 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 00 23 80 00       	push   $0x802300
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 11 23 80 00       	push   $0x802311
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 7b 0d 00 00       	call   800e17 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 2d 0a 00 00       	call   800ade <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 7d 0f 00 00       	call   80106f <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 a1 09 00 00       	call   800a9d <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 2f 09 00 00       	call   800a60 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 54 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 d4 08 00 00       	call   800a60 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 74 1e 00 00       	call   802070 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 61 1f 00 00       	call   8021a0 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 32 23 80 00 	movsbl 0x802332(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025a:	83 fa 01             	cmp    $0x1,%edx
  80025d:	7e 0e                	jle    80026d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	8d 4a 08             	lea    0x8(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 02                	mov    (%edx),%eax
  800268:	8b 52 04             	mov    0x4(%edx),%edx
  80026b:	eb 22                	jmp    80028f <getuint+0x38>
	else if (lflag)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	74 10                	je     800281 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	eb 0e                	jmp    80028f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800297:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a0:	73 0a                	jae    8002ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	88 02                	mov    %al,(%edx)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
	va_end(ap);
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
  8002d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 89 03 00 00    	je     800670 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	53                   	push   %ebx
  8002eb:	50                   	push   %eax
  8002ec:	ff d6                	call   *%esi
  8002ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	83 c7 01             	add    $0x1,%edi
  8002f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f8:	83 f8 25             	cmp    $0x25,%eax
  8002fb:	75 e2                	jne    8002df <vprintfmt+0x14>
  8002fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800301:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800308:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 07                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800320:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	0f b6 07             	movzbl (%edi),%eax
  80032d:	0f b6 c8             	movzbl %al,%ecx
  800330:	83 e8 23             	sub    $0x23,%eax
  800333:	3c 55                	cmp    $0x55,%al
  800335:	0f 87 1a 03 00 00    	ja     800655 <vprintfmt+0x38a>
  80033b:	0f b6 c0             	movzbl %al,%eax
  80033e:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034c:	eb d6                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800351:	b8 00 00 00 00       	mov    $0x0,%eax
  800356:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800359:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800360:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800363:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800366:	83 fa 09             	cmp    $0x9,%edx
  800369:	77 39                	ja     8003a4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036e:	eb e9                	jmp    800359 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 48 04             	lea    0x4(%eax),%ecx
  800376:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800381:	eb 27                	jmp    8003aa <vprintfmt+0xdf>
  800383:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800386:	85 c0                	test   %eax,%eax
  800388:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038d:	0f 49 c8             	cmovns %eax,%ecx
  800390:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800396:	eb 8c                	jmp    800324 <vprintfmt+0x59>
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a2:	eb 80                	jmp    800324 <vprintfmt+0x59>
  8003a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ae:	0f 89 70 ff ff ff    	jns    800324 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c1:	e9 5e ff ff ff       	jmp    800324 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cc:	e9 53 ff ff ff       	jmp    800324 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	53                   	push   %ebx
  8003de:	ff 30                	pushl  (%eax)
  8003e0:	ff d6                	call   *%esi
			break;
  8003e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e8:	e9 04 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	99                   	cltd   
  8003f9:	31 d0                	xor    %edx,%eax
  8003fb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fd:	83 f8 0f             	cmp    $0xf,%eax
  800400:	7f 0b                	jg     80040d <vprintfmt+0x142>
  800402:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  800409:	85 d2                	test   %edx,%edx
  80040b:	75 18                	jne    800425 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040d:	50                   	push   %eax
  80040e:	68 4a 23 80 00       	push   $0x80234a
  800413:	53                   	push   %ebx
  800414:	56                   	push   %esi
  800415:	e8 94 fe ff ff       	call   8002ae <printfmt>
  80041a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800420:	e9 cc fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800425:	52                   	push   %edx
  800426:	68 2d 27 80 00       	push   $0x80272d
  80042b:	53                   	push   %ebx
  80042c:	56                   	push   %esi
  80042d:	e8 7c fe ff ff       	call   8002ae <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800438:	e9 b4 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800448:	85 ff                	test   %edi,%edi
  80044a:	b8 43 23 80 00       	mov    $0x802343,%eax
  80044f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800456:	0f 8e 94 00 00 00    	jle    8004f0 <vprintfmt+0x225>
  80045c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800460:	0f 84 98 00 00 00    	je     8004fe <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	ff 75 d0             	pushl  -0x30(%ebp)
  80046c:	57                   	push   %edi
  80046d:	e8 86 02 00 00       	call   8006f8 <strnlen>
  800472:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800475:	29 c1                	sub    %eax,%ecx
  800477:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800481:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800484:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800487:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	eb 0f                	jmp    80049a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	53                   	push   %ebx
  80048f:	ff 75 e0             	pushl  -0x20(%ebp)
  800492:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800494:	83 ef 01             	sub    $0x1,%edi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	85 ff                	test   %edi,%edi
  80049c:	7f ed                	jg     80048b <vprintfmt+0x1c0>
  80049e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a4:	85 c9                	test   %ecx,%ecx
  8004a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ab:	0f 49 c1             	cmovns %ecx,%eax
  8004ae:	29 c1                	sub    %eax,%ecx
  8004b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b9:	89 cb                	mov    %ecx,%ebx
  8004bb:	eb 4d                	jmp    80050a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c1:	74 1b                	je     8004de <vprintfmt+0x213>
  8004c3:	0f be c0             	movsbl %al,%eax
  8004c6:	83 e8 20             	sub    $0x20,%eax
  8004c9:	83 f8 5e             	cmp    $0x5e,%eax
  8004cc:	76 10                	jbe    8004de <vprintfmt+0x213>
					putch('?', putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 0c             	pushl  0xc(%ebp)
  8004d4:	6a 3f                	push   $0x3f
  8004d6:	ff 55 08             	call   *0x8(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb 0d                	jmp    8004eb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 0c             	pushl  0xc(%ebp)
  8004e4:	52                   	push   %edx
  8004e5:	ff 55 08             	call   *0x8(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004eb:	83 eb 01             	sub    $0x1,%ebx
  8004ee:	eb 1a                	jmp    80050a <vprintfmt+0x23f>
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fc:	eb 0c                	jmp    80050a <vprintfmt+0x23f>
  8004fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800501:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800504:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800507:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050a:	83 c7 01             	add    $0x1,%edi
  80050d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800511:	0f be d0             	movsbl %al,%edx
  800514:	85 d2                	test   %edx,%edx
  800516:	74 23                	je     80053b <vprintfmt+0x270>
  800518:	85 f6                	test   %esi,%esi
  80051a:	78 a1                	js     8004bd <vprintfmt+0x1f2>
  80051c:	83 ee 01             	sub    $0x1,%esi
  80051f:	79 9c                	jns    8004bd <vprintfmt+0x1f2>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	eb 18                	jmp    800543 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	6a 20                	push   $0x20
  800531:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 08                	jmp    800543 <vprintfmt+0x278>
  80053b:	89 df                	mov    %ebx,%edi
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	85 ff                	test   %edi,%edi
  800545:	7f e4                	jg     80052b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054a:	e9 a2 fd ff ff       	jmp    8002f1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054f:	83 fa 01             	cmp    $0x1,%edx
  800552:	7e 16                	jle    80056a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 08             	lea    0x8(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 50 04             	mov    0x4(%eax),%edx
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800568:	eb 32                	jmp    80059c <vprintfmt+0x2d1>
	else if (lflag)
  80056a:	85 d2                	test   %edx,%edx
  80056c:	74 18                	je     800586 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 04             	lea    0x4(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 c1                	mov    %eax,%ecx
  80057e:	c1 f9 1f             	sar    $0x1f,%ecx
  800581:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800584:	eb 16                	jmp    80059c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 c1                	mov    %eax,%ecx
  800596:	c1 f9 1f             	sar    $0x1f,%ecx
  800599:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ab:	79 74                	jns    800621 <vprintfmt+0x356>
				putch('-', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	53                   	push   %ebx
  8005b1:	6a 2d                	push   $0x2d
  8005b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005bb:	f7 d8                	neg    %eax
  8005bd:	83 d2 00             	adc    $0x0,%edx
  8005c0:	f7 da                	neg    %edx
  8005c2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ca:	eb 55                	jmp    800621 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cf:	e8 83 fc ff ff       	call   800257 <getuint>
			base = 10;
  8005d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d9:	eb 46                	jmp    800621 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	e8 74 fc ff ff       	call   800257 <getuint>
			base = 8;
  8005e3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e8:	eb 37                	jmp    800621 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	53                   	push   %ebx
  8005ee:	6a 30                	push   $0x30
  8005f0:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f2:	83 c4 08             	add    $0x8,%esp
  8005f5:	53                   	push   %ebx
  8005f6:	6a 78                	push   $0x78
  8005f8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800612:	eb 0d                	jmp    800621 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800614:	8d 45 14             	lea    0x14(%ebp),%eax
  800617:	e8 3b fc ff ff       	call   800257 <getuint>
			base = 16;
  80061c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800628:	57                   	push   %edi
  800629:	ff 75 e0             	pushl  -0x20(%ebp)
  80062c:	51                   	push   %ecx
  80062d:	52                   	push   %edx
  80062e:	50                   	push   %eax
  80062f:	89 da                	mov    %ebx,%edx
  800631:	89 f0                	mov    %esi,%eax
  800633:	e8 70 fb ff ff       	call   8001a8 <printnum>
			break;
  800638:	83 c4 20             	add    $0x20,%esp
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063e:	e9 ae fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	51                   	push   %ecx
  800648:	ff d6                	call   *%esi
			break;
  80064a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800650:	e9 9c fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 25                	push   $0x25
  80065b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb 03                	jmp    800665 <vprintfmt+0x39a>
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800669:	75 f7                	jne    800662 <vprintfmt+0x397>
  80066b:	e9 81 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	83 ec 18             	sub    $0x18,%esp
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800684:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800687:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800695:	85 c0                	test   %eax,%eax
  800697:	74 26                	je     8006bf <vsnprintf+0x47>
  800699:	85 d2                	test   %edx,%edx
  80069b:	7e 22                	jle    8006bf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069d:	ff 75 14             	pushl  0x14(%ebp)
  8006a0:	ff 75 10             	pushl  0x10(%ebp)
  8006a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a6:	50                   	push   %eax
  8006a7:	68 91 02 80 00       	push   $0x800291
  8006ac:	e8 1a fc ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb 05                	jmp    8006c4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c4:	c9                   	leave  
  8006c5:	c3                   	ret    

008006c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cf:	50                   	push   %eax
  8006d0:	ff 75 10             	pushl  0x10(%ebp)
  8006d3:	ff 75 0c             	pushl  0xc(%ebp)
  8006d6:	ff 75 08             	pushl  0x8(%ebp)
  8006d9:	e8 9a ff ff ff       	call   800678 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 03                	jmp    8006f0 <strlen+0x10>
		n++;
  8006ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f4:	75 f7                	jne    8006ed <strlen+0xd>
		n++;
	return n;
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800701:	ba 00 00 00 00       	mov    $0x0,%edx
  800706:	eb 03                	jmp    80070b <strnlen+0x13>
		n++;
  800708:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070b:	39 c2                	cmp    %eax,%edx
  80070d:	74 08                	je     800717 <strnlen+0x1f>
  80070f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800713:	75 f3                	jne    800708 <strnlen+0x10>
  800715:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	53                   	push   %ebx
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800723:	89 c2                	mov    %eax,%edx
  800725:	83 c2 01             	add    $0x1,%edx
  800728:	83 c1 01             	add    $0x1,%ecx
  80072b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800732:	84 db                	test   %bl,%bl
  800734:	75 ef                	jne    800725 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800736:	5b                   	pop    %ebx
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800740:	53                   	push   %ebx
  800741:	e8 9a ff ff ff       	call   8006e0 <strlen>
  800746:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	01 d8                	add    %ebx,%eax
  80074e:	50                   	push   %eax
  80074f:	e8 c5 ff ff ff       	call   800719 <strcpy>
	return dst;
}
  800754:	89 d8                	mov    %ebx,%eax
  800756:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	8b 75 08             	mov    0x8(%ebp),%esi
  800763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800766:	89 f3                	mov    %esi,%ebx
  800768:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076b:	89 f2                	mov    %esi,%edx
  80076d:	eb 0f                	jmp    80077e <strncpy+0x23>
		*dst++ = *src;
  80076f:	83 c2 01             	add    $0x1,%edx
  800772:	0f b6 01             	movzbl (%ecx),%eax
  800775:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800778:	80 39 01             	cmpb   $0x1,(%ecx)
  80077b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077e:	39 da                	cmp    %ebx,%edx
  800780:	75 ed                	jne    80076f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800782:	89 f0                	mov    %esi,%eax
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	56                   	push   %esi
  80078c:	53                   	push   %ebx
  80078d:	8b 75 08             	mov    0x8(%ebp),%esi
  800790:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800793:	8b 55 10             	mov    0x10(%ebp),%edx
  800796:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800798:	85 d2                	test   %edx,%edx
  80079a:	74 21                	je     8007bd <strlcpy+0x35>
  80079c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a0:	89 f2                	mov    %esi,%edx
  8007a2:	eb 09                	jmp    8007ad <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	83 c1 01             	add    $0x1,%ecx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ad:	39 c2                	cmp    %eax,%edx
  8007af:	74 09                	je     8007ba <strlcpy+0x32>
  8007b1:	0f b6 19             	movzbl (%ecx),%ebx
  8007b4:	84 db                	test   %bl,%bl
  8007b6:	75 ec                	jne    8007a4 <strlcpy+0x1c>
  8007b8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ba:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bd:	29 f0                	sub    %esi,%eax
}
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cc:	eb 06                	jmp    8007d4 <strcmp+0x11>
		p++, q++;
  8007ce:	83 c1 01             	add    $0x1,%ecx
  8007d1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d4:	0f b6 01             	movzbl (%ecx),%eax
  8007d7:	84 c0                	test   %al,%al
  8007d9:	74 04                	je     8007df <strcmp+0x1c>
  8007db:	3a 02                	cmp    (%edx),%al
  8007dd:	74 ef                	je     8007ce <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007df:	0f b6 c0             	movzbl %al,%eax
  8007e2:	0f b6 12             	movzbl (%edx),%edx
  8007e5:	29 d0                	sub    %edx,%eax
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f3:	89 c3                	mov    %eax,%ebx
  8007f5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f8:	eb 06                	jmp    800800 <strncmp+0x17>
		n--, p++, q++;
  8007fa:	83 c0 01             	add    $0x1,%eax
  8007fd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800800:	39 d8                	cmp    %ebx,%eax
  800802:	74 15                	je     800819 <strncmp+0x30>
  800804:	0f b6 08             	movzbl (%eax),%ecx
  800807:	84 c9                	test   %cl,%cl
  800809:	74 04                	je     80080f <strncmp+0x26>
  80080b:	3a 0a                	cmp    (%edx),%cl
  80080d:	74 eb                	je     8007fa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080f:	0f b6 00             	movzbl (%eax),%eax
  800812:	0f b6 12             	movzbl (%edx),%edx
  800815:	29 d0                	sub    %edx,%eax
  800817:	eb 05                	jmp    80081e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081e:	5b                   	pop    %ebx
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 07                	jmp    800834 <strchr+0x13>
		if (*s == c)
  80082d:	38 ca                	cmp    %cl,%dl
  80082f:	74 0f                	je     800840 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	0f b6 10             	movzbl (%eax),%edx
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f2                	jne    80082d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084c:	eb 03                	jmp    800851 <strfind+0xf>
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800854:	38 ca                	cmp    %cl,%dl
  800856:	74 04                	je     80085c <strfind+0x1a>
  800858:	84 d2                	test   %dl,%dl
  80085a:	75 f2                	jne    80084e <strfind+0xc>
			break;
	return (char *) s;
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	57                   	push   %edi
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 7d 08             	mov    0x8(%ebp),%edi
  800867:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086a:	85 c9                	test   %ecx,%ecx
  80086c:	74 36                	je     8008a4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800874:	75 28                	jne    80089e <memset+0x40>
  800876:	f6 c1 03             	test   $0x3,%cl
  800879:	75 23                	jne    80089e <memset+0x40>
		c &= 0xFF;
  80087b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087f:	89 d3                	mov    %edx,%ebx
  800881:	c1 e3 08             	shl    $0x8,%ebx
  800884:	89 d6                	mov    %edx,%esi
  800886:	c1 e6 18             	shl    $0x18,%esi
  800889:	89 d0                	mov    %edx,%eax
  80088b:	c1 e0 10             	shl    $0x10,%eax
  80088e:	09 f0                	or     %esi,%eax
  800890:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800892:	89 d8                	mov    %ebx,%eax
  800894:	09 d0                	or     %edx,%eax
  800896:	c1 e9 02             	shr    $0x2,%ecx
  800899:	fc                   	cld    
  80089a:	f3 ab                	rep stos %eax,%es:(%edi)
  80089c:	eb 06                	jmp    8008a4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	fc                   	cld    
  8008a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a4:	89 f8                	mov    %edi,%eax
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	57                   	push   %edi
  8008af:	56                   	push   %esi
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b9:	39 c6                	cmp    %eax,%esi
  8008bb:	73 35                	jae    8008f2 <memmove+0x47>
  8008bd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c0:	39 d0                	cmp    %edx,%eax
  8008c2:	73 2e                	jae    8008f2 <memmove+0x47>
		s += n;
		d += n;
  8008c4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c7:	89 d6                	mov    %edx,%esi
  8008c9:	09 fe                	or     %edi,%esi
  8008cb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d1:	75 13                	jne    8008e6 <memmove+0x3b>
  8008d3:	f6 c1 03             	test   $0x3,%cl
  8008d6:	75 0e                	jne    8008e6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d8:	83 ef 04             	sub    $0x4,%edi
  8008db:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008de:	c1 e9 02             	shr    $0x2,%ecx
  8008e1:	fd                   	std    
  8008e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e4:	eb 09                	jmp    8008ef <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e6:	83 ef 01             	sub    $0x1,%edi
  8008e9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ec:	fd                   	std    
  8008ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ef:	fc                   	cld    
  8008f0:	eb 1d                	jmp    80090f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	09 c2                	or     %eax,%edx
  8008f6:	f6 c2 03             	test   $0x3,%dl
  8008f9:	75 0f                	jne    80090a <memmove+0x5f>
  8008fb:	f6 c1 03             	test   $0x3,%cl
  8008fe:	75 0a                	jne    80090a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800900:	c1 e9 02             	shr    $0x2,%ecx
  800903:	89 c7                	mov    %eax,%edi
  800905:	fc                   	cld    
  800906:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800908:	eb 05                	jmp    80090f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090a:	89 c7                	mov    %eax,%edi
  80090c:	fc                   	cld    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090f:	5e                   	pop    %esi
  800910:	5f                   	pop    %edi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800916:	ff 75 10             	pushl  0x10(%ebp)
  800919:	ff 75 0c             	pushl  0xc(%ebp)
  80091c:	ff 75 08             	pushl  0x8(%ebp)
  80091f:	e8 87 ff ff ff       	call   8008ab <memmove>
}
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	89 c6                	mov    %eax,%esi
  800933:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800936:	eb 1a                	jmp    800952 <memcmp+0x2c>
		if (*s1 != *s2)
  800938:	0f b6 08             	movzbl (%eax),%ecx
  80093b:	0f b6 1a             	movzbl (%edx),%ebx
  80093e:	38 d9                	cmp    %bl,%cl
  800940:	74 0a                	je     80094c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800942:	0f b6 c1             	movzbl %cl,%eax
  800945:	0f b6 db             	movzbl %bl,%ebx
  800948:	29 d8                	sub    %ebx,%eax
  80094a:	eb 0f                	jmp    80095b <memcmp+0x35>
		s1++, s2++;
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800952:	39 f0                	cmp    %esi,%eax
  800954:	75 e2                	jne    800938 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800966:	89 c1                	mov    %eax,%ecx
  800968:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096f:	eb 0a                	jmp    80097b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800971:	0f b6 10             	movzbl (%eax),%edx
  800974:	39 da                	cmp    %ebx,%edx
  800976:	74 07                	je     80097f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	39 c8                	cmp    %ecx,%eax
  80097d:	72 f2                	jb     800971 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097f:	5b                   	pop    %ebx
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098e:	eb 03                	jmp    800993 <strtol+0x11>
		s++;
  800990:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800993:	0f b6 01             	movzbl (%ecx),%eax
  800996:	3c 20                	cmp    $0x20,%al
  800998:	74 f6                	je     800990 <strtol+0xe>
  80099a:	3c 09                	cmp    $0x9,%al
  80099c:	74 f2                	je     800990 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099e:	3c 2b                	cmp    $0x2b,%al
  8009a0:	75 0a                	jne    8009ac <strtol+0x2a>
		s++;
  8009a2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009aa:	eb 11                	jmp    8009bd <strtol+0x3b>
  8009ac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b1:	3c 2d                	cmp    $0x2d,%al
  8009b3:	75 08                	jne    8009bd <strtol+0x3b>
		s++, neg = 1;
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c3:	75 15                	jne    8009da <strtol+0x58>
  8009c5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c8:	75 10                	jne    8009da <strtol+0x58>
  8009ca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ce:	75 7c                	jne    800a4c <strtol+0xca>
		s += 2, base = 16;
  8009d0:	83 c1 02             	add    $0x2,%ecx
  8009d3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d8:	eb 16                	jmp    8009f0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009da:	85 db                	test   %ebx,%ebx
  8009dc:	75 12                	jne    8009f0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009de:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e6:	75 08                	jne    8009f0 <strtol+0x6e>
		s++, base = 8;
  8009e8:	83 c1 01             	add    $0x1,%ecx
  8009eb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f8:	0f b6 11             	movzbl (%ecx),%edx
  8009fb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fe:	89 f3                	mov    %esi,%ebx
  800a00:	80 fb 09             	cmp    $0x9,%bl
  800a03:	77 08                	ja     800a0d <strtol+0x8b>
			dig = *s - '0';
  800a05:	0f be d2             	movsbl %dl,%edx
  800a08:	83 ea 30             	sub    $0x30,%edx
  800a0b:	eb 22                	jmp    800a2f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a10:	89 f3                	mov    %esi,%ebx
  800a12:	80 fb 19             	cmp    $0x19,%bl
  800a15:	77 08                	ja     800a1f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a17:	0f be d2             	movsbl %dl,%edx
  800a1a:	83 ea 57             	sub    $0x57,%edx
  800a1d:	eb 10                	jmp    800a2f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a22:	89 f3                	mov    %esi,%ebx
  800a24:	80 fb 19             	cmp    $0x19,%bl
  800a27:	77 16                	ja     800a3f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a29:	0f be d2             	movsbl %dl,%edx
  800a2c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a32:	7d 0b                	jge    800a3f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3d:	eb b9                	jmp    8009f8 <strtol+0x76>

	if (endptr)
  800a3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a43:	74 0d                	je     800a52 <strtol+0xd0>
		*endptr = (char *) s;
  800a45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a48:	89 0e                	mov    %ecx,(%esi)
  800a4a:	eb 06                	jmp    800a52 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4c:	85 db                	test   %ebx,%ebx
  800a4e:	74 98                	je     8009e8 <strtol+0x66>
  800a50:	eb 9e                	jmp    8009f0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a52:	89 c2                	mov    %eax,%edx
  800a54:	f7 da                	neg    %edx
  800a56:	85 ff                	test   %edi,%edi
  800a58:	0f 45 c2             	cmovne %edx,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	89 d1                	mov    %edx,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	89 cb                	mov    %ecx,%ebx
  800ab5:	89 cf                	mov    %ecx,%edi
  800ab7:	89 ce                	mov    %ecx,%esi
  800ab9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7e 17                	jle    800ad6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	50                   	push   %eax
  800ac3:	6a 03                	push   $0x3
  800ac5:	68 3f 26 80 00       	push   $0x80263f
  800aca:	6a 23                	push   $0x23
  800acc:	68 5c 26 80 00       	push   $0x80265c
  800ad1:	e8 12 15 00 00       	call   801fe8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 02 00 00 00       	mov    $0x2,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_yield>:

void
sys_yield(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	be 00 00 00 00       	mov    $0x0,%esi
  800b2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b38:	89 f7                	mov    %esi,%edi
  800b3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 04                	push   $0x4
  800b46:	68 3f 26 80 00       	push   $0x80263f
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 5c 26 80 00       	push   $0x80265c
  800b52:	e8 91 14 00 00       	call   801fe8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b79:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7e 17                	jle    800b99 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	50                   	push   %eax
  800b86:	6a 05                	push   $0x5
  800b88:	68 3f 26 80 00       	push   $0x80263f
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 5c 26 80 00       	push   $0x80265c
  800b94:	e8 4f 14 00 00       	call   801fe8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800baf:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bba:	89 df                	mov    %ebx,%edi
  800bbc:	89 de                	mov    %ebx,%esi
  800bbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 17                	jle    800bdb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 06                	push   $0x6
  800bca:	68 3f 26 80 00       	push   $0x80263f
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 5c 26 80 00       	push   $0x80265c
  800bd6:	e8 0d 14 00 00       	call   801fe8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf1:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	89 df                	mov    %ebx,%edi
  800bfe:	89 de                	mov    %ebx,%esi
  800c00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	7e 17                	jle    800c1d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 08                	push   $0x8
  800c0c:	68 3f 26 80 00       	push   $0x80263f
  800c11:	6a 23                	push   $0x23
  800c13:	68 5c 26 80 00       	push   $0x80265c
  800c18:	e8 cb 13 00 00       	call   801fe8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c33:	b8 09 00 00 00       	mov    $0x9,%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	89 df                	mov    %ebx,%edi
  800c40:	89 de                	mov    %ebx,%esi
  800c42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 09                	push   $0x9
  800c4e:	68 3f 26 80 00       	push   $0x80263f
  800c53:	6a 23                	push   $0x23
  800c55:	68 5c 26 80 00       	push   $0x80265c
  800c5a:	e8 89 13 00 00       	call   801fe8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	89 df                	mov    %ebx,%edi
  800c82:	89 de                	mov    %ebx,%esi
  800c84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 17                	jle    800ca1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	50                   	push   %eax
  800c8e:	6a 0a                	push   $0xa
  800c90:	68 3f 26 80 00       	push   $0x80263f
  800c95:	6a 23                	push   $0x23
  800c97:	68 5c 26 80 00       	push   $0x80265c
  800c9c:	e8 47 13 00 00       	call   801fe8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 cb                	mov    %ecx,%ebx
  800ce4:	89 cf                	mov    %ecx,%edi
  800ce6:	89 ce                	mov    %ecx,%esi
  800ce8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 0d                	push   $0xd
  800cf4:	68 3f 26 80 00       	push   $0x80263f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 5c 26 80 00       	push   $0x80265c
  800d00:	e8 e3 12 00 00       	call   801fe8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	ba 00 00 00 00       	mov    $0x0,%edx
  800d18:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1d:	89 d1                	mov    %edx,%ecx
  800d1f:	89 d3                	mov    %edx,%ebx
  800d21:	89 d7                	mov    %edx,%edi
  800d23:	89 d6                	mov    %edx,%esi
  800d25:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 df                	mov    %ebx,%edi
  800d47:	89 de                	mov    %ebx,%esi
  800d49:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7e 17                	jle    800d66 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	50                   	push   %eax
  800d53:	6a 0f                	push   $0xf
  800d55:	68 3f 26 80 00       	push   $0x80263f
  800d5a:	6a 23                	push   $0x23
  800d5c:	68 5c 26 80 00       	push   $0x80265c
  800d61:	e8 82 12 00 00       	call   801fe8 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7c:	b8 10 00 00 00       	mov    $0x10,%eax
  800d81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	89 df                	mov    %ebx,%edi
  800d89:	89 de                	mov    %ebx,%esi
  800d8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	7e 17                	jle    800da8 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	50                   	push   %eax
  800d95:	6a 10                	push   $0x10
  800d97:	68 3f 26 80 00       	push   $0x80263f
  800d9c:	6a 23                	push   $0x23
  800d9e:	68 5c 26 80 00       	push   $0x80265c
  800da3:	e8 40 12 00 00       	call   801fe8 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	8b 75 08             	mov    0x8(%ebp),%esi
  800db8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  800dbe:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  800dc0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800dc5:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	e8 fb fe ff ff       	call   800ccc <sys_ipc_recv>

	if (from_env_store != NULL)
  800dd1:	83 c4 10             	add    $0x10,%esp
  800dd4:	85 f6                	test   %esi,%esi
  800dd6:	74 14                	je     800dec <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  800dd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	78 09                	js     800dea <ipc_recv+0x3a>
  800de1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800de7:	8b 52 74             	mov    0x74(%edx),%edx
  800dea:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  800dec:	85 db                	test   %ebx,%ebx
  800dee:	74 14                	je     800e04 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  800df0:	ba 00 00 00 00       	mov    $0x0,%edx
  800df5:	85 c0                	test   %eax,%eax
  800df7:	78 09                	js     800e02 <ipc_recv+0x52>
  800df9:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800dff:	8b 52 78             	mov    0x78(%edx),%edx
  800e02:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  800e04:	85 c0                	test   %eax,%eax
  800e06:	78 08                	js     800e10 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  800e08:	a1 08 40 80 00       	mov    0x804008,%eax
  800e0d:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e23:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  800e29:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  800e2b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800e30:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  800e33:	ff 75 14             	pushl  0x14(%ebp)
  800e36:	53                   	push   %ebx
  800e37:	56                   	push   %esi
  800e38:	57                   	push   %edi
  800e39:	e8 6b fe ff ff       	call   800ca9 <sys_ipc_try_send>

		if (err < 0) {
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	85 c0                	test   %eax,%eax
  800e43:	79 1e                	jns    800e63 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  800e45:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e48:	75 07                	jne    800e51 <ipc_send+0x3a>
				sys_yield();
  800e4a:	e8 ae fc ff ff       	call   800afd <sys_yield>
  800e4f:	eb e2                	jmp    800e33 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  800e51:	50                   	push   %eax
  800e52:	68 6a 26 80 00       	push   $0x80266a
  800e57:	6a 49                	push   $0x49
  800e59:	68 77 26 80 00       	push   $0x802677
  800e5e:	e8 85 11 00 00       	call   801fe8 <_panic>
		}

	} while (err < 0);

}
  800e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e76:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e79:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e7f:	8b 52 50             	mov    0x50(%edx),%edx
  800e82:	39 ca                	cmp    %ecx,%edx
  800e84:	75 0d                	jne    800e93 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e86:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e89:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e8e:	8b 40 48             	mov    0x48(%eax),%eax
  800e91:	eb 0f                	jmp    800ea2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e93:	83 c0 01             	add    $0x1,%eax
  800e96:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e9b:	75 d9                	jne    800e76 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaa:	05 00 00 00 30       	add    $0x30000000,%eax
  800eaf:	c1 e8 0c             	shr    $0xc,%eax
}
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	05 00 00 00 30       	add    $0x30000000,%eax
  800ebf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ec4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed6:	89 c2                	mov    %eax,%edx
  800ed8:	c1 ea 16             	shr    $0x16,%edx
  800edb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee2:	f6 c2 01             	test   $0x1,%dl
  800ee5:	74 11                	je     800ef8 <fd_alloc+0x2d>
  800ee7:	89 c2                	mov    %eax,%edx
  800ee9:	c1 ea 0c             	shr    $0xc,%edx
  800eec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef3:	f6 c2 01             	test   $0x1,%dl
  800ef6:	75 09                	jne    800f01 <fd_alloc+0x36>
			*fd_store = fd;
  800ef8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	eb 17                	jmp    800f18 <fd_alloc+0x4d>
  800f01:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f06:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f0b:	75 c9                	jne    800ed6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f0d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f13:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f20:	83 f8 1f             	cmp    $0x1f,%eax
  800f23:	77 36                	ja     800f5b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f25:	c1 e0 0c             	shl    $0xc,%eax
  800f28:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f2d:	89 c2                	mov    %eax,%edx
  800f2f:	c1 ea 16             	shr    $0x16,%edx
  800f32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f39:	f6 c2 01             	test   $0x1,%dl
  800f3c:	74 24                	je     800f62 <fd_lookup+0x48>
  800f3e:	89 c2                	mov    %eax,%edx
  800f40:	c1 ea 0c             	shr    $0xc,%edx
  800f43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f4a:	f6 c2 01             	test   $0x1,%dl
  800f4d:	74 1a                	je     800f69 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f52:	89 02                	mov    %eax,(%edx)
	return 0;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
  800f59:	eb 13                	jmp    800f6e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f60:	eb 0c                	jmp    800f6e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f67:	eb 05                	jmp    800f6e <fd_lookup+0x54>
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	83 ec 08             	sub    $0x8,%esp
  800f76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f79:	ba 00 27 80 00       	mov    $0x802700,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f7e:	eb 13                	jmp    800f93 <dev_lookup+0x23>
  800f80:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f83:	39 08                	cmp    %ecx,(%eax)
  800f85:	75 0c                	jne    800f93 <dev_lookup+0x23>
			*dev = devtab[i];
  800f87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f91:	eb 2e                	jmp    800fc1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f93:	8b 02                	mov    (%edx),%eax
  800f95:	85 c0                	test   %eax,%eax
  800f97:	75 e7                	jne    800f80 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f99:	a1 08 40 80 00       	mov    0x804008,%eax
  800f9e:	8b 40 48             	mov    0x48(%eax),%eax
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	51                   	push   %ecx
  800fa5:	50                   	push   %eax
  800fa6:	68 84 26 80 00       	push   $0x802684
  800fab:	e8 e4 f1 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    

00800fc3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 10             	sub    $0x10,%esp
  800fcb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd4:	50                   	push   %eax
  800fd5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fdb:	c1 e8 0c             	shr    $0xc,%eax
  800fde:	50                   	push   %eax
  800fdf:	e8 36 ff ff ff       	call   800f1a <fd_lookup>
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 05                	js     800ff0 <fd_close+0x2d>
	    || fd != fd2)
  800feb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fee:	74 0c                	je     800ffc <fd_close+0x39>
		return (must_exist ? r : 0);
  800ff0:	84 db                	test   %bl,%bl
  800ff2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff7:	0f 44 c2             	cmove  %edx,%eax
  800ffa:	eb 41                	jmp    80103d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ffc:	83 ec 08             	sub    $0x8,%esp
  800fff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	ff 36                	pushl  (%esi)
  801005:	e8 66 ff ff ff       	call   800f70 <dev_lookup>
  80100a:	89 c3                	mov    %eax,%ebx
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 1a                	js     80102d <fd_close+0x6a>
		if (dev->dev_close)
  801013:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801016:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801019:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80101e:	85 c0                	test   %eax,%eax
  801020:	74 0b                	je     80102d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	56                   	push   %esi
  801026:	ff d0                	call   *%eax
  801028:	89 c3                	mov    %eax,%ebx
  80102a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80102d:	83 ec 08             	sub    $0x8,%esp
  801030:	56                   	push   %esi
  801031:	6a 00                	push   $0x0
  801033:	e8 69 fb ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	89 d8                	mov    %ebx,%eax
}
  80103d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80104a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104d:	50                   	push   %eax
  80104e:	ff 75 08             	pushl  0x8(%ebp)
  801051:	e8 c4 fe ff ff       	call   800f1a <fd_lookup>
  801056:	83 c4 08             	add    $0x8,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 10                	js     80106d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80105d:	83 ec 08             	sub    $0x8,%esp
  801060:	6a 01                	push   $0x1
  801062:	ff 75 f4             	pushl  -0xc(%ebp)
  801065:	e8 59 ff ff ff       	call   800fc3 <fd_close>
  80106a:	83 c4 10             	add    $0x10,%esp
}
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <close_all>:

void
close_all(void)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	53                   	push   %ebx
  801073:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801076:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	53                   	push   %ebx
  80107f:	e8 c0 ff ff ff       	call   801044 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801084:	83 c3 01             	add    $0x1,%ebx
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	83 fb 20             	cmp    $0x20,%ebx
  80108d:	75 ec                	jne    80107b <close_all+0xc>
		close(i);
}
  80108f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
  80109a:	83 ec 2c             	sub    $0x2c,%esp
  80109d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010a3:	50                   	push   %eax
  8010a4:	ff 75 08             	pushl  0x8(%ebp)
  8010a7:	e8 6e fe ff ff       	call   800f1a <fd_lookup>
  8010ac:	83 c4 08             	add    $0x8,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	0f 88 c1 00 00 00    	js     801178 <dup+0xe4>
		return r;
	close(newfdnum);
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	56                   	push   %esi
  8010bb:	e8 84 ff ff ff       	call   801044 <close>

	newfd = INDEX2FD(newfdnum);
  8010c0:	89 f3                	mov    %esi,%ebx
  8010c2:	c1 e3 0c             	shl    $0xc,%ebx
  8010c5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010cb:	83 c4 04             	add    $0x4,%esp
  8010ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d1:	e8 de fd ff ff       	call   800eb4 <fd2data>
  8010d6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010d8:	89 1c 24             	mov    %ebx,(%esp)
  8010db:	e8 d4 fd ff ff       	call   800eb4 <fd2data>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010e6:	89 f8                	mov    %edi,%eax
  8010e8:	c1 e8 16             	shr    $0x16,%eax
  8010eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f2:	a8 01                	test   $0x1,%al
  8010f4:	74 37                	je     80112d <dup+0x99>
  8010f6:	89 f8                	mov    %edi,%eax
  8010f8:	c1 e8 0c             	shr    $0xc,%eax
  8010fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801102:	f6 c2 01             	test   $0x1,%dl
  801105:	74 26                	je     80112d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801107:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	25 07 0e 00 00       	and    $0xe07,%eax
  801116:	50                   	push   %eax
  801117:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111a:	6a 00                	push   $0x0
  80111c:	57                   	push   %edi
  80111d:	6a 00                	push   $0x0
  80111f:	e8 3b fa ff ff       	call   800b5f <sys_page_map>
  801124:	89 c7                	mov    %eax,%edi
  801126:	83 c4 20             	add    $0x20,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 2e                	js     80115b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80112d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801130:	89 d0                	mov    %edx,%eax
  801132:	c1 e8 0c             	shr    $0xc,%eax
  801135:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	25 07 0e 00 00       	and    $0xe07,%eax
  801144:	50                   	push   %eax
  801145:	53                   	push   %ebx
  801146:	6a 00                	push   $0x0
  801148:	52                   	push   %edx
  801149:	6a 00                	push   $0x0
  80114b:	e8 0f fa ff ff       	call   800b5f <sys_page_map>
  801150:	89 c7                	mov    %eax,%edi
  801152:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801155:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801157:	85 ff                	test   %edi,%edi
  801159:	79 1d                	jns    801178 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	53                   	push   %ebx
  80115f:	6a 00                	push   $0x0
  801161:	e8 3b fa ff ff       	call   800ba1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801166:	83 c4 08             	add    $0x8,%esp
  801169:	ff 75 d4             	pushl  -0x2c(%ebp)
  80116c:	6a 00                	push   $0x0
  80116e:	e8 2e fa ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	89 f8                	mov    %edi,%eax
}
  801178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 14             	sub    $0x14,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	53                   	push   %ebx
  80118f:	e8 86 fd ff ff       	call   800f1a <fd_lookup>
  801194:	83 c4 08             	add    $0x8,%esp
  801197:	89 c2                	mov    %eax,%edx
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 6d                	js     80120a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a3:	50                   	push   %eax
  8011a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a7:	ff 30                	pushl  (%eax)
  8011a9:	e8 c2 fd ff ff       	call   800f70 <dev_lookup>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 4c                	js     801201 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011b8:	8b 42 08             	mov    0x8(%edx),%eax
  8011bb:	83 e0 03             	and    $0x3,%eax
  8011be:	83 f8 01             	cmp    $0x1,%eax
  8011c1:	75 21                	jne    8011e4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c8:	8b 40 48             	mov    0x48(%eax),%eax
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	53                   	push   %ebx
  8011cf:	50                   	push   %eax
  8011d0:	68 c5 26 80 00       	push   $0x8026c5
  8011d5:	e8 ba ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011e2:	eb 26                	jmp    80120a <read+0x8a>
	}
	if (!dev->dev_read)
  8011e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e7:	8b 40 08             	mov    0x8(%eax),%eax
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	74 17                	je     801205 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	ff 75 10             	pushl  0x10(%ebp)
  8011f4:	ff 75 0c             	pushl  0xc(%ebp)
  8011f7:	52                   	push   %edx
  8011f8:	ff d0                	call   *%eax
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	eb 09                	jmp    80120a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801201:	89 c2                	mov    %eax,%edx
  801203:	eb 05                	jmp    80120a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801205:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80120a:	89 d0                	mov    %edx,%eax
  80120c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 0c             	sub    $0xc,%esp
  80121a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801220:	bb 00 00 00 00       	mov    $0x0,%ebx
  801225:	eb 21                	jmp    801248 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	89 f0                	mov    %esi,%eax
  80122c:	29 d8                	sub    %ebx,%eax
  80122e:	50                   	push   %eax
  80122f:	89 d8                	mov    %ebx,%eax
  801231:	03 45 0c             	add    0xc(%ebp),%eax
  801234:	50                   	push   %eax
  801235:	57                   	push   %edi
  801236:	e8 45 ff ff ff       	call   801180 <read>
		if (m < 0)
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 10                	js     801252 <readn+0x41>
			return m;
		if (m == 0)
  801242:	85 c0                	test   %eax,%eax
  801244:	74 0a                	je     801250 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801246:	01 c3                	add    %eax,%ebx
  801248:	39 f3                	cmp    %esi,%ebx
  80124a:	72 db                	jb     801227 <readn+0x16>
  80124c:	89 d8                	mov    %ebx,%eax
  80124e:	eb 02                	jmp    801252 <readn+0x41>
  801250:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5f                   	pop    %edi
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	53                   	push   %ebx
  80125e:	83 ec 14             	sub    $0x14,%esp
  801261:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801264:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	53                   	push   %ebx
  801269:	e8 ac fc ff ff       	call   800f1a <fd_lookup>
  80126e:	83 c4 08             	add    $0x8,%esp
  801271:	89 c2                	mov    %eax,%edx
  801273:	85 c0                	test   %eax,%eax
  801275:	78 68                	js     8012df <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	ff 30                	pushl  (%eax)
  801283:	e8 e8 fc ff ff       	call   800f70 <dev_lookup>
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 47                	js     8012d6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801292:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801296:	75 21                	jne    8012b9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801298:	a1 08 40 80 00       	mov    0x804008,%eax
  80129d:	8b 40 48             	mov    0x48(%eax),%eax
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	53                   	push   %ebx
  8012a4:	50                   	push   %eax
  8012a5:	68 e1 26 80 00       	push   $0x8026e1
  8012aa:	e8 e5 ee ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b7:	eb 26                	jmp    8012df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8012bf:	85 d2                	test   %edx,%edx
  8012c1:	74 17                	je     8012da <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c3:	83 ec 04             	sub    $0x4,%esp
  8012c6:	ff 75 10             	pushl  0x10(%ebp)
  8012c9:	ff 75 0c             	pushl  0xc(%ebp)
  8012cc:	50                   	push   %eax
  8012cd:	ff d2                	call   *%edx
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	eb 09                	jmp    8012df <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	eb 05                	jmp    8012df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012df:	89 d0                	mov    %edx,%eax
  8012e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	ff 75 08             	pushl  0x8(%ebp)
  8012f3:	e8 22 fc ff ff       	call   800f1a <fd_lookup>
  8012f8:	83 c4 08             	add    $0x8,%esp
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	78 0e                	js     80130d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801302:	8b 55 0c             	mov    0xc(%ebp),%edx
  801305:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	53                   	push   %ebx
  801313:	83 ec 14             	sub    $0x14,%esp
  801316:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801319:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	53                   	push   %ebx
  80131e:	e8 f7 fb ff ff       	call   800f1a <fd_lookup>
  801323:	83 c4 08             	add    $0x8,%esp
  801326:	89 c2                	mov    %eax,%edx
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 65                	js     801391 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801336:	ff 30                	pushl  (%eax)
  801338:	e8 33 fc ff ff       	call   800f70 <dev_lookup>
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	85 c0                	test   %eax,%eax
  801342:	78 44                	js     801388 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801344:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801347:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80134b:	75 21                	jne    80136e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80134d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801352:	8b 40 48             	mov    0x48(%eax),%eax
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	53                   	push   %ebx
  801359:	50                   	push   %eax
  80135a:	68 a4 26 80 00       	push   $0x8026a4
  80135f:	e8 30 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80136c:	eb 23                	jmp    801391 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80136e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801371:	8b 52 18             	mov    0x18(%edx),%edx
  801374:	85 d2                	test   %edx,%edx
  801376:	74 14                	je     80138c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	ff 75 0c             	pushl  0xc(%ebp)
  80137e:	50                   	push   %eax
  80137f:	ff d2                	call   *%edx
  801381:	89 c2                	mov    %eax,%edx
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	eb 09                	jmp    801391 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801388:	89 c2                	mov    %eax,%edx
  80138a:	eb 05                	jmp    801391 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80138c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801391:	89 d0                	mov    %edx,%eax
  801393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	53                   	push   %ebx
  80139c:	83 ec 14             	sub    $0x14,%esp
  80139f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	ff 75 08             	pushl  0x8(%ebp)
  8013a9:	e8 6c fb ff ff       	call   800f1a <fd_lookup>
  8013ae:	83 c4 08             	add    $0x8,%esp
  8013b1:	89 c2                	mov    %eax,%edx
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 58                	js     80140f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c1:	ff 30                	pushl  (%eax)
  8013c3:	e8 a8 fb ff ff       	call   800f70 <dev_lookup>
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 37                	js     801406 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013d6:	74 32                	je     80140a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013d8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013db:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e2:	00 00 00 
	stat->st_isdir = 0;
  8013e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ec:	00 00 00 
	stat->st_dev = dev;
  8013ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	53                   	push   %ebx
  8013f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8013fc:	ff 50 14             	call   *0x14(%eax)
  8013ff:	89 c2                	mov    %eax,%edx
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	eb 09                	jmp    80140f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801406:	89 c2                	mov    %eax,%edx
  801408:	eb 05                	jmp    80140f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80140a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80140f:	89 d0                	mov    %edx,%eax
  801411:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	6a 00                	push   $0x0
  801420:	ff 75 08             	pushl  0x8(%ebp)
  801423:	e8 d6 01 00 00       	call   8015fe <open>
  801428:	89 c3                	mov    %eax,%ebx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 1b                	js     80144c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	ff 75 0c             	pushl  0xc(%ebp)
  801437:	50                   	push   %eax
  801438:	e8 5b ff ff ff       	call   801398 <fstat>
  80143d:	89 c6                	mov    %eax,%esi
	close(fd);
  80143f:	89 1c 24             	mov    %ebx,(%esp)
  801442:	e8 fd fb ff ff       	call   801044 <close>
	return r;
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	89 f0                	mov    %esi,%eax
}
  80144c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144f:	5b                   	pop    %ebx
  801450:	5e                   	pop    %esi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    

00801453 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	56                   	push   %esi
  801457:	53                   	push   %ebx
  801458:	89 c6                	mov    %eax,%esi
  80145a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80145c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801463:	75 12                	jne    801477 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	6a 01                	push   $0x1
  80146a:	e8 fc f9 ff ff       	call   800e6b <ipc_find_env>
  80146f:	a3 00 40 80 00       	mov    %eax,0x804000
  801474:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801477:	6a 07                	push   $0x7
  801479:	68 00 50 80 00       	push   $0x805000
  80147e:	56                   	push   %esi
  80147f:	ff 35 00 40 80 00    	pushl  0x804000
  801485:	e8 8d f9 ff ff       	call   800e17 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80148a:	83 c4 0c             	add    $0xc,%esp
  80148d:	6a 00                	push   $0x0
  80148f:	53                   	push   %ebx
  801490:	6a 00                	push   $0x0
  801492:	e8 19 f9 ff ff       	call   800db0 <ipc_recv>
}
  801497:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c1:	e8 8d ff ff ff       	call   801453 <fsipc>
}
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014de:	b8 06 00 00 00       	mov    $0x6,%eax
  8014e3:	e8 6b ff ff ff       	call   801453 <fsipc>
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 04             	sub    $0x4,%esp
  8014f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801504:	b8 05 00 00 00       	mov    $0x5,%eax
  801509:	e8 45 ff ff ff       	call   801453 <fsipc>
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 2c                	js     80153e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801512:	83 ec 08             	sub    $0x8,%esp
  801515:	68 00 50 80 00       	push   $0x805000
  80151a:	53                   	push   %ebx
  80151b:	e8 f9 f1 ff ff       	call   800719 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801520:	a1 80 50 80 00       	mov    0x805080,%eax
  801525:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80152b:	a1 84 50 80 00       	mov    0x805084,%eax
  801530:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80154c:	8b 55 08             	mov    0x8(%ebp),%edx
  80154f:	8b 52 0c             	mov    0xc(%edx),%edx
  801552:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801558:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80155d:	50                   	push   %eax
  80155e:	ff 75 0c             	pushl  0xc(%ebp)
  801561:	68 08 50 80 00       	push   $0x805008
  801566:	e8 40 f3 ff ff       	call   8008ab <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80156b:	ba 00 00 00 00       	mov    $0x0,%edx
  801570:	b8 04 00 00 00       	mov    $0x4,%eax
  801575:	e8 d9 fe ff ff       	call   801453 <fsipc>

}
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
  801581:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801584:	8b 45 08             	mov    0x8(%ebp),%eax
  801587:	8b 40 0c             	mov    0xc(%eax),%eax
  80158a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80158f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801595:	ba 00 00 00 00       	mov    $0x0,%edx
  80159a:	b8 03 00 00 00       	mov    $0x3,%eax
  80159f:	e8 af fe ff ff       	call   801453 <fsipc>
  8015a4:	89 c3                	mov    %eax,%ebx
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 4b                	js     8015f5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015aa:	39 c6                	cmp    %eax,%esi
  8015ac:	73 16                	jae    8015c4 <devfile_read+0x48>
  8015ae:	68 14 27 80 00       	push   $0x802714
  8015b3:	68 1b 27 80 00       	push   $0x80271b
  8015b8:	6a 7c                	push   $0x7c
  8015ba:	68 30 27 80 00       	push   $0x802730
  8015bf:	e8 24 0a 00 00       	call   801fe8 <_panic>
	assert(r <= PGSIZE);
  8015c4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015c9:	7e 16                	jle    8015e1 <devfile_read+0x65>
  8015cb:	68 3b 27 80 00       	push   $0x80273b
  8015d0:	68 1b 27 80 00       	push   $0x80271b
  8015d5:	6a 7d                	push   $0x7d
  8015d7:	68 30 27 80 00       	push   $0x802730
  8015dc:	e8 07 0a 00 00       	call   801fe8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015e1:	83 ec 04             	sub    $0x4,%esp
  8015e4:	50                   	push   %eax
  8015e5:	68 00 50 80 00       	push   $0x805000
  8015ea:	ff 75 0c             	pushl  0xc(%ebp)
  8015ed:	e8 b9 f2 ff ff       	call   8008ab <memmove>
	return r;
  8015f2:	83 c4 10             	add    $0x10,%esp
}
  8015f5:	89 d8                	mov    %ebx,%eax
  8015f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fa:	5b                   	pop    %ebx
  8015fb:	5e                   	pop    %esi
  8015fc:	5d                   	pop    %ebp
  8015fd:	c3                   	ret    

008015fe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	53                   	push   %ebx
  801602:	83 ec 20             	sub    $0x20,%esp
  801605:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801608:	53                   	push   %ebx
  801609:	e8 d2 f0 ff ff       	call   8006e0 <strlen>
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801616:	7f 67                	jg     80167f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801618:	83 ec 0c             	sub    $0xc,%esp
  80161b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161e:	50                   	push   %eax
  80161f:	e8 a7 f8 ff ff       	call   800ecb <fd_alloc>
  801624:	83 c4 10             	add    $0x10,%esp
		return r;
  801627:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 57                	js     801684 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80162d:	83 ec 08             	sub    $0x8,%esp
  801630:	53                   	push   %ebx
  801631:	68 00 50 80 00       	push   $0x805000
  801636:	e8 de f0 ff ff       	call   800719 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80163b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801643:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801646:	b8 01 00 00 00       	mov    $0x1,%eax
  80164b:	e8 03 fe ff ff       	call   801453 <fsipc>
  801650:	89 c3                	mov    %eax,%ebx
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	79 14                	jns    80166d <open+0x6f>
		fd_close(fd, 0);
  801659:	83 ec 08             	sub    $0x8,%esp
  80165c:	6a 00                	push   $0x0
  80165e:	ff 75 f4             	pushl  -0xc(%ebp)
  801661:	e8 5d f9 ff ff       	call   800fc3 <fd_close>
		return r;
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	89 da                	mov    %ebx,%edx
  80166b:	eb 17                	jmp    801684 <open+0x86>
	}

	return fd2num(fd);
  80166d:	83 ec 0c             	sub    $0xc,%esp
  801670:	ff 75 f4             	pushl  -0xc(%ebp)
  801673:	e8 2c f8 ff ff       	call   800ea4 <fd2num>
  801678:	89 c2                	mov    %eax,%edx
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	eb 05                	jmp    801684 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80167f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801684:	89 d0                	mov    %edx,%eax
  801686:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801691:	ba 00 00 00 00       	mov    $0x0,%edx
  801696:	b8 08 00 00 00       	mov    $0x8,%eax
  80169b:	e8 b3 fd ff ff       	call   801453 <fsipc>
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016a8:	68 47 27 80 00       	push   $0x802747
  8016ad:	ff 75 0c             	pushl  0xc(%ebp)
  8016b0:	e8 64 f0 ff ff       	call   800719 <strcpy>
	return 0;
}
  8016b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 10             	sub    $0x10,%esp
  8016c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016c6:	53                   	push   %ebx
  8016c7:	e8 62 09 00 00       	call   80202e <pageref>
  8016cc:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8016cf:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8016d4:	83 f8 01             	cmp    $0x1,%eax
  8016d7:	75 10                	jne    8016e9 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8016d9:	83 ec 0c             	sub    $0xc,%esp
  8016dc:	ff 73 0c             	pushl  0xc(%ebx)
  8016df:	e8 c0 02 00 00       	call   8019a4 <nsipc_close>
  8016e4:	89 c2                	mov    %eax,%edx
  8016e6:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016e9:	89 d0                	mov    %edx,%eax
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016f6:	6a 00                	push   $0x0
  8016f8:	ff 75 10             	pushl  0x10(%ebp)
  8016fb:	ff 75 0c             	pushl  0xc(%ebp)
  8016fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801701:	ff 70 0c             	pushl  0xc(%eax)
  801704:	e8 78 03 00 00       	call   801a81 <nsipc_send>
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801711:	6a 00                	push   $0x0
  801713:	ff 75 10             	pushl  0x10(%ebp)
  801716:	ff 75 0c             	pushl  0xc(%ebp)
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	ff 70 0c             	pushl  0xc(%eax)
  80171f:	e8 f1 02 00 00       	call   801a15 <nsipc_recv>
}
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80172c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80172f:	52                   	push   %edx
  801730:	50                   	push   %eax
  801731:	e8 e4 f7 ff ff       	call   800f1a <fd_lookup>
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 17                	js     801754 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80173d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801740:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801746:	39 08                	cmp    %ecx,(%eax)
  801748:	75 05                	jne    80174f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80174a:	8b 40 0c             	mov    0xc(%eax),%eax
  80174d:	eb 05                	jmp    801754 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80174f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	83 ec 1c             	sub    $0x1c,%esp
  80175e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801760:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	e8 62 f7 ff ff       	call   800ecb <fd_alloc>
  801769:	89 c3                	mov    %eax,%ebx
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 1b                	js     80178d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801772:	83 ec 04             	sub    $0x4,%esp
  801775:	68 07 04 00 00       	push   $0x407
  80177a:	ff 75 f4             	pushl  -0xc(%ebp)
  80177d:	6a 00                	push   $0x0
  80177f:	e8 98 f3 ff ff       	call   800b1c <sys_page_alloc>
  801784:	89 c3                	mov    %eax,%ebx
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	85 c0                	test   %eax,%eax
  80178b:	79 10                	jns    80179d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80178d:	83 ec 0c             	sub    $0xc,%esp
  801790:	56                   	push   %esi
  801791:	e8 0e 02 00 00       	call   8019a4 <nsipc_close>
		return r;
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	89 d8                	mov    %ebx,%eax
  80179b:	eb 24                	jmp    8017c1 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80179d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017b2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017b5:	83 ec 0c             	sub    $0xc,%esp
  8017b8:	50                   	push   %eax
  8017b9:	e8 e6 f6 ff ff       	call   800ea4 <fd2num>
  8017be:	83 c4 10             	add    $0x10,%esp
}
  8017c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5e                   	pop    %esi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	e8 50 ff ff ff       	call   801726 <fd2sockid>
		return r;
  8017d6:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	78 1f                	js     8017fb <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	ff 75 10             	pushl  0x10(%ebp)
  8017e2:	ff 75 0c             	pushl  0xc(%ebp)
  8017e5:	50                   	push   %eax
  8017e6:	e8 12 01 00 00       	call   8018fd <nsipc_accept>
  8017eb:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ee:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	78 07                	js     8017fb <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017f4:	e8 5d ff ff ff       	call   801756 <alloc_sockfd>
  8017f9:	89 c1                	mov    %eax,%ecx
}
  8017fb:	89 c8                	mov    %ecx,%eax
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	e8 19 ff ff ff       	call   801726 <fd2sockid>
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 12                	js     801823 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801811:	83 ec 04             	sub    $0x4,%esp
  801814:	ff 75 10             	pushl  0x10(%ebp)
  801817:	ff 75 0c             	pushl  0xc(%ebp)
  80181a:	50                   	push   %eax
  80181b:	e8 2d 01 00 00       	call   80194d <nsipc_bind>
  801820:	83 c4 10             	add    $0x10,%esp
}
  801823:	c9                   	leave  
  801824:	c3                   	ret    

00801825 <shutdown>:

int
shutdown(int s, int how)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80182b:	8b 45 08             	mov    0x8(%ebp),%eax
  80182e:	e8 f3 fe ff ff       	call   801726 <fd2sockid>
  801833:	85 c0                	test   %eax,%eax
  801835:	78 0f                	js     801846 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	ff 75 0c             	pushl  0xc(%ebp)
  80183d:	50                   	push   %eax
  80183e:	e8 3f 01 00 00       	call   801982 <nsipc_shutdown>
  801843:	83 c4 10             	add    $0x10,%esp
}
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	e8 d0 fe ff ff       	call   801726 <fd2sockid>
  801856:	85 c0                	test   %eax,%eax
  801858:	78 12                	js     80186c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80185a:	83 ec 04             	sub    $0x4,%esp
  80185d:	ff 75 10             	pushl  0x10(%ebp)
  801860:	ff 75 0c             	pushl  0xc(%ebp)
  801863:	50                   	push   %eax
  801864:	e8 55 01 00 00       	call   8019be <nsipc_connect>
  801869:	83 c4 10             	add    $0x10,%esp
}
  80186c:	c9                   	leave  
  80186d:	c3                   	ret    

0080186e <listen>:

int
listen(int s, int backlog)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801874:	8b 45 08             	mov    0x8(%ebp),%eax
  801877:	e8 aa fe ff ff       	call   801726 <fd2sockid>
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 0f                	js     80188f <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	ff 75 0c             	pushl  0xc(%ebp)
  801886:	50                   	push   %eax
  801887:	e8 67 01 00 00       	call   8019f3 <nsipc_listen>
  80188c:	83 c4 10             	add    $0x10,%esp
}
  80188f:	c9                   	leave  
  801890:	c3                   	ret    

00801891 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801897:	ff 75 10             	pushl  0x10(%ebp)
  80189a:	ff 75 0c             	pushl  0xc(%ebp)
  80189d:	ff 75 08             	pushl  0x8(%ebp)
  8018a0:	e8 3a 02 00 00       	call   801adf <nsipc_socket>
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 05                	js     8018b1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018ac:	e8 a5 fe ff ff       	call   801756 <alloc_sockfd>
}
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018bc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018c3:	75 12                	jne    8018d7 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018c5:	83 ec 0c             	sub    $0xc,%esp
  8018c8:	6a 02                	push   $0x2
  8018ca:	e8 9c f5 ff ff       	call   800e6b <ipc_find_env>
  8018cf:	a3 04 40 80 00       	mov    %eax,0x804004
  8018d4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018d7:	6a 07                	push   $0x7
  8018d9:	68 00 60 80 00       	push   $0x806000
  8018de:	53                   	push   %ebx
  8018df:	ff 35 04 40 80 00    	pushl  0x804004
  8018e5:	e8 2d f5 ff ff       	call   800e17 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018ea:	83 c4 0c             	add    $0xc,%esp
  8018ed:	6a 00                	push   $0x0
  8018ef:	6a 00                	push   $0x0
  8018f1:	6a 00                	push   $0x0
  8018f3:	e8 b8 f4 ff ff       	call   800db0 <ipc_recv>
}
  8018f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    

008018fd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	56                   	push   %esi
  801901:	53                   	push   %ebx
  801902:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80190d:	8b 06                	mov    (%esi),%eax
  80190f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801914:	b8 01 00 00 00       	mov    $0x1,%eax
  801919:	e8 95 ff ff ff       	call   8018b3 <nsipc>
  80191e:	89 c3                	mov    %eax,%ebx
  801920:	85 c0                	test   %eax,%eax
  801922:	78 20                	js     801944 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801924:	83 ec 04             	sub    $0x4,%esp
  801927:	ff 35 10 60 80 00    	pushl  0x806010
  80192d:	68 00 60 80 00       	push   $0x806000
  801932:	ff 75 0c             	pushl  0xc(%ebp)
  801935:	e8 71 ef ff ff       	call   8008ab <memmove>
		*addrlen = ret->ret_addrlen;
  80193a:	a1 10 60 80 00       	mov    0x806010,%eax
  80193f:	89 06                	mov    %eax,(%esi)
  801941:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801944:	89 d8                	mov    %ebx,%eax
  801946:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801949:	5b                   	pop    %ebx
  80194a:	5e                   	pop    %esi
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    

0080194d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	53                   	push   %ebx
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
  80195a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80195f:	53                   	push   %ebx
  801960:	ff 75 0c             	pushl  0xc(%ebp)
  801963:	68 04 60 80 00       	push   $0x806004
  801968:	e8 3e ef ff ff       	call   8008ab <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80196d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801973:	b8 02 00 00 00       	mov    $0x2,%eax
  801978:	e8 36 ff ff ff       	call   8018b3 <nsipc>
}
  80197d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801988:	8b 45 08             	mov    0x8(%ebp),%eax
  80198b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801990:	8b 45 0c             	mov    0xc(%ebp),%eax
  801993:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801998:	b8 03 00 00 00       	mov    $0x3,%eax
  80199d:	e8 11 ff ff ff       	call   8018b3 <nsipc>
}
  8019a2:	c9                   	leave  
  8019a3:	c3                   	ret    

008019a4 <nsipc_close>:

int
nsipc_close(int s)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b7:	e8 f7 fe ff ff       	call   8018b3 <nsipc>
}
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	53                   	push   %ebx
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019d0:	53                   	push   %ebx
  8019d1:	ff 75 0c             	pushl  0xc(%ebp)
  8019d4:	68 04 60 80 00       	push   $0x806004
  8019d9:	e8 cd ee ff ff       	call   8008ab <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019de:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8019e9:	e8 c5 fe ff ff       	call   8018b3 <nsipc>
}
  8019ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a04:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a09:	b8 06 00 00 00       	mov    $0x6,%eax
  801a0e:	e8 a0 fe ff ff       	call   8018b3 <nsipc>
}
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	56                   	push   %esi
  801a19:	53                   	push   %ebx
  801a1a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a20:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a25:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2e:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a33:	b8 07 00 00 00       	mov    $0x7,%eax
  801a38:	e8 76 fe ff ff       	call   8018b3 <nsipc>
  801a3d:	89 c3                	mov    %eax,%ebx
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 35                	js     801a78 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a43:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a48:	7f 04                	jg     801a4e <nsipc_recv+0x39>
  801a4a:	39 c6                	cmp    %eax,%esi
  801a4c:	7d 16                	jge    801a64 <nsipc_recv+0x4f>
  801a4e:	68 53 27 80 00       	push   $0x802753
  801a53:	68 1b 27 80 00       	push   $0x80271b
  801a58:	6a 62                	push   $0x62
  801a5a:	68 68 27 80 00       	push   $0x802768
  801a5f:	e8 84 05 00 00       	call   801fe8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a64:	83 ec 04             	sub    $0x4,%esp
  801a67:	50                   	push   %eax
  801a68:	68 00 60 80 00       	push   $0x806000
  801a6d:	ff 75 0c             	pushl  0xc(%ebp)
  801a70:	e8 36 ee ff ff       	call   8008ab <memmove>
  801a75:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a78:	89 d8                	mov    %ebx,%eax
  801a7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5e                   	pop    %esi
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    

00801a81 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	53                   	push   %ebx
  801a85:	83 ec 04             	sub    $0x4,%esp
  801a88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a93:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a99:	7e 16                	jle    801ab1 <nsipc_send+0x30>
  801a9b:	68 74 27 80 00       	push   $0x802774
  801aa0:	68 1b 27 80 00       	push   $0x80271b
  801aa5:	6a 6d                	push   $0x6d
  801aa7:	68 68 27 80 00       	push   $0x802768
  801aac:	e8 37 05 00 00       	call   801fe8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ab1:	83 ec 04             	sub    $0x4,%esp
  801ab4:	53                   	push   %ebx
  801ab5:	ff 75 0c             	pushl  0xc(%ebp)
  801ab8:	68 0c 60 80 00       	push   $0x80600c
  801abd:	e8 e9 ed ff ff       	call   8008ab <memmove>
	nsipcbuf.send.req_size = size;
  801ac2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ac8:	8b 45 14             	mov    0x14(%ebp),%eax
  801acb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ad0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ad5:	e8 d9 fd ff ff       	call   8018b3 <nsipc>
}
  801ada:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801af5:	8b 45 10             	mov    0x10(%ebp),%eax
  801af8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801afd:	b8 09 00 00 00       	mov    $0x9,%eax
  801b02:	e8 ac fd ff ff       	call   8018b3 <nsipc>
}
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b11:	83 ec 0c             	sub    $0xc,%esp
  801b14:	ff 75 08             	pushl  0x8(%ebp)
  801b17:	e8 98 f3 ff ff       	call   800eb4 <fd2data>
  801b1c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b1e:	83 c4 08             	add    $0x8,%esp
  801b21:	68 80 27 80 00       	push   $0x802780
  801b26:	53                   	push   %ebx
  801b27:	e8 ed eb ff ff       	call   800719 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b2c:	8b 46 04             	mov    0x4(%esi),%eax
  801b2f:	2b 06                	sub    (%esi),%eax
  801b31:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b37:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b3e:	00 00 00 
	stat->st_dev = &devpipe;
  801b41:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b48:	30 80 00 
	return 0;
}
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	53                   	push   %ebx
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b61:	53                   	push   %ebx
  801b62:	6a 00                	push   $0x0
  801b64:	e8 38 f0 ff ff       	call   800ba1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b69:	89 1c 24             	mov    %ebx,(%esp)
  801b6c:	e8 43 f3 ff ff       	call   800eb4 <fd2data>
  801b71:	83 c4 08             	add    $0x8,%esp
  801b74:	50                   	push   %eax
  801b75:	6a 00                	push   $0x0
  801b77:	e8 25 f0 ff ff       	call   800ba1 <sys_page_unmap>
}
  801b7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	57                   	push   %edi
  801b85:	56                   	push   %esi
  801b86:	53                   	push   %ebx
  801b87:	83 ec 1c             	sub    $0x1c,%esp
  801b8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b8d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b8f:	a1 08 40 80 00       	mov    0x804008,%eax
  801b94:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	ff 75 e0             	pushl  -0x20(%ebp)
  801b9d:	e8 8c 04 00 00       	call   80202e <pageref>
  801ba2:	89 c3                	mov    %eax,%ebx
  801ba4:	89 3c 24             	mov    %edi,(%esp)
  801ba7:	e8 82 04 00 00       	call   80202e <pageref>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	39 c3                	cmp    %eax,%ebx
  801bb1:	0f 94 c1             	sete   %cl
  801bb4:	0f b6 c9             	movzbl %cl,%ecx
  801bb7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bba:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801bc0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bc3:	39 ce                	cmp    %ecx,%esi
  801bc5:	74 1b                	je     801be2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bc7:	39 c3                	cmp    %eax,%ebx
  801bc9:	75 c4                	jne    801b8f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bcb:	8b 42 58             	mov    0x58(%edx),%eax
  801bce:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd1:	50                   	push   %eax
  801bd2:	56                   	push   %esi
  801bd3:	68 87 27 80 00       	push   $0x802787
  801bd8:	e8 b7 e5 ff ff       	call   800194 <cprintf>
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	eb ad                	jmp    801b8f <_pipeisclosed+0xe>
	}
}
  801be2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be8:	5b                   	pop    %ebx
  801be9:	5e                   	pop    %esi
  801bea:	5f                   	pop    %edi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	57                   	push   %edi
  801bf1:	56                   	push   %esi
  801bf2:	53                   	push   %ebx
  801bf3:	83 ec 28             	sub    $0x28,%esp
  801bf6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bf9:	56                   	push   %esi
  801bfa:	e8 b5 f2 ff ff       	call   800eb4 <fd2data>
  801bff:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	bf 00 00 00 00       	mov    $0x0,%edi
  801c09:	eb 4b                	jmp    801c56 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c0b:	89 da                	mov    %ebx,%edx
  801c0d:	89 f0                	mov    %esi,%eax
  801c0f:	e8 6d ff ff ff       	call   801b81 <_pipeisclosed>
  801c14:	85 c0                	test   %eax,%eax
  801c16:	75 48                	jne    801c60 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c18:	e8 e0 ee ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c1d:	8b 43 04             	mov    0x4(%ebx),%eax
  801c20:	8b 0b                	mov    (%ebx),%ecx
  801c22:	8d 51 20             	lea    0x20(%ecx),%edx
  801c25:	39 d0                	cmp    %edx,%eax
  801c27:	73 e2                	jae    801c0b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c30:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c33:	89 c2                	mov    %eax,%edx
  801c35:	c1 fa 1f             	sar    $0x1f,%edx
  801c38:	89 d1                	mov    %edx,%ecx
  801c3a:	c1 e9 1b             	shr    $0x1b,%ecx
  801c3d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c40:	83 e2 1f             	and    $0x1f,%edx
  801c43:	29 ca                	sub    %ecx,%edx
  801c45:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c49:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c4d:	83 c0 01             	add    $0x1,%eax
  801c50:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c53:	83 c7 01             	add    $0x1,%edi
  801c56:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c59:	75 c2                	jne    801c1d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5e:	eb 05                	jmp    801c65 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c60:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c68:	5b                   	pop    %ebx
  801c69:	5e                   	pop    %esi
  801c6a:	5f                   	pop    %edi
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    

00801c6d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	57                   	push   %edi
  801c71:	56                   	push   %esi
  801c72:	53                   	push   %ebx
  801c73:	83 ec 18             	sub    $0x18,%esp
  801c76:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c79:	57                   	push   %edi
  801c7a:	e8 35 f2 ff ff       	call   800eb4 <fd2data>
  801c7f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c89:	eb 3d                	jmp    801cc8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c8b:	85 db                	test   %ebx,%ebx
  801c8d:	74 04                	je     801c93 <devpipe_read+0x26>
				return i;
  801c8f:	89 d8                	mov    %ebx,%eax
  801c91:	eb 44                	jmp    801cd7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c93:	89 f2                	mov    %esi,%edx
  801c95:	89 f8                	mov    %edi,%eax
  801c97:	e8 e5 fe ff ff       	call   801b81 <_pipeisclosed>
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	75 32                	jne    801cd2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ca0:	e8 58 ee ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ca5:	8b 06                	mov    (%esi),%eax
  801ca7:	3b 46 04             	cmp    0x4(%esi),%eax
  801caa:	74 df                	je     801c8b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cac:	99                   	cltd   
  801cad:	c1 ea 1b             	shr    $0x1b,%edx
  801cb0:	01 d0                	add    %edx,%eax
  801cb2:	83 e0 1f             	and    $0x1f,%eax
  801cb5:	29 d0                	sub    %edx,%eax
  801cb7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cbf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cc2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc5:	83 c3 01             	add    $0x1,%ebx
  801cc8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ccb:	75 d8                	jne    801ca5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ccd:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd0:	eb 05                	jmp    801cd7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cd2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cda:	5b                   	pop    %ebx
  801cdb:	5e                   	pop    %esi
  801cdc:	5f                   	pop    %edi
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cea:	50                   	push   %eax
  801ceb:	e8 db f1 ff ff       	call   800ecb <fd_alloc>
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	89 c2                	mov    %eax,%edx
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	0f 88 2c 01 00 00    	js     801e29 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfd:	83 ec 04             	sub    $0x4,%esp
  801d00:	68 07 04 00 00       	push   $0x407
  801d05:	ff 75 f4             	pushl  -0xc(%ebp)
  801d08:	6a 00                	push   $0x0
  801d0a:	e8 0d ee ff ff       	call   800b1c <sys_page_alloc>
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	89 c2                	mov    %eax,%edx
  801d14:	85 c0                	test   %eax,%eax
  801d16:	0f 88 0d 01 00 00    	js     801e29 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d1c:	83 ec 0c             	sub    $0xc,%esp
  801d1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d22:	50                   	push   %eax
  801d23:	e8 a3 f1 ff ff       	call   800ecb <fd_alloc>
  801d28:	89 c3                	mov    %eax,%ebx
  801d2a:	83 c4 10             	add    $0x10,%esp
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	0f 88 e2 00 00 00    	js     801e17 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d35:	83 ec 04             	sub    $0x4,%esp
  801d38:	68 07 04 00 00       	push   $0x407
  801d3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d40:	6a 00                	push   $0x0
  801d42:	e8 d5 ed ff ff       	call   800b1c <sys_page_alloc>
  801d47:	89 c3                	mov    %eax,%ebx
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	0f 88 c3 00 00 00    	js     801e17 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5a:	e8 55 f1 ff ff       	call   800eb4 <fd2data>
  801d5f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d61:	83 c4 0c             	add    $0xc,%esp
  801d64:	68 07 04 00 00       	push   $0x407
  801d69:	50                   	push   %eax
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 ab ed ff ff       	call   800b1c <sys_page_alloc>
  801d71:	89 c3                	mov    %eax,%ebx
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	85 c0                	test   %eax,%eax
  801d78:	0f 88 89 00 00 00    	js     801e07 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	ff 75 f0             	pushl  -0x10(%ebp)
  801d84:	e8 2b f1 ff ff       	call   800eb4 <fd2data>
  801d89:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d90:	50                   	push   %eax
  801d91:	6a 00                	push   $0x0
  801d93:	56                   	push   %esi
  801d94:	6a 00                	push   $0x0
  801d96:	e8 c4 ed ff ff       	call   800b5f <sys_page_map>
  801d9b:	89 c3                	mov    %eax,%ebx
  801d9d:	83 c4 20             	add    $0x20,%esp
  801da0:	85 c0                	test   %eax,%eax
  801da2:	78 55                	js     801df9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801da4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801db9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dce:	83 ec 0c             	sub    $0xc,%esp
  801dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd4:	e8 cb f0 ff ff       	call   800ea4 <fd2num>
  801dd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dde:	83 c4 04             	add    $0x4,%esp
  801de1:	ff 75 f0             	pushl  -0x10(%ebp)
  801de4:	e8 bb f0 ff ff       	call   800ea4 <fd2num>
  801de9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	ba 00 00 00 00       	mov    $0x0,%edx
  801df7:	eb 30                	jmp    801e29 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801df9:	83 ec 08             	sub    $0x8,%esp
  801dfc:	56                   	push   %esi
  801dfd:	6a 00                	push   $0x0
  801dff:	e8 9d ed ff ff       	call   800ba1 <sys_page_unmap>
  801e04:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 8d ed ff ff       	call   800ba1 <sys_page_unmap>
  801e14:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e17:	83 ec 08             	sub    $0x8,%esp
  801e1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1d:	6a 00                	push   $0x0
  801e1f:	e8 7d ed ff ff       	call   800ba1 <sys_page_unmap>
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e29:	89 d0                	mov    %edx,%eax
  801e2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5e                   	pop    %esi
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    

00801e32 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3b:	50                   	push   %eax
  801e3c:	ff 75 08             	pushl  0x8(%ebp)
  801e3f:	e8 d6 f0 ff ff       	call   800f1a <fd_lookup>
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 18                	js     801e63 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e4b:	83 ec 0c             	sub    $0xc,%esp
  801e4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e51:	e8 5e f0 ff ff       	call   800eb4 <fd2data>
	return _pipeisclosed(fd, p);
  801e56:	89 c2                	mov    %eax,%edx
  801e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5b:	e8 21 fd ff ff       	call   801b81 <_pipeisclosed>
  801e60:	83 c4 10             	add    $0x10,%esp
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e68:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    

00801e6f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e75:	68 9f 27 80 00       	push   $0x80279f
  801e7a:	ff 75 0c             	pushl  0xc(%ebp)
  801e7d:	e8 97 e8 ff ff       	call   800719 <strcpy>
	return 0;
}
  801e82:	b8 00 00 00 00       	mov    $0x0,%eax
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    

00801e89 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	57                   	push   %edi
  801e8d:	56                   	push   %esi
  801e8e:	53                   	push   %ebx
  801e8f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e95:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e9a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea0:	eb 2d                	jmp    801ecf <devcons_write+0x46>
		m = n - tot;
  801ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ea7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eaa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eaf:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb2:	83 ec 04             	sub    $0x4,%esp
  801eb5:	53                   	push   %ebx
  801eb6:	03 45 0c             	add    0xc(%ebp),%eax
  801eb9:	50                   	push   %eax
  801eba:	57                   	push   %edi
  801ebb:	e8 eb e9 ff ff       	call   8008ab <memmove>
		sys_cputs(buf, m);
  801ec0:	83 c4 08             	add    $0x8,%esp
  801ec3:	53                   	push   %ebx
  801ec4:	57                   	push   %edi
  801ec5:	e8 96 eb ff ff       	call   800a60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eca:	01 de                	add    %ebx,%esi
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	89 f0                	mov    %esi,%eax
  801ed1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ed4:	72 cc                	jb     801ea2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed9:	5b                   	pop    %ebx
  801eda:	5e                   	pop    %esi
  801edb:	5f                   	pop    %edi
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 08             	sub    $0x8,%esp
  801ee4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ee9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eed:	74 2a                	je     801f19 <devcons_read+0x3b>
  801eef:	eb 05                	jmp    801ef6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ef1:	e8 07 ec ff ff       	call   800afd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ef6:	e8 83 eb ff ff       	call   800a7e <sys_cgetc>
  801efb:	85 c0                	test   %eax,%eax
  801efd:	74 f2                	je     801ef1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 16                	js     801f19 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f03:	83 f8 04             	cmp    $0x4,%eax
  801f06:	74 0c                	je     801f14 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f0b:	88 02                	mov    %al,(%edx)
	return 1;
  801f0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f12:	eb 05                	jmp    801f19 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f21:	8b 45 08             	mov    0x8(%ebp),%eax
  801f24:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f27:	6a 01                	push   $0x1
  801f29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f2c:	50                   	push   %eax
  801f2d:	e8 2e eb ff ff       	call   800a60 <sys_cputs>
}
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	c9                   	leave  
  801f36:	c3                   	ret    

00801f37 <getchar>:

int
getchar(void)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f3d:	6a 01                	push   $0x1
  801f3f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f42:	50                   	push   %eax
  801f43:	6a 00                	push   $0x0
  801f45:	e8 36 f2 ff ff       	call   801180 <read>
	if (r < 0)
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	78 0f                	js     801f60 <getchar+0x29>
		return r;
	if (r < 1)
  801f51:	85 c0                	test   %eax,%eax
  801f53:	7e 06                	jle    801f5b <getchar+0x24>
		return -E_EOF;
	return c;
  801f55:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f59:	eb 05                	jmp    801f60 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f5b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f60:	c9                   	leave  
  801f61:	c3                   	ret    

00801f62 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6b:	50                   	push   %eax
  801f6c:	ff 75 08             	pushl  0x8(%ebp)
  801f6f:	e8 a6 ef ff ff       	call   800f1a <fd_lookup>
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	85 c0                	test   %eax,%eax
  801f79:	78 11                	js     801f8c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f84:	39 10                	cmp    %edx,(%eax)
  801f86:	0f 94 c0             	sete   %al
  801f89:	0f b6 c0             	movzbl %al,%eax
}
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    

00801f8e <opencons>:

int
opencons(void)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f97:	50                   	push   %eax
  801f98:	e8 2e ef ff ff       	call   800ecb <fd_alloc>
  801f9d:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	78 3e                	js     801fe4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa6:	83 ec 04             	sub    $0x4,%esp
  801fa9:	68 07 04 00 00       	push   $0x407
  801fae:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb1:	6a 00                	push   $0x0
  801fb3:	e8 64 eb ff ff       	call   800b1c <sys_page_alloc>
  801fb8:	83 c4 10             	add    $0x10,%esp
		return r;
  801fbb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	78 23                	js     801fe4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fc1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fd6:	83 ec 0c             	sub    $0xc,%esp
  801fd9:	50                   	push   %eax
  801fda:	e8 c5 ee ff ff       	call   800ea4 <fd2num>
  801fdf:	89 c2                	mov    %eax,%edx
  801fe1:	83 c4 10             	add    $0x10,%esp
}
  801fe4:	89 d0                	mov    %edx,%eax
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    

00801fe8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	56                   	push   %esi
  801fec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ff0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ff6:	e8 e3 ea ff ff       	call   800ade <sys_getenvid>
  801ffb:	83 ec 0c             	sub    $0xc,%esp
  801ffe:	ff 75 0c             	pushl  0xc(%ebp)
  802001:	ff 75 08             	pushl  0x8(%ebp)
  802004:	56                   	push   %esi
  802005:	50                   	push   %eax
  802006:	68 ac 27 80 00       	push   $0x8027ac
  80200b:	e8 84 e1 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802010:	83 c4 18             	add    $0x18,%esp
  802013:	53                   	push   %ebx
  802014:	ff 75 10             	pushl  0x10(%ebp)
  802017:	e8 27 e1 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  80201c:	c7 04 24 98 27 80 00 	movl   $0x802798,(%esp)
  802023:	e8 6c e1 ff ff       	call   800194 <cprintf>
  802028:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80202b:	cc                   	int3   
  80202c:	eb fd                	jmp    80202b <_panic+0x43>

0080202e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802034:	89 d0                	mov    %edx,%eax
  802036:	c1 e8 16             	shr    $0x16,%eax
  802039:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802040:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802045:	f6 c1 01             	test   $0x1,%cl
  802048:	74 1d                	je     802067 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80204a:	c1 ea 0c             	shr    $0xc,%edx
  80204d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802054:	f6 c2 01             	test   $0x1,%dl
  802057:	74 0e                	je     802067 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802059:	c1 ea 0c             	shr    $0xc,%edx
  80205c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802063:	ef 
  802064:	0f b7 c0             	movzwl %ax,%eax
}
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    
  802069:	66 90                	xchg   %ax,%ax
  80206b:	66 90                	xchg   %ax,%ax
  80206d:	66 90                	xchg   %ax,%ax
  80206f:	90                   	nop

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
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
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
