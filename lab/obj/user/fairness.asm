
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
  800059:	e8 10 0d 00 00       	call   800d6e <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 c0 22 80 00       	push   $0x8022c0
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
  80007e:	68 d1 22 80 00       	push   $0x8022d1
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 39 0d 00 00       	call   800dd5 <ipc_send>
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
  8000ed:	e8 3b 0f 00 00       	call   80102d <close_all>
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
  8001f7:	e8 34 1e 00 00       	call   802030 <__udivdi3>
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
  80023a:	e8 21 1f 00 00       	call   802160 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 f2 22 80 00 	movsbl 0x8022f2(%eax),%eax
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
  80033e:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
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
  800402:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800409:	85 d2                	test   %edx,%edx
  80040b:	75 18                	jne    800425 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040d:	50                   	push   %eax
  80040e:	68 0a 23 80 00       	push   $0x80230a
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
  800426:	68 ed 26 80 00       	push   $0x8026ed
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
  80044a:	b8 03 23 80 00       	mov    $0x802303,%eax
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
  800ac5:	68 ff 25 80 00       	push   $0x8025ff
  800aca:	6a 23                	push   $0x23
  800acc:	68 1c 26 80 00       	push   $0x80261c
  800ad1:	e8 d0 14 00 00       	call   801fa6 <_panic>

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
  800b46:	68 ff 25 80 00       	push   $0x8025ff
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 1c 26 80 00       	push   $0x80261c
  800b52:	e8 4f 14 00 00       	call   801fa6 <_panic>

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
  800b88:	68 ff 25 80 00       	push   $0x8025ff
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 1c 26 80 00       	push   $0x80261c
  800b94:	e8 0d 14 00 00       	call   801fa6 <_panic>

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
  800bca:	68 ff 25 80 00       	push   $0x8025ff
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 1c 26 80 00       	push   $0x80261c
  800bd6:	e8 cb 13 00 00       	call   801fa6 <_panic>

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
  800c0c:	68 ff 25 80 00       	push   $0x8025ff
  800c11:	6a 23                	push   $0x23
  800c13:	68 1c 26 80 00       	push   $0x80261c
  800c18:	e8 89 13 00 00       	call   801fa6 <_panic>

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
  800c4e:	68 ff 25 80 00       	push   $0x8025ff
  800c53:	6a 23                	push   $0x23
  800c55:	68 1c 26 80 00       	push   $0x80261c
  800c5a:	e8 47 13 00 00       	call   801fa6 <_panic>

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
  800c90:	68 ff 25 80 00       	push   $0x8025ff
  800c95:	6a 23                	push   $0x23
  800c97:	68 1c 26 80 00       	push   $0x80261c
  800c9c:	e8 05 13 00 00       	call   801fa6 <_panic>

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
  800cf4:	68 ff 25 80 00       	push   $0x8025ff
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 1c 26 80 00       	push   $0x80261c
  800d00:	e8 a1 12 00 00       	call   801fa6 <_panic>

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
  800d55:	68 ff 25 80 00       	push   $0x8025ff
  800d5a:	6a 23                	push   $0x23
  800d5c:	68 1c 26 80 00       	push   $0x80261c
  800d61:	e8 40 12 00 00       	call   801fa6 <_panic>

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

00800d6e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	8b 75 08             	mov    0x8(%ebp),%esi
  800d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  800d7c:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  800d7e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800d83:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	e8 3d ff ff ff       	call   800ccc <sys_ipc_recv>

	if (from_env_store != NULL)
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	85 f6                	test   %esi,%esi
  800d94:	74 14                	je     800daa <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  800d96:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	78 09                	js     800da8 <ipc_recv+0x3a>
  800d9f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800da5:	8b 52 74             	mov    0x74(%edx),%edx
  800da8:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  800daa:	85 db                	test   %ebx,%ebx
  800dac:	74 14                	je     800dc2 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  800dae:	ba 00 00 00 00       	mov    $0x0,%edx
  800db3:	85 c0                	test   %eax,%eax
  800db5:	78 09                	js     800dc0 <ipc_recv+0x52>
  800db7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800dbd:	8b 52 78             	mov    0x78(%edx),%edx
  800dc0:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	78 08                	js     800dce <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  800dc6:	a1 08 40 80 00       	mov    0x804008,%eax
  800dcb:	8b 40 70             	mov    0x70(%eax),%eax
}
  800dce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	57                   	push   %edi
  800dd9:	56                   	push   %esi
  800dda:	53                   	push   %ebx
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	8b 7d 08             	mov    0x8(%ebp),%edi
  800de1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  800de7:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  800de9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800dee:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  800df1:	ff 75 14             	pushl  0x14(%ebp)
  800df4:	53                   	push   %ebx
  800df5:	56                   	push   %esi
  800df6:	57                   	push   %edi
  800df7:	e8 ad fe ff ff       	call   800ca9 <sys_ipc_try_send>

		if (err < 0) {
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	79 1e                	jns    800e21 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  800e03:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e06:	75 07                	jne    800e0f <ipc_send+0x3a>
				sys_yield();
  800e08:	e8 f0 fc ff ff       	call   800afd <sys_yield>
  800e0d:	eb e2                	jmp    800df1 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  800e0f:	50                   	push   %eax
  800e10:	68 2a 26 80 00       	push   $0x80262a
  800e15:	6a 49                	push   $0x49
  800e17:	68 37 26 80 00       	push   $0x802637
  800e1c:	e8 85 11 00 00       	call   801fa6 <_panic>
		}

	} while (err < 0);

}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e2f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e34:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e37:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e3d:	8b 52 50             	mov    0x50(%edx),%edx
  800e40:	39 ca                	cmp    %ecx,%edx
  800e42:	75 0d                	jne    800e51 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e4c:	8b 40 48             	mov    0x48(%eax),%eax
  800e4f:	eb 0f                	jmp    800e60 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e51:	83 c0 01             	add    $0x1,%eax
  800e54:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e59:	75 d9                	jne    800e34 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
  800e68:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
  800e78:	05 00 00 00 30       	add    $0x30000000,%eax
  800e7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e82:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e94:	89 c2                	mov    %eax,%edx
  800e96:	c1 ea 16             	shr    $0x16,%edx
  800e99:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea0:	f6 c2 01             	test   $0x1,%dl
  800ea3:	74 11                	je     800eb6 <fd_alloc+0x2d>
  800ea5:	89 c2                	mov    %eax,%edx
  800ea7:	c1 ea 0c             	shr    $0xc,%edx
  800eaa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb1:	f6 c2 01             	test   $0x1,%dl
  800eb4:	75 09                	jne    800ebf <fd_alloc+0x36>
			*fd_store = fd;
  800eb6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebd:	eb 17                	jmp    800ed6 <fd_alloc+0x4d>
  800ebf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ec4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ec9:	75 c9                	jne    800e94 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ecb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ed1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ede:	83 f8 1f             	cmp    $0x1f,%eax
  800ee1:	77 36                	ja     800f19 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ee3:	c1 e0 0c             	shl    $0xc,%eax
  800ee6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	c1 ea 16             	shr    $0x16,%edx
  800ef0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef7:	f6 c2 01             	test   $0x1,%dl
  800efa:	74 24                	je     800f20 <fd_lookup+0x48>
  800efc:	89 c2                	mov    %eax,%edx
  800efe:	c1 ea 0c             	shr    $0xc,%edx
  800f01:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f08:	f6 c2 01             	test   $0x1,%dl
  800f0b:	74 1a                	je     800f27 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f10:	89 02                	mov    %eax,(%edx)
	return 0;
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	eb 13                	jmp    800f2c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f1e:	eb 0c                	jmp    800f2c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f25:	eb 05                	jmp    800f2c <fd_lookup+0x54>
  800f27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f37:	ba c0 26 80 00       	mov    $0x8026c0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f3c:	eb 13                	jmp    800f51 <dev_lookup+0x23>
  800f3e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f41:	39 08                	cmp    %ecx,(%eax)
  800f43:	75 0c                	jne    800f51 <dev_lookup+0x23>
			*dev = devtab[i];
  800f45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f48:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4f:	eb 2e                	jmp    800f7f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f51:	8b 02                	mov    (%edx),%eax
  800f53:	85 c0                	test   %eax,%eax
  800f55:	75 e7                	jne    800f3e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f57:	a1 08 40 80 00       	mov    0x804008,%eax
  800f5c:	8b 40 48             	mov    0x48(%eax),%eax
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	51                   	push   %ecx
  800f63:	50                   	push   %eax
  800f64:	68 44 26 80 00       	push   $0x802644
  800f69:	e8 26 f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 10             	sub    $0x10,%esp
  800f89:	8b 75 08             	mov    0x8(%ebp),%esi
  800f8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f92:	50                   	push   %eax
  800f93:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f99:	c1 e8 0c             	shr    $0xc,%eax
  800f9c:	50                   	push   %eax
  800f9d:	e8 36 ff ff ff       	call   800ed8 <fd_lookup>
  800fa2:	83 c4 08             	add    $0x8,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 05                	js     800fae <fd_close+0x2d>
	    || fd != fd2)
  800fa9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fac:	74 0c                	je     800fba <fd_close+0x39>
		return (must_exist ? r : 0);
  800fae:	84 db                	test   %bl,%bl
  800fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb5:	0f 44 c2             	cmove  %edx,%eax
  800fb8:	eb 41                	jmp    800ffb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fba:	83 ec 08             	sub    $0x8,%esp
  800fbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc0:	50                   	push   %eax
  800fc1:	ff 36                	pushl  (%esi)
  800fc3:	e8 66 ff ff ff       	call   800f2e <dev_lookup>
  800fc8:	89 c3                	mov    %eax,%ebx
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 1a                	js     800feb <fd_close+0x6a>
		if (dev->dev_close)
  800fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	74 0b                	je     800feb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	56                   	push   %esi
  800fe4:	ff d0                	call   *%eax
  800fe6:	89 c3                	mov    %eax,%ebx
  800fe8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	56                   	push   %esi
  800fef:	6a 00                	push   $0x0
  800ff1:	e8 ab fb ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	89 d8                	mov    %ebx,%eax
}
  800ffb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801008:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	ff 75 08             	pushl  0x8(%ebp)
  80100f:	e8 c4 fe ff ff       	call   800ed8 <fd_lookup>
  801014:	83 c4 08             	add    $0x8,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	78 10                	js     80102b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80101b:	83 ec 08             	sub    $0x8,%esp
  80101e:	6a 01                	push   $0x1
  801020:	ff 75 f4             	pushl  -0xc(%ebp)
  801023:	e8 59 ff ff ff       	call   800f81 <fd_close>
  801028:	83 c4 10             	add    $0x10,%esp
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <close_all>:

