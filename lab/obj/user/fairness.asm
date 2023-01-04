
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
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 af 0c 00 00       	call   800d0d <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 00 1e 80 00       	push   $0x801e00
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
  80007e:	68 11 1e 80 00       	push   $0x801e11
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 d8 0c 00 00       	call   800d74 <ipc_send>
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
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8000ed:	e8 da 0e 00 00       	call   800fcc <close_all>
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
  8001f7:	e8 64 19 00 00       	call   801b60 <__udivdi3>
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
  80023a:	e8 51 1a 00 00       	call   801c90 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 32 1e 80 00 	movsbl 0x801e32(%eax),%eax
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
  80033e:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
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
  800402:	8b 14 85 e0 20 80 00 	mov    0x8020e0(,%eax,4),%edx
  800409:	85 d2                	test   %edx,%edx
  80040b:	75 18                	jne    800425 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040d:	50                   	push   %eax
  80040e:	68 4a 1e 80 00       	push   $0x801e4a
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
  800426:	68 29 22 80 00       	push   $0x802229
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
  80044a:	b8 43 1e 80 00       	mov    $0x801e43,%eax
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
  800ac5:	68 3f 21 80 00       	push   $0x80213f
  800aca:	6a 23                	push   $0x23
  800acc:	68 5c 21 80 00       	push   $0x80215c
  800ad1:	e8 08 10 00 00       	call   801ade <_panic>

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
  800b46:	68 3f 21 80 00       	push   $0x80213f
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 5c 21 80 00       	push   $0x80215c
  800b52:	e8 87 0f 00 00       	call   801ade <_panic>

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
  800b88:	68 3f 21 80 00       	push   $0x80213f
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 5c 21 80 00       	push   $0x80215c
  800b94:	e8 45 0f 00 00       	call   801ade <_panic>

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
  800bca:	68 3f 21 80 00       	push   $0x80213f
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 5c 21 80 00       	push   $0x80215c
  800bd6:	e8 03 0f 00 00       	call   801ade <_panic>

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
  800c0c:	68 3f 21 80 00       	push   $0x80213f
  800c11:	6a 23                	push   $0x23
  800c13:	68 5c 21 80 00       	push   $0x80215c
  800c18:	e8 c1 0e 00 00       	call   801ade <_panic>

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
  800c4e:	68 3f 21 80 00       	push   $0x80213f
  800c53:	6a 23                	push   $0x23
  800c55:	68 5c 21 80 00       	push   $0x80215c
  800c5a:	e8 7f 0e 00 00       	call   801ade <_panic>

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
  800c90:	68 3f 21 80 00       	push   $0x80213f
  800c95:	6a 23                	push   $0x23
  800c97:	68 5c 21 80 00       	push   $0x80215c
  800c9c:	e8 3d 0e 00 00       	call   801ade <_panic>

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
  800cf4:	68 3f 21 80 00       	push   $0x80213f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 5c 21 80 00       	push   $0x80215c
  800d00:	e8 d9 0d 00 00       	call   801ade <_panic>

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

00800d0d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	8b 75 08             	mov    0x8(%ebp),%esi
  800d15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  800d1b:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  800d1d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800d22:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	e8 9e ff ff ff       	call   800ccc <sys_ipc_recv>

	if (from_env_store != NULL)
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	85 f6                	test   %esi,%esi
  800d33:	74 14                	je     800d49 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  800d35:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	78 09                	js     800d47 <ipc_recv+0x3a>
  800d3e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d44:	8b 52 74             	mov    0x74(%edx),%edx
  800d47:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  800d49:	85 db                	test   %ebx,%ebx
  800d4b:	74 14                	je     800d61 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	85 c0                	test   %eax,%eax
  800d54:	78 09                	js     800d5f <ipc_recv+0x52>
  800d56:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d5c:	8b 52 78             	mov    0x78(%edx),%edx
  800d5f:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	78 08                	js     800d6d <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  800d65:	a1 04 40 80 00       	mov    0x804004,%eax
  800d6a:	8b 40 70             	mov    0x70(%eax),%eax
}
  800d6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 0c             	sub    $0xc,%esp
  800d7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  800d86:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  800d88:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800d8d:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  800d90:	ff 75 14             	pushl  0x14(%ebp)
  800d93:	53                   	push   %ebx
  800d94:	56                   	push   %esi
  800d95:	57                   	push   %edi
  800d96:	e8 0e ff ff ff       	call   800ca9 <sys_ipc_try_send>

		if (err < 0) {
  800d9b:	83 c4 10             	add    $0x10,%esp
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	79 1e                	jns    800dc0 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  800da2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800da5:	75 07                	jne    800dae <ipc_send+0x3a>
				sys_yield();
  800da7:	e8 51 fd ff ff       	call   800afd <sys_yield>
  800dac:	eb e2                	jmp    800d90 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  800dae:	50                   	push   %eax
  800daf:	68 6a 21 80 00       	push   $0x80216a
  800db4:	6a 49                	push   $0x49
  800db6:	68 77 21 80 00       	push   $0x802177
  800dbb:	e8 1e 0d 00 00       	call   801ade <_panic>
		}

	} while (err < 0);

}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800dd3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800dd6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ddc:	8b 52 50             	mov    0x50(%edx),%edx
  800ddf:	39 ca                	cmp    %ecx,%edx
  800de1:	75 0d                	jne    800df0 <ipc_find_env+0x28>
			return envs[i].env_id;
  800de3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800de6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800deb:	8b 40 48             	mov    0x48(%eax),%eax
  800dee:	eb 0f                	jmp    800dff <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800df0:	83 c0 01             	add    $0x1,%eax
  800df3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800df8:	75 d9                	jne    800dd3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e21:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e33:	89 c2                	mov    %eax,%edx
  800e35:	c1 ea 16             	shr    $0x16,%edx
  800e38:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e3f:	f6 c2 01             	test   $0x1,%dl
  800e42:	74 11                	je     800e55 <fd_alloc+0x2d>
  800e44:	89 c2                	mov    %eax,%edx
  800e46:	c1 ea 0c             	shr    $0xc,%edx
  800e49:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e50:	f6 c2 01             	test   $0x1,%dl
  800e53:	75 09                	jne    800e5e <fd_alloc+0x36>
			*fd_store = fd;
  800e55:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e57:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5c:	eb 17                	jmp    800e75 <fd_alloc+0x4d>
  800e5e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e63:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e68:	75 c9                	jne    800e33 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e6a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e70:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e7d:	83 f8 1f             	cmp    $0x1f,%eax
  800e80:	77 36                	ja     800eb8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e82:	c1 e0 0c             	shl    $0xc,%eax
  800e85:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8a:	89 c2                	mov    %eax,%edx
  800e8c:	c1 ea 16             	shr    $0x16,%edx
  800e8f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e96:	f6 c2 01             	test   $0x1,%dl
  800e99:	74 24                	je     800ebf <fd_lookup+0x48>
  800e9b:	89 c2                	mov    %eax,%edx
  800e9d:	c1 ea 0c             	shr    $0xc,%edx
  800ea0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea7:	f6 c2 01             	test   $0x1,%dl
  800eaa:	74 1a                	je     800ec6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eac:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eaf:	89 02                	mov    %eax,(%edx)
	return 0;
  800eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb6:	eb 13                	jmp    800ecb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebd:	eb 0c                	jmp    800ecb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ebf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec4:	eb 05                	jmp    800ecb <fd_lookup+0x54>
  800ec6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 08             	sub    $0x8,%esp
  800ed3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed6:	ba 00 22 80 00       	mov    $0x802200,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800edb:	eb 13                	jmp    800ef0 <dev_lookup+0x23>
  800edd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ee0:	39 08                	cmp    %ecx,(%eax)
  800ee2:	75 0c                	jne    800ef0 <dev_lookup+0x23>
			*dev = devtab[i];
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eee:	eb 2e                	jmp    800f1e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef0:	8b 02                	mov    (%edx),%eax
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	75 e7                	jne    800edd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef6:	a1 04 40 80 00       	mov    0x804004,%eax
  800efb:	8b 40 48             	mov    0x48(%eax),%eax
  800efe:	83 ec 04             	sub    $0x4,%esp
  800f01:	51                   	push   %ecx
  800f02:	50                   	push   %eax
  800f03:	68 84 21 80 00       	push   $0x802184
  800f08:	e8 87 f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	83 ec 10             	sub    $0x10,%esp
  800f28:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f31:	50                   	push   %eax
  800f32:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f38:	c1 e8 0c             	shr    $0xc,%eax
  800f3b:	50                   	push   %eax
  800f3c:	e8 36 ff ff ff       	call   800e77 <fd_lookup>
  800f41:	83 c4 08             	add    $0x8,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	78 05                	js     800f4d <fd_close+0x2d>
	    || fd != fd2)
  800f48:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f4b:	74 0c                	je     800f59 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f4d:	84 db                	test   %bl,%bl
  800f4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f54:	0f 44 c2             	cmove  %edx,%eax
  800f57:	eb 41                	jmp    800f9a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f59:	83 ec 08             	sub    $0x8,%esp
  800f5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	ff 36                	pushl  (%esi)
  800f62:	e8 66 ff ff ff       	call   800ecd <dev_lookup>
  800f67:	89 c3                	mov    %eax,%ebx
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	78 1a                	js     800f8a <fd_close+0x6a>
		if (dev->dev_close)
  800f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f73:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f76:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	74 0b                	je     800f8a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	56                   	push   %esi
  800f83:	ff d0                	call   *%eax
  800f85:	89 c3                	mov    %eax,%ebx
  800f87:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f8a:	83 ec 08             	sub    $0x8,%esp
  800f8d:	56                   	push   %esi
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 0c fc ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	89 d8                	mov    %ebx,%eax
}
  800f9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800faa:	50                   	push   %eax
  800fab:	ff 75 08             	pushl  0x8(%ebp)
  800fae:	e8 c4 fe ff ff       	call   800e77 <fd_lookup>
  800fb3:	83 c4 08             	add    $0x8,%esp
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	78 10                	js     800fca <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fba:	83 ec 08             	sub    $0x8,%esp
  800fbd:	6a 01                	push   $0x1
  800fbf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc2:	e8 59 ff ff ff       	call   800f20 <fd_close>
  800fc7:	83 c4 10             	add    $0x10,%esp
}
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    