void
close_all(void)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	53                   	push   %ebx
  801031:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801034:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	53                   	push   %ebx
  80103d:	e8 c0 ff ff ff       	call   801002 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801042:	83 c3 01             	add    $0x1,%ebx
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	83 fb 20             	cmp    $0x20,%ebx
  80104b:	75 ec                	jne    801039 <close_all+0xc>
		close(i);
}
  80104d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801050:	c9                   	leave  
  801051:	c3                   	ret    

00801052 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 2c             	sub    $0x2c,%esp
  80105b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80105e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	ff 75 08             	pushl  0x8(%ebp)
  801065:	e8 6e fe ff ff       	call   800ed8 <fd_lookup>
  80106a:	83 c4 08             	add    $0x8,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	0f 88 c1 00 00 00    	js     801136 <dup+0xe4>
		return r;
	close(newfdnum);
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	56                   	push   %esi
  801079:	e8 84 ff ff ff       	call   801002 <close>

	newfd = INDEX2FD(newfdnum);
  80107e:	89 f3                	mov    %esi,%ebx
  801080:	c1 e3 0c             	shl    $0xc,%ebx
  801083:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801089:	83 c4 04             	add    $0x4,%esp
  80108c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108f:	e8 de fd ff ff       	call   800e72 <fd2data>
  801094:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801096:	89 1c 24             	mov    %ebx,(%esp)
  801099:	e8 d4 fd ff ff       	call   800e72 <fd2data>
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a4:	89 f8                	mov    %edi,%eax
  8010a6:	c1 e8 16             	shr    $0x16,%eax
  8010a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b0:	a8 01                	test   $0x1,%al
  8010b2:	74 37                	je     8010eb <dup+0x99>
  8010b4:	89 f8                	mov    %edi,%eax
  8010b6:	c1 e8 0c             	shr    $0xc,%eax
  8010b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c0:	f6 c2 01             	test   $0x1,%dl
  8010c3:	74 26                	je     8010eb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d4:	50                   	push   %eax
  8010d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d8:	6a 00                	push   $0x0
  8010da:	57                   	push   %edi
  8010db:	6a 00                	push   $0x0
  8010dd:	e8 7d fa ff ff       	call   800b5f <sys_page_map>
  8010e2:	89 c7                	mov    %eax,%edi
  8010e4:	83 c4 20             	add    $0x20,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 2e                	js     801119 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010ee:	89 d0                	mov    %edx,%eax
  8010f0:	c1 e8 0c             	shr    $0xc,%eax
  8010f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801102:	50                   	push   %eax
  801103:	53                   	push   %ebx
  801104:	6a 00                	push   $0x0
  801106:	52                   	push   %edx
  801107:	6a 00                	push   $0x0
  801109:	e8 51 fa ff ff       	call   800b5f <sys_page_map>
  80110e:	89 c7                	mov    %eax,%edi
  801110:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801113:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801115:	85 ff                	test   %edi,%edi
  801117:	79 1d                	jns    801136 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801119:	83 ec 08             	sub    $0x8,%esp
  80111c:	53                   	push   %ebx
  80111d:	6a 00                	push   $0x0
  80111f:	e8 7d fa ff ff       	call   800ba1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112a:	6a 00                	push   $0x0
  80112c:	e8 70 fa ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	89 f8                	mov    %edi,%eax
}
  801136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	53                   	push   %ebx
  801142:	83 ec 14             	sub    $0x14,%esp
  801145:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801148:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114b:	50                   	push   %eax
  80114c:	53                   	push   %ebx
  80114d:	e8 86 fd ff ff       	call   800ed8 <fd_lookup>
  801152:	83 c4 08             	add    $0x8,%esp
  801155:	89 c2                	mov    %eax,%edx
  801157:	85 c0                	test   %eax,%eax
  801159:	78 6d                	js     8011c8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801161:	50                   	push   %eax
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	ff 30                	pushl  (%eax)
  801167:	e8 c2 fd ff ff       	call   800f2e <dev_lookup>
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 4c                	js     8011bf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801173:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801176:	8b 42 08             	mov    0x8(%edx),%eax
  801179:	83 e0 03             	and    $0x3,%eax
  80117c:	83 f8 01             	cmp    $0x1,%eax
  80117f:	75 21                	jne    8011a2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801181:	a1 08 40 80 00       	mov    0x804008,%eax
  801186:	8b 40 48             	mov    0x48(%eax),%eax
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	53                   	push   %ebx
  80118d:	50                   	push   %eax
  80118e:	68 85 26 80 00       	push   $0x802685
  801193:	e8 fc ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a0:	eb 26                	jmp    8011c8 <read+0x8a>
	}
	if (!dev->dev_read)
  8011a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a5:	8b 40 08             	mov    0x8(%eax),%eax
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	74 17                	je     8011c3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ac:	83 ec 04             	sub    $0x4,%esp
  8011af:	ff 75 10             	pushl  0x10(%ebp)
  8011b2:	ff 75 0c             	pushl  0xc(%ebp)
  8011b5:	52                   	push   %edx
  8011b6:	ff d0                	call   *%eax
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	eb 09                	jmp    8011c8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	eb 05                	jmp    8011c8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011c8:	89 d0                	mov    %edx,%eax
  8011ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cd:	c9                   	leave  
  8011ce:	c3                   	ret    

008011cf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	57                   	push   %edi
  8011d3:	56                   	push   %esi
  8011d4:	53                   	push   %ebx
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011db:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e3:	eb 21                	jmp    801206 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	89 f0                	mov    %esi,%eax
  8011ea:	29 d8                	sub    %ebx,%eax
  8011ec:	50                   	push   %eax
  8011ed:	89 d8                	mov    %ebx,%eax
  8011ef:	03 45 0c             	add    0xc(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	57                   	push   %edi
  8011f4:	e8 45 ff ff ff       	call   80113e <read>
		if (m < 0)
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 10                	js     801210 <readn+0x41>
			return m;
		if (m == 0)
  801200:	85 c0                	test   %eax,%eax
  801202:	74 0a                	je     80120e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801204:	01 c3                	add    %eax,%ebx
  801206:	39 f3                	cmp    %esi,%ebx
  801208:	72 db                	jb     8011e5 <readn+0x16>
  80120a:	89 d8                	mov    %ebx,%eax
  80120c:	eb 02                	jmp    801210 <readn+0x41>
  80120e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5f                   	pop    %edi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	53                   	push   %ebx
  80121c:	83 ec 14             	sub    $0x14,%esp
  80121f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801222:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	53                   	push   %ebx
  801227:	e8 ac fc ff ff       	call   800ed8 <fd_lookup>
  80122c:	83 c4 08             	add    $0x8,%esp
  80122f:	89 c2                	mov    %eax,%edx
  801231:	85 c0                	test   %eax,%eax
  801233:	78 68                	js     80129d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801235:	83 ec 08             	sub    $0x8,%esp
  801238:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	ff 30                	pushl  (%eax)
  801241:	e8 e8 fc ff ff       	call   800f2e <dev_lookup>
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 47                	js     801294 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801250:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801254:	75 21                	jne    801277 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801256:	a1 08 40 80 00       	mov    0x804008,%eax
  80125b:	8b 40 48             	mov    0x48(%eax),%eax
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	53                   	push   %ebx
  801262:	50                   	push   %eax
  801263:	68 a1 26 80 00       	push   $0x8026a1
  801268:	e8 27 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801275:	eb 26                	jmp    80129d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801277:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127a:	8b 52 0c             	mov    0xc(%edx),%edx
  80127d:	85 d2                	test   %edx,%edx
  80127f:	74 17                	je     801298 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801281:	83 ec 04             	sub    $0x4,%esp
  801284:	ff 75 10             	pushl  0x10(%ebp)
  801287:	ff 75 0c             	pushl  0xc(%ebp)
  80128a:	50                   	push   %eax
  80128b:	ff d2                	call   *%edx
  80128d:	89 c2                	mov    %eax,%edx
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	eb 09                	jmp    80129d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801294:	89 c2                	mov    %eax,%edx
  801296:	eb 05                	jmp    80129d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801298:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80129d:	89 d0                	mov    %edx,%eax
  80129f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	ff 75 08             	pushl  0x8(%ebp)
  8012b1:	e8 22 fc ff ff       	call   800ed8 <fd_lookup>
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	78 0e                	js     8012cb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 14             	sub    $0x14,%esp
  8012d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	53                   	push   %ebx
  8012dc:	e8 f7 fb ff ff       	call   800ed8 <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	89 c2                	mov    %eax,%edx
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 65                	js     80134f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f4:	ff 30                	pushl  (%eax)
  8012f6:	e8 33 fc ff ff       	call   800f2e <dev_lookup>
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 44                	js     801346 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801302:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801305:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801309:	75 21                	jne    80132c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80130b:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801310:	8b 40 48             	mov    0x48(%eax),%eax
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	53                   	push   %ebx
  801317:	50                   	push   %eax
  801318:	68 64 26 80 00       	push   $0x802664
  80131d:	e8 72 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132a:	eb 23                	jmp    80134f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80132c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132f:	8b 52 18             	mov    0x18(%edx),%edx
  801332:	85 d2                	test   %edx,%edx
  801334:	74 14                	je     80134a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	ff 75 0c             	pushl  0xc(%ebp)
  80133c:	50                   	push   %eax
  80133d:	ff d2                	call   *%edx
  80133f:	89 c2                	mov    %eax,%edx
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	eb 09                	jmp    80134f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801346:	89 c2                	mov    %eax,%edx
  801348:	eb 05                	jmp    80134f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80134a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80134f:	89 d0                	mov    %edx,%eax
  801351:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801354:	c9                   	leave  
  801355:	c3                   	ret    

00801356 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	53                   	push   %ebx
  80135a:	83 ec 14             	sub    $0x14,%esp
  80135d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801360:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	ff 75 08             	pushl  0x8(%ebp)
  801367:	e8 6c fb ff ff       	call   800ed8 <fd_lookup>
  80136c:	83 c4 08             	add    $0x8,%esp
  80136f:	89 c2                	mov    %eax,%edx
  801371:	85 c0                	test   %eax,%eax
  801373:	78 58                	js     8013cd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137f:	ff 30                	pushl  (%eax)
  801381:	e8 a8 fb ff ff       	call   800f2e <dev_lookup>
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 37                	js     8013c4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80138d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801390:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801394:	74 32                	je     8013c8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801396:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801399:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013a0:	00 00 00 
	stat->st_isdir = 0;
  8013a3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013aa:	00 00 00 
	stat->st_dev = dev;
  8013ad:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	53                   	push   %ebx
  8013b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ba:	ff 50 14             	call   *0x14(%eax)
  8013bd:	89 c2                	mov    %eax,%edx
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	eb 09                	jmp    8013cd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	eb 05                	jmp    8013cd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013cd:	89 d0                	mov    %edx,%eax
  8013cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	56                   	push   %esi
  8013d8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	6a 00                	push   $0x0
  8013de:	ff 75 08             	pushl  0x8(%ebp)
  8013e1:	e8 d6 01 00 00       	call   8015bc <open>
  8013e6:	89 c3                	mov    %eax,%ebx
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 1b                	js     80140a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	ff 75 0c             	pushl  0xc(%ebp)
  8013f5:	50                   	push   %eax
  8013f6:	e8 5b ff ff ff       	call   801356 <fstat>
  8013fb:	89 c6                	mov    %eax,%esi
	close(fd);
  8013fd:	89 1c 24             	mov    %ebx,(%esp)
  801400:	e8 fd fb ff ff       	call   801002 <close>
	return r;
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	89 f0                	mov    %esi,%eax
}
  80140a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	56                   	push   %esi
  801415:	53                   	push   %ebx
  801416:	89 c6                	mov    %eax,%esi
  801418:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80141a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801421:	75 12                	jne    801435 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801423:	83 ec 0c             	sub    $0xc,%esp
  801426:	6a 01                	push   $0x1
  801428:	e8 fc f9 ff ff       	call   800e29 <ipc_find_env>
  80142d:	a3 00 40 80 00       	mov    %eax,0x804000
  801432:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801435:	6a 07                	push   $0x7
  801437:	68 00 50 80 00       	push   $0x805000
  80143c:	56                   	push   %esi
  80143d:	ff 35 00 40 80 00    	pushl  0x804000
  801443:	e8 8d f9 ff ff       	call   800dd5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801448:	83 c4 0c             	add    $0xc,%esp
  80144b:	6a 00                	push   $0x0
  80144d:	53                   	push   %ebx
  80144e:	6a 00                	push   $0x0
  801450:	e8 19 f9 ff ff       	call   800d6e <ipc_recv>
}
  801455:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801458:	5b                   	pop    %ebx
  801459:	5e                   	pop    %esi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801462:	8b 45 08             	mov    0x8(%ebp),%eax
  801465:	8b 40 0c             	mov    0xc(%eax),%eax
  801468:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80146d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801470:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801475:	ba 00 00 00 00       	mov    $0x0,%edx
  80147a:	b8 02 00 00 00       	mov    $0x2,%eax
  80147f:	e8 8d ff ff ff       	call   801411 <fsipc>
}
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80148c:	8b 45 08             	mov    0x8(%ebp),%eax
  80148f:	8b 40 0c             	mov    0xc(%eax),%eax
  801492:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801497:	ba 00 00 00 00       	mov    $0x0,%edx
  80149c:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a1:	e8 6b ff ff ff       	call   801411 <fsipc>
}
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	53                   	push   %ebx
  8014ac:	83 ec 04             	sub    $0x4,%esp
  8014af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8014c7:	e8 45 ff ff ff       	call   801411 <fsipc>
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 2c                	js     8014fc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	68 00 50 80 00       	push   $0x805000
  8014d8:	53                   	push   %ebx
  8014d9:	e8 3b f2 ff ff       	call   800719 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014de:	a1 80 50 80 00       	mov    0x805080,%eax
  8014e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e9:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	83 ec 0c             	sub    $0xc,%esp
  801507:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80150a:	8b 55 08             	mov    0x8(%ebp),%edx
  80150d:	8b 52 0c             	mov    0xc(%edx),%edx
  801510:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801516:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80151b:	50                   	push   %eax
  80151c:	ff 75 0c             	pushl  0xc(%ebp)
  80151f:	68 08 50 80 00       	push   $0x805008
  801524:	e8 82 f3 ff ff       	call   8008ab <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801529:	ba 00 00 00 00       	mov    $0x0,%edx
  80152e:	b8 04 00 00 00       	mov    $0x4,%eax
  801533:	e8 d9 fe ff ff       	call   801411 <fsipc>

}
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	56                   	push   %esi
  80153e:	53                   	push   %ebx
  80153f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801542:	8b 45 08             	mov    0x8(%ebp),%eax
  801545:	8b 40 0c             	mov    0xc(%eax),%eax
  801548:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80154d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801553:	ba 00 00 00 00       	mov    $0x0,%edx
  801558:	b8 03 00 00 00       	mov    $0x3,%eax
  80155d:	e8 af fe ff ff       	call   801411 <fsipc>
  801562:	89 c3                	mov    %eax,%ebx
  801564:	85 c0                	test   %eax,%eax
  801566:	78 4b                	js     8015b3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801568:	39 c6                	cmp    %eax,%esi
  80156a:	73 16                	jae    801582 <devfile_read+0x48>
  80156c:	68 d4 26 80 00       	push   $0x8026d4
  801571:	68 db 26 80 00       	push   $0x8026db
  801576:	6a 7c                	push   $0x7c
  801578:	68 f0 26 80 00       	push   $0x8026f0
  80157d:	e8 24 0a 00 00       	call   801fa6 <_panic>
	assert(r <= PGSIZE);
  801582:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801587:	7e 16                	jle    80159f <devfile_read+0x65>
  801589:	68 fb 26 80 00       	push   $0x8026fb
  80158e:	68 db 26 80 00       	push   $0x8026db
  801593:	6a 7d                	push   $0x7d
  801595:	68 f0 26 80 00       	push   $0x8026f0
  80159a:	e8 07 0a 00 00       	call   801fa6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	50                   	push   %eax
  8015a3:	68 00 50 80 00       	push   $0x805000
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	e8 fb f2 ff ff       	call   8008ab <memmove>
	return r;
  8015b0:	83 c4 10             	add    $0x10,%esp
}
  8015b3:	89 d8                	mov    %ebx,%eax
  8015b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5e                   	pop    %esi
  8015ba:	5d                   	pop    %ebp
  8015bb:	c3                   	ret    