00800fcc <close_all>:

void
close_all(void)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fd8:	83 ec 0c             	sub    $0xc,%esp
  800fdb:	53                   	push   %ebx
  800fdc:	e8 c0 ff ff ff       	call   800fa1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe1:	83 c3 01             	add    $0x1,%ebx
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	83 fb 20             	cmp    $0x20,%ebx
  800fea:	75 ec                	jne    800fd8 <close_all+0xc>
		close(i);
}
  800fec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	57                   	push   %edi
  800ff5:	56                   	push   %esi
  800ff6:	53                   	push   %ebx
  800ff7:	83 ec 2c             	sub    $0x2c,%esp
  800ffa:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ffd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801000:	50                   	push   %eax
  801001:	ff 75 08             	pushl  0x8(%ebp)
  801004:	e8 6e fe ff ff       	call   800e77 <fd_lookup>
  801009:	83 c4 08             	add    $0x8,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	0f 88 c1 00 00 00    	js     8010d5 <dup+0xe4>
		return r;
	close(newfdnum);
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	56                   	push   %esi
  801018:	e8 84 ff ff ff       	call   800fa1 <close>

	newfd = INDEX2FD(newfdnum);
  80101d:	89 f3                	mov    %esi,%ebx
  80101f:	c1 e3 0c             	shl    $0xc,%ebx
  801022:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801028:	83 c4 04             	add    $0x4,%esp
  80102b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80102e:	e8 de fd ff ff       	call   800e11 <fd2data>
  801033:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801035:	89 1c 24             	mov    %ebx,(%esp)
  801038:	e8 d4 fd ff ff       	call   800e11 <fd2data>
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801043:	89 f8                	mov    %edi,%eax
  801045:	c1 e8 16             	shr    $0x16,%eax
  801048:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104f:	a8 01                	test   $0x1,%al
  801051:	74 37                	je     80108a <dup+0x99>
  801053:	89 f8                	mov    %edi,%eax
  801055:	c1 e8 0c             	shr    $0xc,%eax
  801058:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105f:	f6 c2 01             	test   $0x1,%dl
  801062:	74 26                	je     80108a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801064:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	25 07 0e 00 00       	and    $0xe07,%eax
  801073:	50                   	push   %eax
  801074:	ff 75 d4             	pushl  -0x2c(%ebp)
  801077:	6a 00                	push   $0x0
  801079:	57                   	push   %edi
  80107a:	6a 00                	push   $0x0
  80107c:	e8 de fa ff ff       	call   800b5f <sys_page_map>
  801081:	89 c7                	mov    %eax,%edi
  801083:	83 c4 20             	add    $0x20,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	78 2e                	js     8010b8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80108d:	89 d0                	mov    %edx,%eax
  80108f:	c1 e8 0c             	shr    $0xc,%eax
  801092:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a1:	50                   	push   %eax
  8010a2:	53                   	push   %ebx
  8010a3:	6a 00                	push   $0x0
  8010a5:	52                   	push   %edx
  8010a6:	6a 00                	push   $0x0
  8010a8:	e8 b2 fa ff ff       	call   800b5f <sys_page_map>
  8010ad:	89 c7                	mov    %eax,%edi
  8010af:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010b2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b4:	85 ff                	test   %edi,%edi
  8010b6:	79 1d                	jns    8010d5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b8:	83 ec 08             	sub    $0x8,%esp
  8010bb:	53                   	push   %ebx
  8010bc:	6a 00                	push   $0x0
  8010be:	e8 de fa ff ff       	call   800ba1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c3:	83 c4 08             	add    $0x8,%esp
  8010c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c9:	6a 00                	push   $0x0
  8010cb:	e8 d1 fa ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	89 f8                	mov    %edi,%eax
}
  8010d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 14             	sub    $0x14,%esp
  8010e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ea:	50                   	push   %eax
  8010eb:	53                   	push   %ebx
  8010ec:	e8 86 fd ff ff       	call   800e77 <fd_lookup>
  8010f1:	83 c4 08             	add    $0x8,%esp
  8010f4:	89 c2                	mov    %eax,%edx
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	78 6d                	js     801167 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fa:	83 ec 08             	sub    $0x8,%esp
  8010fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801100:	50                   	push   %eax
  801101:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801104:	ff 30                	pushl  (%eax)
  801106:	e8 c2 fd ff ff       	call   800ecd <dev_lookup>
  80110b:	83 c4 10             	add    $0x10,%esp
  80110e:	85 c0                	test   %eax,%eax
  801110:	78 4c                	js     80115e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801112:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801115:	8b 42 08             	mov    0x8(%edx),%eax
  801118:	83 e0 03             	and    $0x3,%eax
  80111b:	83 f8 01             	cmp    $0x1,%eax
  80111e:	75 21                	jne    801141 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801120:	a1 04 40 80 00       	mov    0x804004,%eax
  801125:	8b 40 48             	mov    0x48(%eax),%eax
  801128:	83 ec 04             	sub    $0x4,%esp
  80112b:	53                   	push   %ebx
  80112c:	50                   	push   %eax
  80112d:	68 c5 21 80 00       	push   $0x8021c5
  801132:	e8 5d f0 ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80113f:	eb 26                	jmp    801167 <read+0x8a>
	}
	if (!dev->dev_read)
  801141:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801144:	8b 40 08             	mov    0x8(%eax),%eax
  801147:	85 c0                	test   %eax,%eax
  801149:	74 17                	je     801162 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	ff 75 10             	pushl  0x10(%ebp)
  801151:	ff 75 0c             	pushl  0xc(%ebp)
  801154:	52                   	push   %edx
  801155:	ff d0                	call   *%eax
  801157:	89 c2                	mov    %eax,%edx
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	eb 09                	jmp    801167 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115e:	89 c2                	mov    %eax,%edx
  801160:	eb 05                	jmp    801167 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801162:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801167:	89 d0                	mov    %edx,%eax
  801169:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116c:	c9                   	leave  
  80116d:	c3                   	ret    