008015bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 20             	sub    $0x20,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015c6:	53                   	push   %ebx
  8015c7:	e8 14 f1 ff ff       	call   8006e0 <strlen>
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d4:	7f 67                	jg     80163d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d6:	83 ec 0c             	sub    $0xc,%esp
  8015d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	e8 a7 f8 ff ff       	call   800e89 <fd_alloc>
  8015e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8015e5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 57                	js     801642 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	53                   	push   %ebx
  8015ef:	68 00 50 80 00       	push   $0x805000
  8015f4:	e8 20 f1 ff ff       	call   800719 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801601:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801604:	b8 01 00 00 00       	mov    $0x1,%eax
  801609:	e8 03 fe ff ff       	call   801411 <fsipc>
  80160e:	89 c3                	mov    %eax,%ebx
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	79 14                	jns    80162b <open+0x6f>
		fd_close(fd, 0);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	6a 00                	push   $0x0
  80161c:	ff 75 f4             	pushl  -0xc(%ebp)
  80161f:	e8 5d f9 ff ff       	call   800f81 <fd_close>
		return r;
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	89 da                	mov    %ebx,%edx
  801629:	eb 17                	jmp    801642 <open+0x86>
	}

	return fd2num(fd);
  80162b:	83 ec 0c             	sub    $0xc,%esp
  80162e:	ff 75 f4             	pushl  -0xc(%ebp)
  801631:	e8 2c f8 ff ff       	call   800e62 <fd2num>
  801636:	89 c2                	mov    %eax,%edx
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	eb 05                	jmp    801642 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80163d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801642:	89 d0                	mov    %edx,%eax
  801644:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80164f:	ba 00 00 00 00       	mov    $0x0,%edx
  801654:	b8 08 00 00 00       	mov    $0x8,%eax
  801659:	e8 b3 fd ff ff       	call   801411 <fsipc>
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801666:	68 07 27 80 00       	push   $0x802707
  80166b:	ff 75 0c             	pushl  0xc(%ebp)
  80166e:	e8 a6 f0 ff ff       	call   800719 <strcpy>
	return 0;
}
  801673:	b8 00 00 00 00       	mov    $0x0,%eax
  801678:	c9                   	leave  
  801679:	c3                   	ret    

0080167a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	53                   	push   %ebx
  80167e:	83 ec 10             	sub    $0x10,%esp
  801681:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801684:	53                   	push   %ebx
  801685:	e8 62 09 00 00       	call   801fec <pageref>
  80168a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80168d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801692:	83 f8 01             	cmp    $0x1,%eax
  801695:	75 10                	jne    8016a7 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801697:	83 ec 0c             	sub    $0xc,%esp
  80169a:	ff 73 0c             	pushl  0xc(%ebx)
  80169d:	e8 c0 02 00 00       	call   801962 <nsipc_close>
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016a7:	89 d0                	mov    %edx,%eax
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016b4:	6a 00                	push   $0x0
  8016b6:	ff 75 10             	pushl  0x10(%ebp)
  8016b9:	ff 75 0c             	pushl  0xc(%ebp)
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	ff 70 0c             	pushl  0xc(%eax)
  8016c2:	e8 78 03 00 00       	call   801a3f <nsipc_send>
}
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016cf:	6a 00                	push   $0x0
  8016d1:	ff 75 10             	pushl  0x10(%ebp)
  8016d4:	ff 75 0c             	pushl  0xc(%ebp)
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	ff 70 0c             	pushl  0xc(%eax)
  8016dd:	e8 f1 02 00 00       	call   8019d3 <nsipc_recv>
}
  8016e2:	c9                   	leave  
  8016e3:	c3                   	ret    

008016e4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016ea:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016ed:	52                   	push   %edx
  8016ee:	50                   	push   %eax
  8016ef:	e8 e4 f7 ff ff       	call   800ed8 <fd_lookup>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 17                	js     801712 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fe:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801704:	39 08                	cmp    %ecx,(%eax)
  801706:	75 05                	jne    80170d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801708:	8b 40 0c             	mov    0xc(%eax),%eax
  80170b:	eb 05                	jmp    801712 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80170d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	56                   	push   %esi
  801718:	53                   	push   %ebx
  801719:	83 ec 1c             	sub    $0x1c,%esp
  80171c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80171e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801721:	50                   	push   %eax
  801722:	e8 62 f7 ff ff       	call   800e89 <fd_alloc>
  801727:	89 c3                	mov    %eax,%ebx
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 1b                	js     80174b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801730:	83 ec 04             	sub    $0x4,%esp
  801733:	68 07 04 00 00       	push   $0x407
  801738:	ff 75 f4             	pushl  -0xc(%ebp)
  80173b:	6a 00                	push   $0x0
  80173d:	e8 da f3 ff ff       	call   800b1c <sys_page_alloc>
  801742:	89 c3                	mov    %eax,%ebx
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	79 10                	jns    80175b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80174b:	83 ec 0c             	sub    $0xc,%esp
  80174e:	56                   	push   %esi
  80174f:	e8 0e 02 00 00       	call   801962 <nsipc_close>
		return r;
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	89 d8                	mov    %ebx,%eax
  801759:	eb 24                	jmp    80177f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80175b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801761:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801764:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801766:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801769:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801770:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	50                   	push   %eax
  801777:	e8 e6 f6 ff ff       	call   800e62 <fd2num>
  80177c:	83 c4 10             	add    $0x10,%esp
}
  80177f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801782:	5b                   	pop    %ebx
  801783:	5e                   	pop    %esi
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	e8 50 ff ff ff       	call   8016e4 <fd2sockid>
		return r;
  801794:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801796:	85 c0                	test   %eax,%eax
  801798:	78 1f                	js     8017b9 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	ff 75 10             	pushl  0x10(%ebp)
  8017a0:	ff 75 0c             	pushl  0xc(%ebp)
  8017a3:	50                   	push   %eax
  8017a4:	e8 12 01 00 00       	call   8018bb <nsipc_accept>
  8017a9:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ac:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 07                	js     8017b9 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017b2:	e8 5d ff ff ff       	call   801714 <alloc_sockfd>
  8017b7:	89 c1                	mov    %eax,%ecx
}
  8017b9:	89 c8                	mov    %ecx,%eax
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	e8 19 ff ff ff       	call   8016e4 <fd2sockid>
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	78 12                	js     8017e1 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017cf:	83 ec 04             	sub    $0x4,%esp
  8017d2:	ff 75 10             	pushl  0x10(%ebp)
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	50                   	push   %eax
  8017d9:	e8 2d 01 00 00       	call   80190b <nsipc_bind>
  8017de:	83 c4 10             	add    $0x10,%esp
}
  8017e1:	c9                   	leave  
  8017e2:	c3                   	ret    

008017e3 <shutdown>:

int
shutdown(int s, int how)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	e8 f3 fe ff ff       	call   8016e4 <fd2sockid>
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 0f                	js     801804 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	ff 75 0c             	pushl  0xc(%ebp)
  8017fb:	50                   	push   %eax
  8017fc:	e8 3f 01 00 00       	call   801940 <nsipc_shutdown>
  801801:	83 c4 10             	add    $0x10,%esp
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	e8 d0 fe ff ff       	call   8016e4 <fd2sockid>
  801814:	85 c0                	test   %eax,%eax
  801816:	78 12                	js     80182a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801818:	83 ec 04             	sub    $0x4,%esp
  80181b:	ff 75 10             	pushl  0x10(%ebp)
  80181e:	ff 75 0c             	pushl  0xc(%ebp)
  801821:	50                   	push   %eax
  801822:	e8 55 01 00 00       	call   80197c <nsipc_connect>
  801827:	83 c4 10             	add    $0x10,%esp
}
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <listen>:

int
listen(int s, int backlog)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801832:	8b 45 08             	mov    0x8(%ebp),%eax
  801835:	e8 aa fe ff ff       	call   8016e4 <fd2sockid>
  80183a:	85 c0                	test   %eax,%eax
  80183c:	78 0f                	js     80184d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80183e:	83 ec 08             	sub    $0x8,%esp
  801841:	ff 75 0c             	pushl  0xc(%ebp)
  801844:	50                   	push   %eax
  801845:	e8 67 01 00 00       	call   8019b1 <nsipc_listen>
  80184a:	83 c4 10             	add    $0x10,%esp
}
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801855:	ff 75 10             	pushl  0x10(%ebp)
  801858:	ff 75 0c             	pushl  0xc(%ebp)
  80185b:	ff 75 08             	pushl  0x8(%ebp)
  80185e:	e8 3a 02 00 00       	call   801a9d <nsipc_socket>
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	85 c0                	test   %eax,%eax
  801868:	78 05                	js     80186f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80186a:	e8 a5 fe ff ff       	call   801714 <alloc_sockfd>
}
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	53                   	push   %ebx
  801875:	83 ec 04             	sub    $0x4,%esp
  801878:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80187a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801881:	75 12                	jne    801895 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801883:	83 ec 0c             	sub    $0xc,%esp
  801886:	6a 02                	push   $0x2
  801888:	e8 9c f5 ff ff       	call   800e29 <ipc_find_env>
  80188d:	a3 04 40 80 00       	mov    %eax,0x804004
  801892:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801895:	6a 07                	push   $0x7
  801897:	68 00 60 80 00       	push   $0x806000
  80189c:	53                   	push   %ebx
  80189d:	ff 35 04 40 80 00    	pushl  0x804004
  8018a3:	e8 2d f5 ff ff       	call   800dd5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018a8:	83 c4 0c             	add    $0xc,%esp
  8018ab:	6a 00                	push   $0x0
  8018ad:	6a 00                	push   $0x0
  8018af:	6a 00                	push   $0x0
  8018b1:	e8 b8 f4 ff ff       	call   800d6e <ipc_recv>
}
  8018b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
  8018c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018cb:	8b 06                	mov    (%esi),%eax
  8018cd:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d7:	e8 95 ff ff ff       	call   801871 <nsipc>
  8018dc:	89 c3                	mov    %eax,%ebx
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 20                	js     801902 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018e2:	83 ec 04             	sub    $0x4,%esp
  8018e5:	ff 35 10 60 80 00    	pushl  0x806010
  8018eb:	68 00 60 80 00       	push   $0x806000
  8018f0:	ff 75 0c             	pushl  0xc(%ebp)
  8018f3:	e8 b3 ef ff ff       	call   8008ab <memmove>
		*addrlen = ret->ret_addrlen;
  8018f8:	a1 10 60 80 00       	mov    0x806010,%eax
  8018fd:	89 06                	mov    %eax,(%esi)
  8018ff:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801902:	89 d8                	mov    %ebx,%eax
  801904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801907:	5b                   	pop    %ebx
  801908:	5e                   	pop    %esi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	53                   	push   %ebx
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80191d:	53                   	push   %ebx
  80191e:	ff 75 0c             	pushl  0xc(%ebp)
  801921:	68 04 60 80 00       	push   $0x806004
  801926:	e8 80 ef ff ff       	call   8008ab <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80192b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801931:	b8 02 00 00 00       	mov    $0x2,%eax
  801936:	e8 36 ff ff ff       	call   801871 <nsipc>
}
  80193b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80194e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801951:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801956:	b8 03 00 00 00       	mov    $0x3,%eax
  80195b:	e8 11 ff ff ff       	call   801871 <nsipc>
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <nsipc_close>:

int
nsipc_close(int s)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801970:	b8 04 00 00 00       	mov    $0x4,%eax
  801975:	e8 f7 fe ff ff       	call   801871 <nsipc>
}
  80197a:	c9                   	leave  
  80197b:	c3                   	ret    

0080197c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	53                   	push   %ebx
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80198e:	53                   	push   %ebx
  80198f:	ff 75 0c             	pushl  0xc(%ebp)
  801992:	68 04 60 80 00       	push   $0x806004
  801997:	e8 0f ef ff ff       	call   8008ab <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80199c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8019a7:	e8 c5 fe ff ff       	call   801871 <nsipc>
}
  8019ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019c7:	b8 06 00 00 00       	mov    $0x6,%eax
  8019cc:	e8 a0 fe ff ff       	call   801871 <nsipc>
}
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    

008019d3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
  8019d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019db:	8b 45 08             	mov    0x8(%ebp),%eax
  8019de:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019e3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ec:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019f1:	b8 07 00 00 00       	mov    $0x7,%eax
  8019f6:	e8 76 fe ff ff       	call   801871 <nsipc>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 35                	js     801a36 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a01:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a06:	7f 04                	jg     801a0c <nsipc_recv+0x39>
  801a08:	39 c6                	cmp    %eax,%esi
  801a0a:	7d 16                	jge    801a22 <nsipc_recv+0x4f>
  801a0c:	68 13 27 80 00       	push   $0x802713
  801a11:	68 db 26 80 00       	push   $0x8026db
  801a16:	6a 62                	push   $0x62
  801a18:	68 28 27 80 00       	push   $0x802728
  801a1d:	e8 84 05 00 00       	call   801fa6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a22:	83 ec 04             	sub    $0x4,%esp
  801a25:	50                   	push   %eax
  801a26:	68 00 60 80 00       	push   $0x806000
  801a2b:	ff 75 0c             	pushl  0xc(%ebp)
  801a2e:	e8 78 ee ff ff       	call   8008ab <memmove>
  801a33:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a36:	89 d8                	mov    %ebx,%eax
  801a38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	53                   	push   %ebx
  801a43:	83 ec 04             	sub    $0x4,%esp
  801a46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a51:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a57:	7e 16                	jle    801a6f <nsipc_send+0x30>
  801a59:	68 34 27 80 00       	push   $0x802734
  801a5e:	68 db 26 80 00       	push   $0x8026db
  801a63:	6a 6d                	push   $0x6d
  801a65:	68 28 27 80 00       	push   $0x802728
  801a6a:	e8 37 05 00 00       	call   801fa6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a6f:	83 ec 04             	sub    $0x4,%esp
  801a72:	53                   	push   %ebx
  801a73:	ff 75 0c             	pushl  0xc(%ebp)
  801a76:	68 0c 60 80 00       	push   $0x80600c
  801a7b:	e8 2b ee ff ff       	call   8008ab <memmove>
	nsipcbuf.send.req_size = size;
  801a80:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a86:	8b 45 14             	mov    0x14(%ebp),%eax
  801a89:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a8e:	b8 08 00 00 00       	mov    $0x8,%eax
  801a93:	e8 d9 fd ff ff       	call   801871 <nsipc>
}
  801a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aae:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ab3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801abb:	b8 09 00 00 00       	mov    $0x9,%eax
  801ac0:	e8 ac fd ff ff       	call   801871 <nsipc>
}
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801acf:	83 ec 0c             	sub    $0xc,%esp
  801ad2:	ff 75 08             	pushl  0x8(%ebp)
  801ad5:	e8 98 f3 ff ff       	call   800e72 <fd2data>
  801ada:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801adc:	83 c4 08             	add    $0x8,%esp
  801adf:	68 40 27 80 00       	push   $0x802740
  801ae4:	53                   	push   %ebx
  801ae5:	e8 2f ec ff ff       	call   800719 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aea:	8b 46 04             	mov    0x4(%esi),%eax
  801aed:	2b 06                	sub    (%esi),%eax
  801aef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801af5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801afc:	00 00 00 
	stat->st_dev = &devpipe;
  801aff:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b06:	30 80 00 
	return 0;
}
  801b09:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	53                   	push   %ebx
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b1f:	53                   	push   %ebx
  801b20:	6a 00                	push   $0x0
  801b22:	e8 7a f0 ff ff       	call   800ba1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b27:	89 1c 24             	mov    %ebx,(%esp)
  801b2a:	e8 43 f3 ff ff       	call   800e72 <fd2data>
  801b2f:	83 c4 08             	add    $0x8,%esp
  801b32:	50                   	push   %eax
  801b33:	6a 00                	push   $0x0
  801b35:	e8 67 f0 ff ff       	call   800ba1 <sys_page_unmap>
}
  801b3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3d:	c9                   	leave  
  801b3e:	c3                   	ret    