0080116e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 0c             	sub    $0xc,%esp
  801177:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801182:	eb 21                	jmp    8011a5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	89 f0                	mov    %esi,%eax
  801189:	29 d8                	sub    %ebx,%eax
  80118b:	50                   	push   %eax
  80118c:	89 d8                	mov    %ebx,%eax
  80118e:	03 45 0c             	add    0xc(%ebp),%eax
  801191:	50                   	push   %eax
  801192:	57                   	push   %edi
  801193:	e8 45 ff ff ff       	call   8010dd <read>
		if (m < 0)
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 10                	js     8011af <readn+0x41>
			return m;
		if (m == 0)
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	74 0a                	je     8011ad <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a3:	01 c3                	add    %eax,%ebx
  8011a5:	39 f3                	cmp    %esi,%ebx
  8011a7:	72 db                	jb     801184 <readn+0x16>
  8011a9:	89 d8                	mov    %ebx,%eax
  8011ab:	eb 02                	jmp    8011af <readn+0x41>
  8011ad:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b2:	5b                   	pop    %ebx
  8011b3:	5e                   	pop    %esi
  8011b4:	5f                   	pop    %edi
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 14             	sub    $0x14,%esp
  8011be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c4:	50                   	push   %eax
  8011c5:	53                   	push   %ebx
  8011c6:	e8 ac fc ff ff       	call   800e77 <fd_lookup>
  8011cb:	83 c4 08             	add    $0x8,%esp
  8011ce:	89 c2                	mov    %eax,%edx
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	78 68                	js     80123c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011de:	ff 30                	pushl  (%eax)
  8011e0:	e8 e8 fc ff ff       	call   800ecd <dev_lookup>
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 47                	js     801233 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f3:	75 21                	jne    801216 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fa:	8b 40 48             	mov    0x48(%eax),%eax
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	53                   	push   %ebx
  801201:	50                   	push   %eax
  801202:	68 e1 21 80 00       	push   $0x8021e1
  801207:	e8 88 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801214:	eb 26                	jmp    80123c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801216:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801219:	8b 52 0c             	mov    0xc(%edx),%edx
  80121c:	85 d2                	test   %edx,%edx
  80121e:	74 17                	je     801237 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801220:	83 ec 04             	sub    $0x4,%esp
  801223:	ff 75 10             	pushl  0x10(%ebp)
  801226:	ff 75 0c             	pushl  0xc(%ebp)
  801229:	50                   	push   %eax
  80122a:	ff d2                	call   *%edx
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	eb 09                	jmp    80123c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801233:	89 c2                	mov    %eax,%edx
  801235:	eb 05                	jmp    80123c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801237:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80123c:	89 d0                	mov    %edx,%eax
  80123e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801241:	c9                   	leave  
  801242:	c3                   	ret    

00801243 <seek>:

int
seek(int fdnum, off_t offset)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801249:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	ff 75 08             	pushl  0x8(%ebp)
  801250:	e8 22 fc ff ff       	call   800e77 <fd_lookup>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 0e                	js     80126a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80125c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80125f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801262:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	53                   	push   %ebx
  801270:	83 ec 14             	sub    $0x14,%esp
  801273:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801276:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	53                   	push   %ebx
  80127b:	e8 f7 fb ff ff       	call   800e77 <fd_lookup>
  801280:	83 c4 08             	add    $0x8,%esp
  801283:	89 c2                	mov    %eax,%edx
  801285:	85 c0                	test   %eax,%eax
  801287:	78 65                	js     8012ee <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801293:	ff 30                	pushl  (%eax)
  801295:	e8 33 fc ff ff       	call   800ecd <dev_lookup>
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 44                	js     8012e5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a8:	75 21                	jne    8012cb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012aa:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012af:	8b 40 48             	mov    0x48(%eax),%eax
  8012b2:	83 ec 04             	sub    $0x4,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	50                   	push   %eax
  8012b7:	68 a4 21 80 00       	push   $0x8021a4
  8012bc:	e8 d3 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c9:	eb 23                	jmp    8012ee <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ce:	8b 52 18             	mov    0x18(%edx),%edx
  8012d1:	85 d2                	test   %edx,%edx
  8012d3:	74 14                	je     8012e9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d5:	83 ec 08             	sub    $0x8,%esp
  8012d8:	ff 75 0c             	pushl  0xc(%ebp)
  8012db:	50                   	push   %eax
  8012dc:	ff d2                	call   *%edx
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	eb 09                	jmp    8012ee <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	eb 05                	jmp    8012ee <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012ee:	89 d0                	mov    %edx,%eax
  8012f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f3:	c9                   	leave  
  8012f4:	c3                   	ret    

008012f5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	53                   	push   %ebx
  8012f9:	83 ec 14             	sub    $0x14,%esp
  8012fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801302:	50                   	push   %eax
  801303:	ff 75 08             	pushl  0x8(%ebp)
  801306:	e8 6c fb ff ff       	call   800e77 <fd_lookup>
  80130b:	83 c4 08             	add    $0x8,%esp
  80130e:	89 c2                	mov    %eax,%edx
  801310:	85 c0                	test   %eax,%eax
  801312:	78 58                	js     80136c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131e:	ff 30                	pushl  (%eax)
  801320:	e8 a8 fb ff ff       	call   800ecd <dev_lookup>
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 37                	js     801363 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80132c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801333:	74 32                	je     801367 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801335:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801338:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80133f:	00 00 00 
	stat->st_isdir = 0;
  801342:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801349:	00 00 00 
	stat->st_dev = dev;
  80134c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	53                   	push   %ebx
  801356:	ff 75 f0             	pushl  -0x10(%ebp)
  801359:	ff 50 14             	call   *0x14(%eax)
  80135c:	89 c2                	mov    %eax,%edx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	eb 09                	jmp    80136c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801363:	89 c2                	mov    %eax,%edx
  801365:	eb 05                	jmp    80136c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801367:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136c:	89 d0                	mov    %edx,%eax
  80136e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	6a 00                	push   $0x0
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	e8 d6 01 00 00       	call   80155b <open>
  801385:	89 c3                	mov    %eax,%ebx
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	85 c0                	test   %eax,%eax
  80138c:	78 1b                	js     8013a9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	ff 75 0c             	pushl  0xc(%ebp)
  801394:	50                   	push   %eax
  801395:	e8 5b ff ff ff       	call   8012f5 <fstat>
  80139a:	89 c6                	mov    %eax,%esi
	close(fd);
  80139c:	89 1c 24             	mov    %ebx,(%esp)
  80139f:	e8 fd fb ff ff       	call   800fa1 <close>
	return r;
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	89 f0                	mov    %esi,%eax
}
  8013a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ac:	5b                   	pop    %ebx
  8013ad:	5e                   	pop    %esi
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	56                   	push   %esi
  8013b4:	53                   	push   %ebx
  8013b5:	89 c6                	mov    %eax,%esi
  8013b7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c0:	75 12                	jne    8013d4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c2:	83 ec 0c             	sub    $0xc,%esp
  8013c5:	6a 01                	push   $0x1
  8013c7:	e8 fc f9 ff ff       	call   800dc8 <ipc_find_env>
  8013cc:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d4:	6a 07                	push   $0x7
  8013d6:	68 00 50 80 00       	push   $0x805000
  8013db:	56                   	push   %esi
  8013dc:	ff 35 00 40 80 00    	pushl  0x804000
  8013e2:	e8 8d f9 ff ff       	call   800d74 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e7:	83 c4 0c             	add    $0xc,%esp
  8013ea:	6a 00                	push   $0x0
  8013ec:	53                   	push   %ebx
  8013ed:	6a 00                	push   $0x0
  8013ef:	e8 19 f9 ff ff       	call   800d0d <ipc_recv>
}
  8013f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f7:	5b                   	pop    %ebx
  8013f8:	5e                   	pop    %esi
  8013f9:	5d                   	pop    %ebp
  8013fa:	c3                   	ret    

008013fb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801401:	8b 45 08             	mov    0x8(%ebp),%eax
  801404:	8b 40 0c             	mov    0xc(%eax),%eax
  801407:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80140c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801414:	ba 00 00 00 00       	mov    $0x0,%edx
  801419:	b8 02 00 00 00       	mov    $0x2,%eax
  80141e:	e8 8d ff ff ff       	call   8013b0 <fsipc>
}
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80142b:	8b 45 08             	mov    0x8(%ebp),%eax
  80142e:	8b 40 0c             	mov    0xc(%eax),%eax
  801431:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801436:	ba 00 00 00 00       	mov    $0x0,%edx
  80143b:	b8 06 00 00 00       	mov    $0x6,%eax
  801440:	e8 6b ff ff ff       	call   8013b0 <fsipc>
}
  801445:	c9                   	leave  
  801446:	c3                   	ret    

00801447 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	53                   	push   %ebx
  80144b:	83 ec 04             	sub    $0x4,%esp
  80144e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801451:	8b 45 08             	mov    0x8(%ebp),%eax
  801454:	8b 40 0c             	mov    0xc(%eax),%eax
  801457:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80145c:	ba 00 00 00 00       	mov    $0x0,%edx
  801461:	b8 05 00 00 00       	mov    $0x5,%eax
  801466:	e8 45 ff ff ff       	call   8013b0 <fsipc>
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 2c                	js     80149b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80146f:	83 ec 08             	sub    $0x8,%esp
  801472:	68 00 50 80 00       	push   $0x805000
  801477:	53                   	push   %ebx
  801478:	e8 9c f2 ff ff       	call   800719 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80147d:	a1 80 50 80 00       	mov    0x805080,%eax
  801482:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801488:	a1 84 50 80 00       	mov    0x805084,%eax
  80148d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ac:	8b 52 0c             	mov    0xc(%edx),%edx
  8014af:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014b5:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014ba:	50                   	push   %eax
  8014bb:	ff 75 0c             	pushl  0xc(%ebp)
  8014be:	68 08 50 80 00       	push   $0x805008
  8014c3:	e8 e3 f3 ff ff       	call   8008ab <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cd:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d2:	e8 d9 fe ff ff       	call   8013b0 <fsipc>

}
  8014d7:	c9                   	leave  
  8014d8:	c3                   	ret    