00801b3f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	57                   	push   %edi
  801b43:	56                   	push   %esi
  801b44:	53                   	push   %ebx
  801b45:	83 ec 1c             	sub    $0x1c,%esp
  801b48:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b4b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b4d:	a1 08 40 80 00       	mov    0x804008,%eax
  801b52:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	ff 75 e0             	pushl  -0x20(%ebp)
  801b5b:	e8 8c 04 00 00       	call   801fec <pageref>
  801b60:	89 c3                	mov    %eax,%ebx
  801b62:	89 3c 24             	mov    %edi,(%esp)
  801b65:	e8 82 04 00 00       	call   801fec <pageref>
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	39 c3                	cmp    %eax,%ebx
  801b6f:	0f 94 c1             	sete   %cl
  801b72:	0f b6 c9             	movzbl %cl,%ecx
  801b75:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b78:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b7e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b81:	39 ce                	cmp    %ecx,%esi
  801b83:	74 1b                	je     801ba0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b85:	39 c3                	cmp    %eax,%ebx
  801b87:	75 c4                	jne    801b4d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b89:	8b 42 58             	mov    0x58(%edx),%eax
  801b8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b8f:	50                   	push   %eax
  801b90:	56                   	push   %esi
  801b91:	68 47 27 80 00       	push   $0x802747
  801b96:	e8 f9 e5 ff ff       	call   800194 <cprintf>
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	eb ad                	jmp    801b4d <_pipeisclosed+0xe>
	}
}
  801ba0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba6:	5b                   	pop    %ebx
  801ba7:	5e                   	pop    %esi
  801ba8:	5f                   	pop    %edi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	57                   	push   %edi
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 28             	sub    $0x28,%esp
  801bb4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bb7:	56                   	push   %esi
  801bb8:	e8 b5 f2 ff ff       	call   800e72 <fd2data>
  801bbd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	bf 00 00 00 00       	mov    $0x0,%edi
  801bc7:	eb 4b                	jmp    801c14 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bc9:	89 da                	mov    %ebx,%edx
  801bcb:	89 f0                	mov    %esi,%eax
  801bcd:	e8 6d ff ff ff       	call   801b3f <_pipeisclosed>
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	75 48                	jne    801c1e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bd6:	e8 22 ef ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bdb:	8b 43 04             	mov    0x4(%ebx),%eax
  801bde:	8b 0b                	mov    (%ebx),%ecx
  801be0:	8d 51 20             	lea    0x20(%ecx),%edx
  801be3:	39 d0                	cmp    %edx,%eax
  801be5:	73 e2                	jae    801bc9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bea:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bee:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bf1:	89 c2                	mov    %eax,%edx
  801bf3:	c1 fa 1f             	sar    $0x1f,%edx
  801bf6:	89 d1                	mov    %edx,%ecx
  801bf8:	c1 e9 1b             	shr    $0x1b,%ecx
  801bfb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bfe:	83 e2 1f             	and    $0x1f,%edx
  801c01:	29 ca                	sub    %ecx,%edx
  801c03:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c07:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c0b:	83 c0 01             	add    $0x1,%eax
  801c0e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c11:	83 c7 01             	add    $0x1,%edi
  801c14:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c17:	75 c2                	jne    801bdb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c19:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1c:	eb 05                	jmp    801c23 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c1e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5f                   	pop    %edi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	57                   	push   %edi
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	83 ec 18             	sub    $0x18,%esp
  801c34:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c37:	57                   	push   %edi
  801c38:	e8 35 f2 ff ff       	call   800e72 <fd2data>
  801c3d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c47:	eb 3d                	jmp    801c86 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c49:	85 db                	test   %ebx,%ebx
  801c4b:	74 04                	je     801c51 <devpipe_read+0x26>
				return i;
  801c4d:	89 d8                	mov    %ebx,%eax
  801c4f:	eb 44                	jmp    801c95 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c51:	89 f2                	mov    %esi,%edx
  801c53:	89 f8                	mov    %edi,%eax
  801c55:	e8 e5 fe ff ff       	call   801b3f <_pipeisclosed>
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	75 32                	jne    801c90 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c5e:	e8 9a ee ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c63:	8b 06                	mov    (%esi),%eax
  801c65:	3b 46 04             	cmp    0x4(%esi),%eax
  801c68:	74 df                	je     801c49 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c6a:	99                   	cltd   
  801c6b:	c1 ea 1b             	shr    $0x1b,%edx
  801c6e:	01 d0                	add    %edx,%eax
  801c70:	83 e0 1f             	and    $0x1f,%eax
  801c73:	29 d0                	sub    %edx,%eax
  801c75:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c7d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c80:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c83:	83 c3 01             	add    $0x1,%ebx
  801c86:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c89:	75 d8                	jne    801c63 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8e:	eb 05                	jmp    801c95 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c90:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c98:	5b                   	pop    %ebx
  801c99:	5e                   	pop    %esi
  801c9a:	5f                   	pop    %edi
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ca5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca8:	50                   	push   %eax
  801ca9:	e8 db f1 ff ff       	call   800e89 <fd_alloc>
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	89 c2                	mov    %eax,%edx
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	0f 88 2c 01 00 00    	js     801de7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbb:	83 ec 04             	sub    $0x4,%esp
  801cbe:	68 07 04 00 00       	push   $0x407
  801cc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 4f ee ff ff       	call   800b1c <sys_page_alloc>
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	89 c2                	mov    %eax,%edx
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 0d 01 00 00    	js     801de7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce0:	50                   	push   %eax
  801ce1:	e8 a3 f1 ff ff       	call   800e89 <fd_alloc>
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	83 c4 10             	add    $0x10,%esp
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	0f 88 e2 00 00 00    	js     801dd5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf3:	83 ec 04             	sub    $0x4,%esp
  801cf6:	68 07 04 00 00       	push   $0x407
  801cfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 17 ee ff ff       	call   800b1c <sys_page_alloc>
  801d05:	89 c3                	mov    %eax,%ebx
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	0f 88 c3 00 00 00    	js     801dd5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	ff 75 f4             	pushl  -0xc(%ebp)
  801d18:	e8 55 f1 ff ff       	call   800e72 <fd2data>
  801d1d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1f:	83 c4 0c             	add    $0xc,%esp
  801d22:	68 07 04 00 00       	push   $0x407
  801d27:	50                   	push   %eax
  801d28:	6a 00                	push   $0x0
  801d2a:	e8 ed ed ff ff       	call   800b1c <sys_page_alloc>
  801d2f:	89 c3                	mov    %eax,%ebx
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	0f 88 89 00 00 00    	js     801dc5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3c:	83 ec 0c             	sub    $0xc,%esp
  801d3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d42:	e8 2b f1 ff ff       	call   800e72 <fd2data>
  801d47:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d4e:	50                   	push   %eax
  801d4f:	6a 00                	push   $0x0
  801d51:	56                   	push   %esi
  801d52:	6a 00                	push   $0x0
  801d54:	e8 06 ee ff ff       	call   800b5f <sys_page_map>
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	83 c4 20             	add    $0x20,%esp
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 55                	js     801db7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d62:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d70:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d77:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d80:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d85:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d8c:	83 ec 0c             	sub    $0xc,%esp
  801d8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d92:	e8 cb f0 ff ff       	call   800e62 <fd2num>
  801d97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d9a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d9c:	83 c4 04             	add    $0x4,%esp
  801d9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801da2:	e8 bb f0 ff ff       	call   800e62 <fd2num>
  801da7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801daa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	ba 00 00 00 00       	mov    $0x0,%edx
  801db5:	eb 30                	jmp    801de7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801db7:	83 ec 08             	sub    $0x8,%esp
  801dba:	56                   	push   %esi
  801dbb:	6a 00                	push   $0x0
  801dbd:	e8 df ed ff ff       	call   800ba1 <sys_page_unmap>
  801dc2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dc5:	83 ec 08             	sub    $0x8,%esp
  801dc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801dcb:	6a 00                	push   $0x0
  801dcd:	e8 cf ed ff ff       	call   800ba1 <sys_page_unmap>
  801dd2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dd5:	83 ec 08             	sub    $0x8,%esp
  801dd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddb:	6a 00                	push   $0x0
  801ddd:	e8 bf ed ff ff       	call   800ba1 <sys_page_unmap>
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801de7:	89 d0                	mov    %edx,%eax
  801de9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    