008014d9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	56                   	push   %esi
  8014dd:	53                   	push   %ebx
  8014de:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014ec:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fc:	e8 af fe ff ff       	call   8013b0 <fsipc>
  801501:	89 c3                	mov    %eax,%ebx
  801503:	85 c0                	test   %eax,%eax
  801505:	78 4b                	js     801552 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801507:	39 c6                	cmp    %eax,%esi
  801509:	73 16                	jae    801521 <devfile_read+0x48>
  80150b:	68 10 22 80 00       	push   $0x802210
  801510:	68 17 22 80 00       	push   $0x802217
  801515:	6a 7c                	push   $0x7c
  801517:	68 2c 22 80 00       	push   $0x80222c
  80151c:	e8 bd 05 00 00       	call   801ade <_panic>
	assert(r <= PGSIZE);
  801521:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801526:	7e 16                	jle    80153e <devfile_read+0x65>
  801528:	68 37 22 80 00       	push   $0x802237
  80152d:	68 17 22 80 00       	push   $0x802217
  801532:	6a 7d                	push   $0x7d
  801534:	68 2c 22 80 00       	push   $0x80222c
  801539:	e8 a0 05 00 00       	call   801ade <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80153e:	83 ec 04             	sub    $0x4,%esp
  801541:	50                   	push   %eax
  801542:	68 00 50 80 00       	push   $0x805000
  801547:	ff 75 0c             	pushl  0xc(%ebp)
  80154a:	e8 5c f3 ff ff       	call   8008ab <memmove>
	return r;
  80154f:	83 c4 10             	add    $0x10,%esp
}
  801552:	89 d8                	mov    %ebx,%eax
  801554:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	53                   	push   %ebx
  80155f:	83 ec 20             	sub    $0x20,%esp
  801562:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801565:	53                   	push   %ebx
  801566:	e8 75 f1 ff ff       	call   8006e0 <strlen>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801573:	7f 67                	jg     8015dc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801575:	83 ec 0c             	sub    $0xc,%esp
  801578:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157b:	50                   	push   %eax
  80157c:	e8 a7 f8 ff ff       	call   800e28 <fd_alloc>
  801581:	83 c4 10             	add    $0x10,%esp
		return r;
  801584:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801586:	85 c0                	test   %eax,%eax
  801588:	78 57                	js     8015e1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80158a:	83 ec 08             	sub    $0x8,%esp
  80158d:	53                   	push   %ebx
  80158e:	68 00 50 80 00       	push   $0x805000
  801593:	e8 81 f1 ff ff       	call   800719 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801598:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a8:	e8 03 fe ff ff       	call   8013b0 <fsipc>
  8015ad:	89 c3                	mov    %eax,%ebx
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	79 14                	jns    8015ca <open+0x6f>
		fd_close(fd, 0);
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	6a 00                	push   $0x0
  8015bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015be:	e8 5d f9 ff ff       	call   800f20 <fd_close>
		return r;
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	89 da                	mov    %ebx,%edx
  8015c8:	eb 17                	jmp    8015e1 <open+0x86>
	}

	return fd2num(fd);
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d0:	e8 2c f8 ff ff       	call   800e01 <fd2num>
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	eb 05                	jmp    8015e1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015dc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015e1:	89 d0                	mov    %edx,%eax
  8015e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f3:	b8 08 00 00 00       	mov    $0x8,%eax
  8015f8:	e8 b3 fd ff ff       	call   8013b0 <fsipc>
}
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	56                   	push   %esi
  801603:	53                   	push   %ebx
  801604:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	ff 75 08             	pushl  0x8(%ebp)
  80160d:	e8 ff f7 ff ff       	call   800e11 <fd2data>
  801612:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801614:	83 c4 08             	add    $0x8,%esp
  801617:	68 43 22 80 00       	push   $0x802243
  80161c:	53                   	push   %ebx
  80161d:	e8 f7 f0 ff ff       	call   800719 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801622:	8b 46 04             	mov    0x4(%esi),%eax
  801625:	2b 06                	sub    (%esi),%eax
  801627:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80162d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801634:	00 00 00 
	stat->st_dev = &devpipe;
  801637:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80163e:	30 80 00 
	return 0;
}
  801641:	b8 00 00 00 00       	mov    $0x0,%eax
  801646:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5d                   	pop    %ebp
  80164c:	c3                   	ret    

0080164d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	53                   	push   %ebx
  801651:	83 ec 0c             	sub    $0xc,%esp
  801654:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801657:	53                   	push   %ebx
  801658:	6a 00                	push   $0x0
  80165a:	e8 42 f5 ff ff       	call   800ba1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80165f:	89 1c 24             	mov    %ebx,(%esp)
  801662:	e8 aa f7 ff ff       	call   800e11 <fd2data>
  801667:	83 c4 08             	add    $0x8,%esp
  80166a:	50                   	push   %eax
  80166b:	6a 00                	push   $0x0
  80166d:	e8 2f f5 ff ff       	call   800ba1 <sys_page_unmap>
}
  801672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	57                   	push   %edi
  80167b:	56                   	push   %esi
  80167c:	53                   	push   %ebx
  80167d:	83 ec 1c             	sub    $0x1c,%esp
  801680:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801683:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801685:	a1 04 40 80 00       	mov    0x804004,%eax
  80168a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	ff 75 e0             	pushl  -0x20(%ebp)
  801693:	e8 8c 04 00 00       	call   801b24 <pageref>
  801698:	89 c3                	mov    %eax,%ebx
  80169a:	89 3c 24             	mov    %edi,(%esp)
  80169d:	e8 82 04 00 00       	call   801b24 <pageref>
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	39 c3                	cmp    %eax,%ebx
  8016a7:	0f 94 c1             	sete   %cl
  8016aa:	0f b6 c9             	movzbl %cl,%ecx
  8016ad:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016b0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016b6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016b9:	39 ce                	cmp    %ecx,%esi
  8016bb:	74 1b                	je     8016d8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016bd:	39 c3                	cmp    %eax,%ebx
  8016bf:	75 c4                	jne    801685 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016c1:	8b 42 58             	mov    0x58(%edx),%eax
  8016c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016c7:	50                   	push   %eax
  8016c8:	56                   	push   %esi
  8016c9:	68 4a 22 80 00       	push   $0x80224a
  8016ce:	e8 c1 ea ff ff       	call   800194 <cprintf>
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	eb ad                	jmp    801685 <_pipeisclosed+0xe>
	}
}
  8016d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5f                   	pop    %edi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	57                   	push   %edi
  8016e7:	56                   	push   %esi
  8016e8:	53                   	push   %ebx
  8016e9:	83 ec 28             	sub    $0x28,%esp
  8016ec:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016ef:	56                   	push   %esi
  8016f0:	e8 1c f7 ff ff       	call   800e11 <fd2data>
  8016f5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8016ff:	eb 4b                	jmp    80174c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801701:	89 da                	mov    %ebx,%edx
  801703:	89 f0                	mov    %esi,%eax
  801705:	e8 6d ff ff ff       	call   801677 <_pipeisclosed>
  80170a:	85 c0                	test   %eax,%eax
  80170c:	75 48                	jne    801756 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80170e:	e8 ea f3 ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801713:	8b 43 04             	mov    0x4(%ebx),%eax
  801716:	8b 0b                	mov    (%ebx),%ecx
  801718:	8d 51 20             	lea    0x20(%ecx),%edx
  80171b:	39 d0                	cmp    %edx,%eax
  80171d:	73 e2                	jae    801701 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80171f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801722:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801726:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801729:	89 c2                	mov    %eax,%edx
  80172b:	c1 fa 1f             	sar    $0x1f,%edx
  80172e:	89 d1                	mov    %edx,%ecx
  801730:	c1 e9 1b             	shr    $0x1b,%ecx
  801733:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801736:	83 e2 1f             	and    $0x1f,%edx
  801739:	29 ca                	sub    %ecx,%edx
  80173b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80173f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801743:	83 c0 01             	add    $0x1,%eax
  801746:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801749:	83 c7 01             	add    $0x1,%edi
  80174c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80174f:	75 c2                	jne    801713 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801751:	8b 45 10             	mov    0x10(%ebp),%eax
  801754:	eb 05                	jmp    80175b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801756:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80175b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5f                   	pop    %edi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	57                   	push   %edi
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	83 ec 18             	sub    $0x18,%esp
  80176c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80176f:	57                   	push   %edi
  801770:	e8 9c f6 ff ff       	call   800e11 <fd2data>
  801775:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80177f:	eb 3d                	jmp    8017be <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801781:	85 db                	test   %ebx,%ebx
  801783:	74 04                	je     801789 <devpipe_read+0x26>
				return i;
  801785:	89 d8                	mov    %ebx,%eax
  801787:	eb 44                	jmp    8017cd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801789:	89 f2                	mov    %esi,%edx
  80178b:	89 f8                	mov    %edi,%eax
  80178d:	e8 e5 fe ff ff       	call   801677 <_pipeisclosed>
  801792:	85 c0                	test   %eax,%eax
  801794:	75 32                	jne    8017c8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801796:	e8 62 f3 ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80179b:	8b 06                	mov    (%esi),%eax
  80179d:	3b 46 04             	cmp    0x4(%esi),%eax
  8017a0:	74 df                	je     801781 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017a2:	99                   	cltd   
  8017a3:	c1 ea 1b             	shr    $0x1b,%edx
  8017a6:	01 d0                	add    %edx,%eax
  8017a8:	83 e0 1f             	and    $0x1f,%eax
  8017ab:	29 d0                	sub    %edx,%eax
  8017ad:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017b8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017bb:	83 c3 01             	add    $0x1,%ebx
  8017be:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017c1:	75 d8                	jne    80179b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c6:	eb 05                	jmp    8017cd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5f                   	pop    %edi
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e0:	50                   	push   %eax
  8017e1:	e8 42 f6 ff ff       	call   800e28 <fd_alloc>
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	89 c2                	mov    %eax,%edx
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	0f 88 2c 01 00 00    	js     80191f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f3:	83 ec 04             	sub    $0x4,%esp
  8017f6:	68 07 04 00 00       	push   $0x407
  8017fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fe:	6a 00                	push   $0x0
  801800:	e8 17 f3 ff ff       	call   800b1c <sys_page_alloc>
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	89 c2                	mov    %eax,%edx
  80180a:	85 c0                	test   %eax,%eax
  80180c:	0f 88 0d 01 00 00    	js     80191f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801818:	50                   	push   %eax
  801819:	e8 0a f6 ff ff       	call   800e28 <fd_alloc>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	85 c0                	test   %eax,%eax
  801825:	0f 88 e2 00 00 00    	js     80190d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	68 07 04 00 00       	push   $0x407
  801833:	ff 75 f0             	pushl  -0x10(%ebp)
  801836:	6a 00                	push   $0x0
  801838:	e8 df f2 ff ff       	call   800b1c <sys_page_alloc>
  80183d:	89 c3                	mov    %eax,%ebx
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	0f 88 c3 00 00 00    	js     80190d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80184a:	83 ec 0c             	sub    $0xc,%esp
  80184d:	ff 75 f4             	pushl  -0xc(%ebp)
  801850:	e8 bc f5 ff ff       	call   800e11 <fd2data>
  801855:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801857:	83 c4 0c             	add    $0xc,%esp
  80185a:	68 07 04 00 00       	push   $0x407
  80185f:	50                   	push   %eax
  801860:	6a 00                	push   $0x0
  801862:	e8 b5 f2 ff ff       	call   800b1c <sys_page_alloc>
  801867:	89 c3                	mov    %eax,%ebx
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	0f 88 89 00 00 00    	js     8018fd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801874:	83 ec 0c             	sub    $0xc,%esp
  801877:	ff 75 f0             	pushl  -0x10(%ebp)
  80187a:	e8 92 f5 ff ff       	call   800e11 <fd2data>
  80187f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801886:	50                   	push   %eax
  801887:	6a 00                	push   $0x0
  801889:	56                   	push   %esi
  80188a:	6a 00                	push   $0x0
  80188c:	e8 ce f2 ff ff       	call   800b5f <sys_page_map>
  801891:	89 c3                	mov    %eax,%ebx
  801893:	83 c4 20             	add    $0x20,%esp
  801896:	85 c0                	test   %eax,%eax
  801898:	78 55                	js     8018ef <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80189a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018af:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018c4:	83 ec 0c             	sub    $0xc,%esp
  8018c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ca:	e8 32 f5 ff ff       	call   800e01 <fd2num>
  8018cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018d4:	83 c4 04             	add    $0x4,%esp
  8018d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018da:	e8 22 f5 ff ff       	call   800e01 <fd2num>
  8018df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ed:	eb 30                	jmp    80191f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	56                   	push   %esi
  8018f3:	6a 00                	push   $0x0
  8018f5:	e8 a7 f2 ff ff       	call   800ba1 <sys_page_unmap>
  8018fa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018fd:	83 ec 08             	sub    $0x8,%esp
  801900:	ff 75 f0             	pushl  -0x10(%ebp)
  801903:	6a 00                	push   $0x0
  801905:	e8 97 f2 ff ff       	call   800ba1 <sys_page_unmap>
  80190a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	ff 75 f4             	pushl  -0xc(%ebp)
  801913:	6a 00                	push   $0x0
  801915:	e8 87 f2 ff ff       	call   800ba1 <sys_page_unmap>
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80191f:	89 d0                	mov    %edx,%eax
  801921:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801924:	5b                   	pop    %ebx
  801925:	5e                   	pop    %esi
  801926:	5d                   	pop    %ebp
  801927:	c3                   	ret    

00801928 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80192e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801931:	50                   	push   %eax
  801932:	ff 75 08             	pushl  0x8(%ebp)
  801935:	e8 3d f5 ff ff       	call   800e77 <fd_lookup>
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 18                	js     801959 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801941:	83 ec 0c             	sub    $0xc,%esp
  801944:	ff 75 f4             	pushl  -0xc(%ebp)
  801947:	e8 c5 f4 ff ff       	call   800e11 <fd2data>
	return _pipeisclosed(fd, p);
  80194c:	89 c2                	mov    %eax,%edx
  80194e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801951:	e8 21 fd ff ff       	call   801677 <_pipeisclosed>
  801956:	83 c4 10             	add    $0x10,%esp
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80195e:	b8 00 00 00 00       	mov    $0x0,%eax
  801963:	5d                   	pop    %ebp
  801964:	c3                   	ret    