00801df0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df9:	50                   	push   %eax
  801dfa:	ff 75 08             	pushl  0x8(%ebp)
  801dfd:	e8 d6 f0 ff ff       	call   800ed8 <fd_lookup>
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 18                	js     801e21 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e09:	83 ec 0c             	sub    $0xc,%esp
  801e0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0f:	e8 5e f0 ff ff       	call   800e72 <fd2data>
	return _pipeisclosed(fd, p);
  801e14:	89 c2                	mov    %eax,%edx
  801e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e19:	e8 21 fd ff ff       	call   801b3f <_pipeisclosed>
  801e1e:	83 c4 10             	add    $0x10,%esp
}
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e26:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e33:	68 5f 27 80 00       	push   $0x80275f
  801e38:	ff 75 0c             	pushl  0xc(%ebp)
  801e3b:	e8 d9 e8 ff ff       	call   800719 <strcpy>
	return 0;
}
  801e40:	b8 00 00 00 00       	mov    $0x0,%eax
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	57                   	push   %edi
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
  801e4d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e53:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e58:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e5e:	eb 2d                	jmp    801e8d <devcons_write+0x46>
		m = n - tot;
  801e60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e63:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e65:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e68:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e6d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e70:	83 ec 04             	sub    $0x4,%esp
  801e73:	53                   	push   %ebx
  801e74:	03 45 0c             	add    0xc(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	57                   	push   %edi
  801e79:	e8 2d ea ff ff       	call   8008ab <memmove>
		sys_cputs(buf, m);
  801e7e:	83 c4 08             	add    $0x8,%esp
  801e81:	53                   	push   %ebx
  801e82:	57                   	push   %edi
  801e83:	e8 d8 eb ff ff       	call   800a60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e88:	01 de                	add    %ebx,%esi
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	89 f0                	mov    %esi,%eax
  801e8f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e92:	72 cc                	jb     801e60 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 08             	sub    $0x8,%esp
  801ea2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ea7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eab:	74 2a                	je     801ed7 <devcons_read+0x3b>
  801ead:	eb 05                	jmp    801eb4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eaf:	e8 49 ec ff ff       	call   800afd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eb4:	e8 c5 eb ff ff       	call   800a7e <sys_cgetc>
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	74 f2                	je     801eaf <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	78 16                	js     801ed7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ec1:	83 f8 04             	cmp    $0x4,%eax
  801ec4:	74 0c                	je     801ed2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ec6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec9:	88 02                	mov    %al,(%edx)
	return 1;
  801ecb:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed0:	eb 05                	jmp    801ed7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ed2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801edf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ee5:	6a 01                	push   $0x1
  801ee7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eea:	50                   	push   %eax
  801eeb:	e8 70 eb ff ff       	call   800a60 <sys_cputs>
}
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    

00801ef5 <getchar>:

int
getchar(void)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801efb:	6a 01                	push   $0x1
  801efd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f00:	50                   	push   %eax
  801f01:	6a 00                	push   $0x0
  801f03:	e8 36 f2 ff ff       	call   80113e <read>
	if (r < 0)
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	78 0f                	js     801f1e <getchar+0x29>
		return r;
	if (r < 1)
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	7e 06                	jle    801f19 <getchar+0x24>
		return -E_EOF;
	return c;
  801f13:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f17:	eb 05                	jmp    801f1e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f19:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f29:	50                   	push   %eax
  801f2a:	ff 75 08             	pushl  0x8(%ebp)
  801f2d:	e8 a6 ef ff ff       	call   800ed8 <fd_lookup>
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	85 c0                	test   %eax,%eax
  801f37:	78 11                	js     801f4a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f42:	39 10                	cmp    %edx,(%eax)
  801f44:	0f 94 c0             	sete   %al
  801f47:	0f b6 c0             	movzbl %al,%eax
}
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <opencons>:

int
opencons(void)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f55:	50                   	push   %eax
  801f56:	e8 2e ef ff ff       	call   800e89 <fd_alloc>
  801f5b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f5e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 3e                	js     801fa2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f64:	83 ec 04             	sub    $0x4,%esp
  801f67:	68 07 04 00 00       	push   $0x407
  801f6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 a6 eb ff ff       	call   800b1c <sys_page_alloc>
  801f76:	83 c4 10             	add    $0x10,%esp
		return r;
  801f79:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	78 23                	js     801fa2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f7f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f88:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f94:	83 ec 0c             	sub    $0xc,%esp
  801f97:	50                   	push   %eax
  801f98:	e8 c5 ee ff ff       	call   800e62 <fd2num>
  801f9d:	89 c2                	mov    %eax,%edx
  801f9f:	83 c4 10             	add    $0x10,%esp
}
  801fa2:	89 d0                	mov    %edx,%eax
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    

00801fa6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	56                   	push   %esi
  801faa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fab:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fae:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fb4:	e8 25 eb ff ff       	call   800ade <sys_getenvid>
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	ff 75 0c             	pushl  0xc(%ebp)
  801fbf:	ff 75 08             	pushl  0x8(%ebp)
  801fc2:	56                   	push   %esi
  801fc3:	50                   	push   %eax
  801fc4:	68 6c 27 80 00       	push   $0x80276c
  801fc9:	e8 c6 e1 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fce:	83 c4 18             	add    $0x18,%esp
  801fd1:	53                   	push   %ebx
  801fd2:	ff 75 10             	pushl  0x10(%ebp)
  801fd5:	e8 69 e1 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801fda:	c7 04 24 58 27 80 00 	movl   $0x802758,(%esp)
  801fe1:	e8 ae e1 ff ff       	call   800194 <cprintf>
  801fe6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fe9:	cc                   	int3   
  801fea:	eb fd                	jmp    801fe9 <_panic+0x43>

00801fec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fec:	55                   	push   %ebp
  801fed:	89 e5                	mov    %esp,%ebp
  801fef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff2:	89 d0                	mov    %edx,%eax
  801ff4:	c1 e8 16             	shr    $0x16,%eax
  801ff7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802003:	f6 c1 01             	test   $0x1,%cl
  802006:	74 1d                	je     802025 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802008:	c1 ea 0c             	shr    $0xc,%edx
  80200b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802012:	f6 c2 01             	test   $0x1,%dl
  802015:	74 0e                	je     802025 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802017:	c1 ea 0c             	shr    $0xc,%edx
  80201a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802021:	ef 
  802022:	0f b7 c0             	movzwl %ax,%eax
}
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    
  802027:	66 90                	xchg   %ax,%ax
  802029:	66 90                	xchg   %ax,%ax
  80202b:	66 90                	xchg   %ax,%ax
  80202d:	66 90                	xchg   %ax,%ax
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