00801965 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80196b:	68 62 22 80 00       	push   $0x802262
  801970:	ff 75 0c             	pushl  0xc(%ebp)
  801973:	e8 a1 ed ff ff       	call   800719 <strcpy>
	return 0;
}
  801978:	b8 00 00 00 00       	mov    $0x0,%eax
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	57                   	push   %edi
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
  801985:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80198b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801990:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801996:	eb 2d                	jmp    8019c5 <devcons_write+0x46>
		m = n - tot;
  801998:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80199b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80199d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019a0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019a5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019a8:	83 ec 04             	sub    $0x4,%esp
  8019ab:	53                   	push   %ebx
  8019ac:	03 45 0c             	add    0xc(%ebp),%eax
  8019af:	50                   	push   %eax
  8019b0:	57                   	push   %edi
  8019b1:	e8 f5 ee ff ff       	call   8008ab <memmove>
		sys_cputs(buf, m);
  8019b6:	83 c4 08             	add    $0x8,%esp
  8019b9:	53                   	push   %ebx
  8019ba:	57                   	push   %edi
  8019bb:	e8 a0 f0 ff ff       	call   800a60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c0:	01 de                	add    %ebx,%esi
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	89 f0                	mov    %esi,%eax
  8019c7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019ca:	72 cc                	jb     801998 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019cf:	5b                   	pop    %ebx
  8019d0:	5e                   	pop    %esi
  8019d1:	5f                   	pop    %edi
  8019d2:	5d                   	pop    %ebp
  8019d3:	c3                   	ret    

008019d4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019e3:	74 2a                	je     801a0f <devcons_read+0x3b>
  8019e5:	eb 05                	jmp    8019ec <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019e7:	e8 11 f1 ff ff       	call   800afd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019ec:	e8 8d f0 ff ff       	call   800a7e <sys_cgetc>
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	74 f2                	je     8019e7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 16                	js     801a0f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019f9:	83 f8 04             	cmp    $0x4,%eax
  8019fc:	74 0c                	je     801a0a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a01:	88 02                	mov    %al,(%edx)
	return 1;
  801a03:	b8 01 00 00 00       	mov    $0x1,%eax
  801a08:	eb 05                	jmp    801a0f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a0a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a17:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a1d:	6a 01                	push   $0x1
  801a1f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a22:	50                   	push   %eax
  801a23:	e8 38 f0 ff ff       	call   800a60 <sys_cputs>
}
  801a28:	83 c4 10             	add    $0x10,%esp
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <getchar>:

int
getchar(void)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a33:	6a 01                	push   $0x1
  801a35:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a38:	50                   	push   %eax
  801a39:	6a 00                	push   $0x0
  801a3b:	e8 9d f6 ff ff       	call   8010dd <read>
	if (r < 0)
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	85 c0                	test   %eax,%eax
  801a45:	78 0f                	js     801a56 <getchar+0x29>
		return r;
	if (r < 1)
  801a47:	85 c0                	test   %eax,%eax
  801a49:	7e 06                	jle    801a51 <getchar+0x24>
		return -E_EOF;
	return c;
  801a4b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a4f:	eb 05                	jmp    801a56 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a51:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a56:	c9                   	leave  
  801a57:	c3                   	ret    

00801a58 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a61:	50                   	push   %eax
  801a62:	ff 75 08             	pushl  0x8(%ebp)
  801a65:	e8 0d f4 ff ff       	call   800e77 <fd_lookup>
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	78 11                	js     801a82 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a74:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a7a:	39 10                	cmp    %edx,(%eax)
  801a7c:	0f 94 c0             	sete   %al
  801a7f:	0f b6 c0             	movzbl %al,%eax
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <opencons>:

int
opencons(void)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8d:	50                   	push   %eax
  801a8e:	e8 95 f3 ff ff       	call   800e28 <fd_alloc>
  801a93:	83 c4 10             	add    $0x10,%esp
		return r;
  801a96:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 3e                	js     801ada <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a9c:	83 ec 04             	sub    $0x4,%esp
  801a9f:	68 07 04 00 00       	push   $0x407
  801aa4:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa7:	6a 00                	push   $0x0
  801aa9:	e8 6e f0 ff ff       	call   800b1c <sys_page_alloc>
  801aae:	83 c4 10             	add    $0x10,%esp
		return r;
  801ab1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 23                	js     801ada <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ab7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	50                   	push   %eax
  801ad0:	e8 2c f3 ff ff       	call   800e01 <fd2num>
  801ad5:	89 c2                	mov    %eax,%edx
  801ad7:	83 c4 10             	add    $0x10,%esp
}
  801ada:	89 d0                	mov    %edx,%eax
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ae3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ae6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801aec:	e8 ed ef ff ff       	call   800ade <sys_getenvid>
  801af1:	83 ec 0c             	sub    $0xc,%esp
  801af4:	ff 75 0c             	pushl  0xc(%ebp)
  801af7:	ff 75 08             	pushl  0x8(%ebp)
  801afa:	56                   	push   %esi
  801afb:	50                   	push   %eax
  801afc:	68 70 22 80 00       	push   $0x802270
  801b01:	e8 8e e6 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b06:	83 c4 18             	add    $0x18,%esp
  801b09:	53                   	push   %ebx
  801b0a:	ff 75 10             	pushl  0x10(%ebp)
  801b0d:	e8 31 e6 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801b12:	c7 04 24 5b 22 80 00 	movl   $0x80225b,(%esp)
  801b19:	e8 76 e6 ff ff       	call   800194 <cprintf>
  801b1e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b21:	cc                   	int3   
  801b22:	eb fd                	jmp    801b21 <_panic+0x43>

00801b24 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2a:	89 d0                	mov    %edx,%eax
  801b2c:	c1 e8 16             	shr    $0x16,%eax
  801b2f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3b:	f6 c1 01             	test   $0x1,%cl
  801b3e:	74 1d                	je     801b5d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b40:	c1 ea 0c             	shr    $0xc,%edx
  801b43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b4a:	f6 c2 01             	test   $0x1,%dl
  801b4d:	74 0e                	je     801b5d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b4f:	c1 ea 0c             	shr    $0xc,%edx
  801b52:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b59:	ef 
  801b5a:	0f b7 c0             	movzwl %ax,%eax
}
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    
  801b5f:	90                   	nop

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b77:	85 f6                	test   %esi,%esi
  801b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b7d:	89 ca                	mov    %ecx,%edx
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	75 3d                	jne    801bc0 <__udivdi3+0x60>
  801b83:	39 cf                	cmp    %ecx,%edi
  801b85:	0f 87 c5 00 00 00    	ja     801c50 <__udivdi3+0xf0>
  801b8b:	85 ff                	test   %edi,%edi
  801b8d:	89 fd                	mov    %edi,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f7                	div    %edi
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 c8                	mov    %ecx,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c1                	mov    %eax,%ecx
  801ba4:	89 d8                	mov    %ebx,%eax
  801ba6:	89 cf                	mov    %ecx,%edi
  801ba8:	f7 f5                	div    %ebp
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	89 fa                	mov    %edi,%edx
  801bb0:	83 c4 1c             	add    $0x1c,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
  801bb8:	90                   	nop
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	39 ce                	cmp    %ecx,%esi
  801bc2:	77 74                	ja     801c38 <__udivdi3+0xd8>
  801bc4:	0f bd fe             	bsr    %esi,%edi
  801bc7:	83 f7 1f             	xor    $0x1f,%edi
  801bca:	0f 84 98 00 00 00    	je     801c68 <__udivdi3+0x108>
  801bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	89 c5                	mov    %eax,%ebp
  801bd9:	29 fb                	sub    %edi,%ebx
  801bdb:	d3 e6                	shl    %cl,%esi
  801bdd:	89 d9                	mov    %ebx,%ecx
  801bdf:	d3 ed                	shr    %cl,%ebp
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	09 ee                	or     %ebp,%esi
  801be7:	89 d9                	mov    %ebx,%ecx
  801be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bed:	89 d5                	mov    %edx,%ebp
  801bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bf3:	d3 ed                	shr    %cl,%ebp
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e2                	shl    %cl,%edx
  801bf9:	89 d9                	mov    %ebx,%ecx
  801bfb:	d3 e8                	shr    %cl,%eax
  801bfd:	09 c2                	or     %eax,%edx
  801bff:	89 d0                	mov    %edx,%eax
  801c01:	89 ea                	mov    %ebp,%edx
  801c03:	f7 f6                	div    %esi
  801c05:	89 d5                	mov    %edx,%ebp
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	f7 64 24 0c          	mull   0xc(%esp)
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	72 10                	jb     801c21 <__udivdi3+0xc1>
  801c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e6                	shl    %cl,%esi
  801c19:	39 c6                	cmp    %eax,%esi
  801c1b:	73 07                	jae    801c24 <__udivdi3+0xc4>
  801c1d:	39 d5                	cmp    %edx,%ebp
  801c1f:	75 03                	jne    801c24 <__udivdi3+0xc4>
  801c21:	83 eb 01             	sub    $0x1,%ebx
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	89 fa                	mov    %edi,%edx
  801c2a:	83 c4 1c             	add    $0x1c,%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
  801c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c38:	31 ff                	xor    %edi,%edi
  801c3a:	31 db                	xor    %ebx,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 d8                	mov    %ebx,%eax
  801c52:	f7 f7                	div    %edi
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	89 fa                	mov    %edi,%edx
  801c5c:	83 c4 1c             	add    $0x1c,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	39 ce                	cmp    %ecx,%esi
  801c6a:	72 0c                	jb     801c78 <__udivdi3+0x118>
  801c6c:	31 db                	xor    %ebx,%ebx
  801c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c72:	0f 87 34 ff ff ff    	ja     801bac <__udivdi3+0x4c>
  801c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c7d:	e9 2a ff ff ff       	jmp    801bac <__udivdi3+0x4c>
  801c82:	66 90                	xchg   %ax,%ax
  801c84:	66 90                	xchg   %ax,%ax
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 d2                	test   %edx,%edx
  801ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb1:	89 f3                	mov    %esi,%ebx
  801cb3:	89 3c 24             	mov    %edi,(%esp)
  801cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cba:	75 1c                	jne    801cd8 <__umoddi3+0x48>
  801cbc:	39 f7                	cmp    %esi,%edi
  801cbe:	76 50                	jbe    801d10 <__umoddi3+0x80>
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	f7 f7                	div    %edi
  801cc6:	89 d0                	mov    %edx,%eax
  801cc8:	31 d2                	xor    %edx,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	77 52                	ja     801d30 <__umoddi3+0xa0>
  801cde:	0f bd ea             	bsr    %edx,%ebp
  801ce1:	83 f5 1f             	xor    $0x1f,%ebp
  801ce4:	75 5a                	jne    801d40 <__umoddi3+0xb0>
  801ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cea:	0f 82 e0 00 00 00    	jb     801dd0 <__umoddi3+0x140>
  801cf0:	39 0c 24             	cmp    %ecx,(%esp)
  801cf3:	0f 86 d7 00 00 00    	jbe    801dd0 <__umoddi3+0x140>
  801cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	85 ff                	test   %edi,%edi
  801d12:	89 fd                	mov    %edi,%ebp
  801d14:	75 0b                	jne    801d21 <__umoddi3+0x91>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f7                	div    %edi
  801d1f:	89 c5                	mov    %eax,%ebp
  801d21:	89 f0                	mov    %esi,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f5                	div    %ebp
  801d27:	89 c8                	mov    %ecx,%eax
  801d29:	f7 f5                	div    %ebp
  801d2b:	89 d0                	mov    %edx,%eax
  801d2d:	eb 99                	jmp    801cc8 <__umoddi3+0x38>
  801d2f:	90                   	nop
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 1c             	add    $0x1c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	8b 34 24             	mov    (%esp),%esi
  801d43:	bf 20 00 00 00       	mov    $0x20,%edi
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	29 ef                	sub    %ebp,%edi
  801d4c:	d3 e0                	shl    %cl,%eax
  801d4e:	89 f9                	mov    %edi,%ecx
  801d50:	89 f2                	mov    %esi,%edx
  801d52:	d3 ea                	shr    %cl,%edx
  801d54:	89 e9                	mov    %ebp,%ecx
  801d56:	09 c2                	or     %eax,%edx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 14 24             	mov    %edx,(%esp)
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	d3 e2                	shl    %cl,%edx
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	89 c6                	mov    %eax,%esi
  801d71:	d3 e3                	shl    %cl,%ebx
  801d73:	89 f9                	mov    %edi,%ecx
  801d75:	89 d0                	mov    %edx,%eax
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	09 d8                	or     %ebx,%eax
  801d7d:	89 d3                	mov    %edx,%ebx
  801d7f:	89 f2                	mov    %esi,%edx
  801d81:	f7 34 24             	divl   (%esp)
  801d84:	89 d6                	mov    %edx,%esi
  801d86:	d3 e3                	shl    %cl,%ebx
  801d88:	f7 64 24 04          	mull   0x4(%esp)
  801d8c:	39 d6                	cmp    %edx,%esi
  801d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d92:	89 d1                	mov    %edx,%ecx
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	72 08                	jb     801da0 <__umoddi3+0x110>
  801d98:	75 11                	jne    801dab <__umoddi3+0x11b>
  801d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d9e:	73 0b                	jae    801dab <__umoddi3+0x11b>
  801da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801da4:	1b 14 24             	sbb    (%esp),%edx
  801da7:	89 d1                	mov    %edx,%ecx
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801daf:	29 da                	sub    %ebx,%edx
  801db1:	19 ce                	sbb    %ecx,%esi
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 f0                	mov    %esi,%eax
  801db7:	d3 e0                	shl    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 ea                	shr    %cl,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	d3 ee                	shr    %cl,%esi
  801dc1:	09 d0                	or     %edx,%eax
  801dc3:	89 f2                	mov    %esi,%edx
  801dc5:	83 c4 1c             	add    $0x1c,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
  801dd0:	29 f9                	sub    %edi,%ecx
  801dd2:	19 d6                	sbb    %edx,%esi
  801dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ddc:	e9 18 ff ff ff       	jmp    801cf9 <__umoddi3+0x69>
